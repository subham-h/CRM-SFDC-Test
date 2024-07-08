@isTest
public class CustomNBARecommendation_Test{
    public static Boolean bCreate = true;
    public static Contact conInstance = null;
    public static Case caseInstance = null;
    
     @testSetup static void testDataSetup() {
         
         Folder maerskFolder =  [SELECT id,DeveloperName,Name FROM Folder WHERE DeveloperName = 'NBA_templates'];
         Folder sealandFolder =  [SELECT id,DeveloperName,Name FROM Folder WHERE DeveloperName = 'NBA_Sealand_Templates'];
         
         EmailTemplate template1 = new EmailTemplate (developerName = 'NBA_Container_Track_Sealand_CAR_English_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand CAR English'); 
         insert template1;
         
         EmailTemplate template2 = new EmailTemplate (developerName = 'NBA_Container_Track_Sealand_CAR_Spanish_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand CAR Spanish'); 
         insert template2;
         
         EmailTemplate template3 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Sealand_Asia_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand Asia'); 
         insert template3;  
         
         EmailTemplate template4 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Maersk_Generic_Test', FolderId = maerskFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Maersk Generic'); 
         insert template4;
         
         EmailTemplate template5 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Maersk_Portugal_Test', FolderId = maerskFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Maersk Portugal'); 
         insert template5;    
    } 
    
    
    public static testMethod void createUpdateResolutionSummary(){
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
       
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.Case_Channel__c = 'E-mail';
        CaseInstance.SuppliedEmail = 'test@test.com';
        insert CaseInstance;
        
         //Create NBA
        List<NBA_Action_Map__c> nbaList = new List<NBA_Action_Map__c>();
        NBA_Action_Map__c nba = new NBA_Action_Map__c();
        nba.Actions__c = 'Send an email';
        nba.Flow_Name__c = 'Custom_NBA_Action';
        nba.Recommendation_Name__c = 'Charges, Invoice & Payment (Provide Invoice Copy)';
        nba.Recommendation_Id__c = '3';
        nba.Object__c ='Case';
        nbaList.add(nba);
        
        NBA_Action_Map__c nba1 = new NBA_Action_Map__c();
        nba1.Actions__c = 'Update a Record';
        nba1.Flow_Name__c = 'Custom_NBA_Action';
        nba1.Recommendation_Name__c = 'Cargo Container (Container Tracking)';
        nba1.Recommendation_Id__c = '4';
        nba1.Object__c ='Case';
        nbaList.add(nba1);
        insert nbaList;
        
        //Update Type and Sub Type for Cargo Container
        CaseInstance.Type = 'Cargo/Container';
        CaseInstance.Sub_Type__c ='Container Status';
        caseInstance.Reason_for_case__c =  'Unable to Track Container';
        update CaseInstance;
        system.debug('CaseInstance###'+CaseInstance);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NBARecommendationsMock()); 
        CustomNBARecommendation.getRecommendations(String.valueof(CaseInstance.Id),'Case');
        
        List<Case_Recommendation__c> cseRecomList = [SELECT Id,Recommendation_Id__c,Recommendation_Name__c from Case_Recommendation__c  where Case__c=: CaseInstance.Id and Recommendation_Name__c = 'Cargo Container (Container Tracking)'];
        system.debug('cseRecomList ##'+cseRecomList);
        
        CustomNBAAction.caseinput flowInput = new CustomNBAAction.caseinput();
        flowInput.caseId = String.valueof(CaseInstance.Id); 
        flowInput.recommendationName = String.valueof(cseRecomList[0].Recommendation_Name__c );
        flowInput.objectName = 'Case';
        flowInput.fieldName = 'Resolution_Summary__c';
        CustomNBAAction.runNBAction(new List<CustomNBAAction.caseinput>{flowInput});
        Test.stopTest();
    }
    
    public static testMethod void CreateSendEmailCase(){
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
       
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.Case_Channel__c = 'E-mail';
        CaseInstance.SuppliedEmail = 'test@test.com';
        Insert CaseInstance;
        
        Case cse = [SELECT id,Type,Sub_Type__c,isRecommendationAvaialble__c from Case where id=:CaseInstance.Id];        
        System.assertEquals(cse.isRecommendationAvaialble__c , false);
        
        cse.Type = 'Charges, Invoice & Payment';
        cse.Sub_Type__c ='Invoice / Payer Party';
        cse.Reason_for_case__c =  'Invoice Query';
        update cse;
        
        //Create NBA
        List<NBA_Action_Map__c> nbaList = new List<NBA_Action_Map__c>();
        NBA_Action_Map__c nba = new NBA_Action_Map__c();
        nba.Actions__c = 'Send an email';
        nba.Flow_Name__c = 'Custom_NBA_Action';
        nba.Recommendation_Name__c = 'Charges, Invoice & Payment (Provide Invoice Copy)';
        nba.Recommendation_Id__c = '3';
        nba.Object__c ='Case';
        nbaList.add(nba);
        
        NBA_Action_Map__c nba1 = new NBA_Action_Map__c();
        nba1.Actions__c = 'Update a Record';
        nba1.Flow_Name__c = 'Custom_NBA_Action';
        nba1.Recommendation_Name__c = 'Cargo Container (Container Tracking)';
        nba1.Recommendation_Id__c = '4';
        nba1.Object__c ='Case';
        nba1.Fields__c ='Resolution_Summary__c';
        nbaList.add(nba1);
        insert nbaList;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;  
        
        List<ContentDocument> conDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        EmailMessage emsg = new EmailMessage();
        emsg.FromAddress = 'test1@maersk.com';
        emsg.ToAddress = 'test2@gmail.com';
        emsg.CcAddress = 'test3@gmail.com';
        emsg.Subject = 'Test 1';
        emsg.TextBody = 'Test 2';
        emsg.ParentId = cse.Id;
        emsg.Incoming = true;
        insert emsg;
        
        NBAEmailController.EmailContent emailContent = new NBAEmailController.EmailContent();
        emailContent.to = 'test1@maersk.com';
        emailContent.cc = 'test2@maersk.com';
        emailContent.subject = 'Test 2';
        emailContent.bodyHTML = 'Test 2';
        emailContent.selectedEmailList = new List<String>{'test4@gmail.com'};
        emailContent.docIds = conDocs[0].Id;        
                
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NBARecommendationsMock()); 
        CustomNBARecommendation.getRecommendations(String.valueof(cse.Id),'Case');
        
        List<Case_Recommendation__c> cseRecomList = [SELECT Id,Recommendation_Id__c,Recommendation_Name__c from Case_Recommendation__c  where Case__c=: cse.Id];
        system.debug('cseRecomList ##'+cseRecomList );
        
        NBAEmailController.EmailWrapper ewrap1 = NBAEmailController.getEmailTemplate(cse.Id, cseRecomList[0].Recommendation_Id__c);
        system.debug('ewrap1 ##'+ewrap1);
        system.assertEquals(ewrap1.showTemplate, true);
        NBAEmailController.EmailWrapper ewrap2 = NBAEmailController.sendEmail(cse.Id, JSON.serialize(emailContent));
        system.debug('ewrap2 ##'+ewrap2);
        system.assertEquals(ewrap2.emailSent, true);
        
        CustomNBARecommendation.getRecommendations(String.valueof(cse.Id),'Case');
        
        /*CustomNBAAction.caseinput flowInput = new CustomNBAAction.caseinput();
        flowInput.caseId = String.valueof(cse.Id); 
        flowInput.recommendationName = String.valueof(cseRecomList[0].Recommendation_Name__c );
        flowInput.objectName = 'Case';
        flowInput.fieldName = 'Resolution_Summary__c';
        CustomNBAAction.runNBAction(new List<CustomNBAAction.caseinput>{flowInput});*/
        Test.stopTest();
    }
    
    public static testMethod void AutoDeletionofCRuponSubTypeUpdate(){
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1; 
        CaseData_Test.createExternalCasesII();
       
        CaseInstance = CaseData_Test.lstCases[0];
        CaseInstance.Case_Channel__c = 'E-mail';
        CaseInstance.SuppliedEmail = 'test@test.com';
        Insert CaseInstance;
        
        Case cse = [SELECT id,Type,Sub_Type__c,isRecommendationAvaialble__c from Case where id=:CaseInstance.Id];        
        System.assertEquals(cse.isRecommendationAvaialble__c , false);
        
        cse.Type = 'Charges, Invoice & Payment';
        cse.Sub_Type__c ='Invoice / Payer Party';
        cse.Reason_for_case__c =  'Invoice Query';
        update cse;
        
        //Create NBA
        List<NBA_Action_Map__c> nbaList = new List<NBA_Action_Map__c>();
        NBA_Action_Map__c nba = new NBA_Action_Map__c();
        nba.Actions__c = 'Send an email';
        nba.Flow_Name__c = 'Custom_NBA_Action';
        nba.Recommendation_Name__c = 'Charges, Invoice & Payment (Provide Invoice Copy)';
        nba.Recommendation_Id__c = '3';
        nba.Object__c ='Case';
        nbaList.add(nba);
        
        NBA_Action_Map__c nba1 = new NBA_Action_Map__c();
        nba1.Actions__c = 'Update a Record';
        nba1.Flow_Name__c = 'Custom_NBA_Action';
        nba1.Recommendation_Name__c = 'Cargo Container (Container Tracking)';
        nba1.Recommendation_Id__c = '4';
        nba1.Object__c ='Case';
        nba1.Fields__c ='Resolution_Summary__c';
        nbaList.add(nba1);
        insert nbaList;
                
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new NBARecommendationsMock()); 
        CustomNBARecommendation.getRecommendations(String.valueof(cse.Id),'Case');        
        
        List<Case_Recommendation__c> cseRecomList = [SELECT Id,Recommendation_Id__c,Recommendation_Name__c from Case_Recommendation__c  where Case__c=: cse.Id];
        
        //Update Type and Sub Type for Cargo Container
        CaseInstance.Type = 'Cargo/Container';
        CaseInstance.Sub_Type__c ='Container Status';
        caseInstance.Reason_for_case__c =  'Unable to Track Container';
        update CaseInstance;
        
        CustomNBARecommendation.getRecommendations(String.valueof(cse.Id),'Case');
        Test.stopTest();
    }
    
     public testMethod static void test_GetCaseRunNBAActionSealandClusters(){       
        // For Creating a Contact Instance
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        Contact conInstance = ContactData_Test.lstContacts[0];
        
        //Create NBA
        List<NBA_Action_Map__c> nbaList = new List<NBA_Action_Map__c>();
        NBA_Action_Map__c nba = new NBA_Action_Map__c();
        nba.Actions__c = 'Send an email';
        nba.Flow_Name__c = 'Custom_NBA_Action';
        nba.Recommendation_Name__c = 'Charges, Invoice & Payment (Provide Invoice Copy)';
        nba.Recommendation_Id__c = '3';
        nba.Object__c ='Case';
        nbaList.add(nba);
        
        NBA_Action_Map__c nba1 = new NBA_Action_Map__c();
        nba1.Actions__c = 'Update a Record';
        nba1.Flow_Name__c = 'Custom_NBA_Action';
        nba1.Recommendation_Name__c = 'Cargo Container (Container Tracking)';
        nba1.Recommendation_Id__c = '4';
        nba1.Object__c ='Case';
        nba1.Fields__c ='Resolution_Summary__c';
        nbaList.add(nba1);
        insert nbaList;
        
        // For Creating a Case Instance
        CaseData_Test.bCreate = true;
        CaseData_Test.iNumberOfCases = 3; 
        CaseData_Test.conInstance = conInstance;
        list<Case> lstCases = new list<Case>();
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);

        BDA__c germanyBD = new BDA__c(Name = 'East Coast South America Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert germanyBD;
        
        // Update field on case to test scenarios
        for(Case caseIterator : lstCases) { 
            
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Cargo/Container'; 
            caseIterator.Liner_Brand__c = BrandUtilities.SEALAND;
            caseIterator.sub_type__c = 'Container Status';
            caseIterator.Reason_For_Case__c = 'Unable to Track Container';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.contactid = conInstance.id;
            caseIterator.Cluster__c = germanyBD.id;
        }  
        
        update lstCases;
        system.debug('lstCases--->'+lstCases);
        
        test.startTest();       

        contact c1 = new contact();
        
        Test.setMock(HttpCalloutMock.class, new NBARecommendationsMock());
        CustomNBARecommendation.getRecommendations(String.valueof(lstCases[0].id),'Case');
        List<Case_Recommendation__c> cseRecomList = [SELECT Id,Recommendation_Id__c,Recommendation_Name__c from Case_Recommendation__c  where Case__c=: lstCases[0].id and Recommendation_Name__c = 'Cargo Container (Container Tracking)'];
        system.debug('cseRecomList ##'+cseRecomList);
        
        CustomNBAAction.caseinput flowInput = new CustomNBAAction.caseinput();
        flowInput.caseId = String.valueof(lstCases[0].Id); 
        flowInput.recommendationName = String.valueof(cseRecomList[0].Recommendation_Name__c );
        flowInput.objectName = 'Case';
        flowInput.fieldName = 'Resolution_Summary__c';
        CustomNBAAction.runNBAction(new List<CustomNBAAction.caseinput>{flowInput});
        
        BDA__c carCluster = new BDA__c(Name = 'West Coast South America Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert carCluster;
        
        // Update field on case to test scenarios
        for(Case caseIterator : lstCases) { 
            
            caseIterator.Direction__c = 'Export';
            caseIterator.status = 'Triaged';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Type = 'Cargo/Container'; 
            caseIterator.Liner_Brand__c = BrandUtilities.SEALAND;
            caseIterator.sub_type__c = 'Container Status';
            caseIterator.Reason_For_Case__c = 'Unable to Track Container';
            caseIterator.Case_Channel__c ='E-mail';   
            caseIterator.contactid = conInstance.id;
            caseIterator.Cluster__c = carCluster.id;
        }  
        
        update lstCases;
        
        contact c2 = new contact();
        
        //Test.setMock(HttpCalloutMock.class, new NBARecommendationsMock());
        CustomNBARecommendation.getRecommendations(String.valueof(lstCases[0].id),'Case');
        List<Case_Recommendation__c> cseRecomList1 = [SELECT Id,Recommendation_Id__c,Recommendation_Name__c from Case_Recommendation__c  where Case__c=: lstCases[0].id and Recommendation_Name__c = 'Cargo Container (Container Tracking)'];
        system.debug('cseRecomList ##'+cseRecomList1);
        
        CustomNBAAction.caseinput flowInput1 = new CustomNBAAction.caseinput();
        flowInput1.caseId = String.valueof(lstCases[0].Id); 
        flowInput1.recommendationName = String.valueof(cseRecomList1[0].Recommendation_Name__c );
        flowInput1.objectName = 'Case';
        flowInput1.fieldName = 'Resolution_Summary__c';
        CustomNBAAction.runNBAction(new List<CustomNBAAction.caseinput>{flowInput});
                        
        Test.stopTest();
    }
}