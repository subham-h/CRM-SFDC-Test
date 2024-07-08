/* 
* Story               Owner            Description
  SFSE-12634          Bharti Rana      Batch to insert record in sales Rep target Quarter data object after calculating targets from target measure 
*/

global class BatchPopulateQuarterValuesOnMeasure implements Database.Batchable<sObject>,Database.Stateful {
    
    Set<Id> participantIds;
    String targetcurrentYear;
    Set<String> setOfProcessedRecords = new Set<String>(); 
    
    // Constructor to accept the set of IDs
    global BatchPopulateQuarterValuesOnMeasure(Set<Id> ids,String year) {
        this.participantIds = ids;
        this.targetcurrentYear = year;
    }
    
    private static final String[] MONTH_NAMES = new String[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        
    global Database.QueryLocator start(Database.BatchableContext bc) { 
		Date firstDate = Date.newInstance(Date.today().year(),01,01); //Used as variable in Query String             
        List<Target_Setting_Batch_Query__mdt> listQuery = [SELECT Query__c FROM Target_Setting_Batch_Query__mdt WHERE DeveloperName = 'STS_SIP_BATCH1'];
        return Database.getQueryLocator(listQuery[0].Query__c);  
    }
    
    global void execute(Database.BatchableContext bc, List<Target_Customer_Portfolio__C> listOfTcp){
        Map<string,Target_Customer_Portfolio__c> mapOfParticipanyWithTcp= new Map<string,Target_Customer_Portfolio__c>();
        Set<String> localSetOfProcessedRecords = new Set<String>();
        date startDate,endDate; 
        String key,month,keyOfTCPAndMonth;        
        Map<Id,Set<String>> mapOfMeasureToMonth = new Map<Id,Set<String>>();
        Integer startMonth,endMonth;
        Map<String,String> tcpIdToQuarterMap = new Map<String,String>();
        //String targetId;
        Set<String> targetIdSet = new Set<String>();
        if(!setOfProcessedRecords.isEmpty()){
            localSetOfProcessedRecords.addAll(setOfProcessedRecords);
            setOfProcessedRecords.clear();
        }
        for(Target_Customer_Portfolio__c tcp :listOfTcp){
            targetIdSet.add(tcp.Assigned_Target__r.Target_Item__r.Target__c);
            startDate = tcp.Effective_Start_Date__c;
            endDate = tcp.Effective_End_Date__c;
            String currentMonthName;
            // Month will store the range of months Like 1-4 based on start date and end date  
            month = STSSIPUtilityClass.getMonthFromDate(startDate,endDate);
            // Split the month range into individual months
            if(month.contains('-')){
                String[] range = month.split('-');
                startMonth = Integer.valueOf(range[0]);
                endMonth = Integer.valueOf(range[1]);
                // Iterate over the months
                for (Integer currentMonth = startMonth; currentMonth <= endMonth; currentMonth++) {                      
                    currentMonthName = MONTH_NAMES[currentMonth - 1];
                    keyOfTCPAndMonth = tcp.Assigned_Target__c + '-'+currentMonthName + '-'+ String.valueOf(tcp.Assigned_Sales_Rep__c);
                    if(!mapOfParticipanyWithTcp.containsKey(keyOfTCPAndMonth) && !localSetOfProcessedRecords.contains(keyOfTCPAndMonth)){
                        mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                        setOfProcessedRecords.add(keyOfTCPAndMonth);
                    }}}
            else{
                currentMonthName = MONTH_NAMES[Integer.valueOf(month) - 1];
                keyOfTCPAndMonth = tcp.Assigned_Target__c + '-'+currentMonthName + '-' + String.valueOf(tcp.Assigned_Sales_Rep__c);
                //Map Holds Tcp records against the combination of Measure Id - Month - Sales rep 
                if(!mapOfParticipanyWithTcp.containsKey(keyOfTCPAndMonth) && !localSetOfProcessedRecords.contains(keyOfTCPAndMonth)){
                    mapOfParticipanyWithTcp.put(keyOfTCPAndMonth,tcp);
                    setOfProcessedRecords.add(keyOfTCPAndMonth);
                }} 
        }
        //SFSE-14392
        tcpIdToQuarterMap = STSSIPUtilityClass.tcpForExclusions(listOfTcp,targetIdSet);
        if(!mapOfParticipanyWithTcp.isEmpty())        
            STSSIPUtilityClass.upsertSalesRepTargetQData(mapOfParticipanyWithTcp,tcpIdToQuarterMap);
        
    }
    global void finish(Database.BatchableContext bc){		
        Database.executeBatch(new BatchSIPManagersPopulateQuarters(), Integer.valueOf(Target_Setting_Batch_Query__mdt.getInstance('SIP_STS_BATCH2').Batch_Size__c));
    }        
}