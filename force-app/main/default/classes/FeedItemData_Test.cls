/*
* Author   : Naved
* Purpose  : Utility test class for creating FeedItemrelated data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0       RQ-009492   19-Nov-2018 Naved@mersk                Created.
*/
@isTest
public with sharing class FeedItemData_Test {
    public static list<FeedItem> lstFeedItems = new list<FeedItem>();
    public static testMethod void createCaseFeedItems(){
        for(Case c : CaseData_Test.lstCases){
             FeedItem feed = new FeedItem (parentid = c.id,type = 'TextPost',
                                            Body = 'Test');   
             lstFeedItems.add(feed);                                                                       
         }
         if(lstFeedItems.size()>0){
            insert lstFeedItems;
         }
    
    }
    
}