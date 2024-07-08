/*******************************************************  
 * Class Name    : ViewOrgChartControllerTest
 * Description   : Test class for ViewOrgChartController
 * -----------------------  Revision History -------------------
 * 
 * Sno		Version		Story		Author			Date			Descrition
 * 1.		1.0			SFSE-5902	Kiran@Maersk	13/11/2019		Initial Development. 
 * 2.       2.0         SPI-100     Ronnie@SF       08/06/2022      Removed brand hardcoding
 *********************************************************/
@isTest
public class ViewOrgChartControllerTest {
    
    @testSetup static void setup() {

        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
		TriggerExecutionController.skipContactTrigger(true);
        Contact TestCon1 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'Qwerty@gmail.com', RunUser );
        Contact TestCon2 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'testcon2@gmail.com', RunUser );
        Contact TestCon3 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'testcon3@gmail.com', RunUser );
        Contact TestCon4 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'testcon4@gmail.com', RunUser );
        Contact TestCon5 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'testcon5@gmail.com', RunUser );
        TriggerExecutionController.skipContactTrigger(false);
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
        
        Id recordTypeId = Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName().get('External').getRecordTypeId();
        Stakeholder__c extStake1 = new Stakeholder__c(External_Stakeholder__c = TestCon1.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        Stakeholder__c extStake2 = new Stakeholder__c(External_Stakeholder__c = TestCon2.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        Stakeholder__c extStake3 = new Stakeholder__c(External_Stakeholder__c = TestCon3.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        Stakeholder__c extStake4 = new Stakeholder__c(External_Stakeholder__c = TestCon4.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        //Stakeholder__c extStake5 = new Stakeholder__c(External_Stakeholder__c = TestCon5.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        List<Stakeholder__c> exStakeList = new List<Stakeholder__c>{extStake1, extStake2, extStake3, extStake4};
            Database.insert(exStakeList, false);
    }
    
    @isTest static void getStakeholderHierarchyTest(){
        
        Test.startTest();
        List<Contact> contactsWithReportsTo = [Select Id, ReportsToId from Contact order by Name];
        contactsWithReportsTo[1].reportsToId = contactsWithReportsTo[0].Id;
        contactsWithReportsTo[2].reportsToId = contactsWithReportsTo[1].Id;
        contactsWithReportsTo[3].reportsToId = contactsWithReportsTo[4].Id;
        contactsWithReportsTo[4].reportsToId = contactsWithReportsTo[2].Id;
        ViewOrgChartController.getOrgChartColors();
        database.update(contactsWithReportsTo, false);
        ViewOrgChartController.getStakeholderHierarchy([SELECT ID from Business_Plan__c limit 1].Id);
        Test.stopTest();
    }
    
    @isTest static void updateContactPositiveTest(){
        Test.startTest();
        List<Contact> contactsWithReportsTo = [Select Id, ReportsToId from Contact order by Name];

        ViewOrgChartController.updateContact(contactsWithReportsTo[0].Id, contactsWithReportsTo[2].Id);
        Test.stopTest();
    }
    
    @isTest static void updateContactPositiveNegative(){
        Test.startTest();
        List<Contact> contactsWithReportsTo = [Select Id, ReportsToId from Contact order by Name];

        ViewOrgChartController.updateContact(contactsWithReportsTo[0].Id, contactsWithReportsTo[0].Id);
        Test.stopTest();
    }
}