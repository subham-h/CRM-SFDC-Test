/** 
* @description 
* Author   : Vivek
* Purpose  : EMP consumer handler class to call specific classes for Shipment, TPDoc and Geography record creations.
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agrawal          Created handler class to call shipment and tpdoc classes with base data.
* 2.0      SC-7773     18-April-2023 Vivek Agrawal         Modified the Class to call partiesManagerClass() with synchronous call.
* 3.0      SC-9586     05-Feb-2024  Richa@Maersk           Added Shipment Cancelled event consumption method                                                              
*/
public class EMPConsumerHandler {
    
    public static void processShipmentData(List<ShipmentJsonParser> shipmentData){
        
        system.debug('--shipmentData'+shipmentData);
        
        //get metadata records to process per class
        
        Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentsFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> cargosFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> equipmentsFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> tpDocFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> equipmentStuffingFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> partiesFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        
        for(EMP_Consumer_settings__mdt cdtt : [SELECT Id, MasterLabel, DeveloperName, Field_Value__c, Json_Key__c, Reference_Field__c, Reference_Field_Value__c, Topic_Type__c FROM EMP_Consumer_settings__mdt WHERE DeveloperName Like '%Tag%']){
            
            //forming Shipment Map from metadata
            if(cdtt.DeveloperName.contains('ShipmentNode')){
                if(shipmentsFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    shipmentsFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    shipmentsFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            //forming Cargo Map from metadata
            if(cdtt.DeveloperName.contains('CargoNode')){
                if(cargosFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    cargosFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    cargosFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            
            //forming Equipments Map from metadata
            if(cdtt.DeveloperName.contains('EquipmentNode')){
                if(equipmentsFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    equipmentsFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    equipmentsFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            //forming Equipments Stuffing Map from metadata
            if(cdtt.DeveloperName.contains('EquipmentStuffingsNode')){
                if(equipmentStuffingFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    equipmentStuffingFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    equipmentStuffingFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            //forming TP DOC Stuffing Map from metadata
            if(cdtt.DeveloperName.contains('TPDocNode')){
                if(tpDocFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    tpDocFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    tpDocFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            //forming PartiesMap from metadata
            if(cdtt.DeveloperName.contains('PartiesNode')){
                if(partiesFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    partiesFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    partiesFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            
            
        }
        
        
        //get Shipment Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt shipmentTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerShipmentNodes');
        
        //call ShipmentManagerClass class to create Shipment records via createShipmentRecords()
        ShipmentManagerClass.createShipmentRecords(shipmentTags.First_Field_Value__c, shipmentData, shipmentsFieldValueMap);
        
        //get TP DOC Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt tpDocTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerTPDocNodes');
        
        //call TPDocManagerClass class to create tpDoc records via createTPDocRecords()
        TPDocManagerClass.createTPDocRecords(tpDocTags.First_Field_Value__c, shipmentData, tpDocFieldValueMap);
        
        //get Cargo Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt cargoTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerCargoNodes');
        
        //call CargoManagerClass class to create Cargo records via createCargoRecords()
        CargoManagerClass.createCargoRecords(cargoTags.First_Field_Value__c, shipmentData, cargosFieldValueMap);
        
        //get Equipment Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt equipmentTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerEquipmentNodes');
        
        //call EquipmentManagerClass class to create Equipment records via createEquipmentRecords()
        EquipmentManagerClass.createEquipmentRecords(equipmentTags.First_Field_Value__c, shipmentData, equipmentsFieldValueMap);
        
        //get Equipment Stuffing Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt equipmentStuffingTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerEquipmentStuffingNodes');
        
        //call EquipmentManagerClass class to create EquipmentStuffing records via createEquipmentStuffingRecords()
        EquipmentManagerClass.createEquipmentStuffingRecords(equipmentStuffingTags.First_Field_Value__c, shipmentData, equipmentStuffingFieldValueMap);
        
        //get Parties Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt partiesTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerPartiesNodes');
        
        //call PartiesManagerClass class to create Parties records via createPartiesRecords()
        PartiesManagerClass.createPartiesRecords(partiesTags.First_Field_Value__c,shipmentData,partiesFieldValueMap);
        
        //get VesselRouting Node tags from General Key Value metadata
        String jsonStringVesselRouting = json.serialize(shipmentData);
        
        //call VesselRoutingManagerClass class to create Vessel Routing records via createVesselRoutingRecords()
        VesselRoutingManagerClass.createVesselRoutingRecords(jsonStringVesselRouting);
        
    }
    
    public static void ProcessTPDocEventData(List<TpDocJsonParser> tpDocData){
        
        
        Map<String, Map<String, EMP_Consumer_settings__mdt>> tpDocFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String, Map<String, EMP_Consumer_settings__mdt>> partiesFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        
        for(EMP_Consumer_settings__mdt cdtt : [SELECT Id, MasterLabel, DeveloperName, Field_Value__c, Json_Key__c, Reference_Field__c, Reference_Field_Value__c, Topic_Type__c FROM EMP_Consumer_settings__mdt WHERE DeveloperName Like '%TPDocEvent%']){
            
            //forming TP DOC Map from metadata
            if(cdtt.DeveloperName.contains('TPDocEventTPDocNode')){
                if(tpDocFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    tpDocFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{
                    
                    tpDocFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
            //forming Paties Tp DOC Map from metadata
            if(cdtt.DeveloperName.contains('TPDocEventPartiesNode')){
                if(partiesFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){
                    
                    partiesFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                    
                }else{
                    
                    partiesFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            }
        }
        
        system.debug('--tpDocData'+tpDocData);
        
        //get TP DOC Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt tpDocTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerTPDOCEventTPDocNodes');
        
        //call TPDocManagerClass class to create tpDoc records via createTPDocRecords()
        TPDocManagerClass.createTPDOCEventTPDocRecords(tpDocTags.First_Field_Value__c, tpDocData, tpDocFieldValueMap);
        
        //get Parties Node tags from General Key Value metadata
        General_Key_Value_Configurations__mdt partiesTags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerTPDocEventPartiesNodes');
        
        PartiesManagerClass.createTPDOCEventPartiesRecords(partiesTags.First_Field_Value__c,tpDocData,partiesFieldValueMap);
        
        
    }
    
    /* public static void ProcessGeographyData(List<GeographyEventParser> geoData){

system.debug('--geoData'+geoData);

//get metadata records to process per class

Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();


for(EMP_Consumer_settings__mdt cdtt : [SELECT Id, MasterLabel, DeveloperName, Field_Value__c, Json_Key__c, Reference_Field__c, Reference_Field_Value__c, Topic_Type__c FROM EMP_Consumer_settings__mdt WHERE DeveloperName Like 'GeographyNode%']){

//forming Geo Map from metadata
if(geographyFieldValueMap.containsKey(cdtt.DeveloperName.split('_')[1])){

geographyFieldValueMap.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
}else{

geographyFieldValueMap.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});

}
}

system.debug('--geographyFieldValueMap'+geographyFieldValueMap);

if(!geographyFieldValueMap.isEmpty() && geographyFieldValueMap!=null){

//call GeographyManagerClass class to create Geography records via createGeographyRecords()
GeographyManagerClass.createGeographyRecords(geoData, geographyFieldValueMap);
}

}
*/
  
 /** 
* @description | SC-9586-  Process Cancelled Shipment events |
* @param lstCancelledShipmentData accepts a list of parsed Cancelled Shipment events
*/  
    public static void processShipmentCancelledEventData(List<ShipmentCancelledJsonParser> lstCancelledShipmentData){
        Map<String, Map<String, EMP_Consumer_settings__mdt>> mapShipmentCancelledFieldValues = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
        Map<String,String> mapCancelledStatusValues = new Map<String,String>();
        for(EMP_Consumer_settings__mdt cdtt : [SELECT Id, MasterLabel, DeveloperName, Field_Value__c, Json_Key__c, Reference_Field__c, Reference_Field_Value__c, Topic_Type__c FROM EMP_Consumer_settings__mdt WHERE DeveloperName LIKE '%ShipmentCancelledNode%']){           
            if(cdtt.DeveloperName.contains('ShipmentCancelledNode')){
                if(mapShipmentCancelledFieldValues.containsKey(cdtt.DeveloperName.split('_')[1])){                        
                    mapShipmentCancelledFieldValues.get(cdtt.DeveloperName.split('_')[1]).put(cdtt.Json_Key__c, cdtt);
                }else{                        
                    mapShipmentCancelledFieldValues.put(cdtt.DeveloperName.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.Json_Key__c =>cdtt});
                    
                }
            } 
        }     
        
        //get Cancelled Status values from General Key Value metadata
        for(General_Key_Value_Configurations__mdt mdt : [SELECT Id,First_Field_Name__c,First_Field_Value__c,Second_Field_Name__c,Second_Field_Value__c,Key__c FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'ShipmentCancelledStatus']){
            mapCancelledStatusValues.put(mdt.First_Field_Value__c,mdt.Second_Field_Value__c); 
        }       
        //call ShipmentManager class to update status of Shipment as Cancelled
        ShipmentManagerClass.cancelShipmentRecords(lstCancelledShipmentData, mapShipmentCancelledFieldValues,mapCancelledStatusValues);
    }
    
    
    public static Map<String, String> getFieldDataType(String objectName){
        Map<String, String> fieldDataTypeMap = new Map<String, String>();
        List<FieldDefinition> fldDefList=[SELECT DataType, QualifiedAPIName FROM FieldDefinition WHERE EntityDefinitionId=:objectName ];
        for(FieldDefinition tempString : fldDefList){
            
            fieldDataTypeMap.put(tempString.QualifiedAPIName, tempString.DataType);
            
            system.debug('--field'+fieldDataTypeMap);
            
        }
        
        return fieldDataTypeMap;
        
    }
    
    public static Boolean getBooleanValue(String value){
        Boolean booleanValue =false;
        if(value == 'N' || value == 'n' || value == 'No' || value == 'NO' || value == 'InActive' || value == 'INACTIVE' || value == 'false' || value == 'FALSE')
            booleanValue = false;
        else if(value == 'Y' || value == 'y' || value == 'Yes' || value == 'YES' || value == 'Active' || value == 'ACTIVE' || value == 'true' || value == 'TRUE')
            booleanValue = true;
        
        return booleanValue;
        
    }
    
    public static DateTime getDateTimeValue(String value){
        DateTime dt;
        
        return dt;
        
    }
    
    public static Date getDateValue(String value){
        Date dt;
        
        return dt;
        
    }
    
    public static Date getDateValueFromEpocDays(Integer value){
        
        Integer IntTime = value;
        DateTime dt = DateTime.newInstance(IntTime);       
        Date myDate = dt.date().addDays(IntTime);
        if(myDate.YEAR() < 1700) {
            myDate = Date.newInstance(1701, mydate.month(),mydate.day());
        }if (myDate.YEAR() > 4000) {
            myDate = Date.newInstance(3999, mydate.month(),mydate.day());
        }
        
        system.debug('--'+myDate);
        return myDate;
        
    }
    
    
}