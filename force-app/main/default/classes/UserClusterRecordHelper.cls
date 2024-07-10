/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFSE-6847   15-09-2021  Sidhartha@maersk        Created Code.
*/
public class UserClusterRecordHelper {
    public static void validateNoDuplicateUserCluster(list<User_Cluster__c> lstlstUserClusters, Map < Id,Id > mapofUserCluster){
        for (User_Cluster__c uCluster : lstlstUserClusters) {
            if (mapofUserCluster.containskey(uCluster.User__c)) {
                uCluster.addError('This user already exists. You Can not add duplicate user records.');
            }
        }
    }
}