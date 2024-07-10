/**
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      #RQ-008579  24-May-2018     meghana.gupta@ust-global.com           Code created
 * 2.0      SFSE-6066   29-Sep-2021     Kiran@Maersk                           Removing Territory record type references
 * 3.0      SPI-100     08-Jun-2022     Ronnie@SF                              Removed brand hardcoding
 * 4.0      SFSE-10605  27-Mar-2022		Jay@UST								   Added DateCheck 
 * 5.0      SFSE- 13491 14-12-2023     Bharti                                  Remove Hardcoding Of product Responsibility/Brands
 */

@isTest
public class TerritoryAccountAssociationTrigger_Test {
    
    @testSetup static void setup() {
        TriggerExecutionController.skipAccountTrigger(true);
        TerritoryDataGeneration_Test.createTerritoryData(); 
        TriggerExecutionController.skipAccountTrigger(false);  
        Account clientAcc = [SELECT Id FROM Account LIMIT 1];
        try{
            TriggerExecutionController.skipOpportunityTrigger(true);
            Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLDryOpportunity( clientAcc.id, null );
            TriggerExecutionController.skipOpportunityTrigger(false);
        }catch(exception e){}
    }
    
    @isTest
    static void testPortfolioValidations(){
        Test.startTest();
        Map<Id, Territory__c> mapTerritory = new Map<Id, Territory__c>([SELECT Id FROM Territory__c WHERE POrtfolio_Owner__c <> null]);
        List<Territory_Account_Association__c> lst = [SELECT id, Brand__c, Portfolio_Owner_Responsibility__c FROM Territory_Account_Association__c WHERE territory__c in :mapTerritory.keySet() ];
        
        
        for (Territory_Account_Association__c rec : lst) {
            if (rec.Portfolio_Owner_Responsibility__c <> TAASettingConstants.POR_SALES_CONTROL)
                rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_SALES_CONTROL;
        }
        try {
            update lst;
        } catch(exception ex) {}
        
        
        for (Territory_Account_Association__c rec : lst) {
            if (rec.Portfolio_Owner_Responsibility__c <> TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER)
                rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER;
        }
        try {
            update lst;
        } catch(exception ex) {}
        
        for (Territory_Account_Association__c rec : lst) {
            if (rec.Portfolio_Owner_Responsibility__c <> TAASettingConstants.POR_Influencer_Only)
                rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_Influencer_Only;
        }
        try {
            update lst;
        } catch(exception ex) {}
        
        for (Territory_Account_Association__c rec : lst) {
            rec.Brand__c = BrandUtilities.SEAGO;
        }
        try {
            update lst;
        } catch(exception ex) {}
        Test.stopTest();

    }
    
    @isTest
    static void testPortfolioValidationsLeadAccountOwner(){
        Test.StartTest();
        List <PermissionSet> lstPS = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios' ];
		List<PermissionSetAssignment> lstPSA = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :lstPS[0].Id];
        Set<Id> userIds = new Set<Id>();
        for (PermissionSetAssignment rec : lstPSA){
            userIds.add(rec.AssigneeId);
        }
        List<User> uList = [SELECT ID FROM User Where Id in :userIds AND isActive = true limit 1];
        List<Account> accList = [SELECT id, Attractiveness__c FROM Account];
         List<Territory_Account_Association__c> lst = [SELECT id, Account__c, Brand__c, Portfolio_Owner_Responsibility__c, Product_Responsibility__c, Territory__c
                                                      FROM Territory_Account_Association__c ];
        List<Territory_Account_Association__c> insertLst = new List<Territory_Account_Association__c>();
       // Test.startTest();
        for (Account acc : accList){
            acc.Attractiveness__c = '';
        }
        update accList;
        system.debug('TAA size:'+lst.size());
        
