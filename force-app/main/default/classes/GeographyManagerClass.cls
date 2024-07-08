/** 
* @description 
* Author   : Vivek
* Purpose  : Manager Class to manage Geography Object Data
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5864     12-Feb-2023 Vivek Agarwal          Created and optimized for creating or updating Geography records.
*/
public class GeographyManagerClass {

    /** 
  * @description | SC-5864  Create Geography Records |
  * @param geographyFieldValueMap accepts the Map of metadata records
  * @param geoData accepts the Geography Data
  */
    public static void createGeographyRecords(List<GeographyEventParser> geoData, Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap){
    
        system.debug('-->geoData'+geoData);

        Map<GeographyEventParser,String> geoDataObjectMap = new Map<GeographyEventParser, String>();
        Map<GeographyEventParser,String> bdaDataObjectMap = new Map<GeographyEventParser, String>();
        Map<GeographyEventParser,String> bdaGeoDataObjectMap = new Map<GeographyEventParser, String>();
        Map<GeographyEventParser,String> parentBdaDataObjectMap = new Map<GeographyEventParser, String>();        
        Map<GeographyEventParser,String> parentBDARecordDataObjectMap = new Map<GeographyEventParser, String>();        

        Map<GeographyEventParser,String> parentGeoDataObjectMap = new Map<GeographyEventParser, String>();


        system.debug('-->geographyFieldValueMap'+geographyFieldValueMap);

        for(GeographyEventParser thisGeoData : geoData){
                  
            if(thisGeoData.geography != null && thisGeoData.geography.geoType!= null ){
                
                if(geographyFieldValueMap.get('geoTypeLocation').Values().Reference_Field_Value__c.contains(thisGeoData.geography.geoType)){

                    geoDataObjectMap.put(thisGeoData, 'Geography');

                    //parent geography records collection

                    if(thisGeoData.geography.geoType != 'Country' && (thisGeoData.geography.parents[0] != null || thisGeoData.geography.subCityParents != null)){

                        parentGeoDataObjectMap.put(thisGeoData, 'Country');

                        if(thisGeoData.geography.bdas != null){
                            
                            parentBDARecordDataObjectMap.put(thisGeoData, 'Business Defined Area');
                            
                        }//bda geo record creation
                        if(thisGeoData.geography.country != null && thisGeoData.geography.country.alternateCodes != null && thisGeoData.geography.bdas != null){
                        
                            bdaGeoDataObjectMap.put(thisGeoData, 'Country');

                        }

                    }
                    //bda geography records collection

                    if(thisGeoData.geography.geoType == 'Country' && (thisGeoData.geography.parents != null || thisGeoData.geography.bdas != null)){

                        parentBDARecordDataObjectMap.put(thisGeoData, 'Business Defined Area');


                        bdaGeoDataObjectMap.put(thisGeoData, 'Country');

                    }
                
                }
                else if(thisGeoData.geography.geoType == 'Business Defined Area' && (geographyFieldValueMap.get('bdaType').Values().Reference_Field_Value__c!= null ||(geographyFieldValueMap.get('bdaType').Values().Reference_Field_Value__c.contains(thisGeoData.geography.bdaType)))){
                    system.debug('-->Create Business Defined Area'+thisGeoData.geography.geoType);

                    bdaDataObjectMap.put(thisGeoData, 'Business Defined Area');

                    //Parent bda records collection

                    if(thisGeoData.geography.geoType == 'Business Defined Area' && (thisGeoData.geography.parents != null || thisGeoData.geography.bdas != null || thisGeoData.geography.bdaLocations != null)){

                        parentBdaDataObjectMap.put(thisGeoData, 'Business Defined Area');

                        if(thisGeoData.geography.parents != null){
                            parentBDARecordDataObjectMap.put(thisGeoData, 'Business Defined Area');
                        }

                        if(thisGeoData.geography.bdaLocations != null){
                            parentGeoDataObjectMap.put(thisGeoData, 'Country');

                            bdaGeoDataObjectMap.put(thisGeoData, 'Country');

                        }

                    }
                } 
            }
        }

        //Create geography records
        List<SObject> geoSObjects = new List<SObject>();
        List<SObject> bdaSObjects = new List<SObject>();
        List<SObject> bdaGeoSbjects = new List<SObject>();
        List<SObject> parentBdaSbjects = new List<SObject>();
        List<SObject> parentGeoSbjects = new List<SObject>();
        List<SObject> parentBDARecordSbjects = new List<SObject>();
        List<SObject> parentBDALocationsSObject = new List<SObject>();

        try{
    
            Schema.SObjectField fGeo = Geography__c.Fields.GEO_ID__c;
            Schema.SObjectField fBda = BDA__c.Fields.GEO_ID__c;
            Schema.SObjectField fbdaGeo = BDA_Geography__c.Link_Id__c;
            Schema.SObjectField fParentBda = Parent_BDA__c.Link_ID__c;

    
            if(!parentGeoDataObjectMap.isEmpty()){
                parentGeoSbjects.addAll(getParentOfGeoRecords(geographyFieldValueMap, parentGeoDataObjectMap, 'Geography__C'));
                Database.Upsert(parentGeoSbjects, fGeo, true);
                system.debug('-->geoBdalocations'+parentGeoSbjects);

            }
            if(!geoDataObjectMap.isEmpty()){
                geoSObjects.addAll(getGeoRecords(geographyFieldValueMap, geoDataObjectMap, 'Geography__C'));
                Database.Upsert(geoSObjects, fGeo, true);

            }     
            if(!parentBDARecordDataObjectMap.isEmpty()){
                parentBDARecordSbjects.addAll(getParentOfBDARecords(geographyFieldValueMap, parentBDARecordDataObjectMap, 'BDA__C'));
                Database.Upsert(parentBDARecordSbjects, fBda, true);

            }                              
            if(!bdaDataObjectMap.isEmpty()){
                bdaSObjects.addAll(getBDARecords(geographyFieldValueMap, bdaDataObjectMap, 'BDA__C'));
                Database.Upsert(bdaSObjects, fBda, true);

            }     
        
            if(!parentBdaDataObjectMap.isEmpty()){
                 parentBdaSbjects.addAll(getParentBDARecords(geographyFieldValueMap, parentBdaDataObjectMap, 'Parent_BDA__C'));
 
                 Database.Upsert(parentBdaSbjects, fParentBda, true);     
                }  
             
            if(!bdaGeoDataObjectMap.isEmpty()){
                bdaGeoSbjects.addAll(getGeoBDARecords(geographyFieldValueMap, bdaGeoDataObjectMap, 'BDA_Geography__c'));

                Database.Upsert(bdaGeoSbjects, fbdaGeo, true);     
            }  
            

        }catch(exception ex){

            ErrorLogger.writeError('geography Events', 'Geography__c', 'GeographyManagerClass.createGeographyRecords', ex.getMessage(), ex.getStackTraceString() ,String.valueOf(ex.getCause()));

        }
    }

