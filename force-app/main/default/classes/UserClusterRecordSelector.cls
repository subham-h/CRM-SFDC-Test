/*              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -----------------       -----------
 * 1.0      SFSE-6847   15-09-2021  Sidhartha@maersk        Created Code.
*/
public class UserClusterRecordSelector implements RecordSelector{
    private TriggerHandler usrclusterTriggerHandler; 
    List <Id> usrId = new List <Id> ();
    public Map < Id,Id > mapofUserCluster = new Map < Id,Id > ();
    
    public UserClusterRecordSelector(list<User_Cluster__c> lstUserCluster, map<Id, User_Cluster__c> mapOldUserClusters, UserClusterTriggerHandler usrclusterTriggerHandler) {
        this.usrclusterTriggerHandler = usrclusterTriggerHandler;
        selectRecords(lstUserCluster, mapOldUserClusters);
    }
    
    public void getRelatedRecords(list<User_Cluster__c> lstUserCluster) {
        
    }
    
    public void selectRecords(list<User_Cluster__c> lstlstUserClusters, map<Id, sObject> mapOldUserClusters) {
        for(User_Cluster__c usrClu : lstlstUserClusters) {
            User_Cluster__c oldUsrCluster;
            if(usrclusterTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                if(usrclusterTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(usrClu.User__c !=null) {
                        usrId.add(usrClu.User__c);
                    }
                }else if( usrclusterTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE ) {
                    oldUsrCluster = (User_Cluster__c)mapOldUserClusters.get(usrClu.Id);
                    if(usrClu.User__c !=null && usrClu.User__c != oldUsrCluster.User__c){
                        usrId.add(usrClu.User__c);  
                    }
                }
            }   
        }
        List<User_Cluster__c> existinClusters=[select Id, BDA__c,User__c  from User_Cluster__c where User__c in : usrId];
        for (User_Cluster__c uCluster : existinClusters) {
            mapofUserCluster.put(uCluster.User__c, uCluster.BDA__c );
        }
    }
}