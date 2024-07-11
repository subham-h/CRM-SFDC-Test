/**
 * Class Name : TestsimilarOpportunitiesCtrl
 *     Description: This is a test class created to cover below class :
 *                 1.  similarOpportunitiesCtrl
 * Date         Author                                    Ref.         Description            
 * 08/12/2014   Krishnamoorthi.murugesan@ust-global.com   #RQ-000828   Removed PPVVC from Opportunity
 * 08/01/2016   meghana.gupta@ust-global.com                           Assigned Export Rep Maersk Id so to resolve test failure
 * 12/08/2016   Jiji@UST                                  #RQ-004057   Remove reference to Survey_Me__c, Primary_Contact__c field
 * 05/10/2016   meghana.gupta@ust-global.com                           Test Class optimization
 * 22/03/2017   rathish.rajendran@ust-global.com                       Removed reference to Account.Segment__c
 * 14/04/2020   Amritesh@UST	          			      #RQ-013373   Fixed duplicate account scv code error
 * 15/06/2022   Ronnie@SF                                 SPI-100      Removed brand hardcoding
 */

@isTest
private class SimilarOpportunitiesCtrl_Test {
    
    static testMethod void TestsimilarOpportunitiesCtrl () {
        
        //create client account
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        Account clientAcc1 = TestBusinessHelper.createAccount('Client_Account', true);
        Account clientAcc2 = TestBusinessHelper.createAccount(null,country ,'Client_Account', true);
        list<Opportunity> oppList = new list<Opportunity>{TestBusinessHelper.createOpportunity(clientAcc1, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true)};
        oppList.add(TestBusinessHelper.createOpportunity(clientAcc2, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true));
        //list<Opportunity> oppList2 = OpportunityDataGeneratorHelper_Test.createOpportunities( clientAcc2.Id, null, BrandUtilities.MAERSKLINE, 'Lead', UserDataGeneratorHelper_Test.MSLIntegrationUser, 'Dry', Test.getStandardPricebookId(), 2 );
        /*
        oppList.get(1).AccountID = clientAcc2.id;
        oppList.get(1).Named_Account__c = clientAcc2.id;
        
        update oppList.get(1);
        */
        Test.startTest();
        
        clientAcc2.ParentId = clientAcc1.id;
        //clientAcc2.Segment__c = 'Direct Sales';
        Update clientAcc2;
        
        ApexPages.StandardController con = new Apexpages.Standardcontroller( oppList.get(0) );
        similarOpportunitiesCtrl chkDupOppCon  = new similarOpportunitiesCtrl( con );
        chkDupOppCon.sendChatterPost();
        chkDupOppCon.chatterMsg='Test';
        chkDupOppCon.sendChatterPost();
        chkDupOppCon.similarDirOpps= chkDupOppCon.getsimilarDirOpps();
        chkDupOppCon.similarDirOpps[0].isSelected = true;
        //chkDupOppCon.similarFwdOpps[0].isSelected = true;
        chkDupOppCon.sendChatterPost();
        
        List<opportunity> opptyList = [ Select id,ownerId from Opportunity where accountId=:chkDupOppCon.similarDirOpps[0].opObj.accountId LIMIT 1];
        List<FeedItem> postList = [ Select id,body from FeedItem where parentId=:opptyList[0].ownerId ];
        
        chkDupOppCon.BackToOpportunityClick();
        
        ApexPages.StandardController con1 = new Apexpages.Standardcontroller(oppList.get(1));
        similarOpportunitiesCtrl chkDupOppCon1  = new similarOpportunitiesCtrl(con1);
        chkDupOppCon1.sendChatterPost();
        chkDupOppCon1.chatterMsg='Test';
        chkDupOppCon1.sendChatterPost();
        chkDupOppCon1.similarDirOpps  = chkDupOppCon1.getsimilarDirOpps();
        chkDupOppCon1.setsimilarDirOpps(chkDupOppCon1.similarDirOpps);
        chkDupOppCon1.similarFwdOpps  = chkDupOppCon1.getsimilarFwdOpps();
        chkDupOppCon1.setsimilarFwdOpps(chkDupOppCon1.similarFwdOpps);
        chkDupOppCon1.similarDirOpps[0].isSelected = true;
        chkDupOppCon1.similarFwdOpps[0].isSelected = true;
        chkDupOppCon1.sendChatterPost();
        
        List<opportunity> opptyList1 = [Select id,ownerId from Opportunity where accountId=:chkDupOppCon1.similarDirOpps[0].opObj.accountId LIMIT 1];
        List<FeedItem> postList1 = [Select id,body from FeedItem where parentId=:opptyList1[0].ownerId];
        
        chkDupOppCon1.BackToOpportunityClick();
        
        Test.stopTest();
    }
}