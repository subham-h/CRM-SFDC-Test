/*
Date			   Story			Developer 	Description
02-June-2024		SFSE-13862		Anjali		Test Class Created; To cover Controller class 'OpportunityRenewalHomeCntrl'
*/
@isTest
public class OpportunityRenewalHomeCntrl_Test {
 @testSetup
    static void setupTestData() {  
        User salesUser = TestBusinessHelper.createUser('Sales', 'MaerskLine', false);
        salesUser.Id=null;
        salesUser.firstname='Test';
        salesUser.lastname='AJSalesUserTestt';
        System.runAs(new user(ID = UserInfo.getUserID())){
        insert salesUser;
        }
        Account testAccountRec = TestBusinessHelper.createAccount('Client_Account', true);
        Contact testContact = TestBusinessHelper.createContact(testAccountRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        List<opportunity> lstOpp = TestBusinessHelper.createOpportunities(testAccountRec,testContact, salesUser,new List<String>{'ShippingCargoServices', 'ShippingCargoServices'}, BrandUtilities.MAERSKLINE, false);   
        lstOpp[0].Renewal_Opportunitity__c = true;lstOpp[0].CloseDate = System.today().addDays(10);lstopp[0].OwnerId = salesUser.Id;
        lstOpp[1].Type = 'Renewal';lstOpp[1].CloseDate = System.today().addDays(2);lstopp[1].OwnerId = salesUser.Id; 
             insert lstOpp;      
    }
    
    @isTest
    static void testMethod1() { 
         // Run the test as the sales user
        Test.startTest();
        User salesUser = [SELECT Id FROM User WHERE IsActive=true AND lastname='AJSalesUserTestt'];
        System.runAs(salesUser) {
            // Call the method and capture the result
            Map<String, Integer> renewalCounts = OpportunityRenewalHomeCntrl.getUserRenewalCounts();
            // Assert the counts are as expected
            System.assertEquals(2, renewalCounts.get('upcomingRenewals'), 'The count of upcoming renewals should be 2');
         Test.stopTest();
        }
    }
}