/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		11-Apr-2023		Bharti Rana				This is a test class for TAAMassDeleteCntrl.
*/

@isTest
public class TAAMassDeleteCntrl_Test {
     
    @testSetup static void setup() {
          TerritoryDataGeneration_Test.createTerritoryData(); 
    }
    @isTest
    public static void test(){
        test.startTest();
    List<Territory__c> territoryId = [Select Id from Territory__c LIMIT 1];
    List<Id> ids = new List<Id>();
    List<Territory_Account_Association__c> lstTAAs = [Select Id from Territory_Account_Association__c Limit 1];
        for(Territory_Account_Association__c recId : lstTAAs){
            ids.add(recId.Id);
        }
      
        TAAMassDeleteCntrl.massDeleteAction(ids); 
        test.stopTest();
       
    }

}