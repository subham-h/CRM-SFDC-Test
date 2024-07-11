@isTest
public class EmailToCaseAutomationControllerTest {
    @testSetup
    public static void setup(){
        Zippex sampleZip = new Zippex();
        Blob groupData = Blob.valueOf('Name \n Customer Service1 - SCM - Puma - UK');
        sampleZip.addFile('E2C Package/Groups.csv', groupData, null);
        
        Blob queueData = Blob.valueOf('Queue Name,Group Name,CM BA Address \n Test SCM - Puma - United Kingdom,Customer Service1 - SCM - Puma - UK,testpuma.gb@lns.maersk.com');
        sampleZip.addFile('E2C Package/Queues.csv', queueData, null);
        
        Blob originData = Blob.valueOf('CaseOrigin \n SCMTest1');
        sampleZip.addFile('E2C Package/Origins.csv', originData, null);
        
        Blob roleData = Blob.valueOf('Name,ParentRole \n SCM Puma - United Kingdom - Front Line,SCM Key Client');
        sampleZip.addFile('E2C Package/Roles.csv', roleData, null);
        
        Blob listViewData = Blob.valueOf('Name,Criteria,Filter Logic,Column,Group,Role,Portal Role,Portal Role Subordinates,Role and Subordinates,Role and Subordinates Internal \n Test SCM - Puma - United Kingdom,Liner_Brand__c-equals-MCC,1 AND 2,CASES.ORIGIN;Liner_Brand__c,Customer Service1 - SCM - Puma - UK,SCM Puma - United Kingdom - Front Line,SCM Puma - United Kingdom - Front Line,SCM Puma - United Kingdom - Front Line,SCM Puma - United Kingdom - Front Line,SCM Puma - United Kingdom - Front Line');
        sampleZip.addFile('E2C Package/ListViews.csv', listViewData, null);
        
        Blob AutoRespData = Blob.valueOf('booleanFilter,criteriaItems,notifyCcRecipients,replyToEmail,senderEmail,senderName,template \n 1,Case.Origin-equals-SCMGLOBALFIN,FALSE,finops1@lns.maersk.com,autoreply1@lns.maersk.com,Maersk L&amp;S Support Team,BR7_Email_Templates/Standard_Automatic_Case_Creation_SCM_Global');
        sampleZip.addFile('E2C Package/CaseAutoResponseRules.csv', AutoRespData, null);
        
        Blob baData = Blob.valueOf('Email Address,Case Origin,Case Owner \n test1@sealandmaersk.com,SCMTest1,Test SCM - Puma - United Kingdom');
        sampleZip.addFile('E2C Package/BA.csv', baData, null);
        
        Blob orgWideData = Blob.valueOf('Address \n test1@sealandmaersk.com');
        sampleZip.addFile('E2C Package/OrgWideAddress.csv', orgWideData, null);
        
        Blob linerBrandData = Blob.valueOf('DeveloperName,Label,Reply_To_Email__c,Direction__c,Liner_Brand__c,Case_Visibility__c,Product__c,On_Behalf_of_Account_ID__c,Country__c,QueueId__c \n LoadSCMTest1,TestLoad@Maersk.com,Not Known,Maersk L &S,All Users,SCM,GN12354,Null,Null');
        sampleZip.addFile('E2C Package/LinerBrand.csv', linerBrandData, null);
        
        Blob scmKeyClientData = Blob.valueOf('DeveloperName,Label,QueueId__c,Country__c,Business_Hour__c,SCM_KC_Indicator__c,Relation_to_LBDC_metadata__c,On_Behalf_of_Account_ID__c \n SCMLoadSCMKCE2CAuto,SCM - Adidas - China,GN,MCC Bangladesh Business Hours,Load-SCM1,SGLUKIMP,GN12354');
        sampleZip.addFile('E2C Package/SCMKeyClient.csv', scmKeyClientData, null);
        
        Blob customBAData = Blob.valueOf('developerName,localPart\ntestemail,testemail');
        sampleZip.addFile('E2C Package/CustomBA.csv', customBAData, null);
        
        Blob customEmailServicesData = Blob.valueOf('BA Address,Origin,Queue Name,LocalPart,Record Type,Remove Header,Skip Auto Handshake\ntest1@sealandmaersk.com,SCMTest1,SCM - Puma - United Kingdom,testemail,External,false,false');
        sampleZip.addFile('E2C Package/CustomEmailServices.csv', customEmailServicesData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        
        Document document;
        document = new Document();
        document.Body = zipData;
        document.ContentType = 'application/x-zip-compressed';
        document.DeveloperName = 'Email2CaseAutomationTest';
        document.IsPublic = true;
        document.Name = 'Email2CaseAutomation';
        document.FolderId = [select id from folder where name = 'Email2Case'].id;
        insert document;
    }
    
    @isTest
    public static void testUploadFile(){
        Test.startTest();
        EmailToCaseAutomationController.uploadFile('test', 'zip', 'application/x-zip-compressed');
        Test.stopTest();
    }
    
    @isTest
    public static void testAutomation(){
        Test.startTest();
        EmailToCaseAutomationController.deployMetadata('Deploy Groups');
        EmailToCaseAutomationController.deployMetadata('Deploy Queues');
        EmailToCaseAutomationController.deployMetadata('Deploy Origins');
        EmailToCaseAutomationController.deployMetadata('Deploy Roles');
        EmailToCaseAutomationController.deployMetadata('Deploy List Views');
        EmailToCaseAutomationController.deployAutoResponse('Deploy Case Autoresponse Rules');
        EmailToCaseAutomationController.deployMetadata('Deploy BAs');
        EmailToCaseAutomationController.deployMetadata('Deploy LinerBrand Direction and Country');
        EmailToCaseAutomationController.deployMetadata('Deploy SCM Key Client Country Mapping');
        
        Test.stopTest();
    }

	@isTest    
    public static void testCustomBAANDEmailServices(){
        EmailToCaseAutomationController.deployMetadata('Deploy BAs (Custom)');
        EmailToCaseAutomationController.deployMetadata('Deploy Custom Email Services');
    }
    
    @isTest
    public static void testOrgWideAutomation(){
        Test.setMock(HttpCalloutMock.class, new OrgWideAddressesMock());
        Test.startTest();
        EmailToCaseAutomationController.deployMetadata('Deploy Org Wide Addresses');
        Test.stopTest();
    }
    
    @isTest
    public static void testMetadataDeployCallback(){
        CustomMetadataCallback con = new CustomMetadataCallback();
        con.handleResult(null, null);
    }
}