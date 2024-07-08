public class dummyClassSeba { 
    
    @auraEnabled
    public static Boolean checkIfFileisGenerated(String accountPlanId){
        Boolean fileExists = false;
        String fileId = '';
        system.debug('accountPlanId'+accountPlanId);
        list<ContentDocumentLink> cd =  [select id from ContentDocumentLink where ContentDocument.Description = 'Account Plan Output' AND LinkedEntityId = :accountPlanId];
        system.debug('cd'+cd);
        fileId = [select id from ContentDocumentLink where ContentDocument.Description = 'Account Plan Output' AND LinkedEntityId = :accountPlanId]?.Id;
		fileExists = String.isBlank(fileId) ? false : true;
        system.debug(fileExists); 
        return fileExists;
    }
}