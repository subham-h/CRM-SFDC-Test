/*              
* Revision Ref Number  Date        Owner                           Description
* -------- ----------  ----------- -------------------             -----------
* 1.0      RQ-005390   05-Jun-2017 Nisha@ust                     Test Class for AccountHierarchyManager
* 2.0      SFSE-14450  26-Mar-2024 Aleena@maersk                 Added for customer size
*/

@isTest
public class AccountHierarchyManager_Test {   
    @testSetup static void setup() {
        List<Account> lstConcernAccount = TestBusinessHelper.createAccounts(new List<String>{'Concern_Account','Concern_Account' },false);
        lstConcernAccount[0].Id = null;
        lstConcernAccount[0].Name = 'Test Conern 1';
        lstConcernAccount[0].SCV_Code__c = 'TestABC';

        lstConcernAccount[1].Id = null;
        lstConcernAccount[1].Name = 'Test Conern 1';
        lstConcernAccount[1].SCV_Code__c = 'TestXYZ';

        insert lstConcernAccount;
        List<Account> lstClientAccount = TestBusinessHelper.createAccounts(new List<String>{'Client_Account','Client_Account' },false);
        lstClientAccount[0].Id = null;
        lstClientAccount[0].Name = 'Test Client 1';
        lstClientAccount[0].SCV_Code__c = 'TestDEF';

        lstClientAccount[1].Id = null;
        lstClientAccount[1].Name = 'Test Client 1';
        lstClientAccount[1].SCV_Code__c = 'Test123';

        insert lstClientAccount;
    }
    /*public static testMethod void test_updateRepresentsConcern(){
        
       AccountData_Test.iNumberOfAccounts = 1;
       AccountData_Test.createConcernAccounts();
        list<Account> lstConcernAccounts = new list<Account>();  
        lstConcernAccounts =AccountData_Test.lstAccounts;
        
       AccountData_Test.iNumberOfAccounts = 2;
       AccountData_Test.createClientAccounts();
        list<Account> lstClientAccounts = new list<Account>();    
        lstClientAccounts =AccountData_Test.lstAccounts;
        
        for(Account accIterator : lstClientAccounts) {
            accIterator.ParentId = lstConcernAccounts[0].Id;
            accIterator.Represents_Concern__c  = TRUE;
        }   
        update lstClientAccounts[0];
        
        for(Account accIterator : lstClientAccounts) {
            accIterator.ParentId = lstConcernAccounts[0].Id; 
            accIterator.Represents_Concern__c  = FALSE;
        } 
        update lstClientAccounts[1];
        
        for(Account accIterator : lstClientAccounts) {         
            accIterator.Represents_Concern__c  = TRUE;
        }
        
        Test.startTest();   
        update lstClientAccounts[1];
        Test.stopTest();
        
        list<Account> lstRepresentConcernUpdated = new list<Account>([SELECT Id, Represents_Concern__c FROM Account WHERE Id =: lstClientAccounts[0].Id]);
        System.assertEquals(lstRepresentConcernUpdated[0].Represents_Concern__c,FALSE);                   
    }
    */
    static testmethod void  voidtest_updateConcern(){
        Test.startTest();
        List<Account> lstConcernAccount = [SELECT id FROM Account WHERE Recordtype.name = 'Concern Account'];
        List<Account> lstClientAccount = [SELECT id,ParentId,Represents_Concern__c FROM Account WHERE Recordtype.name = 'Client Account'];
         
        lstClientAccount[0].ParentId = lstConcernAccount[0].Id;
        lstClientAccount[0].Represents_Concern__c = true;
         
        lstClientAccount[1].ParentId = lstConcernAccount[0].Id;
        lstClientAccount[1].Represents_Concern__c = true;
        
        update lstClientAccount;

        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.ParentId = lstConcernAccount[0].Id;
        clientAccount.Represents_Concern__c = true;

        insert clientAccount;

        
        lstClientAccount[0].ParentId = lstConcernAccount[0].Id;

        update lstClientAccount;

        lstClientAccount[0].ParentId = lstConcernAccount[1].Id;
        lstClientAccount[0].Represents_Concern__c = false;

        update lstClientAccount[0];

        
        Test.stopTest();
    }

