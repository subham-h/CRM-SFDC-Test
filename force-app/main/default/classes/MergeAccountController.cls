/*
Description  :   

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          10/08/2015          meghana.gupta@ust-global.com          #RQ-000980:Code created for merging the accounts            
                                    madhava.kotte@ust-global.com
------------------------------------------------------------------------------------------------------
*/

public without sharing class MergeAccountController {

    /** * Variables used in the class.  */
    public Account draftAccount{get; set;}
    public Account primaryAccount{get; set;}   
    public boolean validUser {get; set;}
    public boolean showAccountNotFoundMsg{get; set;}
    public string searchSCVCode {get; set;}
    public Id loggedInUser {get; set;}
    private Boolean allowSysGrpMbrUsr {get;set;}
    
    
    
    /** 
    
    * Constructor.  
    
    */
    public MergeAccountController (ApexPages.StandardController controller) {
        
        Id accountId= ApexPages.currentPage().getParameters().get('id');
        draftAccount = [SELECT id,name, OwnerId, BillingStreet, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE id = :AccountId];
        loggedInUser = UserInfo.getUserId();
        searchSCVCode='';
        allowSysGrpMbrUsr = false;
        validUser = false;
        
        // Check if logged in user is owner or SysAdmin or belongs to 'Account Merge SysAdmin' group
        if (draftAccount.OwnerId == loggedInUser ){
        
            validUser = true;
            
        }
        
        if (UserInfo.getProfileId() == Label.System_Admin_Id){
        
            validUser = true;
            allowSysGrpMbrUsr = true;
            
        }
        else{
        
            //check if logged in user belongs to Account Merge SysAdmin group
            // only users added to group individually are supported. Adding roles/sub-groups is not supported.
            List<GroupMember> grpMemberLst = [select id, UserorGroupId from GroupMember 
                                        Where UserorGroupId = :LoggedInUser and groupId = :Label.Account_Merge_Admin_Group_Id];
            
            system.debug('#####grpMember'+grpMemberLst);
            
            if (grpMemberLst.size() > 0){
                
                validUser = true;
                
                allowSysGrpMbrUsr = true;
            
            }
                
        }
        
        if(validUser == false){
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.MergeAccount_UnauthorizedUser)); 
        
        }
        showAccountNotFoundMsg = false;
    }
    
    
    
    /**
    *Back To Account Custom Link Click
    */
    public pageReference BackToAccountClick(){        
        
        PageReference accountPage;
        accountPage= new PageReference('/'+ draftAccount.Id); 
        accountPage.setRedirect(true);
        return accountPage;
        
    }
    
    
    
    /**
    *For Searching the SCV code of Client Account
    */
    public pageReference SearchAccount(){
        If(searchSCVCode != NULL){
            searchSCVCode= searchSCVCode.trim();
        }
        
        system.debug('####searchSCVCode'+searchSCVCode);
        
        if (searchSCVCode == ''){
            
            showAccountNotFoundMsg = true;
            primaryAccount = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Error_Without_SCV_Code));             
        
        }
        else{
            
            if(searchSCVCode != null && searchSCVCode != ''){
            
                if( !searchSCVCode.isAlphanumericSpace()){
                        
                        showAccountNotFoundMsg = true;
                        primaryAccount = null;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.MergeAccount_AccountNotFound));
                        return Null;                
                }
            
            }

            //Dynamic SOQL Query for getting the client accounts to be merged
            string clientRcrdTypeId=system.Label.Client_Account_Record_Type_Id;
            String sqlAccount='';
            
           //allow only valid user to search SCV code
            if(validUser == true){
                
                //Dynamic SOQL Query for getting the client accounts to be merged
                string sqlAccQuery = 'SELECT id, name, SCV_Code__c, BillingStreet, BillingCity, BillingCountry, BillingPostalCode, Current_Owner__c, MSL_Account_Owner__c, SCL_Account_Owner__c, SEA_Account_Owner__c, MCC_Account_Owner__c, MLL_Account_Owner__c FROM Account WHERE SCV_Code__c =: SearchSCVCode AND recordtypeId =: clientRcrdTypeId'; 
                    
                sqlAccQuery += ' AND (SCV_Status__c = \''+ String.escapeSingleQuotes('Active') + '\' )';
                
                if(allowSysGrpMbrUsr == true){
                
                    sqlAccount = sqlAccQuery;
                    
                }else if(allowSysGrpMbrUsr == false){
                    
                    sqlAccount += sqlAccQuery;
                    
                    sqlAccount += ' AND (MSL_Account_Owner__c = :LoggedInUser OR SCL_Account_Owner__c = :LoggedInUser OR SEA_Account_Owner__c = :LoggedInUser OR MCC_Account_Owner__c = :LoggedInUser OR MLL_Account_Owner__c=:LoggedInUser)';
                    
                }
            
            }
            List<Account> lstPrimaryAccount= (List<Account>)Database.query(sqlAccount);
            
            system.debug('####accountList'+lstPrimaryAccount);
            
            if (lstPrimaryAccount == null || lstPrimaryAccount.size() == 0){
            
                showAccountNotFoundMsg = true;
                primaryAccount = null;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.MergeAccount_AccountNotFound));
        
            }
            else{
            
                showAccountNotFoundMsg = false;
                primaryAccount = lstPrimaryAccount[0];
                
                
            }
        }
        return null;
    }
    
    
    
    /**
    *Merging the draft account into client account
    */
    public pageReference MergeAccounts(){
        
        try {
        
            Database.MergeResult mrgResult = Database.merge(primaryAccount, draftAccount, false);
            
            if (mrgResult.isSuccess() == false){
            
                for(Database.Error err : mrgResult.getErrors()) {
                
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Cannot_Merge_Accounts)); 
                                  
                }
                   
            }
            else{
            
                PageReference accountPage;
                accountPage= new PageReference('/'+ primaryAccount.Id); 
                accountPage.setRedirect(true);
                return accountPage;
                
            }
            
        } catch (DmlException e) {
                 
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            
        }
        return null;
    }
    
}