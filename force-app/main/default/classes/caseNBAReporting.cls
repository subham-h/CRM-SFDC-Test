/*
Description  : This Class is designed to Update NBA Reporting fields

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           02/05/2022         sunil.bs@maersk.com                         Moved NBA Reporting fields to new class to reolve edge case issues
*-------------------------------------------------------------------------------------------------------------------
*/
global with sharing class caseNBAReporting {

       public class NBAReportingInputs{
            @invocablevariable(label = 'Case Id')
            public string caseId;       
            @InvocableVariable
            public list<recommendation> recommendationlist;
        }
    
    @invocableMethod(label = 'NBAReportingUpdate')
    public static list<list<Recommendation>> NBAReportingUpdate (List<NBAReportingInputs> inputrequests){
 
            case inputcase;
            List<List<Recommendation>> recomreclist = new List<List<Recommendation>>();
        
        try{
            if(!inputrequests.isEmpty()){
                if(!inputrequests[0].recommendationlist.isEmpty()){
                    recomreclist.add(inputrequests[0].recommendationlist);
                    inputcase = [select Id,Recommendation_Presented__c from case where Id =: inputrequests[0].caseId];   
                    if(inputcase != null && String.isEmpty(inputcase.Recommendation_Presented__c) && !recomreclist.isEmpty() && !recomreclist[0].isEmpty() && recomreclist[0][0] != null){ 
                        TriggerExecutionController.skipCaseTrigger(true); 
                        inputcase.Recommendation_Presented__c=recomreclist[0][0].Name;
                        update inputcase;
                        TriggerExecutionController.skipCaseTrigger(false);           
                    }
                }
            }   
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'NBAReportingUpdate', new list<Exception>{ex});
            }
         return recomreclist;                 
    }
    
}