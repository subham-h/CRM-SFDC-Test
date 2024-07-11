/*
* Author    : Richa
* Purpose   : Update Service Relationship fields on Ocean Plus Lead records
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8922	    25-08-2023  Richa@Maersk            Update Service Relationship lookup on OPL
* 2.0       SC-6992		24-01-2024	Nayana@maersk			Updated populateCareRelationship() method to include BookedBy and Contractual logic
*															Added populateMatchRuleFields() methods from CareTriggerhandler class as part of framework
*/
public without sharing class CareRelationshipUtility { 
    
    /** 
* @description | SC-8922: Method to associate appropriate Care Relationship to case records based on Liner Brand, Direction, Country and SCV
* @param setCareId accepts Id of inserted/updated Service Relationship records
*/     
    
    public static void populateCareRelationship(Set<String> setCareId,Set<String> setAccChangeId,Set<String> setCountryIds){
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        Set<String> setSCV = new Set<String>();
        Map<String, List<Care_Relationship__c>> mapCareRelationships = new Map<String, List<Care_Relationship__c>>();
        Set<String> setCountryNames = new Set<String>();
        try{    
            for(Care_Relationship__c care : [Select Id,Direction__c,Location__r.Name,Country__c,Country__r.Name,Liner_Brand__c, Care_Business_Partner__c,Account__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c where Id IN: setCareId]) {
                if(care.Account__r.SCV_Code__c != null){
                    setSCV.add(care.Account__r.SCV_Code__c);
                    setCountryNames.add(care.Country__r.Name); //SC-9662 - To check Bookedby and Contractual country 
                }
            }
            
            for(Geography__c geo : [SELECT Id,Name FROM Geography__c WHERE Active__c = true and Type_Of_Location__c = 'Country' and Id in:setCountryIds]){
                setCountryNames.add(geo.Name);
            } 
            
            for(Care_Relationship__c care : [Select Id,Direction__c,Location__r.Name,Country__c,Country__r.Name,Liner_Brand__c, Care_Business_Partner__c,Account__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c where Account__r.SCV_Code__c IN: setSCV and (Country__c IN:setCountryIds OR Country__r.Name IN:setCountryNames)]) {
                if(care.Account__r.SCV_Code__c != null){
                    if(mapCareRelationships.containsKey(care.Account__r.SCV_Code__c)) {
                        mapCareRelationships.get(care.Account__r.SCV_Code__c).add(care);
                    }
                    else {
                        mapCareRelationships.put(care.Account__r.SCV_Code__c, new list<Care_Relationship__c>{care});
                    }
                }
            }            
            
            for(Ocean_Plus_Lead__c opl : [Select Id,Service_Relationship_Import__c,Service_Relationship_Export__c,Consignee_SCV_Code__c,Shipper_SCV_Code__c,
                                          Direction__c,Destination_Country__c,Consignee_City__c,Brand__c,Origin_Country__c,Shipper_Billing_City__c,Service_Relationship_BookedBy__c,
                                          Service_Relationship_Contractual__c,Booked_By_SCV_Code__c,Contractual_SCV_Code__c,BookedBy_Country__c,BookedBy_City__c,Contractual_Country__c,Contractual_City__c
                                          from Ocean_Plus_Lead__c where 
                                          (Consignee_SCV_Code__c IN: mapCareRelationships.keySet() OR Shipper_SCV_Code__c IN: mapCareRelationships.keySet() OR 
                                           Booked_By_SCV_Code__c IN: mapCareRelationships.keySet() OR Contractual_SCV_Code__c IN: mapCareRelationships.keySet() OR
                                           Service_Relationship_Export__c IN:setCareId OR Service_Relationship_Import__c IN:setCareId OR
                                           Service_Relationship_BookedBy__c IN:setCareId OR Service_Relationship_Contractual__c IN:setCareId) AND 
                                          (Destination_Country__c IN: setCountryIds OR Origin_Country__c IN: setCountryIds OR BookedBy_Country__c IN: setCountryNames OR Contractual_Country__c IN: setCountryNames) AND 
                                          Status__c IN ('New','In Progress') AND ((Days_To_Arrival__c >=-11 AND Days_To_Arrival__c <=28) OR (Days_To_Departure__c >=0 AND Days_To_Departure__c <=28))]) {
                    if(setAccChangeId != null && setAccChangeId.contains(opl.Service_Relationship_Export__c)){
                        opl.Service_Relationship_Export__c = null;
                    }
                    if(setAccChangeId != null && setAccChangeId.contains(opl.Service_Relationship_Import__c)){
                        opl.Service_Relationship_Import__c = null;
                    }
                    //SC-6992 - Changes for BookedBy and Contractual
                    if(setAccChangeId != null && setAccChangeId.contains(opl.Service_Relationship_BookedBy__c)){
                        opl.Service_Relationship_BookedBy__c = null;
                    }
                    if(setAccChangeId != null && setAccChangeId.contains(opl.Service_Relationship_Contractual__c)){
                        opl.Service_Relationship_Contractual__c = null;
                    }
                if(!mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(opl.Consignee_SCV_Code__c) && setCountryIds.contains(opl.Destination_Country__c)) {
                    String careIdConsignee = OceanPlusLeadFieldPopulator.setCareRelationship(opl, mapCareRelationships.get(opl.Consignee_SCV_Code__c), 'Consignee');
                    if(opl.Service_Relationship_Import__c != careIdConsignee) {
                        opl.Service_Relationship_Import__c = careIdConsignee;
                    }
                } 
                if(!mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(opl.Shipper_SCV_Code__c)  && setCountryIds.contains(opl.Origin_Country__c)) {
                    String careIdShipper = OceanPlusLeadFieldPopulator.setCareRelationship(opl, mapCareRelationships.get(opl.Shipper_SCV_Code__c), 'Shipper');
                    if(opl.Service_Relationship_Export__c != careIdShipper) {
                        opl.Service_Relationship_Export__c = careIdShipper;
                    }
                }
                //SC-6992 - Changes for BookedBy and Contractual
                if(!mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(opl.Booked_By_SCV_Code__c) && setCountryNames.contains(opl.BookedBy_Country__c)) {
                    String careIdBookedBy = OceanPlusLeadFieldPopulator.setCareRelationship(opl, mapCareRelationships.get(opl.Booked_By_SCV_Code__c), 'BookedBy');
                    if(opl.Service_Relationship_BookedBy__c != careIdBookedBy) {
                        opl.Service_Relationship_BookedBy__c = careIdBookedBy;
                    }
                } 
                if(!mapCareRelationships.isEmpty() && mapCareRelationships.containsKey(opl.Contractual_SCV_Code__c)  && setCountryNames.contains(opl.Contractual_Country__c)) {
                    String careIdContractual = OceanPlusLeadFieldPopulator.setCareRelationship(opl, mapCareRelationships.get(opl.Contractual_SCV_Code__c), 'Contractual');
                    if(opl.Service_Relationship_Contractual__c != careIdContractual) {
                        opl.Service_Relationship_Contractual__c = careIdContractual;
                    }
                }
                lstOPLUpdate.add(opl);
            }  
            
            if(lstOPLUpdate != null && lstOPLUpdate.size() > 0){
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update lstOPLUpdate;
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            } 
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'CareRelationship', 'CareRelationshipUtility.populateCareRelationship', new list<Exception>{ex});   
        }
    }

    /* Matching and duplicate rule is used to prevent duplicate Support Level records.
Matching rule is having a restriction of using only one lookup field in it.
This method populates the lookup field Ids to text fields for using in matching rule*/
    public static void populateMatchRuleFields (List<Care_Relationship__c> newCareList, Map<Id, Care_Relationship__c> oldMap){        
        for(Care_Relationship__c c : newCareList){
            c.Account_ID_Text__c = c.Account__c;
            c.Country_ID_Text__c = c.Country__c;
        }        
    }
}