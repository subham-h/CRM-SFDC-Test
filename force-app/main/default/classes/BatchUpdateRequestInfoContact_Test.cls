/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          25/04/2018        meghana.gupta@ust-global.com              #RQ-007794 : Code created
*
*/
@isTest
public class BatchUpdateRequestInfoContact_Test {

    @testSetup static void setup() {
        
        RateSheetData_Test.createRequestData();      
 
    }
    
    @isTest static void testBatch() {
        
        Test.startTest();
        BatchUpdateRequestInformationContact batchTest = new BatchUpdateRequestInformationContact();
        Database.executeBatch( batchTest); 
        Test.stopTest();
        
        List<Request_Information__c> lstReqInfo = [SELECT Id, RecordTypeId FROM Request_Information__c WHERE RecordTypeId = null];
        System.assertEquals(lstReqInfo.size(), 0);
    }
}