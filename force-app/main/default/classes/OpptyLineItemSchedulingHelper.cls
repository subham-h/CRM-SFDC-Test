/* Author  : Madhava
* Purpose  : Utility class to hold simple and reusable functionalities
*        
* Revision Ref Number  Date        Owner                          Description
* -------- ----------  ----------- -------------------            -----------
* 1.0      #RQ-003743 04-May-2016  Madhava.kotte@ust-global.com         Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      #RQ-004742 22-May-2017  Meghana.Gupta@UST-Global.com         Need to call oli trigger method on unassigned delete
* 3.0      #RQ-005636 26-Sep-2017  Nisha@UST                            Update references of GlobalErrorLogger
* 4.0      #RQ-007322 20-Nov-17    AniBhatn@in.ibm.com                  Updated to add code for addressing Unassigned OLI adjustment on OLI update.
* 5.0      #RQ-007309 08-Mar-18    Jagadeesan.sakthivel@ust-global.com  Added method to update the OLI quantity based on Amend Expected FFE and re create the schedule records 
* 6.0      #RQ-009201 10-Sep-2018  manjunath.c.holekade@maersk.com      Mod-01 to Mod-02 -> Logic to auto create Corridor Guidance on insertion of Routes against the Quarterly Deals
* 7.0      #RQ-009597 26/11/2018   Sidhartha Mohapatra                  Removing auto creation of Unassigned Product and updating FFE
* 7.1      #RQ-009597 14/12/2018   Sidhartha/Nitin                      Added new method prepareScheduleDetailsForOLI and setScheduleDetailsOnOLIAfterInsert and setScheduleDetailsOnOLI
* 7.2      #RQ-009890 23/01/2018   Sidhartha                            Fixing Opportunity Schedule not been created when data loaded by dataloader.
* 8.0      #RQ-010441 08-Apr-2019  manjunath.c.holekade@maersk.com      Mod-01 to Mod-07 - Code added/modified to include "Revenue Scheduling"
* 9.0      #RQ-010819 06-Jun-2019  manjunath.c.holekade@maersk.com      Removal of references of deprecated fields
*10.0.     SFSE-4388  14-Sep-2020  meghana.gupta@UST                    New method to modify GP per unit
*11.0      SFSE-8606  27-Jun-2022  meghana@UST                          Opt-Out scheduling code fix
*/
public class OpptyLineItemSchedulingHelper{
    
