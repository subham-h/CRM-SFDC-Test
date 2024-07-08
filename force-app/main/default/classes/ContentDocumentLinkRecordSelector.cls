/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-012152   04-Oct-2019 Neha-TCS                Code Created. 
*/
public class ContentDocumentLinkRecordSelector implements RecordSelector {

    private TriggerHandler trgHandler;
    
    public List<Event> lstLinkedEntity = new List<Event>(); // List of Events to be updated
    List<Id> lstEvenIds = new List<Id>();
    public Boolean isCaseSobjectType=false;
    public ContentDocumentLinkRecordSelector(list<ContentDocumentLink> lstContentDocumentLink, map<Id, ContentDocumentLink> mapOldContentDocumentLink, ContentDocumentLinkTriggerHandler conDocumentLinkTriggerHandler) {
        this.trgHandler = conDocumentLinkTriggerHandler;        
        selectRecords(lstContentDocumentLink, mapOldContentDocumentLink);
        getRelatedRecords(lstContentDocumentLink);
    }
        
    public void selectRecords(list<ContentDocumentLink> lstContentDocumentLink, map<Id, sObject> mapOldContentDocumentLink) { 
        ContentDocumentLink conDoc;
        Map<Id,ID> mapOFofContentDocumentIdEventId = new Map<Id,Id>(); // Map to get the content document id and Event Id   
        for(ContentDocumentLink contentDocRecords : lstContentDocumentLink){  
            Id linkedid =  contentDocRecords.LinkedEntityId;         
            String sobjectType = linkedid.getSObjectType().getDescribe().getName();            
            if(sobjectType== 'Event'){ // To check if Notes is related to Event              
                mapOFofContentDocumentIdEventId.put(contentDocRecords.ContentDocumentId,linkedid); 
            }
            if(sobjectType!=null && sobjectType.equalsIgnoreCase('Case')){
                isCaseSobjectType=true;
            }            
        }
        if(!mapOFofContentDocumentIdEventId.isEmpty()){
            // QUery to check if the content document record is note or file
            List<ContentDocument> ContentDocumentList =[SELECT id,FileType FROM ContentDocument where id in :mapOFofContentDocumentIdEventId.keySet() and FileType = 'SNOTE'];
            
            for(ContentDocument cd :ContentDocumentList){
                lstEvenIds.add(mapOFofContentDocumentIdEventId.get(cd.id));
            }
            List<String> lstEventType = Label.Event_type.split(',');        
            if(lstEvenIds.size() > 0 && trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){           
                lstLinkedEntity = [Select id, Type, HasNotes__c from Event where id in : lstEvenIds and Type in :lstEventType];            
            }
        }
    }

    public void getRelatedRecords(list<ContentDocumentLink> lstContentDocumentLink) {
            
    }  
}