/*
 * Author   : Nisha
 * Purpose  : Test TaskValidator
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-004102   15/7/2016   Nisha.arjunan@UST       Created.
 * 
 */

@isTest
public class TaskValidator_Test {
    public static testMethod void test_preventTaskOn_UnassignedAccount () {
        list<Task> lstTasks = new list<Task>();
        ActivityData_Test.bCreate = false;
        
       AccountData_Test.iNumberOfAccounts = 1;
       AccountData_Test.createUnassignedAccounts();
        Account accInstance =AccountData_Test.lstAccounts[0];
        
        Test.StartTest(); 
        try{
            ActivityData_Test.createTasks();
            lstTasks = ActivityData_Test.lstTasks;
            for(Task taskIterator : lstTasks) {
                taskIterator.WhatId = accInstance.Id;
            }
            insert lstTasks;
            update lstTasks;
        }
        catch(Exception e){}
        Test.StopTest();  
    }
    
}