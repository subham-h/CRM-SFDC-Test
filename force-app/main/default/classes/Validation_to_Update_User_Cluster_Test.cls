/**
 * Version   Date          Owner                                    Ref Number    Description
 **************************************************************************************************************************************
 * 1.0       12/02/2015    Ranjini.Janardhanan@ust-global.com       #RQ-000875    Removed profile Name hardcoding.
 * 2.0       03-03-2017    deepak.r.mahapatra@in.ibm.com            #RQ-004643    Delete Quoting Tool Field in the User object
 * 3.0       04-04-2017    Abby.Abraham@ust-global.com              #RQ-004759    Modified test class to accomodate User Country Mandatory Validation Rule
 * 3.1	     04-06-2020	   Sidhartha@maersk.com                     SFSE-396      Upgraded API version from 26 to 48
 * 4.0       08-06-2022    Ronnie@SF                                SPI-100       Removed brand hardcoding
 */

@isTest
private class Validation_to_Update_User_Cluster_Test {
    
    //Testing of Trigger
    
    static
    {
        CreateIntegrationUserData_Test.initializeIntegrationUser();
    }   
    
    static testMethod void testValidation_to_Update_User_Cluster () {
        //id testpro=[select id from profile where Name=:Label.System_Administrator].id;
        //Creating Test Users:
        USER us=new USER();
        us.LastName='testuser';
        us.Email='abc09q32ecs@ust-global.com';
        us.Username='testusername@gg.play';
        us.CommunityNickname='testcomname';
        us.LanguageLocaleKey='en_US';
        us.LocaleSidKey='en_GB';
        us.timezonesidkey='GMT';
        us.emailencodingkey='ISO-8859-1';
        us.alias='tAls';
        us.Liner_brand__c=BrandUtilities.MAERSKLINE;
        //us.Cluster__c=CreateIntegrationUserData_Test.testBDA.Id;
        us.Cluster__c=CreateIntegrationUserData_Test.testBDA.Name;
        us.Country='Test COuntry';  // #RQ-004759    
        us.Profileid=Label.TestClean_ProfileIdsSystemAdmin;//#RQ-000875
        //us.Quoting_Tool__c = 'Quote Builder';   
        insert us;
        
        USER us2=new USER();
        us2.LastName='testuser';
        us2.Email='abccw21@ust-global.com';
        us2.Username='testusernamee@gg.play';
        us2.CommunityNickname='testcomnamew';
        us2.LanguageLocaleKey='en_US';
        us2.LocaleSidKey='en_GB';
        us2.timezonesidkey='GMT';
        us2.emailencodingkey='ISO-8859-1';
        us2.alias='tAls';
        us2.Liner_brand__c=BrandUtilities.MAERSKLINE;
        //us2.Cluster__c=CreateIntegrationUserData_Test.testBDA.Id;
        us2.Cluster__c=CreateIntegrationUserData_Test.testBDA.Name;
        us.Country='Test COuntry';  // #RQ-004759                
        us2.Profileid=Label.TestClean_ProfileIdsSystemAdmin;//#RQ-000875
        
        Geography__c geo = new Geography__c();
        geo.Name = 'TestGeography';
        geo.Type_Of_Location__c = 'Country';
        geo.GEO_ID__c = '0QK7LWQMLOXVJ';
        insert geo;
        
        //Creating Test BDA
        BDA__C testBDACluster1=new BDA__C();
        testBDACluster1.Name='test1 BDA Cluster';
        testBDACluster1.Type__c='Cluster';
        testBDACluster1.BDA_Code__c='djrtzewh';
        testBDACluster1.GEO_ID__c=geo.GEO_ID__c;
        insert testBDACluster1;
        
        BDA__C testBDACluster2=new BDA__C();
        testBDACluster2.Name='test2 BDA Cluster';
        testBDACluster2.Type__c='Cluster';
        testBDACluster2.BDA_Code__c='abcdef';
        testBDACluster2.GEO_ID__c = geo.GEO_ID__c;
        insert testBDACluster2;
        
        //Creating Test User_Cluster object
        User_Cluster__c uCluster = new User_Cluster__c();  
        uCluster.User__c = us.id;
        uCluster.BDA__c = testBDACluster1.id;
        insert uCluster;       
        
        // Testing Scenario 1    
        User_Cluster__c Cluster = new User_Cluster__c();  
        Cluster.User__c = us.id;
        Cluster.BDA__c = testBDACluster2.id;
        try {
            insert Cluster;
            system.debug('We can insert the Cluster');    
        } catch(exception e) {
            system.debug('This user already exists.So you cant add duplicate user records');
        }
        
        User_Cluster__c Cluster1 = new User_Cluster__c();  
        Cluster1.User__c = us2.id;
        Cluster1.BDA__c = testBDACluster2.id;
        try {
            insert Cluster1; 
            system.debug('We could insert the Cluster1');  
        } catch(exception e) {
            system.debug('This Cluster already exists.So you cant add duplicate user records');
        }
        
        User_Cluster__c uCluster2 = new User_Cluster__c();  
        uCluster2.User__c = us.id;
        uCluster2.BDA__c = testBDACluster2.id;
        try {
            update uCluster2;
            system.debug('We can update the Cluster2');
        } catch(exception e) {
            system.debug('We cant update the Cluster2');
        }
    }
}