/*
* Author   : Ragu
* Purpose  : Utility class to hold simple and reusable functionalities for auto populating Contact fields. 
 *        
 * Revision Ref Number  Date        Owner                                           Description
* -------- ----------  ----------- -------------------                              -----------
* 1.0      RQ-003245   12-Apr-2016 Sunu.Paul@ust-global.com                     Created for implementing CBO (Centralized By Org) trigger architecture.
* 2.0                              Madhava.kotte@ust-global.com
* 3.0      RQ-004156   25-Jul-2016 Jiji@UST                                     Update Liner Brand from Lead During Lead Conversion
* 4.0      RQ-004057   11-Aug-2016 Jiji@UST                                     Remove Survey me field
* 5.0      RQ-004319   19-Aug-2016 Jiji@UST                                     Remove Primary contact concept in contact and account
* 6.0      RQ-004366   13-Dec-2016 Ranjini@UST                                  Logics to keep Community users in Sync with the contact record.
* 7.0      RQ-004708   6-Feb-2017  Hitha@UST                                    Logics to prevent deletion of Customer Contacts
* 8.0      RQ-005407   6-June-2017 Ranjini@ust                                  Added null check for email.
* 9.0                  8-Feb-2018  Nisha@ust                                    Added null check prevention of customer contact deletion
* 10.0     RQ-007882   13-Feb-2018 Madhubharathi.Gopalakrishnan@ust-global.com  Added null check  prevention of delete contact without account
* 11.0     RQ-010026   28-Mar-2019 Sidharth/Nitin@Maersk                        Added getContactInformaticaWebserviceDetails method
* 12.0     RQ-012372        09-03-2020      sidhartha@maersk              		Added SCPI customer group validation
* 12.1     SFSE-5757   26-May-2021 nitin@maersk                                 Added setContactIdsToAssignIndividualId
* 12.2     SFSE-6287   7/6/2021    meghana@ust									Bug fix - correction in if condition
* 13.0     SFSE-10558  09-Mar-2023 shubham@maersk                               Added SCPI_TAX_EXEMPT customer group validation
* 14.0	   SFSE-13245	03-Nov-2023		Kiran@Maersk							Contact SOQL 101 issue fix
*/
public class ContactRecordSelector implements RecordSelector {

    private TriggerHandler conTriggerHandler;

    // To store related Account details 
    public set<Id> setAccountIds = new set<Id>();
    public map<Id, Account> mapRelatedAccounts = new map<Id, Account>();
    
    // Below variable is used in ContactFieldPopulator.updateRecordType() 
    public list<Contact> lstContactForRTUpdate = new list<Contact>();
    
    // Below variables are used in ContactFieldPopulator.updateLinerBrand() 
    public set<Id> setCreatorIdForLBUpdate = new set<Id>();//ver 3.0
    public list<Contact> lstContactForLBUpdate = new list<Contact>();

    //ET related changes
    public Map<String,List<Contact>> emailIdConListMap=new Map<String,List<Contact>>();
    // Below variable is used in PrimaryContactUtilities
    public map<Id, Id> mapConIdOldAccId = new map<Id, Id>();
    
    // #RQ-004366.To store the set of Contact Ids.
    public Set<Id> setContactIdsToSync = new Set<Id>();
    
    public list<Contact> lstContactToSycnWithCMD = new list<Contact>();
    
    public Map<String, String> mapEmailIdsToFieldNameForInformatica = new Map<String, String>();
    public Map<String, String> mapPhoneNumbersToFieldNameForInformatica = new Map<String, String>();
    public Map<String, String> mapPhoneNumbersWithoutCountryCodeToFieldName = new Map<String, String>();
    public Id contactIdForInformatica;
    
    public map<Id, Account> mapGetRelatedSCPIAccounts = new map<Id, Account>();
    public list<Contact> lstNewContactForValidation = new list<Contact>();
    public list<Contact> lstOldContactForValidation = new list<Contact>();
    
