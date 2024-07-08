/*
* Author   : Nisha
* Purpose  : Test class for ErrorLogger
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
*1.0       #RQ-005306  16-Jun-2017 Nisha@UST               Test class for ErrorLogger
*/

@isTest
public class ErrorLogger_Test {   
    
    // Create Error logger configuration custom setting records 
    @testSetup static void createErrLoggerRecords() {
        List<Error_Log_Configuration__c> errLogConfigList = new List<Error_Log_Configuration__c>();
        Error_Log_Configuration__c errorConfig = new Error_Log_Configuration__c();
        errorConfig = new Error_Log_Configuration__c();
        errorConfig.Name = 'SFDC:Contact';
        errorConfig.Source_System__c = 'SFDC';
        errorConfig.SFDC_Object_Name__c = 'Contact';
        errorConfig.Total_Errors__c = 0;
        errorConfig.Max_Errors__c = 20;
        errorConfig.Time_Period_Minutes__c = 10;
        errLogConfigList.add(errorConfig);    
        
        Error_Log_Configuration__c errorConfig1 = new Error_Log_Configuration__c();
        errorConfig1.Name = 'SFDC:Case';
        errorConfig1.Source_System__c = 'SFDC';
        errorConfig1.SFDC_Object_Name__c = 'Case';
        errorConfig1.Total_Errors__c = 0;
        errorConfig1.Max_Errors__c = 20;
        errorConfig1.Time_Period_Minutes__c = 10;
        errLogConfigList.add(errorConfig1);    
        insert errLogConfigList; 
    }
    
    // Test method for Exception with details.
    public static testMethod void test_ExceptionDetails() {
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Id> lstContactIds = new list<Id>();
        Database.DeleteResult[] sr;
        Boolean flag;
        
        list<Contact> lstContact =  ContactData_Test.lstContacts;
        for(Contact conIterator : lstContact){
            lstContactIds.add(conIterator.Id);
        }
        
        Test.startTest();
        try {
            sr = Database.delete(lstContactIds);
        }
        catch(Exception ex) {
            list<Exception> lstException = new list<Exception>();
            lstException.add(ex);
            flag = ErrorLogger.writeError('SFDC', 'Contact', 'Error', ex.getMessage(), ex.getTypeName(), ex.getStackTraceString());
        }
        
        Test.stopTest();
        //System.assertEquals(flag, true);
        
        
        //Added code to cover the class
        ErrorStormHandler.skipErrorStormCheck(true);
        ErrorStormHandler.skipErrorStormCheck();
    }
    
    // Test method for Exception list
    public static testMethod void test_lstException() {
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Id> lstContactIds = new list<Id>();      
        list<Contact> lstContact = ContactData_Test.lstContacts;    
        Database.DeleteResult[] sr;
        Boolean flag;
        
        for(Contact conIterator : lstContact){
            lstContactIds.add(conIterator.Id);
        }      
        
        Test.startTest();
        try {
            sr = Database.delete(lstContactIds);
        }
        catch(Exception ex) {
            list<Exception> lstException = new list<Exception>();
            lstException.add(ex);
            flag = ErrorLogger.writeErrors('SFDC', 'Contact', 'Error', lstException);
        }
        Test.stopTest();
        //System.assertEquals(flag, true);
    }
    
    // Test method for Database.SaveResult
    public static testMethod void test_saveResult() {
        ContactData_Test.bcreate = false;
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Contact> lstContact =  ContactData_Test.lstContacts;
        Boolean flag;
        
        for(Contact contactIterator : lstContact) {    
            contactIterator.Liner_Brands__c = 'Maserkline-123';
            contactIterator.Phone = '4554765687989089';
        }
        
        Test.startTest();
        Database.SaveResult[] sr = Database.insert(lstContact,false);
        flag = ErrorLogger.writeErrors('SFDC', 'Contact', 'Error', sr, lstContact);
        Test.stopTest();
        System.assertEquals(flag, true);
    }
    
    // Test method for Database.UpsertResult
    public static testMethod void test_upsertResult() {
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Contact> lstContact =  ContactData_Test.lstContacts;
        Integer externalIdIncrement = 0;
        Boolean flag;
        
        for(Contact contactIterator : lstContact) {
            contactIterator.Liner_Brands__c = 'MaserkLine-123';
            contactIterator.Phone = '4554765687989089';
            contactIterator.External_Id__c = externalIdIncrement + 'a';
            externalIdIncrement++;            
        }       
        Schema.SObjectField f = Contact.Fields.External_Id__c;
        
        Test.startTest();
        Database.UpsertResult[] up = Database.upsert(lstContact,f,false);
        flag = ErrorLogger.writeErrors('SFDC', 'Contact', 'Error', up, lstContact);
        Test.stopTest();
        System.assertEquals(flag, true);
    }
    
    // Test method for Database.DeleteResult
    public static testMethod void test_deleteResult() {
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Id> lstContactIds = new list<Id>();
        list<Contact> lstContact =  ContactData_Test.lstContacts;
        Boolean flag;
        
        for(Contact conIterator : lstContact){
            lstContactIds.add(conIterator.Id);
        }
        
        Test.startTest();
        Database.DeleteResult[] dr = Database.delete(lstContactIds,false);
        flag = ErrorLogger.writeErrors('SFDC', 'Contact', 'Error', dr, lstContact);
        Test.stopTest();
        //System.assertEquals(flag, true);
    }
    
    public static testMethod void test_ExceptionDetailsFalse() {
        ContactData_Test.iNumberOfContacts = 10;
        ContactData_Test.createCustomerContacts();
        list<Id> lstContactIds = new list<Id>();
        Database.DeleteResult[] sr;
        Boolean flag;
        
        list<Contact> lstContact =  ContactData_Test.lstContacts;
        for(Contact conIterator : lstContact){
            lstContactIds.add(conIterator.Id);
        }
        
        Test.startTest();
        try {
            sr = Database.delete(lstContactIds);
        }
        catch(Exception ex) {
            list<Exception> lstException = new list<Exception>();
            lstException.add(ex);
            ErrorStormHandler.skipErrorStormCheck(false);
            flag = ErrorLogger.writeError('SFDC', 'Contact', 'Error', ex.getMessage(), ex.getTypeName(), ex.getStackTraceString());
        }
        
        Test.stopTest();
        ErrorStormHandler.skipErrorStormCheck(false);
        ErrorStormHandler.isErrorStorm('SFDC', 'Case', 1);
    }
    
}