global class BatchUpdateRequestInformationContact implements Database.Batchable<SObject> {

    global Database.queryLocator start( Database.BatchableContext ctx ) {
         
        String query;
        query ='SELECT id, recordtypeId ';
            query += ' FROM Request_Information__c ';
        
        if (! Test.isRunningTest())
            query += ' Where recordtypeId = null '; 
        
        query += ' LIMIT 200000'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute( Database.BatchableContext BC, List<Request_Information__c> scope ) {
        
		String recTypeId = Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get( Label.RequestDetail_ContactRecordType).getRecordTypeId();
        List<Request_Information__c> lstReqInfoContact = new List<Request_Information__c>();
        
    	for (Request_Information__c rqCon : scope ) {
            rqCon.RecordTypeId = recTypeId;
            lstReqInfoContact.add(rqCon);
        }
        
        database.update(lstReqInfoContact, false);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}