/****
* Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-9733        13/01/2023    Bharti&Aditi            Code Created
*/



global class Batch_Escalation_ApprovalProcess  implements Database.Batchable<sObject> {
    
    global Set<Id> setOpptyIds;
    
    global Batch_Escalation_ApprovalProcess(Set<Id> setOpptyIds){
        
        if(setOpptyIds != null){
            this.setOpptyIds = setOpptyIds;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query;
       
        query = 'Select  id, Approval_Status__c, Name, StageName, Opportunity_Owner__c, Products_for_Approval__c, OwnerId, Owner.Email, Owner_Area_Code__c from Opportunity where Approval_Status__c like \'Submitted%\' AND IsClosed = false';
      if(setOpptyIds != null){
            query += ' AND ID In :setOpptyIds';
        }
        System.debug('query '+query);
        //System.debug('setOpptyIds '+setOpptyIds);
        //System.debug('setOpptyIds '+setOpptyIds.size());
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc , List < Opportunity > opps){
        ApprovalProcessEscalationHandler handler = new ApprovalProcessEscalationHandler();
        handler.escalate(opps);
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Finished');
    }
}