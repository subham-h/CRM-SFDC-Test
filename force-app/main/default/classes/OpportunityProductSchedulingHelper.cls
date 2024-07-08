/*      
* Revision      Ref Number      Date            Owner                       Description
* --------      ----------      -----------     -------------------         -------------------------
* 1.1           SFSE-10984      23-May-2023     Kiran@Maersk                To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 2.0           SFSE-13638      30-Jan-2024     Samar@maersk.com             Opportunity product revenue schedule
*/

public class OpportunityProductSchedulingHelper {
    
    public static void scheduleOppLineItem(list<Opportunity_Product__c> lstOppProducts, list<Opportunity_Product__c> lstOldOppLineItems, Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        system.debug('@@@scheduleOppLineItem' + lstOppProducts);
        InsertUpdateOliLineItem(lstOppProducts,lstOldOppLineItems,opportunityMap,OpportunityClosedmap);
    }
    
    public static void InsertUpdateOliLineItem(List<Opportunity_Product__c> lstOppProducts, List<Opportunity_Product__c> lstOldOppLineItems,Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        
        system.debug('@@@@' + lstOppProducts);
        
        Boolean isInsertSchedules=false;
        set<Id> oppIds = new set<Id>();//  to store curent opportunity Ids
        
        List<Opportunity_Product__c> insertSchedulesLst = new List<Opportunity_Product__c>();
        Map<id,List<Opportunity_Product__c>> OppToOpptyProdmMap = new Map<id,List<Opportunity_Product__c>>();// this Map will contain unassigned and other OLis
        
        try{
            //Iterating opportunity line items and forming the map of Opportunity Ids and its list of OLIs
            for(Opportunity_Product__c oli:lstOppProducts){
                
                //if(oli.PricebookentryId != Label.UnassignedPriceBookEntryID){
                if(OppToOpptyProdmMap.containsKey(oli.OpportunityId__c)){           
                    OppToOpptyProdmMap.get(oli.OpportunityId__c).add(oli);                      
                }else{
                    OppToOpptyProdmMap.Put(oli.OpportunityId__c, new List<Opportunity_Product__c>{oli});        
                } 
                
                oppIds.add(oli.opportunityId__c);     
                //}
            }  
            
            system.debug('oppIds ' + oppIds);
            //calculate the other line items quantity and unassigned quantity for the each opportunity
            for(Id oppId:oppIds){
                if(OppToOpptyProdmMap.containsKey(oppId)){
                    Decimal otherOliQuantity=0.0;
                    for(Opportunity_Product__c opptyProd:OppToOpptyProdmMap.get(oppId)){
                        // SFSE-8606 if(OppToLineItemMap.containsKey(oppId)){
                        otherOliQuantity += opptyProd.Quantity__c;
                        system.debug('otherOliQuantity ' + otherOliQuantity);
                        //} 
                    }
                    
                }
            }
            
            //Create schedules for newly created line items and updated line items
            
            if(trigger.isInsert){
                for(Opportunity_Product__c optyProdInsert : lstOppProducts){
                    if( opportunityMap !=null && opportunityMap.containsKey(optyProdInsert.opportunityId__c) && optyProdInsert.Opt_Out_Auto_Quantity_Scheduling__c == False && (opportunityMap.get(optyProdInsert.opportunityId__c).First_Shipment_Date__c != null || opportunityMap.get(optyProdInsert.opportunityId__c).Last_Shipment_Date__c != null)){
                        insertSchedulesLst.add(optyProdInsert);
                    }
                }
            }
            
            system.debug('insertSchedulesLst: ' + insertSchedulesLst);
            if( ! insertSchedulesLst.isEmpty()){
                
                // Generate the Opportunity Product Schedules for new Product.
                List<Opportunity_Product_Schedule__c> lineItemSchedule =  ScheduleOpportunityProducts.PrepareProductSchedules(opportunityMap, insertSchedulesLst);
                system.debug('opptylineitemschedulinghelper:lineItemSchedule' + lineItemSchedule);
                // Insert Product Schedules and Insert Other Product with remainining QTY Update the FFE on Opportunity
                if( lineItemSchedule.size()>0  )
                {
                    system.debug('lineItemSchedule ' + lineItemSchedule);
                    List<Database.SaveResult> oliUpdateResultList=Database.insert(lineItemSchedule,false);
                    ErrorLogger.writeErrors('SFDC', 'OpportunityProductSchedulingHelper', 'OpportunityProductSchedulingHelper.InsertUpdateOliLineItem', oliUpdateResultList, lineItemSchedule) ; // #RQ-005636
                }
            }
            
        }catch(exception e){
            
        }
    }
    
