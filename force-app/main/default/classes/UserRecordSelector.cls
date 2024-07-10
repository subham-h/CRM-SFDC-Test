/**
* Purpose  : Centralize the record selection process for User object.
*          Defines the methods which iterate and segregate the User records for further use.
* 
* Revision Ref Number   Date        Owner                   Description
* -------- ----------   ----------- -------------------     -----------
* 1.0      RQ-005483    19-Jun-2017 Meghana@UST             Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0      RQ-005477    4-Jun-2017  Nisha@ust               Customers should not get email when chatter post is being added by internal users.
* 3.0      RQ-007716    6-Mar-2018  Junaid@ust              Changes made to select users matching German criterion.
* 4.0      RQ-009466    28-Nov-2018 Jagadeesan@ust          Changes made to pick up the users who got changed from Active to Inactive.
* 5.0      RQ-009884    15-01-2019  meghana.gupta@ust       To handle user exception if user last name is updated to null
* 6.0      RQ-010166    22-03-2019  kelvin.fajardo@maersk   The existing field "User Level " for case object to be decommissioned
* 7.0      RQ-010755    21-05-2019  mohammad.naved@maersk   Dynamic chat queue assigmnet for User .
* 8.0      RQ-010755    21-05-2019  mohammad.naved@maersk   Dynamic assigned permission set to the Live agent.
* 7.0      #SC-515      10/06/2020  ramadevi@ust            N&C - Assignment of users to public groups
* 8.0      #SCTM-335    28/07/2020  Manik@UST               SCM CTM - User Assignments to Public Group
* 9.0      SC-1160      14/10/2020  sriram@maersk           L&S - Assignment of users to public groups
* 9.1      SFSE-6249    30/06/2021  Nitin@maersk            Added check if FedID isAllLowerCase
* 10.0	   SC - 4505    07/04/2022  Sreya@Maersk            Add/Remove users from 4PL group based on 4PL Account selection 
* 11.0      SPI-100      28/06/2022  Ronnie@SF               List assignBrandsUserList used to populate brand field when brands on user changes
* 12.0	   SC-5695      25/07/2022  Sunil.bs@Maersk         Add/Remove groups for SCM KC Users basis SCM KC Country/Area Selection
* 13.0 	   SC-7849		14/07/2023	nayana.sharma@maersk    Added userListAssignToMnAQueues to handle add/remove groups for M&A Queues 
* 13.0 	   SC-8395		21/08/2023	meghna.singh@maersk    	Carrefour Customer - SCM On-boarding Part 1
*14.0     SFSE-12445    20/09/2023  Bharti.rana@maersk      Added condition to check and prepare map for records whose salesjobfunction is updated
* 15.0    SFSE-12713   06/10/2023  shilpa.nagtode@maersk   logic added to assigned wizard permission set while user creation and updation.
* 16.0	  SFSE-15210	27/05/2024  Jothsana@maersk			Logic added to assign Edit Default Prices permission set to user having sales job functions as 'Product Organization'
*/
 
public class UserRecordSelector implements RecordSelector {
    
    private UserTriggerHandler usrTriggerHandler;
    
    public List<User> setRegionUserList = new List<User>(); // list of users for which we need to set User->Region field
    public List<User> setFEDList = new List<User>(); // list of users for which we need to convert FED Id to lower case
    public List<User> setInactiveUserList = new List<User>(); // list of users for which Active flag is modified, set Last Activity Date
    public List<User> syncFlagUserList = new List<User>(); // list of users for which we need to set Synced Flag = True
    public List<User> assignToGroup_UserList = new List<User>(); // list of users need to be added to public group
    public List<User> assignToBrandGroup_UserList = new List<User>(); // list of users need to be added to public group
    public List<User> assignToSalesGroup_UserList = new List<User>();
    public List<User> assignToSCMQueues_UserList = new List<User>(); //SCTM-335: list of users need to be added to public group
    public List<User> nameChangedUserList = new List<User>(); // list of users need to be added to public group
    public set<Id> setCommunityUserIds = new set<Id>(); // #RQ-005477 - set of community user ids.
    public List<User> assignToChat_userlist = new List<User>();
    public List<User> assignPermissionsetToChat_userlist = new List<User>();
    public Set<Id> activeToInactiveUserIdsSet = new Set<Id>(); // #RQ-009466
    public List<User> assignToGrpCMVisibility_UserList = new List<User>(); //SC-515
    public List<User> assignToGrp4PLAccount_UserList = new List<User>(); //SC-4505
    public List<User> assignToGrpMC_RestrictedAcc_UserList = new List<User>(); //SC-8395
    public List<User> assignToLS_UserList = new List<User>(); //SC-1160 
    public List<User> assignBrandsUserList = new List<User>(); //SPI-100. Populate Brand_Logic__c field
    public List<User> processSkill_userlist = new List<User>();
    public List<User> userListAssignToMnAQueues = new List<User>(); //SC-7849: List of users need to be added to public group based on M&A queues
 	public Map<Id, String> mapUserToSalesJobFunction = new Map<Id, String>();//map hold Id of users whose salesJob function is updated
    public List<User> mirrorAccess_UserList = new List<User>(); //list of users to be cloned based on 'Mirrored_Access__c' field
    public List<User> assignOpportunityWizardPermissionset = new list<User>();
    public List<User> assignEditDefaultPricesPermissionSet = new List<User>();//SFSE-15210
    public List<User> RemoveEditDefaultPricesPermissionSet = new List<User>();//SFSE-15210
    // constructor 
    public UserRecordSelector(list<User> lstUsers, map<Id, User> mapOldUsers, UserTriggerHandler usrTriggerHandler) {
        
        this.usrTriggerHandler = usrTriggerHandler;
        selectRecords(lstUsers, mapOldUsers); // call method to set all required user lists
        
    }
    
