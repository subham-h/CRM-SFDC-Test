/**
 * This is test class created for AFLSQuoteExtController class.
 * 
 * Date         Owner                                     Ref Number    Description
 *********************************************************************************************************************************
 * 06/05/2014   jagadeesan.sakthivel@ust-global.com                     code created as part of #Upstream.
 * 01/10/2014   Sandhya.Sambasivan@ust-global.com         #RQ-000261    Removed the field Opportunity_Reference_Text__c
 * 08/12/2014   Krishnamoorthi.murugesan@ust-global.com   #RQ-000828    Removed PPVVC from Opportunity  
 * 27/02/2015   revathy.sudhindran@ust-global.com         #RQ-000918    Improve test coverage
 * 05/06/2015   revathy.sudhindran@ust-global.com         #RQ-001503    Allow users with quoting tool  'Both' to edit AFLS quotes
 * 14/09/2015   Madhava.kotte@ust-global.com              #RQ-001889    Modified the code test carrier code selection 
 * 26/02/2016   Sunu.Paul@ust-global.com                  #RQ-0002978   Introduced data generator classes    
 * 12/08/2016   Jiji@UST                                  #RQ-004319    Remove reference to Survey_Me__c, Primary_Contact__c field
 * 03-03-2017   deepak.r.mahapatra@in.ibm.com             #RQ-004643    Delete Quoting Tool Field in the User object
 * 15-10-2020   meghana@UST					              SFSE-4767     Deprecate Safmarine brand
 * 07-06-2022	Ronnie@SF                                 SPI-100       Removing brand hardcodings
 */

 
@isTest
public class AFLSQuoteExtController_Test {

    @testSetup
    static void setup() {
        string conEmail = 'testsample@newtestsample.com';
        if(UserDataGeneratorHelper_Test.integrationUser == null){
            UserDataGeneratorHelper_Test.initializeIntegrationUser();
        }
        User userRec = UserDataGeneratorHelper_Test.integrationUser;
        TriggerExecutionController.skipAllTriggers(true);
        Account testAccount = TestBusinessHelper.createAccount('Client_Account', true);
        TriggerExecutionController.skipAllTriggers(false);
        Contact cont = ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,testAccount.Id,
                                                                        conEmail,userRec);//Create MSL Contact
        TriggerExecutionController.skipAllTriggers(true);
        Opportunity testOpportunity = TestBusinessHelper.createOpportunity(testAccount, cont, userRec, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);//#RQ-0002978
        
    
     
