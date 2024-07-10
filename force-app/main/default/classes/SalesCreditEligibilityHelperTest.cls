/*              
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11362  15-09-2023    Seba                     Test class for SalesCreditEligibilityHelper. 
* 2.0      SFSE-13491  14-dec-2023     Bharti                 Remove hardcoding of Portfolio owner Responsibility
* */
@isTest
private class SalesCreditEligibilityHelperTest {
    
    
    @testSetup
    static void tesDataSetup(){
        List<User> usersToInsert = new List<User>();
        List<Geography__c> listGeographyToInsert = new list<Geography__c>();
        List<Territory_Account_Association__c> listTAAToInsert = new List<Territory_Account_Association__c>();
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); country.Id = null; listGeographyToInsert.add(country);
        Geography__c country1 = TestBusinessHelper.createGeography('InvalidCountry', 'Country', null,'INVAl',TRUE); country1.Id = null; listGeographyToInsert.add(country1);
        insert listGeographyToInsert;
        System.assertEquals(true, listGeographyToInsert.size() > 0); 
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true); 
        System.assertNotEquals(null, parentBDA.Id); 
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        System.assertNotEquals(null, childBDA.Id);  
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        TriggerExecutionController.skipAccountTrigger(true);
        List<Account> listConcernAccToInsert = new List<Account>();
        List<Account> listAccToInsert = new List<Account>();
        
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='CONCERNCODETEST123';
        concernAccount.SCV_Status__c = 'Active';
        concernAccount.Id=NULL;
        listConcernAccToInsert.add(concernAccount);  
        
        Account concernAccount2 = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount2.Customer_Code__c='CONCERNCODETEST222';
        concernAccount2.SCV_Status__c = 'Active';
        concernAccount2.Id=NULL;
        listConcernAccToInsert.add(concernAccount2);  
        
        Account concernAccount3 = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount3.Customer_Code__c='CONCERNCODETEST333';
        concernAccount3.SCV_Status__c = 'Active';
        concernAccount3.Id=NULL;
        listConcernAccToInsert.add(concernAccount3);   
        
        Account concernAccount4 = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount4.Customer_Code__c='CONCERNCODETEST444';
        concernAccount4.SCV_Status__c = 'Active';
        concernAccount4.Id=NULL;
        listConcernAccToInsert.add(concernAccount4);  
        insert listConcernAccToInsert;
        
        Account representAccount = TestBusinessHelper.createAccount('Client_Account',False);
        representAccount.Customer_Code__c='REPRESENTCODE123'; 
        representAccount.Represents_Concern__c=TRUE;
        representAccount.ParentId=concernAccount.Id;
        representAccount.Country__c = country.Id;
        representAccount.SCV_Status__c = 'Active';
        representAccount.Id=NULL; 
        listAccToInsert.add(representAccount);
        
        Account representAccount2 = TestBusinessHelper.createAccount('Client_Account',False);
        representAccount2.Customer_Code__c='REPRESENTCODE222'; 
        representAccount2.Represents_Concern__c=TRUE;
        representAccount2.ParentId=concernAccount2.Id;
        representAccount2.Country__c = country.Id;
        representAccount2.SCV_Status__c = 'Active';
        representAccount2.Id=NULL; 
        listAccToInsert.add(representAccount2);
        
        Account representAccount3 = TestBusinessHelper.createAccount('Client_Account',False);
        representAccount3.Customer_Code__c='REPRESENTCODE333'; 
        representAccount3.Represents_Concern__c=TRUE;
        representAccount3.ParentId=concernAccount3.Id;
        representAccount3.Country__c = country.Id;
        representAccount3.SCV_Status__c = 'Active';
        representAccount3.Id=NULL; 
        listAccToInsert.add(representAccount3);
        
        Account representAccount4 = TestBusinessHelper.createAccount('Client_Account',False);
        representAccount4.Customer_Code__c='REPRESENTCODE444'; 
        representAccount4.Represents_Concern__c=TRUE;
        representAccount4.ParentId=concernAccount.Id;
        representAccount4.Country__c = country1.Id;
        representAccount4.SCV_Status__c = 'Active';
        representAccount4.Id=NULL; 
        listAccToInsert.add(representAccount4);
        
        Account normalClientAccount = TestBusinessHelper.createAccount('Client_Account',False);
        normalClientAccount.Customer_Code__c='NORMALCLIENTCODE123'; 
        normalClientAccount.Represents_Concern__c= FALSE;
        normalClientAccount.SCV_Status__c = 'Active';
        normalClientAccount.ParentId=concernAccount.Id;
        normalClientAccount.Country__c = country.Id; 
        normalClientAccount.Id=NULL;   
        listAccToInsert.add(normalClientAccount);
        
        Account normalClientAccount2 = TestBusinessHelper.createAccount('Client_Account',False);
        normalClientAccount2.Customer_Code__c='NORMALCLIENTCODE222'; 
        normalClientAccount2.Represents_Concern__c= FALSE;
        normalClientAccount2.SCV_Status__c = 'Active';
        normalClientAccount2.ParentId=concernAccount2.Id;
        normalClientAccount2.Country__c = country.Id; 
        normalClientAccount2.Id=NULL;   
        listAccToInsert.add(normalClientAccount2); 
        
        insert listAccToInsert; 
        
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c br = new Target_Brand_Mapping__c();
        br.RecordtypeId = recordTypeId;
        br.Salesforce_Brand__c=BrandUtilities.MAERSKLINE;
        br.Active__c=True;
        br.BrandMnA__c=BrandUtilities.MAERSKLINE;
        insert br;
        
        TriggerExecutionController.skipUserTrigger(true);  
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.Country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;                        
        }
        System.assertNotEquals(null, adminUser.Id);
        
        System.runAs(adminUser){
            
            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1]?.Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            }
            
            
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
        
        System.runAs(adminUser){
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(ter1, representAccount, TAASettingConstants.POR_Influencer_Only,TAASettingConstants.PR_All , BrandUtilities.MAERSKLINE, FALSE);
        TAA.Start_Date__c = Date.today().addDays(-2);
        TAA.End_Date__c = null;
        TAA.Business_Defined_Area__c = childBDA.Id;//India and Bangladesh Area
        TAA.Id=NULL;
            
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(ter1, normalClientAccount, TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Start_Date__c = Date.today().addDays(-4);
        TAA1.End_Date__c = null;
        TAA1.Id=NULL;
        
        Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(ter2, representAccount2, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA2.Start_Date__c = Date.today().addDays(-4);
        TAA2.End_Date__c = null;
        TAA2.Id=NULL;
        
        Territory_Account_Association__c TAA3 = TestBusinessHelper.createTerritoryAccountAssociation(ter2, normalClientAccount2, TAASettingConstants.POR_Lead_Account_Owner_Only, TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA3.Start_Date__c = Date.today().addDays(-3);
        TAA3.End_Date__c = null;
        TAA3.Id=NULL; 
        
        Territory_Account_Association__c TAA4 = TestBusinessHelper.createTerritoryAccountAssociation(ter1, representAccount3, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA4.Start_Date__c = Date.today().addDays(-2);
        TAA4.End_Date__c = null;
        TAA4.Country__c = country.Id;//India  
        TAA4.Id=NULL;
        
        Territory_Account_Association__c TAA5 = TestBusinessHelper.createTerritoryAccountAssociation(ter1, representAccount4,TAASettingConstants.POR_Influencer_Only,TAASettingConstants.PR_All, BrandUtilities.MAERSKLINE, FALSE);
        TAA5.Start_Date__c = Date.today().addDays(-2);
        TAA5.End_Date__c = null;
        TAA5.Country__c = country.Id;//India 
        TAA5.Id=NULL;
        
        listTAAToInsert.add(TAA);listTAAToInsert.add(TAA1);listTAAToInsert.add(TAA2);listTAAToInsert.add(TAA3); listTAAToInsert.add(TAA4);listTAAToInsert.add(TAA5);
        
        insert listTAAToInsert;
            
        } 
        
         
    }
    
    @isTest
    static void getCreditEligibilityByPartyTypeTest(){
        Test.startTest();
        List<Account> listAccount = [SELECT Id,Customer_Code__c,Country__r.GEO_Code__c  from Account where ParentId!= null];
        Map<String,String> mapExeCountryByCustomerCodeTest = new Map<String,String>{listAccount[0].Customer_Code__c => listAccount[0].Country__r.GEO_Code__c, 
            listAccount[1].Customer_Code__c => listAccount[1].Country__r.GEO_Code__c,
            listAccount[2].Customer_Code__c => listAccount[2].Country__r.GEO_Code__c, 
            listAccount[3].Customer_Code__c => listAccount[3].Country__r.GEO_Code__c,
            listAccount[4].Customer_Code__c => listAccount[4].Country__r.GEO_Code__c,
            listAccount[5].Customer_Code__c => listAccount[5].Country__r.GEO_Code__c
            };
                Map<String, String> mapBrandByCustomerCode = new Map<String, String> {
                        listAccount[0].Customer_Code__c => BrandUtilities.MAERSKLINE,
                        listAccount[1].Customer_Code__c => BrandUtilities.MAERSKLINE,
                        listAccount[2].Customer_Code__c => BrandUtilities.MAERSKLINE,
                        listAccount[3].Customer_Code__c => BrandUtilities.MAERSKLINE,
                        listAccount[4].Customer_Code__c => BrandUtilities.MAERSKLINE,
                        listAccount[5].Customer_Code__c => BrandUtilities.MCC
                        };
        SalesCreditEligibilityHelper.getCreditEligibilityByPartyType(mapExeCountryByCustomerCodeTest, mapBrandByCustomerCode, TargetSettingConstants.PARTY_PO);
        SalesCreditEligibilityHelper.getCreditEligibilityByPartyType(mapExeCountryByCustomerCodeTest, mapBrandByCustomerCode, TargetSettingConstants.PARTY_SHIPPER); 
        Test.stopTest();
    } 
    
}