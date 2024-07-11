/*              
* Revision Ref Number  Date        Owner                       Description
* -------- ----------  ----------- -------------------         -----------
* 1.0      RQ-004168   17-Mar-2017 Ranjini@UST                 Place holder class for AccountFieldPopulator when Trigger is updated to CBO Architecture
* 2.0      RQ-005400   06-Jun-2017 Ranjini@UST                 Billing State update based on Biling city.
* 3.0      RQ-005317   12-Jul-2017 Sandhya@UST                 Removed Population of Cluster for Client account
* 4.0      RQ-007146   10-Oct-2017 Uvais@UST                   Populate the Maersk IDs of Liner Brand Owners
* 5.0      RQ-005636   21-Sep-2017 Nisha@UST                   Update references of GlobalErrorLogger
* 6.0      SFSE-6116   17-Jun-2021 Neha@TCS                    Created method for populating account address area
* 6.1      SFSE-6116   24-Jun-2021 Nitin@Maersk                Created method populateAccountSalesGroup
* 6.2      SFSE-6116   23-Aug-2021 Neha@TCS                    Updated the method populateAccountSalesGroup to populate sales group for OTS manager
*7.0       SFSE-14282  23-Feb-2023 Samar@Maersk                Moving Account Process Builder to Trigger.
*/

public class AccountFieldPopulator {
    //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
    // RQ-005400. Populate the BillingState if the BillingState's Parent Geo matches with Account Country.
    public static void populateBillingState(list<Account> lstAccounts, set<String> setBillingCities) {
        if(Generic_TriggerHandler.validateRunForMethod('AccountFieldPopulator.populateBillingState()', 1)) {
            try {
                map<String, list<Geography__c>> mapCityNameGeos = new map<String, list<Geography__c>>();
                for(Geography__c geo : [Select Id, Name, Parent_Geography__c, Parent_Geography__r.Name, Parent_Geography__r.Parent_Geography__c
                                        From Geography__c Where Name IN :setBillingCities AND Type_Of_Location__c = 'City' AND (Parent_Geography__r.Type_Of_Location__c = 'State' OR Parent_Geography__r.Type_Of_Location__c = 'Province')]) {
                                            String goeName = geo.Name.toLowerCase();
                                            if(mapCityNameGeos.containsKey(goeName)) {
                                                mapCityNameGeos.get(goeName).add(geo);
                                            }
                                            else {
                                                mapCityNameGeos.put(goeName, new list<Geography__c>{geo});
                                            }
                                        }
                    //Generic_TriggerHandler.validateRunForMethod SS9
                    //Generic_TriggerHandler.validateRunForMethod SS10
                    //Generic_TriggerHandler.validateRunForMethod SS11
                    //Generic_TriggerHandler.validateRunForMethod SS12
                    //Generic_TriggerHandler.validateRunForMethod SS13
                    //Generic_TriggerHandler.validateRunForMethod SS14
                    //Generic_TriggerHandler.validateRunForMethod SS15
                    //Generic_TriggerHandler.validateRunForMethod SS16
                    
                for(Account acc : lstAccounts) {
                    String strCityName = acc.BillingCity.toLowerCase();
                    if(mapCityNameGeos.get(strCityName) != null) {
                        // If there is only one city with the BillingCityName.
                        if(mapCityNameGeos.get(strCityName).size() == 1 && mapCityNameGeos.get(strCityName)[0].Parent_Geography__r.Parent_Geography__c == acc.Country__c) {
                            acc.BillingState = mapCityNameGeos.get(strCityName)[0].Parent_Geography__r.Name;
                        }
                        else if(mapCityNameGeos.get(strCityName).size() > 1) { // If there are more than one city records with the same name.
                            Integer iDuplicate = 0;
                            String strStateName;
                            for(Geography__c geo : mapCityNameGeos.get(strCityName)) { // If there are more than one city in different states with in same country. (Eg: Newark)
                                if(geo.Parent_Geography__r.Parent_Geography__c == acc.Country__c) {
                                    iDuplicate = iDuplicate + 1; 
                                    strStateName = geo.Parent_Geography__r.Name;
                                }
                            }
                            if(iDuplicate == 1) {
                                acc.BillingState = strStateName;
                            }
                        }
                    }
                }
            }
            catch(Exception ex) {
                ErrorLogger.writeErrors( 'SFDC', 'Account', 'AccountFieldPopulator.populateBillingState', new list<Exception>{ex}); // #RQ-005636 
            }
        }
    }
    
