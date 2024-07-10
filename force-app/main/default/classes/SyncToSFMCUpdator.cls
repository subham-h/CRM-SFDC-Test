/* 
 * Author   : Amrutha Varshini Manjunath
 * Purpose  : To perform update on the contact "Sync_to_SFMC__c" field based on the Contact Record 
 * and Related ContactPointTypeConsent record (if it has status !='OptOut' in one of the records)
 * 
 * Revision     Ref Number      Date            Owner                         Description
 * --------     ----------      -----------     -------------------           -----------
 * 1.0          SFMC-7285       10-Jan-2024     amrutha.manjunath@maersk.com   Code created
 * */
public without sharing class SyncToSFMCUpdator {
    /*
    *Name : updateIndividualIds
    *Method: To Update the Contact record IndividualId
    */
    public static void updateIndividualIds(Map<Id,Contact> newContactMap,Map<Id,Contact> oldContactMap){
        for(Contact conObj:newContactMap.values()){
            if (conObj.IndividualId != null && 
                (conObj.Email != oldContactMap.get(conObj.id).Email)) {
                    conObj.IndividualId = null;
            }
            if(conObj.Email == null || 
                'Inactive'.equalsIgnoreCase(conObj.Contact_Status__c) || 
                (conObj.IndividualId == null && (!conObj.Included_in_Data_Signals__c)))
            {
                conObj.Sync_to_SFMC__c=false;
            }
        }
    }
    /*
    *Name : updateIndividualIds
    *Method: when individual id is associated with Contact
    */
    public static void updateConSyncToSFMC(List<Contact> conNewList,Map<Id,Contact> conOldMap,Boolean isInsert) {
    
        Set<Id> individualIds=new Set<Id>();
        for(Contact conObj:conNewList){
            if(conObj.Email != null && 
                'Active'.equalsIgnoreCase(conObj.Contact_Status__c) && 
                conObj.Included_in_Data_Signals__c)
            {
                conObj.Sync_to_SFMC__c=true;

            }else if(isInsert && conObj.IndividualId!=null)
            {
                individualIds.add(conObj.IndividualId);

            }else if((!isInsert) && conObj.IndividualId!=null && 
                (conObj.IndividualId!=conOldMap.get(conObj.Id).IndividualId || 
                conObj.Contact_Status__c !=conOldMap.get(conObj.Id).Contact_Status__c
                ||conObj.Included_in_Data_Signals__c!=conOldMap.get(conObj.Id).Included_in_Data_Signals__c))
            {
                individualIds.add(conObj.IndividualId);
            }
            
        }
        if (individualIds.isEmpty()) {return;}
        Map<Id, List<ContactPointTypeConsent>> consentsByIndividual = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent consent : [
                SELECT PartyId, PrivacyConsentStatus
                FROM ContactPointTypeConsent
                WHERE PartyId IN :individualIds]) 
        {
            if (!consentsByIndividual.containsKey(consent.PartyId)) {
                consentsByIndividual.put(consent.PartyId, new List<ContactPointTypeConsent>());
            }
           consentsByIndividual.get(consent.PartyId).add(consent);    
        }
        for (Contact tempContObj : conNewList) {
            Boolean syncToSFMC = true;

            // Check for false conditions
            if (tempContObj.Email == null || 
                'Inactive'.equalsIgnoreCase(tempContObj.Contact_Status__c) || 
                tempContObj.IndividualId == null ||
                 !consentsByIndividual.containsKey(tempContObj.IndividualId)||
                 consentsByIndividual.get(tempContObj.IndividualId).isEmpty())//for delete scenerio
            {
                syncToSFMC = false;
            } 
            else 
            {
                List<ContactPointTypeConsent> consents = consentsByIndividual.get(tempContObj.IndividualId);
                Boolean allOptOut = true;
                for (ContactPointTypeConsent consent : consents) {
                    if (consent.PrivacyConsentStatus != 'OptOut') {
                        allOptOut = false;
                        break;
                    }
                }
                if (allOptOut) {
                    syncToSFMC = false;
                }
            }

            // Only update if the value has changed
            if (tempContObj.Sync_to_SFMC__c != syncToSFMC) {
                tempContObj.Sync_to_SFMC__c = syncToSFMC;
            }
        }
    }
    /*
    *Name : updateSyncToSFMC
    *Method: when a new ContactPointTypeConsent is inserted or updated
    */
    public static void updateSyncToSFMC(Set<Id> individualIdSet,Map<Id, ContactPointTypeConsent> oldMap,Boolean isDelete) {
        Set<Id> individualIds=new Set<Id>();
        Map<Id,Contact> contactToUpdateMap=new Map<Id,Contact>();
        List<Contact> conList=[Select Id,IndividualId,Email,Contact_Status__c,Sync_to_SFMC__c,Included_in_Data_Signals__c from Contact where IndividualId in:individualIdSet ];
        if(conList.isEmpty()){return; }
        for(Contact conObj:conList){
            if(conObj.Email != null && 
                'Active'.equalsIgnoreCase(conObj.Contact_Status__c) && 
                conObj.Included_in_Data_Signals__c)
            { 
                continue;
            }
            individualIds.add(conObj.IndividualId);
        }
        if (individualIds.isEmpty()) {return;}
        Map<Id, List<ContactPointTypeConsent>> consentsByIndividual = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent consent : [
                SELECT PartyId, PrivacyConsentStatus
                FROM ContactPointTypeConsent
                WHERE PartyId IN :individualIds]) 
        {
            if (!consentsByIndividual.containsKey(consent.PartyId)) {
                consentsByIndividual.put(consent.PartyId, new List<ContactPointTypeConsent>());
            }
            if(!(isDelete && oldMap.containsKey(consent.Id))){//for delete scenerio
                consentsByIndividual.get(consent.PartyId).add(consent);
            }
        }
        

        for (Contact tempContObj : conList) {
            Boolean syncToSFMC = true;

            // Check for false conditions
            if (tempContObj.Email == null || 
                'Inactive'.equalsIgnoreCase(tempContObj.Contact_Status__c) || 
                tempContObj.IndividualId == null ||
                 !consentsByIndividual.containsKey(tempContObj.IndividualId)||
                 consentsByIndividual.get(tempContObj.IndividualId).isEmpty())//for delete scenerio
            {
                syncToSFMC = false;
            } 
            else 
            {
                List<ContactPointTypeConsent> consents = consentsByIndividual.get(tempContObj.IndividualId);
                Boolean allOptOut = true;
                for (ContactPointTypeConsent consent : consents) {
                    if (consent.PrivacyConsentStatus != 'OptOut') {
                        allOptOut = false;
                        break;
                    }
                }
                if (allOptOut) {
                    syncToSFMC = false;
                }
            }

            // Only update if the value has changed
            if (tempContObj.Sync_to_SFMC__c != syncToSFMC) {
                tempContObj.Sync_to_SFMC__c = syncToSFMC;
                contactToUpdateMap.put(tempContObj.Id,tempContObj);
            }
        }
        if(!contactToUpdateMap.isEmpty()){
            List<Database.SaveResult> contactSaveResultList = Database.update(contactToUpdateMap.values(), false);
            ErrorLogger.writeErrors('SFDC', 'Contact', 'SyncToSFMCUpdator.updateSyncToSFMC', contactSaveResultList, contactToUpdateMap.values());
        }
    }
}