    public static void scheduleOppLineItem(list<OpportunityLineItem> lstOppLineItems, list<OpportunityLineItem> lstOldOppLineItems, Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        system.debug('@@@scheduleOppLineItem' + lstOppLineItems);
        InsertUpdateOliLineItem(lstOppLineItems,lstOldOppLineItems,opportunityMap,OpportunityClosedmap);
    }
    public static void InsertUpdateOliLineItem(List<OpportunityLineItem> lstOppLineItems, List<OpportunityLineItem> lstOldOppLineItems,Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        
        system.debug('@@@@' + lstOppLineItems);
        
        Boolean isInsertSchedules=false;
        set<Id> oppIds = new set<Id>();//  to store curent opportunity Ids
        
        List<opportunityLineItem> insertSchedulesLst = new List<opportunityLineItem>();
        Map<id,List<opportunityLineItem>> OppToLineItemMap = new Map<id,List<opportunityLineItem>>();// this Map will contain unassigned and other OLis
        
        try{
            //Iterating opportunity line items and forming the map of Opportunity Ids and its list of OLIs
            for(opportunityLineItem oli:lstOppLineItems){
                
                if(oli.PricebookentryId != Label.UnassignedPriceBookEntryID){
                    if(OppToLineItemMap.containsKey(oli.OpportunityId)){           
                        OppToLineItemMap.get(oli.OpportunityId).add(oli);                      
                    }else{
                        OppToLineItemMap.Put(oli.OpportunityId, new List<opportunityLineItem>{oli});        
                    } 
                    
                    oppIds.add(oli.opportunityId);     
                }
            }  
            
            system.debug('oppIds ' + oppIds);
            //calculate the other line items quantity and unassigned quantity for the each opportunity
            for(Id oppId:oppIds){
                if(OppToLineItemMap.containsKey(oppId)){
                    Decimal otherOliQuantity=0.0;
                    for(OpportunityLineItem oppLine:OppToLineItemMap.get(oppId)){
                       // SFSE-8606 if(OppToLineItemMap.containsKey(oppId)){
                                otherOliQuantity += oppLine.quantity;
                                system.debug('otherOliQuantity ' + otherOliQuantity);
                        //} 
                    }
                    
                }
            }

            //Create schedules for newly created line items and updated line items
           
            /*if(trigger.isInsert){
                for(opportunityLineItem oliInsert : lstOppLineItems){
                    if( opportunityMap !=null && opportunityMap.containsKey(oliInsert.opportunityId) && oliInsert.Opt_Out_Auto_Quantity_Scheduling__c == False && (opportunityMap.get(oliInsert.opportunityId).First_Shipment_Date__c != null || opportunityMap.get(oliInsert.opportunityId).Last_Shipment_Date__c != null)){
                        insertSchedulesLst.add(oliInsert);
                    }
                }
            }*/
            insertSchedulesLst.addAll(lstOppLineItems);

            system.debug('insertSchedulesLst: ' + insertSchedulesLst);
            if( ! insertSchedulesLst.isEmpty()){
                
                // Generate the Opportunity Product Schedules for new Product.
                List<OpportunityLineItemSchedule > lineItemSchedule =  ScheduleOppProducts.PrepareProductSchedules(opportunityMap, insertSchedulesLst);           
                system.debug('opptylineitemschedulinghelper:lineItemSchedule' + lineItemSchedule);
                // Insert Product Schedules and Insert Other Product with remainining QTY Update the FFE on Opportunity
                if( lineItemSchedule.size()>0  )
                {
                    system.debug('lineItemSchedule ' + lineItemSchedule);
                    List<Database.SaveResult> oliUpdateResultList=Database.insert(lineItemSchedule,false);
                    ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.InsertUpdateOliLineItem', oliUpdateResultList, lineItemSchedule) ; // #RQ-005636
                }
            }
            
        }catch(exception e){
            
        }
        
        
    }
    public static void OppLineItemOnDelete(Map<id,OpportunityLineItem> oldOpptyLineItems,Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap){
        
        InsertUpdateOliLineItem(oldOpptyLineItems.values(),oldOpptyLineItems.values(),opportunityMap,OpportunityClosedmap);
          
    }
    
    //method displaying error messages on delete of unassigned route direction and other line item for closed opportunity
    public static void validateoliOnDelete(Map<id,OpportunityLineItem> oldOppLineItemMap, Map<id,Boolean> OpportunityClosedmap,Boolean VRBypassIsActive){
        
        for(OpportunityLineItem oldOli:oldOppLineItemMap.values()){
            /*
            if(oldOli.PricebookentryId == Label.UnassignedPriceBookEntryID){
                oldOli.addError(Label.CannotDeleteUnassigned);
            }else */
                if( OpportunityClosedmap.get(oldOli.OpportunityId)!=null && OpportunityClosedmap.get(oldOli.OpportunityId) == True  && VRBypassIsActive != true ){
                oldOli.addError(' '+Label.ExpectedErrorLabel);
            }
        }
    }
    // Method to delete schedule of the source/ Original Opportunity which is not created via cloning
    public static void deleteDefaultScheduleOppLineItem(List<OpportunityLineItem> oLIItems, Boolean checkIsNotCloned){

        Set<Id> setOLIIds = new Set<Id>(); // set of Opportunity Line items whose schedules needs to be deleted        
        for(OpportunityLineItem oli: oLIItems){
            setOLIIds.add(oli.Id);            
        }

        String strQuery = 'SELECT Id, OpportunityLineItemId, Quantity, Revenue, ScheduleDate, Type FROM OpportunityLineItemSchedule  WHERE OpportunityLineItemId IN:setOLIIds ';
        if (checkIsNotCloned){
            strQuery += '  AND isClonedrecord__c = false ';
        }
        
        List<OpportunityLineItemSchedule> lstOpptyLineItemSchedule = Database.Query(strQuery);
        List<OpportunityLineItemSchedule> lstOpLISchToDel = new List<OpportunityLineItemSchedule>();
        /*for(OpportunityLineItemSchedule opsc : lstOpptyLineItemSchedule){
            system.debug('opsc==>'+opsc.getCloneSourceId());
             //if(opsc.getCloneSourceId()!=null){
                lstOpptyLineItemSchedule.add(opsc);
            }//
        }*/
        System.debug('delteDefaultScheduleOppLineItem  lstOpptyLineItemSchedule::: '+lstOpptyLineItemSchedule);
        if(lstOpptyLineItemSchedule.size() > 0){   

            //delete lstOpportunityLineItemSchedule;
            TriggerExecutionController.skipopptyLineItemTrigger(true);
            List<Database.DeleteResult> lstOliSchdlsDeleteResult = Database.delete(lstOpptyLineItemSchedule, false ); 
            TriggerExecutionController.skipopptyLineItemTrigger(false);                
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.deleteDefaultScheduleOppLineItem', lstOliSchdlsDeleteResult, lstOpptyLineItemSchedule) ;  
        }        
    }

