/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-007192       20-02-2019     Junaid.Khader@ust-global.com         Code created
*/
public class CampaignMemberRecordSelector implements RecordSelector {
    private TriggerHandler CampaignMemberTriggerHandler;
    public Set<Id> setAssociatedContactIds = new Set<Id>();
    public Set<Id> setAssociatedLeadIds = new Set<Id>();
    public Set<Id> setAssociatedLeadOfDeletedCampaignIds = new Set<Id>();
    public Set<Id> setAssociatedCampaignIds = new Set<Id>();
    
    public CampaignMemberRecordSelector(List<CampaignMember> listCampaignMember, Map<Id, CampaignMember> mapOldCampaignMember, CampaignMemberTriggerHandler CampMemberTriggerHandler) {
        this.CampaignMemberTriggerHandler = CampMemberTriggerHandler;
        selectRecords(listCampaignMember, mapOldCampaignMember);
    }
    
    public void selectRecords(List<CampaignMember> listCampaignMember, Map<Id, SObject> mapOldCampaignMember) {
        CampaignMember oldCampaignMember;
        
        if((CampaignMemberTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) && ((CampaignMemberTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) || (CampaignMemberTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE))){
            if(listCampaignMember.size() > 0){
                for(CampaignMember rowCampaignMember : listCampaignMember){
                    if(rowCampaignMember.ContactId != null)
                        setAssociatedContactIds.add(rowCampaignMember.ContactId);
                    if((CampaignMemberTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) && (rowCampaignMember.LeadId != null))
                        setAssociatedLeadIds.add(rowCampaignMember.LeadId);
                }
            }
        }
        if((CampaignMemberTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) && (CampaignMemberTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE)){
            if(mapOldCampaignMember.size() > 0){
                for(SObject rowCampaignMember : mapOldCampaignMember.values()) {
                    oldCampaignMember = (CampaignMember)rowCampaignMember;
                    if(oldCampaignMember.CampaignId != null)
                        setAssociatedCampaignIds.add(oldCampaignMember.CampaignId);
                    if(oldCampaignMember.LeadId != null)
                        setAssociatedLeadOfDeletedCampaignIds.add(oldCampaignMember.LeadId);
                }
            }
        }
        getRelatedRecords(listCampaignMember);
    }
    
    public void getRelatedRecords(List<SObject> listCampaignMember) {
    
    }
}