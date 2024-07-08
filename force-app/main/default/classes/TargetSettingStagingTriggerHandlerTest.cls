/*
* Author        : Seba 
* Description   : Test class for TargetSettingStagingTrigger,TargetSettingStagingTriggerHandler, TargetSettingStagingTriggerHelper, TargetSettingUtil
*         
* Revision    Ref Number    Date           Owner                 Description
* --------    ----------    -----------    ------------------    -----------
* 1.0                       21-09-2023     Seba                  Created. 
* 
*/
@isTest
public class TargetSettingStagingTriggerHandlerTest {

    @testSetup
    static void testDataSetup(){
        
        List<Geography__c> listGeographyToInsert = new list<Geography__c>();
        Geography__c country1 = TestBusinessHelper.createGeography('India', 'Country', null,'IN',FALSE); country1.Id = null; listGeographyToInsert.add(country1);
        Geography__c country2 = TestBusinessHelper.createGeography('InvalidCountry', 'Country', null,'INVAl',FALSE); country2.Id = null;  listGeographyToInsert.add(country2);
        insert listGeographyToInsert;
            
        TriggerExecutionController.skipUserTrigger(true); 
        List<User> usersToInsert = new List<User>();
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);   
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
        }  
        System.assertNotEquals(null, adminUser.Id); 
        
        
        System.runAs(adminUser){
            User maestroInterfaceUser = TestBusinessHelper.createUser('911 - Interface (Business Intelligence)', BrandUtilities.MAERSKLINE, false);
            maestroInterfaceUser.Id = null;
            maestroInterfaceUser.IsActive=true;
            maestroInterfaceUser.country = 'India';  
            insert maestroInterfaceUser;  
        }
        
         TriggerExecutionController.skipAllTriggers(true);
            
            BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true); 
            System.assertNotEquals(null, parentBDA.Id); 
            BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
            System.assertNotEquals(null, childBDA.Id);  
            BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country1.Id, null, true);
            BDA_Geography__c bdaGeo1 = TestBusinessHelper.createBDAGeography(childBDA.Id, country2.Id, null, true);
            
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
            
            Id brandMappingRecordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Transaction_Mapping').getRecordTypeId();
            Target_Brand_Mapping__c testTargetBM = TestBusinessHelper.createSalesTargetBrandMapping(TRUE, 'Maersk Line', 'Hamburg Sud', FALSE);
            testTargetBM.RecordTypeId = brandMappingRecordTypeId;
            testTargetBM.GDA_Brand__c = 'UnknownBrand'; 
            testTargetBM.Id = NULL;
            insert testTargetBM; 
    }
    
    @isTest
    static void testTargetSettingStagingTrigger1(){ 
        User maestroInterfaceUser = [Select id from User where Profile.Name ='911 - Interface (Business Intelligence)' AND isActive = TRUE LIMIT 1];
        List<Account> listAccount = [SELECT Id,Customer_Code__c from Account];
        Target_Brand_Mapping__c tbm= [SELECT Id,GDA_Brand__c,BrandMnA__c from Target_Brand_Mapping__c ];  
        List<Target_Setting_Staging__c> lstTargetSettingStaging = new List<Target_Setting_Staging__c>();
        test.startTest(); 
        Target_Setting_Staging__c targetSettingStageTest1 = TestBusinessHelper.createTargetSettingStage('USD','Previous Year Actuals','New','Revenue','UnknownBrand',listAccount[0].Customer_Code__c,
            TRUE,'1695357018', 'IN', FALSE, TRUE, listAccount[1].Customer_Code__c,'Insurance PF','ROFOQ42023', listAccount[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest1.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest1);
        
        Target_Setting_Staging__c targetSettingStageTest2 = TestBusinessHelper.createTargetSettingStage('USD','Rolling Forecast','New','Revenue','Maersk Line',listAccount[0].Customer_Code__c,
            TRUE,'1695357018', 'TN', FALSE,  TRUE, listAccount[1].Customer_Code__c,'Insurance PF',' ', listAccount[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest2.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest2);
        
        Target_Setting_Staging__c targetSettingStageTest3 = TestBusinessHelper.createTargetSettingStage('USD','Budget','New','Revenue','UnknownBrand',listAccount[0].Customer_Code__c,
            TRUE,'1695357018', 'IN', FALSE, TRUE, listAccount[1].Customer_Code__c,'Insurance PF','ROFOQ12023', listAccount[2].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest3.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest3);
        
        Target_Setting_Staging__c targetSettingStageTest4 = TestBusinessHelper.createTargetSettingStage('USD','Budget','New','Revenue','Maersk Line',listAccount[1].Customer_Code__c,
            TRUE,'1695357018', 'MA', FALSE,  TRUE, listAccount[0].Customer_Code__c,'Insurance PF','ROFOQ12023', listAccount[4].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest4.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest4);
        
        Target_Setting_Staging__c targetSettingStageTest5 = TestBusinessHelper.createTargetSettingStage('USD','Budget','New','Revenue','Maersk Line',listAccount[1].Customer_Code__c,
            TRUE,'1695357018', 'MA', FALSE,  TRUE, listAccount[1].Customer_Code__c,'Insurance PF','ROFOQ12023', listAccount[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest5.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest5);
        
        Target_Setting_Staging__c targetSettingStageTest6 = TestBusinessHelper.createTargetSettingStage('USD','Budget','New','Revenue','Maersk Line',listAccount[1].Customer_Code__c,
            TRUE,'1695357018', 'MA', FALSE,  TRUE, listAccount[3].Customer_Code__c,'Insurance PF','ROFOQ12023', listAccount[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest6.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest6);
        
         Target_Setting_Staging__c targetSettingStageTest7 = TestBusinessHelper.createTargetSettingStage('USD','Budget','New','Revenue','Maersk Line',listAccount[0].Customer_Code__c,
            TRUE,'1695357018', 'MA', FALSE,  TRUE, listAccount[0].Customer_Code__c,'Insurance PF','ROFOQ12023', listAccount[1].Customer_Code__c, FALSE, '2023', FALSE);
        targetSettingStageTest7.Id = NULL;
        lstTargetSettingStaging.add(targetSettingStageTest7);

        System.runAs(maestroInterfaceUser){
            insert lstTargetSettingStaging;
        }
         
         
       
        test.stopTest();          
        List<Target_Setting_Staging__c> insertedTargetRec = [SELECT id from Target_Setting_Staging__c where Country_Code__c='IN'];
        System.assertEquals(insertedTargetRec.size() > 0, TRUE);
    }
    
}