/*
* Author   : Shilpa
* Purpose  : Batch class to assigned accounts to contacts coming from CMD which is failed . 
*/

global class BatchAssignContactsToAccounts implements Database.Batchable<sObject>{ 
    
    /*private List<Id> contactIds;
    
    global BatchAssignContactsToAccounts(List<Id> contactIds) {
        this.contactIds = contactIds;
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
         
        Id Customer_Contact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
        String query = 'SELECT Id, Name, Customer_Code__c, Contact_Status__c,RecordTypeId, AccountId FROM Contact WHERE Customer_Code__c != null AND Contact_Status__c = \'Inactive\' AND AccountId = null AND RecordTypeId =\'' + Customer_Contact + '\'';
        return Database.getQueryLocator(query);
        
    } 
    
    global void execute(Database.BatchableContext BC, List<Contact> conlist) {
        Set<String> setOfcustomerCode = new Set<String>();
        map<String,Account> mapOfAccount = new map<String,Account>();
        List<Contact>listToUpdateContact = new list<Contact>(); 
        for(Contact c : conlist){
            setOfcustomerCode.add(c.Customer_Code__c);
        }
       
        for(Account acc : [Select Id,name,Customer_Code__c from Account where Customer_Code__c IN: setOfcustomerCode]){
            mapOfAccount.put(acc.Customer_Code__c,acc);
        }
       if(!mapOfAccount.isEmpty()){
          for(Contact con :conlist) {
              if(mapOfAccount.containskey(con.Customer_Code__c)){
                  con.AccountId = mapOfAccount.get(con.Customer_Code__c).Id;
                  con.Customer_Code__c ='';
                  con.Contact_Status__c = 'Active';
                  listToUpdateContact.add(con);
              }  
           }
       }
       if(!listToUpdateContact.isEmpty()){
          try{
            Database.Update(listToUpdateContact); 
        } Catch(Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Contact', 'BatchAssignContactsToAccounts', new list<Exception>{e});
        }
        }
    }
    global void finish(Database.BatchableContext BC) { 
        
       
    } 
    
}