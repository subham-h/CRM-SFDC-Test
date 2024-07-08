@isTest
public class AzureRequestClassTest {
    
    static testmethod void testAzureCallout(){  
        
        List<User>userList=new List<User>();
        Id profileId = [select id from profile where name='System Administrator'].id;
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
        
        userList.add(userIterator);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockClass());
        AzureRequestClass.AzureDisableUsersByEmail(userList);
        test.stopTest();
        
    }  
}