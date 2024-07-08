/*
 * Author   : Shahanawaz@Maersk
 * Purpose  : Test class for External Party trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0     SC-9293     22-12-2023  Shahanawaz@maersk       	Create feeditem on parent Case
*/
@isTest
public class ExternalPartyTrigger_Test {
    
    @isTest
    public static void testExternalPartyFeedItem(){
        TriggerExecutionController.skipAllTriggers(true);
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
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        insert cs;
        TriggerExecutionController.skipAllTriggers(false);
        
        External_Party__c extParty = TestBusinessHelper.createExternalParty(cs.Id, con.Id, false);
        extParty.Id = null;
        insert extParty;
    }

}