/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		26-Jun-2023		Vazid@UST				This is a test class for sendOfferEmailAboutToExpire
*/
@isTest
public class sendOfferEmailAboutToExpireTest {
    
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
        Offer_information__c testOfferRecord = new Offer_information__c(Opportunity__c = opportunityRecordTest.Id, To_Recipient__c = testContactRecordsLst[0].Id, CC_Recipients__c = testContactRecordsLst[1].Email); 
            insert testOfferRecord;
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion testContentVersionRecord =  new Contentversion(Title = 'contentVersionTest1',PathOnClient='cvPathTest1',VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')); 
        insert testContentVersionRecord;   
        
        // Create test data
        Set<String> testData = new Set<String>{'data1', 'data2', 'data3'};
            Blob cryptoKey = Crypto.generateAesKey(256); 
        
        String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
        User adminUser = new user();
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            
            adminUser = UserDataGeneratorHelper_Test.systemAdminUser;
        }
        // Create a mock record for One_Click_Journey_Details__c with the valid key
        One_Click_Journey_Details__c mockRecord = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = UserInfo.getProfileId());
        insert mockRecord;
    }
    
    public static testMethod void test_PageReference () {
        Opportunity oppty= [SELECT Id, Offer_Type__c,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity LIMIT 1];
        PageReference pageRef = Page.oneClickAboutToExpireTemplate;
        pageRef.getParameters().put('src','html');
        pageRef.getParameters().put('optyId',oppty.Id);
        pageRef.getParameters().put('msg','sampleMessage');
        Test.setCurrentPage(pageRef); 
        Test.startTest();
         sendOfferEmailAboutToExpire controllerObj = new sendOfferEmailAboutToExpire();   
        controllerObj.setLastName();
        Test.stopTest();
    }
   
    public static testMethod void testSendEmail(){
         List<Contact> testContactRecordLst  = [SELECT id FROM Contact]; 
        Opportunity oppty= [SELECT Id FROM Opportunity LIMIT 1];
        Offer_information__c testOfferInformationRecord = [Select Id, Accepted_by__c,Name, Opportunity__c,  To_Recipient__c, CC_Recipients__c, CreatedById from Offer_Information__c LIMIT 1];
        ContentVersion testContentVersionRec = [SELECT Id FROM ContentVersion LIMIT 1]; 
        List<String> strLst = new List<String>{'emailGreetingValue==Hi Sam\n\nThank you for your interest.','solutionUserValue==SolutionText',
											   'summaryUserValue==SummaryText','emailSignOffValue==Regards,\nSalesUser'};  
       
        Test.startTest();
        sendOfferEmailAboutToExpire.sendEmailOfferToExpire(new List<Offer_information__c>{testOfferInformationRecord});
        Test.stopTest(); 
    }
    
}