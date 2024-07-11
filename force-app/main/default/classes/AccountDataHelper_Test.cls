/**
* Helper class for generating Test data for all types of Account.

* Date         Owner                                   Description
**************************************************************************************************************************************
* 14/10/2014   Deepa.Raman@ust-global.com              #RQ-000917 Move ALL test data generation to Helper classes.
* 20/11/2015   meghana.gupta@ust-global.com            #RQ-002192 Use Maersk Id fields to populate Export/Import Reps or Owner fields
* 02/12/2015   Sunu.Paul@ust-global.com                #PR-0055-Added MLL,MCC,Seago Account Owners. 
* 10/02/2016   Sunu.Paul@ust-global.com                #RQ-002978-Added SuperUser
* 31/03/2016   Madhava.kotte@ust-global.com            #RQ-002301:OpportunityTrigger Refactoring
* 30/03/2017   Nisha.arjunan@ust-global.com            #RQ-005057 Updated createNonShippingPartyAccount(), return nonShipPartyAccount instead of draftAccount, fix
* 25/09/2017   Uvais.Komath@ust-global.com             #RQ-005677 Removed reference to Account.Cluster_Name__c sa part of field deprecation
* 23/09/2019    Neha -TCS                              #RQ-007086Removed the limit 6 from Query at line 61 where Account Record type are being queries since now there are 7 record types.
* 12-Nov-2019  manjunath@maersk                        #RQ-012362 Removed reference of Account.Commercial_Leader__c
* 3-June - 2020 Rakesh@maersk                           #SFSE-397   Inserting Geography record
*/
        
public class AccountDataHelper_Test {          
   
    public static Account clientAccount = null;
    public static Account concernAccount = null;
    public static Account unAssignedAccount = null;
    public static Account draftAccount = null;
    public static Account nonShipPartyAccount = null ;
    public static User integrationTestUser = null;
    public static Account testAccountMSL,testAccountSEA,testNamedAccount;
    public static AccountTeamMember acctMbrObj,acctMbrSEAObj;
    public static Bda__c bdObj = null;
   
    //Call method to create Test Users
    static 
    {
        if (UserDataGeneratorHelper_Test.integrationUser == null){
            
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        
        }
        
        if ( UserDataGeneratorHelper_Test.salesUser == null){
            
            UserDataGeneratorHelper_Test.initializeSalesUser();
        
        }
        
        /*if ( UserDataGeneratorHelper_Test.SuperUser == null){//#RQ-002978
            
        UserDataGeneratorHelper_Test.initializeSuperUser();//#RQ-002978
         
        }*///#RQ-002978
        //UserDataGeneratorHelper_Test.initializeSystemAdminUser();
    } 
    
    
    
    
    /**
    * Method to get Record Types of Account to create Accounts.
    **/ 
    public static Map<String, ID> getAccountRecordType () {
    
        Map<String, ID> accRT = new Map<String, ID> ();
        /*for(RecordType r : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account']) {
            accRT.put(r.Name, r.Id);
        }*/
        Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> rtInfo = accountDescribe.getRecordTypeInfos();
        for(Schema.RecordTypeInfo recordtype : rtInfo){
            accRT.put( recordtype.name , recordtype.getRecordTypeId());
        }
        return accRT;
    }
    
