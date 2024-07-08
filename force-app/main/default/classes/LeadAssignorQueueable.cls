/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7512   15-Feb-2024 Ranjan@maersk           Created
*/
public without sharing class LeadAssignorQueueable implements Queueable{
    public Map<String,Set<Id>> operationIdSetMap;
    public LeadAssignorQueueable(Map<String,Set<Id>> operationIdSetMap) {
        this.operationIdSetMap=operationIdSetMap;
    }
    public void execute(QueueableContext context) {
       AssignLeadsUsingAssignmentRules.leadAssignments(new List<id>(operationIdSetMap.get('AssignLead')));  
        if(operationIdSetMap.containsKey('MELchanges')){
            system.enqueueJob(new LeadMELUpdatorQueueable(operationIdSetMap));
        }    
    }
}