    public static void OppLineItemOnDelete(Map<id,Opportunity_Product__c> oldOpptyLineItems,Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        
        InsertUpdateOliLineItem(oldOpptyLineItems.values(),oldOpptyLineItems.values(),opportunityMap,OpportunityClosedmap);
        
    }
    
    //method displaying error messages on delete of unassigned route direction and other line item for closed opportunity
    public static void validateoliOnDelete(Map<id,Opportunity_Product__c> oldOppLineItemMap, Map<id,Boolean> OpportunityClosedmap,Boolean VRBypassIsActive){
        
        for(Opportunity_Product__c oldOli:oldOppLineItemMap.values()){
            /*
            if(oldOli.PricebookentryId == Label.UnassignedPriceBookEntryID){
            oldOli.addError(Label.CannotDeleteUnassigned);
            }else */
            if( OpportunityClosedmap.get(oldOli.OpportunityId__c)!=null && OpportunityClosedmap.get(oldOli.OpportunityId__c) == True  && VRBypassIsActive != true ){
                oldOli.addError(' '+Label.ExpectedErrorLabel);
            }
        }
    }

    // Method to delete schedule of the source/ Original Opportunity which is not created via cloning
    public static void deleteDefaultScheduleOppLineItem(List<Opportunity_Product__c> oLIItems, Boolean checkIsNotCloned){
        
        Set<Id> setOLIIds = new Set<Id>(); // set of Opportunity Line items whose schedules needs to be deleted        
        for(Opportunity_Product__c oli: oLIItems){
            setOLIIds.add(oli.Id);            
        }
        
        String strQuery = 'SELECT Id, Opportunity_Product__c, Quantity__c, Revenue__c, Schedule_Date__c, Type__c FROM Opportunity_Product_Schedule__c WHERE Opportunity_Product__c IN:setOLIIds ';
        if (checkIsNotCloned){
            strQuery += '  AND isClonedrecord__c = false ';
        }
        
        List<Opportunity_Product_Schedule__c> lstOpptyLineItemSchedule = Database.Query(strQuery);
        List<Opportunity_Product_Schedule__c> lstOpLISchToDel = new List<Opportunity_Product_Schedule__c>();
        /*for(OpportunityLineItemSchedule opsc : lstOpptyLineItemSchedule){
            system.debug('opsc==>'+opsc.getCloneSourceId());
            //if(opsc.getCloneSourceId()!=null){
            lstOpptyLineItemSchedule.add(opsc);
            }//
            }*/
        System.debug('delteDefaultScheduleOppLineItem  lstOpptyLineItemSchedule::: '+lstOpptyLineItemSchedule);
        if(lstOpptyLineItemSchedule.size() > 0){   
            
            //delete lstOpportunityLineItemSchedule;
            TriggerExecutionController.skipOpportunityProductTrigger(true);
            List<Database.DeleteResult> lstOliSchdlsDeleteResult = Database.delete(lstOpptyLineItemSchedule, false ); 
            TriggerExecutionController.skipOpportunityProductTrigger(false);                
            ErrorLogger.writeErrors('SFDC', 'OpportunityProductSchedulingHelper', 'OpportunityProductSchedulingHelper.deleteDefaultScheduleOppLineItem', lstOliSchdlsDeleteResult, lstOpptyLineItemSchedule) ;  
        }        
    }
    
