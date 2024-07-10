/**
*
*/
@isTest
public class DeleteBatch_Test {
    //Seconds to sleep after the migration in order to give time to the batch process to finish the migration
    private static final Integer SLEEP_AFTER_MIGRATION = 2;
    
    //test error while delete
    @isTest
    public static void deleteError(){
        Test.startTest();
        //setup
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        UtilitiesForTestClasses_Test.createAttachmentForObject(1, clientAcc.Id, true ); //a private attachment
        
        List <Attachment> attachments = new List <Attachment>();
        List <Id> attachmentsId = new List <Id>();        
        attachments = [SELECT Id, Name FROM Attachment];
        for(Attachment attachment: attachments){
            attachmentsId.add(attachment.Id);
        }
        //end setup
        DeleteBatch batch = new DeleteBatch('SELECT Id FROM Account','Account');
      //  batch.deleteError = 1;  
        batch.listAttachmentsFail = attachmentsId;
        Id batchId = Database.executeBatch(batch);  
        //end setup
        Test.stopTest();    
        system.assert(batchId != null);
    }    
    
}