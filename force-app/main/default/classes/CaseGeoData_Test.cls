/**
* Author   : Nirmal
* Purpose  : Test class to cover CaseGeoData. 
*        
* Revision Ref Number  Date         Owner                  Description
* -------- ----------  -----------  -------------------    -----------
* 1.0                  20-Mar-2017  Nirmal@UST             Test class to cover CaseGeoData.
* 2.0      RQ-007865   27-Mar-2018  Nisha@UST              Update ISR case 'country' to case owner country on Owner Change
*3.0       SC-394      25-06-2020    ramadevi@ust          added for Geo data population for SCM Cases
* 4.0       SC-4847     06-Apr-2022 Thippeswamy@Ust        Fixing the test class for Restricting the Case Sub Type picklist
 * 5.0      SPI-100     08-Jun-2022   Ronnie@SF              Removed brand hardcoding
*/

@isTest
public class CaseGeoData_Test {
    
    public static Contact conInstance = null;
    
    // Country and Cluster != null
    @isTest
    public static void testPopulateCountryAndClusterOnUpdate() {
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Cluster__c = BDAGeographyData_Test.clusterUK.Id;
        caseInstance.Country__c = BDAGeographyData_Test.countryUK.Id;
        
        Test.startTest();
        update caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c FROM Case Where Id =:caseInstance.Id];
       // System.assertEquals(caseInst.Country__c,BDAGeographyData_Test.countryUK.Id);
       // System.assertEquals(caseInst.Cluster__c,BDAGeographyData_Test.clusterUK.Id);   
    }
    
    // Cluster is null country isn't
    @isTest
    public static void testPopulateClusterBasedOnCountry() {
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseInstance.Cluster__c = null;
        
        Test.startTest();
        update caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c,BDAGeographyData_Test.countryUK.Id);
       // System.assertEquals(caseInst.Cluster__c,BDAGeographyData_Test.clusterUK .Id); 
    }
    
        // Cluster is null country isn't for Dispute cases
    @isTest
    public static void testPopulateClusterBasedOnCountryforDispute() {
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createDisputecases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseInstance.Cluster__c = BDAGeographyData_Test.clusterNA.Id;
        
        Test.startTest();
        update caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c FROM Case Where Id =:caseInstance.Id];
        //system.debug('**caseInst'+caseInst);
        //System.assertEquals(caseInst.Country__c,BDAGeographyData_Test.countryIN.Id);
        //System.assertEquals(caseInst.Cluster__c,BDAGeographyData_Test.clusterUK .Id); 
    }
    
    // City is updated
    @isTest
    public static  void testPopulateCountryClusterOnCityUpdate() {
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.City__c = BDAGeographyData_Test.cityEdinburgh.Id;
        
        Test.startTest();
        update caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c, City__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUK.Id);
        //System.assertEquals(caseInst.City__c, BDAGeographyData_Test.cityEdinburgh.Id);   
        //System.assertEquals(caseInst.Cluster__c, BDAGeographyData_Test.clusterUK .Id); 
        
    }
    
    // Country = null
    @isTest
    public static  void testPopulateCountryFromAccount() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Country__c = null;
        
        Test.startTest();
        insert caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c, City__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUS.Id);
    }
    
    // SuppliedEmail != null
    @isTest
    public static  void testPopulateCountryForEmailToCase() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createEmailToCase();
        
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Country__c = null;
        Test.startTest();
        insert caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c, City__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUS.Id);
    }
    
    // Country__c = null & Cluster__c != null
    @isTest
    public static  void testPopulateCountryBasedOnCluster() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 20;
        CaseData_Test.createExternalCases();
        
        Case caseInstance = CaseData_Test.lstCases[0];
        Account accInstance = new Account(Id = caseInstance.AccountId, Country__c = null);
        update accInstance;
        
        caseInstance.Country__c = null;
        caseInstance.Cluster__c = BDAGeographyData_Test.clusterNA.Id;
        
        Test.startTest();
        insert caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c, City__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUS.Id);
        //System.assertEquals(caseInst.Cluster__c, BDAGeographyData_Test.clusterNA.Id);
    }
    
    // RQ-007865
    @isTest
    public static void testPopulateCountryOnISROwnerUpdate() {       
        TriggerExecutionController.skipAllTriggers(True);
        CaseData_Test.iNumberOfCases = 20;
        CaseData_Test.createISRCases();
        list<Case> lstCases =  new list<Case>();
        list<Case> lstCasesToUpdate =  new list<Case>();
        lstCases = CaseData_Test.lstCases;
        
        BDAGeographyData_Test bda = new BDAGeographyData_Test();
        
        UserData_Test.iNumberOfUsers = 1;
        UserData_Test.createCustomerusers();
        list<User> lstUser = UserData_Test.lstUsers;
        lstUser = UserData_Test.lstUsers;
        lstUser[0].Country = 'UNITED STATES';
        update lstUser[0];
        TriggerExecutionController.skipAllTriggers(False);
        
        for(Case caseInst : lstCases) {
            caseInst.Requestor_Dept__c = 'Single Carrier';
            caseInst.Resolver_Dept__c = 'Ocean: Sales - DnD';
            caseInst.Liner_Brand__c = BrandUtilities.SEAGO;
            caseInst.OwnerId = lstUser[0].Id; 
            lstCasesToUpdate.add(caseInst);
        }
        
        //Test.startTest();
        update lstCasesToUpdate;
        //Test.stopTest();
        
        // On case owner update, the case country is updated to the owner(user) country us. 
       // Case caseInst = [SELECT Id, Country__c FROM Case WHERE Id =: lstCasesToUpdate[0].Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUS.Id);   
    }
    
    // RQ-007865
    @isTest
    public static  void testPopulateCountryForMLLUSFLGEmailToCase() {       
        TriggerExecutionController.skipAllTriggers(True);
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        if(conInstance != null) {
            conInstance.Email = 'test@gmail.com';
            update conInstance;
        }
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 20;
        CaseData_Test.createEmailToCase();
        list<Case> lstCases =  new list<Case>();
        list<Case> lstCasesToinsert =  new list<Case>();
        lstCases = CaseData_Test.lstCases;       
        BDAGeographyData_Test bda = new BDAGeographyData_Test();            
        TriggerExecutionController.skipAllTriggers(False); 
        
        for(Case caseInst : lstCases) {
            caseInst.Type = 'Booking';
            caseInst.Sub_Type__c = 'Amend Booking Details';
            caseInst.Priority = 'Medium';
            caseInst.Origin = 'MLLUSFLG'; 
            caseInst.SuppliedEmail = 'Test@gmail.com';
            lstCasesToInsert.add(caseInst);
        }
        
        Test.startTest();
        insert lstCasesToInsert;
        Test.stopTest();
        
        // Case country should be updated to the account country for the MLLUSFLG origin.
        Case caseInst = [SELECT Id, Country__c FROM Case WHERE Id =: lstCasesToInsert[0].Id];
        //System.assertEquals(caseInst.Country__c,BDAGeographyData_Test.countryUS.Id);   
    }
    
    // RQ-007865
    @isTest
    public static  void testPopulateCountryOnCountryUpdation(){       
        TriggerExecutionController.skipAllTriggers(True);
        CaseData_Test.iNumberOfCases = 20;
        CaseData_Test.createExternalCases();
        list<Case> lstCases =  new list<Case>();
        list<Case> lstCasesToUpdate =  new list<Case>();
        lstCases = CaseData_Test.lstCases;
        
        BDAGeographyData_Test bda = new BDAGeographyData_Test();                    
        TriggerExecutionController.skipAllTriggers(False);
        
        for(Case caseInst : lstCases) {
            caseInst.Country__c = BDAGeographyData_Test.countryCH.Id;
            lstCasesToUpdate.add(caseInst);
        }
        
        Test.startTest();
        update lstCasesToUpdate;
        Test.stopTest();
        
        //The case country should be the one entered by the user on case updation.
        Case caseInst = [SELECT Id, Country__c FROM Case WHERE Id =: lstCasesToUpdate[0].Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryCH.Id);   
    }
    
    //SC-394
    @isTest
    public static  void testPopulateCountryFromContactForSCMCases() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createSCMCases();
        
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.type = 'Non-Case';
        caseInstance.sub_type__c = 'Reporting';
        caseInstance.product__c = 'SCM';
        caseInstance.reason_for_case__c = 'New additional report request';
        
        Test.startTest();
        insert caseInstance;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c, Cluster__c, City__c FROM Case Where Id =:caseInstance.Id];
        //System.assertEquals(caseInst.Country__c, BDAGeographyData_Test.countryUS.Id);
    }
     
   @isTest
    public static  void testPopulateCountryForSCMGLOBALEmailToCase() {       
        TriggerExecutionController.skipAllTriggers(True);
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createEmailToCase();
        list<Case> lstCases =  new list<Case>();
        list<Case> lstCasesToinsert =  new list<Case>();
        lstCases = CaseData_Test.lstCases;       
        BDAGeographyData_Test bda = new BDAGeographyData_Test(); 
        TriggerExecutionController.skipAllTriggers(False); 
         Group queueId = [SELECT Id FROM Group WHERE Name = 'SCM - Adidas - Cambodia' and Type = 'Queue'];
        for(Case caseInst : lstCases) {
            caseInst.Type = 'Carrier booking';
            caseInst.Sub_Type__c = 'Amend Booking Details';
            caseInst.Reason_for_case__c = 'Wrong booking initiated by Maersk SCM';
            caseInst.product__c = 'SCM';
            caseInst.Priority = 'Medium';
            caseInst.Origin = 'SCMGLOBALADG'; 
            caseInst.SuppliedEmail = 'Test@gmail.com';
            caseInst.OwnerId =queueId.Id; 
            lstCasesToInsert.add(caseInst);
        }
        
        Test.startTest();
        insert lstCasesToInsert;
        Test.stopTest();
        
        Case caseInst = [SELECT Id, Country__c FROM Case WHERE Id =: lstCasesToInsert[0].Id];
        //System.assertEquals(caseInst.Country__c,BDAGeographyData_Test.countryCH.Id);   
    }
 @isTest
    public static  void testPopulateCountryFromAccountISR() {
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        
        CaseTrigger_DataSetUtilities.CountryClusterGeoList = null;
        Generic_TriggerHandler.clearLoopCountForAllMethod();
        Case caseInstance = CaseData_Test.lstCases[0];
        caseInstance.Country__c = null;
        caseInstance.SF_4PL_Account__c = 'Nvidia';
        caseInstance.Product__c = '4PL';
        Test.startTest();
        try{
          insert caseInstance;  
        }catch(Exception e){
            
        }
        
        Test.stopTest();
    }
    
}