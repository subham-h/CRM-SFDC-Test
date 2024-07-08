/*
* Author   : Seba
* Purpose  : Test class for oneClickEmailTemplateCtrl 
*        
* Revision Ref Number   Date            Owner                   Description
* -------- ----------   -----------     -------------------     -----------
* 1.0      SFSE-10740   21-May-2023     Seba                    Test class for oneClickEmailTemplateCtrl 
* 2.0      SFSE-10847   19-June-2023    Seba                    Modified to increase test coverage
* 3.0      SFSE-10769   02-Aug-2023     Seba                    Modified for code optimization
* 4.0      SFSE-12757   20-Sep-2023     Seba                    Modified for code fixes in controller 
* 5.0      SFSE-12757   04-Oct-2023     Seba                    Modified for deployment fixes
*/

@isTest
public class oneClickEmailTemplateCtrlTest {

    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true); 
        
        Geography__c country1 =  TestBusinessHelper.createGeography('India', 'Country', null,'IN', true);
            //TestBusinessHelper.createGeography('India', 'Country', null,'IN',true);  
        
        Account testAccountRecord = TestBusinessHelper.createAccount('Client_Account',true);
        List<Contact> testContactRecordsLst = TestBusinessHelper.createContacts(testAccountRecord,new List<String>{'Customer_Contact','Customer_Contact'},BrandUtilities.MAERSKLINE,true);
        List<User> lstUser = new List<User>();
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);	
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        User salesUserTest = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserTest.CM_Visibility__c ='Single Carrier'; 
        salesUserTest.id = null;
        salesUserTest.country = 'India';
        lstUser.add(adminUser);
        lstUser.add(salesUserTest);
        System.runAs(new User(Id = UserInfo.getUserId())){
              TriggerExecutionController.skipAllTriggers(true); 
            insert lstUser;
        }  
    
        Test.startTest(); 
        TriggerExecutionController.skipAllTriggers(true); 
        Opportunity opportunityRecordTest = TestBusinessHelper.createOpportunity(testAccountRecord,testContactRecordsLst[0],salesUserTest,'ShippingCargoServices',BrandUtilities.MAERSKLINE,true);
        //List<Product2> testProductLst = TestBusinessHelper.createProducts(new List<String> {'Ocean'},1,true);
        List<Product2> testProductLst = new List<Product2>();
        Product2 product = TestBusinessHelper.createProduct('ocean', false);
        product.Id = null;
        product.Name = 'TestOcean';
        product.OIPC_Code__c = 'p2-wfd';
        product.Portfolio__c = 'ocean';
        product.Terms_Conditions__c = 'http/ocean';
        testProductLst.add(product);
        Product2 product1 = TestBusinessHelper.createProduct('Lns', false);
        product1.Id = null;
        product1.Name = 'TestLns';
        product1.OIPC_Code__c = 'p2-wft';
        product1.Portfolio__c = 'Lns';
        product1.Terms_Conditions__c = 'http/lns';
        testProductLst.add(product1);
        Product2 product2 = TestBusinessHelper.createProduct('ocean', false);
        product2.Id = null;
        product2.Name = 'testMcs';
        product2.OIPC_Code__c = 'P-P0-env';
        product2.Terms_Conditions__c = 'http/mcs';
        testProductLst.add(product2);
        Product2 product3 = TestBusinessHelper.createProduct('ocean', false);
        product3.Id = null;
        product3.Name = 'testMcs';
        product3.OIPC_Code__c = 'P-P0-dw7';
        product3.Terms_Conditions__c = 'http/mcs';
        testProductLst.add(product3);
    
        Product2 product4 = TestBusinessHelper.createProduct('ocean', false);
        product4.Id = null;
        product4.Name = 'testMcs';
        product4.OIPC_Code__c = 'P-P0-12l0';
        product4.Terms_Conditions__c = 'http/mcs';
        testProductLst.add(product4);
  
        Product2 product5 = TestBusinessHelper.createProduct('ocean', false);
        product5.Id = null;
        product5.Name = 'testMcs';
        product5.OIPC_Code__c = 'P-P0-dx5';
        product4.Terms_Conditions__c = 'http/mcs';
        testProductLst.add(product5);
        insert testProductLst;
        
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1,true);
        System.debug('Shilpa%%'+lstTradeRoute);
        List<Opportunity_product__c> olilist = new list<Opportunity_product__c>();
        Opportunity_product__c oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[0].id,lstTradeRoute[0],true);
        oli1.id = null;
        olilist.add(oli1);
         Opportunity_product__c oli2 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[1].id,lstTradeRoute[0],true);
        oli2.id = null;
        olilist.add(oli2);
         Opportunity_product__c oli3 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[2].id,lstTradeRoute[0],true);
        oli3.id = null;
        olilist.add(oli3);
        Opportunity_product__c oli4 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[3].id,lstTradeRoute[0],true);
        oli4.id = null;
        olilist.add(oli4);
        Opportunity_product__c oli5 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[4].id,lstTradeRoute[0],true);
        oli5.id = null;
        olilist.add(oli5);
        Opportunity_product__c oli6 = TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[5].id,lstTradeRoute[0],true);
        oli6.id = null;
        olilist.add(oli6);
        insert olilist; 
        
        System.debug('%%shilpa'+oli2);
        
        //TestBusinessHelper.createOpportunityLineItemCustom(opportunityRecordTest,testProductLst[0].Id,null,true);
        Test.stopTest();
        Offer_information__c testOfferRecord = new Offer_information__c(Opportunity__c = opportunityRecordTest.Id);  
        insert testOfferRecord;
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion testContentVersionRecord =  new Contentversion(Title = 'contentVersionTest1',PathOnClient='cvPathTest1',VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body')); 
        insert testContentVersionRecord;   
    }
    
     public static testMethod void testPageReferenceMethod() { 
        Opportunity testOppty= [SELECT Id FROM Opportunity LIMIT 1];
        PageReference pageRef = Page.oneClickEmailTemplate;
        pageRef.getParameters().put('src','html');
        pageRef.getParameters().put('optyId',testOppty.Id);
        pageRef.getParameters().put('msg','sampleMessage');
        pageRef.getParameters().put('oldNameInGreetingLine','sampleMessage');  
        pageRef.getParameters().put('greetingLineWithAddress','sample Message email body message'); 
        pageRef.getParameters().put('showBanner','true');
        pageRef.getParameters().put('url','testurl'); 
        Test.setCurrentPage(pageRef); 
        Test.startTest();
        oneClickEmailTemplateCtrl controllerObj = new oneClickEmailTemplateCtrl();
        controllerObj.setLastName();
        controllerObj.enableEdit();
        controllerObj.disableEdit(); 
        Test.stopTest();
    }
    
    public static testMethod void testSendEmailMethod(){ 
        List<Contact> testContactRecordLst  = [SELECT id FROM Contact]; 
        Opportunity oppty= [SELECT Id FROM Opportunity LIMIT 1];
        Offer_information__c testOfferInformationRecord = [SELECT Id FROM Offer_information__c LIMIT 1];
        ContentVersion testContentVersionRec = [SELECT Id FROM ContentVersion LIMIT 1]; 
        List<String> strLst = new List<String>{'emailGreetingValue==Hi Sam\n\nThank you for your interest.','solutionUserValue==SolutionText',
											   'summaryUserValue==SummaryText','emailSignOffValue==Regards,\nSalesUser'};  
                                                   
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        String file = EncodingUtil.base64Encode(b);
        String fileName ='test.xlsx';
        Test.startTest();
        String sendEmailResultStr = oneClickEmailTemplateCtrl.sendEmail(oppty.Id, strLst,testContactRecordLst[0].Id,new List<String>{String.valueOf(testContactRecordLst[1].Id)},new List<String>{String.valueOf(testContentVersionRec.Id)},'Test Email','testUserLastName',file,fileName);
        System.assertEquals(sendEmailResultStr,'success');
        
        List<Id> contentVersionIDResultLst = oneClickEmailTemplateCtrl.createContentVersionRecords(EncodingUtil.base64Encode(Blob.valueOf('pdf email body')),testOfferInformationRecord.Id); 
        System.assertEquals(contentVersionIDResultLst.size()>0,true);
        
        oneClickEmailTemplateCtrl.fetchActiveOfferInformation(oppty.Id);
        String testVFOriginStr = oneClickEmailTemplateCtrl.getVFOrigin(); 
        System.assertEquals(testVFOriginStr!=null,true);
        
        Boolean testValidContentSize = oneClickEmailTemplateCtrl.validateFileSize(new List<String>{String.valueOf(testContentVersionRec.Id)}); 
        System.assertEquals(testValidContentSize == true,false);
        
        oneClickEmailTemplateCtrl.fetchFirstName(String.valueOf(testContactRecordLst[0]));
        
        PageReference pageRef = Page.oneClickEmailTemplate; 
        pageRef.getParameters().put('optyId',oppty.Id); 
        pageRef.getParameters().put('oldNameInGreetingLine','Dear  Sam.');  
        pageRef.getParameters().put('greetingLineWithAddress','Hello /n/n Thank you for your reaching out.');  
        Test.setCurrentPage(pageRef); 
        TriggerExecutionController.skipAllTriggers(true); 
        
        //Checking for edited email message
        oneClickEmailTemplateCtrl.sendEmail(oppty.Id, strLst ,testContactRecordLst[0].Id,new List<String>{String.valueOf(testContactRecordLst[1].Id)},new List<String>{String.valueOf(testContentVersionRec.Id)},'Test Email','testUserLastName',file,fileName); 
        Test.stopTest(); 
    }  
    
    public static testMethod void testLastNameMethod(){  
        Opportunity oppty= [SELECT Id FROM Opportunity LIMIT 1]; 
        
        PageReference pageRef = Page.oneClickEmailTemplate; 
        pageRef.getParameters().put('optyId',oppty.Id); 
        pageRef.getParameters().put('oldNameInGreetingLine','Hi Ram,');  
        pageRef.getParameters().put('greetingLineWithAddress','Hello Tim, Thank you for your interest.');  
        Test.setCurrentPage(pageRef); 
        oneClickEmailTemplateCtrl controllerObj = new oneClickEmailTemplateCtrl();
        controllerObj.setLastName();
        
        Test.startTest();  
        pageRef.getParameters().put('optyId',oppty.Id); 
        pageRef.getParameters().put('oldNameInGreetingLine','Hi Ram');  
        pageRef.getParameters().put('greetingLineWithAddress','Dear John,\n\nWelcome to Maersk.');  
        Test.setCurrentPage(pageRef);  
        oneClickEmailTemplateCtrl controllerObj1 = new oneClickEmailTemplateCtrl();
        controllerObj1.setLastName(); 
        Test.stopTest(); 
    }  
    
    public static testMethod void testMethod1(){ 
        List<Contact> testContactRecordLst  = [SELECT id FROM Contact]; 
        Opportunity oppty= [SELECT Id FROM Opportunity LIMIT 1];
        User salesUser = [SELECT Id,ProfileId FROM User WHERE Profile.Name='Sales' LIMIT 1];
        Offer_information__c testOfferInformationRecord = [SELECT Id FROM Offer_information__c LIMIT 1];
        ContentVersion testContentVersionRec = [SELECT Id FROM ContentVersion LIMIT 1]; 
        List<String> strLst = new List<String>{'emailGreetingValue==Hi Sam\n\nThank you for your interest.','solutionUserValue==SolutionText',
											   'summaryUserValue==SummaryText','emailSignOffValue==Regards,\nSalesUser'};  
        TriggerExecutionController.skipAllTriggers(true); 
         
        Blob cryptoKey = Crypto.generateAesKey(256);  
        String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey); 
        // Create a mock record for One_Click_Journey_Details__c with the valid key
        One_Click_Journey_Details__c mockRecord = new One_Click_Journey_Details__c(Secret_Key__c = cryptoKeyString, setUpOwnerId = salesUser.ProfileId); 
        insert mockRecord;
       	Blob b=Blob.valueOf('Unit Test Attachment Body');
        String file = EncodingUtil.base64Encode(b);
        String fileName ='test.xlsx';
        Test.startTest();
        PageReference pageRef = Page.oneClickEmailTemplate; 
        pageRef.getParameters().put('optyId',oppty.Id); 
        pageRef.getParameters().put('oldNameInGreetingLine','Hi Ram');  
        pageRef.getParameters().put('greetingLineWithAddress','');  
        Test.setCurrentPage(pageRef);  
        oneClickEmailTemplateCtrl controllerObj1 = new oneClickEmailTemplateCtrl();
        controllerObj1.setLastName();  
        String sendEmailResultStr = oneClickEmailTemplateCtrl.sendEmail(oppty.Id, strLst,testContactRecordLst[0].Id,new List<String>{String.valueOf(testContactRecordLst[1].Id)},new List<String>{String.valueOf(testContentVersionRec.Id)},'Test Email','testUserLastName',file,fileName);
        Test.stopTest(); 
    }  
    
    public static testMethod void testSendEmailMethodP2QOppty(){ 
        List<Contact> testContactRecordLst  = [SELECT id FROM Contact]; 
        Validation_Rules_Bypass__c bypass= Validation_Rules_Bypass__c.getInstance();
        bypass.Active__c = true;
        insert bypass;
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity oppty= [SELECT Id,Customer_Journey__c,First_Shipment_Date__c,Last_Shipment_Date__c,CloseDate FROM Opportunity LIMIT 1];
        oppty.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Integer daysLeftInMonth = oppty.CloseDate.daysBetween(oppty.CloseDate.toStartOfMonth());
        Integer daysLeftForNextMonth = Date.daysInMonth(oppty.CloseDate.year(), oppty.CloseDate.month()) - daysLeftInMonth;
        oppty.First_Shipment_Date__c = oppty.CloseDate + daysLeftForNextMonth + 9;
        oppty.Last_Shipment_Date__c =  oppty.CloseDate + daysLeftForNextMonth + 10;
        update oppty;
        TriggerExecutionController.skipAllTriggers(false);
        
        Offer_information__c testOfferInformationRecord = [SELECT Id FROM Offer_information__c LIMIT 1];
        ContentVersion testContentVersionRec = [SELECT Id FROM ContentVersion LIMIT 1]; 
        List<String> strLst = new List<String>{'emailGreetingValue==Hi Sam\n\nThank you for your interest.','solutionUserValue==SolutionText',
											   'summaryUserValue==SummaryText','emailSignOffValue==Regards,\nSalesUser'};  
                                                   
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        String file = EncodingUtil.base64Encode(b);
        String fileName ='test.xlsx';
        Test.startTest();
        String sendEmailResultStr = oneClickEmailTemplateCtrl.sendEmail(oppty.Id, strLst,testContactRecordLst[0].Id,new List<String>{String.valueOf(testContactRecordLst[1].Id)},new List<String>{String.valueOf(testContentVersionRec.Id)},'Test Email','testUserLastName',file,fileName);
        System.assertEquals(sendEmailResultStr,'success');
        
        Validation_Rules_Bypass__c bypass1= Validation_Rules_Bypass__c.getInstance();
        delete bypass1;
        Test.stopTest(); 
    }
    
    public static testmethod void TestTermsCondition(){
        Test.startTest();
        Opportunity oppty= [SELECT Id FROM Opportunity LIMIT 1];
        List<Opportunity_Product__c> oli = [Select id,name from Opportunity_Product__c];
        Test.stopTest();      
    }
    
 
}