      /** 
        * @description | SC-5864  Get Geo Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param geoData accepts the geoData
        * @param Nodes accepts the list of Nodes
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
      public static List<SObject> getGeoRecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> geoData, String sObjectName){

        List<SObject> thisGeoList = new List<SObject>();

        if(!geographyFieldValueMap.isEmpty() && geographyFieldValueMap!=null){

            Geography__c thisGeoData =  new Geography__c();

            Map<String, String> geoMapData = new Map<String, String>();

            for(GeographyEventParser thisGeoEvent  : geoData.keySet()){

                if(geographyFieldValueMap.get('geoTypeLocation').Values().Reference_Field_Value__c.contains(thisGeoEvent.geography.geoType)){

                    for(String temp: geographyFieldValueMap.get('geography').keySet()){

                        String s = JSON.serialize(thisGeoEvent.Geography);
                        Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                        if(geographyFieldValueMap.get('geography').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('geography').get(temp).Reference_Field_Value__c == 'bdaType'){

                            continue;

                        }else{

                            geoMapData.put(temp, (String)obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c).toString());
                        
                        }
                    }

                    //get alterateCodes for geography map 
                     geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                     //get parent records for geography when subCityParents is not null

                     if(thisGeoEvent.Geography.subCityParents!=null ){
                        geoMapData.put('Parent_Geography__c', getAlternateCodesMap(thisGeoEvent.Geography.subCityParents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')).get('GEO_ID__c'));
                     }
                    //get parent records for geography when subCityParents is null and parents is not null
                    if(thisGeoEvent.Geography.subCityParents==null && thisGeoEvent.Geography.parents != null && thisGeoEvent.Geography.parents[0].type != 'Continent' && thisGeoEvent.Geography.parents[0].alternateCodes != null){

                        system.debug('-->parents'+thisGeoEvent.Geography.parents[0].alternateCodes);
                        geoMapData.put('Parent_Geography__c', getAlternateCodesMap(thisGeoEvent.Geography.parents[0].alternateCodes, geographyFieldValueMap.get('alternateCodesGeo')).get('GEO_ID__c'));

                    }
                     system.debug('-->geoMapData'+geoMapData);

                }

            }

            if(!geoMapData.isEmpty()){

                system.debug('-->geoMapData'+geoMapData);
                thisGeoList.add(getSObjectMap(geoMapData, 'Geography__c'));

            }
              
        }
        return thisGeoList;

    }


      /** 
        * @description | SC-5864  Get BDA Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param geoData accepts the geoData
        * @param Nodes accepts the list of Nodes
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<SObject> getBDARecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> geoData, String sObjectName){

            List<SObject> thisBDAList = new List<SObject>();
    
            if(!geographyFieldValueMap.isEmpty() && geographyFieldValueMap!=null){
    
                BDA__c thisBDAData =  new BDA__c();
        
                Map<String, String> geoMapData = new Map<String, String>();
    
                for(GeographyEventParser thisGeoEvent  : geoData.keySet()){
    
                    if(geographyFieldValueMap.get('bdaType').Values().Reference_Field_Value__c != null){
    
                        for(String temp: geographyFieldValueMap.get('geography').keySet()){
    
                            String s = JSON.serialize(thisGeoEvent.Geography);
                            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
    
                            if(geographyFieldValueMap.get('geography').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('geography').get(temp).Reference_Field_Value__c == 'bdaType'){

                                system.debug('-->'+obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c));
                                geoMapData.put(temp, String.valueOf(obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c)));
                              
                            }
                            if(geographyFieldValueMap.get('geography').get(temp).Reference_Field__c == null){
        
                                system.debug('-->'+obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c));
                                geoMapData.put(temp, (String)obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c).toString());
                               
                            }
                        }
    
                        //get alterateCodes for geography map 
                         geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));
    
                         //get parent records for BDA 
    
                        if(thisGeoEvent.Geography.parents != null && thisGeoEvent.Geography.parents[0].alternateCodes != null){
    
                            system.debug('--> parents'+thisGeoEvent.Geography.parents[0].alternateCodes);
                            geoMapData.put('Parent_BDA__c', getAlternateCodesMap(thisGeoEvent.Geography.parents[0].alternateCodes, geographyFieldValueMap.get('alternateCodesBDA')).get('GEO_ID__c'));
    
                        }
                         system.debug('-->geoMapData'+geoMapData);
    
                    }
    
                }
    
                if(!geoMapData.isEmpty()){
    
                    system.debug('-->thisBDAData'+thisBDAData);
                    thisBDAList.add(getSObjectMap(geoMapData, 'BDA__c'));
    
                }
                  
            }
            return thisBDAList;
    
        }


    public static Map<String, String> getAlternateCodesMap(List<GeographyEventParser.AlternateCodes> alternateCodesList ,Map<String, EMP_Consumer_settings__mdt> alternateCodesMapMetadata){

        Map<String, String> geoDataMap = new Map<String , String>();

        for(String temp: alternateCodesMapMetadata.keySet()){

            for(GeographyEventParser.AlternateCodes thisAlternateCodes : alternateCodesList){
                            
                String s = JSON.serialize(thisAlternateCodes);
                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
        
                system.debug('-->geoDataMapOutside'+(alternateCodesMapMetadata.get(temp).Reference_Field_Value__c.contains((String)obj.get(alternateCodesMapMetadata.get(temp).Reference_Field__c))));
                system.debug('-->obj'+obj);

                if(alternateCodesMapMetadata.get(temp).Reference_Field__c != '' && (String)alternateCodesMapMetadata.get(temp).Reference_Field__c != 'codeType'){

                    continue;

                }else if(alternateCodesMapMetadata.get(temp).Reference_Field__c != '' && (String)alternateCodesMapMetadata.get(temp).Reference_Field__c == 'codeType' && alternateCodesMapMetadata.get(temp).Reference_Field_Value__c.contains((String)obj.get(alternateCodesMapMetadata.get(temp).Reference_Field__c))){

                    geoDataMap.put(temp, (String)obj.get(alternateCodesMapMetadata.get(temp).Field_Value__c).toString());
                    system.debug('-->geoDataMap'+(alternateCodesMapMetadata.get(temp).Reference_Field_Value__c.contains((String)obj.get(alternateCodesMapMetadata.get(temp).Reference_Field__c))));


                    system.debug('-->geoDataMap'+geoDataMap);
                }
            }
        }
            
        return geoDataMap;
        
    }


     /** 
        * @description | SC-5864  Get Parent Of BDA Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param geoData accepts the geoData
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<SObject> getParentOfBDARecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> geoData, String sObjectName){

            List<SObject> thisBDAList = new List<SObject>();
    
            if(!geographyFieldValueMap.isEmpty() && geographyFieldValueMap!=null){
    
                BDA__c thisBDAData =  new BDA__c();
        
                Map<String, String> geoMapData = new Map<String, String>();
    
                for(GeographyEventParser thisGeoEvent  : geoData.keySet()){
        
                    if(thisGeoEvent.geography.parents != null && thisGeoEvent.geography.parents[0].type != 'Continent' && thisGeoEvent.geography.parents[0].type == 'Business Defined Area'){

                        for(String temp: geographyFieldValueMap.get('parents').keySet()){
    
                            String s = JSON.serialize(thisGeoEvent.geography.parents[0]);
                            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
    
                            if(geographyFieldValueMap.get('parents').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('geography').get(temp).Reference_Field_Value__c == 'bdaType'){

                                system.debug('-->'+obj.get(geographyFieldValueMap.get('parents').get(temp).Field_Value__c));
                                geoMapData.put(temp, String.valueOf(obj.get(geographyFieldValueMap.get('parents').get(temp).Field_Value__c)));
                              
                            }
                            if(geographyFieldValueMap.get('parents').get(temp).Reference_Field__c == null){
        
                                system.debug('-->'+obj.get(geographyFieldValueMap.get('parents').get(temp).Field_Value__c));
                                geoMapData.put(temp, (String)obj.get(geographyFieldValueMap.get('geography').get(temp).Field_Value__c).toString());
                               

                            
                            }
                        }
    
                        //get alterateCodes for geography map 
                         geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.parents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));

                         system.debug('-->geoMapData'+geoMapData);
    
                    }
                    //bdas from geography records will be created from here
                    if( thisGeoEvent.geography.bdas != null){

                        BDA__C thisBDA = new BDA__C();

                        for(GeographyEventParser.BDAs thisGeoEventBDA  : thisGeoEvent.geography.bdas){
                            
                            Map<String, String> geoMapData2 = new Map<String, String>();

                            for(String temp: geographyFieldValueMap.get('bdas').keySet()){


                                String s = JSON.serialize(thisGeoEventBDA);
                                Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);
    
                                if(geographyFieldValueMap.get('bdas').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('bdas').get(temp).Reference_Field_Value__c == 'bdaType'){

                                system.debug('-->'+obj.get(geographyFieldValueMap.get('bdas').get(temp).Field_Value__c));
                                geoMapData2.put(temp, String.valueOf(obj.get(geographyFieldValueMap.get('bdas').get(temp).Field_Value__c)));
                              
                                }
                                if(geographyFieldValueMap.get('bdas').get(temp).Reference_Field__c == null){
        
                                    system.debug('-->'+obj.get(geographyFieldValueMap.get('bdas').get(temp).Field_Value__c));
                                    geoMapData2.put(temp, (String)obj.get(geographyFieldValueMap.get('bdas').get(temp).Field_Value__c).toString());
                                                           
                                }
                            }
    
                            //get alterateCodes for geography map 
                            geoMapData2.putAll(getAlternateCodesMap(thisGeoEventBDA.alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));

                            system.debug('-->geoMapData2'+geoMapData2);

                            if(!geoMapData2.isEmpty()){
                            
                                thisBDAList.add(getSObjectMap(geoMapData2, 'BDA__C'));
                                system.debug('-->thisBDAList'+thisBDAList);
                
                            }
    
                        }
                    }
                }
    
                if(!geoMapData.isEmpty()){
                
                    system.debug('-->thisBDAList'+thisBDAList);
                    thisBDAList.add(getSObjectMap(geoMapData, 'BDA__c'));
    
                }
                  
            }
            return thisBDAList;
    
        }
    /** 
        * @description | SC-5864  Get Parent Geo Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param geoData accepts the geoData
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
      public static List<SObject> getParentOfGeoRecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> geoData, String sObjectName){

        List<SObject> thisGeoList = new List<SObject>();

        if(!geographyFieldValueMap.isEmpty() && geographyFieldValueMap!=null){

            Geography__c thisGeoData =  new Geography__c();

            Map<String, String> geoMapDataSubCity = new Map<String, String>();
            Map<String, String> geoMapDataParents = new Map<String, String>();
            Map<String, String> geoMapDataCountry = new Map<String, String>();

            for(GeographyEventParser thisGeoEvent  : geoData.keySet()){
                
                //to create subCity parent for a CitySubArea
                if(thisGeoEvent.geography.subCityParents != null && thisGeoEvent.geography.geoType != 'Business Defined Area'){

                    for(String temp: geographyFieldValueMap.get('subCityParents').keySet()){

                        String s = JSON.serialize(thisGeoEvent.geography.subCityParents[0]);
                        Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                        if(geographyFieldValueMap.get('subCityParents').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('subCityParents').get(temp).Reference_Field_Value__c == 'bdaType'){

                            continue;

                        }else{

                            geoMapDataSubCity.put(temp, (String)obj.get(geographyFieldValueMap.get('subCityParents').get(temp).Field_Value__c).toString());
                        
                        }
                    }

                    //get alterateCodes for geography map 
                    geoMapDataSubCity.putAll(getAlternateCodesMap(thisGeoEvent.geography.subCityParents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                    //get parent records for geography when subCityParents is not null

                    if(thisGeoEvent.Geography.subCityParents!=null && thisGeoEvent.Geography.parents[0].type == 'State/Prov' ){
                        geoMapDataSubCity.put('Parent_Geography__c', getAlternateCodesMap(thisGeoEvent.Geography.Parents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')).get('GEO_ID__c'));
                     }
                    
                     system.debug('-->geoMapDataSubCity'+geoMapDataSubCity);

                }

                //to create a Parent for a geo record
                if(thisGeoEvent.geography.parents != null && thisGeoEvent.geography.geoType != 'Business Defined Area'){

                    for(String temp: geographyFieldValueMap.get('parents').keySet()){

                        String s = JSON.serialize(thisGeoEvent.geography.Parents[0]);
                        Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                        if(geographyFieldValueMap.get('parents').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('parents').get(temp).Reference_Field_Value__c == 'bdaType'){

                            continue;

                        }else{

                            geoMapDataParents.put(temp, (String)obj.get(geographyFieldValueMap.get('parents').get(temp).Field_Value__c).toString());
                        
                        }
                    }

                    //get alterateCodes for geography map 
                    geoMapDataParents.putAll(getAlternateCodesMap(thisGeoEvent.geography.parents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                    //get parent records for geography when subCityParents is null and parents is not null
                    if(thisGeoEvent.Geography.parents != null && thisGeoEvent.Geography.parents[0].type == 'State/Prov' && thisGeoEvent.Geography.Country != null && thisGeoEvent.Geography.Country.alternateCodes != null){

                        system.debug('-->parents'+thisGeoEvent.Geography.country.alternateCodes);
                        geoMapDataParents.put('Parent_Geography__c', getAlternateCodesMap(thisGeoEvent.Geography.country.alternateCodes, geographyFieldValueMap.get('alternateCodesGeo')).get('GEO_ID__c'));

                    }
                    //get parent of geography when parents is not null and parent is country
                    else if(thisGeoEvent.Geography.parents != null && thisGeoEvent.Geography.parents[0].type == 'Country' && thisGeoEvent.Geography.Country != null && thisGeoEvent.Geography.Country.alternateCodes != null){

                        system.debug('-->parents'+thisGeoEvent.Geography.parents[0].alternateCodes);
                        //parent of country cannot be updated on geography

                    }

                }

                 //to create a Country for a geo record
                 if(thisGeoEvent.geography.country != null && thisGeoEvent.Geography.parents[0].type != 'Country' && thisGeoEvent.geography.geoType != 'Business Defined Area'){

                    for(String temp: geographyFieldValueMap.get('country').keySet()){

                        String s = JSON.serialize(thisGeoEvent.geography.country);
                        Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                        if(geographyFieldValueMap.get('country').get(temp).Reference_Field__c != '' && (String)geographyFieldValueMap.get('country').get(temp).Reference_Field_Value__c == 'bdaType'){

                            continue;

                        }else{

                            geoMapDataCountry.put(temp, (String)obj.get(geographyFieldValueMap.get('country').get(temp).Field_Value__c).toString());
                            geoMapDataCountry.put('Type_Of_Location__c', 'Country');
                        
                        }
                    }

                    //get alterateCodes for geography map 
                    geoMapDataCountry.putAll(getAlternateCodesMap(thisGeoEvent.geography.country.alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                     system.debug('-->geoMapDataCountry'+geoMapDataCountry);

                }
               
                if(thisGeoEvent.geography.bdaLocations != null && thisGeoEvent.Geography.bdaLocations[0].type == 'Country' && thisGeoEvent.geography.geoType == 'Business Defined Area'){

                    for(GeographyEventParser.BdaLocations thisBDALocation :  thisGeoEvent.geography.bdalocations){

                        Map<String, String> geoMapDataCountryBDA = new Map<String, String>();

                        for(String temp: geographyFieldValueMap.get('bdalocations').keySet()){

                            String s = JSON.serialize(thisBDALocation);
                            Map<String,Object> obj =  (Map<String,Object>) JSON.deserializeUntyped(s);

                            if(geographyFieldValueMap.get('bdalocations').get(temp).Reference_Field__c == null){

                                geoMapDataCountryBDA.put(temp, (String)obj.get(geographyFieldValueMap.get('bdalocations').get(temp).Field_Value__c).toString());
                            
                                }
                        }

                    //get alterateCodes for geography map 
                        geoMapDataCountryBDA.putAll(getAlternateCodesMap(thisBDALocation.alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                        system.debug('-->geoMapDataCountryBDA'+geoMapDataCountryBDA);
                        
                        if(!geoMapDataCountryBDA.isEmpty()){

                            thisGeoList.add(getSObjectMap(geoMapDataCountryBDA, 'Geography__C'));
            
                        }

                    }
               
                }
            }
            if(!geoMapDataCountry.isEmpty()){

                thisGeoList.add(getSObjectMap(geoMapDataCountry, 'Geography__C'));

            }
          
            if(!geoMapDataParents.isEmpty()){

                thisGeoList.add(getSObjectMap(geoMapDataParents, 'Geography__C'));

            }
            if(!geoMapDataSubCity.isEmpty()){

                thisGeoList.add(getSObjectMap(geoMapDataSubCity, 'Geography__C'));

            }
           
              
        }
        return thisGeoList;

    }

    /** 
        * @description | SC-5864  Get BDA Geo relationship Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param bdaGeoDataObjectMap accepts the geoData
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<SObject> getGeoBDARecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> geoData, String sObjectName){

            List<SObject> thisGeoBDAList = new List<SObject>();
                
            Map<String, String> geoMapData = new Map<String, String>();

    
            for(GeographyEventParser thisGeoEvent  : geoData.keySet()){
        
                if(thisGeoEvent.geography.geoType == 'Country' && thisGeoEvent.geography.parents != null && thisGeoEvent.geography.parents[0].type != 'Continent' && thisGeoEvent.geography.parents[0].type == 'Business Defined Area'){
    
                    BDA_Geography__c thisGeoBDAData =  new BDA_Geography__c();

                    //get alterateCodes for geography map 
                    geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.parents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));
                    BDA__C ref = new BDA__C(GEO_ID__c = geoMapData.get('GEO_ID__c'));
                    Geography__C refGeo  = new Geography__C(Geo_Id__C = thisGeoEvent.geography.geoId);
                    system.debug('-->geoMapData.get(GEO_ID__c)'+geoMapData.get('GEO_ID__c'));

                    thisGeoBDAData.BDA__r = ref;
                    thisGeoBDAData.Geography__r = refGeo;
                    thisGeoBDAData.Link_Id__c = geoMapData.get('GEO_ID__c') +':'+thisGeoEvent.geography.geoId;

                    system.debug('-->thisGeoBDAData'+thisGeoBDAData);

                    thisGeoBDAList.add(thisGeoBDAData);
    
                }
                else if(thisGeoEvent.geography.geoType == 'Country' && thisGeoEvent.geography.bdas != null ){

                    for(GeographyEventParser.BDAs thisGeoEventBDA  : thisGeoEvent.geography.bdas){
                        
                        geoMapData = new Map<String, String>();

                        //get alterateCodes for geography map
                        geoMapData.putAll(getAlternateCodesMap(thisGeoEventBDA.alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));
         
                        BDA_Geography__c thisGeoBDAData =  new BDA_Geography__c();

                        BDA__C ref = new BDA__C(GEO_ID__c = geoMapData.get('GEO_ID__c'));
                        Geography__C refGeo  = new Geography__C(Geo_Id__C = thisGeoEvent.geography.geoId);
                        system.debug('-->geoMapData.get(GEO_ID__c)'+geoMapData.get('GEO_ID__c'));
                        thisGeoBDAData.BDA__r = ref;
                        thisGeoBDAData.Geography__r = refGeo;
                        thisGeoBDAData.Link_Id__c = geoMapData.get('GEO_ID__c') +':'+thisGeoEvent.geography.geoId;
    
                        system.debug('-->thisGeoBDAData'+thisGeoBDAData);
    
                        thisGeoBDAList.add(thisGeoBDAData);
                
                    }
                }
                else if(thisGeoEvent.geography.geoType != 'Business Defined Area' && thisGeoEvent.geography.geoType != 'Country' && thisGeoEvent.geography.country != null && thisGeoEvent.geography.country.alternateCodes != null && thisGeoEvent.geography.bdas != null ){
                    
                    //get alterateCodes for geography map 
                    geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.country.alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));

                    for(GeographyEventParser.BDAs thisGeoEventBDA  : thisGeoEvent.geography.bdas){
                            
                        Map<String, String> geoMapData2 = new Map<String, String>();

                        BDA_Geography__c thisGeoBDAData =  new BDA_Geography__c();

                        //get alterateCodes for geography map 
    
                        geoMapData2.putAll(getAlternateCodesMap(thisGeoEventBDA.alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));

                        system.debug('-->geoMapData2'+geoMapData2);

                        BDA__C ref = new BDA__C(GEO_ID__c = geoMapData2.get('GEO_ID__c'));
                        Geography__C refGeo  = new Geography__C(Geo_Id__C = geoMapData.get('GEO_ID__c'));
                        system.debug('-->geoMapData2.get(GEO_ID__c)'+geoMapData2.get('GEO_ID__c'));

                        thisGeoBDAData.BDA__r = ref;
                        thisGeoBDAData.Geography__r = refGeo;
                        thisGeoBDAData.Link_Id__c = geoMapData2.get('GEO_ID__c') +':'+geoMapData.get('GEO_ID__c');

                        system.debug('-->thisGeoBDAData'+thisGeoBDAData);

                        thisGeoBDAList.add(thisGeoBDAData);
            
                    }
                }
                else if(thisGeoEvent.geography.geoType == 'Business Defined Area' && thisGeoEvent.geography.bdalocations != null &&  thisGeoEvent.geography.bdalocations[0].alternateCodes != null ){
                    
                    for(GeographyEventParser.BdaLocations thisBDALocation :  thisGeoEvent.geography.bdalocations){         

                        geoMapData.putAll(getAlternateCodesMap(thisBDALocation.alternateCodes,geographyFieldValueMap.get('alternateCodesGeo')));
                                  
                        BDA_Geography__c thisGeoBDAData =  new BDA_Geography__c();

                        system.debug('-->geoMapData'+geoMapData);

                        BDA__C ref = new BDA__C(GEO_ID__c = thisGeoEvent.geography.geoId);
                        Geography__C refGeo  = new Geography__C(Geo_Id__C = geoMapData.get('GEO_ID__c'));
                        system.debug('-->geoMapData.get(GEO_ID__c)'+geoMapData.get('GEO_ID__c'));

                        thisGeoBDAData.BDA__r = ref;
                        thisGeoBDAData.Geography__r = refGeo;
                        thisGeoBDAData.Link_Id__c = thisGeoEvent.geography.geoId +':'+geoMapData.get('GEO_ID__c');

                        system.debug('-->thisGeoBDAData'+thisGeoBDAData);

                        thisGeoBDAList.add(thisGeoBDAData);
            
                    }
                }
            }
                        
            return thisGeoBDAList;
    
        }


        /** 
        * @description | SC-5864  Get Parent BDA relationship Records Data |
        * @param geographyFieldValueMap accepts the Map of Metadata
        * @param bdaGeoDataObjectMap accepts the geoData
        * @param sObjectName accepts Name of the object
        * @return List of sobject 
        */
        public static List<SObject> getParentBDARecords(Map<String, Map<String, EMP_Consumer_settings__mdt>> geographyFieldValueMap,Map<GeographyEventParser,String> parentBdaDataObjectMap, String sObjectName){

            List<SObject> thisParentBDAList = new List<SObject>();
                
            Map<String, String> geoMapData; 
    
            for(GeographyEventParser thisGeoEvent  : parentBdaDataObjectMap.keySet()){
        
                if(thisGeoEvent.geography.geoType == 'Business Defined Area' && thisGeoEvent.geography.parents != null && thisGeoEvent.geography.parents[0].type != 'Continent' && thisGeoEvent.geography.parents[0].type == 'Business Defined Area'){

                    geoMapData = new Map<String, String>();
    
                    Parent_BDA__C thisParentBDAData =  new Parent_BDA__C();

                    //get alterateCodes for geography map 
                    geoMapData.putAll(getAlternateCodesMap(thisGeoEvent.Geography.parents[0].alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));

                    BDA__C refParent = new BDA__C(GEO_ID__c = geoMapData.get('GEO_ID__c'));
                    BDA__C refChild  = new BDA__C(GEO_ID__c = thisGeoEvent.geography.geoId);

                    thisParentBDAData.Child_BDA__r = refChild;
                    thisParentBDAData.Parent_BDA__r = refParent;
                    thisParentBDAData.Link_Id__c = geoMapData.get('GEO_ID__c') +':'+thisGeoEvent.geography.geoId;

                    system.debug('-->thisParentBDAData'+thisParentBDAData);

                    thisParentBDAList.add(thisParentBDAData);
    
                }
                else if(thisGeoEvent.geography.geoType == 'Business Defined Area' && thisGeoEvent.geography.bdas != null ){

                    for(GeographyEventParser.BDAs thisGeoEventBDA  : thisGeoEvent.geography.bdas){
                        
                        geoMapData = new Map<String, String>();

                        //get alterateCodes for geography map
                        geoMapData.putAll(getAlternateCodesMap(thisGeoEventBDA.alternateCodes,geographyFieldValueMap.get('alternateCodesBDA')));

                        //if the BDAs related to BDA record are not same, then continue
                        if(thisGeoEvent.geography.geoId != geoMapData.get('GEO_ID__c')){
                            
                            Parent_BDA__C thisParentBDAData =  new Parent_BDA__C();    
            
                            BDA__C refParent = new BDA__C(GEO_ID__c = geoMapData.get('GEO_ID__c'));
                            BDA__C refChild  = new BDA__C(GEO_ID__c = thisGeoEvent.geography.geoId);

                            thisParentBDAData.Child_BDA__r = refChild;
                            thisParentBDAData.Parent_BDA__r = refParent;
                            thisParentBDAData.Link_Id__c = geoMapData.get('GEO_ID__c') +':'+thisGeoEvent.geography.geoId;

                            system.debug('-->thisParentBDAData'+thisParentBDAData);

                            thisParentBDAList.add(thisParentBDAData);
                
                        }
                    }
                }
            }
                        
            return thisParentBDAList;
    
        }

