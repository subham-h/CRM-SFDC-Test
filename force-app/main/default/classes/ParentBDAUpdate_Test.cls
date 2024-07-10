/**

* Test class for trigger UpdateUserTradeRegion
* Version    Date                  Modified By                       Description
* 1.0                                                       Code created 
* 2.0       21/12/2015    meghana.gupta@ust-global.com      Code optiimized as part of #RQ-002192
* 3.0       29/06/2020    meghana.gupta@ust-global.com      Code optimized to use testsetup
* 4.0       01/02/2024    Shashi@Maersk                     Code optimization as per new test data framework
*/

@isTest(SeeAllData=false)
public class ParentBDAUpdate_Test {
    
    @testSetup static void dataSetup() {
        if (UserDataGeneratorHelper_Test.MSLintegrationUser == null){
            UserDataGeneratorHelper_Test.initializeIntegrationUser(); 
        }     
        List<String> bdacodes = new List<String>{'NAM','LAM'};
        List<BDA__c> regionList = TestBusinessHelper.createBDAs('North America Area','Trade Region',bdacodes,null, null, true);
        BDA__c cluster = TestBusinessHelper.createBDA('North America Region', 'Cluster', 'NAR', null, null, true);
        List<BDA__c> clusterList = new List<BDA__c>();
        clusterList.add(cluster);
        
    	List<String> linkIds = new List<String>{'test1','test2'};  //unique IDs for linking tradeRegion and clusters in Parent BDA 
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
            
        User maerskLineUser = TestBusinessHelper.createUser(ProfileUtilities.Sales, Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
        System.runAs(new User(Id = UserInfo.getUserId())){
                maerskLineUser.Id = null;
                maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
                maerskLineUser.Cluster__c='North America Area';
                maerskLineUser.Country='United States';
                maerskLineUser.Region__c='North America Region';
                maerskLineUser.IsActive=true;
                maerskLineUser.Maersk_User_Id__c = 'SSS123';
            insert maerskLineUser;
        }
        
        List<Parent_BDA__c> parentBDA = TestBusinessHelper.createParentBDAs(clusterList, regionList, maerskLineUser,linkIds, 1, true);
    }
    
     static testmethod void testUserClusterAutomation() {
        ID profID = [SELECT Id FROM Profile WHERE Name = :ProfileUtilities.Sales LIMIT 1].Id;
        User maerskLineUser = [SELECT Id, Region__c,Liner_Brand__c,Email,CM_Visibility__c from User WHERE ProfileId = :profID and Maersk_User_Id__c =: 'SSS123' LIMIT 1];
        Parent_BDA__c recParentBDA = [Select id, Parent_BDA__c FROM Parent_BDA__c WHERE Link_ID__c = 'test1' ];
        BDA__c recRegionBDA = [SELECT id FROM BDA__c WHERE Type__c = 'Trade Region' and id != :recParentBDA.Parent_BDA__c ];
        Test.StartTest();       
        recParentBDA.Parent_BDA__c = recRegionBDA.id;        
        System.runAs(maerskLineUser){            
            update recParentBDA;
             
        }
        Test.StopTest();
    }
}