/* 
* Story               Owner                Description
SFSE-12634            Bharti Rana         Batch Created to Update sip measure target based on applicable period 
*/
global class BatchUpdateSipMeasureQuarter implements Database.Batchable<sObject> {
    global Decimal totaltarget; global String keyOfsalesRepWithMeasure;
    global Map<String,Sales_Rep_Target_Quarter_Data__c> mapOfSalesRepTargetQuarterData = new Map<String,Sales_Rep_Target_Quarter_Data__c>();
    global Map<String,List<Sales_Rep_Target_Quarter_Data__c>> mapOfSalsRepWithMeasure = new map<String,List<Sales_Rep_Target_Quarter_Data__c>>();
    global Map<String, Set<String>> mapOfSalesRepMeasureTypeToPeriods = new Map<String, Set<String>>();
    
    global Database.QueryLocator start(Database.BatchableContext batchableCtx) {
        String currentYear = String.ValueOf(System.today().year());
        List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName = 'STS_SIP_batch3' ];
        String queryStr = listQuery[0].Query__c;
       
        return Database.getQueryLocator(queryStr);  
    }
    global void execute(Database.BatchableContext batchableCtx, List<Sip_Measure__c> listOfSipMeasure) {
        Set<Id> salesReps = new Set<Id>();
        Set<String> measureType = new Set<String>();
        String key;  String KeyOfsalesTargetQuarter;
        For(Sip_Measure__c measure : listOfSipMeasure){
            salesReps.add(measure.SIP_Participant__r.SIP_Participant__c);
            measureType.add(measure.SIP_KPI__r.measure_Type__c);
            //Map holding Quarter against each sip participant
            if (!mapOfSalesRepMeasureTypeToPeriods.containsKey(measure.SIP_Participant__r.SIP_Participant__c)) {
                mapOfSalesRepMeasureTypeToPeriods.put(measure.SIP_Participant__r.SIP_Participant__c, new Set<String>{measure.Applicable_Period__c});
            } else {
                mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c).add(measure.Applicable_Period__c);
            }
            
        }
        //Fetching existing record from Sales_Rep_Target_Quarter_Data__c object
        List<Sales_Rep_Target_Quarter_Data__c> salesReptargetList = [Select id,Sales_Rep__c, Q1_Total__c,measure_Type__c, Q2_Total__c, Q3_Total__c, Q4_Total__c,L_S_product_family__c from Sales_Rep_Target_Quarter_Data__c where Sales_Rep__c IN :salesReps and measure_Type__c IN : measureType];
        
        
        For(Sales_Rep_Target_Quarter_Data__c s : salesReptargetList ){
            //Map to hold Key with product family
            KeyOfsalesTargetQuarter = s.Sales_Rep__c + '-' + s.Measure_Type__c + '-'+ s.L_S_product_family__c ; 
            mapOfSalesRepTargetQuarterData.put(KeyOfsalesTargetQuarter ,s); 
            keyOfsalesRepWithMeasure = s.Sales_Rep__c + '-' + s.Measure_Type__c;
            //Map to Hold key without product family
            if(!mapOfSalsRepWithMeasure.containsKey(keyOfsalesRepWithMeasure)){
                mapOfSalsRepWithMeasure.put(keyOfsalesRepWithMeasure,new List<Sales_Rep_Target_Quarter_Data__c>{s});
            }else{
                mapOfSalsRepWithMeasure.get(keyOfsalesRepWithMeasure).add(s);
            }
        }
            
        for(Sip_Measure__c measure : listOfSipMeasure){
            totaltarget =0; 
            //When product family is not null and product family contains multiple values
            if( measure.SIP_KPI__r.L_S_product_family__c != null && measure.SIP_KPI__r.L_S_product_family__c.contains(';')){
                
                List<String> productFamilyList = measure.SIP_KPI__r.L_S_product_family__c.split(';'); 
                
                for (String productFamily : productFamilyList) {
                    
                    calculateTargets(measure,productFamily);
                }
            }
            //Block to be executed when PF is null
            else if(measure.SIP_KPI__r.L_S_product_family__c == null){
                
                calculateTargets(measure , null);
            }
            //Block when Pf contains single value
            else{
                calculateTargets(measure,measure.SIP_KPI__r.L_S_product_family__c); 
            }
            
            // updating Target field of sip measure and Load_Target_from_STS__c as false 
            if(totaltarget >0){
                measure.Target__c  = totaltarget;
               measure.Load_Target_from_STS__c = false;
            }
            
        }
        //update listOfSipMeasure;
        Database.SaveResult[] SR= Database.update(listOfSipMeasure,FALSE);
        ErrorLogger.writeErrors('SFDC', 'Sales Target', 'STS SIP Targets Rollout Batch', SR, listOfSipMeasure);	            
    }
    //method to calculate targets for each sip measure for certain conditions and quarterly
    /* 1. when Pf is not null and cumulative based crediting is true 
      2. when Pf is not null and cumulative based crediting is false
      3. when Pf is null and cumulative based crediting is true
      4. when Pf is null and cumulative based crediting is false
*/  
    public  void calculateTargets(Sip_Measure__c measure , String productFamily)
    {
        String keyOfMeasure = measure.SIP_Participant__r.SIP_Participant__c + '-' + measure.SIP_KPI__r.measure_Type__c + '-' + productFamily;
        String keyWithoutPf = measure.SIP_Participant__r.SIP_Participant__c + '-' + measure.SIP_KPI__r.measure_Type__c;
        Set<String> periods = new Set<String>();
        //When product family in sip measure is blank 
        if(productFamily != null){
            if (mapOfSalesRepTargetQuarterData.containsKey(keyOfMeasure) && measure.SIP_KPI__r.Cumulative_Based_Crediting__c == true ) {
                if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_ONE){
                    totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c;
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_TWO){
                    periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                    // Check if the set of periods contains "Q1"
                    if (periods.contains(TargetSettingConstants.QUARTER_ONE)) {
                        // The combination has "Q1" as a value
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c+mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c; 
                        
                    } else {
                        
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c;
                    }
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_THREE){
                    periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                    // Check if the set of periods contains "Q1"
                    if (periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) ) {
                        // The combination has "Q1" as a value
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c +  mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c; 
                        
                    } else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO)){
                        // The combination does not have "Q1" as a value
                        
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c;
                    }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c;  
                        
                    }else{
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c;
                    }
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_FOUR){
                    periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                    // Check if the set of periods contains "Q1"
                    if(periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c +  mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c ;    
                    }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c;
                        
                    }else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c;
                        
                    }else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c;
                        
                    }
                    else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                        totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c ;
                    }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c ;
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c + mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c ;
                            
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            
                            totaltarget +=  mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c==NULL?0:mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c;
                        }
                    
                }
            }
            //This else if block will execute for the case when Pf is not null and  KPI's Cumulative_Based_Crediting__c checkbox is false 
            else if(mapOfSalesRepTargetQuarterData.containsKey(keyOfMeasure)){
                
                if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_ONE){
                    totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q1_Total__c;
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_TWO){
                    totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q2_Total__c;
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_THREE){
                    totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q3_Total__c;
                }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_FOUR){
                    totaltarget += mapOfSalesRepTargetQuarterData.get(keyOfMeasure).Q4_Total__c;
                }
                
            }
        }
        /*This else if block is when Product Family field on sip measure is Blank then check with Key
         of Sales rep and Measure type only and Cumulative_Based_Crediting__c is true on KPI  */
        else{
            if(mapOfSalsRepWithMeasure.containskey(keyWithoutPf) && measure.SIP_KPI__r.Cumulative_Based_Crediting__c == true){
                List<Sales_Rep_Target_Quarter_Data__c> s = mapOfSalsRepWithMeasure.get(keyWithoutPf);
                
                for(Sales_Rep_Target_Quarter_Data__c record : s){
                    if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_ONE){
                        totaltarget  += record.Q1_Total__c;
                    }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_TWO){
                        periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                        
                        // Check if the set of periods contains "Q1"
                        if (periods.contains(TargetSettingConstants.QUARTER_ONE)) {
                            // The combination has "Q1" as a value
                            totaltarget += record.Q1_Total__c+ record.Q2_Total__c; 
                            
                        } else {
                            // The combination does not have "Q1" as a value
                            
                            totaltarget += record.Q2_Total__c;
                        }
                    }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_THREE){
                        periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                        // Check if the set of periods contains "Q1"
                        if (periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) ) {
                            // The combination has "Q1" as a value
                            totaltarget += record.Q1_Total__c + record.Q2_Total__c + record.Q3_Total__c; 
                            
                        } else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO)){
                            // The combination does not have "Q1" as a value
                            
                            totaltarget += record.Q1_Total__c + record.Q3_Total__c;
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO)){
                            totaltarget +=  record.Q2_Total__c + record.Q3_Total__c;  
                            
                        }else{
                            totaltarget += record.Q3_Total__c;
                        }
                    }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_FOUR){
                        periods = mapOfSalesRepMeasureTypeToPeriods.get(measure.SIP_Participant__r.SIP_Participant__c);
                        // Check if the set of periods contains "Q1"
                        if(periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q1_Total__c + record.Q2_Total__c  + record.Q3_Total__c + record.Q4_Total__c ;    
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q2_Total__c + record.Q3_Total__c + record.Q4_Total__c;
                            
                        }else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q1_Total__c + record.Q3_Total__c + record.Q4_Total__c;
                            
                        }else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q1_Total__c + record.Q2_Total__c + record.Q4_Total__c;
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q3_Total__c + record.Q4_Total__c ;
                        }else if(periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q1_Total__c + record.Q4_Total__c ;
                            
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                            totaltarget += record.Q2_Total__c + record.Q4_Total__c ;
                        }else if(!periods.contains(TargetSettingConstants.QUARTER_ONE) && !periods.contains(TargetSettingConstants.QUARTER_TWO) && !periods.contains(TargetSettingConstants.QUARTER_THREE)){
                             totaltarget +=  record.Q4_Total__c ;
                        }
               }
                }
            } else{
                
                // This block execute when Pf is null and Cumulative_Based_Crediting__c is false 
                if(mapOfSalsRepWithMeasure.containsKey(keyWithoutPf) && !measure.SIP_KPI__r.Cumulative_Based_Crediting__c) {
                    
                    List<Sales_Rep_Target_Quarter_Data__c> s = mapOfSalsRepWithMeasure.get(keyWithoutPf);
                    For(Sales_Rep_Target_Quarter_Data__c record : s){
                        if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_ONE){
                            totaltarget += record.Q1_Total__c;
                        }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_TWO){
                            totaltarget += record.Q2_Total__c;
                        }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_THREE){
                            totaltarget += record.Q3_Total__c;
                        }else if(measure.Applicable_Period__c == TargetSettingConstants.QUARTER_FOUR){
                            totaltarget += record.Q4_Total__c;
                        }
                    }
                    
                }
                
            }
        }
       
    }
    
    
    
    global void finish(Database.BatchableContext batchableCtx) {
        
        
    }
    
}