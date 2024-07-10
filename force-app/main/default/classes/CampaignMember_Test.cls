/**
 *
 * Date         Owner                                  Ref Number       Description
 **************************************************************************************************************************************
 * 2/01/2019    meghana.gupta@ust-global.com           RQ-007160        Modified to increase code coverage
 * 22/02/2019   Junaid.Khader@ust-global.com           RQ-007192        Modified to cover new classes
 * 12/11/2019   manjunath@maersk                       RQ-012362        Removed reference of deprecated Account fields
 * 10/09/2020   meghana.gupta                          SFSE-262         Changes for new Source Brand field on leads
 * 07/06/2022   Ronnie@SF                              SPI-100          Removed brand hardcoding
 */

@isTest
private class CampaignMember_Test {
    
    @testSetup static void setup() {
        
        Account acct = AccountDataHelper_Test.createClientAccount();
        acct.OwnerId = UserDataGeneratorHelper_Test.MSLIntegrationUser.Id;        
        System.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            update acct;
        }
        
        Contact con = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE, acct.Id, 'QwertyMSL1@gmail.com' ,UserDataGeneratorHelper_Test.MSLIntegrationUser);//Create MSL Contact
      
        List<Campaign> lstCampaign = DataGeneratorHelper2_Test.createCampaign(2, BrandUtilities.MAERSKLINE, True, UserDataGeneratorHelper_Test.MSLIntegrationUser) ; 
        
        List<Lead> lstLeads = new List<Lead>();
        lstLeads.add(LeadDataGeneration.createLead('myTestFirst', 'TestLast001', 'TestCompany', null, BrandUtilities.MAERSKLINE, 'test1cd41@test.com.play', UserDataGeneratorHelper_Test.MSLIntegrationUser.id, lstCampaign.get(0).Id,'LinkedIn'));
        lstLeads.add(LeadDataGeneration.createLead('myTestFirst', 'TestLast002', 'TestCompany2', null, BrandUtilities.MAERSKLINE, 'test1cd00002@test.com.play', UserDataGeneratorHelper_Test.MSLIntegrationUser.id, lstCampaign.get(0).Id,'LinkedIn'));
        
        System.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            insert lstLeads;
        }
    }
    
    static testMethod void CampaignMemberTest() {
        
        Campaign cmp1 = [SELECT Id FROM Campaign LIMIT 1];
        Contact recContact = [SELECT Id FROM Contact LIMIT 1];
        Account acct = [SELECT Id FROM Account LIMIT 1 ];
        User adminUser = [SELECT Id FROM User WHERE ProfileId = :Label.TestClean_ProfileIdsSystemAdmin AND isActive = true LIMIT 1];
        
        Test.StartTest();
                
        CampaignMember lCampaignMember = new CampaignMember(CampaignId=cmp1.Id, ContactId = recContact.Id,Status='Sent');
        insert lCampaignMember;
        
        lCampaignMember = [Select Id, Account_Owners_Email__c from CampaignMember where Id= :lCampaignMember.Id];
        
        System.runAs(adminUser){
            update acct;
        }
        
        lCampaignMember.Status= 'Responded';
        update lCampaignMember;
        
        delete lCampaignMember;
        
        Test.stopTest();
    }
    
     static testMethod void CampaignMember_LeadAssociatedTest() {
        
        Campaign cmp1 = [SELECT Id FROM Campaign LIMIT 1];
        Lead recLead = [SELECT Id FROM Lead LIMIT 1];
        Account acct = [SELECT Id FROM Account LIMIT 1 ];
        User adminUser = [SELECT Id FROM User WHERE ProfileId = :Label.TestClean_ProfileIdsSystemAdmin AND isActive = true LIMIT 1];
        
        Test.StartTest();
                
        CampaignMember lCampaignMember = new CampaignMember(CampaignId=cmp1.Id, LeadId = recLead.Id,Status='Sent');
        insert lCampaignMember;
        
        lCampaignMember = [Select Id, Account_Owners_Email__c from CampaignMember where Id= :lCampaignMember.Id];
        
        System.runAs(adminUser){
            update acct;
        }
        
        lCampaignMember.Status= 'Responded';
        update lCampaignMember;
        
        delete lCampaignMember;
        
        Test.stopTest();
    }
    static testMethod void testDeleteTrigger() {
        
        List<Campaign> listCampaign = [SELECT Id FROM Campaign LIMIT 3];
        Lead recLead = [SELECT Id, Primary_Campaign__c FROM Lead LIMIT 1];
        recLead.Primary_Campaign__c = null;
        update recLead;
        Test.StartTest();
        CampaignMember lCampaignMember1 = new CampaignMember(CampaignId=listCampaign[0].Id, LeadId = recLead.Id,Status='Sent');
        insert lCampaignMember1;
        
        if(listCampaign.size() > 1){
            CampaignMember lCampaignMember2 = new CampaignMember(CampaignId=listCampaign[1].Id, LeadId = recLead.Id,Status='Sent');
            insert lCampaignMember2;
        }
        delete lCampaignMember1;
        Test.stopTest();
    }
}