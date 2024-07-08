/********************************************************************************************************************************************
* No.   Version	     Story		     Author			 Date		 Description
* 1.	 1.0		SFSE-13549	   Seba@Maersk	  15/05/2024	 Test class for RenewalOppDockNotificationController 
***/
@isTest
public class RenewalOppDockNotificationControllerTest {
    @testSetup
    static void setupTestData() {  
        User salesUser = TestBusinessHelper.createUser('Sales', 'MaerskLine', true); 	
        Account testAccountRec = TestBusinessHelper.createAccount('Client_Account', true);
        Contact testContact = TestBusinessHelper.createContact(testAccountRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        List<opportunity> lstOpp = TestBusinessHelper.createOpportunities(testAccountRec,testContact, salesUser,new List<String>{'ShippingCargoServices', 'ShippingCargoServices'}, BrandUtilities.MAERSKLINE, false);   
        lstOpp[0].Renewal_Opportunitity__c = true;lstOpp[0].CloseDate = System.today().addDays(10); 
        lstOpp[1].Type = 'Renewal';lstOpp[1].CloseDate = System.today().addDays(2);  
        insert lstOpp; 
        Notification_and_Subscription__c notificationRec = new Notification_and_Subscription__c(Object_Name__c = 'Opportunity',Record_Id__c=lstOpp[0].Id,User__c =  UserInfo.getUserId(), Reminder_Date__c = System.now().addHours(50), Feature__c = 'Renewals');
        insert notificationRec;  
    }
    
    @isTest
    static void testMethod1() { 
        List<Opportunity> lstOppRec = [SELECT Id,CloseDate from Opportunity where CloseDate != null];
        Map<String,Object> lstOppFetched = RenewalOppDockNotificationController.fetchRenewalOpportunities();  
        Assert.areNotEqual(lstOppFetched.values().size(), 0);  
        Boolean upsertSucceeded = RenewalOppDockNotificationController.upsertRenewalNotificnSubscriptionRecords(lstOppRec[0].Id, '1 Day');
        Assert.areEqual(upsertSucceeded, TRUE); 
        Boolean upsertSucceeded1 =  RenewalOppDockNotificationController.upsertRenewalNotificnSubscriptionRecords(lstOppRec[1].Id, '1 Week');
        Assert.areEqual(upsertSucceeded1, TRUE); 
    }  
    
    @isTest
    static void testClosedOpportunities(){
        List<Opportunity> lstOpp = [SELECT Id,CloseDate from Opportunity where CloseDate != null];  
        lstOpp[0].StageName = 'Closed Lost';  lstOpp[0].Reason_For_Close__c = 'Lost - Customer Relationship Issue'; 
        lstOpp[1].StageName = 'Closed Lost'; lstOpp[1].Reason_For_Close__c = 'Lost - Uncompetitive price';
        update lstOpp;
        Map<String,Object> lstOppFetched = RenewalOppDockNotificationController.fetchRenewalOpportunities(); 
        Assert.areNotEqual(lstOppFetched.values().size(), 0); 
    }
    
}