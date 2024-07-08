/*
* Test class for UserTrigger, UserTriggerHandler, UserTriggerUtility
* 
*Version  Date         Owner                                    RQ#           Description
*******************************************************************************************************************************************
*1.0      11/06/2015   Ranjini.Janardhanan@ust-global.com       #RQ-001511    Created .
*2.0      20/06/2015   Sandhya.Sambasivan@ust-global.com        #RQ-001367    Dynamic list view assignment
*3.0      06/11/2015   Parvathy.Prabhash@ust-global.com         #RQ-002142    Removed testClusterCount() which tests for Cluster Count
*4.0      10/10/2016   ramadevi.palaniswamy@ust-global.com      #RQ-004412    Optimized the test classes
*5.0      03/03/2017   deepak.r.mahapatra@in.ibm.com            #RQ-004643    Delete Quoting Tool Field in the User object
*6.0      06/04/2017   abby.abraham@ust-global.com              #RQ-004759    Added Country field to users.
*7.0      06/03/2018   Junaid.Khader@ust-global.com             #RQ-007716    Added new test method testGermanUser.
*8.0      29/11/2018    Jagadeesan.sakthivel@ust-global.com     #RQ-009466    Added new test method testUserInactiveRequestInformationStatusChange 
*8.1      19/11/2018   nitin.v.more@maersk.com                  #RQ-009625    Amended testGermanUser method to replace 'KC Rep / KAO' with 'Key Client Manager'. Added testsetup method
*9.0      15/01/2019   meghana.gupta@ust-global.com             #RQ-009884    Add  method to test scenario with Last Name as null
*10.0     30-Jan-2020  manjunath@maersk                          RQ-012371    Removed references of deprecated field, User.Associated_Cluster_Count__c
*11.0     14/04/2020   Amritesh@UST	          				    #RQ-013373    Fixed bad cluster value
*12.0     28/07/2020   Manik@UST                                #SCTM-335     SCM CTM - User Assignments to Public Group
*13.0     16/10/2020   Meghana@UST								SFSE-4767 	  Replace Safmarine brand update to some other brand.
*13.1     19/01/2021   Nitin@Maersk                             SFSE-5472     Corrected unit test as group was declred but not initialised.
*13.2     30/06/2021   Nitin@Maersk                             SFSE-6249     Amended testInactive to create AccountTeamMember and OppTeamMember test data
*14.0     10/06/2022   Ronnie@SF                                SPI-100       Removed brand hardcoding
*15.0     29/06/2022   Ronnie@SF                                SPI-100       Added new test method testSetBrandLogic and removed reference to custom setting Liner_Brand_Mapping__c
*16.0	  17/07/2023   Nayana@maersk							SC-7849		  Added logic in test_SCMQueuesGroupAssignment() to test ECL
*/

@isTest(SeeAllData=false)
public class UserTrigger_Test {
    
