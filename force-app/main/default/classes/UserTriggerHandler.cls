/**
* Trigger Handler Class for UserTrigger
* 
*Version  Date         Owner                                    RQ#           Description
****************************************************************************************************************************************
*7.0      19/06/2017   meghana.gupta@ust-global.com             #RQ-005483    Implementing CBO architecture. Make User name init caps, add user to brand specific groups, do not auto-populate cluster
*8.0      19/06/2017   Nisha.arjunan@ust-global.com             #RQ-005477    Customers should not get email when chatter post is being added by internal users.
*8.0      06/03/2018   Junaid.Khader@ust-global.com             #RQ-007716    Added checks for assignToSalesGroup_UserList in after insert and after update
*9.0      28/11/2018   Jagadeesan.Sakthivel@ust-global.com      #RQ-009466    Added future method to make the request information change status to be 'Removed' for Inactive users
*10.0     21/05/2019   mohammad.naved@maersk.com                #RQ-010755    Dynamic chat queue assigmnet for User
*10.1     21/05/2019   mohammad.naved@maersk.com                #RQ-010755    Dynamic assigned permission set to the Live agent
*11.0     24/01/2020    Rakesh @maersk                          #RQ-012996      Change Customer User License
*12.0     10/01/2020    ramadevi@maersk.com                     #SC-515        N&C - Assignment of users to public groups
*13.0     28/07/2020   Manik@UST                                #SCTM-335     SCM CTM - User Assignments to Public Group
*14.0     14/10/2020   sriram@maersk                            SC-1160        L&S - Assignment of users to public groups
*14.1     30/06/2021   Nitin@Maersk                             SFSE-6249     Added call to delete AccountTeamMember and OppTeamMember when user is deactivated
*15.0	  07/04/2022   Sreya@Maersk                             SC - 4505     Add/Remove users from 4PL group based on 4PL Account selection
*16.0     28/06/2022   Ronnie@SF                                SPI-100       Populate 
*17.0	  14/07/2023	Nayana@maersk							SC-7849		  Added call to UserTriggerUtility.assignDynamicMandAQueues for M&A Queues group assignment
*18.0     20/07/2023    Bharti@maersk                          SFSE-12445     Added code to call 'BatchUpdateTAAPortfolioOwnerSalesJobFunc' batch class
*19.0     06/10/2023  shilpa.nagtode@maersk                     SFSE-12713             logic added to assigned wizard permission set while user creation and updation.
*20.0	  27/05/2024	Jothsana@maersk							SFSE-15210	  Logic added to assign Edit Default Prices permission set to user having sales job functions as 'Product Organization'
*/

public class UserTriggerHandler extends TriggerHandler {
    
    
    public map<Id, User> newMap;
    public map<Id, User> oldMap;
    
    public UserTriggerHandler() {
        this.newMap = (map<Id, User>)Trigger.newMap;
        this.oldMap = (map<Id, User>)Trigger.oldMap; 
    }
    
    // Use an UserRecordSelector instance to initiate and form lists of users that need to be considered for different functionalities
    public UserRecordSelector usrRecordSelector;
    public override void getRecordSelector() {
        usrRecordSelector = new UserRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        // method to set User region
        if ( !usrRecordSelector.setRegionUserList.isEmpty())
            UserFieldPopulator.populateUserRegion( usrRecordSelector.setRegionUserList );         
        
        // method to set FED Id to lower case
        if ( !usrRecordSelector.setFEDList.isEmpty())
            UserFieldPopulator.setFedIdToLowerCase( usrRecordSelector.setFEDList ); 
        
        // method to set name to init caps case
        if ( !usrRecordSelector.nameChangedUserList.isEmpty())
            UserFieldPopulator.setUserNameCase( usrRecordSelector.nameChangedUserList ); 
        
        // method to change/set default community license for customer users - #RQ-012996
        if ( !usrRecordSelector.setRegionUserList.isEmpty())
            CommunityUserUtility.changeUserLicense(usrRecordSelector.setRegionUserList);
        
        // Method to update Brand_Logic__c based on brand multi-select picklist
        if (!usrRecordSelector.assignBrandsUserList.isEmpty()) {
            UserTriggerUtility.setBrandLogic(usrRecordSelector.assignBrandsUserList);
        }
        if ( !usrRecordSelector.mirrorAccess_UserList.isEmpty())
            UserFieldPopulator.mirrorUser(usrRecordSelector.mirrorAccess_UserList);
    }
    
