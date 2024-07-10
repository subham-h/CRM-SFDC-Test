/**
* Test class for CaseRunNBAAction
* 
* Version  Date         Owner                   RQ#           Description
*******************************************************************************************************************
* 1.0                                                         Class created
* 2.0      27/06/2022   Ronnie@SF               SPI-100       Removed brand hardcoding
*/

@isTest
public class CaseRunNBAAction_Test {
    
    @testSetup 
    public static void testDataSetup() {
        Folder maerskFolder =  [SELECT id,DeveloperName,Name FROM Folder WHERE DeveloperName = 'NBA_templates'];
        Folder sealandFolder =  [SELECT id,DeveloperName,Name FROM Folder WHERE DeveloperName = 'NBA_Sealand_Templates'];
        
        List<EmailTemplate> templateList = new List<EmailTemplate>();
        EmailTemplate template1 = new EmailTemplate (developerName = 'NBA_Container_Track_Sealand_CAR_English_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand CAR English'); 
        templateList.add(template1);
        
        EmailTemplate template2 = new EmailTemplate (developerName = 'NBA_Container_Track_Sealand_CAR_Spanish_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand CAR Spanish'); 
        templateList.add(template2);
        
        EmailTemplate template3 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Sealand_Asia_Test', FolderId = sealandFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Sealand Asia'); 
        templateList.add(template3);
        
