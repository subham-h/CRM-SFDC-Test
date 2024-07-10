/**
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      SC-7083     18-03-2023  ramadevi@maersk.com     Invocable method called from Flow to perform Custom Action on recommendation.
 */

Global with sharing class CustomNBAAction{
     public class caseinput{
        @InvocableVariable(label='Case ID')
        public String caseId;
        
        @InvocableVariable(label='Recommendation Name')
        public String recommendationName;
        
        @InvocableVariable(label='Object Name')
        public String objectName;
        
        @InvocableVariable(label='Field Name')
        public String fieldName;
    }
    
    @InvocableMethod(label='Run NBA Action')
    public static void runNBAction(list<caseinput> inputrequests){        
        if(inputrequests <> null){        
            if(inputrequests[0].objectName == 'Case' && inputrequests[0].fieldName == 'Resolution_Summary__c'){
                CustomNBAActionUtilityClass.inputs updInputs = new CustomNBAActionUtilityClass.inputs();
                updInputs.caseId = inputrequests[0].caseId;
                updInputs.recommendationName = inputrequests[0].recommendationName;
                CustomNBAActionUtilityClass.UpdateResolSummForContainerTracking(new List<CustomNBAActionUtilityClass.inputs>{updInputs});
            }
        }
    
    }
}