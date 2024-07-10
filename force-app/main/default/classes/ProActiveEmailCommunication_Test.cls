/*
* test class for sending emails from  ProActive Email communication.
* 
*Version    Date           Owner                                      RQ#           Description
*********************************************************************************************************************************  
1.0       7/9/2021    ramadevi.palaniswamy@ust-global.com        #sc-2675      Code created.
*/
@isTest
public class ProActiveEmailCommunication_Test {
    
    public static EmailTemplate validEmailTemplate;

    @testSetup
    public static void testDataSetup(){        
        
        validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'TestTemplate';
        validEmailTemplate.DeveloperName = 'TestTemplate';
        validEmailTemplate.Body = 'test {!Case.Thread_Id}';
        validEmailTemplate.Subject = 'test {!Case.Thread_Id}';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();        
        insert validEmailTemplate;   
        
        EmailTemplate T1 = new EmailTemplate();
        T1.isActive = true;
        T1.Name = 'TestTemplate';
        T1.DeveloperName = 'TestTemplate123';
        T1.Body = 'test {!Case.Thread_Id}';
        T1.Subject = 'test {!Case.Thread_Id}';
        T1.TemplateType = 'text';
        T1.HtmlValue = 'test mail';
        T1.FolderId = UserInfo.getUserId();        
        insert T1;
        system.debug('validEmailTemplate'+validEmailTemplate);
    }
    
    public static testMethod void sendEmail(){
        //Contact Data Creation
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact  conInstance = ContactData_Test.lstContacts[0];
        
        EmailTemplate createdTemplate=[SELECT Id,Body,Subject from EmailTemplate where DeveloperName ='TestTemplate' LIMIT 1];
        
        List<ProActive_Email_Templates__c> pTempList = new List<ProActive_Email_Templates__c>();
        for(Integer i=0;i<2;i++){
            ProActive_Email_Templates__c ProEmailTemp = new ProActive_Email_Templates__c();
            ProEmailTemp.Contact__C = conInstance.Id;
            ProEmailTemp.Name = 'Spain / Loading Info / Floor & Decor';
            ProEmailTemp.Type__c = 'Prior To Booking';
            ProEmailTemp.Sub_Type__c ='Carrier forecast';
            ProEmailTemp.Reason_For_Case__c='Carrier forecast';
            ProEmailTemp.Country__c = conInstance.Country__c;
            ProEmailTemp.Case_Visibility__c = 'Multi-Carrier';
            ProEmailTemp.Product__c='SCM';
            ProEmailTemp.Brand__c = BrandUtilities.MAERSKLS;
            ProEmailTemp.Direction__c ='Export';
            ProEmailTemp.To_Email_Address__c='test@test.com';
            ProEmailTemp.CC_Email_Address__c='test@test.com';
            if(i==0){
                ProEmailTemp.Email_Template_API_Name__c=createdTemplate.Id;
            } else {
                ProEmailTemp.Email_Template_API_Name__c='Test';
            }
            pTempList.add(ProEmailTemp);
        }
        insert pTempList;        
        proActiveEmailController.getEmailTemplates('',null);//get all the templates
        proActiveEmailController.getEmailTemplates('Spain',JSON.serialize(pTempList));
        try {
        proActiveEmailController.getEmailTemplateDetails(pTempList[1].Email_Template_API_Name__c); // throw exception
        }catch(Exception e){
        system.AssertEquals('Script-thrown exception',e.getMessage());
        }
        proActiveEmailController.getEmailTemplateDetails(pTempList[0].Email_Template_API_Name__c);
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;         
        //Get Content Version
        ContentVersion cv1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];         
        //Get Content Documents
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];

        proActiveEmailController.EmailContent eCon= new proActiveEmailController.EmailContent();
        eCon.to = new List<String>{'test@test.com'};
        eCon.cc = new List<String>{'testcc@test.com'};
        eCon.subject=createdTemplate.Subject;
        eCon.bodyHTML=createdTemplate.Body;
        eCon.templateAPIName='TestTemplate';
        eCon.templateId=createdTemplate.Id;
        eCon.contactId=conInstance.Id;
        eCon.type='Prior To Booking';
        eCon.subType='Carrier forecast';
        eCon.product='SCM';
        eCon.country=conInstance.Country__c;
        eCon.reason='Carrier forecast';
        eCon.Brand = BrandUtilities.MAERSKLS;
        eCon.Direction='Export';
        eCon.caseVisibility='Multi-Carrier';
        eCon.DocIds = cd.Id;//Adding attachment
        eCon.proActiveTempId = pTempList[0].Id;
        String JSONstr = JSON.serialize(eCon); 
        
        //Upon clicking send email
        proActiveEmailController.createCaseSendEmail(JSONstr);
        
        List<Case> insertedCase = [SELECT Id, CaseNumber, ThreadId__c FROM Case WHERE Type=:pTempList[0].Type__c AND Sub_Type__c =:pTempList[0].Sub_Type__c AND Product__c=:pTempList[0].Product__c];        
        
        List<EmailMessage> emlMessage = [SELECt Id from EmailMessage where ParentId =: insertedCase[0].Id];
        
        system.AssertEquals(insertedCase.size(),1);
        
        system.AssertEquals(emlMessage.size(),1);
        
        PageReference pageRef = Page.tinymce3;
        string templateid = createdTemplate.Id;
        pageRef.getParameters().put('templateid',templateid);
        Test.setCurrentPage(pageRef); 
        Test.startTest();
        RichTextCapture richText = new  RichTextCapture();
        Test.stopTest();    
    }
    
    public static testMethod void emailInput(){
        String searchString='Customer';
        CustomPageController.search(searchString);
    }
}