/*
 * Version		Story #			Date		Developer		Comments 
 * 1.0			SFSE-5541		5/2/2021	Meghana@UST		Code created		
 */

@isTest
private class RateStructureItemLwcCntrl_Test {
 	
    @testSetup static void dataSetup() {
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null );
        
        DataGeneratorHelper2_Test.CreateRateStructureItemList();               
        Rate_Structure__c recRS = DataGeneratorHelper2_Test.CreateRateStructure ( mslOppty.id );
    }
    
    static testMethod void RateStructureItemControllerTest(){
            
        Rate_Structure__c rsRecord = [SELECT Id, Opportunity__c  FROM Rate_Structure__c LIMIT 1 ];
        Opportunity opp = [SELECT Id, Cargo_Type__c, Opportunity_contains_Dangerous_Goods__c FROM Opportunity WHERE ID = :rsRecord.Opportunity__c LIMIT 1 ];
        
        Test.startTest();       
        RateStructureItemLwcCntrl.rsiData response = RateStructureItemLwcCntrl.getRateStructureItemList(rsRecord.Id);
        
		opp.Opportunity_contains_Dangerous_Goods__c = 'No';       
        TriggerExecutionController.skipOpportunityTrigger(true);
        update opp;
        TriggerExecutionController.skipOpportunityTrigger(false);

        response = RateStructureItemLwcCntrl.getRateStructureItemList(rsRecord.Id);
                
        List<Rate_Structure_Item__c> updateList = new List<Rate_Structure_Item__c>();
        updateList.add(response.lstRSI[0]);
       	updateList[0].Sales_Comments__c = 'TEST Comment';

        RateStructureItemLwcCntrl.updateRateStructureItemList(updateList);
        Test.stopTest(); 
        
    }
}