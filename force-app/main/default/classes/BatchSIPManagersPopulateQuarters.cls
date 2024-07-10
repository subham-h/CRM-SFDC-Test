/* 
* Story               Owner             Description
* SFSE-13419		  Vinay			    Calculate Target for Hierachial Users reporting for a given SIP Participant.
*/
public class BatchSIPManagersPopulateQuarters implements Database.Batchable<sObject>, Database.Stateful{
    
    Map<Id, Set<String>> managerMap = new Map<Id, Set<String>>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String currentYear = String.ValueOf(Date.today().year());
        Date firstDate = Date.newInstance(Date.today().year(),01,01);
        Set<Id> participantIds = new Set<Id>();
        Set<Id> setreportingUsers = new Set<Id>();
        Map<Id,List<Id>> mapManagerSubOrds = new Map<Id,List<Id>>();
        
        //Querying all the SIP Measures where Load Target From STS is Checked AND Product Portfolio is LNS AND SIP Participant Year is CurrentYear
		List<Target_Setting_Batch_Query__mdt> listQuery1 = [SELECT Query__c FROM Target_Setting_Batch_Query__mdt WHERE DeveloperName = 'STS_SIP_batch3'];      
        List<SIP_Measure__c> measures = Database.query(listQuery1[0].Query__c+ ' ORDER BY SIP_Participant__r.SIP_Participant__c');
        
        for(SIP_Measure__c measure: measures){
            participantIds.add(measure.SIP_Participant__r.SIP_Participant__c);  
        }
        
        // Get the Direct and Indeirect reporting Users of SIP Participants
        if(!participantIds.isEmpty()){
            mapManagerSubOrds = GetHierarchicalUsers.retriveSubordinatesList(participantIds);
            setreportingUsers = GetHierarchicalUsers.reportingUserIdsSet;}
        
        Set<id> managerIds = mapManagerSubOrds.keySet(); //Used in Query Locator query String DO NOT DELETE
        
