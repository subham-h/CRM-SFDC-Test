/**
 * Helper class for generating Contact for all Liner Brands to be used as primary contact for an Account/Opportunity
 *
 * Date         Owner                                   Ref Number   Description
 **************************************************************************************************************************************
 * 17/02/2015   Deepa.Raman@ust-global.com              #RQ-000917   Move ALL test data generation to Helper classes.
 * 22/12/2015   Sandhya.Sambasivan@ust-global.com       #RQ-002247   Case trigger refactoring
 * 06/01/2016   Meghana.gupta@ust-global.com            #RQ-002192   Add method createCustomerContact by passing RunAs user
 * 12/12/2015   Sunu.Paul@ust-global.com                #PR-0055     Added data generator methods from Contact Trigger and also methods for creating Seago Contacts..
 * 03/05/2016   Sandhya.Sambasivan@ust-global.com       #RQ-003041   Added Linet Brand for internal contact
 * 12/08/2016   Jiji@UST                                #RQ-004057   RQ-004319 - Remove reference to Survey_Me__c, Primary_Contact__c field
 * 11/07/2019   Junaid.Khader@ust-global.com            RQ-010654    Removed reference of deprecated objects Trade_Interest__c & Customer_Subscription__c
 */
    
public class ContactDataGeneratorHelper_Test {      

    public static Contact customerContact = null,customerContactWithCountry;
    public static Contact nonShipPartyContact = null;
    public static Contact internalContact = null;
    public static Contact conObj,conObj2,conObj3,conSCLObj,conSCLObj2,conSCLObj3,conSEAObj,conSEAObj2,conSEAObj3;
    
    /**
    * Constructor
    **/    
    public ContactDataGeneratorHelper_Test () { 

    }   
    
    /**
    * Method to get Record Types of Contact to create Contacts.
    **/ 
    public static Map<String, ID> getContactRecordType () {
        Map<String, ID> ContRT = new Map<String, ID> ();
        for(RecordType r : [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Contact' LIMIT 4]){
            ContRT.put(r.Name,r.id);
        }
        return ContRT;
    }
     
    public static Map<String, ID> ContactRecordTypeMap = getContactRecordType();
       
    /**
    * Method to create Customer Contact with specified Liner Brand.
    **/        
    public static Contact createCustomerContact(ID AccountID,String LinerBrand) {
        
        //Create primary contact
        customerContact =  createCustomerContact ( AccountID, LinerBrand, UserDataGeneratorHelper_Test.IntegrationUser);
        return customerContact;
    }
    
    /**
    * #RQ-002192 
    * Sealand contacts can be created by Sealand users only, hence passing runas user to method
    **/        
    public static Contact createCustomerContact(ID AccountID, String LinerBrand, User RunAsUser) {
        
        //customerContact = createCustomerContact(LinerBrand,AccountID,'MSLTestContact@testingContact1.com',true,false,RunAsUser);
        customerContact = createCustomerContact(LinerBrand,AccountID,'MSLTestContact@testingContact1.com',RunAsUser);
        return customerContact;
    }
    
    /**
    * Method to create Non-shipping Party Contact with specified Liner Brand
    **/ 
    public static Contact createNonShipPartyContact(ID AccountID,String LinerBrand) {
    
        //Create primary contact
        nonShipPartyContact =  new Contact();
        nonShipPartyContact.LastName = 'Test Class Contact' + Math.random();
        nonShipPartyContact.FirstName = LinerBrand ;
        nonShipPartyContact.Email = 'NSPTestContact1@testingcontact3.com';
        nonShipPartyContact.Preferred_Language__c = 'English';
        nonShipPartyContact.Liner_Brands__c = LinerBrand  ; 
        nonShipPartyContact.RecordTypeId = ContactRecordTypeMap.get('Non-shipping Party Contact');
        nonShipPartyContact.AccountId = AccountID;

        System.runAs(UserDataGeneratorHelper_Test.IntegrationUser){
            Database.Insert(nonShipPartyContact);
        }
        return nonShipPartyContact;
    }
    
    /**
    * Method to create Internal Contact with specified Liner Brand.Internal Contact does not need a brand specified.
    **/
    public static Contact createInternalContact(ID AccountID, String LinerBrand) {
    
        internalContact =  new Contact();
        internalContact.LastName = 'Test Class Contact' + Math.random();
        internalContact.FirstName = 'Inernal';
        internalContact.Email = 'InternalContact1@maersk.com';
        internalContact.Preferred_Language__c = 'English';
        internalContact.RecordTypeId = ContactRecordTypeMap.get('Internal Contact'); 
        internalContact.AccountId = AccountID;
        internalContact.Liner_Brands__c = LinerBrand ; //#RQ-003041 - Added Liner Brand
        internalContact.Unique_User_ID__c = 'TTT123'; //Feild avaible in preprod.
        
        System.runAs(UserDataGeneratorHelper_Test.IntegrationUser){
            Database.Insert(internalContact);
        }       
        return internalContact;
    }
    
    /**
    * Method to create Customer Contact with specified Liner Brand.
    **/        
    public static Contact createCustomerContactWithCountry(ID AccountId,String LinerBrand, Id CountryId) {
        
        //Create primary contact
        customerContactWithCountry =  new Contact();
        customerContactWithCountry.LastName = 'Test Class Contact' + Math.random();
        customerContactWithCountry.FirstName = LinerBrand ;
        customerContactWithCountry.Email = 'TestContact@testingcontact3.com';
        customerContactWithCountry.Preferred_Language__c = 'English';
        //customerContactWithCountry.Primary_Contact__c = true;
        customerContactWithCountry.Liner_Brands__c = LinerBrand ; 
        customerContactWithCountry.RecordTypeId = ContactRecordTypeMap.get('Customer Contact');
        customerContactWithCountry.AccountId = AccountId;
        customerContactWithCountry.Country__c = CountryId;
 
        System.runAs(UserDataGeneratorHelper_Test.MLLIntegrationUser){
            Database.Insert(customerContactWithCountry);
        }
        return customerContactWithCountry;
    }
    
    /*
    * Method to create Customer Contact with specified Liner Brand, Email and Primary Flag 
    **/        
    //public static Contact createCustomerContact(String LinerBrand,Id AccountID,String ContactEmail,Boolean PrimaryFlag,Boolean Surveyme,User RunAsUser) {
    public static Contact createCustomerContact(String LinerBrand,Id AccountID,String ContactEmail,User RunAsUser) {
        
        //Create primary contact
        customerContact =  new Contact();
        customerContact.LastName = 'Test Class Contact' + Math.random();
        customerContact.FirstName = LinerBrand ;
        customerContact.Email = ContactEmail;
        customerContact.Preferred_Language__c = 'English';
        //customerContact.Primary_Contact__c = PrimaryFlag ;
        customerContact.Liner_Brands__c = LinerBrand ;
        customerContact.RecordTypeId = ContactRecordTypeMap.get('Customer Contact');
        customerContact.AccountId = AccountID;
		customerContact.Contact_Status__c = 'Active';
        System.runAs(RunAsUser){
            Database.Insert(customerContact);
        } 
        System.debug('*********Contact Last Name :'+customerContact.LastName+'Email:'+customerContact.Email+'Liner Brand:'+customerContact.Liner_Brands__c);    

        return customerContact;
    }         
}