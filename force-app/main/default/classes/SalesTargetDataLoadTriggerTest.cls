@isTest
public class SalesTargetDataLoadTriggerTest {
	@testSetup
    static void setupTestData(){
        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
                
        List<Geography__c> listGeographyToInsert = new list<Geography__c>();
        Geography__c country1 = TestBusinessHelper.createGeography('India', 'Country', null,'IN',FALSE); country1.Id = null; listGeographyToInsert.add(country1);
        Geography__c country2 = TestBusinessHelper.createGeography('InvalidCountry', 'Country', null,'INVAl',FALSE); country2.Id = null;  listGeographyToInsert.add(country2);
        insert listGeographyToInsert;
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true); 
        System.assertNotEquals(null, parentBDA.Id); 
        
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        System.assertNotEquals(null, childBDA.Id);  
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country1.Id, null, true);
        BDA_Geography__c bdaGeo1 = TestBusinessHelper.createBDAGeography(childBDA.Id, country2.Id, null, true);
        
       	Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST4876CONCERNCODE';
        concernAccount.Id=NULL;
        TriggerExecutionController.skipAccountTrigger(true);
        insert concernAccount;
        
        List<Account> lstClientAccounts = new List<Account>();
        Account RC1 = TestBusinessHelper.createAccount('Client_Account',False);
        RC1.Customer_Code__c='TEST487651'; 
        RC1.Represents_Concern__c=TRUE;
        RC1.ParentId=concernAccount.Id;
        RC1.Id=NULL;
        lstClientAccounts.add(RC1);
        
        Account NCC1 = TestBusinessHelper.createAccount('Client_Account',False);
        NCC1.Customer_Code__c='TEST445652'; 
        NCC1.ParentId=concernAccount.Id;
        NCC1.Id=NULL;
        lstClientAccounts.add(NCC1);
		
	    insert lstClientAccounts;
        
        Target__c target = TestBusinessHelper.createSalesTarget(user1, '2050', 'USD', 'Monthly', true);      
        Budget_Group__c budgetGroup = TestBusinessHelper.createSalesBudgetGroup(target, 'Hamburg Sud', childBDA, country1, '4PL PF', 'StagingReference', true );
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(target, 'Hamburg Sud', country1, bdaGeo, 'WND PF', true);
        
        Target_item__c targetItem = TestBusinessHelper.createSalesTargetItem(target, targetItemGroup, null, NCC1, null, null, null, true);
        
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, TargetSettingConstants.CY_ACTUALS, 'Volume', 'Shipper', false, true);        
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, TargetSettingConstants.CY_ACTUALS, 'Revenue', 'Shipper', false, true);
        Target_Measure__c targetMeasure3 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, TargetSettingConstants.CY_ACTUALS, 'Revenue', 'Price Owner', false, true);
        Target_Measure__c targetMeasure4 = TestBusinessHelper.createSalesTargetItemMeasure(targetItem, TargetSettingConstants.CY_ACTUALS, 'Gross Profit', 'Shipper', false, true);         
    }

	@isTest
    static void testMethod1(){
        
        Target_Data_Load__c dataLoad = new Target_Data_Load__c(Correlation_Id__c = '123456789011121314151617181920212223242', Data_Load_Type__c=TargetSettingConstants.CY_ACTUALS, Status__c='New');
        insert dataLoad;
        List<Account> accounts = [SELECT Id,Customer_Code__c FROM Account WHERE Customer_Code__c='TEST445652' OR  Customer_Code__c='TEST487651'];
        List<Target_Setting_Staging__c> lstTargetSettingStaging = new List<Target_Setting_Staging__c>();
        
        Target_Setting_Staging__c targetSettingStageTest1 = TestBusinessHelper.createTargetSettingStage('USD',TargetSettingConstants.CY_ACTUALS,'New','Revenue','Maersk Line',accounts[0].Customer_Code__c,
                                                                                                        TRUE,'123456789011121314151617181920212223242', 'IN', FALSE, TRUE, accounts[1].Customer_Code__c,'Insurance PF','ROFOQ42023', accounts[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest1.Id = NULL;
        targetSettingStageTest1.Price_Owner_Account_Id__c = accounts[0].Id;
        targetSettingStageTest1.Shipper_Account_Id__c = accounts[0].Id;
        targetSettingStageTest1.Consignee_Account_Id__c = accounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest1);
        
        Test.startTest();
            dataLoad.Status__c='Completed';
            update dataLoad; 
        Test.stopTest();
    }
    
}