        TriggerExecutionController.skipAllTriggers(false);
        List<Qt_Quote__c> AFLSQuoteList = DataGeneratorHelper1_Test.createAFLSQuotes(testOpportunity.ID,1);
        Qt_Quote__c testAFLSQuote = AFLSQuoteList[0];
        testAFLSQuote.Qt_Quote_Id__c = '1234';
        update testAFLSQuote;
    }
  
    /**
    * Test creation of New AFLS Quote
    */
    static testMethod void test_NewAFLSQuote(){
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        system.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            PageReference pgOpp = new PageReference('/apex/AFLSQuote?oppId='+testOpportunity.Id+'&iframetarget=aflsnewquote');
            Test.setCurrentPage(pgOpp);
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
            AFLSQuoteExtController controller = new AFLSQuoteExtController (sc);                  
            
            Test.stopTest();       
            system.assertEquals('/'+testOpportunity.Id, controller.BackToOpportunityClick().getURL());       
        }  
    }
    
    /** 
    * Test edit an existing AFLS Quote
    * #RQ-001889: Modified the code to get pass carrier code of safmarine
    */
    /*static testMethod void test_EditAFLSQuote(){
        try {
            system.runAs(userRec) {
                
                Test.startTest();
               ContactDataGeneratorHelper_Test.createCustomerContact(testAccount.Id,BrandUtilities.SEAGO);
                Opportunity sclOppty = OpportunityDataGeneratorHelper_Test.createSCLDryOpportunity(testAccount.Id,
                                                                                                       ContactDataGeneratorHelper_Test.customerContact.id);
                testAFLSQuote.Opportunity__c = sclOppty.Id;
            
                update testAFLSQuote;
    
                PageReference pgOpp1 = new PageReference('/apex/AFLSQuote?oppId=' + sclOppty.Id + '&iframetarget=aflsnewquote');
                Test.setCurrentPage(pgOpp1);
                
                ApexPAges.StandardController sc1 = new ApexPages.StandardController(testAFLSQuote);
                AFLSQuoteExtController controller1 = new AFLSQuoteExtController (sc1);                  
                Test.stopTest();       
                system.assertEquals('/'+sclOppty.Id, controller1.BackToOpportunityClick().getURL());                                
            }
        } catch(Exception e) {
        }
    }*/
    
    /**
    * Test Generate Output button functionality
    */
    static testMethod void test_GenerateOutput(){
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        system.runAs( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            PageReference pgOpp = new PageReference( '/apex/AFLSQuote?&quoteId=' + testAFLSQuote.Id + '&iframetarget=qog' );
            Test.setCurrentPage(pgOpp);
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
            AFLSQuoteExtController controller = new AFLSQuoteExtController( sc );
            
            system.assertNotEquals( null, controller.iFrameSrc );
            
            controller.BackToQuoteClick();
            Test.stopTest();
        }
    }
    
    /**
    * Method for Quote creation for an inactive Account
    */
    static testMethod void test_InactiveAccount() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        Account testAccount = [SELECT Id, Name, SCV_Status__c FROM Account LIMIT 1];
        Test.startTest();
        testAccount.SCV_Status__c = 'Inactive';
        update testAccount;
        
        PageReference pgOpp = new PageReference('/apex/AFLSQuote?oppId='+testOpportunity.Id+'&iframetarget=aflsnewquote');
        Test.setCurrentPage(pgOpp);
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
        AFLSQuoteExtController controller = new AFLSQuoteExtController (sc);                  
        Test.stopTest();
        system.assertEquals(False,controller.showIframe);
    }
    
    /**
    * Method for Quote creation for an inactive Account
    */
    static testMethod void test_NullPrimaryContact(){
        Opportunity testOpportunity = [SELECT Id, Primary_Contact__c FROM Opportunity LIMIT 1];
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        testOpportunity.Primary_Contact__c = null;
        Test.startTest();
        system.runAs(new User(Id = UserInfo.getUserId())) {
            update testOpportunity;
        }
        
        PageReference pgOpp = new PageReference('/apex/AFLSQuote?oppId='+testOpportunity.Id+'&iframetarget=aflsnewquote');
        Test.setCurrentPage(pgOpp);
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
        AFLSQuoteExtController controller = new AFLSQuoteExtController (sc);                  
        Test.stopTest();
        system.assertEquals(False,controller.showIframe);
    }
    
    /* 
    * Create Test AFLSQuote Edit Extension Controller 
    */
    static testMethod void test_AFLSQuoteEditExtController(){
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        system.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest(); 
            PageReference pgOpp = new PageReference('/apex/AFLSQuoteEditPage?Id='+testAFLSQuote.Id);
            Test.setCurrentPage(pgOpp);
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
            AFLSQuoteEditExtController aflsQtEditController = new AFLSQuoteEditExtController(sc);
            Test.stopTest();
            system.assertNotEquals(null,aflsQtEditController.redirectPage().getURL());
        }   
    }
   
    /*
    * Test method for generating error message when non AFLS User tries to create Quote 
    */
    /*static testMethod void test_NotAFLSUser(){  

        //userRec.Quoting_Tool__c ='Quote Builder';
        update userRec;
        
        system.runAs(userRec){
            PageReference pgOpp = new PageReference('/apex/AFLSQuote?&quoteId='+testAFLSQuote.Id+'&iframetarget=null');
            Test.setCurrentPage(pgOpp);
            ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
            controller = new AFLSQuoteExtController(sc);
            system.assertEquals(False,controller.showIframe);
        }
    }
    
    
    /*
    * #RQ-001503 Test method for generating whether  Quoting  tool ' Both'  User allowed edit Quote 
    */
    static testMethod void test_editAFLSByBothUser(){  
        Qt_Quote__c testAFLSQuote = [SELECT Id FROM Qt_Quote__c LIMIT 1];
        //userRec.Quoting_Tool__c ='Both';
        Test.startTest();
        
        system.runAs(new User(Id = UserInfo.getUserId())) {
            PageReference pgOpp = new PageReference('/apex/AFLSQuote?&quoteId='+testAFLSQuote.Id+'&iframetarget=null');
            Test.setCurrentPage(pgOpp);
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(testAFLSQuote);
            AFLSQuoteExtController controller = new AFLSQuoteExtController(sc);
            
            system.assertNotEquals(null,controller.redirectToNewURL().getURL());
            Test.stopTest();
        }
    } 
}