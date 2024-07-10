/*      
 * Revision Ref Number  Date             Owner                                Description
 * -------- ----------  -----------    -------------------                 -------------------------
 * 1.0      #RQ-012405   12-Nov-2019     meghana.gupta@ust-global.com        code created 
 * 2.0      SFSE-10220   01-Feb-2023     Aditi@Maersk                        Added Offer_Type__c field value

     
 */

@isTest
public class opportunitySplitCntrl_Test {

     @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
         Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true); // create account     
         Opportunity mslOppty;
         mslOppty = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);// create opportunity
         User testMSLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
       	User testSCLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE , true);
       	
        TriggerExecutionController.skipAllTriggers(false);
        Test.startTest();
         DataGeneratorHelper2_Test.createOppTeamMembr(1, testMSLIntgrationUser, mslOppty.Id, 'Sales Contributor'); // add Sales contributor to team
         DataGeneratorHelper2_Test.createOppTeamMembr(1, testSCLIntgrationUser, mslOppty.Id, 'Sales Contributor'); // add another Sales contributor to team
                  
         Id StdPricebook = Test.getStandardPricebookId();       
         List<Product2> pdt1 = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean'); // create a product
         PriceBookEntry pbEntry = [select id from PriceBookEntry where Product2Id =:pdt1[0].Id];        
         OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id ); // add product to opportunity
         Test.stopTest();
    }
    
    // test validation sceanrios
    static testMethod void Test_CreateOppSplits_Errors() {
        Test.startTest();
        // Check error for Stage, Owner, No products, no Sales Contributors
        Opportunity opp = [select id, StageName from Opportunity limit 1];
        opp.StageName = 'Identifying';
        //opp.Offer_Type__c = 'Offer containing Standard T&Cs';
        update opp;
        
        List<OpportunityLineItem> lstOLI = [ SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id ];
        try{
            delete lstOLI;
        }catch(Exception ex){
            System.debug('ex '+ex);
        }
        
        List<OpportunityTeamMember> lstTeam = [ SELECT Id FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id and TeamMemberRole = 'Sales Contributor'];
        delete lstTeam;
        
        opportunitySplitCntrl.createOpportunitySplits(opp.id);
        Test.stopTest();
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
           
        System.assert([SELECT COUNT() FROM OpportunitySplit WHERE SplitTypeId = :recSplitType.Id ] == 0, 'No Opportunity Split records created. Error messages displayed to user');
        
    }
    
    static testMethod void Test_CreateOppSplits() {
    
        Opportunity opp = [select id, StageName,OwnerId, Estimated_L_S_Product_Gross_Profit1__c, Estimated_Ocean_FFE__c, First_Shipment_Date__c, Last_Shipment_Date__c from Opportunity limit 1];
        opp.StageName = 'Qualifying'; 
      
        System.debug(opp.Estimated_L_S_Product_Gross_Profit1__c + 'opportunityfiled');
        update opp;
        List<OpportunityLineItem> oli = [Select Id,Name,L_S_Product__c,Product_Family__c, Country__r.Name,TotalPrice from OpportunityLineItem Limit 1];
        oli[0].L_S_Product__c = true;
        
        oli[0].UnitPrice = 100;
        oli[0].L_S_Product__c = false;
        Oli[0].Ocean_Product__c = true;
        Update oli;
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
        Test.startTest();
        
        // test split creation
        opportunitySplitCntrl.createOpportunitySplits(opp.id);
        
        List<OpportunityTeamMember> lstTeam = [ SELECT Id, UserId, User.Country,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id and TeamMemberRole = 'Sales Contributor'];
        lstTeam[0].TeamMemberRole = 'Sales Support';
        update lstTeam[0];
        
        // test split refresh as team memeber's role is changed
        opportunitySplitCntrl.createOpportunitySplits(opp.id);
        opportunitySplitCntrl.createSplits(opp,oli,lstTeam,recSplitType.id);
        
        Test.stopTest();
        System.assert([SELECT COUNT() FROM OpportunitySplit]>0, 'Opportunity Split records created');        
    }
    
    static testMethod void Test_CreateOppSplitsforLNS() {
        
        Opportunity opp = [select id, StageName from Opportunity limit 1];
        opp.StageName = 'Qualifying';
        update opp;
        Test.startTest();     
        // to check for L&S product 
        OpportunityLineItem oli = [SELECT Id,L_S_Product__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        oli.L_S_Product__c = true;
        update oli;
                
        opportunitySplitCntrl.createOpportunitySplits(opp.id);
        Test.stopTest();
        
        System.assert([SELECT COUNT() FROM OpportunitySplit]>0, 'Opportunity Split records created');
    }
    static testMethod void Test_createSplitSchedules(){
        
         Test.startTest();
         Opportunity opp = [select id, StageName,OwnerId, Estimated_L_S_Product_Gross_Profit1__c, Estimated_Ocean_FFE__c, First_Shipment_Date__c, Last_Shipment_Date__c from Opportunity limit 1];
         opp.StageName = 'Qualifying';
        
         update opp;
         OpportunityLineItem oli = [SELECT Id,L_S_Product__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
         oli.L_S_Product__c = true;
         update oli;
         List<OpportunityTeamMember> lstTeam = [ SELECT Id, UserId, User.Country,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :opp.Id and TeamMemberRole = 'Sales Contributor'];
         lstTeam[0].TeamMemberRole = 'Sales Support';
         update lstTeam[0];
         OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
    
         List<OpportunitySplit> lstExistinSplits = new list<OpportunitySplit>();
         OpportunitySplit oppSplit = new OpportunitySplit();
         oppSplit.OpportunityId = opp.id;
         oppSplit.SplitOwnerId = lstTeam[0].UserId;
         oppSplit.SplitTypeId = recSplitType.id;
         oppSplit.Ocean_FFE_Split__c = 2000;
         oppSplit.Uplift_Amount__c = 2000;
        // oppSplit.SplitAmount = 2000;
         lstExistinSplits.add(oppSplit);
         insert lstExistinSplits;
        
         List<Opportunity_Splits_Schedule__c> sch = new List<Opportunity_Splits_Schedule__c>();
         Opportunity_Splits_Schedule__c sch1 = new Opportunity_Splits_Schedule__c();
         sch1.Opportunity__c = opp.Id;
         sch1.User__c = lstExistinSplits[0].SplitOwnerId;
         sch1.Schedule_Date__c = system.today();
        insert sch1;
        opportunitySplitCntrl.createSplitSchedules(opp,recSplitType.id );        
        Test.stopTest();          
        
    }
}