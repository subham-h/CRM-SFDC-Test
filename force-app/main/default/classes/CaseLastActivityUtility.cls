/*
 * Author   : Mohammad Naved
 * Purpose  : Update Case 'Last Meaningful Activity' field update with current date/time.
 *        
 * Revision Ref Number  Date        Owner                           Description
 * -------- ----------  ----------- -------------------             -----------
 * 1.0      RQ-009492   08/07/2016 mohammed.naved@maersk.com         Code created
 * 
 */  
 public class CaseLastActivityUtility {
     public static void updateCasefield(Set<Id> setCaseId){
         try{
             List<Case> lstCase = new List<Case>();
             for(Id caseId : setCaseId) {
                 //Get all the task's cases and make last Meaning Activity as current day time
                 case c = new case(id = caseId , Last_Meaningful_Activity__c = System.now());
                 lstCase.add(c);
             
             }
             //Update all the cases
         
             if(lstCase.size()>0){
                 update lstCase;
                 system.debug('lstCase#'+lstCase);
             }
         }  
         catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseLastActivityUtility.updateCasefield(list<Case> lstCases)', new list<Exception>{ex});  
        }    
     }
 }