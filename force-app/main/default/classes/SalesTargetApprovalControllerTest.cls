/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0	   SFSE-11482   03-Oct-2023   Vinay					 Test Class for SalesTargetApprovalController.
*/
@istest
public class SalesTargetApprovalControllerTest {
    
    @testSetup
    static void setupMethod(){
        Map<String, User> mapUsers= TestBusinessHelper.createUsers(new List<String>{'Sales','System Administrator'}, 'MaerskLine', true);
        Geography__c testCountry = new Geography__c();
        BDA__c testCluster = new BDA__C ();
        BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
        List<Account> listAccounts = new List<Account>();
        BDA__c bdaArea = new BDA__c();
        
        //Running as Admin User
        system.runAs(mapUsers.values()[1]){
            
            Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
            concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
            concernAccount.Id=NULL;
            insert concernAccount;
            Assert.isNotNull(concernAccount.Id);
            
            Account Acc1 = new Account();
            Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
            Acc1.Customer_Code__c='TEST445655';	
            Acc1.Id=NULL;
            Acc1.SCV_Status__c='Active';
            Acc1.ParentId=concernAccount.Id;
            listAccounts.add(Acc1);
            
            Account Acc2 = new Account();
            Acc2 = TestBusinessHelper.createAccount('Client_Account',False);
            Acc2.Customer_Code__c='TEST445654';	
            Acc2.Id=NULL;
            Acc2.ParentId=concernAccount.Id;
            Acc2.SCV_Status__c='Active';
            listAccounts.add(Acc2);                        
            
            Account representConcernAcc = TestBusinessHelper.createAccount('Client_Account',False);
            representConcernAcc.Customer_Code__c='TEST445651';
            representConcernAcc.Represents_Concern__c=TRUE;
            representConcernAcc.ParentId=concernAccount.Id;
            representConcernAcc.Id=NULL;
            representConcernAcc.MSL_Account_Owner__c = UserInfo.getUserId();
            listAccounts.add(representConcernAcc);
            
            insert listAccounts;
            
            
            testCountry.Name = 'India';
            testCountry.Active__c =true;
            testCountry.GEO_Code__c = 'IN';
            testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
            testCountry.Is_Port__c = false;
            testCountry.Type_Of_Location__c = 'Country';
            insert testCountry;
            
            
            testCluster.Name = 'West Africa Area';
            testCluster.Type__c = 'Cluster';
            testCluster.BDA_Code__c = 'WAF';
            testCluster.GEO_ID__c= 'dsaewetwer';
            testCluster.Active__c  =  true;
            insert testCluster;  
            
            
            bdaGeo.BDA__c = testCluster.Id;
            bdaGeo.Geography__c = testCountry.Id;
            insert bdaGeo;            
        }
        
        Target__c target = TestBusinessHelper.createSalesTarget(mapUsers.values()[1],'3000', 'USD','Monthly', true); 
        
        system.runAs(mapUsers.values()[0]){
            
            Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(target, BrandUtilities.MAERSKLINE, testCountry, bdaGeo, '4PL PF', true);
            Assert.isNotNull(targetItemGroup.Id);
            
            List<Target_Item__c> listItems = new List<Target_Item__c>();
            Target_Item__c item = TestBusinessHelper.createSalesTargetItem(target, targetItemGroup, null, listAccounts[0], null, null, null, FALSE);
            item.Id = NULL;
            listItems.add(item);
            
            Target_Item__c item1 = TestBusinessHelper.createSalesTargetItem(target, targetItemGroup, null, listAccounts[1], null, null, null, FALSE);
            item1.Id = NULL;
            listItems.add(item1);
            
            insert listItems;
        }
        Target_Stage_Matrix__c stageMatrix = TestBusinessHelper.createSalesTargetApprovalMatrix(target,TargetSettingConstants.APPROVAL_STAGE_1,testCluster, null, '', '', true);
        Target_Reviewer__c reviewer = TestBusinessHelper.createSalesTargetApprovalUser(stageMatrix,mapUsers.values()[0],true,true);
    }
    