    // #RQ-004708. To store List of Customer Contacts
    public List<Contact> lstCustomerContact = new List<Contact>();
    public Contact_Informatica_Webservice__mdt contPhoneInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
    public Contact_Informatica_Webservice__mdt contEmailInformaticaWebserviceDetails = new Contact_Informatica_Webservice__mdt();
    public Set<String> setContPhoneRecordTypes = new Set<String>();
    public Set<String> setContEmailRecordTypes = new Set<String>();

    // To store set of contact Ids if email is populated on contact
    public Set<Id> setContactIdsToAssignIndividualId = new Set<Id>(); 
    public Boolean skipInformaticaWebservices = false;
    public List<Id>conCustomerCode= new list<Id>();

    public ContactRecordSelector(list<Contact> lstNewContacts, map<Id, Contact> mapOldContacts, TriggerHandler contTriggerHandler) {
        this.conTriggerHandler = contTriggerHandler;
        getContactInformaticaWebserviceDetails();
        selectRecords(lstNewContacts, mapOldContacts);
        getRelatedRecords(lstNewContacts);
        
    }
    
    /*
    * For getting the old Account map values
    */
    public void selectRecords(list<Contact> lstNewContacts, map<Id, sObject> mapOldContacts){
        Contact oldContact;
        map<Id,Account> mapAccounts= new Map<Id,Account>();
         if(lstNewContacts != null && !lstNewContacts.isEmpty()) {
            for(Contact newContact : lstNewContacts) {
                oldContact = new Contact();
                if(mapOldContacts != null && !mapOldContacts.isEmpty()) {
                    oldContact = (Contact)mapOldContacts.get(newContact.Id);
                    
                    if(newContact.AccountId != oldContact.AccountId) {
                        setAccountIds.add(oldContact.AccountId);
                       // mapGetRelatedSCPIAccounts = getRelatedAccounts(setAccountIds);
                    }
                }

                // Store AccountId
                if(newContact.AccountId != null) {
                    setAccountIds.add(newContact.AccountId);
                   //  mapGetRelatedSCPIAccounts = getRelatedAccounts(setAccountIds);
                    //system.debug(mapGetRelatedSCPIAccounts + 'mapGetRelatedSCPIAccounts');
                }
            }
        }else if(lstNewContacts == null){
            if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                for(Contact oldContactRec : (List <Contact>)mapOldContacts.values()){
                    setAccountIds.add(oldContactRec.AccountId);
                }
            }
        }
        
