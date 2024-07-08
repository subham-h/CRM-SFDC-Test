/*
 *        
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      #RQ-008579  22-May-2018     meghana.gupta@ust-global.com            Code created
 * 2.0      #RQ-009529  13-Dec-2018     Junaid.Khader@ust-global.com            Separated methods for handling invocation from batch as well.                              
 * 3.0.     SFSE-5268   03-Dec-2020     meghana.gupta@ust                       Add checks for Account/Brand/Role uniqueness for Portfolios
 * 4.0      SFSE-5787   12-Apr-2021     Kiran@Maersk                            Stop Territory and Cluster Code fields from being populated on Opportunity
 * 5.0      SFSE-6978   10-Oct-2021     Kiran@Maersk                            SIP-2022 Area SOMs configure portfolio territory account assignments
 * 6.0      SFSE-9317   07-Nov-2022     meghana.gupta@ust                       Duplicate check for Lead Account Owner & Single brand check
 * 7.0      SFSE-11889  28-Jul-2023     Shubham@Maersk                          Populate TAA Fields                                
 * 8.0      SFSE-12093  14-Aug-2023     Shubham@Maersk                          Commenting portfolioOwnerBrandCheck method as removing brand check
 * 9.0      SFSE-11477  01-Nov-2023     Vinay                                   Added Code for updating Customer Portfolio Assigned on After Insert and on After Update
 * 10.0     SFSE-13491  14-dec-2023     Bharti                                  Remove hardcoding of Portfolio owner Responsibility
 * 11.0     SFSE-13392  11-Jan-2024     Bharti/Aditi                            Added code to Trigger Delection of Tcp method
*/

public class TerritoryAccAssociationTriggerHandler extends TriggerHandler {

    public map<Id, Territory_Account_Association__c> newMap;
    public map<Id, Territory_Account_Association__c> oldMap;
    public List<Territory_Account_Association__c> newList;
    public TerritoryAccAssociationTriggerHandler() {
        
        this.newMap = ( map<Id, Territory_Account_Association__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Territory_Account_Association__c> ) Trigger.oldMap;
        this.newList = (List<Territory_Account_Association__c>) Trigger.new;  
    }
    
