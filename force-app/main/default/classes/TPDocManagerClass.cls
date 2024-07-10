/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage TP Doc Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agarwal          Created and optimized for creating or updating TP Doc records.
*/
public class TPDocManagerClass {
     
    /** 
      * @description | SC-5462  Create TP Doc Records |
      * @param tags accepts the list of Tags
      * @param shipmentData accepts the shipment Data
      */
    public static void createTpDocRecords(String tags, List<ShipmentJsonParser> shipmentData, Map<String, Map<String, EMP_Consumer_settings__mdt>> tpDocFieldValueMap){
        
        List<SObject> sObjects = new List<SObject>();
    
        try{
                           
            Schema.SObjectField f = TP_Doc__c.Fields.TP_Doc_Number__c;
            if(!tpDocFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataTPDoc(tpDocFieldValueMap, shipmentData, tags, 'TP_Doc__c'));
            }
                                                             
            List<SObject> tpDocsToUpload = new List<SObject>();
            tpDocsToUpload.addAll(sObjects);
                
            Database.Upsert(tpDocsToUpload, f, true);       
        
        }catch(exception ex){
        
            if( !String.valueOf(ex.getMessage()).contains('MISSING_ARGUMENT, TP_Doc_Number__c') ||    !String.valueOf(ex.getCause()).contains('MISSING_ARGUMENT, TP_Doc_Number__c') ){

                ErrorLogger.writeError( 'Shipment Events', 'TP_Doc__c', 'TPDocManagerClass.createTpDocRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
        
            }
        }
        
    }
        
