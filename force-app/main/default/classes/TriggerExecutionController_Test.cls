/*
 * Purpose  : Test Class for TriggerExecutionController.
 *        
 * Revision Ref Number  Date              Owner                 Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   10-Feb-2016       Ragu@UST              Created.
 * 2.0      RQ-004145   22-Jul-2016       Jiji@UST              To skip triggers based on trigger execution controller custom setting 
 * 3.0      RQ-004653   27-April-2017     Rathish@UST           Updated test class to accomodate validation rule "BillingCity_Not_Valid"
 * 4.0      RQ-009682   14-Jan-2019       Junaid@UST            Added code for covering newhiremodule skip section
 * 5.0      RQ-012152   03-Oct-2019       Neha@TCS              Added code for skipping new ContentDocumentLink trigger
 * 6.0       RQ-012314   13-NOv-2019      Neha@TCS              Added code for skipping new OpportunitySplittrigger
 * 7.0      SFSE-5203    05-Apr-2021      Neha@TCS              Removed the references for skipUserTerritory2AssociationTrigger
 * 8.0      SFSE-7308    18-Nov-2021      Neha@Tcs              Added code for skipping new SIPMeasureTrigger
 * 9.0    SC-4640    03-Mar-2022      Avinash@Maersk    Object Level Trigger Bypass Design change
 * 10.0    SC-4905    21-Apr-2022      Avinash@Maersk    Flow execution bypass design change
 * 11.0    SFSE-12549   11-Sept-2023      Samar@Maersk           Added code for skipping new OpptyProductConfigTrigger
 * 12.0     SFSE-11771  14-Sept-2023 Jothsana@maersk            Added code to skip ApprovalHistoryTrigger
 * 13.0     SFSE-12888  15-Oct-2023      Aleena@maersk          Added code to skip skipOfferinformationTrigger and skipOpportunityFileTrigger
 */
 
 @isTest
 private class TriggerExecutionController_Test {
 
     static testMethod void test_TriggerExecutionController() {
         Test.StartTest();
         TriggerExecutionController.skipAllTriggers(true);
         System.assert(TriggerExecutionController.skipAllTriggers(), true);
         
         TriggerExecutionController.skipAccountTrigger(true);
         System.assert(TriggerExecutionController.skipAccountTrigger(), true);
         
         TriggerExecutionController.skipAccountActualsTrigger(true);
         System.assert(TriggerExecutionController.skipAccountActualsTrigger(), true);
 
         TriggerExecutionController.skipContactTrigger(true);
         System.assert(TriggerExecutionController.skipContactTrigger(), true);
         
         TriggerExecutionController.skipCaseTrigger(true);
         System.assert(TriggerExecutionController.skipCaseTrigger(), true);
         
         TriggerExecutionController.skipCaseFlow(true);
         System.assert(TriggerExecutionController.skipCaseFlow(), true);
 
         TriggerExecutionController.skipOpportunityTrigger(true);
         System.assert(TriggerExecutionController.skipOpportunityTrigger(), true);
         
         TriggerExecutionController.skipEmailMessageTrigger(true);
         System.assert(TriggerExecutionController.skipEmailMessageTrigger(), true);
         
         TriggerExecutionController.skipFinancialDetailsTrigger(true);
         System.assert(TriggerExecutionController.skipFinancialDetailsTrigger(), true);
         
         TriggerExecutionController.skipIncidentTrigger(true);
         System.assert(TriggerExecutionController.skipIncidentTrigger(), true);
         
         TriggerExecutionController.skipTaskTrigger(true);
         System.assert(TriggerExecutionController.skipTaskTrigger(), true);
         
         TriggerExecutionController.skipEventTrigger(true);
         System.assert(TriggerExecutionController.skipEventTrigger(), true);
         
         TriggerExecutionController.skipSalesCallTrigger(true);
         System.assert(TriggerExecutionController.skipSalesCallTrigger(), true);
         
         TriggerExecutionController.skipSIPTrigger(true);
         System.assert(TriggerExecutionController.skipSIPTrigger(), true);
         
         TriggerExecutionController.skipopptyLineItemTrigger(true);
         System.assert(TriggerExecutionController.skipopptyLineItemTrigger(), true);
         
         TriggerExecutionController.skipRateStructureTrigger(true);
         System.assert(TriggerExecutionController.skipRateStructureTrigger(), true);
         
         TriggerExecutionController.skipCorridorGuidanceTrigger(true);
         System.assert(TriggerExecutionController.skipCorridorGuidanceTrigger(), true);
         
         TriggerExecutionController.skipSalesMetricTrigger(true);
         System.assert(TriggerExecutionController.skipSalesMetricTrigger(), true);  
         
         TriggerExecutionController.skipModuleTrigger(true);
         System.assert(TriggerExecutionController.skipModuleTrigger(), true);
         
         TriggerExecutionController.skipInitiativeTrigger(true);
         System.assert(TriggerExecutionController.skipInitiativeTrigger(), true);
         
         TriggerExecutionController.skipCustomerCodeTrigger(true);
         System.debug(TriggerExecutionController.skipCustomerCodeTrigger());
         System.assert(TriggerExecutionController.skipCustomerCodeTrigger(), true);
         
         TriggerExecutionController.skipCustomerRatingTrigger(true);
         System.assert(TriggerExecutionController.skipCustomerRatingTrigger());
         System.assert(TriggerExecutionController.skipCustomerRatingTrigger(), true);
         
         TriggerExecutionController.skipOnboardingPlanTrigger(true);
         System.assert(TriggerExecutionController.skipOnboardingPlanTrigger(), true);
         
         TriggerExecutionController.skipProjectTemplateTrigger(true);
         System.assert(TriggerExecutionController.skipProjectTemplateTrigger(), true);
         TriggerExecutionController.skipProjectTemplateTrigger(false);
         
         TriggerExecutionController.skipProjectMilestoneTrigger(true);
         System.assert(TriggerExecutionController.skipProjectMilestoneTrigger(), true);
         TriggerExecutionController.skipProjectMilestoneTrigger(false);
         
         TriggerExecutionController.skipProjectTaskTrigger(true);
         System.assert(TriggerExecutionController.skipProjectTaskTrigger(), true);
         TriggerExecutionController.skipProjectTaskTrigger(false);
         
         TriggerExecutionController.skipNewHireModuleTrigger(true);
         System.assert(TriggerExecutionController.skipNewHireModuleTrigger(), true);
         TriggerExecutionController.skipNewHireModuleTrigger(false);
         
         TriggerExecutionController.skipRequestTrigger(true);
         System.assert(TriggerExecutionController.skipRequestTrigger(), true);
         TriggerExecutionController.skipRequestTrigger(false);
         
         TriggerExecutionController.skipTerritoryAccountAssociationTrigger(true);
         System.assert(TriggerExecutionController.skipTerritoryAccountAssociationTrigger(), true);
         TriggerExecutionController.skipTerritoryAccountAssociationTrigger(false);
         
         TriggerExecutionController.skipTerritoryUserAssociationTrigger(true);
         System.assert(TriggerExecutionController.skipTerritoryUserAssociationTrigger(), true);
         TriggerExecutionController.skipTerritoryUserAssociationTrigger(false);   
         
         TriggerExecutionController.skipSurveyTrigger(true);
         System.assert(TriggerExecutionController.skipSurveyTrigger(), true);
         TriggerExecutionController.skipSurveyTrigger(false);
         
         TriggerExecutionController.skipTerritoryTrigger(true);
         System.assert(TriggerExecutionController.skipTerritoryTrigger(), true);
         TriggerExecutionController.skipTerritoryTrigger(false);
         
         TriggerExecutionController.skipOpportunityTeamMemberTrigger(true);
         System.assert(TriggerExecutionController.skipOpportunityTeamMemberTrigger(), true);
         TriggerExecutionController.skipOpportunityTeamMemberTrigger(false);
         
         TriggerExecutionController.skipUserTrigger(true);
         System.assert(TriggerExecutionController.skipUserTrigger(), true);
         TriggerExecutionController.skipUserTrigger(false);
         
         TriggerExecutionController.skipCorridorActualTrigger(true);
         System.assert(TriggerExecutionController.skipCorridorActualTrigger(), true);
         TriggerExecutionController.skipCorridorActualTrigger(false);
         
         TriggerExecutionController.skipProduct2Trigger(true);
         System.assert(TriggerExecutionController.skipProduct2Trigger(), true);
         TriggerExecutionController.skipProduct2Trigger(false);
         
         TriggerExecutionController.skipCampaignMemberTrigger(true);
         System.assert(TriggerExecutionController.skipCampaignMemberTrigger(), true);
         TriggerExecutionController.skipCampaignMemberTrigger(false);
         
         TriggerExecutionController.skipLeadTrigger(true);
         System.assert(TriggerExecutionController.skipLeadTrigger(), true);
         TriggerExecutionController.skipLeadTrigger(false);
         
         TriggerExecutionController.skipApprovalRequestTrigger(true);
         System.assert(TriggerExecutionController.skipApprovalRequestTrigger(), true);
         TriggerExecutionController.skipApprovalRequestTrigger(false);
         
         TriggerExecutionController.skipcontentDocumentLinkTrigger(true);
         System.assert(TriggerExecutionController.skipcontentDocumentLinkTrigger(), true);
         TriggerExecutionController.skipcontentDocumentLinkTrigger(false);
         
         TriggerExecutionController.skipOpportunitySplitTrigger(true);
         System.assert(TriggerExecutionController.skipOpportunitySplitTrigger(), true);
         TriggerExecutionController.skipOpportunitySplitTrigger(false);
 
         TriggerExecutionController.skipConnectiveTaskStagingTrigger(true);
         System.assert(TriggerExecutionController.skipConnectiveTaskStagingTrigger(), true);
         TriggerExecutionController.skipConnectiveTaskStagingTrigger(false);
 
         TriggerExecutionController.skipConnectiveTaskTrigger(true);
         System.assert(TriggerExecutionController.skipConnectiveTaskTrigger(), true);
         TriggerExecutionController.skipConnectiveTaskTrigger(false);
         
         TriggerExecutionController.skipSIPMeasureTrigger(true);
         System.assert(TriggerExecutionController.skipSIPMeasureTrigger(), true);
         TriggerExecutionController.skipSIPMeasureTrigger(false);
         
         TriggerExecutionController.skipMaerskIdeaVoteTrigger(true);
         System.assert(TriggerExecutionController.skipMaerskIdeaVoteTrigger(), true);
         TriggerExecutionController.skipMaerskIdeaVoteTrigger(false);
         
         TriggerExecutionController.skipOpportunityContractTrigger(true);
         System.assert(TriggerExecutionController.skipOpportunityContractTrigger(), true);
         TriggerExecutionController.skipOpportunityContractTrigger(false);
 
         TriggerExecutionController.skipConcernEventTrigger(true);
         System.assert(TriggerExecutionController.skipConcernEventTrigger(), true);
         TriggerExecutionController.skipConcernEventTrigger(false);
         
         TriggerExecutionController.skipArchivedCaseTrigger(true);
         System.assert(TriggerExecutionController.skipArchivedCaseTrigger(), true);
         TriggerExecutionController.skipArchivedCaseTrigger(false);
         
         TriggerExecutionController.skipOpportunityProductSchedule(true);
         System.assert(TriggerExecutionController.skipOpportunityProductSchedule(), true);
         TriggerExecutionController.skipOpportunityProductSchedule(false);
 
         TriggerExecutionController.skipOpptyProductConfigTrigger(true);
         System.assert(TriggerExecutionController.skipOpptyProductConfigTrigger(), true);
         TriggerExecutionController.skipOpptyProductConfigTrigger(false);
         
         TriggerExecutionController.skipOpportunityLineItemSchedule(true);
         System.assert(TriggerExecutionController.skipOpportunityLineItemSchedule(), true);
         TriggerExecutionController.skipOpportunityLineItemSchedule(false);
         
         TriggerExecutionController.skipActionTrigger(true);
         System.assert(TriggerExecutionController.skipActionTrigger(), true);
         TriggerExecutionController.skipActionTrigger(false);
 
         TriggerExecutionController.skipCustomerEventTrigger(true);
         System.assert(TriggerExecutionController.skipCustomerEventTrigger(), true);
         TriggerExecutionController.skipCustomerEventTrigger(false);
         
               TriggerExecutionController.skipContactEventTrigger(true);
         System.assert(TriggerExecutionController.skipContactEventTrigger(), true);
         TriggerExecutionController.skipContactEventTrigger(false);
         
         TriggerExecutionController.skipAIUpdateRecordEventTrigger(true);
         System.assert(TriggerExecutionController.skipAIUpdateRecordEventTrigger(), true);
         TriggerExecutionController.skipAIUpdateRecordEventTrigger(false);
         
          TriggerExecutionController.skipChatTranscriptTrigger(true);
         System.assert(TriggerExecutionController.skipChatTranscriptTrigger(), true);
         TriggerExecutionController.skipChatTranscriptTrigger(false);
         
         TriggerExecutionController.skipEmployeeHRDataTrigger(true);
         System.assert(TriggerExecutionController.skipEmployeeHRDataTrigger(), true);
         TriggerExecutionController.skipEmployeeHRDataTrigger(false);
 
         TriggerExecutionController.skipOceanPlusLeadTrigger(true);
         System.assert(TriggerExecutionController.skipOceanPlusLeadTrigger(), true);
         TriggerExecutionController.skipOceanPlusLeadTrigger(false);
         
         TriggerExecutionController.skipOceanPlusLineItemTrigger(true);
         System.assert(TriggerExecutionController.skipOceanPlusLineItemTrigger(), true);
         TriggerExecutionController.skipOceanPlusLineItemTrigger(false);
         
         TriggerExecutionController.skipShipmentTrigger(true);
         System.assert(TriggerExecutionController.skipShipmentTrigger(), true);
         TriggerExecutionController.skipShipmentTrigger(false);
         
         TriggerExecutionController.skipApprovalHistoryTrigger(true);
         System.assert(TriggerExecutionController.skipApprovalHistoryTrigger(), true);
         TriggerExecutionController.skipApprovalHistoryTrigger(false);
         
         TriggerExecutionController.skipOfferinformationTrigger(true);
         System.assert(TriggerExecutionController.skipOfferinformationTrigger(), true);
         TriggerExecutionController.skipOfferinformationTrigger(false);
         
         TriggerExecutionController.skipOpportunityFileTrigger(true);
         System.assert(TriggerExecutionController.skipOpportunityFileTrigger(), true);
         TriggerExecutionController.skipOpportunityFileTrigger(false);
         
         TriggerExecutionController.skipBookingInformationTrigger(true);
        System.assert(TriggerExecutionController.skipBookingInformationTrigger(), true);
        TriggerExecutionController.skipBookingInformationTrigger(false);
        
        TriggerExecutionController.skipExternalPartyTrigger(true);
        System.assert(TriggerExecutionController.skipExternalPartyTrigger(), true);
        TriggerExecutionController.skipExternalPartyTrigger(false);
        
        TriggerExecutionController.skipEquipmentCommodityTrigger(true);
        System.assert(TriggerExecutionController.skipEquipmentCommodityTrigger(), true);
        TriggerExecutionController.skipEquipmentCommodityTrigger(false);
         
         TriggerExecutionController.skipCareTrigger(true);
         System.assert(TriggerExecutionController.skipCareTrigger(), true);
         TriggerExecutionController.skipCareTrigger(false);
         
         Test.StopTest();
     
     }
     //Ver 2.0: Start
     static testMethod void SkipTriggerforCurrentUser_test() {
         Test.StartTest();
         
         TriggerExecutionController.skipTriggerOnObject('Case');
         TriggerExecutionController.skipTriggerOnObject('Survey__c');
         
         Geography__c geo = new Geography__c();
         geo.Name = 'TestGeography';
         geo.Type_Of_Location__c = 'Country';
         geo.GEO_ID__c = '0QK7LWQMLOXVI';
         insert geo;
         
         Geography__c geo1 = new Geography__c();
         geo1.Name = 'TestCity';
         geo1.Type_Of_Location__c = 'Country';
         geo1.GEO_ID__c = '0QK7LAQMLIXVI';
         insert geo1;
 
         BDA__c clu = new BDA__c();
         clu.Name = 'test Cluster';
         clu.BDA_Code__c = '1111111111111';
         clu.Default_Account_Owner__c = UserInfo.getUserId();
         clu.Type__c = 'Cluster';
         clu.GEO_ID__c = geo.GEO_ID__c;
         insert clu;
 
         BDA_Geography__c bdaGeo = new BDA_Geography__c();
         bdaGeo.Geography__c = geo.Id;
         bdaGeo.BDA__c = clu.Id;
         insert bdaGeo;
         
         // Create test account data
         Account account1 = new Account();
         account1.Name = 'UniteTestAccountName';
         account1.BillingStreet = '403 McAdoo St';
         account1.BillingCity = 'TestCity';
         account1.BillingState = 'NM';
         account1.BillingPostalCode = '87901';
         account1.BillingCountry = 'US';
         account1.Country__c = geo.id;
         insert account1;
 
         TriggerExecutionController.skipFlowOnObject(new List<Id>{account1.Id});
         
         Test.StopTest();
     }
     //Ver 2.0: End
 }