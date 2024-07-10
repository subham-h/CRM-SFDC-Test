/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11961  18-08-2023     Seba & Bharti     Created Code for assigning the target to Territories.
*  2.0      SFSE-13429  24-11-2023     Bharti           Modified the code to create TAA field in target customer Portfolio
* 2.1	   SFSE-13767  26-12-2023	  Vinay				Added extra condition to where clause so that code run only for Existing Biz(Having Accounts)
*/


public class TargetsAssignToSalesRep {
    
    public static Set<String> setHoldsParentIds = new Set<String>();
    public static Map<String,String> mapAccountToRepresentConcernCustomerCode = new Map<String,String>();
    public static Set<String> lstterritoriesTemp = new Set<String>();
    public static Map<String, String> mapTargetBrandMapping =  TargetsAssignToSalesRep.targetBrandMappingMethod();   
    
    public static void getSalesTargetItemMeasure(List<Target_measure__c> lstOfTargetMeasure){
        Map<String,List<Territory_Account_Association__c>> mapOFTaas = new Map<String,List<Territory_Account_Association__c>>();
        List<Territory_Account_Association__c> listTAAForRC = new List<Territory_Account_Association__c>();
        Set<String> setHoldsAccountIds = new Set<String>();
        Map<String,List<Territory_Account_Association__c>> mapRCAccCodeToTAAList = new Map<String,List<Territory_Account_Association__c>>();
        
        Map<String,Set<String>> mapMeasurePartyTypeAndUserId = new Map<String,Set<String>>();   
        Map<Id, Set<Id>> mapMeasrId_SetTerrIds = new Map<Id, Set<Id>>(); //Key: MeasureId  Value: User Ids
        Set<String> setMeasureIdAndTerrId = new Set<String>();
        
        // Added Target_Item__r.Account__c!=NULL condition to below SOQL so that Code should run only for Existing Biz where Account is not null.
        List <Target_Measure__c> lstTargetMeasure =[SELECT Id,Target_Item__r.Target__c,Target_Item__r.Account__r.Customer_Code__c,Party_Type__c,
                                                    Target_Item__r.Account__r.Represents_Concern__c,Target_Item__r.Represent_Concern_Account__c,
                                                    Target_Item__r.Represents_Concern_Customer_Code__c,Target_Item__r.Account__r.ParentId,
                                                    Target_Item__r.Sales_Target_Item_Group__r.Executing_Area__c,Target_Item__r.Sales_Target_Item_Group__r.Executing_Country__c,
                                                    Target_Item__r.Target__r.Status__c,Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c FROM Target_Measure__c where ID IN :lstOfTargetMeasure AND Target_Item__r.Account__c!=NULL];
        if(!lstTargetMeasure.isEmpty()){
        for(Target_Measure__c tm : lstTargetMeasure){
            setHoldsAccountIds.add(tm.Target_Item__r.Account__r.Customer_Code__c) ;
            setHoldsParentIds.add(tm.Target_Item__r.Represents_Concern_Customer_Code__c);
            //Holds the account customer code as key and the customer code of RC in its hierarchy as the value 
            mapAccountToRepresentConcernCustomerCode.put(tm.Target_Item__r.Account__r.Customer_Code__c,tm.Target_Item__r.Represents_Concern_Customer_Code__c);
            }}
        
        if(!setHoldsAccountIds.isEmpty()){
        for(Territory_Account_Association__c taa : [SELECT Id,Account__r.Customer_Code__c,Customer_Status__c,Product_Responsibility__c,Start_Date__c,End_Date__c,
                                                    Account__r.Represents_Concern__c,Account__r.ParentId,Portfolio_Owner_Responsibility__c,Territory__r.Portfolio_Owner__c,
                                                    Business_Defined_Area__c,Country__c,Brand__c FROM Territory_Account_Association__c WHERE 
                                                    (Account__r.Customer_Code__c IN : setHoldsParentIds OR Account__r.Customer_Code__c IN : setHoldsAccountIds)
                                                    AND (Start_Date__c <= TODAY OR Start_Date__c > TODAY)  AND (End_Date__c = null OR End_Date__c >= TODAY) AND Product_Responsibility__c != :TAASettingConstants.PR_Ocean]){
                                                        
                                                        if(setHoldsAccountIds.contains(taa.Account__r.Customer_Code__c)){
                                                            if (!mapOFTaas.containsKey(taa.Account__r.Customer_Code__c)) {
                                                                mapOFTaas.put(taa.Account__r.Customer_Code__c, new List<Territory_Account_Association__c>());
                                                            }
                                                            mapOFTaas.get(taa.Account__r.Customer_Code__c).add(taa);
                                                        }
                                                                                                                
                                                        if(setHoldsParentIds.contains(taa.Account__r.Customer_Code__c)){
                                                            if(!mapRCAccCodeToTAAList.containsKey(taa.Account__r.Customer_Code__c)){
                                                                mapRCAccCodeToTAAList.put(taa.Account__r.Customer_Code__c, new List<Territory_Account_Association__c>());
                                                            } 
                                                            mapRCAccCodeToTAAList.get(taa.Account__r.Customer_Code__c).add(taa);
                                                        }   
                                                        }}
        
        if(!lstTargetMeasure.isEmpty()){                                                            
        for( Target_Measure__c targetMeasure : lstTargetMeasure ){
            if(targetMeasure.Target_Item__r.Target__r.Status__c != TargetSettingConstants.TARGET_STATUS_CLOSED && targetMeasure.Target_Item__r.Target__r.Status__c != TargetSettingConstants.TARGET_STATUS_CANCELLED ){
                //call represent concern account logic
                if(targetMeasure.Target_Item__r.Account__r.Represents_Concern__c  ){ 
                    mapMeasurePartyTypeAndUserId = checkPOEligibleUser(mapOFTaas,targetMeasure); 
                }
                
                //call normal client account logic 
                else if(targetMeasure.Target_Item__r.Account__r.ParentId  == null){
                    mapMeasurePartyTypeAndUserId = checkPOEligibleUserClient(mapOFTaas,targetMeasure);
                }
                
                else{  
                    //If the NCC account on Target Item has TAA records
                    //If there is zero TAA for NCC, then also RC needs to be checked
                    mapMeasurePartyTypeAndUserId = checkPOEligibleUserNRC(mapOFTaas,mapRCAccCodeToTAAList,targetMeasure);
                } 
                if(mapMeasurePartyTypeAndUserId.containsKey(targetMeasure.Party_Type__c) && mapMeasurePartyTypeAndUserId.get(targetMeasure.Party_Type__c) != Null){
                    //Loop over the territoryIDs and creating unique key of current measureId + territoryId
                    for(String territoryId: mapMeasurePartyTypeAndUserId.get(targetMeasure.Party_Type__c)){
                        String measureTerrrIdKey = targetMeasure.Id + '-' + territoryId;
                        setMeasureIdAndTerrId.add(measureTerrrIdKey);
                    }
                } 
            }
            
            }}
        
        //Call the method to insert  Target Customer Portfolio Record
        if(setMeasureIdAndTerrId!= Null)
            TargetAssignmentUtility.insertTargetCustomerPortfolioRecord(setMeasureIdAndTerrId);
    }
    
