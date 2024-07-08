/* 
* Author   : Ranjini
* Purpose  : To keep Community users in sync with associated Contact.
* 
* Revision     Ref Number      Date            Owner                         Description
* --------     ----------      -----------     -------------------           -----------
* 1.0          RQ-004366       13-Dec-2016     Ranjini@UST                   Logics to update community user based on Contact updates.
* 2.0          RQ-005407       6-June-2017     Ranjini@ust                   Added null check for email.
* 3.0          RQ-005477       4-Jun-2017      Nisha@ust                     Customers should not get email when chatter post is being added by internal users
* 4.0           #RQ-012996      24/01/2020      rakesh @maersk              Change Customer User License
*/
public class CommunityUserUtility {
    
    // RQ-004366. Sync Community User with the associated Contact. Fields: Email, IsActive 
    @future
    public static void syncWithContact(set<Id> setContactIds) {
        list<User> lstUsers = [SELECT Id, ContactId, Email, IsActive FROM User WHERE ContactId IN :setContactIds];
        
        if(lstUsers != null && !lstUsers.isEmpty()) {
            map<Id, Contact> mapContacts = new map<Id, Contact>([SELECT Id, Email, Contact_Status__c FROM Contact WHERE Id IN :setContactIds]);
            
            for(User userIterator : lstUsers) {
                Contact conIterator = mapContacts.get(userIterator.ContactId);
                if(conIterator.Email != null) { // RQ-005407
                    userIterator.Email = conIterator.Email;
                }
                
                if(conIterator.Contact_Status__c == 'Inactive' && userIterator.IsActive == true) {
                    userIterator.IsActive = false;
                }
            }
            
            // Exceptions are not handled and logged to Global Error Logger purposely to avoid getting Mixed DML Operation exceptions.
            // Any failures during below update statement will trigger an Apex Exception email to the System Administrators to notify on the failures.    
            TriggerExecutionController.skipUserTrigger(true);
            update lstUsers;
            TriggerExecutionController.skipUserTrigger(false);
        }
    }
    
    //  RQ-005477 - Disable Receive Email option in NetworkMember table  for community users
    @future   
    public static void setPreferencesDisableAllFeedsEmailToFalse(set<Id> setUserIds) {
        try{
            if(setUserIds != null || !setUserIds.isEmpty()){
                list<NetworkMember> lstNetworkMember = [SELECT Id, PreferencesDisableAllFeedsEmail FROM NetworkMember WHERE MemberId IN : setUserIds];
                for(NetworkMember netMemIterator : lstNetworkMember){
                    netMemIterator.PreferencesDisableAllFeedsEmail = true;
                }
                update lstNetworkMember;         
            }
        }
        catch(Exception ex){
            System.debug( ex.getMessage()) ;            
        }       
    }
    
    // #RQ-012996 - Start 
    // This method is to change/set the default community license for customer users
    Public Static void changeUserLicense(List<User> newList){
        String communityLoginProfile = Environment_Variables__c.getValues('Community License Type')!=null ? Environment_Variables__c.getValues('Community License Type').Value_String__c : null;
        if(communityLoginProfile != null && communityLoginProfile == 'Login'){
            Id profileOld;
            Id profileLogin;
            //Profile captures License Info, hense query on 
            for(Profile prof : [select Id, userLicense.Name from Profile where name LIKE '501 - Customer Community%' and UserLicense.Name LIKE 'Customer Community%']){
                //License names are static hence checking based on License
                if(prof.userLicense.Name == 'Customer Community')
                    profileOld = prof.Id;   // 501 - Customer Community User
                if(prof.userLicense.Name == 'Customer Community Login')
                    profileLogin = prof.Id; //501 - Customer Community Login User
            }
            if(profileOld != null && profileLogin != null){ 
                for(User usr : newList){
                    if(usr.profileId== profileOld && userinfo.getUserName().contains('usi.provisioning@maersk.com'))
                        usr.profileId = profileLogin;
                }
            }
        }
    }
    // #RQ-012996 - End
    
}