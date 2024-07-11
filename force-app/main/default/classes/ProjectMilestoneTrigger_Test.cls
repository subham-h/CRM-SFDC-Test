/**
* Test class for : ProjectMilestoneTrigger

* Date			Owner										Description
******************************************************************************************************************************
* 25/04/2018	jiji.jayasingh@ust-global.com				Test Class for ProjectMilestoneTrigger
* 26/07/2023	Kiran@Maersk								New test data creation framework in use
*/


@isTest
private class ProjectMilestoneTrigger_Test {
    @testSetup
    static void setup() {
        Test.startTest();
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity tenderOpportunity = TestBusinessHelper.createOpportunity(clientAccount, null, adminUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateProjectMilestonewithPT_Test() {
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
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, Opportunity__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity1.Id];
        Test.startTest();
        if (ptRecord.Id != null) {
            Project_Milestones__c pmRecord = [SELECT Id, Milestone_Completed__c 
                                              FROM Project_Milestones__c
                                              WHERE Project_Template__c = :ptRecord.Id 
                                              ORDER BY CreatedDate ASC LIMIT 1];
            try {
                pmRecord.Milestone_Completed__c = TRUE;
                update pmRecord;
                delete pmRecord;
            } catch(exception e){}
        }
        Test.stopTest();
    }
    
    @isTest
    static void UpdateProjectMilestoneCompleted_Test() {
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
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, Opportunity__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity1.Id];
        Test.startTest();
        if (ptRecord.Id != null) {
            Project_Milestones__c pmRecord = [SELECT Id, Milestone_Completed__c 
                                              FROM Project_Milestones__c
                                              WHERE Project_Template__c = :ptRecord.Id 
                                              ORDER BY CreatedDate ASC LIMIT 1];
            pmRecord.Milestone_Completed__c = TRUE;
            update pmRecord;
        }
        Test.stopTest();
    }
    
    @isTest
    static void UpdateProjectMilestoneStatus_Test() {
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
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, Opportunity__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity1.Id];
        Test.startTest();
        if (ptRecord.Id != null) {
            Project_Milestones__c pmRecord = [SELECT Id, Milestone_Completed__c 
                                              FROM Project_Milestones__c
                                              WHERE Project_Template__c = :ptRecord.Id 
                                              ORDER BY CreatedDate ASC LIMIT 1];
            pmRecord.Status__c = 'Completed';
            update pmRecord;
        }
        Test.stopTest();
    }
    
    @isTest
    static void updateDueDateTest() {
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
        Project_Template__c ptRecord = [SELECT Id, Name, Handling_Rounds__c, Opportunity__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity1.Id];
        Test.startTest();
        if (ptRecord.Id != null) {
            Project_Milestones__c pmRecord = [SELECT Id, Due_Date__c 
                                              FROM Project_Milestones__c
                                              WHERE Project_Template__r.Opportunity__c = :tenderOpportunity1.Id
                                              ORDER BY CreatedDate ASC LIMIT 1];
            pmRecord.Due_Date__c= pmRecord.Due_Date__c-1;
            update pmRecord;
        }  
        Test.stopTest();
    }
    
    @isTest
    static void updateCustomerRequiresSpecialBAFClause() {
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
        Project_Template__c ptRecord = [SELECT Id, Name, Does_the_Customer_Require_a_SBF_Clause__c
                                        FROM Project_Template__c 
                                        WHERE Opportunity__c = :tenderOpportunity1.Id];
        Test.startTest();
        ptRecord.Does_the_Customer_Require_a_SBF_Clause__c = 'Yes';
        update ptRecord;
        Test.stopTest();
    }
    
    @isTest
    static void createGuidanceHelpCustomMetadata() {
        Test.startTest();
        MilestoneguidanceCntrl.getAllTMG();
        Test.stopTest();
    }
}