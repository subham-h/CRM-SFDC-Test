/*
* Revision Ref Number  Date        Owner                                      	Description
* -------- ----------  ----------- --------------------------------------     	-----------
* 1.0      #SP-0032     7/11/2014   Vivek Menon									Created
* 2.0 	   #RQ-003127  14/03/2016	Ranjini.Janardhanan@ust-global.com			Convert Approved Amount to USD
* 3.0      #RQ-007189  21/02/2019   Meghana.Gupta@UST          					Code converted to Signle trigger model
* 4.0      SC-9293     22-12-2023   Shahanawaz@maersk      						Create feeditem on parent Case
*/

public class ApprovalRequestTriggerHandler extends TriggerHandler {
    
    public map<Id, Approval_Request__c> newMap;
    public map<Id, Approval_Request__c> oldMap;
    
    public ApprovalRequestTriggerHandler() {
        this.newMap = (map<Id, Approval_Request__c>)trigger.newMap;
        this.oldMap = (map<Id, Approval_Request__c>)trigger.oldMap; 
    }
    
    public ApprovalRequestRecordSelector recordSelector;
    
    public override void getRecordSelector() {
        recordSelector = new ApprovalRequestRecordSelector( trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {  
        
         // Calcualte Requested/Approved amount to standard currency
         if ( !recordSelector.lstCalculateStdCurrency.IsEmpty())
            ApprovalRequestUtilities.calculateStandardCurrency(recordSelector.lstCalculateStdCurrency, this.oldMap);        
    }
    
    public override void onBeforeUpdate() {    
        
        // Calcualte Requested/Approved amount to standard currency
        if ( !recordSelector.lstCalculateStdCurrency.IsEmpty())
            ApprovalRequestUtilities.calculateStandardCurrency(recordSelector.lstCalculateStdCurrency, this.oldMap);
    }
    
    public override void onAfterInsert(){
        if(!recordSelector.appReqList.isEmpty()){
            ApprovalRequestUtilities.createFeedItem(recordSelector.appReqList);
        }
    }
}