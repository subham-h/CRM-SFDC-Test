/**
 * Author   : Partha               
 * Purpose  : Test class for CaseClassificationMatrixController_test
 *
 * Revision Ref Number  Date         Owner                  Description
 * -------- ----------  -----------  -------------------    -----------
 * 1.0      RQ-009759   22-Jan-2019  Partha                 Created.
 * 2.0      SPI-100     07-Jun-2022  Ronnie@SF              Removed brand hardcoding 
 * 3.0      SC-6307		06-Nov-2022	 Nayana@Maersk			Test method for Case classification requirement 
 */

@isTest
private class  CaseClassificationMatrixController_test {
    
    @testSetup
    static void testDataSetup() {         
        
        System.runAs(new User(Id=UserInfo.getUserId())){
        Test.startTest();
        EmailTemplate validEmailTemplate = new EmailTemplate();
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
        
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        list<Case> lstCases = CaseData_Test.lstCases;
        list<Case> lstUpdateCase = new list<Case>();
        
        for(Case newCase : lstCases ) {
            /*newCase.Status ='Closed - Resolved';
            newCase.Resolution_Summary__c = 'Resolved'; 
            newCase.Send_Case_Closure__c ='Yes';*/
            newCase.type='Booking';
            newCase.Sub_Type__c='New Booking Request'; 
            newCase.Reason_For_Case__c = 'Booking Request';
            newCase.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            newCase.Country__c = BDAGeographyData_Test.countryRU.Id;
            newCase.Security_Code__c = '1235';
            lstUpdateCase.add(newCase);
            
        }
        update lstUpdateCase;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript tx = new LiveChatTranscript(
            chatKey = '123',
            liveChatVisitorId = visitor.id,caseId = lstUpdateCase[0].Id
        );            
		insert tx;       
                       
    }
    
    static testMethod void  testCaseSurvey(){
        
        Case testCase = [SELECT Id,Status FROM Case limit 1][0]; 
        LiveChatTranscript testChatTranscript = [SELECT Id,CaseId from LiveChatTranscript LIMIT 1];
        
        Test.startTest(); 
        
        List<Case_Classification_Matrix__mdt> ccmdt=CaseClassificationMatrixController.readClassificationMatrix();        
        Map<string,object> caseRecord = new Map<string,object>();
        caseRecord.put('Status',testCase.Status);
        
        CaseClassificationMatrixController.LiveChatClassificationWrap chatMDT = CaseClassificationMatrixController.readChatTranscriptClassification(testChatTranscript.Id,'LiveChatTranscript');        
        System.assertEquals(chatMDT.chatCaseId,testChatTranscript.CaseId);
        
        Test.stopTest();                
    }    
    
}