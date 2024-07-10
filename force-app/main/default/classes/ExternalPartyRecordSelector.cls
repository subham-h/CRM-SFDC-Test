/*
* Author   : Shahanawaz@Maersk
* Purpose  : Centralize the record selection process for External Party object.
*            Defines the methods which iterate and segregate the External Party records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
public class ExternalPartyRecordSelector {

    private TriggerHandler extPartyTriggerHandler;
    
    public List<External_Party__c> extPartyList = new List<External_Party__c>();
    
    public ExternalPartyRecordSelector(list<External_Party__c> externalPartyList, map<Id, External_Party__c> mapOldExtParty, TriggerHandler extPartyTriggerHandler) {
        this.extPartyTriggerHandler = extPartyTriggerHandler;
        
        this.selectRecords(externalPartyList, mapOldExtParty);
        
        if(externalPartyList != null) {
            this.getRelatedRecords(externalPartyList);
        }
        
    }
    
    public void selectRecords(list<External_Party__c> externalPartyList, map<Id, External_Party__c> mapOldExtParty) {
        for(External_Party__c ext : externalPartyList){
            if(extPartyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                if(extPartyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    //SC-9293
                    if(ext.Claim__c != null){
                        extPartyList.add(ext);
                    }
                }
            }
        }
    }
    
    public void getRelatedRecords(list<External_Party__c> externalPartyList) {
        
    }
}