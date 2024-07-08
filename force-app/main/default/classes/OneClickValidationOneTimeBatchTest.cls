@isTest
public class OneClickValidationOneTimeBatchTest {
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Account acc = TestBusinessHelper.createAccount(user1, geoCountry, 'Client_Account', true);
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact','MaerskLine', true);
        List<String> recTypes = new List<String>{'Quarterly_Deal', 'ShippingCargoServices', 'Supply_Chain_Services','Quarterly_Deal' , 'ShippingCargoServices',  'Supply_Chain_Services', 'Quarterly_Deal' , 'ShippingCargoServices'};
        List<Opportunity> oppList = TestBusinessHelper.createOpportunities(acc,con, user1, recTypes ,'MaerskLine', true);
        
        for(Opportunity opp : oppList){
        opp.Offer_Type__c = 'Offer containing Standard T&Cs';
        opp.Qualify_OneClick_Journey__c = false;
        update opp;
        }
    }
    @isTest
    public static void TestOneClick(){  
        Test.startTest();
        List<Opportunity> opplst = [Select Id from Opportunity WHERE IsClosed = false AND Offer_Type__c = 'Offer containing Standard T&Cs' AND First_Shipment_Date__c != null AND Last_Shipment_Date__c != null AND Must_Go_To_OMEB__c = false];
        database.executeBatch(new OneClickValidationOneTimeBatch());  
        Test.stopTest();       
       
    }
}