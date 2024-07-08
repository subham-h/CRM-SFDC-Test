/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Controller of externalCaseHistory LWC component
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-9190   19-Oct-2023  Shahanawaz@Maersk       Created
 * 
*/
public class ExternalCaseHistoryController {
    
    /** 
        * @description | get external case history
        * @param recId accepts parentId
        * SC-9190
    */
    @AuraEnabled
    public static List<ExternalCaseHistoryWrapper> getCaseHistoryList(Id recId){
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> usrMap = new Map<Id, User>();
        List<ExternalCaseHistoryWrapper> extWrapList = new List<ExternalCaseHistoryWrapper >();
        List<Casehistoryarchival__x> csHistoryList = new List<Casehistoryarchival__x >();
        if(Test.isRunningTest()){
            csHistoryList.add(new Casehistoryarchival__x(caseid__c = '5001X00000IxaWQQAZ', createdbyid__c = UserInfo.getUserId(), createddate__c = String.valueOf(System.now()), field__c = 'Priority', oldvalue__c = 'Medium', newvalue__c = 'High'));
        }
        else{
            csHistoryList = [Select caseid__c, createdbyid__c, createddate__c, field__c, oldvalue__c, newvalue__c From Casehistoryarchival__x Where caseid__c != null AND caseid__c =: recId Order By createddate__c DESC];
        }
        
        for(Casehistoryarchival__x ch : csHistoryList){
            if(!String.isBlank(ch.createdbyid__c)){
                userIds.add(ch.createdbyid__c);
            }
        }
        if(!userIds.isEmpty()){
            usrMap = new Map<Id, User>([Select Id, Name From User Where Id =: userIds]);
        }
        for(Casehistoryarchival__x ch : csHistoryList){
            String usersName = (usrMap.containsKey(ch.createdbyid__c) && usrMap.get(ch.createdbyid__c) != null) ? usrMap.get(ch.createdbyid__c).Name : '';
            ExternalCaseHistoryWrapper ech = new ExternalCaseHistoryWrapper(ch.caseid__c, ch.createdbyid__c, usersName, ch.field__c, ch.createddate__c, ch.oldvalue__c, ch.newvalue__c);
            extWrapList.add(ech);
        }
        extWrapList.sort();
        for(ExternalCaseHistoryWrapper ech : extWrapList){
            List<String> strList = ech.createdDate.replace('T', ' ').split(' ');
            List<String> dateList = strList[0].split('-');
            List<String> timeList = strList[1].split(':');
            Datetime dt = Datetime.newInstanceGMT(Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[2]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2]));
            ech.createdDateText = dt.format();
        }
        return extWrapList;
    }
    
    public class ExternalCaseHistoryWrapper implements Comparable{
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String createdById;
        @AuraEnabled
        public String createdByName;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String createdDate;
        @AuraEnabled
        public String oldValue;
        @AuraEnabled
        public String newValue;        
        @AuraEnabled
        public String createdDateText;
        
        public ExternalCaseHistoryWrapper(String caseId, String createdById, String createdByName, String fieldName,  String createdDate, String oldValue, String newValue){
            this.caseId = caseId;
            this.createdById = createdById;
            this.createdByName = createdByName;
            this.fieldName = fieldName;
            this.createdDate = createdDate;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
        
        public Integer compareTo(Object objToCompare){
            return createdDate.compareTo(((ExternalCaseHistoryWrapper)objToCompare).createdDate) * -1;
        }
    }
    
}