/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFSE-6847   15-09-2021  Sidhartha@maersk        Created Code.
*/
public class UserClusterTriggerHandler extends TriggerHandler {
    public map<Id, User_Cluster__c > newMap;
    public map<Id, User_Cluster__c > oldMap;
    public UserClusterTriggerHandler() {
        this.newMap = (map<Id, User_Cluster__c >)Trigger.newMap;
        this.oldMap = (map<Id, User_Cluster__c >)Trigger.oldMap; 
    }
    public UserClusterRecordSelector usrClusterRecordSelector;
    public override void getRecordSelector() {
        usrClusterRecordSelector = new UserClusterRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(usrClusterRecordSelector.mapofUserCluster !=null && usrClusterRecordSelector.mapofUserCluster.size() > 0) {
            UserClusterRecordHelper.validateNoDuplicateUserCluster(Trigger.new, usrClusterRecordSelector.mapofUserCluster);
        }
    }
    
    public override void onBeforeUpdate() {
        if(usrClusterRecordSelector.mapofUserCluster !=null && usrClusterRecordSelector.mapofUserCluster.size() > 0) {
            UserClusterRecordHelper.validateNoDuplicateUserCluster(Trigger.new, usrClusterRecordSelector.mapofUserCluster);
        }
    }
    
    public override void onAfterInsert() {}
    
    public override void onAfterUpdate() {}
    
    public override void onBeforeDelete() {}
    
}