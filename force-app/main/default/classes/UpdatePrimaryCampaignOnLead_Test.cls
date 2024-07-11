/**
 *   Class Name : Test_UpdatePrimaryCampaignOnLead
 *   Description: This is a test class created to cover below class :    
 *                 1. UpdatePrimaryCampaignOnLead.trigger
 *   
 *   Modified By : UST Global
 *   Modified On : 20/5/2014
 * 
 * 2.0 meghana.gupta	 	10/09/2020  SFSE-262: Changes for new Source Brand field on leads
 * 3.0 Ronnie@SF            08/06/2022  SPI-100:  Removed brand hardcoding
 */
@isTest
private class UpdatePrimaryCampaignOnLead_Test {
    
    static testMethod void UpdatePrimaryCampaignOnLeadTest() {
        CreateIntegrationUserData_Test.initializeIntegrationUser();
        //Create two Campaigns
        List<Campaign> lCampaign = new List<Campaign>(); 
        for (integer i = 0;i < 2 ;i++) {
            Campaign cmp1 = New Campaign(Name = 'Test Campaign 1', Liner_Brand__c = BrandUtilities.MAERSKLINE, Status = 'Launched', IsActive = True, StartDate = System.Today().adddays(2), EndDate = System.Today().adddays(2),Description='Test');
            lCampaign.add(cmp1);
        }
        insert lCampaign;
        //Create two Leads associated with Campaign[0]
        //Lead[0] --> Campaign[0]
        //Lead[1] --> Campaign[0]
        List<Lead> lLead = new List<Lead>(); 
        for (integer i = 0;i < 2 ;i++) {
            lLead.add(LeadDataGeneration.createLead('myTestFirst', 'TestLast001', 'TestCompany', null, BrandUtilities.MAERSK, 'test1cd41@test.com.play', UserDataGeneratorHelper_Test.MSLIntegrationUser.id, lCampaign[0].id, 'LinkedIn'));
        }
        
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert lLead;
        }
        Test.startTest();
        //add Lead[0] as the campaign Member in both Campaigns.
        // CM[0], Campaign[0],Lead[0] 
        // CM[1], C[1]       ,Lead[0]
        List<CampaignMember> lCampaignMember = new List<CampaignMember>();
        for (integer i = 0; i < 2; i++) {
            CampaignMember campMember = new CampaignMember();
            campMember.CampaignId = lCampaign[i].Id;
            campMember.LeadId= lLead[0].Id;
            campMember.Status='Sent';
            lCampaignMember.add(campMember);
        }
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert lCampaignMember;
        }
        delete lCampaign[0];//test --> deletion of Campaign will reassign 'Primary Contact' on Lead
        Test.StopTest();
    }
}