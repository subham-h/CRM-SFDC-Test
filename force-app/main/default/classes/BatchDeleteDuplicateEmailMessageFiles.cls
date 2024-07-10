global class BatchDeleteDuplicateEmailMessageFiles implements Database.Batchable<SObject>, Schedulable{ 
    
    global Date startDate;
    global Date endDate;
    global Integer batchSize;
    global String context;
    public BatchDeleteDuplicateEmailMessageFiles(Date startDate, Date endDate, Integer size, String context){
        this.startDate = startDate;
        this.endDate = endDate;
        this.context = context;
        if(size != null){
            this.batchSize = size;
        }
        else if(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size') != null && !String.isEmpty(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c)){
            this.batchSize = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From EmailMessage ';
        Date startDt;
        Date endDt;
        if(startDate != null && endDate != null){
            startDt = startDate;
            endDt = endDate;
        }
        else{
            startDt = System.today()-1;
            endDt = System.today();
        }
        query += 'Where CreatedDate >=: startDt AND CreatedDate <: endDt';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailMsgList){
        Map<Id, Id> contentDocIdToEntityIdMap = new Map<Id, Id>();
        Set<Id> emMsgIdset = new Set<Id>();
        for(EmailMessage em : emailMsgList){
            emMsgIdset.add(em.Id);
        }
        try{
            for(ContentDocumentLink cdl : [Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN: emMsgIdset LIMIT 25000]){
                contentDocIdToEntityIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            if(!contentDocIdToEntityIdMap.isEmpty()){
                ContentDocumentLinkUtilities.deleteDuplicateContentDocuments(contentDocIdToEntityIdMap, context);
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'EmailMessage', 'BatchDeleteDuplicateEmailMessageFiles.execute()', new list<Exception>{e});
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext SC) {
        BatchDeleteDuplicateEmailMessageFiles batch  =  new BatchDeleteDuplicateEmailMessageFiles(System.today()-1, System.today(), null, '');
        Database.executeBatch(batch, 1);
    }
}