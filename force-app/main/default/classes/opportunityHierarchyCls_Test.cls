/**   
 * Revision Ref Number  Date           Owner                           Description
 * -------- ----------  -----------    -------------------             -------------------------
 * 1.0      #SFSE-1128  06-08-2020     abhinav.ankit@maersk.com        code created 
 * 2.0      SPI-100     15-06-2022     Ronnie@SF                       Removed brand hardcoding
 * 3.0      SFSE-13935  11-03-2024     Seba@Maersk                     Display at least 5 parents and 5 children from hierarchy
 */

@isTest
public class opportunityHierarchyCls_Test {
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty;
        Opportunity mslOppty1;
        mslOppty = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
    	//Create opportunity
        mslOppty1 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity oppTender = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Opportunity oppQuarterlyDeal = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'Quarterly_Deal', BrandUtilities.MAERSKLINE, true);
        TriggerExecutionController.skipAllTriggers(false);
        List<Opportunity> oppList = TestBusinessHelper.createOpportunities(clientAcc, null, null,new List<String>{ 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices', 'ShippingCargoServices','ShippingCargoServices','ShippingCargoServices'}, BrandUtilities.MAERSKLINE, true);
    }
    
    static testMethod void Test_CreateOppSplits_Errors() {
        List<Opportunity> opp = [SELECT Id,Name, StageName FROM Opportunity LIMIT 2];
        opp[0].Parent_Opportunity__c = opp[1].Id;
        string opptyid = opp[1].Id;
        update opp; 
        opportunityHierarchyCls.OpportunityWrapper wrapper= new opportunityHierarchyCls.OpportunityWrapper(opp[0].Id, opp[0].Name,false,new List<opportunityHierarchyCls.OpportunityWrapper>(),opptyid);
        Test.startTest();
        opportunityHierarchyCls.getChildOpportunities(opptyid);
        Test.stopTest();   
    }    
    
     static testMethod void Test_CreateOppSplits() {
        List<Opportunity> opp = [SELECT Id,Name, StageName FROM Opportunity LIMIT 2];
        opportunityHierarchyCls.OpportunityWrapper wrapper= new opportunityHierarchyCls.OpportunityWrapper(opp[0].Id, opp[0].Name,false,new List<opportunityHierarchyCls.OpportunityWrapper>(),opp[0].Id);
        Test.startTest();
        opportunityHierarchyCls.getChildOpportunities(opp[0].id);
        Test.stopTest();   
    }   
    
    //SFSE-13935
    static testMethod void Test_CreateHierarchy() {
        List<Opportunity> opp = [SELECT Id,parent_opportunity__c,parent_opportunity__r.parent_opportunity__r.parent_opportunity__c, parent_opportunity__r.parent_opportunity__c, StageName FROM Opportunity LIMIT 10];
        List<Opportunity> opptoUpdateLst = new List<Opportunity>();
        if(opp.size() >= 7){
            opp[1].parent_opportunity__c = opp[0].Id; opptoUpdateLst.add(opp[1]);
        	opp[2].parent_opportunity__c = opp[1].Id; opptoUpdateLst.add(opp[2]);
        	opp[3].parent_opportunity__c = opp[2].Id; opptoUpdateLst.add(opp[3]);
            opp[4].parent_opportunity__c = opp[3].Id; opptoUpdateLst.add(opp[4]);
            opp[5].parent_opportunity__c = opp[4].Id; opptoUpdateLst.add(opp[5]);
            opp[6].parent_opportunity__c = opp[5].Id; opptoUpdateLst.add(opp[6]); 
            opp[7].parent_opportunity__c = opp[6].Id; opptoUpdateLst.add(opp[7]);
            opp[8].parent_opportunity__c = opp[7].Id; opptoUpdateLst.add(opp[8]);
            opp[9].parent_opportunity__c = opp[8].Id; opptoUpdateLst.add(opp[9]); 
        }
        if(opptoUpdateLst.size()>0) update opptoUpdateLst;
        Test.startTest();
        opportunityHierarchyCls.getChildOpportunities(opp[4].id);
        Test.stopTest();   
    } 
    
    //SFSE-13935
    static testMethod void Test_CreateHierarchy1() {
        List<Opportunity> opp = [SELECT Id,parent_opportunity__c,parent_opportunity__r.parent_opportunity__r.parent_opportunity__c, parent_opportunity__r.parent_opportunity__c, StageName FROM Opportunity LIMIT 10];
        List<Opportunity> opptoUpdateLst = new List<Opportunity>();
        if(opp.size() >= 7){
            opp[1].parent_opportunity__c = opp[0].Id; opptoUpdateLst.add(opp[1]);
        	opp[2].parent_opportunity__c = opp[1].Id; opptoUpdateLst.add(opp[2]);
        	opp[3].parent_opportunity__c = opp[2].Id; opptoUpdateLst.add(opp[3]);
            opp[4].parent_opportunity__c = opp[3].Id; opptoUpdateLst.add(opp[4]);
            opp[5].parent_opportunity__c = opp[4].Id; opptoUpdateLst.add(opp[5]);
            opp[6].parent_opportunity__c = opp[5].Id; opptoUpdateLst.add(opp[6]); 
            opp[7].parent_opportunity__c = opp[6].Id; opptoUpdateLst.add(opp[7]);
            opp[8].parent_opportunity__c = opp[7].Id; opptoUpdateLst.add(opp[8]);
            opp[9].parent_opportunity__c = opp[8].Id; opptoUpdateLst.add(opp[9]); 
        }
        if(opptoUpdateLst.size()>0) update opptoUpdateLst;
        Test.startTest();
        opportunityHierarchyCls.getChildOpportunities(opp[5].id);
        opportunityHierarchyCls.getChildOpportunities(opp[6].id);
        opportunityHierarchyCls.getChildOpportunities(opp[7].id);
        opportunityHierarchyCls.getChildOpportunities(opp[2].id);
        Test.stopTest();   
    } 
}