/*
 * Version		Story #			Date		Developer		Comments 
 * 1.0			SFSE-5814		26/3/2021	Sidhartha		Code created	
 * 2.0          SFMC-7512       15-Feb-2024 Ranjan@maersk   Changed the call from future to queuable	
 */

public class AssignLeadsUsingAssignmentRules {
    @InvocableMethod (label='Re-run Assignment Rules on Lead')
    public static void LeadAssign(List<Id> lstLeadIds)
    {   
        if(Generic_TriggerHandler.validateRunForMethod('AssignLeadsUsingAssignmentRules.LeadAssign', 1)){
                LeadRecordSelector.operationIdSetMap.put('AssignLead',new Set<Id>(lstLeadIds));
                system.enqueueJob(new LeadAssignorQueueable(LeadRecordSelector.operationIdSetMap));
        }
    } 
    
    //@future()
    public static void leadAssignments(List<Id> lstLeadIds){
        system.debug('in future method - lead ids: ' + lstLeadIds);
         List<Lead> lstLeadsToUpdate = new List<Lead>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true; 
        dmo.EmailHeader.triggerUserEmail = true;
        list<Lead> leadList = [select id from lead where lead.id in :lstLeadIds];
        TriggerExecutionController.skipLeadTrigger(true);
        database.update(leadList, dmo);
        TriggerExecutionController.skipLeadTrigger(false);
    }
}