    /** 
      * @description | SC-5462  Create TP Doc Records |
      * @param tags accepts the list of Tags
      * @param tpDocData accepts the Tp Doc Data
      */
    public static void createTPDOCEventTPDocRecords(String tags, List<TpDocJsonParser> tpDocData, Map<String, Map<String, EMP_Consumer_settings__mdt>> tpDocFieldValueMap){

        
        List<SObject> sObjects = new List<SObject>();
        try{
                                    
            Schema.SObjectField f = TP_Doc__c.Fields.TP_Doc_Number__c;
            if(!tpDocFieldValueMap.isEmpty()){
                sObjects.addAll(getTagDataTPDocEvent(tpDocFieldValueMap.get('Tag2120'), tpDocData, tags, 'TP_Doc__c'));
            }

            List<SObject> tpDocsToUpload = new List<SObject>();
            tpDocsToUpload.addAll(sObjects);
                
            Database.Upsert(tpDocsToUpload, f, true);       
        
        }catch(exception ex){
            //insert the records again if it has failed due to Shipment_number__c not present in SFDC

            if(ex.getMessage().contains('Shipment_Number__c')){
                try{
                //retry tp doc creation without shipment number
                    if(!tpDocFieldValueMap.isEmpty()){
                        List<SObject> sObjectsRetry = new List<SObject>();
                        Map<String, EMP_Consumer_settings__mdt> tpDocUpdatedMap = tpDocFieldValueMap.get('Tag2120');
                        
                        tpDocUpdatedMap.remove('Shipment_Number__c');

                        Schema.SObjectField f = TP_Doc__c.Fields.TP_Doc_Number__c;
                        system.debug('--Retry tpdoc map'+tpDocFieldValueMap);
                        sObjectsRetry.addAll(getTagDataTPDocEvent(tpDocUpdatedMap, tpDocData, tags, 'TP_Doc__c'));
                        List<SObject> tpDocsToUploadRetry = new List<SObject>();
                        tpDocsToUploadRetry.addAll(sObjectsRetry);
                        system.debug('--sObjectsBeforeInsertRetry'+tpDocsToUploadRetry);
                    
                        Database.Upsert(tpDocsToUploadRetry, f, true);       
            
                    }
                }catch(exception e){
                    ErrorLogger.writeError( 'TPDoc Events Retry', 'TP_Doc__c', 'TPDocManagerClass.createTPDOCEventTPDocRecords', e.getMessage(), e.getStackTraceString() ,String.valueOf(e.getCause()) );
                    
                }
            }else{
                ErrorLogger.writeError( 'TPDoc Events', 'TP_Doc__c', 'TPDocManagerClass.createTPDOCEventTPDocRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
                }
        }
        
    }

        /** 
        * @description | SC-5462  Get TP Doc Tag Data |
        * @param tpDocFieldValueMap accepts the Map of Metadata
        * @param tpDocData accepts the TP Doc Data
        * @param tags accepts the list of Tags
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<sObject> getTagDataTPDocEvent(Map<String, EMP_Consumer_settings__mdt> tpDocFieldValueMap, List<TpDocJsonParser> tpDocData, String tags, String sObjectName){
                
            List<sObject> tpDocList = new List<sObject>();
    
            Map<String, String> tpDocFieldValueMapNew ;
        
            Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
                
            for(TpDocJsonParser thisTPDocData : tpDocData){
                  
                if(thisTPDocData.Tag0000[0].Tag2100[0] != null && thisTPDocData.Tag0000[0].Tag2100[0].Tag2120 != null ){
                    List<TpDocJsonParser.Tag2120> tag2120 = thisTPDocData.Tag0000[0].Tag2100[0].Tag2120;
    
                    tpDocFieldValueMapNew = getFieldValueMapTag2120(tag2120,tpDocFieldValueMap);
    
                    if(tags.containsIgnoreCase('tag2120') && tag2120 != null && !tag2120.isEmpty()){
                                        
                        tpDocList.addAll(getFieldValueTag2120(tpDocFieldValueMapNew, fieldDataTypeMap));
                
                    }
                }
            }
            
            return tpDocList;
        
        }
        
        /** 
        * @description | SC-5462  Get TP DOc Tag Data |
        * @param shipmentMap accepts the Map of Metadata
        * @param shipmentData accepts the shipment Data
        * @param tags accepts the list of Tags
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<sObject> getTagDataTPDoc(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
                
            List<sObject> tpDocList = new List<sObject>();
    
            Map<String, String> shipmentMapNew ;
        
            Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
                
            for(ShipmentJsonParser thisShipmentData : shipmentData){                              
                  
                if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0120 != null ){
                    List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;
    
                    shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));
    
                    if(tags.containsIgnoreCase('tag0120') && tag0120 != null && !tag0120.isEmpty()){
                                        
                        tpDocList.addAll(getFieldValueTag0120(shipmentMapNew, fieldDataTypeMap));                
                    }
                }
            }
            
            return tpDocList;
        
        }
            
        /** 
        * @description | SC-5462  Get Shipment Tag0120  Data |
        * @param shipmentMapNew accepts Map of Shipment Data
        * @param fieldDataTypeMap accepts Map of Field Type Data
        * @return List of Field value 
        */ 
        public static List<sObject> getFieldValueTag0120(Map<String, String> shipmentMapNew, Map<String, String> fieldDataTypeMap){
            //	tag100Ref.ge
        
            List<sObject> tpDocList = new List<sObject>();
            Map<String, String> shipmentvalueMapNew = shipmentMapNew;
            if(shipmentMapNew!= null && !shipmentMapNew.isEmpty() ){
                       
                tpDocList.add(gettpDocRecord(shipmentvalueMapNew, fieldDataTypeMap));
            }
    
            return tpDocList;
        }
    
        /** 
        * @description | SC-5462  Get TP Doc Record |
        * @param shipmentMapNew accepts Map of Shipment Data
        * @param fieldDataTypeMap accepts Map of Field Type Data
        * @return Tp Doc Record 
        */
        public static TP_Doc__c getTpDocRecord(Map<String, String> shipmentMapNew, Map<String, String> fieldDataTypeMap){
                //	tag100Ref.ge
    
            TP_Doc__c thistpDoc = new TP_Doc__c();
                
            if(fieldDataTypeMap.containsKey('TP_Doc_Number__c') ){
                            
                thistpDoc.TP_Doc_Number__c =  shipmentMapNew.get('TP_Doc_Number__c');
            }
            if(shipmentMapNew.containsKey('Shipment_Number__c') && fieldDataTypeMap.containsKey('Shipment_Number__c') && fieldDataTypeMap.get('Shipment_Number__c') == 'Lookup(Shipment)'){
                
                Shipment__c ref = new Shipment__c(shipment_number__c = shipmentMapNew.get('Shipment_Number__c'));
                    
                thistpDoc.shipment_number__r =  ref;
    
                    
            }
            
                            
            return thistpDoc;
        
        }

        /** 
        * @description | SC-5462  Get Tag2120 Dara |
        * @param tpDocMapNew accepts Map of TP Doc Data
        * @param fieldDataTypeMap accepts Map of Field Type Data
        * @return List of Field value 
        */
        public static List<sObject> getFieldValueTag2120(Map<String, String> tpDocMapNew, Map<String, String> fieldDataTypeMap){
            //	tag100Ref.ge
        
            List<sObject> tpDocList = new List<sObject>();
            Map<String, String> tpDocMapUpdateNew = tpDocMapNew;
            if(tpDocMapUpdateNew!= null && !tpDocMapUpdateNew.isEmpty() ){
                       
                tpDocList.add(getTpDocRecord(tpDocMapUpdateNew, fieldDataTypeMap));
            }
    
            return tpDocList;
        }

        /** 
        * @description | SC-5462  Get Tag2120 Dara |
        * @param tag2120 accepts tag2120 Data
        * @param tpDocDataMap accepts Map of TP Doc Data
        * @return Map of Field value 
        */
        public static Map<String, String> getFieldValueMapTag2120(List<TpDocJsonParser.Tag2120> tag2120, Map<String, EMP_Consumer_settings__mdt>  tpDocDataMap){
       
            Map<String, String> tpDocMapReturn  = new Map<String, String>();
    
            if(tag2120!= null && !tag2120.isEmpty()){
                for(TpDocJsonParser.Tag2120 tagRef : tag2120){
             
                    String s = JSON.serialize(tagRef);
                    Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
                    for(String temp: tpDocDataMap.keySet()){
                        
                        //for tag2120, we need to check the referencetypeField to get booking number
                        if(tpDocDataMap.get(temp).Reference_Field__c != '' && (String)obj.get(tpDocDataMap.get(temp).Reference_Field__c) == tpDocDataMap.get(temp).Reference_Field_Value__c){
                            
                            tpDocMapReturn.put(temp, (String)obj.get(tpDocDataMap.get(temp).Field_Value__C));
                   
                        }
                    }
                }
           }
            return tpDocMapReturn;
        }
    }