    public static Map<String, ID> accountRecordTypeMap = getAccountRecordType ();  
    
    
    /**
    * Method to create Client Account
    **/     
    /*
    public static Account createClientAccount(){   
    
        clientAccount = createClientAccount( null, 'Active');
        return clientAccount;

    }
    
    public static Account createClientAccount( Id bdaId, String scvStatus ){ 
    
        system.debug('####### Inside createClientAccount');
    
        clientAccount = new Account ();        
        clientAccount.Name = 'Test Class Client Account';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Code__c = '11223344';
        clientAccount.SCV_Status__c = scvStatus;
        clientAccount.RecordTypeId = accountRecordTypeMap.get('Client Account');
        
       clientAccount.MSL_Export_Rep_Maersk_Id__c  = UserDataGeneratorHelper_Test.MSLsalesUser.Maersk_User_Id__c  ;  //Export Rep for MSL  is auto-populated based on this field
       clientAccount.SCL_Export_Rep_Maersk_Id__c  = UserDataGeneratorHelper_Test.SCLsalesUser.Maersk_User_Id__c ;        
       clientAccount.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAsalesUser.id ; //Brand Account Owner for SEA 
       clientAccount.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;//Brand Account Owner for MCC//#PR-0055 
       clientAccount.MLL_Account_Owner__c = UserDataGeneratorHelper_Test.MLLIntegrationUser.id;  //Brand Account Owner for MLL//#PR-0055   
       clientAccount.Seago_Account_Owner__c = UserDataGeneratorHelper_Test.SeagoIntegrationUser.id;//Brand Account Owner for Seago//#PR-0055      
        
        if (bdaId != null){
            
            clientAccount.Cluster_Name__c = bdaId;
        
        }
        
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
        
            insert clientAccount;
        
        }
        
        return clientAccount;
    }
    */
    public static Account createClientAccount(){   
    
        clientAccount = createClientAccount( null, 'Active', '10000045402');
        return clientAccount;

    }
    public static Account createClientAccount( Id bdaId, String scvStatus ){ 
        
        clientAccount = createClientAccount( bdaId, scvStatus, null );
        return clientAccount;    
        
    }
    
     public static Account createClientAccountwithCountry( Id bdaId, String scvStatus, id geoid ){ 
    
        system.debug('####### Inside createClientAccount');
    
        clientAccount = new Account ();        
        clientAccount.Name = 'Test Class Client Account';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Status__c = scvStatus;
        clientAccount.RecordTypeId = accountRecordTypeMap.get('Client Account');
        clientAccount.Country__c = geoid;
        
       clientAccount.MSL_Account_Owner__c  = UserDataGeneratorHelper_Test.MSLsalesUser.Id  ;  
       //clientAccount.SCL_Account_Owner__c  = UserDataGeneratorHelper_Test.SCLsalesUser.Id ;        
       clientAccount.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAsalesUser.id ; //Brand Account Owner for SEA 
       clientAccount.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;//Brand Account Owner for MCC//#PR-0055 
       clientAccount.MLL_Account_Owner__c = UserDataGeneratorHelper_Test.MLLIntegrationUser.id;  //Brand Account Owner for MLL//#PR-0055   
       clientAccount.Seago_Account_Owner__c = UserDataGeneratorHelper_Test.SeagoIntegrationUser.id;//Brand Account Owner for Seago//#PR-0055      
       /*
        if (bdaId != null){
            
            clientAccount.Cluster_Name__c = bdaId;
        
        }
        */
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
        
            insert clientAccount;
        
        }
        
