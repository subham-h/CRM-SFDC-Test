/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Cargo Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agarwal          Created and optimized for creating or updating cargo records.
*/

public class CargoManagerClass {
     
    /** 
      * @description | SC-5462  Create Cargo Records |
      * @param tags accepts the list of Tags
      * @param shipmentData accepts the shipment Data
      */
    public static void createCargoRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> cargoFieldValueMap){
    
        List<SObject> sObjects = new List<SObject>();
        try{  
            
            Schema.SObjectField f = Cargo__c.Fields.Cargo_Id__c;
            if(!cargoFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataCargo(cargoFieldValueMap, shipmentData, tags, 'Cargo__c'));
            }
                                                         
            List<SObject> cargosToUpload = new List<SObject>();
            cargosToUpload.addAll(sObjects);
            
            Database.Upsert(cargosToUpload, f, true);       
    
        }catch(exception ex){
    
            ErrorLogger.writeError( 'Shipment Events', 'Cargo__c', 'CargoManagerClass.createCargoRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
    
            }
    
        }
    
    /** 
    * @description | SC-5462  Get Cargo Tag Data |
    * @param shipmentMap accepts the Map of Metadata
    * @param shipmentData accepts the shipment Data
    * @param tags accepts the list of Tags
    * @param sObjectName accepts Name of the object
    * @return List of sobject 
    */
    public static List<sObject> getTagDataCargo(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
            
        List<sObject> cargoList = new List<sObject>();

        Map<String, String> shipmentMapNew ;
    
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
            
        for(ShipmentJsonParser thisShipmentData : shipmentData){
                
                          
              
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0400 != null ){
                List<ShipmentJsonparser.Tag0400> tag0400 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0400;
                List<ShipmentJsonparser.Tag01c0> tag01c0 = thisShipmentData.Tag0000[0].Tag0100[0].Tag01c0;
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;

                shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));

                if(tags.containsIgnoreCase('tag0400') && tag0400 != null && !tag0400.isEmpty()){
                                    
                    cargoList.addAll(getFieldValueTag0400(tag0400, tag01c0, shipmentMapNew, shipmentMap.get('Tag0400'),shipmentMap.get('Tag01c0'), fieldDataTypeMap));

            
                }
            }
        }
        
                        
    
        return cargoList;
    
    }
        
    /** 
    * @description | SC-5462  Get Cargo Tag0400 $ Tag01c0  Data |
    * @param tag0400 accepts tag0400 data
    * @param tag01c0 accepts tag01c0 data
    * @param shipmentMapNew accepts the map of shipment data
    * @param tag0400DataMap accepts tag0400 data map with metadata
    * @param tag01c0DataMap accepts tag01c0 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @return List of sobject 
    */
    public static List<sObject> getFieldValueTag0400(List<ShipmentJsonparser.Tag0400> tag0400, List<ShipmentJsonparser.Tag01c0> tag01c0, Map<String, String> shipmentMapNew, Map<String, EMP_Consumer_settings__mdt>  tag0400DataMap, Map<String, EMP_Consumer_settings__mdt> tag01c0DataMap, Map<String, String> fieldDataTypeMap){
            //	tag100Ref.ge
    
        List<sObject> cargoList = new List<sObject>();
        Map<String, String> shipmentvalueMapNew = shipmentMapNew;
        Map<ShipmentJsonparser.Tag0400, Map<String, Object>> objectMap = new Map<ShipmentJsonparser.Tag0400, Map<String, Object>>();
        if(tag0400!= null && !tag0400.isEmpty() && tag01c0 != null && !tag01c0.isEmpty()){
            //when there will be multiple 01c0 tags , the tag for 01c0 logic to be considered from tag0400 's fkCargo field.
            //All the fields logic for 01c0 derives from 0400 tag.
     
            for(ShipmentJsonparser.Tag0400 tagRef : tag0400){
            
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                    
                for(ShipmentJsonparser.Tag01c0 tagRef1 : tag01c0){
    
                    s = JSON.serialize(tagRef1);
                    Map<String,Object> obj1 =  (Map<String,Object>) JSON.deserializeUntyped(s);
                        
                    if((String)obj.get('instanceId') == (String)Obj1.get('fkCargo')){
                            
                        if(objectMap.containsKey(tagRef)){
                            objectMap.get(tagRef).putAll(obj1);
                        }else{
                            objectMap.put(tagRef, obj1);
                        }
                         
                        break;

                    }else{continue;}
                }
                  
            }
            if(objectMap!= null && !objectMap.isEmpty()){

                for(ShipmentJsonparser.Tag0400 tagRef : objectMap.keySet()){
                    String s = JSON.serialize(tagRef);
                    Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                       
                    cargoList.add(getCargoRecord(obj, objectMap.get(tagRef), tag0400DataMap, tag01c0DataMap, fieldDataTypeMap, shipmentvalueMapNew));
                }
            }
        }

        return cargoList;
    }

       /** 
    * @description | SC-5462  Get Cargo Record |
    * @param tag0400Obj accepts tag0400 map data
    * @param tag01c0Obj accepts tag01c0 map data
    * @param tag0400DataMap accepts tag0400 data map with metadata
    * @param tag01c0DataMap accepts tag01c0 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @param shipmentMapNew accepts the map of shipment data
    * @return Cargo Record
    */
    public static Cargo__c getCargoRecord(Map<String,Object> tag0400Obj, Map<String,Object> tag01c0Obj, Map<String, EMP_Consumer_settings__mdt>  tag0400DataMap, Map<String, EMP_Consumer_settings__mdt>  tag01c0DataMap, Map<String, String> fieldDataTypeMap, Map<String, String> shipmentMapNew){
            //	tag100Ref.ge

        Cargo__c thisCargo = new Cargo__c();

        for(String tempString : tag0400DataMap.keyset()){

            if(fieldDataTypeMap.containsKey(tempString) && tag0400DataMap.get(tempString).Reference_Field__c != null ){
                  
                if(tag0400DataMap.get(tempString).Reference_Field__c == 'measureUnitWeight' && tempString == 'Cargo_Weight__c' )
                {    
                    String cargoWeight = tag0400Obj.get(tag0400DataMap.get(tempString).Field_Value__C) +'('+tag0400Obj.get(tag0400DataMap.get(tempString).Reference_Field__C)+')';
                    thisCargo.put(tempString, cargoWeight);
                }
                if(tag0400DataMap.get(tempString).Reference_Field__c == 'measureUnitMeasure' && tempString == 'Cargo_Volume__c' )
                {    
                    String cargoVolume = tag0400Obj.get(tag0400DataMap.get(tempString).Field_Value__C) +'('+tag0400Obj.get(tag0400DataMap.get(tempString).Reference_Field__C)+')';
                    thisCargo.put(tempString, cargoVolume);
                }
            }else
            {
                thisCargo.put(tempString, (String)tag0400Obj.get(tag0400DataMap.get(tempString).Field_Value__C));
            }  

        }
        for(String tempString : tag01c0DataMap.KeySet()){

            if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString).Contains('Number') ){
                String cargoSequence;
                if((String)tag01c0Obj.get(tag01c0DataMap.get(tempString).Field_Value__C) == 'O'){
                    cargoSequence = '0';
                }
                    
                else{
                    cargoSequence =((String)tag01c0Obj.get(tag01c0DataMap.get(tempString).Field_Value__C));
                }

                thisCargo.put(tempString,Decimal.valueOf(cargoSequence));
            }
            else{
                thisCargo.put(tempString, (String)tag01c0Obj.get(tag01c0DataMap.get(tempString).Field_Value__C));
                  
            }
        }
        if(fieldDataTypeMap.containsKey('TP_Doc_Number__c') && fieldDataTypeMap.get('TP_Doc_Number__c') == 'Lookup(TP Doc)' ){

            TP_Doc__c ref = new TP_Doc__c(TP_Doc_Number__c = shipmentMapNew.get('TP_Doc_Number__c'));
                        
            thisCargo.TP_Doc_Number__r =  ref;
        }
        if(fieldDataTypeMap.containsKey('Shipment_Number__c') && fieldDataTypeMap.get('Shipment_Number__c') == 'Master-Detail(Shipment)' ){

            Shipment__c ref = new Shipment__c(Shipment_Number__c = shipmentMapNew.get('Shipment_Number__c'));
                    
            thisCargo.Shipment_Number__r =  ref;
        }
                        
        
        return thisCargo;
    }
    
}