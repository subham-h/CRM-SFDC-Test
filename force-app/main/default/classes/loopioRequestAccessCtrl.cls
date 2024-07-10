/*
 * This class is controller for loopioRequestAccess lwc component. To assign loopio permission set.
 * Test Class : loopioRequestAccessCtrlTest
 */ 
public without sharing class loopioRequestAccessCtrl {
    @AuraEnabled
    public static void assignLoopioPermissionSet(){
        List<PermissionSet> loopioPermissionSet = [select id from PermissionSet  where name='Loopio_Access' limit 1];
        if(!loopioPermissionSet.isempty()){
            insert (new PermissionSetAssignment(PermissionSetId = loopioPermissionSet[0].Id, AssigneeId = UserInfo.getUserId()));
        } 
    }
    
}