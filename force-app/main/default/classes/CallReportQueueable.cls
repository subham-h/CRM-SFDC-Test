/*
* Queueable class for Merging Cases.
* 
*Version    Date           Owner                                      RQ#           Description
*1.0      23-05-2023      ramadevi.p@maersk.com                        SC-7966       Replacing future method with multiple callout to Queuable method.     
*/
public class CallReportQueueable implements Queueable,Database.AllowsCallouts
{
    public final Long beginParam;
    public final Long endParam;
    public final List<WxCC_Report_Configurations__mdt> reportConfigList;
    public CallReportQueueable(Long begin1,Long end1,List<WxCC_Report_Configurations__mdt> reportConfigList)
    {
        this.beginParam = begin1;
        this.endParam = end1;
        this.reportConfigList = reportConfigList;
        //this.DuplicateCaseIds = DuplicateCaseIds;
        //this.ParentCase = ParentCase;
    }
    public void execute(QueueableContext context)
    {  
        system.debug('size own before----'+reportConfigList.size());
        getAnalyzerReport(beginParam,endParam,reportConfigList);
    }
    
    public static void getAnalyzerReport(Long beginVal,Long endVal,List<WxCC_Report_Configurations__mdt> reportConfigList){
        try{
            List<Call_Report__c> lstCallReport = new List<Call_Report__c>();
            Map<string,string > countryMap = new Map<string,string >();
            List<WxCC_Analyzer_Report__mdt> lstNewSite = new List<WxCC_Analyzer_Report__mdt>();
            ESB_Webservice__mdt apiCred = new ESB_Webservice__mdt();
            List<WxCC_Report_Configurations__mdt> lstReportConfigurations = new List<WxCC_Report_Configurations__mdt>();
            List<WxCC_Report_Configurations__mdt> lstReportConfigEnqueue = new List<WxCC_Report_Configurations__mdt>();
            List<String> uniqueIdList = new List<String>();
            
            // The scheduler will be executed daily basis to pull previouse day's data.
            if(beginVal == null && endVal == null){
                Date beginDate = system.today() - 1;
                Datetime beginTime = Datetime.newInstance(beginDate,Time.newInstance(0,0,0,0));
                beginVal = beginTime.getTime();
                
                Date endDate = system.today();
                Datetime endTime = Datetime.newInstance(endDate,Time.newInstance(0,0,0,0));
                endVal = endTime.getTime(); 
            }
            //Querying the country geography to identify the country based on country code.
            for(Geography__c geo : [SELECT GEO_Code__c,Id FROM Geography__c WHERE Type_Of_Location__c = 'Country' and Active__c = true]){
                countryMap.put(geo.GEO_Code__c,geo.id);
            }
            
            //New queues will be stored in WxCC_Analyzer_Report__mdt metadata.Need to be updated on every site onboarding.
            lstNewSite = [select MasterLabel,Country_Name__c,Report_Brand__c from WxCC_Analyzer_Report__mdt];
            
            apiCred = [select OSB_Username__c,Password__c,Timeout__c,End_point_URL__c from ESB_Webservice__mdt where Module__c = 'WxCC_Analyzer' limit 1]; 
            system.debug('reportConfigList---'+reportConfigList.size());
            /*if(!(reportConfigList.size() > 0)) {
                lstReportConfigurations = [select API_Query__c,Brand__c,Report_Name__c from WxCC_Report_Configurations__mdt Order by Report_Name__c ASC];
            } else {*/
                if(reportConfigList <> Null) {
                    lstReportConfigurations = reportConfigList;
                }
            //}
            system.debug('lstReportConfigurations ---'+lstReportConfigurations.size());
            if(lstReportConfigurations.size()>0){               
                WxCC_Report_Configurations__mdt config;
                Integer i = 0;
                for(WxCC_Report_Configurations__mdt config1 : lstReportConfigurations){
                    if(i == 0){
                        config = config1;
                        i = i+1;
                    }else {
                        lstReportConfigEnqueue.add(config1);
                        i = i+1;
                    }
                }
                //for(WxCC_Report_Configurations__mdt config : lstReportConfigurations){
                    
                    Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(config.API_Query__c);
                    
                    //Modify the query dynamically to override the begin date and end date.
                    List<Object> dateBegin = (List<Object>) root.get('dateBegin');
                    dateBegin.clear();
                    dateBegin.add(beginVal);
                    List<Object> dateEnd = (List<Object>) root.get('dateEnd');
                    dateEnd.clear();
                    dateEnd.add(endVal); 
                    
                    /*if(lstNewSite.size()>0){
                        
                        Map<string,List<String>> mapCountryToQueue = new Map<string,List<string>>();
                        
                        // dynamic query 2 to Add new queue filter to list
                        List<Object> filterGroups = (List<Object>) root.get('filterGroups');
                        Map<String,Object> filter = (Map<String,Object>) filterGroups[1];
                        List<Object> valueFilters = (List<Object>) filter.get('valueFilters');
                        
                        Map<String,Object> aggregateQueryProperties =  (Map<String,Object>) root.get('aggregateQueryProperties');
                        List<Object> rowSegmentSet = (List<Object>) aggregateQueryProperties.get('rowSegmentSet');
                        Map<String,Object> rowSegmentSetRow = (Map<String,Object>) rowSegmentSet[0];
                        Map<String,Object> valueRange = (Map<String,Object>) rowSegmentSetRow.get('valueRange');
                        
                        //Modifying the query to append new queue values in the filter node.
                        for(WxCC_Analyzer_Report__mdt newQueue : lstNewSite){
                            if(newQueue.Report_Brand__c == config.Report_Name__c){ 
                                valueFilters.add(new Map<String, Object>{
                                    'columnName' => 'queueName__s',
                                        'value' => newQueue.MasterLabel,
                                        'operator' => 'EQUAL',
                                        'includeIfColumnNotPresent' => false
                                        });
                                
                                if(!mapCountryToQueue.containsKey(newQueue.Country_Name__c)){
                                    List<string> listCountryQueue = new List<string>();
                                    listCountryQueue.add(newQueue.MasterLabel);
                                    mapCountryToQueue.put(newQueue.Country_Name__c,listCountryQueue); 
                                }
                                else if(mapCountryToQueue.containsKey(newQueue.Country_Name__c)){
                                    mapCountryToQueue.get(newQueue.Country_Name__c).add(newQueue.MasterLabel);
                                }                   
                            } 
                        }
                        //Modifying the query to append country and queue mapping to the valueRange node.
                        
                        if(mapCountryToQueue.size()>0){
                            valueRange.putAll(mapCountryToQueue);
                        }
                        
                    }*/
                    
                    String modifiedQuery = JSON.serialize(root);
                    system.debug('@@Modified Query'+modifiedQuery);    
                    
                    //encoding the modified query
                    String encodedModifiedQuery = EncodingUtil.urlEncode(modifiedQuery, 'UTF-8');
                    
                    //Setting the headers,end point and time out.
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setHeader('Authorization',apiCred.Password__c);
                    req.setHeader('From', apiCred.OSB_Username__c );
                    req.setHeader('Accept','text/csv');
                    req.setTimeout(Integer.valueof(apiCred.Timeout__c)); 
                    req.setEndpoint(apiCred.End_point_URL__c+encodedModifiedQuery);
                    system.debug('req ###'+req);
                    
                    http httpobj = new http();
                    httpresponse res; 
                    res = httpobj.send(req);
                    String result = res.getBody();
                    system.debug('result'+result);
                    
                    //creating global error logger record in case of failure responses.
                    if (res.getStatusCode()<200 || res.getStatusCode()>299){
                        system.debug(res.getBody());             
                        ErrorLogger.writeError( 'SFDC', 'Call_Report__c', 'CallReportScheduler.getAnalyzerReportUtility',string.ValueOf(res.getStatusCode()) , res.getStatus(),res.getBody()+ 'Failed report: '+config.Report_Name__c);               
                    }
                    
                    else{
                        
                        string[] rowDataList = result.split('[\n\r]');                
                        rowDataList.remove(0);
                        rowDataList.remove(0);
                        
                        //Parsing the text/csv formatted response.
                        if(rowDataList.size()>0){
                            for(string str : rowDataList){
                                string[] rowData = str.split(',');
                                Call_Report__c callRpt = new Call_Report__c(); 
                                
                                //Converting the interval from milliseconds to date
                                DateTime dtInterval = DateTime.newInstance(long.valueOf(rowData[1]));
                                callRpt.Interval__c = dtInterval.date();
                                
                                //Identifying the Country from the Country code.
                                String countryName = rowData[2];
                                if(countryName.contains('(')){
                                Integer openingIndex = countryName.indexOf('(');
                                Integer closingIndex = countryName.indexOf(')');
                                String countryCode = countryName.subString(openingIndex + 1, closingIndex);
                                if(countryMap.get(countryCode) != null){
                                    callRpt.Country__c = countryMap.get(countryCode);
                                }
                                
                                callRpt.Total_calls_offered__c = Decimal.valueOf(rowData[3]);
                                callRpt.In_Service_Level__c = Decimal.valueOf(rowData[4]);
                                callRpt.Abandoned_with_SL__c = Decimal.valueOf(rowData[5]);
                                callRpt.Abandoned__c = Decimal.valueOf(rowData[6]);
                                callRpt.Callback_ANI_PIN__c = Decimal.valueOf(rowData[7]);
                                callRpt.Brand__c = config.Brand__c;
                                callRpt.Unique_Interval_Country__c = callRpt.Brand__c +'-'+ callRpt.Interval__c +'-'+ callRpt.Country__c;
                                lstCallReport.add(callRpt);
                                uniqueIdList.add(callRpt.Unique_Interval_Country__c);
                            }
                            }
                        }                
                    }
                //}
            }
            Map<String,Call_Report__c> existingCallReportRecordMap = new Map<String,Call_Report__c>();
            List<Call_Report__c> listToUpdate = new List<Call_Report__c>();
            List<Call_Report__c> listToUpsert  = new List<Call_Report__c>();
            List<String> countryList = new List<String>();
            countryList.add('China');
            
            if (!lstCallReport.isEmpty()) {
                for (Call_Report__c cr:[SELECT Id,Unique_Interval_Country__c,Country__c,Total_calls_offered__c,In_Service_Level__c,Abandoned_with_SL__c,Abandoned__c,Callback_ANI_PIN__c,Brand__c from Call_Report__c where Unique_Interval_Country__c in :uniqueIdList and createdDate =:system.today() and Country__c in :countryList]){
                    existingCallReportRecordMap .put(cr.Unique_Interval_Country__c,cr);
                }
                
                for(Call_Report__c cr:lstCallReport){
                    if(existingCallReportRecordMap.containsKey(cr.Unique_Interval_Country__c)){
                        Call_Report__c existingCR = existingCallReportRecordMap.get(cr.Unique_Interval_Country__c);
                        Call_Report__c cr1= new Call_Report__c();
                        cr1.Total_calls_offered__c = existingCR.Total_calls_offered__c + cr.Total_calls_offered__c;
                        cr1.In_Service_Level__c = existingCR.In_Service_Level__c+cr.In_Service_Level__c;
                        cr1.Abandoned_with_SL__c = existingCR.Abandoned_with_SL__c + cr.Abandoned_with_SL__c;
                        cr1.Abandoned__c = existingCR.Abandoned__c + cr.Abandoned__c;
                        cr1.Callback_ANI_PIN__c = existingCR.Callback_ANI_PIN__c + cr.Callback_ANI_PIN__c;                  
                        listToUpdate.add(cr);
                    } else {
                        listToUpsert.add(cr);
                    }
                    
                }
                //The upsert will happen at the end of all callouts.
                system.debug('@@@@@lstCallReport'+lstCallReport.size());
                if(!listToUpsert.isEmpty()){
                     upsert listToUpsert Unique_Interval_Country__c;
                }  
                
                if(!listToUpdate.isEmpty()){
                    update listToUpdate;
                }
            }
            if(!lstReportConfigEnqueue.isEmpty()){
                system.debug('size own----'+lstReportConfigEnqueue.size());
                system.debug('beginVal+++'+beginVal);
                system.debug('endVal+++'+endVal);
                System.enqueueJob(new CallReportQueueable(beginVal,endVal,lstReportConfigEnqueue));
            }
        }
        catch(Exception ex){ 
            system.debug(ex.getMessage());             
            ErrorLogger.writeErrors( 'SFDC', 'Call_Report__c', 'CallReportScheduler.getAnalyzerReport', new list<Exception>{ex});
        }      
    }
}