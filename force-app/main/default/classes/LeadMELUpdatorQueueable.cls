/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7512   15-Feb-2024 Ranjan@maersk           Created
*/
public without sharing class LeadMELUpdatorQueueable implements Queueable{
    public Map<String,Set<Id>> operationIdSetMap;
    public LeadMELUpdatorQueueable(Map<String,Set<Id>> operationIdSetMap) {
        this.operationIdSetMap=operationIdSetMap;
    }
    public void execute(QueueableContext context) {
        Map<Id,Lead> leadMap=new Map<Id,Lead>([Select Id,
                                                      IndividualId,
                                                      Maersk_Marketing_Consent__c,
                                                      FirstName,
                                                      LastName,
                                                      Company,
                                                      Email,
                                                      Country_lk__c,
                                                      LeadSource,
                                                      Status,
                                                      OwnerId from Lead where Id in:operationIdSetMap.get('MELchanges')]);
        LeadMELUpdator.updateToMEL(leadMap, true);    
    }
}