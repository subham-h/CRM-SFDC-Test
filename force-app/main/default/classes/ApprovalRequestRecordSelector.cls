/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-007189   21-Feb-2019 Meghana.Gupta@UST       Code created
* 2.0      SC-9293     22-12-2023  Shahanawaz@maersk       Create feeditem on parent Case
*/

public class ApprovalRequestRecordSelector implements RecordSelector {
    
    private TriggerHandler trgHandler;
    public List<Approval_Request__c> lstCalculateStdCurrency = new List<Approval_Request__c>();
    public List<Approval_Request__c> appReqList = new List<Approval_Request__c>();
    
    public ApprovalRequestRecordSelector(list<Approval_Request__c> lstApprovalRequests, map<Id, Approval_Request__c> mapOldApprovalRequests, ApprovalRequestTriggerHandler appRequestTriggerHandler) {
        
        this.trgHandler = appRequestTriggerHandler;        
        selectRecords(lstApprovalRequests, mapOldApprovalRequests);
        getRelatedRecords(lstApprovalRequests);
    }
    
    public void selectRecords(list<Approval_Request__c> lstApprovalRequests, map<Id, sObject> mapOldApprovalRequests) {
        
        Approval_Request__c oldAppReq;        
        for (Approval_Request__c recAppReq : lstApprovalRequests){
            
            // if record is updated, get old record 
            if (mapOldApprovalRequests != null){
                oldAppReq = (Approval_Request__c) mapOldApprovalRequests.get(recAppReq.Id);
            }
            
            // On Insert when Amount is not null Or on Update when Amount is changed
            if ( trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && ( recAppReq.Requested_Amount__c != null || recAppReq.Approved_Amount__c != null)
            		&& ( trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || ( trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE 
                    && ( recAppReq.Requested_Amount__c != oldAppReq.Requested_Amount__c || recAppReq.Requested_Amount_Currency__c != oldAppReq.Requested_Amount_Currency__c
                    ||   recAppReq.Approved_Amount__c != oldAppReq.Approved_Amount__c || recAppReq.Approved_Amount_Currency__c != oldAppReq.Approved_Amount_Currency__c )))){
                
                lstCalculateStdCurrency.add(recAppReq);
            }
            
            //SC-9293
            if(trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                if(recAppReq.Case__c != null){
                    appReqList.add(recAppReq);
                }
            }
        }
        
    }
    
    public void getRelatedRecords(list<Approval_Request__c> lstApprovalRequests) {
        
    }    
}