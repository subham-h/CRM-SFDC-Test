/*  
* Version   Date            Owner                   Description
* --------  -----------     -------------------     -----------
* 1.0       25-Oct-2023     Vazid                   Test class for TargetSettingActualsLoadBatch
*/
@isTest
public class TargetSettingActualsLoadBatchTest {
    @testSetup
    static void testDataSetup(){
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        //    adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
        }  
        System.assertNotEquals(null, adminUser.Id); 
        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        
        List<String> cadence= new List<String>{'Monthly','Monthly','Monthly'};
            List<String> year= new List<String>{'2034','2035','2036'};
                List<String> curr= new List<String>{'USD','USD','USD'};
                     List<String> brands= new List<String>{'Maersk Line','Hamburg Sud'};
                    List<Target__c> testTargets = TestBusinessHelper.createSalesTargets(user1, year,curr,cadence, 3, true);
        User maestroInterfaceUser = new User();
        System.runAs(adminUser){
            maestroInterfaceUser = TestBusinessHelper.createUser('911 - Interface (Business Intelligence)', BrandUtilities.MAERSKLINE, false);
            maestroInterfaceUser.Id = null;
            maestroInterfaceUser.IsActive=true;
            insert maestroInterfaceUser;  
        }
        
        TriggerExecutionController.skipAllTriggers(true);
        List<Geography__c> listGeographyToInsert = new list<Geography__c>();
        Geography__c country1 = TestBusinessHelper.createGeography('India', 'Country', null,'IN',FALSE); country1.Id = null; listGeographyToInsert.add(country1);
        Geography__c country2 = TestBusinessHelper.createGeography('InvalidCountry', 'Country', null,'INVAl',FALSE); country2.Id = null;  listGeographyToInsert.add(country2);
        insert listGeographyToInsert;
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true); 
        System.assertNotEquals(null, parentBDA.Id); 
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        System.assertNotEquals(null, childBDA.Id);  
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country1.Id, null, true);
        BDA_Geography__c bdaGeo1 = TestBusinessHelper.createBDAGeography(childBDA.Id, country2.Id, null, true);
        
        Target_Item_Group__c tig = new Target_Item_Group__c();
        tig.BrandMnA__c='Maersk Line';
        tig.Product_Family__c = 'Insurance PF';
        tig.Target__c=testTargets[0].id;
        tig.Country_Code__c='IN';
        tig.Executing_Area__c=childBDA.id;
        tig.Executing_Country__c=country1.id;
        insert tig;

        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST4876CONCERNCODE';
        concernAccount.Id=NULL;
        TriggerExecutionController.skipAccountTrigger(true);
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
        
        //Creating client accounts without parent
        List<String> lstAccountRecordTypes = new List<String>{'Client_Account','Client_Account','Client_Account'};
            List<Account> lstClientAccounts =  TestBusinessHelper.createAccounts(lstAccountRecordTypes,false);
        lstClientAccounts[0].Customer_Code__c='CL000000000';
        lstClientAccounts[0].SCV_Status__c = 'Active';
        lstClientAccounts[0].Country__c = country1.Id; 
        lstClientAccounts[0].Id = null;
        lstClientAccounts[1].Customer_Code__c='CL111111111';
        lstClientAccounts[1].SCV_Status__c = 'InActive';
        lstClientAccounts[1].Country__c = country1.Id; 
        lstClientAccounts[1].Id = null;
        lstClientAccounts[2].Customer_Code__c='CL222222222';
        lstClientAccounts[2].SCV_Status__c = 'Active';
        lstClientAccounts[2].Country__c = country2.Id;//Invalid country
        lstClientAccounts[2].Id = null; 
        
        Account RC1 = TestBusinessHelper.createAccount('Client_Account',False);
        RC1.Customer_Code__c='TEST487651'; 
        RC1.Represents_Concern__c=TRUE;
        RC1.ParentId=concernAccount.Id;
        RC1.Id=NULL;
        lstClientAccounts.add(RC1);
        
        Account NCC1 = TestBusinessHelper.createAccount('Client_Account',False);
        NCC1.Customer_Code__c='TEST445652'; 
        NCC1.ParentId=concernAccount.Id;
        NCC1.Id=NULL;
        lstClientAccounts.add(NCC1);
        
        TriggerExecutionController.skipAccountTrigger(true);
        insert lstClientAccounts;
        
        
        List<Target_Setting_Staging__c> lstTargetSettingStaging = new List<Target_Setting_Staging__c>();
        test.startTest(); 
        Target_Setting_Staging__c targetSettingStageTest1 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','Maersk Line',lstClientAccounts[0].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'IN', FALSE, TRUE, lstClientAccounts[1].Customer_Code__c,'Insurance PF','ROFOQ42023', lstClientAccounts[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest1.Id = NULL;
        targetSettingStageTest1.Price_Owner_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest1.Shipper_Account_Id__c = lstClientAccounts[2].Id;
        targetSettingStageTest1.Consignee_Account_Id__c = lstClientAccounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest1);
        
        Target_Setting_Staging__c targetSettingStageTest2 = TestBusinessHelper.createTargetSettingStage('USD','Rolling Forecast','New','Revenue','Maersk Line',lstClientAccounts[0].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'TN', FALSE,  TRUE, lstClientAccounts[1].Customer_Code__c,'Insurance PF',' ', lstClientAccounts[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest2.Id = NULL;
        targetSettingStageTest2.Price_Owner_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest2.Shipper_Account_Id__c = lstClientAccounts[2].Id;
        targetSettingStageTest2.Consignee_Account_Id__c = lstClientAccounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest2);
        
        Target_Setting_Staging__c targetSettingStageTest3 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','UnknownBrand',lstClientAccounts[0].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'IN', FALSE, TRUE, lstClientAccounts[1].Customer_Code__c,'Insurance PF','ROFOQ12023', lstClientAccounts[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest3.Id = NULL;
        targetSettingStageTest3.Price_Owner_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest3.Shipper_Account_Id__c = lstClientAccounts[2].Id;
        targetSettingStageTest3.Consignee_Account_Id__c = lstClientAccounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest3);
        
        Target_Setting_Staging__c targetSettingStageTest4 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','Maersk Line',lstClientAccounts[1].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'MA', FALSE,  TRUE, lstClientAccounts[0].Customer_Code__c,'Insurance PF','ROFOQ12023', lstClientAccounts[4].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest4.Id = NULL;
        targetSettingStageTest4.Price_Owner_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest4.Shipper_Account_Id__c = lstClientAccounts[4].Id;
        targetSettingStageTest4.Consignee_Account_Id__c = lstClientAccounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest4);
        
        Target_Setting_Staging__c targetSettingStageTest5 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','Maersk Line',lstClientAccounts[1].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'MA', FALSE,  TRUE, lstClientAccounts[1].Customer_Code__c,'Insurance PF','ROFOQ12023', lstClientAccounts[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest5.Id = NULL;
        targetSettingStageTest5.Price_Owner_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest5.Shipper_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest5.Consignee_Account_Id__c = lstClientAccounts[1].Id;
        lstTargetSettingStaging.add(targetSettingStageTest5);
        
        Target_Setting_Staging__c targetSettingStageTest6 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','Maersk Line',lstClientAccounts[1].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'MA', FALSE,  TRUE, lstClientAccounts[3].Customer_Code__c,'Insurance PF','ROFOQ12023', lstClientAccounts[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest6.Id = NULL;
        targetSettingStageTest6.Price_Owner_Account_Id__c = lstClientAccounts[3].Id;
        targetSettingStageTest6.Shipper_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest6.Consignee_Account_Id__c = lstClientAccounts[1].Id;
        lstTargetSettingStaging.add(targetSettingStageTest6);
        
        Target_Setting_Staging__c targetSettingStageTest7 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','Maersk Line',lstClientAccounts[0].Customer_Code__c,
                                                                                                        TRUE,'1695357018', 'MA', FALSE,  TRUE, lstClientAccounts[0].Customer_Code__c,'Insurance PF','ROFOQ12023', lstClientAccounts[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest7.Id = NULL;
        targetSettingStageTest7.Price_Owner_Account_Id__c = lstClientAccounts[0].Id;
        targetSettingStageTest7.Shipper_Account_Id__c = lstClientAccounts[1].Id;
        targetSettingStageTest7.Consignee_Account_Id__c = lstClientAccounts[0].Id;
        lstTargetSettingStaging.add(targetSettingStageTest7);
        
         List<String> productFamily= new List<String>{'4PL PF','INLAND PF','Depot & EMR PF'}; 
         List<Target_item_group__c> testTargetGroup= new List<Target_item_group__c>();
        testTargetGroup.add(tig);
        List<Target_item__c> SalesTargetItems= TestBusinessHelper.createSalesTargetItems(testTargetGroup, RC1, 3, true);
        
        List<String>measureDim=new List<String>{TargetSettingConstants.CY_ACTUALS,TargetSettingConstants.TARGET,TargetSettingConstants.CY_ACTUALS};
        List<String>measureType=new List<String>{'Revenue','Gross Profit','Volume'};
        List<String>partyType=new List<String>{'Price Owner','Shipper','Consignee'};
        List<Boolean> credEligible=new List<Boolean>{true,false,true};
            
        List <Target_measure__c> testItemMeasures= TestBusinessHelper.createSalesTargetItemMeasures(SalesTargetItems, measureDim, measureType, partyType,credEligible, 3, true);
       
        
        System.runAs(maestroInterfaceUser){
            insert lstTargetSettingStaging;
        }
        
    }
    @isTest
    static void testTargetSettingActualsLoadBatchTest(){ 
        Target_Setting_Batch_Query__mdt mdt_TSB =  [SELECT Id,Query__c  from Target_Setting_Batch_Query__mdt WHERE 
                                                    DeveloperName = 'PY_ACTUALS' LIMIT 1];
        List<Target__c> targetRec = [Select Id from Target__c limit1];
        List<Target_Item_Group__c> targetItemGrpList = [SELECT Id, Unique_Identifier__c FROM Target_Item_Group__c];
        
        List<Target_Setting_Staging__c> stageList = [SELECT Id, Price_Owner_Account_Id__c, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c, Price_Owner__c FROM Target_Setting_Staging__c WHERE Measure_Dimension__c = 'Previous Year Actuals' and Price_Owner_Account_Id__c != null];
        system.debug('stageList'+stageList.size());
        targetItemGrpList[0].Unique_Identifier__c = TargetSettingUtil.generateUniqueIdFromString(
            stageList[0].Country_Code__c + stageList[0].Brand__c + stageList[0].Product_Family__c)+targetRec[0].Id;
        update targetItemGrpList;
          List<Target_item__c> targetItemList = [SELECT Id, Unique_Identifier__c FROM Target_item__c ];
        targetItemList[0].Unique_Identifier__c = TargetSettingUtil.generateUniqueIdFromString(
                stageList[0].Country_Code__c + stageList[0].Brand__c + stageList[0].Product_Family__c) +targetRec[0].Id+stageList[0].Price_Owner_Account_Id__c;
       update targetItemList;
        List <Target_measure__c> listofMeasure = [SELECT Id  , Jan__c , Feb__c , Mar__c, Apr__c, May__c , Jun__c, Jul__c, Aug__c , Sep__c, Oct__c, Nov__c, Dec__c, Measure_Dimension__c , Measure_Type__c, Credit_Eligible__c  , Target_Item__r.Unique_Identifier__c  FROM Target_Measure__c];
        Test.starttest();
        TargetSettingActualsLoadBatch bch = new TargetSettingActualsLoadBatch(targetRec[0].Id,'1695357018','PY_ACTUALS');
        Database.executeBatch(bch);
        TargetSettingBatchHelper.aggregateMeasureFromStaging(listofMeasure[0],stageList[0]);
        Test.stopTest();
    }
    
}