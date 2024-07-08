/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Case related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 
 */

@isTest
Public class TriggerHandler_Test {
    public static List<Account> AccountList = new List<Account>();
    private static testMethod void Test_accountInsert() {
       AccountData_Test.bCreate = false;
       AccountData_Test.iNumberOfAccounts = 5;
        
        If(AccountList.Size() == 0){
           AccountData_Test.createDraftAccounts();
            AccountList =AccountData_Test.lstAccounts;       
        }    
        Test.startTest();
        insert AccountList; //Insert Account records
        Test.StopTest();
        
        Set<Id>accIdSet = new Set<Id>();
        for(Account a : AccountList)
        {
            accIdSet.add(a.Id);
        }

        List<Account> accRec = [Select Id from Account WHERE Id IN : accIdSet];
        
        system.assertEquals(5, accRec.size());
    }
    private static testMethod void Test_accountUpdate() {
       AccountData_Test.iNumberOfAccounts = 5;
        
        If(AccountList.Size() == 0){
           AccountData_Test.createDraftAccounts();
            AccountList =AccountData_Test.lstAccounts;       
        }   
        List<Account> accountListtoUpdate = new List<Account>();
        for(Account accRec :AccountList){
           accRec.Phone = '09998977888' ;
           accountListtoUpdate.add(accRec); 
        }
        Test.startTest();
        update accountListtoUpdate; //Update Account records
        Test.StopTest();
        Set<Id>accIdSet = new Set<Id>();
        for(Account a : AccountList)
        {
            accIdSet.add(a.Id);
        }

        List<Account> accRec = [Select Id from Account WHERE Id IN : accIdSet];
        
        system.assertEquals(5, accRec.size());
    }
    private static testMethod void Test_accountDelete() {
       AccountData_Test.iNumberOfAccounts = 5;
        
        If(AccountList.Size() == 0){
           AccountData_Test.createDraftAccounts();
            AccountList =AccountData_Test.lstAccounts;       
        }   
        Set<Id>accIdSet = new Set<Id>();
        for(Account a : AccountList)
        {
            accIdSet.add(a.Id);
        }
        Test.startTest();
        Delete AccountList; //Delete Account records
        Test.StopTest();
        

        List<Account> accRec = [Select Id from Account WHERE Id IN : accIdSet];
        
        system.assertEquals(0, accRec.size());
    }
     private static testMethod void Test_accountUnDelete() {
       AccountData_Test.iNumberOfAccounts = 5;
        
        If(AccountList.Size() == 0){
           AccountData_Test.createDraftAccounts();
            AccountList =AccountData_Test.lstAccounts;       
        }   
        Set<Id>accIdSet = new Set<Id>();
        for(Account a : AccountList)
        {
            accIdSet.add(a.Id);
        }
        Test.startTest();
        Delete AccountList; //UnDelete Account records
        List<Account> accRec = [Select Id from Account WHERE Id IN : accIdSet];
        system.assertEquals(0, accRec.size());
        undelete AccountList;
        List<Account> accRec2 = [Select Id from Account WHERE Id IN : accIdSet];
        
        system.assertEquals(5, accRec2.size());
        Test.StopTest();
        //system.assertEquals(5, finRec.size());
    }
}