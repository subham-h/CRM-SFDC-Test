/**
* Test class for MergeAccountController
*
* Version    Date                  Modified By                       Description
* 1.0       17/08/2015    meghana.gupta@ust-global.com      Code created as part of #RQ-00980.
* 2.0       20/11/2015    meghana.gupta@ust-global.com      RQ-002192 - Rename test class, add comments and optimization
* 
*/

@isTest
private class MergeAccountController_Test {
    
    static testMethod void testMergeAccount() {
        
        //create draft & client account
        Account clientAccount = AccountDataHelper_Test.createClientAccount();         
        Account draftAccount = AccountDataHelper_Test.createDraftAccount();         
        
        Test.startTest();
        
        //set page reference to MergeAccount that uses controller MergeAccountController
        PageReference pgRef = new PageReference( '/apex/MergeAccount?id=' + draftAccount.id );
        Test.setCurrentPage( pgRef );         
        
        // initialize controller
        ApexPages.StandardController cntller = new Apexpages.Standardcontroller( draftAccount );
        MergeAccountController MergeContrller = new MergeAccountController ( cntller );
        
        // Test 'Back To Account' link click
        MergeContrller.BackToAccountClick();
        
        // Test scenario when SCV code is not entered and Search button is clicked
        MergeContrller.SearchSCVCode = ' ' ;
        MergeContrller.SearchAccount();
        
        // Test scenario when incorrect SCV code entered and Search button is clicked
        MergeContrller.SearchSCVCode = ' !!@#' ;
        MergeContrller.SearchAccount();
        
        // Test scenario when a valid SCV code is entered but client account corresponding to logged in user's ownership is not present and Search button is clicked
        MergeContrller.SearchSCVCode = '000Test' ;
        MergeContrller.SearchAccount();
        
        //Test scenario when a valid SCV code corresponding to logged in user's owned client account is entered and Search is clicked
        // clientAccount.MSL_Account_Owner__c = UserInfo.getUserId();
        // update clientAccount;
        
        System.runAs( UserDataGeneratorHelper_Test.MSLsalesUser ){
            
            MergeContrller.SearchSCVCode = clientAccount.SCV_Code__c ;
            MergeContrller.SearchAccount();
            
           
        }
        
         //Test Merge of draft account into client account as System Admin
            MergeContrller.MergeAccounts(); 
        
        // If merge is successful draft account will be deleted. Hence below SOQL should return 0 records
        List<Account> draftAcc_Deleted = [ Select id, name from Account where id = :draftAccount.id ];
        System.AssertEquals ( draftAcc_Deleted.isEmpty(), true );
        
        Test.stopTest();
        
    }
    
    // Test merge account as a sales user 
    static testMethod void testMergeAccountAsSales() { 
    
        //create draft & client account     
        Account clientAccount = AccountDataHelper_Test.createClientAccount();         
        Account draftAccount = AccountDataHelper_Test.createDraftAccount();         
        
        System.runAs( UserDataGeneratorHelper_Test.salesUser ){
            
            Test.startTest();
            
            //set page reference to MergeAccount that uses controller MergeAccountController       
            PageReference pgRef = new PageReference( '/apex/MergeAccount?id=' + draftAccount.id );
            Test.setCurrentPage( pgRef );   

            // initialize controller
            ApexPages.StandardController cntller = new Apexpages.Standardcontroller( draftAccount );
            MergeAccountController MergeContrller = new MergeAccountController ( cntller );            
            
            // Sales user should not be allowed to merge accounts
            System.AssertEquals ( MergeContrller.validUser, false );        
            
            Test.stopTest();
            
        }   
    }
    
    // Test merge account as an account owner
    static testMethod void testMergeAccountAsAccountOwner() {
        
        //create draft & client account
        Account clientAccount = AccountDataHelper_Test.createClientAccount();                 
        Account draftAccount = AccountDataHelper_Test.createDraftAccount( UserDataGeneratorHelper_Test.salesUser );
            
        System.runAs( UserDataGeneratorHelper_Test.salesUser ){   
        
            Test.startTest();
            
            //set page reference to MergeAccount that uses controller MergeAccountController                  
            PageReference pgRef = new PageReference( '/apex/MergeAccount?id=' + draftAccount.id );
            Test.setCurrentPage( pgRef );         
            
            // initialize controller
            ApexPages.StandardController cntller = new Apexpages.Standardcontroller( draftAccount );
            MergeAccountController MergeContrller = new MergeAccountController ( cntller );
            
            MergeContrller.SearchSCVCode = '000Test';
            MergeContrller.SearchAccount();
            
            // since the sales user is also account owner , user should be able to user Merge functionality
            System.AssertEquals ( MergeContrller.validUser, true );        
            
            Test.stopTest();
        }   
    }    
    
    // Test merge account as member of group Account Merge Admins
    static testMethod void testMergeAccountAsGroupMember() {  
        
        //create draft & client account
        Account clientAccount = AccountDataHelper_Test.createClientAccount();         
        Account draftAccount = AccountDataHelper_Test.createDraftAccount( UserDataGeneratorHelper_Test.salesUser );
        
        // Add sales user to group 'Account Merge Admins'
        UserDataGeneratorHelper_Test.AddUserToGroup(UserDataGeneratorHelper_Test.salesUser.id, ID.valueof(Label.Account_Merge_Admin_Group_Id));
        
        System.runAs(UserDataGeneratorHelper_Test.salesUser){
       
            Test.startTest();
            
            //set page reference to MergeAccount that uses controller MergeAccountController
            PageReference pgRef = new PageReference( '/apex/MergeAccount?id=' + draftAccount.id );
            Test.setCurrentPage( pgRef );         
            
            // initialize controller
            ApexPages.StandardController cntller = new Apexpages.Standardcontroller( draftAccount );
            MergeAccountController MergeContrller = new MergeAccountController ( cntller );
            
            System.AssertEquals ( MergeContrller.validUser, true );   
            
            Test.stopTest();
            
        }
    }
}