    // Method to process the OLI records for which Amend_Expected_FFE__c is updated so that it should reflect as OLI quantity and schedule records should be created based on new Quantity
    public static void reCreateScheduleOppLineItem(List<Opportunity_Product__c> oLIItems, boolean isCloned){
        system.debug('lstOppToBeUpdated' + oLIItems);   
        Set<Id> setOLIIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOrignalOliIds = new Set<Id>();
        Map<Id,Decimal> oliIDToSalesPriceMap = new Map<Id,Decimal>();
        for(Opportunity_Product__c oli: oLIItems){
            setOLIIds.add(oli.Id);
            setOppIds.add(oli.OpportunityId__c);
            oliIDToSalesPriceMap.put(oli.Id,oli.UnitPrice__c);
            //setOrignalOliIds.add(oli.loneSourceId());
            system.debug('Original ID==>'+oli.getCloneSourceId());
        }
        // Fetch the schedule records
        List<Opportunity_Product_Schedule__c> lstOpportunityLineItemSchedule = [SELECT Id, Opportunity_Product__c, Quantity__c, Revenue__c, Schedule_Date__c, Type__c 
                                                                                FROM Opportunity_Product_Schedule__c 
                                                                                WHERE Opportunity_Product__c IN:setOLIIds];          
        system.debug('lstOpportunityLineItemSchedule-->>'+lstOpportunityLineItemSchedule);
        if(lstOpportunityLineItemSchedule != null){
            TriggerExecutionController.skipOpportunityProductTrigger(true);
            List<Database.DeleteResult> lstOliSchdlsDeleteResult = Database.delete(lstOpportunityLineItemSchedule, false ); 
            TriggerExecutionController.skipOpportunityProductTrigger(false);                
            ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'OpportunityProductSchedulingHelper.reCreateScheduleOppLineItem', lstOliSchdlsDeleteResult, lstOpportunityLineItemSchedule) ;             
        }
        system.debug('@@@after delete schedule');
        // Fetch the corresponding opportunity for updating the opportunity Expected FFE
        Map<Id,Opportunity> mapOfOpp = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Quantity, Amend_Expected_FFE__c FROM OpportunityLineItems),First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE Id IN :setOppIds]);
        
        if(mapOfOpp != null){
            //ScheduleOpportunityProducts sopp = new ScheduleOpportunityProducts();
            List<Opportunity_Product_Schedule__c> lstLineItemSchedule = ScheduleOpportunityProducts.PrepareProductSchedules(mapOfOpp, oLIItems);
            List<Opportunity> lstOppToBeUpdated = new List<Opportunity>();
            if( lstLineItemSchedule.size()>0 ){
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                for(Opportunity_Product_Schedule__c oLisch: lstLineItemSchedule) {
                    if(isCloned){
                        oLisch.isClonedrecord__c = true; // Setting this floag to true for custom records. created for sfse-6737
                    } 
                }
                System.debug(' ##### lstLineItemSchedule '+lstLineItemSchedule);
                List<Database.SaveResult> oliUpdateResultList=Database.insert(lstLineItemSchedule,false);                               
                ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'OpportunityProductSchedulingHelper.reCreateScheduleOppLineItem',  oliUpdateResultList, lstLineItemSchedule) ; 
                TriggerExecutionController.skipOpportunityProductTrigger(false);
                
                Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(oLIItems);
                Map<Id,Opportunity_Product__c> mapOfOliIDToOli = new Map<Id,Opportunity_Product__c> ();
                for(Opportunity_Product_Schedule__c oLisch: lstLineItemSchedule) {
                    If(!mapOfOliIDToOli.containsKey(oLisch.Opportunity_Product__c)) { 
                        Decimal oliUniPrice = oliIDToSalesPriceMap.get(oLisch.Opportunity_Product__c);
                        String strSchDet = mapOliIdToSchDetails.get(oLisch.Opportunity_Product__c );
                        system.debug('oliUniPrice' + oliUniPrice);
                        mapOfOliIDToOli.put(oLisch.Opportunity_Product__c,new Opportunity_Product__c(Id=oLisch.Opportunity_Product__c,UnitPrice__c = oliUniPrice, Schedule_Details__c = strSchDet));
                        system.debug('mapOfOliIDToOli' + mapOfOliIDToOli);
                    }
                }
                if(mapOfOliIDToOli.size()> 0) {
                    try {
                        TriggerExecutionController.skipOpportunityProductTrigger(true);
                        system.debug('mapOfOliIDToOli' + mapOfOliIDToOli);
                        update mapOfOliIDToOli.values();
                        TriggerExecutionController.skipOpportunityProductTrigger(false); 
                    } catch (Exception e) {
                        
                    }
                }
            } 
        }
        
    }
    
    
    public static void setScheduleDetailsOnOLI(List<Opportunity_Product__c> pOliNewLst, map<Id, Opportunity_Product__c> pOliOldMap){
        
        Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(pOliNewLst);
        List<Opportunity_Product__c> lstOliToUpdate = new List<Opportunity_Product__c>();
        
        Map<Id,Decimal> mapofOliIDtoOldSalesPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofOliIdtoNewSalesPrice = new Map<Id,Decimal>();
        for(Opportunity_Product__c oliN : pOliNewLst)
        {                        
            Opportunity_Product__c OLIOld =  pOliOldMap.get(oliN.Id);
            mapofOliIdtoNewSalesPrice.put(oliN.Id,oliN.UnitPrice__c);
            if( OLIOld.Quantity__c != 0 && oliN.Quantity__c != OLIOld.Quantity__c ) {
                mapofOliIDtoOldSalesPrice.put(oliN.Id, OLIOld.UnitPrice__c);
            }
        }
        system.debug('mapofOliIDtoOldSalesPrice' + mapofOliIDtoOldSalesPrice);
        
        for (Opportunity_Product__c oli : pOliNewLst){
            String strScheduleDetails = mapOliIdToSchDetails.get(oli.Id);
            Decimal oliPriorSalesPrice = mapofOliIDtoOldSalesPrice.get(oli.Id);
            Decimal oliNewSalesPrice = mapofOliIdtoNewSalesPrice.get(oli.Id); //#RQ-009890
            Opportunity_Product__c oliRec = new Opportunity_Product__c();
            oliRec.Id = oli.Id;
            // schdule has changed and opt out is not enabled 
            if ( pOliOldMap.get(oli.Id).Schedule_Details__c != strScheduleDetails
                && (((pOliOldMap.get(oli.Id).Quantity__c != oli.Quantity__c))|| ((pOliOldMap.get(oli.Id).Total_Price__c  != oli.Total_Price__c ) && (pOliOldMap.get(oli.Id).UnitPrice__c != oli.UnitPrice__c))) //RQ-010441 - Mod-02 - Included additional condition related to 'TotalPrice' and 'UnitPrice'
                && oli.Amend_Expected_FFE__c == null
                && oli.Opt_Out_Auto_Quantity_Scheduling__c == false){
                    
                    oliRec.Opt_Out_Auto_Quantity_Scheduling__c = true;
                }
            oliRec.Schedule_Details__c = strScheduleDetails;    
            oliRec.UnitPrice__c = (oliPriorSalesPrice==null) ? oliNewSalesPrice : oliPriorSalesPrice; //#RQ-009890
            lstOliToUpdate.add(oliRec);
        } 
        
        if (lstOliToUpdate.size() > 0){
            TriggerExecutionController.skipOpportunityProductTrigger(true);
            List<Database.SaveResult> lstOliUpdResult = Database.update(lstOliToUpdate,false);
            System.debug('lstOliUpdResult'+lstOliUpdResult);
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLI',  lstOliUpdResult, lstOliToUpdate) ; 
            TriggerExecutionController.skipOpportunityProductTrigger(false);
        }
    }
    
    
    public static void setScheduleDetailsOnOLIAfterInsert(List<Opportunity_Product__c> pListNewOli){
        system.debug('in setScheduleDetailsOnOLIAfterInsert');
        Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(pListNewOli);
        List<Opportunity_Product__c> lstOliToUpdate = new List<Opportunity_Product__c>();
        
        for (Id oRecId : mapOliIdToSchDetails.keyset()){
            Opportunity_Product__c oliRec = new Opportunity_Product__c();
            oliRec.Id = oRecId;
            oliRec.Schedule_Details__c = mapOliIdToSchDetails.get(oRecId);
            
            lstOliToUpdate.add(oliRec);
        }
        
        if (lstOliToUpdate.size() > 0){
            TriggerExecutionController.skipOpportunityProductTrigger(true);
            List<Database.SaveResult> lstOliUpdResult = Database.update(lstOliToUpdate,false);
            System.debug('lstOliUpdResult'+lstOliUpdResult);
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLIAfterInsert',  lstOliUpdResult, lstOliToUpdate) ; 
            TriggerExecutionController.skipOpportunityProductTrigger(false);
        }
    }
    
    public static Map<Id, String> prepareScheduleDetailsForOLI(List<Opportunity_Product__c> pOliNewList){
        Set<Id> setOliId = new Set<Id>();
        Map<Id, String> mapOliIdToSchDet = new Map<Id, String>();
        Map<Id, String> mapOliIdToSchDetMod = new Map<Id, String>(); 
        Map<Id, String> mapOliIdToSchDetOld = new Map<Id, String>(); 
        for (Opportunity_Product__c oli : pOliNewList){
            setOliId.add(oli.Id);
            mapOliIdToSchDetOld.put(oli.Id, oli.Schedule_Details__c); //RQ-010441 - Mod-03
        }
        system.debug('$$$$: mapOliIdToSchDetOld' + mapOliIdToSchDetOld);
        // get Schedule of OLI
        List<Opportunity_Product_Schedule__c > lstOliSchedule = [SELECT Id, Opportunity_Product__c, Schedule_Date__c, Quantity__c, Revenue__c, Opportunity_Product__r.UnitPrice__c FROM Opportunity_Product_Schedule__c WHERE Opportunity_Product__c in :setOliId ORDER BY Opportunity_Product__c, Schedule_Date__c]; //RQ-010441 - Removed Type = 'Quantity' and added 'Revenue'
        List<Opportunity_Product_Schedule__c> lstToBeUpdateOliSchedule = new List<Opportunity_Product_Schedule__c>();
        Map<Id, Opportunity_Product_Schedule__c> mapOliSchIdToOlidSch = new Map<Id, Opportunity_Product_Schedule__c>();
        Map<Id, List<Decimal>> mapOliToGPandQty = new Map<Id, List<Decimal>>();
        for (Opportunity_Product_Schedule__c oliSch : lstOliSchedule){
            // Gross profit per unit/ Schedule Id/ Schedule data; (Schedule date: quantity : Revenue)
            // example 20/a5z2o000001ZpqHAAS/2024-04-01:9473.00:189460.0000 ;
            String strSchDet = String.valueOf(oliSch.Schedule_Date__c) + ':' + oliSch.Quantity__c + ':' + oliSch.Revenue__c; //RQ-010441 - Mod-04 - Appended 'Revenue' part of the string
            mapOliSchIdToOlidSch.put(oliSch.Id, oliSch);
            if (mapOliIdToSchDet.get(oliSch.Opportunity_Product__c) == null){
                strSchDet = oliSch.Opportunity_Product__r.UnitPrice__c + '/' + oliSch.Id + '/' + strSchDet; //RQ-010441 - Mod-05 - Appended 'UnitPrice' and Schedule ID part of the string
                mapOliIdToSchDet.put(oliSch.Opportunity_Product__c, strSchDet);
            } else {
                List<String> lstStrTempSplitFromMapSchDet = mapOliIdToSchDet.get(oliSch.Opportunity_Product__c).split('/');
                String strTempOliSchIds = lstStrTempSplitFromMapSchDet[1] + ';' + oliSch.Id;
                String strTempSchDat = lstStrTempSplitFromMapSchDet[2] + ';' + strSchDet;
                String strFinalSchDet = lstStrTempSplitFromMapSchDet[0] + '/' + strTempOliSchIds + '/' + strTempSchDat;
                mapOliIdToSchDet.put(oliSch.Opportunity_Product__c, strFinalSchDet); 
            }
        }
        system.debug('a1f'+mapOliIdToSchDet);
        for(Id mapOliIdToSchDetKey:mapOliIdToSchDet.keySet()){ //RQ-010441 - Mod-06 - Start - Logic to update schedule string and update appropriate schedule records
            if(mapOliIdToSchDetOld.get(mapOliIdToSchDetKey) != NULL && mapOliIdToSchDetOld.get(mapOliIdToSchDetKey) != ''){ // RQ-010441 Condition to check if it is not Insert
                List<String> lstOldOliSchDetSplit = mapOliIdToSchDetOld.get(mapOliIdToSchDetKey).split('/'); // RQ-010441Split between the IDs list and SchDetails list
                List<String> lstNewOliSchDetSplit = mapOliIdToSchDet.get(mapOliIdToSchDetKey).split('/');
                if(lstOldOliSchDetSplit.size() > 1){
                    String strOldOliSchIds = lstOldOliSchDetSplit[1];
                    String strNewOliSchIds = lstNewOliSchDetSplit[1];
                    system.debug('a1c'+ strOldOliSchIds + '---' + strNewOliSchIds);
                    if(strOldOliSchIds == strNewOliSchIds){ // compare schedule ids (schedule are manually changed)
                        String strOliSchDetwithOldUnitPrc = lstOldOliSchDetSplit[0]; 
                        List<String> lstOldSchDet = lstOldOliSchDetSplit[2].split(';');
                        List<String> lstNewSchDet = lstNewOliSchDetSplit[2].split(';');
                        List<String> lstOliSchIds = strOldOliSchIds.split(';');
                        for(integer i=0; i<lstOldSchDet.size();i++){
                            Opportunity_Product_Schedule__c tempOliSch = mapOliSchIdToOlidSch.get(lstOliSchIds[i]);
                            // (Schedule date: quantity : Revenue)
                            List<String> lstOldIndvDet = lstOldSchDet[i].split(':');
                            List<String> lstNewIndvDet = lstNewSchDet[i].split(':');
                            Decimal tempRevenue;
                            String tempQty;
                            system.debug('a1d'+lstOldIndvDet[1] + '---' + lstNewIndvDet[1]);
                            if(lstOldIndvDet[1] != lstNewIndvDet[1]){ //compare quantity 
                                tempQty = lstNewIndvDet[1];// new quantity
                                if(lstOldIndvDet[2] != 'null'){
                                    tempRevenue = Decimal.valueOf(lstNewIndvDet[1]) * Decimal.valueOf(strOliSchDetwithOldUnitPrc).setScale(2);
                                    tempOliSch.Revenue__c = tempRevenue;
                                }
                            }else{// same quantity
                                tempQty = lstOldIndvDet[1];// old quantity
                                if(lstOldIndvDet[1]!= 'null' && lstOldIndvDet[2] != 'null'){
                                    tempRevenue = Decimal.valueOf(lstOldIndvDet[2]);
                                    tempOliSch.Revenue__c = tempRevenue;
                                }
                            }
                            String strSchDet = lstOldIndvDet[0] + ':' + tempQty + ':' + String.valueOf(tempRevenue);
                            String strFinalSchDet = strOliSchDetwithOldUnitPrc;
                            if (mapOliIdToSchDetMod.get(mapOliIdToSchDetKey) == null){
                                strFinalSchDet += '/' + strOldOliSchIds + '/' + strSchDet;
                                mapOliIdToSchDetMod.put(mapOliIdToSchDetKey, strFinalSchDet);
                            }else{
                                List<String> lstStrTempSplitFromMapSchDet = mapOliIdToSchDetMod.get(mapOliIdToSchDetKey).split('/');
                                String strTempSchDat = lstStrTempSplitFromMapSchDet[2] + ';' + strSchDet;
                                strFinalSchDet += '/' + strOldOliSchIds + '/' + strTempSchDat;
                                mapOliIdToSchDetMod.put(mapOliIdToSchDetKey, strFinalSchDet);
                            }
                            lstToBeUpdateOliSchedule.add(tempOliSch);
                        }                       
                    }
                }
            }
        }
        if(lstToBeUpdateOliSchedule.size() <> 0){
            TriggerExecutionController.skipOpportunityProductTrigger(true);
            List<Database.SaveResult> lstOliSchUpdResult = Database.Update(lstToBeUpdateOliSchedule, false );
            TriggerExecutionController.skipOpportunityProductTrigger(false);
            ErrorLogger.writeErrors('SFDC', 'OpportunityLineItemSchedule', 'OpptyLineItemSchedulingHelper.prepareScheduleDetailsForOLI', lstOliSchUpdResult, lstToBeUpdateOliSchedule) ;             
        } //RQ-010441 - Mod-06 - End
        if(mapOliIdToSchDetMod.size() == 0) //RQ-010441 - Mod-07 - Return modified/edited schedule string if any of the schedule records is edited
            return mapOliIdToSchDet;
        else
            return mapOliIdToSchDetMod;
    }
    
    // SFSE-4388
    public static void updateOliGP(List<Opportunity_Product__c > lstOli){
        
        //create map of OLI Id to Unit Price
        Map<Id,Decimal> mapOliToGP = new Map<Id,Decimal>();
        for(Opportunity_Product__c oli: lstOli){
            
            if (oli.Amend_Gross_Profit_per_unit__c  != null)
                mapOliToGP.put(oli.Id, oli.Amend_Gross_Profit_per_unit__c);
            else
                mapOliToGP.put(oli.Id, oli.UnitPrice__c);
            
        }
        // Fetch the schedule records
        List<Opportunity_Product_Schedule__c> lstOliSchedule = [SELECT Id, Opportunity_Product__c, Revenue__c, Quantity__c, Schedule_Date__c
                                                                FROM Opportunity_Product_Schedule__c  
                                                                WHERE Opportunity_Product__c IN :mapOliToGP.keyset()  
                                                                ORDER By Opportunity_Product__c, Schedule_Date__c];          
        
        // Update revenue
        for (Opportunity_Product_Schedule__c oliSch : lstOliSchedule){
            oliSch.Revenue__c = oliSch.Quantity__c * mapOliToGP.get(oliSch.Opportunity_Product__c);
        }
        
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        List<Database.SaveResult> oliSchUpdateResultList = Database.update(lstOliSchedule, false);                               
        ErrorLogger.writeErrors('SFDC', 'updateOliGP', 'OpportunityProductSchedulingHelper.updateOliGP',  oliSchUpdateResultList, lstOliSchedule) ; 
        TriggerExecutionController.skipOpportunityProductTrigger(false);
        
        // update Schedule_Details__c on OLI
        Map<Id, String> mapOliIdToSchDetails = new Map<Id, String>();
        for (Opportunity_Product_Schedule__c oliSch : lstOliSchedule){
            
            String strSchDet = String.valueOf(oliSch.Schedule_Date__c) + ':' + oliSch.Quantity__c + ':' + oliSch.Revenue__c; 
            if (mapOliIdToSchDetails.get(oliSch.Opportunity_Product__c) == null){
                
                strSchDet = mapOliToGP.get(oliSch.Opportunity_Product__c) + '/' + oliSch.Id + '/' + strSchDet;
                mapOliIdToSchDetails.put(oliSch.Opportunity_Product__c, strSchDet);
                
            } else {
                
                List<String> lstStrTempSplitFromMapSchDet = mapOliIdToSchDetails.get(oliSch.Opportunity_Product__c).split('/');
                String strTempOliSchIds = lstStrTempSplitFromMapSchDet[1] + ';' + oliSch.Id;
                String strTempSchDat = lstStrTempSplitFromMapSchDet[2] + ';' + strSchDet;
                String strFinalSchDet = lstStrTempSplitFromMapSchDet[0] + '/' + strTempOliSchIds + '/' + strTempSchDat;
                mapOliIdToSchDetails.put(oliSch.Opportunity_Product__c, strFinalSchDet); 
            }
        } // for
        
        List<Opportunity_Product__c> lstUpdateOli = new List<Opportunity_Product__c> ();
        for (Id oliId : mapOliIdToSchDetails.keyset()){
            System.debug('UnitPrice__c '+mapOliToGP.get(oliId));
            lstUpdateOli.add(new Opportunity_Product__c(Id = oliId, Schedule_Details__c = mapOliIdToSchDetails.get(oliId)));
        }
        
        if( lstUpdateOli.size() > 0) {
            try {
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                update lstUpdateOli;
                TriggerExecutionController.skipOpportunityProductTrigger(false); 
            } catch (Exception e) {
                
            }
        }
        
    }

    //SFSE-13638
    public static void updateOliRevenue(List<Opportunity_Product__c > lstOli){
        //create map of OLI Id to Unit Price
        Map<Id,Decimal> mapOliToRevenue = new Map<Id,Decimal>();
        for(Opportunity_Product__c oli: lstOli){
            if (oli.Product_Revenue_Per_Unit__c  != null){
                mapOliToRevenue.put(oli.Id,oli.Product_Revenue_Per_Unit__c);
            }
        }
        // Fetch the schedule records
        List<Opportunity_Product_Schedule__c> lstOliSchedule = [SELECT Id, Opportunity_Product__c, Revenue__c, Quantity__c, Schedule_Date__c
                                                                FROM Opportunity_Product_Schedule__c  
                                                                WHERE Opportunity_Product__c IN :mapOliToRevenue.keyset()  
                                                                ORDER By Opportunity_Product__c, Schedule_Date__c];          
        
        // Update revenue
        for (Opportunity_Product_Schedule__c oliSch : lstOliSchedule){
            oliSch.Schedule_Revenue__c = mapOliToRevenue.containsKey(oliSch.Opportunity_Product__c) && mapOliToRevenue.get(oliSch.Opportunity_Product__c)!= null ? oliSch.Quantity__c * mapOliToRevenue.get(oliSch.Opportunity_Product__c):null;
        }
        
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        List<Database.SaveResult> oliSchUpdateResultList = Database.update(lstOliSchedule, false);                               
        ErrorLogger.writeErrors('SFDC', 'updateOliRevenue', 'OpportunityProductSchedulingHelper.updateOliRevenue',  oliSchUpdateResultList, lstOliSchedule) ; 
        TriggerExecutionController.skipOpportunityProductTrigger(false);
        
    }
    
}