/*
 * Author   : Ragu@UST
 * Purpose  : Contains static members to control the execution of the trigger for any object. 
 *          By default all the objects trigger will run. If you want to skip any of the object trigger, set corresponding member value to true.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   10-Feb-2016 Ragu@UST                Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      RQ-003245   12-Apr-2016 Madhava@UST             Added Boolean variables for contact trigger execution
 * 3.0      RQ-004145   21-Jul-2016 Jiji@UST                To skip current trigger for current user based on Trigger Execution Controller custom setting
 * 4.0      RQ-002683   24-Mar-2016 Ragu@UST                Added facilities for skipping Financial_Details__c object trigger.
 * 5.0      RQ-002716   29-Mar-2016 Jiji@UST                Added facilities for skipping Incident__c object trigger.
 * 6.0      RQ-004366   13-Dec-2016 Hitha@UST               Added facilities for skipping User Trigger
 * 7.0                  26-Jul-2017 meghana@UST             Added variable for skipping Opportunity Team Member trigger
 * 8.0      RQ-005186   31-Jul-2017 Sandhya@UST             Added variable for skipping territory trigger
 * 9.0      RQ-005644   10-Oct-2017 Uvais@UST               Created Trigger for UserTerritory2Association
 * 10.0     RQ-008579   22-May-2018 meghana@UST             Added variable for skipping TerritoryUserAssociationTrigger, TerritoryAccountAssociationTrigger
 * 11.0     RQ-09384    29-Nov-2018 Jagadeesan@UST          Added variable for skipping Request Trigger
 * 12.0     RQ-009682   14-Jan-2019 Junaid@UST              Added variable for skipping new Hire Module Trigger
 * 13.0     RQ-004490   21-Jan-2019 meghana@UST             Added variable for skipping new Lead Trigger
 * 14.0     RQ-007192   20-Feb-2019 Junaid@UST              Added variable for skipping new CampaignMember trigger
 * 15.0     RQ-007189   21-Feb-2019 meghana@UST             Added variable for skipping new Approval Request trigger
 * 16.0     RQ-012152   03-Oct-2019 Neha@TCS                Added variable for skipping new ContentDocumentLink trigger
 * 16.0     RQ-012314   13-NOv-2019 Neha@TCS                Added code for skipping new OpportunitySplittrigger
 * 17.0     RQ-012314   27-Dec-2019 Amritesh@UST            Added code for skipping new QuoteTrigger
 * 18.0     SFSE-5203   05-Apr-2021 Neha@TCS                Removed the references for skipUserTerritory2AssociationTrigger
 * 19.0     SC-2668     30-07-2021  Ramadevi@ust            Added code for Activity Related Reference 
 * 20.0     SFSE-7308   18-Nov-2021 Neha@TCS                Added variable for skipping new SIPMeasureTrigger trigger
 * 21.0     SC-4640     03-Mar-2022 Avinash@Maersk          Object Level Trigger Bypass Design change
 * 22.0     SC-4905     19-Apr-2022 Avinash@Maersk          Flow execution bypass design change
 * 22.0     SC-5433     17-Jul-2022 Sunil.bs@Maersk.com     Added variable for skipping AIUpdateRecordEventTrigger trigger
 * 23.0     SFSE-8727   09-Sep-2022 Kiran@Maersk            Added variable for skipping CustomerEventTrigger trigger
 * 24.0     SFSE-9685   15-Nov-2022 Meghana@UST             Added variable for skipping OpportunityLineItemSchedule trigger
 * 25.0     SFSE-9032   16-Dec-2022 Vazid@UST               Added variable for skipping ConcernEventTrigger trigger
 * 26.0     SFSE-10986  17-May- 2023 sriram@maerk           Introduced a variable to skipp OpportunityProductScheduleTrigger trigger
 * 27.0     SFSE-10984  19-May-2023 Jothsana@maersk         Added Variable to skip OpportunityProductTrigger
 * 28.0     SC-8485     19-June-2023 Richa@Maersk           Added variable for skipping OceanPlusLead trigger
 * 29.0     SC-8872     23-Aug-2023  Richa@Maersk           Added variable for skipping OceanPlusLineItem trigger
 * 30.0     SC-8410     23-Aug-2023  Ramadevi@Maersk        Added variable for skipping MessagingSession trigger
 * 31.0     SC-9041     11-Sep-2023  Richa@Maersk           Added variable for skipping Shipment trigger
 * 32.0    SFSE-12549   11-Sept-2023 Samar@Maersk           Added code for skipping new OpptyProductConfigTrigger
 * 33.0     SFSE-11771  14-Sept-2023 Jothsana@maersk        Added Variable to skip ApprovalHistoryTrigger
 * 34.0     SFSE-12888  10-Oct-2023  Aleena@Maersk          Added variable to skip OfferInformationTrigger and OpportunityFileTrigger 
 * 35.0     SC-9582    	22-Dec-2023  Richa@Maersk        	Added variable for skipping Party trigger 
 * 36.0		SC-9662		25-Jan-2024	 Nayana@Maersk			Added variable for skipping Care relationship trigger
 * 37.0     SFMC-7692   29-May-2024  Ranjan@Maersk          Added variable for skipping Enagagment Tracker trigger     
*/

