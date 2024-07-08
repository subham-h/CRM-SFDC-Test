/*  
* Version   Date            #Ref                    Owner                   Description
* --------  -----------     -------------------     -----------             ---------------
* 1.0       06-MAR-2023                             Sowmya@maersk           To create Contacts from CMD
* 2.0       08-May-2023     SFSE-10873              Samar@Maersk            Duplicates detected fix
* 2.1       08-May-2023     SFSE-10910              Samar@Maersk            Brand population
* 2.2       23-Jan-2024     SFSE-13939              kusum@Maersk            Commented to fix to stop syncing of job role field to CMD
* 2.3       31-Jan-2024     SC-9422                 Shahanawaz@Maersk       Populating the Customer Contact Country Field
* 2.4       13-Jun-2024     SFMC-7706               Ranjan@maersk           Consume Contact SCV code values from CMD
*/
public with sharing class ContactEventHandler extends TriggerHandler{
    
    public List<Contact_Message_Event__e> newContactMsg;
    public String jsonStr;
    public List<Contact> contactsToUpsert;
    public List<Contact> contactsToUpdate;
    private static Map<String, customerContact> mapContactCode;
    public static Set<String> setForPrimaryEmail;
    public static Set<String> setforExternalId;
    public static Map<String,Contact> mapOfExistingContact;
    public static Map<String,Contact> mapOfExistingContactExternalId;
    
    public ContactEventHandler() {
        this.newContactMsg = (List<Contact_Message_Event__e>) Trigger.new;
        contactsToUpsert = new List<Contact>();
        contactsToUpdate = new List<Contact>();
        mapContactCode = new Map<String, customerContact>();
        setForPrimaryEmail = new Set<String>();
        setforExternalId = new Set<String>(); 
        mapOfExistingContact = new Map<String,Contact>();
        mapOfExistingContactExternalId = new Map<String,Contact>();
        
    }
    public override void  onAfterInsert() {
        try{
            CustomerContact customerContact;
            String contactcode;
            DateTime lastUpdatedDate;
            DateTime lastUpdatedDatePrevious;
            for(Contact_Message_Event__e contactMsg : newContactMsg){
                if(contactMsg.JSON_1__c != '' && contactMsg.JSON_1__c != null)
                    jsonStr = contactMsg.JSON_1__c;
                if(contactMsg.JSON_2__c != '' && contactMsg.JSON_2__c != null)
                    jsonStr = jsonStr + contactMsg.JSON_2__c;
                if(contactMsg.JSON_3__c != '' && contactMsg.JSON_3__c != null)
                    jsonStr = jsonStr + contactMsg.JSON_3__c;
                if(contactMsg.JSON_4__c != '' && contactMsg.JSON_4__c != null)
                    jsonStr = jsonStr + contactMsg.JSON_4__c;
                if(jsonStr != null){
                    ContactWrapper jsonDeserialized = parse(jsonStr.replace('number','pnumber'));
                    if(jsonDeserialized.contactEntity != null && jsonDeserialized.contactEntity.customerContact != null){
                        customerContact = jsonDeserialized.contactEntity.customerContact;
                        //Adding Email and last name  
                        setForPrimaryEmail.add(customerContact.primaryEmailId);
                        setforExternalId.add(customerContact.contactCode);
                        // checking and adding recent modified contact
                        contactcode = customerContact.contactCode;
                        lastUpdatedDate = convertEpochToDateTime(customerContact.contactAuditData.lastUpdateDate);
                        if(!mapContactCode.containsKey(contactcode)){
                            mapContactCode.put(contactcode, customerContact);
                        }else{
                            lastUpdatedDatePrevious = convertEpochToDateTime(mapContactCode.get(contactcode).contactAuditData.lastUpdateDate);
                            if( lastUpdatedDate > lastUpdatedDatePrevious ){
                                mapContactCode.put(contactcode, customerContact);
                            }
                        }
                    }
                }   
            }
            // Query all the contact with email address in event
            getExistingContact(setForPrimaryEmail);
            
            //SC-9422
            Map<String, String> telephoneMap = new Map<String, String>();
            Map<String, Account> accMap = getAccountMapFromCustomerCode(mapContactCode.values());
            Map<String, Map<String, CommunicationNumbers>> comTypeToComNumberMap = getConCodeToNumberMap(mapContactCode.values(), telephoneMap);
            Map<String, Geography__c> geoMap = getGeoMap(telephoneMap.values());
            
            for(CustomerContact custContact : mapContactCode.values()){
                if(mapOfExistingContact.containsKey(custContact.primaryEmailId) || mapOfExistingContactExternalId.containskey(custContact.contactCode)){
                    contactsToUpdate.add(upsertContacts(custContact, accMap, comTypeToComNumberMap, telephoneMap, geoMap));
                }else{
                    contactsToUpsert.add(upsertContacts(custContact, accMap, comTypeToComNumberMap, telephoneMap, geoMap));
                }
            }
            if(contactsToUpsert.size() > 0){
                Database.UpsertResult[] results = Database.upsert(contactsToUpsert,Contact.External_ID__c, false);
                ErrorLogger.writeErrors('CMD', 'Contact Message', 'ContactEventHandler.onAfterInsert', results, contactsToUpsert);
            }
            if(contactsToUpdate.size() > 0){
                Database.UpsertResult[] results = Database.upsert(contactsToUpdate, false);
                ErrorLogger.writeErrors('CMD', 'Contact Message', 'ContactEventHandler.onAfterInsert', results, contactsToUpdate);
            }
        }catch(Exception ex){
            //Rertrying the platform event since it got failed
            ErrorLogger.writeErrors( 'CMD', 'Contact Message Event', 'ContactEventHandler.onAfterInsert', new list<Exception>{ex});
        }
    }
    
    public static Contact upsertContacts(CustomerContact customerContacts, Map<String, Account> accMap, Map<String, Map<String, CommunicationNumbers>> comTypeToComNumberMap, Map<String, String> telephoneMap, Map<String, Geography__c> geoMap){
        Map<String,String> mapContactType = new Map<String,String>();
        mapContactType.put('COMMERCIAL','Commercial');
        /*mapContactType.put('EDI BUSINESS','EDI Business');
        mapContactType.put('EDI TECHNICAL','EDI Technical'); */
        mapContactType.put('FINANCE','Finance');

        mapContactType.put('PORTAL','Portal');
        Contact newcustomerContact = new Contact();
        // Adding Customer Contact recordtype      
        if(mapOfExistingContact.containsKey(customerContacts.primaryEmailId) ){
            newcustomerContact.Id = mapOfExistingContact.get(customerContacts.primaryEmailId).Id;
        }
        else if( mapOfExistingContactExternalId.containskey(customerContacts.contactCode)){
            newcustomerContact.Id = mapOfExistingContactExternalId.get(customerContacts.contactCode).Id;
        }
        newcustomerContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
        newcustomerContact.External_ID__c = customerContacts.contactCode;
        newcustomerContact.Unique_Email_Address__c = customerContacts.primaryEmailId;
        newcustomerContact.Email = customerContacts.primaryEmailId;
        if(customerContacts.statusCode == 'A'){
            newcustomerContact.Contact_Status__c = 'Active';  
        }else if(customerContacts.statusCode == 'I'){
            newcustomerContact.Contact_Status__c = 'Inactive';    
        }else {
            newcustomerContact.Contact_Status__c = null;  
        }
        
        newcustomerContact.FirstName = customerContacts.firstName;
        newcustomerContact.LastName = customerContacts.lastName;
        newcustomerContact.Salutation = (String)customerContacts.primarySalutationCode;
        newcustomerContact.Title = customerContacts.jobTitle;
        newcustomerContact.Team_Contact__c = (customerContacts.isTeamContact?'Yes':'No');
        newcustomerContact.Department = (String)customerContacts.department;
        newcustomerContact.Preferred_Language__c = PreferedLanguageMapCtrl.mapOfisoLanguageCode.get(customerContacts.isoLanguageCodePreference);
        //newcustomerContact.External_ID__c = customerContacts.contactCode;
        newcustomerContact.Duplicate_Email__c = customerContacts.secondaryEmailId;
        if(customerContacts.contactTypes != null){
            String tempContactType;
            for(Integer i=0; i<customerContacts.contactTypes.size();i++){
                if(customerContacts.contactTypes[i] != null && customerContacts.contactTypes[i].isDeletedFlag == false && mapContactType.containsKey(customerContacts.contactTypes[i].typeName)){
                    tempContactType = tempContactType == null ? (mapContactType.get(customerContacts.contactTypes[i].typeName)+';') :(tempContactType + mapContactType.get(customerContacts.contactTypes[i].typeName)+';') ;
                        }                   
            }               
            newcustomerContact.Contact_Type__c  = tempContactType;            
        }
        
        Set<String> setBrandName = new Set<String>();
        Set<String> selectedBrand= new Set<String>();

        if(mapOfExistingContact.containsKey(customerContacts.primaryEmailId) && mapOfExistingContact.get(customerContacts.primaryEmailId).Liner_Brands__c !=null){
            selectedBrand.addAll(mapOfExistingContact.get(customerContacts.primaryEmailId).Liner_Brands__c.split(';'));          
        }else if(mapOfExistingContactExternalId.containskey(customerContacts.contactCode) && mapOfExistingContactExternalId.get(customerContacts.contactCode).Liner_Brands__c!= null ){
            selectedBrand.addAll(mapOfExistingContactExternalId.get(customerContacts.contactCode).Liner_Brands__c.split(';'));
        }
      
        if(!selectedBrand.isEmpty() && (selectedBrand.contains(BrandUtilities.SEAGO) || selectedBrand.contains(BrandUtilities.MCC)  || selectedBrand.contains(BrandUtilities.SEALAND)) ){
            selectedBrand.add(BrandUtilities.MAERSKLINE);
        }
    
        if(customerContacts.contactBrands == null){
            newcustomerContact.Liner_Brands__c = (!selectedBrand.isEmpty()) ? selectedBrand.toString().replace(',',';').replace('{','').replace('}','') : BrandUtilities.MAERSKLINE;
        }
        else{
            for(Integer i=0; i<customerContacts.contactBrands.size();i++){
                if(customerContacts.contactBrands[i] !=null && customerContacts.contactBrands[i].brandName != null && customerContacts.contactBrands[i].isDeletedFlag == false){
                    setBrandName.add(customerContacts.contactBrands[i].brandName);
                }
                if(customerContacts.contactBrands[i] !=null && customerContacts.contactBrands[i].brandName != null && customerContacts.contactBrands[i].isDeletedFlag == true){
                   if(selectedBrand.contains(customerContacts.contactBrands[i].brandName) ) {
                        selectedBrand.remove(customerContacts.contactBrands[i].brandName);
                   }
                }   
            }
            for(string brand : setBrandName){
                if(!BrandUtilities.getAllBrandsList().contains(brand) ){
                    selectedBrand.add(BrandUtilities.MAERSKLINE);
                }
                else if(brand == BrandUtilities.HAMBURGSUD ){  
                    selectedBrand.add(BrandUtilities.MAERSKLINE);
                    selectedBrand.add(BrandUtilities.HAMBURGSUD);
                }else if(brand == BrandUtilities.MAERSKLINE){
                    selectedBrand.add(BrandUtilities.MAERSKLINE);
                }else{
                    selectedBrand.add(brand);
                }   
            } 
            newcustomerContact.Liner_Brands__c = (!selectedBrand.isEmpty()) ? selectedBrand.toString().replace(',',';').replace('{','').replace('}','') : BrandUtilities.MAERSKLINE ;
        } 
        
        //SC-9422
        if(customerContacts.communicationNumbers != null && !comTypeToComNumberMap.isEmpty() && comTypeToComNumberMap.containsKey(customerContacts.ContactCode)){
            Map<String, CommunicationNumbers> comNumberMap = comTypeToComNumberMap.get(customerContacts.ContactCode);
            if(comNumberMap.containsKey('TEL')){
                newcustomerContact.Phone = '+'+comNumberMap.get('TEL').internationalDialingCode+' '+comNumberMap.get('TEL').pnumber;
                newcustomerContact.Extension_Number__c = String.valueOf(comNumberMap.get('TEL').extensionNumber);
            }
            if(comNumberMap.containsKey('MOB')){
                newcustomerContact.MobilePhone = '+'+comNumberMap.get('MOB').internationalDialingCode+' '+comNumberMap.get('MOB').pnumber;
            }
            if(comNumberMap.containsKey('FAX')){
                newcustomerContact.Fax = '+'+comNumberMap.get('FAX').internationalDialingCode+' '+comNumberMap.get('FAX').pnumber;
            }
        }
                        
        //SC-9422
        if(newcustomerContact.Id == null && !telephoneMap.isEmpty() && !geoMap.isEmpty() && telephoneMap.containsKey(customerContacts.ContactCode) && !String.isBlank(telephoneMap.get(customerContacts.ContactCode)) && geoMap.containsKey(telephoneMap.get(customerContacts.ContactCode))){
           newcustomerContact.Country__c = geoMap.get(telephoneMap.get(customerContacts.ContactCode)).Id;
                   }                
        //SC-9422
        if(!accMap.isEmpty() && customerContacts.customerIds != null && !String.isBlank(customerContacts.customerIds.customerCode) && accMap.containsKey(customerContacts.customerIds.customerCode)){
            newcustomerContact.AccountId = accMap.get(customerContacts.customerIds.customerCode).Id;
            if(newcustomerContact.Id == null && newcustomerContact.Country__c == null){
                newcustomerContact.Country__c = accMap.get(customerContacts.customerIds.customerCode).Country__c;
            }
        }else if(accMap.isEmpty() && customerContacts.customerIds != null && !String.isBlank(customerContacts.customerIds.customerCode)){
          newcustomerContact.Customer_Code__c = customerContacts.customerIds.customerCode;
          newcustomerContact.Contact_Status__c = 'Inactive';
        }
        if(customerContacts.customerIds != null && 
            customerContacts.customerIds.customerExternalSystemIdentifiers!=null && 
            !customerContacts.customerIds.customerExternalSystemIdentifiers.isEmpty())
        {
            for(CustomerExternalSystemIdentifiers cesObj:customerContacts.customerIds.customerExternalSystemIdentifiers){
                if('SCV'.equalsIgnoreCase(cesObj.externalSystemName)){
                    newcustomerContact.SCV_Code__c=cesObj.externalSystemReference;
                }
            }
        }
        return newcustomerContact;       
    }
        
    //SC-9422
    private static Map<String, Map<String, CommunicationNumbers>> getConCodeToNumberMap(List<CustomerContact> custContactList, Map<String, String> telephoneMap){
        Map<String, Map<String, CommunicationNumbers>> comTypeToComNumberMap = new Map<String, Map<String, CommunicationNumbers>>();
        for(CustomerContact con : custContactList){
            if(con.communicationNumbers != null){
                comTypeToComNumberMap.put(con.ContactCode, getCommunicationNumbersMap(con.communicationNumbers, con.ContactCode, telephoneMap));
            }
        }
        return comTypeToComNumberMap;
    }
    
    private static Map<String, CommunicationNumbers> getCommunicationNumbersMap(List<CommunicationNumbers> comNumbersList, String contactCode, Map<String, String> telephoneMap){
        Map<String, CommunicationNumbers> comTypeToComNumberMap = new Map<String, CommunicationNumbers>();
        for(Integer i=0; i < comNumbersList.size(); i++){
            if(comNumbersList[i] != null && comNumbersList[i].internationalDialingCode != null && comNumbersList[i].pnumber != null){
                comTypeToComNumberMap.put(comNumbersList[i].communicationNumberType, comNumbersList[i]);
                if(comNumbersList[i].communicationNumberType == 'TEL'){
                    telephoneMap.put(contactCode, comNumbersList[i].isoCountryCode);
                }
            }                
        }
        return comTypeToComNumberMap;
    }
    
    //SC-9422
    private static Map<String, Account> getAccountMapFromCustomerCode(List<CustomerContact> custContactList){
        Map<String, Account> accMap = new Map<String, Account>();
        Set<String> custCodeSet = new Set<String>();
        for(CustomerContact con : custContactList){
            if(con.customerIds.customerCode != null){
                custCodeSet.add(con.customerIds.customerCode);
            }
        }
        if(!custCodeSet.isEmpty()){
            for(Account acc : [Select Id, Customer_Code__c, Country__c From Account Where Customer_Code__c != null AND Customer_Code__c =: custCodeSet]){
                accMap.put(acc.Customer_Code__c, acc);
            }
        }
        return accMap;
    }
    
    //SC-9422
    private static Map<String, Geography__c> getGeoMap(List<String> geoCodes){
        Map<String, Geography__c> geoCodeToGeoMap = new Map<String, Geography__c>();
        if(!geoCodes.isEmpty()){
            for(Geography__c geo : [Select Id, GEO_Code__c From Geography__c Where Type_Of_Location__c = 'Country' AND GEO_Code__c != null AND GEO_Code__c =: geoCodes]){
                geoCodeToGeoMap.put(geo.GEO_Code__c, geo);
            }
        }
        return geoCodeToGeoMap;
    }
    
    public static void getExistingContact(Set<String> emails){
        for(Contact c: [SELECT id,External_ID__c,Email, lastName,Liner_Brands__c FROM Contact WHERE Email IN : emails OR External_ID__c IN: setforExternalId]){
            if(!mapOfExistingContact.containskey(c.Email)){
                mapOfExistingContact.put(c.Email, c);
            }
            if(c.External_ID__c != null && !mapOfExistingContact.containskey(c.External_ID__c)){
                mapOfExistingContactExternalId.put(c.External_ID__c, c);
            }
        }
    }
    
    public static ContactWrapper parse(String json){
        return (ContactWrapper) System.JSON.deserialize(json, ContactWrapper.class);
    }
    
    private static DateTime convertEpochToDateTime(Long epochDay) {
        return DateTime.newInstance(epochDay);
    }
    
    public class ContactWrapper {
        public ContactEntity contactEntity;
    }
    public class ContactEntity {
        public CustomerContact customerContact;
    }
    public class CustomerContact {
        public CustomerIds customerIds;
        public String contactCode;
        public List<ContactExternalSystemIdentifiers> contactExternalSystemIdentifiers;
        public String firstName;
        public String lastName;
        public Boolean isMasterContact;
        public String internationalFirstName;
        public String internationalLastName;
        public String primaryEmailId;
        public String secondaryEmailId;
        public String statusCode;
        public String internationalSalutationCode;
        public String primarySalutationCode;
        public Boolean isTeamContact;
        public String jobTitle;
        public String department;
        public String role;
        public String isoLanguageCodePreference;
        public CommunicationNumbers[] communicationNumbers;
        public ContactBrands[] contactBrands;
        public ContactTypes[] contactTypes;
        public List<DocumentPreferences> documentPreferences;
        //public String onBehalfOfRelationships;
        public ContactAuditData contactAuditData;
    }
    public class DocumentPreferences{
        public string customerCode;
        public string brandCode;
        public string documentTypeCode;
        public List<CommunicationPreferences> communicationPreferences;
    }
    public class CustomerIds {
        public String customerCode;
        public String customerTradingName;
        public CustomerExternalSystemIdentifiers[] customerExternalSystemIdentifiers;
    }
    public class ContactTypes {
        public String typeName ; 
        public String typeCode;
        public Boolean isDeletedFlag;
    }
    public class CustomerExternalSystemIdentifiers {
        public String externalSystemName;
        public String externalSystemReference;
        public Boolean isDeletedFlag;
    }
    public class ContactExternalSystemIdentifiers {
        public String externalSystemName;
        public String externalSystemReference;
        public Boolean isDeletedFlag;
    }
    public class CommunicationNumbers {
        public String communicationNumberType;
        public String isoCountryCode;
        public String internationalDialingCode;
        public Integer extensionNumber;
        public Long pnumber;
    }
    public class CommunicationPreferences {
        public String preferenceMediaType;
        public String preferenceValue;
        public Boolean isDeletedFlag;
    }
    
    public class ContactBrands {
        public String brandName;
        public String brandCode;
        public Boolean isDeletedFlag;       
        
    }    
    public class ContactAuditData {
        public String creationUser;
        public Long creationDate;
        public String lastUpdateUser;
        public Long lastUpdateDate;
        public String lastUpdateSourceSystem;
    }
}