        // Query All TCPs of Manager's Subordinate's TCPS.
        List<Target_Setting_Batch_Query__mdt> listQuery = [SELECT Query__c FROM Target_Setting_Batch_Query__mdt WHERE DeveloperName = 'SIP_STS_BATCH2'];        
        return Database.getQueryLocator(listQuery[0].Query__c);    
    }
    
    public void execute(Database.BatchableContext bc, List<Target_Customer_Portfolio__c> portfolios){
        
        Map<Id, Map<String, List<Target_Customer_Portfolio__c>>> mapSalesRepTCPs= new Map<Id, Map<String, List<Target_Customer_Portfolio__c>>>();
        Map<String, List<Target_Customer_Portfolio__c>> tempMap;
        Map<String, List<Target_Customer_Portfolio__c>> SalesRepMeasureTCPMap = new Map<String, List<Target_Customer_Portfolio__c>>();
        Map<string,Target_Customer_Portfolio__c> mapOfParticipanyWithTcp= new Map<string,Target_Customer_Portfolio__c>();
        Map<String,String> tcpIdToQuarterMap = new Map<String,String>();
        Map<Id, Set<Target_Customer_Portfolio__c>> managerTCPsMap = new Map<Id, Set<Target_Customer_Portfolio__c>>();
        Map<Id,List<Id>> mapManagerSubOrds = new Map<Id,List<Id>>();
        
        Set<String> mgrMeasureData = new Set<String>();
        Set<String> targetIdSet = new Set<String>();
        Set<Id> participantIds = new Set<Id>();
        
        Date startDate,endDate;
        Decimal Q ;
        Integer startMonth,endMonth;
        String[] MONTH_NAMES = new String[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}; 
        String key,month,keyOfTCPAndMonth,targetId, currentYear = String.ValueOf(Date.today().year());
        
        List<Target_Setting_Batch_Query__mdt> listQuery1 = [SELECT Query__c FROM Target_Setting_Batch_Query__mdt WHERE DeveloperName = 'STS_SIP_batch3'];      
        List<SIP_Measure__c> measures = Database.query(listQuery1[0].Query__c+ ' ORDER BY SIP_Participant__r.SIP_Participant__c');
        listQuery1.clear();
        Set<Id> targetMeasureIds = new Set<Id>();
        
        for(Target_Customer_Portfolio__c tcp: portfolios){
            targetMeasureIds.add(tcp.Assigned_Target__c );
        }   
        
        if(!managerMap.isEmpty()){
            for(Id measureId: managerMap.keySet()){
                if(!targetMeasureIds.contains(measureId)){
                managerMap.remove(measureId);    
       }}}
        
        for(SIP_Measure__c measure: measures){
            participantIds.add(measure.SIP_Participant__r.SIP_Participant__c);  
        }
        
        // Get the Direct and Indeirect reporting Users of SIP Participants
        if(!participantIds.isEmpty()){
            mapManagerSubOrds = GetHierarchicalUsers.retriveSubordinatesList(participantIds);
            participantIds.clear();
        }
        // If the mapManagerSubOrds is not Empty which means some or all Participants are managers at some Level.
        // mgrMeasureData - Will Have a Map of ManagerId(SIP Participant's UserId)+PF+SIP Measure Type or
        // Map of ManagerId(SIP Participant's UserId)+SIP Measure Type in case if PF is NULL.
        if(!mapManagerSubOrds.isEmpty()){
            for(SIP_Measure__c measure: measures){
                if(mapManagerSubOrds.keySet().contains(measure.SIP_Participant__r.SIP_Participant__c)){
                    if(measure.SIP_KPI__r.L_S_product_family__c!=NULL){
                        if(measure.SIP_KPI__r.L_S_product_family__c.contains(';')){
                        for(String pf: measure.SIP_KPI__r.L_S_product_family__c.split(';')){
                            mgrMeasureData.add(measure.SIP_Participant__r.SIP_Participant__c+'-'+pf+'-'+measure.SIP_KPI__r.measure_Type__c);
                        }}
                        else{
                            mgrMeasureData.add(measure.SIP_Participant__r.SIP_Participant__c+'-'+measure.SIP_KPI__r.L_S_product_family__c+'-'+measure.SIP_KPI__r.measure_Type__c);
                        }}
                    else{
                        mgrMeasureData.add(measure.SIP_Participant__r.SIP_Participant__c+'-'+measure.SIP_KPI__r.measure_Type__c);
        }}}}
        measures.clear();
        //Iterate over TCP and Build 2 Maps with the below Structues
        //mapSalesRepTCPs - has Map like Map<SalesRepUserId, Map<PF+MeasureType, List of TCPs>>
        //SalesRepMeasureTCPMap - has Map like Map<SalesRepUserId+MeasureType, List of TCPs>
        for(Target_Customer_Portfolio__c tcp: portfolios){
            targetIdSet.add(tcp.Assigned_Target__r.Target_Item__r.Target__c);
            tempMap = new Map<String, List<Target_Customer_Portfolio__c>>();
            
            if(!mapSalesRepTCPs.containsKey(tcp.Assigned_Sales_Rep__c)){
                tempMap.put(tcp.Assigned_Target__r.Target_Item__r.Product_Family__c+tcp.Assigned_Target__r.Measure_Type__c, new List<Target_Customer_Portfolio__c>{tcp});  
                mapSalesRepTCPs.put(tcp.Assigned_Sales_Rep__c, tempMap);                                              
            }
            else{
                tempMap = mapSalesRepTCPs.get(tcp.Assigned_Sales_Rep__c);
                if(!tempMap.containsKey(tcp.Assigned_Target__r.Target_Item__r.Product_Family__c+tcp.Assigned_Target__r.Measure_Type__c)){
                    tempMap.put(tcp.Assigned_Target__r.Target_Item__r.Product_Family__c+tcp.Assigned_Target__r.Measure_Type__c, new List<Target_Customer_Portfolio__c>{} );  
                }
                tempMap.get(tcp.Assigned_Target__r.Target_Item__r.Product_Family__c+tcp.Assigned_Target__r.Measure_Type__c).add(tcp);
                mapSalesRepTCPs.put(tcp.Assigned_Sales_Rep__c, tempMap);
            }
            key = tcp.Assigned_Sales_Rep__c+tcp.Assigned_Target__r.Measure_Type__c;
            if(!SalesRepMeasureTCPMap.containsKey(key)){
                SalesRepMeasureTCPMap.put(key, new List<Target_Customer_Portfolio__c>{});   
            }
            SalesRepMeasureTCPMap.get(key).add(tcp);         
        }
           
        // Iterate over mgrMeasureData Map that is with combinatation of ManagerId+PF+MeasureType or ManagerId+MeasureType        
        if(!mgrMeasureData.isEmpty()){
            Id participantId;
            String pf, measureType;
            for(String str: mgrMeasureData){
                participantId = Id.valueof(str.split('-')[0]);
                pf = str.split('-').size()==3?str.split('-')[1]: '';
                measureType = str.split('-').size()==3?str.split('-')[2]: str.split('-')[1];
                
                if(!managerTCPsMap.containsKey(participantId)){
                    managerTCPsMap.put(participantId, new Set<Target_Customer_Portfolio__c>{});
                }
                // When PF is not Empty then get all TCP of Manager and Map it to ManagerId which are matching PF+Measure Type
                // as well Manager's subordinate TCPs which are matching the Manager's PF+Measure Type 
                if(pf!=''){
                    if(mapSalesRepTCPs.containsKey(participantId) && mapSalesRepTCPs.get(participantId).containsKey(pf+measureType)){
                        managerTCPsMap.get(participantId).addAll(mapSalesRepTCPs.get(participantId).get(pf+measureType));
                    } 
                    
                    if(mapManagerSubOrds.containsKey(participantId) && !mapManagerSubOrds.get(participantId).isEmpty()){
                        for(Id reportingUserId: mapManagerSubOrds.get(participantId)){
                            if(mapSalesRepTCPs.containsKey(reportingUserId) && mapSalesRepTCPs.get(reportingUserId).containsKey(pf+measureType)){
                               managerTCPsMap.get(participantId).addAll(mapSalesRepTCPs.get(reportingUserId).get(pf+measureType));
                    }}}}
                // When PF is Empty then get all TCP of Manager and Map it to ManagerId which are matching Manager's UserId+Measure Type
                // as well Manager's subordinate TCPs which are matching the Manager's Measure Type                                 
                else{
                    if(SalesRepMeasureTCPMap.containsKey(participantId+measureType) && !SalesRepMeasureTCPMap.get(participantId+measureType).isEmpty()){
                        managerTCPsMap.get(participantId).addAll(SalesRepMeasureTCPMap.get(participantId+measureType));
                    }
                    if(mapManagerSubOrds.containsKey(participantId) && !mapManagerSubOrds.get(participantId).isEmpty()){
                        for(Id reportingUserId: mapManagerSubOrds.get(participantId)){
                            if(SalesRepMeasureTCPMap.containsKey(reportingUserId+measureType) && !SalesRepMeasureTCPMap.get(reportingUserId+measureType).isEmpty()){
                                managerTCPsMap.get(participantId).addAll(SalesRepMeasureTCPMap.get(reportingUserId+measureType));
                    }}}
                    
                }
            }            
            mapSalesRepTCPs.clear();
            SalesRepMeasureTCPMap.clear();
            mapManagerSubOrds.clear();
            tempMap.clear();
            if(!managerTCPsMap.isEmpty()){
                for(Id salesRepId: managerTCPsMap.keySet()){
                    if(!managerTCPsMap.isEmpty() && managerTCPsMap.containsKey(salesRepId) && !managerTCPsMap.get(salesRepId).isEmpty()){
                        for(Target_Customer_Portfolio__c tcp:managerTCPsMap.get(salesRepId)){
                            startDate = tcp.Effective_Start_Date__c;
                            endDate = tcp.Effective_End_Date__c;
                            Q=0; String currentMonthName;
                            // Month will store the range of months Like 1-4 based on start date and end date  
                            month = STSSIPUtilityClass.getMonthFromDate(startDate, endDate);                
                            // Split the month range into individual months
                            if(month.contains('-')){
                                String[] range = month.split('-');
                                startMonth = Integer.valueOf(range[0]);
                                endMonth = Integer.valueOf(range[1]);
                                // Iterate over the months
                                for (Integer currentMonth = startMonth; currentMonth <= endMonth; currentMonth++) {                      
                                    currentMonthName = MONTH_NAMES[currentMonth - 1];
                                    keyOfTCPAndMonth = tcp.Assigned_Target__c + '-'+currentMonthName + '-'+ String.valueOf(salesRepId);                                    
                                    if(managerMap.containsKey(tcp.Assigned_Target__c)){
                                       if(!managerMap.get(tcp.Assigned_Target__c).contains(keyOfTCPAndMonth)){
                                           managerMap.get(tcp.Assigned_Target__c).add(keyOfTCPAndMonth);
					    //Map Holds Tcp records against the combination of Measure Id - Month - Sales rep 
                                           mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                                    }}
                                    else{
                                        managerMap.put(tcp.Assigned_Target__c, new set<String>{keyOfTCPAndMonth});
					 //Map Holds Tcp records against the combination of Measure Id - Month - Sales rep 	
                                        mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                                    }
                                }
                            }else{
                                currentMonthName = MONTH_NAMES[Integer.valueOf(month) - 1];
                                keyOfTCPAndMonth = tcp.Assigned_Target__c + '-'+currentMonthName + '-' + String.valueOf(salesRepId);
                               

                                if(managerMap.containsKey(tcp.Assigned_Target__c)){
                                   if(!managerMap.get(tcp.Assigned_Target__c).contains(keyOfTCPAndMonth)){
                                      managerMap.get(tcp.Assigned_Target__c).add(keyOfTCPAndMonth);
				       //Map Holds Tcp records against the combination of Measure Id - Month - Sales rep 	
                                      mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                                }}
                                else{
                                     managerMap.put(tcp.Assigned_Target__c, new set<String>{keyOfTCPAndMonth});
                                     //Map Holds Tcp records against the combination of Measure Id - Month - Sales rep 
                                     mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                                }                    
                            }    
                        }}}}  
            managerTCPsMap.clear();
            mgrMeasureData.clear();
            
            tcpIdToQuarterMap = STSSIPUtilityClass.tcpForExclusions(portfolios,targetIdSet);
            if(!mapOfParticipanyWithTcp.isEmpty()){
            STSSIPUtilityClass.upsertSalesRepTargetQData(mapOfParticipanyWithTcp,tcpIdToQuarterMap);}
        }
        
        
    }// End of execute
    
    public void finish(Database.BatchableContext bc){
        Database.executeBatch(new BatchUpdateSipMeasureQuarter(), Integer.valueOf(Target_Setting_Batch_Query__mdt.getInstance('SIP_STS_BATCH2').Batch_Size__c));  
    }
}