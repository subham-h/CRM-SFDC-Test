/**
 * test class to cover batch class BatchUpdateAiEmailUserFlag
 *  Date           Owner                                  Description
*********************************************************************************************************************************  
 * 
 *  17/11/2023    Vivek@maersk.com                 BatchUpdateAiEmailUserFlagTest testing field updates for field AI_Email_User flag for user object
*/

@isTest public class BatchUpdateAiEmailUserFlagTest {    
    
      @testSetup static void setup() {
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        List<user> usersToInsert = new List<user>();
        User aiUser = TestBusinessHelper.createUser('102 - Customer Service', BrandUtilities.MAERSKLINE, false);
        aiUser.Id = null;
        aiUser.country = 'India';
        usersToInsert.add(aiUser);
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.country = 'India';
        usersToInsert.add(adminUser);
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert usersToInsert;
        }  
        TestBusinessHelper.createPermissionSetAssignment('Display_Email_recommendations_Pilot_Users', usersToInsert[0]);
        TestBusinessHelper.createPermissionSetAssignment('Receive_Email_Recommendations', usersToInsert[1]);

      }
    @isTest
    public static void testAiEmailFieldChange()
    {
        User createdUser = [select id from user Where isActive = true limit 1 ];
        
        System.runAs(CreatedUser)
        {
            
            Test.startTest();
            BatchUpdateAiEmailUserFlag batch = new BatchUpdateAiEmailUserFlag();
            Database.executeBatch(batch, 1);
            String sch = '0 0 2 * * ?';
            String jobID = system.schedule('BatchUpdateAiEmailUserFlagTest', sch, batch);

            Test.stopTest();   
        }     

    }
    
}