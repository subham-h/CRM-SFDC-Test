/** 
* @description 
* Author   : Nayana
* Purpose  : Helper class to hold reusable methods to create Service contract, Entitlements and Contract line items for Account. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9354	   06-Dec-2023 Nayana@Maersk           Created.
*/

/**
* 
* @author Nayana@Maersk
* @description Helper class to Link CX package with Accounts upon creation and used in Batch
*/
public class AccountCxPackageLinkingHelper {
/** 
* @description | Link CX package to Account
* @param lstAccsForCxPackage accepts list of accounts
* @param createSR accepts True or False based on account type
*/    
    public static void linkCXPackageToAccount(List<Account> lstAccsForCxPackage, Boolean createSR){
        //system.debug('lstAccsForCxPackage++'+lstAccsForCxPackage);
        Map<Id,ServiceContract> mapAccountidServiceContract = new Map<Id,ServiceContract>();
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id,Account> mapAccIdToAccount = new Map<Id,Account>();
        try{
            if(!lstAccsForCxPackage.isEmpty()) { 
                //If only Client Account then only create Entitlements
                if(!createSR){
                    //Get all the parent accounts in a set
                    for(Account acc:lstAccsForCxPackage){
                        parentAccountIds.add(acc.ParentId);
                        mapAccIdToAccount.put(acc.Id, acc);
                    }
                    //Get all the service contracts for the parent accounts
                    for(ServiceContract sc: [SELECT Id,AccountId,Name from ServiceContract where AccountId IN :parentAccountIds]){
                        mapAccountidServiceContract.put(sc.AccountId,sc);                                       
                    }
                    //Create entitlement using service contract of Parent
                    if(!mapAccountidServiceContract.isEmpty() && !mapAccIdToAccount.isEmpty()){
                    	createEntitlementsforClient(mapAccountidServiceContract,mapAccIdToAccount);
                    }
                }
                else{
                    createServiceContract(lstAccsForCxPackage);
                }            
            }
        }
        catch(Exception ex){
            if(System.isBatch()){
                ErrorLogger.writeErrors('SFDC', 'CX_Package', 'Batch_CXPackagePopulatorForAccount.linkCXPackageToAccount', new List<Exception>{ex});
            }
            else{
                system.debug('Exception+++'+ex);
               ErrorLogger.writeErrors('SFDC', 'CX_Package', 'AccountCxPackageLinking_Helper.linkCXPackageToAccount', new List<Exception>{ex}); 
            }            
        }
    }
/** 
* @description | Create Service Contract
* @param lstAccsForCxPackage accepts list of accounts
*/    
    public static void createServiceContract(List<Account> lstAccsForCxPackage){
        List<ServiceContract> serviceContractsToInsert = new List<ServiceContract>();
        Set<Id> setInsertedServiceContracts = new Set<Id>();
        Map<Id,String> mapAccountIdPackageName = new Map<Id,String>();
        mapAccountIdPackageName = getAccountToPackageMapping(lstAccsForCxPackage);
        //Only if Package is applicable for account then create service contract and other records
        for (Account acc : lstAccsForCxPackage) {
            if(!mapAccountIdPackageName.isEmpty() && mapAccountIdPackageName.containsKey(acc.Id)){
                // Create Service Contract
                ServiceContract serviceContract = new ServiceContract(
                    Name = acc.Name + ' Contract',
                    StartDate = system.today(),
                    AccountId = acc.Id
                );
                serviceContractsToInsert.add(serviceContract);       
            }    
        }
        
        //system.debug('serviceContractsToInsert++'+serviceContractsToInsert);
        if(!serviceContractsToInsert.isEmpty() && serviceContractsToInsert.size()>0){
            insert serviceContractsToInsert;        
            
            Map<Id,ServiceContract> mapAccountidServiceContract = new Map<Id,ServiceContract>();
            for(ServiceContract sc: serviceContractsToInsert){
                mapAccountidServiceContract.put(sc.AccountId,sc);
            }
            //system.debug('mapAccountidServiceContract++'+mapAccountidServiceContract);
            if(!mapAccountidServiceContract.isEmpty() && !mapAccountIdPackageName.isEmpty()){
                createEntitlementsforParent(mapAccountidServiceContract,mapAccountIdPackageName);
                createContractLineItems(mapAccountidServiceContract,mapAccountIdPackageName);
            }   
        }
    }
/** 
* @description | Create Entitlement for standalone accounts
* @param mapAccountidServiceContract accepts map of accountid and ServiceContract
* @param mapAccountIdPackageName accepts map of accountid and packagename
*/    
    public static void createEntitlementsforParent(Map<Id,ServiceContract> mapAccountidServiceContract,Map<Id,String> mapAccountIdPackageName){
        List<Entitlement> entitlementsToInsert = new List<Entitlement>();
        
        //Loop through the service contracts to form the Entitlements and Contract line items
        for(Id accId: mapAccountidServiceContract.keyset()){            
            // Create Entitlement
            Entitlement entitlement = new Entitlement(
                Name = mapAccountidServiceContract.containsKey(accId) ? mapAccountidServiceContract.get(accId).Name.removeEnd(' Contract') + ' Entitlement' : null,
                AccountId = accId,
                ServiceContractId = mapAccountidServiceContract.containsKey(accId) ? mapAccountidServiceContract.get(accId).Id : null,
                Type=null,
                StartDate = system.today()
            );
            entitlementsToInsert.add(entitlement);           
        }
        //system.debug('entitlementsToInsert++'+entitlementsToInsert);
        if(!entitlementsToInsert.isEmpty() && entitlementsToInsert.size()>0){
                Database.SaveResult[] resultsList = Database.insert(entitlementsToInsert, false);
            	ErrorLogger.writeErrors('SFDC', 'Entitlement', 'AccountCxPackageLinking_Helper.createEntitlementsforParent', resultsList, entitlementsToInsert);                
        }        
    }
/** 
* @description | Create Contract line items for standalone accounts
* @param mapAccountidServiceContract accepts map of accountid and ServiceContract
* @param mapAccountIdPackageName accepts map of accountid and packagename
*/     
    public static void createContractLineItems(Map<Id,ServiceContract> mapAccountidServiceContract,Map<Id,String> mapAccountIdPackageName){
        List<Contract_Line_Item__c> contractLineItemsToInsert = new List<Contract_Line_Item__c>();
        Map<String,List<Specification_Option_CM__c>> mapFeatureNameToSpecsOptions = new Map<String,List<Specification_Option_CM__c>>();
        //Get all the Specification Options into a map with Feature name
        for(Specification_Option_CM__c spo:[SELECT Id, Name, Specification_Parameter__c,Feature__c,Description__c from Specification_Option_CM__c]){        	
            if(mapFeatureNameToSpecsOptions.isEmpty() || !mapFeatureNameToSpecsOptions.containsKey(spo.Feature__c)){
                mapFeatureNameToSpecsOptions.put(spo.Feature__c, new List<Specification_Option_CM__c>{spo});                
            }
            else{
                mapFeatureNameToSpecsOptions.get(spo.Feature__c).add(spo);
            }
        }
        //system.debug('mapFeatureNameToSpecsOptions++'+mapFeatureNameToSpecsOptions);
        
        for(Id accId: mapAccountidServiceContract.keyset()){ 
            String cxPackage = null;
            cxPackage = mapAccountIdPackageName.containsKey(accId) ? mapAccountIdPackageName.get(accId) : null;
            //System.debug('cxPackage++'+cxPackage);
            List<Specification_Option_CM__c> listSpecOptions = new List<Specification_Option_CM__c>();
            listSpecOptions = mapFeatureNameToSpecsOptions.containskey(cxPackage) ? mapFeatureNameToSpecsOptions.get(cxPackage) : new List<Specification_Option_CM__c>();
            //Create Contract Line items for each specification option as it is the grain level of record
            for(Specification_Option_CM__c spo:listSpecOptions){       
                Contract_Line_Item__c contractLine = new Contract_Line_Item__c(
                    Service_Contract__c = mapAccountidServiceContract.containsKey(accId) ? mapAccountidServiceContract.get(accId).Id : null,                
                    Specification_Parameter__c = spo.Specification_Parameter__c,
                    Specification_Option__c = spo.Id,
                    Standard_package__c = true
                    //Specification_Option_Description__c	= spo.Description__c
                );
                contractLineItemsToInsert.add(contractLine);
            }
        }
        if(!contractLineItemsToInsert.isEmpty() && contractLineItemsToInsert.size()>0){
            Database.SaveResult[] resultsList = Database.insert(contractLineItemsToInsert, false);
            ErrorLogger.writeErrors('SFDC', 'Contract_Line_Item__c', 'AccountCxPackageLinking_Helper.createContractLineItems', resultsList, contractLineItemsToInsert);
        }
    }
/** 
* @description | Create Entitlement for non-standalone accounts
* @param mapAccountidServiceContract accepts map of accountid and ServiceContract
* @param mapAccountIdPackageName accepts map of accountid and account
*/     
    public static void createEntitlementsforClient(Map<Id,ServiceContract> mapAccountidServiceContract,Map<Id,Account> mapAccIdToAccount){
        List<Entitlement> entitlementsToInsert = new List<Entitlement>();
        // Creating Entitlement for Hierarchy accounts using Parent's service contractid
        for(Id accId: mapAccIdToAccount.keyset()){            
            Entitlement entitlement = new Entitlement(
                Name = mapAccIdToAccount.get(accId).Name + ' Entitlement',
                AccountId = accId,
                ServiceContractId = mapAccountidServiceContract.containsKey(mapAccIdToAccount.get(accId).ParentId) ? 
                					mapAccountidServiceContract.get(mapAccIdToAccount.get(accId).ParentId).Id : null,
                Type=null,
                StartDate = system.today()
            );
            entitlementsToInsert.add(entitlement);    
        }
        //system.debug('entitlementsToInsert++'+entitlementsToInsert);
        if(!entitlementsToInsert.isEmpty() && entitlementsToInsert.size()>0){
            Database.SaveResult[] resultsList = Database.insert(entitlementsToInsert, false);
            ErrorLogger.writeErrors('SFDC', 'Entitlement', 'AccountCxPackageLinking_Helper.createEntitlementsforClient', resultsList, entitlementsToInsert);
        }
    }
    
/** 
* @description | Map the account with right package based on customer profiling
* @param lstAccsForCxPackage accepts list of accounts
* @return map of Accountid and package name
*/    
    public static Map<Id,String> getAccountToPackageMapping(List<Account> lstAccsForCxPackage){
        Map<String,String> mapAccountfieldToPackage = new Map<String,String>();
        Map<Id,String> mapAccountIdPackageName = new Map<Id,String>();
        for(General_Key_Value_Configurations__mdt gen : [Select Key__c, First_Field_Value__c, Second_Field_Value__c,Order__c From General_Key_Value_Configurations__mdt Where Key__c = 'CxPackageCustomerProfileMapping' order by Order__c]){
            if(!String.isEmpty(gen.First_Field_Value__c) && !String.isEmpty(gen.Second_Field_Value__c)){
                mapAccountfieldToPackage.put(gen.First_Field_Value__c,gen.Second_Field_Value__c);
            }
        }
        for (Account acc : lstAccsForCxPackage) {
            Boolean consideredAttractiveness = false;
            if(acc.Attractiveness__c!=null && !mapAccountfieldToPackage.isEmpty()){                
                String cxPackage = null;
                if(acc.Attractiveness__c.contains(';')){
                    for(String str:mapAccountfieldToPackage.keyset()){
                        if(acc.Attractiveness__c.containsIgnoreCase(str)){
                            cxPackage = mapAccountfieldToPackage.containsKey(str) ? mapAccountfieldToPackage.get(str) : null;
                            break;
                        }
                    }
                    mapAccountIdPackageName.put(acc.id,cxPackage);
                    consideredAttractiveness = true;
                }
                else if(mapAccountfieldToPackage.containsKey(acc.Attractiveness__c)){
                    mapAccountIdPackageName.put(acc.id,mapAccountfieldToPackage.get(acc.Attractiveness__c));
                    consideredAttractiveness = true;
                }                
            }            
            if(!consideredAttractiveness && acc.Customer_Role__c!=null && !mapAccountfieldToPackage.isEmpty() && mapAccountfieldToPackage.containsKey(acc.Customer_Role__c)){
                mapAccountIdPackageName.put(acc.id,mapAccountfieldToPackage.get(acc.Customer_Role__c));
            }
        }
        return mapAccountIdPackageName;
        
    }    

/** 
* @description | Delete Entitlement and Servicecontract on Account
* @param lstAccsForCustProfilingChangeCx accepts list of accounts
*/    
    public static void handleCXPkgForAccountUpdate(List<Account> lstAccsForCxPackageOnUpdate, Map<Id, Account> mapOldAccounts){
        List<Account> listAccountsToCreateSC = new List<Account>();
        Map<Id,ServiceContract> mapAccIdToServiceCont = new Map<Id,ServiceContract>();
        Map<Id,String> mapAccountIdPackageName = new Map<Id,String>();
        List<ServiceContract> listServiceContsToDelete = new List<ServiceContract>();
        List<Entitlement> listEntitlementsToDelete = new List<Entitlement>();
        List<Contract_Line_Item__c> listCliToDelete = new List<Contract_Line_Item__c>();
        Map<Id,ServiceContract> mapAccountidServiceContract = new Map<Id,ServiceContract>();
        Account oldAccount;
        List<Account> listChildAccounts = new List<Account>();
        Map<Id,Account> mapAccountidAccount = new Map<Id,Account>();
        List<Account> listAccountwithServCont = new List<Account>();
        
        //Get account to package mapping using customer profiling
        mapAccountIdPackageName = getAccountToPackageMapping(lstAccsForCxPackageOnUpdate);
        for(Account act: [Select Id, Name,ParentId,Attractiveness__c,Customer_Role__c,(Select Id from ServiceContracts),(Select Id from Entitlements) from Account where Id IN :lstAccsForCxPackageOnUpdate]){
            mapAccountidAccount.put(act.Id,act);
            if(!act.ServiceContracts.isEmpty()){
                listAccountwithServCont.add(act);
            }
        }
        //Get service contarcts for the applicable accounts        
        if(!listAccountwithServCont.isEmpty()){
            for(ServiceContract sct:[SELECT Id, AccountId, (Select Id,Feature_Name__c,Standard_package__c from Contract_Line_Items__r),(Select Id from Entitlements) from ServiceContract where AccountId IN :listAccountwithServCont]){
                mapAccIdToServiceCont.put(sct.AccountId,sct);
            }
        }
        try{
            for(Account acc:lstAccsForCxPackageOnUpdate){
                Boolean isParentChanged = false;
                if (mapOldAccounts != null){
                	oldAccount = mapOldAccounts.get(acc.Id);
            	}
                if(oldAccount.ParentId != acc.ParentId){
                    isParentChanged = true;
                    //Delete Service contract and Entitlements
                    if(!mapAccIdToServiceCont.isEmpty() && mapAccIdToServiceCont.containsKey(acc.Id)){                        
                        listServiceContsToDelete.add(mapAccIdToServiceCont.get(acc.Id));
                    }           
                    if(!mapAccountidAccount.isEmpty() && mapAccountidAccount.containsKey(acc.Id) && !mapAccountidAccount.get(acc.Id).Entitlements.isEmpty()){
                        listEntitlementsToDelete.addAll(mapAccountidAccount.get(acc.Id).Entitlements);
                    }
                    //Process accounts based on parentId
                    if(acc.ParentId!=null){
                        listChildAccounts.add(acc);
                    }   
                    else if(acc.ParentId==null){
                        listAccountsToCreateSC.add(acc);
                    }
                }
                //If service contract is present for the Account
                if(!isParentChanged && !mapAccIdToServiceCont.isEmpty() && mapAccIdToServiceCont.containsKey(acc.Id)){            
                    //If account does not have applicable package then delete existing service contract for that account
                    if((mapAccountIdPackageName.isEmpty() || !mapAccountIdPackageName.containsKey(acc.Id)) && mapAccIdToServiceCont.containsKey(acc.Id)){
                        listEntitlementsToDelete.addAll(mapAccIdToServiceCont.get(acc.Id).Entitlements);
                        listServiceContsToDelete.add(mapAccIdToServiceCont.get(acc.Id));
                    }          
                    //If account has applicable package then delete existing contract line items and create new
                    else if(!mapAccountIdPackageName.isEmpty() && mapAccountIdPackageName.containsKey(acc.Id) && 
                            !mapAccIdToServiceCont.get(acc.Id).Contract_Line_Items__r.isEmpty()){
                                Boolean noPackageChange = false;                                
                                for(Contract_Line_Item__c cli: mapAccIdToServiceCont.get(acc.Id).Contract_Line_Items__r){
                                    //If existing standard package is the applicable package then no need to delete CLI
                                    if(cli.Standard_package__c && mapAccountIdPackageName.get(acc.Id) == cli.Feature_Name__c){
                                        noPackageChange = true;
                                        break;
                                    }
                                }
                                if(!noPackageChange){
                                    listCliToDelete.addAll(mapAccIdToServiceCont.get(acc.Id).Contract_Line_Items__r);
                                	mapAccountidServiceContract.put(acc.Id,mapAccIdToServiceCont.get(acc.Id));  
                                }                                  
                   }              
                }
                //If account does not have Service contract and account profiling should have applicable package then create SR
                else if(!isParentChanged && (mapAccIdToServiceCont.isEmpty() || !mapAccIdToServiceCont.containsKey(acc.Id)) && 
                        !mapAccountIdPackageName.isEmpty() && mapAccountIdPackageName.containsKey(acc.Id)){
                            listAccountsToCreateSC.add(acc);
                }
            }
            //DML for deletetion
            if(!listEntitlementsToDelete.isEmpty()){
                delete listEntitlementsToDelete;                
            }
            if(!listServiceContsToDelete.isEmpty()){
                delete listServiceContsToDelete;
            }
            if(!listCliToDelete.isEmpty()){
                delete listCliToDelete;                
            }
            //Create contract line items
            if(!mapAccountidServiceContract.isEmpty()){
                createContractLineItems(mapAccountidServiceContract,mapAccountIdPackageName);
            }
            //When Parent is present then process it for only Entitlements
            if(!listChildAccounts.isEmpty()){
                linkCXPackageToAccount(listChildAccounts,false);
            }  
            //When Parent is not present then process it for only Service contract and Entitlements
            if(!listAccountsToCreateSC.isEmpty()){
                linkCXPackageToAccount(listAccountsToCreateSC,true);
            }
        }
        catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Account', 'AccountCxPackageLinking_Helper.handleCXPkgForParentUpdate', new List<Exception>{ex}); 
        }
    }
}