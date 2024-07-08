@IsTest
private class BatchSendEmailForOfferInfoExpiredTest {
    
    @testSetup static void setup() {
        Test.startTest(); 
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Account clientAccount2 = TestBusinessHelper.createAccount('Client_Account', true);
        Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
        Contact con2 = TestBusinessHelper.createContact(clientAccount2, 'Customer_Contact', 'Alianca', true);
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, true);
        Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.Closedate = date.today();
        mslOppty.Offer_Status__c ='Sent';
        update mslOppty;
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty2.CloseDate = Date.today().addDays(1);
        mslOppty2.Offer_Status__c ='Sent';
        update mslOppty2;
        Offer_Information__c offInfo = TestBusinessHelper.createOfferInformation('Sent',salesUser,mslOppty,con,con2,true);
        Offer_Information__c offInfo2 = TestBusinessHelper.createOfferInformation('Sent',salesUser,mslOppty2,con,con2,true);
        
        
        
        
        
        
    }
    static testmethod void TestbatchSendEmailForOfferInfoExpiredTest(){
        TriggerExecutionController.skipAllTriggers(true);
        Test.startTest();
       
         String jobId = System.schedule('Test Batch', '0 0 * * * ?', new BatchSendExpiry_Email_Scheduler());
        TriggerExecutionController.skipAllTriggers(false);
        Test.stopTest();
        
        
        
    }
    
    
    
}