        EmailTemplate template4 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Maersk_Generic_Test', FolderId = maerskFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Maersk Generic'); 
        templateList.add(template4);
        
        EmailTemplate template5 = new EmailTemplate (developerName = 'NBA_Container_Tracking_Maersk_Portugal_Test', FolderId = maerskFolder.Id, TemplateType= 'Text', Name = 'NBA Container Tracking Maersk Portugal'); 
        templateList.add(template5);
        
        insert templateList;
    } 
    
    @isTest
    public static void getCaseRunNBAActionSealandClusters(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        BDA__c bda = TestBusinessHelper.createBDA('East Coast South America Area', 'Cluster', '', null, UserInfo.getUserId(), false);
        bda.Id = null;
        bda.GEO_ID__c = 'NA-Trade';
        insert bda;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Ocean';
        cs.Type = 'Cargo/Container'; 
        cs.sub_type__c = 'Container Status';
        cs.Reason_For_Case__c = 'Container Withdraw';
        cs.Cluster__c = bda.Id;
        cs.Liner_Brand__c = BrandUtilities.SEALAND;
        insert cs;
        
        List<CaseRunNBAAction.caseinput> caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        CaseRunNBAAction.caseinput caseRunNBAActionInstance = new CaseRunNBAAction.caseinput();
        caseRunNBAActionInstance.caseId = cs.id;
        caseRunNBAActionInstance.recommendationName = 'Cargo Container (Container Tracking)';
        caseinputInstanceList.add(CaseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        Test.startTest();
        BDA__c bda2 = TestBusinessHelper.createBDA('West Coast South America Area', 'Cluster', '', null, UserInfo.getUserId(), false);
        bda2.Id = null;
        bda2.GEO_ID__c = 'NA-Trade';
        insert bda2;
        
        cs.Cluster__c = bda2.Id;
        update cs;
        
        caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        caseinputInstanceList.add(caseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        Test.stopTest();
        Case newCs = [Select Id, Resolution_Summary__c From Case Where Id =: cs.Id];
        Assert.isTrue(!String.isBlank(newCs.Resolution_Summary__c), 'Resolution summary should be present.');
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    @isTest
    public static void getCaseRunNBAActionSealandCARClusters1(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c geography = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c arubaGeo = TestBusinessHelper.createGeography('Aruba', 'Country', null, true);
        Geography__c denmarkGeo = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        BDA__c bda = TestBusinessHelper.createBDA('Central America, Andina, Caribbean', 'Cluster', '', null, UserInfo.getUserId(), false);
        bda.Id = null;
        bda.GEO_ID__c = 'NA-Trade';
        insert bda;
        
        BDA__c region = TestBusinessHelper.createBDA('Latin America Region', 'Trade Region', 'LAM-Region', null, UserInfo.getUserId(), false);
        region.Id = null;
        region.GEO_ID__c = '466871';
        insert region;
        
        BDA__c eurRegion = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EUR-Region', null, UserInfo.getUserId(), false);
        eurRegion.Id = null;
        eurRegion.GEO_ID__c = '466872';
        insert eurRegion;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Ocean';
        cs.Type = 'Cargo/Container'; 
        cs.sub_type__c = 'Container Status';
        cs.Reason_For_Case__c = 'Container Withdraw';
        cs.Cluster__c = bda.Id;
        cs.Liner_Brand__c = BrandUtilities.SEALAND;
        cs.Country__c = geography.Id;
        cs.Region__c = region.Id;
        insert cs;
        
        List<CaseRunNBAAction.caseinput> caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        CaseRunNBAAction.caseinput caseRunNBAActionInstance = new CaseRunNBAAction.caseinput();
        caseRunNBAActionInstance.caseId = cs.id;
        caseRunNBAActionInstance.recommendationName = 'Cargo Container (Container Tracking)';
        caseinputInstanceList.add(CaseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        Test.startTest();
        
        cs.Country__c = arubaGeo.Id;
        update cs;
        
        caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        caseinputInstanceList.add(caseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        cs.Country__c = denmarkGeo.Id;
        cs.Liner_Brand__c = BrandUtilities.SEAGO;
        cs.Region__c = eurRegion.Id;
        update cs;
        
        caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        caseinputInstanceList.add(caseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        Test.stopTest();
        
        Case newCs = [Select Id, Resolution_Summary__c From Case Where Id =: cs.Id];
        Assert.isTrue(!String.isBlank(newCs.Resolution_Summary__c), 'Resolution summary should be present.');
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    @isTest
    public static void getCaseRunNBAActionSealandCARClusters2(){
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c denmarkGeo = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c indonesiaGeo = TestBusinessHelper.createGeography('Indonesia', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = denmarkGeo.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        BDA__c bda = TestBusinessHelper.createBDA('Central America, Andina, Caribbean', 'Cluster', '', null, UserInfo.getUserId(), false);
        bda.Id = null;
        bda.GEO_ID__c = 'NA-Trade';
        insert bda;
        
        BDA__c eurRegion = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EUR-Region', null, UserInfo.getUserId(), false);
        eurRegion.Id = null;
        eurRegion.GEO_ID__c = '466872';
        insert eurRegion;
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 234559625';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Ocean';
        cs.Type = 'Cargo/Container'; 
        cs.sub_type__c = 'Container Status';
        cs.Reason_For_Case__c = 'Container Withdraw';
        cs.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        cs.Country__c = denmarkGeo.Id;
        cs.Cluster__c = bda.Id;
        cs.Region__c = eurRegion.Id;
        insert cs;
        
        List<CaseRunNBAAction.caseinput> caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        CaseRunNBAAction.caseinput caseRunNBAActionInstance = new CaseRunNBAAction.caseinput();
        caseRunNBAActionInstance.caseId = cs.id;
        caseRunNBAActionInstance.recommendationName = 'Cargo Container (Container Tracking)';
        caseinputInstanceList.add(CaseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        cs.Country__c = indonesiaGeo.Id;
        update cs;
        
        caseinputInstanceList = new List<CaseRunNBAAction.caseinput>();
        caseinputInstanceList.add(caseRunNBAActionInstance); 
        CaseRunNBAAction.getCaseRunNBAAction(caseinputInstanceList);
        
        Case newCs = [Select Id, Resolution_Summary__c From Case Where Id =: cs.Id];
        Assert.isTrue(!String.isBlank(newCs.Resolution_Summary__c), 'Resolution summary should be present.');
        TriggerExecutionController.skipAllTriggers(false);
    }
    
}