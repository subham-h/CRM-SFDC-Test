/*
* Author    : Richa
* Purpose   : Update OceanPlusLead records with Party details
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-9582     22-12-2023  Richa@Maersk            Update OceanPlusLead records with Booked By Party details
* 2.0       SFMC-7564   02/02/2024  Amrutha@maersk          Replaced Booked_By_Contact_Id__c with Booked_By_Contac__c
*/
public without sharing class PartyUtility { 
    
    /** 
* @description | SC-9582: Method to update OPLs with Booked By Party details
* @param mapParties accepts map of Booked By Parties
* @param mapParties accepts map of OPLs to be updated
* @param mapContacts accepts map of Booked By Contacts
*/     
    
    public static void updatePartyOnOpl(Map<String,Party__c> mapParties,Map<String,Ocean_Plus_Lead__c> mapOPLs,Map<String,Contact> mapContacts){
        try{   
            List<Ocean_Plus_Lead__c> lstOPLToUpdate = new List<Ocean_Plus_Lead__c>();  
            for(Ocean_Plus_Lead__c opl: mapOPLs.values()){
                if(mapParties.containsKey(opl.Booking_Number__c) && mapParties.get(opl.Booking_Number__c).Contact_Person__c != Null && mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c) != Null){
                    opl.Booked_By_Contact_Name__c = mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).Name;
                    opl.Booked_By_Contact_Email__c = mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).Email;            
                    opl.Booked_By_Contact__c = mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).Id;                    
                    if(mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).MobilePhone != Null){
                        opl.Booked_By_Contact_Phone_Number__c = mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).MobilePhone;
                    }else{
                        opl.Booked_By_Contact_Phone_Number__c = mapContacts.get(mapParties.get(opl.Booking_Number__c).Contact_Person__c).Phone;  
                    }
                    lstOPLToUpdate.add(opl);
                }
            }
            if(lstOPLToUpdate != null && lstOPLToUpdate.size()>0){
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update lstOPLToUpdate;
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Party', 'PartyUtility.updatePartyOnOpl', new list<Exception>{ex});   
        }
    }    
    
}