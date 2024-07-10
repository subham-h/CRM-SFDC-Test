/*              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -----------------       -----------
 * 1.0      RQ-004103   05-Jul-2017 Ranjini@UST             Updated as part of CBO refactoring. All previous revision history are removed since it doesn't make sense anymore. 
 * 2.0      RQ-005317   12-Jul-2017 Sandhya@UST             Removed Population of Cluster for Client account, Account Team
 * 3.0      RQ-007146   10-Oct-2017 Uvais@UST               Added Liner Brand Owner Maersk Id Population
 * 4.0      RQ-008878   05-Jul-2018 Meghana@UST             Associate account to KC territories
 * 5.0      RQ-009529   13-Dec-2018 Junaid@UST              Removed Logics for associating account to KC territories
 * 6.0      RQ-013016   03-04-2020  Sidhartha@maersk        Removed updateOpportunityOwner method.
 * 7.0      SFSE-6116   17-Jun-2021 Neha@TCS                Invoked method populateAccountAddressArea(),to get the account address area 
 * 7.1      SFSE-6116   24-Jun-2021 Nitin@Maersk            Invoked method populateAccountSalesGroup()
 * 7.2 		SFSE-9032	28-Dec-2022 Vazid@UST				Invoked method updateRepresentsConcern in after insert
 * 8.0      SFSE-14282  23-Feb-2023 Samar@Maersk            Moving Account Process Builder to Trigger.
*/
 
public class AccountTriggerHandler extends TriggerHandler {
       
    public map<Id, Account> newMap;
    public map<Id, Account> oldMap;
    public AccountTriggerHandler() {
        this.newMap = (map<Id, Account>)Trigger.newMap;
        this.oldMap = (map<Id, Account>)Trigger.oldMap; 
    }
    
    public AccountRecordSelector accRecordSelector;
    public override void getRecordSelector() {
        accRecordSelector = new AccountRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        // RQ-005400. Populate BillingState based on BillingCity.
        if(!accRecordSelector.lstAccBillingStateUpdate.isEmpty()) {
            AccountFieldPopulator.populateBillingState(accRecordSelector.lstAccBillingStateUpdate, accRecordSelector.setBillingCityNames);
        }
        
        // RQ-007146. Populate Liner Brand Owner Maersk Ids.
        if(!accRecordSelector.accountsForMidPopulation.isEmpty()) {
           AccountFieldPopulator.populateLinerBrandOwnerMIDs(accRecordSelector.accountsForMidPopulation,accRecordSelector.LinerBrandOwnerDetails);
        }
        //SFSE-6116. Populate account address area and Sales Group
        if(!accRecordSelector.lstAccountToAssignArea.isEmpty()) {
           AccountFieldPopulator.populateAccountAddressArea(accRecordSelector.lstAccountToAssignArea,this.oldMap);
        }
        if(!accRecordSelector.lstAccountToAssignSalesGroup.isEmpty()) {
            AccountFieldPopulator.populateAccountSalesGroup(accRecordSelector.lstAccountToAssignSalesGroup);
        }

        //Check for the Account SCV Status and Inactive Recordtype - SFSE-14282
        if(!accRecordSelector.setInactiveRecordType.isEmpty()){
            AccountFieldPopulator.setRecordtypetoInactive(accRecordSelector.setInactiveRecordType);
        }

        //Inactive Client Accounts - Sync to SFMC to False - SFSE-14282
        if(!accRecordSelector.setSFMCFlagFalse.isEmpty()){
            AccountFieldPopulator.setSFMCFlag(accRecordSelector.setSFMCFlagFalse,false);
        }

        //Active Client Accounts - Sync to SFMC to TRUE - SFSE-14282
        if(!accRecordSelector.setSFMCFlagTrue.isEmpty()){
            AccountFieldPopulator.setSFMCFlag(accRecordSelector.setSFMCFlagTrue,true);
        }
        
        // Set Represent concern as false if there is no concern code added - SFSE-14551
        if(!accRecordSelector.listAcctoUpdateRepresentConcern.isEmpty()){
             AccountFieldPopulator.setRepresentConcern(accRecordSelector.listAcctoUpdateRepresentConcern);
        }
    }
    
