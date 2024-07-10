/*
 * Author   : Ragu
 * Purpose  : Test class for CaseTrigger_DataSetUtilities.
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002716   11-Nov-2016 Ragu@UST                Test class for CaseTrigger_DataSetUtilities.
 *  
 */
 
@isTest
private class CaseTrigger_DataSetUtilities_Test {

    static testMethod void test_generalMethods() {
        // Create Contacts
        ContactData_Test.createCustomerContacts();

        User currentUser = CaseTrigger_DataSetUtilities.getLoggedInUser(UserInfo.getUserId());
        System.assertEquals(currentUser.Id, UserInfo.getUserId());
        
        set<Id> setContactIds = new set<Id>();
        set<String> setContactEmails = new set<String>();
        set<Id> setAccountIds = new set<Id>();
        for(Contact con : [select Id, Email, AccountId from Contact order by CreatedDate desc limit 10]) {
            setContactIds.add(con.Id);
            setContactEmails.add(con.Email);
            setAccountIds.add(con.AccountId);
        }
        
        list<Contact> lstContacts = CaseTrigger_DataSetUtilities.getContactlist(setContactIds, setContactEmails);
        System.assertNotEquals(lstContacts, null);
        
        map<Id, Contact> mapContacts = CaseTrigger_DataSetUtilities.getContactIdToContactMap(setContactIds);
        System.assertNotEquals(mapContacts, null);
        
        list<Account> lstAccounts = CaseTrigger_DataSetUtilities.getAccountList(setAccountIds);
        System.assertEquals(lstAccounts.size(), 1);
    }
    
    static testMethod void test_customMetadataRelatedMethods() {
        list<LinerBrand_Direction_and_Country__mdt> lstLBDCs = CaseTrigger_DataSetUtilities.getCustomMetadataList(new set<String>{'MSLUSEXP', 'MSLUSIMP', 'MSLINIMP', 'MSLINEXP'});
        System.assertNotEquals(lstLBDCs, null);
        
        map<string,LinerBrand_Direction_and_Country__mdt>lstLBDCs2 = CaseTrigger_DataSetUtilities.getAllCustomMetadataList();
        System.assertNotEquals(lstLBDCs, null);
    }
    
    static testMethod void test_geographyRelatedMethods() {
        // Create BDA, Geography and BDA_Geography
        BDAGeographyData_Test bdaGeo = new BDAGeographyData_Test();

        list<Geography__c> lstGeos = CaseTrigger_DataSetUtilities.getAllCountrylist();
        list<BDA__c> lstBDAs = CaseTrigger_DataSetUtilities.getBDAList();
        
        set<Id> setClusterIds = new set<Id>();
        for(BDA__c bda : [select Id from BDA__c where Type__c = 'Cluster' order by CreatedDate desc]) {
            setClusterIds.add(bda.Id);
        }
        set<Id> setCountryIds = new set<Id>();
        for(Geography__c geo : [select Id from Geography__c where Type_Of_Location__c = 'Country' order by CreatedDate desc]) {
            setCountryIds.add(geo.Id);
        }
        list<BDA_Geography__c> lstBDAGeos = CaseTrigger_DataSetUtilities.getCountryClusterGeoList(setClusterIds, setCountryIds);
        System.assertNotEquals(lstBDAGeos, null);
        
        lstGeos = CaseTrigger_DataSetUtilities.getBHCountryCitylist(new set<Id>(), setCountryIds);
        System.assertNotEquals(lstGeos, null);
        
        list<BusinessHours> lstBHs = CaseTrigger_DataSetUtilities.getBHList(new set<String>{'Default', 'MSL India Business Hours', 'MSL United Kingdom Business Hours', 'MSL United States Business Hours'});
        System.assertNotEquals(lstBHs, null);
    }
    
    static testMethod void test_entitlementRelatedMethods() {
        list<Entitlement> lstEntitlements = CaseTrigger_DataSetUtilities.getEntList();
        
        // Create Cases
        CaseData_Test.createExternalCases();
        Case caseIterator = [select Id from Case order by CreatedDate desc limit 1];
        CaseTrigger_DataSetUtilities.getCaseMilestoneList(new set<Id>{caseIterator.Id});
        
        list<Stop_Status__c> lstStopStatuses = CaseTrigger_DataSetUtilities.getstopStatusList();
        
        list<CaseStatus> lstCaseStatuses = CaseTrigger_DataSetUtilities.getCaseStatusList();
        System.assert(lstCaseStatuses.size() > 0);
    }
    
}