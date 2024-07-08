/*
* Author   : Seba
* Purpose  : Test class for oneClickOfferRecallController 
*        
* Revision Ref Number   Date            Owner                   Description
* -------- ----------   -----------     -------------------     -----------
* 1.0      SFSE-10847  16-June-2023     Seba                    Test class for oneClickOfferRecallController
* 2.0      SFSE-10769  02-Aug-2023      Seba                    Modified for code optimization
*/

@isTest
public class oneClickOfferRecallControllerTest {
 
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true); 
        Account testAccountRecord = TestBusinessHelper.createAccount('Client_Account',true);
        List<Contact> testContactRecordsLst = TestBusinessHelper.createContacts(testAccountRecord,new List<String>{'Customer_Contact','Customer_Contact'},BrandUtilities.MAERSKLINE,true);
        User usrRecord = new User(id=UserInfo.getUserId());
        User salesUserTest = new User();
        System.runAs(usrRecord){
        salesUserTest = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserTest.CM_Visibility__c ='Single Carrier';
        salesUserTest.id = null;
        insert salesUserTest;
        }
        Test.startTest(); 
        TriggerExecutionController.skipAllTriggers(true); 
        Opportunity opportunityRecordTest = TestBusinessHelper.createOpportunity(testAccountRecord,testContactRecordsLst[0],salesUserTest,'ShippingCargoServices',BrandUtilities.MAERSKLINE,true);
        List<Product2> testProductLst = TestBusinessHelper.createProducts(new List<String> {'Ocean'},1,true);
        TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[0].Id,null,true);
        Test.stopTest();
        Offer_information__c testOfferRecord = new Offer_information__c(Opportunity__c = opportunityRecordTest.Id);  
        insert testOfferRecord;           
    }
    
    
    public static testMethod void recallOfferTest () { 
        Opportunity testOpportunityRecord = [select id FROM Opportunity LIMIT 1]; 
        Offer_information__c testOfferInformationRecord = [SELECT Id FROM Offer_information__c LIMIT 1];  
        User testSalesUserRec = [SELECT Id, Name from User LIMIT 1];
        PageReference pg = Page.oneClickOfferRecallEmailTemplate;
        pg.getParameters().put('customerName', 'TestName');
        pg.getParameters().put('optyProductNames', 'prodNames');
        pg.getParameters().put('agreementStartDate', String.ValueOf(System.today()));
        pg.getParameters().put('agreementEndDate', String.ValueOf(System.today().addDays(10)));
        pg.getParameters().put('loggedInUserName',testSalesUserRec.Name);
        Test.setCurrentPage(pg); 
        oneClickOfferRecallController recallInstanceObj = new oneClickOfferRecallController();
        oneClickOfferRecallController.updateRecordsAndSendCustomerEmailNotification('TestName','test@gmail.com',System.today(),System.today().addDays(10),testOpportunityRecord.Id,testOfferInformationRecord.Id,false,new List<String>{'test125@gmail.com'});  
        
        Test.startTest(); 
        pg  = Page.oneClickOfferRecallAndNewEmailTemplate;
        pg.getParameters().put('customerName', 'TestName');
        pg.getParameters().put('optyProductNames', 'prodNames'); 
        pg.getParameters().put('loggedInUserName',testSalesUserRec.Name);
        Test.setCurrentPage(pg);  
        oneClickOfferRecallController.updateRecordsAndSendCustomerEmailNotification('TestName','test@gmail.com',System.today(),System.today().addDays(10),testOpportunityRecord.Id,testOfferInformationRecord.Id,true,new List<String>{'test125@gmail.com'});  
        Test.stopTest();
    }
    
}