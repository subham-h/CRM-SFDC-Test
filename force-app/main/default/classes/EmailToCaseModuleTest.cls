/*
* test class Email to Case Module.
* 
 Date        Owner                         Description
*********************************************************************************************************************************  
3/1/2022    kusum.jha@maersk.com          Code created
3/1/2022    kusum.jha@maersk.com          testEmailSendingToBA : send email to BA to create case
3/2/2022    kusum.jha@maersk.com          testCaseDetailsValidation : validate the case created via email 
3/2/2022    kusum.jha@maersk.com          testCaseClosure : close the case created via email
3/2/2022    kusum.jha@maersk.com          testReopenCase : reopen the case created via email
*/
@isTest
public class EmailToCaseModuleTest {
    
    @isTest
    public static void testEmailSendingToBA()
    {
        //sending email to BA to create case
        Messaging.InboundEmailResult result = TestDataFactoryHelper.sendEmailToBA();
        Test.startTest();
        //Testing the mail is sent or not to BA 
        System.assertEquals( result.success , true);
        Test.stopTest();
     }
    
    @isTest
    public static void testCaseDetailsValidation()
    {
        
            //sending email to BA to create case
            Messaging.InboundEmailResult result = TestDataFactoryHelper.sendEmailToBA();
            Test.startTest();
            //quering the created case
            List<Case> lstCases = [select id, Country__c, Origin ,Product__c, OwnerId, case_channel__C,Liner_Brand__c,status,Direction__c, type from case];
            Test.stopTest();   
            //testing the created case
            System.assertEquals(lstCases.size(), 5,'5 cases created');
            system.assertEquals('Triaged', lstCases[0].Status,'Status is triaged');
            system.assertEquals('Email',lstCases[0].Case_Channel__c,'Case channel is email');
       
    }
    
    @isTest
    public static void testCaseClosure()
    {
            //sending email to BA to create case
            Messaging.InboundEmailResult result = TestDataFactoryHelper.sendEmailToBA();
            Test.startTest();
            //quering the created case
            List<Case> lstCases = [select id from case];
                
            //closing the created case
            TestDataFactoryHelper.closeEmailToCase(lstCases[0]);           
                
            //query the closed case
            List<Case> lstUpdatedCases = [select id,Status,Duration_Of_Case_Closed_first_time__c,ClosedDate from case where id in: lstCases];
            Test.stopTest();  
            //testing closing of case csat is sent validation
            system.assertEquals('Closed - Not a case',lstUpdatedCases[0].Status,'status is closed not a case');
            System.assertNotEquals(null, lstUpdatedCases[0].ClosedDate,'closed date is not null');
            System.assertNotEquals(null, lstUpdatedCases[0].Duration_Of_Case_Closed_first_time__c,'duration of case closed first time is not null');
               
    }
    
    @isTest
    public static void testReopenCase()
    {
       
            //sending email to BA to create case
            Messaging.InboundEmailResult result = TestDataFactoryHelper.sendEmailToBA();
            Test.startTest();      
            //quering the created case
            List<Case> lstCases = [select id from case];
            
            //reopened the case
            TestDataFactoryHelper.reopenEmailToCase(lstCases[0]);
                
            //query the case
            List<Case> lstReopenedcases = [select id, Status,Case_Reopened__c,Case_Reopened_Date_Time__c, ClosedDate from case where id in: lstCases];
            Test.stopTest();   
            //testing closing of case csat is sent validation
            system.assertEquals('In Progress',lstReopenedcases[0].Status,'status is in progress');
            System.assertEquals(null, lstReopenedcases[0].ClosedDate,'closed date is null');
        
            
    }
    
}