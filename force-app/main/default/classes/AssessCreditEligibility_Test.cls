/*              
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11961  18-08-2023    Seba,Bharti and Vinay  Test class for AssessCreditEligibility.
* 2.0      SFSE- 13491 14-12-2023     Bharti                  Remove Hardcoding Of product Responsibility/Brands
* */
@isTest
public class AssessCreditEligibility_Test {
    
    static String adminId;
    
    @testSetup 
    static void dataSetup() {
        
        TriggerExecutionController.skipAccountTrigger(true);
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
        Account concernAccount1 = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount1.Customer_Code__c='TEST55555CONCERNCODE';
        concernAccount1.Id=NULL;
        insert concernAccount1;
        Assert.isNotNull(concernAccount1.Id);
        
        List<Account> childAccounts = new List<Account>();
        Account Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc1.Customer_Code__c='TEST445651';
        Acc1.Represents_Concern__c=TRUE;
        Acc1.ParentId=concernAccount.Id;
        Acc1.Id=NULL;
        childAccounts.add(Acc1);
        
        Account Acc2 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc2.Customer_Code__c='TEST445652';
        Acc2.ParentId=concernAccount.Id;
        Acc2.Id=NULL;
        childAccounts.add(Acc2);
        
        Account Acc3 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc3.Customer_Code__c='TEST445653';
        //Acc3.SCV_Code__c = 'test3';
        Acc3.ParentId=concernAccount.Id;
        Acc3.Id=NULL;
        childAccounts.add(Acc3);
        
        Account Acc4 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc4.Customer_Code__c='TEST445654';
        //Acc3.SCV_Code__c = 'test3';
        //Acc3.ParentId=concernAccount.Id;
        Acc4.Id=NULL;        
        childAccounts.add(Acc4); 
        
        insert childAccounts;   
        
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
        br.Salesforce_Brand__c= BrandUtilities.SEAGO;
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
            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            }
        }
        
        Territory__c ter1 = TestBusinessHelper.createTerritory(usersToInsert[0], TRUE);
        Territory__c ter2 = TestBusinessHelper.createTerritory(usersToInsert[1], TRUE);
        
        Test.stopTest();        
        
        TriggerExecutionController.skipAccountTrigger(false);
        
    }
    
    @istest
    static void allPartyTypesAreSame(){
        // Negative Scenerio -No TAA Records for Accounts
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(2, listBDA.size());
        // PO is Client Account and Represents Concern
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c='TEST445651';
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c='TEST445651';
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stg.Area__c = listBDA[0].Id;
        stagingRecords.add(stg);
        
        // PO is Normal Client Account of Concern
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c='TEST445652';
        stg1.Price_Owner__c='TEST445652';
        stg1.Shipper__c='TEST445652';
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1); 
        
        //PO is Client Account
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682208';
        stg2.Consignee__c='TEST445654';
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c='TEST445654';
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords; 
        
        Test.startTest();
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);                         
        Test.stopTest();
    }
    
    @istest
    static void allPartyTypesAreSame1(){
        // Positive Scenerio - TAA Records Exist for Accounts        
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(2, listBDA.size());
        
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        //PO is Client Account and Represents Concern.
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c='TEST445651';
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c='TEST445651';
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stg.Area__c = listBDA[0].Id;
        stagingRecords.add(stg);
        
        // PO is Normal Client Account of Concern.
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c='TEST445652';
        stg1.Price_Owner__c='TEST445652';
        stg1.Shipper__c='TEST445652';
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1);                
        
        // PO is Client Account.
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682207';
        stg2.Consignee__c='TEST445654';
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c='TEST445654';
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords; 
        
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        List<Account> listAccounts = [SELECT Id,Represents_Concern__c,Customer_Code__c,ParentId FROM Account WHERE RecordTypeId=:clientRecordTypeId];
        Assert.areEqual(4, listAccounts.size());
        
        Account concernAccount, clientAcc;
        List<Account> listNormalAccounts = new List<Account>();
        
        for(Account Acc: listAccounts){
            if(Acc.Represents_Concern__c){
                concernAccount = Acc; 
            } 
            if(!Acc.Represents_Concern__c  && Acc.ParentId!=NULL){
                listNormalAccounts.add(Acc);
            }
            if(Acc.ParentId==NULL){
                clientAcc = Acc;   
            }
        }
        Assert.areEqual(2, listNormalAccounts.size());
        Assert.isNotNull(clientAcc);
        Assert.isNotNull(concernAccount);
        
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritories.size());
        
        
        List<Territory_Account_Association__c> listTAAs = new List<Territory_Account_Association__c>();
        
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernAccount, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA.Id=NULL;
        TAA.Business_Defined_Area__c = listBDA[0].Id;
        TAA.Start_Date__c = Date.Today();
        //insert TAA;
        listTAAs.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], concernAccount, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA1.Id=NULL;
        TAA1.Start_Date__c = Date.Today();
        listTAAs.add(TAA1);
        
        Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[0], TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA2.Id=NULL;
        TAA2.Start_Date__c = Date.Today();
        listTAAs.add(TAA2);
        
        Territory_Account_Association__c TAA3 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], listNormalAccounts[0], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA3.Id=NULL;
        TAA3.Start_Date__c = Date.Today();
        listTAAs.add(TAA3);
        
        Territory_Account_Association__c TAA4 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], clientAcc, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA4.Id=NULL;
        TAA4.Start_Date__c = Date.Today();
        listTAAs.add(TAA4);
        
        Territory_Account_Association__c TAA5 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA5.Id=NULL;
        TAA5.Start_Date__c = Date.Today();
        listTAAs.add(TAA5);
        
        //System.runAs(new User(Id = adminId)){         
          //  insert listTAAs;
        //}
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        system.runAs(sysAdminUsr){
            insert listTAAs;
        }
        
        Test.startTest();   
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);
        
        Test.stopTest();
    }
    
    @istest
    static void poAndShipperSame(){
        // Negative Scenerio -No TAA Records for Accounts
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(2, listBDA.size());
        
        // PO is Client Account and Represents Concern.
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c='TEST445652';
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c='TEST445651';
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stg.Area__c = listBDA[0].Id;
        stagingRecords.add(stg);
        
        //PO is Normal Client Account of Concern.
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c='TEST445651';
        stg1.Price_Owner__c='TEST445652';
        stg1.Shipper__c='TEST445652';
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1); 
        
        // PO is Client Account
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682208';
        stg2.Consignee__c='TEST445654';
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c='TEST445653';
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        //stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords; 
        
        Test.startTest();
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);                         
        Test.stopTest();
    }  
    
    @istest
    static void poAndShipperSame1(){
        // +ve Scenerio -TAA Record Exists for Accounts
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(2, listBDA.size());
        
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        List<Account> listAccounts = [SELECT Id,Represents_Concern__c,Customer_Code__c,ParentId FROM Account WHERE RecordTypeId=:clientRecordTypeId];
        Assert.areEqual(4, listAccounts.size());
        
        Account concernAccount, clientAcc;
        List<Account> listNormalAccounts = new List<Account>();
        
        for(Account Acc: listAccounts){
            if(Acc.Represents_Concern__c){
                concernAccount = Acc; 
            } 
            if(!Acc.Represents_Concern__c  && Acc.ParentId!=NULL){
                listNormalAccounts.add(Acc);
            }
            if(Acc.ParentId==NULL){
                clientAcc = Acc;   
            }
        }
        Assert.areEqual(2, listNormalAccounts.size());
        Assert.isNotNull(clientAcc);
        Assert.isNotNull(concernAccount);
        
        // PO is Client Account AND Represents Concern.
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c='TEST445651';
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stg.Area__c = listBDA[0].Id;
        stagingRecords.add(stg);
        
        // Po is Normal Client of Concern.
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg1.Price_Owner__c=listNormalAccounts[1].Customer_Code__c;
        stg1.Shipper__c=listNormalAccounts[1].Customer_Code__c;
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1); 
        
        //PO is Client Account.
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682208';
        stg2.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c='TEST445654';
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        //stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords; 
        
        
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritories.size());
        
        List<Territory_Account_Association__c> listTAAs = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernAccount, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA.Id=NULL;
        TAA.Business_Defined_Area__c = listBDA[0].Id;
        TAA.Start_Date__c = Date.Today();
        //insert TAA;
        listTAAs.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], concernAccount, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA1.Id=NULL;
        TAA1.Start_Date__c = Date.Today();
        listTAAs.add(TAA1);
        
        Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[1], TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA2.Id=NULL;
        TAA2.Start_Date__c = Date.Today();
        listTAAs.add(TAA2);
        
        Territory_Account_Association__c TAA2A = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], listNormalAccounts[1], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA2A.Id=NULL;
        TAA2A.Start_Date__c = Date.Today();
        listTAAs.add(TAA2A);
        
        Territory_Account_Association__c TAA3 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], listNormalAccounts[0], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA3.Id=NULL;
        TAA3.Start_Date__c = Date.Today();
        listTAAs.add(TAA3);
        
        Territory_Account_Association__c TAA4 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], clientAcc, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA4.Id=NULL;
        TAA4.Start_Date__c = Date.Today();
        listTAAs.add(TAA4);
        
        Territory_Account_Association__c TAA5 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        TAA5.Id=NULL;
        TAA5.Start_Date__c = Date.Today();
        listTAAs.add(TAA5);
        
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        
        System.runAs(sysAdminUsr){          
            insert listTAAs;
        }                           
        
        Test.startTest();
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);                         
        Test.stopTest();
    }
    
    
    
    @istest
    static void allPartyDifferentPositiveScenarios(){ 
        
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>(); 
        List<Territory_Account_Association__c> listTAAsToInsert = new List<Territory_Account_Association__c>();  
        Territory_Account_Association__c taaRec1,taaRec2,taaRec3,taaRec4,taaRec5,taaRec6,taaRec7; 
        Account concernRepresentAccount, clientAcc;
        List<Account> listNormalAccounts = new List<Account>();
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(listBDA.size()>0, true);  
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        List<Account> listAccounts = [SELECT Id,Represents_Concern__c,Customer_Code__c,ParentId FROM Account WHERE RecordTypeId=:clientRecordTypeId];
        Assert.areEqual(listAccounts.size()>0, true); 
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        Assert.areEqual(listTerritories.size()>0, true);
        
        for(Account Acc: listAccounts){
            if(Acc.Represents_Concern__c){
                concernRepresentAccount = Acc;  
            } 
            if(!Acc.Represents_Concern__c  && Acc.ParentId!=NULL){
                listNormalAccounts.add(Acc); 
            }
            if(Acc.ParentId==NULL){
                clientAcc = Acc;  
            }  
        }
        Assert.areEqual(listNormalAccounts.size()>0, true);  
        
        //PO as NCC , Shipper as RC, Consignee as Client
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();  
        stg.Price_Owner__c= listNormalAccounts[1].customer_Code__c;
        stg.Shipper__c= concernRepresentAccount.customer_Code__c;
        stg.Consignee__c= clientAcc.customer_Code__c; 
        stg.Country_Code__c ='IN';
        stg.Area__c = listBDA[0].Id;
        stg.Product_Family__c ='SCM PF';  
        stg.Year__c= String.valueOf(Date.Today().Year());
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stagingRecords.add(stg);
        
        //PO as RC , Shipper as Client, Consignee as NCC
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();  
        //RC with 2 TAAs - SO & Influencer with a non-matching country
        stg1.Price_Owner__c = concernRepresentAccount.customer_Code__c;
        stg1.Shipper__c = clientAcc.customer_Code__c;
        stg1.Consignee__c = listNormalAccounts[1].customer_Code__c; 
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF'; 
        stg1.Year__c= String.valueOf(Date.Today().Year());
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1);
        
        //PO as Client , Shipper as NCC, Consignee as RC
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();  
        stg2.Price_Owner__c = clientAcc.customer_Code__c;
        stg2.Shipper__c = listNormalAccounts[1].customer_Code__c;
        stg2.Consignee__c = concernRepresentAccount.customer_Code__c;
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF'; 
        stg2.Year__c= String.valueOf(Date.Today().Year());
        //stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2); 
        
        //PO as NCC , Shipper as RC, Consignee as Client
        Target_Setting_Staging__c stg3 = new Target_Setting_Staging__c();  
        stg3.Price_Owner__c= listNormalAccounts[0].customer_Code__c;
        stg3.Shipper__c= concernRepresentAccount.customer_Code__c;
        stg3.Consignee__c= clientAcc.customer_Code__c; 
        stg3.Country_Code__c ='IN';
        stg3.Area__c = listBDA[0].Id;
        stg3.Product_Family__c ='SCM PF';  
        stg3.Year__c= String.valueOf(Date.Today().Year());
        //stg3.Brand__c= BrandUtilities.SEAGO;
        stg3.Brand__c= 'Sealand Europe';
        stg3.Measure_Dimension__c='Previous Year Actuals';
        stg3.Measure_Type__c='Volume';
        stagingRecords.add(stg3); 
        
        insert stagingRecords;  
        
        Test.startTest();
        
        
        Geography__c geoTest = [SELECT Id, GEO_Code__c FROM Geography__c WHERE GEO_Code__c = 'AUS'];//listTAAsToInsert
        taaRec1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[1], TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[0], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE); 
        taaRec3 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec4 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc, TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec5 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], concernRepresentAccount, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec6 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernRepresentAccount, TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec7 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernRepresentAccount, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
        taaRec7.Country__c = geoTest.Id;    
        taaRec1.Id = NULL; taaRec2.Id = NULL; taaRec3.Id = NULL; taaRec4.Id = NULL; taaRec5.Id = NULL; taaRec6.Id = NULL; taaRec7.Id=NULL;
        taaRec1.Start_Date__c = Date.Today(); taaRec2.Start_Date__c = Date.Today(); taaRec3.Start_Date__c = Date.Today(); taaRec4.Start_Date__c = Date.Today(); taaRec5.Start_Date__c = Date.Today(); taaRec6.Start_Date__c = Date.Today(); taaRec7.Start_Date__c = Date.Today();
        listTAAsToInsert.add(taaRec1);listTAAsToInsert.add(taaRec2);listTAAsToInsert.add(taaRec3);listTAAsToInsert.add(taaRec4);
        listTAAsToInsert.add(taaRec5);listTAAsToInsert.add(taaRec6); listTAAsToInsert.add(taaRec7); 
        
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        
        System.runAs(sysAdminUsr){          
            insert listTAAsToInsert;
        }
        
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords); 
        Test.stopTest();
    } 
    
    @istest
    static void allPartyDifferentNegativeScenarios(){ 
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>(); 
        List<Account> listNormalAccounts = new List<Account>(); 
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c(); 
        Account concernRepresentAccount, clientAcc;
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE]; 
        Assert.areEqual(listBDA.size() > 0 , true);  
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        List<Account> listAccounts = [SELECT Id,Represents_Concern__c,Customer_Code__c,ParentId FROM Account WHERE RecordTypeId=:clientRecordTypeId];
        Assert.areEqual(listAccounts.size() > 0, true); 
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        Assert.areEqual(listTerritories.size()>0, true);
        
        for(Account Acc: listAccounts){
            if(Acc.Represents_Concern__c){
                concernRepresentAccount = Acc;  
            } 
            if(!Acc.Represents_Concern__c  && Acc.ParentId!=NULL){
                listNormalAccounts.add(Acc); 
            }
            if(Acc.ParentId==NULL){
                clientAcc = Acc;  
            }  
        }
        Assert.areEqual(listNormalAccounts.size() > 0 , true);
        
        
        stg.Consignee__c= clientAcc.customer_Code__c;
        stg.Price_Owner__c= listNormalAccounts[1].customer_Code__c;
        stg.Shipper__c= concernRepresentAccount.customer_Code__c; 
        stg.Country_Code__c ='IN';
        stg.Area__c = listBDA[0].Id;
        stg.Product_Family__c ='SCM PF';  
        stg.Year__c= String.valueOf(Date.Today().Year());
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stagingRecords.add(stg);
        
        //PO as Represent client account of concern
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c(); 
        stg1.Consignee__c = clientAcc.customer_Code__c;
        //PO with a non matching BDA
        stg1.Price_Owner__c = concernRepresentAccount.customer_Code__c;
        stg1.Shipper__c = listNormalAccounts[1].customer_Code__c;
        stg1.Area__c = listBDA[1].Id;
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF'; 
        stg1.Year__c= String.valueOf(Date.Today().Year());
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1); 
        
        //PO as client account without concern
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c(); 
        stg2.Consignee__c = concernRepresentAccount.customer_Code__c;
        stg2.Price_Owner__c = clientAcc.customer_Code__c;
        stg2.Shipper__c = listNormalAccounts[0].customer_Code__c;
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF'; 
        stg2.Year__c= String.valueOf(Date.Today().Year());
        //stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2); 
        
        //PO as client account without concern
        Target_Setting_Staging__c stg3 = new Target_Setting_Staging__c(); 
        stg3.Consignee__c = 'INVALIDCONSIGNEE';
        stg3.Price_Owner__c = 'INVALIDPO';
        stg3.Shipper__c = 'INVALIDSHIPPER';
        stg3.Country_Code__c ='IN';
        stg3.Product_Family__c ='SCM PF'; 
        stg3.Year__c= String.valueOf(Date.Today().Year());
        //stg3.Brand__c= BrandUtilities.SEAGO;
        stg3.Brand__c= 'Sealand Europe';
        stg3.Measure_Dimension__c='Previous Year Actuals';
        stg3.Measure_Type__c='Volume';
        stagingRecords.add(stg3); 
        
        insert stagingRecords;  
        
        Test.startTest();  
        
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        List<Territory_Account_Association__c> listTAAs = new List<Territory_Account_Association__c>();
        System.runAs(sysAdminUsr){    
            Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[1], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA1.Id=NULL;
            TAA1.Start_Date__c = Date.Today();
            listTAAs.add(TAA1);
            
            Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[0],  TAASettingConstants.POR_Global_Lead_Account_Owner_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA2.Id=NULL;
            TAA2.Start_Date__c = Date.Today();
            listTAAs.add(TAA2);
            
            Territory_Account_Association__c TAA3 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc,  TAASettingConstants.POR_Global_Lead_Account_Owner_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA3.Id=NULL;
            TAA3.Start_Date__c = Date.Today();
            listTAAs.add(TAA3);
            
            Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernRepresentAccount, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA.Id=NULL;
            TAA.Business_Defined_Area__c = listBDA[0].Id;
            TAA.Start_Date__c = Date.Today();
            listTAAs.add(TAA);
            
            insert listTAAs;
        }
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);
        
        Test.stopTest();
    } 
    
    @istest
    static void onlyConsigneeAndShipperAreSame(){
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Assert.areEqual(2, listBDA.size());
        // PO is Client Account and Represents Concern.
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c='TEST445652';
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c='TEST445652';
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        stg.Area__c = listBDA[0].Id;
        stagingRecords.add(stg);
        
        //PO is Normal Client Account of Concern
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c='TEST445653';
        stg1.Price_Owner__c='TEST445652';
        stg1.Shipper__c='TEST445653';
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stagingRecords.add(stg1);
        
        // PO is Client Account
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682208';
        stg2.Consignee__c='TEST445653';
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c='TEST445653';
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        //stg2.Brand__c= BrandUtilities.SEAGO;\
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords; 
        
        Test.startTest();
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);                         
        Test.stopTest();
        
        
    }
    
    @istest
    static void onlyConsigneeAndShipperAreSame1(){
        List<Target_Setting_Staging__c> stagingRecords = new List<Target_Setting_Staging__c>();
        
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE AND Name ='India and Bangladesh Area'];
        Assert.areEqual(1, listBDA.size());
        
        Id clientRecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        List<Account> listAccounts = [SELECT Id,Represents_Concern__c,Customer_Code__c,ParentId FROM Account WHERE RecordTypeId=:clientRecordTypeId];
        Assert.areEqual(4, listAccounts.size());
        
        Account concernAccount, clientAcc;
        List<Account> listNormalAccounts = new List<Account>();
        
        for(Account Acc: listAccounts){
            if(Acc.Represents_Concern__c){
                concernAccount = Acc; 
            } 
            if(!Acc.Represents_Concern__c  && Acc.ParentId!=NULL){
                listNormalAccounts.add(Acc);
            }
            if(Acc.ParentId==NULL){
                clientAcc = Acc;   
            }
        }
        Assert.areEqual(2, listNormalAccounts.size());
        Assert.isNotNull(clientAcc);
        Assert.isNotNull(concernAccount);
        
        Geography__c geoTest = [SELECT Id, GEO_Code__c FROM Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        system.debug(geoTest+'geoTest------->');
        Assert.isNotNull(geoTest);
        
        // PO is Client Account and Represents Concern.
        Target_Setting_Staging__c stg = new Target_Setting_Staging__c();
        stg.Correlation_Id__c='1692682206';
        stg.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg.Price_Owner__c='TEST445651';
        stg.Shipper__c=listNormalAccounts[0].Customer_Code__c;
        stg.Year__c= String.valueOf(Date.Today().Year());
        stg.Country_Code__c ='IN';
        stg.Product_Family__c ='SCM PF';
        //stg.Brand__c= BrandUtilities.SEAGO;
        stg.Brand__c= 'Sealand Europe';
        stg.Measure_Dimension__c='Previous Year Actuals';
        stg.Measure_Type__c='Volume';
        //stg.Area__c = listBDA[0].Id;
        stg.Country__c = geoTest.Id;
        stagingRecords.add(stg);
        
        //PO is Normal Client Account of Concern
        Target_Setting_Staging__c stg1 = new Target_Setting_Staging__c();
        stg1.Correlation_Id__c='1692682207';
        stg1.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg1.Price_Owner__c=listNormalAccounts[1].Customer_Code__c;
        stg1.Shipper__c=listNormalAccounts[0].Customer_Code__c;
        stg1.Year__c= String.valueOf(Date.Today().Year());
        stg1.Country_Code__c ='IN';
        stg1.Product_Family__c ='SCM PF';
        //stg1.Brand__c= BrandUtilities.SEAGO;
        stg1.Brand__c= 'Sealand Europe';
        stg1.Measure_Dimension__c='Previous Year Actuals';
        stg1.Measure_Type__c='Volume';
        stg1.Country__c = geoTest.Id;
        stagingRecords.add(stg1);
        
        // PO is Client Account
        Target_Setting_Staging__c stg2 = new Target_Setting_Staging__c();
        stg2.Correlation_Id__c='1692682208';
        stg2.Consignee__c=listNormalAccounts[0].Customer_Code__c;
        stg2.Price_Owner__c='TEST445654';
        stg2.Shipper__c=listNormalAccounts[0].Customer_Code__c;
        stg2.Year__c= String.valueOf(Date.Today().Year());
        stg2.Country_Code__c ='IN';
        stg2.Product_Family__c ='SCM PF';
        //stg2.Brand__c= BrandUtilities.SEAGO;
        stg2.Brand__c= 'Sealand Europe';
        stg2.Measure_Dimension__c='Previous Year Actuals';
        stg2.Measure_Type__c='Volume';
        stagingRecords.add(stg2);                
        
        insert stagingRecords;         
        
        List<Territory__c> listTerritories = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritories.size());
                
        List<Territory_Account_Association__c> listTAAs = new List<Territory_Account_Association__c>();
        
        User sysAdminUsr = [SELECT Id FROM User WHERE EMail =:'systemadministratormaerskline@maersk.com' LIMIT 1];
        Assert.isNotNull(sysAdminUsr);
        
        
        System.runAs(sysAdminUsr){    
            Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], concernAccount, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA.Id=NULL;
            TAA.Business_Defined_Area__c = listBDA[0].Id;
            TAA.Start_Date__c = Date.Today();
            //insert TAA;
            listTAAs.add(TAA);
            
            Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], concernAccount, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA1.Id=NULL;
            TAA1.Start_Date__c = Date.Today();
            listTAAs.add(TAA1);
            
            Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], listNormalAccounts[1],TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA2.Id=NULL;
            TAA2.Start_Date__c = Date.Today();
            listTAAs.add(TAA2);
            
            Territory_Account_Association__c TAA2A = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], listNormalAccounts[1], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA2A.Id=NULL;
            TAA2A.Start_Date__c = Date.Today();
            listTAAs.add(TAA2A);
            
            Territory_Account_Association__c TAA3 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], listNormalAccounts[0],TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA3.Id=NULL;
            TAA3.Start_Date__c = Date.Today();
            listTAAs.add(TAA3);
            
            Territory_Account_Association__c TAA4 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[0], clientAcc, TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA4.Id=NULL;
            TAA4.Start_Date__c = Date.Today();
            listTAAs.add(TAA4);
            
            Territory_Account_Association__c TAA5 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritories[1], clientAcc, TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA5.Id=NULL;
            TAA5.Start_Date__c = Date.Today();
            listTAAs.add(TAA5);
            
            
            
            insert listTAAs;
        }
        Test.startTest();
        
        AssessCreditEligibility cr = new AssessCreditEligibility();
        cr.determineAccountEligibility(stagingRecords);                         
        Test.stopTest();
        
        
    }
    
}