    // Get valid records based on criteria
    public TerritoryAccAssociationRecordSelector terAccAssocRecordSelector;
    public override void getRecordSelector() {
        terAccAssocRecordSelector = new TerritoryAccAssociationRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        
        TerritoryAccountAssociationUtility.populateTAAFields(this.newList);
        
        /*if(terAccAssocRecordSelector.lstBrandCheck.size() > 0){
            TerritoryAccountAssociationUtility.portfolioOwnerBrandCheck(terAccAssocRecordSelector.lstBrandCheck);
        }*/
        
        if(terAccAssocRecordSelector.lstDupCheck_GloablAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_GloablAccountOwner,TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER, Label.PortfolioUniqueCheck_Error1 );
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesControl.size() > 0){
        TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesControl, Label.Sales_Owner_Role, Label.PortfolioUniqueCheck_Error2);
        TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesControl, Label.Sales_Owner_Role, Label.PortfolioUniqueCheck_Error2);
        }

        if(terAccAssocRecordSelector.lstDupCheck_Influencer.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_Influencer, TAASettingConstants.POR_Influencer_Only, Label.PortfolioUniqueCheck_Error8);
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly, TAASettingConstants.POR_SALES_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error4);
            TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly, TAASettingConstants.POR_SALES_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error2);
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly,TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error5);
            TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error2);
        }
        if(terAccAssocRecordSelector.lstDupCheck_LeadAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_LeadAccountOwner,TAASettingConstants.POR_Lead_Account_Owner_Only, Label.PortfolioUniqueCheck_Error6 );
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_GlobalLeadAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_GlobalLeadAccountOwner,TAASettingConstants.POR_Global_Lead_Account_Owner_Only, Label.PortfolioUniqueCheck_Error7 );
        }
        
        if(terAccAssocRecordSelector.lstsingleBrandCheck.size() > 0){
            TerritoryAccountAssociationUtility.singleBrandCheck(terAccAssocRecordSelector.lstsingleBrandCheck,TAASettingConstants.POR_Lead_Account_Owner_Only, Label.PortfolioSingleBrandCheck_Error );
        }
        
        TerritoryAccountAssociationUtility.accountCheck(this.newList);

    }
    
     public override void onBeforeUpdate() {
         
        /*if(terAccAssocRecordSelector.lstBrandCheck.size() > 0){
            TerritoryAccountAssociationUtility.portfolioOwnerBrandCheck(terAccAssocRecordSelector.lstBrandCheck);
        }*/
        
        if(terAccAssocRecordSelector.lstDupCheck_GloablAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_GloablAccountOwner, TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER, Label.PortfolioUniqueCheck_Error1 );
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesControl.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesControl, Label.Sales_Owner_Role, Label.PortfolioUniqueCheck_Error2);
            TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesControl, Label.Sales_Owner_Role, Label.PortfolioUniqueCheck_Error2);
        }
         
         if(terAccAssocRecordSelector.lstDupCheck_Influencer.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_Influencer, TAASettingConstants.POR_Influencer_Only, Label.PortfolioUniqueCheck_Error8);
         } 
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly, TAASettingConstants.POR_SALES_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error4);
            TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesControlOnly,TAASettingConstants.POR_SALES_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error2);
        }
        
        if(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly,TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error5);
            TerritoryAccountAssociationUtility.portfolioUniqueRespCheckCombo(terAccAssocRecordSelector.lstDupCheck_SalesNonControlOnly,TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, Label.PortfolioUniqueCheck_Error2);
        }
         
        if(terAccAssocRecordSelector.lstDupCheck_LeadAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_LeadAccountOwner, TAASettingConstants.POR_Lead_Account_Owner_Only, Label.PortfolioUniqueCheck_Error6 );
        }
        
         if(terAccAssocRecordSelector.lstDupCheck_GlobalLeadAccountOwner.size() > 0){
            TerritoryAccountAssociationUtility.portfolioUniqueResponsibilityCheck(terAccAssocRecordSelector.lstDupCheck_GlobalLeadAccountOwner, TAASettingConstants.POR_Global_Lead_Account_Owner_Only, Label.PortfolioUniqueCheck_Error7 );
         }
         
        if(terAccAssocRecordSelector.lstsingleBrandCheck.size() > 0){
            TerritoryAccountAssociationUtility.singleBrandCheck(terAccAssocRecordSelector.lstsingleBrandCheck, TAASettingConstants.POR_Lead_Account_Owner_Only, Label.PortfolioSingleBrandCheck_Error );
        }
         
    }
    // SFSE-11477
    public override void onAfterInsert(){
        if(!terAccAssocRecordSelector.lstTaaForCreditEligibility.isEmpty()){            
            TerritoryAccountAssociationUtility.updateCreditEligibility(terAccAssocRecordSelector.lstTaaForCreditEligibility);
    }}
    // SFSE-11477
    public override void onAfterUpdate(){
       if(!terAccAssocRecordSelector.lstTaaForCreditEligibility.isEmpty()){
        TerritoryAccountAssociationUtility.updateCreditEligibility(terAccAssocRecordSelector.lstTaaForCreditEligibility);
        }
    //SFSE-13392- To delete corresponding TCPS when TAA is modified
        if(!terAccAssocRecordSelector.lstTAAForTCPDeletion.isEmpty() || !terAccAssocRecordSelector.lstTAABrandUpdate.isEmpty()){
            TargetAssignmentUtility.deleteTcpRecords(terAccAssocRecordSelector.lstTAAForTCPDeletion, terAccAssocRecordSelector.lstTAABrandUpdate);
        }
    }
     public override void onBeforeDelete(){
        //SFSE-13392- To delete corresponding TCPS when TAA is deleted
        if(!terAccAssocRecordSelector.lstTAAForTCPDeletion.isEmpty() || !terAccAssocRecordSelector.lstTAABrandUpdate.isEmpty()){
            TargetAssignmentUtility.deleteTcpRecords(terAccAssocRecordSelector.lstTAAForTCPDeletion, terAccAssocRecordSelector.lstTAABrandUpdate);
			
        }
        
    }
    
}