    //Get Po/Consignee/Shipper Eligible territories for client type of account 
    public static Map<String,Set<String>>  checkPOEligibleUserClient(Map<String,List<Territory_Account_Association__c>> mapOfTaas,Target_Measure__c targetMeasureRecord){
        
        Map<String,Set<String>> mapPartyTypeAndTaa = new Map<String,Set<String>>();
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        
        if(targetMeasureRecord.Party_Type__c == TargetSettingConstants.PARTY_PO && mapOfTaas.containskey(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c)
           && mapOfTaas.get(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c) != Null){
            lstTAA = mapOfTaas.get(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c);
            
            Set<String> lstOfterritories = getUserForPOTargetsNRC(lstTAA, targetMeasureRecord, FALSE);
            
            if(!lstOfterritories.isEmpty()){
                mapPartyTypeAndTaa.put(targetMeasureRecord.Party_Type__c ,lstOfterritories);
                
            }
        }
        Set<String> lstOfShipperConsigneeTAAIds = checkConsigneeAndShipper(mapOfTaas, targetMeasureRecord);
        if(!lstOfShipperConsigneeTAAIds.isEmpty()){
            mapPartyTypeAndTaa.put(targetMeasureRecord.Party_Type__c ,lstOfShipperConsigneeTAAIds);
        } 
        return mapPartyTypeAndTaa;
    }
    
