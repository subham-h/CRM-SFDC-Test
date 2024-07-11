/**
 * This test class created for AFLSQuoteTrigger.
 * 
 * Date              Owner                                 Ref Number            Description
 ********************************************************************************************************************
 * 06/05/2014   Shiva.Nampally@ust-global.com,                                   code created as part of #Upstream.
 * 01/10/2014   Sandhya.Sambasivan@ust-global.com          #RQ-000261            Removed the field Opportunity_Reference_Text__c
 * 08/12/2014   Krishnamoorthi.murugesan@ust-global.com    #RQ-000828            Removed PPVVC from Opportunity
 * 14/09/2015   Madhava.kotte@ust-global.com               #RQ-001889            Modified the code to test MCC and SEA Account owners as AFLS owners
 * 18/01/2016   Sunu.Paul@ust-global.com                   #PR-0055              Modified the code to include data generator classes and also, test 
 *                                                                               Seago Owners as AFLS owners      
 * 20/08/2016   Jiji@UST                                   #RQ-004057, RQ-00431  Remove reference to Survey_Me__c, Primary_Contact__c field
 * 07/06/2022   Ronnie@SF                                  SPI-100               Removing brand hardcodings
 */

@isTest
private class AFLSQuoteTrigger_Test {
   
    /* 
    * Create Test AFLSQuote Trigger
    * #RQ-001889 : Modified below test method to improve code coverage
    */
    static testMethod void AFLSQuoteTrigger() { 
        
        try {
            TriggerExecutionController.skipAllTriggers(true);
            Account ClientAccount = AccountDataHelper_Test.createClientAccount();
            /*Contact MSLContact =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,
                                                                                            ClientAccount.Id,'QwertyMSL2@gmail.com',true,false,
                                                                                            UserDataGeneratorHelper_Test.MSLIntegrationUser);//Create MSL Contact*/
                                                                                            
            Contact MSLContact =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,
                                                                                            ClientAccount.Id,'QwertyMSL2@gmail.com',
                                                                                            UserDataGeneratorHelper_Test.MSLIntegrationUser);//Create MSL Contact
            Opportunity MSLOppty = OpportunityDataGeneratorHelper_Test.createOpportunity(ClientAccount.Id,MSLContact.Id,
                                                                                               BrandUtilities.MAERSKLINE,'Lead',
                                                                                              UserDataGeneratorHelper_Test.MSLIntegrationUser,
                                                                                             'Dry');
            List<Qt_Quote__c> AFLSQuoteList = DataGeneratorHelper1_Test.createAFLSQuotes(MSLOppty.ID,200);
            
            Test.startTest();
            
            Opportunity ChangeMSLOppty = OpportunityDataGeneratorHelper_Test.createOpportunity(ClientAccount.Id,MSLContact.Id,
                                                                                                    BrandUtilities.MAERSKLINE,'Lead',
                                                                                                    UserDataGeneratorHelper_Test.MSLSystemAdminUser,
                                                                                                   'Dry');
             TriggerExecutionController.skipAllTriggers(false);
            //Updating AFLS Quote Record    
            List<Qt_Quote__c> qtupdList = new List<Qt_Quote__c>();
         
            AFLSQuoteList[1].Qt_External_Id__c = 'OPR-0001';
            AFLSQuoteList[1].Opportunity__c = ChangeMSLOppty.Id;
            update AFLSQuoteList[1];
            
            AFLSQuoteList[1].Qt_Carrier__c = BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE);
            AFLSQuoteList[1].Qt_External_Id__c = 'OPR-0002';
            update AFLSQuoteList[1];
            
            AFLSQuoteList[1].Qt_Carrier__c = BrandUtilities.getBrandOperatorCode(BrandUtilities.SEALAND);
            AFLSQuoteList[1].Qt_External_Id__c = 'OPR-0003';
            update AFLSQuoteList[1];
            
            AFLSQuoteList[1].Qt_Carrier__c = BrandUtilities.getBrandOperatorCode(BrandUtilities.MCC); 
            AFLSQuoteList[1].Qt_External_Id__c = 'OPR-0004';
            update AFLSQuoteList[1];
            
            AFLSQuoteList[1].Qt_Carrier__c = BrandUtilities.getBrandOperatorCode(BrandUtilities.SEAGO);
            AFLSQuoteList[1].Qt_External_Id__c = 'OPR-0005';
            update AFLSQuoteList[1];        
            
            System.assertEquals(AFLSQuoteList[1].Opportunity__c, ChangeMSLOppty.Id);
            System.assertEquals(BrandUtilities.MAERSKLINE + 'Test opportunity', ChangeMSLOppty.Name);
            List<Qt_Quote__c> qtupdLists = new List<Qt_Quote__c>(); 
          
            //Updating AFLS Quote Record                 
            AFLSQuoteList[1].Qt_Customer_Code__c = null;
            AFLSQuoteList[1].Qt_External_Id__c = null;         
            qtupdLists.add(AFLSQuoteList[1]);
            
            update qtupdLists;          
            Test.stopTest();
            System.assertEquals(BrandUtilities.MAERSKLINE + 'Test opportunity', ChangeMSLOppty.Name);
            ChangeMSLOppty = [SELECT Id, Account.Name FROM Opportunity WHERE Id = :ChangeMSLOppty.Id];
            System.assertEquals('Test Class Client Account', ChangeMSLOppty.Account.Name);
        } catch(Exception e) {
        
        }
    }
}