    @testSetup static void setup() {
        
        //Create BDA test data
        BDA__c bda1 = new BDA__c (Name='Centre Function',BDA_Code__c='xx123aa',GEO_ID__c='xx123aa',Type__c='BDA');
        insert bda1;
        system.debug(bda1);
        
        Parent_BDA__c parentBDA = new Parent_BDA__c(Child_BDA__c=bda1 .id,Parent_BDA__c=bda1 .id,Link_ID__c='xx123aa');
        insert parentBDA;
        system.debug(parentBDA);
        
        // Create Geography test data
        List<Geography__c> lstGeographyToInsert = new List<Geography__c>();
        lstGeographyToInsert.add(new Geography__c(Name = 'testcountry', Active__c =true, GEO_Code__c = 'IN0', GEO_ID__c = '10Z2W9Zkjh3q4in0', Is_Port__c = false, Type_Of_Location__c = 'Country'));
        lstGeographyToInsert.add(new Geography__c(Name = 'Germany', Active__c =true, GEO_Code__c = 'DE', GEO_ID__c = '10Z2W9Zkjh3q4aDE', Is_Port__c = false, Type_Of_Location__c = 'Country'));
        
        insert lstGeographyToInsert;
        
        Group mlGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'SFU_All_MSL_Users' LIMIT 1];
        Group mccGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'ALL_MCC_Users' LIMIT 1];
        //Group safGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'SFU_All_SCL_Users' LIMIT 1];
        Group seaGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'ALL_SEA_Users' LIMIT 1];
        Group sglGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'All_Seago_Users' LIMIT 1];
        Group allSalesUsersGroupRec = [SELECT Id, Name FROM Group WHERE DeveloperName = 'All_Sales_Users' LIMIT 1];
        //added by rama
        Group singleCarrier = [SELECT Id, Name FROM Group WHERE DeveloperName = 'SFU_All_Single_Carrier_Users' LIMIT 1];        
        Group multiCarrier = [SELECT Id, Name FROM Group WHERE DeveloperName = 'SFU_All_Multi_Carrier_Users' LIMIT 1];
        Group unilver4PL = [SELECT Id from Group WHERE DeveloperName = 'SFU_All_4PL_Unilever_Users' LIMIT 1];
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1];
        
        
        // create custom setting User Group Assignment
        List<User_Group_Assignment__c> lstUserGroupAssignmentToInsert = new List<User_Group_Assignment__c>();
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = BrandUtilities.MAERSKLINE, Public_Group_Ids__c = mlGroupRec.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = BrandUtilities.MCC, Public_Group_Ids__c = mccGroupRec.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = BrandUtilities.SEALAND, Public_Group_Ids__c = seaGroupRec.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = BrandUtilities.SEAGO, Public_Group_Ids__c = sglGroupRec.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = salesProfile.Id, Public_Group_Ids__c = allSalesUsersGroupRec.Id));
        //added by rama
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = 'Single Carrier', Public_Group_Ids__c = singleCarrier.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(Name = 'Multi-Carrier', Public_Group_Ids__c = multiCarrier.Id));
        lstUserGroupAssignmentToInsert.add(new User_Group_Assignment__c(User_Field__c ='SF_4PL_Account__c', Name = 'Unilever', Public_Group_Ids__c = unilver4PL.Id ));
        
        insert lstUserGroupAssignmentToInsert;
    }
    
    
    /*To test the User Cluster creation for users*/
    public static testmethod void testUserCluster() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
      
        List<User> testUsers = new List <User> ();
        Set<Id> userIdSet = new Set<Id>();
        for(Integer i=1000; i< 1010; i++){
            
            User systemAdminUser= new User();                 
            systemAdminUser.FirstName ='Cluster'+i;                 
            systemAdminUser.LastName ='User'+i;                 
            systemAdminUser.Username ='user'+i+'Cluster'+i+'@hello.com';                 
            systemAdminUser.Email ='ting@maersk.com';                 
            systemAdminUser.Alias ='tl'+i;                 
            systemAdminUser.CommunityNickname ='clst'+i;                 
            systemAdminUser.TimeZoneSidKey ='Europe/London';                 
            systemAdminUser.LocaleSidKey ='en_GB';                 
            systemAdminUser.EmailEncodingKey ='ISO-8859-1';                 
            systemAdminUser.ProfileId = Label.TestClean_ProfileIdsSystemAdmin; 
            systemAdminUser.Country = recGeo.Name;               
            systemAdminUser.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            //systemAdminUser.Quoting_Tool__c = 'Quote Builder';                 
            systemAdminUser.LanguageLocaleKey='en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            testUsers.add(systemAdminUser);
            
        }
        
        System.runAs (thisUser) {
            test.startTest();
            insert testUsers;
            test.stopTest();                   
            For(User u : testUsers){
                userIdSet.add(u.Id);
            }
            
            List<User> createdUsers = [Select Id, Cluster__c, Region__c FROM User Where Id IN :userIdSet ];        
            List<User_Cluster__c> userClusterList = [Select Id, User__c,BDA__c FROM User_Cluster__c Where User__c IN :userIdSet];           
            System.assertEquals(testUsers.size(), userClusterList.size());
        }
    }
    
    
    
    /*To test the User Cluster creation for users*/
    public static testmethod void testBlankCluster() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        
        List<User> testUsers = new List <User> ();
        Set<Id> userIdSet = new Set<Id>();
        for(Integer i=50; i< 79; i++){
            
            User systemAdminUser= new User();                 
            systemAdminUser.FirstName ='Cluster'+i;                 
            systemAdminUser.LastName ='User'+i;                 
            systemAdminUser.Username ='user'+i+'Cluster'+i+'@hello.com';                 
            systemAdminUser.Email ='ting@maersk.com';                 
            systemAdminUser.Alias ='tclst'+i;                 
            systemAdminUser.CommunityNickname ='clst'+i;                 
            systemAdminUser.TimeZoneSidKey ='Europe/London';                 
            systemAdminUser.LocaleSidKey ='en_GB';                 
            systemAdminUser.EmailEncodingKey ='ISO-8859-1';                 
            systemAdminUser.ProfileId = Label.TestClean_ProfileIdsSystemAdmin; 
            systemAdminUser.Country = recGeo.Name;                
            systemAdminUser.Cluster__c = 'Centre Function'; //'France Area';
            //systemAdminUser.Quoting_Tool__c = 'Quote Builder';                 
            systemAdminUser.LanguageLocaleKey='en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            testUsers.add(systemAdminUser);
            
        }
        
        System.runAs (thisUser) {
            test.startTest();
            insert testUsers;
            test.stopTest();                   
            System.assertEquals(testUsers[0].Region__c, null);
        }
    }
    
    
    public static testmethod void testGermanUser() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeoGermany = [SELECT Id, Name FROM Geography__c WHERE Name = 'Germany' LIMIT 1];
        
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1]; 
        User systemAdminUser= new User();                 
        systemAdminUser.FirstName ='Fed';                 
        systemAdminUser.LastName ='User';                 
        systemAdminUser.Username ='userfFed@hello.com';                 
        systemAdminUser.Email ='ting@maersk.com';                 
        systemAdminUser.Alias ='tfedd';                 
        systemAdminUser.CommunityNickname ='fedd';                 
        systemAdminUser.TimeZoneSidKey ='Europe/London';                 
        systemAdminUser.LocaleSidKey ='en_GB';                 
        systemAdminUser.EmailEncodingKey ='ISO-8859-1';                 
        systemAdminUser.ProfileId = UserInfo.getProfileId();
        systemAdminUser.Country = recGeoGermany.Name; //'Germany';                 
        systemAdminUser.Cluster__c = 'Centre Function'; 
        //systemAdminUser.Quoting_Tool__c = 'Quote Builder';                 
        systemAdminUser.LanguageLocaleKey='en_US';      
        systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        systemAdminUser.FederationIdentifier = 'QWERTY654';
        systemAdminUser.Sales_Job_Function__c = 'KC Sales Rep';
        System.runAs (thisUser) {
            insert systemAdminUser;   
            systemAdminUser.ProfileId  = salesProfile.Id;
            systemAdminUser.CM_Visibility__c  = 'Single Carrier';//SC-394,SC-554 
            update systemAdminUser;
        }
    }
    
    
    
    /*To test the Fed id lower case */
    public static testmethod void testFedId() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        
        List<User> testUsers = new List <User> ();
        Set<Id> userIdSet = new Set<Id>();
        for(Integer i=50; i< 79; i++){
            
            User systemAdminUser= new User();                 
            systemAdminUser.FirstName ='Fed'+i;                 
            systemAdminUser.LastName ='User'+i;                 
            systemAdminUser.Username ='user'+i+'Fed'+i+'@hello.com';                 
            systemAdminUser.Email ='ting@maersk.com';                 
            systemAdminUser.Alias ='tfed'+i;                 
            systemAdminUser.CommunityNickname ='fed'+i;                 
            systemAdminUser.TimeZoneSidKey ='Europe/London';                 
            systemAdminUser.LocaleSidKey ='en_GB';                 
            systemAdminUser.EmailEncodingKey ='ISO-8859-1';                 
            systemAdminUser.ProfileId = Label.TestClean_ProfileIdsSystemAdmin;
            systemAdminUser.Country = recGeo.Name;                 
            systemAdminUser.Cluster__c = 'Centre Function'; //'France Area';
            //systemAdminUser.Quoting_Tool__c = 'Quote Builder';                 
            systemAdminUser.LanguageLocaleKey='en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            systemAdminUser.FederationIdentifier = 'QWERTY65'+i;
            testUsers.add(systemAdminUser);
            
        }
        
        System.runAs (thisUser) {
            test.startTest();
            //UserTriggerHandler.beforeRun = true; #RQ-002142
            insert testUsers;
            test.stopTest();   
            User createdUser = [Select Id,FederationIdentifier FROm User WHERE Id =: testUsers[0].Id];
            System.assertEquals(createdUser.FederationIdentifier, 'qwerty6550');
            
        }
    }
    
    
    /*To test the last active date*/
    public static testmethod void testInactive() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];

        TriggerExecutionController.skipOpportunityTrigger(true);
        Account testClientAcc = AccountDataHelper_Test.createClientAccount();        
        Opportunity testMSLOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( testClientAcc.id, null);
        //TriggerExecutionController.skipCaseTrigger(false);

        List<User> testUsers = new List <User> ();
        Set<Id> userIdSet = new Set<Id>();
        for(Integer i=50; i< 60; i++){
            
            User systemAdminUser= new User();                 
            systemAdminUser.FirstName ='Inactive'+i;                 
            systemAdminUser.LastName ='User'+i;                 
            systemAdminUser.Username ='user'+i+'Inactive'+i+'@hello.com';                 
            systemAdminUser.Email ='ting@maersk.com';                 
            systemAdminUser.Alias ='tina'+i;                 
            systemAdminUser.CommunityNickname ='ina'+i;                 
            systemAdminUser.TimeZoneSidKey ='Europe/London';                 
            systemAdminUser.LocaleSidKey ='en_GB';                 
            systemAdminUser.EmailEncodingKey ='ISO-8859-1';                 
            systemAdminUser.ProfileId = Label.TestClean_ProfileIdsSystemAdmin; 
            systemAdminUser.Country = recGeo.Name;                
            systemAdminUser.Cluster__c = 'Centre Function'; 
            systemAdminUser.LanguageLocaleKey='en_US';      
            systemAdminUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            systemAdminUser.FederationIdentifier = 'QWARTY23'+i;
            testUsers.add(systemAdminUser);
            
        }
        
        System.runAs (thisUser) {
            test.startTest();
            insert testUsers;
            //test.stopTest();
            
            // test inactivating users
            
            User utest = [Select Id, Last_Active_On__c, isActive from User where Id=:testUsers[0].Id limit 1];
            AccountTeamMember testATM = new AccountTeamMember(AccountId=testClientAcc.Id, TeamMemberRole='Team Member', userId=utest.Id); 
            insert testATM;
            OpportunityTeamMember testOTM = new OpportunityTeamMember(OpportunityId=testMSLOppty.Id, TeamMemberRole='Team Member', userId=utest.Id);
            insert testOTM;

            utest.isActive = false;
            update utest;
            System.assertEquals(testUsers[0].LastModifiedDate, utest.Last_Active_On__c);
            
            // test re-activating user
            
            utest.IsActive = true;
            update utest;
            test.stopTest();
            System.assertEquals(null, utest.Last_Active_On__c);
            
        }
        
    }
    
    
    // #RQ-001367 - Start 
    /* Test Bulk load 10 users with Support Countries. */
    public static testmethod void testBulkDynamicInsertUser(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
        
        User salesTestUser; 
        Group testGroup;
        List<User>userList = new List<User>();
         Set<Id>userIdSet = new Set<Id>();
        //Check if public group exists, if not create it for testing
        List<Group> testGroupList = [SELECT Name, DeveloperName 
                                     FROM Group 
                                     WHERE DeveloperName  =: Label.TestClean_PublicGroupNameMSL_BE]; 
        
        System.debug('# testGroupList : ' + testGroupList);
        if(testGroupList == null || testGroupList.size() == 0){
            testGroup.Name  = Label.TestClean_PublicGroupNameMSL_BE;
            testGroup.DeveloperName = Label.TestClean_PublicGroupNameMSL_BE;
            Database.insert(testGroup);
        }
        else{
            testGroup = testGroupList[0];
        }
        
        
        //System.debug('# label TestClean_PublicGroupNameMSL_BE: ' + Label.TestClean_PublicGroupNameMSL_BE);
        
        for(Integer i=1001 ; i<=1010 ;i++){ // 10 user records
            
            salesTestUser = new User();                 
            salesTestUser.FirstName = 'TestName';                 
            salesTestUser.LastName = 'Sales User'+i;                 
            salesTestUser.Username = 'TestSalesUser'+i+'@ust-global.com';                 
            salesTestUser.Email = 'TestSalesUser'+i+'@ust-global.com';                
            salesTestUser.Alias = 'u'+i;                 
            salesTestUser.CommunityNickname = 'st'+i;                 
            salesTestUser.TimeZoneSidKey = 'Europe/London';                 
            salesTestUser.LocaleSidKey = 'en_GB';                 
            salesTestUser.EmailEncodingKey = 'ISO-8859-1';                 
            salesTestUser.ProfileId = Label.TestClean_ProfileIdsSales;                 
            salesTestUser.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            salesTestUser.Country = recGeo.Name;
            //salesTestUser.Quoting_Tool__c = 'AFLS;Quote Builder';                   
            salesTestUser.LanguageLocaleKey = 'en_US';      
            salesTestUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salesTestUser.Support_Countries__c = 'Belgium (BE)';  
            salesTestUser.CM_Visibility__c = '4PL';  //SC-4505
            salesTestUser.SF_4PL_Account__c = 'Unilever';
            
            userList.add(salesTestUser);
            
        }
        System.runAs (thisUser) { 
            Test.startTest();
            insert userList; //Insert 10 users
            for(User u : userList){
                u.CM_Visibility__c = 'Single Carrier';
                u.SF_4PL_Account__c = ''; //SC-4505
                userIdSet.add(u.Id);
            }
            //UserTriggerHandler.afterRun = true; #RQ-002142
            Database.update(userList); //Update users with Support COuntry as Germany
            Test.Stoptest();  
        }
        
       
        for(User u : userList){
            userIdSet.add(u.id); //Get Ids of users
        }
        
        System.debug('# userIdSet: ' + userIdSet);
        //Query the Group member which will be created by code
        List<GroupMember> grpMemberList = [SELECT Id, GroupId, UserOrGroupId 
                                           FROM GroupMember  
                                           WHERE GroupId=: testGroup.Id AND UserOrGroupId IN: userIdSet];
        
        //Verify if group member list size is 10.                        
        System.assertEquals(10, grpMemberList.size());
    }
    
    
    /* Test Bulk update of  10 users with Support Countries.*/
    public static testmethod void testBulkDynamicUpdateUser(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
        
        List<User>userList = new List<User>();
        User salesTestUser; 
        Set<Id>userIdSet = new Set<Id>();
        Group testGroupDE = new Group();
        Group testGroupBE = new Group();
        
        //Check if public group exists, if not create it for testing
        List<Group> testGroupListBE = [SELECT Name, DeveloperName 
                                       FROM Group 
                                       WHERE DeveloperName  =: Label.TestClean_PublicGroupNameMSL_BE]; 
        if(testGroupListBE == null || testGroupListBE.size() == 0){
            testGroupBE.Name  = Label.TestClean_PublicGroupNameMSL_BE;
            testGroupBE.DeveloperName = Label.TestClean_PublicGroupNameMSL_BE;
            Database.insert(testGroupBE);
        }
        else{
            testGroupBE = testGroupListBE[0];
        }
        //Check if public group exists, if not create it for testing
        List<Group> testGroupListDE = [SELECT Name, DeveloperName 
                                       FROM Group 
                                       WHERE DeveloperName  =: Label.TestClean_PublicGroupNameMSL_DE]; 
        if(testGroupListDE == null || testGroupListDE.size() == 0){
            testGroupDE.Name  = Label.TestClean_PublicGroupNameMSL_DE;
            testGroupDE.DeveloperName = Label.TestClean_PublicGroupNameMSL_DE;
            Database.insert(testGroupDE);
        }
        else{
            testGroupDE = testGroupListDE[0];
        }
        
        for(Integer i=1001 ; i<=1010;i++){
            
            salesTestUser = new User();                 
            salesTestUser.FirstName = 'TestName';                 
            salesTestUser.LastName = 'Sales User'+i;                 
            salesTestUser.Username = 'TestSalesUser'+i+'@ust-global.com';                 
            salesTestUser.Email='TestSalesUser'+i+'@ust-global.com';                
            salesTestUser.Alias = 'u'+i;                 
            salesTestUser.CommunityNickname = 'st'+i;                 
            salesTestUser.TimeZoneSidKey = 'Europe/London';                 
            salesTestUser.LocaleSidKey = 'en_GB';                 
            salesTestUser.EmailEncodingKey = 'ISO-8859-1';                 
            salesTestUser.ProfileId = Label.TestClean_ProfileIdsSales; 
            salesTestUser.Country = recGeo.Name;                
            salesTestUser.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            //salesTestUser.Quoting_Tool__c = 'AFLS;Quote Builder';                   
            salesTestUser.LanguageLocaleKey = 'en_US';      
            salesTestUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salesTestUser.Support_Countries__c = 'Belgium (BE)';  
            salesTestUser.CM_Visibility__c = 'Single Carrier';//SC-394,SC-554        
            userList.add(salesTestUser);
            
        }
        System.runAs (thisUser) { 
            Test.startTest();
            Database.insert(userList); //Insert users with Support Country as Belgium  
            for(User u : userList){
                u.Support_Countries__c = 'Germany (DE)';
                u.CM_Visibility__c = 'Single Carrier';//SC-394,SC-554 
                userIdSet.add(u.Id);
            }
            //UserTriggerHandler.afterRun = true; #RQ-002142
            Database.update(userList); //Update users with Support COuntry as Germany
            Test.Stoptest();  
        }
        
        for(User u : userList ){
            userIdSet.add(u.Id);
        }
        
        //Query the Group members which will be created by code
        List<GroupMember> grpMember = [SELECT Id, GroupId, UserOrGroupId 
                                       FROM GroupMember  
                                       WHERE GroupId=: testGroupDE.Id AND UserOrGroupId IN: userIdSet];
        
        //Verify if group member list size is 10                     
        System.assertEquals(10, grpMember.size());
    }
    
    
    /* Test bulk update of  100 users with Support Countries. */
    public static testmethod void testBulkDynamicUpdateUser_withNoSupportCountries(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
        
        User salesTestUser; 
        Group testGroup;
        List<User>userList = new List<User>();
        Set<Id> userIdSet= new Set<Id>();
        
        //Check if public group exists, if not create it for testing
        List<Group> testGroupList = [SELECT Name, DeveloperName 
                                     FROM Group 
                                     WHERE DeveloperName  =: Label.TestClean_PublicGroupNameMSL_BE]; 
        if(testGroupList == null || testGroupList.size() == 0){
            testGroup.Name  = Label.TestClean_PublicGroupNameMSL_BE;
            testGroup.DeveloperName = Label.TestClean_PublicGroupNameMSL_BE;
            Database.insert(testGroup);
        }
        else{
            testGroup = testGroupList[0];
        }
        
        for(Integer i=1001 ; i<=1010 ;i++){ // 10 user records
            
            salesTestUser = new User();                 
            salesTestUser.FirstName = 'TestName';                 
            salesTestUser.LastName = 'Sales User'+i;                 
            salesTestUser.Username = 'TestSalesUser'+i+'@ust-global.com';                 
            salesTestUser.Email = 'TestSalesUser'+i+'@ust-global.com';                
            salesTestUser.Alias = 'u'+i;                 
            salesTestUser.CommunityNickname = 'st'+i;                 
            salesTestUser.TimeZoneSidKey = 'Europe/London';                 
            salesTestUser.LocaleSidKey = 'en_GB';                 
            salesTestUser.EmailEncodingKey = 'ISO-8859-1';                 
            salesTestUser.ProfileId = Label.TestClean_ProfileIdsSales; 
            salesTestUser.Country = recGeo.Name;               
            salesTestUser.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            //salesTestUser.Quoting_Tool__c = 'AFLS;Quote Builder';                   
            salesTestUser.LanguageLocaleKey = 'en_US';      
            salesTestUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salesTestUser.Support_Countries__c = 'Belgium (BE)';    
            salesTestUser.CM_Visibility__c = 'Single Carrier'; //SC-394,SC-554 
            
            userList.add(salesTestUser);
            
        }
        System.runAs (thisUser) { 
            // Test.startTest();
            Database.insert(userList); //Insert users with Support Country as Belgium  
            for(User u : userList){
                u.Support_Countries__c = '';
                userIdSet.add(u.Id);
            }
            //UserTriggerHandler.afterRun = true; #RQ-002142
            Test.startTest();
            Database.update(userList); //Update users with Support COuntry as Germany
            Test.Stoptest();  
        }
        
        //Query the Group member which will be created by code
        List<GroupMember> grpMemberList = [SELECT Id, GroupId, UserOrGroupId 
                                           FROM GroupMember  
                                           WHERE GroupId=: testGroup.Id AND UserOrGroupId IN: userIdSet];
        
    }
    
    
    /* Test bulk update of Liner Brand of 10 users .*/
    public static testmethod void testBulkDynamicUpdateUser_LinerBrand(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug('# thisUser: ' + thisUser);
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        System.debug('# recGeo: ' + recGeo);
        List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
		System.debug('# clusterRegionList: ' + clusterRegionList);
        
        List<User>userList = new List<User>();
        User salesTestUser; 
        Set<Id>userIdSet = new Set<Id>();
        
        Group testGroupBE_MSL = new Group();
        
        //Check if public group exists, if not create it for testing
        List<Group> testGroupList_BE_MSL = [SELECT Name, DeveloperName 
                                            FROM Group 
                                            WHERE DeveloperName  =: Label.TestClean_PublicGroupNameMSL_DE];
        System.debug('# testGroupList_BE_MSL: ' + testGroupList_BE_MSL);
        
        if(testGroupList_BE_MSL == null || testGroupList_BE_MSL.size() == 0){
            testGroupBE_MSL.Name  = Label.TestClean_PublicGroupNameMSL_DE;
            testGroupBE_MSL.DeveloperName = Label.TestClean_PublicGroupNameMSL_DE;
            Database.insert(testGroupBE_MSL);
        }
        else{
            testGroupBE_MSL = testGroupList_BE_MSL[0];
        }
                
        for(Integer i=1401 ; i<=1410 ;i++){
            
            salesTestUser = new User();                 
            salesTestUser.FirstName = 'TestName';                 
            salesTestUser.LastName = 'Sales User'+i;                 
            salesTestUser.Username = 'TestSalesUser'+i+'@ust-global.com';                 
            salesTestUser.Email='TestSalesUser'+i+'@ust-global.com';                
            salesTestUser.Alias = 'u'+i;                 
            salesTestUser.CommunityNickname = 'st'+i;                 
            salesTestUser.TimeZoneSidKey = 'Europe/London';                 
            salesTestUser.LocaleSidKey = 'en_GB';                 
            salesTestUser.EmailEncodingKey = 'ISO-8859-1';                 
            salesTestUser.ProfileId = Label.TestClean_ProfileIdsSales; 
            salesTestUser.Country = recGeo.Name;                
            salesTestUser.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            //salesTestUser.Quoting_Tool__c = 'AFLS;Quote Builder';                   
            salesTestUser.LanguageLocaleKey = 'en_US';      
            salesTestUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salesTestUser.Support_Countries__c = 'Germany (DE)';  
            salesTestUser.CM_Visibility__c = 'Single Carrier';//SC-394,SC-554 
            userList.add(salesTestUser);
            
        }
        
        System.runAs (thisUser) { 
            Test.startTest();
            Database.insert(userList); //Insert users with Support Country as Germany 
            
            for(User u : userList){
                u.Liner_Brand__c = BrandUtilities.SEAGO;
                userIdSet.add(u.Id);
            }
            //UserTriggerHandler.afterRun = true; #RQ-002142
            Database.update(userList); //Update users with Seago Liner Brand
            Test.Stoptest();
        }
        
        for(User u : userList ){
            userIdSet.add(u.Id);
        }
        
        //query users to check liner brand is updated
        List<User> ulist = [SELECT Id, Name, Liner_Brand__c 
                            FROM User  
                            WHERE Id =: userIdSet AND Liner_Brand__c = :BrandUtilities.SEAGO];
        
        //Verify if user list size is 10                     
        System.assertEquals(10, ulist.size());
        
    }
    // #RQ-001367 - End
    
    // #RQ-009466 - Start - test method to cover the UserUtilities.changeRequestInformationStatus() code 
    public static testmethod void testUserInactiveRequestInformationStatusChange(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        RateSheetData_Test.createRequestData();
        
        Test.StartTest();
        UserDataGeneratorHelper_Test.SystemAdminUser.isActive = false;
        System.runAs (thisUser) { 
            Database.Update(UserDataGeneratorHelper_Test.SystemAdminUser);
        }       
        Test.StopTest();
        
        // Query the request information records related to the UserDataGeneratorHelper_Test.SystemAdminUser and verify the change status value change
        List<Request_Information__c> reqInfoList = [SELECT Id, Change_Status__c, User__c FROM Request_Information__c];
        for(Request_Information__c reqInfo: reqInfoList){
            System.assertEquals('Remove', reqInfo.Change_Status__c);
        }   
        
    }
    // #RQ-009466 - End
    
    /* RQ-009884 - Test user creation with no last name */
    public static testmethod void UserWithBlankLastName(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        
        User salesTestUser = new User();                 
        salesTestUser.FirstName = 'TestName NoLastName';                                  
        salesTestUser.Username = 'TestSalesUser@test.com';                 
        salesTestUser.Email='TestSalesUser@test.com';                
        salesTestUser.Alias = 'uTest';                 
        salesTestUser.CommunityNickname = 'stest';                 
        salesTestUser.TimeZoneSidKey = 'Europe/London';                 
        salesTestUser.LocaleSidKey = 'en_GB';                 
        salesTestUser.EmailEncodingKey = 'ISO-8859-1';                 
        salesTestUser.ProfileId = Label.TestClean_ProfileIdsSales; 
        salesTestUser.Country = recGeo.Name;                
        salesTestUser.LanguageLocaleKey = 'en_US';      
        salesTestUser.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        
        System.runAs (thisUser) { 
            Test.startTest();
            try{
                
                Database.insert(salesTestUser); 
            }catch(exception ex){}
            
            Test.Stoptest();
        }        
        
    }
    // RQ-009884 - Ends
    
    public static testMethod void test_ChatQueueAndGroupAssignment()
    {
        
        UserData_Test.bCreate  = false;
        list<User>  lstUsers  = new list<User>();
        UserData_Test.createCustomerUsers();
        lstUsers = UserData_Test.lstUsers;
        
        for(User usrRec : lstUsers){
            usrRec.Chat_Queues__c = 'MSL CS - Algeria (DZ);MSL CS - Austria (AT)'; 
            usrRec.CM_Visibility__c = 'Multi-Carrier';//SC-394,SC-554 
            usrRec.UserPermissionsLiveAgentUser = true;
        }
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        Test.startTest();
        
        insert lstUsers;
        list<GroupMember> lstGrMember = [SELECT  Id, GroupId FROM GroupMember WHERE  UserOrGroupId =:lstUsers[0].Id];
        System.assert(lstGrMember != null);
        
        for(User usrRec : lstUsers){
            usrRec.Chat_Queues__c = 'MSL CS - Andorra (AD);Technical - English';  
            usrRec.UserPermissionsLiveAgentUser = true;
            usrRec.CM_Visibility__c = 'Multi-Carrier';//SC-394,SC-554
            usrRec.IsActive = true;
            //usrRec.LS_TM_SCM_Queues__c = 'Argentina (AR)'; //SCTM-335 
            //usrRec.Liner_Brand__c = BrandUtilities.MAERSKLS;
            //usrRec.Email=usrRec.LastName + '@lns.maersk.com'; 
        }
        
        update lstUsers;
        
        for(User usrRec : lstUsers){
            usrRec.Chat_Queues__c = null;
        }
        
        //Test.startTest();
        update lstUsers;
        Test.stopTest();
        }
        
        list<GroupMember> lstGrMembers = [SELECT  Id, GroupId FROM GroupMember WHERE  UserOrGroupId =:lstUsers[0].Id];
        
    }
    
    public static testMethod void test_SCMQueuesGroupAssignment() {
        
        UserData_Test.bCreate  = false;
        list<User>  lstUsers  = new list<User>();
        UserData_Test.createCustomerusers();
        lstUsers = UserData_Test.lstUsers;
        
        for(User usrRec : lstUsers){
            usrRec.CM_Visibility__c = 'Multi-Carrier';
            usrRec.LS_TM_SCM_Queues__c = 'Argentina (AR)'; //SCTM-335
            usrRec.Liner_Brand__c = BrandUtilities.MAERSKLS;
            usrRec.Email=usrRec.LastName + '@lns.maersk.com'; 
            usrRec.L_S_Queues__c = 'Argentina (AR)';
            usrRec.M_A_queues__c = 'E-Fulfillment CX Europe (EUR);E-Delivery CX NAM (NAM)'; //SC-7849
        }
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        insert lstUsers;
        Test.startTest();            
            for(User usrRec : lstUsers){
                usrRec.LS_TM_SCM_Queues__c = null; //SCTM-335
                usrRec.SCM_KC_Country_Area__c = null;
                usrRec.L_S_Queues__c = null;
                usrRec.M_A_queues__c = null;
            }
            lstUsers[0].L_S_Queues__c = 'Australia (AU)';            
            update lstUsers;
        Test.stopTest();
        }
    } 
    
    
    //Unit test SCM KC Account Scenarios
    public static testMethod void test_SCMQueuesGroupAssignment2() {
        
        UserData_Test.bCreate  = false;
        list<User>  lstUsers  = new list<User>();
        UserData_Test.createCustomerusers();
        lstUsers = UserData_Test.lstUsers;
        
        for(User usrRec : lstUsers){
            usrRec.CM_Visibility__c = 'Multi-Carrier';
            usrRec.LS_TM_SCM_Queues__c = 'Adidas'; //SCTM-335
            usrRec.SCM_KC_Country_Area__c = 'China (CN)';
            usrRec.Liner_Brand__c = BrandUtilities.MAERSKLS;
            usrRec.Email=usrRec.LastName + '@lns.maersk.com'; 
            usrRec.L_S_Queues__c = 'Argentina (AR)';
        }
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        insert lstUsers;
        Test.startTest();            
        for(User usrRec : lstUsers){
            usrRec.LS_TM_SCM_Queues__c = null; //SCTM-335
            usrRec.SCM_KC_Country_Area__c = null;
            usrRec.L_S_Queues__c = null;
        }
        lstUsers[0].L_S_Queues__c = 'Australia (AU)';
        update lstUsers;
        Test.stopTest();
        }
    }
    
    // Test method for UserTriggerUtility.setBrandLogic(), which stores all brands from User.Liner_Brand__c to User.Brand_Logic__c
    public static testMethod void testSetBrandLogic() {
        UserData_Test.bCreate = false;
        List<User> lstUsers = new List<User>();
        UserData_Test.createCustomerusers();
        lstUsers = UserData_Test.lstUsers;
        
        for (Integer i = 0; i < lstUsers.size(); i++) {
            User u = lstUsers[i];
            if (i == 0) {
                u.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            } else if (i == 1) {
                u.Liner_Brand__c = BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MLL;
            } else if (i == 2) {
                u.Liner_Brand__c = BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MCC + ';' + BrandUtilities.SEAGO + ';' + BrandUtilities.SEALAND;
            } else {
                u.Liner_Brand__c = BrandUtilities.MAERSKLS;
            }
            u.FirstName = 'BrandLogic00' + i;
        }
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        Test.startTest();
        insert lstUsers;
        List<User> updatedUsers = [SELECT Id, FirstName, Liner_Brand__c, Brand_Logic__c FROM User WHERE FirstName LIKE 'BrandLogic00%'];
        
        for (User u : updatedUsers) {
            System.assertEquals(u.Liner_Brand__c, u.Brand_Logic__c, 'Brand has not been copied to text field.');
        }
        Test.stopTest();
        }
    }

    public static testMethod void test_ServiceResourceAutomation()
    {

        UserData_Test.bCreate  = false;
        list<User>  lstUsers  = new list<User>();
        UserData_Test.createCustomerUsers();
        lstUsers = UserData_Test.lstUsers;

        for(User usrRec : lstUsers){
            usrRec.Chat_Queues__c = 'MSL CS - Algeria (DZ);MSL CS - Germany (DE)'; 
            usrRec.CM_Visibility__c = 'Multi-Carrier';//SC-394,SC-554 
            usrRec.UserPermissionsLiveAgentUser = true;
        }
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        Test.startTest();

        insert lstUsers;        
        for(User usrRec : lstUsers){
            usrRec.isActive = false;           
        }

        update lstUsers;
        Test.stopTest();
        }

        list<GroupMember> lstGrMembers = [SELECT  Id, GroupId FROM GroupMember WHERE  UserOrGroupId =:lstUsers[0].Id];

    }  

    public static testMethod void testCloneMirrorUserFields() {
         User saviyntUser = [SELECT Id,Username FROM User WHERE Username like '%saviynt.interface@maersk.com%'];
         Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
      	 List<Parent_BDA__c> clusterRegionList = [Select Id, Parent_BDA__c, Child_BDA__c, Parent_BDA__r.Name, Child_BDA__r.Name FROM  Parent_BDA__c LIMIT 2];
       	 List<User> existingUserId = [Select Id,Maersk_User_Id__c,UserRoleId FROM User Where isActive=true limit 1];
         String MaerskId=existingUserId[0].Maersk_User_Id__c;
         List<User> testUsers = new List<User>();
        // Set<Id> userIdSet = new Set<Id>();
          for(Integer i=0; i<5; i++){
            
            User usrRec= new User();                 
            usrRec.FirstName ='test'+i;                 
            usrRec.LastName ='User'+i;                 
            usrRec.Username ='saviynt.interface@maersk.com'+i;                 
            usrRec.Email ='vamsidhar.ande@maersk.com';
            usrRec.ProfileId = UserInfo.getProfileId();
            usrRec.EmailEncodingKey ='ISO-8859-1';                
            usrRec.CommunityNickname ='Savynt'+i;   
            usrRec.Alias ='tl'+i;                 
            usrRec.Country = recGeo.Name;               
            usrRec.Liner_Brand__c = BrandUtilities.MAERSKLS;
            usrRec.Mirrored_Access__c=MaerskId;
            usrRec.Cluster__c = clusterRegionList[0].Child_BDA__r.Name;
            usrRec.TimeZoneSidKey ='Europe/London';                 
            usrRec.LocaleSidKey ='en_GB';                 
            usrRec.LanguageLocaleKey='en_US';      
          testUsers.add(usrRec);
            
        }
        
        System.runAs (saviyntUser) {
            test.startTest();
            insert testUsers; 
            test.stopTest(); 
            User createdUser = [Select UserRoleId FROM User Where Id =:testUsers[0].ID];
          //  System.assertEquals(existingUserId[0].UserRoleId,createdUser.UserRoleId);
     
        }
    }
    
    public static testmethod void testassignEditDefaultPricesPermissionset(){
		test.startTest();
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1];
        User testuser = [Select id, Name, Country, IsActive, Sales_Job_Function__c from User where IsActive =: true and ProfileId =: salesProfile.Id limit 1];
        Geography__c recGeo = [SELECT Id, Name FROM Geography__c WHERE Name = 'testcountry' LIMIT 1];
        testuser.Sales_Job_Function__c = 'Product Organization';
        testuser.Country = recGeo.Name;
        testuser.IsActive = true;
        Update testuser;
        PermissionSetAssignment psa = [Select AssigneeId from PermissionSetAssignment where PermissionSet.Name =: 'Edit_Default_Prices' and AssigneeId =: testuser.Id];
        System.assertEquals(psa.AssigneeId, testuser.Id);
        testuser.Sales_Job_Function__c = 'Other';
        Update testuser;
        List<PermissionSetAssignment> psa1 = [Select AssigneeId from PermissionSetAssignment where PermissionSet.Name =: 'Edit_Default_Prices' and AssigneeId =: testuser.Id];
        System.assertEquals(0, psa1.size());
        test.stopTest();
    }
}