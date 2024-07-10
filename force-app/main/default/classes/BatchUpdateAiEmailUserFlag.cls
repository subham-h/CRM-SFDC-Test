/*
*Version  Date         Owner                                    RQ#           Description
********************************************************************************************************************************************
*1.0	  17/11/2023   Vivek@Maersk								SC-9206		  new Batch class to update Ai_Email_User__c for AI permission sets to support it on Power BI dashboards
*/
global class BatchUpdateAiEmailUserFlag implements Database.Batchable<sObject>, Schedulable  {
/*SC-9206 update Ai_Email_User__c for AI users based on the permission set assigned */
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer limitRows = Test.isRunningTest() ? 1 : 50000;
        String query = 'select id,Ai_Email_User__c, User.Profile.UserLicense.Name from USER WHERE isActive = True and User.Profile.UserLicense.Name = \'Salesforce\' limit : limitRows';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<User> scope) {
        Map<Id, User> aiPermissionUsers = new Map<Id, User>();
        List<User> listUserRecords =  new List<User>(); 
        List<Id> permissionSetIds = new List<Id>();
        permissionSetIds.addAll(label.Gen_1_AI_Email_PermissionSets.split(','));
        system.debug('-->permissionSetIds'+permissionSetIds);
        system.debug('-->scope'+scope);
        
        for(PermissionSetAssignment thisPE : [Select Id , AssigneeId,PermissionSetId from PermissionSetAssignment where PermissionSetId != '' and permissionSetId In: permissionSetIds and assigneeId IN: scope]){
                aiPermissionUsers.put(thisPE.assigneeId, null);
        }
        
         for( User userRec : scope){
            //Update AI Email User flag to true if the user has permission sets assigned
            if(!aiPermissionUsers.isEmpty() && aiPermissionUsers.containsKey(userRec.Id) && userRec.Ai_Email_User__c ==  false){
                userRec.Ai_Email_User__c = true;
                listUserRecords.add(userRec);
            }
            //Update AI Email User flag to false  if the user does not have permission sets assigned
            else if(userRec.Ai_Email_User__c ==  true && !aiPermissionUsers.containsKey(userRec.Id) ){
                userRec.Ai_Email_User__c = false;
                listUserRecords.add(userRec);

            }
             
            system.debug('-->listUserRecords'+listUserRecords);

        }
            
        
        if(!listUserRecords.isEmpty())
            Database.update(listUserRecords, false);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext SC) {
        
        BatchUpdateAiEmailUserFlag batch = new BatchUpdateAiEmailUserFlag();
        Database.executeBatch(batch, 10);
        
    }
    
}