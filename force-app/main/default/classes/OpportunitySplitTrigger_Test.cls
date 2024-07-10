/*******************************************************  
* Class Name    : OpportunitySplitTrigger_Test
* Description   : Test class for OpportunitySplitTrigger  and its associated classed.
* -----------------------  Revision History -------------------
* 
* Sno      Version      Author     Date            Descrition                  
* 1.       1.0          Neha-TCS   13/11/2019      Initial Development.
* 2.       2.0          Ronnie@SF  08/06/2022      Removed brand hardcoding
*********************************************************/
@isTest
public class OpportunitySplitTrigger_Test {
    
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); // create account     
        //TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLDryOpportunity( clientAcc.id, null ); // create opportunity
        
        TriggerExecutionController.skipAllTriggers(false);
       // TriggerExecutionController.skipOpportunitySplitTrigger(true);
        DataGeneratorHelper2_Test.createOppTeamMembr(1, UserDataGeneratorHelper_Test.MSLIntegrationUser, mslOppty.Id, 'Sales Contributor'); // add Sales contributor to team
        
        Id StdPricebook = Test.getStandardPricebookId();       
        List<Product2> pdt1 = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean'); // create a product
        PriceBookEntry pbEntry = [select id FROM PriceBookEntry where Product2Id =:pdt1[0].Id];        
        OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id ); // add product to opportunity
    }
    
    // test validation sceanrios
    static testMethod void Test_opportunitySplitforIdentfyingStage() {      
        Test.startTest();
        // Check error for Stage
        Opportunity opp = [SELECT id, StageName,Estimated_L_S_Product_Gross_Profit1__c,Estimated_Ocean_FFE__c FROM Opportunity WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE AND StageName = 'Identifying' LIMIT 1];
        opp.StageName = 'Identifying';
        update opp;
        Opportunity updatedOpp = [SELECT id, StageName,Estimated_L_S_Product_Gross_Profit1__c,Estimated_Ocean_FFE__c FROM Opportunity WHERE StageName ='Identifying' LIMIT 1];
        List<OpportunityLineItem> oli = [Select id,name from OpportunityLineItem];
        oli[0].L_S_Product__c = false;
        oli[0].Ocean_Product__c = false;
        update oli;
        
        OpportunityTeamMember teammemberrecord = [SELECT id, OpportunityId,UserId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :updatedOpp.id AND TeamMemberRole='Sales Contributor'];       
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
        OpportunitySplitUtilities.validateOpportunitySplitCreation(opp,oli);
        try {
            OpportunitySplit oppsplit = new OpportunitySplit();
            oppsplit.SplitTypeId =recSplitType.Id; 
            oppsplit.OpportunityId = updatedOpp.id;
            oppsplit.SplitOwnerId = teammemberrecord.UserId;
            insert oppsplit;
        } catch(Exception ex) {
            Boolean expectedExceptionThrown = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    static testMethod void Test_opportunitySplitforInvalidRole() {      
        Test.startTest();
        // Check error for invalid team member role
        Opportunity opp = [select id, StageName FROM Opportunity WHERE Liner_Brand__c= :BrandUtilities.MAERSKLINE AND StageName= 'Identifying' limit 1];       
        opp.StageName = 'Qualifying';
        update opp;
        OpportunityTeamMember teammemberrecord = [SELECT id, OpportunityId,UserId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :opp.id AND TeamMemberRole='Sales Contributor'];       
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
        TriggerExecutionController.skipOpportunitySplitTrigger(false);
        OpportunitySplit oppsplit = new OpportunitySplit();
        oppsplit.SplitTypeId =recSplitType.Id; 
        oppsplit.OpportunityId = opp.id;
        oppsplit.SplitOwnerId = teammemberrecord.UserId;
        insert oppsplit;
       /* teammemberrecord.TeamMemberRole ='Delivery Manager';
        update teammemberrecord;
        OpportunityTeamMember updatedTMrecord = [SELECT id, OpportunityId,UserId,TeamMemberRole FROM OpportunityTeamMember WHERE  OpportunityId = : opp.id AND TeamMemberRole='Delivery Manager'];
        
        OpportunitySplit splitrec =[SELECT id,OpportunityId,SplitOwnerId,Ocean_FFE_Split__c FROM OpportunitySplit WHERE SplitOwnerId=: teammemberrecord.UserId];
        splitrec.Ocean_FFE_Split__c=1;
        try {
            
            update splitrec;
        } catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }*/
        Test.stopTest();
    }
    
    static testMethod void updateOpportunitySplit() {
        Test.startTest();
        OpportunitySplitType recSplitType = [SELECT Id, DeveloperName, MasterLabel FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
        
        List<OpportunitySplit> optySplitList = [SELECT Id, SplitTypeId, OpportunityId, SplitOwnerId FROM OpportunitySplit WHERE SplitTypeId !=:recSplitType.Id];
        
        if(optySplitList.size() > 0) {
            OpportunitySplit optySplit = new OpportunitySplit(Id = optySplitList[0].Id, SplitTypeId = recSplitType.Id);
            try {
                OpportunitySplitUtilities.calculateScheduleDates( System.today()+2, System.today() + 3);
                update optySplit;
                
            } catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
        Test.stopTest();
    }
}