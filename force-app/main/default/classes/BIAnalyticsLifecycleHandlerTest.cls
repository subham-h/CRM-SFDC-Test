/*
* version   Date         Owner             Description
*******************************************************************************************************
* V1.0      03/10/2018   Nitin More        Test class code created
*/
@isTest
private class BIAnalyticsLifecycleHandlerTest {

    static testMethod void testDefaultMockValues(){
        Canvas.RenderContext mock = Canvas.Test.mockRenderContext(null,null);
	    
        // Test handler using the default mock RenderContext Canvas.Test creates
        BIAnalyticsLifecycleHandler handler = new BIAnalyticsLifecycleHandler();
        Canvas.Test.testCanvasLifecycle(handler,mock);

        BI_Analytics_Mapping__mdt scvContractBIMapping = [SELECT Label, MasterLabel, Active__c, Path__c, Query_Path_1__c, Query_Path_2__c FROM BI_Analytics_Mapping__mdt
															WHERE Active__c = true AND MasterLabel = 'SCV_CONTRACT' limit 1];

        String testSTRQueryPath2 = scvContractBIMapping.Query_Path_2__c.replace('<<SCV_CODE>>','123456');
       	String testSTRURLPath = 'https://www.mock.server' + scvContractBIMapping.Path__c + scvContractBIMapping.Query_Path_1__c + testSTRQueryPath2;

        //System.debug('# scvContractBIMapping: ' + scvContractBIMapping);
        //System.debug('# testSTRURLPath :' + testSTRURLPath); 
        //System.debug('# canvas url: ' + mock.getApplicationContext().getCanvasURL());
        System.assertEquals(testSTRURLPath, mock.getApplicationContext().getCanvasURL(), 'Canvas URL Path doesnot match');
    }
    
    static testMethod void testexcludeContextTypes(){
    	
    	Set<Canvas.ContextTypeEnum> setContext = BIAnalyticsLifecycleHandler.excludeContextTypes();
    	//System.debug('# setContext.size: ' + setContext.size());
        System.assertEquals(1, setContext.size(), 'Exclude Context size doesnot match');
    }
}