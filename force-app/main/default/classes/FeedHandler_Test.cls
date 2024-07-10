/*
* Author   : Naved
* Purpose  : Test Class to Cover FeedHandler 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0       RQ-009492   19-Nov-2018 Naved@mersk                Created.
*/

@isTest
public with sharing class FeedHandler_Test {
    public static testMethod void test_FeedCreate(){
    	 
    	 FeedItemData_Test.createCaseFeedItems(); 
    
    } 
}