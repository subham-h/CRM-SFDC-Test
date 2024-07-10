/**
 * test class ISR Module.
 * 
 * Date        Owner                         Description
 *********************************************************************************************************************************  
 * 3/3/2022    kusum.jha@maersk.com          Code created.
 * 3/3/2022    kusum.jha@maersk.com          testCreateISRCase : testing the creation of ISR Case
 * 3/3/2022    kusum.jha@maersk.com          testCaseVisibility : Testing the Case Visibility of ISR Case
 * 3/3/2022    kusum.jha@maersk.com          testQueueChange : Testing the change queue of ISR Case
 * 3/3/2022    kusum.jha@maersk.com          testCloseISRCase : testing Closing of ISR Case
 * 27/06/2022  Ronnie@SF                     SPI-100: Removed brand hardcoding
 */

@isTest
public class ISRCaseModuleTest {

    @isTest
    public static void testCreateISRCase()
    {
        //create ISR case [For Brand : ML  and L&S]
        TestDataFactoryHelper.createISRCaseML();
        Test.startTest();
        TestDataFactoryHelper.createISRCaseMaerskLnS();
         
        
        //query the created case
        List<Case> lstCreatedCase = [SELECT id, RecordTypeId,Case_Visibility__c,Requestor_Dept__c, CreatedById, OwnerId, Liner_Brand__c, Status from Case WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE];        
        List<Case> lstCreatedCaselns = [SELECT id, RecordTypeId,Case_Visibility__c,Requestor_Dept__c, CreatedById, OwnerId, Liner_Brand__c, Status from Case WHERE Liner_Brand__c = :BrandUtilities.MAERSKLS];
        
        //getting the recordtype name of created case
        String strRecordtypeName = StaticFactory.getRecordTypeNameById('Case', lstCreatedCase[0].RecordTypeId);
        String strRecordtypeNameLnS = StaticFactory.getRecordTypeNameById('Case', lstCreatedCaselns[0].RecordTypeId);
        
        //testing the case is created for ML Brand
        System.assert(lstcreatedCase.size()==5, 'ISR case get created');
        System.assertNotEquals(lstCreatedCase[0].CreatedById, lstCreatedCase[0].OwnerId,'Id of created case and ownerid should not be equal' );
        System.assertEquals('ISR',strRecordtypeName,'Record type is ISR');
        System.assertEquals(BrandUtilities.MAERSKLINE, lstCreatedCase[0].Liner_Brand__c,'Brand is Maersk Line');      
        Test.stopTest();
        
        //testing the case is created for LnS Brand
        System.assert(lstCreatedCaselns.size()==5, 'ISR case get created');
        System.assertEquals('ISR',strRecordtypeNameLnS,'Record type is ISR');
        System.assertEquals(BrandUtilities.MAERSKLS, lstCreatedCaselns[0].Liner_Brand__c,'Brand is maersk line');
    }
    
    /*comment all */
    @isTest
    public static void testCaseVisibility()
    {
        //create ISR case 
        TestDataFactoryHelper.createISRCaseML();
        Test.startTest(); 
        TestDataFactoryHelper.createISRCaseMaerskLnS();
        
        
        //query the created case
        List<Case> lstCreatedCase = [SELECT id, RecordTypeId,Case_Visibility__c,Requestor_Dept__c,OwnerId, Liner_Brand__c, Status from Case WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        List<Case> lstCreatedCaselns = [SELECT id, RecordTypeId,Case_Visibility__c,Requestor_Dept__c,OwnerId, Liner_Brand__c, Status from Case WHERE Liner_Brand__c = :BrandUtilities.MAERSKLS];
        Test.stopTest();
        
        //test the visibility of case
        System.assertEquals('All Users', lstCreatedCase[0].Case_Visibility__c,'Case visibility is all users'); 
        System.assertEquals('Multi-Carrier', lstCreatedCaselns[0].Case_Visibility__c,'Case visisbility is multi carrier'); 
    }
    
    @isTest
    public static void testQueueChange()
    {
         //create ISR case 
        TestDataFactoryHelper.createISRCaseML();
        Test.startTest();
        //query the created case
        Case createdCase = [SELECT id,ContactId, RecordTypeId,Country__c,Case_Visibility__c,Requestor_Dept__c,OwnerId, Liner_Brand__c, Status from Case WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE LIMIT 1];
        id previousOwnerId = createdCase.OwnerId;
        
        //create a user
        User createdUser = TestDataFactoryHelper.createUser();
        
        //change the queue of the case
        createdCase.OwnerId = createdUser.id;
        update createdCase;
        Test.stopTest();
        
        //test the queue change
        System.assertNotEquals(previousOwnerId, createdCase.OwnerId,'previous ownerid and created case ownerid is not equal');
    }
    
    @isTest
    public static void testCloseISRCase()
    {
        //create ISR case 
        TestDataFactoryHelper.createISRCaseML();
        Test.startTest(); 
        //query the created case
        Case createdCase = [SELECT id, ContactId, Duration_Of_Case_Closed_first_time__c, RecordTypeId,Case_Visibility__c,Requestor_Dept__c,OwnerId, Liner_Brand__c, Status from Case  WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE LIMIT 1];
        
        //create a user
        User createdUser = TestDataFactoryHelper.createUser() ;
        
        //update to close the case
        createdCase.Status = 'Closed - Resolved';
        createdCase.Resolution_Summary__c  ='Resolved Case';
        createdCase.OwnerId = createdUser.id;
        update createdCase;
        Test.stopTest();
        //test the status 
        system.assertEquals('Closed - Resolved', createdCase.Status,'status is same');
        System.assertNotEquals( 0.000, createdCase.Duration_Of_Case_Closed_first_time__c,'duration of case closed first time is same');
    }   
}