/*
* Author    : Richa
* Purpose   : Populate fields on Ocean Plus Lead records
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-8485     19-06-2023  Richa@Maersk            Populate Shipment and Country lookup
* 2.0       SC-8746     03-08-2023  Richa@Maersk            Populate Service Relationship lookup
* 3.0       SC-8782     12-08-2023  Richa@Maersk            Populate Area and Region lookup
* 4.0       SC-8872     22-08-2023  Richa@Maersk            Insert/Delete OPLI items on Product update
* 5.0       SC-9001     06-09-2023  Richa@Maersk            Update related account fields on insert and update of opl
* 6.0       SC-9001     08-09-2023  Richa@Maersk            Update related contact fields on insert and update of opl
* 7.0       SC-9148     26-09-2023  Richa@Maersk            Validate OPL status on closure
* 8.0       SC-9234     12-10-2023  Richa@Maersk            Add Owner Manager field for Ocean Plus Leads
* 9.0       SC-9237     26-10-2023  Richa@Maersk            Capture Won date of an OPL
* 10.0      SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer and Contact information on OPL
* 11.0      SC-9662     23-01-2024  Nayana@Maersk           Added logic to populate Booked By Country and City and Contractual country and city on OPL
*															Added logic to populate Service relationship Booked By and Service relationship Contractual on OPL
*															Changed logic for setCareRelationship() method and added getMatchingCare() method
* 12.0      SFMC-7564    02/02/2024   Amrutha@maersk         Replaced Booked_By_Contact_Id__c with Booked_By_Contac__c
* 13.0		SC-9845 	05-03-2024	 Nayana@Maersk			Logic updated for Contractual to consider Bidirectional as first priority
* 14.0		SC-9971 	20-05-2024	 Meghna@Maersk			Update Marketing Engaged Flag
*/
public without sharing class OceanPlusLeadFieldPopulator { 
    
    /** 
* @description | SC-8485: Method to associate appropriate Shipment Lookup to Ocean Plus Lead records based on Booking Number |
* @param lstOceanPlusLeads accepts a list of Ocean Plus Lead records
* @param mapShipments accepts a key value pair of Booking Number and Shipment Id
*/      
    public static void populateShipmentLookup(List<Ocean_Plus_Lead__c> lstOceanPlusLeads,map<String, Shipment__c> mapShipments, OceanPlusLeadRecordSelector oceanPlusLeadRecordSelector,Map<Id, Ocean_Plus_Lead__c> mapOldOPLs,OceanPlusLeadTriggerHandler oplTriggerHandler) {
        try{
            Boolean bRefreshRecordSelector = false;
            for(Ocean_Plus_Lead__c newOpl:lstOceanPlusLeads){               
                if(mapShipments.containsKey(newOpl.Booking_Number__c)){
                    newOpl.Shipment__c = mapShipments.get(newOpl.Booking_Number__c).Id;
                    if(mapShipments.get(newOpl.Booking_Number__c).Booked_By_Customer_SCV_Code__c != null){
                        newOpl.Booked_By_SCV_Code__c = mapShipments.get(newOpl.Booking_Number__c).Booked_By_Customer_SCV_Code__c; //SC-9582 - Populate Booked By SCV  
                        oceanPlusLeadRecordSelector.setAllAccountSCVCodes.add(newOpl.Booked_By_SCV_Code__c);                   
                        oceanPlusLeadRecordSelector.setToPopulateSR.add(newOpl);//Added to populate Service_Relationship_BookedBy__c
                        oceanPlusLeadRecordSelector.setCareAccountSCVCodes.add(newOPL.Booked_By_SCV_Code__c);
                        bRefreshRecordSelector = true;   
                    }                  
                }
            } 
            if(bRefreshRecordSelector){                                    
                oceanPlusLeadRecordSelector.getRelatedAccounts(); //SC-9582 - To Populate Booked By Customer Details
                oceanPlusLeadRecordSelector.getRelatedServiceRelationships(); //SC-9662 - To populate Service relationship bookedby
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.populateShipmentLookup', new list<Exception>{ex});  
        }        
    }
    
    /** 
* @description | SC-8746: Method to associate appropriate Origin and Destination Geography to Ocean Plus Lead records based on Geo Code |
* @param lstOceanPlusLeads accepts a list of Ocean Plus Lead records
* @param setCountryCode accepts a set of Geo Codes
*/ 
    public static void populateGeography(List<Ocean_Plus_Lead__c> lstOceanPlusLeads,Set<String> setCountryCode){
        try{
            Map<string,string > mapGeoCodeId = new Map<string,string >();
            Map<string,string > mapGeoIdBDAId = new Map<string,string >();
            Map<string,string > mapGeoIdParentBDAId = new Map<string,string >();
            for(Geography__c geo : [SELECT Id,GEO_Code__c,GEO_ID__c FROM Geography__c WHERE Active__c = true and Type_Of_Location__c = 'Country' and GEO_Code__c in:setCountryCode]){
                mapGeoCodeId.put(geo.GEO_Code__c,geo.id);
            }  
            for(BDA_Geography__c bdaGeography : [SELECT Id, Geography__c,Geography__r.GEO_Code__c, BDA__c, BDA__r.Parent_BDA__c from BDA_Geography__c where Geography__r.GEO_Code__c in :setCountryCode and BDA__r.Type__c = 'Cluster' AND BDA__r.Active__c = true]) {
                mapGeoIdBDAId.put(bdaGeography.Geography__r.GEO_Code__c, bdaGeography.BDA__c);
                mapGeoIdParentBDAId.put(bdaGeography.Geography__r.GEO_Code__c, bdaGeography.BDA__r.Parent_BDA__c);
            }
            
            for(Ocean_Plus_Lead__c opl:lstOceanPlusLeads){
                if(mapGeoCodeId.containsKey(opl.Origin_Country_Code__c) && opl.Origin_Country__c != mapGeoCodeId.get(opl.Origin_Country_Code__c)){
                    opl.Origin_Country__c = mapGeoCodeId.get(opl.Origin_Country_Code__c);   
                    opl.Origin_Area__c = mapGeoIdBDAId.get(opl.Origin_Country_Code__c);
                    opl.Origin_Region__c = mapGeoIdParentBDAId.get(opl.Origin_Country_Code__c);
                }
                if(mapGeoCodeId.containsKey(opl.Destination_Country_Code__c) && opl.Destination_Country__c != mapGeoCodeId.get(opl.Destination_Country_Code__c)){
                    opl.Destination_Country__c = mapGeoCodeId.get(opl.Destination_Country_Code__c);
                    opl.Destination_Area__c = mapGeoIdBDAId.get(opl.Destination_Country_Code__c);
                    opl.Destination_Region__c = mapGeoIdParentBDAId.get(opl.Destination_Country_Code__c);
                }
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.populateGeography', new list<Exception>{ex});   
        }
    }
    
    /** 
* @description | SC-8782: Method to associate appropriate Care Relationship to OPL records based on SCV, Liner Brand, Direction, Country, City |
* @param setOceanPlusLeads accepts a list of Ocean Plus Lead records
* @param mapCareRelationships accepts a key value pair of Account SCV code and List of corresponding Service Relationship records
* @param mapOldOPLs acceps a key value pair of old Ocean Plus Lead records
*/     
    
    public static void populateServiceRelationship(Set<Ocean_Plus_Lead__c> setOceanPlusLeads,Map<String, List<Care_Relationship__c>>mapCareRelationships, Map<Id, Ocean_Plus_Lead__c> mapOldOPLs,OceanPlusLeadTriggerHandler oplTriggerHandler){
        Set<Id> setOplIds = new Set<Id>();
        try{
            Set<Care_Relationship__c> setSR = new Set<Care_Relationship__c>();            
            for(Ocean_Plus_Lead__c newOPL : setOceanPlusLeads) {  
                setOplIds.add(newOPL.Id);
                if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(mapCareRelationships.containsKey(newOPL.Consignee_SCV_Code__c)) {
                        newOPL.Service_Relationship_Import__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Consignee_SCV_Code__c), 'Consignee');
                    }
                    if(mapCareRelationships.containsKey(newOPL.Shipper_SCV_Code__c)) {
                        newOPL.Service_Relationship_Export__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Shipper_SCV_Code__c), 'Shipper');
                    }     
                    //SC-9662
                    if(mapCareRelationships.containsKey(newOPL.Booked_By_SCV_Code__c)) {
                        newOPL.Service_Relationship_BookedBy__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Booked_By_SCV_Code__c), 'BookedBy');
                    }
                    if(mapCareRelationships.containsKey(newOPL.Contractual_SCV_Code__c)) {
                        newOPL.Service_Relationship_Contractual__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Contractual_SCV_Code__c), 'Contractual');
                    }   
                } else if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    Ocean_Plus_Lead__c oldOPL;
                    if(mapOldOPLs != null) {
                        oldOPL = mapOldOPLs.get(newOPL.Id);
                    }                        
                    if(newOPL.Consignee_SCV_Code__c != null && (oldOPL.Consignee_SCV_Code__c != newOPL.Consignee_SCV_Code__c 
                                                                || oldOPL.Destination_Country__c != newOPL.Destination_Country__c || oldOPL.Consignee_City__c != newOPL.Consignee_City__c || oldOPL.Brand__c != newOPL.Brand__c ) && mapCareRelationships.containsKey(newOPL.Consignee_SCV_Code__c)) { 
                                                                    newOPL.Service_Relationship_Import__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Consignee_SCV_Code__c), 'Consignee');                                                                    
                                                                }
                    if(newOPL.Shipper_SCV_Code__c != null && (oldOPL.Shipper_SCV_Code__c != newOPL.Shipper_SCV_Code__c 
                                                              || oldOPL.Origin_Country__c != newOPL.Origin_Country__c || oldOPL.Shipper_Billing_City__c != newOPL.Shipper_Billing_City__c || oldOPL.Brand__c != newOPL.Brand__c ) && mapCareRelationships.containsKey(newOPL.Shipper_SCV_Code__c)) {
                                                                  newOPL.Service_Relationship_Export__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Shipper_SCV_Code__c), 'Shipper');                                                                  
                                                              }
                    //SC-9662
                    if(newOPL.Booked_By_SCV_Code__c != null && (oldOPL.Booked_By_SCV_Code__c != newOPL.Booked_By_SCV_Code__c  
                                                                || oldOPL.BookedBy_Country__c != newOPL.BookedBy_Country__c || oldOPL.BookedBy_City__c != newOPL.BookedBy_City__c || oldOPL.Brand__c != newOPL.Brand__c ) && mapCareRelationships.containsKey(newOPL.Booked_By_SCV_Code__c)) { 
                                                                    newOPL.Service_Relationship_BookedBy__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Booked_By_SCV_Code__c), 'BookedBy');                                                                    
                                                                }
                    if(newOPL.Contractual_SCV_Code__c != null && (oldOPL.Contractual_SCV_Code__c != newOPL.Contractual_SCV_Code__c 
                                                              || oldOPL.Contractual_Country__c != newOPL.Contractual_Country__c || oldOPL.Contractual_City__c != newOPL.Contractual_City__c || oldOPL.Brand__c != newOPL.Brand__c ) && mapCareRelationships.containsKey(newOPL.Contractual_SCV_Code__c)) {
                                                                  newOPL.Service_Relationship_Contractual__c = setCareRelationship(newOPL, mapCareRelationships.get(newOPL.Contractual_SCV_Code__c), 'Contractual');                                                                  
                                                              }
                    
                }                
            }           
            
        }catch(Exception ex){
            ErrorLogger.writeError( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.populateServiceRelationship',ex.getTypeName(),ex.getMessage()+ex.getLineNumber(),JSON.serialize(setOplIds)+'\n'+ex.getStackTraceString());   
        }
    }
    
    /** 
* @description | Utility method which is called from populateServiceRelationship() to return the Care Relationship based on the mentioned criterias  |
* @param opl accepts an Ocean Plus Lead Record
* @param lstCareRelationship accepts a list of Care Relationship Object
* @param direction accepts Direction of Ocean Plus Lead Record
* @param customerType accepts the type of customer(shipper/consignee) of Ocean Plus Lead Record
* @return careId in String format
* SC-9662
*/  
    public static String setCareRelationship(Ocean_Plus_Lead__c newOPL, list<Care_Relationship__c> lstCareRelationship, String customerType) {
        String careId=null;
        List<Care_Relationship__c> oneDirectionalCare=new List<Care_Relationship__c>();
        List<Care_Relationship__c> biDirectionalCare=new List<Care_Relationship__c>();
        if(lstCareRelationship !=null && lstCareRelationship.size()>0){
            for(Care_Relationship__c care : lstCareRelationship) 
            {           
                if(care.Direction__c == Label.DirectionBoth && newOPL.Brand__c == BrandUtilities.getBrandShortForm(care.Liner_Brand__c) && care.Status__c == Label.ActiveStatus){
                    biDirectionalCare.add(care);
                }
                else if(newOPL.Brand__c == BrandUtilities.getBrandShortForm(care.Liner_Brand__c) && care.Status__c == Label.ActiveStatus){
                    oneDirectionalCare.add(care);
                }
            }
        }
        
        //SC-9845 Logic updated for Contractual to consider Bidirectional as first priority
        List<Care_Relationship__c> firstDirectionalCare = new List<Care_Relationship__c>();
        List<Care_Relationship__c> secondDirectionalCare = new List<Care_Relationship__c>();
        If(customerType=='Contractual'){  
            if(biDirectionalCare!=null && biDirectionalCare.size()>0){
                firstDirectionalCare.addAll(biDirectionalCare);
            }
            if(oneDirectionalCare!=null && oneDirectionalCare.size()>0){
            	secondDirectionalCare.addAll(oneDirectionalCare);
            }
        }
        else{
            if(oneDirectionalCare!=null && oneDirectionalCare.size()>0){
            	firstDirectionalCare.addAll(oneDirectionalCare);
            }
            if(biDirectionalCare!=null && biDirectionalCare.size()>0){
            	secondDirectionalCare.addAll(biDirectionalCare); 
            }
        }
        
        //Consider Bidirectional service relationship as 1st priority for Contractual
        careId = getMatchingCare(firstDirectionalCare,newOPL,customerType,true);
        if(careId!=null){return careId;}
        careId = getMatchingCare(secondDirectionalCare,newOPL,customerType,true);
        if(careId!=null){return careId;}
        careId = getMatchingCare(firstDirectionalCare,newOPL,customerType,false);
        if(careId!=null){return careId;}
        careId = getMatchingCare(secondDirectionalCare,newOPL,customerType,false);
        if(careId!=null){return careId;}          
        return null;        
    }  
    
    /** 
* @description | SC-8872: Method to insert/delete OPLI based on Product selection on Ocean Plus Lead |
* @param mapInsertAndDeleteOPLI accepts a map of Ocean Plus Lead id and product key value pair 
*/     
    
    public static void insertAndDeleteOPLI(Map<String,Ocean_Plus_Lead__c> mapInsertAndDeleteOPLI,map<Id, Ocean_Plus_Lead__c> mapOldOPLs,OceanPlusLeadTriggerHandler oplTriggerHandler){
        try{ 
            Map<String,Set<String>> mapOPLIProds = new Map<String,Set<String>>();
            List<Ocean_Plus_Line_Item__c> lstDeleteOPLI = new List<Ocean_Plus_Line_Item__c>();
            Map<String,Set<String>> mapInsertOPLI = new Map<String,Set<String>>();
            List <Ocean_Plus_Line_Item__c> lstOPLI =  [SELECT  Id,Product__c,Ocean_Plus_Lead__c,Ocean_Plus_Lead__r.Products_Pitched__c FROM Ocean_Plus_Line_Item__c WHERE Ocean_Plus_Lead__c IN:mapInsertAndDeleteOPLI.keySet()];
            if(lstOPLI != null && lstOPLI.size() >0){      
                for(Ocean_Plus_Line_Item__c opli: lstOPLI){
                    if(opli.Ocean_Plus_Lead__r.Products_Pitched__c == null || !opli.Ocean_Plus_Lead__r.Products_Pitched__c.contains(opli.Product__c)){
                        lstDeleteOPLI.add(opli);
                    }
                    if (!mapOPLIProds.containsKey(opli.Ocean_Plus_Lead__c)) {
                        mapOPLIProds.put(opli.Ocean_Plus_Lead__c, new Set<String>());
                    }                
                    mapOPLIProds.get(opli.Ocean_Plus_Lead__c).add(opli.Product__c);
                }
            }
            
            for(Ocean_Plus_Lead__c newOPL : mapInsertAndDeleteOPLI.values()) {
                Ocean_Plus_Lead__c oldOPL;
                if(mapOldOPLs != null) {
                    oldOPL = mapOldOPLs.get(newOPL.Id);
                }
                if(newOPL.Products_Pitched__c != null){
                List <String> lstOPLProds = newOPL.Products_Pitched__c.split(';');               
                for(String prod:lstOPLProds){                                                 
                     if(mapOPLIProds.isEmpty() || !mapOPLIProds.containsKey(newOPL.Id)|| (mapOPLIProds.containsKey(newOPL.Id) && !mapOPLIProds.get(newOPL.Id).contains(prod))) {
                        if (!mapInsertOPLI.containsKey(newOPL.Id)) {
                            mapInsertOPLI.put(newOPL.Id, new Set<String>());
                        }                
                        mapInsertOPLI.get(newOPL.Id).add(prod);
                    }
                }  
                }
            }
            if(lstDeleteOPLI != null && !lstDeleteOPLI.isEmpty()){
                delete lstDeleteOPLI;
            }
            if(!mapInsertOPLI.isEmpty()){
                insertOPLI(mapInsertOPLI);
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.insertAndDeleteOPLI', new list<Exception>{ex});   
        }
    }   
    
    /** 
* @description | SC-8872: Utility method to insert OPLI based on Product selection on Ocean Plus Lead |
* @param mapInsertOPLI accepts a map of Ocean Plus Lead id and product key value pair 
*/    
    public static void insertOPLI(Map<String,Set<String>> mapInsertOPLI){
        try{
            if(!mapInsertOPLI.isEmpty()){
                List<Ocean_Plus_Line_Item__c> lstInsertOPLI = new List<Ocean_Plus_Line_Item__c>();
                for(String oplId: mapInsertOPLI.keySet()){
                    for(String prod: mapInsertOPLI.get(oplId)){
                        Ocean_Plus_Line_Item__c opli = new Ocean_Plus_Line_Item__c();
                        opli.Ocean_Plus_Lead__c = oplId;
                        opli.Product__c = prod;
                        lstInsertOPLI.add(opli);  
                    }
                    
                }
                if(lstInsertOPLI != null && lstInsertOPLI.size() >0){
                    insert lstInsertOPLI;
                }                
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.insertOPLI', new list<Exception>{ex});   
        }
        
    }
    /** 
* @description | SC-9001: Method to update related account fields on insert and update of opl |
* @param setOceanPlusLeads accepts a set of OPLs
* @param mapSCVAccount accepts a map of SCV code and Account key value pair 
* @param mapOldOPLs acceps a key value pair of old Ocean Plus Lead records
*/     
    
    public static void updateAccountFields(List<Ocean_Plus_Lead__c> lstOceanPlusLeads,Map<String,Account> mapSCVAccount, map<Id, Ocean_Plus_Lead__c> mapOldOPLs,OceanPlusLeadTriggerHandler oplTriggerHandler){
        try{
            Boolean bRefreshRecordSelector = false;
            for(Ocean_Plus_Lead__c newOPL : lstOceanPlusLeads) {
                if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {  
                    //SC-9582 - Populate Booked By Customer Details
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Booked_By_SCV_Code__c)) {                       
                        newOPL.Booked_By_Address__c = (mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingStreet  + ' ' +mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry).replaceAll('null', '');
                        newOPL.Booked_By_Customer_Name__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).Name;
                        //SC-9662
                        newOPL.BookedBy_Country__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry;
                        newOPL.BookedBy_City__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCity;
                        newOPL.Booked_By_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).MSL_Account_Owner__r.Name;
                        newOPL.Booked_By_Account_Id__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).Id;
                        if(mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry != null){                        
                            oplTriggerHandler.oceanPlusLeadRecordSelector.setCountryName.add(newOPL.BookedBy_Country__c);
                            bRefreshRecordSelector = true; 
                        }
                    }
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Consignee_SCV_Code__c)) {                       
                        newOPL.Consignee_Address__c = (mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingStreet  + ' ' +mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCountry).replaceAll('null', '');
                        newOPL.Consignee_Attractiveness__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Attractiveness__c;
                        newOPL.Consignee_City__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCity;
                        newOPL.Consignee_Country__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCountry;
                        newOPL.Consignee_Customer_Name__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Name;
                        newOPL.Consignee_Value_Proposition__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Value_Proposition__c;
                        newOPL.Consignee_Vertical__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Vertical__c;
                        newOPL.Consignee_Customer_Role__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Customer_Role__c;
                        newOPL.Consignee_Customer_Size__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Customer_Size__c;
                        newOPL.Consignee_Sales_Channel__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Sales_Channel__c;
                        newOPL.Consignee_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).MSL_Account_Owner__r.Name;
                        newOPL.Consignee_Account_Id__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Id;
                    }
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Shipper_SCV_Code__c)) {
                        newOPL.Shipper_Address__c = (mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingStreet + ' ' +mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCountry).replaceAll('null', '');
                        newOPL.Shipper_Attractiveness__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Attractiveness__c;
                        newOPL.Shipper_Billing_City__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCity;
                        newOPL.Shipper_Customer_Name__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Name;
                        newOPL.Shipper_Value_Proposition__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Value_Proposition__c;
                        newOPL.Shipper_Vertical__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Vertical__c;
                        newOPL.Shipper_Customer_Role__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Customer_Role__c;
                        newOPL.Shipper_Customer_Size__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Customer_Size__c;
                        newOPL.Shipper_Sales_Channel__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Sales_Channel__c;
                        newOPL.Shipper_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).MSL_Account_Owner__r.Name;
                        newOPL.Shipper_Account_Id__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Id;
                    }
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Contractual_SCV_Code__c)) {
                        newOPL.Contractual_Address__c = (mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingStreet + ' ' +mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry).replaceAll('null', '');
                        newOPL.Contractual_Attractiveness__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Attractiveness__c;
                        newOPL.Contractual_Customer_Name__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Name;
                        newOPL.Contractual_Value_Proposition__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Value_Proposition__c;
                        newOPL.Contractual_Vertical__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Vertical__c; 
                        newOPL.Contractual_Customer_Role__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Customer_Role__c;
                        newOPL.Contractual_Customer_Size__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Customer_Size__c;
                        newOPL.Contractual_Sales_Channel__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Sales_Channel__c;
                        //SC-9662
                        newOPL.Contractual_Country__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry;
                        newOPL.Contractual_City__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCity;
                        newOPL.Contract_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).MSL_Account_Owner__r.Name;
                        newOPL.Contractual_Account_Id__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Id;
                        if(mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry != null){     
                            oplTriggerHandler.oceanPlusLeadRecordSelector.setCountryName.add(newOPL.Contractual_Country__c);
                            bRefreshRecordSelector = true;  
                        }
                    }
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Price_Owner_SCV_Code__c)) {
                        newOPL.Price_Owner_Name__c = mapSCVAccount.get(newOPL.Price_Owner_SCV_Code__c).Name;
                        newOPL.Price_Owner_Account_Id__c = mapSCVAccount.get(newOPL.Price_Owner_SCV_Code__c).Id;
                    }
                } else if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    Ocean_Plus_Lead__c oldOPL;
                    if(mapOldOPLs != null) {
                        oldOPL = mapOldOPLs.get(newOPL.Id);
                    }
                    if(oldOPL.Booked_By_SCV_Code__c != newOPL.Booked_By_SCV_Code__c) { 
                        if(newOPL.Booked_By_SCV_Code__c == null || mapSCVAccount.isEmpty() || !mapSCVAccount.containsKey(newOPL.Booked_By_SCV_Code__c)) {
                            newOPL.Booked_By_Address__c = newOPL.Booked_By_Customer_Name__c = newOPL.BookedBy_Country__c = newOPL.BookedBy_City__c = newOPL.Booked_By_Account_Id__c = newOPL.Booked_By_MSL_Account_Owner__c = null;
                        }
                        else if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Booked_By_SCV_Code__c)) {                       
                            newOPL.Booked_By_Address__c = (mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingStreet  + ' ' +mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry).replaceAll('null', '');
                            newOPL.Booked_By_Customer_Name__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).Name;
                            //SC-9662
                            newOPL.BookedBy_Country__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry;
                        	newOPL.BookedBy_City__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCity;
                            newOPL.Booked_By_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).MSL_Account_Owner__r.Name;
                            newOPL.Booked_By_Account_Id__c = mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).Id;

                            if(mapSCVAccount.get(newOPL.Booked_By_SCV_Code__c).BillingCountry != null){   
                                oplTriggerHandler.oceanPlusLeadRecordSelector.setCountryName.add(newOPL.BookedBy_Country__c);
                                bRefreshRecordSelector = true;  
                            }
                        }
                        
                    }
                    if(oldOPL.Consignee_SCV_Code__c != newOPL.Consignee_SCV_Code__c) {                       
                        if(newOPL.Consignee_SCV_Code__c == null || mapSCVAccount.isEmpty() || !mapSCVAccount.containsKey(newOPL.Consignee_SCV_Code__c)) {
                            newOPL.Consignee_Address__c = newOPL.Consignee_Attractiveness__c = newOPL.Consignee_City__c = newOPL.Consignee_Country__c= newOPL.Consignee_Customer_Name__c = newOPL.Consignee_Value_Proposition__c = newOPL.Consignee_Vertical__c = newOPL.Consignee_Customer_Role__c = newOPL.Consignee_Customer_Size__c = newOPL.Consignee_Sales_Channel__c = newOPL.Consignee_MSL_Account_Owner__c = newOPL.Consignee_Account_Id__c = null;
                        }
                        else if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Consignee_SCV_Code__c)){
                            newOPL.Consignee_Address__c = (mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingStreet  + ' ' +mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCountry).replaceAll('null', '');
                            newOPL.Consignee_Attractiveness__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Attractiveness__c;
                            newOPL.Consignee_City__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCity;
                            newOPL.Consignee_Country__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).BillingCountry;
                            newOPL.Consignee_Customer_Name__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Name;
                            newOPL.Consignee_Value_Proposition__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Value_Proposition__c;
                            newOPL.Consignee_Vertical__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Vertical__c;
                            newOPL.Consignee_Customer_Role__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Customer_Role__c;
                            newOPL.Consignee_Customer_Size__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Customer_Size__c;  
                            newOPL.Consignee_Sales_Channel__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Sales_Channel__c;
                            newOPL.Consignee_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).MSL_Account_Owner__r.Name;
                            newOPL.Consignee_Account_Id__c = mapSCVAccount.get(newOPL.Consignee_SCV_Code__c).Id;
                        }
                    }
                    if(oldOPL.Shipper_SCV_Code__c != newOPL.Shipper_SCV_Code__c) {   
                        if(newOPL.Shipper_SCV_Code__c == null  || mapSCVAccount.isEmpty() || !mapSCVAccount.containsKey(newOPL.Shipper_SCV_Code__c)) {
                            newOPL.Shipper_Address__c = newOPL.Shipper_Attractiveness__c = newOPL.Shipper_Billing_City__c = newOPL.Shipper_Customer_Name__c = newOPL.Shipper_Value_Proposition__c = newOPL.Shipper_Vertical__c = newOPL.Shipper_Customer_Role__c = newOPL.Shipper_Customer_Size__c = newOPL.Shipper_Sales_Channel__c = newOPL.Shipper_Account_Id__c = newOPL.Shipper_Account_Id__c = null;
                        }
                        else if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Shipper_SCV_Code__c)){
                            newOPL.Shipper_Address__c = (mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingStreet + ' ' +mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCountry).replaceAll('null', '');
                            newOPL.Shipper_Attractiveness__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Attractiveness__c;
                            newOPL.Shipper_Billing_City__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).BillingCity;
                            newOPL.Shipper_Customer_Name__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Name;
                            newOPL.Shipper_Value_Proposition__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Value_Proposition__c;
                            newOPL.Shipper_Vertical__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Vertical__c;
                            newOPL.Shipper_Customer_Role__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Customer_Role__c;
                            newOPL.Shipper_Customer_Size__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Customer_Size__c;
                            newOPL.Shipper_Sales_Channel__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Sales_Channel__c;
                            newOPL.Shipper_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).MSL_Account_Owner__r.Name;
                            newOPL.Shipper_Account_Id__c = mapSCVAccount.get(newOPL.Shipper_SCV_Code__c).Id;
                        }
                        
                    } 
                    if(oldOPL.Contractual_SCV_Code__c != newOPL.Contractual_SCV_Code__c) {
                        if(newOPL.Contractual_SCV_Code__c == null  || mapSCVAccount.isEmpty() || !mapSCVAccount.containsKey(newOPL.Contractual_SCV_Code__c)) {
                            newOPL.Contractual_Address__c = newOPL.Contractual_Attractiveness__c  = newOPL.Contractual_Customer_Name__c = newOPL.Contractual_Value_Proposition__c = newOPL.Contractual_Vertical__c = newOPL.Contractual_Customer_Role__c = newOPL.Contractual_Customer_Size__c = newOPL.Contractual_Sales_Channel__c = newOPL.Contractual_Country__c = newOPL.Contractual_City__c = newOPL.Contract_MSL_Account_Owner__c = newOPL.Contractual_Account_Id__c = null;
                        }
                        else if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Contractual_SCV_Code__c)){
                            newOPL.Contractual_Address__c = (mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingStreet + ' ' +mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCity + ' '+mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry).replaceAll('null', '');
                            newOPL.Contractual_Attractiveness__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Attractiveness__c;
                            newOPL.Contractual_Customer_Name__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Name;
                            newOPL.Contractual_Value_Proposition__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Value_Proposition__c;
                            newOPL.Contractual_Vertical__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Vertical__c; 
                            newOPL.Contractual_Customer_Role__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Customer_Role__c;
                            newOPL.Contractual_Customer_Size__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Customer_Size__c;
                            newOPL.Contractual_Sales_Channel__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Sales_Channel__c;
                            //SC-9662
                            newOPL.Contractual_Country__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry;
                        	newOPL.Contractual_City__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCity;
                            newOPL.Contract_MSL_Account_Owner__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).MSL_Account_Owner__r.Name;
                            newOPL.Contractual_Account_Id__c = mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).Id;
                            if(mapSCVAccount.get(newOPL.Contractual_SCV_Code__c).BillingCountry != null){   
                                oplTriggerHandler.oceanPlusLeadRecordSelector.setCountryName.add(newOPL.Contractual_Country__c);
                                bRefreshRecordSelector = true;  
                            }
                        }
                    }
                    if(oldOPL.Price_Owner_SCV_Code__c != newOPL.Price_Owner_SCV_Code__c) {
                        if(newOPL.Price_Owner_SCV_Code__c == null  || mapSCVAccount.isEmpty() || !mapSCVAccount.containsKey(newOPL.Price_Owner_SCV_Code__c)) {
                            newOPL.Price_Owner_Name__c = newOPL.Price_Owner_Account_Id__c = null;
                        }
                        else if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Price_Owner_SCV_Code__c)){
                            newOPL.Price_Owner_Name__c = mapSCVAccount.get(newOPL.Price_Owner_SCV_Code__c).Name;
                            newOPL.Price_Owner_Account_Id__c = mapSCVAccount.get(newOPL.Price_Owner_SCV_Code__c).Id;
                        }
                    }                    
                }                
            }
            if(bRefreshRecordSelector && !oplTriggerHandler.oceanPlusLeadRecordSelector.setCountryName.isEmpty()){
                oplTriggerHandler.oceanPlusLeadRecordSelector.getRelatedServiceRelationships(); //SC-9662 
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.updateAccountFields', new list<Exception>{ex});   
        }
    }    
    /** 
* @description | SC-9001: Method to update related contact fields on insert and update of opl |
* @param setOceanPlusLeads accepts a set of OPLs
* @param mapEmailContact accepts a map of Email and Contact key value pair 
* @param mapOldOPLs acceps a key value pair of old Ocean Plus Lead records 
*/     
    
    public static void updateContactFields(List<Ocean_Plus_Lead__c> lstOceanPlusLeads,Map<String,Contact> mapEmailContact, Map<Id, Ocean_Plus_Lead__c> mapOldOPLs,OceanPlusLeadTriggerHandler oplTriggerHandler){
        try{ 
            for(Ocean_Plus_Lead__c newOPL : lstOceanPlusLeads) {
                if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                    if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Consignee_Contact_Email__c) && mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Account.SCV_Code__c == newOPL.Consignee_SCV_Code__c) {
                        newOPL.Consignee_Contact_Name__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Name;
                        newOPL.Consignee_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Phone;
                        newOPL.Consignee_Contact__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Id;
                    }
                    if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Shipper_Contact_Email__c) && mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Account.SCV_Code__c == newOPL.Shipper_SCV_Code__c) {
                        newOPL.Shipper_Contact_Name__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Name;
                        newOPL.Shipper_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Phone;
                        newOPL.Shipper_Contact__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Id;
                    }
                    if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Contractual_Contact_Email__c) && mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Account.SCV_Code__c == newOPL.Contractual_SCV_Code__c) {
                        newOPL.Contractual_Contact_Name__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Name;
                        newOPL.Contractual_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Phone;
                        newOPL.Contractual_Contact__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Id;
                    }
                    
                } else if(oplTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                    Ocean_Plus_Lead__c oldOPL;
                    if(mapOldOPLs != null) {
                        oldOPL = mapOldOPLs.get(newOPL.Id);
                    } 
                    if(oldOPL.Consignee_Contact_Email__c != newOPL.Consignee_Contact_Email__c) {
                        if(newOPL.Consignee_Contact_Email__c == null || mapEmailContact.isEmpty() || !mapEmailContact.containsKey(newOPL.Consignee_Contact_Email__c)) {
                            newOPL.Consignee_Contact_Name__c = newOPL.Consignee_Contact_Cell_Phone_Number__c = newOPL.Consignee_Contact__c = null;
                        }
                        else if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Consignee_Contact_Email__c) && mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Account.SCV_Code__c == newOPL.Consignee_SCV_Code__c) {
                            newOPL.Consignee_Contact_Name__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Name;
                            newOPL.Consignee_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Phone;
                            newOPL.Consignee_Contact__c = mapEmailContact.get(newOPL.Consignee_Contact_Email__c).Id;
                        }
                    }
                    if(oldOPL.Shipper_Contact_Email__c != newOPL.Shipper_Contact_Email__c) {
                        if(newOPL.Shipper_Contact_Email__c == null || mapEmailContact.isEmpty() || !mapEmailContact.containsKey(newOPL.Shipper_Contact_Email__c)){
                            newOPL.Shipper_Contact_Name__c = newOPL.Shipper_Contact_Cell_Phone_Number__c = newOPL.Shipper_Contact__c = null;
                        }
                        else if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Shipper_Contact_Email__c) && mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Account.SCV_Code__c == newOPL.Shipper_SCV_Code__c) {
                            newOPL.Shipper_Contact_Name__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Name;
                            newOPL.Shipper_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Phone;
                            newOPL.Shipper_Contact__c = mapEmailContact.get(newOPL.Shipper_Contact_Email__c).Id;
                        }
                    }
                    if(oldOPL.Contractual_Contact_Email__c != newOPL.Contractual_Contact_Email__c) {
                        if(newOPL.Contractual_Contact_Email__c == null || mapEmailContact.isEmpty() || !mapEmailContact.containsKey(newOPL.Contractual_Contact_Email__c)) {
                            newOPL.Contractual_Contact_Name__c = newOPL.Contractual_Contact_Cell_Phone_Number__c = newOPL.Contractual_Contact__c = null;
                        }
                        else if(!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Contractual_Contact_Email__c) && mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Account.SCV_Code__c == newOPL.Contractual_SCV_Code__c) {
                            newOPL.Contractual_Contact_Name__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Name;
                            newOPL.Contractual_Contact_Cell_Phone_Number__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Phone;
                            newOPL.Contractual_Contact__c = mapEmailContact.get(newOPL.Contractual_Contact_Email__c).Id;
                        }
                    }                    
                    
                }
                
            } 
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusLeadFieldPopulator.updateContactFields', new list<Exception>{ex});   
        }
    } 
    
    /** 
* @description | SC-9148: Method to validate parent OPL status on update |
* @param mapOPLs accepts a map of OPLs
*/ 
    public static void validateOPLStatus(Map<Id,Ocean_Plus_Lead__c> mapOPLs){         
        try{
            for(Ocean_Plus_Lead__c opl:[Select Id,Status__c,(Select Id,Status__c from Ocean_Plus_Line_Items__r where Status__c  IN ('New','In Progress')) from Ocean_Plus_Lead__c where Id IN:mapOPLs.keySet()]){
                if(opl.Ocean_Plus_Line_Items__r.size()>0){  
                    Ocean_Plus_Lead__c parentOPL = mapOPLs.get(opl.Id);
                    parentOPL.addError(Label.OPLStatusError);
                }
            }            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusFieldPopulator.validateOPLStatus', new list<Exception>{ex});  
        }       
    }
    /** 
* @description | SC-9934 Add LastUpdatedDate field on OPL record |
* @param mapOPLs accepts a map of OPLs
*/ 
    public static void updateOPLLastModifiedDate(Map<Id,Ocean_Plus_Lead__c> newMap, Map<Id, Ocean_Plus_Lead__c> oldMap){
        try{
            List<Ocean_Plus_Lead__c> lstUpdateOPL = new List<Ocean_Plus_Lead__c>();
            
            for (Ocean_Plus_Lead__c newOPL: newMap.values()) {
                Ocean_Plus_Lead__c newOPLRecord = new Ocean_Plus_Lead__c(Id = newOPL.id);
                Ocean_Plus_Lead__c oldOPL = oldMap.get(newOPL.id);
                if (oldOPL.LastModifiedDate != newOPL.LastModifiedDate) {
                    
                    newOPLRecord.LastUpdatedDate__c = Datetime.now();
                }
                lstUpdateOPL.add(newOPLRecord); 
            }
            if(lstUpdateOPL != null && lstUpdateOPL.size() >0){
                TriggerExecutionController.skipOceanPlusLeadTrigger(true);
                update lstUpdateOPL;
                TriggerExecutionController.skipOceanPlusLeadTrigger(false);
            }  
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusFieldPopulator.updateOPLLastModifiedDate', new list<Exception>{ex});  
            
        }
    }
    /** 
* @description | SC-SC-9234 Add Owner Manager field for Ocean Plus Leads
* @param setOceanPlusLeads accepts the set of OPL records for owner update
* @param mapUserManager accepts key value pair with Id and User record
*/
    public static void updateOwnerManger(Set<Ocean_Plus_Lead__c> setOceanPlusLeads, Map<Id, User> mapUserManager){
        try{ 
            for(Ocean_Plus_Lead__c newOPL : setOceanPlusLeads){
                if(mapUserManager.get(newOPL.OwnerId) != null && mapUserManager.get(newOPL.OwnerId).Manager.Name != null){
                    newOPL.Owner_Manager__c = mapUserManager.get(newOPL.OwnerId).Manager.Name;
                }else{
                    newOPL.Owner_Manager__c = '';
                }                     
            }
        }        
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusFieldPopulator.updateOwnerManger', new list<Exception>{ex}); 
        }
    }
    
 /** 
* @description | SC-9582 Update Booked By Customer and Contact information on OPL
* @param setOceanPlusLeads accepts the set of OPL records for update
* @param mapUserManager accepts key value pair with Id and User record
*/
    public static void populateBookedByPartyDetails(List<Ocean_Plus_Lead__c> lstOceanPlusLeads, Map<String, String> mapBookedByParty){
        try{ 
            Map<String,Contact > mapBookedByContact = new Map<String,Contact>();
            for(Contact con: [Select Id,Name,External_ID__c,Email, Phone,MobilePhone,Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingCountry from Contact where External_ID__c IN :mapBookedByParty.values()]){
                mapBookedByContact.put(con.External_ID__c,con);
            }
            if(!mapBookedByContact.isEmpty()){
                for(Ocean_Plus_Lead__c newOPL : lstOceanPlusLeads){
                    if(mapBookedByParty.containsKey(newOPL.Booking_Number__c) && mapBookedByParty.get(newOPL.Booking_Number__c) != null && mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)) != null){                    
                        newOPL.Booked_By_Contact_Name__c = mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).Name;
                        newOPL.Booked_By_Contact_Email__c = mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).Email;
                        newOPL.Booked_By_Contact__c = mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).Id;                                        
                        if( mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).MobilePhone != Null){
                            newOPL.Booked_By_Contact_Phone_Number__c = mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).MobilePhone;
                        }else{
                            newOPL.Booked_By_Contact_Phone_Number__c = mapBookedByContact.get(mapBookedByParty.get(newOPL.Booking_Number__c)).Phone;  
                        }
                    }
                }
            }
        }        
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusFieldPopulator.populateBookedByPartyDetails', new list<Exception>{ex}); 
        }
    }
    
