/*  
* Version	Date			#Reference				Owner					Description
1.0         17-04-2024      SFSE-11169              Sunil.bs                Test class to cover Getting opportunity score from GDA and updating on the SF field
*/
@istest
public class OpportunityScoringEvent_Test {    
    static{
        TriggerExecutionController.skipAllTriggers(true); 
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        Account clientAcc =TestBusinessHelper.createAccount('Client_Account', true);
        Contact customerContact = TestBusinessHelper.createContact(clientAcc, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Opportunity standardOpportunity =  TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity opportunity2 = [SELECT Id, Liner_Brand__c, OwnerId, CreatedById FROM Opportunity];
        TriggerExecutionController.skipAllTriggers(false);
    }
    
	/**
	* @description | Test the method which Reads and updates opportunity score flowing from GDA via events
	* SFSE-11169
	*/
    public static testmethod void testOpportunityScoreEvent(){
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);		
        Opportunity opportunityInst = [select id,opportunity_score__c from opportunity limit 1];
        Opportunity_Scoring_Event__e evt=new Opportunity_Scoring_Event__e();
        //Event data flowing from GDA
        evt.Json_1__c='{\"winProbablity\":\"30\",\"opportunityIdentifier\":\"'+opportunityInst.id+'\"}';
        Database.SaveResult results = EventBus.publish(evt);
        Test.stopTest();
        Opportunity opportunityInst2 = [select id,opportunity_score__c from opportunity limit 1];
        //Check if score is updated properly
        Assert.areequal(30,opportunityInst2.Opportunity_Score__c,'Expected values are not matching');
        TriggerExecutionController.skipAllTriggers(false);
    }
    
}