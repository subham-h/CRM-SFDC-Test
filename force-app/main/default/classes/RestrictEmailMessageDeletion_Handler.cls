/*
* Trigger Handler class called by the RestrictEmailMessageDeletion written on EmailMessage object
*  RestrictEmailMessageDeletionHandler class is using Single Trigger Framework. This class extends a virtual Generic_TriggerHandler Class
* 
*Version    Date            Owner                                               RQ#                     Description
*********************************************************************************************************************************  
* 1.0        21/10/2015       Prashanth D S                                     #RQ-000965                Code created
* 2.0        01/01/2016       meghana.gupta@ust-global.com                      #RQ-002190                Add a check on restricting email deletion
*/

public without sharing class RestrictEmailMessageDeletion_Handler extends Generic_TriggerHandler {
    
    public Map<Id, EmailMessage> oldEMMap;
    public list<EmailMessage> oldEMList;

    public RestrictEmailMessageDeletion_Handler() {
        
        this.oldEMMap = (Map<Id, EmailMessage>) Trigger.oldMap;
        this.oldEMList = (List<EmailMessage>) Trigger.old; 
    
    }

    public override void beforeDelete() {
        // in case Child case email is getting deleted by code DuplicateCaseManagerExtension then do not restrict email deletion
        if ( !TriggerRecursionCounter.isMergeFromDuplicateCaseManager ){
            
            RestrictEmailMessageDeletion_Utilities.DeleteRestrictionMethods(oldEMList);
            
        }
    }
    
 }