/** 
* @description | Utility method which is called from setCareRelationship() to return the Care Relationship based on the mentioned criterias  |
* @param newOPL accepts an Ocean Plus Lead Record
* @param careList accepts a list of Care Relationship Object
* @param customerType accepts the type of customer(shipper/consignee/bookedby/contractual) of Ocean Plus Lead Record
* @param isCityCheckValid accepts boolean to check for city
* @return careId in String format
*/  
    public static String getMatchingCare(List<Care_Relationship__c> careList,Ocean_Plus_Lead__c newOPL, String customerType,Boolean isCityCheckValid){
        system.debug('customerType++'+customerType);
        String careId=null;
        if(careList!=null && careList.size()>0){
            for(Care_Relationship__c care : careList){
                switch on customerType {
                    when 'Consignee' { 
                        if(isCityCheckValid){
                            if((care.Direction__c == 'Import' || care.Direction__c == Label.DirectionBoth) && (newOPL.Destination_Country__c == care.Country__c) && (newOPL.Consignee_City__c == care.Location__r.Name)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                        else{
                            if((care.Direction__c == 'Import' || care.Direction__c == Label.DirectionBoth) && (newOPL.Destination_Country__c == care.Country__c)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                    }
                    when 'Shipper' { 
                        if(isCityCheckValid){
                            if((care.Direction__c == 'Export' || care.Direction__c == Label.DirectionBoth)  && (newOPL.Origin_Country__c == care.Country__c) && (newOPL.Shipper_Billing_City__c == care.Location__r.Name)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                        else{
                            if((care.Direction__c == 'Export' || care.Direction__c == Label.DirectionBoth)  && (newOPL.Origin_Country__c == care.Country__c)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                    }
                    when 'BookedBy' { //SC-9662
                        if(isCityCheckValid){
                            if((care.Direction__c == 'Export' || care.Direction__c == Label.DirectionBoth) && (newOPL.BookedBy_Country__c == care.Country__r.Name) && 
                               (newOPL.BookedBy_City__c == care.Location__r.Name)) {
                                   careId = care.Id;
                                   return careId;
                               }
                        }
                        else{
                            if((care.Direction__c == 'Export' || care.Direction__c == Label.DirectionBoth) && (newOPL.BookedBy_Country__c == care.Country__r.Name)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                    }				
                    when 'Contractual' { //SC-9662
                        if(isCityCheckValid){
                            if((care.Direction__c == Label.DirectionBoth || care.Direction__c == 'Export' || care.Direction__c == 'Import') && (newOPL.Contractual_Country__c == care.Country__r.Name) && (newOPL.Contractual_City__c == care.Location__r.Name)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                        else{
                            if((care.Direction__c == Label.DirectionBoth || care.Direction__c == 'Export' || care.Direction__c == 'Import') && (newOPL.Contractual_Country__c == care.Country__r.Name)) {
                                careId = care.Id;
                                return careId;
                            }
                        }
                    }
                }
            }  
        }
        else{
        	careId = null;
        }    
        return careId;
    }
    
        /** 
* @description | SC-9971 : Update Marketing Engaged Flag
* @param setOceanPlusLeads accepts the set of OPL records for owner update
*/
    public static void updateMarketingEngagedFlag(List<Ocean_Plus_Lead__c> lstOceanPlusLeads){
        try{ 
            for(Ocean_Plus_Lead__c newOPL : lstOceanPlusLeads){
                if(newOPL.Status__c=='Marketing Engaged Lead'){
                    newOPL.Marketing_Engaged_Flag__c = true;
                    }                    
                }
            }        
        catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'OceanPlusFieldPopulator.updateMarketingEngagedFlag', new list<Exception>{ex}); 
        }
    }
    
}