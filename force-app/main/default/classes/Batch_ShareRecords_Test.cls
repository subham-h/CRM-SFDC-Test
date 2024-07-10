/*  
 * Version  Date            #Reference              Owner                   Description
 * -------- -----------     -------------------     -----------             ---------------
 * 1.0      10-Jan-2024                             Sowmya@maersk           
 * 2.0      10-Jan-2024                             Kiran@Maersk            Moving test data into setup and simlifying the test class
 */

@isTest
public class Batch_ShareRecords_Test {
    
    @testSetup
    static void setupTestData() {
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, true);
        
        List<Geography__c> geoInsertList = new List<Geography__c>();
        Geography__c indCountry = TestBusinessHelper.createGeography('India', 'Country', null, false);
        indCountry.Id = null;
        indCountry.GEO_Code__c = 'IN';
        Geography__c ukCountry = TestBusinessHelper.createGeography('United Kingdom', 'Country', null, false);
        ukCountry.Id = null;
        ukCountry.GEO_Code__c = 'UK';
        Geography__c chinaCountry = TestBusinessHelper.createGeography('China','Country', null, false);
        chinaCountry.Id = null;
        chinaCountry.GEO_Code__c = 'CN';
        Geography__c uSCountry = TestBusinessHelper.createGeography('United States',  'Country',  null, false);
        uSCountry.Id = null;
        uSCountry.GEO_Code__c = 'US';
        Geography__c russiaCountry = TestBusinessHelper.createGeography('Russia','Country', null, false);
        russiaCountry.Id = null;
        
        geoInsertList.add(indCountry);
        geoInsertList.add(ukCountry);
        geoInsertList.add(chinaCountry);
        geoInsertList.add(uSCountry);
        geoInsertList.add(russiaCountry);
        
        System.runAs(adminUser){
            insert geoInsertList;
        }
        
        geoInsertList = new List<Geography__c>();
        Geography__c ukState = TestBusinessHelper.createGeography('London', 'State', ukCountry.Id, false);
        ukState.Id = null;
        Geography__c stateKA = TestBusinessHelper.createGeography('Karnataka', 'State', indCountry.Id, false);
        stateKA.Id = null;
        Geography__c uSstate = TestBusinessHelper.createGeography('New Jersey', 'State', uSCountry.Id, false);
        uSstate.Id = null;
        Geography__c chinastate = TestBusinessHelper.createGeography('San Carlos','State', chinaCountry.Id, false);
        chinastate.Id = null;
        geoInsertList.add(ukState);
        geoInsertList.add(stateKA);
        geoInsertList.add(uSstate);
        geoInsertList.add(chinastate);
        
        System.runAs(adminUser){
            insert geoInsertList;
        }
        
        BDA__c indParentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c indChildBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', indParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c indbdaGeo = TestBusinessHelper.createBDAGeography(indChildBDA.Id, indCountry.Id, null, true);
        
