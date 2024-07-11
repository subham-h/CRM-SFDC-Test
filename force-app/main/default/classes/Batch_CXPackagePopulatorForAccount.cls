/*
* Author    : Nayana
* Purpose   : Mapping CX Package to Accounts using the batch. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9354     04-Dec-2023 Nayana@Maersk            Created as part of Static service package implementation.
*            
*/

/**
* 
* @author Nayana@Maersk
* @description Batch class to Link CX package with Accounts
*/
global class Batch_CXPackagePopulatorForAccount implements Database.Batchable<SObject>,Database.AllowsCallouts {
    global Date beginDate;
    global Date endDate;
/** 
* @description | Constructor method |
* @param Startdate and endingDate accepts date as string
*/	
    global Batch_CXPackagePopulatorForAccount(Date startDate, Date endingDate) {
        this.beginDate = startDate;
        this.endDate = endingDate;
    }
/** 
* @description | Start method |
* @param bc accepts BatchableContext interface
* @return list of Account
*/	
    global List<Account> start(Database.BatchableContext bc) {
        List<Account> listAccountToProcess = new List<Account>();
        Date startDt;
        Date endDt;
        if(beginDate != null && endDate != null){
            startDt = beginDate;
            endDt = endDate;
        }        
        String strQuery = '';
        String strSelect = 'SELECT Id, Name,ParentId,Attractiveness__c,Customer_Role__c,CX_Package_Indicator__c FROM Account';
        String strWhere = ' WHERE ';
        strWhere += '(Record_Type__c = \'' + Label.ConcernAccountRecordType + '\' OR ';
        strWhere += '(Record_Type__c = \'' + Label.ClientAccountRecordType + '\' AND ParentId = null)) AND (';
        for(General_Key_Value_Configurations__mdt gen : [Select Key__c,First_Field_Name__c, First_Field_Value__c,Second_Field_Name__c,Second_Field_Value__c, Order__c From General_Key_Value_Configurations__mdt Where Key__c = 'BatchCXPackagePopulatorForAccount' order by Order__c]){
            if(!String.isEmpty(gen.First_Field_Value__c) && !String.isEmpty(gen.First_Field_Name__c) && !String.isEmpty(gen.Second_Field_Value__c)){
                strWhere +=  gen.First_Field_Name__c + ' ' + gen.Second_Field_Value__c +' ('+ gen.First_Field_Value__c +') OR ';
            }            
        }
        //strWhere += ' AND CX_Package_Indicator__c IN ('+ Label.CX_Packages_for_Batch +')';
        strWhere = strWhere.trim().removeEnd('OR');
        strWhere += ') AND SCV_Status__c = \'Active\'';
        if(startDt!=null && endDt!=null){
        	strWhere += ' AND Createddate >=: startDt AND Createddate <=: endDt'; 
        }
        strQuery = strSelect +' '+ strWhere;
        system.debug(strQuery);
        //Getting all the Concern accounts+ Client accounts without Parentid to create Service contracts
        listAccountToProcess = Database.query(strQuery);
        system.debug('listAccountToProcess+++'+listAccountToProcess.size());        
        return listAccountToProcess;
    }
/** 
* @description | Execute method |
* @param bc accepts BatchableContext interface and scope accepts list of accounts
*/	
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> listScopeAccounts = new List<Account>();
        listScopeAccounts.addAll(scope);
        Set<Id> setIdsToRemove = new Set<Id>();
        //If Account already has ServiceContract, then no need to pass it for contract creation
        for(ServiceContract sc:[SELECT Id,AccountId,Name from ServiceContract where AccountId IN :scope]){   
            setIdsToRemove.add(sc.AccountId);
        }
        if(!setIdsToRemove.isEmpty() && setIdsToRemove!=null){
            for (Integer i = scope.size() - 1; i >= 0; i--) {
                if (setIdsToRemove.contains(scope[i].Id)) {
                    scope.remove(i);
                }
            }            
        }
        //This is to create Service Contract, Entitlement and Contract line items for Concern accounts and Client Accounts without Parent
        AccountCxPackageLinkingHelper.linkCXPackageToAccount(scope,true);  
        //This creates Entitlements for the accounts that come under parent accounts
        processHeirarchyAccounts(listScopeAccounts);           
    }
    public static void processHeirarchyAccounts(List<Account> listParentAccounts){
        Map<Id,ServiceContract> mapAccountidServiceContract = new Map<Id,ServiceContract>();
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id,Account> mapAccIdToAccount = new Map<Id,Account>();
        for(Account acc:[Select Id,ParentId,Name,(Select Id from Entitlements) from Account where ParentId IN :listParentAccounts]){   
            if(acc.Entitlements.isEmpty()){ //Only if client accounts dont have Entitlements then send for processing
                parentAccountIds.add(acc.ParentId);
                mapAccIdToAccount.put(acc.Id, acc);
            }
        }
        //Get all the service contracts for the parent accounts
        for(ServiceContract sc: [SELECT Id,AccountId,Name from ServiceContract where AccountId IN :parentAccountIds]){
        	mapAccountidServiceContract.put(sc.AccountId,sc);  
        }
        AccountCxPackageLinkingHelper.createEntitlementsforClient(mapAccountidServiceContract,mapAccIdToAccount);
    }
/** 
* @description | Finish method |
* @param bc accepts BatchableContext interface
*/    
    global void finish(Database.BatchableContext bc) {
    }

}