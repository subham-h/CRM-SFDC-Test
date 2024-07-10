/*
* Trigger Utility Class for UserTrigger and Trigger Handler class.
* 
*Version  Date         Owner                                    RQ#           Description
*******************************************************************************************************************************************
*1.0      11/06/2015   Ranjini.Janardhanan@ust-global.com       #RQ-001511    Created Single Trigger.
*2.0      14/05/2015   Sandhya.Sambasivan@ust-global.com        #RQ-001367    Dynamic List View and Queue Assignment.
*3.0      07/09/2015   Ranjini.Janardhanan@ust-global.com       #RQ-001771    Dynamic public group assignment for US Flag.
*4.0      29/09/2015   sherin.jose@accenture.com                #RQ-001772    Dynamic public group assignment for Sealand.
*5.0      06/11/2015   Parvathy.Prabhash@ust-global.com         #RQ-002142    Removed function that updates User record with Cluster Count
*6.0      29/03/2017   Govindaraj.Sundaram@ust-global.com       #RQ-004759    Included function that returns Gegoraphy and BDA names. 
*7.0      19/06/2017   meghana.gupta@ust-global.com             #RQ-005483    Moved few methods to UserUtilities class and removed commented/unwanted code and added logic for 
*                                                                             public group creation based on liner brand and the sales profile Ids
*8.0      28/02/2018   Junaid.Khader@ust-global.com             #RQ-007716    Checks to exclude non german users from adding to 'Sales Users Excluding DE'
*9.0      10/10/2018   Nisha.Arjunan@ust-global.com             #RQ-009414    To avoid exeception added a null check for 'oldBrands'. 
*10.0     28/11/2018   Jagadeesan.Sakthivel@ust-global.com      #RQ-009466    Added future method to change the Request Information object records of an inactive user to be in Remove status
*10.1     19/11/2018   nitin.v.more@maersk.com                  #RQ-009625    replaced 'KC Rep / KAO' with 'Key Client Manager'AND 'Office-Based Sales' wiht 'Account Manager'
*11.0     21/05/2019   mohammad.naved@maersk.com                #RQ-010755    Dynamic chat queue assigmnet for User
*11.1     21/05/2019   mohammad.naved@maersk.com                #RQ-010755    Dynamic assigned permission set to the Live agent
*12.0     10/06/2020   ramadevi@ust                             #Sc-515       N&C - Assignment of users to public groups
*13.0     28/07/2020   Manik@UST                                #SCTM-335     SCM CTM - User Assignments to Public Group
*14.0     14/07/2020   sriram@maersk                            SC-1160      auto assign or remove LNS queues  
*14.1     30/06/2021   Nitin@maersk                             SFSE-6249     Added method to delete AccountTeamMember and OppTeamMember
*15.0    07/04/2022   Sreya@Maersk                             SC - 4505     Add/Remove users from 4PL group based on 4PL Account selection
*16.0    25/07/2022   sunil.bs@maersk.com                      SC-5695     Add/Remove groups for SCM KC Users basis SCM KC Country/Area Selection
*17.0     06/07/2022   Ronnie@SF                                SPI-100       Removed brand hardcoding + method for populating Brand_Logic__c + calls to getPublicGroupIds
*18.0     13/Mar/2023  Saradha@UST                              SC-7497       If the user is part of 4PL visibility, then dont add Maersk L&S ISR group to public grp assignment.
*19.0     13/Jul/2023  Nayana@maersk                            SC-7849       Added a parameter to formRelatedPublicGroups() method to handle newly added method assignDynamicMandAQueues() for M&A Queues public group assignment
*19.0     06/Sept/2023 Meghna@maersk                            SC-8395       Add/Remove users from Multi Carrier (Restricted) group based on Multi Carrier (Restricted) Account selection
*20.0     06/10/2023  shilpa.nagtode@maersk                   SFSE-12713       logic added to assigned wizard permission set while user creation and updation.
*21.0     27/05/2024  Jothsana@maersk                         SFSE-15210       Logic added to assign Edit Default Prices permission set to user having sales job functions as 'Product Organization'
*22.0     05/06/2024  Avinash@maersk                          SFSE-14825       Cargo type on opportunity level
*/