    public override void onBeforeUpdate() {
        // method to set Synced Flag to true
        if ( !usrRecordSelector.syncFlagUserList.isEmpty())
            UserFieldPopulator.synchedFlagUpdate( usrRecordSelector.syncFlagUserList ); //To set the Synched Flag field.
        
        // method to set Last Active Date based on user is made active or inactive
        if ( !usrRecordSelector.setInactiveUserList.isEmpty())      
            UserFieldPopulator.setLastActiveDate ( usrRecordSelector.setInactiveUserList);
        
        // method to set User region
        if ( !usrRecordSelector.setRegionUserList.isEmpty())
            UserFieldPopulator.populateUserRegion( usrRecordSelector.setRegionUserList );         
        
        // method to set FED Id to lower case
        if ( !usrRecordSelector.setFEDList.isEmpty())
            UserFieldPopulator.setFedIdToLowerCase( usrRecordSelector.setFEDList ); 
        
        // method to set name to init caps case
        if ( !usrRecordSelector.nameChangedUserList.isEmpty())
            UserFieldPopulator.setUserNameCase( usrRecordSelector.nameChangedUserList ); 
        
        // Method to update Brand_Logic__c based on brand multi-select picklist
        if (!usrRecordSelector.assignBrandsUserList.isEmpty()) {
            UserTriggerUtility.setBrandLogic(usrRecordSelector.assignBrandsUserList);
        }
        if ( !usrRecordSelector.mirrorAccess_UserList.isEmpty())
            UserFieldPopulator.mirrorUser(usrRecordSelector.mirrorAccess_UserList);
    }
    
