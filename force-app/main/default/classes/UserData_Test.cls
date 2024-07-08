/**
 * Author   : Hitha
 * Purpose  : Utility test class for creating User related test data. 
 *
 * Revision Ref Number  Date         Owner                   Description
 * -------- ----------  -----------  -------------------     -----------
 * 1.0      RQ-004366   09/01/2017   Hitha@UST               Created.
 * 2.0      RQ-012996   24/01/2020   Rakesh@ maersk          Change Customer User License
 * 3.0      SPI-100     08/06/2022   Ronnie@SF               Removed brand hardcoding
 * 4.0      SPI-100     23/09/2022   Ronnie@SF               Removed brand hardcoding
 * 5.0                  14-Nov-2022  Ronnie@SF               Removed testMethod from method definitions
 */
 
@isTest
public class UserData_Test {

    public static boolean bCreate = true;
    public static integer iNumberOfUsers = 5;
    public static List<User> lstUsers;
    public static Contact conInstance = null;
    public static List<Contact> lstContact = new List<Contact>();
    
    public static List<User> createCustomerusers() {
        ContactData_Test.iNumberOfContacts = iNumberOfUsers;
        ContactData_Test.createCustomerContacts();
        lstContact = ContactData_Test.lstContacts;
        Integer i=0;
        
        populateCommonUserFields();        
        System.runAs(new User(Id=UserInfo.getUserId())){ 
        Id profileId = [SELECT Id FROM Profile WHERE Name = '101 - Customer Service & Sales (Pilot)'].Id; 
        for(User userIterator : lstUsers) {
            userIterator.LastName = 'Customer' + Math.random();
            userIterator.CM_Visibility__c = 'Single Carrier';
            userIterator.profileid = profileId;
            // userIterator.contactId = lstContact[i].Id;
            i++;             
        }
       
        if(bCreate) {
            insert lstUsers;
            
        }
    }
        
        Environment_Variables__c env = new Environment_Variables__c();
        env.Name = 'Community License Type';
        env.Value_String__c = 'Login';
        insert env;
        return lstUsers;
    }
    
    public static List<User> createCommunityUsers() {
        ContactData_Test.iNumberOfContacts = iNumberOfUsers;
        ContactData_Test.createCustomerContacts();
        lstContact = ContactData_Test.lstContacts;
        Integer i=0;
        Environment_Variables__c env = new Environment_Variables__c();
        env.Name = 'Community License Type';
        env.Value_String__c = 'Login';
        insert env;
        populateCommonUserFields();        
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = '501 - Customer Community User'].Id;  //RQ-012996
        for(User userIterator : lstUsers) {
            userIterator.LastName = 'Community' + Math.random();
            userIterator.profileid = profileId;
            userIterator.contactId = lstContact[i].Id;
            i++;             
        }
        if(bCreate) {
            insert lstUsers;
        }
        return lstUsers;
    }
    
    public static User createUsersForChat() {
        Geography__c geo = new Geography__c();
        geo.Name = 'India';
        geo.Active__c = true;
        geo.GEO_ID__c = '10Z2W9ZTH2RUM';
        geo.GEO_Code__c = 'IN';
        geo.Type_Of_Location__c = 'Country';
        insert geo;
                
        Id profileId = [select id from profile where name='102 - Customer Service'].id;  //RQ-012996
        User userIterator = new User();
        userIterator.FirstName = 'Test';
        userIterator.LastName = 'User';
        userIterator.alias = 'tstUser';
        userIterator.ProfileId = profileId;
        // fix on production validation error, changed the email domain to maersk.com
        userIterator.email='ContactData_Test'+ '@maersk.com';
        userIterator.TimeZoneSidKey = 'America/Los_Angeles';
        userIterator.LocaleSidKey = 'en_US';
        userIterator.LanguageLocaleKey = 'en_US';
        userIterator.EmailEncodingKey = 'UTF-8';
        userIterator.country='India';
        userIterator.IsActive =true;
        //userIterator.Quoting_Tool__c='AFLS';
        userIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        userIterator.MLL__C = True;
        userIterator.Cluster__c='Central America, Andina, Caribbean';
        userIterator.username='userinstance'+'@noemail.com';
        userIterator.CM_Visibility__c = 'Single Carrier';
        return userIterator;
    }
    
    public static User createUser() {
        Id profileId = [select id from profile where name='System Administrator'].id;  //RQ-012996
        User userIterator = new User();
        userIterator.FirstName = 'Automated';
        userIterator.LastName = 'Process';
        userIterator.alias = 'tstUser';
        userIterator.ProfileId = profileId;
        // fix on production validation error, changed the email domain to maersk.com
        userIterator.email='ContactData_Test'+ '@maersk.com';
        userIterator.TimeZoneSidKey = 'America/Los_Angeles';
        userIterator.LocaleSidKey = 'en_US';
        userIterator.LanguageLocaleKey = 'en_US';
        userIterator.EmailEncodingKey = 'UTF-8';
        userIterator.country='UNITED STATES';
        userIterator.IsActive =true;
        //userIterator.Quoting_Tool__c='AFLS';
        userIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        userIterator.MLL__C = True;
        userIterator.Cluster__c='Central America, Andina, Caribbean';
        userIterator.username='userinstance'+'@noemail.com';
        //userIterator.CM_Visibility__c = 'Single Carrier';
        return userIterator;
    }
    
    private static void populateCommonUserFields() {
        lstUsers = new list<User>();
        if(lstContact != null && !lstContact.isEmpty()){            
            for(integer i=0; i<iNumberOfUsers; i++) {    
                User userIterator = new User();
                userIterator.alias = 'tstUser'+i;
                // fix on production validation error, changed the email domain to maersk.com
                userIterator.email='ContactData_Test' + i+ '@maersk.com';
                userIterator.TimeZoneSidKey = 'America/Los_Angeles';
                userIterator.LocaleSidKey = 'en_US';
                userIterator.LanguageLocaleKey = 'en_US';
                userIterator.EmailEncodingKey = 'UTF-8';
                userIterator.country='UNITED STATES';
                userIterator.IsActive =true;
                //userIterator.Quoting_Tool__c='AFLS';
                userIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                userIterator.MLL__C = True;
                userIterator.Cluster__c='Central America, Andina, Caribbean';
                userIterator.username='userinstance'+ i +'@noemail.com';
                lstUsers.add(userIterator);
                i=i+1;
            }       
        }
    }
}