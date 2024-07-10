@isTest
public class Batch_DataImportTest {
    
    @testSetup
    static void setUpData() {
        TerritoryDataGeneration_Test.createTerritoryData();
        Validation_Rules_Bypass__c customSetting = new Validation_Rules_Bypass__c();
        customSetting.Active__c = true;
        customSetting.Name = 'Test';
        insert customSetting;
    }
    
    @isTest
    static void test1() {
        
        Test.startTest();
        List<String> headers = new List<String>{'Customer Code','Portfolio Owner Maersk UID','Portfolio Owner Responsibility','Brand','Start Date'};
        List<Territory__c> tList = [SELECT id,Portfolio_Owner__c, Portfolio_Owner__r.Maersk_User_Id__c, name from Territory__c];
        String userId = tList[0].Portfolio_Owner__c;
        User user = [select id,Liner_Brand__c from user where Id =:userId];
        user.Liner_Brand__c = 'Maersk Line';
        User latest = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        system.runAs(latest) {
            update user;    
        }
        List<Account> acclist = [SELECT Id,Customer_Code__c,Name FROM Account];
        acclist[0].Customer_Code__c = 'Sdff3wr';
        update acclist;
        Data_Import_Mapping__c dataMapping = new Data_Import_Mapping__c();
        dataMapping.Operations__c = 'Create';
        dataMapping.Config__c = 'Territory_Account_Association';
        dataMapping.Field1__c = 'Sdff3wr';
        dataMapping.Field2__c = 'SAL001';
        dataMapping.Field3__c = 'Lead Account Owner';
        dataMapping.Field5__c = 'Maersk Line';
        dataMapping.Field6__c = '01/01/2023';
        
        insert dataMapping;
        Set<String> idSet = new Set<String>();
        idSet.add(dataMapping.Id);
        Batch_DataImport bch = new Batch_DataImport(idSet,'Territory_Account_Association',headers,'Create');
        DataBase.executeBatch(bch);
        Test.stopTest();
    }
    
    @isTest
    static void test2() {
        
        List<String> headers = new List<String>{'Customer Code','Portfolio Owner Maersk UID','Portfolio Owner Responsibility','Brand','Start Date'};
        Data_Import_Mapping__c dataMapping = new Data_Import_Mapping__c();
        dataMapping.Operations__c = 'Create';
        dataMapping.Config__c = 'Territory_Account_Association';
        dataMapping.Status__c = 'New';
        dataMapping.Field1__c = 'Sdff3wr';
        dataMapping.Field2__c = 'SJA447';
        dataMapping.Field3__c = 'Influencer';
        dataMapping.Field4__c = 'Nordic Area';
        dataMapping.Field5__c = 'Maersk Line';
        dataMapping.Field6__c = '01/01/2023';
        insert dataMapping;
        Set<String> idSet = new Set<String>();
        idSet.add(dataMapping.Id);
        Test.startTest();
        Batch_DataImport bch = new Batch_DataImport(idSet,'Territory_Account_Association',headers,'Create');
        DataBase.executeBatch(bch);
        Test.stopTest();
        dataMapping = [SELECT Id, Status__c,Message__c FROM Data_Import_Mapping__c limit 1];
        System.assertEquals('Failed',dataMapping.Status__c);
    }
    
    @isTest
    static void test3() {
        
        List<String> headers = new List<String>{'Customer Code','Portfolio Owner Maersk UID','Portfolio Owner Responsibility','Brand','Start Date'};
        Data_Import_Mapping__c dataMapping = new Data_Import_Mapping__c();
        dataMapping.Operations__c = 'Create';
        dataMapping.Config__c = 'Territory_Account_Association';
        dataMapping.Status__c = 'New';
        dataMapping.Field1__c = 'Sdff3wr';
        dataMapping.Field2__c = 'SJA447';
        dataMapping.Field3__c = 'Influencer';
        dataMapping.Field4__c = 'Nordic Area';
        dataMapping.Field5__c = 'Maersk Line';
        dataMapping.Field6__c = '01/31/2023';
        insert dataMapping;
        Set<String> idSet = new Set<String>();
        idSet.add(dataMapping.Id);
        Test.startTest();
        Batch_DataImport bch = new Batch_DataImport(idSet,'Territory_Account_Association',headers,'Create');
        DataBase.executeBatch(bch);
        Test.stopTest();
        dataMapping = [SELECT Id, Status__c,Message__c FROM Data_Import_Mapping__c limit 1];
        System.assertEquals('Failed',dataMapping.Status__c);
    }
    
    
}