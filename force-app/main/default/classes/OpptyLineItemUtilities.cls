/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0      #RQ-004492 16-Nov-2016     kishore.dupam@ust-global.com        To do chatter post on Opportunity when Tender Target is changed. 
* 2.0      #RQ-004492 16-Nov-2016     Abhinav.ankit@maersk.com            To do chatter post on Opportunity when Tender Target is changed.
* 3.0      RQ-013269  03-04-2020     sidhartha@maersk.com           removed chatter post   
* 4.0      #RQ-004492 06-Aug-2020     Abhinav.ankit@maersk.com            SFSE-245.
* 5.0      SFSE-4453  13-Aug-2020     Neha@TCS                             Modify approval flow for 4PL Product Family
* 6.0      SFSE-5309  26-Feb-2021     Meghana@UST							New method added to check if an opportunity Meets OMEB conditions
* 7.0      SFSE-8606  27-Jun-2022     Meghana@UST                          Method to create Corridor Guidance records moved from other class
* 8.0		SFSE-8521  04-Jul-2022		Rakesh@Maersk				  		Handle Cloning Opportunity Product Features on Opp clone
* 9.0		SFSE-9098  06-Oct-2022	   Meghana@UST							Replace Exclude_from_OMEB_Approvals__c by Include_in_OMEB_Approvals__c
* 9.1		SFSE-9505  07-Oct-2022		Kiran@Maersk						Approval Must goto OMEB check for Accepted Brands
* 9.2      SFSE-9542  18-Oct-2022		Meghana@UST							Code added to check for Produts for approval eligible for all areas if we don't get area specific code
* 9.3		SFSE-9417  18-Oct-2022		Kiran@Maersk						Adding VR to stop creatining OLI if Opportunity approval status is Approved Solution Gate and StageName is Quoting
* 9.4     SFSE-10262   15-Mar-2023     Bharti@Maersk                       Adding logic for changing product for approval of contract logistic family product From WD to CL if annualised GP is less than 100k
*/
public class OpptyLineItemUtilities{
    
    
    public static void ProductListUpdate(List<opportunitylineitem> lstOLIs){
        List<opportunity> listOpptyUpdate = new List<opportunity> (); //list of Opportunity which needs to be updated
        List<opportunitylineitem> listOli = new List<opportunitylineitem>(); 
        
        Set<Id> setOpptyList1= new Set<Id>();
        Set<Id> setParentGeoIds = new Set<Id>();
        
        Map<String,Set<String>> productFmlytoAreaSet = new Map<String,Set<String>>();
        Map<String,Set<String>> productFmlytoName= new Map<String,Set<String>>();        
        Map<Id, String>  mapCntryBDA = new Map<Id, String>();        
        Map<String,String> mapProdApprovalMD = new Map<String, String>();        
        String stringProductList;
        String keyStr='';
        
        //Fetch contracting Products For Approval metadata type
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        // Logic to get Product Approval code from Metadata based on Product Family
        // if Product family and name on OLI matches in Metadata, populate the corresponding Approval code. If match is only on family, name is null in metadata, populate the corresponding approval code.
        
        if(productsForApprovalList.size() >0){
            for(Products_For_Approval__mdt prodApproval : productsForApprovalList){
                String teampKey = prodApproval.Product_Family__c;
                if(String.isBlank(prodApproval.Product_Name__c)){
                    teampKey +='-NA';
                }else{
                    teampKey +='-'+prodApproval.Product_Name__c;
                }
                if(String.isBlank(prodApproval.Area__c)){
                    teampKey +='-NA';
                }else{
                    teampKey +='-'+prodApproval.Area__c;
                }
                
                // Prepares the temp key        
                mapProdApprovalMD.put(teampKey, prodApproval.Product_Approval_Code__c);
                
                
                if(productFmlytoAreaSet.containsKey(prodApproval.Product_Family__c)){        
                    Set<String> teampAraSet = productFmlytoAreaSet.get(prodApproval.Product_Family__c);
                    teampAraSet.add(prodApproval.Area__c);
                    productFmlytoAreaSet.put(prodApproval.Product_Family__c,teampAraSet);
                }else{
                    productFmlytoAreaSet.put(prodApproval.Product_Family__c,new Set<String>{prodApproval.Area__c});
                }
                
                
                if(productFmlytoName.containsKey(prodApproval.Product_Family__c)){    
                    Set<String> teampNameSet = productFmlytoName.get(prodApproval.Product_Family__c);
                    teampNameSet.add(prodApproval.Product_Name__c);
                    productFmlytoName.put(prodApproval.Product_Family__c,teampNameSet);
                }else{
                    productFmlytoName.put(prodApproval.Product_Family__c,new Set<String>{prodApproval.Product_Name__c});
                }
            }
            
        }
        
        //Fetch opportunity based on OLI
        for(OpportunityLineItem setOpptyList :lstOLIs){
            setOpptyList1.add(setOpptyList.OpportunityId);                    
        }
        //Fetch opportunity Line Items
        for( OpportunityLineItem oliRec : [Select Id,Product2.Name,Product_Family__c,Country__c,OpportunityId,product2.Include_in_OMEB_Approvals__c,Annualized_Gross_Profit__c from opportunitylineitem where OpportunityId in: setOpptyList1]){
            if(oliRec.product2.Include_in_OMEB_Approvals__c == true){
                setParentGeoIds.add(oliRec.Country__c);
                listOli.add(oliRec);
            } 
        }
        
        //Fetch BDA based on OLI Country 
        for(BDA_Geography__c lstBDAGeo :[select Id, Geography__c, BDA__c,BDA__r.Name, BDA__r.Parent_BDA__c from BDA_Geography__c where Geography__c in :setParentGeoIds and BDA__r.Type__c = 'Cluster']) {
            mapCntryBDA.put(lstBDAGeo.Geography__c, lstBDAGeo.BDA__r.Name);
        }
        
        // generate Key
        for(Opportunity oppRec : [Select Id,Products_for_Approval__c from opportunity where id in: setOpptyList1]){
            stringProductList='';
            //System.debug(oppRec +' !!!!!!!');
            oppRec.Products_for_Approval__c ='';
            for(Opportunitylineitem olObj: listOli){
                if(olObj.OpportunityId ==oppRec.Id){                    
                    keyStr=olObj.Product_Family__c;                 
                    if(productFmlytoName.containsKey(olObj.Product_Family__c)){
                        if(productFmlytoName.get(olObj.Product_Family__c).contains(olObj.Product2.Name)){
                            keyStr += '-'+olObj.Product2.Name;
                        }else{
                            keyStr += '-NA';
                        }
                    } 
                    
                    
                    String alternateKeyStr = keyStr + '-NA';
                    if(productFmlytoAreaSet.containsKey(olObj.Product_Family__c)){
                        String oliAraCode = mapCntryBDA.get(olObj.Country__c); 
                        
                        if(oliAraCode!= null && productFmlytoAreaSet.get(olObj.Product_Family__c).contains(oliAraCode)){
                            keyStr += '-'+oliAraCode;
                        }else{
                            keyStr += '-NA';
                            
                        }
                    }              
                    system.debug('@@@ : keystr - ' + keyStr);
                    //get product Code from Map
                    String productCode ='';
                    if(mapProdApprovalMD.containsKey(keyStr)){
                        productCode = mapProdApprovalMD.get(keyStr);
                        
                    } else if(mapProdApprovalMD.containsKey(alternateKeyStr)){
                        productCode = mapProdApprovalMD.get(alternateKeyStr);
                    }
                    //if GP of OLI is less than 100k than product for approval will be CL rather than WD 
                    if(olObj.Annualized_Gross_Profit__c < 100000 && productCode.contains('WD')){
                        productCode =  productCode.replace('WD','CL') ;
                    } 
                    if(String.isNotBlank(productCode) && !stringProductList.contains(productCode)){
                        stringProductList += productCode+ ';';
                    } 
                }               
            } 
            System.debug('stringProductList' + stringProductList);
            stringProductList = stringProductList.removeEnd(';');            
            oppRec.Products_for_Approval__c =stringProductList;
            
            listOpptyUpdate.add(oppRec);
            
            
        }
        
        system.debug('@@@listOpptyUpdate'+JSON.serializePretty(listOpptyUpdate));
        system.debug('size:::'+listOpptyUpdate.size());
        
        if(listOpptyUpdate.size()>0){
            TriggerExecutionController.skipOpportunityTrigger(true);
            //Database.update(listOpptyUpdate,false);
            List<Database.SaveResult> opptyUpdateResultList = Database.update(listOpptyUpdate, false );            
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemUtilities', 'OpptyLineItemUtilities.ProductListUpdate', opptyUpdateResultList, listOpptyUpdate) ; // #RQ-005636
            TriggerExecutionController.skipOpportunityTrigger(false);   
        }
        
    }
    
