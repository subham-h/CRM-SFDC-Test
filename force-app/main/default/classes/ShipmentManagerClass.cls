/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Shipment Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agarwal          Created and optimized for creating or updating Shipment records.
* 2.0      SC-7136     27-Feb-2023  Vivek Agarwal          Updated to consume tag01g0 and field ShipmentPropertyTypeRoot
* 3.0      SC-9586     05-Feb-2024  Richa@Maersk           Added Shipment Cancelled event consumption method 
* 4.0      SC-9600     09-Feb-2024  Shahanawaz@Maersk      Updated to consume tag01a0 and field Cargo type
* 5.0      SC-9950     19-March-2024  Vivek Agarwal        Updated to consume tag0900

*/
public class ShipmentManagerClass {
    
    /** 
* @description | SC-5462  Create Shipment Records |
* @param tags accepts the list of Tags
* @param shipmentData accepts the shipment Data
*/
    public static void createShipmentRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentFieldValueMap){
        List<SObject> sObjects = new List<SObject>();
        try{
            Set<String> shipmentNumberSet = new Set<String>();
            Map<String, Shipment__c> shipmentMap = new Map<String, Shipment__c>();
            List<SObject> shipmentsToInsert = new List<SObject>();
            List<SObject> shipmentsToUpdate = new List<SObject>();
            
            Schema.SObjectField f = Shipment__c.Fields.Shipment_Number__c;
            if(!shipmentFieldValueMap.isEmpty()){
                sObjects.addAll(getTagData(shipmentFieldValueMap, shipmentData, tags, 'Shipment__c'));
            }                                 
            
            List<SObject> shipmentsToUpload = new List<SObject>();
            shipmentsToUpload.addAll(sObjects);            
            
            if(!shipmentsToUpload.isEmpty()){
                for(SObject sObj : shipmentsToUpload){
                    if(sobj.get('Shipment_Number__c') != null){
                        shipmentNumberSet.add((String)sobj.get('Shipment_Number__c'));
                    }
                }
            }
            
            if(!shipmentNumberSet.isEmpty()){
                for(Shipment__c ship : [Select Id, Shipment_Number__c From Shipment__c Where Shipment_Number__c!= null AND Shipment_Number__c =: shipmentNumberSet]){
                    shipmentMap.put(ship.Shipment_Number__c, ship);
                }
            }
            
            if(!shipmentsToUpload.isEmpty()){
                for(SObject sObj : shipmentsToUpload){
                    if(sobj.get('Shipment_Number__c') != null && shipmentMap.containsKey((String)sobj.get('Shipment_Number__c'))){
                        sObj.Id = shipmentMap.get((String)sobj.get('Shipment_Number__c')).Id;
                        shipmentsToUpdate.add(sObj);
                    }
                    else{
                        shipmentsToInsert.add(sObj);
                    }
                }
            }
            
            if(!shipmentsToInsert.isEmpty()){
                insert shipmentsToInsert;
            }
            
            if(!shipmentsToUpdate.isEmpty()){
                update shipmentsToUpdate;
            }
            
            //Database.Upsert(shipmentsToUpload, f, true);
            
        }catch(exception ex){
            
            ErrorLogger.writeError( 'Shipment Events', 'Shipment__c', 'ShipmentManagerClass.createShipmentRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
            
        }
        
    }
    
    /** 
* @description | SC-9586 Cancel Shipment Records |
* @param lstCancelledShipmentData accepts a list of parsed Cancelled Shipment events
* @param mapshipmentFieldValues accepts a map of all JSON field mappings with object fields that need to be updated in SFDC
* @param mapCancelledStatusValues accepts a map of all JSON field cancelled values with SFDC status values
*/
    public static void cancelShipmentRecords(List<ShipmentCancelledJsonParser> lstCancelledShipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> mapshipmentFieldValues,  Map<String,String> mapCancelledStatusValues){
           try{
            List<SObject> lstSObjects = new List<SObject>();
            Set<String> setShipmentNumbers = new Set<String>();
            Map<String, Shipment__c> mapExistingShipment= new Map<String, Shipment__c>();
            List<SObject> lstShipmentsToUpload = new List<SObject>();
            List<SObject> lstShipmentsToUpdate = new List<SObject>();            
            List<SObject> lstShipmentToInsert = new List<SObject>();
            if(!mapshipmentFieldValues.isEmpty()){
                lstSObjects.addAll(getCancelledShipmentTagData(mapshipmentFieldValues, lstCancelledShipmentData, 'Shipment__c',mapCancelledStatusValues));
            }
               
            if(lstSObjects != null && lstSObjects.size() > 0){        
                lstShipmentsToUpload.addAll(lstSObjects);  
            }
               
            if(lstShipmentsToUpload != null && lstShipmentsToUpload.size() > 0){
                for(SObject sObj : lstShipmentsToUpload){
                    if(sobj.get('Shipment_Number__c') != null){
                        setShipmentNumbers.add((String)sobj.get('Shipment_Number__c'));
                    }
                }
            }
               
            if(!setShipmentNumbers.isEmpty()){
                for(Shipment__c ship : [Select Id, Shipment_Number__c From Shipment__c Where Shipment_Number__c!= null AND Shipment_Number__c =: setShipmentNumbers]){
                    mapExistingShipment.put(ship.Shipment_Number__c, ship);
                }
            }
            
           if(lstShipmentsToUpload != null && lstShipmentsToUpload.size() > 0){
                for(SObject sObj : lstShipmentsToUpload){
                    if(sObj.get('Shipment_Number__c') != null && mapExistingShipment.containsKey((String)sObj.get('Shipment_Number__c'))){
                        sObj.Id = mapExistingShipment.get((String)sObj.get('Shipment_Number__c')).Id;
                        lstShipmentsToUpdate.add(sObj);
                    }
                    else{
                        lstShipmentToInsert.add(sObj);                        
                    }
                }
            }            
            
            
            if(!lstShipmentToInsert.isEmpty()){
                insert lstShipmentToInsert;
            }
            
            if(!lstShipmentsToUpdate.isEmpty()){
                update lstShipmentsToUpdate;
            }
           
            
        }catch(exception ex){
            ErrorLogger.writeError( 'Shipment Events', 'Shipment__c', 'ShipmentManagerClass.cancelShipmentRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()));
        }
    }
    
    
    /** 
* @description | SC-5462  Get Shipment Tag Data |
* @param shipmentMap accepts the Map of Metadata
* @param shipmentData accepts the shipment Data
* @param tags accepts the list of Tags
* @param sObjectName accepts Name of the object
* @return List of sobject 
*/
    public static List<sObject> getTagData(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
        
        List<sObject> shipmentList = new List<sObject>();
        
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
        
        for(ShipmentJsonParser thisShipmentData : shipmentData){
            Map<String, String> shipmentMapNew = new Map<String, String>();
            if(thisShipmentData.Tag0000[0] != null && thisShipmentData.Tag0000[0].Tag0100 != null ){
                List<ShipmentJsonparser.Tag0100> tag0100 = thisShipmentData.Tag0000[0].Tag0100;
                if(tags.containsIgnoreCase('tag0100') && tag0100 != null && !tag0100.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0100(tag0100,shipmentMap.get('Tag0100')));
                }
            }
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0110 != null ){
                List<ShipmentJsonparser.Tag0110> tag0110 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0110;
                if(tags.containsIgnoreCase('tag0110') && tag0110 != null && !tag0110.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0110(tag0110,shipmentMap.get('Tag0110')));
                }
            }
            if(thisShipmentData.Tag0000[0].Tag0100[0]!= null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0200 != null ){
                List<ShipmentJsonparser.Tag0200> tag0200 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0200;
                if(tags.containsIgnoreCase('tag0200') && tag0200 != null && !tag0200.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0200(tag0200,shipmentMap.get('Tag0200')));
                }
            }
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0600 != null ){
                List<ShipmentJsonparser.Tag0600> tag0600 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0600;
                if(tags.containsIgnoreCase('tag0620') && tag0600 != null && !tag0600.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0600(tag0600,shipmentMap.get('Tag0620')));
                }
            }
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0120 != null ){
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;
                if(tags.containsIgnoreCase('tag0120') && tag0120 != null && !tag0120.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120')));
                }
            }
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0160 != null ){
                List<ShipmentJsonparser.Tag0160> tag0160 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0160;
                if(tags.containsIgnoreCase('tag0160') && tag0160 != null && !tag0160.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0160(tag0160,shipmentMap.get('Tag0160')));
                }
            }
            
            //SC-7136
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag01g0 != null ){
                List<ShipmentJsonparser.Tag01g0> tag01g0 = thisShipmentData.Tag0000[0].Tag0100[0].Tag01g0;
                if(tags.containsIgnoreCase('tag01g0') && tag01g0 != null && !tag01g0.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag01g0(tag01g0,shipmentMap.get('Tag01g0')));
                }
            }
            
            //SC-9600
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].tag01a0 != null ){
                List<ShipmentJsonparser.Tag01a0> tag01a0 = thisShipmentData.Tag0000[0].Tag0100[0].tag01a0;
                if(tags.containsIgnoreCase('tag01a0') && tag01a0 != null && !tag01a0.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag01a0(tag01a0, shipmentMap.get('Tag01a0')));
                }
            }
            
             //SC-9950
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].tag0900 != null ){
                List<ShipmentJsonparser.Tag0900> tag0900 = thisShipmentData.Tag0000[0].Tag0100[0].tag0900;
                if(tags.containsIgnoreCase('tag0900') && tag0900 != null && !tag0900.isEmpty()){
                    shipmentMapNew.putAll(getFieldValueTag0900(tag0900, shipmentMap.get('Tag0900')));
                }
            }
            
            if(!shipmentMapNew.isEmpty() && shipmentMapNew!=null){
                
                Shipment__C thisShipment =  new Shipment__C();
                
                for(String tempString : shipmentMapNew.keySet()){
                    
                    if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) =='Checkbox'){
                        
                        thisShipment.put(tempString, Boolean.ValueOf(EMPConsumerHandler.getBooleanValue(shipmentMapNew.get(tempString))));
                        
                    }
                    else if(tempString == 'Place_of_Delivery_Id__c' || tempString == 'Place_of_Receipt_Id__c' ) {
                        
                        Geography__c ref = new Geography__c(GEO_ID__c = shipmentMapNew.get(tempString));
                        
                        if(tempString == 'Place_of_Delivery_Id__c'){
                            
                            thisShipment.Place_of_Delivery_Id__r =  ref;
                        }
                        if(tempString == 'Place_of_Receipt_Id__c'){
                            
                            thisShipment.Place_of_Receipt_Id__r =  ref;
                        }
                    }
                    else {
                        thisShipment.put(tempString, shipmentMapNew.get(tempString));
                    }
                }
                shipmentList.add(thisShipment);
                
            }
        }
        
        return shipmentList;
        
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0110  Data |
* @param tag0110 accepts tag0110 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0110(List<ShipmentJsonparser.Tag0110> tag0110, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        //	tag100Ref.ge
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0110!= null && !tag0110.isEmpty()){
            for(ShipmentJsonparser.Tag0110 tagRef : tag0110){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                    
                }
            }
        }
		return shipmentMapReturn;
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0160  Data |
* @param tag0160 accepts tag0160 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0160(List<ShipmentJsonparser.Tag0160> tag0160, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        //	tag100Ref.ge
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0160!= null && !tag0160.isEmpty()){
            for(ShipmentJsonparser.Tag0160 tagRef : tag0160){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                    
                }
            }
        }
        
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0100  Data |
* @param tag0100 accepts tag0100 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0100(List<ShipmentJsonparser.Tag0100> tag0100, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        //	tag100Ref.ge
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0100!= null && !tag0100.isEmpty()){
            for(ShipmentJsonparser.Tag0100 tagRef : tag0100){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    //for tag100, we need to check the referencetypeField to get booking number
                    if(temp == 'Service_Mode__c' && shipmentDataMap.get(temp).Reference_Field__c != '' && (String)shipmentDataMap.get(temp).Reference_Field__c == 'receiptDeliveryModeDel'){
                        
                        String serviceMode = ''+obj.get(shipmentDataMap.get(temp).Field_Value__C)+'/'+obj.get(shipmentDataMap.get(temp).Reference_Field__c) +'';
                        shipmentMapReturn.put(temp, serviceMode);
                        
                    }
                    else{
                        shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                    }
                }
            }
        }
        
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0120  Data |
* @param tag0120 accepts tag0120 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0120(List<ShipmentJsonparser.Tag0120> tag0120, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0120!= null && !tag0120.isEmpty()){
            for(ShipmentJsonparser.Tag0120 tagRef : tag0120){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    //for tag120, we need to check the referencetypeField to get booking number
                    if(shipmentDataMap.get(temp).Reference_Field__c != '' && (String)obj.get(shipmentDataMap.get(temp).Reference_Field__c) == shipmentDataMap.get(temp).Reference_Field_Value__c){
                        
                        shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                        
                    }
                }
            }
        }
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0200  Data |
* @param tag0200 accepts tag02000 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0200(List<ShipmentJsonparser.Tag0200> tag0200, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0200!= null && !tag0200.isEmpty()){
            for(ShipmentJsonparser.Tag0200 tagRef : tag0200){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    //for tag200, we need to check the referencetypeField to get booking by customer
                    if(temp == 'Booked_By_Customer_SCV_Code__c' && shipmentDataMap.get(temp).Reference_Field__c != '' && (String)obj.get(shipmentDataMap.get(temp).Reference_Field__c) == shipmentDataMap.get(temp).Reference_Field_Value__c){
                        
                        shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                        break;
                    }
                    if(temp == 'Price_Owner_SCV_Code__c' && shipmentDataMap.get(temp).Reference_Field__c != '' && (String)obj.get(shipmentDataMap.get(temp).Reference_Field__c) == shipmentDataMap.get(temp).Reference_Field_Value__c){
                        
                        shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__C));
                        break;
                    }
                }
                
            }
        }
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-5462  Get Shipment Tag0600  Data |
* @param tag0600 accepts tag0600 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0600(List<ShipmentJsonparser.Tag0600> tag0600, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag0600!= null && !tag0600.isEmpty()){
            String sReceipt ;
            Map<String,Object> objReceipt ;
            String sDelivery ;
            Map<String,Object> objDelivery ;
            
            for(ShipmentJsonparser.Tag0600 tagRef : tag0600){
                
                //consider the 600 node where 610.route type = 'Operation Route' then break the loop else continue
                if(tagRef.Tag0610[0] != null && tagRef.Tag0610[0].routeType == 'Operational Route'){
                    List<ShipmentJsonparser.Tag0620> tag0620 = tagRef.Tag0620;
                    for(ShipmentJsonParser.Tag0620 tagRef1 : tag0620){
                        if(tagRef1 != null && tagRef1.tag0621 != null){
                            if(tagRef1.Tag0621[0]!= null && tagRef1.Tag0621[0].routePointRoleType == 'Place of Receipt'){
                                
                                sReceipt = JSON.serialize(tagRef1);
                                objReceipt =  (Map<String,Object>) JSON.deserializeUntyped(sReceipt);
                                continue;
                            }
                            if(tagRef1.Tag0621[0]!= null && tagRef1.Tag0621[0].routePointRoleType == 'Place of Delivery'){
                                sDelivery = JSON.serialize(tagRef1);
                                objDelivery =  (Map<String,Object>) JSON.deserializeUntyped(sDelivery);
                                
                                continue;
                            }
                            if(sDelivery != null && sReceipt != null){
                                break;
                            }
                            
                        }
                    }
                }
            }
            
            if(sReceipt != null && sDelivery != null){
                for(String temp: shipmentDataMap.keySet()){
                    //for tag600, we need to check the referencetypeField to get place of receipt id
                    if(temp == 'Place_of_Receipt_Id__c' && objReceipt != null){
                        
                        shipmentMapReturn.put(temp, (String)objReceipt.get(shipmentDataMap.get(temp).Field_Value__C));
                    }
                    if(temp == 'Place_of_Delivery_Id__c' && objDelivery!= null){
                        
                        shipmentMapReturn.put(temp, (String)objDelivery.get(shipmentDataMap.get(temp).Field_Value__C));
                    }
                    if(temp == 'Place_of_Delivery__c' && objDelivery!= null){
                        
                        shipmentMapReturn.put(temp, (String)objDelivery.get(shipmentDataMap.get(temp).Field_Value__C));
                    }
                    if(temp == 'Place_of_Receipt__c' && objReceipt!= null){
                        
                        shipmentMapReturn.put(temp, (String)objReceipt.get(shipmentDataMap.get(temp).Field_Value__C));                     
                    }
                }
                
            }
        }
        
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-7136  Get Shipment Tag01g0  Data |
* @param tag01g0 accepts tag01g0 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag01g0(List<ShipmentJsonparser.Tag01g0> tag01g0, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        
        if(tag01g0!= null && !tag01g0.isEmpty()){
            for(ShipmentJsonparser.Tag01g0 tagRef : tag01g0){
                
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    
                    //for tag01g0, we need to check the referencetypeField to check the PropertyTypeValue
                    if(temp == 'Property_Type_Name__c' && shipmentDataMap.get(temp).Reference_Field__c != '' && shipmentDataMap.get(temp).Reference_Field__c == 'bksValue'){
                        
                        String fieldValue = String.valueOf(obj.get(shipmentDataMap.get(temp).Field_Value__C));
                        if(fieldValue.containsIgnoreCase(shipmentDataMap.get(temp).Reference_Field_Value__c)){
                            shipmentMapReturn.put(temp, (String)shipmentDataMap.get(temp).Reference_Field_Value__c);
                            break;
                        }else{
                            
                            continue;
                        }
                    }
                }
                
            }
        }
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-9586  Get cancelled Shipment Tag Data |
* @param shipmentMap accepts the Map of Metadata
* @param shipmentData accepts the shipment Data
* @param tags accepts the list of Tags
* @param sObjectName accepts Name of the object
* @return List of sobject 
*/
    public static List<sObject> getCancelledShipmentTagData(Map<String, Map<String, EMP_Consumer_settings__mdt>> mapShipment, List<ShipmentCancelledJsonParser> shipmentData, String sObjectName,Map<String,String> mapCancelledStatusValues){
        List<sObject> lstShipmentToUpdate = new List<sObject>();        
        for(ShipmentCancelledJsonParser shpData : shipmentData){
            Map<String, String> mapNewshipment = new Map<String, String>(); 
            String s = JSON.serialize(shpData);
            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
            for(String temp: mapShipment.get('Cancelled').keySet()){  
                if(temp == 'Shipment_Status__c'){
                    mapNewshipment.put(temp, mapCancelledStatusValues.get((String)obj.get(mapShipment.get('Cancelled').get(temp).Field_Value__c)));
                }else{
                    mapNewshipment.put(temp, (String)obj.get(mapShipment.get('Cancelled').get(temp).Field_Value__c)); 
                }
            }            
            
            if(!mapNewshipment.isEmpty() && mapNewshipment!=null){
                Shipment__c thisShipment =  new Shipment__c();
                for(String tempString : mapNewshipment.keySet()){
                    thisShipment.put(tempString, mapNewshipment.get(tempString));
                }
                lstShipmentToUpdate.add(thisShipment);                
            }
        }        
        return lstShipmentToUpdate;
    }
    
       
 /** 
* @description | SC-9950  Get Shipment Tag0900  Data |
* @param tag0900 accepts tag0900 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag0900(List<ShipmentJsonparser.Tag0900> tag0900, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        List<ShipmentJsonparser.Tag0910> tag09100List = tag0900[0].tag0910;
        if(tag09100List!= null && !tag09100List.isEmpty()){
            for(ShipmentJsonparser.tag0910 tagRef : tag09100List){
                
               if(tagRef.fkMarsRulesFreightType != '' && tagRef.fkMarsRulesFreightType == 'BASOBK'){

                    String s = JSON.serialize(tagRef);
                    Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                   
                    for(String temp: shipmentDataMap.keySet()){

                        //for tag0910, we need to check the referencetypeField to check the Property_Type_Name_BKS__c
                        if(temp == 'Property_Type_Name_BKS__c' && shipmentDataMap.get(temp).Reference_Field__c != '' && shipmentDataMap.get(temp).Reference_Field__c == 'fkMarsRulesFreightType' && shipmentDataMap.get(temp).Reference_Field_Value__c != '' && shipmentDataMap.get(temp).Reference_Field_Value__c == 'BASOBK'){
                            
                            shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__c));
                            break; //break from shipmentDataMap loop
                        }
                        else{
                            continue;
                        }
                    }
	             break; //break from main loop
               }
               else{
                   continue;
               }
            }
        }
        return shipmentMapReturn;
    }
    
    /** 
* @description | SC-9600  Get Shipment Tag01a0  Data |
* @param tag01a0 accepts tag01a0 data
* @param shipmentDataMap accepts Map of Shipment Data
* @return Map of Field value 
*/
    public static Map<String, String> getFieldValueTag01a0(List<ShipmentJsonparser.Tag01a0> tag01a0, Map<String, EMP_Consumer_settings__mdt>  shipmentDataMap){
        Map<String, String> cargoValuesMap = getCargoValuesMap();
        Map<String, String> shipmentMapReturn  = new Map<String, String>();
        if(tag01a0!= null && !tag01a0.isEmpty()){
            for(ShipmentJsonparser.tag01a0 tagRef : tag01a0){
                String s = JSON.serialize(tagRef);
                Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);
                for(String temp: shipmentDataMap.keySet()){
                    if(temp == 'Cargo_Type__c'){
                        String cargoType = (String)obj.get(shipmentDataMap.get(temp).Field_Value__c);
                        if(obj.get('applies') == 'Y' && cargoValuesMap.containsKey(cargoType)){
                            if(shipmentMapReturn.isEmpty() || !shipmentMapReturn.containsKey(temp)){
                                shipmentMapReturn.put(temp, cargoValuesMap.get(cargoType));
                            }
                            else{
                                shipmentMapReturn.put(temp, shipmentMapReturn.get(temp)+';'+cargoValuesMap.get(cargoType));
                            }
                        }
                    }
                    else{
                        shipmentMapReturn.put(temp, (String)obj.get(shipmentDataMap.get(temp).Field_Value__c));
                    }
                    
                }
            }
        }
        system.debug('***shipmentMapReturn--->'+shipmentMapReturn);
        return shipmentMapReturn;
    }
    
    public static Map<String, String> getCargoValuesMap(){
        Map<String, String> cargoValuesMap = new Map<String, String>();
        cargoValuesMap.put('Live Reefer', 'Reefer');
        cargoValuesMap.put('Dangerous or Hazardous', 'Dangerous Cargo');
        cargoValuesMap.put('OOG', 'Out-of-gauge');
        cargoValuesMap.put('Break Bulk', 'Break Bulk');
        cargoValuesMap.put('Dry', 'Dry');
        return cargoValuesMap;
    }
    
}