    //get PO eligible territories for represent concern type of account
    public static Map<String,Set<String>> checkPOEligibleUser(Map<String,List<Territory_Account_Association__c>> mapOfTaas,Target_Measure__c lstTargetMeasure){
        Map<String,Set<String>> mapPartyTypeAndTaa = new Map<String,Set<String>>();
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Set<String> lstOfShipperConsigneeTAAs = new Set<String>();
        
        if(lstTargetMeasure.Party_Type__c == TargetSettingConstants.PARTY_PO && mapOfTaas.containskey(lstTargetMeasure.Target_Item__r.Account__r.Customer_Code__c)
           && mapOfTaas.get(lstTargetMeasure.Target_Item__r.Account__r.Customer_Code__c) != Null){
            lstTAA = mapOfTaas.get(lstTargetMeasure.Target_Item__r.Account__r.Customer_Code__c);
            Set<String> lstOfterritories = getUserForPOTargets(lstTAA,lstTargetMeasure);
            if(!lstOfterritories.isEmpty()){
                mapPartyTypeAndTaa.put(lstTargetMeasure.Party_Type__c ,lstOfterritories);
            }
        }  
        
        if(lstTargetMeasure.Party_Type__c == TargetSettingConstants.PARTY_SHIPPER || lstTargetMeasure.Party_Type__c == TargetSettingConstants.PARTY_CONSIGNEE){
          
            lstOfShipperConsigneeTAAs = checkConsigneeAndShipper(mapOfTaas, lstTargetMeasure);
            if(!lstOfShipperConsigneeTAAs.isEmpty()){
                mapPartyTypeAndTaa.put(lstTargetMeasure.Party_Type__c ,lstOfShipperConsigneeTAAs);
            }
        } 
        return mapPartyTypeAndTaa;
    }
    //get PO eligible territories for Non represent concern type of account
    public static Map<String,Set<String>> checkPOEligibleUserNRC(Map<String,List<Territory_Account_Association__c>> normalClientAccToTAALst,
                                                             Map<String,List<Territory_Account_Association__c>> RCAccToTAALst, 
                                                                 Target_Measure__c targetMeasureRecord)
    {
        Map<String,Set<String>> mapPartyTypeAndTaa = new Map<String,Set<String>>();
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Set<String> lstOfterritories = new Set<String>(); 
        Set<String> lstOfShipperConsigneeTAAs = new Set<String>();
        lstterritoriesTemp = new Set<String>(); 
        
                                                                     if(targetMeasureRecord.Party_Type__c == TargetSettingConstants.PARTY_PO){
            //If Account on target item has TAAs
            
            if(normalClientAccToTAALst!=NULL && 
               normalClientAccToTAALst.containskey(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c)){  
                lstTAA = normalClientAccToTAALst.get(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c);
                                                                                
                lstOfterritories = getUserForPOTargetsNRC(lstTAA,targetMeasureRecord, FALSE); 
                                                                                
            } 
            //Check if there exists a RC in the hierarchy if Normal Client of Concern
            if (mapAccountToRepresentConcernCustomerCode.containsKey(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c) &&
                                                                             mapAccountToRepresentConcernCustomerCode.get(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c) != Null &&
                                                                             RCAccToTAALst.get(targetMeasureRecord.Target_Item__r.Represents_Concern_Customer_Code__c) != Null &&
                RCAccToTAALst.containsKey(mapAccountToRepresentConcernCustomerCode.get(targetMeasureRecord.Target_Item__r.Account__r.Customer_Code__c))){
                    lstTAA = RCAccToTAALst.get(targetMeasureRecord.Target_Item__r.Represents_Concern_Customer_Code__c);      
                                                                                
                    lstterritoriesTemp = getUserForPOTargetsNRC(lstTAA,targetMeasureRecord,TRUE);
                    
                                                                                 
                    lstOfterritories.addAll(lstterritoriesTemp);   
                }
            
        }
        
        
        if(!lstOfterritories.isEmpty()){
            mapPartyTypeAndTaa.put(targetMeasureRecord.Party_Type__c ,lstOfterritories);
            
        }
        
        //For Shipper and consignee (NCC), no need to check for Represent Concern
                                                                     if(targetMeasureRecord.Party_Type__c == TargetSettingConstants.PARTY_SHIPPER || targetMeasureRecord.Party_Type__c == TargetSettingConstants.PARTY_CONSIGNEE){
            lstOfShipperConsigneeTAAs = checkConsigneeAndShipper(normalClientAccToTAALst, targetMeasureRecord);
                                                                        
            if(!lstOfShipperConsigneeTAAs.isEmpty()){
                mapPartyTypeAndTaa.put(targetMeasureRecord.Party_Type__c ,lstOfShipperConsigneeTAAs);
                
            }
        } 
        return mapPartyTypeAndTaa;
    }
    
    
    
