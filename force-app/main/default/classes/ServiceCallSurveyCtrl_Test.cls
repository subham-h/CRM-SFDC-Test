/**
 * Test class for ServiceCallSurveyCtrl
 * 
 * Version     Date         Owner                      RQ#            Description
 ******************************************************************************************************  
 * 1.0                                                 #              Code created
 * 2.0         08-06-2022   Ronnie@SF                  SPI-100        Removed brand hardcoding
 */

@isTest
public  class ServiceCallSurveyCtrl_Test {
    public ServiceCallSurveyCtrl_Test() {
        
    }
    static testMethod void test_populateEncryptedId() {
        Account acc =  new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;       
        
        list<Sales_Call__c> lstSalCall = new list<Sales_Call__c>();
        SalesCallData_Test.bCreate = false;
        SalesCallData_Test.createServiceCallWithEvent();
        lstSalCall = SalesCallData_Test.lstsalesCall;
        lstSalCall[0].Contact__c =  cont.Id;
        lstSalCall[0].Service_Type__c = 'Onboarding';
        lstSalCall[0].StartDateTime__c = system.now() - 2;
        lstSalCall[0].EndDateTime__c = system.now() - 1;
        lstSalCall[0].Survey_Sent_Date__c= date.today()- 1;
        
        Service_Call_Survey_Key__c key = new Service_Call_Survey_Key__c();
        key.Crypto_Key__c = 'cj67pKL+Pa7qr8K6Ul/HFep33jQC8gnoEPnUxCXhdYk=';
        insert key;
        
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        insert lstSalCall;
        
        Sales_Call__c salesCallUpdated = [SELECT Id, Encrypted_Service_Call_Id__c, Status__c, Service_Type__c, RecordType.Name, liner_brand__c FROM Sales_Call__c WHERE Id = :lstSalCall[0].Id];
        //system.System.debug('salesCallUpdated'+salesCallUpdated.Encrypted_Service_Call_Id__c);
        salesCallUpdated.Status__c = 'Completed';
        TriggerExecutionController.skipAllTriggers(false);
        update salesCallUpdated;
        Sales_Call__c salesCallUpdated1 = [SELECT Id, Encrypted_Service_Call_Id__c, Status__c, Service_Type__c, RecordType.Name, liner_brand__c FROM Sales_Call__c WHERE Id = :lstSalCall[0].Id];
        system.System.debug('salesCallUpdated##'+salesCallUpdated1.Encrypted_Service_Call_Id__c);
        
        PageReference pageRef = Page.CaseSurvey;       
        pageRef.getParameters().put('Id',salesCallUpdated1.Encrypted_Service_Call_Id__c );
        pageRef.getParameters().put('Fb','3');
        Test.setCurrentPage(pageRef); 
        ServiceCallSurveyCtrl obj = new ServiceCallSurveyCtrl();
        obj.createSurvey();
        obj.updateSurvey();
        PageReference pageRef1 = Page.CaseSurvey;       
        pageRef.getParameters().put('Id',salesCallUpdated1.Encrypted_Service_Call_Id__c );
        pageRef.getParameters().put('Fb','2');
        Test.setCurrentPage(pageRef); 
        ServiceCallSurveyCtrl obj2 = new ServiceCallSurveyCtrl();
        obj2.createSurvey();
        obj2.updateSurvey();
        PageReference pageRef2 = Page.CaseSurvey;       
        pageRef.getParameters().put('Id',salesCallUpdated1.id );
        pageRef.getParameters().put('Fb','2');
        Test.setCurrentPage(pageRef); 
        ServiceCallSurveyCtrl obj3 = new ServiceCallSurveyCtrl();
        obj3.createSurvey();
        obj3.updateSurvey();
        obj3.twill = false;
        obj3.LinerBrand = BrandUtilities.MAERSKLINE;
        obj3.getBrandCSSLocation();
        obj3.getBrandCSSFileName();
        obj3.getBrandCSSFileName();
        obj3.getBrandLogoFileName();
        obj3.getBrandLogoLocation();
        test.StopTest();
    }
}