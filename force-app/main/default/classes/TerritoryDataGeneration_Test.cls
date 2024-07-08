/**
 * Purpose : Test data for Territory (custom object)
 *        
 * Revision Ref Number  Date            Owner                      Description
 * -------- ----------  -----------     -------------------        -----------
 * 1.0     RQ-008577    21/05/2018      meghana.gupta@ust          Code Created.  
 * 2.0     SFSE-4767    15/10/2020      meghana.gupta@ust          Safmarine brand deprecated
 * 3.0     SFSE-5268    04/12/2020      meghana.gupta              Code change for portfolio record type and account association changes
 * 4.0     SFSE-6066    29/092021       Kiran@Maersk               Removing Territory record type references
 * 5.0     SPI-100      08/06/2022      Ronnie@SF                  Removed brand hardcoding
 * 6.0 	   SFSE-10464	02/03/2022		Vazid@ust				   Added code for Geography in TAA.
 * 7.0     SFSE- 13491   14-12-2023     Bharti                     Remove Hardcoding Of product Responsibility/Brands
 */

public class TerritoryDataGeneration_Test {
    
    public static void createTerritoryData(){ 
        
        if (UserDataGeneratorHelper_Test.salesUser == null){            
            UserDataGeneratorHelper_Test.initializeSalesUser();             
        } 
        if (UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){            
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        } 
        
        TriggerExecutionController.skipAllTriggers(true);
        
        List <PermissionSet> lstPS = [SELECT Id FROM PermissionSet WHERE Name = 'APP_Territory_Management_Manage_Portfolios' ];
        // assign manage portfolio permission set to user 
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserDataGeneratorHelper_Test.systemAdminUser.Id;
        psa.PermissionSetId = lstPS[0].Id;  
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
    
            insert psa;           
        }
        TriggerExecutionController.skipAllTriggers(false);
        
