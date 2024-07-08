/*      
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0       SFSE-10984  16-May-2023     mahanthi.devi@maersk.com        To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 1.1		SFSE-9052	02-Jun-2023		Kiran@Maersk					Removing the logic implemented as part of SFSE-8521
* 2.0		SFSE-11132	24-07-2023		mahanthi.devi@maersk.com		To stamp the Global Hub product in Product for Approval field
* 3.0		SFSE-11753	30-10-2023		mahanthi.devi@maersk.com		To change the product family references to oipc code
* 4.0       SFSE-13691  02-01-2023      Aleena.akhtar@maesrk.com        To remove Product Name references 
*/
public class OpportunityProductUtilities {
    public static Map<Id, String>  mapCntryBDA = new Map<Id, String>();        
    
    public static void  checkcountryToRegion(Set<Id> setGeoIds){
        //Fetch BDA based on opptyprod Country 
        
        for(BDA_Geography__c lstBDAGeo :[select Id, Geography__c, BDA__c,BDA__r.Name, BDA__r.Parent_BDA__r.Name,BDA__r.Parent_BDA__c from BDA_Geography__c where Geography__c in :setGeoIds and BDA__r.Type__c = 'Cluster']) {
            mapCntryBDA.put(lstBDAGeo.Geography__c, lstBDAGeo.BDA__r.Parent_BDA__r.Name);
        }   
    } 
    public static void ProductListUpdate(List<opportunity_Product__c> lstOPs){
        system.debug('entered here');
        List<opportunity> listOpptyUpdate = new List<opportunity> (); //list of Opportunity which needs to be updated
        List<opportunity_Product__c> listOpptyProd = new List<opportunity_Product__c>(); 
        
        Set<Id> setOpptyList1= new Set<Id>();
        Set<Id> setParentGeoIds = new Set<Id>();
        
        Map<String,Set<String>> productOipcCodetoRegionSet = new Map<String,Set<String>>();
        
        //Map<String,Set<String>> productFmlytoName= new Map<String,Set<String>>();        
        //  Map<Id, String>  mapCntryBDA = new Map<Id, String>();        
        Map<String,String> mapProdApprovalMD = new Map<String, String>();     
        List<string> excludeProducts = new List<string>{'CS','WD'};
            set<String> deprecatedProductSet = new set<string>();//SFSE-10552
        deprecatedProductSet.addall(Label.OMEBProductFamily.split(','));//SFSE-10552
        
        
        String stringProductList;
        String keyStr='';
        
        //Fetch contracting Products For Approval metadata type
        List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
        // Logic to get Product Approval code from Metadata based on Product oipc code
        // if Product oipc code and name on opptyprod matches in Metadata, populate the corresponding Approval code. If match is only on oipc code, name is null in metadata, populate the corresponding approval code.
        
        if(productsForApprovalList.size() >0){
            for(Products_For_Approval__mdt prodApproval : productsForApprovalList){
                if(prodApproval.Active__c == true){
                    //String tempKey = prodApproval.Family_Code__c;
                    String tempKey = '';
                    if(!String.isBlank(prodApproval.OIPC_Code__c) /*&& !String.isBlank(prodApproval.Family_Code__c)*/){//SFSE-10552
                        tempKey = prodApproval.OIPC_Code__c;
                    }else{
                        if(deprecatedProductSet.contains(prodApproval.Product_Name__c)){ // for Supply Chain Orchestrator as Family Code and OIPC Code is null for this product
                            tempKey = prodApproval.Product_Name__c;
                        } else{
                            tempKey ='NA';     
                        }
                    }
                    
                    if(String.isBlank(prodApproval.Region__c)){
                        tempKey +='-NA';
                    }else{
                        tempKey +='-'+prodApproval.Region__c;
                    }
                    system.debug('@@@ : keystr - ' + tempKey);   
                    // Prepares the temp key        
                    mapProdApprovalMD.put(tempKey, prodApproval.Product_Approval_Code__c);
                    
                    
                    if(productOipcCodetoRegionSet.containsKey(prodApproval.OIPC_Code__c)){        
                        Set<String> tempRegionSet = productOipcCodetoRegionSet.get(prodApproval.OIPC_Code__c);
                        tempRegionSet.add(prodApproval.Region__c);
                        productOipcCodetoRegionSet.put(prodApproval.OIPC_Code__c,tempRegionSet);
                    }else{
                        productOipcCodetoRegionSet.put(prodApproval.OIPC_Code__c,new Set<String>{prodApproval.Region__c});
                    }
                    
                    
                   /* if(productFmlytoName.containsKey(prodApproval.Product_Name__c)){ //oipc code check instead of product name   
                        Set<String> tempNameSet = productFmlytoName.get(prodApproval.Product_Name__c);
                        tempNameSet.add(prodApproval.OIPC_Code__c);
                        productFmlytoName.put(prodApproval.Product_Name__c,tempNameSet);
                    }else{
                        productFmlytoName.put(prodApproval.Product_Name__c,new Set<String>{prodApproval.OIPC_Code__c});
                    }*/
                }
            }  
        }
        
        //Fetch opportunity based on Opportunity Products 
        for(Opportunity_Product__c setOpptyList :lstOPs){
            setOpptyList1.add(setOpptyList.OpportunityId__c);                    
        }
        //Fetch opportunity Products
        for( Opportunity_Product__c opRec : [Select Id,Product2ID__r.Name,Product2ID__r.OIPC_Code__c,Product2ID__r.Family_Code__c,Product_Family__c,Country__c,OpportunityId__c,product2ID__r.Include_in_OMEB_Approvals__c,Annualized_Gross_Profit__c,Exclude_from_OMEB__c,OIPC_Product_Code__c from Opportunity_Product__c where OpportunityId__c in: setOpptyList1]){
            if(opRec.product2ID__r.Include_in_OMEB_Approvals__c == true){
                setParentGeoIds.add(opRec.Country__c);
                listOpptyProd.add(opRec);
            } 
        }
        checkcountryToRegion(setParentGeoIds);
        /* //Fetch BDA based on opptyprod Country 
for(BDA_Geography__c lstBDAGeo :[select Id, Geography__c, BDA__c,BDA__r.Name, BDA__r.Parent_BDA__r.Name,BDA__r.Parent_BDA__c from BDA_Geography__c where Geography__c in :setParentGeoIds and BDA__r.Type__c = 'Cluster']) {
mapCntryBDA.put(lstBDAGeo.Geography__c, lstBDAGeo.BDA__r.Parent_BDA__r.Name);
}*/
        
        // generate Key
        Boolean olithreshold = false;
        for(Opportunity oppRec : [Select Id,Products_for_Approval__c from opportunity where id in: setOpptyList1]){
            stringProductList='';
            System.debug(oppRec +' !!!!!!!');
            oppRec.Products_for_Approval__c ='';
            for(Opportunity_Product__c olObj: listOpptyProd){
                if(olObj.OpportunityId__c == oppRec.Id && olObj.Exclude_from_OMEB__c == false){
                    system.debug('olObj'+olObj);
                    if(deprecatedProductSet.contains(olObj.Product2ID__r.Name)){
                        olObj.Product2ID__r.Family_Code__c = Label.lead_logistics_FamiliyCode;
                    }
                    //keyStr=olObj.Product2ID__r.Family_Code__c; 
                    keyStr='';             
                   // if(productFmlytoName.containsKey(olObj.Product2ID__r.Name)){
                     //  if(productFmlytoName.get(olObj.Product2ID__r.Name).contains(olObj.Product2ID__r.OIPC_Code__c)){
                            if(deprecatedProductSet.contains(olObj.Product2ID__r.Name) && olObj.Product2ID__r.OIPC_Code__c == null){
                                keyStr = olObj.Product2ID__r.Name;
                            }else{
                                keyStr = olObj.Product2ID__r.OIPC_Code__c;
                            }
                        //}else{
                          //  keyStr += '-NA';
                        //}
                 //   } 
                    
                    String APAregion = System.Label.Asia_Pacific_Region;
                    String OCFoipcCode = System.Label.OCF_Oipc_Code;
                    String alternateKeyStr = keyStr + '-NA';
                    if(productOipcCodetoRegionSet.containsKey(olObj.Product2ID__r.OIPC_Code__c)){
                        String opRegion = mapCntryBDA.get(olObj.Country__c); 
                        
                        if(opRegion!= null && productOipcCodetoRegionSet.get(olObj.Product2ID__r.OIPC_Code__c).contains(opRegion)){
                            //to check if OCF product added with APA region 
                            if(opRegion == APAregion){
                                if(olObj.Annualized_Gross_Profit__c>250000 && olObj.Product2ID__r.OIPC_Code__c == OCFoipcCode){
                                    olithreshold = true;
                                }
                            }
                            keyStr += '-'+opRegion;
                        }else{
                            keyStr += '-NA';
                            
                        }
                    }
                    
                    system.debug('@@@ : keystr - ' + keyStr);
                    system.debug('@@@ : alternatekeystr - ' + alternateKeyStr);
                    //get product Code from Map
                    String productCode ='';
                    if(mapProdApprovalMD.containsKey(keyStr)){
                        productCode = mapProdApprovalMD.get(keyStr);
                        
                    } else if(mapProdApprovalMD.containsKey(alternateKeyStr)){
                        productCode = mapProdApprovalMD.get(alternateKeyStr);
                    }
                    //if GP of opptyprod is less than 100k than product for approval will be CL rather than WD 
                    if(productCode.contains('WD04') && olithreshold == false){
                        productCode = productCode.remove('WD04');
                    }
                    if(!productCode.contains('WD04')){
                        if(olObj.Annualized_Gross_Profit__c < 100000 && productCode.contains('WD')){ 
                            productCode =  productCode.replace('WD','CL') ;
                        }
                    }
                    //if GP of Global Hub Product is less than 100k than product for approval will be GL rather than GH 
                    if(olObj.Annualized_Gross_Profit__c < 100000 && productCode.contains('GH')){ 
                        productCode =  productCode.replace('GH','GL') ;
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
            ErrorLogger.writeErrors('SFDC', 'OpportunityProductUtilities', 'OpportunityProductUtilities.ProductListUpdate', opptyUpdateResultList, listOpptyUpdate) ; // #RQ-005636
            TriggerExecutionController.skipOpportunityTrigger(false);   
        }
        
    }
    
    public static void checkProductsForOmeb (List<opportunity_Product__c> lstOPs, List<Id> opptyIds, String triggerAction){
        // fetch custom metadata 
        List<Products_For_Approval__mdt> lstProdForApproval = new List<Products_For_Approval__mdt>(); 
        //[SELECT MasterLabel, field_to_compare__c, Operator__c, Value_to_Compare__c FROM Products_For_Approval__mdt WHERE IsActive__c = true];
        
        for (Products_For_Approval__mdt pf : Products_For_Approval__mdt.getAll().values()){
            if(pf.Active__c){
                lstProdForApproval.add(pf);
            }
        }
        system.debug(lstProdForApproval.size());
        String fieldsToFetch =''; // get list of fields to be fetched from Opportunity Product
        
        // form map of Product oipc code ==> Custom Metadata record
        Map<String, List<Products_For_Approval__mdt>> mapProdNameToSetting = new Map<String, List<Products_For_Approval__mdt>>();
        for (Products_For_Approval__mdt rec : lstProdForApproval){
            List<Products_For_Approval__mdt> tmpList = new List<Products_For_Approval__mdt>();
            if (mapProdNameToSetting.containskey(rec.OIPC_Code__c)){
                tmpList = mapProdNameToSetting.get(rec.OIPC_Code__c);
            }
            tmpList.add(rec);
            if(rec.OIPC_Code__c != null){
                mapProdNameToSetting.put(rec.OIPC_Code__c, tmpList);
                //system.debug(mapProdNameToSetting.get(rec.OIPC_Code__c));
            }else{
                mapProdNameToSetting.put(rec.Product_Name__c, tmpList);
                //system.debug(mapProdNameToSetting.get(rec.Product_Name__c));
            }
            
            //system.debug(mapProdNameToSetting);
            if (! fieldsToFetch.contains(rec.Field_to_compare__c)){
                fieldsToFetch += rec.Field_to_compare__c + ', ';
            }
        }
        
        system.debug('fieldsToFetch=='+fieldsToFetch);
        
        // If oppty product being inserted, updated or deleted is from given product oipc code then create a list of Oppty Id
        List<Id> oppIdToCheckLst = new List<Id>();
        Map<Id, List<Opportunity_Product__c>> mapOpptyToOpptyProd = new Map<Id, List<Opportunity_Product__c>>();
        
        system.debug('lstOfOppProduct=='+lstOPs);
        if (lstOPs != null){
            for (Opportunity_Product__c opptyprod : lstOPs){
                
                if (mapProdNameToSetting.containsKey(opptyprod.OIPC_Product_Code__c) || mapProdNameToSetting.containsKey('Supply Chain Orchestrator')){
                    oppIdToCheckLst.add(opptyprod.OpportunityId__c);
                    system.debug('entered'+oppIdToCheckLst.size());
                    List<Opportunity_Product__c> tmpOpptyprod = new List<Opportunity_Product__c>();
                    if (mapOpptyToOpptyProd.containsKey(opptyprod.OpportunityId__c)){
                        tmpOpptyprod = mapOpptyToOpptyProd.get(opptyprod.OpportunityId__c);
                    }
                    tmpOpptyprod.add(opptyprod);
                    mapOpptyToOpptyProd.put(opptyprod.OpportunityId__c, tmpOpptyprod);
                    system.debug('mapOpptyToOpptyProd: '+mapOpptyToOpptyProd);
                }
            }
        }   
        
        if (opptyIds != null){
            oppIdToCheckLst.addAll(opptyIds);
        }
        system.debug(oppIdToCheckLst.size()+'oppIdToCheckLst'); 
        Set<String> lstFilterOption = mapProdNameToSetting.keySet();
        if (! oppIdToCheckLst.isEmpty()){
            
            String strQuery = 'SELECT Id, Must_Go_To_OMEB__c,Products_for_Approval__c, Liner_Brand__c, StageName, (SELECT Id, ' + fieldsToFetch + ' Product_Family__c,Country__c,ProductCode__c,Product2ID__r.Name,Exclude_from_OMEB__c,OIPC_Product_Code__c FROM Opportunity_Products__r WHERE Product2ID__r.Include_in_OMEB_Approvals__c = true and (OIPC_Product_Code__c in: lstFilterOption or Product2ID__r.Name in: lstFilterOption)' ; 
            strQuery +=   ' ) FROM Opportunity WHERE id in: oppIdToCheckLst' ;
            
            system.debug('strQuery: ' + strQuery);
            List<Opportunity> lstOppToCheck = database.query(strQuery);
            system.debug('lstOppToCheck'+lstOppToCheck.size());
            checkOpportunityNeedOmebApproval(lstOppToCheck, mapProdNameToSetting, triggerAction, mapOpptyToOpptyProd);
        }
    }
    
    public static void checkOpportunityNeedOmebApproval (List<opportunity> lstOppty, Map<String, List<Products_For_Approval__mdt>> mapProdNameToSetting, String triggerAction, Map<Id, List<Opportunity_Product__c>> mapOpptyToOpptyProd){
        
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
        
        for(Opportunity opp : lstOppty){
            string s = opp.id;
            List<string> prodforapprvl = new List<String>();
            if(opp.Products_for_Approval__c != null){
                List<String> productsForApproval = opp.Products_for_Approval__c.split(';');
                for(String tmpstr : productsForApproval){
                    if(tmpstr.startswith('CL')){
                        tmpstr = tmpstr.replace('CL','WD');
                    }else if(tmpstr.contains('GL')){
                        tmpstr = tmpstr.replace('GL','GH');
                    }
                    prodforapprvl.add(tmpstr);    
                }
            }
            //list<Opportunity_Product__c> op = [select id from Opportunity_Product__c where OpportunityId__r.Id =: opp.Id];
            // If OMEB flag is already true and we are inserting new record, it wont change OMEB flag vlaue so no need to execute logic
            // If OMEB flag is false and we are deleting a record, it won't change flag value so no need to execute logic
            // If OMEB flag is false and brand donesn't contains OMEB Brands, it won't change flag value so no need to execute logic
            
            if (!((triggerAction == 'Insert' && opp.Must_Go_To_OMEB__c == true) || (triggerAction == 'Delete' && opp.Must_Go_To_OMEB__c == false) ||
                  (triggerAction == 'Update' && opp.Must_Go_To_OMEB__c == false && !listBrands.contains(opp.Liner_Brand__c)))){
                      System.debug('---237---');
                      
                      Map<String, decimal> pfSumPerProdName = new Map<String, decimal>();
                      boolean omebFlag = false;
                      if(listBrands.contains(opp.Liner_Brand__c)){
                          system.debug(opp.Opportunity_Products__r);
                          for (Opportunity_Product__c opptyprod : opp.Opportunity_Products__r){
                              if(opptyprod.Exclude_from_OMEB__c == false){
                                  // get the custom metadata applicable to opptyprod's prod oipc code.
                                  // in case there are 2 criteria defined on same product oipc code use for loop..
                                  string key = '';
                                  if(opptyprod.OIPC_Product_Code__c != null){
                                      key = opptyprod.OIPC_Product_Code__c;
                                  }else{
                                      key = opptyprod.Product2ID__r.Name;
                                  }
                                  
                                  for (Products_For_Approval__mdt criteria : mapProdNameToSetting.get(key)){
                                      system.debug('criteria@@'+criteria);
                                      if(prodforapprvl !=null){
                                          if(prodforapprvl.contains(criteria.Product_Approval_Code__c)){
                                              double criteriaValue = (double) opptyprod.get(criteria.Field_to_compare__c); // get the value for 'field_to_compare' field from opptyprod record
                                              double valueToCompare = criteria.Threshold__c; 
                                              if (pfSumPerProdName.containskey(key)){
                                                  System.debug('mapProdNameToSetting '+pfSumPerProdName.get(key));
                                                  criteriaValue += pfSumPerProdName.get(key);
                                              } 
                                              System.debug('criteriaValue >> '+criteriaValue);
                                              pfSumPerProdName.put(opptyprod.OIPC_Product_Code__c,criteriaValue );
                                              system.debug('$$$ pfSumPerProdName: '+ pfSumPerProdName);
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
                                      }
                                  }
                                  /*else{
if(mapProdNameToSetting.containsKey(opptyprod.Product2ID__r.name)){
omebFlag = true;//for supply chain orchestrator
break;
}}*/
                              }
                              // end for loop as flag is set to true for 1 opptyprod, no need to check rest opptyprod records.
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
            
            if (mapOpptyToOpptyProd != null && !mapOpptyToOpptyProd.isEmpty()){    
                
                for(Integer i=0; i < opptyUpdateResultList.size(); i++){
                    Database.SaveResult sr = opptyUpdateResultList[i];
                    if (!sr.isSuccess()) {
                        String errMessage = '';
                        for(Database.Error err : sr.getErrors()) {
                            errMessage += err.getMessage() + ' ';
                        }
                        system.debug('sr: ' + sr);
                        for (Opportunity_Product__c opptyprod : mapOpptyToOpptyProd.get(lstOppToUpdate[i].id)){
                            opptyprod.addError(errMessage);
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
    
    public static void createCorridorGuidance (List<Opportunity_Product__c> lstOppLineItems, Map<Id,Opportunity> opportunityMap){
        
        List<Corridor_Guidance__c> lstTobeinsertedCGs = new List<Corridor_Guidance__c>();  
        for(Opportunity_Product__c opptyprod : lstOppLineItems){
            
            if(opportunityMap.get(opptyprod.OpportunityId__c) != null && opptyprod.Product2ID__r.Family == Label.Ocean_Product && opportunityMap.get(opptyprod.OpportunityId__c).RecordTypeId ==  System.Label.QuarterlyDealsRecordTypeId){  
                
                Corridor_Guidance__c cgObj = new  Corridor_Guidance__c();                                
                cgObj.Opportunity__c = opptyprod.OpportunityId__c;
                cgObj.Product__c = opptyprod.Product2ID__c;
                lstTobeinsertedCGs.add(cgObj);                  
            }
        }
        if(lstTobeinsertedCGs.size() > 0){
            List<Database.SaveResult> insertResult = Database.insert(lstTobeinsertedCGs, false );            
            ErrorLogger.writeErrors('SFDC', 'OpptyLineItemUtilities', 'OpptyLineItemUtilities.createCorridorGuidance', insertResult, lstTobeinsertedCGs) ;
            
        }
    }
    
    /*Method : validateOpptyStageApprovalStatus
*Author : Kiran
*functionality : Stop creatining/deleting opptyprod if OMEB Opportunity in Quoting/Negotiating stage
*/ 
    public static void validateOpptyStageApprovalStatus(List<Opportunity_Product__c> approvedSGOptyQuoteStage){
        for(Opportunity_Product__c opRec : approvedSGOptyQuoteStage){
            opRec.addError(Label.OLI_Error);
        }
    }
    
    /*Method : validateOpptyPendingApprovalProcesses
*Author : Kiran
*functionality : Stop creating/updating/deleting opptyprod if OMEB Opportunity has pending approvals
*/ 
    public static void validateOpptyPendingApprovalProcesses(List<Opportunity_Product__c> opptyprodOpptyWithPendingApprovals, List<Opportunity> opptyWithPendingApprovals){
        if(opptyprodOpptyWithPendingApprovals != null){
            for(Opportunity_Product__c opRec : opptyprodOpptyWithPendingApprovals){
                opRec.addError(Label.Opportunity_Pending_Approvals_Error);
            }
        }
        if(opptyWithPendingApprovals != null){
            for(Opportunity opptyRec : opptyWithPendingApprovals){
                opptyRec.addError(Label.Opportunity_Pending_Approvals_Error_Brand_Change);
            }
        }
    }
    
    /***********************************************************************************
* *Method : set stampingOLiID at approval History with _D
*  Author : Rama
************************************************************************************/    
    public static void stampingOLIidsonhistoryRecords(List<Id> olilist){
        set<Id> olids = new set<Id>();
        set<Id> opprids = new set<Id>();
        List<Approval_History__c> ahlisttoUpdate = new List<Approval_History__c>();
        
        if(!olilist.isEmpty()){
            for(Opportunity_Product__c opRec : [Select Id,OpportunityId__c from Opportunity_Product__c where Id IN:olilist]){
                olids.add(opRec.Id);
                opprids.add(opRec.OpportunityId__c);
            }
            List<Approval_History__c> aprHisList = [SELECT TargetObjectId__c,Opportunity_Product__c, Submitter_Comments__c,createdById,Approval_Step__r.Approval_Process_Name__r.sla__c,Key__c,Approval_Step__r.Escalation_owner__c,Approval_Step__r.Escalation_owner__r.Email,
                                                    Step_Name__c, Status__c, Name, IsDeleted, Id,CreatedDate,Approved_By__r.Email,Approval_Step__r.Step_Name__c,
                                                    Approver_Comments__c, Approval_Step__r.Current_owner__r.name,Approval_Step__r.Approval_Process_Name__r.name,Approved_By__r.Name,
                                                    Approval_Step__r.Approval_Process_Name__r.Gate__c, Action_Date__c,TargetObjectId__r.Products_for_Approval__c FROM Approval_History__c
                                                    WHERE TargetObjectId__c IN:opprids];
            if(!aprHisList.isEmpty()){
                for(Approval_History__c ah : aprHisList){
                    system.debug('check----'+ah.Opportunity_Product__c);
                    String prodStamp;
                    if(!String.isBlank(ah.Opportunity_Product__c)){
                        List<String> optyProdIds = ah.Opportunity_Product__c.split(',');
                        Set<String> allIds = New Set<String>();
                        for(Integer i=(optyProdIds.size()-1);i>=0;i--){
                            String prodId = optyProdIds[i];
                            if(prodId.endswithIgnoreCase('_D')){
                                optyProdIds.remove(i);
                                allIds.add(prodId);
                            }
                        }
                        for(String str : optyProdIds){
                            System.debug('Str >> '+str);
                            if(olids.contains(str)){
                                prodStamp = str+'_D';
                                allIds.add(prodStamp);
                            }else{
                                
                                allIds.add(str);
                            }
                        }
                        String allprodId;
                        for(String productId : allIds){
                            if(productId != null){
                                if( allprodId ==  null){
                                    allprodId =   productId+',';
                                }else{
                                    allprodId +=   productId+',';
                                }
                            }
                        }
                        if(allprodId != null){
                            allprodId = allprodId.endsWith(',') ? allprodId.removeEnd(',') : allprodId;
                            ah.Opportunity_Product__c  = allprodId ;
                            ahlisttoUpdate.add(ah);
                        }
                    }
                }
                
            }
        }try{
            if(!ahlisttoUpdate.isEmpty()){
                update ahlisttoUpdate;
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Approval_History__c', 'OpportunityProductUtilities.stampingOLIidsonhistoryRecords', new list<Exception>{e});
        }
    }
    
}