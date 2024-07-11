/**
* 
*/
@isTest
public class MigratorBatch_Test {
    
    //Seconds to sleep after the migration in order to give time to the batch process to finish the migration
    private static final Integer SLEEP_AFTER_MIGRATION = 1;
    
    /*
* Creates one public attachment and one private attachments and after the migrations there should be only 
* the public attachment migrated
*/
    @isTest static void migrateOnlyPublicAttachments() {
        Test.startTest();
        //setup
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        UtilitiesForTestClasses_Test.createAttachmentForObject(1, clientAcc.Id, true ); //a private attachment
       
        UtilitiesForTestClasses_Test.createAttachmentForObject(1, clientAcc.Id, false); //a public attachment
      
        Boolean deleteAfterMigration = false;
        Id objectId = null;
        Id ownerId = null;
        
        //end setup
        
        //run the migration
        MigratorBatch batch = new MigratorBatch('Account', deleteAfterMigration,2, null);
        Id batchId = Database.executeBatch(batch);
        
        //sleeps some seconds to give time to the background migration (batch process)
        UtilitiesForTestClasses_Test.sleep(SLEEP_AFTER_MIGRATION);
        Test.stopTest();
        
        //after the migration there should be only one file migrated
        List<ContentVersion> files = UtilitiesForTestClasses_Test.getLastFiles();
        System.assert(!files.isEmpty(), 'There is not a file migrated');
        System.assertEquals(1, files.size(), 'There is more than one file migrated');
        ContentVersion file = files.get(0);
         
    }
   
    @isTest static void migratePublicAndPrivateEvents() {
        Test.startTest();
        //START set up
        Event event = UtilitiesForTestClasses_Test.createEvent();
        //END set up
        
        String objectName = 'Event';
        Boolean changePrivate = true; 
        Boolean deleteAfterMigration = true;
        Boolean rollupFileToParents = true;
        Boolean migrateAttachment = true;
        Boolean migrateNote = false;
        Id objectId = null;
        Id ownerId = null;
        
        //sleeps some seconds to give time to the background migration (batch process)
        UtilitiesForTestClasses_Test.sleep(SLEEP_AFTER_MIGRATION);
        
        //run the migration
        MigratorBatch batch = new MigratorBatch(objectName, deleteAfterMigration,1, null);
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        
        System.assertEquals(0, UtilitiesForTestClasses_Test.countAllFiles(),'Event was not migrated');
    }
    
    @isTest static void migratePublicAndPrivateTasks() {
        Test.startTest();
        //START set up
        Task task = UtilitiesForTestClasses_Test.createTask();
        //END set up
        
        String objectName = 'Task';
        Boolean changePrivate = true; 
        Boolean deleteAfterMigration = true;
        Boolean rollupFileToParents = true;
        Boolean migrateAttachment = true;
        Boolean migrateNote = false;
        Id objectId = null;
        Id ownerId = null;
        
        //sleeps some seconds to give time to the background migration (batch process)
        UtilitiesForTestClasses_Test.sleep(SLEEP_AFTER_MIGRATION);
        
        //run the migration
        MigratorBatch batch = new MigratorBatch(objectName, deleteAfterMigration,1, null);
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        
        System.assertEquals(0, UtilitiesForTestClasses_Test.countAllFiles(),'Task was not migrated');
    }
    
    
    
    @isTest static void migrateById() {
        Test.startTest();
        //START set up
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        UtilitiesForTestClasses_Test.createAttachmentForObject(1, clientAcc.Id, true ); //a private attachment
   
        //END set up
        Boolean deleteAfterMigration = false;
        Id objectId = null;
        Id ownerId = null;
        List <id> aux = new List <id>();
        Attachment attach = [SELECT Id, Name FROM Attachment LIMIT 1];
        aux.add(attach.Id);
        //sleeps some seconds to give time to the background migration (batch process)
        UtilitiesForTestClasses_Test.sleep(SLEEP_AFTER_MIGRATION);
        
        //run the migration
        MigratorBatch batch = new MigratorBatch(null, deleteAfterMigration,1,aux);
       // batch.listIds = aux;
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        List <Attachment> attachments = new List <Attachment>();
        attachments = [SELECT Id, Name FROM Attachment WHERE Name LIKE '[068%' ];
        System.assertEquals(1, attachments.size());
    }
    
    @isTest static void migrateLimitBigger() {
        Test.startTest();
        //START set up
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        //END set up
        
        String objectName = 'Account';
        Boolean changePrivate = true; 
        Boolean deleteAfterMigration = true;
        Boolean rollupFileToParents = true;
        Boolean migrateAttachment = true;
        Boolean migrateNote = false;
        Id objectId = null;
        Id ownerId = null;
        
        //sleeps some seconds to give time to the background migration (batch process)
        UtilitiesForTestClasses_Test.sleep(SLEEP_AFTER_MIGRATION);
                
        //run the migration
        MigratorBatch batch = new MigratorBatch(objectName, deleteAfterMigration,1, null);
        Id batchId = Database.executeBatch(batch);
        
        Test.stopTest();
        
        System.assertEquals(0, UtilitiesForTestClasses_Test.countAllFiles(),'Account Attachment was not migrated');
    }  
}