    // RQ-007146. Populate the Maersk IDs of Liner Brand Owners.
    public static void populateLinerBrandOwnerMIDs(list<Account> lstAccounts,Map<Id,User> linerBrandOwnerDetails) {
        if(Generic_TriggerHandler.validateRunForMethod('AccountFieldPopulator.populateLinerBrandOwnerMIDs()', 1)) {
        //Generic_TriggerHandler.validateRunForMethod SS1
        //Generic_TriggerHandler.validateRunForMethod SS2
        //Generic_TriggerHandler.validateRunForMethod SS3
        //Generic_TriggerHandler.validateRunForMethod SS4
        //Generic_TriggerHandler.validateRunForMethod SS5
        //Generic_TriggerHandler.validateRunForMethod SS6
        //Generic_TriggerHandler.validateRunForMethod SS7
        //Generic_TriggerHandler.validateRunForMethod SS8
            try {
                
                for (Account newAccount : lstAccounts){
                    if(newAccount.MSL_Account_Owner__c != null ){
                        newAccount.MSL_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.MSL_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.MSL_Account_Owner_Maersk_Id__c = null;   
                    
                    if(newAccount.MCC_Account_Owner__c != null ){
                        newAccount.MCC_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.MCC_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.MCC_Account_Owner_Maersk_Id__c = null;   
                    
                    if(newAccount.MLL_Account_Owner__c != null ){
                        newAccount.MLL_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.MLL_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.MLL_Account_Owner_Maersk_Id__c = null;   
                    
                    if(newAccount.SEA_Account_Owner__c != null ){
                        newAccount.SEA_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.SEA_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.SEA_Account_Owner_Maersk_Id__c = null;   
                    
                    /*if(newAccount.SCL_Account_Owner__c != null){
                        newAccount.SCL_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.SCL_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.SCL_Account_Owner_Maersk_Id__c = null; */  
                    
                    if( newAccount.Seago_Account_Owner__c != null ){
                        newAccount.Seago_Account_Owner_Maersk_Id__c = linerBrandOwnerDetails.get(newAccount.Seago_Account_Owner__c).Maersk_User_Id__c;
                    }
                    else
                        newAccount.Seago_Account_Owner_Maersk_Id__c = null;   
                }
                
            }
            catch(Exception ex) {
                ErrorLogger.writeErrors( 'SFDC', 'Account', 'AccountFieldPopulator.populateLinerBrandOwnerMIDs', new list<Exception>{ex}); // #RQ-005636               
            }
        }
    }
    
    public static void populateAccountAddressArea(list<Account> lstAccounts, Map<Id, Account> mapOldAccounts ) {
            //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
        Set<Id> setCountryIds = new Set<Id>(); // Store Geography Ids selected in Account
        Account oldAccount;  
        Map<Id, Id> mapCountryToAreaCluster = new Map<Id, Id>(); // Store Mapping between Country to Cluster(BDA) Ids
        
        for (Account accRec : lstAccounts){
            if(accRec.Country__c != NULL ){
                setCountryIds.add(accRec.Country__c);
                system.debug('setCountryIds::' + setCountryIds);
            }
        }
        if (setCountryIds.size() > 0){
                //  Get Cluster for Account  country from BDA Geography 
            for( BDA_Geography__c bdaGeoRec : [ SELECT Id, Geography__c, BDA__c FROM BDA_Geography__c WHERE Geography__c IN :setCountryIds AND BDA__r.Type__c = 'Cluster' AND BDA__r.Active__c = True ]){
                mapCountryToAreaCluster.put(bdaGeoRec.Geography__c, bdaGeoRec.BDA__c);
                system.debug('mapCountryToAreaCluster ' + mapCountryToAreaCluster);
            }            
        }
        
        for (Account accRec : lstAccounts){
                
            if (mapOldAccounts != null){
                oldAccount = mapOldAccounts.get(accRec.Id);
            }
            
            // If Insert or on update when country is changed & Country != null & country is mapped to a ara then assign Ownership cluster to Country's Area or cluster
            if(accRec.Country__c != NULL && mapCountryToAreaCluster.get(accRec.Country__c) != NULL && (mapOldAccounts == null || accRec.Country__c != null)){
                
                accRec.Account_Address_Area__c = mapCountryToAreaCluster.get(accRec.Country__c);

            } else if (accRec.Country__c == null || mapCountryToAreaCluster.get(accRec.Country__c) == NULL ){
                 // set it to null if country is blank out or there is no active cluster
                accRec.Account_Address_Area__c = null;
            }
        }
    }
    
    public static void populateAccountSalesGroup(list<Account> lstAccounts) {
        Map<String, OneTeamSales_Information__mdt> mapOTSInformation = OneTeamSales_Information__mdt.getAll();
        Set<Id> setAccountAddressArea = new Set<Id>();
        Set<Id> setMSLOwner = new Set<Id>();
         
        for (Account accRec : lstAccounts){
            setAccountAddressArea.add(accRec.Account_Address_Area__c);
            setMSLOwner.add(accRec.MSL_Account_Owner__c);
        }

        Map<Id, BDA__c> mapBDAIdToBDA = new Map<Id, BDA__c>([SELECT Id, BDA_Code__c FROM BDA__c WHERE Id in :setAccountAddressArea]);
        Map<Id, User> mapIdToUser = new Map<Id, User>([SELECT Id, Sales_Job_Function__c FROM User WHERE Id in :setMSLOwner]);

        for (Account accRec2 : lstAccounts){
            String strMSLOwnerSalesJobFunction = (accRec2.MSL_Account_Owner__c != null && mapIdToUser.get(accRec2.MSL_Account_Owner__c).Sales_Job_Function__c != null) ? mapIdToUser.get(accRec2.MSL_Account_Owner__c).Sales_Job_Function__c : '';
            String strAddressAreaBDACode = (accRec2.Account_Address_Area__c != null) ? mapBDAIdToBDA.get(accRec2.Account_Address_Area__c).BDA_Code__c : null;           
            String strSalesGroup = (strAddressAreaBDACode != null && mapOTSInformation.get(strAddressAreaBDACode) !=null ) ? mapOTSInformation.get(strAddressAreaBDACode).Group_Name__c : null;
            if (accRec2.MSL_Account_Owner__c == null || (accRec2.MSL_Account_Owner__c != null && strMSLOwnerSalesJobFunction.Contains(Label.SalesJobFunction_OTS))){
                accRec2.Sales_Group__c = strSalesGroup;
            }

            if (accRec2.MSL_Account_Owner__c != null && !strMSLOwnerSalesJobFunction.Contains(Label.SalesJobFunction_OTS)){
                accRec2.Sales_Group__c = null;
            }
        }
    }

    // Setting the Account recordtype id to inactive recordtype 
    public static void setRecordtypetoInactive(list<Account> lstAccounts) {
        Id inactiveRecordTypeId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();

        if(lstAccounts.size()>0){
            for(Account acc:lstAccounts){
                acc.RecordTypeId = inactiveRecordTypeId;
            }
        }
    }

    // Setting Sync to SFMC flag 
    public static void setSFMCFlag(list<Account> lstAccounts, Boolean isTrue) {
        
        if(lstAccounts.size()>0){
            for(Account acc:lstAccounts){
                acc.Sync_to_SFMC__c = isTrue;
            }
        }
    }
    
    public static void setRepresentConcern(List<Account> acclist){
        if(!acclist.isEmpty()){
                //Generic_TriggerHandler.validateRunForMethod SS1
    //Generic_TriggerHandler.validateRunForMethod SS2
    //Generic_TriggerHandler.validateRunForMethod SS3
    //Generic_TriggerHandler.validateRunForMethod SS4
    //Generic_TriggerHandler.validateRunForMethod SS5
    //Generic_TriggerHandler.validateRunForMethod SS6
    //Generic_TriggerHandler.validateRunForMethod SS7
    //Generic_TriggerHandler.validateRunForMethod SS8
            for(Account acc:acclist){
                acc.Represents_Concern__c = false;
            }
        }
    }
}