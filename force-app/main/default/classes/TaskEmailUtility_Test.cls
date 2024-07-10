/*
 * Author   : Nisha
 * Purpose  : Test TaskEmailUtility
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   15/7/2016   Nisha.arjunan@UST       Created.
 * 
 */

@isTest
public class TaskEmailUtility_Test {
    public static testMethod void test_sendEmail() {
        list<Task> lstTasks = new list<Task>();
        ActivityData_Test.bCreate = false;
        
       AccountData_Test.iNumberOfAccounts = 1;
       AccountData_Test.createDraftAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        Test.StartTest();  
        ActivityData_Test.createTasks();
        lstTasks = ActivityData_Test.lstTasks;
        for(Task taskIterator : lstTasks) {
            taskIterator.WhatId = accInstance.Id;
        }
        insert lstTasks;
        Test.StopTest();
        
        System.assert(!lstTasks.isEmpty());   
    }
    
}