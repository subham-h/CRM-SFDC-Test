/*  
* Version	Date			#Reference				Owner					Description
* --------	-----------		-------------------		-----------				---------------
* 1.0		06-Sep-2022		SFSE-8727				Kiran@maersk			To create Customer Accounts from CMD
* 1.1       26-Apr-2023     SFSE-10934              Kiran@Maersk            Concern Account updates
* 1.2		24-Apr-2023		SFSE-10870				Kiran@Maersk			Fix Duplicate external Id found error
* 2.0		28-Jun-2023		SFSE-11513				Kiran@Maersk			Removing logic to map Represent Concern value
* 2.1		22-Aug-2023		SFSE-12142				Kiran@Maersk			Removing logic to update concern name from CustomeEeventHandler since it will be handled from Concern message
* 2.2       22-feb-2024     SFSE-14203              Aleena@Maersk           Adding logic to map Sales Channel field
* 2.3       26-mar-2024     SFSE-14450              Aleena@Maersk           Adding Logic to map Customer Size field
*/

public with sharing class CustomerEventHandler extends TriggerHandler{
    
    public List<Customer_Message_Event__e> newCustomerMsg;
    public String jsonStr;
    public List<Account> accountsToUpsert;
    public Set<String> setCountries;
    public static Map<String, Id> mapCountryNameToId;
    private static Map<String, CustomerDetails> mapCustCodeToWrap;
    private static String custCode;
    private DateTime lastUpdatedDate;
    private DateTime lastUpdatedDatePrevious;
    
    public CustomerEventHandler() {
        this.newCustomerMsg = (List<Customer_Message_Event__e>) Trigger.new;
        accountsToUpsert = new List<Account>();
        setCountries = new Set<String>();
        mapCountryNameToId = new Map<String, Id>();
        mapCustCodeToWrap = new Map<String, CustomerDetails>();
    }
    
    public override void onAfterInsert() {
        CustomerDetails customerDetails;
        try{
            
            for(Customer_Message_Event__e customerMsg : newCustomerMsg){
                customerDetails = new CustomerDetails();
                if(customerMsg.JSON_1__c != '' && customerMsg.JSON_1__c != null)
                    jsonStr = customerMsg.JSON_1__c;
                if(customerMsg.JSON_2__c != '' && customerMsg.JSON_2__c != null)
                    jsonStr = jsonStr + customerMsg.JSON_2__c;
                if(customerMsg.JSON_3__c != '' && customerMsg.JSON_3__c != null)
                    jsonStr = jsonStr + customerMsg.JSON_3__c;
                if(customerMsg.JSON_4__c != '' && customerMsg.JSON_4__c != null)
                    jsonStr = jsonStr + customerMsg.JSON_4__c;
                if(customerMsg.JSON_5__c != '' && customerMsg.JSON_5__c != null)
                    jsonStr = jsonStr + customerMsg.JSON_5__c;
                if(customerMsg.JSON_6__c != '' && customerMsg.JSON_6__c != null)
                    jsonStr = jsonStr + customerMsg.JSON_6__c;
                if(jsonStr != null){
                    CustomerAccountWrapper jsonDeserialized = parse(jsonStr.replace('number','phoneNumber'));
                    if(jsonDeserialized.customerEntity != null && jsonDeserialized.customerEntity.customerDetails != null){
                        customerDetails = jsonDeserialized.customerEntity.customerDetails;    
                    }
                    if(customerDetails != null && customerDetails.customerCoreInformation != null &&
                       customerDetails.customerCoreInformation.customerAddress != null &&
                       customerDetails.customerCoreInformation.customerAddress.country != null && 
                       customerDetails.customerCoreInformation.customerAddress.country.countryName != null){
                           setCountries.add(customerDetails.customerCoreInformation.customerAddress.country.countryName);
                       }
                    custCode = customerDetails.customerCoreInformation.customerCode;
                    lastUpdatedDate = convertEpochToDateTime(customerDetails.customerAuditData.lastUpdateDate);
                    if(!mapCustCodeToWrap.containsKey(custCode)){
                        mapCustCodeToWrap.put(custCode, customerDetails);
                    }else{
                        lastUpdatedDatePrevious = convertEpochToDateTime(mapCustCodeToWrap.get(custCode).customerAuditData.lastUpdateDate);
                        if( lastUpdatedDate > lastUpdatedDatePrevious ){
                            mapCustCodeToWrap.put(custCode, customerDetails);
                        }
                    }
                    
                }
            }
            if(setCountries.size() > 0){
                mapCountryNameToId = getCountryIds(setCountries);
            }
            
            for(CustomerDetails customerDetail : mapCustCodeToWrap.values()){
                accountsToUpsert.add(customerAccountUpsert(customerDetail));
            }
            
            if(accountsToUpsert.size() > 0){
                Database.UpsertResult[] results = Database.upsert(accountsToUpsert, Account.Customer_Code__c, false);
                ErrorLogger.writeErrors('CMD', 'Customer Message', 'CustomerEventHandler.onAfterInsert '+custCode, results, accountsToUpsert);
            }
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
            ErrorLogger.writeErrors( 'CMD', 'Customer Message', 'CustomerEventHandler.onAfterInsert '+custCode, new list<Exception>{ex});
        }
    }
    
    public static CustomerAccountWrapper parse(String json){
        return (CustomerAccountWrapper) System.JSON.deserialize(json, CustomerAccountWrapper.class);
    }
    
    public static Account customerAccountUpsert(CustomerDetails customerDetails){
        
        CustomerCoreInformation customerCoreInfo = customerDetails.customerCoreInformation != null ? customerDetails.customerCoreInformation : new CustomerCoreInformation();
        CustomerExtendedInformation customerExtendedInfo = customerDetails.customerExtendedInformation != null ? customerDetails.customerExtendedInformation : new CustomerExtendedInformation();
        CustomerEnrichedInformation customerEnrichedInfo = customerDetails.customerEnrichedInformation != null ? customerDetails.customerEnrichedInformation : new CustomerEnrichedInformation();
        CustomerRelationship customerRelationship = customerDetails.customerRelationships != null && customerDetails.customerRelationships.size() > 0  ? getCustomerRelationships(customerDetails.customerRelationships) : new CustomerRelationship();
        List<CustomerIdentifier> customerIdentifiers = (customerDetails.customerIdentifiers != null && customerDetails.customerIdentifiers.size() > 0) ? customerDetails.customerIdentifiers : new List<CustomerIdentifier>();
        List<CustomerSegments> customerSegments = (customerDetails.customerSegments != null && customerDetails.customerSegments.size() > 0) ? customerDetails.customerSegments : new List<CustomerSegments>();
        Map<String, String> externalSystemMap = getExternalIdentifiers(customerCoreInfo);
        Map<String, String> customerIdentifiersMap = getCustomerIdentifiers(customerIdentifiers);
        Map<String, String> segmentClassificationMap = getSegmentClassification(customerSegments);
        String attractiveness;
        CustomerAddress customerAddress = customerCoreInfo.customerAddress != null ? customerCoreInfo.customerAddress : new CustomerAddress();
        
        Account customerAcc = new Account();
        
        customerAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        if(customerCoreInfo.customerType == 'ZEXC'){
            customerAcc.Customer_Type__c = 'External';
        }else if(customerCoreInfo.customerType == 'ZICC'){
            customerAcc.Customer_Type__c = 'Internal';
        }
        customerAcc.Customer_Code__c = customerCoreInfo.customerCode;
        customerAcc.Customer_Group__c = customerExtendedInfo.customerGroupType != null ? customerExtendedInfo.customerGroupType : '';
        customerAcc.SCV_Code__c = getExternalSystemCode('SCV', externalSystemMap);
        customerAcc.Legal_Name__c = customerCoreInfo.legalName;
        customerAcc.Name = customerCoreInfo.tradingName;
        customerAcc.Website = customerCoreInfo.url;
        if(customerCoreInfo.telecommunicationNumber != null && customerCoreInfo.telecommunicationNumber.phoneNumberType == 'TEL' && 
           customerCoreInfo.telecommunicationNumber.internationalDialingCode != null && 
           customerCoreInfo.telecommunicationNumber.phoneNumber != null ){
               customerAcc.Phone = '+'+customerCoreInfo.telecommunicationNumber.internationalDialingCode+' '+customerCoreInfo.telecommunicationNumber.phoneNumber;
           }
        if(customerCoreInfo.telecommunicationNumber != null && customerCoreInfo.telecommunicationNumber.phoneNumberType == 'MOB' && 
           customerCoreInfo.telecommunicationNumber.internationalDialingCode != null && 
           customerCoreInfo.telecommunicationNumber.phoneNumber != null ){
               customerAcc.Phone = '+'+customerCoreInfo.telecommunicationNumber.internationalDialingCode+' '+customerCoreInfo.telecommunicationNumber.phoneNumber;   
           }
        
        if(mapCountryNameToId.containsKey(customerAddress.country.countryName)){
            customerAcc.Country__c = mapCountryNameToId.get(customerAddress.country.countryName);
        }
        
        String streetNumber = '';
        if(customerAddress.streetNumber != null && customerAddress.streetNumber != ''){
            streetNumber = customerAddress.streetNumber;
        }
        
        customerAcc.BillingStreet = streetNumber + ' ' + customerAddress.streetName;
        customerAcc.BillingState = customerAddress.region.regionName;
        customerAcc.BillingCity = customerAddress.cityName;
        customerAcc.BillingCountry = customerAddress.country.countryName;
        customerAcc.BillingPostalCode = customerAddress.postalCode;
        customerAcc.Credit_Rating__c = customerEnrichedInfo.creditRating;
        customerAcc.Recommended_Credit_Limit__c = convertToDecimal(customerEnrichedInfo.recommendedCreditLimit);
        customerAcc.BvD_ID__c = getCustomerIdentifierId('BVD_ID', customerIdentifiersMap);
        customerAcc.GUO_BvD_ID__c = getCustomerIdentifierId('BVD_GUO', customerIdentifiersMap);
        customerAcc.HQ_BvD_ID__c = getCustomerIdentifierId('BVD_HQ', customerIdentifiersMap);
        customerAcc.Major_Sector__c = customerEnrichedInfo.majorSector;
        customerAcc.Market_Cap__c = convertToDecimal(customerEnrichedInfo.marketCap);
        customerAcc.Operating_Revenue_Turn_Over__c = convertToDecimal(customerEnrichedInfo.operatingRevenueTurnOver);
        if(customerEnrichedInfo.dateOfAccount != null && customerEnrichedInfo.dateOfAccount != ''){
            customerAcc.Annual_Filing_Date__c = convertEpochDays(customerEnrichedInfo.dateOfAccount);
        }
        customerAcc.Profit_Margin__c = convertToDecimal(customerEnrichedInfo.profitMarginPercentage);
        if(customerCoreInfo.customerStatus != null){
            customerAcc.SCV_Status__c = customerCoreInfo.customerStatus.statusName;
            if(customerCoreInfo.customerStatus.customerStatusReasons != null && customerCoreInfo.customerStatus.customerStatusReasons.size() > 0){
                customerAcc.Customer_Status_Reason__c = customerCoreInfo.customerStatus.customerStatusReasons[0].reasonName;
            }else{
                customerAcc.Customer_Status_Reason__c = '';
            }
        }
        customerAcc.Damco_BE_Code__c = getExternalSystemCode('MODS', externalSystemMap);
        if(customerRelationship.relationshipType == Label.Relationship_Master_Dup && !customerRelationship.isDeletedFlag){
            customerAcc.Master_Duplicate_Customer_Code__c = customerRelationship.childCustomerCode;
        }else{
            customerAcc.Master_Duplicate_Customer_Code__c = null;
        }
        customerAcc.Customer_Role__c = getSegmentClassificationValue('CUST', segmentClassificationMap);
        customerAcc.Industry__c = getSegmentClassificationValue('INDU', segmentClassificationMap);
        customerAcc.Value_Proposition__c = getSegmentClassificationValue('VALP', segmentClassificationMap);
        customerAcc.Vertical__c = getSegmentClassificationValue('VERT', segmentClassificationMap);
        attractiveness = getSegmentClassificationValue('SERV', segmentClassificationMap);
        if(attractiveness != null && attractiveness != ''){
            customerAcc.Attractiveness__c = system.label.MSL != '-MSL' ?attractiveness : attractiveness+ system.label.MSL;
        }else{
            customerAcc.Attractiveness__c = '';
        }
        customerAcc.Sub_Segment__c = getSegmentClassificationValue('EFCY', segmentClassificationMap);
        customerAcc.Rolling_Protection__c = getSegmentClassificationValue('ROLP', segmentClassificationMap);
        customerAcc.Customer_Manifest__c = getSegmentClassificationValue('CUSM', segmentClassificationMap);
        customerAcc.Sales_Channel__c = getSegmentClassificationValue('SALC', segmentClassificationMap);
       // customerAcc.Customer_Size__c = getSegmentClassificationValue('CUSI',segmentClassificationMap);
        //customerAcc.Service_Package__c = '';
        //customerAcc.Non_Profit_Customer__c = '';
        
        //SFSE-12142
        /*if((customerRelationship.relationshipType == Label.Relationship_Is_Concern || customerRelationship.relationshipType == Label.Relationship_Concern_Member  ) && !customerRelationship.isDeletedFlag ){
Account parentAcc = new Account(Customer_Code__c=customerRelationship.childCustomerCode);
customerAcc.Parent = parentAcc;
}else{
customerAcc.parentId = null;
}*/
        
        //SFSE-11513 Removing logic to update Represent concern from customer message event.
        /*if(customerRelationship.relationshipType == Label.Relationship_Is_Concern && !customerRelationship.isDeletedFlag ){
customerAcc.Represents_Concern__c = true;
}else{
customerAcc.Represents_Concern__c = false;
}*/
        customerAcc.Business_Partner_Number__c = getExternalSystemCode('BPMA', externalSystemMap);
        return customerAcc;
    }
    
    private static Map<String, String> getExternalIdentifiers(CustomerCoreInformation customerCoreInfo){
        Map<String, String> externalSystemMap = new Map<String, String>();
        if(customerCoreInfo.externalSystemIdentifiers != null && customerCoreInfo.externalSystemIdentifiers.size() > 0){
            for(ExternalSystemIdentifiers identifier : customerCoreInfo.externalSystemIdentifiers){
                if(!identifier.isDeletedFlag){
                    externalSystemMap.put(identifier.externalSystemName, identifier.externalSystemReference);
                }
            }
        }
        return externalSystemMap;
    }
    
    private static Map<String, Id> getCountryIds(Set<String> setCountries){
        Map<String, Id> mapCountryNameToId = new Map<String, Id>();
        for(Geography__c geo : [SELECT Id, Name FROM Geography__c
                                WHERE Type_Of_Location__c = 'Country' AND Active__c = true AND Name in :setCountries]){
                                    
                                    mapCountryNameToId.put(geo.Name.toUpperCase(), geo.Id);
                                }
        return mapCountryNameToId;
    }
    
    private static Map<String, String> getCustomerIdentifiers(List<CustomerIdentifier> customerIdentifiers){
        Map<String, String> customerIdentifiersMap = new Map<String, String>();
        for(CustomerIdentifier identifier : customerIdentifiers){
            if(!identifier.isDeletedFlag){
                customerIdentifiersMap.put(identifier.identifierCode , identifier.identifierValue);
            }
        }
        return customerIdentifiersMap;
    }
    
    private static Map<String, String> getSegmentClassification(List<CustomerSegments> customerSegments){
        Map<String, String> segmentClassificationMap = new Map<String, String>();
        List<CustomerSegments> segmentClassifications = new List<CustomerSegments>();
        for(CustomerSegments segment : customerSegments){
            if(segment.segmentBrandInformation != null && segment.segmentBrandInformation.brandName == BrandUtilities.MAERSKLINE &&
               segment.segmentClassifications != null && segment.segmentClassifications.size() > 0 && !segment.isDeletedFlag){
                   segmentClassificationMap.put(segment.segmentClassifications[0].segmentTypeCode, segment.segmentClassifications[0].segmentValueName);
               }
        }
        return segmentClassificationMap;
    }
    
    private static String getSegmentClassificationValue(String segTypeCode, Map<String, String> segmentClassificationMap){
        String segmentValueName;
         if(segmentClassificationMap.containsKey(segTypeCode)){
            segmentValueName = segmentClassificationMap.get(segTypeCode);
        }
        return segmentValueName;
    }
    
    private static String getExternalSystemCode(String systemName, Map<String, String> externalSystemMap){
        String systemCode;
        if(externalSystemMap.containsKey(systemName)){
            systemCode = externalSystemMap.get(systemName);
        }
        return systemCode;
    }
    
    private static String getCustomerIdentifierId(String custIdentifierCode, Map<String, String> customerIdentifiersMap){
        String custIdentifierVal;
        if(customerIdentifiersMap.containsKey(custIdentifierCode)){
            custIdentifierVal = customerIdentifiersMap.get(custIdentifierCode);
        }
        return custIdentifierVal;
    }
    
    private static CustomerRelationship getCustomerRelationships(List<CustomerRelationship> customerRelationships){
        CustomerRelationship masterDupRelationship = new CustomerRelationship();        
        for(CustomerRelationship custRelation : customerRelationships){
            if(!custRelation.isDeletedFlag && custRelation.relationshipType == Label.Relationship_Master_Dup){
                masterDupRelationship = custRelation;
                break;
            }
        }
        System.debug('masterDupRelationship '+masterDupRelationship);
        return masterDupRelationship;
    }
    
    private static Date convertEpochDays(String epochDays) {
        Long l = Long.valueOf(epochDays);
        DateTime dt = DateTime.newInstance(l);
        Date sfDate = Date.newInstance(dt.year(), dt.month(), dt.day());
        return sfDate;
    }
    
    private static DateTime convertEpochToDateTime(Long epochDay) {
        return DateTime.newInstance(epochDay);
    }
    
    private static Decimal convertToDecimal(String val){
        Decimal decVal;
        if(val != null && val != ''){
            decVal = Decimal.valueOf(val);
        }
        return decVal;
    }
    
    public class CustomerAccountWrapper{
        public CustomerEntity customerEntity;
    }
    public class CustomerEntity {
        public CustomerDetails customerDetails;
    }
    public class CustomerDetails {
        public CustomerCoreInformation customerCoreInformation;
        public CustomerExtendedInformation customerExtendedInformation;
        public CustomerIdentifier[] customerIdentifiers;
        public CustomerEnrichedInformation customerEnrichedInformation;
        public CustomerRelationship[] customerRelationships;
        public CustomerSegments[] customerSegments;
        public CustomerAuditData customerAuditData;
        
    }
    public class CustomerCoreInformation {
        public String customerCode;
        public ExternalSystemIdentifiers[] externalSystemIdentifiers;
        public String legalName;
        public String tradingName;
        public String customerType;
        public String url;
        public boolean isSoleProprietor;
        public boolean isWorkflowPending;
        public WorkflowInformation workflowInformation;
        public CustomerStatus customerStatus;
        public TelecommunicationNumber telecommunicationNumber;
        public Brands[] brands;
        public CustomerAddress customerAddress;
    }
    public class ExternalSystemIdentifiers {
        public String externalSystemName;
        public String externalSystemReference;
        public boolean isDeletedFlag;
    }
    public class WorkflowInformation {
    }
    public class CustomerStatus {
        public String statusCode;
        public String statusName;
        public CustomerStatusReasons[] customerStatusReasons;
    }
    public class CustomerStatusReasons {
        public Integer reasonCode;
        public String reasonName;
        public String reasonDescription;
    }
    public class TelecommunicationNumber {
        public String phoneNumberType;
        public PhoneCountry phoneCountry;
        public String internationalDialingCode;
        public String phoneNumber;
        public Integer extensionNumber;
        public boolean isDeletedFlag;
    }
    public class PhoneCountry {
        public String countryName;
        public String isoCountryCode;
    }
    public class Brands {
        public String brandCode;
        public String brandName;
        public boolean isDeletedFlag;
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
    public class CustomerExtendedInformation{
        public String customerGroupType;
        public String invoiceISOLanguageCodePreference;
        public Boolean isBrokerage;
        public Boolean isForwardersCompensation;
        public String vipNonRoll;
    }
    public class CustomerEnrichedInformation{
        public String marketCap;
        public String majorSector;
        public String operatingRevenueTurnOver;
        public String dateOfAccount;
        public String profitMarginPercentage;
        public String creditRating;
        public String recommendedCreditLimit;
    }
    public class CustomerRelationship{
        public String parentCustomerCode;
        public String parentCustomerName;
        public String childCustomerCode;
        public String childCustomerName;
        public String relationshipType;
        public Boolean isDeletedFlag;
    }
    public class CustomerIdentifier{
        public String identifierType;
        public String identifierCode;
        public String identifierValue;        
        public Boolean isDeletedFlag;        
    }
    public class CustomerSegments{
        public SegmentBrandInformation segmentBrandInformation;
        public SegmentClassifications[] segmentClassifications;
        public Boolean isDeletedFlag;
    }
    public class SegmentBrandInformation{
        public String brandCode;
        public String brandName;
    }
    public class SegmentClassifications{
        public String segmentTypeCode;
        public String segmentValueCode;
        public String segmentValueName;
        public String segmentValueDescription;
    }
    public class CustomerAuditData {
        public String creationUser;
        public Long creationDate;
        public String lastUpdateUser;
        public Long lastUpdateDate;
        public String lastUpdateSourceSystem;
    }
    
}