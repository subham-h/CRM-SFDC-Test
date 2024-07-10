/**
 * Purpose  : This is a test class for Batch class - Batch_UpdateContactOwner
 * 
 * Revision  Ref Number      Date            Owner                   Description
 * --------  ----------      -----------     -------------------     -----------
 * 1.0       #RQ-011601      24-Oct-2019     Abhinav Ankit           Test class for Batch_UpdateContactOwner
 * 2.0       SFSE-1617       15-Jun-2020     Meghana                 Fix test failure - FIELD_CUSTOM_VALIDATION_EXCEPTION, Please update Unique User ID: [Unique_User_ID__c]
 * 3.0       SPI-100         13-Jun-2022     Ronnie@SF               Removed brand hardcoding
 */

@isTest
public class Batch_UpdateContactOwner_test {
	
    public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
    
    // Use this accInstance if you have already created an Account and you wanted to create Contacts for it.
    public static Account accInstance = null;
    
    public static testMethod void createInternalContacts() {
    	AccountData_Test.iNumberOfAccounts = 1;
    	AccountData_Test.createUnassignedAccounts();
    	populateCommonContactFields();
         
        Id internalRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Internal Contact');
        Integer loopCounter1 = 1;
        for(Contact conIterator : lstContacts) {
            conIterator.LastName = 'Internal Contact' + Math.random() + DateTime.now().millisecond(); 
            conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@maersk.com'; 
            conIterator.RecordTypeId = internalRTId;
            conIterator.Unique_User_ID__c = 'UId' + loopCounter1;
            loopCounter1++;
        }
        if(bCreate) {
            insert lstContacts;
        }
        
        Test.startTest();
        String query = 'select id,ownerId,owner.name from contact where recordtype.name=\'Internal Contact\' ';
        Batch_UpdateContactOwner oppBatch = new Batch_UpdateContactOwner(query);          
        ID batchProcessID = Database.executeBatch(oppBatch,200);
        Test.stopTest();
    }
    
     public static testMethod void createInternalContacts_1() {
    	AccountData_Test.iNumberOfAccounts = 1;
    	AccountData_Test.createUnassignedAccounts();
    	populateCommonContactFields();
         
        Id internalRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Internal Contact');
         Integer loopCounter1 = 1;
        for(Contact conIterator : lstContacts) {
            conIterator.LastName = 'Internal Contact' + Math.random() + DateTime.now().millisecond(); 
            conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@maersk.com'; 
            conIterator.RecordTypeId = internalRTId;
            conIterator.Unique_User_ID__c = 'UId' + loopCounter1;
            loopCounter1++;
        }
        if(bCreate) {
            insert lstContacts;
        }
        
        Test.startTest();
        String query = 'select id,ownerId,owner.name from contact where recordtype.name=\'Internal Contact\' ';
        Batch_UpdateContactOwner oppBatch = new Batch_UpdateContactOwner(null);          
        ID batchProcessID = Database.executeBatch(oppBatch,200);
        Test.stopTest();
    }
    
    
      private static testMethod void populateCommonContactFields() {
        if(accInstance == null) {
           AccountData_Test.iNumberOfAccounts = 1;
           AccountData_Test.createUnassignedAccounts();
            accInstance =AccountData_Test.lstAccounts[0];
        }
        
        lstContacts = new list<Contact>();
        for(Integer i=0; i<iNumberOfContacts; i++) {
            Contact conIterator = new Contact();
            conIterator.AccountId = accInstance.Id;
            
            Double randomVal = Math.random() * 100;
            Integer roundval = Math.round(randomVal);
            
            conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
            conIterator.Phone = '+44 123412' + roundval;
            conIterator.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
            conIterator.Liner_Brands__c = BrandUtilities.MAERSKLINE;
            conIterator.Country__c = accInstance.Country__c;
            conIterator.Contact_Status__c = 'Active';
            
            lstContacts.add(conIterator);
        }
      }     
}