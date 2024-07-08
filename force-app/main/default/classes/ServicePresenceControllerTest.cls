/*
* Test class of ServicePresenceController Controller
* 
*Version    Date        Owner                  RQ#           Description
*********************************************************************************************************************************  
1.0       07-05-2024    Shahanawaz@Maersk      SC-9994       Test class of ServicePresenceController Controller
*/
@isTest(seeAllData = true)
public class ServicePresenceControllerTest {
    
    @isTest
    public static void testPresenceStatus(){
        User usr = [Select Id From User Where Name = 'Omni Test User' LIMIT 1];
        system.runAs(usr){
            ServicePresenceController.getServiceStatus();
            ServicePresenceController.getServiceStatus();
        }
    }
    
    @isTest
    public static void testNonPresenceStatus(){
        String emailPresenceStatusDevName = 'Omni_Channel_Email_Presence_Statuses';
        List<PermissionSetAssignment> pmAssignmentList = new List<PermissionSetAssignment>([Select Id, AssigneeId From PermissionSetAssignment Where PermissionSet.Name !=: emailPresenceStatusDevName AND Assignee.IsActive = true LIMIT 1]);
        if(!pmAssignmentList.isEmpty()){
            User usr = [Select Id From User Where Id =: pmAssignmentList[0].AssigneeId];
            system.runAs(usr){
                ServicePresenceController.getServiceStatus();
            }
        }
    }
    
    @isTest
    public static void testNonPresenceStatus2(){
        String emailPresenceStatusDevName = 'Omni_Channel_Email_Presence_Statuses';
        Constants.servicePresenceTest = true;
        User usr = [Select Id From User Where Name = 'Omni Test User' LIMIT 1];
        system.runAs(usr){
            ServicePresenceController.getServiceStatus();
        }
    }
    
    @isTest
    public static void testNonPresenceStatus3(){
        String emailPresenceStatusDevName = 'Omni_Channel_Email_Presence_Statuses';
        Constants.servicePresenceTest = true;
        User usr = [Select Id From User Where Name = 'Omni Test User' LIMIT 1];
        system.runAs(usr){
            Maersk_Admin_Configuration__c mac = new Maersk_Admin_Configuration__c();
            mac.Record_Id__c = UserInfo.getUserId();
            mac.Show_Nudge__c = true;
            mac.RecordTypeId = Constants.Maersk_Admin_Omni_Nudge_RTId;
            insert mac;
            ServicePresenceController.getServiceStatus();
        }
    }
    
}