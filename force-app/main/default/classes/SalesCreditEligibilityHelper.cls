/*
* Revision 	Ref Number  	Date          Owner              Description
* -------- ----------  	-----------   -----------------     --------------------------------------------
*	1.0 	SFSE-13491  14-dec-2023     Bharti              Remove hardcoding of Portfolio owner Responsibility
*	2.0 	SFSE-13783	12-Jan-2023	 	Vinay				Fixing the production issue to Evaluate Credit eligibility and fixed couple of edge cases.	 
*/

public inherited sharing class SalesCreditEligibilityHelper{   
    
    public static Map<String, Boolean> getCreditEligibilityByPartyType(Map<String, String> mapExeCountryByCustomerCode, Map<String, String> mapBrandByCustomerCode, String partyType) {         
        
        Map<String, Set<String>> mapPortfolioRolesByCustomerCode 
            = SalesCreditEligibilityHelper.getPortfolioRolesByCustomerCode(mapExeCountryByCustomerCode, mapBrandByCustomerCode,partyType); 
        Set<String> setPartyTypeRole = SalesCreditEligibilityHelper.getPortfolioOwnerRoles(partyType);// Price Owner, Shipper, Consignee
        Map<String, Boolean> retVal = new Map<String, Boolean>();
        Set<String> setAccountPortfolioRole;
        
        for(String eachCustomerCode :mapPortfolioRolesByCustomerCode.keySet()) {
            if(mapPortfolioRolesByCustomerCode.get(eachCustomerCode) != null) {
                setAccountPortfolioRole = mapPortfolioRolesByCustomerCode.get(eachCustomerCode);
                if(setAccountPortfolioRole!=NULL){
                setAccountPortfolioRole.retainAll(setPartyTypeRole);}
                
                if(!setAccountPortfolioRole.isEmpty()){
                    retVal.put(eachCustomerCode, true);
                    continue;
                }                
            }            
        }
        return retVal;
    }

    /* getRepConcernAccountIdForConcern - This Method will take mapCustomerCodesByConcernId as input which contains 
     * Normal Client Account's Parent Id(Concern Account Id) as Key and Normal Client Account Customer Code as Value. 
     * Quries Accounts which are falling under Concern Account And Maps Normal Client Acc Code as Key and its Sibling 
     * Which is a Represent Concern(Id) as Value.
    */
    public static Map<String, Id> getRepConcernAccountIdForConcern(Map<Id, Set<String>> mapCustomerCodesByConcernId){
        Map<String, Id> retVal = new Map<String, Id>();
        for (Account eachAccount :[SELECT Id,ParentId,Customer_Code__c FROM Account
                                    WHERE ParentId IN :mapCustomerCodesByConcernId.keySet() AND Represents_Concern__c = true]) {
            for (String eachCustomerCode :mapCustomerCodesByConcernId.get(eachAccount.ParentId)) {
                retVal.put(eachCustomerCode, eachAccount.Id);
            }
          }
        return retVal;
    }
    
    public static Map<String, Set<String>> getPortfolioRolesByCustomerCode(Map<String, String> mapExeCountryByCustomerCode,
                                                                           Map<String, String> mapBrandByCustomerCode,String partyType){
        
		Map<String, Set<String>> mapRolesByCustomerCode = new Map<String, Set<String>>();
        Map<Id, Set<String>> mapCustomerCodesByConcernId = new Map<Id, Set<String>>();
        Map<String, Id> mapCustomerCodeByRepConcernId;
        Map<String,String> brandMapping = TargetSettingBatchHelper.targetBrandMappingMethod();
                                                                              
        // GET BDA GEOGRAPHY FOR THE ALL COUNTRY CODES IN DB (235-250 records)
        Map<String, BDA_Geography__c> mapBdaGeographyByCountryCode = GeographyHelper.getBdaGeographyByCountryCode(); 
        Boolean flagRoleApplicable = false;
        String itemGroupBrand, brand; 
        for (Territory_Account_Association__c eachTaa :[SELECT Id,Customer_Code__c,Brand__c,Account__r.ParentId,Country__r.GEO_Code__c,
                                                         Business_Defined_Area__c,Account__r.Customer_Code__c,Account__r.Represents_Concern__c,
                                                         Portfolio_Owner_Responsibility__c FROM Territory_Account_Association__c 
                                                         WHERE Account__r.Customer_Code__c IN :mapExeCountryByCustomerCode.keySet()
                                                         AND Account__r.SCV_Status__c = 'Active'
                                                         AND Product_Responsibility__c != :TAASettingConstants.PR_Ocean
                                                         AND (End_Date__c = null OR End_Date__c >= TODAY)]) 
        {
            //If TAA Account is a Normal Client Acc then Map TAA's Account's Parent as Key and TAA's Account's Customer code as Value                                                      
            if (!eachTaa.Account__r.Represents_Concern__c && eachTaa.Account__r.ParentId != null) {  
               
                if (!mapCustomerCodesByConcernId.containsKey(eachTaa.Account__r.ParentId)) {
                    mapCustomerCodesByConcernId.put(eachTaa.Account__r.ParentId, new Set<String>());
                }
                mapCustomerCodesByConcernId.get(eachTaa.Account__r.ParentId).add(eachTaa.Customer_Code__c); 
            } 
                        
        if(!TAASettingConstants.POR_Influencer_Only.equals(eachTaa.Portfolio_Owner_Responsibility__c)){
            // PORTFOLIO OWNER IS NOT INFLUENCER
            flagRoleApplicable = true; 
            //GLAO is only applicable for RC for credit eligibility. 
            if(eachTaa.Portfolio_Owner_Responsibility__c==TAASettingConstants.POR_Global_Lead_Account_Owner_Only && !eachTaa.Account__r.Represents_Concern__c){
              flagRoleApplicable = false; 
              }
        } 
        else
        {
          flagRoleApplicable = SalesCreditEligibilityHelper.isInfluencerRoleApplicable(
          mapExeCountryByCustomerCode.get(eachTaa.Account__r.Customer_Code__c),eachTaa.Country__r.GEO_Code__c, 
          eachTaa.Business_Defined_Area__c, mapBdaGeographyByCountryCode); 
       }
        // CHECK IF BRAND MATCHES
        if(flagRoleApplicable) {
            // SFSE-13107 - Mapping the Lns Brand with SalesForce Brand. 
           itemGroupBrand = mapBrandByCustomerCode.get(eachTaa.Account__r.Customer_Code__c);
           brand = brandMapping.containsKey(itemGroupBrand) && !String.isBlank(brandMapping.get(itemGroupBrand))
                               ?brandMapping.get(itemGroupBrand):'';  
           if(!TAASettingConstants.PR_All.equals(eachTaa.Brand__c) && brand==''){
              flagRoleApplicable = false;  
           }                
           else if(String.isNotBlank(eachTaa.Brand__c) && !TAASettingConstants.PR_All.equals(eachTaa.Brand__c)                
                  && brand!='' && !eachTaa.Brand__c.contains(brand)){
                    flagRoleApplicable = false;                     
           }                
        }
        // ADD THE ROLES FOR ACCOUNT
        if(flagRoleApplicable) {
            SalesCreditEligibilityHelper.createCustomerRoleMap(eachTaa.Account__r.Customer_Code__c, 
                                                                   eachTaa.Portfolio_Owner_Responsibility__c, mapRolesByCustomerCode);
           //Passing Customer Code, Portfolio responsibility,
           flagRoleApplicable = false;
        }
                                                            
     } 
     // When there are no TAA's exist for accounts in mapExeCountryByCustomerCode key set, Iterate over the key set and find the
     // whether they are Normal Client Account of Concern(NC), if they are so then, put values in mapCustomerCodesByConcernId with 
     // key as NC's Parent Id and all NC's Customer codes as Values  
     if(mapCustomerCodesByConcernId.isEmpty() && partyType==TAASettingConstants.PO){
        for(Account Acc: [SELECT Id,ParentId,Customer_Code__c FROM Account WHERE Customer_Code__c IN: mapExeCountryByCustomerCode.keyset()
                          AND ParentId!=NULL AND Represents_Concern__c=FALSE]){
            if(!mapCustomerCodesByConcernId.containsKey(Acc.ParentId)) {
                 mapCustomerCodesByConcernId.put(Acc.ParentId, new Set<String>());
            }
                mapCustomerCodesByConcernId.get(Acc.ParentId).add(Acc.Customer_Code__c); 
        }                                                                        
     }
     
	// When NC Doesnt have any TAA, mapCustomerCodeByRepConcernId will not have any values hence populating values in it. 
	// getRepConcernAccountIdForConcern method returns Map with key: Normal Client Acc code Value: its Sibiling Represents Concern Account Id.                                                                                                                                                       
     if(!mapCustomerCodesByConcernId.isEmpty() && partyType==TAASettingConstants.PO){
        mapCustomerCodeByRepConcernId = SalesCreditEligibilityHelper.getRepConcernAccountIdForConcern(mapCustomerCodesByConcernId);
     }
                                                                                    
	 // For input NC Account evaluate Credit Eligibility for its RC Account.                                                                         
     if(mapCustomerCodeByRepConcernId!=NULL && !mapCustomerCodeByRepConcernId.values().isEmpty()){
        Map<Id, List<Territory_Account_Association__c>> mapRCAccountIdWithTAAs = new Map<Id, List<Territory_Account_Association__c>>();
         // While evaluating RC for NC, GAO,GLAO and Influencers are valid roles to become credit eligible 
         List<String> eligibleRoles = new List<String>{TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER,
             											 TAASettingConstants.POR_Global_Lead_Account_Owner_Only,
             											 TAASettingConstants.POR_Influencer_Only}; 
		for(Territory_Account_Association__c eachTaa :[SELECT Id,Brand__c,Account__r.ParentId,Country__r.GEO_Code__c,Business_Defined_Area__c,
                                                        Account__r.Customer_Code__c,Account__r.Represents_Concern__c,
                                                        Portfolio_Owner_Responsibility__c,Account__c  
                                                        FROM Territory_Account_Association__c
                                                        WHERE Account__c IN :mapCustomerCodeByRepConcernId.values()
                                                        AND Account__r.SCV_Status__c = 'Active' AND Product_Responsibility__c != :TAASettingConstants.PR_Ocean  
                                                        AND (End_Date__c = null OR End_Date__c > TODAY)
                                                        AND Portfolio_Owner_Responsibility__c IN: eligibleRoles])
         {
               if(!mapRCAccountIdWithTAAs.containsKey(eachTaa.Account__c)){
                   mapRCAccountIdWithTAAs.put(eachTaa.Account__c, new List<Territory_Account_Association__c>{});
               }  
               mapRCAccountIdWithTAAs.get(eachTaa.Account__c).add(eachTaa);
          }
          //Iterate over Normal Client Accs and evalute Credit Eligibility for its RC Acc.
          for(String ncAccountCode: mapCustomerCodeByRepConcernId.keySet()){
              String itemGrpBrand, brand1;    
              Id rcAccId = mapCustomerCodeByRepConcernId.get(ncAccountCode);
              if(rcAccId!=NULL && mapRCAccountIdWithTAAs.get(rcAccId)!=NULL){
              	for(Territory_Account_Association__c eachTaa :mapRCAccountIdWithTAAs.get(rcAccId)){
                    //Logic for Portfolio Owner Responsibilites other than Influencer.
                   	if(!TAASettingConstants.POR_Influencer_Only.equals(eachTaa.Portfolio_Owner_Responsibility__c)) {
                       flagRoleApplicable = true;   
                    } 
                    //Logic for Portfolio Owner Responsibility is Influencer.
        			else{                        
            			flagRoleApplicable = SalesCreditEligibilityHelper.isInfluencerRoleApplicable(mapExeCountryByCustomerCode.get(ncAccountCode),eachTaa.Country__r.GEO_Code__c, eachTaa.Business_Defined_Area__c,mapBdaGeographyByCountryCode);            
        			}
                   // CHECK IF BRAND MATCHES
                   if(flagRoleApplicable){
                       // SFSE-13107 - Mapping the Lns Brand with SalesForce Brand.
                       itemGrpBrand = mapBrandByCustomerCode.get(ncAccountCode);
                       brand1 = brandMapping.containsKey(itemGrpBrand) && !String.isBlank(brandMapping.get(itemGrpBrand))?brandMapping.get(itemGrpBrand):'';            
            		   if(!TAASettingConstants.PR_All.equals(eachTaa.Brand__c) && brand1==''){
              			   flagRoleApplicable = false;  
                       }
           				else if (String.isNotBlank(eachTaa.Brand__c) && !TAASettingConstants.PR_All.equals(eachTaa.Brand__c) 
                                 && brand1!='' && !eachTaa.Brand__c.contains(brand1))
                        {    
                			flagRoleApplicable = false;
                        }
                     	
                        if(flagRoleApplicable){
                            SalesCreditEligibilityHelper.createCustomerRoleMap(ncAccountCode, eachTaa.Portfolio_Owner_Responsibility__c, 
                                                                  mapRolesByCustomerCode);
                        	flagRoleApplicable = false;
            			}    
                   }}}}
       	}
        return mapRolesByCustomerCode;
    }
    
    public static void createCustomerRoleMap(String inCustomerCode, String responsibility, Map<String, Set<String>> mapRolesByCustomerCode) {
        if (mapRolesByCustomerCode.get(inCustomerCode) == null) {
            mapRolesByCustomerCode.put(inCustomerCode, new Set<String>());
        }        
        mapRolesByCustomerCode.get(inCustomerCode).add(responsibility);        
    }
    
    public static Boolean isInfluencerRoleApplicable(String inCountryCode, String portfolioCountryCode, String portfolioAreaId, Map<String, BDA_Geography__c> mapBdaGeographyByCountryCode) {
        // PORTFOLIO OWNER IS INFLUENCER
        if (null != portfolioCountryCode && portfolioCountryCode.equals(inCountryCode)) {
            return true;
        } 
        else if (null != portfolioAreaId  && null != mapBdaGeographyByCountryCode
        && mapBdaGeographyByCountryCode.get(inCountryCode) != null && 
        portfolioAreaId.equals(mapBdaGeographyByCountryCode.get(inCountryCode).BDA__c)) 
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    
    public static Set<String> getPortfolioOwnerRoles(String partyType) {
        Set<String> setPortfolioOwnerRole = new Set<String>();
        for (Sales_Credit_Eligibility_Check__mdt eachCeCheck :[SELECT Id,Portfolio_Owner_Responsibility__c 
                                                                FROM  Sales_Credit_Eligibility_Check__mdt
                                                                WHERE Party_Type__c = :partyType]) {
            if (String.isNotBlank(eachCeCheck.Portfolio_Owner_Responsibility__c)) {
                setPortfolioOwnerRole.addAll(eachCeCheck.Portfolio_Owner_Responsibility__c.split(','));             
            }

        }       
        return setPortfolioOwnerRole;
    }
}