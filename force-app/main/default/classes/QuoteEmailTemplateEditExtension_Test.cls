/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 @isTest
 private class QuoteEmailTemplateEditExtension_Test
{
    static testMethod void testQuoteEmailTemplateEditExtension() 
    {
        Quote_Template__c quoteEmailTemp = new Quote_Template__c();
        
        PageReference pg = new PageReference('/apex/QuoteEmailTemplateEdit');
        Test.setCurrentPage(pg);         
        ApexPages.StandardController mc = new Apexpages.Standardcontroller(quoteEmailTemp);
        QuoteEmailTemplateEditExtension quoteEmailTempExtn=new QuoteEmailTemplateEditExtension(mc);
        quoteEmailTempExtn.getSObjectName();
        quoteEmailTempExtn.setfieldSelectList(quoteEmailTempExtn.getfieldSelectList());
        quoteEmailTempExtn.strObjectSelect='Opportunity';
        quoteEmailTempExtn.addSelectedObject();
        quoteEmailTempExtn.strFieldValue='Name';
        quoteEmailTempExtn.addSelectedField();
        quoteEmailTempExtn.showValues();
        system.assertEquals(quoteEmailTempExtn.strDispValue,'{!Opportunity.Name}');
        quoteEmailTempExtn.strObjectSelect='Account';
        quoteEmailTempExtn.addSelectedObject();
        quoteEmailTempExtn.strObjectSelect='User';
        quoteEmailTempExtn.addSelectedObject();
    }
}