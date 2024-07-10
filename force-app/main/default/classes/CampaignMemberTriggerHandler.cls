/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-007192       20-02-2019     Junaid.Khader@ust-global.com         Code created
*/
public class CampaignMemberTriggerHandler extends TriggerHandler {
    public map<Id, CampaignMember> newMap;
    public map<Id, CampaignMember> oldMap;
    public CampaignMemberRecordSelector campMemberRecordSelector;
    
    public CampaignMemberTriggerHandler() {
        this.newMap = (map<Id, CampaignMember>)Trigger.newMap;
        this.oldMap = (map<Id, CampaignMember>)Trigger.oldMap; 
    }
    public override void getRecordSelector() {
        campMemberRecordSelector = new CampaignMemberRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if((campMemberRecordSelector.setAssociatedContactIds.size() > 0) || (campMemberRecordSelector.setAssociatedLeadIds.size() > 0)){
            CampaignMemberUtilities.populateAccountOwnerEmailAndUpdateLeads(Trigger.new, campMemberRecordSelector.setAssociatedContactIds, campMemberRecordSelector.setAssociatedLeadIds);
        }
    }
    
    public override void onBeforeUpdate() {
        if(campMemberRecordSelector.setAssociatedContactIds.size() > 0){
            CampaignMemberUtilities.populateAccountOwnerEmailAndUpdateLeads(Trigger.new, campMemberRecordSelector.setAssociatedContactIds, campMemberRecordSelector.setAssociatedLeadIds);
        }
    }
    
    public override void onBeforeDelete() {
        if(campMemberRecordSelector.setAssociatedLeadOfDeletedCampaignIds.size() > 0){
            CampaignMemberUtilities.resetPrimaryCampaignOnLeads(oldMap.values(), campMemberRecordSelector.setAssociatedLeadOfDeletedCampaignIds, campMemberRecordSelector.setAssociatedCampaignIds);
        }
    }
}