        List<Territory__c> lstInsertTerritory = new List<Territory__c>();
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio1',UserDataGeneratorHelper_Test.salesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio2',UserDataGeneratorHelper_Test.MSLsalesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio3',UserDataGeneratorHelper_Test.SeagosalesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio4',UserDataGeneratorHelper_Test.MCCSalesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio5',UserDataGeneratorHelper_Test.MLLSalesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio6',UserDataGeneratorHelper_Test.SCLsalesUser.Id));
        lstInsertTerritory.add(TerritoryDataGeneration_Test.createPortfolio('testPortfolio7',UserDataGeneratorHelper_Test.SEAsalesUser.Id));
        insert(lstInsertTerritory);
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
        Account acc1 = AccountDataHelper_Test.createConcernAccount();
        clientAcc.ParentId = acc1.Id;
        
        TriggerExecutionController.skipAllTriggers(true);
        update clientAcc;
        TriggerExecutionController.skipAllTriggers(false);
        
        Map<String, ID> accountRecordTypeMap = AccountDataHelper_Test.getAccountRecordType ();
        Account acc =new Account();
        acc.Name = 'Test Class Client Account';
        acc.Type = 'BCO' ;
        acc.SCV_Status__c = 'Active';
        acc.RecordTypeId = accountRecordTypeMap.get('Client Account');
        acc.SCV_Code__c = '1234';
        acc.BillingCity = 'London';
        acc.BillingStreet = 'test street 123';
        acc.Attractiveness__c= 'Key Client';
        acc.Represents_Concern__c = True;
        insert acc;
        list<BDA_Geography__c> lstBDAGeographies = BDAGeographyData_Test.lstBDAGeographies;
        List<Territory_Account_Association__c> lstInsert = new List<Territory_Account_Association__c>();
           
		Geography__c countryhum = new Geography__c(Name = 'Humberside', GEO_Code__c = 'hum', GEO_ID__c = '21X0YL367479K', Type_Of_Location__c = 'Country', Active__c = true);
		insert countryhum;
        
        BDA__c clusterBDA = new BDA__c(Name = 'North', GEO_ID__c = '8EUQZ9N6BTHIU', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
		insert clusterBDA;
        
        lstBDAGeographies = new list<BDA_Geography__c>();
        lstBDAGeographies.add(new BDA_Geography__c(BDA__c = BDAGeographyData_Test.clusterUK.Id, Geography__c = countryhum.Id));
		lstBDAGeographies.add(new BDA_Geography__c(BDA__c = clusterBDA.Id, Geography__c = BDAGeographyData_Test.countryUS.Id));
        insert lstBDAGeographies;
        
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, clientAcc.Id, BrandUtilities.SEAGO, TAASettingConstants.POR_SALES_CONTROL,TAASettingConstants.PR_Ocean ));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[1].Id, clientAcc.Id, BrandUtilities.MAERSKLINE,TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.PR_All));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[2].Id, clientAcc.Id, BrandUtilities.SEAGO,TAASettingConstants.POR_SALES_CONTROL,  TAASettingConstants.PR_LnS));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[3].Id, clientAcc.Id, BrandUtilities.MCC,TAASettingConstants.POR_Influencer_Only , TAASettingConstants.PR_All));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[3].Id, clientAcc.Id, BrandUtilities.MCC, TAASettingConstants.POR_Global_Lead_Account_Owner_Only, TAASettingConstants.PR_All));
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, clientAcc.Id, BrandUtilities.MCC, 'Sales Owner - Control Only', 'All'));
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, clientAcc.Id, BrandUtilities.SEALAND, 'Sales Owner - Control Only', 'All'));
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, clientAcc.Id, BrandUtilities.SEAGO, 'Sales Owner - Non-Control Only', 'All'));
        //lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, clientAcc.Id, BrandUtilities.SEALAND, 'Sales Owner - Non-Control Only', 'All'));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio(lstInsertTerritory[4].Id, clientAcc.Id, BrandUtilities.MAERSKLINE, TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[5].Id, clientAcc.Id, BrandUtilities.MAERSKLINE, TAASettingConstants.POR_Global_Lead_Account_Owner_Only , TAASettingConstants.PR_All));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio2(lstInsertTerritory[0].Id, acc.id, BrandUtilities.SEAGO, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio3(lstInsertTerritory[6].Id, clientAcc.Id, BrandUtilities.Sealand, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_Ocean,BDAGeographyData_Test.countryUK.Id));
		lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio3(lstInsertTerritory[6].Id, clientAcc.Id, BrandUtilities.Sealand,TAASettingConstants.POR_Influencer_Only,TAASettingConstants.PR_Ocean,countryhum.Id));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio4(lstInsertTerritory[3].Id, clientAcc.Id, BrandUtilities.MCC, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All,BDAGeographyData_Test.clusterUK.Id));
        lstInsert.add( TerritoryDataGeneration_Test.addAccountToPortfolio3(lstInsertTerritory[2].Id, clientAcc.Id, BrandUtilities.SEAGO, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_Ocean,BDAGeographyData_Test.countryUS.Id));
		lstInsert.add(TerritoryDataGeneration_Test.addAccountToPortfolio3(lstInsertTerritory[2].Id, clientAcc.Id, BrandUtilities.SEAGO, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_LnS,BDAGeographyData_Test.countryUS.Id));

        
        System.runAs(UserDataGeneratorHelper_Test.systemAdminUser) {
             insert lstInsert;
        }
         
        lstInsert = new List<Territory_Account_Association__c>();
        
    }
        
    public static  Territory__c createPortfolio ( String strName, Id idUser) {
        
        Id portfolioRecTypeId =  (ID) Schema.SObjectType.Territory__c.getRecordTypeInfosByName().get('Portfolio').getRecordTypeId();

        Territory__c recTerritory = new Territory__c(
            Name = strName,
            Portfolio_Owner__c = idUser,
            RecordTypeId = portfolioRecTypeId
        ); 
        return recTerritory;
    }
    
    
    public static  Territory_Account_Association__c addAccountToPortfolio ( Id idTerritory, Id idAccount, String strBrand, String responsibility) {
   
        Territory_Account_Association__c rec = new Territory_Account_Association__c(
            Territory__c = idTerritory,
            Account__c = idAccount,
            Portfolio_Owner_Responsibility__c = responsibility,
			Represents_Concern__c = true,            
            Product_Responsibility__c = TAASettingConstants.PR_All,
            brand__c = strBrand
            
        );
        return rec;
    }
    
     public static  Territory_Account_Association__c addAccountToPortfolio2 ( Id idTerritory, Id idAccount, String strBrand, String responsibility, String productResponsibility) {
         BDA__c parentRecBDA = new BDA__c();
         BDA__c recBDA = new BDA__c();   
        if(responsibility == TAASettingConstants.POR_Influencer_Only){
           parentRecBDA = DataGeneratorHelper1_Test.createBDA('Trade Region', null, UserDataGeneratorHelper_Test.integrationuser.id); 
		  recBDA =  DataGeneratorHelper1_Test.createBDA('Cluster', parentRecBDA.id, UserDataGeneratorHelper_Test.integrationuser.id); 
          
            Map<String, String> mapGeo = new Map<String, String> {'United Kingdom'=>'Country', 'India' =>'Country'};
        List<Geography__c> lstGeo = DataGeneratorHelper1_Test.createGeography(mapGeo);
        
        

        Map<Id, Id> mapBDAToGeo = new Map<Id, Id>{recBDA.Id => lstGeo[0].Id};
		List<BDA_Geography__c> lstBDAGeo = DataGeneratorHelper1_Test.createBDAGeography(mapBDAToGeo);
        }
        Territory_Account_Association__c rec = new Territory_Account_Association__c(
            Territory__c = idTerritory,
            Account__c = idAccount,
            Portfolio_Owner_Responsibility__c = responsibility,
            Product_Responsibility__c = productResponsibility,
            Business_Defined_Area__c = (responsibility == TAASettingConstants.POR_Influencer_Only? recBDA.Id : null),
            brand__c = strBrand
        );
        return rec;
    }
     public static  Territory_Account_Association__c addAccountToPortfolio3 ( Id idTerritory, Id idAccount, String strBrand, String responsibility, String productResponsibility, Id geoGraphId) {
        Territory_Account_Association__c rec = new Territory_Account_Association__c(
            Territory__c = idTerritory,
            Account__c = idAccount,
            Portfolio_Owner_Responsibility__c = responsibility,
            Product_Responsibility__c = productResponsibility,
            Country__c = geoGraphId,
            brand__c = strBrand
        );
        return rec;
    }
    public static  Territory_Account_Association__c addAccountToPortfolio4 ( Id idTerritory, Id idAccount, String strBrand, String responsibility, String productResponsibility, Id BDAId) {
        Territory_Account_Association__c rec = new Territory_Account_Association__c(
            Territory__c = idTerritory,
            Account__c = idAccount,
            Portfolio_Owner_Responsibility__c = responsibility,
            Product_Responsibility__c = productResponsibility,
            Business_Defined_Area__c = BDAId,
            brand__c = strBrand
        );
        return rec;
    }
}