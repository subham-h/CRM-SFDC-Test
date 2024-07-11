/*              
* Revision Ref Number  Date        Owner                           Description
* -------- ----------  ----------- -------------------             -----------
* 1.0      RQ-004168   17-Mar-2017 Ranjini@UST                     Place holder class for AccountRecordSelector when Trigger is updated to CBO Architecture
* 2.0      RQ-005400   06-Jun-2017 Ranjini@UST                     Billing State update based on Biling city.
* 3.0      RQ-005390   05-Jun-2017 Nisha@UST                       Update 'Represents Concern' on client account
* 4.0      RQ-004103   05-Jul-2017 Ranjini@UST                     Updates as part of CBO refactoring.
* 5.0      RQ-005317   12-Jul-2017 Sandhya@UST                     Removed Population of Cluster for Client account, Account Owner
* 6.0      RQ-007146   10-Oct-2017 Uvais@UST                       Select records for populating Liner Brand Owner Maersk Ids
* 7.0      RQ-007439   14-Dec-2017 Nisha@UST                       Prevent deleting NSP accounts where there is a vendor code or vendor type
* 8.0      RQ-008878   05-Jul-2018 Meghana@UST                     Create a list of client accounts and parent !=null to associate account to territories
* 9.0      RQ-009529   13-Dec-2018 Junaid@UST                      Removed Logics for associating account to KC territories
*10.0      SFSE-6116   17-Jun-2021 Neha@TCS                        Created selector for lstAccountToAssignArea to invoke before insert/update
*10.1      SFSE-6116   24-Jun-2021 Nitin@Maersk                    Creaetd selector for lstAccountToAssighSalesGroup to invoke before insert/update
*11.0      SFSE-14282  23-Feb-2023 Samar@Maersk                    Moving Account Process Builder to Trigger.
* 12.0     SFSE-14450  26-Mar-2024 Aleena@maersk                   Added logic for Customer Size to populate data to concern account
* 12.0     SFSE-14551  08-Apr-2024 Shilpa@maersk                   Added logic to stamp Represent Concern as false if there is no concern code  added.
*/

public class AccountRecordSelector implements RecordSelector {
    
    private TriggerHandler accTriggerHandler; 
    
    public List<Account> lstAccountToAssignArea = new List<Account>(); // list of Accounts inserted or updated where country is modified and area  needs to be repopulated
    public List<Account> lstAccountToAssignSalesGroup = new List<Account>(); // list of Accounts inserted or MSL Owner is modified.
    
    // RQ-005400: For BillingState Population
    public list<Account> lstAccBillingStateUpdate = new list<Account>();
    public Set<String> setBillingCityNames = new Set<String>(); 
    
    // RQ-005390: Client and Concern Account should always be in sync with CMD
    public set<Id> setConcernIdsForHierarchy = new set<Id>();
    public set<Id> setClientIdsForHierarchy = new set<Id>();
    
    // Prevent Client and Concern Account deletion
    public list<Account> lstDeletedAccounts = new list<Account>();
    
    // RQ-007146: For MaerskId Population
    public list<Account> accountsForMidPopulation = new list<Account>();
    Public Set<Id> LinerBrandOwnersId = new Set<Id>();
    Public Map<Id,User> LinerBrandOwnerDetails;
    
    // Handle Account Owner Changes
    public set<Id> setMSLAccoutIds = new set<Id>();
    public set<Id> setMLLAccoutIds = new set<Id>();
    public set<Id> setSCLAccoutIds = new set<Id>();
    public set<Id> setSEAAccoutIds = new set<Id>();
    public set<Id> setSGLAccoutIds = new set<Id>();
    public set<Id> setMCCAccoutIds = new set<Id>();
    
    
    public set<Id> setKCAccoutIds = new set<Id>();
    
