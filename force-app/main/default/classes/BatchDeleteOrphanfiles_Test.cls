@isTest
public class BatchDeleteOrphanfiles_Test {
    @testSetup
    static void testDataSetup() {
        Purge_Configuration__c customCln1 = new Purge_Configuration__c(Name = 'File',
                                                                       Object_Name__c = 'File',
                                                                       Field_Name__c = 'Linkedentityid',
                                                                       Order__c = 1,
                                                                       Job_Number__c = 1,
                                                                       Operation__c = '<=',
                                                                       Value__c = userinfo.getuserid(),
                                                                       days_to_skip__c =2,
                                                                       No_of_days_to_delete__c=3);
        insert customCln1;
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            CreatedDate = System.now()
        );
        insert contentVersion_1;
    }
    static testMethod void test_delete(){
        Test.StartTest();
        BatchDeleteOrphanfiles batchCleanUp= new BatchDeleteOrphanfiles('File');
        Id ApexId = Database.executeBatch(batchCleanUp);
        Test.StopTest();
    }
    static testMethod void test_delete2(){
        Test.StartTest();
        BatchDeleteOrphanfiles testsche = new BatchDeleteOrphanfiles('File');
        String sch = '0 0 23 * * ?';
        system.schedule('Test delete orphan files', sch, testsche );
        Test.stopTest();
    }
}