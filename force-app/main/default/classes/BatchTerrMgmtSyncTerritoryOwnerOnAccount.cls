/*
* Version  Date             Owner                                    RQ#           Description
***********************************************************************************************************************************************
* 1.0      17/03/2021       Sidhartha@Maersk.com                    SFSE-5366
* 2.0      09/11/2021       Meghana@UST                             SFSE-7175
* 3.0      08/03/2022       Neha@TCS                                SFSE-7692
* 4.0.     05/07/2022       Ronnie@SF                               SPI-100        Removing brand hardcoding
* 5.0	   28/07/2022		Vazid@UST								SFSE-8475      Added changes to populate Alianca Owner 
* 6.0      01/11/2022		Meghana@UST								SFSE-9627	   For Key Client accounts global account owner with brand 'All' in TAA should be owner for all brands in Account
* 7.0      01/11/2022		Sowmya@Maersk.com						SFSE-9315	   Update Sales Owner Control Only and Sales Owner Non Control Only Scenario
* 8.0      18/07/2023       Bharti@Maersk.com                       SFSE-11735     Added conditions in query of TAA's records in getAccountIdToTAAMap method 
* 9.0      09/10/2023       Seba@Maersk  							SFSE-12234     Modified the code for Account owner logic update
* 10.0     02/11/2023       Seba@Maersk  							SFSE-13217     Modified the code for Account owner logic update
* 11.0     16/11/2023       Seba@Maersk  							SFSE-13379     Modified the code for bug fix
* 12.0     14-12-2023      Bharti@Maersk                            SFSE-13491     Remove Hardcoding Of product Responsibility/Brands
*/

public class BatchTerrMgmtSyncTerritoryOwnerOnAccount implements Database.Batchable<SObject>, Database.Stateful {
    
    private Set<String> poResponsibilities;
    private Map<String, String> brandToAccountFieldMap;
    public Set<Id> accountIds = new Set<Id>();
    public Set<Id> paccountIds = new Set<Id>();
    public Boolean reprsntConcern = false;
   
    
    private String ptRecordTypeID = Schema.SObjectType.Territory__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
    private String caRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
    
    Map<Id, Account> accountMap1;
    Map<Id, Account> updatedAccountMapSalesControl = new Map<Id, Account>();      
    
    private class BrandOwnerWrapper {
        public Integer brandCounter;  
        public Boolean isAllSalesControl;
        public Boolean isAllSalesControlOnly;
        public Boolean isAllSalesNonControlOnly; 
        public Map<Id, Map<String, Id>> accountKeyToBrandOwnerMap;
        public Map<Id, Map<String, String>> accountKeyToBrandPORMap;
        public Map<Id, Map<String, Territory_Account_Association__c>> brandToTAAmap; //v2 - keep track of TAA record that was used to assign Owner
        
        public BrandOwnerWrapper() {
            brandCounter = 0;  
            isAllSalesControl = false;
            isAllSalesControlOnly = false;
            isAllSalesNonControlOnly = false;
            accountKeyToBrandOwnerMap = new Map<Id, Map<String, Id>>();
            accountKeyToBrandPORMap = new Map<Id, Map<String, String>>();
            brandToTAAmap = new Map<Id, Map<String, Territory_Account_Association__c>>(); 
        }
    }
    
    public BatchTerrMgmtSyncTerritoryOwnerOnAccount(Set<Id> accIds, Boolean representConcern) { 
        this.accountIds = accIds;
        this.reprsntConcern = representConcern;
        poResponsibilities = new Set<String> {TAASettingConstants.POR_SALES_CONTROL, TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER,TAASettingConstants.POR_SALES_CONTROL_ONLY,TAASettingConstants.POR_SALES_NON_CONTROL_ONLY};
        brandToAccountFieldMap = BrandUtilities.getBrandAndAccountOwnerMap(); 
    }
    
