/*************************************************************************************************************************************************
 * Description : This is a test class created to cover below class :
 *                      1.  OpportunityDeleteOverrideExtension
 *                    
 * Version Date         Owner                                   Ref Number    Description
 **************************************************************************************************************************************
 * 1.0     17/5/2014    UST                                                   Modified as part of cleanup Activity
 * 2.0     14/10/2014   revathy.sudhindran@ust-global.com       #RQ-000058    Comented the statements containing Potential_FFE__c field of Quote Object.
 * 3.0     08/12/2014   Krishnamoorthi.murugesan@ust-global.com #RQ-000828    Removed PPVVC from Opportunity
 * 4.0     26/04/2017   Rathish.Rajendran@ust-global.com        #RQ-004168    Added a user record to Account.MSL_Account_Owner__c. Removed fields Account.Export_Rep__c and MSL_Export_Rep_Maersk_Id__c.
 * 5.0     06/06/2019   manjunath.c.holekade@maersk.com         #RQ-010819	  Removal of references of deprecated fields 
 * 6.0     08/06/2022   Ronnie@SF                               SPI-100       Removed brand hardcoding
 **************************************************************************************************************************************************/
 

@isTest
private class OpportunityDeleteOverrideExtension_Test
{
    
    testmethod static void checkDeletion()
    {
        TriggerExecutionController.skipAllTriggers(true);
        CreateIntegrationUserData_Test.initializeIntegrationUser();
        User demoUser = CreateIntegrationUserData_Test.integrationUser;
        Test.starttest();
        Account demoAcccount = new Account();
        demoAcccount.Name ='demoAcc';
        demoAcccount.Type = 'BCO';
        demoAcccount.SCV_Code__c = '2242348789';
        demoAcccount.MSL_Account_Owner__c =  CreateIntegrationUserData_Test.integrationUser.Id;                
        // demoAcccount.Export_Rep__c=CreateIntegrationUserData_Test.integrationUser.Id;
        // demoAcccount.MSL_Export_Rep_Maersk_Id__c = 'MSL123';
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert demoAcccount;
        }
        Contact cont=new Contact(FirstName = 'Sample', LastName = 'test', Liner_Brands__c = BrandUtilities.MAERSKLINE, Account = demoAcccount, AccountId = demoAcccount.Id, Email = 're.sudh@hotmail.play', Preferred_Language__c = 'English');
        System.runAs(CreateIntegrationUserData_Test.integrationUser) {
            insert cont;
        }
        TriggerExecutionController.skipAllTriggers(false);
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'test opportunity';
        oppObj.AccountId = demoAcccount.Id;
        oppObj.CloseDate = date.today()+30;
        oppObj.StageName = Label.LeadLabel;
        oppObj.Primary_Contact__c = cont.id;
        oppObj.Liner_Brand__c = BrandUtilities.MAERSKLINE;
         oppObj.Expected_Handling_Rounds__c = 2;
        insert oppObj;
        
        Quote quoteObj = new Quote();
        quoteObj.Name = 'Test Quote';
        //quoteObj.Potential_FFE__c=100;
        quoteObj.Effective_From_Date__c = date.today();
        quoteObj.ExpirationDate = date.today() + 30;
        quoteObj.Segment__c = 'BCO';
        quoteObj.OpportunityId = oppObj.Id;
        insert quoteObj;
        
        try{
            Test.setCurrentPageReference(Page.OpportunityDeleteOverride);
            ApexPages.currentPage().getParameters().put('Id',oppObj.Id);
            ApexPages.StandardController lStandardOppObj = new ApexPages.StandardController(oppObj);
            OpportunityDeleteOverrideExtension lDeleteOppObj = new OpportunityDeleteOverrideExtension(lStandardOppObj);
            lDeleteOppObj.deleteAction();
             Integer lOpportunityCount = [SELECT count() FROM Opportunity WHERE Id = :oppObj.Id];
            System.assert(lOpportunityCount>0, true);
            lDeleteOppObj.redirectUrl();
            System.assertEquals(ApexPages.currentPage().getParameters().get('Id'),String.valueOf(oppObj.Id));
            
            delete quoteObj;
                Test.setCurrentPageReference(Page.OpportunityDeleteOverride);
            ApexPages.currentPage().getParameters().put('Id', oppObj.Id);
            lStandardOppObj = new ApexPages.StandardController(oppObj);
            lDeleteOppObj = new OpportunityDeleteOverrideExtension(lStandardOppObj);
            lDeleteOppObj.deleteAction();
            lOpportunityCount = [SELECT count() FROM Opportunity WHERE Id = :oppObj.Id];
            system.debug('integer'+lOpportunityCount);
        }catch(Exception ex){
            
        }
        Test.stopTest();
    }
}