    static testmethod void  voidtest_updateConernTrue(){
        Test.startTest();
        List<Account> lstConcernAccount = [SELECT id FROM Account WHERE Recordtype.name = 'Concern Account'];
        
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        //clientAccount.ParentId = lstConcernAccount[0].Id;
        clientAccount.Represents_Concern__c = true;
        insert clientAccount;
        TriggerExecutionController.skipAllTriggers(false);
       
        clientAccount.ParentId = lstConcernAccount[0].Id;
        clientAccount.Represents_Concern__c = true;
        update clientAccount;
        
        Test.stopTest();
    }

    static testmethod void  voidtest_keyAttributesChanegs(){
        Test.startTest();
        List<Account> lstConcernAccount = [SELECT id FROM Account WHERE Recordtype.name = 'Concern Account'];
        List<Account> lstClientAccount = [SELECT id,ParentId,Represents_Concern__c FROM Account WHERE Recordtype.name = 'Client Account'];
         
        lstClientAccount[0].ParentId = lstConcernAccount[0].Id;
        lstClientAccount[0].Represents_Concern__c = true;
        lstClientAccount[0].Attractiveness__c = 'Runway';
        lstClientAccount[0].Vertical__c = 'Automotive';
        lstClientAccount[0].Industry__c = 'Banking Insurance & Financial Services';
        lstClientAccount[0].Value_Proposition__c = 'Efficiency';
        lstClientAccount[0].Sub_Segment__c = 'Local Champion';
        lstClientAccount[0].Sales_Channel__c = 'Integrated Sales';
        lstClientAccount[0].Customer_Size__c = 'Large'; 
        
        update lstClientAccount[0];

        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        clientAccount.Id = null;
        clientAccount.ParentId = lstConcernAccount[0].Id;
        clientAccount.Represents_Concern__c = true;
        clientAccount.Attractiveness__c = 'Key Client';
        clientAccount.Vertical__c =  'Lifestyle';
        clientAccount.Industry__c = 'Business Services';
        clientAccount.Value_Proposition__c = 'Ambition';
        clientAccount.Sub_Segment__c = 'Digital Innovator';
        clientAccount.Sales_Channel__c = 'Key Client/Runway';
        clientAccount.Customer_Size__c = 'Large';
        insert clientAccount;

        lstClientAccount[0].ParentId = lstConcernAccount[1].Id;
        lstClientAccount[0].Represents_Concern__c = true;

        update lstClientAccount[0];
        Test.stopTest();
    }

    static testmethod void  voidtest_updateContact(){
        Test.startTest();
        Id clientRecordTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client Account').getRecordTypeId();

        List<Account> lstConcernAccount = [SELECT id FROM Account WHERE Recordtype.name = 'Concern Account'];
        List<Account> lstClientAccount = [SELECT id,ParentId,Represents_Concern__c FROM Account WHERE Recordtype.name = 'Client Account'];
         
        
        Account clientAccount = TestBusinessHelper.createAccount('Draft_Account', true);

        

        Contact customerContactMaersk = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        customerContactMaersk.Id = null;
        customerContactMaersk.LastName = 'CustomerContactMaersk';
        customerContactMaersk.Phone = '+44 123456';
        customerContactMaersk.MobilePhone = '+44 123456';
        customerContactMaersk.OtherPhone = '+44 123456';
        customerContactMaersk.Fax = '+44 123456';
        insert customerContactMaersk;

        clientAccount.recordtypeId=clientRecordTypeId;
        clientAccount.ParentId = lstConcernAccount[0].Id;
        clientAccount.Represents_Concern__c = true;
        clientAccount.Attractiveness__c = 'Key Client';
        clientAccount.Vertical__c =  'Lifestyle';
        clientAccount.Industry__c = 'Business Services';
        clientAccount.Value_Proposition__c = 'Ambition';
        clientAccount.Sub_Segment__c = 'Digital Innovator';
        clientAccount.Sales_Channel__c = 'Key Client/Runway';
        clientAccount.Customer_Size__c = 'Large';
        update clientAccount;
        

        
        Test.stopTest();
    }
	
