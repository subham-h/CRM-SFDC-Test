/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Equipment and Equipment Stuffing Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agarwal          Created and optimized for creating or updating Equipment records.
*/
public class EquipmentManagerClass {
  
    /** 
    * @description | SC-5462  Create Equipment Records |
    * @param tags accepts the list of Tags
    * @param shipmentData accepts the shipment Data
    */
    public static void createEquipmentRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> equipmentFieldValueMap){
    
        List<SObject> sObjects = new List<SObject>();
        try{
        
            Schema.SObjectField f = Equipment__c.Fields.Equipment_Assignmnet_Id__c;
            if(!equipmentFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataEquipments(equipmentFieldValueMap, shipmentData, tags, 'Equipment__c'));
            }
                                                         
            List<SObject> equipmentsToUpload = new List<SObject>();
            equipmentsToUpload.addAll(sObjects);
            
            Database.Upsert(equipmentsToUpload, f, true);       
    
        }catch(exception ex){
    
            ErrorLogger.writeError( 'Shipment Event', 'Equipment__c', 'EquipmentManagerClass.createEquipmentRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
    
        }
    
    }

    /** 
    * @description | SC-5462  Create Equipment Stuffing Records |
    * @param tags accepts the list of Tags
    * @param shipmentData accepts the shipment Data
    */
    public static void createEquipmentStuffingRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> equipmentStuffingsFieldValueMap){
    
        List<SObject> sObjects = new List<SObject>();
        try{
        
            Schema.SObjectField f = Equipment_Stuffing__c.Fields.Equipment_Stuffing_Id__c;
            if(!equipmentStuffingsFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataEquipmentStuffings(equipmentStuffingsFieldValueMap, shipmentData, tags, 'Equipment_Stuffing__c'));
            }
                                                         
            List<SObject> equipmentStuffingsToUpload = new List<SObject>();
            equipmentStuffingsToUpload.addAll(sObjects);

            Database.Upsert(equipmentStuffingsToUpload, f, true);       
    
        }catch(exception ex){
    
            ErrorLogger.writeError( 'Shipment Event', 'Equipment_Stuffing__c', 'EquipmentManagerClass.createEquipmentStuffingRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
    
        }
    
    }
    
    /** 
    * @description | SC-5462  Get Equipment Tag Data |
    * @param shipmentMap accepts the Map of Metadata
    * @param shipmentData accepts the shipment Data
    * @param tags accepts the list of Tags
    * @param sObjectName accepts Name of the object
    * @return List of sobject 
    */
    public static List<sObject> getTagDataEquipmentStuffings(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
            
        List<sObject> equipmentStuffingList = new List<sObject>();

        Map<String, String> shipmentMapNew ;
    
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
            
        for(ShipmentJsonParser thisShipmentData : shipmentData){                          
              
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0300 != null ){
                List<ShipmentJsonparser.Tag0300> tag0300 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0300;
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;

                shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));

                if(tags.containsIgnoreCase('tag0300') && tag0300 != null && !tag0300.isEmpty()){
                                    
                    equipmentStuffingList.addAll(getFieldValueTag0370(tag0300, shipmentMapNew, shipmentMap.get('Tag0300'), shipmentMap.get('Tag0370'),fieldDataTypeMap));
            
                }
            }
        }
        
    
        return equipmentStuffingList;
    
    }

    /** 
    * @description | SC-5462  Get Equipment Stuffing Tag Data |
    * @param shipmentMap accepts the Map of Metadata
    * @param shipmentData accepts the shipment Data
    * @param tags accepts the list of Tags
    * @param sObjectName accepts Name of the object
    * @return List of sobject 
    */
    public static List<sObject> getTagDataEquipments(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
            
        List<sObject> equipmentList = new List<sObject>();

        Map<String, String> shipmentMapNew ;
    
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
            
        for(ShipmentJsonParser thisShipmentData : shipmentData){
              
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0300 != null ){
                List<ShipmentJsonparser.Tag0300> tag0300 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0300;
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;

                shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));

                if(tags.containsIgnoreCase('tag0300') && tag0300 != null && !tag0300.isEmpty()){
                                    
                    equipmentList.addAll(getFieldValueTag0300(tag0300, shipmentMapNew, shipmentMap.get('Tag0300'), shipmentMap.get('Tag0310'), fieldDataTypeMap));
            
                }
            }
        }
        
    
        return equipmentList;
    
    }
    
    /** 
    * @description | SC-5462  Get Equipment Tag0300 $ Tag0370  Data |
    * @param tag0300 accepts tag0300 data
    * @param shipmentMapNew accepts the map of shipment data
    * @param tag0300DataMap accepts tag0300 data map with metadata
    * @param tag0370DataMap accepts tag0370 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @return List of sobject 
    */
    public static List<sObject> getFieldValueTag0370(List<ShipmentJsonparser.Tag0300> tag0300, Map<String, String> shipmentMapNew, Map<String, EMP_Consumer_settings__mdt>  tag0300DataMap, Map<String, EMP_Consumer_settings__mdt>  tag0370DataMap, Map<String, String> fieldDataTypeMap){
        //	tag100Ref.ge

        Map<ShipmentJsonparser.Tag0300, Map<String, Object>> objectMap = new Map<ShipmentJsonparser.Tag0300, Map<String, Object>>();

        List<sObject> equipmentStuffingList = new List<sObject>();
        Map<String, String> shipmentvalueMapNew = shipmentMapNew;
        if(tag0300!= null && !tag0300.isEmpty() ){
            
            for(ShipmentJsonparser.Tag0300 tagRef : tag0300){
            
                String s = JSON.serialize(tagRef);
                //Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                List<ShipmentJsonparser.Tag0370> tag0370 = tagRef.Tag0370;
                if(tag0370!=null && !tag0370.isEmpty()){

                    ShipmentJsonparser.Tag0370 tagRef1 = tagRef.tag0370[0];

                    s = JSON.serialize(tagRef1);
                    Map<String,Object> obj1 =  (Map<String,Object>) JSON.deserializeUntyped(s);
                    
                    if(objectMap.containsKey(tagRef)){
                        objectMap.get(tagRef).putAll(obj1);
                    }else{
                        objectMap.put(tagRef, obj1);
                    }
                             
                }
                
            }
    
            if(objectMap!= null && !objectMap.isEmpty()){
    
                for(ShipmentJsonparser.Tag0300 tagRef : objectMap.keySet()){
                    String s = JSON.serialize(tagRef);
                    Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                       
                    equipmentStuffingList.add(getEquipmentStuffingRecord(obj, objectMap.get(tagRef), tag0300DataMap, tag0370DataMap, fieldDataTypeMap, shipmentvalueMapNew));
                }
            }
    
        }    

        return equipmentStuffingList;
    }

      /** 
    * @description | SC-5462  Get Equipment Stuffing Record |
    * @param tag0300Obj accepts tag0300 map data
    * @param tag0370Obj accepts tag0370 map data
    * @param tag0300DataMap accepts tag0300 data map with metadata
    * @param tag0370DataMap accepts tag0370 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @param shipmentMapNew accepts the map of shipment data
    * @return Equipment Stuffing Record 
    */
    public static Equipment_Stuffing__c getEquipmentStuffingRecord(Map<String,Object> tag0300Obj, Map<String,Object> tag0370Obj, Map<String, EMP_Consumer_settings__mdt>  tag0300DataMap, Map<String, EMP_Consumer_settings__mdt>  tag0370DataMap, Map<String, String> fieldDataTypeMap, Map<String, String> shipmentMapNew){
        //	tag100Ref.ge

        Equipment_Stuffing__c thisEquipmentStuffing = new Equipment_Stuffing__c();

        for(String tempString : tag0300DataMap.keyset()){

            if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) == 'Master-Detail(Equipment)' ){

                Equipment__c ref = new Equipment__c(Equipment_Assignmnet_Id__c = (String)tag0300Obj.get(tag0300DataMap.get(tempString).Field_Value__c));
                        
                thisEquipmentStuffing.Equipment_Assignment_Id__r =  ref;

            }
                

        }
        for(String tempString : tag0370DataMap.KeySet()){

            if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString).Contains('Number') ){
                        
                thisEquipmentStuffing.put(tempString,Decimal.valueOf((String)tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C)));

            }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) == 'Checkbox' ){
                        
                thisEquipmentStuffing.put(tempString,Boolean.ValueOf(EMPConsumerHandler.getBooleanValue((String)tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C))));

            }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) == 'Master-Detail(Cargo)' ){

                Cargo__c ref = new Cargo__c(Cargo_Id__c = (String)tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C));
                        
                thisEquipmentStuffing.Cargo_Id__r =  ref;

            }else if(fieldDataTypeMap.containsKey(tempString) && tag0370DataMap.get(tempString).Reference_Field__c != null ){
                  
                if(tag0370DataMap.get(tempString).Reference_Field__c == 'measureUnitWeight' && tempString == 'Stuffing_Weight__c' )
                {    
                    String stuffingWeight = tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C) +'('+tag0370Obj.get(tag0370DataMap.get(tempString).Reference_Field__C)+')';
                    thisEquipmentStuffing.put(tempString, stuffingWeight);
                }
                if(tag0370DataMap.get(tempString).Reference_Field__c == 'measureUnitMeasure' && tempString == 'Stuffing_Volume__c' )
                {    
                    String stuffingVolume = tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C) +'('+tag0370Obj.get(tag0370DataMap.get(tempString).Reference_Field__C)+')';
                    thisEquipmentStuffing.put(tempString, stuffingVolume);
                }
            }else{

                thisEquipmentStuffing.put(tempString, (String)tag0370Obj.get(tag0370DataMap.get(tempString).Field_Value__C));
            }
        }
        if(fieldDataTypeMap.containsKey('Shipment_Number__c') && fieldDataTypeMap.get('Shipment_Number__c') == 'Lookup(Shipment)' ){

            Shipment__c ref = new Shipment__c(Shipment_Number__c = shipmentMapNew.get('Shipment_Number__c'));
                    
            thisEquipmentStuffing.Shipment_Number__r =  ref;
        }
        if(fieldDataTypeMap.containsKey('TP_Doc_Number__c') && fieldDataTypeMap.get('TP_Doc_Number__c') == 'Lookup(TP Doc)' ){

            TP_Doc__c ref = new TP_Doc__c(TP_Doc_Number__c = shipmentMapNew.get('TP_Doc_Number__c'));
                    
            thisEquipmentStuffing.TP_Doc_Number__r =  ref;
        }
                        
        
        return thisEquipmentStuffing;
    }

    /** 
    * @description | SC-5462  Get Equipment Tag0300 $ Tag0310  Data |
    * @param tag0300 accepts tag0300 data
    * @param shipmentMapNew accepts the map of shipment data
    * @param tag0300DataMap accepts tag0300 data map with metadata
    * @param tag0310DataMap accepts tag0310 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @return List of sobject 
    */
    public static List<sObject> getFieldValueTag0300(List<ShipmentJsonparser.Tag0300> tag0300, Map<String, String> shipmentMapNew, Map<String, EMP_Consumer_settings__mdt>  tag0300DataMap, Map<String, EMP_Consumer_settings__mdt>  tag0310DataMap, Map<String, String> fieldDataTypeMap){
            //	tag100Ref.ge
        Map<ShipmentJsonparser.Tag0300, Map<String, Object>> objectMap = new Map<ShipmentJsonparser.Tag0300, Map<String, Object>>();
        List<sObject> equipmentList = new List<sObject>();
        Map<String, String> shipmentvalueMapNew = shipmentMapNew;
        if(tag0300!= null && !tag0300.isEmpty() ){
            
            for(ShipmentJsonparser.Tag0300 tagRef : tag0300){
            
                String s = JSON.serialize(tagRef);
                //Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                List<ShipmentJsonparser.Tag0310> tag0310 = tagRef?.Tag0310;
                if(tag0310 != null){
                    for(ShipmentJsonParser.Tag0310 tagRef1: tag0310){
                        
                        s = JSON.serialize(tagref1);
                        Map<String,Object> obj1 =  (Map<String,Object>) JSON.deserializeUntyped(s);
                        
                        if((String)obj1.get('gcssName') == 'Height in Inches'){
                            
                            if(objectMap.containsKey(tagRef)){
                                objectMap.get(tagRef).putAll(obj1);
                            }else{
                                objectMap.put(tagRef, obj1);
                            }
                            
                            break;
                        }
                        else{continue;}
                    }
                }
            }

            if(objectMap!= null && !objectMap.isEmpty()){

                for(ShipmentJsonparser.Tag0300 tagRef : objectMap.keySet()){
                    String s = JSON.serialize(tagRef);
                    Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                   
                    equipmentList.add(getEquipmentRecord(obj, objectMap.get(tagRef), tag0300DataMap, tag0310DataMap, fieldDataTypeMap, shipmentvalueMapNew));
                }
            }

        }

        return equipmentList;
    }

      /** 
    * @description | SC-5462  Get Equipment Stuffing Record |
    * @param tag0300Obj accepts tag0300 map data
    * @param tag0310Obj accepts tag0310 map data
    * @param tag0300DataMap accepts tag0300 data map with metadata
    * @param tag0310DataMap accepts tag0310 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @param shipmentMapNew accepts the map of shipment data
    * @return Equipment Record 
    */
    public static Equipment__c getEquipmentRecord(Map<String,Object> tag0300Obj, Map<String,Object> tag0310Obj, Map<String, EMP_Consumer_settings__mdt>  tag0300DataMap, Map<String, EMP_Consumer_settings__mdt>  tag0310DataMap, Map<String, String> fieldDataTypeMap, Map<String, String> shipmentMapNew){
            //	tag100Ref.ge

        Equipment__c thisEquipment = new Equipment__c();

        for(String tempString : tag0300DataMap.keyset()){

            if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString).Contains('Number') ){
                        
                thisEquipment.put(tempString,Decimal.valueOf((String)tag0300Obj.get(tag0300DataMap.get(tempString).Field_Value__C)));

            }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) == 'Checkbox' ){
                        
                thisEquipment.put(tempString,Boolean.ValueOf(EMPConsumerHandler.getBooleanValue((String)tag0300Obj.get(tag0300DataMap.get(tempString).Field_Value__C))));

            }else if(fieldDataTypeMap.containsKey(tempString) && tag0300DataMap.get(tempString).Reference_Field__c != null ){
                  
                if(tag0300DataMap.get(tempString).Reference_Field__c == 'measureUnitWeightCustomer' && tempString == 'Booked_Weight__c' )
                {    
                    String bookedWeight = tag0300Obj.get(tag0300DataMap.get(tempString).Field_Value__C) +'('+tag0300Obj.get(tag0300DataMap.get(tempString).Reference_Field__C)+')';
                    thisEquipment.put(tempString, bookedWeight);
                }
            }else{

                thisEquipment.put(tempString, (String)tag0300Obj.get(tag0300DataMap.get(tempString).Field_Value__C));
            }
                   

        }
        for(String tempString : tag0310DataMap.KeySet()){

            if(fieldDataTypeMap.containsKey(tempString) && tempString=='Container_Height__c' ){
                        
                thisEquipment.put(tempString,tag0310Obj.get(tag0310DataMap.get(tempString).Field_Value__C));
            }
        }

        if(fieldDataTypeMap.containsKey('Shipment_Number__c') && fieldDataTypeMap.get('Shipment_Number__c') == 'Master-Detail(Shipment)' ){

            Shipment__c ref = new Shipment__c(Shipment_Number__c = shipmentMapNew.get('Shipment_Number__c'));
                    
            thisEquipment.Shipment_Number__r =  ref;
        }
                        
        
        return thisEquipment;
    }
    
}