    public override void onBeforeUpdate() {
        
        // RQ-005400. Populate BillingState based on BillingCity.
        if(!accRecordSelector.lstAccBillingStateUpdate.isEmpty()) {
            AccountFieldPopulator.populateBillingState(accRecordSelector.lstAccBillingStateUpdate, accRecordSelector.setBillingCityNames);
        }
        
        // RQ-007146. Populate Liner Brand Owner Maersk Ids.
        if(!accRecordSelector.accountsForMidPopulation.isEmpty()) {
            AccountFieldPopulator.populateLinerBrandOwnerMIDs(accRecordSelector.accountsForMidPopulation,accRecordSelector.LinerBrandOwnerDetails);
        }
        
        if(!accRecordSelector.lstAccountToAssignArea.isEmpty()) {
           AccountFieldPopulator.populateAccountAddressArea(accRecordSelector.lstAccountToAssignArea,this.oldMap);
        }
        
        if(!accRecordSelector.lstAccountToAssignSalesGroup.isEmpty()) {
            AccountFieldPopulator.populateAccountSalesGroup(accRecordSelector.lstAccountToAssignSalesGroup);
        }

        //Check for the Account SCV Status and Inactive Recordtype - SFSE-14282
        if(!accRecordSelector.setInactiveRecordType.isEmpty()){
            AccountFieldPopulator.setRecordtypetoInactive(accRecordSelector.setInactiveRecordType);
        }

        //Inactive Client Accounts - Sync to SFMC to False - SFSE-14282
        if(!accRecordSelector.setSFMCFlagFalse.isEmpty()){
            AccountFieldPopulator.setSFMCFlag(accRecordSelector.setSFMCFlagFalse,false);
        }
        
        //Active Client Accounts - Sync to SFMC to TRUE - SFSE-14282
        if(!accRecordSelector.setSFMCFlagTrue.isEmpty()){
            AccountFieldPopulator.setSFMCFlag(accRecordSelector.setSFMCFlagTrue,true);
        }
        
         // Set Represent concern as false if there is no concern code added - SFSE-14551
        if(!accRecordSelector.listAcctoUpdateRepresentConcern.isEmpty()){
             AccountFieldPopulator.setRepresentConcern(accRecordSelector.listAcctoUpdateRepresentConcern);
        }
    }
    
    public override void onAfterInsert() {
        
        // SFSE-9032: Update 'Represents Concern' on client account. 
        if(!accRecordSelector.setConcernIdsForHierarchy.isEmpty()) {
            AccountHierarchyManager.updateRepresentsConcern(accRecordSelector.setConcernIdsForHierarchy, accRecordSelector.setClientIdsForHierarchy);
        }
        
        // SC-9354: Create Service Contract and contract line items for CX package 
        if(!accRecordSelector.lstConcernAccsForCxPackage.isEmpty()) {
            AccountCxPackageLinkingHelper.linkCXPackageToAccount(accRecordSelector.lstConcernAccsForCxPackage,true);
        }
        if(!accRecordSelector.lstClientAccsForCxPackage.isEmpty()) {
            AccountCxPackageLinkingHelper.linkCXPackageToAccount(accRecordSelector.lstClientAccsForCxPackage,false);
        }

        // When Client Account is key attributes is being Modifed and respresent concern is True - SFSE-14282
        if(!accRecordSelector.listAccforKeyAttributes.isEmpty()){
            AccountHierarchyManager.updateKeyAttribute(accRecordSelector.listAccforKeyAttributes);
        }
        
    }
    
    public override void onAfterUpdate() {
        
        // RQ-005390. Update 'Represents Concern' on client account. 
        System.debug('##### Inside Concern Trigger Handler');
        if(!accRecordSelector.setConcernIdsForHierarchy.isEmpty()) {
            AccountHierarchyManager.updateRepresentsConcern(accRecordSelector.setConcernIdsForHierarchy, accRecordSelector.setClientIdsForHierarchy);
        }
        // setKCAccoutIds is commented out in AccountRecordSelector
        /*if(!accRecordSelector.setKCAccoutIds.isEmpty()) {
           AccountHierarchyManager.updateAccountPlanKCAccount(accRecordSelector.setKCAccoutIds); 
        }*/
        
        if(!accRecordSelector.setOldUserIds.isEmpty() && !accRecordSelector.mapOfBrandUserId.isEmpty()) {
            AccountValidator.shareContract(accRecordSelector.setAccIds, accRecordSelector.setOldUserIds, accRecordSelector.mapOfBrandUserId);
        }
        
        //SC-9498 CX Package for Concern name update scenario
        if(!accRecordSelector.lstAccsForCxPackageOnUpdate.isEmpty()){
            AccountCxPackageLinkingHelper.handleCXPkgForAccountUpdate(accRecordSelector.lstAccsForCxPackageOnUpdate,this.oldMap);
        } 
        
        // When Client Account is key attributes is being Modifed and respresent concern is True - SFSE-14282
        if(!accRecordSelector.listAccforKeyAttributes.isEmpty()){
            AccountHierarchyManager.updateKeyAttribute(accRecordSelector.listAccforKeyAttributes);
        }

        //Set Send To CMD Flag - Update Contacts - SFSE-14282     
        if(!accRecordSelector.setAccountIdforContUpdate.isEmpty()){
            AccountHierarchyManager.updateContact(accRecordSelector.setAccountIdforContUpdate);
        }
    }
    
    public override void onBeforeDelete() {
        // Client and Concern Accounts can not be deleted.
        if(!accRecordSelector.lstDeletedAccounts.isEmpty()) {
        System.debug('Nish Delete Account Trigger Handler');
            AccountValidator.preventAccountDelete(accRecordSelector.lstDeletedAccounts);
        }
    }
    
}