    // Method to process the OLI records for which Amend_Expected_FFE__c is updated so that it should reflect as OLI quantity and schedule records should be created based on new Quantity
    public static void reCreateScheduleOppLineItem(List<OpportunityLineItem> oLIItems, boolean isCloned){
        system.debug('lstOppToBeUpdated' + oLIItems);   
        Set<Id> setOLIIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOrignalOliIds = new Set<Id>();
        Map<Id,Decimal> oliIDToSalesPriceMap = new Map<Id,Decimal>();
        for(OpportunityLineItem oli: oLIItems){
            setOLIIds.add(oli.Id);
            setOppIds.add(oli.OpportunityId);
            oliIDToSalesPriceMap.put(oli.Id,oli.UnitPrice);
            //setOrignalOliIds.add(oli.loneSourceId());
            system.debug('Original ID==>'+oli.getCloneSourceId());
        }
        // Fetch the schedule records
        List<OpportunityLineItemSchedule> lstOpportunityLineItemSchedule = [SELECT Id, OpportunityLineItemId, Quantity, Revenue, ScheduleDate, Type 
                                                                            FROM OpportunityLineItemSchedule 
                                                                            WHERE OpportunityLineItemId IN:setOLIIds];          
        system.debug('lstOpportunityLineItemSchedule-->>'+lstOpportunityLineItemSchedule);
        if(lstOpportunityLineItemSchedule != null)
        {
            TriggerExecutionController.skipopptyLineItemTrigger(true);
            List<Database.DeleteResult> lstOliSchdlsDeleteResult = Database.delete(lstOpportunityLineItemSchedule, false ); 
            TriggerExecutionController.skipopptyLineItemTrigger(false);                
            ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem', lstOliSchdlsDeleteResult, lstOpportunityLineItemSchedule) ;             
        }
        system.debug('@@@after delete schedule');
        // Fetch the corresponding opportunity for updating the opportunity Expected FFE
        Map<Id,Opportunity> mapOfOpp = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Quantity, Amend_Expected_FFE__c FROM OpportunityLineItems),First_Shipment_Date__c, Last_Shipment_Date__c FROM Opportunity WHERE Id IN :setOppIds]);
        
        if(mapOfOpp != null){
            //ScheduleOppProducts sopp = new ScheduleOppProducts();
            List<OpportunityLineItemSchedule> lstLineItemSchedule = ScheduleOppProducts.PrepareProductSchedules(mapOfOpp, oLIItems);
            List<Opportunity> lstOppToBeUpdated = new List<Opportunity>();
            if( lstLineItemSchedule.size()>0 )
            {
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                for(OpportunityLineItemSchedule oLisch: lstLineItemSchedule) {
                    if(isCloned){
                         oLisch.isClonedrecord__c = true; // Setting this floag to true for custom records. created for sfse-6737
                    } 
                }
                System.debug(' ##### lstLineItemSchedule '+lstLineItemSchedule);
                List<Database.SaveResult> oliUpdateResultList=Database.insert(lstLineItemSchedule,false);                               
                ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem',  oliUpdateResultList, lstLineItemSchedule) ; 
                TriggerExecutionController.skipopptyLineItemTrigger(false);

                Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(oLIItems);
                Map<Id,OpportunityLineItem> mapOfOliIDToOli = new Map<Id,OpportunityLineItem> ();
                for(OpportunityLineItemSchedule oLisch: lstLineItemSchedule) {
                    If(!mapOfOliIDToOli.containsKey(oLisch.OpportunityLineItemId)) { 
                        Decimal oliUniPrice = oliIDToSalesPriceMap.get(oLisch.OpportunityLineItemId);
                        String strSchDet = mapOliIdToSchDetails.get(oLisch.OpportunityLineItemId);
                        system.debug('oliUniPrice' + oliUniPrice);
                        mapOfOliIDToOli.put(oLisch.OpportunityLineItemId,new OpportunityLineItem(Id=oLisch.OpportunityLineItemId,UnitPrice = oliUniPrice, Schedule_Details__c = strSchDet));
                        system.debug('mapOfOliIDToOli' + mapOfOliIDToOli);
                    }
                }
                if(mapOfOliIDToOli.size()> 0) {
                    try {
                        TriggerExecutionController.skipopptyLineItemTrigger(true);
                        system.debug('mapOfOliIDToOli' + mapOfOliIDToOli);
                        update mapOfOliIDToOli.values();
                        TriggerExecutionController.skipopptyLineItemTrigger(false); 
                    } catch (Exception e) {
                        
                    }
                }
            } 
        }
        
    }

    
    public static void setScheduleDetailsOnOLI(List<OpportunityLineItem> pOliNewLst, map<Id, OpportunityLineItem> pOliOldMap){

        Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(pOliNewLst);
        List<OpportunityLineItem> lstOliToUpdate = new List<OpportunityLineItem>();
        
        Map<Id,Decimal> mapofOliIDtoOldSalesPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofOliIdtoNewSalesPrice = new Map<Id,Decimal>();
        for(OpportunityLineItem oliN : pOliNewLst)
        {                        
            OpportunityLineItem OLIOld =  pOliOldMap.get(oliN.Id);
            mapofOliIdtoNewSalesPrice.put(oliN.Id,oliN.UnitPrice);
            if( OLIOld.Quantity != 0 && oliN.Quantity != OLIOld.Quantity ) {
                mapofOliIDtoOldSalesPrice.put(oliN.Id, OLIOld.UnitPrice);
            }
        }
        system.debug('mapofOliIDtoOldSalesPrice' + mapofOliIDtoOldSalesPrice);

        for (OpportunityLineItem oli : pOliNewLst){
            String strScheduleDetails = mapOliIdToSchDetails.get(oli.Id);
            Decimal oliPriorSalesPrice = mapofOliIDtoOldSalesPrice.get(oli.Id);
            Decimal oliNewSalesPrice = mapofOliIdtoNewSalesPrice.get(oli.Id); //#RQ-009890
            OpportunityLineItem oliRec = new OpportunityLineItem();
            oliRec.Id = oli.Id;
            // schdule has changed and opt out is not enabled 
            if ( pOliOldMap.get(oli.Id).Schedule_Details__c != strScheduleDetails
                    && (((pOliOldMap.get(oli.Id).Quantity != oli.Quantity))|| ((pOliOldMap.get(oli.Id).TotalPrice != oli.TotalPrice) && (pOliOldMap.get(oli.Id).UnitPrice != oli.UnitPrice))) //RQ-010441 - Mod-02 - Included additional condition related to 'TotalPrice' and 'UnitPrice'
                    && oli.Amend_Expected_FFE__c == null
                    && oli.Opt_Out_Auto_Quantity_Scheduling__c == false){

                oliRec.Opt_Out_Auto_Quantity_Scheduling__c = true;
            }
            oliRec.Schedule_Details__c = strScheduleDetails;    
            oliRec.UnitPrice = (oliPriorSalesPrice==null)?oliNewSalesPrice : oliPriorSalesPrice; //#RQ-009890
            lstOliToUpdate.add(oliRec);
        } 

        if (lstOliToUpdate.size() > 0){
            TriggerExecutionController.skipopptyLineItemTrigger(true);
            List<Database.SaveResult> lstOliUpdResult = Database.update(lstOliToUpdate,false);
            System.debug('lstOliUpdResult'+lstOliUpdResult);
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLI',  lstOliUpdResult, lstOliToUpdate) ; 
            TriggerExecutionController.skipopptyLineItemTrigger(false);
        }
    }
    

    public static void setScheduleDetailsOnOLIAfterInsert(List<OpportunityLineItem> pListNewOli){
        system.debug('in setScheduleDetailsOnOLIAfterInsert');
        Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(pListNewOli);
        List<OpportunityLineItem> lstOliToUpdate = new List<OpportunityLineItem>();

        for (Id oRecId : mapOliIdToSchDetails.keyset()){
            OpportunityLineItem oliRec = new OpportunityLineItem();
            oliRec.Id = oRecId;
            oliRec.Schedule_Details__c = mapOliIdToSchDetails.get(oRecId);

            lstOliToUpdate.add(oliRec);
        }

        if (lstOliToUpdate.size() > 0){
            TriggerExecutionController.skipopptyLineItemTrigger(true);
            List<Database.SaveResult> lstOliUpdResult = Database.update(lstOliToUpdate,false);
            System.debug('lstOliUpdResult'+lstOliUpdResult);
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemSchedulingHelper', 'OpptyLineItemSchedulingHelper.setScheduleDetailsOnOLIAfterInsert',  lstOliUpdResult, lstOliToUpdate) ; 
            TriggerExecutionController.skipopptyLineItemTrigger(false);
        }
    }

    public static Map<Id, String> prepareScheduleDetailsForOLI(List<OpportunityLineItem> pOliNewList){
        Set<Id> setOliId = new Set<Id>();
        Map<Id, String> mapOliIdToSchDet = new Map<Id, String>();
        Map<Id, String> mapOliIdToSchDetMod = new Map<Id, String>(); 
        Map<Id, String> mapOliIdToSchDetOld = new Map<Id, String>(); 
        for (OpportunityLineItem oli : pOliNewList){
            setOliId.add(oli.Id);
            mapOliIdToSchDetOld.put(oli.Id, oli.Schedule_Details__c); //RQ-010441 - Mod-03
        }
        system.debug('$$$$: mapOliIdToSchDetOld' + mapOliIdToSchDetOld);
        // get Schedule of OLI
        List<OpportunityLineItemSchedule> lstOliSchedule = [SELECT Id, OpportunityLineItemId, ScheduleDate, Quantity, Revenue, OpportunityLineItem.UnitPrice FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId in :setOliId ORDER BY OpportunityLineItemId, ScheduleDate]; //RQ-010441 - Removed Type = 'Quantity' and added 'Revenue'
        List<OpportunityLineItemSchedule> lstToBeUpdateOliSchedule = new List<OpportunityLineItemSchedule>();
        Map<Id, OpportunityLineItemSchedule> mapOliSchIdToOlidSch = new Map<Id, OpportunityLineItemSchedule>();
        Map<Id, List<Decimal>> mapOliToGPandQty = new Map<Id, List<Decimal>>();
        for (OpportunityLineItemSchedule oliSch : lstOliSchedule){
            String strSchDet = String.valueOf(oliSch.ScheduleDate) + ':' + oliSch.Quantity + ':' + oliSch.Revenue; //RQ-010441 - Mod-04 - Appended 'Revenue' part of the string
            mapOliSchIdToOlidSch.put(oliSch.Id, oliSch);
            if (mapOliIdToSchDet.get(oliSch.OpportunityLineItemId) == null){
                strSchDet = oliSch.OpportunityLineItem.UnitPrice + '/' + oliSch.Id + '/' + strSchDet; //RQ-010441 - Mod-05 - Appended 'UnitPrice' and Schedule ID part of the string
                mapOliIdToSchDet.put(oliSch.OpportunityLineItemId, strSchDet);
            } else {
                List<String> lstStrTempSplitFromMapSchDet = mapOliIdToSchDet.get(oliSch.OpportunityLineItemId).split('/');
                String strTempOliSchIds = lstStrTempSplitFromMapSchDet[1] + ';' + oliSch.Id;
                String strTempSchDat = lstStrTempSplitFromMapSchDet[2] + ';' + strSchDet;
                String strFinalSchDet = lstStrTempSplitFromMapSchDet[0] + '/' + strTempOliSchIds + '/' + strTempSchDat;
                mapOliIdToSchDet.put(oliSch.OpportunityLineItemId, strFinalSchDet); 
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
                    if(strOldOliSchIds == strNewOliSchIds){
                        String strOliSchDetwithOldUnitPrc = lstOldOliSchDetSplit[0]; 
                        List<String> lstOldSchDet = lstOldOliSchDetSplit[2].split(';');
                        List<String> lstNewSchDet = lstNewOliSchDetSplit[2].split(';');
                        List<String> lstOliSchIds = strOldOliSchIds.split(';');
                        for(integer i=0; i<lstOldSchDet.size();i++){
                            OpportunityLineItemSchedule tempOliSch = mapOliSchIdToOlidSch.get(lstOliSchIds[i]);
                            List<String> lstOldIndvDet = lstOldSchDet[i].split(':');
                            List<String> lstNewIndvDet = lstNewSchDet[i].split(':');
                            Decimal tempRevenue;
                            String tempQty;
                            system.debug('a1d'+lstOldIndvDet[1] + '---' + lstNewIndvDet[1]);
                            if(lstOldIndvDet[1] != lstNewIndvDet[1]){
                                tempQty = lstNewIndvDet[1];
                                if(lstOldIndvDet[2] != 'null'){
                                    tempRevenue = Decimal.valueOf(lstNewIndvDet[1]) * Decimal.valueOf(strOliSchDetwithOldUnitPrc).setScale(2);
                                    tempOliSch.Revenue = tempRevenue;
                                }
                            }else{
                                tempQty = lstOldIndvDet[1];
                                if(lstOldIndvDet[1]!= 'null' && lstOldIndvDet[2] != 'null'){
                                    tempRevenue = Decimal.valueOf(lstOldIndvDet[2]);
                                    tempOliSch.Revenue = tempRevenue;
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
        
            //Try for SFSE-13321 - Ramadevi
            String OppSchSize = System.Label.OpportunityScheduleListSize;
            if( Limits.getDMLRows()+ lstToBeUpdateOliSchedule.size() <= Integer.valueof(OppSchSize)){  //10000                  
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                List<Database.SaveResult> lstOliSchUpdResult = Database.Update(lstToBeUpdateOliSchedule, false );
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                ErrorLogger.writeErrors('SFDC', 'OpportunityLineItemSchedule', 'OpptyLineItemSchedulingHelper.prepareScheduleDetailsForOLI', lstOliSchUpdResult, lstToBeUpdateOliSchedule) ;             
            }else{
                    system.debug('Within else before queuable -- OLI Update');
                    OpportunityProdSchQueueable queueableUpdateSch = new OpportunityProdSchQueueable(null,lstToBeUpdateOliSchedule,'UpdateScheduleDetailsOnOLI');
                    System.enqueueJob(queueableUpdateSch);
                }
            /*TriggerExecutionController.skipopptyLineItemTrigger(true);
            List<Database.SaveResult> lstOliSchUpdResult = Database.Update(lstToBeUpdateOliSchedule, false );
            TriggerExecutionController.skipopptyLineItemTrigger(false);
            ErrorLogger.writeErrors('SFDC', 'OpportunityLineItemSchedule', 'OpptyLineItemSchedulingHelper.prepareScheduleDetailsForOLI', lstOliSchUpdResult, lstToBeUpdateOliSchedule) ;             
            */
        } //RQ-010441 - Mod-06 - End
        if(mapOliIdToSchDetMod.size() == 0) //RQ-010441 - Mod-07 - Return modified/edited schedule string if any of the schedule records is edited
            return mapOliIdToSchDet;
        else
            return mapOliIdToSchDetMod;
    }
    
    // SFSE-4388
    public static void updateOliGP(List<OpportunityLineItem> lstOli){
        
        //create map of OLI Id to Unit Price
        Map<Id,Decimal> mapOliToGP = new Map<Id,Decimal>();
        for(OpportunityLineItem oli: lstOli){
          
            if (oli.Amend_Gross_Profit_per_unit__c  != null)
                mapOliToGP.put(oli.Id, oli.Amend_Gross_Profit_per_unit__c);
            else
                mapOliToGP.put(oli.Id, oli.UnitPrice);

        }
        // Fetch the schedule records
        List<OpportunityLineItemSchedule> lstOliSchedule = [SELECT Id, OpportunityLineItemId, Revenue, Quantity, ScheduleDate
                                                                            FROM OpportunityLineItemSchedule 
                                                                            WHERE OpportunityLineItemId IN :mapOliToGP.keyset()  
                                                                            ORDER By OpportunityLineItemId, ScheduleDate];          
        
        // Update revenue
        for (OpportunityLineItemSchedule oliSch : lstOliSchedule){
            oliSch.Revenue = oliSch.Quantity * mapOliToGP.get(oliSch.OpportunityLineItemId);
        }
        
        TriggerExecutionController.skipopptyLineItemTrigger(true);
        List<Database.SaveResult> oliSchUpdateResultList = Database.update(lstOliSchedule, false);                               
        ErrorLogger.writeErrors('SFDC', 'updateOliGP', 'OpptyLineItemSchedulingHelper.updateOliGP',  oliSchUpdateResultList, lstOliSchedule) ; 
        TriggerExecutionController.skipopptyLineItemTrigger(false);
        
        // update Schedule_Details__c on OLI
        Map<Id, String> mapOliIdToSchDetails = new Map<Id, String>();
        for (OpportunityLineItemSchedule oliSch : lstOliSchedule){
            
            String strSchDet = String.valueOf(oliSch.ScheduleDate) + ':' + oliSch.Quantity + ':' + oliSch.Revenue; 
            if (mapOliIdToSchDetails.get(oliSch.OpportunityLineItemId) == null){
                
                strSchDet = mapOliToGP.get(oliSch.OpportunityLineItemId) + '/' + oliSch.Id + '/' + strSchDet;
                mapOliIdToSchDetails.put(oliSch.OpportunityLineItemId, strSchDet);
            
            } else {
                
                List<String> lstStrTempSplitFromMapSchDet = mapOliIdToSchDetails.get(oliSch.OpportunityLineItemId).split('/');
                String strTempOliSchIds = lstStrTempSplitFromMapSchDet[1] + ';' + oliSch.Id;
                String strTempSchDat = lstStrTempSplitFromMapSchDet[2] + ';' + strSchDet;
                String strFinalSchDet = lstStrTempSplitFromMapSchDet[0] + '/' + strTempOliSchIds + '/' + strTempSchDat;
                mapOliIdToSchDetails.put(oliSch.OpportunityLineItemId, strFinalSchDet); 
            }
        } // for
        
        List<OpportunityLineItem> lstUpdateOli = new List<OpportunityLineItem> ();
        for (Id oliId : mapOliIdToSchDetails.keyset()){
            lstUpdateOli.add(new OpportunityLineItem(Id = oliId, Schedule_Details__c = mapOliIdToSchDetails.get(oliId)));
        }
        
        if( lstUpdateOli.size() > 0) {
            try {
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                update lstUpdateOli;
                TriggerExecutionController.skipopptyLineItemTrigger(false); 
            } catch (Exception e) {
                
            }
        }
        
    }
}