/**
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Contact fields. 
* 
* Revision Ref Number  Date        Owner                               Description
* -------- ----------  ----------- -------------------                 -----------
* 1.0      RQ-001359                                                   Rewrote updateLinerBrand() method to prevent duplicate contact creation on Internal contactrecords as well as generalizing linerbrand check
* 2.0      RQ-003245   12-Apr-2016 Sunu.Paul@ust-global.com            Created this class for implementing CBO (Centralized By Org) trigger architecture.
*                                  Madhava.kotte@ust-global.com
* 3.0      RQ-003041   03-May-2016 Sandhya.Sambasivan@ust-global.com   Populate Case Country for Internal Contacts
* 4.0      RQ-004156   25-Jul-2016 Jiji@UST                            Populate Liner Brand from Lead for contacts created via lead conversion    
* 5.0      RQ-004035   29-Jul-2016 Jiji@UST                            Populate Liner Brand from contact owner.
* 6.0      RQ-002894   05-Aug-2016 Jiji@UST                            Populate Unique Email Address
* 7.0      RQ-004319   19-Aug-2016 Jiji@UST                            Removed Contact.Primary_Contact__c
* 8.0      RQ-005057   30-Mar-2017 Nisha@UST                           Deduplication done on Customer Contact, now that the Linerbrand-Email combination is not applicable for Customer Contact RT
* 9.0      RQ-007579   18-Jan-2018 Nisha@Ust                           Removed the nsp contact 'Unique Email Address' field population using the linerbrand and email combination, since all contacts are deduped
* 10.0		RQ-012372	09-03-2020	sidhartha@maersk			        Added SCPI customer group validation
* 11.0     SC-1249     10-11-2020  Sreya@Maersk                        Introducing Maersk L&S as new Brand on User Liner Brand.
* 12.0     SPI-100     17-06-2022  Ronnie@SF                           Removed brand hardcoding
* 13.0	   RQ-14006	   06-02-2024  Kusum@maersk			               Updated validateCustomerGroup()method to validate last contact that has an email address under the SCPI account cannot be removed
* 14.0     SFSE-14585  03-04-2024  Shilpa@maersk                       Logic Written to update accounts for inactive contacts based on customer code
*/

public class ContactFieldPopulator {
    
    // Method to update the Contact Record Type according to the Account Record Type when contacts are being created from publisher action.
    public static void updateRecordType(list<Contact> lstContacts, map<Id, Account> mapRelatedAccounts) {
        for(Contact newContact : lstContacts) {
            Account relatedAccount = mapRelatedAccounts.get(newContact.AccountId);
            
            if(relatedAccount != null) {
                // When Account is 'Client' or 'Concern' or 'Draft' Contact Record type is defaulted as 'Customer'.
                if(relatedAccount.Is_Client__c == true || relatedAccount.Is_Draft_Account__c == 'true' || relatedAccount.Is_Concern__c == true) {
                    if(newContact.RecordTypeId == Label.Internal_Contact_Record_Type) {
                        // Display the error message when user selects 'Client ' or 'Concern' or 'Draft' accounts on internal contact creation
                        newContact.addError(Label.AddOnlyUnassignedAccounts);
                    }
                    else {
                        newContact.RecordTypeId = Label.Customer_Contact_Record_Type;
                    }
                }
                
                // When Account is 'Unassigned' Contact Record type is defaulted as 'Internal'.
                if(relatedAccount.Is_Unassigned__c == true) {
                    newContact.RecordTypeId = Label.Internal_Contact_Record_Type;
                }
                
                // When Account is 'Non-shipping Party' Contact Record type is defaulted as 'Non-shipping Party'.
                if(relatedAccount.Is_Non_shipping_Party__c == true) {
                    if(newContact.RecordTypeId == Label.Internal_Contact_Record_Type) {
                        // Display the error message when user selects 'non-shipping' accounts on internal contact creation
                        newContact.addError(Label.AddOnlyUnassignedAccounts);
                    }
                    else {
                        newContact.RecordTypeId = Label.Non_shipping_Party_Contact_Record_Type;
                    }
                }
            }
        }
    }   
    
    // The below method is created as part of #RQ-000946. 
    // It will perform the below functions during Contact insert and update
    // 1. It will update the Contact Liner Brand field from Owner(Internal Contact Record Type and Contact created from Lead Conversion is excluded) //Ver 5.0
    // 2. It will update  Contact's Unique_Email_Address__c field
    // 3. Update Contact liner brand from lead liner brand if contact is created via Lead Conversion process. Liner Brand Text field will hold the value of Liner Brand field in Lead during Lead Conversion
    public static void updateLinerBrand(list<Contact> lstContacts, set<Id> setCreatorIds, ContactTriggerHandler conTriggerHandler) {
        if(!lstContacts.isEmpty()) {
            map<Id, String> mapUserIdLB = new map<Id, String>();
            if(!setCreatorIds.isEmpty()) {
                // Need a list of User Id's and their Liner Brands so we can default the Contact's Liner Brand if the User is single branded...
                // SC-1249 : Introduce Maersk L&S value on User Brand. Contact Brand should remain as Maersk Line.
                for(User userIterator : [SELECT Id, Liner_Brand__c FROM User WHERE Id IN :setCreatorIds]) {
                    if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLS).contains(userIterator.Liner_Brand__c)) {
                        mapUserIdLB.put(userIterator.Id, BrandUtilities.MAERSKLINE);
                    } else {
                        mapUserIdLB.put(userIterator.Id, userIterator.Liner_Brand__c);
                    }                  
                }
            }
            
