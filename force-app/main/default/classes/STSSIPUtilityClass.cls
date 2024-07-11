/* 
* Story               Owner            Description
  SFSE-12634          Bharti Rana      Batch to insert record in sales Rep target Quarter data object after calculating targets from target measure 
*/
public class STSSIPUtilityClass {
    
        // Method to find the range of months between start date and end date 
    public static String getMonthFromDate(Date startDate,date endDate) {
        String rangeOfMonths; Integer startMonth; Integer endMonth;
        // Get the current date
        Date currentDate = Date.today();
        // Get the year of the current date
        Integer currentYear = currentDate.year();
        Date firstDayOfYear = Date.newInstance(currentYear, 01, 01); 
        Date lastDayOfYear = Date.newInstance(currentYear, 12, 31); 
        Integer givenYear = startDate.Year();
        
        if(endDate != null){
            Integer givenEndYear = endDate.Year(); 
            if (currentYear > givenYear) {
                startMonth =  firstDayOfYear.month();
                endMonth = (givenEndYear == currentYear) ? endDate.month() : lastDayOfYear.month();
            } else if (currentYear == givenYear) {
                startMonth = startDate.month();
                endMonth = (givenEndYear > currentYear) ? lastDayOfYear.month() : endDate.month();
            } 
            
            rangeOfMonths = startMonth != endMonth ? String.valueOf(startMonth + '-' + endMonth) : String.valueOf(startMonth);
            
        }else{
            // Create a new date with the last day of the current year
            if (currentYear > givenYear) {
                startMonth =  firstDayOfYear.month();
                
            } else if (currentYear == givenYear) {
                startMonth = startDate.month();
                
            } 
            rangeOfMonths = String.valueOf(startMonth + '-'+ lastDayOfYear.month());
        }
        return rangeOfMonths;        
    }
    
    public static Map<String,String> tcpForExclusions(List<Target_Customer_Portfolio__c> tcpList, Set<String> targetIdSet) {        
        Map<String,List<Target_Product_Exclusion__c>> mapTargetProductExclusion = new Map<String,List<Target_Product_Exclusion__c>>();
        Map<String,String> tcpIdToQuarterMap = new Map<String,String>();
        
        for (Target_Product_Exclusion__c eachExclusion : [SELECT Id, Brand__c, Product_Family__c, Quarter__c FROM Target_Product_Exclusion__c WHERE Target__c IN :targetIdSet AND RecordType.DeveloperName = :TargetSettingConstants.SIP_EXCLUSION_RECORD_TYPE]) {
            if (!mapTargetProductExclusion.containsKey(eachExclusion.Product_Family__c)) {
                mapTargetProductExclusion.put(eachExclusion.Product_Family__c, new List<Target_Product_Exclusion__c>{eachExclusion});
            } else {
                mapTargetProductExclusion.get(eachExclusion.Product_Family__c).add(eachExclusion);
            } 
        }        
        
        for (Target_Customer_Portfolio__c tcp : tcpList) {
            
            String productFamily = tcp.Assigned_Target__r.Target_Item__r.Product_Family__c;
            
            if(productFamily != null && mapTargetProductExclusion.containskey(productFamily)){
                
                for(Target_Product_Exclusion__c exclusionRec : mapTargetProductExclusion.get(productFamily)){
                    String brand = tcp.Assigned_Target__r.Target_Item__r.Brand__c;
                    Boolean toExclude = false;
                    if (exclusionRec.Brand__c == null && exclusionRec.Quarter__c != null) {
                        toExclude = true;
                    } else if (exclusionRec.Brand__c != null && exclusionRec.Brand__c.contains(brand) && exclusionRec.Quarter__c != null) {
                        toExclude = true;
                    }
                    if (toExclude) {
                        if (tcpIdToQuarterMap.containsKey(tcp.Id)) {
                            tcpIdToQuarterMap.put(tcp.Id, tcpIdToQuarterMap.get(tcp.Id) + exclusionRec.Quarter__c);
                        } else {
                            tcpIdToQuarterMap.put(tcp.Id,exclusionRec.Quarter__c);
                        }
                    } 
                }
            }
        }
        return tcpIdToQuarterMap;
    }
    
