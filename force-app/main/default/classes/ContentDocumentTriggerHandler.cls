public class ContentDocumentTriggerHandler extends TriggerHandler{
    public Map<Id, ContentDocument> newMap;
    public Map<Id, ContentDocument> oldMap;
    public ContentDocumentTriggerHandler() {
        this.newMap = ( map<Id, ContentDocument> ) Trigger.newMap;
        this.oldMap = ( map<Id, ContentDocument> ) Trigger.oldMap;   
    }
    public override void onBeforeDelete() {
        ContentDocumentArtemisUtility.sendArtemisFiles( this.oldMap );  

    }
}