        integer counter = 1;
        for (Territory_Account_Association__c rec : lst) {
            Territory_Account_Association__c newTAA = rec.clone(false, false, false, false);
            
            if (counter == 1){
                newTAA.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_Lead_Account_Owner_Only;
            }
            else {
                newTAA.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_Global_Lead_Account_Owner_Only;
            }
			if (rec.Brand__c == TAASettingConstants.PR_All)
                newTAA.Brand__c = BrandUtilities.MAERSKLINE;            
            insertLst.add(newTAA);
        }
        System.RunAs(uList[0]){
           // insert insertLst;
        }
        
        // reinsert to get duplicate error
         try {
            insert insertLst;
        } catch(exception ex) {}
        
        for (Territory_Account_Association__c rec : insertLst) {
            if (counter <> 1){
                rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_Lead_Account_Owner_Only;
            }
            else {
                rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_Global_Lead_Account_Owner_Only;
            }
            if (rec.Brand__c == TAASettingConstants.PR_All)
                rec.Brand__c = BrandUtilities.MAERSKLINE;
        }
         try {
            update insertLst;
        } catch(exception ex) {}
        Test.stopTest();
    }
    
    static void testPortfolioValidationsSalesOwnerControl(){
        Test.startTest();
        Map<Id, Territory__c> mapTerritory = new Map<Id, Territory__c>([SELECT Id FROM Territory__c WHERE POrtfolio_Owner__c <> null]);
        List<Territory_Account_Association__c> lst = [SELECT id, Brand__c, Portfolio_Owner_Responsibility__c
                                                      FROM Territory_Account_Association__c WHERE territory__c in :mapTerritory.keySet() ];
        
        for (Territory_Account_Association__c rec : lst) {
            rec.Portfolio_Owner_Responsibility__c = TAASettingConstants.POR_SALES_CONTROL_ONLY;
        }
        try {
            update lst;
        } catch(exception ex) {}
        
        for (Territory_Account_Association__c rec : lst) {
            rec.Portfolio_Owner_Responsibility__c =TAASettingConstants.POR_SALES_NON_CONTROL_ONLY;
        }
        try {
            update lst;
        } catch(exception ex) {}
        
        Test.stopTest();
    }

    @isTest
    static void testDateCheck(){
		Test.startTest();
        Map<Id, Territory__c> mapTerritory = new Map<Id, Territory__c>([SELECT Id FROM Territory__c WHERE POrtfolio_Owner__c <> null]);
        List<Territory_Account_Association__c> lst = [SELECT id, Account__c, Brand__c, Start_Date__c, End_Date__c, Business_Defined_Area__c, Country__c, Portfolio_Owner_Responsibility__c, Represents_Concern__c, Product_Responsibility__c, Territory__c
                                                      FROM Territory_Account_Association__c WHERE territory__c in :mapTerritory.keySet() ];
        Id bdaId = [SELECT Id FROM BDA__c WHERE Type__c = 'Cluster' LIMIT 1][0].Id;
        Account clientAcc = [SELECT Id, Represents_Concern__c FROM Account WHERE Name='Test Class Client Account' LIMIT 1];
       
        
        for (Territory_Account_Association__c rec : lst) {
            rec.Start_Date__c = System.Today();
            rec.End_Date__c = System.Today()+30;
            
        }
        try{
            update lst;
        }catch(exception e){
            System.debug('Update taa Exception'+e.getMessage());
        } 
        List<Territory_Account_Association__c> lstNew = New List<Territory_Account_Association__c>();
        for(Territory_Account_Association__c taaold : lst){
            System.debug('old Taa'+taaold);
            
            if(taaold.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                Territory_Account_Association__c taaInfluencer = New Territory_Account_Association__c();
                if(taaold.Business_Defined_Area__c != null){
                    taaInfluencer =  TerritoryDataGeneration_Test.addAccountToPortfolio4(taaold.Territory__c, taaold.Account__c, taaOld.Brand__c, TAASettingConstants.POR_Influencer_Only, taaOld.Product_Responsibility__c ,taaOld.Business_Defined_Area__c);
                    
                }else 
                    taaInfluencer =  TerritoryDataGeneration_Test.addAccountToPortfolio3(taaold.Territory__c, taaold.Account__c, taaOld.Brand__c, TAASettingConstants.POR_Influencer_Only, taaOld.Product_Responsibility__c ,taaOld.Country__c);
                
                taaInfluencer.Start_Date__c = System.Today()+1;
                taaInfluencer.End_Date__c = System.Today() + 10;
                lstNew.add(taaInfluencer);
            }else {
                Territory_Account_Association__c taa = New Territory_Account_Association__c();
                taa = TerritoryDataGeneration_Test.addAccountToPortfolio2(taaOld.Territory__c, taaOld.Account__c, taaOld.Brand__c, taaOld.Portfolio_Owner_Responsibility__c, taaOld.Product_Responsibility__c);
                taa.Start_Date__c = System.Today()-30;
                taa.End_Date__c = System.Today()-20;
                lstNew.add(taa);
            }
        }
        try{
            insert lstNew;
        }catch(exception e){
            System.debug('Exception >> '+e.getMessage());
        }
        Test.stopTest();
    }
        
    @isTest
    static void testDateCheckNull(){
		Test.startTest();
        Map<Id, Territory__c> mapTerritory = new Map<Id, Territory__c>([SELECT Id FROM Territory__c WHERE POrtfolio_Owner__c <> null]);
        List<Territory_Account_Association__c> lst = [SELECT id, Account__c, Brand__c, Start_Date__c, End_Date__c, Business_Defined_Area__c, Country__c, Portfolio_Owner_Responsibility__c, Represents_Concern__c, Product_Responsibility__c, Territory__c
                                                      FROM Territory_Account_Association__c WHERE territory__c in :mapTerritory.keySet() ];
        Id bdaId = [SELECT Id FROM BDA__c WHERE Type__c = 'Cluster' LIMIT 1][0].Id;
        Account clientAcc = [SELECT Id, Represents_Concern__c FROM Account WHERE Name='Test Class Client Account' LIMIT 1];
       
        
        List<Territory_Account_Association__c> lstNew = New List<Territory_Account_Association__c>();
        for(Territory_Account_Association__c taaOld : lst){
            System.debug('old Taa'+taaold);
            if(taaold.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_Influencer_Only){
                Territory_Account_Association__c taaInfluencer = New Territory_Account_Association__c();
                if(taaold.Business_Defined_Area__c != null){
                    taaInfluencer =  TerritoryDataGeneration_Test.addAccountToPortfolio4(taaOld.Territory__c, taaOld.Account__c, taaOld.Brand__c, TAASettingConstants.POR_Influencer_Only, taaOld.Product_Responsibility__c ,taaOld.Business_Defined_Area__c);
                    
                }else 
                    taaInfluencer =  TerritoryDataGeneration_Test.addAccountToPortfolio3(taaOld.Territory__c, taaOld.Account__c, taaOld.Brand__c, TAASettingConstants.POR_Influencer_Only, taaOld.Product_Responsibility__c ,taaOld.Country__c);
                
                taaInfluencer.Start_Date__c = System.Today()+1;
                taaInfluencer.End_Date__c = System.Today() + 10;
                lstNew.add(taaInfluencer);
            }else{
                Territory_Account_Association__c taa = New Territory_Account_Association__c();
                taa = TerritoryDataGeneration_Test.addAccountToPortfolio2(taaOld.Territory__c, taaOld.Account__c, taaOld.Brand__c, taaOld.Portfolio_Owner_Responsibility__c, taaOld.Product_Responsibility__c);
            	taa.Start_Date__c = System.Today()-30;
                
                lstNew.add(taa);
            }
        }
        try{
            insert lstNew;
            System.debug('New Rec Id'+lstNew[0].Id);
        }catch(exception e){
            System.debug('Exception >> '+e.getMessage());
        }
        Test.stopTest();
    }
}