    static testmethod void  voidtest_setSFMCFlagUpdate(){
        Test.startTest();
        Id clientRecordTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client Account').getRecordTypeId();

        List<Account> lstConcernAccount = [SELECT id FROM Account WHERE Recordtype.name = 'Concern Account'];
        List<Account> lstClientAccount = [SELECT id,ParentId,Represents_Concern__c FROM Account WHERE Recordtype.name = 'Client Account'];
         
        lstClientAccount[0].SCV_Status__c ='Inactive';
        lstClientAccount[0].Sync_to_SFMC__c = true;
        lstClientAccount[0].SCV_Status__c = 'Inactive';

        update lstClientAccount;

        Account clientAccount = TestBusinessHelper.createAccount('Draft_Account', true);

        clientAccount.SCV_Status__c = 'Active';
        clientAccount.Sync_to_SFMC__c = false;
    

        update clientAccount;
        

        
        Test.stopTest();
    }

    static testmethod void  voidtest_setSFMCFlagInsert(){
        Test.startTest();
        

        List<Account> lstClientAccount = TestBusinessHelper.createAccounts(new List<String>{'Client_Account','Client_Account' ,'Client_Account'},false);
        lstClientAccount[0].Id = null;
        lstClientAccount[0].Name = 'Test Client abc';
        lstClientAccount[0].SCV_Code__c = 'Test980';
        lstClientAccount[0].SCV_Status__c ='Inactive';

        lstClientAccount[1].Id = null;
        lstClientAccount[1].Name = 'Test Client def';
        lstClientAccount[1].SCV_Code__c = 'Test314';
        lstClientAccount[1].Sync_to_SFMC__c = true;
        lstClientAccount[1].SCV_Status__c = 'Inactive';

        lstClientAccount[2].Id = null;
        lstClientAccount[2].Name = 'Test Client ghj';
        lstClientAccount[2].SCV_Code__c = 'Test456';
        lstClientAccount[2].Sync_to_SFMC__c = false;
        lstClientAccount[2].SCV_Status__c = 'Active';

        insert lstClientAccount;

        
        Test.stopTest();
    }

    static testmethod void voidtest_changeOwner(){
        test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        User maerskUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, false);
        User mlluser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, false);
        User sealandUser = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
        User seagoUser = TestBusinessHelper.createUser('Sales', BrandUtilities.SEAGO, false);
        maerskUser.Id = null;
        sealandUser.id = null;
        seagoUser.Id = null;
        mlluser.Id = null;
        mlluser.MLL__c= true;
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User>{maerskUser, sealandUser, seagoUser,mlluser};
        }

        List<Account> lstClientAccount = [SELECT id,ParentId,Represents_Concern__c FROM Account WHERE Recordtype.name = 'Client Account'];
        lstClientAccount[0].MSL_Account_Owner__c = maerskUser.Id;
        lstClientAccount[0].SEA_Account_Owner__c = sealandUser.Id;
        lstClientAccount[0].Seago_Account_Owner__c = maerskUser.Id;
        lstClientAccount[0].MCC_Account_Owner__c = seagoUser.Id;
    
        update lstClientAccount[0];

        TriggerExecutionController.skipAllTriggers(false);
        

        lstClientAccount[0].MSL_Account_Owner__c = sealandUser.Id;
        lstClientAccount[0].SEA_Account_Owner__c = maerskUser.Id;
        lstClientAccount[0].MLL_Account_Owner__c = mlluser.Id;
        lstClientAccount[0].Seago_Account_Owner__c = seagoUser.Id;
        lstClientAccount[0].MCC_Account_Owner__c = sealandUser.Id;
        update lstClientAccount[0];
        test.stopTest();
    }
    
}