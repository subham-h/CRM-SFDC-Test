@isTest
public class DataImportUtilityClass_Test {
    
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
        
        List<Territory__c> tList = [select id,Portfolio_Owner__c,  name from Territory__c];
        List<String> headers = new List<String>{'Customer Code','Portfolio Owner Maersk UID','Portfolio Owner Responsibility','Brand','Start Date'};
        String userId = tList[0].Portfolio_Owner__c;
        User user = [select id,Liner_Brand__c from user where Id =:userId];
        user.Liner_Brand__c = 'Maersk Line';
        Test.startTest();
        User latest = [SELECT id FROM user WHERE id = :UserInfo.getUserId()];
        system.runAs(latest) {
            update user;    
        }
        
        Data_Import_Mapping__c dataMapping = new Data_Import_Mapping__c();
        dataMapping.Operations__c = 'Create';
        dataMapping.Config__c = 'Territory_Account_Association';
        dataMapping.Status__c = 'New';
        dataMapping.Field1__c = 'Sdff3wr';
        dataMapping.Field2__c = 'SAL001';
        dataMapping.Field3__c = 'Lead Account Owner';
        dataMapping.Field5__c = 'Maersk Line';
        dataMapping.Field6__c = '01/01/2023';	
        insert dataMapping;
        List<sObject> records = new List<sObject>();
        records.add(dataMapping);
        
        DataImportUtilityClass util = new DataImportUtilityClass();
        DataImportUtilityClass.DataWrapper dataWrapper = util.processIntermediateRecords(records,'Territory_Account_Association',headers);
        Test.stopTest();
        
    }
    
    @isTest
    static void test2() {
        
        Test.startTest();
        List<String> headers = new List<String>{'Customer Code','Portfolio Owner Maersk UID','Portfolio Owner Responsibility','Brand','Start Date'};
        List<Data_Import_Staging__mdt> staging_Data = DataImportUtilityClass.getIntermediateMetaData('Territory_Account_Association',headers);
        Set<String> fieldsInfo = new Set<String>();        
        for(Data_Import_Staging__mdt inter: staging_Data){
            fieldsInfo.add(inter.Source_Field__c);
            fieldsInfo.add(inter.Target_Field__c); 
        }
        List<FieldDefinition> result = DataImportUtilityClass.getFieldDefinition(fieldsInfo);
        DataImportUtilityClass util = new DataImportUtilityClass();
        util.getIntList(new List<String>{'1','2','3'});
        util.getDoubleList(new List<String>{'1','2','3'});
        util.getDec('1');
        util.getBool('1');
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        sObject sObj = globalDescribe.get('Data_Import_Mapping__c').newSObject();
        util.getDate('3/7/2023', sObj);
        util.getDate('', sObj);
        util.getDateTime('', sObj);
        util.getInt('2');
        try {
            util.getDate('01/01/2023/2345', sObj);
            util.getDateTime('12-34-5654', sObj);
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }
}