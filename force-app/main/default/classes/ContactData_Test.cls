/**
* Author   : Ragu
* Purpose  : Utility test class for creating Account related test data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   06-May-2016 Ragu@UST                Created.
* 2.0      RQ-004366   29-May-2017 Hitha@UST               Updated to make contact status as "Active".
* 3.0      RQ-005312   12-May-2017 Hitha@UST               Updated to improve code coverage  
* 4.0      SPI-100     13-Jun-2022 Ronnie@SF               Removed brand hardcoding
*/

@isTest
public class ContactData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfContacts = 5;
    public static list<Contact> lstContacts;
    
    // Use this accInstance if you have already created an Account and you wanted to create Contacts for it.
    public static Account accInstance = null;
    
    public static testMethod void createCustomerContacts() {
        populateCommonContactFields();
        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        for(Contact conIterator : lstContacts) {
            conIterator.LastName = 'Customer Contact' + Math.random() + DateTime.now().millisecond(); 
            conIterator.RecordTypeId = customerRTId;
        }
        if(bCreate) {
            insert lstContacts;
        }
        AccountData_Test.createEntitlements();
    }
    
    public static testMethod void createInternalContacts() {
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createUnassignedAccounts();
        ContactData_Test.accInstance =AccountData_Test.lstAccounts[0];
        
        populateCommonContactFields();
        
        Id internalRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Internal Contact');
        Integer uniqueUidCounter = 1;
        for(Contact conIterator : lstContacts) {
            conIterator.LastName = 'Internal Contact' + Math.random() + DateTime.now().millisecond(); 
            conIterator.Unique_User_ID__c = 'UId' + uniqueUidCounter;
            conIterator.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@maersk.com'; //RQ-005312
            conIterator.RecordTypeId = internalRTId;
            uniqueUidCounter++;
        }
        if(bCreate) {
            insert lstContacts;
        }
    }
    
    public static testMethod void createNonShippingPartyContacts() {
        populateCommonContactFields();
        Id nonShippingRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Non-shipping Party Contact');
        for(Contact conIterator : lstContacts) {
            conIterator.LastName = 'Non-shipping Party' + Math.random() + DateTime.now().millisecond(); 
            conIterator.RecordTypeId = nonShippingRTId;
        }
        if(bCreate) {
            insert lstContacts;
        }
    }
    
    private static testMethod void populateCommonContactFields() {
        if(accInstance == null) {
            AccountData_Test.iNumberOfAccounts = 1;
            AccountData_Test.createClientAccounts();
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