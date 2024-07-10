/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0       25-March-2024   Samar@Maserk.com      Trigger to update Negotiation with Quote Information from CoPo
*/
@isTest
public class NegotiationRoundEventHandlerTest {
 @testSetup static void setup() {
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        insert clientAccount;
        Opportunity opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opportunity.Id = null;
        opportunity.Requires_IT_Integration__c = 'Yes, I am sure this is required basis my discussion with customer';
        TriggerExecutionController.skipOpportunityTrigger(true);
        insert opportunity;
        TriggerExecutionController.skipOpportunityTrigger(false);
    }
	
     @isTest static void testValidNegotiationEventForCompleted() {
         List<Opportunity> opty = [select Id, Opportunity_Ref__c from Opportunity limit 1];
         Quotes__c quoteRec = new Quotes__c();
         quoteRec.Status__c = 'Negotiation in Progress';
         quoteRec.Negotiation_Id__c = '1';
         quoteRec.Negotiation_Id__c= '123456789';
         quoteRec.Collaboration_Portal_Link__c = 'dummy';
         quoteRec.Opportunity__c = opty[0].Id;
         Insert quoteRec;
         Negotiation_Round_Event__e negotiationEvent = new Negotiation_Round_Event__e(JSON_1__c='{"header":{"eventNotificationName":"NegotiationRoundStatusEvent","version":"v1","system":"NAAS","eventTimestamp":1712315009523,"messageId":"7de46e10-8ad3-4993-ae35-0712edcc9bf6","correlationId":null},"message":{"productFlow":"ocean","masterFlow":"p2q","businessProcess":["instantQuote"],"negotiationRoundStatus":"FINALISED","statusDescription":"Negotiation round finalized","opportunityNumber":\"'+ opty[0].Opportunity_Ref__c+
										'\","AgreementNumber":"123456789","negotiationRoundNumber":"1","negotiationInstruments":[{"negotiationInstrumentReference":"cca6000b-006c-43a3-b5f6-901f313e6bbb","instrumentGroupReference":null,"negotiationInstrumentDomain":"Athena","negotiationInstrumentType":"Rate Output","negotiationInstrumentStatus":"Active","negotiationDetailOutputReference":"https://ath-container-interface.cdt.maersk-digital.net/athena/v1/assemblerfiles/MaerskQuote_CP-0007435_1.xlsx?opportunityId=/OP-24-8036058"}]}}');
		 Test.startTest();
         
        // Publish test event
        Database.SaveResult sr = EventBus.publish(negotiationEvent);
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());

        Test.stopTest();
    }
}