    // Method to check different conditions and form user lists that will be used in UserTriggerHandler
    public void selectRecords(list<User> newUsersList, map<Id, sObject> mapOldUsers) {
        System.debug('#### usrTriggerHandler.trigEvent '+usrTriggerHandler);
        for (User usrRecord : newUsersList ){
            User oldUser = new User();
            if(mapOldUsers != null) {
                oldUser = (User)mapOldUsers.get(usrRecord.Id);
                
                // if user is made active/inactive, set Last Activity Date accordingly
                if( usrRecord.IsActive != oldUser.IsActive){
                    setInactiveUserList.add(usrRecord);
                }
                
                // #RQ-009466 if user is active and becoming inactive then capture those user records
                if(  usrRecord.IsActive == false && oldUser.IsActive == true ){
                    activeToInactiveUserIdsSet.add(usrRecord.Id);
                }
                //SFSE-12445 if Sales job function field  is updated
               
                if (usrRecord.Sales_Job_Function__c != oldUser.Sales_Job_Function__c) {
                      
                       mapUserToSalesJobFunction.put(usrRecord.Id,usrRecord.Sales_Job_Function__c);
                 }
                
                // If User Maersk Id/Name/Role/Manager/Country cluster/cluster is modified then set Synced flag = true
                if( usrRecord.Maersk_User_Id__c != oldUser.Maersk_User_Id__c || usrRecord.FirstName != oldUser.FirstName
                   || usrRecord.LastName != oldUser.LastName || usrRecord.ManagerId != oldUser.ManagerId
                   || usrRecord.UserRoleId != oldUser.UserRoleId
                   || usrRecord.Country_Cluster_Sales_Manager__c != oldUser.Country_Cluster_Sales_Manager__c || usrRecord.Cluster__c != oldUser.Cluster__c ){
                       
                       syncFlagUserList.add(usrRecord);
                   }           
            }            
            
            if( usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || oldUser.Cluster__c != usrRecord.Cluster__c ){
                // set user region if user cluster is modified
                setRegionUserList.add(usrRecord);                
            }
            
            // Select records to set federationIdentifer Id in lower case
            String strUserFedID = usrRecord.FederationIdentifier;
            if ( usrRecord.FederationIdentifier != null && ( usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || usrRecord.FederationIdentifier != oldUser.FederationIdentifier || !strUserFedID.isAllLowerCase())){
                setFEDList.add(usrRecord);          
            }
            
            //SC-515 - N&C - Assignment of users to public groups
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.CM_Visibility__c != null) || (usrRecord.CM_Visibility__c != oldUser.CM_Visibility__c )){
                system.debug('Inside Record selector for CM Visibility');
                assignToGrpCMVisibility_UserList.add(usrRecord);
            }
            
