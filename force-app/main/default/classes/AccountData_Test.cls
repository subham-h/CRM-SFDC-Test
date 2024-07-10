/**
 * Author   : Ragu
 * Purpose  : Utility test class for creating Account related test data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Ragu@UST                Created.
 * 2.0      RQ-001837   12-Jun-2016 Nisha@UST               Added logic to bypass account duplicate rule
 * 3.0      RQ-004653   28-Feb-2017 Hitha@UST               Removed references to Account.City_Name__C
 * 4.0      RQ-005677   25-Sep-2017 Uvais.K@UST             Removed references to deprecated field Account.Cluster_Name__c
 * 5.0      RQ-007847   12-Feb-2018 Nisha@Ust               Created vendor non shipping party account
 * 6.0      RQ-012362   12-Nov-2019 manjunath@maersk        Removed missed references of Account.City_Name__c
 * 7.0      SPI-100     13-Jun-2022 Ronnie@SF               Removed brand hardcoding
 */

@isTest
public class  AccountData_Test{
    
    public static boolean bCreate = true;
    public static integer iNumberOfAccounts = 5;
    public static list<Account> lstAccounts;
    
    public static testMethod void createDraftAccounts() {
        // RQ-001837 To bypass the account duplicate rule on Draft Accounts.
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        
        populateCommonAccountFields();
        Id draftRTId = StaticFactory.getRecordTypeIdByName('Account', 'Draft Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Draft ' + accIterator.Name;
            accIterator.RecordTypeId = draftRTId;
        }
        if(bCreate) {
            Database.insert(lstAccounts, dml);
        }
    }
    
    public static testMethod void createClientAccounts() {
        populateCommonAccountFields();
        Id clientRTId = StaticFactory.getRecordTypeIdByName('Account', 'Client Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Client ' + accIterator.Name;
            accIterator.RecordTypeId = clientRTId;
        }
        if(bCreate) {
            insert lstAccounts;
        }
    }
    
    
    public static testMethod void createCompetitorAccounts() {
        populateCommonAccountFields();
        Id competitorRTId = StaticFactory.getRecordTypeIdByName('Account', 'Competitor Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Competitor ' + accIterator.Name;
            accIterator.RecordTypeId = competitorRTId;
            accIterator.Country__c = BDAGeographyData_Test.countryUS.Id;
            accIterator.BillingCity = BDAGeographyData_Test.citySterling.Name;
            accIterator.BillingPostalcode = '560066';
            accIterator.BillingStreet = 'WER';
        }
        if(bCreate) {
            insert lstAccounts;
        }
    }
    
    public static testMethod void createConcernAccounts() {
        populateCommonAccountFields();
        Id concernRTId = StaticFactory.getRecordTypeIdByName('Account', 'Concern Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Concern ' + accIterator.Name;
            accIterator.RecordTypeId = concernRTId;
        }
        if(bCreate) {
            insert lstAccounts;
        }
    }
    
    public static testMethod void createNonShippingPartyAccounts() {
        // RQ-001837 To bypass the account duplicate rule on Non Shipping Accounts.
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        
        populateCommonAccountFields();
        Id nonShippingRTId = StaticFactory.getRecordTypeIdByName('Account', 'Non-shipping Party Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Non-shipping Party ' + accIterator.Name;
            accIterator.RecordTypeId = nonShippingRTId;
        }
        if(bCreate) {
            Database.insert(lstAccounts, dml);
        }
    }
    