public class TriggerExecutionController {
    /**
    * @description 
    * @author Avinash@Maersk | 04-21-2022 
    * @param sObjectName 
    * @return boolean 
    **/
    public static boolean skipTriggerOnObject(String sObjectName) {
        boolean skipTriggerForCurrentUser = false;
        Trigger_and_Flow_Execution_Controller__mdt triggerController; 
        if(sObjectName != NULL && sObjectName.contains('__c')){
           triggerController = Trigger_and_Flow_Execution_Controller__mdt.getInstance(sObjectName.replace('__c','_c'));
        }else{
           triggerController = Trigger_and_Flow_Execution_Controller__mdt.getInstance(sObjectName);
        }
        
        if(triggerController != null && 
          (triggerController.Bypass_Capability__c != null && 
          (triggerController.Bypass_Capability__c == General_Key_Value_Configurations__mdt.getInstance('Skip_trigger_execution_only').First_Field_Value__c || 
           triggerController.Bypass_Capability__c == General_Key_Value_Configurations__mdt.getInstance('Skip_flow_and_trigger_execution').First_Field_Value__c)) &&
          (triggerController.User_Ids__c != null && (triggerController.User_Ids__c.Contains(General_Key_Value_Configurations__mdt.getInstance('Skip_all_users_indicator').First_Field_Value__c) || 
           triggerController.User_Ids__c.Contains(userInfo.getUserId().Substring(0, 15))))) {
            skipTriggerForCurrentUser = true;
        }
        return skipTriggerForCurrentUser;
    }
    /**
    * @description 
    * @author Avinash@Maersk | 04-21-2022 
    * @param recordIds 
    * @return List<Boolean> 
    **/
    @InvocableMethod(label='skipFlowOnObject')
    public static List<Boolean> skipFlowOnObject(List<Id> recordIds) {
        Boolean skipFlowForCurrentUser = false;
        String sObjectName = string.valueOf(recordIds[0].getSObjectType());
        Trigger_and_Flow_Execution_Controller__mdt triggerController;
        if(sObjectName != NULL && sObjectName.contains('__c')){
           triggerController = Trigger_and_Flow_Execution_Controller__mdt.getInstance(sObjectName.replace('__c','_c'));
        }else{
           triggerController = Trigger_and_Flow_Execution_Controller__mdt.getInstance(sObjectName);
        }
        
        if(triggerController != null && 
          (triggerController.Bypass_Capability__c != null && 
          (triggerController.Bypass_Capability__c == General_Key_Value_Configurations__mdt.getInstance('Skip_flow_execution_only').First_Field_Value__c || 
           triggerController.Bypass_Capability__c == General_Key_Value_Configurations__mdt.getInstance('Skip_flow_and_trigger_execution').First_Field_Value__c)) &&
          (triggerController.User_Ids__c != null && (triggerController.User_Ids__c.Contains(General_Key_Value_Configurations__mdt.getInstance('Skip_all_users_indicator').First_Field_Value__c) || 
           triggerController.User_Ids__c.Contains(userInfo.getUserId().Substring(0, 15))))) {
            skipFlowForCurrentUser = true;
        }
        return new List<Boolean>{skipFlowForCurrentUser};
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipAllTriggers = false;
    public static void skipAllTriggers(boolean bSkip) {
        skipAllTriggers = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipAllTriggers() {
        return skipAllTriggers;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipAccountTrigger = false;
    public static void skipAccountTrigger(boolean bSkip) {        
        skipAccountTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipAccountTrigger() {
        return skipAccountTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipUserClusterTrigger = false;
    public static void skipUserClusterTrigger(boolean bSkip) {        
        skipUserClusterTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipUserClusterTrigger() {
        return skipUserClusterTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipAccountActualsTrigger = false;
    public static void skipAccountActualsTrigger( boolean bSkip ) {        
        skipAccountActualsTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipAccountActualsTrigger() {
        return skipAccountActualsTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipContactTrigger = false;
    public static void skipContactTrigger(boolean bSkip) {        
        skipContactTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipContactTrigger() {
        return skipContactTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipQuoteLineItemTrigger = false;
    public static void skipQuoteLineItemTrigger(boolean bSkip) {        
        skipQuoteLineItemTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipQuoteLineItemTrigger() {
        return skipQuoteLineItemTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCaseTrigger = false;
    private static boolean skipCaseFlow = false;
    
    public static void skipCaseTrigger(boolean bSkip) {
        skipCaseTrigger = bSkip;
        skipCaseFlow = bSkip;
    }
    
    public static void skipCaseFlow(boolean bSkip) {
        skipCaseFlow = bSkip;
    }
    
    private static boolean skipIntegrationStagingTrigger = false;
    public static void skipIntegrationStagingTrigger(boolean bSkip) {
        skipIntegrationStagingTrigger = bSkip;
    }
    public static boolean skipIntegrationStagingTrigger() {
        return skipIntegrationStagingTrigger;
    }

    private static boolean skipIntegrationResultTrigger = false;
    public static void skipIntegrationResultTrigger(boolean bSkip) {
        skipIntegrationResultTrigger = bSkip;
    }
    public static boolean skipIntegrationResultTrigger() {
        return skipIntegrationResultTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCaseTrigger() {
        return skipCaseTrigger;
    }
    
    public static boolean skipCaseFlow() {
        return skipCaseFlow;
    }
    
   
     /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipAgentWorkTrigger = false;
    public static void skipAgentWorkTrigger(boolean bSkip) {
        skipAgentWorkTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipAgentWorkTrigger() {
        return skipAgentWorkTrigger;
    }
    
    private static boolean skipOpportunityContractTrigger = false;
    public static void skipOpportunityContractTrigger(boolean bSkip) {
        skipOpportunityContractTrigger = bSkip;
    }
    public static boolean skipOpportunityContractTrigger() {
        return skipOpportunityContractTrigger;
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipOpportunityTrigger = false;
    public static void skipOpportunityTrigger( boolean bSkip ) {        
        skipOpportunityTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipOpportunityTrigger() {
        return skipOpportunityTrigger;
    }

    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11-09-23
    * @param bSkip 
    **/
    private static boolean skipOpptyProductConfigTrigger = false;
    public static void skipOpptyProductConfigTrigger( boolean bSkip ) {        
        skipOpptyProductConfigTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11-09-23
    * @return boolean 
    **/
    public static boolean skipOpptyProductConfigTrigger() {
        return skipOpptyProductConfigTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipEmailMessageTrigger = false;
    public static void skipEmailMessageTrigger(boolean bSkip) {
        skipEmailMessageTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipEmailMessageTrigger() {
        return skipEmailMessageTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipFinancialDetailsTrigger = false;
    public static void skipFinancialDetailsTrigger(boolean bSkip) {
        skipFinancialDetailsTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipFinancialDetailsTrigger() {
        return skipFinancialDetailsTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipIncidentTrigger = false;
    public static void skipIncidentTrigger(boolean bSkip) {
        skipIncidentTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipIncidentTrigger() {
        return skipIncidentTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipSIPTrigger = false;
    public static void skipSIPTrigger( boolean bSkip ) {        
        skipSIPTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSIPTrigger() {
        return skipSIPTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipopptyLineItemTrigger = false;
    public static void skipopptyLineItemTrigger( boolean bSkip ) {        
        skipopptyLineItemTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipopptyLineItemTrigger() {
        return skipopptyLineItemTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipOpportunityProductTrigger = false;
    public static void skipOpportunityProductTrigger( boolean bSkip ) {        
        skipOpportunityProductTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipOpportunityProductTrigger() {
        return skipOpportunityProductTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipTaskTrigger = false;
    public static void skipTaskTrigger(boolean bSkip) {
        skipTaskTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipTaskTrigger() {
        return skipTaskTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipEventTrigger = false;
    public static void skipEventTrigger(boolean bSkip) {
        skipEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipEventTrigger() {
        return skipEventTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipSalesCallTrigger = false;
    public static void skipSalesCallTrigger( boolean bSkip ) {        
        skipSalesCallTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSalesCallTrigger() {
        return skipSalesCallTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipRateStructureTrigger = false;
    public static void skipRateStructureTrigger( boolean bSkip ) {        
        skipRateStructureTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipRateStructureTrigger() {
        return skipRateStructureTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCorridorGuidanceTrigger = false;
    public static void skipCorridorGuidanceTrigger( boolean bSkip ) {        
        skipCorridorGuidanceTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCorridorGuidanceTrigger() {
        return skipCorridorGuidanceTrigger; 
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipSalesMetricTrigger = false;
    public static void skipSalesMetricTrigger( boolean bSkip ) {        
        skipSalesMetricTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSalesMetricTrigger() {
        return skipSalesMetricTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCorridorActualTrigger = false;
    public static void skipCorridorActualTrigger( boolean bSkip ) {        
        skipCorridorActualTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCorridorActualTrigger() {
        return skipCorridorActualTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipModuleTrigger = false;
    public static void skipModuleTrigger( boolean bSkip ) {        
        skipModuleTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipModuleTrigger() {
        return skipModuleTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCustomerRatingTrigger = false;
    public static void skipCustomerRatingTrigger( boolean bSkip ) {        
        skipCustomerRatingTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCustomerRatingTrigger() {
        return skipCustomerRatingTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCustomerCodeTrigger = false;
    public static void skipCustomerCodeTrigger( boolean bSkip ) {        
        skipCustomerCodeTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCustomerCodeTrigger() {
        return skipCustomerCodeTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipInitiativeTrigger = false;
    public static void skipInitiativeTrigger( boolean bSkip ) {        
        skipInitiativeTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipInitiativeTrigger() {
        return skipInitiativeTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipOnboardingPlanTrigger = false;
    public static void skipOnboardingPlanTrigger( boolean bSkip ){        
        skipOnboardingPlanTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipOnboardingPlanTrigger(){
        return skipOnboardingPlanTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipUserTrigger = false;
    public static void skipUserTrigger( boolean bSkip ) {        
        skipUserTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipUserTrigger() {
        return skipUserTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipOpportunityTeamMemberTrigger= false;
    public static void skipOpportunityTeamMemberTrigger( boolean bSkip ) {        
        skipOpportunityTeamMemberTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipOpportunityTeamMemberTrigger() {
        return skipOpportunityTeamMemberTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipTerritoryTrigger = false;
    public static void skipTerritoryTrigger( boolean bSkip ) {        
        skipTerritoryTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipTerritoryTrigger() {
        return skipTerritoryTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipSurveyTrigger = false;
    public static void skipSurveyTrigger( boolean bSkip ) {        

        skipSurveyTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSurveyTrigger() {

        return skipSurveyTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipProjectTemplateTrigger = false;
    public static void skipProjectTemplateTrigger( boolean bSkip ) {        
        skipProjectTemplateTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean SkipProjectTemplateTrigger() {
        return skipProjectTemplateTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipProjectMilestoneTrigger = false;
    public static void skipProjectMilestoneTrigger( boolean bSkip ) {        
        skipProjectMilestoneTrigger = bSkip;
    }
    /*
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean SkipProjectMilestoneTrigger() {
        return skipProjectMilestoneTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipTerritoryUserAssociationTrigger = false;
    public static void skipTerritoryUserAssociationTrigger( boolean bSkip ) {        
        skipTerritoryUserAssociationTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipTerritoryUserAssociationTrigger() {
        return skipTerritoryUserAssociationTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipTerritoryAccountAssociationTrigger = false;
    public static void skipTerritoryAccountAssociationTrigger( boolean bSkip ) {        
        skipTerritoryAccountAssociationTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipTerritoryAccountAssociationTrigger() {
        return skipTerritoryAccountAssociationTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipProjectTaskTrigger = false;
    public static void skipProjectTaskTrigger( boolean bSkip ) {        
        skipProjectTaskTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipProjectTaskTrigger() {
        return skipProjectTaskTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipRequestTrigger = false;
    public static void skipRequestTrigger( boolean bSkip ) {        
        skipRequestTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipRequestTrigger() {
        return skipRequestTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipNewHireModuleTrigger = false;
    public static void skipNewHireModuleTrigger( boolean bSkip ) {        
        skipNewHireModuleTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipNewHireModuleTrigger() {
        return skipNewHireModuleTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipLeadTrigger = false;
    public static void skipLeadTrigger( boolean bSkip ) {        
        skipLeadTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipLeadTrigger() {
        return skipLeadTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipProduct2Trigger = false;
    public static void skipProduct2Trigger( boolean bSkip ) {        
        skipProduct2Trigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipProduct2Trigger() {
        return skipProduct2Trigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipCampaignMemberTrigger = false;
    public static void skipCampaignMemberTrigger( boolean bSkip ) {        
        skipCampaignMemberTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipCampaignMemberTrigger() {
        return skipCampaignMemberTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipApprovalRequestTrigger = false;
    public static void skipApprovalRequestTrigger( boolean bSkip ) {        
        skipApprovalRequestTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipApprovalRequestTrigger() {
        return skipApprovalRequestTrigger ;
    }
    /*
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipcontentDocumentLinkTrigger = false;
    public static void skipcontentDocumentLinkTrigger( boolean bSkip ) {        
        skipcontentDocumentLinkTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipcontentDocumentLinkTrigger() {
        return skipcontentDocumentLinkTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipOpportunitySplitTrigger = false;
    public static void skipOpportunitySplitTrigger( boolean bSkip ) {        
        skipOpportunitySplitTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipOpportunitySplitTrigger() {
        return skipOpportunitySplitTrigger ;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipQuoteTrigger = false;
    public static void skipQuoteTrigger(boolean bSkip) {        
        skipQuoteTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipQuoteTrigger() {
        return skipQuoteTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipConnectiveTaskStagingTrigger = false;
    public static void skipConnectiveTaskStagingTrigger(boolean bSkip) {        
        skipConnectiveTaskStagingTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipConnectiveTaskStagingTrigger() {
        return skipConnectiveTaskStagingTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipConnectiveTaskTrigger = false;
    public static void skipConnectiveTaskTrigger(boolean bSkip) {        
        skipConnectiveTaskTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipConnectiveTaskTrigger() {
        return skipConnectiveTaskTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipARRTrigger = false;
    public static void skipARRTrigger(boolean bSkip) {
        skipARRTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipARRTrigger() {
        return skipARRTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipSIPPayoutCurveTrigger = false;
    public static void skipSIPPayoutCurveTrigger( boolean bSkip ) {        
        skipSIPPayoutCurveTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSIPPayoutCurveTrigger() {
        return skipSIPPayoutCurveTrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    * @return boolean 
    **/
    private static boolean skipSIPPayoutCurveBDATrigger = false;
    public static void skipSIPPayoutCurveBDATrigger( boolean bSkip ) {        
        skipSIPPayoutCurveBDATrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSIPPayoutCurveBDATrigger() {
        return skipSIPPayoutCurveBDATrigger;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    * @return boolean 
    **/
    private static boolean skipSIPMeasureTrigger= false;
    public static void skipSIPMeasureTrigger( boolean bSkip ) {        
        skipSIPMeasureTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipSIPMeasureTrigger() {
        return skipSIPMeasureTrigger;
    }
      /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-06-2022 
    * @param bSkip 
    **/
    private static boolean skipMaerskIdeaVoteTrigger = false;
    public static void skipMaerskIdeaVoteTrigger(boolean bSkip) {        
        skipMaerskIdeaVoteTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-06-2022 
    * @return boolean 
    **/
    public static boolean skipMaerskIdeaVoteTrigger() {
        return skipMaerskIdeaVoteTrigger;
    }
        /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @param bSkip 
    **/
    private static boolean skipChatTranscriptTrigger = false;
    public static void skipChatTranscriptTrigger(boolean bSkip) {
        skipChatTranscriptTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipChatTranscriptTrigger() {
        return skipChatTranscriptTrigger;
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 07-14-2022 
    * @param bSkip 
    **/
    private static boolean skipAIUpdateRecordEventTrigger = false;
    public static void skipAIUpdateRecordEventTrigger(boolean bSkip) {
        skipAIUpdateRecordEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 07-14-2022 
    * @return boolean 
    **/
    public static boolean skipAIUpdateRecordEventTrigger() {
        return skipAIUpdateRecordEventTrigger;
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-06-2022 
    * @param bSkip 
    **/
    private static boolean skipCustomerEventTrigger = false;
    public static void skipCustomerEventTrigger( boolean bSkip ) {        
        skipCustomerEventTrigger = bSkip;
    }


    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 25-04-2024
    * @param bSkip 
    **/
    private static boolean skipOpportunityScoreEventTrigger = false;
    public static void skipOpportunityScoreEventTrigger( boolean bSkip ) {        
        skipOpportunityScoreEventTrigger = bSkip;
    }
    
       /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 25-04-2024
    * @return boolean 
    **/
    public static boolean skipOpportunityScoreEventTrigger() {
        return skipOpportunityScoreEventTrigger;
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-06-2022 
    * @param bSkip 
    **/
    private static boolean skipContactEventTrigger = false;
    public static void skipContactEventTrigger( boolean bSkip ) {        
        skipContactEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-06-2022 
    * @return boolean 
    **/
    public static boolean skipCustomerEventTrigger() {
        return skipCustomerEventTrigger;
    }
    
     /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-06-2022 
    * @return boolean 
    **/
    public static boolean skipContactEventTrigger() {
        return skipContactEventTrigger;
    }
    
    private static boolean skipOpportunityLineItemSchedule = false;
    public static void skipOpportunityLineItemSchedule( boolean bSkip ) {        
        skipOpportunityLineItemSchedule = bSkip;
    }
     public static boolean skipOpportunityLineItemSchedule() {
        return skipOpportunityLineItemSchedule;
    }
    private static boolean skipActionTrigger =false;
    public static void skipActionTrigger(boolean bskip){
        skipActiontrigger = bskip;
    }
    public static boolean skipActionTrigger(){
        return skipActionTrigger;
    }
    
     /**
    * @description 
    * @author Vazid | 16-12-2022 
    * @param bSkip 
    **/
    private static boolean skipConcernEventTrigger = false;
    public static void skipConcernEventTrigger( boolean bSkip ) {        
        skipConcernEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author Vazid | 16-12-2022 
    * @return boolean 
    **/
    public static boolean skipConcernEventTrigger() {
        return skipConcernEventTrigger;
    }
    
      /**
    * @description 
    * @author Vazid | 16-12-2022 
    * @param bSkip 
    **/
    private static boolean skipNegotiationEventTrigger = false;
    public static void skipNegotiationEventTrigger( boolean bSkip ) {        
        skipNegotiationEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author Vazid | 16-12-2022 
    * @return boolean 
    **/
    public static boolean skipNegotiationEventTrigger() {
        return skipNegotiationEventTrigger;
    }
    
      /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-06-2022 
    * @param bSkip 
    **/
    private static boolean skipArchivedCaseTrigger = false;
    public static void skipArchivedCaseTrigger(boolean bSkip) {        
        skipArchivedCaseTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-06-2022 
    * @return boolean 
    **/
    public static boolean skipArchivedCaseTrigger() {
        return skipArchivedCaseTrigger;
    }
    
          /**
    * @description : SFSE-10986
    * @author sriram.kalluri@maersk.com | 17-05-2023 
    * @param bSkip 
    **/
    private static boolean skipOpportunityProductSchedule = false;
    public static void skipOpportunityProductSchedule(boolean bSkip) {        
        skipOpportunityProductSchedule= bSkip;
    }
    /**
    * @description : SFSE-10986
    * @author sriram.kalluri@maersk.com | 17-05-2023  
    * @return boolean 
    **/
    public static boolean skipOpportunityProductSchedule() {
        return skipOpportunityProductSchedule;
    }
            /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-06-2023 
    * @param bSkip 
    **/
    private static boolean skipOceanPlusLeadTrigger = false;
    public static void skipOceanPlusLeadTrigger(boolean bSkip) {        
        skipOceanPlusLeadTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 19-06-2023 
    * @return boolean 
    **/
    public static boolean skipOceanPlusLeadTrigger() {
        return skipOceanPlusLeadTrigger;
    }

    /**
    * @description  : SFSE-11111
    * @author Vazid | 04-07-2023 
    * @param bSkip 
    **/
    private static boolean skipEmployeeHRDataTrigger = false;
    public static void skipEmployeeHRDataTrigger( boolean bSkip ) {        
        skipEmployeeHRDataTrigger = bSkip;
    }
    /**
    * @description  : SFSE-11111
    * @author Vazid | 04-07-2023 
    * @return boolean 
    **/
    public static boolean skipEmployeeHRDataTrigger() {
        return skipEmployeeHRDataTrigger;
    }
        
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 23-08-2023 
    * @param bSkip 
    **/
    private static boolean skipOceanPlusLineItemTrigger = false;
    public static void skipOceanPlusLineItemTrigger(boolean bSkip) {        
        skipOceanPlusLineItemTrigger= bSkip;
    } 

     /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 23-08-2023 
    * @return boolean 
    **/
    public static boolean skipOceanPlusLineItemTrigger() {
        return skipOceanPlusLineItemTrigger;
    } 
        
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 23-08-2023 
    * @return boolean 
    **/
    private static boolean skipMessagingSessionTrigger = false;
    public static void skipMessagingSessionTrigger(boolean bSkip) {
        skipMessagingSessionTrigger = bSkip;
    }
     /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 04-21-2022 
    * @return boolean 
    **/
    public static boolean skipMessagingSessionTrigger() {
        return skipMessagingSessionTrigger;
    }
    
        /**
    * @description :SC-9041
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11-09-2023 
    * @param bSkip 
    **/
    private static boolean skipShipmentTrigger = false;
    public static void skipShipmentTrigger(boolean bSkip) {        
        skipShipmentTrigger= bSkip;
    } 

     /**
    * @description :SC-9041
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 11-09-2023 
    * @return boolean 
    **/
    public static boolean skipShipmentTrigger() {
        return skipShipmentTrigger;
    }
    
    /**
    * @description  : SFSE-11771
    * @author Jothsana | 14-09-2023 
    * @param bSkip 
    **/
    private static boolean skipApprovalHistoryTrigger = false;
    public static void skipApprovalHistoryTrigger( boolean bSkip ) {        
        skipApprovalHistoryTrigger = bSkip;
    }
    /**
    * @description  : SFSE-11771
    * @author  Jothsana | 14-09-2023 
    * @return boolean 
    **/
    public static boolean skipApprovalHistoryTrigger() {
        return skipApprovalHistoryTrigger;
    }
    
    /**
    * @description  : SFSE-12888
    * @author Aleena | 10-10-2023 
    * @param bSkip 
    **/
    private static boolean skipOfferinformationTrigger = false;
    public static void skipOfferinformationTrigger( boolean bSkip ) {        
        skipOfferinformationTrigger = bSkip;
    }
    /**
    * @description  : SFSE-12888
    * @author  Aleena | 10-10-2023  
    * @return boolean 
    **/
    public static boolean skipOfferinformationTrigger() {
        return skipOfferinformationTrigger;
    }
 
    /**
    * @description  : SFSE-12888
    * @author Aleena | 10-10-2023 
    * @param bSkip 
    **/
    private static boolean skipOpportunityFileTrigger = false;
    public static void skipOpportunityFileTrigger( boolean bSkip ) {        
        skipOpportunityFileTrigger = bSkip;
    }
    /**
    * @description  : SFSE-12888
    * @author  Aleena | 10-10-2023  
    * @return boolean 
    **/
    public static boolean skipOpportunityFileTrigger() {
        return skipOpportunityFileTrigger;
    }
    
    /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @param bSkip 
    **/
    private static boolean skipBookingInformationTrigger = false;
    public static void skipBookingInformationTrigger(boolean bSkip) {        
        skipBookingInformationTrigger = bSkip;
    } 
    
     /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @return boolean 
    **/
    public static boolean skipBookingInformationTrigger() {
        return skipBookingInformationTrigger;
    } 
    
    /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @param bSkip 
    **/
    private static boolean skipExternalPartyTrigger = false;
    public static void skipExternalPartyTrigger(boolean bSkip) {        
        skipExternalPartyTrigger = bSkip;
    } 
    
     /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @return boolean 
    **/
    public static boolean skipExternalPartyTrigger() {
        return skipExternalPartyTrigger;
    } 
    
    /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @param bSkip 
    **/
    private static boolean skipEquipmentCommodityTrigger = false;
    public static void skipEquipmentCommodityTrigger(boolean bSkip) {        
        skipEquipmentCommodityTrigger = bSkip;
    } 
    
     /**
    * @description :SC-9293
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @return boolean 
    **/
    public static boolean skipEquipmentCommodityTrigger() {
        return skipEquipmentCommodityTrigger;
    }
    
        /**
    * @description :SC-9582
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @param bSkip 
    **/
    private static boolean skipPartyTrigger = false;
    public static void skipPartyTrigger(boolean bSkip) {        
        skipPartyTrigger= bSkip;
    }

    /**
    * @description :SC-9582
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 22-12-2023 
    * @return boolean 
    **/
    public static boolean skipPartyTrigger() {
        return skipPartyTrigger;
    } 
    
            /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 25-01-2024 
    * @param bSkip 
    **/
    private static boolean skipCareTrigger = false;
    public static void skipCareTrigger(boolean bSkip) {        
        skipCareTrigger= bSkip;
    }
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 25-01-2024 
    * @return boolean 
    **/
    public static boolean skipCareTrigger() {
        return skipCareTrigger;
    }
    
    /**
    @description : SFSE-13010
    @author : Arpitha
    ***/
    public static Boolean isRun = true;
    public static Boolean isMeasureTriggerSkip=true;
	public static Boolean isTargetItemTriggerSkip = false;


      /**
    * @description 
    * @author Samar | 25-03-2024 
    * @param bSkip 
    **/
    private static boolean skipNegotiationRoundEventTrigger = false;
    public static void skipNegotiationRoundEventTrigger( boolean bSkip ) {        
        skipNegotiationRoundEventTrigger = bSkip;
    }
    /**
    * @description 
    * @author Samar | 25-03-2024 
    * @return boolean 
    **/
    public static boolean skipNegotiationRoundEventTrigger() {
        return skipNegotiationRoundEventTrigger;
    }
     /**
    * @description 
    * @author Ranjan | 30-05-2024 
    * @return boolean 
    **/
    private static boolean skipEngagementTrackerTrigger = false;
    public static void skipEngagementTrackerTrigger( boolean bSkip ) {        
        skipEngagementTrackerTrigger = bSkip;
    }
     /**
    * @description 
    * @author Ranjan | 30-05-2024 
    * @return boolean 
    **/
    public static boolean skipEngagementTrackerTrigger() {
        return skipEngagementTrackerTrigger;
    }
    
}