/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public  class OpportunityEventBatchTest {

    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        List<String> family1 = new List<String>{'Landside Transportation','Contract Logistics'};
        List<Product2> prod = TestBusinessHelper.createProducts(family1, 2, true);
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        Geography__c geoCountry = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c geoState = TestBusinessHelper.createGeography('Arizona', 'State', geoCountry.Id, true);
        Geography__c geoCity = TestBusinessHelper.createGeography('  Phoenix', 'City', geoState.Id, true);
        Account acc = TestBusinessHelper.createAccount(user1, geoCountry, 'Client_Account', true);
        Contact con = TestBusinessHelper.createContact(acc, 'Customer_Contact','MaerskLine', true);
        Opportunity opp = TestBusinessHelper.createOpportunity(acc, con, user1,'Supply_Chain_Services','MaerskLine', true);
        List<Trade_Route__c> traderoutes = TestBusinessHelper.createTradeRoutes(new List<String>{'MSL'}, 1, true);
        Opportunity_Product__c op = TestBusinessHelper.createOpportunityLineItemCustom(opp, prod[1].Id, traderoutes[0], geoCountry, geoState, true);
    }


    @isTest
    public static void testDailyBatch(){  
        Test.startTest();
        OpportunityEventBatch be = new OpportunityEventBatch( 'sync - daily', new set<Id>{});
        database.executeBatch(be,1);
        Test.stopTest();       
    }

    @isTest
    public static void testMonthlyBatch(){  
        Test.startTest();
        OpportunityEventBatch be = new OpportunityEventBatch( 'sync - monthly', new set<Id>{});
        database.executeBatch(be,1);
        Test.stopTest();       
    }

    @isTest
    public static void testLiveBatch(){  
        Test.startTest();
        Opportunity opp = [SELECT id FROM Opportunity limit 1];
        OpportunityEventBatch be = new OpportunityEventBatch( 'live',new set<Id>{opp.Id});
        database.executeBatch(be,1);
        Test.stopTest();       
    }


    @isTest
    public static void testScheduleMethod(){  
        Test.startTest();
        System.schedule('OpportunityEvent sync Monthly 1', '0 0 23 * * ?' , new Opportunity_Event_Scheduler('sync - monthly'));
        Test.stopTest();       
    }
    
    @isTest
    public static void testScheduleMethodClosedOpportunity(){  
        Test.startTest();
        TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity opp = [SELECT id,StageName,Offer_Type__c FROM Opportunity where name='Supply_Chain_Services' limit 1];
        opp.StageName='Closed Won';
        opp.Offer_Type__c='Offer containing Standard T&Cs';
        update opp;
        TriggerExecutionController.skipOpportunityTrigger(false);
       
        
        System.schedule('OpportunityEvent sync Monthly 2', '0 0 23 * * ?' , new Opportunity_Event_Scheduler('sync - monthly closed'));
        Test.stopTest();       
    }

    @isTest
    public static void testMonthlyBatchClosed(){  
        Test.startTest();
        TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity opp = [SELECT id,StageName,Offer_Type__c FROM Opportunity where name='Supply_Chain_Services' limit 1];
        opp.StageName='Closed Won';
        opp.Offer_Type__c='Offer containing Standard T&Cs';
        update opp;  
        TriggerExecutionController.skipOpportunityTrigger(false);

        ClosedOpportunityEventBatch be = new ClosedOpportunityEventBatch('sync - monthly' );
        database.executeBatch(be,1);

        Test.stopTest(); 
    }
    
}