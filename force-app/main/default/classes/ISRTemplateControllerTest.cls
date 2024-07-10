/*
* Test class of ISRTemplateController
* 
*Version    Date        Owner                  RQ#           Description
*********************************************************************************************************************************  
1.0       29-04-2024    Shahanawaz@Maersk      SC-10027      Auto Fill Details to ISR template
*/
@isTest
public class ISRTemplateControllerTest {
    
    @isTest
    public static void testISRController(){
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = geography.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        ISR_Template__c isrTempdata = TestBusinessHelper.createISRTemplate(con.Id, false);
        
        Test.startTest();
        ISRTemplateController.getISRTemplates('');
        ISRTemplateController.getISRTemplates('test');
        Test.stopTest();
    }

}