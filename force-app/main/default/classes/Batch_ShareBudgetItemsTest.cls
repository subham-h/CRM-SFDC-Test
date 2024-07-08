@isTest
public class Batch_ShareBudgetItemsTest {
    
    @testSetup
    static void setupTestData() {
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        
        //User user2 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year = new List<String>{'2034','2035','2036'};
        List<String> curr = new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        BDA_Geography__c bdaGeography = BDAGeographyData_Test.lstBDAGeographies[0];
        Geography__c geo = new Geography__c(Type_Of_Location__c ='Country',Id=bdaGeography.Geography__c);
        update geo;
        
        Geography__c testCountry = new Geography__c();
        testCountry.Name = 'United States';
        testCountry.Active__c =true;
        testCountry.GEO_Code__c = 'IN';
        testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
        testCountry.Is_Port__c = false;
        testCountry.Type_Of_Location__c = 'Country';
        insert testCountry;
        
        BDA__c testCluster = new BDA__C ();
        testCluster.Name = 'West Africa Area';
        testCluster.Type__c = 'Cluster';
        testCluster.BDA_Code__c = 'WAF';
        testCluster.GEO_ID__c= 'dsaewetwer';
        testCluster.Active__c  =  true;
        insert testCluster;
        
        BDA__c testCluster1 = new BDA__C ();
        testCluster1.Name = 'North America Area';
        testCluster1.Type__c = 'Cluster';
        testCluster1.BDA_Code__c = 'CWB';
        testCluster1.GEO_ID__c = 'dsaewetwerq';
        testCluster1.Active__c  =  true;
        insert testCluster1;
        
        BDA__c testRegion = new BDA__C ();
        testRegion.Name = 'Central West Africa';
        testRegion.Type__c = 'Trade Region';
        testRegion.BDA_Code__c = 'CWAD';
        testRegion.GEO_ID__c= 'dsaewetweryyy';
        testRegion.Active__c  =  true;
        testRegion.Parent_BDA__c = testCluster.Id; 
        insert testRegion;
        
        BDA__c testRegion1 = new BDA__C ();
        testRegion1.Name = 'Central West Region';
        testRegion1.Type__c = 'Trade Region';
        testRegion1.BDA_Code__c = 'CWAS';
        testRegion1.GEO_ID__c= 'dsaewetweryyy';
        testRegion1.Active__c  =  true;
        testRegion1.Parent_BDA__c = testCluster1.Id; 
        insert testRegion1;
        
        Budget_Group__c bg = new Budget_Group__c();
        bg.Target__c = testTargets[0].Id;
        bg.Brand__c = 'Maersk Line';
        bg.Country_Code__c = 'US';
        bg.Executing_Country__c = testCountry.Id;
        bg.Product_Family__c = '4PL PF';
        bg.Executing_Country__c = geo.id;
        insert bg;
        
        
        BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
        String countryCode= 'IN';
        List<String> productFamily = new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
        List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
        List<String> brands = new List<String>{'Maersk Line','Hamburg Sud','B2C'};
        Account acc = TestBusinessHelper.createAccount(user1,testCountry,'Client_Account',true);
        Account accConcern = TestBusinessHelper.createAccount(user1,testCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        //List<Target_item_group__c> testTargetGroup = TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        //List<Target_item__c> SalesTargetItems = TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);
        Target_Stage_Matrix__c stageMatrix = TestBusinessHelper.createSalesTargetApprovalMatrix(testTargets[0],TargetSettingConstants.APPROVAL_STAGE_1,testCluster, null, '','',true);
        Target_Reviewer__c reviewer = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix,user1,true,true);
        Target_Stage_Matrix__c stageMatrix2 = TestBusinessHelper.createSalesTargetApprovalMatrix(testTargets[0],TargetSettingConstants.APPROVAL_STAGE_2,testCluster, null, '','',true);
        Target_Reviewer__c reviewerStage2 = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix2,user1,true,true);
    }
    
     @isTest
    static void testItemStage1ControllingExecutingMatch() {
        User user = [SELECT Id,Country FROM User WHERE isActive = true LIMIT 1];
        user.Country = 'United States';
        update user;
        
        Geography__c geaoCountry = [SELECT Id,Type_Of_Location__c,Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' limit 1];
        geaoCountry.Name = 'United States';
        update geaoCountry;
        
        Account accConcern = TestBusinessHelper.createAccount(user,geaoCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        
       // List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        List<Target__c> targetList = [SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c];
        Test.startTest();
        BDA__c bda = [SELECT Id,Type__c FROM BDA__c where Type__c = 'Cluster' limit 1];
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Area__c = bda.Id;
        tx.Target__c= targetList[0].Id;	
        insert tx;
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = user.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        
         
        
        Budget_Group__c Brgrp = [Select Id,Executing_Country__c from Budget_Group__c limit 1];
        
        System.runAs(user) {
            
            Batch_ShareBudgetItems bch = new Batch_ShareBudgetItems(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_1, false);
            ID batchprocessid = Database.executeBatch(bch);
        }
        Test.stopTest();  
    } 
    
    @isTest
    static void testItemStage3ControllingExecutingMatch() {
        User user = [SELECT Id,Country FROM User WHERE isActive = true LIMIT 1];
        user.Country = 'United States';
        update user;
        
        Geography__c geaoCountry = [SELECT Id,Type_Of_Location__c,Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' limit 1];
        geaoCountry.Name = 'United States';
        update geaoCountry;
        
        Account accConcern = TestBusinessHelper.createAccount(user,geaoCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        
       // List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        List<Target__c> targetList = [SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c];
        
        BDA__c bda = [SELECT Id,Type__c FROM BDA__c where Type__c = 'Cluster' limit 1];
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_3;
        tx.Area__c = bda.Id;
        tx.Target__c= targetList[0].Id;	
        insert tx;
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = user.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        
        Test.startTest(); 
        
        Budget_Group__c Brgrp = [Select Id,Executing_Country__c from Budget_Group__c limit 1];
        
        System.runAs(user) {
            
            Batch_ShareBudgetItems bch = new Batch_ShareBudgetItems(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_1, false);
            ID batchprocessid = Database.executeBatch(bch);
        }
        Test.stopTest();  
    }
    
    @isTest
    static void testItemStage4ControllingExecutingMatch() {
        User user = [SELECT Id,Country FROM User WHERE isActive = true LIMIT 1];
        user.Country = 'United States';
        update user;
        
        Geography__c geaoCountry = [SELECT Id,Type_Of_Location__c,Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' limit 1];
        geaoCountry.Name = 'United States';
        update geaoCountry;
        
        Account accConcern = TestBusinessHelper.createAccount(user,geaoCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        
       // List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        List<Target__c> targetList = [SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c];
        
        BDA__c bda = [SELECT Id,Type__c FROM BDA__c where Type__c = 'Cluster' limit 1];
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_4;
        tx.Area__c = bda.Id;
        tx.Target__c= targetList[0].Id;	
        insert tx;
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = user.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        Test.startTest(); 
        
        Budget_Group__c Brgrp = [Select Id,Executing_Country__c,Executing_Area__c from Budget_Group__c limit 1];
        Brgrp.Executing_Area__c = bda.Id;
        update Brgrp;
        System.runAs(user) {
            
            Batch_ShareBudgetItems bch = new Batch_ShareBudgetItems(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_1, false);
            ID batchprocessid = Database.executeBatch(bch);
        }
        Test.stopTest();  
    }
    
    @isTest
    static void testItemStage8ControllingExecutingMatch() {
        User user = [SELECT Id,Country FROM User WHERE isActive = true LIMIT 1];
        user.Country = 'United States';
        update user;
        
        Geography__c geaoCountry = [SELECT Id,Type_Of_Location__c,Name FROM Geography__c WHERE Type_Of_Location__c = 'Country' limit 1];
        geaoCountry.Name = 'United States';
        update geaoCountry;
        
        Account accConcern = TestBusinessHelper.createAccount(user,geaoCountry,'Concern_Account',true);
        accConcern.Represents_Concern__c = true;
        Update accConcern;
        
       // List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        List<Target__c> targetList = [SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c];
        
        BDA__c bda = [SELECT Id,Type__c FROM BDA__c where Type__c = 'Cluster' limit 1];
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_8;
        tx.Area__c = bda.Id;
        tx.Target__c= targetList[0].Id;	
        insert tx;
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = user.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        
        Test.startTest(); 
        
        //Budget_Group__c Brgrp = [Select Id,Executing_Country__c,Executing_Area__c from Budget_Group__c limit 1];
        
        System.runAs(user) {
            
            Batch_ShareBudgetItems bch = new Batch_ShareBudgetItems(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_1, false);
            ID batchprocessid = Database.executeBatch(bch);
        }
        Test.stopTest();  
    }

}