    public static void checkProductsForOmeb (List<opportunitylineitem> lstOLIs, List<Id> opptyIds, String triggerAction){
        // fetch custom metadata 
        List<productFamilyForOMEB__mdt> lstProdForOMEB = new List<productFamilyForOMEB__mdt>(); 
        //[SELECT MasterLabel, field_to_compare__c, Operator__c, Value_to_Compare__c FROM productFamilyForOMEB__mdt WHERE IsActive__c = true];
        
        for (productFamilyForOMEB__mdt pf : productFamilyForOMEB__mdt.getAll().values()){
            if(pf.isActive__c){
                lstProdForOMEB.add(pf);
            }
        }
        
        String fieldsToFetch =''; // get list of fields to be fetched from Opportunity Product
        
        // form map of Product Family ==> Custom Metadata record
        Map<String, List<productFamilyForOMEB__mdt>> mapProdFamilyToSetting = new Map<String, List<productFamilyForOMEB__mdt>>();
        for (productFamilyForOMEB__mdt rec : lstProdForOMEB){
            
            List<productFamilyForOMEB__mdt> tmpList = new List<productFamilyForOMEB__mdt>();
            if (mapProdFamilyToSetting.containskey(rec.MasterLabel)){
                tmpList = mapProdFamilyToSetting.get(rec.MasterLabel);
            }
            tmpList.add(rec);
            mapProdFamilyToSetting.put(rec.MasterLabel, tmpList);
            
            if (! fieldsToFetch.contains(rec.field_to_compare__c)){
                fieldsToFetch += rec.field_to_compare__c + ', ';
            }
        }
        
        // If oppty product being inserted, updated or deleted is from given product family then create a list of Oppty Id
        List<Id> oppIdToCheckLst = new List<Id>();
        Map<Id, List<Opportunitylineitem>> mapOpptyToOli = new Map<Id, List<Opportunitylineitem>>();
        
        if (lstOLIs != null){
            for (opportunitylineitem oli : lstOLIs){
                if (mapProdFamilyToSetting.containsKey(oli.Product_Family__c)){
                    oppIdToCheckLst.add(oli.OpportunityId);
                    
                    List<Opportunitylineitem> tmpOli = new List<Opportunitylineitem>();
                    if (mapOpptyToOli.containsKey(oli.OpportunityId)){
                        tmpOli = mapOpptyToOli.get(oli.OpportunityId);
                    }
                    tmpOli.add(oli);
                    mapOpptyToOli.put(oli.OpportunityId, tmpOli);
                    system.debug('mapOpptyToOli: '+mapOpptyToOli);
                }
            }
        }   
        
        if (opptyIds != null){
            oppIdToCheckLst.addAll(opptyIds);
        }
        
        Set<String> lstFilterOption = mapProdFamilyToSetting.keySet();
        if (! oppIdToCheckLst.isEmpty()){
            
            String strQuery = 'SELECT Id, Must_Go_To_OMEB__c, Liner_Brand__c, StageName, (SELECT Id, ' + fieldsToFetch + ' Product_Family__c,ProductCode FROM OpportunityLineItems WHERE Product2.Include_in_OMEB_Approvals__c = true and Product_Family__c in: lstFilterOption' ; 
            strQuery +=   ' ) FROM Opportunity WHERE id in: oppIdToCheckLst' ;
            
            system.debug('strQuery: ' + strQuery);
            
            List<Opportunity> lstOppToCheck = database.query(strQuery);
            checkOpportunityNeedOmebApproval(lstOppToCheck, mapProdFamilyToSetting, triggerAction, mapOpptyToOli);
        }
    }
    