    public override void onAfterInsert() {
        
        // skip logic if trigger is executed as as result of insert/update from batch job
        if ( ! System.isBatch() ){
            
            // Method to set User's cluster or insert User cluster details in User Cluster object if user cluster is modified
            if ( !usrRecordSelector.setRegionUserList.isEmpty())
                UserUtilities.manageUserCluster( usrRecordSelector.setRegionUserList );     
            
            // method to assign user to public group
            //Added extra check with regard to #RQ-007716 for assignToSalesGroup_UserList
            if (!usrRecordSelector.assignToLS_UserList.isEmpty() || !usrRecordSelector.assignToGroup_UserList.isEmpty() || !usrRecordSelector.assignToBrandGroup_UserList.isEmpty() || !usrRecordSelector.assignToSalesGroup_UserList.isEmpty() || !usrRecordSelector.assignToGrp4PLAccount_UserList.isEmpty() || ! usrRecordSelector.assignToGrpMC_RestrictedAcc_UserList.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                //SC-515 : Added parameter assignToGrpCMVisibility_UserList  to assignDynamicSupportCountries
                //// SC-1160 auto assign or remove LNS queues  
                //SC-4505 : 4PL - N&C - Assignment of 4PL Account specific public group to users
                
                UserTriggerUtility.assignDynamicSupportCountries(usrRecordSelector.assignToLS_UserList, usrRecordSelector.assignToGroup_UserList, oldUserMap, usrRecordSelector.assignToBrandGroup_UserList, usrRecordSelector.assignToSalesGroup_UserList,usrRecordSelector.assignToGrpCMVisibility_UserList, usrRecordSelector.assignToGrp4PLAccount_UserList,usrRecordSelector.assignToGrpMC_RestrictedAcc_UserList);    
            }
            //SCTM-335 : assignDynamicSCMQueues
            if ( !usrRecordSelector.assignToSCMQueues_UserList.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignDynamicSCMQueues( usrRecordSelector.assignToSCMQueues_UserList, oldUserMap);    
            }
            if ( !usrRecordSelector.assignToChat_userlist.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignChatCountries( usrRecordSelector.assignToChat_userlist, oldUserMap );    
            }
            if(!usrRecordSelector.assignPermissionsetToChat_userlist.isEmpty()){
                system.debug('assignPermissionsetToChat_userlist##'+usrRecordSelector.assignPermissionsetToChat_userlist);
                UserTriggerUtility.assignPermissionset(usrRecordSelector.assignPermissionsetToChat_userlist);
            }
            
            //SC-7849 - Assign queues to M&A users
            if ( !usrRecordSelector.userListAssignToMnAQueues.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignDynamicMandAQueues( usrRecordSelector.userListAssignToMnAQueues, oldUserMap);    
            }
            // SC-1160 auto assign or remove LNS queues      
            /* if ( !usrRecordSelector.assignToLS_UserList.isEmpty()){
Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
UserTriggerUtility.assignDynamicLNSQueues( usrRecordSelector.assignToLS_UserList, oldUserMap);    
}*/
        } 
        
        // #RQ-005477 - Customers should not get email when chatter post is being added by internal users.
        if ( !usrRecordSelector.setCommunityUserIds.isEmpty() ) {
            CommunityUserUtility.setPreferencesDisableAllFeedsEmailToFalse(usrRecordSelector.setCommunityUserIds);     
        }
        if(!usrRecordSelector.assignOpportunityWizardPermissionset.isEmpty()){
            UserTriggerUtility.assignedWizardPersmission(usrRecordSelector.assignOpportunityWizardPermissionset);
        }

		//SFSE-15210
        if(!usrRecordSelector.assignEditDefaultPricesPermissionSet.isEmpty()){
            UserTriggerUtility.assignEditdefaultpricesPersmission(usrRecordSelector.assignEditDefaultPricesPermissionSet);
        }
        //SFSE-15210
        if(!usrRecordSelector.RemoveEditDefaultPricesPermissionSet.isEmpty()){
            UserTriggerUtility.removeEditdefaultpricesPersmission(usrRecordSelector.RemoveEditDefaultPricesPermissionSet);
        }       
        
    }
    
