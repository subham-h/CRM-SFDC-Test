/*
 * Created By   : Vivek@Maersk
 * Purpose  :     Manager class to implement case recommendation object related logic.
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      SC-8489   08-Aug-2023  Vivek@Maersk            Trigger Handler on Case Recommendation Object
 * 2.0      SC-8489   08-Aug-2023  Vivek@Maersk            formatEmailRecommendationOnBeforeInsert method to format email body before inserting to records.
 * 3.0		SC-8490	  22-Aug-2023  Vivek@Maersk			   Update case field Email_Recommendation_Acceptance__c when a recommendation is created
 * 4.0		SC-9866	  12-March-2024  Vivek@Maersk		   added new record type check for resolution recommendation
 * 5.0		SC-10036  24-April-2024  Vazid 				   Update case owner to Checker queue if case gets resolution recommendation.
*/
public class CaseRecommendationManager {

    public static string emailRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Email Recommendation').getRecordTypeId();
    public static string resolutionRecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Resolution Recommendation').getRecordTypeId();
    public static string NBARecommRecTypeId = Case_Recommendation__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NBA Recommendation').getRecordTypeId();

    /*
    * @description | SC-8489 - Update the Email Recommendation Field with adding new lines inplace of \n  upon insert. 
    @param lstCaseRecommendations accepts the list of Case recommendations records
    */
        public static void formatEmailRecommendationOnBeforeInsert(List<Case_Recommendation__c> lstCaseRecommendations, set<Id> caseIds){
		    Map<Id, String> caseIdRecommendationMap= new Map<Id,String>();
            String[] lines ;
            // SC-10036 : Map to store if Case has resolution recommendations
        	Map<Id, Boolean> mapOfCaseIdContainsRR = new Map<Id, Boolean>();
            Map<Id, Case_Recommendation__C> caseIdRecommendationRecordMap= new Map<Id,Case_Recommendation__C>();
            
            for(Case_Recommendation__C thisCR : lstCaseRecommendations){
                if(thisCR.recordTypeId == emailRecommRecTypeId || thisCR.recordtypeId == resolutionRecommRecTypeId){
                    caseIdRecommendationRecordMap.put(thisCR.Case__c,thisCR);
                    //Scenario to update the Email Recommendation Acceptance field with Recommendations Failed
                    if(thisCR.Recommendation_Id__c != null && thisCR.Recommendation_Id__c == 'NO_RECOMMENDATIONS'){
                        
                        caseIdRecommendationMap.put(thisCR.Case__c,'NO_RECOMMENDATIONS');

                    }
                    else{
                        List<String> tempStringList = new List<String>();
                        String tempString = thisCR.email_recommendation__c.replace('\\n','NEWLINE');
                        //testString = thisCR.email_recommendation__c.replace('\\n\\r','NEWLINE');
                    
                        tempStringList = tempString.split('NEWLINE');
                        tempString = String.join(tempStringList, '\n');   
                        thisCR.email_recommendation__c = tempString+'\r\n'+'\r\n';
                        //calculating total no of lines in email body
                        lines = thisCR.email_recommendation__C.split('\n');
                        thisCR.Total_No_Of_Recommendation_Lines__c = lines.size()+1;
                        caseIdRecommendationMap.put(thisCR.Case__c,'Recommendations Available');
                        //SC-10036 : Check if the case Id has resolution recommendation or not
                        if(thisCR.recordtypeId == resolutionRecommRecTypeId ){//&& thisCR.Action_Status__c == 'Hold'
                            mapOfCaseIdContainsRR.put(thisCR.Case__c, true);
                            //thisCR.addERROR('dml is not possible');
                        }
                    }
                }
            }
            
            if(!caseIdRecommendationMap.isEmpty())
            {
                /*SC-10036 : Get assignment rule for case object*/
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id; 
                
               TriggerExecutionController.skipCaseTrigger(true);
                List<Case> caseList  = new List<Case>();
                set<string> checkerQueueCaseIds  = new set<string>();
                For(Case thisCase : [Select id, Email_Recommendation_Acceptance__c, isClosed, OwnerId, Case_Country__c, Direction__c from case where ID in :caseIdRecommendationMap.keySet()]){
                    
                    // Making Email_Recommendation_Acceptance__c to null to execute the logic to populate the fields on the re-trigger case 
                    if(!caseIds.isEmpty() && caseIds.Contains(thisCase.Id)){
                        thisCase.Email_Recommendation_Acceptance__c = null;
                    }
                    
                    if(thisCase.Email_Recommendation_Acceptance__c == 'Recommendations Available' || thisCase.Email_Recommendation_Acceptance__c == 'Recommendations Failed'){
                        continue;
                    }else if(caseIdRecommendationMap.containsKey(thisCase.id) && caseIdRecommendationMap.get(thisCase.id) == 'NO_RECOMMENDATIONS'){
                            
                        thisCase.Email_Recommendation_Acceptance__c = 'Recommendations Failed';
                        
                        /*SC-10036 : Populate Type of recommendation value based on case recommendation record Type*/
                        if(caseIdRecommendationRecordMap.containsKey(thisCase.id) && caseIdRecommendationRecordMap.get(thisCase.id) != null && caseIdRecommendationRecordMap.get(thisCase.id).RecordTypeId == resolutionRecommRecTypeId){
                            thisCase.AI_Recommendation_Type__c = Schema.SObjectType.Case_Recommendation__c.getRecordTypeInfosById().get(resolutionRecommRecTypeId).getName();
                        }else if(caseIdRecommendationRecordMap.containsKey(thisCase.id) && caseIdRecommendationRecordMap.get(thisCase.id) != null && caseIdRecommendationRecordMap.get(thisCase.id).RecordTypeId == emailRecommRecTypeId){
                            thisCase.AI_Recommendation_Type__c = Schema.SObjectType.Case_Recommendation__c.getRecordTypeInfosById().get(emailRecommRecTypeId).getName();
                            
                        }
                        caseList.add(thisCase);
                    }else{
                        
                        /*SC-10036 : Populate Type of recommendation value based on case recommendation record Type*/
                        if(caseIdRecommendationRecordMap.containsKey(thisCase.id) && caseIdRecommendationRecordMap.get(thisCase.id) != null && caseIdRecommendationRecordMap.get(thisCase.id).RecordTypeId == resolutionRecommRecTypeId){
                            thisCase.AI_Recommendation_Type__c = Schema.SObjectType.Case_Recommendation__c.getRecordTypeInfosById().get(resolutionRecommRecTypeId).getName();
                        }else if(caseIdRecommendationRecordMap.containsKey(thisCase.id) && caseIdRecommendationRecordMap.get(thisCase.id) != null && caseIdRecommendationRecordMap.get(thisCase.id).RecordTypeId == emailRecommRecTypeId){
                            thisCase.AI_Recommendation_Type__c = Schema.SObjectType.Case_Recommendation__c.getRecordTypeInfosById().get(emailRecommRecTypeId).getName();
                            
                        }
                        
                        thisCase.Email_Recommendation_Acceptance__c = 'Recommendations Available';
                        //SC-10036 : If case has resolution recommendations then change the owner to Checker Queue by triggering auto assignment rule process.
                        // Only assign for open case those are still in queue
                        if(mapOfCaseIdContainsRR.containskey(thisCase.id) && Label.Checker_Queue_Regions.contains(thisCase.Case_Country__c)
                           && thisCase.IsClosed == false && thisCase.OwnerId.getSobjectType() == Group.SObjectType){                            
                               checkerQueueCaseIds.add(thisCase.id);
                               thisCase.AI_Recommendation_Status__c = 'Resolution Recommended';
                               thisCase.setOptions(dmlOpts);
                        }
                     	caseList.add(thisCase);
                    }
                    
                }
                if(!caseList.isEmpty()){
                   
                    Database.SaveResult[] results = Database.update(caseList, false);
                    
                    //SC-10036 : Delete the associated PSR records for checker queue cases to skip Omni skill logic
                    List<PendingServiceRouting> psrInScope = [SELECT id, workitemid FROM PendingServiceRouting WHERE workitemid IN :checkerQueueCaseIds];
                    if(!psrInScope.isempty()){
                        Database.DeleteResult[] resultsList = Database.delete(psrInScope, false);
                        ErrorLogger.writeErrors('SFDC', 'Case', 'CaseRecommendationManager.formatEmailRecommendationOnBeforeInsert'+checkerQueueCaseIds, resultsList, psrInScope);
                    }
                    
                    //SC-10036 : Set Show accept reject icons flag to true 
                    for(Case_Recommendation__C thisCR : lstCaseRecommendations){
                        if(checkerQueueCaseIds.contains(thisCR.Case__c) && (String.isEmpty(thisCR.Action_Status__c) || String.isBlank(thisCR.Action_Status__c))){
                            thisCR.Action_Status__c = 'Received';
                        }
                    }
                }
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
    
    /*Update Case owner to checker queue if recommendation Action Status = Hold*/
    public static void updateCaseRecordsWithCheckerQueue(set<Id> caseIds){  
        
        /*SC-10036 : Get assignment rule for case object*/
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        List<Case> caseList = [Select id, Email_Recommendation_Acceptance__c, isClosed, OwnerId, Case_Country__c, Direction__c from case where ID in :caseIds];
        for(Case thisCase : caseList){
            if(Label.Checker_Queue_Regions.contains(thisCase.Case_Country__c)
               && thisCase.IsClosed == false && thisCase.OwnerId.getSobjectType() == Group.SObjectType){    
                   thisCase.AI_Recommendation_Status__c = 'On Hold';
                   thisCase.setOptions(dmlOpts);
               }
        }
        TriggerExecutionController.skipCaseTrigger(true);
        Database.update(caseList, true);
        
        //SC-10036 : Delete the associated PSR records for checker queue cases to skip Omni skill logic
        List<PendingServiceRouting> psrInScope = [SELECT id, workitemid FROM PendingServiceRouting WHERE workitemid IN :caseIds];
        if(!psrInScope.isempty()){
            Database.DeleteResult[] resultsList = Database.delete(psrInScope, false);
            ErrorLogger.writeErrors('SFDC', 'Case', 'CaseRecommendationManager.updateCaseRecordsWithCheckerQueue'+caseIds, resultsList, psrInScope);
        }
        TriggerExecutionController.skipCaseTrigger(false);
    }
    
    /*Update Case owner to original queue if recommendation Action Status = Released*/
    public static void updateCaseRecordsToRemoveCheckerQueue(set<Id> caseIds){   
        List<Case> caseList = [Select id, Email_Recommendation_Acceptance__c, isClosed, OwnerId, Case_Country__c, Direction__c,
                               ( select Id, CreatedDate, OldValue, NewValue, Field, 
                                                CaseId from Histories Where (Field = 'Owner' OR Field = 'ownerAssignment') AND 
                                                DataType = 'EntityId' Order By CreatedDate ASC limit 1) from case where ID in :caseIds];
        for(Case thisCase : caseList){
            if(!thisCase.Histories.isEmpty() && thisCase.IsClosed == false && Label.Checker_Queue_Regions.contains(thisCase.Case_Country__c)){ 
                thisCase.AI_Recommendation_Status__c = 'No Resolution';
                thisCase.OwnerId = (string)thisCase.Histories[0].OldValue;
            }
        }
        TriggerExecutionController.skipCaseTrigger(true);
        Database.update(caseList, true);
        TriggerExecutionController.skipCaseTrigger(false);
    }
    
    /*Delete Case recommendation records if we get any recommendation for Action Status = Hold or Released*/
    public static void deleteCaseRecommRecords(List<Case_Recommendation__c> caseRecommList){   
        if(!caseRecommList.isEmpty())
            delete caseRecommList;
    }
    //To delete existing recommendations if we receive gen2 recommendation in re-trigger scenario
     public static void getExistingRecommList(set<Id> caseIds){   
        List<Case_Recommendation__c> lstOfCaseRecomm = [select Id from Case_Recommendation__c where Case__c IN:caseIds and recordTypeId !=: NBARecommRecTypeId];
        if(!lstOfCaseRecomm.isEmpty()){
            deleteCaseRecommRecords(lstOfCaseRecomm);
        }
    }
}