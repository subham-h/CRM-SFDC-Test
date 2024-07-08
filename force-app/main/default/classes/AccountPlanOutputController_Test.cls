/*
 * Revision  Ref Number    Date           Owner               Description
 **************************************************************************************************************************
 * 1.0       SFSE-4360     02-Sep-2020    Neha@TCS            Test Class for AccountPlanOutputController.cls
 * 2.0       SPI-100       07-Jun-2022    Ronnie@SF           Removing brand hardcodings
 * 3.0					   26-Jul-2023	  Kiran@Maersk		  New test data framework
 */

@isTest
public class AccountPlanOutputController_Test {
    
    @testSetup
    static void setup() {
        Test.startTest();
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Contact customerContact = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        Opportunity opportunity = TestBusinessHelper.createOpportunity(clientAccount, customerContact, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, false);
        Business_Plan__c bp = TestBusinessHelper.createBusinessPlan(clientAccount, BrandUtilities.MAERSKLINE, true);
        opportunity.Id = null;
        opportunity.Account_Plan__c = bp.id;
        insert opportunity;
        TestBusinessHelper.createInitiative(clientAccount, bp, 'Initiative', true);
        Test.stopTest();
    }
    
    // Method to get the Business Plan and all associated record 
    @isTest
    static void getBusinessPlanandAssociatedata() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Business_Plan__c> bp = [SELECT Id, Lead_Account__c, Liner_Brand__c FROM Business_Plan__c WHERE Liner_Brand__c = :BrandUtilities.MAERSKLINE];                     
            Test.startTest();
            AccountPlanOutputController.getBusinessPlanData(bp[0].Id, 'Business_Plan__c');
            AccountPlanOutputController.getInitiativeList(bp[0].Id);
            AccountPlanOutputController.getOpportunityProductList(bp[0].Id);
            Test.stopTest();
            System.assertEquals(bp.size(), 1);
        }
    }
}