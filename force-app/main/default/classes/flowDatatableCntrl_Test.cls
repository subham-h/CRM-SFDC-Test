/*      
 * Revision Ref Number  Date             Owner                   Description
 * -------- ----------  -----------    -------------------    -------------------------
 * 1.0      SFSE-5986  28-04-2021     Meghana@UST               Code created. 
 * */


@isTest
private class flowDatatableCntrl_Test {

    @testSetup static void setup() {
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null );
        
        DataGeneratorHelper2_Test.CreateRateStructureItemList();               
        Rate_Structure__c recRS = DataGeneratorHelper2_Test.CreateRateStructure ( mslOppty.id );    
    }
    
    static testMethod void testDynamicSOQL(){
		
        list<Account> lstAccount = [SELECT Id, Name, CreatedDate FROM Account LIMIT 1];
        Test.startTest();       
		flowDatatableCntrl.getDataRows('Rate_Structure__c','Name,Opportunity__r.Name,CreatedDate', 'Account_Id__c =\'' + lstAccount[0].Id + '\'',
                                            'CreatedDate desc',  '3','Opportunity__r.Name:Opportunity', 'Id', null);
        
        flowDatatableCntrl.getDataRows('Rate_Structure__c','Name,Opportunity__r.Name,CreatedDate', '', '',  '3','Opportunity__r.Name:Opportunity', 'Id', null);
        
        flowDatatableCntrl.getDataRows('','Name,CreatedDate', '', '',  '','', 'Id', lstAccount);
        
        
        Test.stopTest(); 

    }
}