        BDA__c ukParentBDA = TestBusinessHelper.createBDA('United Kingdom', 'Other', 'EMEA', null, UserInfo.getUserId(), true);
        BDA__c ukChildBDA = TestBusinessHelper.createBDA('United Kingdom and Ireland Area', 'Cluster', 'UKI', ukParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c ukBdaGeo = TestBusinessHelper.createBDAGeography(ukChildBDA.Id, ukCountry.Id, null, true);
        
        BDA__c uSParentBDA = TestBusinessHelper.createBDA('North America Region', 'Trade Region', 'NAM', null, UserInfo.getUserId(), true);
        BDA__c uSChildBDA = TestBusinessHelper.createBDA('North America Area', 'Cluster', 'NOA', uSParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c uSBdaGeo = TestBusinessHelper.createBDAGeography(uSChildBDA.Id, uSCountry.Id, null, true);
        
        BDA__c chinaParentBDA = TestBusinessHelper.createBDA('Asia Pacific Region', 'Trade Region', 'APA', null, UserInfo.getUserId(), true);
        BDA__c chinaChildBDA = TestBusinessHelper.createBDA('Greater China Area', 'Cluster', 'GCA', chinaParentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c chinaBdaGeo = TestBusinessHelper.createBDAGeography(chinaChildBDA.Id, chinaCountry.Id, null, true);
        
        List<user> usersToInsert = new List<user>();
        User salesUserFromIndia = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromIndia.Id = null;
        salesUserFromIndia.Country = 'India';
        salesUserFromIndia.FederationIdentifier = 'ABC1234';

        User salesUserFromUS = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromUS.Id = null;
        salesUserFromUS.country = 'United States';
        salesUserFromUS.FederationIdentifier = 'ABC1235';

        User salesUserFromUK = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromUK.Id = null;
        salesUserFromUK.country = 'United Kingdom';
        salesUserFromUK.FederationIdentifier = 'ABC1236';

        User salesUserFromChina = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUserFromChina.Id = null;
        salesUserFromChina.country = 'China';
        salesUserFromChina.FederationIdentifier = 'ABC1237';

        
        usersToInsert.add(salesUserFromIndia);
        usersToInsert.add(salesUserFromUS);
        usersToInsert.add(salesUserFromUK);
        usersToInsert.add(salesUserFromChina);
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            //database.insert(usersToInsert, false);
            insert salesUserFromIndia;
            insert salesUserFromUS;
            insert salesUserFromUK;
            insert salesUserFromChina;
        }
        
        List<String> productFamily = new List<String>{'4PL PF','AIR PF','Cold Chain PF'}; 
        List<String> uniqueIds = new List<String>{'INML','DKSM','INSM'};
        List<String> brands = new List<String>{BrandUtilities.MAERSKLINE,BrandUtilities.HAMBURGSUD,'B2C'};
            
        List<Account> accToInsert = new List<Account>();
        Account accConcern = TestBusinessHelper.createAccount(salesUserFromIndia, indCountry, 'Concern_Account', true);
        Account accIndiaCountryWithSC = TestBusinessHelper.createAccount(salesUserFromIndia, indCountry, 'Client_Account',false);
        accIndiaCountryWithSC.Id = null;
        accIndiaCountryWithSC.Represents_Concern__c = true;
        accIndiaCountryWithSC.ParentId = accConcern.Id;
        accIndiaCountryWithSC.Sales_Channel__c = 'Direct Transport Sales';
        accIndiaCountryWithSC.Vertical__c = 'Lifestyle';
        accToInsert.add(accIndiaCountryWithSC);
        Account accUSCountryWithSC = TestBusinessHelper.createAccount(salesUserFromUS, uSCountry, 'Client_Account',false);
        accUSCountryWithSC.Id = null;
        accUSCountryWithSC.ParentId = accConcern.Id;
        accUSCountryWithSC.Sales_Channel__c = 'Integrated Sales';
        accToInsert.add(accUSCountryWithSC);
        Account accUKCountryWithSC = TestBusinessHelper.createAccount(salesUserFromUK, ukCountry, 'Client_Account',false);
        accUKCountryWithSC.Id = null;
        accUKCountryWithSC.ParentId = accConcern.Id;
        accUKCountryWithSC.Sales_Channel__c = 'Key Client/Runway';
        accToInsert.add(accUKCountryWithSC);
        Account accChinaCountryWithSC = TestBusinessHelper.createAccount(salesUserFromChina, chinaCountry, 'Client_Account',false);
        accChinaCountryWithSC.Id = null;
        accChinaCountryWithSC.ParentId = accConcern.Id;
        accChinaCountryWithSC.Sales_Channel__c = 'Integrated Sales';
        accToInsert.add(accChinaCountryWithSC);
        
        Account accIndiaCountryWithoutSC = TestBusinessHelper.createAccount(salesUserFromIndia, indCountry, 'Client_Account',false);
        accIndiaCountryWithoutSC.Id = null;
        accIndiaCountryWithoutSC.Represents_Concern__c = true;
        accIndiaCountryWithoutSC.ParentId = accConcern.Id;
        accIndiaCountryWithoutSC.Sales_Channel__c = 'Direct Transport Sales';
        accToInsert.add(accIndiaCountryWithoutSC);
        Account accUSCountryWithoutSC = TestBusinessHelper.createAccount(salesUserFromUS, uSCountry, 'Client_Account',false);
        accUSCountryWithoutSC.Id = null;
        accUSCountryWithoutSC.ParentId = accConcern.Id;
        accUSCountryWithoutSC.Sales_Channel__c = 'Integrated Sales';
        accToInsert.add(accUSCountryWithoutSC);
        Account accUKCountryWithoutSC = TestBusinessHelper.createAccount(salesUserFromUK, ukCountry, 'Client_Account',false);
        accUKCountryWithoutSC.Id = null;
        accUKCountryWithoutSC.ParentId = accConcern.Id;
        accUKCountryWithoutSC.Sales_Channel__c = 'Key Client/Runway';
        accToInsert.add(accUKCountryWithoutSC);
        Account accChinaCountryWithoutSC = TestBusinessHelper.createAccount(salesUserFromChina, chinaCountry, 'Client_Account',false);
        accChinaCountryWithoutSC.Id = null;
        accChinaCountryWithoutSC.ParentId = accConcern.Id;
        accChinaCountryWithoutSC.Sales_Channel__c = 'Integrated Sales';
        accToInsert.add(accChinaCountryWithoutSC);
        
        System.runAs(salesUserFromIndia){
            insert accToInsert;
        }
        
        //Creating sales target record with the current year
        Target__c salesTargetRec = TestBusinessHelper.createSalesTarget(salesUserFromIndia, String.valueOf(System.today().year()), 'USD', 'Monthly', true);
        system.Debug('TargetID'+salesTargetRec.Id);
        //Craeting Sales target item group records
        List<Target_Item_Group__c> targetItemGroupsToInsert = new List<Target_Item_Group__c>();
        Target_Item_Group__c salesTargetItemGroupIndia = TestBusinessHelper.createSalesTargetItemGroup(salesTargetRec, BrandUtilities.MAERSKLINE, indCountry, null, '4PL PF', false);
        salesTargetItemGroupIndia.Id = null;
        salesTargetItemGroupIndia.Executing_Area__c = indChildBDA.Id;
        targetItemGroupsToInsert.add(salesTargetItemGroupIndia);
        Target_Item_Group__c salesTargetItemGroupUS = TestBusinessHelper.createSalesTargetItemGroup(salesTargetRec, BrandUtilities.MAERSKLINE, uSCountry, null, '4PL PF', false);
        salesTargetItemGroupUS.Id = null;
        salesTargetItemGroupUS.Executing_Area__c = uSChildBDA.Id;
        targetItemGroupsToInsert.add(salesTargetItemGroupUS);
        Target_Item_Group__c salesTargetItemGroupUK = TestBusinessHelper.createSalesTargetItemGroup(salesTargetRec, BrandUtilities.MAERSKLINE, ukCountry, null, '4PL PF', false);
        salesTargetItemGroupUK.Id = null;
        salesTargetItemGroupUK.Executing_Area__c = ukChildBDA.Id;
        targetItemGroupsToInsert.add(salesTargetItemGroupUK);
        Target_Item_Group__c salesTargetItemGroupChina = TestBusinessHelper.createSalesTargetItemGroup(salesTargetRec, BrandUtilities.MAERSKLINE, chinaCountry, null, '4PL PF', false);
        salesTargetItemGroupChina.Id = null;
        salesTargetItemGroupChina.Executing_Area__c = chinaChildBDA.Id;
        targetItemGroupsToInsert.add(salesTargetItemGroupChina);
        
        insert targetItemGroupsToInsert;
        
        List<Target_item__c> SalesTargetItemsToInsert = new List<Target_item__c>();
        Target_item__c targetItemIndAcc = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupIndia, null, accIndiaCountryWithSC, indCountry, indChildBDA, null, false);
        targetItemIndAcc.Id = null;
        SalesTargetItemsToInsert.add(targetItemIndAcc);
        Target_item__c targetItemUSAcc = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupUS, null, accUSCountryWithSC, usCountry, uSChildBDA, null, false);
        targetItemUSAcc.Id = null;
        SalesTargetItemsToInsert.add(targetItemUSAcc);
        Target_item__c targetItemUKAcc = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupUK, null, accUKCountryWithSC, ukCountry, ukChildBDA, null, false);
        targetItemUKAcc.Id = null;
        SalesTargetItemsToInsert.add(targetItemUKAcc);
        Target_item__c targetItemChinaAcc = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupChina, null, accChinaCountryWithSC, chinaCountry, chinaChildBDA, null, false);
        targetItemChinaAcc.Id = null;
        SalesTargetItemsToInsert.add(targetItemChinaAcc);
        Target_item__c targetItemIndAccWithOutSC = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupIndia, null, accIndiaCountryWithoutSC, indCountry, indChildBDA, null, false);
        targetItemIndAccWithOutSC.Id = null;
        SalesTargetItemsToInsert.add(targetItemIndAccWithOutSC);
        Target_item__c targetItemUSAccWithOutSC = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupUS, null, accUSCountryWithoutSC, usCountry, uSChildBDA, null, false);
        targetItemUSAccWithOutSC.Id = null;
        SalesTargetItemsToInsert.add(targetItemUSAccWithOutSC);
        Target_item__c targetItemUKAccWithOutSC = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupUK, null, accUKCountryWithoutSC, ukCountry, ukChildBDA, null, false);
        targetItemUKAccWithOutSC.Id = null;
        SalesTargetItemsToInsert.add(targetItemUKAccWithOutSC);
        Target_item__c targetItemChinaAccWithOutSC = TestBusinessHelper.createSalesTargetItem(salesTargetRec, salesTargetItemGroupChina, null, accChinaCountryWithoutSC, chinaCountry, chinaChildBDA, null, false);
        targetItemChinaAccWithOutSC.Id = null;
        SalesTargetItemsToInsert.add(targetItemChinaAccWithOutSC);
        
        insert SalesTargetItemsToInsert;
        
        List<Target_Stage_Matrix__c> salesTargetStageMatrixList = new List<Target_Stage_Matrix__c>();
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelOne = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_1, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelOne.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelOne);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelOne = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_1, indChildBDA, indParentBDA, 'Integrated Sales', 'Lifestyle', false);
        matrixIndiaRegionWithSCVerticalLevelOne.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelOne);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelTwo = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_2, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelTwo.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelTwo);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelTwo = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_2, indChildBDA, indParentBDA, 'Direct Transport Sales', 'Chemicals', false);
        matrixIndiaRegionWithSCVerticalLevelTwo.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelTwo);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelThree = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_3, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelThree.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelThree);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelThree = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_3, indChildBDA, indParentBDA, 'Integrated Sales', 'Automotive', false);
        matrixIndiaRegionWithSCVerticalLevelThree.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelThree);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelFour = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_4, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelFour.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelFour);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelFour = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_4, indChildBDA, indParentBDA, 'Direct Transport Sales', 'Technology', false);
        matrixIndiaRegionWithSCVerticalLevelFour.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelFour);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelFive = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_5, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelFive.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelFive);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelFive = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_5, indChildBDA, indParentBDA, 'Key Client/Runway', 'Retail', false);
        matrixIndiaRegionWithSCVerticalLevelFive.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelFive);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelSix = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_6, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelSix.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelSix);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelSix = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_6, indChildBDA, indParentBDA, 'Key Client/Runway', 'Other', false);
        matrixIndiaRegionWithSCVerticalLevelSix.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelSix);
        
        Target_Stage_Matrix__c matrixIndiaRegionWithoutSCVerticalLevelSeven = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_7, indChildBDA, indParentBDA, '', '', false);
        matrixIndiaRegionWithoutSCVerticalLevelSeven.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithoutSCVerticalLevelSeven);
        Target_Stage_Matrix__c matrixIndiaRegionWithSCVerticalLevelSeven = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_7, indChildBDA, indParentBDA, 'Direct Transport Sales', 'FMCG Food and Beverage', false);
        matrixIndiaRegionWithSCVerticalLevelSeven.Id = null;
        salesTargetStageMatrixList.add(matrixIndiaRegionWithSCVerticalLevelSeven);
        
        Target_Stage_Matrix__c matrixUSRegionWithoutSCVerticalLevelOne = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_1, usChildBDA, uSParentBDA, '', '', false);
        matrixUSRegionWithoutSCVerticalLevelOne.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithoutSCVerticalLevelOne);
        Target_Stage_Matrix__c matrixUSRegionWithSCVerticalLevelOne = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_1, usChildBDA, uSParentBDA, 'Integrated Sales', 'Lifestyle', false);
        matrixUSRegionWithSCVerticalLevelOne.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithSCVerticalLevelOne);
        
        Target_Stage_Matrix__c matrixUSRegionWithoutSCVerticalLevelTwo = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_2, usChildBDA, uSParentBDA, '', '', false);
        matrixUSRegionWithoutSCVerticalLevelTwo.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithoutSCVerticalLevelTwo);
        Target_Stage_Matrix__c matrixUSRegionWithSCVerticalLevelTwo = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_2, usChildBDA, uSParentBDA, 'Direct Transport Sales', 'Chemicals', false);
        matrixUSRegionWithSCVerticalLevelTwo.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithSCVerticalLevelTwo);
        
        Target_Stage_Matrix__c matrixUSRegionWithoutSCVerticalLevelThree = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_3, usChildBDA, uSParentBDA, '', '', false);
        matrixUSRegionWithoutSCVerticalLevelThree.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithoutSCVerticalLevelThree);
        Target_Stage_Matrix__c matrixUSRegionWithSCVerticalLevelThree = TestBusinessHelper.createSalesTargetApprovalMatrix(salesTargetRec, TargetSettingConstants.APPROVAL_STAGE_3, usChildBDA, uSParentBDA, 'Integrated Sales', 'Automotive', false);
        matrixUSRegionWithSCVerticalLevelThree.Id = null;
        salesTargetStageMatrixList.add(matrixUSRegionWithSCVerticalLevelThree);
        
        insert salesTargetStageMatrixList;
        
        //List<Target_Reviewer__c> reviewersListToInsert = new List<Target_Reviewer__c>();
        Target_Reviewer__c reviewerLevelOneIndiaWithoutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelOne, salesUserFromIndia, false, true);
        //reviewerLevelOneIndiaWithoutSCVertical.Id = null;
        //reviewersListToInsert.add(reviewerLevelOneIndiaWithoutSCVertical);
        Target_Reviewer__c reviewerLevelOneIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelOne, salesUserFromIndia, false, true);
        //reviewerLevelOneIndiaWithSCVertical.Id = null;
        //reviewersListToInsert.add(reviewerLevelOneIndiaWithSCVertical);
        Target_Reviewer__c reviewerLevelTwoIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelTwo, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelTwoIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelTwo, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelThreeIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelThree, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelThreeIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelThree, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelFourIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelFour, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelFourIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelFour, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelFiveIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelFive, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelFiveIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelFive, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelSixIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelSix, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelSixIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelSix, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelSevenIndiaWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithSCVerticalLevelSeven, salesUserFromIndia, false, true);
        Target_Reviewer__c reviewerLevelSevenIndiaWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixIndiaRegionWithoutSCVerticalLevelSeven, salesUserFromIndia, false, true);
        
        Target_Reviewer__c reviewerLevelOneUSaWithoutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixUSRegionWithoutSCVerticalLevelOne, salesUserFromUS, false, true);
        Target_Reviewer__c reviewerLevelOneUSWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixUSRegionWithSCVerticalLevelOne, salesUserFromUS, false, true);
        Target_Reviewer__c reviewerLevelTwoUSWithSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixUSRegionWithSCVerticalLevelTwo, salesUserFromUS, false, true);
        Target_Reviewer__c reviewerLevelTwoUSWithOutSCVertical = TestBusinessHelper.createSalesTargetApprovalUser(matrixUSRegionWithoutSCVerticalLevelTwo, salesUserFromUS, false, true);
        
    }
    
    @isTest
    static void testReleaseTarget() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        }
        Test.startTest();
        update testTargets;
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLevelOne() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        }
        Validation_Rules_Bypass__c insertBypassvalidation = new Validation_Rules_Bypass__c(
            SetupOwnerId= UserInfo.getUserId(),
            Active__c= true
        );
        insert insertBypassvalidation;
        Test.startTest();
        update testTargets;
        insertBypassvalidation.Active__c = false;
        update insertBypassvalidation;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLevelTwo() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLevelThree() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLevelFour() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLeveFive() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLeveSix() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_7;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetApprovedLeveSeven() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_8;
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, null));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetWithWhereClause() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        }
        List<Target_Item__c> targetItems = [SELECT Id, Dummy_Update_For_Batch__c FROM Target_Item__c WHERE Target__c =:testTargets[0].Id ];
        for(Target_Item__c item : targetItems){
            item.Dummy_Update_For_Batch__c = true;
        }
        update targetItems;
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecords(testTargets[0].Id, ' AND Dummy_Update_For_Batch__c = true '));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        }
        List<Target_Item__c> targetItems = [SELECT Id, Dummy_Update_For_Batch__c FROM Target_Item__c WHERE Target__c =:testTargets[0].Id ];
        for(Target_Item__c item : targetItems){
            item.Dummy_Update_For_Batch__c = true;
        }
        update targetItems;
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, ' AND Dummy_Update_For_Batch__c = true ', reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel1ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Validation_Rules_Bypass__c insertBypassvalidation = new Validation_Rules_Bypass__c(
            SetupOwnerId= UserInfo.getUserId(),
            Active__c= true
        );
        insert insertBypassvalidation;
        Test.startTest();
        update testTargets;
        insertBypassvalidation.Active__c = false;
        update insertBypassvalidation;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel2ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_3;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel3ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_4;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel4ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_5;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel5ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_6;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel6ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_7;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTemp(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }
    
    @isTest
    static void testReleaseTargetLevel7ApprovedForAdditionalReviewersTempBatch() {
        List<Target__c> testTargets = [SELECT Id, Review_Stage__c FROM Target__c];
        for(Target__c tr: testTargets){
           tr.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_8;
        }
        Set<Id> reviewerIds = new Set<Id>();
        for(Target_Reviewer__c reviewers : [SELECT Id, Related_User__c from Target_Reviewer__c ]){
            reviewerIds.add(reviewers.Related_User__c);
        }
        Test.startTest();
        update testTargets;
        Database.executeBatch(new Batch_ShareRecordsTempV2(testTargets[0].Id, null, reviewerIds));
        Test.stopTest();
    }

}