    public Database.QueryLocator start( Database.BatchableContext BC ){ 
        String query = 'SELECT Id, Name, ParentId, Represents_Concern__c ' + 
            'FROM Account ' + 
            'WHERE RecordTypeId =: caRecordTypeID AND Id IN:accountIds AND Represents_Concern__c =:reprsntConcern'; 
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext info, List<Account> accounts) { 
        
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        accountMap1 = new Map<Id, Account>(accounts);
        Map<Id, List<Territory_Account_Association__c>> accountIdToTAAMap = getAccountIdToTAAMap(new Set<Id>(accountMap.keySet()));
        Set<Id> accountIds = new Set<Id>(); // Set to maintain accountIds that has all TAAs deleted
        Map<Id, Account> updatedAccounts = new Map<Id, Account>(); 
        
        // for each account loop through TAA records get owner names
        for(Id accountId : accountIdToTAAMap.keySet()) {
            system.debug('Account coming----->'+accountId);
            List<Territory_Account_Association__c> taaObjList = accountIdToTAAMap.get(accountId); 
            if(taaObjList == null) { 
                accountIds.add(accountId);
                if(accountMap.get(accountId).Represents_Concern__c == true){ 
                    accountIds.add(accountMap.get(accountId).ParentId);    
                }                
                continue;
            } 
            Boolean isAllSalesControl = true;
            Boolean isAllSalesControlOnly = true;
            Boolean isAllSalesNonControlOnly = true;
            Account account = accountMap.get(accountId);
            BrandOwnerWrapper brandOwnerWrapperObj = new BrandOwnerWrapper();
            Map<String, String> mapBrandOwner = new Map<String, String>(); 
            
            for(Territory_Account_Association__c taaObj : taaObjList) {
                Boolean isSalesControl = (taaObj.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL);
                Boolean isSalesControlOnly = (taaObj.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL_ONLY);
                Boolean isSalesNonControlOnly = (taaObj.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_NON_CONTROL_ONLY);
                Boolean isGlobalAccountOwner = (taaObj.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER && account.Represents_Concern__c == true);
                Boolean isGlobalAccountOwnerWithoutRepresentConcern = (taaObj.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER && account.Represents_Concern__c == false);
                 
                List<String> tempBrandList = taaObj.Brand__c.split(';'); 
                /*SFSE-12234*/
                if(isGlobalAccountOwner){
                    for(String brand : tempBrandList) {
                      mapBrandOwner.put(taaObj.Portfolio_Owner_Responsibility__c + brand,taaObj.Territory__c); 
                    }  
                    populateBrandOwnerWrapper(account, account.ParentId, taaObj, brandOwnerWrapperObj, '');
                }  
 
                if(isSalesControl) { 
 
                    //Send Sales Owner + Brand for evaluation only if 'GAO for Same Brand' is not sent already.  
                    for(String brand : tempBrandList) {  
                            //Send Sales Owner + Brand for evaluation only if 'GAO for Same Brand' is not sent already. 
                            //SFSE-13379
                    		if(!mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER+brand) && !mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER+TAASettingConstants.PR_All)){ 
                               mapBrandOwner.put(taaObj.Portfolio_Owner_Responsibility__c + brand,taaObj.Territory__c);    
                               populateBrandOwnerWrapper(account, account.ParentId, taaObj, brandOwnerWrapperObj, brand);
                            }    
                    } 
                } 
                
                if(isSalesControlOnly){//SOCO  
                    //Checking if either GAO or SO for same brand is gone already
                       for(String brand : tempBrandList) {
                           //SFSE-13379
                           if(!mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER +brand) && !mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER +TAASettingConstants.PR_All) &&!mapBrandOwner.containsKey(TAASettingConstants.POR_SALES_CONTROL +brand)){
                      			mapBrandOwner.put(taaObj.Portfolio_Owner_Responsibility__c + brand,taaObj.Territory__c); 
                                populateBrandOwnerWrapper(account, account.ParentId, taaObj, brandOwnerWrapperObj,brand);  
                           }      
                    }  
                } 
                
                //Checking if either GAO/SO/SOCO for same brand is gone already
                if(isSalesNonControlOnly){ 
                     for(String brand : tempBrandList) {
                         //SFSE-13379
                         if(!mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER +brand) && 
                            !mapBrandOwner.containsKey(TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER +TAASettingConstants.PR_All) &&
                       		!mapBrandOwner.containsKey(TAASettingConstants.POR_SALES_CONTROL +brand) &&
                       		!mapBrandOwner.containsKey(TAASettingConstants.POR_SALES_CONTROL_ONLY +brand)){ 
                      			  mapBrandOwner.put(taaObj.Portfolio_Owner_Responsibility__c + brand,taaObj.Territory__c);    
                                  populateBrandOwnerWrapper(account, account.ParentId, taaObj, brandOwnerWrapperObj,brand);     
                            }  
                }
                /*SFSE-12234*/
               }
            }
            
            if(brandOwnerWrapperObj.brandCounter > 0) { 
                
                //getUpdatedAccounts will give the wrapper entries for both the incoming accounts as well as parents
                for(Account acc: getUpdatedAccounts(accountId, account, brandOwnerWrapperObj)) {  
                    
                    /*SFSE-12234*/
                    if(acc.MSL_Account_Owner__c == null) {   
                        acc.MSL_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).MSL_Account_Owner__c : '';
                    }  
                    
                    
                    if(acc.SEA_Account_Owner__c == null) {
                        acc.SEA_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).SEA_Account_Owner__c : '';
                    }  
                    
                    if(acc.Seago_Account_Owner__c == null) {
                        acc.Seago_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).Seago_Account_Owner__c : '';
                    }  
                    
                    if(acc.MCC_Account_Owner__c == null) {
                        acc.MCC_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).MCC_Account_Owner__c : '';
                    }  
                    
                    if(acc.HSUD_Account_Owner__c == null) {
                        acc.HSUD_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).HSUD_Account_Owner__c : '';
                    }  
                    
                    //SFSE-8475
                    if(acc.Alianca_Account_Owner__c	 == null){
                        acc.Alianca_Account_Owner__c = updatedAccountMapSalesControl.get(acc.Id) !=null ? updatedAccountMapSalesControl.get(acc.Id).Alianca_Account_Owner__c : '';
                    }
                     
                    /*SFSE-12234*/
                    if(!updatedAccounts.containsKey(acc.Id)) { 
                        updatedAccounts.put(acc.Id, acc);
                    } 
                }
            }
        }
        
        /** 
        * To add updated accounts for which all TAAs are deleted
        */
        //updatedAccounts.addAll(getUpdatedAccountsWithDeletedTAAs(accountIds));
        
        for(Account delAcc: getUpdatedAccountsWithDeletedTAAs(accountIds)) {
            if(!updatedAccounts.containsKey(delAcc.Id)) {
                updatedAccounts.put(delAcc.Id, delAcc);
            }    
        } 
        
        List<Database.SaveResult> srList = Database.Update(updatedAccounts.values(), false); 
        
        ErrorLogger.writeErrors('SFDC', 'TAA', 'BatchTerrMgmtSyncTerritoryOwnerOnAccount', srList, updatedAccounts.values());
        
    }
    
    private Map<Id, List<Territory_Account_Association__c>> getAccountIdToTAAMap(Set<Id> accountIds) {
        String strDate = System.Label.AccBrandOwnerDateRange;
        String soqlQuery = 'SELECT Id,Account__r.ParentId, Account__r.Represents_Concern__c, Territory_Account_Association__c.Key_Client__c,IsDeleted, Account__c, Brand__c, Portfolio_Owner_Responsibility__c,Territory__c, Territory__r.Portfolio_Owner__c , Product_Responsibility__c FROM Territory_Account_Association__c WHERE Account__c IN: accountIds AND Territory__r.RecordTypeId =:ptRecordTypeID AND Portfolio_Owner_Responsibility__c IN: poResponsibilities AND (End_Date__c =null Or End_Date__c > TODAY) AND Start_Date__c <= TODAY';
        List<Territory_Account_Association__c> taaList = Database.query(soqlQuery);
        
        Map<Id, List<Territory_Account_Association__c>> accountIdToTAAMap = new Map<Id, List<Territory_Account_Association__c>>();
        for(Territory_Account_Association__c taaObj : taaList) {
            Id accountId = taaObj.Account__c;
            accountIds.remove(accountId); // to keep track of accounts with all TAA removed
            List<Territory_Account_Association__c> taAssociations = accountIdToTAAMap.containsKey(accountId) ? accountIdToTAAMap.get(accountId) : new List<Territory_Account_Association__c>();
            taAssociations.add(taaObj);
            accountIdToTAAMap.put(accountId, taAssociations);
        }
        
        /** 
        * This loop is added to track the accounts for which all TAAs are deleted
        */
        for(Id accountId : accountIds) {
            accountIdToTAAMap.put(accountId, null);
        }
        
        return  accountIdToTAAMap;
    }
    
    private void populateBrandOwnerWrapper(Account account, Id parentAccountId, Territory_Account_Association__c taaObj, BrandOwnerWrapper brandOwnerWrapperObj,String brandStr) {
        /** 
        * This can handle the exceptional scenario as well where Portfolio_Owner_Responsibility__c is 'Global Account Owner', 
        * Represents_Concern__c on Client Account record is checked but ParentId on Client record is null.
        */ 
        
        List<String> tempBrandList = taaObj.Brand__c.split(';');
        
        //SFSE-13379 Removing Key_Client__c = TRUE check
        if ( taaObj.Brand__c.contains(TAASettingConstants.PR_All) && taaObj.Portfolio_Owner_Responsibility__c== TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER ){
            //set TTA.Portfolio Owner as owner for all brands on the account
            tempBrandList = new List<String>(brandToAccountFieldMap.keySet());
        }
        
        
        for(String brand : tempBrandList) {
            if(brandStr == '' || (brandStr !=null && brand == brandStr)){
            brandOwnerWrapperObj.brandCounter++;
            String brandKey = brand.toLowerCase();
                
            Map<String, Id> brandOwnerMap = brandOwnerWrapperObj.accountKeyToBrandOwnerMap.containsKey(account.Id) ? brandOwnerWrapperObj.accountKeyToBrandOwnerMap.get(account.Id) : new Map<String, Id>();
            Map<String, String> brandPORMap = brandOwnerWrapperObj.accountKeyToBrandPORMap.containsKey(account.Id) ? brandOwnerWrapperObj.accountKeyToBrandPORMap.get(account.Id) : new Map<String, String>();
            Map<String, Territory_Account_Association__c> brandToTAAmap = brandOwnerWrapperObj.brandToTAAmap.containsKey(account.Id) ? brandOwnerWrapperObj.brandToTAAmap.get(account.Id) : new Map<String, Territory_Account_Association__c>();
            
            //SFSE-12234 If the brand contains 'All' brand selected, then populate all owners 
            //SFSE-13379 Removing Key_Client__c = TRUE check
            if (taaObj.Brand__c.contains(TAASettingConstants.PR_All) && taaObj.Portfolio_Owner_Responsibility__c== TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER){
                brandOwnerMap.put(brandKey, taaObj.Territory__r.Portfolio_Owner__c); 
            } 
            
            brandToTAAmap.put(brandKey, taaObj); 
            
            Id portfolioOwnerId = taaObj.Territory__r.Portfolio_Owner__c != null ? taaObj.Territory__r.Portfolio_Owner__c : NULL;
            String poResponsibility = taaObj.Portfolio_Owner_Responsibility__c != null ? taaObj.Portfolio_Owner_Responsibility__c : NULL;
            
            brandOwnerMap.put(brandKey, portfolioOwnerId); 
            brandOwnerWrapperObj.accountKeyToBrandOwnerMap.put(account.Id, brandOwnerMap);  
            if(account.Represents_Concern__c == TRUE && parentAccountId != NULL )//SFSE-13217 
                brandOwnerWrapperObj.accountKeyToBrandOwnerMap.put(parentAccountId, brandOwnerMap);//For populating parent owner
             
                
            brandPORMap.put(brandKey, poResponsibility); 
            brandOwnerWrapperObj.accountKeyToBrandPORMap.put(account.Id, brandPORMap);  
            if(account.Represents_Concern__c == TRUE &&  parentAccountId != NULL)//SFSE-13217 
                brandOwnerWrapperObj.accountKeyToBrandPORMap.put(parentAccountId, brandPORMap);//For populating parent owner 
            
            brandOwnerWrapperObj.brandToTAAmap.put(account.Id, brandToTAAmap); 
            if(account.Represents_Concern__c == TRUE && parentAccountId != NULL)//SFSE-13217 
                brandOwnerWrapperObj.brandToTAAmap.put(parentAccountId, brandToTAAmap);    
            }
             
        } 
    }
    
    private List<Account> getUpdatedAccounts(Id accountId, Account account, BrandOwnerWrapper brandOwnerWrapperObj) { 
        Map<Id, Account> updatedAccountMap = new Map<Id, Account>();  
        
        for(Id accountKey : brandOwnerWrapperObj.accountKeyToBrandOwnerMap.keySet()) { 
            Map<String, Id> brandOwnerMap = brandOwnerWrapperObj.accountKeyToBrandOwnerMap.get(accountKey); 
            /*SFSE-12234*/     
            updatedAccountMapSalesControl.put(accountKey, getAccountWithBrandOwners(accountKey, brandOwnerMap));         
        } 
        
        
        /** 
        * Exceptional case - All TAAs (with all brands) within an account have Portfolio_Owner_Responsibility__c as 'Global Account Owner',
        * Represents_Concern__c on Client Account record is checked, then brand owners to be updated in Client Account as well.
        */
        Map<String, Id> clearClientConcernbrandOwnerMap = new Map<String, Id>();
        List<String> brandList = BrandUtilities.getAllBrandsList();
        for (String b : brandList) {
            clearClientConcernbrandOwnerMap.put(b, null);
        } 
        
        updatedAccountMap.put(accountId, getAccountWithBrandOwners(accountId, clearClientConcernbrandOwnerMap));
        if(account.Represents_Concern__c == TRUE && account.ParentId != null) {//SFSE-13217 
            updatedAccountMap.put(account.ParentId, getAccountWithBrandOwners(account.ParentId, clearClientConcernbrandOwnerMap));  
        }  
        return updatedAccountMap.values();
    }
    
    private Account getAccountWithBrandOwners(Id accountKey, Map<String, Id> brandOwnerMap) { 
        Account account = new Account(Id = accountKey);
        for(String brandKey : brandToAccountFieldMap.keySet()) {
            account.put(brandToAccountFieldMap.get(brandKey).toLowerCase(), brandOwnerMap.get(brandKey.toLowerCase()));//SFSE-8475
        }
        return account;
    }
    
    private List<Account>  getUpdatedAccountsWithDeletedTAAs(Set<Id> accountIds) {
        Map<String, Id> emptyBrandOwnerMap = new Map<String, Id>();
        List<Account> accountsWithDeletedTAAs = new List<Account>();
        
        for(Id accountId : accountIds) {
            accountsWithDeletedTAAs.add(getAccountWithBrandOwners(accountId, emptyBrandOwnerMap));
        }
        
        return accountsWithDeletedTAAs;
    }
    
    public void finish( Database.BatchableContext BC ) {
        if (this.reprsntConcern == false) {
            Database.executeBatch(new BatchTerrMgmtSyncTerritoryOwnerOnAccount(accountIds, true),10);
        }
    }
}