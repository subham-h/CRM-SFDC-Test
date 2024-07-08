/*
* Author    : Richa
* Purpose   : Query records related to Ocean Plus Lead
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8485     19-06-2023  Richa@Maersk            Query Shipment and Geography records
* 2.0       SC-8746     03-08-2023  Richa@Maersk            Query ServiceRelationShip records
* 3.0       SC-8782     12-08-2023  Richa@Maersk            Populate Area and Region lookup
* 4.0       SC-8872     22-08-2023  Richa@Maersk            Select records on Product update
* 5.0       SC-9001     06-09-2023  Richa@Maersk            Query related Accounts
* 6.0       SC-9001     06-09-2023  Richa@Maersk            Query related Contacts
* 7.0       SC-9148     26-09-2023  Richa@Maersk            Select OPL on status update
* 8.0       SC-9234     12-10-2023  Richa@Maersk            Add Owner Manager field for Ocean Plus Leads
* 9.0       SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer and Contact information on OPL
* 10.0		SC-9662		23-01-2024	Nayana@Maersk			Added logic to handle Booked_By_SCV_Code__c and Contractual_SCV_Code__c, added setCountryName
*/
public class OceanPlusLeadRecordSelector implements RecordSelector{
    private TriggerHandler oceanPlusLeadTriggerHandler; 
    public Set<String> setBookingNumbers = new Set<String>();
    public Map<String, Shipment__c> mapRelatedShipments = new Map<String, Shipment__c>();
    public Set<String> setCountryCode = new Set<String>();    
    public Set<String> setOwnerId = new Set<String>();
    public Map<String, String> mapOwnerCountry = new Map<String, String>();
    public Set<Ocean_Plus_Lead__c> setToPopulateSR = new Set<Ocean_Plus_Lead__c>();
    public Set<String> setAllAccountSCVCodes = new Set<String>();
    public Set<String> setCareAccountSCVCodes = new Set<String>();
    public Map<String, List<Care_Relationship__c>> mapCareRelationships = new Map<String, List<Care_Relationship__c>>();
    public Map<String,Ocean_Plus_Lead__c> mapInsertAndDeleteOPLI = new Map<String,Ocean_Plus_Lead__c>();
    public Map<String,Account> mapSCVAccount = new Map<String,Account>();
    public List<Ocean_Plus_Lead__c> lstOPLsWithSCVCode = new List<Ocean_Plus_Lead__c>();
    public List<Ocean_Plus_Lead__c> lstOPLsWithEmails = new List<Ocean_Plus_Lead__c>();
    public List<Ocean_Plus_Lead__c> lstOPLwithMarketingLead = new List<Ocean_Plus_Lead__c>();
    public Set<String> setEmails = new Set<String>();
    public Map<String,Contact> mapEmailContact = new Map<String,Contact>();
    public Map<String,Contact> mapExIdContact = new Map<String,Contact>();
    public Map<Id,Ocean_Plus_Lead__c> mapOPLStatusUpdate = new Map<Id,Ocean_Plus_Lead__c>();
    public Set<Ocean_Plus_Lead__c> setOPLManagerUpdate = new Set<Ocean_Plus_Lead__c>(); 
    public Set<String> setOwnerIds = new Set<String>();    
    public Map<Id,User> mapUserManager =new Map<Id,User>();
    public Map<String, String> mapBookedByParty = new Map<String, String>();
    public Set<String> setCountryName = new Set<String>();   //SC-9662
    public List<String> updateExcludedUsers = New List<String>();
    
