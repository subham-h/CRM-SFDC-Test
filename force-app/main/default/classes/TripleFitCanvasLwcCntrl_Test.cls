/**
 * Version  Date           Owner                    RQ#           Description
 ****************************************************************************************************************************************
 * 1.0      25/08/2021     Neha@TCS                 SFSE-4360     Test Class for TripleFitCanvasLwcCntrl.cls
 * 2.0      27/06/2022     Ronnie@SF                SPI-100       Removed brand hardcoding
 */

@isTest
public with sharing class TripleFitCanvasLwcCntrl_Test {
    
    // Set up method to create the necessary data
    @testSetup static void setup() {
        //create test account
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        
        //Create MSL Contact
        Contact MSLContact =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'Qwerty@gmail.com', RunUser );
        
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
    }
    
    // Method to get the Business Plan and all associated record 
    @isTest static void getTripleFitCanvasdata() {  
        User usrRecord = new User(id=UserInfo.getUserId());
        System.runAs(usrRecord) {
            List<Business_Plan__c> bp = [Select Id, Lead_Account__c, Liner_Brand__c from Business_Plan__c where Liner_Brand__c = :BrandUtilities.MAERSKLINE];  
            Test.startTest();
            TripleFitCanvasLwcCntrl.getTripleFitCanvasItemList(bp[0].Id);     
            TripleFitCanvasLwcCntrl.getTripleFirHelpSectionData(); 
            List<Triple_Fit_Canvas__c> tfcList = [Select id, Account_Plan__c, Name, Current_Score__c, Target_Score__c, Priority__c,Remarks__c  from Triple_Fit_Canvas__c  where Account_Plan__c=:bp[0].id];  
            system.assertEquals(tfcList.size(), 9);       
            Test.stopTest();
        }
    }
    
    // Method to get the Business Plan and all associated record 
    @isTest static void updateTripleFitCanvasdata() {  
        User usrRecord = new User(id=UserInfo.getUserId());
        System.runAs(usrRecord) {
            List<Business_Plan__c> bp = [Select Id, Lead_Account__c, Liner_Brand__c from Business_Plan__c where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
            List<Triple_Fit_Canvas__c> tfcList = [Select id, Account_Plan__c, Name, Current_Score__c, Target_Score__c, Priority__c,Remarks__c  from Triple_Fit_Canvas__c  where Account_Plan__c=:bp[0].id];  
            List<Triple_Fit_Canvas__c> tfcupdatedlist = new List<Triple_Fit_Canvas__c>();
            Test.startTest();
            for(Triple_Fit_Canvas__c lstupdate :tfcList) {
                lstupdate.Current_Score__c = 1;
                lstupdate.Target_Score__c = 2;
                tfcupdatedlist.add(lstupdate);
            }
            TripleFitCanvasLwcCntrl.updateTripleFitRecordList(tfcupdatedlist);
            List<Triple_Fit_Canvas__c> updatedRecord = [Select id, Account_Plan__c, Name, Current_Score__c, Target_Score__c, Priority__c,Remarks__c  from Triple_Fit_Canvas__c  where Account_Plan__c=:bp[0].id];  
            system.assertEquals(updatedRecord[0].Current_Score__c, 1);
            Test.stopTest();
        }
    }
}