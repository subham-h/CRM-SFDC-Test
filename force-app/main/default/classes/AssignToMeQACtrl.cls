public with sharing class AssignToMeQACtrl {
    @AuraEnabled(cacheable=false)
    public static String updateOPLnTasks(String recordId){
        try {
            if (!Schema.sObjectType.Ocean_Plus_Lead__c.isUpdateable()) {
                new AuraHandledException( 'You dont have the permission to update');
            }
            Ocean_Plus_Lead__c OPLObj=new Ocean_Plus_Lead__c();
            OPLObj.Id=recordId;
            OPLObj.OwnerId=Userinfo.getUserId();
            update as user OPLObj;
            List<Task> tskList=[Select Id,OwnerId from Task where WhatId=:recordId and IsClosed=false];
            if(tskList.isEmpty()){
                return 'Record assigned to you successfully!';
            }
            for(Task tskObj:tskList){
                tskObj.OwnerId=Userinfo.getUserId();
            }
            update tskList;
        }catch (Exception ex) {
            String exMessageStr=(ex.getMessage().containsIgnoreCase('INSUFFICIENT_ACCESS_OR_READONLY')?'You don’t have permission to take that action on this record or related records. For help, contact your Salesforce admin.':ex.getMessage());
            throw new AuraHandledException(exMessageStr);
        }
        return 'Record assigned to you successfully!';

    }
}