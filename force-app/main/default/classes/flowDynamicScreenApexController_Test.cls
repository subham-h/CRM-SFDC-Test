/*******************************************************  
 * Class Name    : flowDynamicScreenApexController_Test
 * Description   : Test class for flowDynamicScreenApexController.
 * -----------------------  Revision History -------------------
 * 
 * Sno      Version      Author         Date         Descrition                  
 * 1.       1.0          Neha-TCS      08/07/2019    Initial Development. This is created for RQ-010090
 * 2.       1.1          Nitin@Maersk  19/01/2021    SFSE-5472 fixed datasetup method to create unique user. 
 * 3.       1.2          Ronnie@SF     08/06/2022    Removed brand hardcoding
 * 4.       2.0          Kiran@Maersk  26/07/2023    New test data framework
 *********************************************************/
@isTest
private class flowDynamicScreenApexController_Test {  

    //This is the set up method for the test class
    @testSetup static void setup() {
        date dateLastUpdatedbeforesixMonths = date.newInstance(2018,06,24);     
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
        salesUser.Id = null;
        salesuser.LastName = 'flowDynamicScreenControllerTest';
        salesUser.IsActive=true;
        salesUser.country = 'India';
        salesUser.Cluster__c = 'GSC';
        salesUser.Industry_Focus__c='Retail';
        salesUser.Segment_Focus__c='Advancement';
        salesUser.Sales_Job_Function__c='Other';
        salesUser.Date_User_Last_Validated_Profile_Data__c = dateLastUpdatedbeforesixMonths;
        salesUser.CM_Visibility__c = 'Single Carrier';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert salesUser;
        }
    }
    
    // This would get the current User detail by calling the Controller method and passing the User Id
    static testMethod void test_getUserDetails() {
        User usrRecord = [Select id from User where LastName = 'flowDynamicScreenControllerTest' limit 1];
        System.runAs(usrRecord){
            Test.startTest();
                User usrRecordReturned = flowDynamicScreenApexController.getUserDetails(usrRecord.id); 
                 System.assertEquals(usrRecordReturned.Industry_Focus__c,'Retail');
            Test.stopTest();
        }
    }
    
    // This would update the current User detail by calling the Controller method and passing the User Id, Value Proposition and Vertical Focus 
    static testMethod void test_upadetUserInfo() {
        User usrRecord = [Select id from User where LastName = 'flowDynamicScreenControllerTest' limit 1];
        List<String> lstValueProposition = new List<String>{'Efficiency, Super Saver and Ease'};
        List<String> lstVerticalProposition = new List<String>{'Reefer'};
        String sfJobFunction ='Sales Rep';
        System.runAs(usrRecord){
            Test.startTest();
                User updatedUserRecord = flowDynamicScreenApexController.upadetUserInfo(usrRecord.id,lstValueProposition,lstVerticalProposition,sfJobFunction);
                updatedUserRecord = [Select id, Industry_Focus__c  from User where LastName = 'flowDynamicScreenControllerTest' limit 1];
                System.assertEquals(updatedUserRecord.Industry_Focus__c,'Reefer');                                             
            Test.stopTest();
        }
    }
    
    static testMethod void test_getselectOptions() {
        User usrRecord = new User();
        usrRecord = [Select id from User where LastName = 'flowDynamicScreenControllerTest' limit 1];        
        System.runAs(usrRecord){
            Test.startTest();
                List <String> lstOption = flowDynamicScreenApexController.getselectOptions(usrRecord,'Industry_Focus__c');
                System.assertEquals(lstOption.contains('Retail'),true);                 
            Test.stopTest();
        }
    }
}