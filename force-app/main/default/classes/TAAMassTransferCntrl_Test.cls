/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		11-Apr-2023		Vazid@UST				This is a test class for TAAMassTransferCntrl.
*/

@isTest
public class TAAMassTransferCntrl_Test {
    @testSetup static void setup() {
        TerritoryDataGeneration_Test.createTerritoryData(); 
    }
    
    @isTest
    static void testmassTransferAction(){
        Test.startTest();
        List<Territory__c> territoryId = [Select Id from Territory__c LIMIT 1];
        List<Id> ids = new List<Id>();
        List<Territory_Account_Association__c> lstTAAs = [Select Id from Territory_Account_Association__c];
        for(Territory_Account_Association__c recId : lstTAAs){
            ids.add(recId.Id);
        }
        TAAMassTransferCntrl.massTransferAction(System.Today(),ids,territoryId[0].Id);
        TAAMassTransferCntrl.massTransferAction(Date.newInstance(2040,01,01),ids,territoryId[0].Id);
        Test.stopTest();
    }
}