            for(Contact newContact : lstContacts) {
                if(newContact.RecordTypeId == Label.Customer_Contact_Record_Type || newContact.RecordTypeId == Label.Non_shipping_Party_Contact_Record_Type) {
                    // Ver 4.0:  Start
                    if(newContact.Lead_Id__c != null && conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) { 
                        newContact.Liner_Brands__c = newContact.Liner_Brands_Text__c;
                        newContact.Liner_Brands_Text__c = newContact.Liner_Brands_Text__c + ';'; //To append ';' at the end.
                    }
                    else { // Ver 4.0:  End 
                        // Get the Liner Brand of the Contact Owner, if single branded set the Liner Brand...
                        String strLinerBrands;
                        if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                            strLinerBrands = mapUserIdLB.get(UserInfo.getUserId());
                        }
                        else if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                            strLinerBrands = mapUserIdLB.get(newContact.CreatedById);    
                        }
                        
                        // v5.0: Start
                        if(newContact.Liner_Brands__c == null && !String.isBlank(strLinerBrands) && strLinerBrands.split(';').size() == 1) {
                            newContact.Liner_Brands__c = strLinerBrands;
                        }
                        newContact.Liner_Brands_Text__c = (newContact.Liner_Brands__c != null ? (newContact.Liner_Brands__c + ';') : null);
                        // v5.0: End
                    }
                }
                //v9.0 :RQ-007579 (Removed the nsp contact Unique email address population using the linerbrand and email combination, since all contacts are deduped)            
                newContact.Unique_Email_Address__c = newContact.Email;                            
            }
        } 
    }
    
    public static void validateCustomerGroup(list<Contact> lstNewContacts, list<Contact> lstOldContacts) {
        
        Set<Id> accountIds = new Set<Id>();
        Map<id, id> oldconMap = new Map<id, id>();
        for(Contact record: lstOldContacts) {
            accountIds.add(record.AccountId);
            oldconMap.put(record.id,record.AccountId);
        }  
        
        Map<id, Integer> accContSize = new  Map<id, Integer>();
        
        for(Account acc: [select id, (select id from contacts where Email !=NULL AND Contact_Status__c = 'Active' AND Id NOT IN:lstNewContacts LIMIT 10) from account where id in :accountIds]){
            accContSize.put(acc.id, acc.contacts.size());   
			
        }	
        //The last contact that has an email address under the SCPI account cannot be removed
        for(Contact record: lstNewContacts) {
            if(accContSize.get(oldconMap.get(record.id)) == 0) {               
                record.addError(Label.CustomerGroupError);
            }
        }
                
    }
    // SFSE-14585 - Logic Written to update accounts for inactive contacts based on customer code
    @future
    public static void assignContactToAccount(List<Id> conId){
        map<String,Contact> mapOfContact = new map<String,Contact>();
        List<Account> acclisttoVerifyCustomerCode = new list<Account>();
        List<Contact> lstOfContactToUpdate = new list<Contact>();
        map<String,Account> accIds = new map<string,Account>();
        for(Contact c : [Select Id,Name,Customer_Code__c from Contact where Id In :conId]){
            mapOfContact.put(c.Customer_Code__c,c);
        }         
        for(Account acc : [Select Id,Name,Customer_Code__c From Account where Customer_Code__C In :mapOfContact.keyset()]){
            accIds.put(acc.Customer_Code__c,acc);
        }
        
        if(accIds!= null){
            for(Contact con : mapOfContact.Values()){
                if(accIds.containskey(con.Customer_Code__c)){
                    Id associatedAccount = accIds.get(con.Customer_Code__c).Id;
                    con.AccountId = associatedAccount;
                    con.Contact_Status__c = 'Active';
                    con.Customer_Code__c = '';   
                    lstOfContactToUpdate.add(con);
                }   
            }
        }
        
        if(!lstOfContactToUpdate.isEmpty()){
            try{
                Database.Update(lstOfContactToUpdate); 
            } Catch(Exception e) {
                ErrorLogger.writeErrors( 'SFDC', 'Contact', 'ContactFieldPopulator.assignContactToAccount', new list<Exception>{e});
            }
            
        }
    }
    
}