global class Batch_ContactLoaderdel implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext BC) { 
     String query = 'SELECT id from Contact_Loader__c';     
         return Database.getQueryLocator(query);
     }
      global void execute(Database.BatchableContext BC, List<Contact_Loader__c> contactloaderList) {
          delete contactloaderList;
          for(Contact_Loader__c c:contactloaderList){
          
          }
      }
      
      global void finish(Database.BatchableContext BC) {
      
     }
}