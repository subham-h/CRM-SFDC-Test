/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-012152   04-Oct-2019 Neha-TCS                Trigger to update has notes fields on corresponding Event. 
*/

public class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    public map<Id, ContentDocumentLink> newMap;
    public map<Id, ContentDocumentLink> oldMap;
    
    public ContentDocumentLinkTriggerHandler() {
        this.newMap = (map<Id, ContentDocumentLink >)trigger.newMap;
        this.oldMap = (map<Id, ContentDocumentLink >)trigger.oldMap;
        ErrorStormHandler.skipErrorStormCheck(true);
    }
    
    public ContentDocumentLinkRecordSelector recordSelector;
    
    public override void getRecordSelector() {
        recordSelector = new ContentDocumentLinkRecordSelector( trigger.new, this.oldMap, this);
    }
    
    public override void onAfterInsert() {
        //Check if the LinkedEntityId is not null and update the corresponding Notes
        if ( !recordSelector.lstLinkedEntity.IsEmpty())
            ContentDocumentLinkUtilities.updateEventswithNotes(recordSelector.lstLinkedEntity, this.oldMap);   
        
        //Calling Artemis method to Publish Files to Artemis system
        if(!userinfo.getusername().contains('system.owner') && !userinfo.getusername().contains('artemis.owner') && recordSelector.isCaseSobjectType){
            FileProducerEventHandler.createFileEvent(this.newMap); 
        }
    }
}