/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFSE-6847   15-09-2021  Sidhartha@maersk        Created Code.
*/
@isTest
public class UserClusterTrigger_Test {
    @testSetup static void setup() {
        if ( UserDataGeneratorHelper_Test.SuperUser == null ){     
            UserDataGeneratorHelper_Test.initializeSuperUser();  
        }
        User superUser = UserDataGeneratorHelper_Test.SuperUser;
        
        if ( UserDataGeneratorHelper_Test.salesUser == null ){     
            UserDataGeneratorHelper_Test.initializeSalesUser(); 
        } 
        User RunUser = UserDataGeneratorHelper_Test.SalesUser;
                
        BDA__c bda1 = new BDA__c (Name='Centre Function',BDA_Code__c='xx123aa',GEO_ID__c='xx123aa',Type__c='Cluster');
        insert bda1;
        
        User_Cluster__c uCluster = new User_Cluster__c();  
        uCluster.User__c = RunUser.id;
        uCluster.BDA__c = bda1.id;
        insert uCluster;  
    }
    
    public static testmethod void testCreateUserCluster() {
        User superUsr = [SELECT Id FROM User where ProfileId =: Label.Super_User_Profile_Id LIMIT 1];
        User_Cluster__c userCluster = [Select Id, User__c,BDA__c FROM User_Cluster__c LIMIT 1];    
        userCluster.User__c = superUsr.Id;
        Test.startTest();
        update userCluster;
        Test.stopTest();
        system.assertEquals(superUsr.Id, userCluster.User__c);
        
    }
    
}