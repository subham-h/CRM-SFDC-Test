/**
Test Class for Batch_AccountDenCategory  
* Date         Owner                                                    Description
**************************************************************************************************************************************
* 18/04/2016   abby.abraham@ust-global.com         #RQ-004658 : Test Class to Cover Batch_AccountDenCategory 
* 16/08/2019   Junaid.Khader@ust-global.com        #RQ-011435 : Removed invocation of Scheduler_Batch_UpdateAccCategory which is deleted.
* 14/04/2020   Amritesh@UST	          			   #RQ-013373 : Fixed duplicate account scv code error
*/
@isTest
private class Batch_AccountDenCategory_Test {
static testMethod void testBatch(){
    
         if ( UserDataGeneratorHelper_Test.salesUser == null ){
            
            UserDataGeneratorHelper_Test.initializeSalesUser();
        
        }  
        
        //create client accounts 
        Account clientAccount = AccountDataHelper_Test.createClientAccount();
        Account clientAccount1 = AccountDataHelper_Test.createClientAccount(null, 'Active', '10000045403');
        
        List<Account> clientActLst = new List<Account>();
        
        clientAccount.Account_DEN_Category__c = 'Expand';
        clientActLst.add(clientAccount);
        
        clientAccount1.Account_DEN_Category__c = 'Expand';
        clientActLst.add(clientAccount1);
        
        Update clientActLst;
      
        System.RunAs ( UserDataGeneratorHelper_Test.mslSalesUser ){
        Test.startTest();
          Batch_AccountDenCategory  batchClientAcc = new Batch_AccountDenCategory();
          Database.executeBatch(batchClientAcc ,200);    
          Test.StopTest(); 
        }
    }
}