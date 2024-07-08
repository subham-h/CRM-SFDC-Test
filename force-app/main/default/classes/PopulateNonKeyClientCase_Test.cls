/*
* Author   : Ayush.k@Maersk
* Purpose  : Utility test class for updating Details on Non KC Case.
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0       SS-5430    16-Nov-2022     Ayush.k@Maersk        To identify the SO Number and related Customer Name for Non KC Case.
*/

@isTest
public class PopulateNonKeyClientCase_Test {
    
    public static list<Case> lstCases = new list<Case>();
    public static list<Account> lstAccs = new list<Account>();
    public static list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>();
    
    @TestSetup
    public static void setupTestData() {
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        for(Case caseIterator : lstCases) {  
            caseIterator.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Documentation'; 
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSK;
            caseIterator.sub_type__c = 'Amend SI/BL/VC';
            caseIterator.Case_Channel__c ='E-mail';
        }
        insert lstCases; 
        
        AccountData_Test.iNumberOfAccounts = 1; 
        AccountData_Test.createClientAccounts();
		lstAccs.addAll(AccountData_Test.lstAccounts);
        
        Id cargoRTId = Schema.SObjectType.LS_TM_Connective_Task__c.getRecordTypeInfosByDeveloperName().get('LS_TM_Cargo_Stuffing').getRecordTypeId();
        Integer iNumberOfCTask = 1;
        for(integer j=0; j<iNumberOfCTask; j++) {
        	LS_TM_Connective_Task__c cTaskIterator = new LS_TM_Connective_Task__c();
            cTaskIterator.RecordTypeId = cargoRTId;
         	cTaskIterator.LS_TM_External_Reference_Number__c = 'Ayu1234567';
            cTaskIterator.LS_TM_External_Reference_Type__c = 'SO';
            cTaskIterator.LS_TM_Consignee_Name__c = lstAccs[0].name;
            lstCTask.add(cTaskIterator);
  		}
        insert lstCTask;
        System.debug('C Task' +lstCTask );
    }
    
    
    @isTest
    private static void testAccountDetails1(){
        Test.startTest();
        list<Case> lstCases = new list<Case>([SELECT id,SO_Number__c,On_Behalf_Account__c,subject,description, Product__c, status, Case_Channel__c, type, sub_type__c FROM case Limit 1]);
        lstCases[0].Type = 'Documentation';
        lstCases[0].sub_type__c = 'Amend SI/BL/VC';
        lstCases[0].Description = 'Description with a SONumber - Ayu1234567.Lets see if it is found or not';
        update lstCases;
        list<Account> lstAccs = new list<Account>([SELECT Id, name FROM account Limit 1]);
        list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c limit 1]);
        PopulateNonKeyClientCase.populateAccountDetails(lstCases[0].id,'Ayu1234567',lstAccs[0].name, lstAccs[0].name);
		list<Case> updatedList = [Select Id, On_Behalf_Account__c From Case Where SO_Number__c = 'Ayu1234567' LIMIT 1];
        //System.assertEquals(true, updatedList[0].On_Behalf_Account__c != null);
        Test.stopTest();
    }
    
    @isTest
    private static void testAccountDetails2(){
        Test.startTest();
        list<Case> lstCases = new list<Case>([SELECT id,SO_Number__c,On_Behalf_Account__c,subject,description FROM case Limit 1]);
        lstCases[0].Type = 'Documentation';
        lstCases[0].sub_type__c = 'Amend SI/BL/VC';
        lstCases[0].Description = 'Description without a SONumber';
        update lstCases;
        list<Account> lstAccs = new list<Account>([SELECT Id, name FROM account Limit 1]);
        list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c limit 1]);
        PopulateNonKeyClientCase.populateAccountDetails(lstCases[0].id,'No Result',lstAccs[0].name,lstAccs[0].name);
        list<Case> updatedList = [Select Id, SO_Number__c,On_Behalf_Account__c From Case LIMIT 1];
        System.assertEquals(null, updatedList[0].SO_Number__c);
        System.assertEquals(true, updatedList[0].On_Behalf_Account__c != null);
        Test.stopTest();
    }
    
    @isTest
    private static void testAccountDetails3(){
        Test.startTest();
        list<Case> lstCases = new list<Case>([SELECT id,SO_Number__c,On_Behalf_Account__c,subject,description FROM case Limit 1]);
        lstCases[0].Type = 'Documentation';
        lstCases[0].sub_type__c = 'Amend SI/BL/VC';
        lstCases[0].Description = 'Description with a SONumber - Ayu1234567 but no account attached to it.Lets see if it is found or not';
        update lstCases;
        list<Account> lstAccs = new list<Account>([SELECT Id, name FROM account Limit 1]);
        list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c limit 1]);
        PopulateNonKeyClientCase.populateAccountDetails(lstCases[0].id,'No Response','Multiple Response',lstAccs[0].name);
        list<Case> updatedList = [Select Id, On_Behalf_Account__c,SO_Number__c From Case Where SO_Number__c = 'Ayu1234567' LIMIT 1];
        if(!updatedList.isEmpty())
            System.assertEquals(false, updatedList[0].On_Behalf_Account__c != null);
        Test.stopTest();
    }    
    
     @isTest
    private static void testAccountDetails4(){
        Test.startTest();
        list<Case> lstCases = new list<Case>([SELECT id,SO_Number__c,On_Behalf_Account__c,subject,description FROM case Limit 1]);
        lstCases[0].Type = 'Documentation';
        lstCases[0].sub_type__c = 'Amend SI/BL/VC';
        lstCases[0].Description = 'Description with a SONumber - Ayu1234567 but no account attached to it.Lets see if it is found or not';
        update lstCases;
        list<Account> lstAccs = new list<Account>([SELECT Id, name FROM account Limit 1]);
        list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c limit 1]);
        PopulateNonKeyClientCase.populateAccountDetails(lstCases[0].id,'Ayu7374839',lstAccs[0].name,lstAccs[0].name);
        list<Case> updatedList = [Select Id, SO_Number__c,On_Behalf_Account__c From Case LIMIT 1];
        System.assertEquals(null, updatedList[0].SO_Number__c);
        System.assertEquals(true, updatedList[0].On_Behalf_Account__c != null);
        Test.stopTest();
    }  

     @isTest
     static void testpopulateSOandOBA(){
       list<Case> lstCases = new list<Case>([SELECT id,SO_Number__c,On_Behalf_Account__c,subject,description FROM case Limit 1]);
       lstCases[0].subject = 'TestSubject Ayu1234567 Test';
       lstCases[0].description = 'TestDescription Ayu1234567 Test';
       update lstCases;
       Test.startTest();
         PopulateNonKeyClientCase.populateSOandOBA(lstCases);
       Test.stopTest();
       list<LS_TM_Connective_Task__c> lstCTask = new list<LS_TM_Connective_Task__c>([SELECT Id,LS_TM_External_Reference_Number__c,LS_TM_Consignee_Name__c FROM LS_TM_Connective_Task__c WHERE LS_TM_External_Reference_Number__c='Ayu1234567' limit 1]);
       list<Case> updatedList = [Select Id, SO_Number__c,On_Behalf_Account__c From Case WHERE subject = 'TestSubject Ayu1234567 Test' LIMIT 1];
       system.assertEquals(updatedList[0].SO_Number__c,lstCTask[0].LS_TM_External_Reference_Number__c );
       //system.assertEquals(updatedList[0].On_Behalf_Account__c,lstCTask[0].LS_TM_Consignee_Name__c );
     }










}