public Class UserTriggerUtility{   
    
    /* This static variable is used to control the 'Batch_AccountClusterFix' class execution 
in 'aINS_aUPD_LeadAccountClusterFixonClusterChange'*/   
    public Static Boolean IsInvokedfromCreateUserCluster = FALSE; 
    
    /*This method will manage all the DML operations*/
    public static void manageDML(List<sObject> sObjectList, String Action){
        
        if( sObjectList.Size() > 0 && Action == 'Insert'){            
            
            Database.SaveResult[] srList = Database.Insert(sObjectList,false);// create Records            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('##### Record Create Errors '+': '+err.getStatusCode() + ': ' + err.getMessage());                                             
                    }
                }    
            }
            
        } else if( sObjectList.Size() > 0 && Action == 'Update'){
            
            Database.SaveResult[] srList = Database.Update(sObjectList,false);// Update Records            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('##### Record Update Errors '+': '+err.getStatusCode() + ': ' + err.getMessage());                                             
                    }
                }    
            }
        }        
    }    
    
    /*
* Creating User Cluster records are put in a Futuer method since this has a depenednecy with the trigger - 
* aINS_aUPD_LeadAccountClusterFixonClusterChange. This is not to disturb the existing functioanlity 
* on User Cluster insert , update.
*/   
    @future
    public static void createUserCluster(Map<Id, Id> ucCreateMap){
        
        List<User_Cluster__c> ucList = new List<User_Cluster__c>();
        
        for(Id userId : ucCreateMap.keySet()){
            User_Cluster__c uc = new User_Cluster__c(User__c = userId, BDA__c = ucCreateMap.get(userId) ) ;
            ucList.add(uc);
        }
        if( ucList.Size() > 0 ){
            
            IsInvokedfromCreateUserCluster = TRUE;
            Database.SaveResult[] srList = Database.Insert(ucList,false);// create Records
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('##### User Cluster Record Create Errors '+': '+err.getStatusCode() + ': ' + err.getMessage());                                             
                    }
                }    
            }
        }        
    }
    
  
    
    public static void assignDynamicSupportCountries(List<User> newLNSUserList,List<User> newUserList, Map<Id,User> oldUserMap, List<User> addToBrandGroupUserList, List<User> assignToSalesGroup_UserList,List<User> assignToGrpCMVisibility_UserList,List<User> assignToGrp4PLAccount_UserList, List<User> assignToGrpMC_RestrictedAcc_UserList){
        
        Map<String, String> supportCountryMap  = new Map<String, String>(); //Map which hold all the Support countries with country code
        Map<String, Id> publicGroupToIdMap = new Map<String, Id>(); //Map of all Customer Service public Groups
        Set<Id> userIdForGroupMemberDel = new Set<Id>(); //Store the User Ids for which Group member to be deleted
        Set<Id> groupMemberIdsToBeDeleted = new Set<Id>(); //Store Ids of Group member to be deleted
        Set<String> groupMemberDeletionSet = new Set<String>(); //Store key for group member deletion
        Set<String> groupMemberInsertSet = new Set<String>(); //Map to hold the key (public group : user) to insert Group members
        Map<String, User_Group_Assignment__c> lnrBrdOrProfileToGroupMap = new Map<String, User_Group_Assignment__c>();
         //Form a map of all Customer service Public Groups
            publicGroupToIdMap = getAllCustomerServicePublicGroups(Label.CM_Public_Group_Name);

        system.debug('$$$ newUserList: '+ newUserList);
        if ( !newUserList.isEmpty() ){
            //Get a map of all available Support Countries with country code
            supportCountryMap = getAllSupportCountryCodes('Support_Countries__c');
            
           
            
            for( User usrRec : newUserList){
                
                
                
                /*Conditions:
1)Insert new user record with Support_Countries__c and Liner Brand.
2)Update User record with Support Countries for first time.
*/
                
                if( usrRec.Support_Countries__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).Support_Countries__c == null))){
                    
                    system.debug('$$$ 1'+usrRec.Support_Countries__c);
                    //Method call : Form the Public Group Names to which the user be added
                    Set<String> publicGroupToAddSet = formRelatedPublicGroups(null, null,usrRec.Support_Countries__c,null, usrRec.Liner_Brand_Logic__c, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    system.debug('publicGroupToAddSet##'+publicGroupToAddSet);                                                          
                    if(publicGroupToAddSet.size() > 0){
                        
                        groupMemberInsertSet.addAll(publicGroupToAddSet); //Add keys for grp members to be inserted
                        
                    }                
                }
                //Condition: Update user with change in Support Countries or Liner Brand and Support Countries is not null.
                else if( oldUserMap != null && (usrRec.Support_Countries__c != null || oldUserMap.get(usrRec.Id).Liner_Brand_Logic__c != usrRec.Liner_Brand_Logic__c)){                  
                    system.debug('$$$ 2');
                    //Method call : Form the Public Group Names to which the user be added/removed
                    Set<String> publicGroupFromNewSet = formRelatedPublicGroups( null,null,usrRec.Support_Countries__c,null, usrRec.Liner_Brand_Logic__c, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    Set<String> publicGroupFromOldSet = formRelatedPublicGroups(null,null,oldUserMap.get(usrRec.Id).Support_Countries__c,null, oldUserMap.get(usrRec.Id).Liner_Brand_Logic__c, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    
                    /* Using set method 'removeAll' find the difference between two set of strings which will give the public groups
to be added/ removed for the user*/
                    
                    Set<String> publicGroupOldSetToCheck = publicGroupFromOldSet.clone();
                    
                    // Old Group names compared with new Group names to check which are the Group names to be removed.
                    publicGroupOldSetToCheck.removeAll( publicGroupFromNewSet );
                    
                    if( publicGroupOldSetToCheck.size() > 0 ){
                        
                        groupMemberDeletionSet.addAll( publicGroupOldSetToCheck ); //List of public groups for which the group members for the user to be deleted
                        userIdForGroupMemberDel.add( usrRec.Id );
                    }
                    
                    // New Group names compared with old Group names to check which are the Group names to be added.
                    publicGroupFromNewSet.removeAll( publicGroupFromOldSet );
                    if( publicGroupFromNewSet.size() > 0 ){
                        
                        groupMemberInsertSet.addAll(publicGroupFromNewSet);//List of public groups for which group members to be inserted
                        
                    }            
                }
                //Condition: Update user with all Support Countries removed.
                else if( oldUserMap != null && usrRec.Support_Countries__c == null && oldUserMap.get(usrRec.Id).Support_Countries__c != null){
                    //When user record is updated and all support countries from user record are removed, remove all public groups.
                    //Method call : Retrieve a set of all public group names from which user need to be removed from.
                    Set<String> publicGroupToDeleteSet = formRelatedPublicGroups(null,null,oldUserMap.get(usrRec.Id).Support_Countries__c,null, usrRec.Liner_Brand_Logic__c, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    
                    if( publicGroupToDeleteSet.size() > 0){
                        
                        groupMemberDeletionSet.addAll(publicGroupToDeleteSet);
                        userIdForGroupMemberDel.add(usrRec.Id);
                        
                    }            
                }            
            }
            
            
        }
        
        /* SC-515 - N & C */
        if(assignToGrpCMVisibility_UserList.size()>0){
            lnrBrdOrProfileToGroupMap = User_Group_Assignment__c.getAll();
            for( User usrRec : assignToGrpCMVisibility_UserList){
                if(lnrBrdOrProfileToGroupMap.size() > 0 ){
                    if(usrRec.CM_Visibility__c != NULL) {
                        // add to group
                        if(lnrBrdOrProfileToGroupMap.containsKey(usrRec.CM_Visibility__c)){
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(usrRec.CM_Visibility__c).Public_Group_Ids__c.split(';')){
                                String groupUserKey = usrRec.Id + ':' + grpId;                                                    
                                groupMemberInsertSet.add(groupUserKey);
                                system.debug('Adding to Insert group member'+groupMemberInsertSet); 
                            }
                        }
                        // To remove from old group
                        if(oldUserMap != null && oldUserMap.get(usrRec.Id).CM_Visibility__c != NULL && oldUserMap.get(usrRec.Id).CM_Visibility__c !=usrRec.CM_Visibility__c && lnrBrdOrProfileToGroupMap.containsKey(oldUserMap.get(usrRec.Id).CM_Visibility__c)){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldUserMap.get(usrRec.Id).CM_Visibility__c).Public_Group_Ids__c.split(';')){                       
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId); // form a list of User:Group keys to be removed 
                                system.debug('Adding to delete group member'+groupMemberDeletionSet);                                
                            }
                        } 
                    } else if(oldUserMap != null && oldUserMap.get(usrRec.Id).CM_Visibility__c != NULL  && usrRec.CM_Visibility__c == NULL && lnrBrdOrProfileToGroupMap.containsKey(oldUserMap.get(usrRec.Id).CM_Visibility__c)){
                        //remove the group
                        userIdForGroupMemberDel.add(usrRec.Id);
                        for (String grpId : lnrBrdOrProfileToGroupMap.get(oldUserMap.get(usrRec.Id).CM_Visibility__c).Public_Group_Ids__c.split(';')){                         
                            groupMemberDeletionSet.add(usrRec.Id + ':' + grpId); // form a list of User:Group keys to be removed 
                            system.debug('Adding to delete group member'+groupMemberDeletionSet);                                
                        }
                    } 
                }
            }                   
        }
        //SC - 4505 : 4PL N&C
        //Adding the users to the appropriate 4PL public group based on the selection made on 4PL Account on User
        if ( !assignToGrp4PLAccount_UserList.isEmpty()){           
            lnrBrdOrProfileToGroupMap = User_Group_Assignment__c.getAll();            
            for( User usrRec : assignToGrp4PLAccount_UserList){                
                if (usrRec.SF_4PL_Account__c != null){
                    List<String> newAccountList = usrRec.SF_4PL_Account__c.split(';');
                    String oldAccounts = '';
                    List<String> oldAccountList = new List<String>();                                      
                    if (oldUserMap != null && String.isNotBlank(oldUserMap.get(usrRec.Id).SF_4PL_Account__c ) && oldUserMap.get(usrRec.Id).SF_4PL_Account__c !=usrRec.SF_4PL_Account__c){
                        oldAccounts = oldUserMap.get(usrRec.Id).SF_4PL_Account__c;
                        oldAccountList = oldAccounts.split(';');
                    }                   
                    for(String newAccount : newAccountList){
                        if ( !oldAccounts.contains(newAccount) && lnrBrdOrProfileToGroupMap.containsKey(newAccount) && lnrBrdOrProfileToGroupMap.get(newAccount) != null){
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(newAccount).Public_Group_Ids__c.split(';')){
                                String groupUserKey = usrRec.Id + ':' + grpId;                          
                                groupMemberInsertSet.add(groupUserKey);
                            }
                        }                   
                    }                    
                    for(String oldAccount : oldAccountList){
                        if ( ! usrRec.SF_4PL_Account__c.contains(oldAccount) && lnrBrdOrProfileToGroupMap.containsKey(oldAccount) && lnrBrdOrProfileToGroupMap.get(oldAccount) != null){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldAccount).Public_Group_Ids__c.split(';')){                         
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId); 
                            }
                        }                   
                    } 
                }
                else if(oldUserMap != null && String.isNotBlank(oldUserMap.get(usrRec.Id).SF_4PL_Account__c )  && usrRec.SF_4PL_Account__c == NULL && oldUserMap.get(usrRec.Id).SF_4PL_Account__c !=usrRec.SF_4PL_Account__c ){
                    String oldAccounts = oldUserMap.get(usrRec.Id).SF_4PL_Account__c;
                    List<String> oldAccountList = oldAccounts.split(';');                    
                    for(String oldAccount : oldAccountList){
                        if (  lnrBrdOrProfileToGroupMap.containsKey(oldAccount) && lnrBrdOrProfileToGroupMap.get(oldAccount) != null){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldAccount).Public_Group_Ids__c.split(';')){                         
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId);                              
                            }
                        }
                    } 
                }                          
            }            
        }
        
        //SC-8395 : MC Restricted N&C
        //Adding the users to the appropriate MC Restricted public group based on the selection made on SCM Account on User
        if ( !assignToGrpMC_RestrictedAcc_UserList.isEmpty()){ 
            system.debug('Came inside method');
            lnrBrdOrProfileToGroupMap = User_Group_Assignment__c.getAll();            
            for( User usrRec : assignToGrpMC_RestrictedAcc_UserList){                
                if (usrRec.Multi_Carrier_Restricted_Account__c != null){
                    List<String> newAccountList = usrRec.Multi_Carrier_Restricted_Account__c.split(';');
                    String oldAccounts = '';
                    List<String> oldAccountList = new List<String>();                                      
                    if (oldUserMap != null && String.isNotBlank(oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c ) && oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c !=usrRec.Multi_Carrier_Restricted_Account__c){
                        oldAccounts = oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c;
                        oldAccountList = oldAccounts.split(';');
                    }                   
                    for(String newAccount : newAccountList){
                        if ( !oldAccounts.contains(newAccount) && lnrBrdOrProfileToGroupMap.containsKey(newAccount) && lnrBrdOrProfileToGroupMap.get(newAccount) != null){
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(newAccount).Public_Group_Ids__c.split(';')){
                                String groupUserKey = usrRec.Id + ':' + grpId;                          
                                groupMemberInsertSet.add(groupUserKey);
                            }
                        }
                 System.debug('List of group ids added'+groupMemberInsertSet);

                    }                    
                    for(String oldAccount : oldAccountList){
                        if ( ! usrRec.Multi_Carrier_Restricted_Account__c.contains(oldAccount) && lnrBrdOrProfileToGroupMap.containsKey(oldAccount) && lnrBrdOrProfileToGroupMap.get(oldAccount) != null){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldAccount).Public_Group_Ids__c.split(';')){                         
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId); 
                            }
                        } 
                                         System.debug('List of group ids deleted'+groupMemberDeletionSet);

                    } 
                }
                else if(oldUserMap != null && String.isNotBlank(oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c )  && usrRec.Multi_Carrier_Restricted_Account__c == NULL && oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c !=usrRec.Multi_Carrier_Restricted_Account__c ){
                    String oldAccounts = oldUserMap.get(usrRec.Id).Multi_Carrier_Restricted_Account__c;
                    List<String> oldAccountList = oldAccounts.split(';');                    
                    for(String oldAccount : oldAccountList){
                        if (  lnrBrdOrProfileToGroupMap.containsKey(oldAccount) && lnrBrdOrProfileToGroupMap.get(oldAccount) != null){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldAccount).Public_Group_Ids__c.split(';')){                         
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId);                              
                            }
                        }
                    } 
                }                                   
            }            
        }        
        
        // Logic to assign user to brand specific public groups
       if ( !addToBrandGroupUserList.isEmpty()){
            
            list<Id> delUserGroupIds = new list<Id>();
            list<String> userGroupKeyToDelete = new list<String>();
            //SC-7497 If the user is part of 4PL visibility, then dont add Maersk L&S ISR queue.
            General_Key_Value_Configurations__mdt mdt = General_Key_Value_Configurations__mdt.getInstance('SF_4PL');
            General_Key_Value_Configurations__mdt mdtMCR = General_Key_Value_Configurations__mdt.getInstance('SF_Multi_Carrier_Restricted');

            String str4PL = mdt.key__c;
            String strMCR = mdtMCR.Key__c;
            for( User usrRec : addToBrandGroupUserList){
                
                if (usrRec.Liner_Brand__c != null){
                    List<String> newBrandList = usrRec.Liner_Brand__c.split(';');
                    String oldBrands = '';
                    List<String> oldBrandList = new List<String>();
                    
                    // #RQ-009414
                    if (oldUserMap != null && String.isNotBlank(oldUserMap.get(usrRec.Id).Liner_Brand__c )){
                        oldBrands = oldUserMap.get(usrRec.Id).Liner_Brand__c;
                        oldBrandList = oldBrands.split(';');
                    }
                    // if there a brand is added to brand list then we should assign user to that brand's group
                  if(usrRec.CM_Visibility__c != strMCR){
                    for(String brand : newBrandList){
                        if (!oldBrands.contains(brand)) {
                            //SC-7497 Added if to exclude maersk l&s group for 4PL
                            if((brand != BrandUtilities.MAERSKLS && usrRec.CM_Visibility__c == str4PL ) || usrRec.CM_Visibility__c != str4PL) {
                            if (BrandUtilities.getPublicGroupIds(brand) != null) {
                                for (String grpId : BrandUtilities.getPublicGroupIds(brand).split(';')) {
                                    if (String.isNotBlank(grpId)) {
                                String groupUserKey = usrRec.Id + ':' + grpId;                          
                                groupMemberInsertSet.add(groupUserKey);
                            }
                        }                   
                    }
                    }
                        }                   
                    }
                    }
                    
                    // if a brand is removed from brand list then remove that brand's group from user's group list
                    for(String brand : oldBrandList){
                        if (!usrRec.Liner_Brand__c.contains(brand)) {
                            userIdForGroupMemberDel.add(usrRec.Id);
                            if (BrandUtilities.getPublicGroupIds(brand) != null) {
                                for (String grpId : BrandUtilities.getPublicGroupIds(brand).split(';')) {
                                    if (String.isNotBlank(grpId)) {
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId); // form a list of User:Group keys to be removed 
                            }
                        }                   
                    } 
                }      
            }
                }      
            }
            
        }
        
        // Logic to assign sales users to Sales public group
        // Id of public group named 'Sales Users Excluding DE' which is stored in custom label. #RQ-007716
        Id salesUsersExcludingDeId = (Label.Sales_Users_Excluding_DE_Id != null) ? Label.Sales_Users_Excluding_DE_Id : '';       
        System.debug('assignToSalesGroup_UserList here ::::'+assignToSalesGroup_UserList);
        if ( !assignToSalesGroup_UserList.isEmpty()){
            if(lnrBrdOrProfileToGroupMap.isEmpty()){
                lnrBrdOrProfileToGroupMap = User_Group_Assignment__c.getAll();  
            }
            // Iterate through all the user records on insertion or for which profileIds are changed on update 
            for( User usrRec : assignToSalesGroup_UserList){
                if( lnrBrdOrProfileToGroupMap.get(usrRec.ProfileId) != null ){ // if new user profile Id exists in the user group assignment custom setting
                    if (oldUserMap == null){ // On insertion, if user profile id exists in the user group assigment custom setting, add the user to the corresponding group 
                        for (String grpId : lnrBrdOrProfileToGroupMap.get(usrRec.ProfileId).Public_Group_Ids__c.split(';')){
                            String groupUserKey = usrRec.Id + ':' + grpId; 
                            if(grpId == salesUsersExcludingDeId) {
                                // Checks for including or excluding german users to group #RQ-007716
                                if((usrRec.Country == 'Germany' && (usrRec.Sales_Job_Function__c == 'KC Sales Rep' || usrRec.Sales_Job_Function__c == 'Sales Rep'))) {
                                    userIdForGroupMemberDel.add(usrRec.Id);
                                    groupMemberDeletionSet.add(groupUserKey);
                                } else {
                                    groupMemberInsertSet.add(groupUserKey);
                                }
                            } else {
                                groupMemberInsertSet.add(groupUserKey);
                            }
                        }
                        
                    } else{ // On Update, new user profile Id exists in the User Group Assignment custom setting and the old user profile Id do not exist in the custom setting, then corresponding 
                        // public group should be added to the User.
                        if( lnrBrdOrProfileToGroupMap.get(oldUserMap.get(usrRec.Id).ProfileId) == null  || usrRec.Country == 'Germany' || oldUserMap.get(usrRec.Id).Country == 'Germany' ){
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(usrRec.ProfileId).Public_Group_Ids__c.split(';')){
                                String groupUserKey = usrRec.Id + ':' + grpId; 
                                if(grpId == salesUsersExcludingDeId) {
                                    // Checks for including or excluding german users to group #RQ-007716
                                    if((usrRec.Country == 'Germany' && (usrRec.Sales_Job_Function__c == 'Key Client Manager' || usrRec.Sales_Job_Function__c == 'Account Manager' || usrRec.Sales_Job_Function__c == 'Field-Based'))) {
                                        userIdForGroupMemberDel.add(usrRec.Id);
                                        groupMemberDeletionSet.add(groupUserKey);
                                    } else {
                                        groupMemberInsertSet.add(groupUserKey);
                                    }
                                } else {
                                    groupMemberInsertSet.add(groupUserKey);
                                }
                            }   
                        }
                    }
                } else{ // if new user profile Id does not exists in the user group assignment custom setting    
                    if (oldUserMap != null){ // on update, if old user profile id exist in the user group assignment custom setting, then the group should be deleted from user
                        if(lnrBrdOrProfileToGroupMap.get(oldUserMap.get(usrRec.Id).ProfileId) != null){
                            userIdForGroupMemberDel.add(usrRec.Id);
                            for (String grpId : lnrBrdOrProfileToGroupMap.get(oldUserMap.get(usrRec.Id).ProfileId).Public_Group_Ids__c.split(';')){                         
                                groupMemberDeletionSet.add(usrRec.Id + ':' + grpId);
                            }   
                        }
                    }
                }
            }
            
        }
        
        // SC-1160 auto assign or remove LNS queues  
        if(newLNSUserList.size()>0){
            system.debug('-------IN LNS Queue assignment-------- ');
            supportCountryMap = getAllSupportCountryCodes('L_S_Queues__c');
            publicGroupToIdMap.putAll(getAllCustomerServicePublicGroups(Label.Case_LNS_groupName));  
            for( User usrRec : newLNSUserList){               
                
                if( usrRec.L_S_Queues__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).L_S_Queues__c == null))){
                    Set<String> publicGroupToAddSet = formRelatedPublicGroups( null,'',null,null, null, usrRec.Id, supportCountryMap, publicGroupToIdMap,usrRec.L_S_Queues__c,null);
                   if(publicGroupToAddSet.size() > 0){                        
                        groupMemberInsertSet.addAll(publicGroupToAddSet); 
                    }    
                    
                } else if( oldUserMap != null && usrRec.L_S_Queues__c == null && oldUserMap.get(usrRec.Id).L_S_Queues__c != null){
                    //When user record is updated and all L&S queue countries from user record are removed, remove all public groups.
                    Set<String> publicGroupToDeleteSet = formRelatedPublicGroups( null,'',null,null, null, usrRec.Id, supportCountryMap, publicGroupToIdMap,oldUserMap.get(usrRec.Id).L_S_Queues__c,null);
                    
                    if( publicGroupToDeleteSet.size() > 0){                        
                        groupMemberDeletionSet.addAll(publicGroupToDeleteSet);
                        userIdForGroupMemberDel.add(usrRec.Id);
                        
                    }            
                }
                else if( oldUserMap != null && (usrRec.L_S_Queues__c != null || oldUserMap.get(usrRec.Id).L_S_Queues__c != usrRec.L_S_Queues__c)){  
                    Set<String> publicGroupFromNewSet = formRelatedPublicGroups(null, '',null,null, null, usrRec.Id, supportCountryMap, publicGroupToIdMap,usrRec.L_S_Queues__c,null);
                    Set<String> publicGroupFromOldSet = formRelatedPublicGroups( null,'',null,null, null, usrRec.Id, supportCountryMap, publicGroupToIdMap,oldUserMap.get(usrRec.Id).L_S_Queues__c,null);
                                    
                    Set<String> publicGroupOldSetToCheck = publicGroupFromOldSet.clone();
                    
                    publicGroupOldSetToCheck.removeAll( publicGroupFromNewSet );
                    if( publicGroupOldSetToCheck.size() > 0 ){
                        
                        groupMemberDeletionSet.addAll( publicGroupOldSetToCheck ); 
                        userIdForGroupMemberDel.add( usrRec.Id );
                    }
                    publicGroupFromNewSet.removeAll( publicGroupFromOldSet );
                    if( publicGroupFromNewSet.size() > 0 ){                        
                        groupMemberInsertSet.addAll(publicGroupFromNewSet);
                    }     
                }
            }
            
        }
        
        system.debug('##groupMemberInsertSet'+groupMemberInsertSet);
        Map<String, Id> groupMemberRemoveMap = new Map<String, Id>(); //Map to store the combination key of public group to user Id for group members to be deleted
        if( groupMemberDeletionSet.size() > 0 && userIdForGroupMemberDel.size() > 0 ){
            
            //Query the Group Members with available groups                    
            for(GroupMember gM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                  WHERE UserOrGroupId IN: userIdForGroupMemberDel]){
                                      
                                      groupMemberRemoveMap.put(gM.UserOrGroupId+':'+gM.GroupId, gM.Id);  
                                  }
        }
        if(groupMemberRemoveMap != null && groupMemberRemoveMap.size() >0){            
            for(String groupMemberKey : groupMemberDeletionSet){                
                if(groupMemberRemoveMap.containsKey(groupMemberKey)){
                    
                    groupMemberIdsToBeDeleted.add(groupMemberRemoveMap.get(groupMemberKey));
                    
                }                
            }            
        }
        
        
        
        
        //Method call : Add or delete group members for users
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){
            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);
            
        }     
    }
    
    /* Form a map of all Support Countries with country codes */
    public static Map<String, String> getAllSupportCountryCodes( string strFieldName){
        system.debug('strFieldName####'+strFieldName);
        Map<String, String> fullSupportCountryMap  = new Map<String, String>();
        Schema.DescribeSObjectResult usrDescribe = User.sObjectType.getDescribe();      
        
        // Get a map of fields for the User Object
        Map<String, Schema.SObjectField> fieldMap = usrDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> supportCountryPicklistValues = fieldMap.get(strFieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry supportCountryStr : supportCountryPicklistValues){
            
            List<String> tempStrList = supportCountryStr.getValue().split('\\(');
            //system.debug('tempStrList###'+supportCountryStr.getValue());
            if(tempStrList.size()>1){
            if(tempStrList[1] != null){
                    fullSupportCountryMap.put(supportCountryStr.getValue(), (tempStrList[1].remove(')')).trim());
               }
            }
        }
        return fullSupportCountryMap;         
    }  
    //SCTM-335 : Assign/Remove SCM Queues
    //SC-5695 : Assign users to group basis scm kc country/Area Selection
    public static void assignDynamicSCMQueues(List<User> newUserList, Map<Id,User> oldUserMap){
        
        Map<String, String> sCMQueueMap  = new Map<String, String>(); //Map which hold all the SCM Queues
        Map<String, Id> publicGroupToIdMap = new Map<String, Id>(); //Map of all Customer Service public Groups
        Set<Id> userIdForGroupMemberDel = new Set<Id>(); //Store the User Ids for which Group member to be deleted
        Set<Id> groupMemberIdsToBeDeleted = new Set<Id>(); //Store Ids of Group member to be deleted
        Set<String> groupMemberDeletionSet = new Set<String>(); //Store key for group member deletion
        Set<String> groupMemberInsertSet = new Set<String>(); //Map to hold the key (public group : user) to insert Group members
        //Map<String, User_Group_Assignment__c> lnrBrdOrProfileToGroupMap = new Map<String, User_Group_Assignment__c>();
        system.debug('myusermethcalled ');
        system.debug('$$$ newUserList: '+ newUserList);
        if ( !newUserList.isEmpty() ){
            //Get a map of all available SCM Queues
            //sCMQueueMap = getAllSCMQueueMap('LS_TM_SCM_Queues__c');
             Map<String, String>  supportCountryMap = getAllSupportCountryCodes('LS_TM_SCM_Queues__c');
            //Form a map of all Customer service Public Groups
            publicGroupToIdMap = getAllCustomerServicePublicGroups(Label.CM_Public_Group_Name);
           // Set<String> publicGroupToAddSet = new Set<String>();
            
            for( User usrRec : newUserList){
                
                /*Conditions:
1)Insert new user record with LS_TM_SCM_Queues__c.
2)Update User record with SCM Queues for first time.
*/            
                
                if( (usrRec.LS_TM_SCM_Queues__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c == null)))|| (usrRec.SCM_KC_Country_Area__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c == null)))){
                    Set<String> publicGroupToAddSet = new Set<String>();
                    system.debug('$$$ 1'+usrRec.LS_TM_SCM_Queues__c);
                    //Method call : Form the Public Group Names to which the user be added
                    if(usrRec.SCM_KC_Country_Area__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c == null))){
                         Set<String> publicGroupToAddSet2 = formRelatedPublicGroups(usrRec.SCM_KC_Country_Area__c, null,null,usrRec.LS_TM_SCM_Queues__c,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                         for(string i: publicGroupToAddSet2)
                            publicGroupToAddSet.add(i);
                    }
                    
                     if(usrRec.LS_TM_SCM_Queues__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c == null))){
                         Set<String> publicGroupToAddSet2 = formRelatedPublicGroups(null, null,null,usrRec.LS_TM_SCM_Queues__c,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                         for(string i: publicGroupToAddSet2)
                            publicGroupToAddSet.add(i);
                     }
                    
                    
                    system.debug('publicGroupToAddSet##'+publicGroupToAddSet);                                                          
                    if(publicGroupToAddSet.size() > 0){
                        groupMemberInsertSet.addAll(publicGroupToAddSet); //Add keys for grp members to be inserted      
                    }                
                }
   
                
                //Condition: Update user with change in SCMQueues and SCMQueues is not null.
                else if( (oldUserMap != null && (usrRec.LS_TM_SCM_Queues__c != null || oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c != usrRec.LS_TM_SCM_Queues__c))||(oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null || oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c != usrRec.SCM_KC_Country_Area__c))){                  
                    system.debug('$$$ 2');
                    //Method call : Form the Public Group Names to which the user be added/removed
                    Set<String> publicGroupFromNewSet = new Set<String>();
                    //For SCM KC country/Area
                    if(oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null || oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c != usrRec.SCM_KC_Country_Area__c)||(oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null))){
                        Set<String> publicGroupFromNewSet2 = formRelatedPublicGroups(usrRec.SCM_KC_Country_Area__c,null,null,usrRec.LS_TM_SCM_Queues__c,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                        for(string i:publicGroupFromNewSet2)
                          publicGroupFromNewSet.add(i);
                    }
                    //For SCM Queues
                    if(oldUserMap != null && (usrRec.LS_TM_SCM_Queues__c != null || oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c != usrRec.LS_TM_SCM_Queues__c)||oldUserMap != null && (usrRec.LS_TM_SCM_Queues__c != null)){
                        Set<String> publicGroupFromNewSet2 = formRelatedPublicGroups( null,null,null,usrRec.LS_TM_SCM_Queues__c,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                      for(string i: publicGroupFromNewSet2)
                          publicGroupFromNewSet.add(i);
                    }
                    
                    
                    Set<String> publicGroupFromOldSet = new Set<String>();
                    //For SCM KC country/Area
                    if(oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null || oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c != usrRec.SCM_KC_Country_Area__c)||oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null)){
                        Set<String> publicGroupFromOldSet2 = formRelatedPublicGroups(oldUserMap.get(usrRec.Id).SCM_KC_Country_Area__c,null,null,oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c,null, usrRec.Id,supportCountryMap, publicGroupToIdMap,null,null);
                         for(string i:publicGroupFromOldSet2)
                          publicGroupFromOldSet.add(i);
                    }
                    //For SCM Queues
                    if(oldUserMap != null && (usrRec.LS_TM_SCM_Queues__c != null || oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c != usrRec.LS_TM_SCM_Queues__c)||oldUserMap != null && (usrRec.SCM_KC_Country_Area__c != null)){
                        Set<String> publicGroupFromOldSet2 = formRelatedPublicGroups(null,null,null,oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                        for(string i: publicGroupFromOldSet2)
                        publicGroupFromOldSet.add(i);
                    }
                    
         
                    /* Using set method 'removeAll' find the difference between two set of strings which will give the public groups
to be added/ removed for the user*/
                    system.debug('publicGroupFromNewSet>>'+publicGroupFromNewSet);
                    system.debug('publicGroupFromOldSet>>'+publicGroupFromOldSet);
                    Set<String> publicGroupOldSetToCheck = publicGroupFromOldSet.clone();
                    
                    // Old Group names compared with new Group names to check which are the Group names to be removed.
                    publicGroupOldSetToCheck.removeAll( publicGroupFromNewSet );
                    
                    if( publicGroupOldSetToCheck.size() > 0 ){
                        
                        groupMemberDeletionSet.addAll( publicGroupOldSetToCheck ); //List of public groups for which the group members for the user to be deleted
                        userIdForGroupMemberDel.add( usrRec.Id );
                    }
                    
                    // New Group names compared with old Group names to check which are the Group names to be added.
                    publicGroupFromNewSet.removeAll( publicGroupFromOldSet );
                    if( publicGroupFromNewSet.size() > 0 ){
                        
                        groupMemberInsertSet.addAll(publicGroupFromNewSet);//List of public groups for which group members to be inserted
                        
                    }            
                }
                //Condition: Update user with all SCMQueues removed.
                /*
else if( oldUserMap != null && usrRec.LS_TM_SCM_Queues__c == null && oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c != null){
//When user record is updated and all SCM Queues from user record are removed, remove all public groups.
//Method call : Retrieve a set of all public group names from which user need to be removed from.
Set<String> publicGroupToDeleteSet = formRelatedPublicGroups(null,null,null,oldUserMap.get(usrRec.Id).LS_TM_SCM_Queues__c,null, usrRec.Id, null, publicGroupToIdMap);

if( publicGroupToDeleteSet.size() > 0){

groupMemberDeletionSet.addAll(publicGroupToDeleteSet);
userIdForGroupMemberDel.add(usrRec.Id);

}            
}*/            
            }
            
            
        }       
         system.debug('myusermethcalledcecpoint5 ');
        system.debug('##groupMemberInsertSet'+groupMemberInsertSet);
        Map<String, Id> groupMemberRemoveMap = new Map<String, Id>(); //Map to store the combination key of public group to user Id for group members to be deleted
        if( groupMemberDeletionSet.size() > 0 && userIdForGroupMemberDel.size() > 0 ){
            
            //Query the Group Members with available groups                    
            for(GroupMember gM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                  WHERE UserOrGroupId IN: userIdForGroupMemberDel]){
                                      
                                      groupMemberRemoveMap.put(gM.UserOrGroupId+':'+gM.GroupId, gM.Id);  
                                  }
        }
        if(groupMemberRemoveMap != null && groupMemberRemoveMap.size() >0){            
            for(String groupMemberKey : groupMemberDeletionSet){                
                if(groupMemberRemoveMap.containsKey(groupMemberKey)){
                    
                    groupMemberIdsToBeDeleted.add(groupMemberRemoveMap.get(groupMemberKey));
                    
                }                
            }            
        }
        
        //Method call : Add or delete group members for users
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){
            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);
            
        }     
    }
    /* Form a map with Name and Id of all Customer Service Public Groups available*/
    public static Map<String, Id> getAllCustomerServicePublicGroups(String strFilter){
        
        Map<String, Id>fullPublicGroupToIdMap = new Map<String, Id>();
        List<Group>allCMPublicGroupList = new List<Group>();
        
        //Retrieve all public groups with name like 'Customer Service' and form a map of public group name to Id
        for(Group singleGroupRec : [SELECT DeveloperName 
                                    FROM Group 
                                    WHERE DeveloperName like : strFilter+ '%']){
                                        
                                        if(Label.CM_Chat_Group_Name == strFilter){
                                            fullPublicGroupToIdMap.put(removeSpecialChar(singleGroupRec.DeveloperName), singleGroupRec.Id);
                                            
                                        }
                                        else{
                                            fullPublicGroupToIdMap.put(singleGroupRec.DeveloperName, singleGroupRec.Id);
                                        }
                                    }
        
        return fullPublicGroupToIdMap;        
    }
    
    /* Method to form a set of combination key with User Id and public Group Id  */
    //SCTM-335: Added a new parameter 
    //SC-5695: Added conditon to handle 'scm kc county/area' picklist
    public static Set<String> formRelatedPublicGroups(string strSCMKCQueues,String strChatCountry,String countryStr,String strSCMQueues, String linerBrandStr, Id UserId, Map<String, String>supportCountryMap, Map<String, Id>publicGroupToIdMap,String countryListLNS,String strMnAQueues){
        
        Set<String> userIdToPublicGroupSet = new Set<String>();
        List<String>userSupportCOuntryList = new List<String>(); //List to store the selected Support Countries as a list
        List<String>linerBrandList = new List<String>(); //List to store the selected Liner Brands as a list
        List<String>userSCMQueuesList = new List<String>(); //SCTM:335 : List to capture SCM Queues to assign public group to users
        List<String> lnsCountryList = new List<String>();
        List<String>userSCMQueuesListKC = new List<String>();
        List<String> userMnAQueuesList = new List<String>(); //SC-7849
        
        system.debug('countryStr##'+countryStr);
        //
        if(countryListLNS !=null)
            lnsCountryList = countryListLNS.contains(';')? countryListLNS.split(';') : new List<String>{countryListLNS};
            
        //Split the list of countries selected
        if(countryStr != null)
            userSupportCountryList = countryStr.contains(';')? countryStr.split(';') : new List<String>{countryStr};
                
                //SCTM:335 : List to capture SCM Queues to assign public group to users
                if(strSCMQueues != null)
                userSCMQueuesList = strSCMQueues.contains(';')? strSCMQueues.split(';') : new List<String>{strSCMQueues};
                    
                    //
                    if(strSCMKCQueues!=null)
                    userSCMQueuesListKC = strSCMKCQueues.contains(';')? strSCMKCQueues.split(';') : new List<String>{strSCMKCQueues};
                    
                    //SC-7849
                    if(strMnAQueues!=null)
                    userMnAQueuesList = strMnAQueues.contains(';')? strMnAQueues.split(';') : new List<String>{strMnAQueues};
                    
                    //Split the Liner Brands
                    if(linerBrandStr != null)
                    linerBrandList = linerBrandStr.contains(';')? linerBrandStr.split(';') : new List<String>{linerBrandStr}; //Split the Liner Brand to a list
                        
                        //Split the list of countries selected
                        if(strChatCountry != null)
                        userSupportCountryList = strChatCountry.contains(';')? strChatCountry.split(';') : new List<String>{strChatCountry};        
                            
                            //Form the combination key (user id to public group id)
                            for(String singleLinerBrandStr : linerBrandList){
                                
                                //#RQ-001771. Public group member ship logic for MLL
                                //#RQ-001772 Dynamic public group assignment for Sealand.
                                if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MLL).contains(singleLinerBrandStr) ||
                                   BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(singleLinerBrandStr)) {
                                       
                                       //For MLL there is only one public group. MLL public groups are not country specific. 
                                       String formPublicGroupName = Label.CM_Public_Group_Name + BrandUtilities.getBrandShortForm(singleLinerBrandStr);
                                       if(publicGroupToIdMap.containsKey(formPublicGroupName)){
                                           
                                           userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(formPublicGroupName));
                                           
                                       }
                                       continue;
                                       
                                   }//#RQ-001771.End
                                
                                for(String singleSuppCountryStr : userSupportCountryList){
                                    
                                    if(linerBrandList != null && BrandUtilities.getBrandShortForm(singleLinerBrandStr) != null) {
                                        
                                        String formPublicGroupName = Label.CM_Public_Group_Name + BrandUtilities.getBrandShortForm(singleLinerBrandStr) + '_' + supportCountryMap.get(singleSuppCountryStr);
                                        system.debug('formPublicGroupName##'+formPublicGroupName);
                                        if(publicGroupToIdMap.containsKey(formPublicGroupName)){
                                            
                                            userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(formPublicGroupName));
                                            
                                        }            
                                    }            
                                }    
                                
                            }
        //SCTM-335 : SCM Queues
        for(String singleSCMQueueStr : userSCMQueuesList){    
            //scm public group logic
            String publicGroup;
            if(!singleSCMQueueStr.contains('(')){
                 List<String> tempStrList = singleSCMQueueStr.split(' '); 
                 string finalvalue = '';
                for(String value:tempStrList){
                    finalvalue = finalvalue+'_'+value.trim();
                }
                singleSCMQueueStr = finalvalue.removeStart('_');
                publicGroup = Label.CM_Public_Group_Name+'SCM_'+singleSCMQueueStr;
                //For 'SCM KC Country/Area'
                for(String singleSCMQueueStrKC : userSCMQueuesListKC){
                      singleSCMQueueStrKC = singleSCMQueueStrKC.substringAfter('('); 
                      singleSCMQueueStrKC = singleSCMQueueStrKC.substringBefore(')');
                    publicGroup = Label.CM_Public_Group_Name+'SCM_'+singleSCMQueueStr+'_'+singleSCMQueueStrKC;
                      // For a single 'scm Queue' entry there can be multiple values for 'scm kc area/country' picklist values
                      if(publicGroupToIdMap.containsKey(publicGroup)){            
                        userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(publicGroup));            
                    } 
                }
            }else{
                 publicGroup = Label.CM_Public_Group_Name+'SCM_'+supportCountryMap.get(singleSCMQueueStr);
            }
           
                if(publicGroupToIdMap.containsKey(publicGroup)){            
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(publicGroup));            
                }   
        }
        system.debug('userIdToPublicGroupSet##'+userIdToPublicGroupSet);
        system.debug('strChatCountry##'+strChatCountry);
        if(strChatCountry != ''){
            for(String singleSuppCountryStr : userSupportCountryList){
                
                singleSuppCountryStr=removeSpecialChar(singleSuppCountryStr);
                String formPublicGroupName = 'Chat'+singleSuppCountryStr;
                system.debug('formPublicGroupName##'+formPublicGroupName);
                system.debug('publicGroupToIdMap##'+publicGroupToIdMap);
                if(publicGroupToIdMap.containsKey(formPublicGroupName)){
                    
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(formPublicGroupName));
                    
                }      
            }
        }
        
        //L&S logic to get group map 
            for(String singleSuppCountryStr : lnsCountryList){
                 List<String> tempStrList = singleSuppCountryStr.split('\\(');
                 string country, pref = 'Case_LNS_';
                if(tempStrList[0] != null){
                    country = tempStrList[0].trim();
                }  
                 String executionGroupName = pref+country+'_Execution';
                 String logisticsGroupName = pref+country+'_Logistics';
                 String publicGroup = Label.CM_Public_Group_Name+'LNS_'+supportCountryMap.get(singleSuppCountryStr);

                if(publicGroupToIdMap.containsKey(executionGroupName)){                    
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(executionGroupName));                    
                } 
                if(publicGroupToIdMap.containsKey(logisticsGroupName)){                    
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(logisticsGroupName));                    
                }
                if(publicGroupToIdMap.containsKey(publicGroup)){                    
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(publicGroup));                    
                } 
                
            }  
        
        //SC-7849 - Get group map for M&A queues
        for(String singleMnAQueueStr : userMnAQueuesList){
            String publicGroup;
            if(singleMnAQueueStr.contains('(')){
                List<String> tempStrList = singleMnAQueueStr.split(' '); 
                tempStrList.remove(2); //Remove Country Name
                string finalvalue = '';
                for(String value:tempStrList){
                    finalvalue = finalvalue+'_'+value.trim();
                }
                singleMnAQueueStr = finalvalue.removeStart('_');
                singleMnAQueueStr=singleMnAQueueStr.remove('(');
                singleMnAQueueStr=singleMnAQueueStr.remove(')');
                singleMnAQueueStr=singleMnAQueueStr.replaceAll('-','_');
                publicGroup = singleMnAQueueStr;
                if(publicGroupToIdMap.containsKey(publicGroup)){            
                    userIdToPublicGroupSet.add(UserId + ':' + publicGroupToIdMap.get(publicGroup));            
                } 
            }
        }
        system.debug('##### userIdToPublicGroupSet:'+userIdToPublicGroupSet);
        return userIdToPublicGroupSet;     
    }
    
    /* -------Method to form a set of combination key with User Id and public Group Id ---------------- */
    
    public static void assignChatCountries(List<User> newUserList, Map<Id,User> oldUserMap ){
        Map<String, String> supportCountryMap  = new Map<String, String>(); //Map which hold all the Support countries with country code
        Map<String, Id> publicGroupToIdMap = new Map<String, Id>(); //Map of all Customer Service public Groups
        Set<String> groupMemberDeletionSet = new Set<String>(); //Store key for group member deletion
        Set<String> groupMemberInsertSet = new Set<String>(); //Map to hold the key (public group : user) to insert Group members
        Set<Id> groupMemberIdsToBeDeleted = new Set<Id>(); //Store Ids of Group member to be deleted
        Set<Id> userIdForGroupMemberDel = new Set<Id>(); //Store the User Ids for which Group member to be deleted
        system.debug('newUserList##'+newUserList);
        if ( !newUserList.isEmpty() ){
            supportCountryMap = getAllSupportCountryCodes('Support_Countries__c');
            //Form a map of all Customer service Public Groups
            publicGroupToIdMap =getAllCustomerServicePublicGroups(Label.CM_Chat_Group_Name);
            for( User usrRec : newUserList){
                
                if( usrRec.Chat_Queues__c    != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).Chat_Queues__c == null))){
                    system.debug('Inside');
                    Set<String> publicGroupToAddSet = formRelatedPublicGroups(null, usrRec.Chat_Queues__c,null,null,null,usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    system.debug('publicGroupToAddSet##'+publicGroupToAddSet);
                    if(publicGroupToAddSet.size() > 0){
                        
                        groupMemberInsertSet.addAll(publicGroupToAddSet); //Add keys for grp members to be inserted
                        system.debug('groupMemberInsertSet##'+groupMemberInsertSet);
                        
                    }    
                    
                    
                    
                }
                //Condition: Update user with all Support Countries removed.
                else if( oldUserMap != null && usrRec.Chat_Queues__c == null && oldUserMap.get(usrRec.Id).Chat_Queues__c != null){
                    //When user record is updated and all support countries from user record are removed, remove all public groups.
                    //Method call : Retrieve a set of all public group names from which user need to be removed from.
                    Set<String> publicGroupToDeleteSet = formRelatedPublicGroups(null,oldUserMap.get(usrRec.Id).Chat_Queues__c,null,null,null,usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    
                    if( publicGroupToDeleteSet.size() > 0){
                        
                        groupMemberDeletionSet.addAll(publicGroupToDeleteSet);
                        userIdForGroupMemberDel.add(usrRec.Id);
                        
                    }            
                }
                //Condition: Update user with change in Support Countries or Liner Brand and Support Countries is not null.
                else if( oldUserMap != null && (usrRec.Chat_Queues__c != null || oldUserMap.get(usrRec.Id).Chat_Queues__c != usrRec.Chat_Queues__c)){                  
                    system.debug('$$$ 2');
                    //Method call : Form the Public Group Names to which the user be added/removed
                    Set<String> publicGroupFromNewSet = formRelatedPublicGroups( null,usrRec.Chat_Queues__c, null,null,null,usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    
                    Set<String> publicGroupFromOldSet = formRelatedPublicGroups(null,oldUserMap.get(usrRec.Id).Chat_Queues__c, null,null,null, usrRec.Id, supportCountryMap, publicGroupToIdMap,null,null);
                    system.debug('publicGroupFromNewSet Else'+publicGroupFromNewSet);
                    system.debug('publicGroupFromOldSet Else'+publicGroupFromOldSet);
                    
                    
                    Set<String> publicGroupOldSetToCheck = publicGroupFromOldSet.clone();
                    
                    // Old Group names compared with new Group names to check which are the Group names to be removed.
                    publicGroupOldSetToCheck.removeAll( publicGroupFromNewSet );
                    
                    if( publicGroupOldSetToCheck.size() > 0 ){
                        
                        groupMemberDeletionSet.addAll( publicGroupOldSetToCheck ); //List of public groups for which the group members for the user to be deleted
                        userIdForGroupMemberDel.add( usrRec.Id );
                    }
                    
                    // New Group names compared with old Group names to check which are the Group names to be added.
                    publicGroupFromNewSet.removeAll( publicGroupFromOldSet );
                    if( publicGroupFromNewSet.size() > 0 ){
                        
                        groupMemberInsertSet.addAll(publicGroupFromNewSet);//List of public groups for which group members to be inserted
                        
                    }            
                }
                
                
                
                
            }
            
            
        }
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){
            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);
            
        }
        system.debug('##groupMemberInsertSet'+groupMemberInsertSet);
        Map<String, Id> groupMemberRemoveMap = new Map<String, Id>(); //Map to store the combination key of public group to user Id for group members to be deleted
        if( groupMemberDeletionSet.size() > 0 && userIdForGroupMemberDel.size() > 0 ){
            
            //Query the Group Members with available groups                    
            for(GroupMember gM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                  WHERE UserOrGroupId IN: userIdForGroupMemberDel]){
                                      
                                      groupMemberRemoveMap.put(gM.UserOrGroupId+':'+gM.GroupId, gM.Id);  
                                  }
        }
        if(groupMemberRemoveMap != null && groupMemberRemoveMap.size() >0){            
            for(String groupMemberKey : groupMemberDeletionSet){                
                if(groupMemberRemoveMap.containsKey(groupMemberKey)){
                    
                    groupMemberIdsToBeDeleted.add(groupMemberRemoveMap.get(groupMemberKey));
                    
                }                
            }            
        }
        
        
        
        
        //Method call : Add or delete group members for users
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){
            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);
            
        }    
        
    }
    
    
    
    public static string removeSpecialChar(string strText){
        
        strText = strText.replaceAll('[^a-zA-Z0-9\\s+]', '');
        strText=strText.trim();
        strText=strText.replaceAll( '\\s+', '');
        return strText;
    }
    /*-------------------------end user chat queue-----------------------------------*/
    
    /* Method to add and delete the Group Members. This is a future method to avoid MIXED DML exception.
userWithPublicGroupKeyToInsertList contains a combination key of Group Id : User Id. Using this key, 
form the Group Member records to be inserted.
groupMembersToDeleteSet contains the Group member Ids to be deleted.
*/
    @future
    public static void addRemoveGroupMembers(Set<String> userWithPublicGroupKeyToInsertList, Set<Id>groupMembersToDeleteSet){ 
        string myid = userinfo.getuserid();
        system.debug('textcontextuser :'+myid);
        
        if(userWithPublicGroupKeyToInsertList !=  null && userWithPublicGroupKeyToInsertList.size() > 0){
            /* Method to insert group members correspoding to public groups
Split the combination key at ':' and get the user id and public group for inserting group member */
            
            List<GroupMember>groupMemberToInsertList = new List<GroupMember>();
            
            for(String singleKey : userWithPublicGroupKeyToInsertList){
                
                if(singleKey.Contains(':')){ //Seperate Group Id and User Id
                    
                    List<String> singleKeyList = singleKey.split(':');
                    
                    if(singleKeyList.size()> 0 && singleKeyList[0] != null && singleKeyList[1] != null){
                        
                        GroupMember grpMember = new GroupMember();
                        grpMember.GroupId = Id.valueOf(singleKeyList[1]);
                        grpMember.UserOrGroupId = Id.valueOf(singleKeyList[0]);
                        groupMemberToInsertList.add(grpMember);      
                        
                    }            
                }            
            }
            system.debug('##### groupMemberToInsertList:'+groupMemberToInsertList);
            if(groupMemberToInsertList != null && groupMemberToInsertList.size() > 0){
                Database.SaveResult[] results = Database.insert(groupMemberToInsertList, false);
                
                // Iterate through each returned result and check for failures
                for (Database.SaveResult sr : results) {
                    
                    if (!sr.isSuccess()) {                
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            
                            System.debug('##### The following error has occurred- ');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            
                        }               
                    }            
                }        
            }
        }
        if(groupMembersToDeleteSet != null && groupMembersToDeleteSet.size() > 0){
            List<GroupMember>groupMembersToDeleteList = [SELECT Id, GroupId, UserOrGroupId 
                                                         FROM GroupMember 
                                                         WHERE Id IN: groupMembersToDeleteSet];
            
            system.debug('##### groupMembersToDeleteList:'+groupMembersToDeleteList);
            if(groupMembersToDeleteList !=null && groupMembersToDeleteList.size()>0){
                
                Database.DeleteResult[] results = Database.delete(groupMembersToDeleteList, false);
                
                // Iterate through each returned result and check for failures
                for (Database.DeleteResult sr : results) {
                    
                    if (!sr.isSuccess()) {
                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            
                            System.debug('##### The following error has occurred- ');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            
                        }                   
                    }                
                }                    
            }
        }
    }
    
    
    public static void assignPermissionset(list<User>lstUser){
        list<PermissionSetAssignment>lstPer = new list<PermissionSetAssignment>();
        list<PermissionSetAssignment>lstPerDel = new list<PermissionSetAssignment>();
        list<User>lstUserAssign = new list<User>();
        map<String,string>mapUsrid_per = new map<String,string>();
        //integer i=0;
        for(PermissionSetAssignment p:[select id,AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId IN :lstUser and PermissionSetID=:label.Presence_Status_Permission_set]){
            system.debug('p.AssigneeId##'+p.AssigneeId);
            system.debug('p.PermissionSetId##'+p.PermissionSetId);
            
            mapUsrid_per.put(String.valueof(p.AssigneeId).substring(0, 15)+'_'+String.valueof(p.PermissionSetId).substring(0, 15),p.PermissionSetId);
            
        }
        for(User u :lstUser ){
            system.debug('u.id'+u.id);
            system.debug('p.label.Presence_Status_Permission_set##'+label.Presence_Status_Permission_set);
            if(!mapUsrid_per.containskey(String.valueof(u.id).substring(0, 15)+'_'+label.Presence_Status_Permission_set)){
                lstUserAssign.add(u);
            }
            
            
        }
        for(User u : lstUserAssign){
            PermissionSetAssignment p = new PermissionSetAssignment(AssigneeId =u.id,PermissionSetId=label.Presence_Status_Permission_set); 
            lstPer.add(p);
        }
        if(!lstPer.isEmpty()){
            insert lstPer;
        }
        
    }
    Public static void assignedWizardPersmission(List<User> usrlist){
        list<PermissionSetAssignment>lstPer = new list<PermissionSetAssignment>();
        list<PermissionSetAssignment>lstPerDel = new list<PermissionSetAssignment>();
        map<String,String> mapusertoWizard = new map<String,String>();
        list<User>lstUsertoProvideWizard = new list<User>();
        map<Id,String>mapofId = new map<Id,String>();
        for(PermissionSetAssignment p:[select id,AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId IN :usrlist and (PermissionSetID=:label.Opportunity_Wizard)]){
            mapusertoWizard.put(String.valueof(p.AssigneeId).substring(0, 15)+'_'+String.valueof(p.PermissionSetId).substring(0, 15),p.PermissionSetId);
            System.debug('%%%Unique key' + mapusertoWizard.keyset());
        }
        for(User u : usrlist){
            if(!mapusertoWizard.containskey(String.valueof(u.id).substring(0, 15)+'_'+label.Opportunity_Wizard)){
                if(u.IsActive == true){
                System.debug('%%%mapusertoWizard1' + mapusertoWizard.keyset());
                System.debug('%%%value' + (String.valueof(u.id).substring(0, 15)+'_'+label.Opportunity_Wizard));
                mapofId.put(u.Id,label.Opportunity_Wizard);
                System.debug('%%%mapOfId' + mapofId);
            }
          }      
        }
        for(String u : mapofId.keyset()){ 
            String values = mapofId.get(u);
            if(values.equals(label.Opportunity_Wizard)){
               PermissionSetAssignment p = new PermissionSetAssignment(AssigneeId =u,PermissionSetId=label.Opportunity_Wizard);
                lstPer.add(p);
                System.debug('$$$' +lstPer);
            }   
          }
        if(!lstPer.isEmpty()){
            insert lstPer;
        }
    }        
    
    //SFSE-15210
    public static void assignEditdefaultpricesPersmission(List<User> usrlist){
        list<PermissionSetAssignment> lstPsa = new list<PermissionSetAssignment>();
        Id PermissionSetId;
        Set<Id> AssigneeIds = new Set<Id>();
        for (PermissionSetAssignment pst : [select id,Assignee.name,AssigneeId,PermissionSetId from PermissionSetAssignment  where PermissionSet.Name =: Label.Edit_Default_Prices_Permission_set]){
            AssigneeIds.add(pst.AssigneeId);
            if(PermissionSetId == null){
                PermissionSetId = pst.PermissionSetId;
            }
        }
        for (User u : usrlist){ 
            if(!AssigneeIds.contains(u.id)){
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = PermissionSetId, AssigneeId = u.Id);
                lstPsa.add(psa);
            }
        }
        if(!lstPsa.isEmpty()){
           Database.SaveResult[] srList = Database.Insert(lstPsa,false);// Assign Edit Default Price Permission set to users
           ErrorLogger.writeErrors('SFDC', 'User', 'UserTriggerUtility.assignEditdefaultpricesPersmission', srList, lstPsa) ; 
        }
    }
    //SFSE-15210
    public static void removeEditdefaultpricesPersmission(List<User> usrlist){
        list<PermissionSetAssignment> lstPsa = new list<PermissionSetAssignment>();
        lstPsa = [select id,Assignee.name,AssigneeId from PermissionSetAssignment  where PermissionSet.Name =: Label.Edit_Default_Prices_Permission_set and AssigneeId in: usrlist];
        if(!lstPsa.isEmpty()){
           Database.deleteResult[] drList = Database.Delete(lstPsa,false);// Remove Edit Default Price Permission set from users
           ErrorLogger.writeErrors('SFDC', 'User', 'UserTriggerUtility.assignEditdefaultpricesPersmission', drList, lstPsa) ; 
        }
    }
    
    // #RQ-009466 - Start     
    
    /*
* Method which makes the Inactive user related Request Information Contact status to be changed to 'Remove'
*
*/   
    @future
    public static void changeRequestInformationStatus(Set<Id> inactiveUserIds){
        List<Request_Information__c> riList = [SELECT Id, Change_Status__c FROM Request_Information__c WHERE User__c in :inactiveUserIds];
        if(!riList.isEmpty()){
            for(Request_Information__c ri: riList){
                ri.Change_Status__c = 'Remove';
            }           
            Database.SaveResult[] srList = Database.Update(riList,false);// create Records
            ErrorLogger.writeErrors('SFDC', 'User', 'UserTriggerUtility.changeRequestInformationStatus', srList, riList) ;
        }      
    }
    
    // #RQ-009466 - End
 
    @future
    public static void deleteAccountTeamMember(Set<Id> setInactiveUserIds){
        List<AccountTeamMember> lstAccountTeamMember = [SELECT ID FROM AccountTeamMember WHERE UserId in :setInactiveUserIds];
        if (!lstAccountTeamMember.isEmpty()){
            Database.DeleteResult[] lstATMDelete = Database.delete(lstAccountTeamMember, false);
            ErrorLogger.writeErrors('SFDC', 'User', 'UserTriggerUtility.deleteAccountTeamMember', lstATMDelete, lstAccountTeamMember);
        }
    }
    
    @future
    public static void deleteOpportunityTeamMember(Set<Id> setInactiveUserIds){
        Map<String, Boolean> mapSplitOwnerOppIdToBoolean = new Map<String, Boolean>();
        List<OpportunitySplit> lstOpenOppSplits = [SELECT SplitOwnerId, OpportunityId FROM OpportunitySplit WHERE Opportunity.IsClosed = false AND SplitOwnerId in :setInactiveUserIds];
        for (OpportunitySplit recOppSplit : lstOpenOppSplits){
            mapSplitOwnerOppIdToBoolean.put(recOppSplit.SplitOwnerId + ':' + recOppSplit.OpportunityId, true);
        }

        List<OpportunityTeamMember> lstOpportunityTeamMember = [SELECT Id, UserId, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.IsClosed = false AND UserId in :setInactiveUserIds];
        List<OpportunityTeamMember> lstOTMToDelete = new List<OpportunityTeamMember>();

        for (OpportunityTeamMember recOTM : lstOpportunityTeamMember){
            Boolean blnSplitExists = (mapSplitOwnerOppIdToBoolean.size() > 0 && mapSplitOwnerOppIdToBoolean.containsKey(recOTM.UserId + ':' + recOTM.OpportunityId)) ? mapSplitOwnerOppIdToBoolean.get(recOTM.UserId + ':' + recOTM.OpportunityId) : false;//SFSE-14825 : Added map containsKey check to avoid null pointer
            if (!blnSplitExists){
                lstOTMToDelete.add(recOTM);
            }
        }

        if (!lstOTMToDelete.isEmpty()){
            Database.DeleteResult[] lstOTMDelete = Database.delete(lstOTMToDelete, false);
            ErrorLogger.writeErrors('SFDC', 'User', 'UserTriggerUtility.deleteOpportunityTeamMember', lstOTMDelete, lstOTMToDelete);
        }
    }
    
    // Method to populate Brand_Logic__c based on Liner_Brand__c
    public static void setBrandLogic (List<User> users) {
        for (User u : users) {
            u.Brand_Logic__c = u.Liner_Brand__c;
        }
    }
    
    // SC-7849 : Method to Assign users to group based on M&A Queues selected on user    
    public static void assignDynamicMandAQueues(List<User> newUserList, Map<Id,User> oldUserMap ){
        Map<String, Id> publicGroupToIdMap = new Map<String, Id>(); //Map of all Customer Service public Groups
        Set<String> groupMemberDeletionSet = new Set<String>(); //Store key for group member deletion
        Set<String> groupMemberInsertSet = new Set<String>(); //Map to hold the key (public group : user) to insert Group members
        Set<Id> groupMemberIdsToBeDeleted = new Set<Id>(); //Store Ids of Group member to be deleted
        Set<Id> userIdForGroupMemberDel = new Set<Id>(); //Store the User Ids for which Group member to be deleted
        system.debug('newUserList##'+newUserList);
        if ( !newUserList.isEmpty() ){            
            //Form a map of all Customer service Public Groups
            publicGroupToIdMap =getAllCustomerServicePublicGroups(Label.ECL_Public_Group_Name);
            for( User usrRec : newUserList){
                
                if( usrRec.M_A_queues__c != null && ( oldUserMap == null || (oldUserMap != null && oldUserMap.get(usrRec.Id).M_A_queues__c == null))){
                    Set<String> publicGroupToAddSet = formRelatedPublicGroups(null, null,null,null,null,usrRec.Id, null, publicGroupToIdMap,null,usrRec.M_A_queues__c);
                    system.debug('publicGroupToAddSet##'+publicGroupToAddSet);
                    if(publicGroupToAddSet.size() > 0){                        
                        groupMemberInsertSet.addAll(publicGroupToAddSet); //Add keys for grp members to be inserted
                        system.debug('groupMemberInsertSet##'+groupMemberInsertSet);                        
                    }                            
                }
                //Condition: When user record is updated and all M&A queues from user record are removed, remove all public groups.
                else if( oldUserMap != null && usrRec.M_A_queues__c == null && oldUserMap.get(usrRec.Id).M_A_queues__c != null){
                    Set<String> publicGroupToDeleteSet = formRelatedPublicGroups(null,null,null,null,null,usrRec.Id, null, publicGroupToIdMap,null,oldUserMap.get(usrRec.Id).M_A_queues__c);                    
                    if( publicGroupToDeleteSet.size() > 0){                        
                        groupMemberDeletionSet.addAll(publicGroupToDeleteSet);
                        userIdForGroupMemberDel.add(usrRec.Id);                        
                    }            
                }
                //Condition: Update user with change in M&A queues is not null.
                else if( oldUserMap != null && (usrRec.M_A_queues__c != null || oldUserMap.get(usrRec.Id).M_A_queues__c != usrRec.M_A_queues__c)){                  
                    //Method call : Form the Public Group Names to which the user be added/removed
                    Set<String> publicGroupFromNewSet = formRelatedPublicGroups( null,null, null,null,null,usrRec.Id, null, publicGroupToIdMap,null,usrRec.M_A_queues__c);
                    
                    Set<String> publicGroupFromOldSet = formRelatedPublicGroups(null,null, null,null,null, usrRec.Id, null, publicGroupToIdMap,null,oldUserMap.get(usrRec.Id).M_A_queues__c);
                    system.debug('publicGroupFromNewSet Else'+publicGroupFromNewSet);
                    system.debug('publicGroupFromOldSet Else'+publicGroupFromOldSet);                    
                    
                    Set<String> publicGroupOldSetToCheck = publicGroupFromOldSet.clone();
                    
                    // Old Group names compared with new Group names to check which are the Group names to be removed.
                    publicGroupOldSetToCheck.removeAll( publicGroupFromNewSet );                    
                    if( publicGroupOldSetToCheck.size() > 0 ){                        
                        groupMemberDeletionSet.addAll( publicGroupOldSetToCheck ); //List of public groups for which the group members for the user to be deleted
                        userIdForGroupMemberDel.add( usrRec.Id );
                    }
                    
                    // New Group names compared with old Group names to check which are the Group names to be added.
                    publicGroupFromNewSet.removeAll( publicGroupFromOldSet );
                    if( publicGroupFromNewSet.size() > 0 ){                        
                        groupMemberInsertSet.addAll(publicGroupFromNewSet);//List of public groups for which group members to be inserted                        
                    }            
                } 
            }           
        }
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);            
        }
        system.debug('##groupMemberInsertSet'+groupMemberInsertSet);
        Map<String, Id> groupMemberRemoveMap = new Map<String, Id>(); //Map to store the combination key of public group to user Id for group members to be deleted
        if( groupMemberDeletionSet.size() > 0 && userIdForGroupMemberDel.size() > 0 ){            
            //Query the Group Members with available groups                    
            for(GroupMember gM : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                  WHERE UserOrGroupId IN: userIdForGroupMemberDel]){                                      
                                      groupMemberRemoveMap.put(gM.UserOrGroupId+':'+gM.GroupId, gM.Id);  
                                  }
        }
        if(groupMemberRemoveMap != null && groupMemberRemoveMap.size() >0){            
            for(String groupMemberKey : groupMemberDeletionSet){                
                if(groupMemberRemoveMap.containsKey(groupMemberKey)){                    
                    groupMemberIdsToBeDeleted.add(groupMemberRemoveMap.get(groupMemberKey));                    
                }                
            }            
        }

        //Method call : Add or delete group members for users
        if(groupMemberInsertSet != null || groupMemberIdsToBeDeleted != null){            
            addRemoveGroupMembers(groupMemberInsertSet, groupMemberIdsToBeDeleted);            
        }    
        
    }
}