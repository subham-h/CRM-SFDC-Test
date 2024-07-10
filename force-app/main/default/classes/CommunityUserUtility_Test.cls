/*
 * Author   : Hitha
 * Purpose  : Test CommunityUserUtility
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004366   5/1/2017    Hitha@UST               Created.
 * 2.0      RQ-005477   4/06/2017   Nisha@ust               Customers should not get email when chatter post is being added by internal users.
 * 
 */
 
@isTest
public class CommunityUserUtility_Test{

    public static testMethod void test_syncWithContact() {
        set<Id> setContactIds = new set<Id>();
        List<User> lstUsers = UserData_Test.createCommunityUsers();     
        for(User userItem : lstUsers) {
            setContactIds.add(userItem.ContactId);
        }
        
        Integer iterator = 0;
        map<Id, Contact> mapContacts = new map<Id, Contact>([select Id, Contact_Status__c, Email from Contact where Id in :setContactIds]);
        for(Contact conInstance : mapContacts.values()) {
            conInstance.Contact_Status__c = 'Inactive';
            conInstance.Email = 'testemailchanged' + (iterator++) + '@test.com';
        }
        
        Test.startTest();
        update mapContacts.values();
        Test.stopTest();
        
        list<User> lstNewUser = [SELECT Id, Name, IsActive, Email, ContactId, Contact.Email from User where ContactId = :setContactIds];
        for(User userItem : lstNewUser) {
            System.assertEquals(false, userItem.IsActive);
            System.assertEquals(userItem.Email, mapContacts.get(userItem.ContactId).Email);
        }
    } 
    
    // RQ-005477
    public static testMethod void test_setPreferencesDisableAllFeedsEmailToFalse() {
        UserData_Test.bCreate = False;
        UserData_Test.iNumberOfUsers = 5;
        UserData_Test.createCommunityUsers();
        list<User> lstUsers = UserData_Test.lstUsers;
        
        Test.startTest();
        insert lstUsers;     
        Test.stopTest();
        set<Id> setCommunityUserIds = (new Map<Id,User>(lstUsers)).keySet();
        
        list<NetworkMember> lstUserModified = [SELECT Id, PreferencesDisableAllFeedsEmail FROM NetworkMember WHERE MemberId =:setCommunityUserIds ];
        if( !lstUserModified.isEmpty()){
            System.assertEquals(true, lstUserModified[0].PreferencesDisableAllFeedsEmail);}
    } 
       
}