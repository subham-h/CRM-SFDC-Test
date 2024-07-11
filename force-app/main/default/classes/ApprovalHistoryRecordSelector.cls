/*
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0			SFSE-12409	05/09/2023		Jothsana@Maersk			To select records from Approval_History__c for stamping opportunity product id and submission order on history Record
*/
public class ApprovalHistoryRecordSelector {
    public List<Approval_History__c> lstaphforolistamping = new List<Approval_History__c>();
    public List<Approval_History__c> lstaphforSubmissionorder = new List<Approval_History__c>();
    public ApprovalHistoryRecordSelector(list<Approval_History__c> lstNewaphRec, TriggerHandler ApprovalHistoryhandler){
        try{
            if(!lstNewaphRec.isEmpty()){
                for(Approval_History__c lstaph : lstNewaphRec){
                    if(ApprovalHistoryhandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && ApprovalHistoryhandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                        lstaphforolistamping.add(lstaph);
                    }
                    if(ApprovalHistoryhandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && ApprovalHistoryhandler.trigType == TriggerHandler.TriggerType.ISBEFORE && (lstaph.Type__c == 'Initial submission' || lstaph.Type__c == null)){
                        lstaphforSubmissionorder.add(lstaph);
                    }
                }
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Approval_History__c', 'ApprovalHistoryRecordSelector', new list<Exception>{e});
        }
    }
}