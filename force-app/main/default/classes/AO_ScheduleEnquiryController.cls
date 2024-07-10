/*
Description  : Perform callout to RKEM to get the Schedule details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          22/10/2019          nivedita.shukla@maersk.com                    Perform callout to RKEM to get the Schedule details from Bot
* V2.0          12/11/2019          Sreya.Maersk                                  ETD Validation within the date range
* v3.0          11/12/2019          Sreya.Maersk                                  UI changes for the display of schedule details.
* v4.0          4/12/2022           Thippeswamy.aravinda@ust                      Apex exception handling for bot
* v5.0          07/06/2022          Ronnie@SF                                     Removed brand hardcodings
* v6.0          27/09/2023          Avinash@maersk                                Chat- Replace AO API with MEPC API for product schedules
*-------------------------------------------------------------------------------------------------------------------
*/

public class AO_ScheduleEnquiryController {
    
    
    public class ScheduledInput{
        @InvocableVariable(required=true)
        public string porGeoId;
        @InvocableVariable(required=true)
        public string operator;
        @InvocableVariable(required=true)
        public string podGeoId;
        @InvocableVariable(required=true)
        public string haulageCombination;
        @InvocableVariable(required=true)
        public string etdDate;  
        @InvocableVariable(required=true)
        public string botLanguage;  
    }
    public class ScheduledInfo{
        @InvocableVariable(required=true)
        public string strLatestSchduled;
        @InvocableVariable(required=true)
        public string strInputDate;
        @InvocableVariable(required=true)
        public string serviceError;
        @InvocableVariable(required=true)
        public string ScheduleEnquiryDateRangeInvalid;
    }
    
    
    // Invoked from chatbot to get scheduled  Enquiry Details details.
    @InvocableMethod(label='getScheduleEnquiry')
    public static List<ScheduledInfo> getScheduledEnquiry(List<ScheduledInput> lstShipmentDetails){
        system.debug('getScheduledEnquiry with input '+lstShipmentDetails);
        List<ScheduledInfo> lstscheduleInfo = new List <ScheduledInfo>();
        List<string> EnglishHeaders = new List<string>();
        List<string> ChineseHeaders=new  List<string> ();
        String strDate;
        try{ 
        String frommode=lstShipmentDetails[0].haulageCombination.split('/')[0];
        String tomode=lstShipmentDetails[0].haulageCombination.split('/')[1];
        String botLanguage = lstShipmentDetails[0].botLanguage;
        
        //convert date
        strDate=lstShipmentDetails[0].etdDate;
        String[] strarr= strDate.split('-');
        strDate=strarr[2]+'-'+strarr[1]+'-'+strarr[0];
        // Not using endpoint from metedata since old one is depricated
        string strObjectName = 'scheduleDetails';
        string modulename = 'getScheduleDetails';
       

        date dtEtd = date.valueOf(strDate);
        
       //Verify ETD is withing +/- 90 days from today. Return 'ScheduleEnquiryDateRangeInvalid' variable to Bot if not in the date range.
        if((dtEtd < (system.today()-90)) || (dtEtd > (system.today()+90))) {
            ScheduledInfo schedule =  new ScheduledInfo();
            schedule.ScheduleEnquiryDateRangeInvalid = 'true';
            lstscheduleInfo.add(schedule);
        }
        else{
        Map<String,String> brandMap = new Map<String,String>{'Maersk' => 'MSL','Seago' => 'SGL','Sealand' => 'SEA'};
            
		string day = lstShipmentDetails[0]?.etdDate?.substring(0,2);
		string month = lstShipmentDetails[0]?.etdDate?.substring(3,5);
		string year = lstShipmentDetails[0]?.etdDate?.substring(6,10);
        DateTime currentDate = Date.newInstance(integer.valueOf(year),integer.valueOf(month),integer.valueOf(day));
        DateTime earliestDate = currentDate;
        DateTime latestDate = currentDate.addDays(28);//default no of weeks are 4,Hence adding 28 days
            
        String earliestTime = earliestDate.format('yyyy-MM-dd') + 'T00:00:00';
        String latestTime = latestDate.format('yyyy-MM-dd') + 'T00:00:00';
            
        String reqBody = '{' +
            '"requestType": "DATED_SCHEDULES",'+
            '"includeFutureSchedules": true,'+
            '"routingCondition": "PREFERRED",'+
            '"exportServiceType":' +'"'+frommode+'",'+
            '"importServiceType":' +'"'+tomode+'",'+
            '"brandCode":'+'"'+brandMap.get(lstShipmentDetails[0].operator)+'",'+
            '"startLocation": {'+
             '"dataObject": "CITY",'+
                '"alternativeCodes": [{'+
                '"alternativeCode":'+'"'+lstShipmentDetails[0].porGeoId+'",'+
                '"alternativeCodeType": "GEO_ID"'+
              '}]'+
            '},'+
            '"endLocation": {'+
             '"dataObject": "CITY",'+
                '"alternativeCodes": [{'+
                '"alternativeCode":'+'"'+lstShipmentDetails[0].podGeoId+'",'+
                '"alternativeCodeType": "GEO_ID"'+
                '}]'+
            '},'+
            '"timeRange": {'+
                '"routingsBasedOn": "DEPARTURE_DATE",'+
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
              '"partyCode":""'+
            '}]'+
          '}';
             
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        String operator = BrandUtilities.getBrandOperatorCode(lstShipmentDetails[0].operator);
        String accessToken = AO_APILoginUtility.getLoginIdToken(operator,AOServiceDetail);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Api-Version', '1');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Correlation-Id', lstShipmentDetails[0].porGeoId+lstShipmentDetails[0]?.etdDate+lstShipmentDetails[0].podGeoId+system.now());
        req.setHeader('Consumer-Key', AOServiceDetail.Authorization_Key__c);
        req.setBody(reqBody);
        req.setHeader('Authorization',accessToken);
        req.setEndpoint(AOServiceDetail.End_point_URL__c+'routings-queries');  
        http httpobj = new http();
        httpresponse res;
        
            res = httpobj.send(req);
            if(res.getStatusCode()==200){
                // Passing the JSON response string to Extension controller for parsing.
                string strJSON = res.getBody(); 
                System.debug('strJSON ' +strJSON);
                EnglishHeaders = Label.Schedule_Enquiry_Chatbot_Header.split(',');
                ChineseHeaders = Label.Schedule_Enquiry_Chatbot_Header_Chinese.split(',');
                
                JSON2Apex_ScheduledEnquiry jsonApex=JSON2Apex_ScheduledEnquiry.parse(strJSON);               
                
                List<JSON2Apex_ScheduledEnquiry.Routings> routingList = jsonApex.Routings;   
                
                
                ScheduledInfo scheduleInfo = new ScheduledInfo();
                System.debug('routingList '+routingList);
                if(routingList.size()<=0){
                    scheduleInfo.serviceError = 'No Schedules Available';
                    lstscheduleInfo.add(scheduleInfo);
                }else{
                    // check if multiple product as well
                    scheduleInfo.strLatestSchduled = '';
                    for(integer j=0;j< routingList.size();j++){
                        List<JSON2Apex_ScheduledEnquiry.Carriage> lstScheduled = new List <JSON2Apex_ScheduledEnquiry.Carriage>();
                        List<DateTime> lstDateTime = new List<DateTime>();
                        Map<DateTime,JSON2Apex_ScheduledEnquiry.RoutingLegs> mapDeptTimeRoutingLeg = new Map<DateTime,JSON2Apex_ScheduledEnquiry.RoutingLegs>();
                        List<JSON2Apex_ScheduledEnquiry.RoutingLegs> lstRoutingLegsTemp = new List<JSON2Apex_ScheduledEnquiry.RoutingLegs>();
                        lstRoutingLegsTemp.addAll(routingList[j].routingLegs);
                        
                        for(JSON2Apex_ScheduledEnquiry.RoutingLegs routingLeg: lstRoutingLegsTemp){
                            mapDeptTimeRoutingLeg.put(DateTime.Valueof(routingLeg.carriage.vesselPortCallStart.estimatedTimeOfDeparture.replace('T', ' ')),routingLeg);
                            lstDateTime.add(DateTime.Valueof(routingLeg.carriage.vesselPortCallStart.estimatedTimeOfDeparture.replace('T', ' ')));
                        }
                        
                        lstDateTime.Sort();
                        lstScheduled.add(mapDeptTimeRoutingLeg.get(lstDateTime[0]).Carriage);
                        lstScheduled.add(mapDeptTimeRoutingLeg.get(lstDateTime[lstDateTime.size()-1]).Carriage);
                    
                        String vesselName = '';
                        String voyageCode = '';
                        if(lstScheduled[0].vessel == null){
                             vesselName = mapDeptTimeRoutingLeg.get(lstDateTime[1]).Carriage?.vessel?.vesselName;
                             voyageCode = mapDeptTimeRoutingLeg.get(lstDateTime[1]).Carriage?.VesselPortCallStart?.departureVoyageNumber;
                        }
                       
                    if(lstScheduled != null && !lstScheduled.isEmpty()){
                            //for(integer i=0 ; i<lstScheduled.size() ; i++){
                                // from date
                                scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+ (j+1)+ '.' + ' ' + EnglishHeaders[0]+' : ';
                               
                                if(lstScheduled[0].vesselPortCallStart!=null && String.isNotBlank(lstScheduled[0].vesselPortCallStart.estimatedTimeOfDeparture)){
                                    DateTime etaDate = (DateTime)JSON.deserialize('"' + lstScheduled[0].vesselPortCallStart.estimatedTimeOfDeparture + '"', DateTime.class);
                                    string formattedDate = etaDate.dayGmt() + ' ' + etaDate.format('MMMMM','GMT') + ' ' + etaDate.yearGmt();
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled +formattedDate +'\n';
                                 }else{
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+'\n' ;
                                 }
                               
                                 // todate  
                               if(botLanguage == 'English'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + EnglishHeaders[1]+ ' : ' ;
                                }
                                else if(botLanguage == 'Chinese'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + ChineseHeaders[1]+ ' : ' ;
                                }
                                    
                                
                                if(lstScheduled[1].VesselPortCallEnd!=null && String.isNotBlank(lstScheduled[1].VesselPortCallEnd.estimatedTimeOfArrival)){
                                    DateTime etaDate = (DateTime)JSON.deserialize('"' + lstScheduled[1].VesselPortCallEnd.estimatedTimeOfArrival + '"', DateTime.class);
                                    string formattedDate = etaDate.dayGmt() + ' ' + etaDate.format('MMMMM','GMT') + ' ' + etaDate.yearGmt();
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled +formattedDate +'\n';

                                }else{
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+'\n' ;
                                }
                                
                                //Vessel Name
                                if(botLanguage == 'English'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + EnglishHeaders[2]+ ' : ' ;
                                }
                                else if(botLanguage == 'Chinese'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + ChineseHeaders[2]+ ' : ' ;
                                }
                                

                                if( lstScheduled[0].vessel !=null && String.isNotBlank(lstScheduled[0].vessel.vesselName) ){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled +lstScheduled[0].vessel.vesselName+ '\n' ;
                                }else if(String.isNotBlank(vesselName)){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + vesselName+ '\n' ;
                                }else{
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+'\n' ;
                                }
                                
                                // Voyage Code
                               if(botLanguage == 'English'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + EnglishHeaders[3]+ ' : ' ;
                                }
                                else if(botLanguage == 'Chinese'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + ChineseHeaders[3]+ ' : ' ;
                                }
                                
                                
                                if(lstScheduled[0].VesselPortCallStart!=null && String.isNotBlank(lstScheduled[0].VesselPortCallStart.departureVoyageNumber)){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled +lstScheduled[0].VesselPortCallStart.departureVoyageNumber+ '\n' ;
                                }else if(String.isNotBlank(voyageCode)){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + voyageCode+ '\n' ;
                                }else{
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+'\n' ;
                                }
                                
                                
                                //Transit Time
                               	if(botLanguage == 'English'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + EnglishHeaders[4]+ ' : ' ;
                                }
                                else if(botLanguage == 'Chinese'){
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled + ChineseHeaders[4]+ ' : ' ;
                                }
                                
                                if(String.isNotBlank(lstScheduled[0].VesselPortCallStart.estimatedTimeOfDeparture) && String.isNotBlank(lstScheduled[1].VesselPortCallEnd.estimatedTimeOfArrival)){
                                    DateTime arrvialDate = DateTime.valueOf(lstScheduled[1].VesselPortCallEnd.estimatedTimeOfArrival.replace('T',' '));
                                    DateTime deptDate = DateTime.valueOf(lstScheduled[0].VesselPortCallStart.estimatedTimeOfDeparture.replace('T',' '));
                                    String transitTime = Math.round(decimal.valueof((arrvialDate.getTime() - deptDate.getTime()))/(1000 * 60 * 60 * 24))+  ' Days';
                                    System.debug('final Time'+transitTime);
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+ transitTime + '\n'+ '\n';
                                }else{
                                    scheduleInfo.strLatestSchduled = scheduleInfo.strLatestSchduled+'\n'+'\n' ;
                                }
                            //}
                        	system.debug('strLatestSchduled :'+scheduleInfo.strLatestSchduled);
                	}
                  }
                    scheduleInfo.strInputDate=strDate;
                	lstscheduleInfo.add(scheduleInfo); 
                }
            }else{
                ScheduledInfo scheduleInfo = new ScheduledInfo();
                scheduleInfo.strInputDate=strDate;
                scheduleInfo.serviceError = res.getStatus();
                lstscheduleInfo.add(scheduleInfo);
            }   
        }
    }
        catch(Exception ex){
            system.debug('exception error'+ex.getMessage());
            ScheduledInfo scheduleInfo = new ScheduledInfo();
            scheduleInfo.strInputDate=strDate;
            scheduleInfo.serviceError = 'System Error/Unhandled Error';
            lstscheduleInfo.add(scheduleInfo);
        }
        system.debug('getScheduledEnquiry with output  '+lstscheduleInfo);
        return lstscheduleInfo;
    }
}