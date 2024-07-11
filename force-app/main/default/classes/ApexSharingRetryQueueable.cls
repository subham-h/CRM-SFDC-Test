/*
* Author   : Richa@Maersk
* Purpose  : Queuable retry class for apex sharing 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-4859     12-04-2022  Richa@Maersk            Queuable retry class for apex sharing 
*/
public class ApexSharingRetryQueueable implements Queueable{
    public Set<Id> setRecordIds;
    public String objName;
    public String key;
    public String accessLevel;
    public String rowCause;
    public Boolean isUpdate;
    public Integer count; 
    public ApexSharingRetryQueueable(Set<Id> setRecordIds, String objName,String key, String accessLevel, String rowCause, Boolean isUpdate,Integer count) {
        this.setRecordIds = setRecordIds;
        this.objName = objName;
        this.key = key;
        this.accessLevel = accessLevel;
        this.rowCause = rowCause;
        this.isUpdate = isUpdate;
        this.count = count;
    }
    public void execute(QueueableContext context) {
        General_Settings__c gs =General_Settings__c.getInstance(); 
        Boolean isFailed = false;
        isFailed = ApexSharingUtility.createShareRecord(setRecordIds,objName,key,accessLevel,rowCause,isUpdate); 
        if(isFailed && gs.Apex_Sharing_Retry_status__c && count <  gs.Apex_Sharing_Retry_Count__c ){ 
            count++;
            System.enqueueJob(new ApexSharingRetryQueueable(setRecordIds,objName,key,accessLevel,rowCause,isUpdate,count));       
        }
    }
}