    public static void upsertSalesRepTargetQData(Map<string,Target_Customer_Portfolio__c> mapOfParticipanyWithTcp, Map<String,String> tcpIdToQuarterMap){
        Map<String,Map<String,Decimal>> mapOfSalesrepToQuarter = new Map<String,Map<String,Decimal>>();
        String currentMonthName,salesRepOrManagerId,quarter,key;
        Decimal Q;Integer Q1;
        Set<Id> salesRepIds = new Set<Id>();
        Set<string> measureTypes = new Set<String>();
        List<Sales_Rep_Target_Quarter_Data__c> existingRecords = new List<Sales_Rep_Target_Quarter_Data__c>();
        Map<String,Sales_Rep_Target_Quarter_Data__c>  salesRepTargetMap = new Map<String,Sales_Rep_Target_Quarter_Data__c>();
        List<Sales_Rep_Target_Quarter_Data__c> salesRepTargetList = new List<Sales_Rep_Target_Quarter_Data__c>();
        
        // Month -> TargetId+Month+SalesRepId
        for(String months : mapOfParticipanyWithTcp.keySet()){
            Q=0;
            Target_customer_Portfolio__c tcp = mapOfParticipanyWithTcp.get(months);
            currentMonthName = months.split('-')[1];
            salesRepOrManagerId = months.split('-')[2];
            
            switch on currentMonthName {
                when 'Jan' {
                    Q = tcp.Assigned_Target__r.Jan__c;                    
                    quarter = 'Q1';
                }
                when 'Feb' {
                    Q = tcp.Assigned_Target__r.Feb__c;                    
                    quarter = 'Q1';
                }
                when 'Mar' {
                    Q = tcp.Assigned_Target__r.Mar__c;
                    quarter = 'Q1';
                }
                when 'Apr' {
                    Q = tcp.Assigned_Target__r.Apr__c;                    
                    quarter = 'Q2';
                }
                when 'May' {
                    Q = tcp.Assigned_Target__r.May__c;                    
                    quarter = 'Q2';
                }
                when 'Jun' {
                    Q = tcp.Assigned_Target__r.Jun__c;                    
                    quarter = 'Q2';
                }
                when 'Jul' {
                    Q = tcp.Assigned_Target__r.Jul__c;                    
                    quarter = 'Q3';
                }
                when 'Aug' {
                    Q = tcp.Assigned_Target__r.Aug__c;                    
                    quarter = 'Q3';
                }
                when 'Sep' {
                    Q = tcp.Assigned_Target__r.Sep__c;                    
                    quarter = 'Q3';
                }
                when 'Oct' {
                    Q = tcp.Assigned_Target__r.Oct__c;                    
                    quarter = 'Q4';
                }
                when 'Nov' {
                    Q = tcp.Assigned_Target__r.Nov__c;                    
                    quarter = 'Q4';
                }
                when 'Dec' {
                    Q = tcp.Assigned_Target__r.Dec__c;                    
                    quarter = 'Q4';
                }
            }
            
            if (tcpIdToQuarterMap.containsKey(tcp.Id) && tcpIdToQuarterMap.get(tcp.Id).contains(quarter)){
                Q = 0;
            }
            
            key = salesRepOrManagerId + '-'+ tcp.Assigned_Target__r.Measure_Type__c + '-' + tcp.Assigned_Target__r.Target_Item__r.Product_Family__c ;
            if(!mapOfSalesrepToQuarter.containsKey(key)){
                mapOfSalesrepToQuarter.put(key , new Map<String,Decimal>{quarter=> Q}); 
            }else{
                Map<String ,decimal> mapOfInnerValues = mapOfSalesrepToQuarter.get(key);
                if(!mapOfInnerValues.containsKey(quarter)){
                    
                    mapOfInnerValues.put(quarter,Q);
                }else{
                    //This Map Holds the Calculated target Value against the Quarter it belongs to
                    mapOfInnerValues.put(quarter,mapOfInnerValues.get(quarter)+Q);
                }
                mapOfSalesrepToQuarter.put(key,mapOfInnerValues);
            }            
        }
        For(String salesRepKey :mapOfSalesrepToQuarter.keySet()){
            Map<String, Decimal> quarterTotals = mapOfSalesrepToQuarter.get(salesRepKey);
            salesRepIds.add(salesRepKey.split('-')[0]);
            measureTypes.add(salesRepKey.split('-')[1]);
            
            Sales_Rep_Target_Quarter_Data__c targetData = new Sales_Rep_Target_Quarter_Data__c();
            targetData.Sales_Rep__c = salesRepKey.split('-')[0];
            targetData.Measure_Type__c = salesRepKey.split('-')[1];
            targetData.L_S_product_family__c = salesRepKey.split('-')[2];
            
            // Check if the quarter totals map contains a value for each quarter
            targetData.Q1_Total__c = quarterTotals.containsKey('Q1') ? quarterTotals.get('Q1') : 0;
            targetData.Q2_Total__c = quarterTotals.containsKey('Q2') ? quarterTotals.get('Q2') : 0;
            targetData.Q3_Total__c = quarterTotals.containsKey('Q3') ? quarterTotals.get('Q3') : 0;
            targetData.Q4_Total__c = quarterTotals.containsKey('Q4') ? quarterTotals.get('Q4') : 0;
            //Map Holds all records which needs to be insert/Update 
            salesRepTargetMap.put(salesRepKey,targetData);
        }
        
        // Insert the Sales_Rep_Target_Quarter_Data__c records
        if (salesRepTargetMap.size() > 0) {
            // Check if records already exist for the given Sales Rep and Measure Type
            existingRecords = [SELECT Id, Sales_Rep__c, Measure_Type__c, Q1_Total__c, Q2_Total__c, Q3_Total__c, Q4_Total__c,L_S_product_family__c FROM Sales_Rep_Target_Quarter_Data__c WHERE Sales_Rep__c IN :salesRepIds AND Measure_Type__c IN :measureTypes];
        }
        // If records exist, update them; otherwise, insert new records
        if (!existingRecords.isEmpty()) {            
            String keyForExistingRecord;
            for (Sales_Rep_Target_Quarter_Data__c existingRecord : existingRecords) {
                // Combine Sales Rep and Measure Type into a unique key
                keyForExistingRecord = existingRecord.Sales_Rep__c + '-' + existingRecord.Measure_Type__c + '-' + existingRecord.L_S_product_family__c;                
                if(salesRepTargetMap.containsKey(keyForExistingRecord)){
                    existingRecord.Q1_Total__c += salesRepTargetMap.get(keyForExistingRecord).Q1_Total__c;
                    existingRecord.Q2_Total__c += salesRepTargetMap.get(keyForExistingRecord).Q2_Total__c;
                    existingRecord.Q3_Total__c += salesRepTargetMap.get(keyForExistingRecord).Q3_Total__c;
                    existingRecord.Q4_Total__c += salesRepTargetMap.get(keyForExistingRecord).Q4_Total__c;
                    salesRepTargetMap.remove(keyForExistingRecord);
                } 
            }
            //Update existingRecords;
            Database.SaveResult[] SR= Database.update(existingRecords,FALSE);
			ErrorLogger.writeErrors('SFDC', 'Sales Target', 'STS SIP Targets Rollout Batch', SR, existingRecords);	            
        } 
        
        if(!salesRepTargetMap.isEmpty()){
            For(String keyToInsert : salesRepTargetMap.keySet()){
                salesRepTargetList.add(salesRepTargetMap.get(keyToInsert));
            }
        }
        // Insert new records if no existing records found
        //insert salesRepTargetList;
        Database.SaveResult[] SR1= Database.insert(salesRepTargetList,FALSE);  
        ErrorLogger.writeErrors('SFDC', 'Sales Target', 'STS SIP Targets Rollout Batch', SR1, salesRepTargetList);	
    }
    
}