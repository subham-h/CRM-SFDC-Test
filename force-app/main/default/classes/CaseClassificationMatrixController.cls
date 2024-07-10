/*
* Author   : Sreya@Maersk
* Purpose  : Controller class for CaseClassificationMatrix lightning component.          
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-009634   20-12-2018  Sreya@Maersk            Returns the fieldset info and case classification matrix custom metadata type
*                                                          for custom update Case component.
* 2.0      RQ-011564   20-09-2019  Sreya@Maersk            Created new Method for accessing Case Classification Metadata and related CaseId
*                                                          for custom update Case component.
* 3.0      SC-9385     21-11-2023  ramadevi@Maersk         Added Case Classification to MessagingSession Object.
*/


public class CaseClassificationMatrixController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Case_Classification_Matrix__mdt> readClassificationMatrix()
    {
       
        // returns the the metadata type 'Case_Classification_Matrix__mdt' records to the client side controller.
        return [select id,sort_order__c,MasterLabel,Product__c,Reason_For_Case__c,Sub_Type__c,Type__c,Product_Label__c,Type_Label__c,Sub_Type_Label__c,Reason_For_Case_Label__c
                from Case_Classification_Matrix__mdt order by sort_order__c asc];    
        
    }
        
    //Method for getting case classification metadata and related caseId for LiveChatTranscript.
    @AuraEnabled(cacheable=true)
    public static LiveChatClassificationWrap readChatTranscriptClassification(string recordId,string objectName)
    {       
        LiveChatClassificationWrap wrap = new LiveChatClassificationWrap();
        wrap.mdtListClassification = [select id,sort_order__c,MasterLabel,Product__c,Reason_For_Case__c,Sub_Type__c,Type__c,Product_Label__c,Type_Label__c,Sub_Type_Label__c,Reason_For_Case_Label__c
                                      from Case_Classification_Matrix__mdt order by sort_order__c asc]; 
        if(objectName == 'LiveChatTranscript'){
            LiveChatTranscript chatRec = [select caseId from LiveChatTranscript where Id=:recordId];
            if(chatRec != null){
                wrap.chatCaseId = chatRec.caseId;
            }
        }
        if(objectName == 'MessagingSession'){
            MessagingSession chatRec = [select caseId from MessagingSession where Id=:recordId];
            if(chatRec != null){
                wrap.chatCaseId = chatRec.caseId;
            }
        }
        return wrap;
        
    }
    public class LiveChatClassificationWrap{
        @AuraEnabled public List<Case_Classification_Matrix__mdt> mdtListClassification{get;set;}
        @AuraEnabled public string chatCaseId{get;set;}       
    }   
    
}