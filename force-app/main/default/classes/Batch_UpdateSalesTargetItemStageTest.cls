/*              
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -----------------      -----------
* 1.0      SFSE-11471  10-Oct-2023   Shubham                Test Class for Batch_UpdateSalesTargetItemStage
*/
@isTest
public class Batch_UpdateSalesTargetItemStageTest {
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        User user1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        user1.FirstName = 'Test Batch User Target';
        user1.Id = null;
        
        PermissionSet ps = [SELECT Id 
                            FROM PermissionSet 
                            WHERE Name = 'Sales_Target_Administrator'];
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert user1;
            insert new PermissionSetAssignment(AssigneeId = user1.Id, PermissionSetId = ps.Id);
        }
        TriggerExecutionController.skipUserTrigger(true);
        Test.stopTest();
        TriggerExecutionController.skipAllTriggers(true);
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
        List<String> year = new List<String>{'2034','2035','2036'};
        List<String> curr = new List<String>{'USD','USD','USD'};
        List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        Geography__c testCountry = new Geography__c();
        testCountry.Name = 'India';
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
        BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
        bdaGeo.BDA__c = testCluster.Id;
        bdaGeo.Geography__c = testCountry.Id;
        insert bdaGeo;
        List<Geography__c> cntry= new List<Geography__c>{testCountry,testCountry,testCountry};
        String countryCode= 'IN';
        List<String> productFamily = new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
        List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
        List<String> brands = new List<String>{'Maersk Line','Hamburg Sud','B2C'};
        Account acc = TestBusinessHelper.createAccount('Client_Account',true);
        List<Target_item_group__c> testTargetGroup = TestBusinessHelper.createSalesTargetItemGroups(testTargets, brands,cntry,bdaGeo, productFamily, 3, true);
        List<Target_item__c> SalesTargetItems = TestBusinessHelper.createSalesTargetItems(testTargetGroup, acc, 3, true);
        Target_Stage_Matrix__c stageMatrix = TestBusinessHelper.createSalesTargetApprovalMatrix(testTargets[0],TargetSettingConstants.APPROVAL_STAGE_1,testCluster, null, '','',true);
        Target_Reviewer__c reviewer = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix,user1,true,true);
        Target_Stage_Matrix__c stageMatrix2 = TestBusinessHelper.createSalesTargetApprovalMatrix(testTargets[0],TargetSettingConstants.APPROVAL_STAGE_2,testCluster, null, '','',true);
        Target_Reviewer__c reviewerStage2 = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix2,user1,true,true);
    
    }
    
    @isTest
    static void testItemStage2() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c, Sales_Target_Item_Group__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        }
        update targetItemList;
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        System.debug([select id from target_item__c where target__c = :targetList[0].Id]);
        Target_Item_Group__c itemGroup = [SELECT Id FROM Target_Item_Group__c WHERE Target__c = :targetList[0].Id];
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(null, itemGroup, null, null, null, null, null, true);
        User user = [SELECT Id FROM User where isActive = true LIMIT 1];
        Test.startTest();
        System.runAs(user) {
            Batch_UpdateSalesTargetItemStage bch = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_2);
            DataBase.executeBatch(bch);   
        }
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage3() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
            update targetItemList;    
        }
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_3);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage4() {
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
            update targetItemList;    
        }
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_4);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage5() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
            update targetItemList;    
        }
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_5);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage6() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
            update targetItemList;    
        }
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_6);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage7() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_7;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
            update targetItemList;    
        }
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_7);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStageError() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
            update targetItemList;    
        }
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        List<Target_Reviewer__c> approverList = [SELECT Id, Approved__c from Target_Reviewer__c];
        Test.startTest();
        Batch_UpdateSalesTargetItemStage bch1 = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_3);
        Batch_UpdateSalesTargetItemStageHelper.updateTargetApprover(approverList);
        DataBase.executeBatch(bch1);
        Test.stopTest();
    }
    
    @isTest
    static void testItemStage8() {
        
        List<Target__c> targetList = [SELECT Id, Review_Stage__c FROM Target__c];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update targetList[0];
        List<Target_Item__c> targetItemList = [SELECT Id, Review_Stage__c, Sales_Target_Item_Group__c FROM Target_Item__c WHERE Target__c = :targetList[0].Id];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        }
        update targetItemList;
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        update targetList[0];
        targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        update targetList[0];
        for (Target_Item__c item : targetItemList) {
            targetList[0].Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        }
        update targetItemList;
        System.debug([select id from target_item__c where target__c = :targetList[0].Id]);
        Target_Item_Group__c itemGroup = [SELECT Id FROM Target_Item_Group__c WHERE Target__c = :targetList[0].Id];
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(null, itemGroup, null, null, null, null, null, true);
        User user = [SELECT Id FROM User where FirstName = 'Test Batch User Target' LIMIT 1];
        Test.startTest();
        System.runAs(user) {
            Batch_UpdateSalesTargetItemStage bch = new Batch_UpdateSalesTargetItemStage(targetList[0].Id, TargetSettingConstants.APPROVAL_STAGE_3);
            DataBase.executeBatch(bch);   
        }
        Test.stopTest();
    }
}