    public override void onAfterUpdate() {
        
        // skip logic if trigger is executed as as result of insert/update from batch job
        if ( ! System.isBatch() ){
            
            // Method to set User's cluster or insert User cluster details in User Cluster object if user cluster is modified
            if ( !usrRecordSelector.setRegionUserList.isEmpty())
                UserUtilities.manageUserCluster( usrRecordSelector.setRegionUserList ); //To update the user cluster / create new user cluster.    
            // method to assign user to public group
            
            //Added extra check with regard to #RQ-007716 for assignToSalesGroup_UserList
            if (!usrRecordSelector.assignToLS_UserList.isEmpty() || !usrRecordSelector.assignToGroup_UserList.isEmpty() || !usrRecordSelector.assignToBrandGroup_UserList.isEmpty() || !usrRecordSelector.assignToSalesGroup_UserList.isEmpty() || !usrRecordSelector.assignToGrpCMVisibility_UserList.isEmpty()  || ! usrRecordSelector.assignToGrp4PLAccount_UserList.isEmpty() || ! usrRecordSelector.assignToGrpMC_RestrictedAcc_UserList.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                //SC-515 : Added parameter assignToGrpCMVisibility_UserList  to assignDynamicSupportCountries
                //// SC-1160 auto assign or remove LNS queues  
                //SC-4505 : 4PL - N&C - Assignment of 4PL Account specific public group to users
                UserTriggerUtility.assignDynamicSupportCountries(usrRecordSelector.assignToLS_UserList, usrRecordSelector.assignToGroup_UserList, oldUserMap, usrRecordSelector.assignToBrandGroup_UserList, usrRecordSelector.assignToSalesGroup_UserList,usrRecordSelector.assignToGrpCMVisibility_UserList,usrRecordSelector.assignToGrp4PLAccount_UserList,usrRecordSelector.assignToGrpMC_RestrictedAcc_UserList );    
            }
            system.debug('usrRecordSelector.assignToChat_userlist##'+usrRecordSelector.assignToChat_userlist);
            //SCTM-335 : assignDynamicSCMQueues
            if ( !usrRecordSelector.assignToSCMQueues_UserList.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignDynamicSCMQueues( usrRecordSelector.assignToSCMQueues_UserList, oldUserMap);    
            }
            if ( !usrRecordSelector.assignToChat_userlist.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignChatCountries( usrRecordSelector.assignToChat_userlist, oldUserMap );    
            }
            if(!usrRecordSelector.assignPermissionsetToChat_userlist.isEmpty()){
                system.debug('assignPermissionsetToChat_userlist##'+usrRecordSelector.assignPermissionsetToChat_userlist);
                UserTriggerUtility.assignPermissionset(usrRecordSelector.assignPermissionsetToChat_userlist);
            }
            
            if(!usrRecordSelector.assignOpportunityWizardPermissionset.isEmpty()){
                UserTriggerUtility.assignedWizardPersmission(usrRecordSelector.assignOpportunityWizardPermissionset);
            }
            
            //SFSE-15210
            if(!usrRecordSelector.assignEditDefaultPricesPermissionSet.isEmpty()){
                UserTriggerUtility.assignEditdefaultpricesPersmission(usrRecordSelector.assignEditDefaultPricesPermissionSet);
            }
            //SFSE-15210
            if(!usrRecordSelector.RemoveEditDefaultPricesPermissionSet.isEmpty()){
                UserTriggerUtility.removeEditdefaultpricesPersmission(usrRecordSelector.RemoveEditDefaultPricesPermissionSet);
            }
            
            //SC-7849 - Assign queues to M&A users
            if ( !usrRecordSelector.userListAssignToMnAQueues.isEmpty()){
                Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
                UserTriggerUtility.assignDynamicMandAQueues( usrRecordSelector.userListAssignToMnAQueues, oldUserMap);    
            }           
            // SC-1160 auto assign or remove LNS queues      
            /*  if ( !usrRecordSelector.assignToLS_UserList.isEmpty()){
Map<Id,User> oldUserMap =( map<Id, User> ) Trigger.oldMap;
UserTriggerUtility.assignDynamicLNSQueues( usrRecordSelector.assignToLS_UserList, oldUserMap);    
}*/
        }   
        
        // #RQ-009466 - @future method call for making the inactive users related Request Information change status to be marked as Remove
        if( !usrRecordSelector.activeToInactiveUserIdsSet.isEmpty()){
            UserTriggerUtility.changeRequestInformationStatus(usrRecordSelector.activeToInactiveUserIdsSet);
            
            UserTriggerUtility.deleteAccountTeamMember(usrRecordSelector.activeToInactiveUserIdsSet);
            UserTriggerUtility.deleteOpportunityTeamMember(usrRecordSelector.activeToInactiveUserIdsSet);
        }        
        // SFSE- 12445 Method to update Portfolio_Owner_Sales_Job_Function__c field on TAA
        if(!usrRecordSelector.mapUserToSalesJobFunction.isEmpty()){
            Map<Id,Territory__c> mapOfTerritories =new Map<Id, Territory__c>([SELECT id, Portfolio_Owner__c, RecordTypeId from Territory__c WHERE Portfolio_Owner__c IN :usrRecordSelector.mapUserToSalesJobFunction.keySet()
                                                                              And RecordType.DeveloperName  = 'Portfolio']);
            
            Database.executeBatch(new BatchUpdateTAAPortfolioOwnerSalesJobFunc(usrRecordSelector.mapUserToSalesJobFunction.keySet(),usrRecordSelector.mapUserToSalesJobFunction,mapOfTerritories.keySet()),200);
        }
    }
}