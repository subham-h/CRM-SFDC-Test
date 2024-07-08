@isTest
global class instantDOAPIControllerTest {
    
        
    @isTest static void testgetBOLNumber() {
        //Case Data creation
        CaseData_Test.bCreate = true;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        List<Case> listCase = CaseData_Test.lstCases;
        listCase[0].Product__c = 'Ocean';
        listCase[0].Type = 'Cargo/Container';
        listCase[0].Sub_Type__c = 'Delivery Order/Container Release';
        
        
        update listCase;
        TriggerExecutionController.skipAllTriggers(false);
        
      
       // List<case>listCase = [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Cargo/Container' AND Sub_Type__c = 'Delivery Order/Container Releaset'];
        Agent_Workflow__c AW1 = new Agent_Workflow__c( ReleaseFromDateTime__c = system.now(),DeliveryFromDateTime__c = SYSTEM.now() ,OwnerId = userinfo.getUserId(),B_L_number__c = '123456', Run_Instant_DO__c = true, Status__c = 'Request Submitted',Sender_Email__c = 'test@test.com',Case_ID__c = listCase[0].Id );
        insert AW1;
        
        instantDOAPIComponentController objINDC = new instantDOAPIComponentController();
        instantDOAPIComponentController.getBOLNumber(AW1.Id);
        
        string str = '{ "customerCode": "10000007951", "capacity":"UNKNOWN", "carrierCode": "MAEU",  "deliveryOrderId": null,    "salesForceCaseId": null,   "salesForceCaseNumber": null,   "importServiceMode": "CY","haulageInstructions":[{"haulageOrderValidityDetails":{"releaseFromDate":[]},"DeliveryStops":[{"deliveryFromDateTimeLocal":""}]}]}';
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Instant_DO_Payload',
            PathOnClient   = 'Instant_DO_Payload.json',
            VersionData    = blob.valueOf(str),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = AW1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        
        insert cdl;
          Test.startTest();
         Test.setMock(HttpCalloutMock.class, new DO_PostDOHttpCalloutMock()); 
        
        
        instantDOAPIComponentController.postInstantDO(AW1.Id, AW1.B_L_number__c);
        //instantDOAPIComponentController.getInstantDOStatus(AW1.B_L_number__c, 'asas', 'asas', 'sas');
        instantDOAPIComponentController.rejectWorkflow(AW1.Id, listCase[0].Id, AW1.OwnerId);
        instantDOAPIComponentController.updateWorkflowNParent(AW1.id, listCase[0].Id, true, AW1.OwnerId);
        instantDOAPIComponentController.updateWorkflowNParent(AW1.Id, listCase[0].Id, false, AW1.OwnerId);
        Test.stopTest();
    } 
    
   @isTest static void testgetBOLNumber1() {
        //Case Data creation
        CaseData_Test.bCreate = true;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();
        List<Case> listCase = CaseData_Test.lstCases;
        listCase[0].Product__c = 'Ocean';
        listCase[0].Type = 'Cargo/Container';
        listCase[0].Sub_Type__c = 'Delivery Order/Container Release';
        
        
        update listCase;
        TriggerExecutionController.skipAllTriggers(false);
        
      
       // List<case>listCase = [ SELECT id,OwnerId,Status,Resolution_Summary__c FROM Case WHERE Type = 'Cargo/Container' AND Sub_Type__c = 'Delivery Order/Container Releaset'];
        Agent_Workflow__c AW1 = new Agent_Workflow__c( ReleaseFromDateTime__c = system.now(),DeliveryFromDateTime__c = SYSTEM.now() ,OwnerId = userinfo.getUserId(),B_L_number__c = '123456', Run_Instant_DO__c = true, Status__c = 'Request Submitted',Sender_Email__c = 'test@test.com',Case_ID__c = listCase[0].Id );
        insert AW1;
        
        instantDOAPIComponentController objINDC = new instantDOAPIComponentController();
        instantDOAPIComponentController.getBOLNumber(AW1.Id);
        
        string str = '{ "customerCode": "10000007951", "capacity":"UNKNOWN", "carrierCode": "MAEU",  "deliveryOrderId": null,    "salesForceCaseId": null,   "salesForceCaseNumber": null,   "importServiceMode": "CY","haulageInstructions":[{"haulageOrderValidityDetails":{"releaseFromDate":[]},"DeliveryStops":[{"deliveryFromDateTimeLocal":""}]}]}';
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Instant_DO_Payload1',
            PathOnClient   = 'Instant_DO_Payload1.json',
            VersionData    = blob.valueOf(str),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = AW1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        
        insert cdl;
          Test.startTest();
         Test.setMock(HttpCalloutMock.class, new DO_PostDOHttpCalloutMock()); 
        
        
        instantDOAPIComponentController.postInstantDO(AW1.Id, AW1.B_L_number__c);
        //instantDOAPIComponentController.getInstantDOStatus(AW1.B_L_number__c, 'asas', 'asas', 'sas');
        instantDOAPIComponentController.rejectWorkflow(AW1.Id, listCase[0].Id, AW1.OwnerId);
        instantDOAPIComponentController.updateWorkflowNParent(AW1.id, listCase[0].Id, true, AW1.OwnerId);
        instantDOAPIComponentController.updateWorkflowNParent(AW1.Id, listCase[0].Id, false, AW1.OwnerId);
        Test.stopTest();
    } 
    
   
}