global class BatchContentVersionChecksum implements Database.Batchable<SObject>, Schedulable{
    
    global Date startDate;
    global Integer batchSize;
    public BatchContentVersionChecksum(Date startDate, Integer size){
        this.startDate = startDate;
        if(size != null){
            this.batchSize = size;
        }
        else if(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size') != null && !String.isEmpty(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c)){
            this.batchSize = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, Checksum, Checksum__c From ContentVersion Where isLatest = true ';
        if(startDate == null){
            query += 'AND CreatedDate = YESTERDAY';
        }
        else{
            Date endDate = startDate + 1;
            query += 'AND CreatedDate >=: startDate AND CreatedDate <: endDate';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<ContentVersion> conVerList){
        List<ContentVersion> conVerListToUpdate = new List<ContentVersion>();
        try{
            for(ContentVersion con : conVerList){
                ContentVersion conVerToUpdate = new ContentVersion();
                conVerToUpdate.Id = con.Id;this.batchSize = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c);
                conVerToUpdate.Checksum__c = con.Checksum;
                conVerListToUpdate.add(conVerToUpdate);
            }
            if(!conVerListToUpdate.isEmpty()){
                update conVerListToUpdate;
            }
        }catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'ContentVersion', 'BatchContentVersionChecksum.execute()', new list<Exception>{e});
        }
    }
    
    global void finish(Database.BatchableContext bc){
        BatchDeleteDuplicateEmailMessageFiles batch = new BatchDeleteDuplicateEmailMessageFiles(null, null, null, '');
        Database.executeBatch(batch, batchSize);
    }
    
    global void execute(SchedulableContext SC) {
        BatchContentVersionChecksum batch = new BatchContentVersionChecksum(startDate, batchSize);
        Database.executeBatch(batch, batchSize);
    }
}