    public static void checkOpportunityNeedOmebApproval (List<opportunity> lstOppty, Map<String, List<productFamilyForOMEB__mdt>> mapProdFamilyToSetting, String triggerAction, Map<Id, List<Opportunitylineitem>> mapOpptyToOli){
        
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        
        
        List<FeedItem> post = new List<FeedItem>();
        FeedItem postObj;
        //SFSE-9505
        List<String> listBrands = new List<String>();
        for (Brand__mdt brand : Brand__mdt.getAll().values()) {
            if(brand.OMEB_Enabled__c){
                listBrands.add(brand.MasterLabel);
            }
        }
        
        for (Opportunity opp : lstOppty){
            
            // If OMEB flag is already true and we are inserting new record, it wont change OMEB flag vlaue so no need to execute logic
            // If OMEB flag is false and we are deleting a record, it won't change flag value so no need to execute logic
            // If OMEB flag is false and brand donesn't contains OMEB Brands, it won't change flag value so no need to execute logic
            
            if (!((triggerAction == 'Insert' && opp.Must_Go_To_OMEB__c == true) || (triggerAction == 'Delete' && opp.Must_Go_To_OMEB__c == false) ||
                  (triggerAction == 'Update' && opp.Must_Go_To_OMEB__c == false && !listBrands.contains(opp.Liner_Brand__c)))){
                      System.debug('---237---');
                      Map<String, decimal> pfSumPerProdFamily = new Map<String, decimal>();
                      boolean omebFlag = false;
                      if(listBrands.contains(opp.Liner_Brand__c)){
                          for (OpportunityLineItem oli : opp.OpportunityLineItems){
                              // get the custom metadata applicable to OLI's prod family.
                              // in case there are 2 criteria defined on same product family use for loop. 
                              for (productFamilyForOMEB__mdt criteria : mapProdFamilyToSetting.get(oli.Product_Family__c)){
                                  double criteriaValue = (double) oli.get(criteria.field_to_compare__c); // get the value for 'field_to_compare' field from OLI record
                                  double valueToCompare = criteria.Value_to_Compare__c;
                                  if (pfSumPerProdFamily.containskey(oli.Product_Family__c)){
                                      criteriaValue += pfSumPerProdFamily.get(oli.Product_Family__c);
                                  } 
                                  pfSumPerProdFamily.put(oli.Product_Family__c,criteriaValue );
                                  system.debug('$$$ pfSumPerProdFamily: '+ pfSumPerProdFamily);
                                  switch on criteria.Operator__c {
                                      when 'GTOEqualTo' {
                                          if (criteriaValue >= valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                      when 'EqualTo' {
                                          if (criteriaValue == valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                      when 'NotEqualTo' {
                                          if (criteriaValue != valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                      when 'GT' {
                                          if (criteriaValue > valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                      when 'LT' {
                                          if (criteriaValue < valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                      when 'LTOEqualTo' {
                                          if (criteriaValue <= valueToCompare){
                                              omebFlag = true;
                                          }
                                      }
                                  }
                                  // End for loop as flag is changed to true already, no need to check rest crtieria 
                                  if (omebFlag){
                                      break;
                                  }
                              }
                              // end for loop as flag is set to true for 1 OLI, no need to check rest OLI records.
                              if (omebFlag){
                                  break;
                              }
                          }
                          
                      }
                      system.debug('===OMEB FLAG is===' +omebFlag);
                      if (opp.Must_Go_To_OMEB__c == true && omebFlag == false && (triggerAction == 'Update' || triggerAction == 'Delete')){
                          opp.Must_Go_To_OMEB__c = omebFlag;
                          opp.Approval_Status__c = '';
                          lstOppToUpdate.add(opp);
                          postObj = new FeedItem();
                          postObj.Body = Label.Non_PEP_Chatter_Message;
                          postObj.ParentId = opp.Id;
                          post.add(postObj);
                      }else if (opp.Must_Go_To_OMEB__c == false && omebFlag == true && (triggerAction == 'Update' ||triggerAction == 'Insert') ) {
                          opp.Must_Go_To_OMEB__c = omebFlag;
                          if(opp.StageName != Label.Opportunity_Stage_Identifying){
                              opp.StageName = Label.Opportunity_Stage_Identifying;
                              opp.Approval_Status__c = '';
                          }
                          lstOppToUpdate.add(opp);
                          postObj = new FeedItem();
                          postObj.Body = Label.PEP_Chatter_Message;
                          postObj.ParentId = opp.Id;
                          post.add(postObj);
                      }else if (opp.Must_Go_To_OMEB__c != omebFlag){
                          opp.Must_Go_To_OMEB__c = omebFlag;
                          lstOppToUpdate.add(opp);
                      }
                  }
        }
        
        if(lstOppToUpdate.size()>0){
            
            TriggerExecutionController.skipOpportunityTrigger(true);
            List<Database.SaveResult> opptyUpdateResultList = Database.update(lstOppToUpdate, false );   
            TriggerExecutionController.skipOpportunityTrigger(false);   
            
            if (mapOpptyToOli != null && !mapOpptyToOli.isEmpty()){    
                
                for(Integer i=0; i < opptyUpdateResultList.size(); i++){
                    Database.SaveResult sr = opptyUpdateResultList[i];
                    if (!sr.isSuccess()) {
                        String errMessage = '';
                        for(Database.Error err : sr.getErrors()) {
                            errMessage += err.getMessage() + ' ';
                        }
                        system.debug('sr: ' + sr);
                        for (OpportunityLineItem oli : mapOpptyToOli.get(lstOppToUpdate[i].id)){
                            oli.addError(errMessage);
                        }  
                    }
                }
            } else {
                ErrorLogger.writeErrors('SFDC', 'OpptyLineItemUtilities', 'OpptyLineItemUtilities.checkOpportunityNeedOmebApproval', opptyUpdateResultList, lstOppToUpdate) ;
            }
            
        }
        
        if(post.size() > 0){
            ChatterPostUtilities.doChatterPost(post,'OpptyLineItemUtilities');
        }
        
    }
    
    public static void createCorridorGuidance (List<OpportunityLineItem> lstOppLineItems, Map<Id,Opportunity> opportunityMap){
        
        List<Corridor_Guidance__c> lstTobeinsertedCGs = new List<Corridor_Guidance__c>();  
        for(opportunityLineItem oli : lstOppLineItems){
            
            if(opportunityMap.get(oli.OpportunityId) != null && Label.Ocean_Product_OipcCode.contains(oli.OIPC_Product_Code__c) && opportunityMap.get(oli.OpportunityId).RecordTypeId ==  System.Label.QuarterlyDealsRecordTypeId){  
                
                Corridor_Guidance__c cgObj = new  Corridor_Guidance__c();                                
                cgObj.Opportunity__c = oli.OpportunityId;
                cgObj.Product__c = oli.Product2Id;
                lstTobeinsertedCGs.add(cgObj);                  
            }
        }
        if(lstTobeinsertedCGs.size() > 0){
            List<Database.SaveResult> insertResult = Database.insert(lstTobeinsertedCGs, false );            
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemUtilities', 'OpptyLineItemUtilities.createCorridorGuidance', insertResult, lstTobeinsertedCGs) ;
            
        }
    }
    
    /*Method : cloneProductFeatures
* Author : Rakesh
* functionality : Clone Opportunity Product Feature when Opportunity is cloned with Line Items - SFSE-8521
*/ 
    public static void cloneProductFeatures(Map<Id, Id> sourceIdClonedIdMap) {
        List<Opportunity_Product_Configuration__c> OppFeatList = new List<Opportunity_Product_Configuration__c>();
        Opportunity_Product_Configuration__c newFeat;
        for(Opportunity_Product_Configuration__c oppFeature : [SELECT Id, Name, Product_Specificaiton_Parameter__c, Opportunity_Product__c, 
                                                         Product_Specification_Option__c, Specification_Option_Order__c 
                                                         FROM 
                                                         Opportunity_Product_Configuration__c where 
                                                         Opportunity_Product__c IN :sourceIdClonedIdMap.keySet()
                                                         ]){
                                                             newFeat = oppFeature.clone(false, false, false, false);
                                                             newFeat.Opportunity_Product__c = sourceIdClonedIdMap.get(oppFeature.Opportunity_Product__c);
                                                             OppFeatList.add(newFeat);
                                                         }
        
        if(!OppFeatList.isEmpty()){
            insert OppFeatList;
        }
    }
    
    /*Method : validateOpptyStageApprovalStatus
*Author : Kiran
*functionality : Stop creatining/deleting OLI if OMEB Opportunity in Quoting/Negotiating stage
*/ 
    
    public static void validateOpptyStageApprovalStatus(List<OpportunityLineItem> approvedSGOptyQuoteStage){
        for(OpportunityLineItem oliRec : approvedSGOptyQuoteStage){
            oliRec.addError(Label.OLI_Error);
        }
    }
    
    /*Method : validateOpptyPendingApprovalProcesses
*Author : Kiran
*functionality : Stop creating/updating/deleting OLI if OMEB Opportunity has pending approvals
*/ 
    
    public static void validateOpptyPendingApprovalProcesses(List<OpportunityLineItem> oliOpptyWithPendingApprovals, List<Opportunity> opptyWithPendingApprovals){
        if(oliOpptyWithPendingApprovals != null){
            for(OpportunityLineItem oliRec : oliOpptyWithPendingApprovals){
                oliRec.addError(Label.Opportunity_Pending_Approvals_Error);
            }
        }
        if(opptyWithPendingApprovals != null){
            for(Opportunity opptyRec : opptyWithPendingApprovals){
                opptyRec.addError(Label.Opportunity_Pending_Approvals_Error_Brand_Change);
            }
        }
    }
    
}