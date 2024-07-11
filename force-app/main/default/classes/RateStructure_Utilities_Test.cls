/**
* Test class for : RateStructureTrigger, RateStructureTriggerHandler, RateStructure_Utilities

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 20/05/2016   Kishore.Dupam@ust-global.com               RQ-003428 : Code Created
* 14/08/2018   Junaid.Khader@ust-global.com               RQ-009022 : Test method added
* 02/03/2021   Neha@TCS                                   SFSE-5351 : Created the cloned rate structure to set value for Cloned from field to cover the changes in the class
*/

@isTest
private class RateStructure_Utilities_Test {

    static testMethod void RateStructureTest(){
    
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null );
        
        DataGeneratorHelper2_Test.CreateRateStructureItemList();               
        
        Test.startTest();  
            Rate_Structure__c recRS = DataGeneratorHelper2_Test.CreateRateStructure ( mslOppty.id );
            update recRS;
            Rate_Structure__c updatedRS =[Select id,Opportunity__c from Rate_Structure__c limit 1 ];
            Rate_Structure__c clonedRS = new Rate_Structure__c(Name='ClonedRS',Cloned_From__c =updatedRS.id,Opportunity__c=mslOppty.id);
            insert clonedRS;
            System.assertEquals(clonedRS.Name,'ClonedRS');
        Test.stopTest();
    }
    static testMethod void testTenderApproveTask(){
        Test.startTest();
            Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
            Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null);
            Rate_Structure__c newRateStructure = new Rate_Structure__c(Opportunity__c = mslOppty.Id, Status__c = 'Not Approved', Description__c = 'Test');
            insert newRateStructure;
            newRateStructure.Status__c = 'Approved';
            update newRateStructure;
        Test.stopTest();
    }
}