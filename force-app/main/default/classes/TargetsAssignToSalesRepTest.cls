/*              
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-10712  10-11-2023    Seba,Bharti             Test class for TargetsAssignToSalesRep.
* 2.0      SFSE- 13491 14-12-2023     Bharti                  Remove Hardcoding Of product Responsibility/Brands
*3.0       SFSE- 13392  11-01-2024   Bharti/Aditi            Add code to cover deletion of TCP
* */
@isTest
public class TargetsAssignToSalesRepTest {
 
    static String adminId; 
   
    
    @testSetup 
    static void dataSetup() {
        
        TriggerExecutionController.skipAccountTrigger(true);
        
        //Concern Account 
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
        //Concern Account 1
        Account concernAccount1 = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount1.Customer_Code__c='TEST55555CONCERNCODE';
        concernAccount1.Id=NULL;
        insert concernAccount1;
        Assert.isNotNull(concernAccount1.Id);
        
        List<Account> lstChildAccounts = new List<Account>();
        
        //Represent Concern of Concern Account 
        Account Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc1.Customer_Code__c='TEST445651';
        Acc1.Represents_Concern__c=TRUE;
        Acc1.ParentId=concernAccount.Id;
        Acc1.Id=NULL;
        lstChildAccounts.add(Acc1);
        
        //Normal Client of Concern Account 
        Account Acc2 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc2.Customer_Code__c='TEST445652';
        Acc2.ParentId=concernAccount.Id;
        Acc2.Id=NULL;
        lstChildAccounts.add(Acc2);
         
        
        //Client account WITHOUT a Concern 
        Account Acc4 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc4.SCV_Status__c  = 'Active'; 
        Acc4.Customer_Code__c='TEST445654'; 
        Acc4.Id=NULL;        
        lstChildAccounts.add(Acc4); 
        
        insert lstChildAccounts;   
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); 
        Assert.isNotNull(country.Id);
        Geography__c country1 = TestBusinessHelper.createGeography('Australia', 'Country', null,'AUS',TRUE);
        Assert.isNotNull(country1.Id);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        Assert.isNotNull(parentBDA.Id);
        
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA.Id);
        
        BDA__c childBDA1 = TestBusinessHelper.createBDA('Saudi Arabia Area', 'Cluster', 'SAA', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA1.Id);
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        BDA_Geography__c bdaGeo1 = TestBusinessHelper.createBDAGeography(childBDA.Id, country1.Id, null, true);
        Assert.isNotNull(bdaGeo.Id);
        Assert.isNotNull(bdaGeo1.Id);
        
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c br = new Target_Brand_Mapping__c();
        br.RecordtypeId = recordTypeId;
        br.Salesforce_Brand__c=BrandUtilities.SEAGO;
        br.Active__c=True;
        br.BrandMnA__c='Sealand Europe';
        insert br;
       
        
        Test.startTest();       
        
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
        }
        
        Assert.isNotNull(adminUser.Id);
        adminId = adminUser.Id;
        
        List<User> usersToInsert = new List<User>();
        System.runAs(adminUser){
            User salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser1.Id = null;
            salesUser1.IsActive=true;
            salesUser1.country = 'India';
            salesUser1.Cluster__c = 'GSC';
            salesUser1.Industry_Focus__c='Retail';
            salesUser1.Segment_Focus__c='Advancement';
            salesUser1.Sales_Job_Function__c='Other';
            usersToInsert.add(salesUser1);
            
            User salesUser2 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
            salesUser2.Id = null;
            salesUser2.IsActive=true;
            salesUser2.country = 'India';
            salesUser2.Cluster__c = 'GSC';
            salesUser2.Industry_Focus__c='Retail';
            salesUser2.Segment_Focus__c='Advancement';
            salesUser2.Sales_Job_Function__c='Sales Manager';
            usersToInsert.add(salesUser2);
            
            insert usersToInsert; 
        }
        
        Territory__c ter1 = TestBusinessHelper.createTerritory(usersToInsert[0], TRUE);
        Territory__c ter2 = TestBusinessHelper.createTerritory(usersToInsert[1], TRUE);
        
        Test.stopTest();       
        Id brandMappingRTId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c(Active__c = TRUE,Salesforce_Brand__c= 'Maersk Line', BrandMnA__c = 'Maersk Line', RecordTypeId = brandMappingRTId);
        insert tbm;   
        Target__c salesTargetTest = TestBusinessHelper.createSalesTarget(usersToInsert[0],'2034','USD','Monthly',TRUE);
        Target_Item_Group__c targetItemGroupTest = TestBusinessHelper.createSalesTargetItemGroup(salesTargetTest, 'Maersk Line', country , bdaGeo, '4PL PF', TRUE);  
        TriggerExecutionController.skipAccountTrigger(false); 
    }
    
    @isTest
    //Test method to cover Represent Concern Account - Role: SO For Proce Owner/Shipper/Consignee
    static void insertTargetMeasureTest1(){
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account representConcernAcc = [SELECT Id from Account WHERE Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1]; 
        Target_Item_Group__c targetItemGroupRec = [SELECT Id from Target_Item_Group__c LIMIT 1]; 
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec, null, representConcernAcc, null, null, null, TRUE);
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        
        //Creating TAA for Represent Concern with SO Role
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = Date.Today();
        lstTAA.add(TAA);
        
        //Creating TAA for Represent Concern with Influencer Role
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], representConcernAcc, TAASettingConstants.POR_Influencer_Only , TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Id = NULL; 
        TAA1.Country__c  = countryIndia.Id;
        TAA1.Start_Date__c = Date.Today();
        lstTAA.add(TAA1);
        
        insert lstTAA;
        
        Test.StartTest(); 
        //Creating Measure record for Price owner
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
        //Creating Measure record for Shipper
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_SHIPPER, TRUE, TRUE);
        //Creating Measure record for Consignee
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_CONSIGNEE, TRUE, TRUE); 
        Test.StopTest(); 
    }
    
    @isTest
    //Test method to cover no Valid TAA exists for NRC, but valid TAA exist for its RC in hierarchy 
    static void insertTargetMeasureTest3(){
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting;
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account nccAcc = [SELECT Id,ParentId from Account WHERE ParentId != NULL  AND Represents_Concern__c = FALSE LIMIT 1];
        Account RCAcc = [SELECT Id from Account WHERE parentId = :nccAcc.parentId AND  Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1]; 
        Target_Item_Group__c targetItemGroupRec = [SELECT Id from Target_Item_Group__c LIMIT 1]; 
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec, null, nccAcc, null, null, null, TRUE); 
        List<Territory_Account_Association__c> lstTAAToInsert = new List<Territory_Account_Association__c>();
        
        List<Territory_Account_Association__c> lstTAA = [SELECT Id from Territory_Account_Association__c WHERE Account__C = :nccAcc.Id];delete lstTAA;
        //Creating TAA for Represent Concern with Influencer Role
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], RCAcc, 'Global Account Owner' , 'All', 'Maersk Line' , FALSE);
        TAA1.Id = NULL;  
        TAA1.Start_Date__c = Date.Today();
        lstTAAToInsert.add(TAA1);
        
        //Creating TAA for Represent Concern with Influencer Role
        Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], RCAcc, 'Influencer' , 'All','Maersk Line', FALSE);
        TAA2.Id = NULL; 
        TAA2.Country__c  = countryIndia.Id;
        TAA2.Start_Date__c = Date.Today();
        lstTAAToInsert.add(TAA2);
        
        insert lstTAAToInsert;
         
        test.StartTest();
        //Creating Measure record for Price owner
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Price Owner', TRUE, TRUE); 
        test.StopTest(); 
    }
    
    
    @isTest
    //Test method to cover Normal Client of Concern - Role: SO  for PO/Shipper/Consignee
    static void insertTargetMeasureTest2(){
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting;
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account normalclientofConcern = [SELECT Id from Account WHERE ParentId != NULL  AND Represents_Concern__c = FALSE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1]; 
        Target_Item_Group__c targetItemGroupRec = [SELECT Id from Target_Item_Group__c LIMIT 1]; 
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec, null, normalclientofConcern, null, null, null, TRUE);  
        List<Territory_Account_Association__c> taaLst = [SELECT ID from Territory_Account_Association__c]; Delete taaLst;
        
        //Creating TAA for Represent Concern with Influencer Role
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], normalclientofConcern, 'Sales Owner' , 'All', 'Maersk Line', FALSE);
        TAA1.Id = NULL;  
        TAA1.Start_Date__c = Date.Today();
        insert TAA1; 
        
        Test.StartTest(); 
        //Creating Measure record for Price owner
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Price Owner', TRUE, TRUE);
        //Creating Measure record for Shipper
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Shipper', TRUE, TRUE);
        //Creating Measure record for Consignee
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Consignee', TRUE, TRUE);
        Test.StopTest(); 
    }
    
    @isTest
    //Test method to cover Normal Client Without Concern    
    static void insertTargetMeasureTest4(){
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting;
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
       Account normalClient = [SELECT Id from Account WHERE ParentId = NULL  AND RecordTypeId=:clientRecordTypeId LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1]; 
        Target_Item_Group__c targetItemGroupRec = [SELECT Id from Target_Item_Group__c LIMIT 1]; 
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec, null, normalClient, null, null, null, TRUE); 
         
        //Creating TAA for Represent Concern with Influencer Role
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], normalClient, 'Sales Owner - Control Only' , 'All', 'Maersk Line', FALSE);
        TAA1.Id = NULL;   
        TAA1.Start_Date__c = Date.Today();
        insert TAA1;  
        
        Test.StartTest(); 
        //Creating Measure record for Price owner
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Price Owner', TRUE, TRUE);
        //Creating Measure record for Shipper
        TestBusinessHelper.createSalesTargetItemMeasure(targetItemRec, TargetSettingConstants.TARGET, 'Revenue', 'Shipper', TRUE, TRUE); 
        Test.StopTest();
    }
    //SFSE-13392
    @isTest
    static void deleteTCPTest(){
        
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting;

        List<Territory__c> listTerritories = [SELECT Id, Portfolio_Owner__c FROM Territory__c];
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        Account normalClient = [SELECT Id from Account WHERE ParentId = NULL  AND RecordTypeId=:clientRecordTypeId LIMIT 1];
        List<Territory_Account_Association__c> lstTaa = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], normalClient, TAASettingConstants.POR_SALES_CONTROL_ONLY , TAASettingConstants.PR_All, 'Maersk Line', false);
        Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], normalClient, TAASettingConstants.POR_Lead_Account_Owner_Only , TAASettingConstants.PR_All, 'Maersk Line', false);
        TAA1.Id = NULL;   
        TAA1.Start_Date__c = Date.Today();
        TAA2.Id = NULL;   
        TAA2.Start_Date__c = Date.Today()+3;
        lstTaa.add(TAA1);
        lstTaa.add(TAA2);
        insert lstTaa;
        
        TAA1.Product_Responsibility__c = 'Ocean';
        TAA2.Brand__c = 'Seago';
        
        
        Test.startTest();        
        update lstTaa;        
        Test.stopTest();
    }
    
}