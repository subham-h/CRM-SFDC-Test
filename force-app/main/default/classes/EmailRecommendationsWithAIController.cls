/*
Description  : Query data for Related email recommendations to a case for LWC component 

* version       Date                Owner                         Description
*******************************************************************************************************************
* V1.0          07/08/2023          Vivek@maersk                  SC-8489- Aura handlers to display recommendations to UI
* V2.0          06/03/2024          Vivek@maersk                  SC-9866- Updated with new method for getResolutionRecommendations() 
* V3.0          22/03/2024          Meghna@maersk                 SC-9543- Updated with new method for getCaseRecommendationFlag() 
* V4.0          29/04/2024          Vazid                         SC-10036- Update case owner to original queue when agent click on accept/reject icons in the resolution recommendation screen
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class EmailRecommendationsWithAIController {
 
    @AuraEnabled(cacheable=true)
    public static List<Case_Recommendation__c> getEmailRecommendations(String recId, String recordTypeName) {
           List<Case_Recommendation__c> returnRecomList  =  new List<Case_Recommendation__c>();
    
           returnRecomList = [SELECT Id, case__c, case__r.status,Total_No_Of_Recommendation_Lines__c, case__r.Case_Reopened__c, case__r.Total_Outbound_Emails_minus_Handshake__c,Recommendation_Id__c, priority__c ,email_recommendation__C, recommendation_summary__c, Name FROM case_Recommendation__C where recordType.name=:recordTypeName and case__r.Email_Recommendation_Acceptance__c != 'Recommendations Failed' and Recommendation_Id__c != 'NO_RECOMMENDATIONS' and  case__c =: Id.valueOf(recId)  and  case__r.Total_Outbound_Emails_minus_Handshake__c < 1 and case__r.isClosed = false  order by priority__c desc];
            
          if(returnRecomList.size()>0)
              return returnRecomList;
          else
              return null;
      }
    @AuraEnabled(cacheable=false)
    public static List<Case> getCaseRecommendationFlag(String recordId) {
           List<Case> lstCase  =  new List<Case>();

           //lstCase = [SELECT Id,AI_Relevance_percentage_Flag__c,Count_Case_Outbound_Email__c from case where id =: Id.valueOf(recordId)];
        
            for(Case cs:[SELECT Id,AI_Relevance_percentage_Flag__c,Count_Case_Outbound_Email__c from case where id =: Id.valueOf(recordId)]){
                if( cs.AI_Relevance_percentage_Flag__c==true)
                    lstCase.add(cs);
            }
        
        return lstCase;

      }
  
    
    @AuraEnabled(cacheable=true)
    public static List<Case_Recommendation__c> getResolutionRecommendations(String recId, String recordTypeName) {
        List<Case_Recommendation__c> returnRecomList  =  new List<Case_Recommendation__c>();
    
        For(Case_Recommendation__C cr : [SELECT Id, case__c, case__r.status,Total_No_Of_Recommendation_Lines__c, case__r.Case_Reopened__c, 
                                         case__r.Total_Outbound_Emails_minus_Handshake__c,Recommendation_Id__c, priority__c ,email_recommendation__C, 
                                         recommendation_summary__c, Name, Case__r.Case_Country__c, Action_Status__c, case__r.OwnerId, Translated_Query__c
                                         FROM case_Recommendation__C 
                                         WHERE recordType.name=:recordTypeName and case__r.Email_Recommendation_Acceptance__c != 'Recommendations Failed' and Recommendation_Id__c != 'NO_RECOMMENDATIONS' and  case__c =: Id.valueOf(recId) /*and  case__r.Total_Outbound_Emails_minus_Handshake__c < 1 and case__r.isClosed = false*/  order by priority__c desc]){
               returnRecomList.add(cr);
        }
            
          if(returnRecomList.size()>0)
              return returnRecomList;
          else
              return null;
      }
    
    @AuraEnabled//method to update action status when a recommendation is copied in UI and datetime captured for the same.
      public static void updateActionStatus(String recId, string recordId, String recordTypeName) {
           List<Case_Recommendation__c> recomListToUpdate  =  new List<Case_Recommendation__c>();
    
          for(Case_Recommendation__c thisRecom : [SELECT Id, case__c, Action_Status__c, case__r.status, case__r.Case_Reopened__c, case__r.Total_Outbound_Emails_minus_Handshake__c, priority__c ,email_recommendation__C, recommendation_summary__c, Name FROM case_Recommendation__C where recordType.name =:recordTypeName and case__c =: Id.valueOf(recordId)]){
              
              if(thisRecom.Action_Status__c != '' && thisRecom.Id != recId){
                  thisRecom.Action_Status__c = '';
                  thisRecom.Email_Recommendation_Accepted_Time__c = null;
                  recomListToUpdate.add(thisRecom);
              }else if(thisRecom.Id == recId){
                  thisRecom.Action_Status__c = 'Accepted';
                  thisRecom.Email_Recommendation_Accepted_Time__c = system.now();
                  recomListToUpdate.add(thisRecom);
              }
              
          }
          if(recomListToUpdate.size()>0)
              update recomListToUpdate;
      }
   
    /*Change Case owner to origin queue when accept/Reject the case from AI Resolution screen*/
    @AuraEnabled
    public static string  changeOwnerToPreviousQueue(String recId, string caseRecommendationId, string strRejectComments) {
        Case caseRecord = [SELECT Id, OwnerId, ( select Id, CreatedDate, OldValue, NewValue, Field, 
                                                CaseId from Histories Where (Field = 'Owner' OR Field = 'ownerAssignment') AND 
                                                DataType = 'EntityId' Order By CreatedDate ASC limit 1)
                           FROM Case WHERE Id = :recId
                          ];
         
        string strMsg = 'success';
        Savepoint sp = Database.setSavepoint();
        if(caseRecord != null && !caseRecord.Histories.isEmpty() && caseRecord.OwnerId != (string)caseRecord.Histories[0].OldValue){
            try {
                caseRecord.OwnerId = (string)caseRecord.Histories[0].OldValue;
                update caseRecord;
            }catch (DMLException  e) {
                strMsg = e.getMessage();
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        }
        /*Set show Accept Reject Icons flag to false once agent accept/reject the case from AI Resolution recommendatin screen*/
        Case_Recommendation__c careRecommendationRec = [select Id, Name, Action_Status__c from Case_Recommendation__c where Id =:caseRecommendationId Limit 1];
        if(careRecommendationRec != null && strMsg == 'success'){
            careRecommendationRec.Action_Status__c = 'Rejected';
            careRecommendationRec.Rejection_Comments__c = strRejectComments;
            try {
                
                update careRecommendationRec;
            }catch (DMLException  e) {
                Database.RollBack(sp);
                strMsg = e.getMessage();
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        }
        return strMsg;
    }
}