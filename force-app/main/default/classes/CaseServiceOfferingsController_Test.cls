@isTest
public class CaseServiceOfferingsController_Test {
@testSetup
    public static void setup(){
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
        
        List<Account> listAccount = new List<Account>();
        Account accD = TestBusinessHelper.createAccount('Concern_Account', false);
        accD.Id = null;
        accD.Name = 'Test Account Diamond';
        accD.Country__c = geography.Id;
        accD.Attractiveness__c = 'Key Client';
        listAccount.add(accD); 
        Account accPl = TestBusinessHelper.createAccount('Concern_Account', false);
        accPl.Id = null;
        accPl.Name = 'Test Account Platinum';
        accPl.Country__c = geography.Id;
        accPl.Attractiveness__c = 'Runway';
        listAccount.add(accPl);
        Account accPr = TestBusinessHelper.createAccount('Client_Account', false);
        accPr.Id = null;
        accPr.Name = 'Test Account Professional';
        accPr.Country__c = geography.Id;
        accPr.Customer_Role__c = 'Forwarder';
        listAccount.add(accPr);
		Account accNp = TestBusinessHelper.createAccount('Concern_Account', false);
        accNp.Id = null;
        accNp.Name = 'Test Account NoPackge';
        accNp.Country__c = geography.Id;
        accNp.Attractiveness__c = 'Booster';
		listAccount.add(accNp);        
        insert listAccount;
        Account acc = TestBusinessHelper.createAccount('Client_Account', false);
        acc.Id = null;
        acc.ParentId = listAccount[0].Id;
        acc.Name = 'Test Account Diamond Client';
        acc.Country__c = geography.Id;
        acc.Customer_Role__c = 'Forwarder';
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc,'Customer_Contact','Maersk Line', true);                
    }
    
    @isTest
    public static void testCaseCxPackage(){
        Test.startTest();
        Account acc = [Select Id,CX_Package_Indicator__c,Country__c,(Select Id from ServiceContracts),(Select Id from Entitlements) From Account where Name='Test Account Diamond' LIMIT 1];
        Contact con = [Select Id,Country__c From Contact LIMIT 1];
        Geography__c geo = [Select Id From Geography__c LIMIT 1];
        //Assertions for Account
        System.assertEquals(acc.CX_Package_Indicator__c,'Diamond','Diamond CX Package');
        System.assertNotEquals(acc.ServiceContracts.size(),0,'Service contracts');
        System.assertNotEquals(acc.Entitlements.size(),0,'Entitlements');
        List<Contract_Line_Item__c> listCli = new List<Contract_Line_Item__c>();
        listCli = [Select id from Contract_Line_Item__c where Service_Contract__c= :acc.ServiceContracts[0].Id];
        System.assertNotEquals(listCli.size(),0,'CLI');
        
        //Create case for the account
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.AccountId = acc.Id;
        cs.ContactId = con.Id;
        cs.Subject = 'Test diamond';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test diamond';
        cs.Country__c = geo.Id;
        insert cs;        
        Case cas = [Select Id,CX_Package__c,Country__c from Case where subject='Test diamond' limit 1];
        System.assertNotEquals(cas.Country__c,null,'Diamond CX Package');
        System.assertNotEquals(cas.CX_Package__c,null,'Diamond CX Package');
        
        //Cover CaseServiceOfferingsController class
        List<CaseServiceOfferingsController.ContractLineItemWrapper> listContractLineItems = new List<CaseServiceOfferingsController.ContractLineItemWrapper>();
        listContractLineItems = CaseServiceOfferingsController.getContractLineItemsWrapper(cas.Id,'Case');
        System.assertNotEquals(listContractLineItems.size(),0,'CLIs');
        Test.stopTest();
    }
    @isTest
    public static void testAccountCxPackage(){
        Test.startTest();
        Account acc = [Select Id,CX_Package_Indicator__c,Country__c,(Select Id from ServiceContracts),(Select Id from Entitlements) from Account where Name='Test Account Platinum' LIMIT 1];
        Contact con = [Select Id,Country__c From Contact LIMIT 1];
        Geography__c geo = [Select Id From Geography__c LIMIT 1];
        //Assertions for Account
        System.assertEquals(acc.CX_Package_Indicator__c,'Platinum','Platinum CX Package');
        System.assertNotEquals(acc.ServiceContracts.size(),0,'Service contracts');
        System.assertNotEquals(acc.Entitlements.size(),0,'Entitlements');
        List<Contract_Line_Item__c> listCli = new List<Contract_Line_Item__c>();
        listCli = [Select id from Contract_Line_Item__c where Service_Contract__c= :acc.ServiceContracts[0].Id];
        System.assertNotEquals(listCli.size(),0,'CLI');
        
        //Cover CaseServiceOfferingsController class for Account scenario
        List<CaseServiceOfferingsController.ContractLineItemWrapper> listContractLineItems = new List<CaseServiceOfferingsController.ContractLineItemWrapper>();
        listContractLineItems = CaseServiceOfferingsController.getContractLineItemsWrapper(acc.Id,'Account');
        System.assertNotEquals(listContractLineItems.size(),0,'CLIs');
        Test.stopTest();
    }
    
    @isTest
    public static void testScmCasePackage(){
        Test.startTest();
        Account acc = [Select Id,CX_Package_Indicator__c,Country__c From Account where Name='Test Account Diamond Client' LIMIT 1];
        Contact con = [Select Id,Country__c From Contact LIMIT 1];
        Geography__c geo = [Select Id From Geography__c LIMIT 1];        
        
        Account accOnBehalf = [Select Id,CX_Package_Indicator__c,Country__c,(Select Id from ServiceContracts),(Select Id from Entitlements) From Account where Name='Test Account Professional' LIMIT 1];
        //Assertions for Account
        System.assertEquals(accOnBehalf.CX_Package_Indicator__c,'Professional','Professional CX Package');
        System.assertNotEquals(accOnBehalf.ServiceContracts.size(),0,'Service contracts');
        System.assertNotEquals(accOnBehalf.Entitlements.size(),0,'Entitlements');
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.AccountId = acc.Id;
        cs.ContactId = con.Id;
        cs.On_Behalf_Account__c = accOnBehalf.Id;
        cs.Product__c = 'SCM';
        cs.Case_Visibility__c = 'Multi-Carrier';
        cs.Type = 'Carrier booking'; 
        cs.sub_type__c = 'Booking confirmation';
        cs.Reason_For_Case__c = 'New booking confirmation';
        cs.Subject = 'Test SCM Professional';
        cs.Case_Channel__c = 'Telephone';
        cs.Description = 'Test SCM Professional';
        cs.Country__c = geo.Id;
        insert cs;
        Case cas = [Select Id,CX_Package__c,Country__c from Case where subject='Test SCM Professional' limit 1];
        System.assertNotEquals(cas.CX_Package__c,null,'Professional CX Package');
        
        //Cover CaseServiceOfferingsController class for SCM scenario
        List<CaseServiceOfferingsController.ContractLineItemWrapper> listContractLineItems = new List<CaseServiceOfferingsController.ContractLineItemWrapper>();
        listContractLineItems = CaseServiceOfferingsController.getContractLineItemsWrapper(cas.Id,'Case');
        System.assertNotEquals(listContractLineItems.size(),0,'CLIs');
        System.assertEquals(listContractLineItems[0].featureName,'Professional','CLI');
        Test.stopTest();
    }
    
    @isTest
    public static void testClientCxPackage(){
        Test.startTest();
        Account acc = [Select Id,CX_Package_Indicator__c,Country__c,(Select Id from ServiceContracts),(Select Id from Entitlements) From Account where Name='Test Account Diamond Client' LIMIT 1];
        Contact con = [Select Id,Country__c From Contact LIMIT 1];
        Geography__c geo = [Select Id From Geography__c LIMIT 1];        
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.AccountId = acc.Id;
        cs.ContactId = con.Id;
        cs.Subject = 'Test Diamond client';
        cs.Case_Channel__c = 'Telephone';
        cs.Description = 'Test Diamond client';
        cs.Country__c = geo.Id;
        insert cs;
        Case cas = [Select Id,CX_Package__c,Country__c from Case where subject='Test Diamond client' limit 1];
        System.assertNotEquals(cas.CX_Package__c,null,'Diamond CX Package');
        
        //Cover CaseServiceOfferingsController class for Client account scenario
        List<CaseServiceOfferingsController.ContractLineItemWrapper> listContractLineItems = new List<CaseServiceOfferingsController.ContractLineItemWrapper>();
        listContractLineItems = CaseServiceOfferingsController.getContractLineItemsWrapper(cas.Id,'Case');
        System.assertNotEquals(listContractLineItems.size(),0,'CLIs');
        System.assertEquals(listContractLineItems[0].featureName,'Diamond','CLI');
        Test.stopTest();
    }
    
    @isTest
    public static void testNoPackage(){ 
        Test.startTest();
        Account accNp = [Select Id,CX_Package_Indicator__c,Country__c,CX_Package__c From Account where Name='Test Account NoPackge' LIMIT 1];
        System.assertEquals(accNp.CX_Package_Indicator__c,null,'No CX Package');
        System.assertEquals(accNp.CX_Package__c,null,'No CX Package');
        //Cover CaseServiceOfferingsController class for Client account scenario
        List<CaseServiceOfferingsController.ContractLineItemWrapper> listContractLineItems = new List<CaseServiceOfferingsController.ContractLineItemWrapper>();
        listContractLineItems = CaseServiceOfferingsController.getContractLineItemsWrapper(accNp.Id,'Account');
        System.assertEquals(listContractLineItems.size(),0,'CLIs');
        Test.stopTest();
    }
}