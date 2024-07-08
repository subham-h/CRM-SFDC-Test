/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-004490   21-Jan-2019 Meghana.Gupta@UST       All Lead triggers moved to Signle trigger model
* 2.0      SFSE-5757   26-May-2021 nitin@maersk            Added after insert section
* 3.0      SFMC-7511   25-Jan-2024 ranjan@maersk           Identify Existing accounts for newly created and updated lead, & Giving visibility to their Sales Representatives - Apex changes
*/


public class LeadTriggerHandler extends TriggerHandler {
    
    public map<Id, Lead> newMap;
    public map<Id, Lead> oldMap;
      
    public LeadTriggerHandler() {
        this.newMap = (map<Id, Lead>)trigger.newMap;
        this.oldMap = (map<Id, Lead>)trigger.oldMap; 
    }
    
    public LeadRecordSelector recordSelector;
    
    public override void getRecordSelector() {
        recordSelector = new LeadRecordSelector( trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {  
        // populate OwnershipCluster field on insert 
        if ( !recordSelector.lstLeadsToAssignCluster.IsEmpty()) {
        	LeadUtilities.populateOwnershipCluster(recordSelector.lstLeadsToAssignCluster, this.oldMap);  
        }
        //SFMC-7511:-populate the Account__c and Account Confidence Score when the Lead is created
        List<Lead> unmappedLeadList=null;
        if ( !recordSelector.leadAccUpdtList.IsEmpty()) {
        	unmappedLeadList=DuplicateAccountUpdator.assignAccountWtEmail(recordSelector.leadAccUpdtList);
        }
        if(unmappedLeadList!=null && !unmappedLeadList.isEmpty()){
            DuplicateAccountUpdator.assignDuplicateAccounts(unmappedLeadList);
        }
        if(!recordSelector.emailIdLeadListMap.IsEmpty()){
            SoftRegistrationUtility.searchETs(recordSelector.emailIdLeadListMap);
        }
    }
    
    public override void onBeforeUpdate() {    
        // before converting lead check if oppty and contact liner brand are same
        if ( !recordSelector.lstConvertingLeads.IsEmpty()){
            LeadUtilities.validateLeadConversion(recordSelector.lstConvertingLeads);
        }
                
        // populate OwnershipCluster field if Onwer/Country is modified
        if ( !recordSelector.lstLeadsToAssignCluster.IsEmpty()) {
            LeadUtilities.populateOwnershipCluster(recordSelector.lstLeadsToAssignCluster, this.oldMap);
        }
        //SFMC-7511:-populate the Account__c and Account Confidence Score when the Lead is updated with
        //Company,Country_lk__c,PostalCode,Phone fields
        List<Lead> unmappedLeadList=null;
        if ( !recordSelector.leadAccUpdtList.IsEmpty()) {
        	unmappedLeadList=DuplicateAccountUpdator.assignAccountWtEmail(recordSelector.leadAccUpdtList);
        }
        if(unmappedLeadList!=null && !unmappedLeadList.isEmpty()){
            DuplicateAccountUpdator.assignDuplicateAccounts(unmappedLeadList);
        }
        //MEL related Changes
        if(!recordSelector.mELLeadMap.IsEmpty()) {
            LeadMELUpdator.updateToMEL(recordSelector.mELLeadMap, false);
        }
    }

    
    public override void onAfterInsert() {  
        if (!recordSelector.setLeadIdsToAssignIndividualId.isEmpty()){
            ConsentMgmtUtility.populateIndividualIdLead(recordSelector.setLeadIdsToAssignIndividualId);
        }
        if(!SoftRegistrationUtility.etMap.isEmpty()){
            SoftRegistrationUtility.updateETs(recordSelector.emailIdLeadListMap);
        }
    }
    
    public override void onAfterUpdate() {
        
        // if in before update trigger, Ownership cluster is assigned based on country then rerun assignment rules to assign correct owner queue
        if (! LeadRecordSelector.lstLeadIdsRerunAssignmentRules.IsEmpty()){
            //LeadUtilities.RerunAssignmentRules(LeadRecordSelector.lstLeadIdsRerunAssignmentRules);
            AssignLeadsUsingAssignmentRules.LeadAssign(LeadRecordSelector.lstLeadIdsRerunAssignmentRules);
        }
        if (! recordSelector.convertingLeadsMap.isEmpty()) {
            SoftRegistrationUtility.updateEtOnLeadConvert(recordSelector.convertingLeadsMap);
        }
    }
    
}