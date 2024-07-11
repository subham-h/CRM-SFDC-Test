/*
 * Created By   : Vivek@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Case Recommendation trigger.
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-8489   08-Aug-2023  Vivek@Maersk            Trigger Handler on Case Recommendation Object
 * 2.0      #SC-10036  17-May-2024  Vazid            		Added after insert context
*/

public class CaseRecommendationTriggerHandler extends TriggerHandler {
 	public map<Id, Case_Recommendation__C> newMap;
    public map<Id, Case_Recommendation__C> oldMap;
	public CaseRecommendationRecordSelector caseRecomRecordSelector;
    
    public CaseRecommendationTriggerHandler() {
        this.newMap = (map<Id, Case_Recommendation__C>)Trigger.newMap;
        this.oldMap = (map<Id, Case_Recommendation__C>)Trigger.oldMap;
    }
    
    public override void getRecordSelector() {
        if (caseRecomRecordSelector == null){
            caseRecomRecordSelector = new CaseRecommendationRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
    
     public override void onBeforeInsert() {
         //To delete existing recommendations if we receive gen2 recommendation in re-trigger scenario
		if(!caseRecomRecordSelector.setOfExistingRecommCaseIds.isEmpty()){
             CaseRecommendationManager.getExistingRecommList(caseRecomRecordSelector.setOfExistingRecommCaseIds);
         }
         
        // Generic Case Recommendation field population logic on before insert
         if(!caseRecomRecordSelector.lstOfNonHoldCRlist.isEmpty()) {
             CaseRecommendationManager.formatEmailRecommendationOnBeforeInsert(caseRecomRecordSelector.lstOfNonHoldCRlist, caseRecomRecordSelector.setOfExistingRecommCaseIds);
         }
         
         /*Update Case owner to checker queue if recommendation Action Status = Hold*/
         if(!caseRecomRecordSelector.setOfHoldCaseIds.isEmpty()){
             CaseRecommendationManager.updateCaseRecordsWithCheckerQueue(caseRecomRecordSelector.setOfHoldCaseIds);
         }
         
         /*Update Case owner to original queue if recommendation Action Status = Released*/
         if(!caseRecomRecordSelector.setOfReleasedCaseIds.isEmpty()){
             CaseRecommendationManager.updateCaseRecordsToRemoveCheckerQueue(caseRecomRecordSelector.setOfReleasedCaseIds);
         }
        
     }
    
    public override void onAfterInsert() {
        /*Delete Case recommendation records if we get any recommendation for Action Status = Hold or Released
          Note : Deleting explicitly because IDA team is using standard API we cannot skip logic for specific records*/
        if(!caseRecomRecordSelector.lstOfHoldorReleasedCRlist.isEmpty()) {
            CaseRecommendationManager.deleteCaseRecommRecords(caseRecomRecordSelector.lstOfHoldorReleasedCRlist);
        }
    }
}