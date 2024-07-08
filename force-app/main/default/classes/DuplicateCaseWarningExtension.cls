/*
 * Author   : Peter Aubrey
 * Purpose  : New and improved controller for finding duplicate cases and displaying a count of how many it has found.
 *          
 * Revision Ref Number  Date            Owner                   Description
 * -------- ----------  -----------     -------------------     -----------
 * 1.0      RQ-002150   01-Dec-2015     peter.aubrey@maersk.com Code created.
 * 2.0      RQ-003781   23-May-2016     Ragu@UST                Optimized to improve performance to resolve slowness issue in console.
 * 3.0      RQ-004078   12-July-2016    Ananth@UST              Resolve QueryException: List has no rows for assignment to SObject.    
 * 4.0      RQ-009908   17-Jan-2019     Vivek@IBM
 * 5.0      RQ-009942   25-Jan-2019     Vivek@IBM
 * 6.0      SC-1316     25-11-2020      ramadevi@ust            Added WhatsApp Case Channel to be excluded
 * 7.0      SC-2138     28-04-2021      Sunil BS                To Skip country-direction check for calculating duplicates for SCM
 * 8.0      SC-6887     04-Apr-2023     Nayana@maersk.com        Calling LWC method for coverage of LWC part
 */
 
public with sharing class DuplicateCaseWarningExtension {

    public Id focusCaseId {get; set;}
    public String focusCaseNumber {get; set;}
    public Integer possibleDupes {get; set;}
    public Boolean isDuplicateCalculated {get; set;}
    public AggregateResult[] groupedResults;
  
    public DuplicateCaseWarningExtension(ApexPages.StandardController controller) {
        possibleDupes = 0;
        isDuplicateCalculated = false;
        focusCaseId = controller.getId();
        
        // v3.0 - Added && String.valueOf(focusCaseId).startsWith('500') in below if condition
        if(focusCaseId != null && String.valueOf(focusCaseId).startsWith('500')) {
            // Get the details of the focus Case in order to find other duplicates...
            list<Case> lstCases = [SELECT Id, CaseNumber, CreatedDate, Country__c, Direction__c, Liner_Brand__c, ParentId, Thread_Topic__c, Status,Case_Channel__c,recordtypeId,Product__c FROM Case WHERE Id = :focusCaseId];
            if(lstCases != null && !lstCases.isEmpty()) {
                Case focusCase = lstCases[0];
                focusCaseNumber = focusCase.CaseNumber;
                
                // v2.0 - Added condition to check whether Thread_Topic__c is not null
                // RQ-009908: Added condition to restrict possible duplicate calculation only for case with status Trigaged or New.
                // RQ-012743 : Duplicate section should not be shown for Chat Cases
                // SC-1320 Removed populating for status 'new'
                if(!String.isBlank(focusCase.Thread_Topic__c) && (focusCase.Status == Label.CaseTriaged || focusCase.Status == Label.CaseNew) && (focusCase.Case_Channel__c <> Label.Chat_Case_Channel || focusCase.Case_Channel__c <> Label.WhatsApp_Case_Channel)) {
                     // RQ-009942: Flag to check possible duplicate execution
                     isDuplicateCalculated = true;
                    // RQ-009908: We're only interested in Cases created within a 2 week window, 1 weeks before and 1 weeks after the Case was created.
                    // Get all possible duplicates including focusCase using an aggregate result for efficiency...
                    
                         groupedResults = [SELECT COUNT(Id) possibleDuplicates 
                                                        FROM Case WHERE Thread_Topic__c = :focusCase.Thread_Topic__c
                                                            AND CreatedDate > :focusCase.CreatedDate.addDays(-14) AND CreatedDate < :focusCase.CreatedDate.addDays(14)
                                                            AND Status in :Label.Non_Merged_Case_Status.split(', ')                                                          
                                                            AND Liner_Brand__c = :focusCase.Liner_Brand__c
                                                        	AND RecordtypeId = :focusCase.recordtypeId//SC-2094: Display duplicates with same record type only
                                                            AND ParentId = null];
                                   
                    
                    possibleDupes = Integer.valueOf(groupedResults[0].get('possibleDuplicates'));
                    if(possibleDupes > 0) {
                        possibleDupes = possibleDupes - 1;
                    }
                }
            }
        }
    }

    //SC-102
    @AuraEnabled(Cacheable=true)
    public static Integer getPossibleDupes(String focusCaseId) {
        //Id focusCaseId;
        String focusCaseNumber;
        Integer possibleDupes = 0;
        Boolean isDuplicateCalculated = false;
        AggregateResult[] groupedResults;        
        
        // v3.0 - Added && String.valueOf(focusCaseId).startsWith('500') in below if condition
        system.debug('id'+focusCaseId);
        if(focusCaseId != null && String.valueOf(focusCaseId).startsWith('500')) {
            // Get the details of the focus Case in order to find other duplicates...
            list<Case> lstCases = [SELECT Id, CaseNumber, CreatedDate, Country__c, Direction__c, Liner_Brand__c, ParentId, Thread_Topic__c, Status,Case_Channel__c,recordtypeId,Product__c FROM Case WHERE Id = :focusCaseId];
            if(lstCases != null && !lstCases.isEmpty()) {
                Case focusCase = lstCases[0];
                focusCaseNumber = focusCase.CaseNumber;
                
                if(!String.isBlank(focusCase.Thread_Topic__c) && (focusCase.Status == Label.CaseTriaged || focusCase.Status == Label.CaseNew) && (focusCase.Case_Channel__c <> Label.Chat_Case_Channel || focusCase.Case_Channel__c <> Label.WhatsApp_Case_Channel)) {
                     isDuplicateCalculated = true;                    
                    
                         groupedResults = [SELECT COUNT(Id) possibleDuplicates 
                                                        FROM Case WHERE Thread_Topic__c = :focusCase.Thread_Topic__c
                                                            AND CreatedDate > :focusCase.CreatedDate.addDays(-14) AND CreatedDate < :focusCase.CreatedDate.addDays(14)
                                                            AND Status in :Label.Non_Merged_Case_Status.split(', ')                                                          
                                                            AND Liner_Brand__c = :focusCase.Liner_Brand__c
                                                        	AND RecordtypeId = :focusCase.recordtypeId//SC-2094: Display duplicates with same record type only
                                                            AND ParentId = null];
                                   
                    
                    possibleDupes = Integer.valueOf(groupedResults[0].get('possibleDuplicates'));
                    if(possibleDupes > 0) {
                        possibleDupes = possibleDupes - 1;
                    }
                }
            }
        }
        return possibleDupes;
    }

}