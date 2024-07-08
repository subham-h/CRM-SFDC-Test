/*************************************************************************************************************************************************
 * Description : This is a test class created to cover below class :
 *                      1.  OpportunityDeleteOverrideExtension
 *                    
 * Version   Date         Owner                                   Ref.            Description
 **************************************************************************************************************************************
 * 1.0       17/5/2014    UST                                                     Modified as part of cleanup Activity
 * 2.0       14/10/2014   revathy.sudhindran@ust-global.com       #RQ-000058      Comented the statements containing Potential_FFE__c field of Quote Object.
 * 3.0       08/12/2014   Krishnamoorthi.murugesan@ust-global.com #RQ-000828      Removed PPVVC from Opportunity
 * 4.0       11/02/2016   Sunu.Paul@ust-global.com                #RQ-002978      Introduced Data Generator classes               
 * 5.0       15/06/2022   Ronnie@SF                               SPI-100         Removed brand hardcoding
 **************************************************************************************************************************************************/

@isTest
private class OpptyDeleteOverrideExtension_Test {
    
    testmethod static void checkDeletion() {
        TriggerExecutionController.skipAllTriggers(true);
        Account acctObj =  TestBusinessHelper.createAccount('Client_Account', true);
        String contObjEmail = 'TestContact@testingContact23sdf.play';
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        //Contact contObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE, acctObj.Id, contObjEmail, true, false, RunUser);//Create MSL Contact
        //Contact contObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE, acctObj.Id, contObjEmail, RunUser);//Create MSL Contact  
        Product2 prod= TestBusinessHelper.createProduct('Ocean', true);
        Opportunity oppObj = TestBusinessHelper.createOpportunity(acctObj, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        List<Quote> quoteObjList = DataGeneratorHelper2_Test.createQuote(1, oppObj.Id);
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.starttest(); 
        Test.setCurrentPageReference(Page.OpportunityDeleteOverride);
        ApexPages.currentPage().getParameters().put('Id', oppObj.Id);
        ApexPages.StandardController lStandardOppObj = new ApexPages.StandardController(oppObj);
        OpportunityDeleteOverrideExtension lDeleteOppObj = new OpportunityDeleteOverrideExtension(lStandardOppObj);
        lDeleteOppObj.deleteAction();
        
        Integer lOpportunityCount = [SELECT count() 
                                     FROM Opportunity
                                     WHERE Id = :oppObj.Id];
        System.assert(lOpportunityCount>0, true);
        lDeleteOppObj.redirectUrl();
        System.assertEquals(ApexPages.currentPage().getParameters().get('Id'), String.valueOf(oppObj.Id));
                
        //delete quoteObj;
        delete quoteObjList[0];//#RQ-002978
        Test.setCurrentPageReference(Page.OpportunityDeleteOverride);
        ApexPages.currentPage().getParameters().put('Id', oppObj.Id);
        lStandardOppObj = new ApexPages.StandardController(oppObj);
        lDeleteOppObj = new OpportunityDeleteOverrideExtension(lStandardOppObj);
        lDeleteOppObj.deleteAction();
        lOpportunityCount = [SELECT count() FROM Opportunity WHERE Id = :oppObj.Id];
        //System.assert(lOpportunityCount != 0, true);
        Test.stopTest();
    }    
}