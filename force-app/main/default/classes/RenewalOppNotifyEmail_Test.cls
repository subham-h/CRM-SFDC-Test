/********************************************************
Name : RenewalOppNotifyEmail_Test

Author : Arpitha J

Description : Test class for RenewalOppNotifyEmail 

*********************************************************/
@isTest
public class RenewalOppNotifyEmail_Test {
    
     
    @isTest
    static void setupTestData()
    {
       Test.startTest();
       TriggerExecutionController.skipAllTriggers(true);

        BDA__c region = TestBusinessHelper.createBDA('North America Area', 'Trade Region', 'NAM', null, null, true); 
        List<BDA__c> regionList = new List<BDA__c>();
        regionList.add(region);

        BDA__c cluster = TestBusinessHelper.createBDA('North America Region', 'Cluster', 'NAR', region, null, true);
        List<BDA__c> clusterList = new List<BDA__c>();
        clusterList.add(cluster);
        
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        Geography__c city = TestBusinessHelper.createGeography('Colorado', 'City', country.Id, true);
        
        BDA_Geography__c BDAGeo1 = TestBusinessHelper.createBDAGeography(cluster.Id, country.Id, '1234', true);

        User teammate = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, false);

        System.runAs(new User(Id = UserInfo.getUserId())){
            teammate.Id = null;
            teammate.FederationIdentifier='testuser1@maersk.com';
            teammate.IsActive=true;
            insert teammate;
        }
        

        User maerskLineUser = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, false);

        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
         maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
                maerskLineUser.Cluster__c='North America Area';
                maerskLineUser.Country='United States';
                maerskLineUser.Region__c='North America Region';
                maerskLineUser.IsActive=true;
                maerskLineUser.MLL__c = true;
            insert maerskLineUser;
        }

        List<String> linkIds = new List<String>{'test1','test2'};  //unique IDs for linking tradeRegion and clusters in Parent BDA
            
        List<Parent_BDA__c> parentBDA = TestBusinessHelper.createParentBDAs(clusterList, regionList, maerskLineUser,linkIds, 2, true);
        
        Account account = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', false);
        account.Id = null;
        account.OwnerId = maerskLineUser.Id; 
        account.MLL_Account_Owner__c = maerskLineUser.Id;
        insert account;

        Contact contact = TestBusinessHelper.createContact(account, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        
        Opportunity opporParent = TestBusinessHelper.createOpportunity(account, contact, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        
        Opportunity opportunity = TestBusinessHelper.createOpportunity(account, contact, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        opportunity.Cargo_Type__c = 'Dry';
        opportunity.Parent_Opportunity__c = opporParent.Id;
        opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        opportunity.Tender_Submission_Format__c = 'No Ocean Tender';
        update opportunity;
        
        
        Product2 product = TestBusinessHelper.createProduct('Ocean', true);  
        product.OIPC_Code__c='12345';
        product.Portfolio__c='Ocean';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        product.Latest_Product_Version__c=null;
        update product;
        
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.Id, null, country, city, true);
       
        RenewalOppNotifyEmail renewclass = new RenewalOppNotifyEmail();
        renewclass.OpportunityId = opportunity.Id;
        renewclass.getOpp();
        renewclass.getMaerskLogo();
        renewclass.getSalesforceLogo();
        renewclass.getRenewalOppRecUrl();
        renewclass.getRenewalParentOppRecUrl();
        renewclass.getproductList();
    }
}