    public set<Id> setOldUserIds = new set<Id>();
    public set<Id> setNewUserIds = new set<Id>();
    public Map<String, Id> mapOfBrandUserId = new Map<String,Id>();
    public set<Id> setAccIds = new set<Id>();
    public list<Account> lstConcernAccsForCxPackage = new list<Account>(); //SC-9354 - CX Package
    public list<Account> lstClientAccsForCxPackage = new list<Account>(); //SC-9354 - CX Package
    public list<Account> lstAccsForCxPackageOnUpdate = new list<Account>(); //SC-9354 - CX Package
    public List<Account> setInactiveRecordType = new List<Account>(); //SFSE-14282
    public List<Account> setSFMCFlagFalse = new List<Account>(); //SFSE-14282
    public List<Account> setSFMCFlagTrue = new List<Account>(); //SFSE-14282
    public Set<Id> setAccountIdforContUpdate = new Set<Id>(); //SFSE-14282
    public List<Account> listAccforKeyAttributes = new List<Account>(); //SFSE-14282
    public list<Account> listAcctoUpdateRepresentConcern = new list<Account>();
    

    public AccountRecordSelector(list<Account> lstAccounts, map<Id, Account> mapOldAccounts, AccountTriggerHandler accTriggerHandler) {
        this.accTriggerHandler = accTriggerHandler;
        
        selectRecords(lstAccounts, mapOldAccounts);
        
        If(!LinerBrandOwnersId.isEmpty())
            linerBrandOwnerDetails = getOwnerMap(LinerBrandOwnersId);
        
    }
    
