/**
* Test class for OpportunityTeamMemberTrigger, OpportunityTeamMemberTriggerHandler, bINS_bUpd_populateOpportunityOwner.
*
 * Version     Date            Owner                                     RQ#                        Description
**************************************************************************************************************************
*1.0         20/11/2014      Adhavan.Rengarajan@ust-global.com       #RQ-000222                   Code created 
*2.0         08/12/2014      Krishnamoorthi.murugesan@ust-global.com #RQ-000828                 Removed PPVVC from Opportunity
*3.0         27/01/2015      revathy.sudhindran@ust-global.com       #RQ-000803                 Role Name Renaming
*4.0         11/02/2016      Sunu.Paul@ust-global.com                #RQ-002978                 Introduced Data Generator classes    
*5.0         06/07/2021      Nitin@Maersk                            SFSE-6249                  Added testOppInsertValidateTeamMemberList unit test
 * 6.0         15/06/2022      Ronnie@SF                                 SPI-100                    Removed brand hardcoding
*/

@isTest   
private class OpportunityTeamMemberTrigger_Test {
   static testMethod void  testShare() {
        Account clientAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity mslOppty2 = TestBusinessHelper.createOpportunity(clientAcc, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        Contract__c cont = new Contract__c();
        cont.Agreement_Type_Code__c = 'Credit_Agreement';
        cont.Brand_Name__c = 'Maersk';
        cont.Customer__c = clientAcc.Id;
        cont.Effective_Date__c = system.today();
        cont.Expiration_Date__c = system.today() + 10;
        cont.Is_FMC_Contract__c = false;
        cont.Is_Master_Contract__c = false;
        cont.Status__c = 'Draft';
        insert cont;
        system.debug('cont ' + cont);
        Opportunity_Contract__c opc = new Opportunity_Contract__c();
        opc.Contract__c = cont.Id;
        opc.Opportunity__c = mslOppty2.Id;
        insert opc;
        system.debug('opc ' + opc);
       	TriggerExecutionController.skipAllTriggers(true);
        User testMSLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
       	TriggerExecutionController.skipAllTriggers(false); 
       List<OpportunityTeamMember> oppMbrList= DataGeneratorHelper2_Test.createOppTeamMembr( 1, testMSLIntgrationUser, mslOppty2.Id, Label.Team_Role_Label_Owner, true );
        
    }
    

    static testMethod void testOpptyUpdate() {
        TriggerExecutionController.skipAllTriggers(true);
        Account testClientAcct =TestBusinessHelper.createAccount('Client_Account', true);
        TriggerExecutionController.skipAllTriggers(true);
        User testMSLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
       	User testSCLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE , true);
       	
        TriggerExecutionController.skipAllTriggers(false); 
        Contact testContact = TestBusinessHelper.createContact(testClientAcct, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        
       
 
        Opportunity testOpp =  TestBusinessHelper.createOpportunity(testClientAcct, testContact, testMSLIntgrationUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);        TriggerExecutionController.skipAllTriggers(false);
        List<OpportunityTeamMember> oppMbrList= DataGeneratorHelper2_Test.createOppTeamMembr( 1, testMSLIntgrationUser, testOpp.Id, Label.Team_Role_Label_Owner, true );

        Test.StartTest(); 
            testOpp.OwnerId = testSCLIntgrationUser.Id;
            update testOpp;
        Test.StopTest();

        Opportunity testOppCheck = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :testOpp.Id LIMIT 1];
        System.assertEquals(testSCLIntgrationUser.Id, testOppCheck.OwnerId, 'Opportunity Owner is not changed.');
    }

    static testMethod void testOppInsertValidateTeamMemberList(){

        Account testClientAcct = TestBusinessHelper.createAccount('Client_Account', true);
      	TriggerExecutionController.skipAllTriggers(true);
        User testMSLIntgrationUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, true);
       	TriggerExecutionController.skipAllTriggers(false); 
        Contact testContact = TestBusinessHelper.createContact(testClientAcct, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        
        Test.startTest();
            Opportunity testOpp = TestBusinessHelper.createOpportunity(testClientAcct, testContact, testMSLIntgrationUser, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);        Test.stopTest();

        OpportunityTeamMember testOppTeamMemberToCheck = [SELECT Id, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :testOpp.Id LIMIT 1];
        System.assertEquals(Label.Team_Role_Label_Owner, testOppTeamMemberToCheck.TeamMemberRole, 'Opportunity Team Member role is not set correctly.');
    }
}