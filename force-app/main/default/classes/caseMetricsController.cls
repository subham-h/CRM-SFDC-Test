/*
* Author    : Raksha
* Purpose   : Display Time related values in chart using chart.js. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-6783     15-Feb-2023 Raksha@Maersk           Created a wrapper for storing the time related fields to be displayed in case metrics section. 
*/

public with sharing class caseMetricsController {
    @AuraEnabled(cacheable=true)
    public static List<fetchCasedata> fieldDetails(Id caseId){
    list <fetchCasedata> wrapCaseList = new list <fetchCasedata> ();
    Case caseRec=[select id,RecordType.Name from Case where id=:caseId];
    if(caseRec.RecordType.Name==Label.External_Case || caseRec.RecordType.Name==Label.Dispute){
        map<String,General_Key_Value_Configurations__mdt> caseMetricMdt = new map<String,General_Key_Value_Configurations__mdt>([SELECT Id,First_Field_Name__c,Second_Field_Name__c,First_Field_Value__c,Order__c,Key__c,Second_Field_Value__c from General_Key_Value_Configurations__mdt where Key__c='CaseMetrics' and Second_Field_Value__c =:caseRec.RecordType.Name order by Order__c ASC]);      
        list<String> CaseFieldNames = new List<String>();
        for(String cseapi: caseMetricMdt.keySet()){
            CaseFieldNames.add(caseMetricMdt.get(cseapi).First_Field_Name__c);
        }
        //Dynamic query to get the time related fields
        if(!CaseFieldNames.isEmpty()){ 
            String result = 'SELECT id,' + String.join(CaseFieldNames, ',') + ' FROM Case where Id=' +'\'' + caseId + '\'';
            Map<Id, Case> caseMap = new Map<Id, Case>((List<Case>)Database.query(result));
            for(Case cs : caseMap.values() ){
                for(String mdtMap : caseMetricMdt.keySet()){
                    String fromField = caseMetricMdt.get(mdtMap).First_Field_Name__c;
                    fetchCasedata caseValue = new fetchCasedata();
                    caseValue.apiName=caseMetricMdt.get(mdtMap).First_Field_Name__c;
                    caseValue.label=caseMetricMdt.get(mdtMap).Second_Field_Name__c;
                    if(cs.get(fromField)!=null){
                        caseValue.value=((Decimal)cs.get(fromField)).setScale(3);  //store upto 3 decimal points         
                    }
                    caseValue.helpText=caseMetricMdt.get(mdtMap).First_Field_Value__c;
                    caseValue.order=caseMetricMdt.get(mdtMap).Order__c;
                    wrapCaseList.add(caseValue);
                }
            }
        }
	}
        return wrapCaseList;
}

    //Wrapper for storing the time related fields
    public with sharing class fetchCasedata {
        @auraEnabled public string apiName {get;set;}
        @auraEnabled public string label {get;set;}
        @auraEnabled public Decimal value {get;set;}
        @auraEnabled public string helpText {get;set;}
        @auraEnabled public Decimal order {get;set;}
    }  
}