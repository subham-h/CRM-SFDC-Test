/*
* version   Date         Owner             Description
*******************************************************************************************************
* V1.0      03/10/2018   Nitin More        Test class code created
*/
@isTest
private class BIAnalyticsControllerTest {
	
	@testSetup static void setup() {
	
		TriggerExecutionController.skipAllTriggers(true);
		
		if (UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
        }
	}
	
    static testMethod void test_getMaerskUserId() {
    
	    User testMSLSysAdminUser = [SELECT Id, Username, Maersk_User_Id__c FROM User WHERE Username = 'Sase123dsaf@ust-global.com' limit 1];
	    String strMaerskUserId;
	    
	    System.runAs(testMSLSysAdminUser){
	    	Test.startTest();
	    		strMaerskUserId = BIAnalyticsController.getMaerskUserId();
	    	Test.stopTest();
	    }
	    
	    System.assertEquals(strMaerskUserId, testMSLSysAdminUser.Maersk_User_Id__c, 'Maersk User id is not valid');
    }
    
    static testMethod void test_getBIAnalyticsMappingDetails() {
    
	    User testMSLSysAdminUser = [SELECT Id, Username, Maersk_User_Id__c FROM User WHERE Username = 'Sase123dsaf@ust-global.com' limit 1];
	    List<BI_Analytics_Mapping__mdt> lstBIMapping = new List<BI_Analytics_Mapping__mdt>();
	    
	    System.runAs(testMSLSysAdminUser){
	    	Test.startTest();
	    		lstBIMapping = BIAnalyticsController.getBIAnalyticsMappingDetails();
	    	Test.stopTest();
	    }
	    
	    System.assert(lstBIMapping.size()>0 , 'BI Analytic mapping details not found');
    }
}