/*
* version   Date         Owner             Description
*******************************************************************************************************
* V1.0      03/10/2018   Nitin More        Lifecycle handler class created
*/
public class BIAnalyticsLifecycleHandler implements Canvas.CanvasLifecycleHandler{
     
    public static Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        excluded.add(Canvas.ContextTypeEnum.ORGANIZATION);
        return excluded;
    }
    
    public void onRender(Canvas.RenderContext renderContext){
    	
    	Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();
		Canvas.ApplicationContext app = renderContext.getApplicationContext();
    	Map<String, Object> mapEnvParams = (Map<String, Object>) JSON.deserializeUntyped(env.getParametersAsJSON());
    	String strRpID = (Test.isRunningTest())? 'SCV_CONTRACT': String.valueOf((String)mapEnvParams.get('pReportId'));
    	String strRpP1 = (Test.isRunningTest())? '123456' : String.valueOf((String)mapEnvParams.get('pReportParam1'));
    	
    	//System.debug('# strRpID:' + strRpID);
        //System.debug('# strRpP1:' + strRpP1);
    	
    	BI_Analytics_Mapping__mdt biReportConfig = [SELECT MasterLabel, Active__c, Path__c, Query_Path_1__c, Query_Path_2__c 
																FROM BI_Analytics_Mapping__mdt
																WHERE MasterLabel = :strRpID
																AND Active__c = true
																Limit 1];
        
        //System.debug('# biReportConfig:' + biReportConfig);
        
        if (biReportConfig != null){
        	String strQueryPath2;
        	
        	if (strRpID == 'SCV_CONTRACT'){
        		strQueryPath2 = biReportConfig.Query_Path_2__c.replace('<<SCV_CODE>>',strRpP1);
        	}
        	
        	String strURLPath = biReportConfig.Path__c + biReportConfig.Query_Path_1__c + strQueryPath2;

        	System.debug('# strURLPath : ' + strURLPath);
        	app.setCanvasUrlPath(strURLPath);
        }
    }
}