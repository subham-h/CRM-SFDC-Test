@isTest
public class Batch_CXPackagePopulatorForAccount_test {
	@testSetup
    public static void setup() {
        Geography__c geography = TestBusinessHelper.createGeography('Denmark', 'Country', null, false);
        geography.Id = null;
        geography.GEO_Code__c = 'DK';
        insert geography;
        
        List<Feature_CM__c> listFeatures = new List<Feature_CM__c>();
        listFeatures.add(TestBusinessHelper.createFeature('Diamond',false));
        listFeatures.add(TestBusinessHelper.createFeature('Platinum',false));
        listFeatures.add(TestBusinessHelper.createFeature('Professional',false));
        for(Feature_CM__c ft:listFeatures){
            ft.id=null;
        }
        insert listFeatures;
        
        List<Specification_Parameter_CM__c> listSpecificationParams = new List<Specification_Parameter_CM__c>();
        for (Integer j = 0; j < listFeatures.size(); j++) {
            listSpecificationParams.addAll(TestBusinessHelper.createSpecParams(3,listFeatures,false));
        }
        for(Specification_Parameter_CM__c spp:listSpecificationParams){            
            spp.id=null;
        }        
        insert listSpecificationParams;
        
        List<Specification_Option_CM__c> listSpecificationOptions = new List<Specification_Option_CM__c>();       
        for (Integer j = 0; j < listSpecificationParams.size(); j++) {
        	listSpecificationOptions.addAll(TestBusinessHelper.createSpecOptions(3,listSpecificationParams,false));
        }
        for(Specification_Option_CM__c spo:listSpecificationOptions){
            spo.id=null;
        }          
        insert listSpecificationOptions;        
        
        // Create test data
        List<Account> testParentAccounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account accD = TestBusinessHelper.createAccount('Concern_Account', false);
            accD.Id = null;
            accD.Name = 'Test Account Diamond '+ i;
            accD.Country__c = geography.Id;
            accD.Attractiveness__c = 'Key Client';
            testParentAccounts.add(accD);
        }
        for (Integer i = 0; i < 10; i++) {
            Account accPl = TestBusinessHelper.createAccount('Concern_Account', false);
            accPl.Id = null;
            accPl.Name = 'Test Account Platinum '+i;
            accPl.Country__c = geography.Id;
            accPl.Attractiveness__c = 'Runway';
            testParentAccounts.add(accPl);
        }
        for (Integer i = 0; i < 10; i++) {
            Account accPr = TestBusinessHelper.createAccount('Client_Account', false);
            accPr.Id = null;
            accPr.Name = 'Test Account Professional '+i;
            accPr.Country__c = geography.Id;
            accPr.Customer_Role__c = 'Forwarder';
            testParentAccounts.add(accPr);
        }        
        TriggerExecutionController.skipCaseTrigger(true);
        insert testParentAccounts;
        TriggerExecutionController.skipCaseTrigger(false);
        
        List<Account> testChildAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = TestBusinessHelper.createAccount('Client_Account', false);
            acc.Id = null;
            acc.ParentId = testParentAccounts[0].Id;
            acc.Name = 'Test Account Diamond Client'+i;
            acc.Country__c = geography.Id;
            acc.Customer_Role__c = 'Forwarder';
            testChildAccounts.add(acc);
        } 
        for (Integer i = 0; i < 5; i++) {
            Account acc2 = TestBusinessHelper.createAccount('Client_Account', false);
            acc2.Id = null;
            acc2.ParentId = testParentAccounts[22].Id;
            acc2.Name = 'Test Account Professional Client'+i;
            acc2.Country__c = geography.Id;
            acc2.Attractiveness__c = 'Runway';
            testChildAccounts.add(acc2);
        } 
        TriggerExecutionController.skipCaseTrigger(true);
        insert testChildAccounts;
        TriggerExecutionController.skipCaseTrigger(false);        
    }
    
    @isTest
    public static void testBatchExecute(){        
        Test.startTest();
        Batch_CXPackagePopulatorForAccount batchInstance = new Batch_CXPackagePopulatorForAccount(null, null);	
        Id batchId = Database.executeBatch(batchInstance,50);
        System.assertNotEquals(batchId,null,'batchId');
        
        List<ServiceContract> listServiceContract = new List<ServiceContract>();
		listServiceContract = [SELECT Id,AccountId from ServiceContract where Createddate=TODAY];
        System.assertNotEquals(listServiceContract.size(),0,'SC');
        
        List<Entitlement> listEntitlement = new List<Entitlement>();
		listEntitlement = [SELECT Id,AccountId from Entitlement where Createddate=TODAY];
        System.assertNotEquals(listEntitlement.size(),0,'Entitlement');
        
        List<Contract_Line_Item__c> listCli = new List<Contract_Line_Item__c>();
		listCli = [SELECT Id from Contract_Line_Item__c where Createddate=TODAY];
        System.assertNotEquals(listCli.size(),0,'CLI');
        Test.stopTest();
    }
}