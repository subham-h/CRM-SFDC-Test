/*
Description  : 1. Perform callout to RKEM to get the container details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          16/05/2019          sriram.kalluri@maersk.com                    Perform callout to RKEM to get the container details
* V2.0          16/06/2019          sreya.v@maersk.com                           Created GetContainerTracking Invokable method which has been called from Einstein Chatbot.
* V3.0          18/10/2019          nivedita.shukla@maersk.com                   Created getScheduledEnquiry Invokable method which has been called from Einstein Chatbot.  
* v4.0          29/10/2019          Sriram.kalluri@maersk.com                    RQ-012287 updated to API URL
* v5.0     RQ-012391   18-11-2019   Sreya@Maersk                                 Made the getScheduleDetails service input parameters to uppercase.
* v6.0     RQ-012794   09-12-2019   Sreya@Maersk                                 Considered getContainerTracking service based on operator.
* v7.0     SC-366      18-05-2020   Avinash@ust                                  Retrieve Schedule Basis Date
* v8.0     SC-367      24-09-2020   Ramadevi@ust                                 Retrieve NAP schedules
* v9.0     SC-4457    11-04-2022    Thippeswamy@UST                              Apex Exception handling for bot method getContainerTracking 
* v10.0    SPI-100    07-06-2022    Ronnie@SF                                    Removed brand hardcodings
* v11.0    SC-8846    06-09-2023    Avinash@Maersk                               Change to Container Tracking API
* v12.0    SC-8073             21-09-2023      Avinash@Maersk                                                                                                                Chat- Replace AO API with MEPC API for product schedules
*-------------------------------------------------------------------------------------------------------------------
*/

