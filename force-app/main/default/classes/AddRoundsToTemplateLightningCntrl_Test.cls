/*
This is the test class for FinanceTriggerHandler
** Version    Date            Owner                                         RQ#                     Description
*********************************************************************************************************************************  
*  V1.0       11/05/2018      Jiji.Jayasingh@ust-global.com                 #RQ-008308              Test class for AddRoundsToTemplateLightningCntrl
*  V2.0       14/02/2019      Junaid.Khader@ust-global.com                  #RQ-009572              SBF renamed as BAF
*  V2.0       20/08/2019      Junaid.Khader@ust-global.com                  #RQ-011439              Added Ocean family for product
*  3.0		  29-Sep-2021	  Kiran@Maersk									SFSE-6066				Removing Territory record type references and Territory User association object deprecation
*  4.0		  26-Jul-2023	  Kiran@Maersk															Test data framework
*/

@isTest
public class AddRoundsToTemplateLightningCntrl_Test {
    
    @testSetup
    static void setup() {
        Test.startTest();
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity tenderOpportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Product2 product = TestBusinessHelper.createProduct('Ocean', true);
        TestBusinessHelper.createOpportunityLineItemCustom(tenderOpportunity, product.Id, null, true);
        Test.stopTest();
    }
    
    //To test add Handling round workflow
    @isTest
    static void HandlingRoundWorkflow_Test() {
         TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity tenderOpportunity = [SELECT Id,Customer_Type__c,Tender_Submission_Format__c,Customer_Requested_Rate_Structure__c FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        tenderOpportunity.Customer_Type__c='';
        tenderOpportunity.Tender_Submission_Format__c='Customer specific format';
        tenderOpportunity.Customer_Requested_Rate_Structure__c= 'Yes';
        tenderOpportunity.First_Shipment_Date__c = date.today() + 300;
        tenderOpportunity.Last_Shipment_Date__c = date.today() + 400;
        update tenderOpportunity;
         TriggerExecutionController.skipOpportunityTrigger(false);
        Opportunity tenderOpportunity1 = [SELECT Id,Customer_Type__c,Tender_Type__c,Tender_Submission_Format__c,Customer_Requested_Rate_Structure__c FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        system.debug('tenderOpportunity1'+ tenderOpportunity1);
        tenderOpportunity1.Customer_Type__c='BCO';
        update tenderOpportunity1;
        Product2 product = [SELECT Id FROM Product2 WHERE Family = 'Ocean'];
        List<Project_Milestone_Mapping__mdt> projMilestoneList = new List<Project_Milestone_Mapping__mdt>();
        for(Project_Milestone_Mapping__mdt projMilestoneMapping : [SELECT MasterLabel,DeveloperName, Milestone_Name__c, Order__c, Milestones_Grouping__c, Reference_Date__c
                                                                   FROM Project_Milestone_Mapping__mdt 
                                                                   ORDER BY Order__c]) {
                                                                       projMilestoneList.add(projMilestoneMapping);                                                  
                                                                   }
        Map<String,Boolean> projTempMap = new Map<String,Boolean>();
        for(Project_Template_Mapping__mdt projTemplateMapping : [SELECT MasterLabel,DeveloperName, isQualified__c
                                                                 FROM Project_Template_Mapping__mdt 
                                                                 WHERE isQualified__c = TRUE]) {
                                                                     projTempMap.put(projTemplateMapping.DeveloperName, projTemplateMapping.isQualified__c);                                                  
                                                                 }
        Test.startTest();
        Project_Template__c ptRecord = [SELECT Id, Name, Lead_Route__c, Handling_Rounds__c, OwnerId, Opportunity__c, Reference_Date__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity.Id];
        ptRecord.Lead_Route__c = product.Id;
        update ptRecord;
        AddRoundsToTemplateLightningCntrl.getTenderDetails(ptRecord.Id);
        Date refDate = Date.today().addDays(330);
        String refDateString = String.valueOf(refDate);
        AddRoundsToTemplateLightningCntrl.validateDates(refDateString, refDateString, null, Label.Contracting);
        AddRoundsToTemplateLightningCntrl.validateDates(refDateString, refDateString, ptRecord, Label.Subsequent_Handling_Round);
        AddRoundsToTemplateLightningCntrl.validateDates(string.valueof(System.today()), refDateString, ptRecord, Label.Subsequent_Handling_Round);
        //System.assertEquals(ptRecord.Handling_Rounds__c, 1);
        AddRoundsToTemplateLightningCntrl.saveTemplateRecord(null, refDateString, refDateString, ptRecord);
        Test.stopTest();
        System.assertEquals(ptRecord.Handling_Rounds__c, 2);
    }
    
    //To test tender workflow
    @isTest
    static void ContractingRound_Test() {
        TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity tenderOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'ShippingCargoServices'];  
        tenderOpportunity.Customer_Type__c='';
        tenderOpportunity.Tender_Submission_Format__c='Customer specific format';
        tenderOpportunity.Customer_Requested_Rate_Structure__c= 'Yes';
        tenderOpportunity.First_Shipment_Date__c = date.today() + 300;
        tenderOpportunity.Last_Shipment_Date__c = date.today() + 400;
        update tenderOpportunity;
         TriggerExecutionController.skipOpportunityTrigger(false);
        Opportunity tenderOpportunity1 = [SELECT Id,Customer_Type__c,Tender_Type__c,Tender_Submission_Format__c,Customer_Requested_Rate_Structure__c FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        system.debug('tenderOpportunity1'+ tenderOpportunity1);
        tenderOpportunity1.Customer_Type__c='BCO';
        update tenderOpportunity1;
        List<Project_Milestone_Mapping__mdt> projMilestoneList = new List<Project_Milestone_Mapping__mdt>();
        for(Project_Milestone_Mapping__mdt projMilestoneMapping : [SELECT MasterLabel,DeveloperName, Milestone_Name__c, Order__c, Milestones_Grouping__c, Reference_Date__c
                                                                   FROM Project_Milestone_Mapping__mdt 
                                                                   ORDER BY Order__c]) {
                                                                       projMilestoneList.add(projMilestoneMapping);                                                  
                                                                   }
        Map<String,Boolean> projTempMap = new Map<String,Boolean>();
        for(Project_Template_Mapping__mdt projTemplateMapping : [SELECT MasterLabel,DeveloperName, isQualified__c
                                                                 FROM Project_Template_Mapping__mdt 
                                                                 WHERE isQualified__c = TRUE]) {
                                                                     projTempMap.put(projTemplateMapping.DeveloperName, projTemplateMapping.isQualified__c);                                                  
                                                                 }
        Test.startTest();
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, OwnerId, Opportunity__c, Reference_Date__c, SBF_Formula__c, Rate_Effective_Date__c, Rate_Expiry_Date__c, Contract_Effective_Date__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity.Id];
        AddRoundsToTemplateLightningCntrl.getTenderDetails(ptRecord.Id);
        AddRoundsToTemplateLightningCntrl.getContractDetails(ptRecord.Id);
        Date refDate = Date.today().addDays(330);
        String refDateString = String.valueOf(refDate);
        AddRoundsToTemplateLightningCntrl.saveRecords(refDateString, refDateString, ptRecord);
        System.assertEquals(ptRecord.Handling_Rounds__c, 1); 
        Test.stopTest();
    }
    
    @isTest
    static void ContractingRound_Test2() {
        TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity tenderOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        tenderOpportunity.Customer_Type__c='';
        tenderOpportunity.Tender_Submission_Format__c='Customer specific format';
        tenderOpportunity.Customer_Requested_Rate_Structure__c= 'Yes';
        tenderOpportunity.First_Shipment_Date__c = date.today() + 300;
        tenderOpportunity.Last_Shipment_Date__c = date.today() + 400;
        update tenderOpportunity;
        TriggerExecutionController.skipOpportunityTrigger(false);
        Opportunity tenderOpportunity1 = [SELECT Id,Customer_Type__c,Tender_Type__c,Tender_Submission_Format__c,Customer_Requested_Rate_Structure__c FROM Opportunity WHERE Name = 'ShippingCargoServices'];
        system.debug('tenderOpportunity1'+ tenderOpportunity1);
        tenderOpportunity1.Customer_Type__c='BCO';
        update tenderOpportunity1;
        List<Project_Milestone_Mapping__mdt> projMilestoneList = new List<Project_Milestone_Mapping__mdt>();
        for(Project_Milestone_Mapping__mdt projMilestoneMapping : [SELECT MasterLabel,DeveloperName, Milestone_Name__c, Order__c, Milestones_Grouping__c, Reference_Date__c
                                                                   FROM Project_Milestone_Mapping__mdt 
                                                                   ORDER BY Order__c]) {
                                                                       projMilestoneList.add(projMilestoneMapping);                                                  
                                                                   }
        Map<String,Boolean> projTempMap = new Map<String,Boolean>();
        for(Project_Template_Mapping__mdt projTemplateMapping : [SELECT MasterLabel,DeveloperName, isQualified__c
                                                                 FROM Project_Template_Mapping__mdt 
                                                                 WHERE isQualified__c = TRUE]) {
                                                                     projTempMap.put(projTemplateMapping.DeveloperName, projTemplateMapping.isQualified__c);                                                  
                                                                 }
        Test.startTest();
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, OwnerId, Opportunity__c, Reference_Date__c, SBF_Formula__c, Rate_Effective_Date__c, Rate_Expiry_Date__c, Contract_Effective_Date__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity.Id];
        ptRecord.Does_the_Customer_Require_a_SBF_Clause__c = 'Yes';
        ptRecord.SBF_Formula__c = 'BAF at customer specific levels – quarterly update';
        ptRecord.Rate_Effective_Date__c = Date.today().addDays(60);
        ptRecord.Rate_Expiry_Date__c = Date.today().addDays(460);
        ptRecord.Contract_Effective_Date__c = Date.today().addDays(40);
        update ptRecord;
        AddRoundsToTemplateLightningCntrl.getTenderDetails(ptRecord.Id);
        AddRoundsToTemplateLightningCntrl.getContractDetails(ptRecord.Id);
        Date refDate = Date.today().addDays(330);
        String refDateString = String.valueOf(refDate);
        AddRoundsToTemplateLightningCntrl.saveRecords(refDateString, refDateString, ptRecord);
        System.assertEquals(ptRecord.Handling_Rounds__c, 1); 
        Test.stopTest();
    }
    
}