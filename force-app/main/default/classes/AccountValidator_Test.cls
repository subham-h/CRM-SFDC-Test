/*
* Author   : Nisha
* Purpose  : Test class for AccountValidator 
*        
* Revision Ref Number   Date            Owner                   Description
* -------- ----------   -----------     -------------------     -----------
* 1.0       RQ-004103    13-Jul-2017     Nisha@UST              Test class for AccountValidator 
* 2.0       RQ-007439    25-Jan-2018     Nisha@UST              Added method to prevent the deletion of NSP Vendor Account.
*/

@isTest
public class AccountValidator_Test {
    public static testMethod void test_shareContract () {
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        Opportunity mslOppty2 = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null);
        Contract__c cont = new Contract__c();
        cont.Agreement_Type_Code__c = 'Credit_Agreement';
        cont.Brand_Name__c = 'Maersk Line';
        cont.Customer__c = clientAcc.Id;
        cont.Effective_Date__c = system.today();
        cont.Expiration_Date__c = system.today() + 10;
        cont.Is_FMC_Contract__c = false;
        cont.Is_Master_Contract__c = false;
        cont.Status__c = 'Draft';
        insert cont;
        system.debug('cont ' + cont);
        
        Account acc = [SELECT Id, MSL_Account_Owner__c FROM Account LIMIT 1];
        acc.MSL_Account_Owner__c = UserInfo.getUserId();
        Test.startTest();
        update acc;
        Test.stopTest();
    }
    public static testMethod void test_preventDeletionOn_ClientAndConcernAccount () {
        list<Account> lstClientAccounts = new list<Account>();
        list<Account> lstConcernAccounts = new list<Account>();
        
        AccountData_Test.iNumberOfAccounts = 5;
        AccountData_Test.createClientAccounts();
        lstClientAccounts =AccountData_Test.lstAccounts;
        
        AccountData_Test.iNumberOfAccounts = 5;
        AccountData_Test.createConcernAccounts();
        lstConcernAccounts =AccountData_Test.lstAccounts;
        
        Test.StartTest(); 
        try{
            delete  lstClientAccounts;
            delete  lstConcernAccounts;
        }
        catch(Exception e){}
        Test.StopTest(); 
        
        System.assertEquals(lstClientAccounts.size(),5);
        System.assertEquals(lstConcernAccounts.size(),5);               
    }
    
    // v2.0 :#RQ-007439 (Prevent deletion on NSP vendor accounts)
    public static testMethod void test_preventDeletionOn_VendorNonShippingPartyAccounts () {
        list<Account> lstVendorNSPAccounts = new list<Account>();
        AccountData_Test.iNumberOfAccounts = 5;
        AccountData_Test.createVendorNonShippingPartyAccounts();
        lstVendorNSPAccounts = AccountData_Test.lstAccounts;
        
        Test.StartTest(); 
        try{
            delete  lstVendorNSPAccounts;            
        }
        catch(Exception e){}
        Test.StopTest(); 
        
        System.assertEquals(lstVendorNSPAccounts.size(),5);           
    }
    
}