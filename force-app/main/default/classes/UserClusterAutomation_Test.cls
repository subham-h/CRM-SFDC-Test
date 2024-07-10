/***********************************************************************************
 * Name        : TestClean_UserClusterAutomation
 * Description : Test class to provide coverage for 
 *                 1. aINS_aUPD_LeadAccountClusterFixonClusterChange
 *                 2. aUPD_UpdateAccOwnerOn_ClusterDAOChange
 *                 3. Batch_AccountClusterFix 
 * ---------------------------------------------------------* 
 * Revision  Name                                    Date                Req Number    Description         
 * 1.0       UST                                     24.07.2014                        Updated
 * 2.0       Ranjini.Janardhanan@ust-global.com      12.02.2015          #RQ-000875    Removed profile Name hardcoding.
 * 3.0       Ranjini.Janardhanan@ust-global.com      24.06.2015          #RQ-001511    variable refernce is from TriggerUtility
 * 4.0       Sunu.Paul@ust-global.com                01.10.2015          #RQ-002042    Changed the SCV Code to 11 characters  
 * 5.0       meghana.gupta@ust-global.com            04.01.2016          #RQ-002192    Rename test class, add comments and optimization
 * 6.0       Ronnie@SF                               08.06.2022          SPI-100       Removed brand hardcoding
 ************************************************************************************/ 

@isTest
private Class UserClusterAutomation_Test {
    
    static testmethod void testUserClusterAutomation() {
        
        UserDataGeneratorHelper_Test.initializeIntegrationUser();
        
        // create cluster record
        List<BDA__c> BDAlist = DataGeneratorHelper1_Test.createBDA( 'Cluster', null, UserDataGeneratorHelper_Test.MSLintegrationUser.Id , 2);
      
        // create client account        
        Account clientAccount = AccountDataHelper_Test.createInvalidTestAccount( BDAlist.get(0).id );
    
        // Create user cluster records
        User_Cluster__c UserCluster1 = DataGeneratorHelper1_Test.createUserCluster( UserDataGeneratorHelper_Test.MSLintegrationUser.Id, BDAlist.get(0).id );
        User_Cluster__c UserCluster2 = DataGeneratorHelper1_Test.createUserCluster( UserDataGeneratorHelper_Test.SCLintegrationUser.Id, BDAlist.get(0).id );
                
        Test.startTest();
      
        UserCluster1.BDA__c = BDAlist.get(1).id;
        update UserCluster1;
        
        delete UserCluster1;
               
        //Lead l = New Lead(OwnerId = testuser.Id,FirstName = 'TestFirst', Liner_brand__c = BrandUtilities.MAERSKLINE, LastName = 'TestLast', Company = 'TestCompany', Email = 'test1234@test.com.play');
        //Insert l;

        BDAlist.get(1).Active__c = false;
        Update BDAlist.get(1);
                
        UserTriggerUtility.IsInvokedfromCreateUserCluster = False;//#RQ-001511. variable refernce is from TriggerUtility
        UserDataGeneratorHelper_Test.MSLintegrationUser.Cluster__c = BDAlist.get(0).Name;
        UserDataGeneratorHelper_Test.MSLintegrationUser.liner_brand__c = BrandUtilities.MAERSKLINE;
        update UserDataGeneratorHelper_Test.MSLintegrationUser;
             
        BDAlist.get(0).Default_Account_Owner__c =  UserDataGeneratorHelper_Test.SCLintegrationUser.Id;
        //BDAlist.get(0).SCL_Default_Account_Owner__c =  UserDataGeneratorHelper_Test.MSLintegrationUser.Id;
        
        Update BDAlist.get(0);
        
        BDAlist.get(0).Default_Account_Owner__c =  UserDataGeneratorHelper_Test.MSLintegrationUser.Id;
        Update BDAlist.get(0);
        
        //BDAlist.get(0).SCL_Default_Account_Owner__c =  UserDataGeneratorHelper_Test.SCLintegrationUser.Id;
        Update BDAlist.get(0);
                
        Test.Stoptest();   
    }
}