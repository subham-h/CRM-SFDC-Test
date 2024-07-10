/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      SFSE-11477  08-Nov-2023     Vinay      						       Code created
 * 1.1		SFSE-13429	24-Nov-2023		Vinay								   Changed the code to send updated string formats to TargetAssignmentUtility's class method: insertTargetCustomerPortfolioRecord
 * 1.2      SFSE-13491  14-dec-2023     Bharti                                 Remove hardcoding of Portfolio owner Responsibility
 * 1.3 		SFSE-15206  16-05-2023		Vinay								   Production Issue Fix	
*/ 
public class UpdateTargetItemMeasureUtility {
    private static Map<String,String> brandMapping;    
    private static List<String> ignoreTargetStatus;
    private static Integer recordsLimit;
    public static void updateCustomerPortfolioAssigned(List<Territory_Account_Association__c> listTAA)
    {         
        brandMapping = TargetSettingBatchHelper.targetBrandMappingMethod();
        Map<String, List<Territory_Account_Association__c>> mapTAA = new Map<String, List<Territory_Account_Association__c>>();        
        Set<Id> setAccIds = new Set<Id>();
        Set<String> setUniqueKeys = new Set<String>();
        Set<Id> incomingTAARCIds = new Set<Id>(); // Ids of incoming TAA Accounts which are Represents Concern Acc.
        Map<Id, Id> mapNormalAccAndParentId = new Map<Id, Id>();
        Set<Id> representConcernAccIdsForTAA = new Set<Id>(); // Ids to store the Represents Concern Acc corresponding to Normal Accs of incoming TAA	      
        Map<Id, List<Target_Measure__c>> measuresMap = new Map<Id, List<Target_Measure__c>>();
        List<Target_Measure__c> measuresToUpdate = new List<Target_Measure__c>();
        List<String> activeTargetStatus = new List<String>{'New','In Progress','Open for Revision'};
        ignoreTargetStatus = new List<String>{TargetSettingConstants.TARGET_STATUS_CLOSED,TargetSettingConstants.TARGET_STATUS_CANCELLED};   
        Set<Id> idsForSiblingMeasures = new Set<Id>(); 
        recordsLimit = Limits.getLimitDMLRows();     
            
        // Fetching all TAA Account Ids in a Set
        for(Territory_Account_Association__c taa : listTAA){
            setAccIds.add(taa.Account__c);
            // GAO, GLAO and Influencer when they gets created against represents Concern then we need to fetch their respective
            // Sibling Account's Measures (Normal Client Accounts) to create TCPs under its Sibling Account Measure
            if(taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER || 
               taa.Portfolio_Owner_Responsibility__c== TAASettingConstants.POR_Global_Lead_Account_Owner_Only||
               taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Influencer_Only){
               idsForSiblingMeasures.add(taa.Account__c); 
            }
        }        
        
        //Getting Normal Acc and Represent Concern's details
        for(Account Acc:[SELECT Id,Represents_Concern__c,ParentId FROM Account WHERE Id IN:setAccIds AND ParentId != null]){
          if(Acc.Represents_Concern__c)
          incomingTAARCIds.add(Acc.Id);
          else
          mapNormalAccAndParentId.put(Acc.Id, Acc.ParentId);    
        }
        
        // For Normal Accounts, getting their respective Represents Concern Account details.        
        if(!mapNormalAccAndParentId.isEmpty()){
            for(Account Acc:[SELECT Id,ParentId FROM Account WHERE ParentId IN:mapNormalAccAndParentId.values() AND Represents_Concern__c=TRUE]){
              representConcernAccIdsForTAA.add(Acc.Id);  
            }
        }
       
       // For all incoming Taa's which are associated to Normal Client Account of Concern, 
       // getting TAAs of their respective Represent Concern which are GAO, GLAO, Influencer which are helpful to evalute credit eligibility.                   
       if(!representConcernAccIdsForTAA.isEmpty()){
       for(Territory_Account_Association__c taa : [SELECT Id,Account__r.Customer_Code__c,Customer_Status__c,Product_Responsibility__c,Start_Date__c,End_Date__c,
                                                  Account__r.Represents_Concern__c,Account__r.ParentId,Portfolio_Owner_Responsibility__c,
                                                  Territory__r.Portfolio_Owner__c,Business_Defined_Area__c,Country__c,Brand__c 
                                                  FROM Territory_Account_Association__c WHERE 
                                                  Account__c IN : representConcernAccIdsForTAA AND Product_Responsibility__c != :TAASettingConstants.PR_Ocean
                                                  AND (Portfolio_Owner_Responsibility__c= :TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER OR Portfolio_Owner_Responsibility__c= :TAASettingConstants.POR_Global_Lead_Account_Owner_Only OR Portfolio_Owner_Responsibility__c= :TAASettingConstants.POR_Influencer_Only)
                                                  AND (End_Date__c = null OR End_Date__c >= TODAY)]){
           if(!mapTAA.containsKey(taa.Account__r.Customer_Code__c)){
               mapTAA.put(taa.Account__r.Customer_Code__c, new List<Territory_Account_Association__c>());
           } 
               mapTAA.get(taa.Account__r.Customer_Code__c).add(taa); 
        }}        
        
        // Get all Measures whose Target Item's Account is TAA's Account that got Created/Updated.
        // Get all PO Measures whose Target Item's Represent Account is TAA's Account that got Created/Updated.
        for(Target_Measure__c measure : [SELECT Id,Credit_Eligible__c,Party_Type__c,Target_Item__r.Account__c,
                                         Target_Item__r.Sales_Target_Item_Group__r.Executing_Area__c,
                                         Target_Item__r.Sales_Target_Item_Group__r.Executing_Country__c,
                                         Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c,
                                         Target_Item__r.Represent_Concern_Account__c,
                                         Target_Item__r.Represents_Concern_Customer_Code__c,
                                         Target_Item__r.Account_Represents_Concern__c,
                                         Target_Item__r.Target__r.Status__c
                                         FROM Target_Measure__c 
                                         WHERE (Target_Item__r.Account__c IN : setAccIds OR 
                                   		 (Target_Item__r.Represent_Concern_Account__c IN : idsForSiblingMeasures 
                                          AND Party_Type__c= :TargetSettingConstants.PARTY_PO 
                                          AND Target_Item__r.Account_Represents_Concern__c =FALSE))                                          
                                         AND Measure_Dimension__c=:TargetSettingConstants.TARGET]){
			                                 
			if(idsForSiblingMeasures.contains(measure.Target_Item__r.Represent_Concern_Account__c) 
               && !measure.Target_Item__r.Account_Represents_Concern__c && measure.Party_Type__c==TargetSettingConstants.PARTY_PO){			   
			   
                   if(!measuresMap.containsKey(measure.Target_Item__r.Represent_Concern_Account__c)){
                    measuresMap.put(measure.Target_Item__r.Represent_Concern_Account__c, new List<Target_Measure__c>());                  
                   }
                    measuresMap.get(measure.Target_Item__r.Represent_Concern_Account__c).add(measure);				
			 }
             if(setAccIds.contains(measure.Target_Item__r.Account__c)){
                     if(!measuresMap.containsKey(measure.Target_Item__r.Account__c)){
                    	measuresMap.put(measure.Target_Item__r.Account__c, new List<Target_Measure__c>());                  
                    }
                    	measuresMap.get(measure.Target_Item__r.Account__c).add(measure);
             }                                            		                                 
        }
        
        String measureBrand,representConcernCode;         
        for(Territory_Account_Association__c taa : listTAA){
            measureBrand ='';
            representConcernCode='';
			
            // setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit -> This condition is to check if no of records of(TCPCreations+Measures to update Credit eligibility to True)
        	// should be with in the governer limits. For rest of records we have a batch that will take care of TCP Creation and update credit eligibility.                    
            if(measuresMap.containsKey(taa.Account__c) && !measuresMap.get(taa.Account__c).isEmpty() && (setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit)){
				
                //If TAA is SO or SO-NCO then iterate over all Shipper and Consignee Measures of TAA Account and 
                //compare TAA Brand with Measure Brand if matched then update Measure's Credit Eligibility to TRUE and
                //build a Key TAA Id to Measure Id and Territory User Id to create TCPs.                                
                if(taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_SALES_CONTROL || 
                   taa.Portfolio_Owner_Responsibility__c== TAASettingConstants.POR_SALES_NON_CONTROL_ONLY){                                        
                    
                       for(Target_Measure__c measure : measuresMap.get(taa.Account__c)){
                        measureBrand = getBrandFromMapping(measure.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
                        
                           if((measure.Party_Type__c==label.PartyType_Shipper|| measure.Party_Type__c==label.PartyType_Consignee)&& 
                           (TAASettingConstants.PR_All.equals(taa.Brand__c) || (measureBrand!='' && taa.Brand__c.contains(measureBrand)))){
                               
                               if(!measure.Credit_Eligible__c && activeTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c) 
                                  && (setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit)){
                               measure.Credit_Eligible__c = True;
                               measuresToUpdate.add(measure);
                               }
                               // SFSE-13429 Concatenating the TAA Id to Measure Id and Territory User Id.
                               if(!ignoreTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c) && (setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit)){
                                   setUniqueKeys.add(measure.Id+'-'+taa.Territory_User_Id__c+'-'+taa.Id);                                   
                               }                                                                             		                    
                    }}}
                
                // If TAA is an influencer,then 
                //  if TAA Account is a Represents Concern then fetch all Measures of TAA's Account + fetch Measures whose Represents Concern Account is TAA Account
                //  Else TAA Account is a Normal Client Acc of Concern then fetch all Measures of TAA Account + fetch Measures of NC's Represents Concern Account.
                //  Iterate over these measures and check if Measures's Brand = TAA Brand AND (Measure's Area = TAA Area or compare Measure's Country = TAA's Country)
                //  then update Measure's Credit Eligibility to TRUE and build a Key TAA Id to Measure Id and Territory User Id to create TCPs.                                
                if(taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Influencer_Only){
                    for(Target_Measure__c measure : measuresMap.get(taa.Account__c)){
                        measureBrand = getBrandFromMapping(measure.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c);
                        
                        if(measure.Party_Type__c==label.PartyType_PriceOwner 
                           &&((taa.Business_Defined_Area__c!=NULL && taa.Business_Defined_Area__c == measure.Target_Item__r.Sales_Target_Item_Group__r.Executing_Area__c) ||
                              (taa.Country__c!=NULL && taa.Country__c ==  measure.Target_Item__r.Sales_Target_Item_Group__r.Executing_Country__c))
                           && (TAASettingConstants.PR_All.equals(taa.Brand__c) || (measureBrand!='' && taa.Brand__c.contains(measureBrand)))){
                               
                               if(!measure.Credit_Eligible__c && activeTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c)
                                 && (setUniqueKeys.size()+ measuresToUpdate.size()<10000)){ 
                                    measure.Credit_Eligible__c = True;
                               		measuresToUpdate.add(measure);
                               }
                               // SFSE-13429 Concatenating the TAA Id to Measure Id and Territory User Id.
                               if(!ignoreTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c) && (setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit)){
                                   setUniqueKeys.add(measure.Id+'-'+taa.Territory_User_Id__c+'-'+taa.Id);
                               }                                                        
                        }
                        if(measure.Party_Type__c==label.PartyType_PriceOwner && mapNormalAccAndParentId.containsKey(taa.Account__c)){
                            representConcernCode = measure.Target_Item__r.Represents_Concern_Customer_Code__c;
                            if(mapTAA.containsKey(representConcernCode) && mapTAA.get(representConcernCode).size()>0){
                               getRCTerritoriesOfNC(mapTAA.get(representConcernCode),measure, setUniqueKeys, measuresToUpdate.size());                                
                            }}
                }}
                if(taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER ||	taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_SALES_CONTROL ||
                   taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_SALES_CONTROL_ONLY ||taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Lead_Account_Owner_Only ||
                   taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Global_Lead_Account_Owner_Only)
                {  
                    // Considering GLAO only for Represents Concern Account
                    if(taa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Global_Lead_Account_Owner_Only && !incomingTAARCIds.contains(taa.Account__c)){
                      continue;  
                    }
                    for(Target_Measure__c measure : measuresMap.get(taa.Account__c)){
                        // SFSE-15206
                        if(taa.Portfolio_Owner_Responsibility__c!=TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER && 
                           taa.Portfolio_Owner_Responsibility__c!=TAASettingConstants.POR_Global_Lead_Account_Owner_Only &&
                           incomingTAARCIds.contains(taa.Account__c) && measure.Target_Item__r.Represent_Concern_Account__c == taa.Account__c &&  measure.Target_Item__r.Account__c!= taa.Account__c ){
                            continue; 
                        }
                        measureBrand = getBrandFromMapping(measure.Target_Item__r.Sales_Target_Item_Group__r.BrandMnA__c); 
                        if(measure.Party_Type__c==label.PartyType_PriceOwner &&
                           (TAASettingConstants.PR_All.equals(taa.Brand__c) || (measureBrand!='' && taa.Brand__c.contains(measureBrand))))
                        {
                           if(!measure.Credit_Eligible__c && activeTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c)
                              && (setUniqueKeys.size()+ measuresToUpdate.size()<10000)){
                              measure.Credit_Eligible__c = True;                          
                              measuresToUpdate.add(measure);
                           }
                         // SFSE-13429 Concatenating the TAA Id to Measure Id and Territory User Id.
                         if(!ignoreTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c) && 
                            (setUniqueKeys.size()+ measuresToUpdate.size()<recordsLimit)){
                             setUniqueKeys.add(measure.Id+'-'+taa.Territory_User_Id__c+'-'+taa.Id);
                         }
                                   
               		   }
                       if(measure.Party_Type__c==label.PartyType_PriceOwner && mapNormalAccAndParentId.containsKey(taa.Account__c)){
                          representConcernCode = measure.Target_Item__r.Represents_Concern_Customer_Code__c;
                          if(mapTAA.containsKey(representConcernCode) && mapTAA.get(representConcernCode).size()>0){    
                             getRCTerritoriesOfNC(mapTAA.get(representConcernCode),measure,setUniqueKeys,measuresToUpdate.size());                                 
                       }}
               }}
                                
        }}
        
        if(!measuresToUpdate.isEmpty()){                                     
            Database.SaveResult[] SR1= Database.update(measuresToUpdate,FALSE);  
			ErrorLogger.writeErrors('SFDC', 'UpdateTargetItemMeasureUtility', 'updateCustomerPortfolioAssigned', SR1, measuresToUpdate);
        }
        
        if(!setUniqueKeys.isEmpty()){
			TargetAssignmentUtility.insertTargetCustomerPortfolioRecord(setUniqueKeys); 
        }
    }
	// Find and return Salesforce Brand corresponds to Lns Brand.
	// Input - Measure's Target Item Group's Brand
	// Output - Corresponding Salesforce Brand from Salesforce Target Brand Mapping Object.    
    public static String getBrandFromMapping(String targetItemBrand){        
      return brandMapping.containsKey(targetItemBrand) && !String.isBlank(brandMapping.get(targetItemBrand))?brandMapping.get(targetItemBrand):'';    
    }
    
    // Get Eligible Territories of Represent Concern(RC) related to Normal Client Account of Concern(NC).
    // Inputs: 
    // rcAccTAALst - List of Territory Account Association(TAA) records of a Represents Concern Account 
    // setUniqueKeys - Concatenated string of MeasureId+TerritoryUserId+TAAId
    // measureCount - measuresToUpdate list Size
    // Output -  Concatenated string of TerritoryUserId+TAAId
    public static void getRCTerritoriesOfNC(List<Territory_Account_Association__c> rcAccTAALst,
                                            Target_Measure__c measure, Set<String> setUniqueKeys, Integer measureCount){
                                              
       if(!rcAccTAALst.isEmpty() && !ignoreTargetStatus.contains(measure.Target_Item__r.Target__r.Status__c)){
       Set<String> mapTerritories = TargetsAssignToSalesRep.getUserForPOTargetsNRC(rcAccTAALst,measure,TRUE);                                          
       if(!mapTerritories.isEmpty()){
           for(String territoryIdAndTaaId : mapTerritories){
           if(measureCount+setUniqueKeys.size()<recordsLimit){   
            setUniqueKeys.add(measure.Id+'-'+territoryIdAndTaaId);}   
       }}}
    }
}