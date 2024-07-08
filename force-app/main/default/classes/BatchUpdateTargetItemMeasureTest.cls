/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      SFSE-11477  08-Nov-2023      Vinay                                  Code created
 * 2.0      SFSE-13491  14-dec-2023     Bharti                                  Remove hardcoding of Portfolio owner Responsibility/Brands/Target Setting
 * 
*/
@isTest
public class BatchUpdateTargetItemMeasureTest {
 
    @testSetup 
    static void dataSetup() {
                
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
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
        Acc3.ParentId=concernAccount.Id;
        Acc3.Id=NULL;
        childAccounts.add(Acc3);
        
        Account Acc4 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc4.Customer_Code__c='TEST445654';
        Acc4.Id=NULL;        
        childAccounts.add(Acc4); 
        
        insert childAccounts;   
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE);         
        Geography__c country1 = TestBusinessHelper.createGeography('Australia', 'Country', null,'AUS',TRUE);
        
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        Assert.isNotNull(parentBDA.Id);
        
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA.Id);
        
        BDA__c childBDA1 = TestBusinessHelper.createBDA('Saudi Arabia Area', 'Cluster', 'SAA', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA1.Id);
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        BDA_Geography__c bdaGeo1 = TestBusinessHelper.createBDAGeography(childBDA.Id, country1.Id, null, true);
        
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c br = new Target_Brand_Mapping__c();
        br.RecordtypeId = recordTypeId;
        br.Salesforce_Brand__c= BrandUtilities.SEAGO;
        br.Active__c=True;
        br.BrandMnA__c='Sealand Europe';
        insert br;
        List<User> usersToInsert = new List<User>();
        
     System.runAs(new User(Id = UserInfo.getUserId())){        
            User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, FALSE);
            salesUser.Id = null;
            salesUser.IsActive=true;
            salesUser.country = 'India';
            salesUser.Cluster__c = 'GSC';
            salesUser.Industry_Focus__c='Retail';
            salesUser.Segment_Focus__c='Advancement';
            salesUser.Sales_Job_Function__c='Other';
            salesUser.FederationIdentifier = 'QWERTY65';
            usersToInsert.add(salesUser);
            
            User salesUser2 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, true);
            salesUser2.Id = null;
            salesUser2.IsActive=true;
            salesUser2.country = 'India';
            salesUser2.Cluster__c = 'GSC';
            salesUser2.Industry_Focus__c='Retail';
            salesUser2.Segment_Focus__c='Advancement';
            salesUser2.Sales_Job_Function__c='Sales Manager';
            salesUser2.FederationIdentifier = 'QWERTY615';
            salesUser2.UserName = 'a'+salesUser2.UserName;
            salesUser2.CommunityNickname = 'a'+salesUser2.CommunityNickname;
            salesUser2.Maersk_User_Id__c = 'a'+salesUser2.Maersk_User_Id__c;
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
         
        List<Target__c> targets = TestBusinessHelper.createSalesTargets(usersToInsert[0],new List<String>{'2070','2071'}, new List<String>{'USD','USD'}, new List<String>{'Monthly','Monthly'}, 2,TRUE);
        
        Target_Item_Group__c tg = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Sealand Europe', country, bdaGeo, '4PL PF',TRUE);
        Target_Item_Group__c tg1 = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Sealand Europe', country1, bdaGeo1, '4PL PF',TRUE);
        Target_Item_Group__c tg2 = TestBusinessHelper.createSalesTargetItemGroup(targets[1], 'Sealand Europe', country, bdaGeo, '4PL PF',TRUE);
        Target_Item_Group__c tg3 = TestBusinessHelper.createSalesTargetItemGroup(targets[1], 'Sealand Europe', country1, bdaGeo1, '4PL PF',TRUE);
    }
    
    @isTest
    static void testMethod1(){
        // Client Account with Measure as Shipper
        List<Target__c> target =[SELECT Id FROM Target__c WHERE Applicable_Year__c='2070'];        
        Assert.areEqual(1, target.size());
            
        List<Target_Item_Group__c> listTargetGrps = [SELECT Id FROM Target_Item_Group__c WHERE Target__c=:target[0].Id];
        Assert.areEqual(2, listTargetGrps.size());
        
        List<Account> clientAcc = [SELECT Id FROM Account WHERE Customer_Code__c='TEST445654'];
        Assert.areEqual(1, clientAcc.size());
        
        List<Target_Item__c> items = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, clientAcc[0], 2,TRUE);
        Assert.areEqual(2, items.size());
        
        List<Target_Measure__c> measures = TestBusinessHelper.createSalesTargetItemMeasures(items,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, measures.size());
        
        List<Territory__c> listTerritory = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritory.size());
      
        system.runAs(new User(Id = UserInfo.getUserId())){
                
                Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
                List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
                if(ps.isEmpty()){
                    insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
                }
            Test.startTest();           
                Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[0], clientAcc[0], TAASettingConstants.POR_SALES_NON_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, TRUE);
                BatchUpdateTargetItemMeasure tm = new BatchUpdateTargetItemMeasure();
                Database.executeBatch(tm);
            Test.stopTest();
        }
    }
    @istest
    static void testMethod2(){
        //Test Method for creating TAA for Represents Concern Account.
        Account representsConcern;
        List<Account> lstAccounts = new List<Account>();
        for(Account acc:[SELECT Id,Represents_Concern__c,Customer_Code__c FROM Account WHERE ParentId!=NULL]){
            if(acc.Represents_Concern__c){
               representsConcern = acc; 
            }
            else{
               lstAccounts.add(acc); 
            }
        }
        Assert.isNotNull(representsConcern.Id);
        Assert.areEqual(2, lstAccounts.size());
        
        List<Target__c> target =[SELECT Id FROM Target__c WHERE Applicable_Year__c='2070'];        
        Assert.areEqual(1, target.size());
            
        List<Target_Item_Group__c> listTargetGrps = [SELECT Id FROM Target_Item_Group__c WHERE Target__c=:target[0].Id];
        Assert.areEqual(2, listTargetGrps.size());
        
        List<Target_Item__c> items = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, representsConcern, 2,TRUE);
        Assert.areEqual(2, items.size());
        
        List<Target_Item__c> normalClientItems = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, lstAccounts[0], 2,TRUE);
        Assert.areEqual(2, normalClientItems.size());
        
        List<Target_Item__c> normalClientItems1 = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, lstAccounts[1], 2,TRUE);
        Assert.areEqual(2, normalClientItems1.size());
        
        List<Target_Measure__c> measures = TestBusinessHelper.createSalesTargetItemMeasures(items,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, measures.size());
        
        List<Target_Measure__c> normalClientmeasures = TestBusinessHelper.createSalesTargetItemMeasures(normalClientItems,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, normalClientmeasures.size());
        
        List<Target_Measure__c> normalClientItems1measures = TestBusinessHelper.createSalesTargetItemMeasures(normalClientItems1,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, normalClientItems1measures.size());
        
        List<Territory__c> listTerritory = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritory.size());
        
        system.runAs(new User(Id = UserInfo.getUserId())){            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            }
            Test.startTest();
                List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
                List<Geography__c> geoTest = [SELECT Id, GEO_Code__c FROM Geography__c WHERE GEO_Code__c = 'AUS'];                
                List<Territory_Account_Association__c> listTaa = new List<Territory_Account_Association__c>();
                
                Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[0], representsConcern, TAASettingConstants.POR_Global_Lead_Account_Owner_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
                TAA.Id=NULL;
                TAA.Start_Date__c = Date.Today();
                listTaa.add(TAA);
                
                Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[1], representsConcern, TAASettingConstants.POR_Influencer_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
                TAA1.Id=NULL;
                TAA1.Start_Date__c = Date.Today();
                TAA1.Country__c =geoTest[0].Id;
                listTaa.add(TAA1);
                
                insert listTaa;
            
                BatchUpdateTargetItemMeasure tm = new BatchUpdateTargetItemMeasure();
                Database.executeBatch(tm);
            Test.stopTest();                
        }
    }
    @istest
    static void testMethod3(){
        // Test Method of creating TAA for Normal Client Account of Concern Account.
        Account representsConcern;
        List<Account> lstAccounts = new List<Account>();
        for(Account acc:[SELECT Id,Represents_Concern__c,Customer_Code__c FROM Account WHERE ParentId!=NULL]){
            if(acc.Represents_Concern__c){
               representsConcern = acc; 
            }
            else{
               lstAccounts.add(acc); 
            }
        }
        Assert.isNotNull(representsConcern.Id);
        Assert.areEqual(2, lstAccounts.size());
        
        List<Target__c> target =[SELECT Id FROM Target__c WHERE Applicable_Year__c='2070'];        
        Assert.areEqual(1, target.size());
            
        List<Target_Item_Group__c> listTargetGrps = [SELECT Id FROM Target_Item_Group__c WHERE Target__c=:target[0].Id];
        Assert.areEqual(2, listTargetGrps.size());
        
        List<Target_Item__c> items = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, representsConcern, 2,TRUE);
        Assert.areEqual(2, items.size());
        
        List<Target_Item__c> normalClientItems = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, lstAccounts[0], 2,TRUE);
        Assert.areEqual(2, normalClientItems.size());
        
        List<Target_Item__c> normalClientItems1 = TestBusinessHelper.createSalesTargetItems(new List<Target_Item_Group__c>{listTargetGrps[0], listTargetGrps[1]}, lstAccounts[1], 2,TRUE);
        Assert.areEqual(2, normalClientItems1.size());
        
        List<Target_Measure__c> measures = TestBusinessHelper.createSalesTargetItemMeasures(items,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, measures.size());
        
        List<Target_Measure__c> normalClientmeasures = TestBusinessHelper.createSalesTargetItemMeasures(normalClientItems,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, normalClientmeasures.size());
        
        List<Target_Measure__c> normalClientItems1measures = TestBusinessHelper.createSalesTargetItemMeasures(normalClientItems1,new List<String>{TargetSettingConstants.TARGET,TargetSettingConstants.TARGET},new List<String>{TargetSettingConstants.VOLUME,TargetSettingConstants.VOLUME},new List<String>{TargetSettingConstants.PARTY_SHIPPER,TargetSettingConstants.PARTY_PO}, new List<Boolean>{FALSE,FALSE}, 2, TRUE);
        Assert.areEqual(2, normalClientItems1measures.size());
        
        List<Territory__c> listTerritory = [SELECT Id FROM Territory__c];
        Assert.areEqual(2, listTerritory.size());
        
      system.runAs(new User(Id = UserInfo.getUserId())){
            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1].Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            }  
          
           Territory_Account_Association__c rcTAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[0], representsConcern, TAASettingConstants.POR_Global_Lead_Account_Owner_Only, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
                rcTAA.Id=NULL;
                rcTAA.Start_Date__c = Date.Today();
                insert rcTAA;
        
        Test.startTest();
            List<Territory_Account_Association__c> listTaa = new List<Territory_Account_Association__c>();
            Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[0], lstAccounts[0], TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All, BrandUtilities.SEAGO, FALSE);
            TAA.Id=NULL;            
            TAA.Start_Date__c = Date.Today();
            //insert TAA;
            listTaa.add(TAA);
            
            Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(listTerritory[1], lstAccounts[1], TAASettingConstants.POR_SALES_CONTROL_ONLY, TAASettingConstants.PR_All,BrandUtilities.SEAGO , FALSE);
            TAA1.Id=NULL;           
            TAA1.Start_Date__c = Date.Today();
            //insert TAA;
            listTaa.add(TAA1);
                    
            insert listTaa;
                
            BatchUpdateTargetItemMeasure tm = new BatchUpdateTargetItemMeasure();
            Database.executeBatch(tm);
        Test.stopTest();                
      }}
}