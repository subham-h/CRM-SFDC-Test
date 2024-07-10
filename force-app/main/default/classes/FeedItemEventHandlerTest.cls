/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Test class for FeedItemEvent trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     17-01-2024  Shahanawaz@maersk       	Create feeditem on parent Case
*/
@isTest
public class FeedItemEventHandlerTest {
    
    @isTest
    public static void testSurveyTrigger() {
        CaseData_Test.createExternalCasesAndSurveys();
        
        Survey__c sur = [Select Id, Case__c From Survey__c LIMIT 1];
        
        List<Feed_Item_Event__e> feedItemEvtList = new List<Feed_Item_Event__e>();
        Feed_Item_Event__e fItemEvt = new Feed_Item_Event__e();
        fItemEvt.Record_Id__c = sur.Id;
        fItemEvt.Parent_Id__c = sur.Case__c;
        fItemEvt.Object_Name__c = 'Survey';
        feedItemEvtList.add(fItemEvt);
        Test.startTest();
        EventBus.publish(feedItemEvtList);
        Test.stopTest();
    } 
    
}