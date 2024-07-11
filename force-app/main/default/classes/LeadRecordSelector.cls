/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-004490   21-Jan-2019 Meghana.Gupta@UST       All Lead triggers moved to Signle trigger model
* 2.0      SFSE-5346   22-Jan-2021 Neh@TCS                 Added condition in selector to check for standard country change as well
* 2.1      SFSE-5757   26-May-2021 nitin@maersk            Populated set of lead Ids to assign Individual id if email is not null
* 3.0      SFMC-7365   13-06-2023  amrutha@maersk		   Existing code to work when Lead Source value is not equal to ‘Email Subscriber/Newsletter’
* 4.0      SFMC-7484   25-10-2023  amrutha@maersk          Include Lead Source value of ‘Preference Center’ along with ‘Email Subscriber/Newsletter’to prevent consent management logic from running
*/

public class LeadRecordSelector implements RecordSelector {
    
    private TriggerHandler trgHandler; 
    public Map<Id,Lead> convertingLeadsMap=new Map<Id,Lead>();
    public static Map<String,Set<Id>> operationIdSetMap=new  Map<String,Set<Id>>();
    Public Map<Id,Lead> mELLeadMap=new Map<Id,Lead>();
    public List<Lead> lstLeadsToAssignCluster = new List<Lead>(); // list of leads inserted or updated where owner/country is modified and Ownership cluster needs to be repopulated
    public static List<Id> lstLeadIdsRerunAssignmentRules = new List<Id>(); // populated in LeadFieldPopulater in before update trigger and used in after update trigger
    public List<Lead> lstConvertingLeads = new List<Lead>(); // list of leads that are getting converted to Account/Contact/Opportunity
    
    // To store set of lead ids inserted and has email id field populated which needs individual id to be populated.
    public Set<Id> setLeadIdsToAssignIndividualId = new Set<Id>(); 
    public List<Lead> leadAccUpdtList=new List<Lead>();
    public Map<String,List<Lead>> emailIdLeadListMap=new Map<String,List<Lead>>();
    
    public LeadRecordSelector(list<Lead> lstLeads, map<Id, Lead> mapOldLeads, LeadTriggerHandler leadTriggerHandler) {
        
        this.trgHandler = leadTriggerHandler;        
        selectRecords(lstLeads, mapOldLeads);
        getRelatedRecords(lstLeads);
    }
    
    public void selectRecords(list<Lead> lstLeads, map<Id, sObject> mapOldLeads) {
        
        Lead oldLead;        
        for (Lead leadRecord : lstLeads){
            
            // if record is updated, get old lead record 
            if (mapOldLeads != null){
                oldLead = (Lead) mapOldLeads.get(leadRecord.Id);
            }
            
            // On Insert Or on Update when Owner or Country is changed, add lead to list to repopulate Ownership Cluster
            if ( trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && ( trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT 
                      || ( trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && ( leadRecord.OwnerId != oldLead.OwnerId || leadRecord.Country_lk__c != oldLead.Country_lk__c || leadRecord.Country != oldLead.Country)))){
                
                System.debug('here ::');
                lstLeadsToAssignCluster.add(leadRecord);
            } 
            
            //before lead conversion
            if ( trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && leadRecord.IsConverted && !oldLead.IsConverted ){
                lstConvertingLeads.add(leadRecord);
            }
            //After lead conversion
            if ( trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && leadRecord.IsConverted && !oldLead.IsConverted ){
                convertingLeadsMap.put(leadRecord.Id,leadRecord);
            }

            if (trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && leadRecord.Email != null && leadRecord.Leadsource != 'Email Subscriber/Newsletter'){
                
                setLeadIdsToAssignIndividualId.add(leadRecord.Id);
            }
            //SFMC-7511:-populate the Account__c and Account Confidence Score when the Lead is created/updated with
            //Company,Country_lk__c,PostalCode,Phone fields
            if (trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                (   
                    trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
                    (   trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                        DuplicateAccountUpdator.hasAccRelfieldChanged(oldLead,leadRecord)
                    )
                ) &&
                leadRecord.Email != null && 
                !DuplicateAccountUpdator.isEmailMaerskDomain(leadRecord.Email) && 
                leadRecord.Leadsource != 'Email Subscriber/Newsletter')
            {
                leadAccUpdtList.add(leadRecord);
            }
            /*Logic related to ET records*/
            if ((trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ||trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER) && 
                trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && leadRecord.Email!=null
            ){
                if(!emailIdLeadListMap.containsKey(leadRecord.Email)){
                    emailIdLeadListMap.put(leadRecord.Email,new List<Lead>());
                }
                emailIdLeadListMap.get(leadRecord.Email).add(leadRecord);
            }
            if (trgHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                    (leadRecord.IndividualId!=oldLead.IndividualId || 
                    leadRecord.FirstName!=oldLead.FirstName ||
                    leadRecord.Company!=oldLead.Company ||
                    leadRecord.Email!=oldLead.Email ||
                    leadRecord.Country_lk__c!=oldLead.Country_lk__c ||
                    leadRecord.LeadSource!=oldLead.LeadSource
                    )
                )
            {
                mELLeadMap.put(leadRecord.Id, leadRecord);

            }
            if(trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
            {
                if(!operationIdSetMap.containsKey('MELchanges')){
                    operationIdSetMap.put('MELchanges', new Set<Id>());
                }
                operationIdSetMap.get('MELchanges').add(leadRecord.Id);
            }
                  
        }
    } 
    public void getRelatedRecords(list<Lead> lstLeads) {
        
    }    
}