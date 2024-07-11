/*
* Author   : Ranjan 
* Purpose  : Case Consumer Event Handler
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 
* 1.1      RTMS-978    21/11/2023  Aditya                  Added the code to check artemis case number before creating cases.
*/

public without sharing class CaseConsumerEventHandler {


    /** 
    * @description | Method to create Sf cases. |
    * @param newList accepts the list of Case Consumer Event
    */

    public class CaseWrapper {
        @AuraEnabled public Case ca {get; set;}
        @AuraEnabled public Boolean isChecked {get; set;}
        @AuraEnabled public Boolean isParent {get; set;}
        @AuraEnabled public Boolean isFocus {get; set;}
        @AuraEnabled public String strOwnerName {get; set;}  
        @AuraEnabled public String caseUrl {get; set;}
        @AuraEnabled public String formattedDate {get; set;}
        @AuraEnabled public String colorText {get; set;}
        @AuraEnabled public Boolean accountPresent {get; set;}         
        
        public CaseWrapper(Case ca, String strOwnerName, Boolean isChecked, Boolean isParent, Boolean isFocus, String caseUrl, String formattedDate, String colorText, Boolean accountPresent) {
            this.ca = ca;
            this.strOwnerName = ca.Owner.Name;           
            this.isChecked = isChecked;
            this.isParent = isParent;
            this.isFocus = isFocus;
            this.caseUrl = caseUrl;
            this.formattedDate = formattedDate;
            this.colorText = colorText;
            this.accountPresent = accountPresent;
        }       
    }

    public static void createSFCases(List<Case_Consumer_Event__e> newList) {
        List<Map<String, Object>> artemisCaseList=new List<Map<String, Object>> ();
        for(Case_Consumer_Event__e cseConsumerEvObj:newList){
            String responseStr=cseConsumerEvObj.Json_1__c+(cseConsumerEvObj.Json_2__c!=null?cseConsumerEvObj.Json_2__c:'');
            Map<String, Object> objMap=(Map<String, Object>)JSON.deserializeUntyped(responseStr);
            artemisCaseList.add(objMap);
        }
        Map<String,String> fieldFromToMap=ArtemisEMPUtility.getPtEvtMetadata('Case Consumer');
        Set<String> caseIdForQuerySet=new Set<String>();
        List<Case> casesToUpsert=new List<Case>();
        for(Map<String, Object> obj:artemisCaseList){
            Map<String, Object> row = (Map<String, Object>)obj.get('message');
            Case cseObj=new Case();
            for(String keyStr:row.keySet()){
                if(!fieldFromToMap.containsKey(keyStr)){continue;}
                if((fieldFromToMap.get(keyStr).equalsIgnoreCase('id')&&row.get(keyStr)!='')||!fieldFromToMap.get(keyStr).equalsIgnoreCase('id')){
                    cseObj.put(fieldFromToMap.get(keyStr), ArtemisEMPUtility.formatValue('Case',fieldFromToMap.get(keyStr),row.get(keyStr)));
                }
            }
            casesToUpsert.add(cseObj);
            if(!String.isBlank(cseObj.Artemis_Case_Number__c)){
                caseIdForQuerySet.add(cseObj.Artemis_Case_Number__c);
            }
        }

        Map<Id,Case> existingCaseMap=new Map<Id,Case>();
        Map<String,Case> existingArtemisCaseMap = new Map<String, Case>();
        if(!caseIdForQuerySet.isEmpty()){
            existingCaseMap=new Map<Id,Case>([select id,Artemis_Id__c from case where Artemis_Case_Number__c in:caseIdForQuerySet]);
            for (Case existingCase : existingCaseMap.values()) {
                existingArtemisCaseMap.put(existingCase.Artemis_Id__c, existingCase);
            }
        }
        // Loop on the cases to upsert and update the case obj Ids from existing case map
        Set<Id> mergingCaseIds=new Set<Id>();
        for (Case caseObj : casesToUpsert) {
            if (caseObj.Id == null && existingArtemisCaseMap != null && existingArtemisCaseMap.containsKey(caseObj.Artemis_Id__c)) {
                caseObj.Id = existingArtemisCaseMap.get(caseObj.Artemis_Id__c).Id;
            }
            if(caseObj.status!=null && (caseObj.status).contains('Closed')){
                caseObj.OwnerId=Label.Artemis_System_Owner_Id;
            }
            if(caseObj.ParentId!=null){
                mergingCaseIds.add(caseObj.ParentId);
                mergingCaseIds.add(caseObj.Id);
            }
        }
        
        Map<Id,Case> parentCaseMap=new Map<Id,Case>();
        if(!mergingCaseIds.isEmpty()){
            parentCaseMap = new Map<Id,Case>([SELECT Id, CaseNumber, RecordTypeId, Subject, Status, AccountId, Owner.Name,
            OwnerId, New_Mail__c, Count_Case_Emails__c, Type, Sub_Type__c, Reason_For_Case__c, Product__c, 
            Type_SubType__c, Thread_Topic__c, Country__c, Direction__c, CreatedDate, Liner_Brand__c, Case_Visibility__c FROM Case 
            WHERE Id in :mergingCaseIds]);
        }
        
        CaseWrapper parentCaseWrapper;
        list<CaseWrapper> childCaseWrapper = new list<CaseWrapper>();
        for(Case caseObj:casesToUpsert){
            if(caseObj.status=='Closed - Merged' && caseObj.ParentId!=null){
                
                if(parentCaseMap.containsKey(caseObj.ParentId)){
                    Datetime dt = Datetime.valueOf(parentCaseMap.get(caseObj.parentId).CreatedDate);
                    String formattedDate = dt.format('MM/dd/yyyy, HH:mm');
                    parentCaseWrapper=new caseWrapper(parentCaseMap.get(caseObj.parentId),'Artemis System Owner',false,true,false,'/'+caseObj.ParentId,formattedDate,'blueText',true);
                } 
                
                Datetime dt1 = Datetime.valueOf(parentCaseMap.get(caseObj.Id).CreatedDate);
                String formattedDate1 = dt1.format('MM/dd/yyyy, HH:mm');
                childCaseWrapper.add(new caseWrapper(parentCaseMap.get(caseObj.Id),'Artemis System Owner',true,false,false,'/'+caseObj.Id,formattedDate1,'blueText',true));     
            }
        }
        if(parentCaseWrapper!=null && !childCaseWrapper.isEmpty()){
            DuplicateCaseManagerExtensionLWC.mergeCases(JSON.serialize(childCaseWrapper),JSON.serialize(parentCaseWrapper));
        }
        Database.UpsertResult[] caseUpsertResList = Database.upsert(casesToUpsert,false);
        ErrorLogger.writeErrors('SFDC', 'Case', 'CaseConsumerEventHandler.createSFCases', caseUpsertResList, casesToUpsert);
        Map<id,String> caseIdArtemisMap=new Map<id,String>();
        for (Case caseObj : casesToUpsert) {
            if(caseObj.id==null){continue;}
            if(existingCaseMap!=null && existingCaseMap.containsKey(caseObj.id))
            {continue;}//eleminate the cases which have been migrated and has artemis id before hand;
            caseIdArtemisMap.put(caseObj.Id,caseObj.Artemis_Id__c);
        }
        if(caseIdArtemisMap.isEmpty()){
            return;
        }
        ArtemisEMPUtility.createChildFileEvent(caseIdArtemisMap,'Case');
        Set<Id> caseIdSet=caseIdArtemisMap.keySet();
        ArtemisEMPUtility.createChildEmailEvent(caseIdSet);
        ArtemisEMPUtility.createChildSurEvent(caseIdSet);
        ArtemisEMPUtility.createChildCaseCommEvent(caseIdSet); 
    }

}