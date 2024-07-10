/*  
 * Version   Date            Referance               Owner                   Description
 * --------  -----------     -------------------     -----------
 * 1.0       19-Dec-2022                             Vazid@UST               To create Concern Accounts from CMD
 * 1.1       26-Apr-2023     SFSE-10934              Sowmya@Maersk           Concern Account updates
 * 1.2       26-Apr-2023     SFSE-10870              Kiran@Maersk            Duplicate external Id error fix
 * 1.3		21-Sep-2023		SFSE-12142				Kiran@Maersk			Represent Concern Issue, Moving client accounts update to future method
 * 2.0		17-Oct-2023		SFSE-12972				Kiran@Maersk			Mapping concern address fields
 * 3.0		7-Dec-2023		SFSE-13594				Kiran@Maersk			Removing async upadtion of client accounts
*/

public with sharing class ConcernEventHandler extends TriggerHandler{
    
    public List<Concern_Message_Event__e> newConcernMsg;
    public String jsonStr;
    public List<Account> concernAccsToUpsert;
    public static List<Account> clientAccsToUpsert;
    public static set<string> setOfcustomerCodes ;
    private static Map<String, ConcernEntity> mapConcernCodeToWrap;
    private static String concernCode;
    private DateTime lastUpdatedDate;
    private DateTime lastUpdatedDatePrevious;
    private static CustomerAddress customerAddress;
    private static Set<String> setCountries;
    private static Map<String, Id> mapCountryNameToId;
    
    public ConcernEventHandler() {
        this.newConcernMsg = (List<Concern_Message_Event__e>) Trigger.new;
        concernAccsToUpsert = new List<Account>();
        clientAccsToUpsert = new List<Account>();
        setOfcustomerCodes = new set<string>();
        mapConcernCodeToWrap = new Map<String, ConcernEntity>();
        customerAddress = new CustomerAddress();
        setCountries = new Set<String>();
        mapCountryNameToId = new Map<String, Id>();
    }
    
    public override void onAfterInsert() {
        
        ConcernEntity concernEntity;
        List<List<concernMembers>> concernMembersList = new List<List<concernMembers>>();
        List<concernMembers> concernMembersFinalList = new List<concernMembers>();
        
        try{
            //get the list of concern memebers to check the client account is exist or not if not mark the customer status to Inactive
            for(Concern_Message_Event__e ConcernMsg : newConcernMsg){
                concernEntity = new ConcernEntity();
                 if(ConcernMsg.JSON_1__c != '' && ConcernMsg.JSON_1__c != null)
                    jsonStr = ConcernMsg.JSON_1__c;
                if(ConcernMsg.JSON_2__c != '' && ConcernMsg.JSON_2__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_2__c;
                if(ConcernMsg.JSON_3__c != '' && ConcernMsg.JSON_3__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_3__c;
                if(ConcernMsg.JSON_4__c != '' && ConcernMsg.JSON_4__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_4__c;
                if(ConcernMsg.JSON_5__c != '' && ConcernMsg.JSON_5__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_5__c;
                if(ConcernMsg.JSON_6__c != '' && ConcernMsg.JSON_6__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_6__c;
                if(jsonStr != null){
                    ConcernAccountWrapper jsonDeserialized = parse(jsonStr);
                    
                    if(jsonDeserialized.concernEntity != null && jsonDeserialized.concernEntity.concernMembers != null && !jsonDeserialized.concernEntity.concernMembers.isEmpty()){
                        concernMembersList.add(jsonDeserialized.concernEntity.concernMembers);
                    }
                    if(jsonDeserialized.concernEntity != null && jsonDeserialized.concernEntity.parentCustomerDetails != null && jsonDeserialized.concernEntity.parentCustomerDetails.customerCode != null){
                        setOfcustomerCodes.add(jsonDeserialized.concernEntity.parentCustomerDetails.customerCode);
                    }
                    
                    if( jsonDeserialized.concernEntity != null ){
                        concernEntity = jsonDeserialized.concernEntity;
                    }
                    concernCode = concernEntity.concernCode;
                    lastUpdatedDate = convertEpochToDateTime(concernEntity.concernAuditData.lastUpdateDate);
                    if(!mapConcernCodeToWrap.containsKey(concernCode)){
                        mapConcernCodeToWrap.put(concernCode, concernEntity);
                    }else{
                        lastUpdatedDatePrevious = convertEpochToDateTime(mapConcernCodeToWrap.get(concernCode).concernAuditData.lastUpdateDate);
                        if( lastUpdatedDate > lastUpdatedDatePrevious ){
                            mapConcernCodeToWrap.put(concernCode, concernEntity);
                        }
                    }
                }
            }
            
            for(List<concernMembers> conMemList : concernMembersList){
                concernMembersFinalList.addAll(conMemList);
            }
            // get list of customercodes for the concern members
            for(concernMembers concernMember : concernMembersFinalList){
                if(concernMember.customerCode != null){
                    setOfcustomerCodes.add(concernMember.customerCode);
                }
            }
            //check if the concern members are exist or not. If not will create new record and mark customer status to inactive 
            List<Account> lstOfaccounts =[select Id, Customer_Code__c from Account where Customer_Code__c in : setOfcustomerCodes];
            setOfcustomerCodes = new set<string>();
            for(Account acc: lstOfaccounts){
                setOfcustomerCodes.add(acc.Customer_Code__c);
            } 
            
            /*for(Concern_Message_Event__e ConcernMsg : newConcernMsg){
                if(ConcernMsg.JSON_1__c != '' && ConcernMsg.JSON_1__c != null)
                    jsonStr = ConcernMsg.JSON_1__c;
                if(ConcernMsg.JSON_2__c != '' && ConcernMsg.JSON_2__c != null)
                    jsonStr = jsonStr + ConcernMsg.JSON_2__c;
                if(jsonStr != null){
                    ConcernAccountWrapper jsonDeserialized = parse(jsonStr);
                    if(jsonDeserialized.concernEntity != null){
                        concernEntity = jsonDeserialized.concernEntity;
                        concernAccsToUpsert.add(concernAccountUpsert(concernEntity));
                    }
                }
            }*/
            
            for(ConcernEntity concernEnt : mapConcernCodeToWrap.values()){
                if(concernEnt.parentCustomerDetails != null && concernEnt.parentCustomerDetails.customerAddress != null &&
                  concernEnt.parentCustomerDetails.customerAddress.country != null &&
                   concernEnt.parentCustomerDetails.customerAddress.country.countryName != null){
                    setCountries.add(concernEnt.parentCustomerDetails.customerAddress.country.countryName);
                }
            }
            
            if(setCountries.size() > 0){
                mapCountryNameToId = getCountryIds(setCountries);
            }
            
            for(ConcernEntity concernEnt : mapConcernCodeToWrap.values()){
                concernAccsToUpsert.add(concernAccountUpsert(concernEnt));
            }
            
            if(!concernAccsToUpsert.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(concernAccsToUpsert, Account.Customer_Code__c, false);
                ErrorLogger.writeErrors('CMD', 'Concern Message', 'ConcernEventHandler.onAfterInsert', results, concernAccsToUpsert);
                boolean blnisSuccess = false;
                for (Database.UpsertResult sr : results) {
                    if (sr.isSuccess()) {
                        blnisSuccess = true;
                    }else{
                        blnisSuccess = false;
                    }
                }
                if(blnisSuccess && !clientAccsToUpsert.isEmpty()){
                    //SFSE-12142
                    //updateClientAccounts(JSON.serialize(clientAccsToUpsert));
                    Database.UpsertResult[] clientAccresults = Database.upsert(clientAccsToUpsert, Account.Customer_Code__c, false);
                    ErrorLogger.writeErrors('SFDC', 'Concern Message', 'ConcernEventHandler.onAfterInsert', clientAccresults, clientAccsToUpsert);
                }
            }
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            //ErrorLogger.writeError('SFDC', 'Concern Message', 'ConcernEventHandler.onAfterInsert', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Concern Message', 'ConcernEventHandler.onAfterInsert', new list<Exception>{ex});
        }
        
    }
    //To create and update the concern account in the system
    public static Account concernAccountUpsert(concernEntity concernEntity){
        
        concernEntity concernEntityInfo = concernEntity != null ? concernEntity : new concernEntity();
        Map<String, String> externalSystemMap = getExternalIdentifiers(concernEntityInfo);
        
        Account concernAcc = new Account();
        concernAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Concern_Account').getRecordTypeId();
        concernAcc.Customer_Code__c = concernEntityInfo.concernCode;
        concernAcc.Name = concernEntityInfo.concernName;
        concernAcc.Legal_Name__c = concernEntityInfo.concernName;
        concernAcc.SCV_Code__c = getExternalSystemCode('SCV', externalSystemMap);
        
        if(concernEntityInfo.statusCode == 'A'){
            concernAcc.SCV_Status__c = 'Active';
        }else if(concernEntityInfo.statusCode == 'S'){
            concernAcc.SCV_Status__c = 'Suspended';
        }else{
            concernAcc.SCV_Status__c = 'Inactive';
        }
        
        createClientAccounts(concernEntityInfo);
        
        if(customerAddress != null){
            concernAcc.BillingStreet = (customerAddress.streetNumber != null && customerAddress.streetNumber != '') ? customerAddress.streetNumber : '';
            concernAcc.BillingStreet = (customerAddress.streetName != null && customerAddress.streetName != '') ? concernAcc.BillingStreet + ' ' + customerAddress.streetName : concernAcc.BillingStreet;
            concernAcc.BillingCity = (customerAddress.cityName != null && customerAddress.cityName != '') ? customerAddress.cityName : '';
            concernAcc.BillingState = (customerAddress.region != null && customerAddress.region.regionName != null && customerAddress.region.regionName != '') ? customerAddress.region.regionName : '';
            concernAcc.BillingPostalCode = (customerAddress.postalCode != null && customerAddress.postalCode != '') ? customerAddress.postalCode : '';
            concernAcc.BillingCountry = (customerAddress.country != null && customerAddress.country.countryName != null && customerAddress.country.countryName != '') ? customerAddress.country.countryName : '';
            if(customerAddress.country != null && customerAddress.country.countryName != null && customerAddress.country.countryName != '' && mapCountryNameToId.containsKey(customerAddress.country.countryName)) {
                concernAcc.Country__c = mapCountryNameToId.get(customerAddress.country.countryName);
            }
        }
        
        return concernAcc;
    }
    
    // To create client accounts from concern members and parentcustomer details in the response.
    private static void createClientAccounts(concernEntity concernEntityInfo){
        
        parentCustomerDetails parentcustDetails = concernEntityInfo.parentCustomerDetails != null ? concernEntityInfo.parentCustomerDetails : new parentCustomerDetails();
        List<concernMembers> concernMembersList = (concernEntityInfo.concernMembers != null && !concernEntityInfo.concernMembers.isEmpty()) ? concernEntityInfo.concernMembers : new List<concernMembers>();
        customerAddress = new CustomerAddress();
        if(parentcustDetails.customerCode != null){
            Account clientAcc = new Account();
            
            if(!setOfcustomerCodes.contains(parentcustDetails.customerCode)){
                clientAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
                clientAcc.SCV_Status__c = 'Inactive';
            }
            
            clientAcc.Name = parentcustDetails.customerName;
            clientAcc.Customer_Code__c = parentcustDetails.customerCode;
            clientAcc.Represents_Concern__c = true;
            
            Account parentAcc = new Account(Customer_Code__c = concernEntityInfo.concernCode);
            clientAcc.Parent = parentAcc;
            clientAccsToUpsert.add(clientAcc);
            
            customerAddress = parentcustDetails.customerAddress != null ? parentcustDetails.customerAddress : new CustomerAddress();
        }
        //SFSE-12142
        Set<String> processedCustomerCodes = new Set<String>();
        for(concernMembers conMember : concernMembersList){
            if(conMember.customerCode != parentcustDetails.customerCode && !processedCustomerCodes.contains(conMember.customerCode)){
                System.debug('processedCustomerCodes '+processedCustomerCodes+ ' conMember.isDeletedFlag '+conMember.isDeletedFlag+' conMember.customerCode '+conMember.customerCode);
                processedCustomerCodes.add(conMember.customerCode);
                Account conMemberAccount = new Account();
                
                if(!setOfcustomerCodes.contains(conMember.customerCode)){
                    conMemberAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
                    conMemberAccount.SCV_Status__c = 'Inactive';
                }
                
                conMemberAccount.Name = conMember.customerName;
                conMemberAccount.Customer_Code__c = conMember.customerCode;
                if(conMember.isDeletedFlag == false){
                    Account conMemberAccountparentAcc = new Account(Customer_Code__c = concernEntityInfo.concernCode);
                    conMemberAccount.Parent = conMemberAccountparentAcc;
                }else{
                    conMemberAccount.ParentId = null;
                }
                clientAccsToUpsert.add(conMemberAccount); 
            }
        }
        
    }
    
    //SFSE-12142
    /*@future
    private static void updateClientAccounts(String jsonClientAccsToUpsert){
        List<Account> clientAccsToUpsert = new List<Account>();
        if(jsonClientAccsToUpsert != null){
            clientAccsToUpsert = (List<Account>)Json.deserialize(jsonClientAccsToUpsert, List<Account>.class);
        }
        System.debug('clientAccsToUpsert size'+clientAccsToUpsert.size());
        Database.UpsertResult[] clientAccresults = Database.upsert(clientAccsToUpsert, Account.Customer_Code__c, false);
        ErrorLogger.writeErrors('SFDC', 'Concern Message', 'ConcernEventHandler.onAfterInsert', clientAccresults, clientAccsToUpsert);
    }*/
    
    private static Map<String, String> getExternalIdentifiers(concernEntity concernEntityInfo){
        Map<String, String> externalSystemMap = new Map<String, String>();
        if(concernEntityInfo.concernExternalSystemIdentifiers != null && concernEntityInfo.concernExternalSystemIdentifiers.size() > 0){
            for(concernExternalSystemIdentifiers identifier : concernEntityInfo.concernExternalSystemIdentifiers){
                if(!identifier.isDeletedFlag){
                    externalSystemMap.put(identifier.externalSystemName, identifier.externalSystemReference);
                }
            }
        }        
        return externalSystemMap;
    }
    
    private static String getExternalSystemCode(String systemName, Map<String, String> externalSystemMap){
        String systemCode;
        if(externalSystemMap.containsKey(systemName)){
            systemCode = externalSystemMap.get(systemName);
        }
        return systemCode;
    }
    
    private static DateTime convertEpochToDateTime(Long epochDay) {
        return DateTime.newInstance(epochDay);
    }
    
    private static Map<String, Id> getCountryIds(Set<String> setCountries){
        Map<String, Id> mapCountryNameToId = new Map<String, Id>();
        for(Geography__c geo : [SELECT Id, Name FROM Geography__c
                                WHERE Type_Of_Location__c = 'Country' AND Active__c = true AND Name in :setCountries]){
                                    
                                    mapCountryNameToId.put(geo.Name.toUpperCase(), geo.Id);
                                }
        return mapCountryNameToId;
    }
    
    public static ConcernAccountWrapper parse(String json){
        return (ConcernAccountWrapper) System.JSON.deserialize(json, ConcernAccountWrapper.class);
    }
    public class ConcernAccountWrapper {
        public ConcernEntity concernEntity;
    }
    public class ConcernEntity {
        public String concernCode;
        public List<concernExternalSystemIdentifiers> concernExternalSystemIdentifiers;
        public String concernName;
        public String statusCode;
        public String isoCountryCode;
        public parentCustomerDetails parentCustomerDetails;
        public List<concernMembers> concernMembers;
        public ConcernAuditData concernAuditData;
    }
    public class concernExternalSystemIdentifiers {
        public String externalSystemName;
        public String externalSystemReference;
        public boolean isDeletedFlag;
    }
    public class parentCustomerDetails {
        public String customerCode;
        public String customerAlternateCode;
        public String customerName;
        public String customerStatusCode;
        public CustomerAddress customerAddress;
    }
    public class concernMembers {
        public String customerCode;
        public String customerAlternateCode;
        public String customerName;
        public String customerStatusCode;
        public String customerIsoCountryCode;
        public String relationshipType;
        public String relationshipTypeName;
        public boolean isDeletedFlag;
    }
    public class ConcernAuditData {
        public String creationUser;
        public Long creationDate;
        public String lastUpdateUser;
        public Long lastUpdateDate;
        public String lastUpdateSourceSystem;
    }
    public class CustomerAddress {
		public String streetNumber;
		public String streetName;
		public String poBoxNumber;
		public String apartmentOrFloor;
		public String subArea;
		public String district;
		public String cityName;
		public String cityCode;
		public Region region;
		public String postalCode;
		public String isoLanguageCode;
		public Country country;
		public String latitude;
		public String longitude;
	}
	public class Region {
		public String regionCode;
		public String regionName;
	}
	public class Country {
		public String isoCountryCode;
		public String countryName;
	}
    
}