    // Method that submits target to Approval.
    @istest
    static void validateCurrentUser(){
        
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Assert.areEqual(1, tr.size());
        
        List<User> users = [SELECT Id,Email FROM User WHERE Email=:'salesmaerskline@maersk.com' OR
                            Email=:'systemadministratormaerskline@maersk.com'];
        Assert.areEqual(2, users.size());
        
        User salesUser, AdminUser;
        for(User usr: users){
            if(usr.Email=='salesmaerskline@maersk.com'){
                salesUser = usr; 
            }
            else{
                AdminUser = usr;   
            }
        } 
        system.debug(AdminUser.Id);                
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Target__c= tr[0].Id;	
        insert tx;
        Assert.isNotNull(tx.Id);
        
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = salesUser.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        list<Id> listItems = new list<Id>();
        for(Target_Item__c item: [SELECT Id,Global_Account_Owner__c FROM Target_Item__c WHERE Target__c=: tr[0].Id]){
            listItems.add(item.Id);  
        }        
        Assert.areEqual(2, listItems.size());
        
        Target_Item__Share share = new Target_Item__Share();
        share.UserOrGroupId = AdminUser.Id;
        share.ParentID  = listItems[0];
        share.AccessLevel ='Edit';
        insert share;
        
        Test.startTest();  
        system.runAs(salesUser){
            //Calling class to cover Target Stage is In Progress.
            SalesTargetApprovalController.validateCurrentUser(tr[0].Id);
            
            //Calling the Class after updating the Target Stage to 1st stage of approval.
            Target__c tar = tr[0];
            tar.Stage_Status__c=TargetSettingConstants.STATUS_IN_PROGRESS;
            tar.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
            update tar;
            
            // Manually pushing to 2nd stage of approval.
            tar.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_2;
            update tar;
            
            SalesTargetApprovalController.validateCurrentUser(tr[0].Id); 
        }
        
        // Calling the Class in Second stage of Approval, Admin is a GAO for one of its Account.
        system.runAs(AdminUser){
            SalesTargetApprovalController.validateCurrentUser(tr[0].Id);            
        }
        
        Test.stopTest();   
        
    }
    
    // Method that covers when all items are same as Target Stage yet user tries to approve.
    @isTest
    static void allItemsAreUpdated(){
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Assert.areEqual(1, tr.size());
        
        User salesUser=[SELECT Id,Email FROM User WHERE Email = 'salesmaerskline@maersk.com' LIMIT 1];
        
        Target_Stage_Matrix__c tx = new Target_Stage_Matrix__c();
        tx.Target_Stage__c=TargetSettingConstants.APPROVAL_STAGE_1;
        tx.Target__c= tr[0].Id;	
        insert tx;
        Assert.isNotNull(tx.Id);
        
        Target_Reviewer__c Trv = new Target_Reviewer__c();
        Trv.Related_User__c = salesUser.Id;
        Trv.Target_Approval_Matrix__c = tx.Id;
        insert Trv;
        
        Test.startTest();  
        system.runAs(salesUser){
            Target__c tar = tr[0];
            tar.Stage_Status__c=TargetSettingConstants.STATUS_IN_PROGRESS;
            tar.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
            update tar;
            
            
            list<Target_Item__c> listItems = new list<Target_Item__c>();
            for(Target_Item__c item: [SELECT Id,Review_Stage__c FROM Target_Item__c WHERE Target__c=: tr[0].Id]){
                item.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
                listItems.add(item);  
            }
            
            update listItems;
            SalesTargetApprovalController.validateCurrentUser(tr[0].Id);
            
        }
        Test.stopTest();
        
        
    }
    
    // test Method to Check Logged in User Authentication.
    @isTest
    static void checkUnAuthorized(){
        User salesUser = [SELECT Id,Email FROM User WHERE Email = 'salesmaerskline@maersk.com' LIMIT 1];
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c]; 
        Assert.areEqual(1,tr.Size());
        Test.startTest();
        Target__c tar = tr[0];
        tar.Status__c=TargetSettingConstants.STATUS_IN_PROGRESS;
        tar.Review_Stage__c = TargetSettingConstants.APPROVAL_STAGE_1;
        update tar;	
        System.runAs(salesUser) {
            SalesTargetApprovalController.validateCurrentUser(tr[0].Id);                
        }
        SalesTargetApprovalController.validateCurrentUser(tr[0].Id);
        Test.stopTest();
    }
    
    // Test Method to Call Batch
    @isTest
    static void updateTargetItems(){
        List<Target__c> tr =[SELECT Id,Review_Stage__c,Status__c,CreatedById FROM Target__c];
        Assert.areEqual(1,tr.Size());
        Test.StartTest();
        SalesTargetApprovalController.updateTargetItems(tr[0].Id, false);
        Test.StopTest();
    }
    
    @isTest
    static void testItems() {
        User salesUser = [SELECT Id,Email FROM User WHERE Email = 'salesmaerskline@maersk.com' LIMIT 1];
        Target__c target = [SELECT Id, Review_Stage__c, Status__c FROM Target__c LIMIT 1];
        target.Review_Stage__C = TargetSettingConstants.APPROVAL_STAGE_1;
        update target;
        target.Review_Stage__C = TargetSettingConstants.APPROVAL_STAGE_2;
        target.Status__C = TargetSettingConstants.STATUS_IN_PROGRESS;
        update target;
        Test.startTest();
        System.runAs(salesUser) {
            SalesTargetApprovalController.validateCurrentUser(target.Id);                
        }        
        Test.stopTest();
    }
    
    
}