    // v5.0 : #RQ-007439 (Created the Non shipping Party Vendor Account)
    public static testMethod void createVendorNonShippingPartyAccounts() {  
        Integer incrementVendorCode = 0;
        
        // To avoid mixed dml  
        User usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        PermissionSet permissionst = [SELECT Id From PermissionSet WHERE Name = 'Edit_Vendor'];
        list<PermissionSetAssignment> lstPermissionSetAssignee = [SELECT AssigneeId  FROM PermissionSetAssignment WHERE PermissionSetId =: permissionst.Id AND AssigneeId =: usr.id];        
        
        System.runAs(usr) {
            // Assign the Edit Vendor permission set to user
            if(lstPermissionSetAssignee.isEmpty()) {
                insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = permissionst.Id );
            }
        }       
        populateCommonAccountFields();
        Id nonShippingRTId = StaticFactory.getRecordTypeIdByName('Account', 'Non-shipping Party Account');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Non-shipping Party ' + accIterator.Name;
            accIterator.RecordTypeId = nonShippingRTId;
            accIterator.Vendor_Code__c = 'SMDS0'+ ++incrementVendorCode;
            accIterator.Vendor_Type__c = 'Depot';
        }
        System.runAs(usr) {
            if(bCreate) {
                insert lstAccounts;
            }
        }
    }
    
    public static testMethod void createUnassignedAccounts() {
        populateCommonAccountFields();
        Id unassignedRTId = StaticFactory.getRecordTypeIdByName('Account', 'Unassigned');
        for(Account accIterator : lstAccounts) {
            accIterator.Name = 'Unassigned ' + accIterator.Name;
            accIterator.RecordTypeId = unassignedRTId;
        }
        if(bCreate) {
            insert lstAccounts;
        }
    }
    
    public static testMethod void populateCommonAccountFields() {
        lstAccounts = new list<Account>();
        for(integer i=0; i<iNumberOfAccounts; i++) {
            Account accIterator = new Account();
            accIterator.Name = 'Test Account_' + Math.round(Math.random()*1000);
            accIterator.Country__c = BDAGeographyData_Test.countryUS.Id;
            //accIterator.City_Name__c = BDAGeographyData_Test.citySterling.Id;
            accIterator.BillingCity = BDAGeographyData_Test.citySterling.Name;
            //accIterator.Cluster_Name__c = BDAGeographyData_Test.clusterNA.Id;
            
            lstAccounts.add(accIterator);
        }
    }
    
    public static testMethod void createCareRelationship() {
        if(lstAccounts != null && !lstAccounts.isEmpty()) {
            list<Care_Relationship__c> lstCareRelationships = new list<Care_Relationship__c>();
            for(Account accIterator : lstAccounts) {
                Care_Relationship__c maerskLineCR = new Care_Relationship__c();
                maerskLineCR.Account__c = accIterator.Id;
                maerskLineCR.Direction__c = 'Import/Export';
                maerskLineCR.Status__c = 'Active';
                maerskLineCR.Service_Level__c = 'CARE';
                maerskLineCR.Liner_Brand__c = BrandUtilities.MAERSKLINE;
                maerskLineCR.Country__c = accIterator.Country__c;
                //maerskLineCR.Cluster__c = accIterator.Cluster_Name__c;
                lstCareRelationships.add(maerskLineCR);
                
                Care_Relationship__c safemarineCR = new Care_Relationship__c();
                safemarineCR.Account__c = accIterator.Id;
                safemarineCR.Direction__c = 'Import/Export';
                safemarineCR.Status__c = 'Active';
                safemarineCR.Service_Level__c = 'CARE';
                //safemarineCR.Liner_Brand__c = BrandUtilities.SAFMARINE;
                safemarineCR.Country__c = accIterator.Country__c;
                //safemarineCR.Cluster__c = accIterator.Cluster_Name__c;
                lstCareRelationships.add(safemarineCR);
            }
            insert lstCareRelationships;
        }
    }
    
    public static testMethod void createEntitlements() {
        if(lstAccounts != null && !lstAccounts.isEmpty()) {
            Id slaProcessId = Id.valueOf(Label.TestClean_SLAProcessID);
            Date dtStart = System.today();
            Date dtEnd = System.today() + 30;
            list<Entitlement> lstEntitlements = new list<Entitlement>();
            for(Account accIterator : lstAccounts) {
                lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = 'Default', SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
                lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = BrandUtilities.MAERSKLINE, SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
                lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = BrandUtilities.USFLAG, SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
                lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = BrandUtilities.SEALAND, SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
                //lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = BrandUtilities.SAFMARINE, SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
                lstEntitlements.add(new Entitlement(Name = 'Test Entitlement', AccountId = accIterator.Id, Liner_Brand_Logic__c = BrandUtilities.MCC, SlaProcessId = slaProcessId, StartDate = dtStart, EndDate = dtEnd));
            }
            Database.insert(lstEntitlements);
        }
    }
    
}