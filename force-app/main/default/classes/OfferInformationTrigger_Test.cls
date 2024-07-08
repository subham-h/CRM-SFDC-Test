/*
 * Created By   : Aleena@Maersk
 * Purpose      : Test class for OfferInformationTriggerHandler
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   10-Oct-2023     Aleena@Maersk      added logic for Opportunity Event v3 and v4
 * 
 */
@isTest
public class OfferInformationTrigger_Test {
     @testSetup 
    static void setup() {
    Test.StartTest();    
    Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
    Account clientAccount2 = TestBusinessHelper.createAccount('Client_Account', true);
    Opportunity mslOppty = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
    Contact con = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact','MaerskLine', true);
    Contact con2 = TestBusinessHelper.createContact(clientAccount2, 'Customer_Contact', 'Alianca', true);
    User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, true);
    Offer_Information__c offInfo = TestBusinessHelper.createOfferInformation('Expired',salesUser,mslOppty,con,con2,true);
     Test.StopTest();   
     }
    static testmethod void TestOpptyEventOnOfferStatusUpdate(){
      Test.StartTest();
       Offer_Information__c offInformation = [Select id,Offer_Status__c from Offer_Information__c limit 1]; 
       offInformation.Offer_Status__c = 'Accepted/Completed';
       Update offInformation; 
      Test.StopTest();   
    }
}