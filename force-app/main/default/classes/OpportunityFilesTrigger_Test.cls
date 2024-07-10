/*
 * Created By   : Aleena@Maersk
 * Purpose      : Test class for OpportunityFilesTrigger_Test.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      added logic for Opportunity Event v3 and v4
 * 
 */
@isTest
public class OpportunityFilesTrigger_Test {
@testSetup 
    static void setup() {
    Test.StartTest();    
    Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
    Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
     Test.StopTest();   
     }
    static testmethod void TestOpptyEventOnOpptyFileUpdate(){
      Test.StartTest();
       List<Opportunity> opp = [Select id from Opportunity limit 1]; 
        Quotes__c quote= new Quotes__c();
        quote.Status__c='Negotiation Initiated';
        quote.Negotiation_Round__c =1;
        quote.Negotiation_Source__c='CRM';
        quote.Opportunity__c = opp[0].Id;
        insert quote;  
        Opportunity_File__c file = new Opportunity_File__c();
        file.File_Category__c='RFQ/Nomination File';
        file.Quote__c=quote.id;
        file.Opportunity__c= opp[0].Id;
        file.Name='test\\.test';
        insert file; 
        file.File_Category__c = 'Freetime';
        file.Send_to_azure__c = true;
        update file;
      Test.StopTest();   
    }
}