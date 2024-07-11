/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Vessel Routing Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5462     02-Sept-2022 Vivek Agarwal          Created and optimized for creating or updating Vessel Routing records.
*/
public with sharing class VesselRoutingManagerClass {
    
    Public static Set<String> vesselRouteId;

    /** 
      * @description | SC-5462  Create Vessel Routing Records |
      * @param jsonStringVesselRouting accepts json string of Vessel Routing
      */
    @future(callout = true)
    public static void createVesselRoutingRecords(String jsonStringVesselRouting){
        
            List<ShipmentJsonParser> shipmentData = (List<ShipmentJsonParser>)Json.deserialize(jsonStringVesselRouting,List<ShipmentJsonParser>.class);

            //get Parties Node tags from General Key Value metadata
            General_Key_Value_Configurations__mdt tags = General_Key_Value_Configurations__mdt.getInstance('EmpConsumerVesselRoutingNodes');
       
            List<Vessel_Routing__x> vesselRoutingList = new List<Vessel_Routing__x>();
            List<Vessel_Routing__x> vesselRoutingListToUpload = new List<Vessel_Routing__x>();
            List<Vessel_Routing__x> vesselRoutingListToUpdate = new List<Vessel_Routing__x>();

            Map<String, EMP_Consumer_settings__mdt> cdtt = EMP_Consumer_settings__mdt.getAll();
            Map<String, Map<String, EMP_Consumer_settings__mdt>> vesselRoutingFieldValueMap = new Map<String, Map<String, EMP_Consumer_settings__mdt>>();
            try{
                for(String tempString : cdtt.keySet()){
                    if(tempString.contains('VesselRoutingNode')){
                        if(vesselRoutingFieldValueMap.containsKey(tempString.split('_')[1])){
                                
                            vesselRoutingFieldValueMap.get(tempString.split('_')[1]).put(cdtt.get(tempString).Json_Key__c, cdtt.get(tempString));
                        }else{
                                
                            vesselRoutingFieldValueMap.put(tempString.split('_')[1], new Map<String, EMP_Consumer_settings__mdt>{cdtt.get(tempString).Json_Key__c =>cdtt.get(tempString)});
        
                        }
                    }
                }
        
                if(!vesselRoutingFieldValueMap.isEmpty()){
                    vesselRoutingList.addAll(getTagDataVesselRoutes(vesselRoutingFieldValueMap, shipmentData, tags.First_Field_Value__c, 'Vessel_Routing__x'));
                }                   
                if(!vesselRoutingList.isEmpty()){

                   // List<Vessel_Routing__x> listsobject = new list<Vessel_Routing__x>();
                    Map<String, Vessel_Routing__x> vesselRouteMap = new Map<String, Vessel_Routing__x>();

                    for(Vessel_Routing__x thisVesselRoute : [Select routing_id__c, shipment_number__c from Vessel_Routing__x Where routing_id__c IN : (vesselRouteId)]){

                        vesselRouteMap.put(thisVesselRoute.routing_id__c, thisVesselRoute);

                    }
                    for(Vessel_Routing__x thisVesselRoute : vesselRoutingList){
                        if(!vesselRouteMap.isEmpty() && vesselRouteMap.containsKey(thisVesselRoute.routing_id__c)){
                            thisVesselRoute.Id = vesselRouteMap.get(thisVesselRoute.routing_id__c).Id;
                            vesselRoutingListToUpdate.add(thisVesselRoute);

                        }else {
                            vesselRoutingListToUpload.add(thisVesselRoute);
                        }
                    }

                    if(vesselRoutingListToUpdate!= null && !vesselRoutingListToUpdate.isEmpty()){
                        database.updateAsync(vesselRoutingListToUpdate);
                    }
    
                    if(vesselRoutingListToUpload!= null && !vesselRoutingListToUpload.isEmpty()){
                        Database.InsertAsync(vesselRoutingListToUpload);
                    }
                }       
                    
            }catch(exception ex){
        
                ErrorLogger.writeError( 'Shipment Events', 'Vessel_Routing__x', 'VesselRoutingManagerClass.createVesselRoutingRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()) );
        
            }
        
    }   

    /** 
    * @description | SC-5462  Get Vessel Routing Tag Data |
    * @param shipmentMap accepts the Map of Metadata
    * @param shipmentData accepts the shipment Data
    * @param tags accepts the list of Tags
    * @param sObjectName accepts Name of the object
    * @return List of sobject 
    */
    public static List<Vessel_Routing__x> getTagDataVesselRoutes(Map<String, Map<String, EMP_Consumer_settings__mdt>> shipmentMap, List<ShipmentJsonParser> shipmentData, String tags, String sObjectName){
                
        List<Vessel_Routing__x> vesselRoutesList = new List<Vessel_Routing__x>();

        Map<String, String> shipmentMapNew ;

        vesselRouteId = new Set<String>();
    
        Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);
            
        for(ShipmentJsonParser thisShipmentData : shipmentData){                          
              
            if(thisShipmentData.Tag0000[0].Tag0100[0] != null && thisShipmentData.Tag0000[0].Tag0100[0].Tag0200 != null ){
                List<ShipmentJsonparser.Tag0600> tag0600 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0600;
                List<ShipmentJsonparser.Tag0120> tag0120 = thisShipmentData.Tag0000[0].Tag0100[0].Tag0120;
                List<ShipmentJsonparser.Tag0620> tag0620 ;
                List<ShipmentJsonparser.Tag0630> tag0630 ;

                shipmentMapNew = ShipmentManagerClass.getFieldValueTag0120(tag0120,shipmentMap.get('Tag0120'));

                if(tag0600 != null && !tag0600.isEmpty()){

                    for(ShipmentJsonparser.Tag0600 tagRef : tag0600){
                
                        ShipmentJsonparser.Tag0610 tag0610 = tagRef.Tag0610[0];
        
                        String s = JSON.serialize(tag0610);
                        Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
        
                        if(tag0610!= null && !tag0600.isEmpty() && (String) obj.get('routeType') == 'Operational Route'){
                            
                            tag0620 = tagRef.Tag0620;
                            tag0630 = tagRef.Tag0630;

                            break;

                        }else {
        
                            continue;
                        }
                        
                    }
                    if(tag0630!= null && tag0620 != null){

                        for(ShipmentJsonparser.Tag0630 tagRef : tag0630){
                        
                            vesselRoutesList.addAll(getFieldValueTagData(tag0620, tagRef, shipmentMapNew, shipmentMap.get('Tag0620'),shipmentMap.get('Tag0630'), fieldDataTypeMap));
                        }
                    }

                }
            }
        }

        return vesselRoutesList;
    
    }

    /** 
    * @description | SC-5462  Get Vessel Routing Tag0620 $ Tag0630  Data |
    * @param tag0620 accepts tag0620 data
    * @param tag0630 accepts tag0630 data
    * @param shipmentMapNew accepts the map of shipment data
    * @param tag0620DataMap accepts tag0620 data map with metadata
    * @param tag0630DataMap accepts tag0630 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @return List of sobject 
    */
    public static List<Vessel_Routing__x> getFieldValueTagData( List<ShipmentJsonparser.Tag0620> tag0620 , ShipmentJsonparser.Tag0630 tag0630,Map<String, String> shipmentMapNew, Map<String, EMP_Consumer_settings__mdt>  tag0620DataMap,Map<String, EMP_Consumer_settings__mdt>  tag0630DataMap,  Map<String, String> fieldDataTypeMap){
        //	tag100Ref.ge

        List<Vessel_Routing__x> vesselRoutesList = new List<Vessel_Routing__x>();
        Map<String, String> shipmentvalueMapNew = shipmentMapNew;
        Map<String,Object> objStart ;
        Map<String,Object> objEnd ;
        String routePointRoleType ;


        if(tag0630!= null ){

            String s = JSON.serialize(tag0630);
            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
            
            for(ShipmentJsonparser.Tag0620 tagRef : tag0620){  

                String s1 = JSON.serialize(tagRef);
                Map<String,Object> obj1 =  (Map<String,Object>) JSON.deserializeUntyped(s1);

                if(tagRef.tag0621 != null ){
                    ShipmentJsonparser.Tag0621 tag0621 = tagRef.Tag0621[0];
                    s1 = JSON.serialize(tag0621);
                    Map<String,Object> objTAG0621 =  (Map<String,Object>) JSON.deserializeUntyped(s1);
                    routePointRoleType = (String)objTAG0621.get('routePointRoleType');
                }
                if(obj1.get('instanceId') == obj.get('fkRoutePointStart')){
                    objStart = obj1;
                }
                if(obj1.get('instanceId') == obj.get('fkRoutePointEnd')){
                  
                    objEnd = obj1;
                }

                if(objStart != null && objEnd != null){
                    break;
                }else{
                    continue;
                }

            }

            if(objStart != null && objEnd != null){
                vesselRoutesList.add(getVesselRouteRecord(objStart, objEnd,  tag0630DataMap, obj, tag0620DataMap, fieldDataTypeMap, shipmentvalueMapNew, routePointRoleType));
            }
              
        }

        return vesselRoutesList;
    }

    /** 
    * @description | SC-5462  Get Vessel Routing Record |
    * @param tag0620ObjStart accepts tag0620 map start
    * @param tag0620ObjEnd accepts tag0620 map end
    * @param tag0630DataMap accepts tag0630 data map with metadata
    * @param tag0630Obj accepts tag0630 map data
    * @param tag0620DataMap accepts tag0620 data map with metadata
    * @param fieldDataTypeMap accept field data type map
    * @param shipmentMapNew accepts the map of shipment data
    * @param routePointRoleType accept routepoint role type
    * @return Vessel ROuting Record
    */
    public static Vessel_Routing__x getVesselRouteRecord(Map<String,Object> tag0620ObjStart, Map<String,Object> tag0620ObjEnd, Map<String, EMP_Consumer_settings__mdt>  tag0630DataMap, Map<String,Object> tag0630Obj ,Map<String, EMP_Consumer_settings__mdt>  tag0620DataMap, Map<String, String> fieldDataTypeMap, Map<String, String> shipmentMapNew, String routePointRoleType){
        //	tag100Ref.ge

        Vessel_Routing__x thisVesselRoute = new Vessel_Routing__x();

        for(String tempString : tag0620DataMap.keyset()){
                         
            if(tag0620DataMap.get(tempString).Reference_Field__C!= null && tag0620DataMap.get(tempString).Reference_Field_Value__c == 'Place of Receipt'){

                thisVesselRoute.put(tempString, (String)tag0620ObjStart.get(tag0620DataMap.get(tempString).Field_Value__C));
               
            }
            if(tag0620DataMap.get(tempString).Reference_Field__C!= null && tag0620DataMap.get(tempString).Reference_Field_Value__c == 'Place of Delivery'){

                thisVesselRoute.put(tempString, (String)tag0620ObjEnd.get(tag0620DataMap.get(tempString).Field_Value__C));
               
            }

        }

        for(String tempString : tag0630DataMap.keyset()){
          
            if(fieldDataTypeMap.containsKey(tempString)){

                thisVesselRoute.put(tempString, (String)tag0630Obj.get(tag0630DataMap.get(tempString).Field_Value__C));

                //forming set of external ids for update scenario
                if(tempString == 'routing_id__c'){
                    vesselRouteId.add((String)tag0630Obj.get(tag0630DataMap.get(tempString).Field_Value__C));
                }

            }

        }
        
        if(shipmentMapNew.containsKey('shipment_number__c')){
            
            thisVesselRoute.shipment_number__c = shipmentMapNew.get('shipment_number__c');
                
        }
        if(fieldDataTypeMap.containsKey('route_point_role_type__c') && routePointRoleType != null){
           
            thisVesselRoute.route_point_role_type__c = routePointRoleType;
        }
        
        return thisVesselRoute;
    }
    
}