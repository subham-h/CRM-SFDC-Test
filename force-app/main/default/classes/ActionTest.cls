/*********************************************************************************************************
 *
 * Description : 
 *
 * Date          Owner                            Ref Number     Description
 ***********************************************************************************************************
 * 15/11/2022     Bharti.rana@maersk.com          SFSE-7819      Test Class for Action Trigger
 * 
 ***********************************************************************************************************/ 



@isTest
public class ActionTest {
    
    @testSetup static void setup() {
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        Account UnAssignedAccount = AccountDataHelper_Test.createUnassignedAccount();
         User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser ;
		 User RunUserSeago = UserDataGeneratorHelper_Test.SeagoIntegrationUser;
      
        Contact TestCon2 =ContactDataGeneratorHelper_Test.createInternalContact(  UnAssignedAccount.Id, BrandUtilities.MAERSKLINE);
		//creating internal  contact 
		Contact TestCon1 =  new Contact();
        TestCon1.LastName = 'Test Class Contact1' + Math.random();
        TestCon1.FirstName = 'Internal2';
        TestCon1.Email = 'InternalContact2@maersk.com';
        TestCon1.Preferred_Language__c = 'English';
        
        TestCon1.AccountId = UnAssignedAccount.id;
        TestCon1.Liner_Brands__c = 'Seago' ; 
        TestCon1.Unique_User_ID__c = 'TTT124'; 
        
        System.runAs(UserDataGeneratorHelper_Test.IntegrationUser){
            Database.Insert(TestCon1);
        }       
          
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
        
         Id recordTypeId = Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName().get('Internal').getRecordTypeId();
        Stakeholder__c extStake1 = new Stakeholder__c(Internal_Stakeholder__c = TestCon2.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        Stakeholder__c extStake2 = new Stakeholder__c(Internal_Stakeholder__c = TestCon1.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
       
         Action__c act = new Action__c(Name= 'test', Account_Plan__c = bp.id,OwnerId= RunUser.Id);
         List<Action__c> action = new List<Action__c>{act};
             Database.insert(action,false);
        List<Stakeholder__c> exStakeList = new List<Stakeholder__c>{extStake1,extStake2};
            Database.insert(exStakeList, false);
        
    }
     static testmethod void TestAction(){  
        Test.StartTest();
        List<User> userList = [Select Id from User where Maersk_User_id__c ='INT006' Limit 1];
        List<Action__c> actionList = [SELECT ID, OwnerId FROM Action__c Limit 1];
         actionList[0].OwnerId = userList[0].Id;
         try{
        update actionList;
         }catch(exception e){
             System.debug('Error is'+e.getMessage());
             
         }
    
    
    

}
}