    //get consignee and shipper eligible territories for all type of account 
    public static Set<String> checkConsigneeAndShipper(Map<String,List<Territory_Account_Association__c>> mapOfTaas,Target_Measure__c lstTargetItem){
        String measureBrand;
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Set<String> setOfTerritoriesId = new Set<String>();
        if(mapTargetBrandMapping.containsKey(lstTargetItem.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c)){
            measureBrand = mapTargetBrandMapping.get(lstTargetItem.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
        }
        
        if((lstTargetItem.Party_Type__c == TargetSettingConstants.PARTY_CONSIGNEE || lstTargetItem.Party_Type__c == TargetSettingConstants.PARTY_SHIPPER) && mapOfTaas.containskey(lstTargetItem.Target_Item__r.Account__r.Customer_Code__c)
           && mapOfTaas.get(lstTargetItem.Target_Item__r.Account__r.Customer_Code__c) != Null){
            lstTAA = mapOfTaas.get(lstTargetItem.Target_Item__r.Account__r.Customer_Code__c);
              
            //IterateOverTaas to find the territories which contains below roles
               for(Territory_Account_Association__c taa : lstTAA){
                   if((taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL||
                       taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_NON_CONTROL_ONLY) &&
                      (TAASettingConstants.PR_All.equals(taa.Brand__c) || (String.isNotEmpty(measureBrand) && taa.Brand__c.contains(measureBrand)))){
                       setOfTerritoriesId.add(taa.Territory__r.Portfolio_Owner__c  + '-' + taa.id) ;
                   }
            }
            
        }
        return setOfTerritoriesId;
    }
    
    // check Taa records for represent concern account and return all territories
    public static Set<String> getUserForPOTargets(List<Territory_Account_Association__c> territoryAccAssociation, Target_Measure__c targetMeasureRecord){
        Set<String> setOfTerritoriesId = new Set<String>();
        String measureBrand;
        List<Territory_Account_Association__c> lstInfluencerTAAs = new List<Territory_Account_Association__c>();
        if(mapTargetBrandMapping.containsKey(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c)){
            measureBrand = mapTargetBrandMapping.get(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
        }
     
        for(Territory_Account_Association__c taa : territoryAccAssociation){
            
            if((taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER || 
                taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL||
                taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Global_Lead_Account_Owner_Only || 
                taa.portfolio_Owner_responsibility__c == TAASettingConstants.POR_SALES_CONTROL_ONLY ||
                taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Lead_Account_Owner_Only) &&
               
               (TAASettingConstants.PR_All.equals(taa.Brand__c) || (String.isNotEmpty(measureBrand) && taa.Brand__c.contains(measureBrand)))){ 
                   setOfTerritoriesId.add(taa.Territory__r.Portfolio_Owner__c + '-' + taa.id); 
            }
            
            if(taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                //influencer logic will run 
                lstInfluencerTAAs.add(taa); 
            }   
        }
        // move it to inside for loop
        if(lstInfluencerTAAs.size() > 0){
            setOfTerritoriesId.addAll(getUserForInfluencerRole(lstInfluencerTAAs,targetMeasureRecord));
        }
        
        return setOfTerritoriesId;
    }
    
    
    //check eligibility of users for Non represent concern type account and return set of territories Id
    Public static Set<String> getUserForPOTargetsNRC(List<Territory_Account_Association__c> territoryAccAssociation, Target_Measure__c targetMeasureRecord, Boolean checkForRC){
        String measureBrand ;
        Set<String> setOfTerritories = new Set<String>();
        List<Territory_Account_Association__c> lstInfluencerTAAs = new List<Territory_Account_Association__c>();
        if(mapTargetBrandMapping.containsKey(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c)){
            measureBrand = mapTargetBrandMapping.get(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
        }
        
        for(Territory_Account_Association__c taa : territoryAccAssociation){
            if(checkForRC == FALSE){
                if((taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL_ONLY || 
                    taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL ||
                    taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Lead_Account_Owner_Only)&&
                   (TAASettingConstants.PR_All.equals(taa.Brand__c) || (String.isNotEmpty(measureBrand) && taa.Brand__c.contains(measureBrand)))){
                       
                       setOfTerritories.add(taa.Territory__r.Portfolio_Owner__c + '-' + taa.id) ;
                       
                   } if(taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                       //influencer logic will run 
                       lstInfluencerTAAs.add(taa); 
                   }   
            } 
            else if(checkForRC == TRUE){
                if((taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER || 
                    taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Global_Lead_Account_Owner_Only) &&
                   (TAASettingConstants.PR_All.equals(taa.Brand__c) || (String.isNotEmpty(measureBrand) && taa.Brand__c.contains(measureBrand)))){
                       
                       setOfTerritories.add(taa.Territory__r.Portfolio_Owner__c + '-' + taa.id ) ;
                       
                   } if(taa.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                       //influencer logic will run 
                       lstInfluencerTAAs.add(taa); 
                   } 
            }
            
        }
        
        if(lstInfluencerTAAs.size() > 0){
            setOfTerritories.addAll(getUserForInfluencerRole(lstInfluencerTAAs,targetMeasureRecord));
        }
        
        return setOfTerritories;    
    }
    //Method to check for brand , country and Area of taa with target item group, for influencer role
    public static Set<String> getUserForInfluencerRole(List<Territory_Account_Association__c> listOfTAA, Target_Measure__c targetMeasureRecord){
        Set<string> setOfTerritoriesId = new Set<string>(); 
        String measureBrand;
        if(mapTargetBrandMapping.containsKey(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c)){
            measureBrand = mapTargetBrandMapping.get(targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
        }
        for(Territory_Account_Association__c taa : listOfTAA){ 
            
            if((taa.Business_Defined_Area__c  == targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.Executing_Area__c || 
                taa.Country__c  == targetMeasureRecord.Target_Item__r.Sales_Target_Item_Group__r.Executing_Country__c) &&
               (TAASettingConstants.PR_All.equals(taa.Brand__c) || (String.isNotEmpty(measureBrand) && taa.Brand__c.contains(measureBrand)))){
                    
                    setOfTerritoriesId.add(taa.Territory__r.Portfolio_Owner__c + '-' + taa.id);
                    
                }  
        }
        return setOfTerritoriesId;        
    }
    
    //Method Brand Mapping
    private static Map<String,String> targetBrandMappingMethod(){
        Map<String,String>mapTargetBrandMapping = new Map<String,String>();
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        for(Target_Brand_Mapping__c tbm:[Select id,Salesforce_Brand__c,BrandMnA__c,Active__c from Target_Brand_Mapping__c where Active__c =true AND Salesforce_Brand__c!=null AND RecordTypeId = :recordTypeId]){
            mapTargetBrandMapping.put(tbm.BrandMnA__c,tbm.Salesforce_Brand__c);    
        }
        return mapTargetBrandMapping;    
    }
    
}