@isTest
public class ArchivedCaseTrigger_Test {
   //Without country and Account 
   public static list<Archived_Case__c> lstCases = new list<Archived_Case__c>();
   public static boolean bCreate = true;
   public static integer iNumberOfCases = 5;
    
    //For the use of case without contact and account
  @isTest
  private static void populateCommonCaseFieldsII() {    
        list<Archived_Case__c> lstCases = new list<Archived_Case__c>();
        Id extCaseRTId = Schema.SObjectType.Archived_Case__c.getRecordTypeInfosByDeveloperName().get('External_Case').getRecordTypeId();
        Archived_Case__c caseIterator = new Archived_Case__c();
        caseIterator.Subject__c = 'CaseTestData Subject_';
        caseIterator.Description__c = 'CaseTestData Description_';
        caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
        caseIterator.Status__c = 'Triaged';
        caseIterator.Type__c = 'Prior To Booking';
        caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
        //caseIterator.Country__c = BDAGeographyData_Test.countryUK.Id;
        caseIterator.Cargo_Classification__c ='US Military (USM)';
        caseIterator.Liner_Brand__c = brandutilities.MAERSK;
        caseIterator.Direction__c = 'Export';
        caseIterator.Case_Channel__c = 'Chat';
        caseIterator.SuppliedEmail__c = Null;
        caseIterator.Case_Origin__c = 'MSLUSEXP';
        caseIterator.Case_Visibility__c = 'All Users';
        caseIterator.recordtypeid = Archived_Case__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.External_Case).getRecordTypeId();
        lstCases.add(caseIterator);
        insert lstCases;
        Map<Id, Archived_Case__c> oldMap = new Map<Id, Archived_Case__c>();
        for(Archived_Case__c arccaseIterator : lstCases) {
            oldMap.put(arccaseIterator.Id, arccaseIterator);
            arccaseIterator.status__c = 'Closed - Not a case';
            arccaseIterator.type__c = 'Booking';
            arccaseIterator.Sub_Type__c = 'Amend Booking Details';
            arccaseIterator.Resolved_Reason__c = 'Accepted';
            arccaseIterator.Reason_For_Case__c = 'Amend Booking Details';
        }
        update lstCases;
                ArchivedCaseTriggerHandler casTriggerHandler = new ArchivedCaseTriggerHandler();
        ArchivedCaseRecordSelector caseRecord = new ArchivedCaseRecordSelector(lstcases, oldMap, casTriggerHandler);
        
        }
    
    
}