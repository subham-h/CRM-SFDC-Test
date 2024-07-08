/*
 * Author   : Ragu
 * Purpose  : Test Class for StaticFactory 
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   04-Apr-2016 Ragu@UST                Created.
 * 1.1      RQ-004058   07-Jun-2016 Sandhya@UST             Assign ISR Queues based on Case Liner Brand
 * 1.2      RQ-003805   15-Dec-2016 Nirmal@UST              Test if Community user is available
 */
@isTest
private class StaticFactory_Test {

    static testMethod void testUserDetails() {
        StaticFactory.getCurrentUserDetails();
        StaticFactory.getUserDetails(UserInfo.getUserId());
    }
    
    static testMethod void testOrgDetails() {
        StaticFactory.getEnvironment();
    }
    
    static testMethod void testRecordTypeMethods() {
        list<RecordType> lstRecTypes = [select Id, Name, SobjectType from RecordType where IsActive = true and SobjectType != 'Knowledge__kav' limit 2];
        if(lstRecTypes != null) {
            RecordType recType = lstRecTypes[0];
            StaticFactory.getRecordTypes(recType.SobjectType);
            StaticFactory.getRecordTypeIdNameMapByNames(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeNameIdMapByNames(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeIdNameMapByIds(recType.SobjectType, new set<Id> {recType.Id});
            StaticFactory.getRecordTypeNameIdMapByIds(recType.SobjectType, new set<Id> {recType.Id});
            StaticFactory.getRecordTypeIds(recType.SobjectType);
            StaticFactory.getRecordTypeNames(recType.SobjectType);
            StaticFactory.getRecordTypeIdByName(recType.SobjectType, recType.Name);
            StaticFactory.getRecordTypeIdByDevName(recType.SobjectType, recType.Name);
            StaticFactory.getRecordTypeNameById(recType.SobjectType, recType.Id);
            StaticFactory.getRecordTypeIdsByNames(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeIdsByDevNames(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeNamesByIds(recType.SobjectType, new set<Id> {recType.Id});
        }
    }
    
    static testMethod void testRecordTypeMethodsDESC() {
        list<RecordType> lstRecTypes = [select Id, Name, SobjectType from RecordType where IsActive = true and SobjectType != 'Knowledge__kav' limit 2];
        if(lstRecTypes != null) {
            RecordType recType = lstRecTypes[0];
            StaticFactory.getRecordTypesDESC(recType.SobjectType);
            StaticFactory.getRecordTypeIdNameMapByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeNameIdMapByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeIdNameMapByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
            StaticFactory.getRecordTypeNameIdMapByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
            StaticFactory.getRecordTypeIdsDESC(recType.SobjectType);
            StaticFactory.getRecordTypeNamesDESC(recType.SobjectType);
            StaticFactory.getRecordTypeIdByNameDESC(recType.SobjectType, recType.Name);
            StaticFactory.getRecordTypeNameByIdDESC(recType.SobjectType, recType.Id);
            StaticFactory.getRecordTypeIdsByNamesDESC(recType.SobjectType, new set<String> {recType.Name});
            StaticFactory.getRecordTypeNamesByIdsDESC(recType.SobjectType, new set<Id> {recType.Id});
        }
    }
    
    static testMethod void testQueueMethods() {
        map<Id, Group> mapQueuesTest = StaticFactory.getQueueMap();
        if(mapQueuesTest != null && !mapQueuesTest.isEmpty()) {
            Group queueInst = mapQueuesTest.values()[0];
            StaticFactory.getQueueIdNameMap();
            StaticFactory.getQueueNameById(queueInst.Id);
            StaticFactory.getQueueById(queueInst.Id);
            StaticFactory.getQueueIdByName(queueInst.Name);
            StaticFactory.getQueueNameIdMapByNames('Case', new  set<String>{queueInst.Name}); //v1.1
        }
    }
    
    static testMethod void testIsCommunityUser () {//V1.2 
        Boolean isCommunityUser = StaticFactory.isCommunityUser ();
     }
    
    
    static testMethod void testPublicGroupMethods() {
        map<Id, Group> mapGroupTest = StaticFactory.getGroupMap();
        if(mapGroupTest != null && !mapGroupTest.isEmpty()) {
            Group grpInst = mapGroupTest.values()[0];
            StaticFactory.getGroupIdNameMap();
            StaticFactory.getGroupNameById(grpInst.Id);
            StaticFactory.getGroupById(grpInst.Id);
            StaticFactory.getGroupIdByName(grpInst.Name);
        }
    }
     static testMethod void testGeoListValues () {//V1.2 
        list<Geography__c> lstgeography = StaticFactory.getGetGeoListValues();
        //CaseData_Test.createExternalCases();
        CaseFieldPopulator_Test.CreateCasewithcitycountryupdate();
     }
    
    static testMethod void testGetArtemisQueueList () {
        List<String> artemisQueueList = StaticFactory.artemisQueueList;
    }
    
}