    public OceanPlusLeadRecordSelector(list<Ocean_Plus_Lead__c> lstOceanPlusLeads, map<Id, Ocean_Plus_Lead__c> mapOldOceanPlusLeads, OceanPlusLeadTriggerHandler oceanPlusLeadTriggerHandler) {
        this.oceanPlusLeadTriggerHandler= oceanPlusLeadTriggerHandler;
        this.selectRecords(lstOceanPlusLeads, mapOldOceanPlusLeads);
        if(lstOceanPlusLeads != null && lstOceanPlusLeads.size() >0) {
            this.getRelatedRecords(lstOceanPlusLeads);
        }
    }
    public void selectRecords(list<Ocean_Plus_Lead__c> lstOceanPlusLeads, map<Id, sObject> mapOldOceanPlusLeads) {
        if(lstOceanPlusLeads != null && lstOceanPlusLeads.size() >0) {
            for(Ocean_Plus_Lead__c newOPL : lstOceanPlusLeads) {
                Ocean_Plus_Lead__c oldOPL;
                if(mapOldOceanPlusLeads != null && !mapOldOceanPlusLeads.isEmpty()) {
                    oldOPL = (Ocean_Plus_Lead__c)mapOldOceanPlusLeads.get(newOPL.Id);
                }
                
                if(oceanPlusLeadTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(oceanPlusLeadTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newOPL.Booking_Number__c != null) {
                            setBookingNumbers.add(newOPL.Booking_Number__c);
                        }
                        if(newOPL.Origin_Country_Code__c != null && !setCountryCode.contains(newOPL.Origin_Country_Code__c)){
                            setCountryCode.add(newOPL.Origin_Country_Code__c); 
                        } 
                        if(newOPL.Destination_Country_Code__c != null && !setCountryCode.contains(newOPL.Destination_Country_Code__c)){
                            setCountryCode.add(newOPL.Destination_Country_Code__c); 
                        } 
                        if(newOPL.Shipper_SCV_Code__c != null) {
                            setAllAccountSCVCodes.add(newOPL.Shipper_SCV_Code__c);
                            setCareAccountSCVCodes.add(newOPL.Shipper_SCV_Code__c);
                        } 
                        if(newOPL.Consignee_SCV_Code__c != null) {
                            setAllAccountSCVCodes.add(newOPL.Consignee_SCV_Code__c);
                            setCareAccountSCVCodes.add(newOPL.Consignee_SCV_Code__c);
                        }
                        if(newOPL.Contractual_SCV_Code__c != null) {
                            setAllAccountSCVCodes.add(newOPL.Contractual_SCV_Code__c);
                            setCareAccountSCVCodes.add(newOPL.Contractual_SCV_Code__c);
                        }
                        if(newOPL.Price_Owner_SCV_Code__c != null) {
                            setAllAccountSCVCodes.add(newOPL.Price_Owner_SCV_Code__c);
                            
                        }                       
                        if((newOPL.Origin_Country_Code__c != null && newOPL.Destination_Country_Code__c != null && newOPL.Brand__c != null  && (newOPL.Shipper_SCV_Code__c != null || newOPL.Consignee_SCV_Code__c != null)) ||
                          (newOPL.Brand__c != null && (newOPL.Booked_By_SCV_Code__c != null || newOPL.Contractual_SCV_Code__c != null))){ //SC-9662
                            setToPopulateSR.add(newOPL); 
                        }
                        
                        if(newOPL.Shipper_Contact_Email__c != null){
                            setEmails.add(newOPL.Shipper_Contact_Email__c);
                        }
                        if(newOPL.Consignee_Contact_Email__c != null){
                            setEmails.add(newOPL.Consignee_Contact_Email__c);
                        }
                        if(newOPL.Contractual_Contact_Email__c != null){
                            setEmails.add(newOPL.Contractual_Contact_Email__c);
                        }
                    }else if(oceanPlusLeadTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(newOPL.Shipment__c != oldOPL.Shipment__c && newOPL.Shipment__c != null){
                            setBookingNumbers.add(newOPL.Booking_Number__c); 
                        } 
                        if(newOPL.Origin_Country_Code__c != oldOPL.Origin_Country_Code__c && !setCountryCode.contains(newOPL.Origin_Country_Code__c)){
                            setCountryCode.add(newOPL.Origin_Country_Code__c); 
                        } 
                        if(newOPL.Destination_Country_Code__c != oldOPL.Destination_Country_Code__c && !setCountryCode.contains(newOPL.Destination_Country_Code__c)){
                            setCountryCode.add(newOPL.Destination_Country_Code__c); 
                        }
                        if(newOPL.Booked_By_SCV_Code__c != oldOPL.Booked_By_SCV_Code__c) {
                            if(newOPL.Booked_By_SCV_Code__c != null){
                                setAllAccountSCVCodes.add(newOPL.Booked_By_SCV_Code__c);  
                                setCareAccountSCVCodes.add(newOPL.Booked_By_SCV_Code__c);
                            }
                            lstOPLsWithSCVCode.add(newOPL);
                        }
                        if(newOPL.Shipper_SCV_Code__c != oldOPL.Shipper_SCV_Code__c) {
                            if(newOPL.Shipper_SCV_Code__c != null){
                                setAllAccountSCVCodes.add(newOPL.Shipper_SCV_Code__c);
                                setCareAccountSCVCodes.add(newOPL.Shipper_SCV_Code__c);
                            }
                            lstOPLsWithSCVCode.add(newOPL);
                        }
                        if(newOPL.Consignee_SCV_Code__c != oldOPL.Consignee_SCV_Code__c) {
                            if(newOPL.Consignee_SCV_Code__c != null){
                                setAllAccountSCVCodes.add(newOPL.Consignee_SCV_Code__c);
                                setCareAccountSCVCodes.add(newOPL.Consignee_SCV_Code__c);
                            }
                            lstOPLsWithSCVCode.add(newOPL);
                        }
                        if(newOPL.Contractual_SCV_Code__c != oldOPL.Contractual_SCV_Code__c) {
                            if(newOPL.Contractual_SCV_Code__c != null){
                                setAllAccountSCVCodes.add(newOPL.Contractual_SCV_Code__c);
                                setCareAccountSCVCodes.add(newOPL.Contractual_SCV_Code__c);
                            }
                            lstOPLsWithSCVCode.add(newOPL);
                        }
                        if(newOPL.Price_Owner_SCV_Code__c != oldOPL.Price_Owner_SCV_Code__c) {
                            if(newOPL.Price_Owner_SCV_Code__c != null){
                                setAllAccountSCVCodes.add(newOPL.Price_Owner_SCV_Code__c);
                            }
                            lstOPLsWithSCVCode.add(newOPL);
                        }                       
                        if(newOPL.Origin_Country_Code__c != oldOPL.Origin_Country_Code__c  || newOPL.Destination_Country_Code__c != oldOPL.Destination_Country_Code__c || newOPL.Shipper_Billing_City__c != oldOPL.Shipper_Billing_City__c || newOPL.Consignee_City__c != oldOPL.Consignee_City__c || newOPL.Brand__c != oldOPL.Brand__c  || newOPL.Shipper_SCV_Code__c != oldOPL.Shipper_SCV_Code__c || newOPL.Consignee_SCV_Code__c !=  oldOPL.Consignee_SCV_Code__c || newOPL.Booked_By_SCV_Code__c !=  oldOPL.Booked_By_SCV_Code__c || newOPL.Contractual_SCV_Code__c !=  oldOPL.Contractual_SCV_Code__c){
                            if(newOPL.Shipper_SCV_Code__c != null){
                                setCareAccountSCVCodes.add(newOPL.Shipper_SCV_Code__c);
                            }
                            if(newOPL.Consignee_SCV_Code__c != null){
                                setCareAccountSCVCodes.add(newOPL.Consignee_SCV_Code__c);
                            }
                            if(newOPL.Booked_By_SCV_Code__c != null){
                                setCareAccountSCVCodes.add(newOPL.Booked_By_SCV_Code__c);
                            }
                            if(newOPL.Contractual_SCV_Code__c != null){
                                setCareAccountSCVCodes.add(newOPL.Contractual_SCV_Code__c);
                            }
                            if(newOPL.Origin_Country_Code__c != null){
                                setCountryCode.add(newOPL.Origin_Country_Code__c); 
                            }
                            if(newOPL.Destination_Country_Code__c != null){
                                setCountryCode.add(newOPL.Destination_Country_Code__c);
                            }                           
                            setToPopulateSR.add(newOPL); 
                        }                       
                        if(newOPL.Shipper_Contact_Email__c != oldOPL.Shipper_Contact_Email__c){
                            if(newOPL.Shipper_Contact_Email__c != null){
                                setEmails.add(newOPL.Shipper_Contact_Email__c);
                            }
                            lstOPLsWithEmails.add(newOPL); 
                        }
                        if(newOPL.Consignee_Contact_Email__c != oldOPL.Consignee_Contact_Email__c){
                            if(newOPL.Consignee_Contact_Email__c != null){
                                setEmails.add(newOPL.Consignee_Contact_Email__c);
                            }
                            lstOPLsWithEmails.add(newOPL); 
                        }
                        if(newOPL.Contractual_Contact_Email__c != oldOPL.Contractual_Contact_Email__c){
                            if(newOPL.Contractual_Contact_Email__c != null){
                                setEmails.add(newOPL.Contractual_Contact_Email__c);
                            }
                            lstOPLsWithEmails.add(newOPL); 
                        }
                         if(newOPL.Status__c != oldOPL.Status__c && (newOPL.Status__c == 'Sold' || newOPL.Status__c == 'Not Sold' || newOPL.Status__c == 'Lead for Sales')) {                                                       
                            mapOPLStatusUpdate.put(newOPL.Id,newOPL );  
                        }
                        if(newOPL.OwnerId != oldOPL.OwnerId){
                            setOPLManagerUpdate.add(newOPL); 
                            setOwnerIds.add(newOPL.OwnerId);
                        }
                        if(newOPL.status__c == 'Marketing Engaged Lead' && newOPL.Status__c!=oldOPL.Status__c){
                            lstOPLwithMarketingLead.add(newOPL);
                        }
                       
                    }
                }else if(oceanPlusLeadTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(oceanPlusLeadTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if(oldOPL.Products_Pitched__c != newOPL.Products_Pitched__c) {                           
                            mapInsertAndDeleteOPLI.put(newOPL.Id,newOPL);                         
                        }                        
                    }
                }                
            }
        }
    }
    
    public void getRelatedRecords(list<Ocean_Plus_Lead__c> lstOceanPlusLeads) {
        getRelatedShipments();
        getRelatedServiceRelationships();
        getRelatedAccounts();
        getRelatedContacts();
        getOwnerManager();
        getBookedByParty();
        getExcludedUser();
    }
    // Retrieve related Shipments
    public void getRelatedShipments() {
        if(!setBookingNumbers.isEmpty()) {
            for(Shipment__c shp: [Select Id,Shipment_Number__c,Booked_By_Customer_SCV_Code__c from Shipment__c where Shipment_Number__c IN :setBookingNumbers]){
                mapRelatedShipments.put(shp.Shipment_Number__c,shp);   
            } 
        } 
    }
    // Retrieve Excluded User
    public void getExcludedUser(){  
        if(updateExcludedUsers.isEmpty()){
            General_Key_Value_Configurations__mdt config = General_Key_Value_Configurations__mdt.getInstance('CrossSellExcludedUser');
            if (config != null && !String.isEmpty(config.First_Field_Value__c)) {
                updateExcludedUsers.addAll(config.First_Field_Value__c.trim().split(','));
            }
        }}
    // Retrieve related Service Relationship records
    public void getRelatedServiceRelationships() {
        if(!setCareAccountSCVCodes.isEmpty()){
            for(Care_Relationship__c careRelationship : [Select Id,Direction__c,Location__r.Name,Country__c,Country__r.GEO_Code__c,Country__r.Name,Liner_Brand__c, Care_Business_Partner__c,Account__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c where Account__r.SCV_Code__c != null and Country__c != null and Account__r.SCV_Code__c IN: setCareAccountSCVCodes and (Country__r.GEO_Code__c in :setCountryCode OR Country__r.Name in :setCountryName) and Status__c = :Label.ActiveStatus]) {
            //for(Care_Relationship__c careRelationship : [Select Id,Direction__c,Location__r.Name,Country__c,Country__r.GEO_Code__c,Country__r.Name,Liner_Brand__c, Care_Business_Partner__c,Account__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c where Account__r.SCV_Code__c != null and Account__r.SCV_Code__c IN: setCareAccountSCVCodes and Status__c = :Label.ActiveStatus]) {    
            	if(careRelationship.Account__r.SCV_Code__c != null){
                    if(mapCareRelationships.containsKey(careRelationship.Account__r.SCV_Code__c)) {
                        mapCareRelationships.get(careRelationship.Account__r.SCV_Code__c).add(careRelationship);
                    }
                    else {
                        mapCareRelationships.put(careRelationship.Account__r.SCV_Code__c, new list<Care_Relationship__c>{careRelationship});
                    }
                }
            }
        }    
    } 
    
    // Retrieve related Account records
    public void getRelatedAccounts() {
        if(!setAllAccountSCVCodes.isEmpty()){
            for(Account acc : [Select Id,Name,Attractiveness__c,SCV_Code__c,Value_Proposition__c,Vertical__c,Country__c,Customer_Size__c,Customer_Role__c,BillingStreet,BillingCity,BillingCountry,Sales_Channel__c,MSL_Account_Owner__c,MSL_Account_Owner__r.Name from Account where SCV_Code__c != null and SCV_Code__c IN: setAllAccountSCVCodes]) {
                mapSCVAccount.put(acc.SCV_Code__c,acc);              
            }
        }    
    } 
    // Retrieve related Contact records
    public void getRelatedContacts() {   
        if(!setEmails.isEmpty()){
            for(Contact con : [Select Id,Name,Email,Phone,Account.SCV_Code__c from Contact where Email != null and Email IN: setEmails AND Contact_Status__c = 'Active']) {
                mapEmailContact.put(con.Email,con);              
            }
        } 
    }  
    
      // Retrieve related Owner Manager
    public void getOwnerManager() {
        if(!setOwnerIds.isEmpty()) {
            for(User usr : [Select Id,Manager.Name from User where Id IN :setOwnerIds]){
                mapUserManager.put(usr.Id,usr);             
            }
        } 
    }
    
     // Retrieve Booked By Party details
    public void getBookedByParty() {
        if(!setBookingNumbers.isEmpty()) {
            for(Party__c prty: [Select Id,Contact_Person__c,Shipment_Number__c from Party__c where Shipment_Number__c IN :setBookingNumbers AND Party_Number__c = '1' AND Contact_Person__c != null]){
                mapBookedByParty.put(prty.Shipment_Number__c,prty.Contact_Person__c);   
            }
        } 
    }
    
}