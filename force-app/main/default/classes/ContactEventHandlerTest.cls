@isTest
public class ContactEventHandlerTest {
    
    @testSetup static void setup() {       
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        clientAcc.Customer_Code__c = 'VN00829521';
        update clientAcc;
        Contact CustContact = ContactDataGeneratorHelper_Test.createCustomerContact(clientAcc.Id, BrandUtilities.MAERSKLINE);
        TriggerExecutionController.skipAllTriggers(false);
    }
        
    @isTest 
    static void testValidContactEvent() {

        String json= '{'+
            '"contactEntity":{'+
            '"customerContact":{'+
            '"customerIds":{'+
            '"customerCode":"VN00829521",'+
            '"customerTradingName":"RYNAN AGRIFOODS JSC",'+
            '"customerExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800829521",'+
            '"isDeletedFlag":false'+
            '}]},'+
            '"contactCode":"VN00830768",'+
            '"contactExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800830768",'+
            '"isDeletedFlag":false'+
            '}],'+
            '"firstName":"Kieu",'+
            '"lastName":"Tran",'+
            '"isMasterContact":false,'+
      '"internationalFirstName":"Kieu",'+
      '"internationalLastName":"Tran",'+
      '"primaryEmailId":"kieu.tran@mylanprintingmedia.com",'+
      '"secondaryEmailId":null,'+
      '"statusCode":"A",'+
            '"internationalSalutationCode":null,'+
            '"primarySalutationCode":null,'+
            '"isTeamContact":false,'+
            '"jobTitle":null,'+
            '"department":null,'+
            '"role":"CUST_CONT",'+
            '"isoLanguageCodePreference":"EN",'+
      '"communicationNumbers":[{'+
            '"communicationNumberType":"TEL",'+
      '"isoCountryCode":"VN",'+
      '"internationalDialingCode":"84",'+
      '"extensionNumber":null,'+
      '"number":"2943846997"'+
      '}],'+
      '"contactBrands":[{'+
      '"brandName":"Hamburg Sud",'+
            '"brandCode":"HSUD",'+
            '"isDeletedFlag":false'+
      '}],'+
      '"contactTypes":[{'+
            '"typeName":"FINANCE",'+
      '"typeCode":"FINANCE",'+
      '"isDeletedFlag":false'+
      '},{'+
      '"typeName":"PORTAL",'+
      '"typeCode":"PORTAL",'+
      '"isDeletedFlag":false'+
            '}],'+
      '"documentPreferences":null,'+
            '"onBehalfOfRelationships":null,'+
            '"contactAuditData":{'+
            '"creationUser":"PPX003@CRB.APMOLLER.NET#1636946",'+
            '"creationDate":1565679129207,'+
            '"lastUpdateUser":"PRO154",'+
            '"lastUpdateDate":1675772947576,'+
            '"lastUpdateSourceSystem":"EXCEL"'+
      '}}}}';
        Contact_Message_Event__e contactEvent = new Contact_Message_Event__e(JSON_1__c = json);
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(contactEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    }
    
    @isTest 
    static void testValidContactEventDuplicateExternalId() {
        
        String json= '{'+
            '"contactEntity":{'+
            '"customerContact":{'+
            '"customerIds":{'+
            '"customerCode":"VN00829521",'+
            '"customerTradingName":"RYNAN AGRIFOODS JSC",'+
            '"customerExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800829521",'+
            '"isDeletedFlag":false'+
            '}]},'+
            '"contactCode":"VN00830768",'+
            '"contactExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800830768",'+
            '"isDeletedFlag":false'+
            '}],'+
            '"firstName":"Kieu",'+
            '"lastName":"Tran",'+
            '"isMasterContact":false,'+
      '"internationalFirstName":"Kieu",'+
      '"internationalLastName":"Tran",'+
      '"primaryEmailId":"kieu.tran@mylanprintingmedia.com",'+
      '"secondaryEmailId":null,'+
      '"statusCode":"A",'+
            '"internationalSalutationCode":null,'+
            '"primarySalutationCode":null,'+
            '"isTeamContact":false,'+
            '"jobTitle":null,'+
            '"department":null,'+
            '"role":"CUST_CONT",'+
            '"isoLanguageCodePreference":"EN",'+
      '"communicationNumbers":[{'+
            '"communicationNumberType":"TEL",'+
      '"isoCountryCode":"VN",'+
      '"internationalDialingCode":"84",'+
      '"extensionNumber":null,'+
      '"number":"2943846997"'+
      '}],'+
      '"contactBrands":[{'+
      '"brandName":"Hamburg Sud",'+
            '"brandCode":"HSUD",'+
            '"isDeletedFlag":false'+
      '}],'+
      '"contactTypes":[{'+
            '"typeName":"FINANCE",'+
      '"typeCode":"FINANCE",'+
      '"isDeletedFlag":false'+
      '},{'+
      '"typeName":"PORTAL",'+
      '"typeCode":"PORTAL",'+
      '"isDeletedFlag":false'+
            '}],'+
      '"documentPreferences":null,'+
            '"onBehalfOfRelationships":null,'+
            '"contactAuditData":{'+
            '"creationUser":"PPX003@CRB.APMOLLER.NET#1636946",'+
            '"creationDate":1565679129207,'+
            '"lastUpdateUser":"PRO154",'+
            '"lastUpdateDate":1675772947576,'+
            '"lastUpdateSourceSystem":"EXCEL"'+
      '}}}}';
        Contact_Message_Event__e contactEvent1 = new Contact_Message_Event__e(JSON_1__c = json);
        json = json.replace('1675772947576', '1675775047576');
        json = json.replace('Tran', 'Tran Updated');
        Contact_Message_Event__e contactEvent2 = new Contact_Message_Event__e(JSON_1__c = json);
        
        List<Contact_Message_Event__e> contactEventList = new List<Contact_Message_Event__e>();
        contactEventList.add(contactEvent1);
        contactEventList.add(contactEvent2);
        Test.startTest();
        
        // Publish test event
        Database.SaveResult[] sr = EventBus.publish(contactEventList);
        // Verify SaveResult value
        //System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
        List<Contact> contactsUpdated = [SELECT Id, LastName, External_Id__c FROM Contact WHERE External_Id__c = 'VN00830768'];
        System.debug('contactsUpdated '+contactsUpdated);
        SYstem.assertEquals(contactsUpdated[0].LastName, 'Tran Updated', 'Record updated with latest updated data');
    }
    
    @isTest 
    static void testValidContactEventWithExistedContact() {
        List<Contact> contactsUpdated = [SELECT Id, LastName, Email, External_Id__c, Liner_Brands__c FROM Contact];
        System.debug('contactsUpdated '+contactsUpdated);
        String email = contactsUpdated[0].Email;
                System.debug('email '+email);
        String json= '{'+
            '"contactEntity":{'+
            '"customerContact":{'+
            '"customerIds":{'+
            '"customerCode":"VN00829521",'+
            '"customerTradingName":"RYNAN AGRIFOODS JSC",'+
            '"customerExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800829521",'+
            '"isDeletedFlag":false'+
            '}]},'+
            '"contactCode":"VN00830768",'+
            '"contactExternalSystemIdentifiers":[{'+
            '"externalSystemName":"SCV",'+
            '"externalSystemReference":"43800830768",'+
            '"isDeletedFlag":false'+
            '}],'+
            '"firstName":"Kieu",'+
            '"lastName":"Tran",'+
            '"isMasterContact":false,'+
      '"internationalFirstName":"Kieu",'+
      '"internationalLastName":"Tran",'+
      '"primaryEmailId":"'+email+'",'+
      '"secondaryEmailId":null,'+
      '"statusCode":"A",'+
            '"internationalSalutationCode":null,'+
            '"primarySalutationCode":null,'+
            '"isTeamContact":false,'+
            '"jobTitle":null,'+
            '"department":null,'+
            '"role":"CUST_CONT",'+
            '"isoLanguageCodePreference":"EN",'+
      '"communicationNumbers":[{'+
            '"communicationNumberType":"TEL",'+
      '"isoCountryCode":"VN",'+
      '"internationalDialingCode":"84",'+
      '"extensionNumber":null,'+
      '"number":"2943846997"'+
      '}],'+
      '"contactBrands":[{'+
      '"brandName":"Hamburg Sud",'+
            '"brandCode":"HSUD",'+
            '"isDeletedFlag":false'+
      '}],'+
      '"contactTypes":[{'+
            '"typeName":"FINANCE",'+
      '"typeCode":"FINANCE",'+
      '"isDeletedFlag":false'+
      '},{'+
      '"typeName":"PORTAL",'+
      '"typeCode":"PORTAL",'+
      '"isDeletedFlag":false'+
            '}],'+
      '"documentPreferences":null,'+
            '"onBehalfOfRelationships":null,'+
            '"contactAuditData":{'+
            '"creationUser":"PPX003@CRB.APMOLLER.NET#1636946",'+
            '"creationDate":1565679129207,'+
            '"lastUpdateUser":"PRO154",'+
            '"lastUpdateDate":1675772947576,'+
            '"lastUpdateSourceSystem":"EXCEL"'+
      '}}}}';
        Contact_Message_Event__e contactEvent = new Contact_Message_Event__e(JSON_1__c = json);
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(contactEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
        contactsUpdated = [SELECT Id, LastName, Email, External_Id__c, Liner_Brands__c, Job_Role__c FROM Contact];
        System.debug('contactsUpdated '+contactsUpdated);
        System.assertEquals(contactsUpdated[0].External_Id__c, 'VN00830768', 'Existed contact record external id updated');
        //SFSE : 13939 Job_Role__c mapping is no longer getting updated from CMD
        System.assertEquals(null, contactsUpdated[0].Job_Role__c, 'Job Role is not supposed to be updated');
        System.assertNotEquals('CUST_CONT', contactsUpdated[0].Job_Role__c, 'Job Role is not supposed to be updated');
        
        
    }
    
    @isTest 
    static void testCountryUpdateOnContact(){
        Test.startTest();
        List<Contact_Message_Event__e> conList = new List<Contact_Message_Event__e>();
        Contact_Message_Event__e con1 = new Contact_Message_Event__e();
        con1.JSON_1__c = '{"contactEntity":{"customerContact":{"customerIds":{"customerCode":"VN00829521","customerTradingName":"CMD EEE TEST COMPANY SRL","customerExternalSystemIdentifiers":[{"externalSystemName":"MODS","externalSystemReference":"CMDEEET0","isDeletedFlag":false},{"externalSystemName":"SCV","externalSystemReference":"30000395191","isDeletedFlag":false}]},"contactCode":"AR00395324","contactExternalSystemIdentifiers":[{"externalSystemName":"SCV","externalSystemReference":"AR00395324","isDeletedFlag":false}],"firstName":"TEST","lastName":"AKHTAR","isMasterContact":false,"internationalFirstName":null,"internationalLastName":null,"primaryEmailId":"shanu.beckham2003@gmail.com","secondaryEmailId":null,"statusCode":"A","internationalSalutationCode":null,"primarySalutationCode":"Mr.","isTeamContact":false,"jobTitle":null,"department":null,"role":"CUST_CONT","isoLanguageCodePreference":"ES","communicationNumbers":[{"communicationNumberType":"TEL","isoCountryCode":"IN","internationalDialingCode":"91","extensionNumber":null,"number":"7975994455"}],"contactBrands":null,"contactTypes":null,"documentPreferences":null,"onBehalfOfRelationships":null,"contactAuditData":{"creationUser":"shahanawaz.akhtar@maersk.com","creationDate":1707114952252,"lastUpdateUser":"shahanawaz.akhtar@maersk.com","lastUpdateDate":1707125992449,"lastUpdateSourceSystem":"PRTL"}}}}';
        conList.add(con1);
        Contact_Message_Event__e con2 = new Contact_Message_Event__e();
        con2.JSON_1__c = '{"contactEntity":{"customerContact":{"customerIds":{"customerCode":"VN00829521","customerTradingName":"CMD EEE TEST COMPANY SRL","customerExternalSystemIdentifiers":[{"externalSystemName":"MODS","externalSystemReference":"CMDEEET0","isDeletedFlag":false},{"externalSystemName":"SCV","externalSystemReference":"30000395191","isDeletedFlag":false}]},"contactCode":"AR00395325","contactExternalSystemIdentifiers":[{"externalSystemName":"SCV","externalSystemReference":"AR00395324","isDeletedFlag":false}],"firstName":"TEST","lastName":"AKHTAR","isMasterContact":false,"internationalFirstName":null,"internationalLastName":null,"primaryEmailId":"shahanawaz.akhtar2003@yahoo.com","secondaryEmailId":null,"statusCode":"A","internationalSalutationCode":null,"primarySalutationCode":"Mr.","isTeamContact":false,"jobTitle":null,"department":null,"role":"CUST_CONT","isoLanguageCodePreference":"ES","communicationNumbers":[{"communicationNumberType":"TEL","isoCountryCode":"IN","internationalDialingCode":"91","extensionNumber":null,"number":"7975998767"}],"contactBrands":null,"contactTypes":null,"documentPreferences":null,"onBehalfOfRelationships":null,"contactAuditData":{"creationUser":"shahanawaz.akhtar@maersk.com","creationDate":1707114952252,"lastUpdateUser":"shahanawaz.akhtar@maersk.com","lastUpdateDate":1707125992449,"lastUpdateSourceSystem":"PRTL"}}}}';
        conList.add(con2);
        Database.SaveResult[] sr = EventBus.publish(conList);
        Test.stopTest();
        List<Contact> contactList = new List<Contact>([Select Id, Country__c From Contact Where External_ID__c IN ('AR00395324', 'AR00395325')]);
        Assert.areEqual(2, contactList.size(), '2 contacts should be created');
        for(Contact con : contactList){
            Assert.isTrue(con.Country__c != null, 'Country should be present.');
        }
    }
}