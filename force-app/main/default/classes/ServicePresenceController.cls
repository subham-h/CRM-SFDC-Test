/*
* Controller for searching ISR templates
* 
*Version    Date        Owner                  RQ#           Description
*********************************************************************************************************************************  
1.0       02-05-2024    Shahanawaz@Maersk      SC-9994       Nudge Omni Onboarded Agents when case offline
*/
public class ServicePresenceController {
    
    /** 
* @description | check presence status of current user
* @return Boolean
* SC-9994 
*/
    @AuraEnabled
    public static Boolean getServiceStatus(){
        String emailPresenceStatusDevName = Constants.emailPresenceStatusDevName;
        List<PermissionSetAssignment> pmAssignmentList = new List<PermissionSetAssignment>([Select Id From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: emailPresenceStatusDevName]);
        Id recordTypeId = Constants.Maersk_Admin_Omni_Nudge_RTId;
        if(pmAssignmentList.isEmpty()){
            return false;
        }
        else{
            List<UserServicePresence> usPresenceList = new List<UserServicePresence>([SELECT Id, IsCurrentState, IsAway FROM UserServicePresence Where UserId =: UserInfo.getUserId() Order by CreatedDate DESC LIMIT 1]);
            if(!usPresenceList.isEmpty() && !Constants.servicePresenceTest){
                if(usPresenceList[0].IsAway || (!usPresenceList[0].IsCurrentState && !usPresenceList[0].IsAway)){
                    List<Maersk_Admin_Configuration__c> macList = new List<Maersk_Admin_Configuration__c>([Select Id, Record_Id__c, Show_Nudge__c From Maersk_Admin_Configuration__c Where RecordTypeId =: recordTypeId AND Record_Id__c =: UserInfo.getUserId()]);
                    if(macList.isEmpty()){
                        Maersk_Admin_Configuration__c mac = new Maersk_Admin_Configuration__c();
                        mac.Record_Id__c = UserInfo.getUserId();
                        mac.Show_Nudge__c = false;
                        mac.RecordTypeId = recordTypeId;
                        insert mac;
                        return true;
                    }
                    else if(macList[0].Show_Nudge__c){
                        macList[0].Show_Nudge__c = false;
                        update macList;
                        return true;
                    }
                    return false;
                }
            }
            else{
                List<Maersk_Admin_Configuration__c> macList = new List<Maersk_Admin_Configuration__c>([Select Id, Record_Id__c, Show_Nudge__c From Maersk_Admin_Configuration__c Where RecordTypeId =: recordTypeId AND Record_Id__c =: UserInfo.getUserId()]);
                if(macList.isEmpty()){
                    Maersk_Admin_Configuration__c mac = new Maersk_Admin_Configuration__c();
                    mac.Record_Id__c = UserInfo.getUserId();
                    mac.Show_Nudge__c = false;
                    mac.RecordTypeId = recordTypeId;
                    insert mac;
                    return true;
                }
                else if(macList[0].Show_Nudge__c){
                    macList[0].Show_Nudge__c = false;
                    update macList;
                    return true;
                }
            }
        }
        return false;
    }
    
}