        if(setAccountIds.size() > 0){
            
            mapGetRelatedSCPIAccounts = getRelatedAccounts(setAccountIds);
            
            if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE){
                mapAccounts= new Map<Id,Account>([SELECT Id, Name , recordTypeId FROM Account WHERE Id IN :setAccountIds]);
            }
        }
        
        
        
        if(lstNewContacts != null && !lstNewContacts.isEmpty()) {
            for(Contact newContact : lstNewContacts) {
                oldContact = new Contact();
                if(mapOldContacts != null && !mapOldContacts.isEmpty()) {
                    oldContact = (Contact)mapOldContacts.get(newContact.Id);
                    
                }
                /*Logic related to ET records*/
                if ((conTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ||conTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) && 
                conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && newContact.Email!=null
                 ){
                    if(!emailIdConListMap.containsKey(newContact.Email)){
                        emailIdConListMap.put(newContact.Email,new List<Contact>());
                    }
                    emailIdConListMap.get(newContact.Email).add(newContact);
                }
                
                // Trigger Context record selection
                if(conTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        setCreatorIdForLBUpdate.add(userinfo.getUserId()); // v3.0: Populate liner brand based on creator
                    }
                    else if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newContact.AccountId != oldContact.AccountId) {
                            mapConIdOldAccId.put(newContact.Id, oldContact.AccountId);
                        }
                       
                        //system.debug('mapGetRelatedSCPIAccounts ' + mapGetRelatedSCPIAccounts.get(oldContact.AccountId).RecordType.DeveloperName);
                      if(mapGetRelatedSCPIAccounts != null && !mapGetRelatedSCPIAccounts.isEmpty()){
                          if(((oldContact.AccountId !=null && (mapGetRelatedSCPIAccounts.get(oldContact.AccountId).Customer_Group__c == 'SCPI' || mapGetRelatedSCPIAccounts.get(oldContact.AccountId).Customer_Group__c == 'SCPI_TAX_EXEMPTED')) && (mapGetRelatedSCPIAccounts.get(oldContact.AccountId).RecordType.DeveloperName == 'Client_Account') && (mapGetRelatedSCPIAccounts.get(oldContact.AccountId).SCV_Status__c == 'Active')) && ((newContact.AccountId != oldContact.AccountId) || 
                           ((newContact.Contact_Status__c != oldContact.Contact_Status__c) && (newContact.Contact_Status__c == 'Inactive')) ||
                           ((newContact.Email != oldContact.Email) && (newContact.Email == NULL)))){
                               lstNewContactForValidation.add(newContact);
                               lstOldContactForValidation.add(oldContact);
                           }
                        } 
                        
                        if(newContact.AccountId != oldContact.AccountId || newContact.RecordTypeId != oldContact.RecordTypeId) {
                            lstContactForRTUpdate.add(newContact);
                        } 
                        if(newContact.Liner_brands__c != oldContact.Liner_brands__c || newContact.Email != oldContact.Email 
                           || newContact.RecordTypeId != oldContact.RecordTypeId 
                           || (newContact.Deduped_contact__c != oldContact.Deduped_contact__c && newContact.Deduped_contact__c == TRUE)) {
                            setCreatorIdForLBUpdate.add(newContact.CreatedbyId); // v3.0
                            lstContactForLBUpdate.add(newContact);
                        }
                    }
                }
                else {
                    if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if ( getCurrentUserCustomPermission() == False ){
                            getChangedEmailPhoneForInformatica(newContact,oldContact);
                        }

                        if (conTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && newContact.Email != null){
                            setContactIdsToAssignIndividualId.add(newContact.Id);
                        }
                        if (conTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && newContact.External_ID__c == null && newContact.RecordTypeId == Label.Customer_Contact_Record_Type){
                            lstContactToSycnWithCMD.add(newContact);
                        }
                         Id Customer_Contact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer_Contact').getRecordTypeId();
                        if(conTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && newContact.Customer_Code__c != null && newContact.Contact_Status__c!= 'Active' && newContact.AccountId == null && newContact.RecordTypeId == Customer_Contact){
                            conCustomerCode.add(newContact.Id);
                           
                        }
                    }
                    if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) { 
                        // #RQ-004366. Get the list of Status / Email updated Contacts. #RQ-005407. Added null check for email.
                        if((newContact.Email != oldContact.Email && newContact.Email != null ) || (newContact.Contact_Status__c != oldContact.Contact_Status__c && newContact.Contact_Status__c == 'Inactive')) {
                            
                            setContactIdsToSync.add(newContact.Id);
                        }

                        if ( getCurrentUserCustomPermission() == False ){
                            getChangedEmailPhoneForInformatica(newContact,oldContact);
                        }
                        if (conTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && newContact.External_ID__c == null && newContact.RecordTypeId == Label.Customer_Contact_Record_Type){
                            lstContactToSycnWithCMD.add(newContact);
                        }
                    } 
                }
            }
        }
        // #RQ-004708. Get the list of Contacts with Record Type = Customer contact and Account Record Type = Client Account.
        else if(lstNewContacts == null){  
            if(conTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                
                // #RQ-007882 - Added null check  prevention of delete contact without account
                for(Contact oldContactRec : (List <Contact>)mapOldContacts.values()){
                    if(mapAccounts.get(oldContactRec.AccountId) != null){
                        if(oldContactRec.RecordTypeId == Label.Customer_Contact_Record_Type && mapAccounts.get(oldContactRec.AccountId).RecordTypeId == Label.Client_Account_Record_Type_Id){
                            lstCustomerContact.add(oldContactRec);
                         }
                    }
                }
                
            }    
        }                
    }
    
    public void getRelatedRecords(list<Contact> lstNewContacts){
        setAccountIds.remove(null);
        if(!setAccountIds.isEmpty()) {
            mapRelatedAccounts = getRelatedAccounts(setAccountIds);
            system.debug('mapRelatedAccounts'+ mapRelatedAccounts);
        }
    }
    
    public static Boolean getCurrentUserCustomPermission(){
        return FeatureManagement.checkPermission('Skip_Contact_Phone_Email_Validation');
    }
    
    public Boolean getChangedEmailPhoneForInformatica(Contact newContact, Contact oldContact) {
    system.debug('@@@@@ newContact' + newContact);
    system.debug('@@@@@ oldContact' + oldContact);
    system.debug('@@@@@ setContPhoneRecordTypes' + setContPhoneRecordTypes);
        contactIdForInformatica = newContact.Id;
        Map<Id, Schema.RecordTypeInfo> mapContactRecordTypeInfo = Contact.sObjectType.getDescribe().getRecordTypeInfosById();
        String strNewContactRecordType_DeveloperName = mapContactRecordTypeInfo.get(String.valueOf(newContact.RecordTypeId)).getDeveloperName();
    system.debug('@@@@@ strNewContactRecordType_DeveloperName : ' + strNewContactRecordType_DeveloperName); 

        //Check EmailId is changed
        if (setContEmailRecordTypes.contains(strNewContactRecordType_DeveloperName)){
            if( !String.ISBLANK(newContact.Email) && ( oldContact == null || newContact.Email != oldContact.Email ) ){
                mapEmailIdsToFieldNameForInformatica.put(newContact.Email, 'Email');
            }
            if( !String.ISBLANK(newContact.Duplicate_Email__c) && ( oldContact == null || newContact.Duplicate_Email__c != oldContact.Duplicate_Email__c ) ){
                mapEmailIdsToFieldNameForInformatica.put(newContact.Duplicate_Email__c, 'Duplicate_Email__c');
            }
        }
    system.debug('@@@@@ mapEmailIdsToFieldNameForInformatica: ' + mapEmailIdsToFieldNameForInformatica);
        
        //Check Phone Numbers/Fax changed
        if (setContPhoneRecordTypes.contains(strNewContactRecordType_DeveloperName)){
            if ( !String.ISBLANK(newContact.Phone) && ( oldContact == null || newContact.Phone != oldContact.Phone ) ){
                String strCntPh = newContact.Phone;
                mapPhoneNumbersToFieldNameForInformatica.put(strCntPh.replace('+','').deleteWhitespace(),'Phone');
                system.debug('phonecheck' + mapPhoneNumbersToFieldNameForInformatica);
                mapPhoneNumbersWithoutCountryCodeToFieldName.put(strCntPh.replace('+','').deleteWhitespace().substring(2),'Phone');
            }
            if ( !String.ISBLANK(newContact.MobilePhone) && ( oldContact == null || newContact.MobilePhone != oldContact.MobilePhone ) ){
                String strCntMobilePh = newContact.MobilePhone;
                mapPhoneNumbersToFieldNameForInformatica.put(strCntMobilePh.replace('+','').deleteWhitespace(), 'MobilePhone');
                mapPhoneNumbersWithoutCountryCodeToFieldName.put(strCntMobilePh.replace('+','').deleteWhitespace().substring(2),'MobilePhone');
            }
            if ( !String.ISBLANK(newContact.OtherPhone) && ( oldContact == null || newContact.OtherPhone != oldContact.OtherPhone ) ){
                String strCntOtherPh = newContact.OtherPhone;
                mapPhoneNumbersToFieldNameForInformatica.put(strCntOtherPh.replace('+','').deleteWhitespace(), 'OtherPhone');
                mapPhoneNumbersWithoutCountryCodeToFieldName.put(strCntOtherPh.replace('+','').deleteWhitespace().substring(2),'OtherPhone');
            }
            if ( !String.ISBLANK(newContact.Fax) && ( oldContact == null || newContact.Fax != oldContact.Fax ) ){
                String strCntFax = newContact.Fax;
                mapPhoneNumbersToFieldNameForInformatica.put(strCntFax.replace('+','').deleteWhitespace(), 'Fax');
                mapPhoneNumbersWithoutCountryCodeToFieldName.put(strCntFax.replace('+','').deleteWhitespace().substring(2),'Fax');
            }

        system.debug('@@@@@ mapPhoneNumbersToFieldNameForInformatica: ' + mapPhoneNumbersToFieldNameForInformatica);
        system.debug('@@@@@ mapPhoneNumbersWithoutCountryCodeToFieldName: ' + mapPhoneNumbersWithoutCountryCodeToFieldName);

            /*if((String.ISBLANK(newContact.Phone) && newContact.Phone != oldContact.Phone) && (String.ISBLANK(newContact.MobilePhone) && newContact.MobilePhone != oldContact.MobilePhone) && (String.ISBLANK(newContact.OtherPhone) && newContact.OtherPhone != oldContact.OtherPhone)) {
                String strCntAcctPh = newContact.Account.Phone; 
                if(strCntAcctPh !=null) {
                    mapPhoneNumbersToFieldNameForInformatica.put(strCntAcctPh.replace('+','').deleteWhitespace(), 'AccountPhone');
                    mapPhoneNumbersWithoutCountryCodeToFieldName.put(strCntAcctPh.replace('+','').deleteWhitespace().substring(2),'AccountPhone');
                }
            }
            */ 
        }
        return true;
    }
    
    // For getting the accounts which are related to inserted/updated contact
    public static map<Id,Account> getRelatedAccounts(set<Id> setAccountIds) {
        //v 5.0: Remove Primary contact fields from account query
       Map<Id, Account> mapAccounts = new Map<Id, Account>();

    // Check if setAccountIds is not null and not empty
    if (setAccountIds != null && !setAccountIds.isEmpty()) {
        
       mapAccounts = new Map<Id, Account>([
            SELECT Id, RecordType.DeveloperName, SCV_Status__c, Customer_Group__c, Is_Client__c, Is_Draft_Account__c, Is_Non_shipping_Party__c, Is_Unassigned__c, Is_Concern__c
            FROM Account WHERE Id IN :setAccountIds
        ]);
    }

        return mapAccounts;
    }

    private void getContactInformaticaWebserviceDetails(){

        // Get Informatica contact phone email validation webservice details
        List<Contact_Informatica_Webservice__mdt> lstContactInformaticaWebservice = [SELECT Label, Chatter_UserName__c, License_Key__c, DeveloperName, Active__c, Host_Name__c, Query_Path__c, Record_Type__c, Timeout__c, Send_Chatter_Post__c, Send_Email_To_Last_Modified__c FROM Contact_Informatica_Webservice__mdt
                                                            WHERE DeveloperName in ('Contact_Phone_Validation','Contact_Email_Validation')];

        if (lstContactInformaticaWebservice.size() > 0){
            for (Contact_Informatica_Webservice__mdt ciw : lstContactInformaticaWebservice){
                contPhoneInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Phone_Validation') ? ciw : contPhoneInformaticaWebserviceDetails;
                contEmailInformaticaWebserviceDetails = (ciw.DeveloperName == 'Contact_Email_Validation') ? ciw : contEmailInformaticaWebserviceDetails;
            }
        system.debug('@@@@@ contPhoneInformaticaWebserviceDetails: ' + contPhoneInformaticaWebserviceDetails);
        system.debug('@@@@@ contEmailInformaticaWebserviceDetails: ' + contEmailInformaticaWebserviceDetails);

            String strContPhoneRecordType = contPhoneInformaticaWebserviceDetails.Record_Type__c;
            for (String p : strContPhoneRecordType.split(';')){
                setContPhoneRecordTypes.add(p);
            }
            String strContEmailRecordType = contEmailInformaticaWebserviceDetails.Record_Type__c;
            for (String e : strContEmailRecordType.split(';')){
                setContEmailRecordTypes.add(e);
            }
        system.debug('@@@@@ setContPhoneRecordTypes: ' + setContPhoneRecordTypes);
        system.debug('@@@@@ setContEmailRecordTypes: ' + setContEmailRecordTypes);

        }
        
        String loggedInUserName = UserInfo.getUserName();
        if(loggedInUserName.containsIgnoreCase(Label.Informatica_Skip_Users) ){
            skipInformaticaWebservices = true;
        }
    }

}