    public void selectRecords(list<Account> lstAccounts, map<Id, sObject> mapOldAccounts) {
       Id clientAccRTId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
       Id concernAccRTId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Concern_Account').getRecordTypeId();
       Id inactiveAccRTId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
       Id draftAccRtId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Draft_Account').getRecordTypeId();
        
        if(lstAccounts != null) {
            for(Account newAccount : lstAccounts) {
                Account oldAccount = null;
                if(mapOldAccounts != null) {
                    oldAccount = (Account)mapOldAccounts.get(newAccount.Id);
                }
                
                if(accTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        
                        // RQ-005400: For BillingState Population
                        if(newAccount.BillingCity != null && newAccount.BillingState != null && (newAccount.BillingState.length() == 2 || newAccount.BillingState.length() == 3)) {
                            lstAccBillingStateUpdate.add(newAccount);
                            setBillingCityNames.add(newAccount.BillingCity);
                        }
                        
                        if(newAccount.RecordTypeId == clientAccRTId){
                            lstAccountToAssignArea.add(newAccount);
                            lstAccountToAssignSalesGroup.add(newAccount);                         
                        }
                        
                        // RQ-007146: For MaerskId Population
                        checkLinerBrandOwnerPresence(newAccount,oldAccount);

                        //Check for the Account SCV Status and Inactive Recordtype - SFSE-14282
                        if(newAccount.SCV_Status__c == 'Inactive' &&  newAccount.RecordTypeId != inactiveAccRTId){
                            setInactiveRecordType.add(newAccount);
                        }

                        //Inactive Client Accounts - Sync to SFMC to False - SFSE-14282
                        if( (newAccount.SCV_Status__c != 'Active' ||  newAccount.RecordTypeId != clientAccRTId) && newAccount.Sync_to_SFMC__c == true ){ 
                            setSFMCFlagFalse.add(newAccount);
                        }

                        //Active Client Accounts - Sync to SFMC to TRUE - SFSE-14282
                        if(newAccount.SCV_Status__c == 'Active' &&  newAccount.RecordTypeId == clientAccRTId && newAccount.Sync_to_SFMC__c == false){ 
                            setSFMCFlagTrue.add(newAccount);
                        }
                        if(newAccount.Concern_Code__c == null && newAccount.Represents_Concern__c!= null && newAccount.Represents_Concern__c == true){
                      listAcctoUpdateRepresentConcern.add(newAccount);  
                        System.debug('Entered in record selector');
                    }
                    }
                    else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        
                        // RQ-005400: For BillingState Population
                        if(newAccount.BillingCity != null && newAccount.BillingState != null && newAccount.BillingState != oldAccount.BillingState && (newAccount.BillingState.length() == 2 || newAccount.BillingState.length() == 3)) {
                            lstAccBillingStateUpdate.add(newAccount);
                            setBillingCityNames.add(newAccount.BillingCity);
                        }
                        if(newAccount.Country__c != null && newAccount.RecordTypeId == clientAccRTId){
                            lstAccountToAssignArea.add(newAccount);
                            lstAccountToAssignSalesGroup.add(newAccount);                         
                        }
                        
                        if(newAccount.RecordTypeId == clientAccRTId && newAccount.Country__c != null){
                            // TAA change will have dummy update on MSL Owner this is done to get Sales Group updated when Sales Job Function is changed on user profile
                            lstAccountToAssignSalesGroup.add(newAccount);
                        }
                        
                        // RQ-007146: For MaerskId Population
                        checkLinerBrandOwnerPresence(newAccount,oldAccount);

                        //Check for the Account SCV Status and Inactive Recordtype - SFSE-14282
                        if(newAccount.SCV_Status__c == 'Inactive' &&  newAccount.RecordTypeId != inactiveAccRTId){
                            setInactiveRecordType.add(newAccount);
                        }

                        //Inactive Client Accounts - Sync to SFMC to False - SFSE-14282
                        if(newAccount.Sync_to_SFMC__c == true && (newAccount.SCV_Status__c != 'Active' ||  newAccount.RecordTypeId != clientAccRTId) ){ 
                            setSFMCFlagFalse.add(newAccount);
                        }

                        //Active Client Accounts - Sync to SFMC to TRUE - SFSE-14282
                        if(newAccount.Sync_to_SFMC__c == false  &&  newAccount.SCV_Status__c == 'Active' &&  newAccount.RecordTypeId == clientAccRTId){ 
                            setSFMCFlagTrue.add(newAccount);
                        }
                         // Set Represent concern as false if there is no concern code added - SFSE-14551
                    if(newAccount.Concern_Code__c == null && newAccount.Represents_Concern__c!= null && newAccount.Represents_Concern__c == true){
                      listAcctoUpdateRepresentConcern.add(newAccount);  
                        System.debug('Entered in record selector');
                    }
                    }
                } else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(newAccount.RecordTypeId == clientAccRTId && newAccount.ParentId != null && newAccount.Represents_Concern__c ) { 
                        setClientIdsForHierarchy.add(newAccount.Id); 
                        setConcernIdsForHierarchy.add(newAccount.ParentId);
                    }  
                    //SC-9498 (If Client account and not linked to any Concern) OR If Concern account and the CX package is not null
                    if(((newAccount.RecordTypeId == clientAccRTId && newAccount.ParentId == null) || newAccount.RecordTypeId == concernAccRTId) && 
                       (String.isNotEmpty(newAccount.Attractiveness__c) || String.isNotEmpty(newAccount.Customer_Role__c))){
                           lstConcernAccsForCxPackage.add(newAccount);
                       }
                    //SC-9498 If Client account and is linked to Concern account
                    if(newAccount.RecordTypeId == clientAccRTId && newAccount.ParentId != null){
                        lstClientAccsForCxPackage.add(newAccount);
                    }

                    // When Client Account is being added and respresent concern is True - SFSE-14282
                    if (newAccount.RecordTypeId == clientAccRTId && newAccount.ParentId != null && newAccount.Represents_Concern__c == true ){
                        listAccforKeyAttributes.add(newAccount);
                    }
                    
                    

                } else if(accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {   
                    setAccIds.add(newAccount.Id);
                    /*if(newAccount.Attractiveness__c != oldAccount.Attractiveness__c) {
                    setKCAccoutIds.add(newAccount.Id);
                    }*/
                    // RQ-005390 - With in a hierarchy there can be only one account which has Represents Concern = true.
                    if(newAccount.RecordTypeId == clientAccRTId && newAccount.ParentId != null && newAccount.Represents_Concern__c && !oldAccount.Represents_Concern__c) { 
                        setClientIdsForHierarchy.add(newAccount.Id); 
                        setConcernIdsForHierarchy.add(newAccount.ParentId);
                    }else{
                        if(newAccount.RecordTypeId == clientAccRTId && (newAccount.ParentId != oldAccount.ParentId) && oldAccount.ParentId == null) {
                            if(newAccount.Represents_Concern__c) {
                                setClientIdsForHierarchy.add(newAccount.Id); 
                                setConcernIdsForHierarchy.add(newAccount.ParentId);  
                            }
                        }
                    }
                    // Update Opportunity Owner based on the liner brand owner change
                    if(newAccount.MSL_Account_Owner__c != oldAccount.MSL_Account_Owner__c) {
                        if(newAccount.MSL_Account_Owner__c != null) {
                            setMSLAccoutIds.add(newAccount.Id);
                            setOldUserIds.add(oldAccount.MSL_Account_Owner__c);
                            setNewUserIds.add(newAccount.MSL_Account_Owner__c);
                            mapOfBrandUserId.put(BrandUtilities.MAERSKLINE, newAccount.MSL_Account_Owner__c);
                        }
                        else if(newAccount.MLL_Account_Owner__c != null) {
                            setMLLAccoutIds.add(newAccount.Id);
                        }
                    }
                    if((newAccount.MLL_Account_Owner__c != oldAccount.MLL_Account_Owner__c) && (newAccount.MLL_Account_Owner__c != null)) {
                        setMLLAccoutIds.add(newAccount.Id);
                    }
                    /*if((newAccount.SCL_Account_Owner__c != oldAccount.SCL_Account_Owner__c) && (newAccount.SCL_Account_Owner__c != null && newAccount.SCL_Account_Owner__c != oldAccount.SCL_Account_Owner__c) ){                             
                    setSCLAccoutIds.add(newAccount.Id);
                    }*/
                    if((newAccount.SEA_Account_Owner__c != oldAccount.SEA_Account_Owner__c) && 
                       (newAccount.SEA_Account_Owner__c != null)) {                             
                           setSEAAccoutIds.add(newAccount.Id);
                           setOldUserIds.add(oldAccount.SEA_Account_Owner__c);
                           setNewUserIds.add(newAccount.SEA_Account_Owner__c);
                           mapOfBrandUserId.put(BrandUtilities.SEALAND, newAccount.SEA_Account_Owner__c);
                       }
                    if((newAccount.Seago_Account_Owner__c != oldAccount.Seago_Account_Owner__c) && 
                       (newAccount.Seago_Account_Owner__c != null)) {                             
                           setSGLAccoutIds.add(newAccount.Id);
                           setOldUserIds.add(oldAccount.Seago_Account_Owner__c);
                           setNewUserIds.add(newAccount.Seago_Account_Owner__c);
                           mapOfBrandUserId.put(BrandUtilities.SEAGO, newAccount.Seago_Account_Owner__c);
                       }
                    if((newAccount.MCC_Account_Owner__c != oldAccount.MCC_Account_Owner__c) && 
                       (newAccount.MCC_Account_Owner__c != null)) {                             
                           setMCCAccoutIds.add(newAccount.Id);
                           setOldUserIds.add(oldAccount.MCC_Account_Owner__c);
                           setNewUserIds.add(newAccount.MCC_Account_Owner__c);
                           mapOfBrandUserId.put(BrandUtilities.MCC, newAccount.MCC_Account_Owner__c);
                       }
                    //SC-9498 If Parent is changed is changed
                    if((newAccount.ParentId != oldAccount.ParentId) || (newAccount.ParentId == null && 
                                                                        (newAccount.Attractiveness__c != oldAccount.Attractiveness__c || newAccount.Customer_Role__c != oldAccount.Customer_Role__c))){
                                                                            lstAccsForCxPackageOnUpdate.add(newAccount);
                                                                        }         

                    //Set Send To CMD Flag - Update Contacts - SFSE-14282        
                    if(newAccount.RecordTypeId == clientAccRTId && oldAccount.RecordTypeId == draftAccRtId  && newAccount.RecordTypeId != oldAccount.RecordTypeId){
                        setAccountIdforContUpdate.add(oldAccount.Id);
                    }

                    // When Client Account is key attributes is being Modifed and respresent concern is True - SFSE-14282
                    if (newAccount.RecordTypeId == clientAccRTId && newAccount.Represents_Concern__c == true  && newAccount.ParentId != null && ( ( newAccount.Attractiveness__c != oldAccount.Attractiveness__c ||
                        newAccount.Vertical__c != oldAccount.Vertical__c || newAccount.Value_Proposition__c != oldAccount.Value_Proposition__c || newAccount.Sub_Segment__c != oldAccount.Sub_Segment__c ||
                        newAccount.Industry__c != oldAccount.Industry__c || newAccount.Sales_Channel__c != oldAccount.Sales_Channel__c)  ||
                        (newAccount.Represents_Concern__c != oldAccount.Represents_Concern__c ) ) ){
                        listAccforKeyAttributes.add(newAccount);
                    }
                }
            }
        }
        else { // Delete events
            for(Account oldAccount : (list<Account>)mapOldAccounts.values()) {
                if(accTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                    // Prevent Client and Concern Account deletion
                    System.debug('#####oldAccount.RecordTypeId'+oldAccount.RecordTypeId);
                    System.debug('#####Label.Client_Account_Record_Type_Id'+Label.Client_Account_Record_Type_Id);
                    System.debug('#####oldAccount.RecordTypeId'+oldAccount.RecordTypeId);
                    System.debug('#####Label.Concern_Account_Record_Type_Id'+Label.Concern_Account_Record_Type_Id );
                    if(oldAccount.RecordTypeId == Label.Client_Account_Record_Type_Id || oldAccount.RecordTypeId == Label.Concern_Account_Record_Type_Id ) {
                        lstDeletedAccounts.add(oldAccount);          
                    }
                    // #RQ-007439 - Prevent deleting NSP accounts where there is a vendor code or vendor type
                    System.debug('#####oldAccount.RecordTypeId'+oldAccount.RecordTypeId);
                    System.debug('######Label.Non_shipping_Party_Account_RecordType_Label'+Label.Non_shipping_Party_Account_RecordType_Label);
                    if(oldAccount.RecordTypeId == Label.Non_shipping_Party_Account_RecordType_Label && (oldAccount.Vendor_code__c != null || oldAccount.Vendor_Type__c !=null) ) {
                        lstDeletedAccounts.add(oldAccount);
                    }
                }
            }
        }
        
    }
    
    
    // CBO
    public void getRelatedRecords(list<Case> lstCases) {
        
    }
    
    //RQ-007146: For MaerskId Population - Return LinerBrandOwner Ids where Liner Brand Owner Is present
    public void checkLinerBrandOwnerPresence(Account newAccount,Account oldAccount) {
        
        if(((accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) && 
            (newAccount.MSL_Account_Owner__c != oldAccount.MSL_Account_Owner__c ||
             newAccount.MCC_Account_Owner__c != oldAccount.MCC_Account_Owner__c || 
             newAccount.MLL_Account_Owner__c != oldAccount.MLL_Account_Owner__c ||
             newAccount.SEA_Account_Owner__c != oldAccount.SEA_Account_Owner__c || 
             //newAccount.SCL_Account_Owner__c != oldAccount.SCL_Account_Owner__c ||
             newAccount.Seago_Account_Owner__c != oldAccount.Seago_Account_Owner__c))||
           ((accTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) && 
            (newAccount.MSL_Account_Owner__c != null ||
             newAccount.MCC_Account_Owner__c != null || 
             newAccount.MLL_Account_Owner__c != null ||
             newAccount.SEA_Account_Owner__c != null || 
             //newAccount.SCL_Account_Owner__c != null ||
             newAccount.Seago_Account_Owner__c != null))) {
                 
                 accountsForMidPopulation.add(newAccount);
                 
                 If(newAccount.MSL_Account_Owner__c != null)
                     LinerBrandOwnersId.add(newAccount.MSL_Account_Owner__c);
                 
                 If(newAccount.MCC_Account_Owner__c != null)
                     LinerBrandOwnersId.add(newAccount.MCC_Account_Owner__c);
                 
                 If(newAccount.MLL_Account_Owner__c != null)
                     LinerBrandOwnersId.add(newAccount.MLL_Account_Owner__c);
                 
                 If(newAccount.SEA_Account_Owner__c != null)
                     LinerBrandOwnersId.add(newAccount.SEA_Account_Owner__c);
                 
                 /*If(newAccount.SCL_Account_Owner__c != null)
				LinerBrandOwnersId.add(newAccount.SCL_Account_Owner__c);*/
                 
                 If(newAccount.Seago_Account_Owner__c != null )
                     LinerBrandOwnersId.add(newAccount.Seago_Account_Owner__c);
             } 
    }
    
    //Return Map with UID Details of LinerBrand Owners 
    public Map<Id,User> getOwnerMap (Set<Id> LinerBrandOwnersId){    
        return New Map<Id,User>([SELECT Id,Maersk_User_Id__c FROM User WHERE Id IN: LinerBrandOwnersId]);    
    }
    
    
}