        return clientAccount;
    }


    public static Account createClientAccount( Id bdaId, String scvStatus, String SCVCode ){ 
    
        system.debug('####### Inside createClientAccount');
        insert new Geography__c(Name='London', Active__c =true);    //#SFSE-397
        clientAccount = new Account ();        
        clientAccount.Name = 'Test Class Client Account';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Code__c = SCVCode;
        clientAccount.SCV_Status__c = scvStatus;
        clientAccount.RecordTypeId = accountRecordTypeMap.get('Client Account');
        clientAccount.BillingCity = 'London';
        clientAccount.BillingStreet = 'test street 123';
        clientAccount.MSL_Account_Owner__c  = UserDataGeneratorHelper_Test.MSLsalesUser.Id  ;  
        //clientAccount.SCL_Account_Owner__c  = UserDataGeneratorHelper_Test.SCLsalesUser.Id ;        
        clientAccount.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAsalesUser.id ; //Brand Account Owner for SEA 
        clientAccount.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;//Brand Account Owner for MCC//#PR-0055 
        clientAccount.MLL_Account_Owner__c = UserDataGeneratorHelper_Test.MLLIntegrationUser.id;  //Brand Account Owner for MLL//#PR-0055   
        clientAccount.Seago_Account_Owner__c = UserDataGeneratorHelper_Test.SeagoIntegrationUser.id;//Brand Account Owner for Seago//#PR-0055      
        clientAccount.Represents_Concern__c= true;
        
        /*
        if (bdaId != null){
            
            clientAccount.Cluster_Name__c = bdaId;
        
        }
        */
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
        
            insert clientAccount;
        
        }
        
        return clientAccount;
    }

    
    
     //To create client account with MSL user
    public static void createClientAccountWithMSLUser(){
        System.debug('###### inside helper');
        testAccountMSL = new Account ();
        testAccountMSL.Name = 'Test Account - MSL User';
        testAccountMSL.Type = 'BCO' ;
        testAccountMSL.RecordTypeId = accountRecordTypeMap.get('Client Account');
        testAccountMSL.Owner = UserDataGeneratorHelper_Test.MSLIntegrationUser; //Account owner as MSL user            
        System.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            
            Database.insert(testAccountMSL);
            
        }
        
    }
    
    public static Account createClntAccountWithMSLUser(){
        createClientAccountWithMSLUser();
        return testAccountMSL;
    }
    //RQ-004168
    //To create client account with MSL user
    public static void createClientNamedAccount(){
        testNamedAccount = new Account ();
        testNamedAccount.Name = 'Test Account - MSL User';
        testNamedAccount.Type = 'BCO' ;
        testNamedAccount.RecordTypeId = accountRecordTypeMap.get('Client Account');
          
        testNamedAccount.MSL_Account_Owner__c  = UserDataGeneratorHelper_Test.MSLsalesUser.Id  ;  //Export Rep for MSL  is auto-populated based on this field
        //testNamedAccount.SCL_Account_Owner__c  = UserDataGeneratorHelper_Test.SCLsalesUser.Id ;        
        testNamedAccount.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAsalesUser.id ; //Brand Account Owner for SEA 
        testNamedAccount.MCC_Account_Owner__c = UserDataGeneratorHelper_Test.MCCIntegrationUser.id;//Brand Account Owner for MCC//#PR-0055 
        testNamedAccount.MLL_Account_Owner__c = UserDataGeneratorHelper_Test.MLLIntegrationUser.id;  //Brand Account Owner for MLL//#PR-0055   
        testNamedAccount.Seago_Account_Owner__c = UserDataGeneratorHelper_Test.SeagoIntegrationUser.id;//Brand Account Owner for Seago//#PR-0055      
        testNamedAccount.Owner = UserDataGeneratorHelper_Test.MSLIntegrationUser; //Account owner as MSL user            
        System.runAs(UserDataGeneratorHelper_Test.MSLIntegrationUser){
            Database.insert(testNamedAccount);
             
        }
        
    }
    
    // create test account for invalid sceanrio testing
    public static Account createInvalidTestAccount( Id bdaId ){
        
        clientAccount = new Account ();        
        clientAccount.Name = 'Test Account Invalid';
        clientAccount.Type = 'BCO' ;
        clientAccount.SCV_Code__c = '11223344';
        clientAccount.SCV_Status__c = 'Active';
        clientAccount.RecordTypeId = accountRecordTypeMap.get('Client Account');
        /*
        clientAccount.Cluster_Name__c = bdaId;
        */
        System.runAs(UserDataGeneratorHelper_Test.IntegrationUser){
            
            Database.insert( clientAccount );
            
        }
        return clientAccount;
    }   
    
    //To create client account with Sealand  & Integration users
    public static void createClientAccountWithSealandUSer(){
        
        testAccountSEA = new Account ();
        testAccountSEA.Name = 'Test Account - Sealand and Integration Users';
        testAccountSEA.Type = 'BCO' ;
        testAccountSEA.RecordTypeId = accountRecordTypeMap.get('Client Account');
        testAccountSEA.Owner = UserDataGeneratorHelper_Test.SEAIntegrationUser;  //Account owner as SEA user   
        testAccountSEA.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAIntegrationUser.Id; 
        System.runAs(UserDataGeneratorHelper_Test.SEAIntegrationUser){
            
            Database.insert(testAccountSEA);
            
        }
        createAccountTeamMemberWithIntegrationUser();
    }        
   
     //To create account team member with integration user in Sealand account
    public static void createAccountTeamMemberWithIntegrationUser(){
    
        acctMbrSEAObj = new AccountTeamMember(); 
        acctMbrSEAObj.AccountId = testAccountSEA.Id;
        acctMbrSEAObj.TeamMemberRole = 'Team Member';
        acctMbrSEAObj.userId = UserDataGeneratorHelper_Test.integrationUser.id;  
      
        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            
            Database.insert(acctMbrSEAObj);
            
        }
        
    }
    /**
    * Method to create Concern Account
    **/   
    //RQ-004168
    public static Account createConcernAccount(){
        system.debug('#### Creating Concern Account');
        concernAccount = new Account ();       
        
        concernAccount.Name = 'Test Class Client Account';
        concernAccount.SCV_Code__c = '***22572';    //SCV code for concern Account starts with ***
        concernAccount.SCV_Status__c = 'Active';
        concernAccount.RecordTypeId = accountRecordTypeMap.get('Concern Account');
        concernAccount.SEA_Account_Owner__c = UserDataGeneratorHelper_Test.SEAsalesUser.id ; //Brand Account Owner for SEA
        concernAccount.MSL_Account_Owner__c = UserDataGeneratorHelper_Test.MSLsalesUser.id ;
        //concernAccount.SCL_Account_Owner__c = UserDataGeneratorHelper_Test.SCLsalesUser.id ;     
       
        //concernAccount.Account_Manager_Maersk_Id__c = UserDataGeneratorHelper_Test.salesUser.Maersk_User_Id__c ;  //Account manager.            
            
        System.runAs( UserDataGeneratorHelper_Test.integrationUser ){
        
            insert concernAccount;
        
        }
        
        system.debug( '####  Concern Account created--' + concernAccount.id );
        return concernAccount;       
        
    }
    
    /**
    * Method to create Unassigned Account
    **/     
    public static Account createUnassignedAccount(){

        unAssignedAccount = new Account ();

        unAssignedAccount.Name = 'Internal Global Address Book 321312';
        unAssignedAccount.Type = 'BCO' ;
        unAssignedAccount.RecordTypeId = accountRecordTypeMap.get('Unassigned');

        System.runAs(UserDataGeneratorHelper_Test.SEAintegrationUser){
            insert unAssignedAccount;
        }
    
         return unAssignedAccount;
    } 
    
    
    
    /**
    * Method to create Draft Account
    **/ 

    public static Account createDraftAccount(){
    
        createDraftAccount(UserDataGeneratorHelper_Test.integrationUser);              
        return draftAccount;
        
    }
    
    public static Account createDraftAccount( User RunAsUser ){
        
        draftAccount = new Account ();
        draftAccount.Name = 'Test Class Draft Account';
        draftAccount.RecordTypeId = accountRecordTypeMap.get( 'Draft Account' );

        System.runAs( RunAsUser ){
            
            insert draftAccount;
        
        }
        
        return draftAccount;
    }
    
    /**
    * Method to create Non-shipping Party Account 
    **/  
    public static Account createNonShippingPartyAccount(){

        nonShipPartyAccount = new Account ();

        nonShipPartyAccount.Name = 'Test Class Non Shipping Party Account';
        nonShipPartyAccount.RecordTypeId = accountRecordTypeMap.get('Non-shipping Party Account');

        System.runAs(UserDataGeneratorHelper_Test.integrationUser){
            insert nonShipPartyAccount;
        }
        
        return nonShipPartyAccount;
    }  
    
    //To create account team member
    public static AccountTeamMember createAccountTeamMember( Id AccountId , Id UserId, String TeamMemberRole ){
                
        AccountTeamMember acctMbr = new AccountTeamMember(); 
        acctMbr.AccountId = AccountId;
        acctMbr.TeamMemberRole = TeamMemberRole;    
        acctMbr.userId = UserId;  
      
        System.runAs( UserDataGeneratorHelper_Test.integrationUser ){
            
            Database.insert(acctMbr);
            
        }
        
        return acctMbr;
        
    }
    
    //To create account team member
    public static AccountShare createAccountShare( Id AccountId , Id UserId,  String AcctAccessLevel,  String OpptyAccessLevel, String CaseAccessLevel, String ContactAccessLevel ){
               //system.debug('***AcctAccessLevel***'+AcctAccessLevel); 
        AccountShare acctShare = new AccountShare(); 
        acctShare.AccountId = AccountId;
        acctShare.AccountAccessLevel = AcctAccessLevel; 
        acctShare.OpportunityAccessLevel = OpptyAccessLevel;
        acctShare.CaseAccessLevel = CaseAccessLevel;
        acctShare.ContactAccessLevel = ContactAccessLevel;
        acctShare.UserOrGroupId = UserId;  
      
      System.runAs( UserDataGeneratorHelper_Test.integrationUser ){
            
            Database.insert(acctShare);
            
       }
        
        return acctShare;
        
    }

    
}//EOF of class