@isTest
public class BatchSIPManagersPopulateQuartersTest {
    @testSetup
    static void prepareData(){
        
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        
        //Represent Concern of Concern Account 
        Account Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc1.Customer_Code__c='TEST445651';
        Acc1.Represents_Concern__c=TRUE;
        Acc1.ParentId=concernAccount.Id;
        Acc1.Id=NULL;
        insert Acc1;
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); 
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        List<Target_Brand_Mapping__c> brandList= new List<Target_Brand_Mapping__c>();
        Target_Brand_Mapping__c br = new Target_Brand_Mapping__c();
        br.RecordtypeId = recordTypeId;
        br.Salesforce_Brand__c=BrandUtilities.SEAGO;
        br.Active__c=True;
        br.BrandMnA__c='Sealand Europe';
        brandList.add(br);
        
        Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c(Active__c = TRUE,Salesforce_Brand__c= 'Maersk Line', BrandMnA__c = 'Maersk Line', RecordTypeId = recordTypeId);
        brandList.add(tbm);
        insert brandList;  
        
        User salesUser = new User();
        User adminUser = new User();
        List<User> usersToInsert = new List<User>();
        
        System.runAs(new user(ID = UserInfo.getUserId())){          
            salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.HAMBURGSUD, false);
            salesUser.Id = null;
            salesUser.IsActive=true;
            salesUser.country = 'India';
            salesUser.Cluster__c = 'Centre Function';
            salesUser.Segment_Focus__c='Advancement';
            salesUser.Sales_Job_Function__c='Sales Manager';
            salesUser.FirstName='Manager';
            salesUser.LastName='Manager For Subordinates';    
            insert salesUser;   
                                       
            User salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser1.Id = null;
            salesUser1.IsActive=true;
            salesUser1.country = 'India';
            salesUser1.Cluster__c = 'GSC';
            salesUser1.Industry_Focus__c='Retail';
            salesUser1.Segment_Focus__c='Advancement';
            salesUser1.Sales_Job_Function__c='Other';
            salesUser1.ManagerId = salesUser.Id; 
            salesUser1.FirstName='Sub Ordinate';
            salesUser1.LastName='User 1';            
            usersToInsert.add(salesUser1);
              

            User salesUser2 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
            salesUser2.Id = null;
            salesUser2.IsActive=true;
            salesUser2.country = 'India';
            salesUser2.Cluster__c = 'Centre Function';
            salesUser2.Segment_Focus__c='Advancement';
            salesUser2.Sales_Job_Function__c='Sales Manager';
            salesUser2.ManagerId = salesUser.Id;
            salesUser2.FirstName='Sub Ordinate';
            salesUser2.LastName='User 2';            
            usersToInsert.add(salesUser2); 
            
            adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);    
            adminUser.Id = null;
            adminUser.IsActive=true;
            adminUser.country = 'India';
            usersToInsert.add(adminUser); 
            insert usersToInsert;   
            
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1]?.Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:adminUser.Id];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=adminUser.Id, PermissionSetId=managePortfolioPermissionSetId);
            }
            
                           
        } // End of System.runAs
                  
          Target__c salesTargetTest = TestBusinessHelper.createSalesTarget(usersToInsert[0],String.ValueOf(Date.today().year()),'USD','Monthly',TRUE);
          
          List<Target_Item_Group__c> listTIG = new List<Target_Item_Group__c>();
          Target_Item_Group__c targetItemGroupTest = TestBusinessHelper.createSalesTargetItemGroup(salesTargetTest, 'Maersk Line', country , bdaGeo, '4PL PF', FALSE);
          targetItemGroupTest.Id=NULL;
          listTIG.add(targetItemGroupTest);
        
          Target_Item_Group__c targetItemGroupTest1 = TestBusinessHelper.createSalesTargetItemGroup(salesTargetTest, 'Maersk Line', country , bdaGeo, 'LCL PF', FALSE);
          targetItemGroupTest1.Id=NULL;
          listTIG.add(targetItemGroupTest1);        
          insert listTIG;
        
          List<Target_Item__c> targetItems = new List<Target_Item__c>();
        
          Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupTest, null, Acc1, null, null, null, FALSE);
          targetItemRec.Id=NULL;
          targetItems.add(targetItemRec);
        
          Target_Item__c targetItemRec1 = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupTest1, null, Acc1, null, null, null, FALSE);
          targetItemRec1.Id=NULL;
          targetItems.add(targetItemRec1);       
          insert targetItems;
        
          Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[0], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
          Target_Measure__c targetMeasure1 = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[1], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
          
          
          System.runAs(new user(ID = adminUser.Id)){ 
              Test.StartTest();
              Territory__c ter1 = TestBusinessHelper.createTerritory(usersToInsert[0], TRUE);
              Territory__c ter2 = TestBusinessHelper.createTerritory(usersToInsert[1], TRUE);
              Territory__c ter3 = TestBusinessHelper.createTerritory(salesUser, TRUE);
                                
              List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
              // SubOrdinate1 TAA
              Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(ter2, Acc1, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
              TAA.Id = NULL; 
              TAA.Start_Date__c = Date.newInstance(Date.Today().Year(), 01,01);
              lstTAA.add(TAA);
            
              // SubOrdinate2 TAA
              Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(ter3, Acc1, TAASettingConstants.POR_Global_Lead_Account_Owner_Only , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
              TAA1.Id = NULL; 
              TAA1.Start_Date__c = Date.newInstance(Date.Today().Year(), 01,01);
              TAA1.End_Date__c   = Date.Today().addDays(10);
              lstTAA.add(TAA1);
                
              Territory_Account_Association__c TAA2 = TestBusinessHelper.createTerritoryAccountAssociation(ter1, Acc1, TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
              TAA2.Id = NULL; 
              TAA2.Start_Date__c = Date.newInstance(Date.Today().Year(), 01,01);
              TAA2.End_Date__c   = Date.newInstance(Date.Today().Year(), 01,30).addYears(2);
              lstTAA.add(TAA2);
                
              insert lstTAA;
              
            List<Sales_Rep_target_Quarter_Data__c> qDataList = new List<Sales_Rep_target_Quarter_Data__c>();
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=salesUser.Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=salesUser.Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=salesUser.Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
            qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=usersToInsert[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
            insert qDataList;
              
              Test.stopTest();
          }
            
    }
    
    // Manager has TCP and SubOrdinate has TCP & Manager SIP Measure is Cumulative - With Multi PFs
    @isTest
    static void testMethod1(){
        
        List<User> managerUser = [SELECT Id FROM User Where FirstName='Manager' AND LastName='Manager For Subordinates' LIMIT 1];  
        BDA__c parentBDA =[SELECT Id FROM BDA__c WHERE Name='India, Middle East, and Africa'];
        BDA__c childBDA =[SELECT Id FROM BDA__c WHERE Name='India and Bangladesh Area'];
        List<String> pfs = new List<String>{'4PL PF','SCM PF'};
        SIP_KPI__c kpiRec = new SIP_KPI__c (Name = 'Ocean Vol',KPI_Code__c = 'Test code',KPI_Incentive_Type__c = 'Target-based',
                                            KPI_Type__c = 'Core',Payout_Frequency__c = 'Annual',Unit_of_Measure__c = 'USD',
                                            KPI_Grouping__c = 'Existing and additional business', Measure_Type__c = 'Revenue',
                                            Target__c = 11,product_Portfolio__c = 'Lns',Geographical_Validity__c = 'Global',
                                            Effective_From_Date__c = Date.newInstance(Date.Today().Year(), 1, 1 ),
                                            Effective_To_Date__c = Date.newInstance(Date.Today().Year(), 12, 30 ),                                          
                                            L_S_product_family__c = String.join(pfs, ';'), Brand__c = BrandUtilities.MAERSK,Cumulative_Based_Crediting__c = true);
        insert kpiRec;
        SIP_Participant__c participant = new SIP_Participant__c(SIP_Participant__c = managerUser[0].id,Year__c = String.valueOf(Date.Today().Year()),
                                                            Paymix__c = 80.0,Brand__c = BrandUtilities.MAERSK,
                                                            Region__c = parentBDA.id,Area__c = childBDA.id);
        insert participant;
        SIP_Measure__c sipMeasure = new SIP_Measure__c(SIP_Participant__c = participant.id,SIP_KPI__c = kpiRec.id,Weight__c = '30%',
                                                        Applicable_Period__c = 'Q4',Target__c =8000,System_Actual__c = 5000,
                                                        Load_Target_from_STS__c = true,Status__c = 'Target Assigned');
         insert sipMeasure;
        
         List<User> userList = [SELECT Id FROM User Where LastName='Manager For Subordinates' OR LastName='User 1' OR LastName='User 2'];
         List<Sales_Rep_target_Quarter_Data__c> qDataList = new List<Sales_Rep_target_Quarter_Data__c>();
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[0].Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[1].Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[2].Id, Measure_Type__c='Revenue', L_S_product_family__c='4PL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[2].Id, Measure_Type__c='Revenue', L_S_product_family__c='LCL PF'));
         qDataList.add(new Sales_Rep_target_Quarter_Data__c(Sales_Rep__c=userList[2].Id, Measure_Type__c='Revenue', L_S_product_family__c='SCM PF'));
         insert qDataList;
        
        Test.startTest();
            new BatchPopulateQuarterValMeasure_Scheduler().execute(null);
        Test.stopTest();
    }
    // Manager has TCP and SubOrdinate has TCP & Manager SIP Measure is NOT Cumulative - Without PF
    @isTest
    static void testMethod2(){
        
        List<User> managerUser = [SELECT Id FROM User Where FirstName='Manager' AND LastName='Manager For Subordinates' LIMIT 1];  
        BDA__c parentBDA =[SELECT Id FROM BDA__c WHERE Name='India, Middle East, and Africa'];
        BDA__c childBDA =[SELECT Id FROM BDA__c WHERE Name='India and Bangladesh Area'];
        
        SIP_KPI__c kpiRec = new SIP_KPI__c (Name = 'Ocean Vol',KPI_Code__c = 'Test code',KPI_Incentive_Type__c = 'Target-based',
                                            KPI_Type__c = 'Core',Payout_Frequency__c = 'Annual',Unit_of_Measure__c = 'USD',
                                            KPI_Grouping__c = 'Existing and additional business', Measure_Type__c = 'Revenue',
                                            Target__c = 11,product_Portfolio__c = 'Lns',Geographical_Validity__c = 'Global',
                                            Effective_From_Date__c = Date.newInstance(Date.Today().Year(), 1, 1 ),
                                            Effective_To_Date__c = Date.newInstance(Date.Today().Year(), 12, 30 ),                                          
                                            Brand__c = BrandUtilities.MAERSK,Cumulative_Based_Crediting__c = false);
        insert kpiRec;
        SIP_Participant__c participant = new SIP_Participant__c(SIP_Participant__c = managerUser[0].id,Year__c = String.valueOf(Date.Today().Year()),
                                                            Paymix__c = 80.0,Brand__c = BrandUtilities.MAERSK,
                                                            Region__c = parentBDA.id,Area__c = childBDA.id);
        insert participant;
        SIP_Measure__c sipMeasure = new SIP_Measure__c(SIP_Participant__c = participant.id,SIP_KPI__c = kpiRec.id,Weight__c = '30%',
                                                        Applicable_Period__c = 'Q4',Target__c =8000,System_Actual__c = 5000,
                                                        Load_Target_from_STS__c = true,Status__c = 'Target Assigned');
         insert sipMeasure;
        
        Test.startTest();
            new BatchPopulateQuarterValMeasure_Scheduler().execute(null);
        Test.stopTest();
    }
    // Manager has NO TCP and SubOrdinate has TCP & Manager SIP Measure is Compounded
    // Manager has NO TCP and SubOrdinate has TCP & Manager SIP Measure is NOT Compounded
    // Both Manager and Sub Ordinate doesnt have TCP & Manager SIP Measure is Compounded
    @isTest
    static void testMethod5(){        
        List<User> managerUser = [SELECT Id FROM User Where FirstName='Manager' AND LastName='Manager For Subordinates' LIMIT 1];  
        BDA__c parentBDA =[SELECT Id FROM BDA__c WHERE Name='India, Middle East, and Africa'];
        BDA__c childBDA =[SELECT Id FROM BDA__c WHERE Name='India and Bangladesh Area'];
        
        List<Target_Customer_Portfolio__c> deleteTCPS = [SELECT Id FROM Target_Customer_Portfolio__c];
        delete deleteTCPS;
        
        SIP_KPI__c kpiRec = new SIP_KPI__c (Name = 'Ocean Vol',KPI_Code__c = 'Test code',KPI_Incentive_Type__c = 'Target-based',
                                            KPI_Type__c = 'Core',Payout_Frequency__c = 'Annual',Unit_of_Measure__c = 'USD',
                                            KPI_Grouping__c = 'Existing and additional business', Measure_Type__c = 'Revenue',
                                            Target__c = 11,product_Portfolio__c = 'Lns',Geographical_Validity__c = 'Global',
                                            Effective_From_Date__c = Date.newInstance(Date.Today().Year(), 1, 1 ),
                                            Effective_To_Date__c = Date.newInstance(Date.Today().Year(), 12, 30 ),                                          
                                            L_S_product_family__c ='4PL PF',Brand__c = BrandUtilities.MAERSK,Cumulative_Based_Crediting__c = TRUE);
        insert kpiRec;
        SIP_Participant__c participant = new SIP_Participant__c(SIP_Participant__c = managerUser[0].id,Year__c = String.valueOf(Date.Today().Year()),
                                                            Paymix__c = 80.0,Brand__c = BrandUtilities.MAERSK,
                                                            Region__c = parentBDA.id,Area__c = childBDA.id);
        insert participant;
        SIP_Measure__c sipMeasure = new SIP_Measure__c(SIP_Participant__c = participant.id,SIP_KPI__c = kpiRec.id,Weight__c = '30%',
                                                        Applicable_Period__c = 'Q4',Target__c =8000,System_Actual__c = 5000,
                                                        Load_Target_from_STS__c = true,Status__c = 'Target Assigned');
         insert sipMeasure;
        
        Test.startTest();
            new BatchPopulateQuarterValMeasure_Scheduler().execute(null);
        Test.stopTest();
    }
    // Both Manager and Sub Ordinate doesnt have TCP & Manager SIP Measure is NOT Compounded
    @isTest
    static void testMethod6(){        
        List<User> managerUser = [SELECT Id FROM User Where FirstName='Manager' AND LastName='Manager For Subordinates' LIMIT 1];  
        BDA__c parentBDA =[SELECT Id FROM BDA__c WHERE Name='India, Middle East, and Africa'];
        BDA__c childBDA =[SELECT Id FROM BDA__c WHERE Name='India and Bangladesh Area'];
        
        List<Target_Customer_Portfolio__c> deleteTCPS = [SELECT Id FROM Target_Customer_Portfolio__c];
        delete deleteTCPS;
        
        SIP_KPI__c kpiRec = new SIP_KPI__c (Name = 'Ocean Vol',KPI_Code__c = 'Test code',KPI_Incentive_Type__c = 'Target-based',
                                            KPI_Type__c = 'Core',Payout_Frequency__c = 'Annual',Unit_of_Measure__c = 'USD',
                                            KPI_Grouping__c = 'Existing and additional business', Measure_Type__c = 'Revenue',
                                            Target__c = 11,product_Portfolio__c = 'Lns',Geographical_Validity__c = 'Global',
                                            Effective_From_Date__c = Date.newInstance(Date.Today().Year(), 1, 1 ),
                                            Effective_To_Date__c = Date.newInstance(Date.Today().Year(), 12, 30 ),                                          
                                            L_S_product_family__c ='4PL PF',Brand__c = BrandUtilities.MAERSK,Cumulative_Based_Crediting__c = FALSE);
        insert kpiRec;
        SIP_Participant__c participant = new SIP_Participant__c(SIP_Participant__c = managerUser[0].id,Year__c = String.valueOf(Date.Today().Year()),
                                                            Paymix__c = 80.0,Brand__c = BrandUtilities.MAERSK,
                                                            Region__c = parentBDA.id,Area__c = childBDA.id);
        insert participant;
        SIP_Measure__c sipMeasure = new SIP_Measure__c(SIP_Participant__c = participant.id,SIP_KPI__c = kpiRec.id,Weight__c = '30%',
                                                        Applicable_Period__c = 'Q4',Target__c =8000,System_Actual__c = 5000,
                                                        Load_Target_from_STS__c = true,Status__c = 'Target Assigned');
         insert sipMeasure;
        
        Test.startTest();
            new BatchPopulateQuarterValMeasure_Scheduler().execute(null);
        Test.stopTest();
    }
}