        public static SObject getSObjectMap(Map<String, String> geoMapData, String sObjectName){

            SObjectType thisSObject = ((SObject) Type.forName(sObjectName).newInstance())
                                  .getSObjectType();
            // Create an instance of that type
            Sobject genericObject = thisSObject.newSObject();

            Map<String, String> fieldDataTypeMap = EMPConsumerHandler.getFieldDataType(sObjectName);

            if(!geoMapData.isEmpty()){
    
                for(String tempString : geoMapData.keySet()){

                    if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) =='Checkbox'){

                        genericObject.put(tempString, Boolean.ValueOf(EMPConsumerHandler.getBooleanValue(geoMapData.get(tempString))));

                    }else if(fieldDataTypeMap.containsKey(tempString) && tempString =='Type__c'){

                        String bdaTypes = 'AREA,CLUSTER,FINANCIAL,REEFER';
                        String typeValue = bdaTypes.Contains(geoMapData.get(tempString)) ? geoMapData.get(tempString) : (geoMapData.get(tempString) == 'TRADE' || geoMapData.get(tempString) == 'REGION')? 'TRADE REGION' : 'OTHER';

                        genericObject.put(tempString, typeValue);

                    }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) =='Date'){
                        
                        genericObject.put(tempString, Date.ValueOf(EMPConsumerHandler.getDateValueFromEpocDays(Integer.ValueOf(geoMapData.get(tempString)))));

                    }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) =='Lookup(Geography)'){
                                                
                        genericObject.putSObject('Parent_Geography__r', new Geography__C(GEO_ID__c = geoMapData.get(tempString)));
                        

                    }else if(fieldDataTypeMap.containsKey(tempString) && fieldDataTypeMap.get(tempString) =='Lookup(BDA)'){
                                
                        genericObject.putSObject('Parent_BDA__r', new BDA__C(GEO_ID__c=geoMapData.get(tempString)));

                    }
                    else {
                        genericObject.put(tempString, geoMapData.get(tempString)== 'CitySubArea' ? 'Subcity' : geoMapData.get(tempString));
                    }

                }
            
                system.debug('-->thisSObject'+genericObject);

            }
            return genericObject;

        }


}