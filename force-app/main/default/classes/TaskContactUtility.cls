/*              
* Revision Ref Number  Date            Owner                  Description
* -------- ----------  -----------     -------------------    -----------
* 1.0      RQ-004146   30/11/2018      Sreya.V@Maersk         Created for Implementing Contact Update on Task Related To Case
*/
public class TaskContactUtility {
    
    //RQ-004146 - Update Contact of Task related to Case and of type Call
    public static void populateContact(List<task> lstTask,set<Id> caseIds){
        
		Map<String,String> mapCaseContact = new Map<String,String>();
        //Querying the Ids and related Contacts from Cases which are Related to Tasks
        for(Case objCS : [select Id,ContactId from case where Id in:caseIds])
        { 
            mapCaseContact.put(objCS.Id, objCS.ContactId);
        }  
        //Updating WhoId of Task with the ContactId of related Case
        for(task currentTask : lstTask){
            if(mapCaseContact.get(currentTask.WhatId) != null){
                 currentTask.WhoId  = mapCaseContact.get(currentTask.WhatId);
            }                      
        }        
    }       
}