/**
* @description - Perform callout to RKEM to get the container details
*/
global with sharing class AO_ServiceController {  
    
    /**
     * @description - containerInput Class
     */
    public class containerInput{
        @InvocableVariable(required=true)
        public string containerNumber;
        @InvocableVariable(required=true)
        public string botLanguage;
        @InvocableVariable(required=true)
        public string brand;
    }
    
    /**
     * @description - trackingInfo Class
     */
    public class trackingInfo{
        @InvocableVariable(required=true)
        public string strOrigin;
        @InvocableVariable(required=true)
        public string strDestination;
        @InvocableVariable(required=true)
        public string serviceError;
        @InvocableVariable(required=true)
        public string strLatestContainer;
    }
    
    /**
     * @description - SC-8846 --> Changes in setHeader and Endpoint
     */
    @AuraEnabled(cacheable=true)
    public static object getContainerTrackingInfo(String containerNumber,string operator){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string strObjectName = 'Tracking';
        string modulename = 'getContainerDetails';
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Api-Version', 'v2');
        req.setHeader('accept', 'application/json');
        req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(AOServiceDetail.End_point_URL__c+containerNumber);
        http httpobj = new http();
        httpresponse res;
        try{
            res = httpobj.send(req);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('@rak log'+res.getBody());
        return res.getBody();
        
    }
    
    /**
     * @description - getScheduleDetails method
     */
    @AuraEnabled(cacheable=true)
    public static string getScheduleDetails(String POR,string POD,string operator,string frommode,string tomode,String dateVal,string dateType,string numberOfWeeks,String isNAP,String customerCode){        
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string porGeoId;
        string podGeoId;
        
        set<string> geoCodeset = new  set<string>{POR,POD};
        map<string,string> geoCodeMap =  new  map<string,string>();
        map<string,Geography__c> geoLocationMap =  new  map<string,Geography__c>();
        geoCodeMap = getGeoIds(geoCodeset);
        
        if(geoCodeMap.containskey(POR.toUpperCase())){
            porGeoId = geoCodeMap.get(POR.toUpperCase());
        }
        if(geoCodeMap.containskey(POD.toUpperCase())){
            podGeoId = geoCodeMap.get(POD.toUpperCase());
        }
        
        Map<String,String> brandMap = new Map<String,String>{'maeu' => 'MSL','safm' => 'SAF','mcpu' => 'MCC','sejj' => 'SGL','seau' => 'SEA','mael' => 'MLL'};
        String routingBasedOn = dateType != NULL && dateType != '' && dateType != 'undefined' ? (dateType == 'D' ? 'DEPARTURE_DATE' : 'ARRIVAL_DATE') : 'DEPARTURE_DATE';  
        string strObjectName = 'scheduleDetails';
        string modulename = 'getScheduleDetails';
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        
        Date dateValDt;
        if(dateVal != null && dateVal != '' && dateVal != 'undefined'){
            String day = dateVal?.substring(8,10);
            String month = dateVal?.substring(5,7);
            String year = dateVal?.substring(0,4);
            dateValDt = Date.newInstance(integer.valueOf(year),integer.valueOf(month),integer.valueOf(day));
        }
        
        
        DateTime earliestDate;
        DateTime latestDate;
        DateTime currentDate = dateVal != null && dateVal != '' && dateVal != 'undefined' ? dateValDt : Date.today().addDays(1);
        if(routingBasedOn == 'DEPARTURE_DATE'){
            earliestDate = currentDate;
            latestDate = currentDate.addDays(Integer.valueOf(numberOfWeeks)*7);
        }
        else{
            latestDate = currentDate;
            earliestDate = currentDate.addDays(-(Integer.valueOf(numberOfWeeks)*7));
        }
        
        String earliestTime = earliestDate.format('yyyy-MM-dd') + 'T00:00:00';
        String latestTime = latestDate.format('yyyy-MM-dd') + 'T00:00:00';
        String partyCode = customerCode != null && customerCode != 'undefined' ? customerCode : '';
        
        String reqBody = '{' +
            '"requestType": "DATED_SCHEDULES",'+
            '"includeFutureSchedules": true,'+
            '"routingCondition": "PREFERRED",'+
            '"exportServiceType":' +'"'+frommode+'",'+
            '"importServiceType":' +'"'+tomode+'",'+
            '"brandCode":'+'"'+brandMap.get(operator)+'",'+
            '"startLocation": {'+
             '"dataObject": "CITY",'+
                '"alternativeCodes": [{'+
                '"alternativeCode":'+'"'+porGeoId+'",'+
                '"alternativeCodeType": "GEO_ID"'+
              '}]'+
            '},'+
            '"endLocation": {'+
             '"dataObject": "CITY",'+
                '"alternativeCodes": [{'+
                '"alternativeCode":'+'"'+podGeoId+'",'+
                '"alternativeCodeType": "GEO_ID"'+
                '}]'+
            '},'+
            '"timeRange": {'+
                '"routingsBasedOn":'+'"'+routingBasedOn+'",'+
                '"earliestTime":'+'"'+earliestTime+'",'+
                '"latestTime":'+'"'+latestTime+'"'+
            '},'+
            '"cargo": {'+
              '"cargoType": "DRY"'+
            '},'+
            '"equipment": {'+
              '"equipmentTypeCode": "HDRY"'+
            '},'+
            '"namedAccounts": [{'+
              '"partyCode":'+ '"'+partyCode+'"'+
            '}]'+
          '}';
      
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Api-Version', '1');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Correlation-Id', porGeoId+partyCode+podGeoId+system.now());
        req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setBody(reqBody);
        string accessToken;
        system.debug('correlation Id :'+porGeoId+partyCode+podGeoId+system.now());
       
            accessToken = AO_APILoginUtility.getLoginIdToken(operator,AOServiceDetail);
            if(accessToken != null){  
                req.setHeader('Authorization',accessToken);
                req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
                req.setEndpoint(AOServiceDetail.End_point_URL__c+'routings-queries');
            }
            else{
                // Setting custom message if Account not existing for the customer code input from lwc
                message msg = new message();
                msg.noAccountMessage = Label.NoAccountMsg;
                return JSON.serialize( msg);
            }
        
        //If it reaches here it means that end point is set - need to be removed
        http httpobj = new http();
        httpresponse res;
        try{
            res = httpobj.send(req);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        string responseString = (string)res.getBody();
        set<string> sitecodes = new set<string>();
        JSONParser parser = JSON.createParser(res.getBody());
        Double grandTotal = 0.0;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'alternativeCode')) {
                    parser.nextToken();
                    sitecodes.add(parser.getText());
                }
        }
        
        list<Geography__c> GeoList = new  list<Geography__c>();
        if(!sitecodes.isEmpty()){
            geoLocationMap = getLocation(sitecodes); 
            for(string geoId:sitecodes){
                if(geoLocationMap.containsKey(geoId)){
                    responseString = responseString.replace(geoId, geoLocationMap.get(geoId).GEO_Code__c+':'+geoLocationMap.get(geoId).name);
                }             
            }
        }
       system.debug('response with city name:'+responseString);
        return responseString;
    }
   
    /**
     * @description - getGeoIds method
     */
    public static map<string,string> getGeoIds(set<string> sitecodes){
        map<string,string> geoCodeMap =  new  map<string,string>();
        list<Geography__c> GeoList = new  list<Geography__c>();
        if(!sitecodes.isEmpty()){   
            GeoList = [select id,GEO_Code__c,GEO_ID__c from Geography__c where GEO_Code__c in:sitecodes]; 
            for(Geography__c geo:GeoList){
                geoCodeMap.put(geo.GEO_Code__c,geo.GEO_ID__c);
            }
            
        }
        return geoCodeMap;
    }
    
    /**
     * @description - getLocation method
     */
    public static map<string,Geography__c> getLocation(set<string> sitecodes){
        map<string,Geography__c> geoCodeMap =  new  map<string,Geography__c>();
        list<Geography__c> GeoList = new  list<Geography__c>();
        if(!sitecodes.isEmpty()){   
            GeoList = [select id,GEO_ID__c,GEO_Code__c,name from Geography__c where GEO_ID__c in:sitecodes]; 
            for(Geography__c geo:GeoList){
                geoCodeMap.put(geo.GEO_ID__c,geo);
            }
            
        }
        return geoCodeMap;
    }
    
    /**
     * @description - Invoked from chatbot to get container tracking details.
     */
    @InvocableMethod(label='getContainerTracking')
    public static List<trackingInfo> getContainerTracking(List<containerInput> lstContainerNumber){
        //public static List<trackingInfo> getContainerTracking(){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        List<trackingInfo> lstTrack = new List<trackingInfo>();
        List<string> EnglishHeaders = new List<string>();
        list<string> ChineseHeaders = new List<string>();
        Boolean IsException = false;
        try{
            
            String containerNumber = lstContainerNumber[0].containerNumber;
            String botLanguage = lstContainerNumber[0].botLanguage;
            //String containerNumber = '229076029';
            //String botLanguage = 'English';
            
            //Invoking WebserviceUtilities.getAOServicesMetadataValue class method for getting the AO Service metadata.
            string strObjectName = 'Tracking';
            string modulename = 'getContainerDetails';
            AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
            //String operator = BrandUtilities.getBrandOperatorCode(lstContainerNumber[0].brand);
                
            //making the Http request with the Authorization Key and Endpoint.
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Api-Version', 'v2');
            req.setHeader('accept', 'application/json');
            req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
            req.setTimeout(Integer.valueof(AOServiceDetail.Apex_Timeout__c));
            req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
            req.setEndpoint(AOServiceDetail.End_point_URL__c+containerNumber);
            
            http httpobj = new http();
            httpresponse res;
            try{
                res = httpobj.send(req);
            }    
            catch(Exception ex){
                trackingInfo track = new trackingInfo();
                track.serviceError = 'System Error/Unhandled Error';
                lstTrack.add(track);
                IsException = true;
            }
            if(IsException == false){
            
            // Passing the JSON response string to Extension controller for parsing.
            string strJSON = res.getBody(); 
            JSON2Apex_ContainerTrackingExtention jsonApex = JSON2Apex_ContainerTrackingExtention.parse(strJSON);
            
            //Storing Origin,Destination,and container list to variables.
            JSON2Apex_ContainerTrackingExtention.Origin objOrigin = jsonApex.origin;
            JSON2Apex_ContainerTrackingExtention.Origin objDestination = jsonApex.destination;
            List<JSON2Apex_ContainerTrackingExtention.Containers> lstContainers = jsonApex.containers;
            
            String serviceError = jsonApex.error;
            
            trackingInfo track = new trackingInfo();
            if(String.isNotBlank(serviceError)){
                track.serviceError = serviceError;
            }
            // making the origin string from the response city,state and country.
            track.strOrigin = ' ';
            if(objOrigin != null){     
                track.strOrigin = String.isNotBlank(objOrigin.City) ? objOrigin.City : track.strOrigin;
                track.strOrigin = String.isNotBlank(objOrigin.state) ? track.strOrigin + ',' + objOrigin.state : track.strOrigin;
                track.strOrigin = String.isNotBlank(objOrigin.country) ? track.strOrigin + ',' + objOrigin.country : track.strOrigin;           
            }
            //making the destination string from the response city,state and country.
            track.strDestination = ' '; 
            if(objDestination != null){
                track.strDestination = String.isNotBlank(objDestination.City) ? objDestination.City : track.strDestination;      
                track.strDestination = String.isNotBlank(objDestination.state) ? track.strDestination + ',' + objDestination.state : track.strDestination;         
                track.strDestination = String.isNotBlank(objDestination.country) ? track.strDestination + ',' + objDestination.country : track.strDestination;             
            } 
            
            EnglishHeaders = Label.Container_Tracking_Chatbot_Header.split(',');
            ChineseHeaders = Label.Container_Tracking_Chatbot_Header_Chinese.split(',');
            
            track.strLatestContainer = '';
            //making the string for Arrivald Date and Last location. As it is impossible to handle iteration of list from Bot. 
                             //Looping over the list of containers and concatenating over one string
            if(lstContainers != null && !lstContainers.isEmpty()){
                
                Map<String,Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events>> mapOfLocEvent = new Map<String,Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events>>();
                for(integer i=0 ; i<lstContainers.size() ; i++){
                   Map<DateTime,String> mapOfEventIdActualTIme = new Map<DateTime,String>();
                   List<DateTime> lstDateTime = new List<DateTime>();
                   for(JSON2Apex_ContainerTrackingExtention.Locations location : lstContainers[i].locations){
                       for(JSON2Apex_ContainerTrackingExtention.Events event: location.events){
                           if(event.event_time_type == 'ACTUAL'){
                               mapOfEventIdActualTIme.put(DateTime.Valueof(event.event_time.replace('T', ' ')),event.eventId);
                               lstDateTime.add(DateTime.Valueof(event.event_time.replace('T', ' ')));
                           }
                       }
                   }
                
                   lstDateTime.Sort();
                   String currEventId = mapOfEventIdActualTIme.get(lstDateTime[lstDateTime.size() - 1]);
                   
                   for(JSON2Apex_ContainerTrackingExtention.Locations location : lstContainers[i].locations){
                       for(JSON2Apex_ContainerTrackingExtention.Events event: location.events){
                           if(event.eventId == currEventId){
                               Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events> mapLocaEveTemp = new Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events>();
                               mapLocaEveTemp.put(location,event);
                               mapOfLocEvent.put(lstContainers[i].container_num,mapLocaEveTemp);
                           }
                       }
                   }
                }
                
                for(integer i=0 ; i<lstContainers.size() ; i++){
                    if(botLanguage == 'English'){
                        track.strLatestContainer = track.strLatestContainer + EnglishHeaders[0]+'\n';
                    }
                    else if(botLanguage == 'Chinese'){
                        track.strLatestContainer = track.strLatestContainer + ChineseHeaders[0]+'\n';
                    }
                    
                    string strContainerNum = ' ';
                    if(String.isNotBlank(lstContainers[i].container_num)){
                        strContainerNum = lstContainers[i].container_num ; 
                    }
                    track.strLatestContainer = track.strLatestContainer + strContainerNum + '\n' + '\n';
                    
                    if(botLanguage == 'English'){
                        track.strLatestContainer = track.strLatestContainer + EnglishHeaders[1]+ '\n' ;
                    }
                    else if(botLanguage == 'Chinese'){
                        track.strLatestContainer = track.strLatestContainer + ChineseHeaders[1]+ '\n' ;
                    }
                    
                    string strArrivalDate = ' ';
                    if(String.isNotBlank(lstContainers[i].eta_final_delivery)){ 
                        // Formatting the Arrival date.
                        DateTime etaDate = (DateTime)JSON.deserialize('"' + lstContainers[i].eta_final_delivery + '"', DateTime.class);
                        string formattedDate = etaDate.dayGmt() + ' ' + etaDate.format('MMMMM','GMT') + ' ' + etaDate.yearGmt();
                        string formattedTime = etaDate.format('HH:mm','GMT');
                        
                        strArrivalDate = formattedDate + '\n' + formattedTime;
                    }
                    track.strLatestContainer = track.strLatestContainer + strArrivalDate + '\n' + '\n';
                    
                    if(botLanguage == 'English'){
                        track.strLatestContainer = track.strLatestContainer + EnglishHeaders[2] + '\n';
                    }
                    else if(botLanguage == 'Chinese'){
                        track.strLatestContainer = track.strLatestContainer + ChineseHeaders[2] + '\n';
                    }
                    
                    string strLastLocation = ' ';
                    if(mapOfLocEvent != null){
                        Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events> mapLocaEveTemp = new Map<JSON2Apex_ContainerTrackingExtention.Locations,JSON2Apex_ContainerTrackingExtention.Events>();
                        mapLocaEveTemp = mapOfLocEvent.get(lstContainers[i].container_num);
                        Set<JSON2Apex_ContainerTrackingExtention.Locations> locationSet = mapLocaEveTemp.KeySet();
                        List<JSON2Apex_ContainerTrackingExtention.Locations> location = new List<JSON2Apex_ContainerTrackingExtention.Locations>();
                        location.addAll(locationSet);
                        List<JSON2Apex_ContainerTrackingExtention.Events> event = mapLocaEveTemp.Values();
                        if(String.isNotBlank(event[0].activity)){
                            strLastLocation = event[0].activity + '-';
                        }
                        strLastLocation = String.isNotBlank(location[0].city) ? strLastLocation + location[0].city : strLastLocation;
                        strLastLocation = String.isNotBlank(location[0].state) ? strLastLocation + ',' + location[0].state : strLastLocation;
                        strLastLocation = String.isNotBlank(location[0].country) ? strLastLocation + ',' + location[0].country : strLastLocation; 
                        if(String.isNotBlank(event[0].actual_time)){
                            //formatting the last location actual date.
                            DateTime actualTime = (DateTime)JSON.deserialize('"' + event[0].actual_time + '"', DateTime.class);
                           string formattedActaulDate = actualTime.dayGmt() + ' ' + actualTime.format('MMMMM','GMT') + ' ' + actualTime.yearGmt();
                            strLastLocation = strLastLocation + '\n' + formattedActaulDate;
                        }
                    } 
                    
                    track.strLatestContainer = track.strLatestContainer + strLastLocation  + '\n' + '\n';
                }
                
            }
            else{
                if(botLanguage == 'English'){
                    track.strLatestContainer = EnglishHeaders[0]+ '\n' + '\n'+EnglishHeaders[1]+'\n'+'\n'+EnglishHeaders[2];
                }
                else if(botLanguage == 'Chinese'){
                    track.strLatestContainer = ChineseHeaders[0]+ '\n' + '\n'+ChineseHeaders[1]+'\n'+'\n'+ChineseHeaders[2]; 
                }
                
            }
            lstTrack.add(track);
            }
        }
        catch(Exception ex)
        {
            trackingInfo track = new trackingInfo();
            track.serviceError = 'System Error/Unhandled Error';
            lstTrack.add(track);
            IsException = true;
        }
        return lstTrack;               
    }
    
    /**
     * @description - Public class message
     */
    //sc-367 
    public class message{
        @AuraEnabled public string noAccountMessage{get;set;}
    }
}