/*
 Date			Story		Developer		Description
03-May-2023		SFSE-10726	Aditi & Bharti	Added code to show Active Customer Contacts in 'CC' lookup of 'Send Offer on Email' lwc
*/
public with sharing class LwcMultiLookupController {
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String objectName, String fieldName, String value, List<String> selectedRecId, String filter, String identifier) {
       System.debug('identifier '+identifier);
           
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        if(selectedRecId == null){
            selectedRecId = new List<String>();
        }   
        if(String.isEmpty(identifier)){
            if(String.isNotEmpty(value)) {
                String query = 'Select Id, '+fieldName+' FROM '+objectName+' WHERE Name LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId';
                if(!String.isEmpty(filter)){
                    query += ' AND '+filter;
                }
                for(sObject so : Database.query(query)) {
                    String fieldvalue = (String)so.get(fieldName);
                    sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
                }
            }
        }
        else if(identifier == 'Send Offer On Email'){
            System.debug(identifier);
            if(String.isNotEmpty(value)) {
                String query = 'SELECT Id, Name, Email FROM Contact WHERE Name LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId';
                if(!String.isEmpty(filter)){
                    query += ' AND AccountId = \''+filter+ '\'' + ' AND RecordType.Name = \'Customer Contact\' AND Contact_Status__c = \'Active\' ';
                }
                System.debug(query);
                for(sObject cn : Database.query(query)) {
                    String fieldvalue = (String)cn.get(fieldName);
                    //String email = (String)cn.get('Email');
                    sObjectResultList.add(new SObjectResult(fieldvalue,cn.Id));
                }
                System.debug('query'+query);  
            }
          
        }
        else if(identifier == 'NBA'){
            if(String.isNotEmpty(value)) {
                String query = 'Select Id, Email, '+fieldName+' FROM Contact WHERE Name LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId';
                if(!String.isEmpty(filter)){
                    query += ' AND '+filter;
                }
                query += ' LIMIT 10';
                for(sObject so : Database.query(query)) {
                    String fieldvalue = (String)so.get(fieldName);
                    String email = (String)so.get('Email');
                    sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, email, 'standard:contact'));
                }
                
                String queryUser = 'Select Id, Email, '+fieldName+' FROM User WHERE Name LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId AND isActive = true';
                if(!String.isEmpty(filter)){
                    queryUser += ' AND '+filter;
                }
                queryUser += ' LIMIT 10';
                for(sObject so : Database.query(queryUser)) {
                    String fieldvalue = (String)so.get(fieldName);
                    String email = (String)so.get('Email');
                    sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, email, 'standard:user'));
                }
            }
        }
        return sObjectResultList;
    }
    
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String recEml;
        @AuraEnabled
        public String iconName;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        public SObJectResult(String recNameTemp, Id recIdTemp, String recEmail, String icon) {
            recName = recNameTemp;
            recId = recIdTemp;
            recEml = recEmail;
            iconName =  icon;
        }
        public SObJectResult() {
            
        }
    }
}