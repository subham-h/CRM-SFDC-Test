/**

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 12/08/2016   meghana.gupta@ust-global.com                Code Created
* 08/01/2019   Junaid.Khader@ust-global.com                RQ-007160: Code coverage Improvement
*/

@isTest
private class Lightning_Utilities_Test{

    static testmethod void TestUtilities(){ 
    
        Lightning_Utilities.getSalesTrackerReports();
        Lightning_Utilities.getSalesTeam();
        Lightning_Utilities.getLoggedInUserId();
       // Lightning_Utilities.GetFieldPikclistValues('OpportunityLineItem', 'Target_Status__c',0);
       // Lightning_Utilities.GetFieldPikclistValues('OpportunityLineItem', 'Target_Status__c',4);
        
        Lightning_Utilities.GetRecordValuesForPicklist('BDA__c','Name','Type__c=\'Cluster\'','');
        
        DataGeneratorHelper1_Test.createBDA('Cluster', null, null,5);
        Lightning_Utilities.GetRecordValuesForPicklist('BDA__c','Name','Type__c=\'Cluster\'','BDA_Code__c');
        Lightning_Utilities.GetRecordValuesForPicklist('BDA__c','Name','Type__c=\'Cluster\'','');
        Lightning_Utilities.GetAllPicklistValues('Opportunity', 'StageName', 'Type', null, null, null);
        Lightning_Utilities.getDependentMap('Rate_Structure_Item__c','Type__c','Sales_Approach__c');
    }
    
}