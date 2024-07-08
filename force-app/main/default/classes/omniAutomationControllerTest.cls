@isTest
public class omniAutomationControllerTest {
    @testSetup
    public static void setup(){
        PresenceUserConfigUser pUser = [select id,PresenceUserConfigId,userid,user.Maersk_User_Id__c, PresenceUserConfig.Capacity from PresenceUserConfigUser LIMIT 1];
        Zippex sampleZip = new Zippex();
        Blob SkillsData = Blob.valueOf('MasterLabel \n test2');
        sampleZip.addFile('OmniOnboardingAutomation Package/Skills.csv', SkillsData, null);
        
        Blob userServiceResourceAndSkillsData = Blob.valueOf('Skill Label,Maersk User Id \n Booking,SBS073');
        sampleZip.addFile('OmniOnboardingAutomation Package/userServiceResourceAndSkills.csv', userServiceResourceAndSkillsData, null);
        
        Blob UserToPSUsingMaerskUserIdData = Blob.valueOf('PermissionSet API Name,Maersk User Id \n Omni_Channel_Email_Presence_Statuses,SBS073');
        sampleZip.addFile('OmniOnboardingAutomation Package/UserToPSUsingMaerskUserId.csv', UserToPSUsingMaerskUserIdData, null);
        
        Blob UserToPSUsingSCVcodeData = Blob.valueOf('SCV Code,Customer Service Agent On SR,PermissionSet API Name \n 123456789,Primary Agent,Omni_Channel_Email_Presence_Statuses');
        sampleZip.addFile('OmniOnboardingAutomation Package/UserToPSUsingSCVcode.csv', UserToPSUsingSCVcodeData, null);
        
        Blob PresenceConfigUsingMaerskUseridData = Blob.valueOf('Override Capacity,Capacity,Maersk User Id, Config Name \n True,8,'+pUser.user.Maersk_User_Id__c+',Level_3_Disable_Sound_Notification');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingMaerskUserid.csv', PresenceConfigUsingMaerskUseridData, null);
        
        Blob PresenceConfigUsingSCVcodeData = Blob.valueOf('Override Capacity,Capacity,SCV Code,Customer Service Agent On SR \n True,8,123456789,Primary Agent');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingSCVcode.csv', PresenceConfigUsingSCVcodeData, null);
        
        Blob addUserOrGroupToOmniSupervisorConfigData = Blob.valueOf('Group DeveloperName,OmniSupervisorConfig DeveloperName \n Case_MSL_India_One_Team_Sales,Supervisor_MCC_Philippines');
        sampleZip.addFile('OmniOnboardingAutomation Package/OmniSupervisorConfiGroupAddition.csv', addUserOrGroupToOmniSupervisorConfigData, null);
        
        Blob addUserOrGroupToOmniSupervisorConfigData2 = Blob.valueOf('OmniSupervisorConfig DeveloperName,Maersk User Id \n Supervisor_MCC_Philippines,SBS073');
        sampleZip.addFile('OmniOnboardingAutomation Package/OmniSupervisorConfigUserAddition.csv', addUserOrGroupToOmniSupervisorConfigData2, null);
        
        Blob CaseOmniMappingsRecordsData = Blob.valueOf('Name,Origin,Channel,Skill Label,Case Field,Skill Label 2,Case Field 2,Additional Skills,Vessel Service Numbers \n SkillMap13500,MSLNLEXP,Email,Amend booking details ,Sub Type,Dangerous Cargo,Cargo Flow,NA,NA');
        sampleZip.addFile('OmniOnboardingAutomation Package/CaseOmniMappingsRecords.csv', CaseOmniMappingsRecordsData, null);
        
        Blob OmniServiceRelationshipmappingsData = Blob.valueOf('Name,Origin,Active,Preferred Agent,Sub Type,Reason for Case \n SkillMap1,MCCMMIMP,MCCMMIMP,TRUE,GSC Agent,NA');
        sampleZip.addFile('OmniOnboardingAutomation Package/OmniServiceRelationshipmappings.csv', OmniServiceRelationshipmappingsData, null);
        
        Blob OmniClientCaseAssignmentsData = Blob.valueOf('Name,Active,Account,Back up Dedicated Agent,Dedicated Agent,Country,Sub Type,Direction \n testupload,TRUE,33148830596,SYA131,MSI286,CN,Booking confirmation,Import');
        sampleZip.addFile('OmniOnboardingAutomation Package/OmniClientCaseAssignments.csv', OmniClientCaseAssignmentsData, null);

        
        Blob LBDCMetadataRecordsData = Blob.valueOf('Label (OriginName),On Behalf of Account Name,Value Proposition Party,Service Relationship Party,Priority 1,Priority 2,Priority 3,Priority 4,Priority 5 \n MSLCNIMP,Price Owner,Price Owner,Price Owner,Type');
        sampleZip.addFile('OmniOnboardingAutomation Package/LBDCMetadataRecords.csv', LBDCMetadataRecordsData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        
        Document document;
        document = new Document();
        document.Body = zipData;
        document.ContentType = 'application/x-zip-compressed';
        document.DeveloperName = 'OmniOnboardingAutomation1';
        document.IsPublic = true;
        document.Name = 'OmniOnboardingAutomation';
        document.FolderId = [select id from folder where name = 'OmniOnboardingAutomation'].id;
        insert document;
        
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc = AccountData_Test.lstAccounts[0];
        acc.SCV_Code__c = '123456789';
        acc.Value_Proposition__c = 'Ease';
        acc.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc;    
        TriggerExecutionController.skipAllTriggers(false);
        
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser = [select id,name from user where name='Einstein User' LIMIT 1];  
        Care_Relationship__c maerskLineCR = new Care_Relationship__c();
        maerskLineCR.Account__c = acc.id;
        maerskLineCR.Direction__c = 'Import/Export';
        maerskLineCR.Status__c = 'Active';
        maerskLineCR.Service_Level__c = 'CARE';
        maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR.Care_Business_Partner__c = einteinUser.id;
        maerskLineCR.GSC_Agent__c = einteinUser.id;
        insert maerskLineCR;
        system.debug('SR created value --->'+[select id,Care_Business_Partner__c from care_relationship__c]);
        TriggerExecutionController.skipAllTriggers(false);
        
        //Data to cover SCV scenario for presence config
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        Account acc2 = AccountData_Test.lstAccounts[0];
        acc2.SCV_Code__c = '123456799';
        acc2.Value_Proposition__c = 'Ease';
        acc2.Country__c = BDAGeographyData_Test.countryCH.Id;
        update acc2;    
        TriggerExecutionController.skipAllTriggers(false);
        
        TriggerExecutionController.skipAllTriggers(true);  
        user einteinUser2 = [select id,name from user where name='Einstein User' LIMIT 1];  
        Care_Relationship__c maerskLineCR2 = new Care_Relationship__c();
        maerskLineCR2.Account__c = acc2.id;
        maerskLineCR2.Direction__c = 'Import/Export';
        maerskLineCR2.Status__c = 'Active';
        maerskLineCR2.Service_Level__c = 'CARE';
        maerskLineCR2.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        maerskLineCR2.Country__c = BDAGeographyData_Test.countryCH.Id;
        maerskLineCR2.Care_Business_Partner__c = einteinUser2.id;
        maerskLineCR2.GSC_Agent__c = einteinUser2.id;
        insert maerskLineCR2;
        system.debug('SR created value --->'+[select id,Care_Business_Partner__c from care_relationship__c]);
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    @isTest
    public static void testUploadFile(){
        Test.startTest();
        omniAutomationController.uploadFile('test', 'zip', 'application/x-zip-compressed');
        Test.stopTest();
    }
    
    @isTest
    public static void testAutomation(){
        Test.startTest();
        omniAutomationController.deployMetadata('Deploy Skills');
        omniAutomationController.deployMetadata('Deploy userServiceResourceAndSkills');
        omniAutomationController.deployMetadata('Deploy UserToPSUsingMaerskUserId');
        omniAutomationController.deployMetadata('Deploy UserToPSUsingSCVcode');
        system.debug('SR created value --->'+[select id,Care_Business_Partner__c from care_relationship__c]);
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingMaerskUserid');
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingSCVcode');                
        omniAutomationController.deployMetadata('Deploy UserToOmniSupervisorConfig');
        omniAutomationController.deployMetadata('Deploy GroupToOmniSupervisorConfig');
        omniAutomationController.deployMetadata('Deploy CaseOmniMappingsRecords');
        omniAutomationController.deployMetadata('Deploy OmniServiceRelationshipmappings');
        omniAutomationController.deployMetadata('Deploy OmniClientCaseAssignments');
        omniAutomationController.deployMetadata('Deploy LBDCMetadataRecords');
        
        coverPresenceConfigurationScenario2();
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingMaerskUserid');
        coverPresenceConfigurationScenario3();
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingMaerskUserid');
        coverPresenceConfigurationScenario4();
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingSCVcode'); 
        coverPresenceConfigurationScenario5();
        omniAutomationController.deployMetadata('Deploy PresenceConfigUsingSCVcode');
        coverCaseOmniMappingsScenario2();
        omniAutomationController.deployMetadata('Deploy CaseOmniMappingsRecords');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testLBDCMetadataRecordsAutomation(){
        Test.setMock(HttpCalloutMock.class, new OrgWideAddressesMock());
        Test.startTest();
        omniAutomationController.deployMetadata('Deploy LBDCMetadataRecords');
        Test.stopTest();
    }
    
    @isTest
    public static void testMetadataDeployCallback(){
        CustomMetadataCallback con = new CustomMetadataCallback();
        con.handleResult(null, null);
    }
    
    @istest
    public static void coverPresenceConfigurationScenario2 (){
        document doc = [select id,Body from document where name = 'OmniOnboardingAutomation'];
        Zippex sampleZip = new Zippex();
        Blob PresenceConfigUsingMaerskUseridData = Blob.valueOf('Override Capacity,Capacity,Maersk User Id,Config Name \n false,NA,SBS073,Level_3_Disable_Sound_Notification');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingMaerskUserid.csv', PresenceConfigUsingMaerskUseridData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        doc.body = zipData;
        list<document> doctoupdateList = new list<document>();
        doctoupdateList.add(doc);         
        update doctoupdateList;                   
    }
    @istest
    public static void coverPresenceConfigurationScenario3 (){
        document doc = [select id,Body from document where name = 'OmniOnboardingAutomation'];
        Zippex sampleZip = new Zippex();
        Blob PresenceConfigUsingMaerskUseridData = Blob.valueOf('Override Capacity,Capacity,Maersk User Id,Config Name \n false,NA,SBS073,Level_3_Disable_Sound_Notification');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingMaerskUserid.csv', PresenceConfigUsingMaerskUseridData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        doc.body = zipData;
        list<document> doctoupdateList = new list<document>();
        doctoupdateList.add(doc);         
        update doctoupdateList;
    }
    
    @istest
    //Covers for SCV Code based when no-overide is selected but user exists
    public static void coverPresenceConfigurationScenario4 (){
        document doc = [select id,Body from document where name = 'OmniOnboardingAutomation'];
        Zippex sampleZip = new Zippex();
        Blob PresenceConfigUsingSCVcodeData = Blob.valueOf('Override Capacity,Capacity,SCV Code,Customer Service Agent On SR \n false,NA,123456789,Primary Agent');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingSCVcode.csv', PresenceConfigUsingSCVcodeData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        doc.body = zipData;
        list<document> doctoupdateList = new list<document>();
        doctoupdateList.add(doc);         
        update doctoupdateList;
    }
    
    @istest
    //Covers for SCV Code based when no-overide is selected and user is no
    public static void coverPresenceConfigurationScenario5 (){
        document doc = [select id,Body from document where name = 'OmniOnboardingAutomation'];
        Zippex sampleZip = new Zippex();
        Blob PresenceConfigUsingSCVcodeData = Blob.valueOf('Override Capacity,Capacity,SCV Code,Customer Service Agent On SR \n false,NA,123456799,Primary Agent');
        sampleZip.addFile('OmniOnboardingAutomation Package/PresenceConfigUsingSCVcode.csv', PresenceConfigUsingSCVcodeData, null);
        
        Blob zipData = sampleZip.getZipArchive();
        doc.body = zipData;
        list<document> doctoupdateList = new list<document>();
        doctoupdateList.add(doc);         
        update doctoupdateList;
    }
    
    @istest
    //Covers for SCV Code based when no-overide is selected and user is no
    public static void coverCaseOmniMappingsScenario2 (){
        document doc = [select id,Body from document where name = 'OmniOnboardingAutomation'];
        Zippex sampleZip = new Zippex();
        Blob CaseOmniMappingsRecordsData = Blob.valueOf('Name,Origin,Channel,Skill Label,Case Field,Skill Label 2,Case Field 2,Additional Skills,Vessel Service Numbers \n SkillMap13500,MSLNLEXP,Email,Amend booking details ,Sub Type,Dangerous Cargo,Cargo Flow,NA,NA');
        sampleZip.addFile('OmniOnboardingAutomation Package/CaseOmniMappingsRecords.csv', CaseOmniMappingsRecordsData, null);
        Blob zipData = sampleZip.getZipArchive();
        doc.body = zipData;
        list<document> doctoupdateList = new list<document>();
        doctoupdateList.add(doc);         
        update doctoupdateList;
    }
}