            //SC-4505 : 4PL - N&C - Assignment of 4PL Account specific public group to users
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.SF_4PL_Account__c != null) || (usrRecord.SF_4PL_Account__c != oldUser.SF_4PL_Account__c )){
                assignToGrp4PLAccount_UserList.add(usrRecord);
            }
            
            //SC-8395 : 4PL - N&C - Assignment of 4PL Account specific public group to users
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.Multi_Carrier_Restricted_Account__c != null) || (usrRecord.Multi_Carrier_Restricted_Account__c != oldUser.Multi_Carrier_Restricted_Account__c )){
                assignToGrpMC_RestrictedAcc_UserList.add(usrRecord);
            }
            
            // SC-1160 L&S Assignment of users to public groups
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.L_S_Queues__c != null) || (usrRecord.L_S_Queues__c != oldUser.L_S_Queues__c )){
                 assignToLS_UserList.add(usrRecord);
            }
            
            // Select records to assign user to public groups based on support countries
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.Support_Countries__c != null)
               || ( usrRecord.Support_Countries__c != oldUser.Support_Countries__c || usrRecord.Liner_Brand_Logic__c != oldUser.Liner_Brand_Logic__c)) {               
                   
                   assignToGroup_UserList.add(usrRecord);
             }
             //SCTM-335 : assignToSCMQueues_UserList
             //SC-5695
             if(((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.LS_TM_SCM_Queues__c != null)
               || ( usrRecord.LS_TM_SCM_Queues__c != oldUser.LS_TM_SCM_Queues__c ))
               ||((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.SCM_KC_Country_Area__c != null)||( usrRecord.SCM_KC_Country_Area__c != oldUser.SCM_KC_Country_Area__c ))) {               
                   
                assignToSCMQueues_UserList.add(usrRecord);
             }  
             if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.Chat_Queues__c != null)||usrRecord.Chat_Queues__c != oldUser.Chat_Queues__c){
                
                
                    assignToChat_userlist.add(usrRecord);
                
             }
             if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.UserPermissionsLiveAgentUser == true)||usrRecord.UserPermissionsLiveAgentUser!= oldUser.UserPermissionsLiveAgentUser && usrRecord.UserPermissionsLiveAgentUser == true){
                    assignPermissionsetToChat_userlist.add(usrRecord);
             }
            // Select records to assign public groups to users based on liner brand
            if( usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || oldUser.Liner_Brand__c != usrRecord.Liner_Brand__c ){
                assignToBrandGroup_UserList.add(usrRecord);
            }  
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || ((usrRecord.IsActive!= oldUser.IsActive || usrRecord.IsActive == true) || (usrRecord.IsActive == true && usrRecord.ProfileId != oldUser.ProfileId)))&& label.SalesProfile.contains(usrRecord.ProfileId)){
                assignOpportunityWizardPermissionset.add(usrRecord);
            }
            //SFSE-15210 Assign EditDefaultPrices Permission set to users whose Sales job function is equal to Product Organization
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || usrRecord.IsActive!= oldUser.IsActive || usrRecord.Sales_Job_Function__c != olduser.Sales_Job_Function__c) && usrRecord.IsActive == true && usrRecord.Sales_Job_Function__c == Label.Product_Organization_User_SFJ){
                assignEditDefaultPricesPermissionSet.add(usrRecord);
            }
            //SFSE-15210 Remove EditDefaultPrices Permission set to users whose Sales job function is not equal to Product Organization
            if((usrRecord.Sales_Job_Function__c != olduser.Sales_Job_Function__c && usrRecord.Sales_Job_Function__c != Label.Product_Organization_User_SFJ) || (usrRecord.IsActive != oldUser.IsActive && usrRecord.IsActive == false)){
                RemoveEditDefaultPricesPermissionSet.add(usrRecord);
            }
            
            //  Select records for setting user Firstname and Lastname as Init Cap
            //  RQ-009884 - usrRecord.LastName != null condition added
            if( usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || ( (usrRecord.FirstName != null && ! usrRecord.FirstName.equals(oldUser.FirstName)) || usrRecord.FirstName != oldUser.FirstName) || ( usrRecord.LastName != null && ! usrRecord.LastName.equals(oldUser.LastName)) ){
                nameChangedUserList.add(usrRecord);
            }  
            
            // Select records to assign  sales users to public groups based on their profile
            // Changes made with respect to #RQ-007716 to select users with country change with checks particularly for german users.
            if( (usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)  ||  (oldUser.ProfileId != usrRecord.ProfileId)
                || ((oldUser.Country != usrRecord.country) && (usrRecord.country == 'Germany' || olduser.country == 'Germany') ) ||
                (usrRecord.Sales_Job_Function__c != olduser.Sales_Job_Function__c && (oldUser.Country == 'Germany' || usrRecord.country == 'Germany'))){
                System.debug('assignToSalesGroup_UserList:::'+assignToSalesGroup_UserList);
                assignToSalesGroup_UserList.add(usrRecord);
            }

            //  #RQ-005477 - Select community user ids.
            if( usrTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER ) {
                if( usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ) {
                    if( usrRecord.UserType != 'Standard' && usrRecord.UserType != 'CsnOnly' ) { 
                            setCommunityUserIds.add(usrRecord.Id); 
                     }  
             }
              
            }
            if(Userinfo.getUserName().startsWith(label.Savyint_user) && String.isNotEmpty(usrRecord.Mirrored_Access__c)){
                mirrorAccess_UserList.add(usrRecord);                
            } 
            
            // Select records where the brand multi-select picklist has changed
            if ((oldUser == null && usrRecord.Liner_Brand__c != null) || usrRecord.Liner_Brand__c != oldUser.Liner_Brand__c) {
                assignBrandsUserList.add(usrRecord);
            }			
            
            //SC-7849 - Get records when M&A queues is present or changed
            if((usrTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && usrRecord.M_A_queues__c != null)||usrRecord.M_A_queues__c != oldUser.M_A_queues__c){               
            	userListAssignToMnAQueues.add(usrRecord);                
            }
        }
    }
    
    public void getRelatedRecords(list<Case> lstCases) {
        
    }
    
}