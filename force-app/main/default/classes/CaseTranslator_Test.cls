@isTest
public  class CaseTranslator_Test {
    @testSetup
    public static void setup(){
        Shipment__c ship = TestBusinessHelper.createShipment('224069341', false);
        ship.Id = null;
        insert ship;
        
        Geography__c geography = TestBusinessHelper.createGeography('Japan', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
    }
   
    @isTest
    public static void testFeedTranslateAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Language='ja';
        cs.Delivery_Channel__c='MaerskGo';
        insert cs;
        Test.startTest();
        Case csObj=[Select id,Delivery_Channel__c,Case_Country__c from case limit 1];
        system.debug(csObj);
        Test.setMock(HttpCalloutMock.class, new CaseTranslatorMock());
        FeedItem feed = new FeedItem();
        feed.ParentId = csObj.Id;
        feed.Body ='Could you please help in resolving the case';
        insert feed;
        Test.stopTest();        
    }
    @isTest
    public static void testFeedTranslateNegativeResponseAPI(){
        Account acc = [Select Id, Country__c From Account LIMIT 1];
        Contact con = [Select Id, Country__c From Contact LIMIT 1];
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Language='ja';
        cs.Delivery_Channel__c='MaerskGo';
        insert cs;
        Test.startTest();
        Case csObj=[Select id,Delivery_Channel__c,Case_Country__c from case limit 1];
        system.debug(csObj);
        FeedItem feed = new FeedItem();
        feed.ParentId = csObj.Id;
        feed.Body ='Could you please help in resolving the case';
        insert feed;
        Test.stopTest();        
    }
}