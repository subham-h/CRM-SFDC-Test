/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0.      07-Jul-2023     Shubham@Maersk          This is a test class for TAAMassTransferCntrl.
*/

@isTest
public class MassTransferCSVController_Test {
    @testSetup static void setup() {
        TerritoryDataGeneration_Test.createTerritoryData(); 
    }
    
    @isTest
    static void testmassTransferAction(){
        Test.startTest();
        List<Territory__c> territoryList = [Select Id,Portfolio_Owner__r.Maersk_User_Id__c from Territory__c LIMIT 1];
        String maerskId = territoryList[0].Portfolio_Owner__r.Maersk_User_Id__c;
        List<Territory_Account_Association__c> lstTAAs = [Select Id,Name from Territory_Account_Association__c Limit 1];
        String taaName = lstTAAs[0].Name;
        String data = '[["TAA NUMBER","Portfolio Owner Maersk ID","Start Date"],["' + taaName + '","' + maerskId + '","12/04/2023"],["1","2",""],["1","",""],["","3",""],["TAA-7739190","6",""],["1","AAK172",""],["TAA-7739206","SJA447",""]]';
        MassTransferCSVController.ProjectResponseWrapper responseWrapper = MassTransferCSVController.uploadData(data);
        data = '[["TAA NUMBER","Portfolio Owner Maersk ID","Start Date"],["' + taaName + '","' + maerskId + '","12/04/2040"],["1","2",""],["1","",""],["","3",""],["TAA-7739190","6",""],["1","AAK172",""],["TAA-7739206","SJA447",""]]';
        responseWrapper = MassTransferCSVController.uploadData(data);
        Test.stopTest();
        System.assertEquals(7, responseWrapper.totalRecords);
    }
}