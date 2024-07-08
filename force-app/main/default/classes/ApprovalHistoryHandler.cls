/*
* Test class : ApprovalHistoryTriggerTest
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0			SFSE-10929  08/07/2023		Jaya@UST				To Stamp Opportunity Id On Approval History Record.
* 2.0			SFSE-11771	24/08/2023		Jaya@UST				Extend Reject Notifications
* 3.0			SFSE-12409	05/09/2023		Jothsana@Maersk			Code Refinement
*/
public class ApprovalHistoryHandler extends TriggerHandler{
    //public static final String REJECTED = System.label.Status_Rejected;
    //public static final String NO_RESPONSE = System.label.Status_No_response;
    public map<Id, Approval_History__c> newMap;
    public map<Id, Approval_History__c> oldMap;
    public List<Opportunity> opptyMap;
    public set<Id> opptyId = new set<Id>();
    public set<Id> matrixId = new set<Id>();
    public List<Approval_Process_Escalation_Matrix__c> matrixMap;
    public ApprovalHistoryHandler(){
        system.debug('This method is called - approval history handler');
        
        this.newMap = (map<Id, Approval_History__c>)Trigger.newMap;
        this.oldMap = (map<Id, Approval_History__c>)Trigger.oldMap;
        
        if( trigger.isInsert ) {
            
            for(Approval_History__c newHistoryRec : (List<Approval_History__c>)trigger.new) {
                opptyId.add(newHistoryRec.TargetObjectId__c);
                matrixId.add(newHistoryRec.Approval_Step__c);
            }
        }
        if(opptyId.size() > 0) {
            opptyMap = new List<Opportunity>([SELECT id, Name, IsClosed,Products_for_approval__c,Requires_IT_Integration__c, StageName, Approval_Status__c,Requires_Custom_Integration__c, Must_Go_To_OMEB__c, RecordTypeId, RecordType.DeveloperName 
                                              FROM Opportunity WHERE Id IN: opptyId]);
        }
        
        if(!matrixId.isEmpty()){
            matrixMap = new List<Approval_Process_Escalation_Matrix__c>([SELECT Id, Product_for_approval__c,Active__c FROM  Approval_Process_Escalation_Matrix__c WHERE Id IN : matrixId AND Active__c = true]);
        }
    }
    public ApprovalHistoryRecordSelector AHRecordSelector;
    public override void getRecordSelector(){
        AHRecordSelector = new ApprovalHistoryRecordSelector(Trigger.new, this);
    }
    public override void onBeforeInsert() {
        if(AHRecordSelector.lstaphforolistamping.size() > 0){
            ApprovalHistoryUtilities.ApprovalHistoryOLIStamping(AHRecordSelector.lstaphforolistamping, opptyId, opptyMap, matrixMap);
        }
        if(AHRecordSelector.lstaphforSubmissionorder.size() > 0){
            ApprovalHistoryUtilities.ApprovalHistorySubmissionOrder(AHRecordSelector.lstaphforSubmissionorder, opptyId);
        }
    }
    
}