/*
* test class ProActive Email Template Module.
* 
 Date        Owner                         Description
*********************************************************************************************************************************  
18/2/2022    kusum.jha@maersk.com          Code created.
18/2/2022    kusum.jha@maersk.com          testCreateProActiveEmailTemplate : testing creation of a new ProActive email Template .
18/2/2022    kusum.jha@maersk.com          testCreateCaseByProActiveEmailTemplate : testing creation of a case using ProActive Email Email Template.
18/2/2022    kusum.jha@maersk.com          testReopenProActiveEmailTemplateCase : testing reopening the created case using ProActive Email Email Template.
*/

@isTest 
public class ProActiveEmailTemplateTest {
    
    public static EmailTemplate validEmailTemplate;

    @testSetup
    public static void testDataSetup(){        
        Test.startTest();
        validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'TestTemplate';
        validEmailTemplate.DeveloperName = 'TestTemplate';
        validEmailTemplate.Body = 'test {{{!Case.Thread_Id}}}';
        validEmailTemplate.Subject = 'test {{{!Case.Thread_Id}}}';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();        
        insert validEmailTemplate;   
        Test.stopTest();
    }
    
    @isTest 
    public static void testCreateProActiveEmailTemplate()         
    {    
        //create contact & Email Template
        Contact  conInstance = TestDataFactoryHelper.createContactRecord(); 
        Test.startTest();
        EmailTemplate createdTemplate=[SELECT Id,Body,Subject from EmailTemplate where DeveloperName ='TestTemplate' LIMIT 1];
        
        //create Proactive email template
        List<ProActive_Email_Templates__c>  listProTemp= TestDataFactoryHelper.createProActiveEmailTemplate( conInstance,createdTemplate);
        insert listProTemp[0];
        
        //get all the templates
        proActiveEmailController.getEmailTemplates('',null);
        proActiveEmailController.getEmailTemplates(listProTemp[0].Name,JSON.serialize(listProTemp));
        try {
            
             proActiveEmailController.getEmailTemplateDetails(listProTemp[1].Email_Template_API_Name__c);
        
        }catch(Exception e)
        {
        
            system.AssertEquals('Script-thrown exception',e.getMessage(),'Email template creation failed');
        }
        
        proActiveEmailController.getEmailTemplateDetails(listProTemp[0].Email_Template_API_Name__c);
        
        //query created proactive email template
        List<ProActive_Email_Templates__c> listCreatedProActiveEmailTemp  = [SELECT Id, Name, CreatedById , OwnerId, Email_Template_API_Name__c, To_Email_Address__c, 
                                                       CC_Email_Address__c, Type__c, Sub_Type__c, Reason_For_Case__c, 
                                                       Product__c, Contact__c, ReplyTo_Email_Address__c, Country__c, Case_Visibility__c,Times_Used__c,Last_used_on__c,On_Behalf_of_Account__c 
                                                        FROM ProActive_Email_Templates__c WHERE Id=:listProTemp[0].Id];
        Test.stopTest();
        //test whether the Proactive email template is created or not.  
        System.assertEquals(listCreatedProActiveEmailTemp.size(), 1,'Email template created');
        System.assertEquals(listCreatedProActiveEmailTemp[0]. CreatedById , listCreatedProActiveEmailTemp[0].OwnerId,'Created by Id equal to Owner Id');
        system.AssertEquals('Pro Active Email Template Testing Module',listCreatedProActiveEmailTemp[0].Name,'Name Matched Successfully');
        system.AssertEquals(createdTemplate.Id, listCreatedProActiveEmailTemp[0].Email_Template_API_Name__c,'EMail template id matched');
        system.AssertEquals('testba@test.com', listCreatedProActiveEmailTemp[0].ReplyTo_Email_Address__c, 'Reply to Email Address Matched');
        
    }
    
    @isTest 
    public static void testCreateCaseByProActiveEmailTemplate()
    {
       
            //create contact, email template and proactive email template
            Contact  conInstance = TestDataFactoryHelper.createContactRecord(); 
            Test.startTest();
            EmailTemplate createdTemplate=[SELECT Id, Body, Subject from EmailTemplate where DeveloperName ='TestTemplate' LIMIT 1];
        	List<ProActive_Email_Templates__c>  listProTemp= TestDataFactoryHelper.createProActiveEmailTemplate( conInstance,createdTemplate);
            //create pro active email  case
            TestDataFactoryHelper.createProActiveCase(conInstance ,createdTemplate);
            
            //query created proactive case and email
            List<Case> lstInsertedCase = [SELECT Id, ClosedDate, CreatedDate, CaseNumber,Case_Channel__c,Status, ThreadId__c FROM Case];     
        	List<EmailMessage> lstEmlMessage = [SELECt Id from EmailMessage where ParentId =: lstInsertedCase[0].Id];
	        Test.stopTest();
            //test created proactive case and email 
            system.AssertEquals(lstInsertedCase.size(),1,'case created');        
            system.AssertEquals(lstEmlMessage.size(),1, 'Email message created');
            system.AssertEquals('Proactive', lstInsertedCase[0].Case_Channel__c,'Case channel updated');
            system.AssertEquals('Closed - Resolved',lstInsertedCase[0].Status,'Case Status updated');
            System.assert(lstInsertedCase[0].CreatedDate== lstInsertedCase[0].ClosedDate,'Close Date check passed');
                     
        
    }
}