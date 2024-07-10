/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Parties Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agrawal          Created and optimized for creating or updating Parties records.
* 2.0      SC-7773     18-April-2023 Vivek Agrawal         Modified the Class to create parties to Party custom object. Moved the logic from External objects to custom objects.
*/

public class PartiesManagerClass {
    
    /** 
* @description | SC-5462  Create Parties Records |
* @param tags accepts the list of Tags
* @param shipmentData accepts the shipment Data
*/
    public static void createPartiesRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> partiesFieldValueMap){
        
        List<SObject> sObjects = new List<SObject>();
        
        try{
            
            Schema.SObjectField f = Party__c.Fields.Party_Role_Type_Id__c;
            if(!partiesFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataParties(partiesFieldValueMap, shipmentData, tags, 'Party__c'));
            }
            
            List<SObject> partiesListToUpload = new List<SObject>();
            partiesListToUpload.addAll(sObjects);
            
            Database.Upsert(partiesListToUpload, f, true);       
            
        }catch(exception ex){
            
            ErrorLogger.writeError( 'Shipment Events', 'Party__c', 'PartiesManagerClass.createPartiesRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
            
        }
        
        
    }   
    
    /** 
* @description | SC-5462  Get Parties Tag Data |
* @param shipmentMap accepts the Map of Metadata
* @param shipmentData accepts the shipment Data
* @param tags accepts the list of Tags
* @param sObjectName accepts Name of the object
* @return List of sobject 
*/
    public static List<Party__c> getTagDataParties(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
        
        List<Party__c> partiesList = new List<Party__c>();
        
        Map<String, String> shipmentMapNew ;
        
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
        
        for(ShipmentJsonParser thisShipmentData : shipmentData){
            
            
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0200 != null ){
                List<ShipmentJsonparser.Tag0200> tag0200 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0200;
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;
                
                shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));
                
                if(tags.containsIgnoreCase('tag0200') && tag0200 != null && !tag0200.isEmpty()){
                    
                    partiesList.addAll(getFieldValueTag0200(tag0200, shipmentMapNew, shipmentMap.get('Tag0200'),fieldDataTypeMap));
                    
                }
            }
        }
        
        return partiesList;
        
    }
    
    /** 
* @description | SC-5462  Get Party Tag0200 Data |
* @param tag0200 accepts tag0200 data
* @param shipmentMapNew accepts the map of shipment data
* @param tag0200DataMap accepts tag0200 data map with metadata
* @param fieldDataTypeMap accept field data type map
* @return List of sobject 
*/
    public static List<Party__c> getFieldValueTag0200(List<ShipmentJsonparser.Tag0200> tag0200,Map<String, String> shipmentMapNew, Map<String, EMP_Consumer_settings__mdt>  tag0200DataMap,  Map<String, String> fieldDataTypeMap){
        //	tag100Ref.ge
        
        List<Party__c> partiesList = new List<Party__c>();
        Map<String, String> shipmentvalueMapNew = shipmentMapNew;
        if(tag0200!= null && !tag0200.isEmpty()){
            //when there will be multiple 01c0 tags , the tag for 01c0 logic to be considered from tag0200 's fkCargo field.
            //All the fields logic for 01c0 derives from 0400 tag.
            
            for(ShipmentJsonparser.Tag0200 tagRef : tag0200){
                
                ShipmentJsonParser.Tag0220 tag0220 ;
                
                if(tagRef.tag0220 != null){
                    
                    //get extCmdContactId field from tag2220
                    tag0220 = tagRef.Tag0220[0];
                    
                }
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                
                partiesList.add(getPartiesRecord(obj,  tag0200DataMap, fieldDataTypeMap, shipmentvalueMapNew, tag0220 ));
            }
            
        }
        
        return partiesList;
    }
    
    /** 
* @description | SC-5462  Get Parties Record |
* @param tag0200Obj accepts tag0200 map data
* @param tag0200DataMap accepts tag0200 data map with metadata
* @param fieldDataTypeMap accept field data type map
* @param shipmentMapNew accepts the map of shipment data
* @return Party Record
*/
    public static Party__c getPartiesRecord(Map<String,Object> tag0200Obj,  Map<String, EMP_Consumer_settings__mdt>  tag0200DataMap,Map<String, String> fieldDataTypeMap, Map<String, String> shipmentMapNew, ShipmentJsonParser.Tag0220 tag0220){
        
        Party__c thisParty = new Party__c();
        
        for(String tempString : tag0200DataMap.keyset()){
            
            //Populate customer reference and customer number
            if(fieldDataTypeMap.containsKey(tempString) && tempString == 'Scv_Customer_Code__c' ){
                thisParty.put(tempString,(String)tag0200Obj.get(tag0200DataMap.get('Scv_Customer_Code__c').Field_Value__C));
            }
            else{ 
                //populate other text fields
                thisParty.put(tempString, (String)tag0200Obj.get(tag0200DataMap.get(tempString).Field_Value__C));
            }
        }
        
        //Populate shipment reference and tp doc reference from shipmentMapNew map where we have the fields data from tag0120
        if(shipmentMapNew.containsKey('TP_Doc_Number__c') ){
            system.debug('-->Inside shipmentMapNew'+shipmentMapNew.get('TP_Doc_Number__c'));
            
            thisParty.Tp_Doc_Number__c =  shipmentMapNew.get('TP_Doc_Number__c');
            
            //populate TPDOC lookup with TODoc number reference
            if(fieldDataTypeMap.containsKey('TP_Doc__c') && fieldDataTypeMap.get('TP_Doc__c') == 'Lookup(TP Doc)' ){
                
                TP_Doc__c ref = new TP_Doc__c(TP_Doc_Number__c = shipmentMapNew.get('TP_Doc_Number__c'));
                
                thisParty.TP_Doc__r =  ref;
            }
        }
        
        if(shipmentMapNew.containsKey('Shipment_Number__c')){
            system.debug('-->Inside shipmentMapNew'+shipmentMapNew.get('Shipment_Number__c'));
            
            
            thisParty.shipment_number__c= shipmentMapNew.get('Shipment_Number__c');
            
            //populate shipment lookup with shipment number reference
            if(fieldDataTypeMap.containsKey('Shipment__c') && fieldDataTypeMap.get('Shipment__c') == 'Lookup(Shipment)' ){
                
                Shipment__c ref = new Shipment__c(Shipment_Number__c = shipmentMapNew.get('Shipment_Number__c'));
                
                thisParty.Shipment__r =  ref;
            }
            
        }
        
        //contactPerson field update from tag2220
        if(tag0220 != null ){
            String s = JSON.serialize(tag0220);
            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
            
            if((String)obj.get('extCmdContactId') != '' && (String)obj.get('extCmdContactId') != null){
                thisParty.Contact_Person__c = (String)obj.get('extCmdContactId');
            }
        }
        
        return thisParty;
    }
    
    /** 
* @description | SC-5462  Create Parties Records |
* @param partiesTPDOCStringJson accepts the Parties String Json
*/
    public static void createTPDOCEventPartiesRecords(String tags, List<TpDocJsonParser> tpDocData, Map<String, Map<String, EMP_Consumer_settings__mdt>> partiesFieldValueMap){
        
        
        List<SObject> sObjects = new List<SObject>();
        
        try{
            
            Schema.SObjectField f = Party__c.Fields.Party_Role_Type_Id__c;
            if(!partiesFieldValueMap.isEmpty()){
                sObjects.addAll(getTPDocEventTagDataParties(partiesFieldValueMap, tpDocData, tags, 'Party__c'));
            }
            
            List<SObject> partiesListToUpload = new List<SObject>();
            partiesListToUpload.addAll(sObjects);
            
            Database.Upsert(partiesListToUpload, f, true);       
            
        }
        catch(exception ex){
            
            ErrorLogger.writeError( 'TPDOC Events', 'Party__c', 'PartiesManagerClass.createPartiesRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
            
        }
        
    }   
    
    /** 
* @description | SC-5462  Get Parties Tag Data |
* @param tpDocMap accepts the Map of Metadata
* @param tpDocData accepts the TP Doc Data
* @param tags accepts the list of Tags
* @param sObjectName accepts Name of the object
* @return List of sobject 
*/
    public static List<Party__c> getTPDocEventTagDataParties(Map<String, Map<String, EMP_Consumer_settings__mdt>> tpDocMap, List<TpDocJsonParser> tpDocData, String tags, String sObjectName){
        Set<String> shipmentNumberSet = new Set<String>();
        Map<String, Shipment__c> shipmentMap = new Map<String, Shipment__c>();
        List<Party__c> partiesList = new List<Party__c>();        
        Map<String, String> tpDocMapNew;        
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
        
        for(TpDocJsonParser thisTpDocData : tpDocData){
            if(thisTpDocData.Tag0000[0].Tag2100[0] != null && thisTpDocData.Tag0000[0].Tag2100[0].Tag2200 != null ){
                List<TpDocJsonParser.Tag2120> tag2120 = thisTpDocData.Tag0000[0].Tag2100[0].Tag2120;
                
                tpDocMapNew = TPDocManagerClass.getFieldValueMapTag2120(tag2120,tpDocMap.get('Tag2120'));
                if(tpDocMapNew != null && !tpDocMapNew.isEmpty()){
                    if(tpDocMapNew.containsKey('Shipment_Number__c') && tpDocMapNew.get('Shipment_Number__c') != null){
                        shipmentNumberSet.add(tpDocMapNew.get('Shipment_Number__c'));
                    }
                }
            }
        }
        
        if(!shipmentNumberSet.isEmpty()){
            for(Shipment__c ship : [Select Id, Shipment_Number__c From Shipment__c Where Shipment_Number__c != null AND Shipment_Number__c =: shipmentNumberSet]){
                shipmentMap.put(ship.Shipment_Number__c, ship);
            }
        }
        
        for(TpDocJsonParser thisTpDocData : tpDocData){
            if(thisTpDocData.Tag0000[0].Tag2100[0] != null && thisTpDocData.Tag0000[0].Tag2100[0].Tag2200 != null ){
                List<TpDocJsonParser.Tag2200> tag2200 = thisTpDocData.Tag0000[0].Tag2100[0].Tag2200;
                List<TpDocJsonParser.Tag2120> tag2120 = thisTpDocData.Tag0000[0].Tag2100[0].Tag2120;
                
                tpDocMapNew = TPDocManagerClass.getFieldValueMapTag2120(tag2120,tpDocMap.get('Tag2120'));
                
                if(tags.containsIgnoreCase('tag2200') && tag2200 != null && !tag2200.isEmpty()){                    
                    partiesList.addAll(getFieldValueTag2200(tag2200, tpDocMapNew, tpDocMap.get('Tag2200'),fieldDataTypeMap, shipmentMap));                    
                }
            }
        }
        return partiesList;
        
    }
    
    
    /** 
* @description | SC-5462  Get Party Tag2200 Data |
* @param tag2200 accepts tag2200 data
* @param tpDocMapNew accepts the map of TP Doc data
* @param tag2200DataMap accepts tag2200 data map with metadata
* @param fieldDataTypeMap accept field data type map
* @return List of sobject 
*/
    public static List<Party__c> getFieldValueTag2200(List<TpDocJsonParser.Tag2200> tag2200,Map<String, String> tpDocMapNew, Map<String, EMP_Consumer_settings__mdt>  tag2200DataMap,  Map<String, String> fieldDataTypeMap, Map<String, Shipment__c> shipmentMap){
        List<Party__c> partiesList = new List<Party__c>();        
        if(tpDocMapNew != null && !tpDocMapNew.isEmpty()){
            if(tpDocMapNew.containsKey('Shipment_Number__c') && tpDocMapNew.get('Shipment_Number__c') != null && (shipmentMap.isEmpty() || !shipmentMap.containsKey(tpDocMapNew.get('Shipment_Number__c')))){
                return partiesList;
            }
        }
        
        if(tag2200!= null && !tag2200.isEmpty()){
            for(TpDocJsonParser.Tag2200 tagRef : tag2200){                
                TpDocJsonParser.Tag2220 tag2220; 
                if(tagRef.tag2220 != null){
                    //get extCmdContactId field from tag2220
                    tag2220 = tagRef.Tag2220[0];                    
                }
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                partiesList.add(getTPDocEventPartiesRecord(obj,  tag2200DataMap, fieldDataTypeMap, tpDocMapNew , tag2220, shipmentMap));
            }
        }
        
        return partiesList;
    }
    
    /** 
* @description | SC-5462  Get Parties Record |
* @param tag2200Obj accepts tag2200 map data
* @param tag2200DataMap accepts tag2200 data map with metadata
* @param fieldDataTypeMap accept field data type map
* @param tpDocMapNew accepts the map of TP Doc data
* @return Party Record
*/
    public static Party__c getTPDocEventPartiesRecord(Map<String,Object> tag2200Obj,  Map<String, EMP_Consumer_settings__mdt>  tag2200DataMap,Map<String, String> fieldDataTypeMap, Map<String, String> tpDocMapNew,  TpDocJsonParser.Tag2220 tag2220, Map<String, Shipment__c> shipmentMap){
        //	tag100Ref.ge            
        Party__c thisParty = new Party__c();
        
        for(String tempString : tag2200DataMap.keyset()){
            //Populate customer reference and customer number
            if(fieldDataTypeMap.containsKey(tempString) && tempString == 'Scv_Customer_Code__c' ){
                thisParty.put(tempString,(String)tag2200Obj.get(tag2200DataMap.get('Scv_Customer_Code__c').Field_Value__C));
            }
            else{ 
                //populate other text fields
                thisParty.put(tempString, (String)tag2200Obj.get(tag2200DataMap.get(tempString).Field_Value__C));
            }
        }
        
        //Populate shipment reference and tp doc reference from tpDocMapNew map where we have the fields data from tag0120
        if(tpDocMapNew.containsKey('TP_Doc_Number__c')){            
            thisParty.Tp_Doc_Number__c =  tpDocMapNew.get('TP_Doc_Number__c');
            //populate TPDOC lookup with TODoc number reference
            if(fieldDataTypeMap.containsKey('TP_Doc__c') && fieldDataTypeMap.get('TP_Doc__c') == 'Lookup(TP Doc)'){
                TP_Doc__c ref = new TP_Doc__c(TP_Doc_Number__c = tpDocMapNew.get('TP_Doc_Number__c'));
                thisParty.TP_Doc__r =  ref;
            }
        }
        
        if(tpDocMapNew.containsKey('Shipment_Number__c')){            
            thisParty.shipment_number__c = tpDocMapNew.get('Shipment_Number__c');
            thisParty.Shipment__c = shipmentMap.get(tpDocMapNew.get('Shipment_Number__c')).Id;
        }
        
        //contactPerson field update from tag2220
        if(tag2220 != null ){
            String s = JSON.serialize(tag2220);
            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
            
            if((String)obj.get('extCmdContactId') != '' && (String)obj.get('extCmdContactId') != null){
                thisParty.Contact_Person__c = (String)obj.get('extCmdContactId');
            }
        }
        
        return thisParty;
    }
    
    
}