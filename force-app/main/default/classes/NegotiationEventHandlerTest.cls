/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		31-May-2023		Vazid@UST				This is a test class for NegotiationEventHandler & NegotiationEventTrigger
*/
@isTest
public class NegotiationEventHandlerTest {
	 @isTest static void testValidNegotiationEventForCreation() {
         List<Opportunity> opty = [select Id, Opportunity_Ref__c from Opportunity limit 1];
		Negotiation_Message_Event__e negotiationEvent = new Negotiation_Message_Event__e(JSON_1__c = '{\n  \"message\": {\n    \"eventType\": \"NEGOTIATION_OBJECT_CREATED\",\n    \"negotiationNumber\": \"CP-23-8018048\",\n    \"opportunityNumber\": \"OP-23-8193288\",\n    \"negotiationRoundNumber\": 1,\n    \"link\": \"dummy\",\n    \"systemSource\": \"CRM\"\n  }\n}');
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(negotiationEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    }
     @isTest static void testValidNegotiationEventForCompleted() {
         List<Opportunity> opty = [select Id, Opportunity_Ref__c from Opportunity limit 1];
		Negotiation_Message_Event__e negotiationEvent = new Negotiation_Message_Event__e(JSON_1__c = '{\n  \"message\": {\n    \"eventType\": \"ROUND_COMPLETED\",\n    \"negotiationNumber\": \"CP-23-8018048\",\n    \"opportunityNumber\": \"OP-23-8193288\",\n    \"negotiationRoundNumber\": 1,\n  \"quoteId\": \"1\",\n   \"link\": \"dummy\",\n    \"systemSource\": \"CRM\"\n  }\n}');
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(negotiationEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    }
}