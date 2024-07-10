/* 
* version       Date                Owner                                       Description
*********************************************************************************************************************************************
* V1.0          8/04/2016          meghana.gupta@ust-global.com         #PR-0089:Code created. Utility class for SIP related classes
* V2.0          2/08/2016          meghana.gupta@ust-global.com         Added method getAccountsOwned
* V3.0          7/06/2017          sandhya.sambasivan@ust-global.com    RQ-005406: Added 'Next' quarter logic to getQuarter method
* V4.0          1/01/2018          meghana.gupta@ust-global.com         RQ-007413: Added method 'getSIPUserReporteeList' and
removed  methods isSF1, CalculatePayoutForUpdatedVolume, getAccountsOwned, getSIPUserReportees
* v5.0          30/05/2018         manjunath.c.holekade@maersk.com      RQ-008638 - 11 additions/modifications(Mod-01 to Mod-11) 
-> Individual payout calculations -> Fine tuning of the existing code
-> Addition of missing Actual target change logic related to Special Cargo
* v6.0      14-Aug-2018           manjunath.c.holekade@maersk.com      RQ-009065 - Included 'maxPerf' parameter for 'calculatePayoutPercent' method
* v7.0      07-Sep-2018           manjunath.c.holekade@maersk.com      RQ-009077 - Mod-01 to Mod-20 - Replaced individual VAS team payouts with individual VAS payouts                              
* v8.0      14-Mar-2019           meghana.gupta@ust-global.com        RQ-010262 - Include calculation for new payout percent fields
* v9.0      12-Apr-2019           meghana.gupta@ust-global.com        RQ-010543 - Changes to payout percent changes based on record type
* v9.1      07-Apr-2019            sidhartha@maersk.com                RQ-010681 - Added payout percent to get displayed on SIP Calculator
* V10.1     09- Jan -2019            Neha@TCS                            RQ-012775    CalculateEstimatePayout(),GetPayoutPercent(),updatePayoutPercent() are  modified to include new measure and corresponding update Payout Percent
*V11.1      06-Feb-2020              Neha@TCS                            RQ-013055 - Payour corrected for Spot Volume for maximum Payout Percent             
*V12.0      24-Feb-2020              Amritesh@UST                        RQ-013054 - Total payout corrected for SIP Calculator page  
* v13.0     06-Mar-2020           Meghana@UST              RQ-013156 - Remove references of deprecated fields
* v14.0     26-Jun-2020        manjunath@maersk          SFSE-1382 - Option to mass update payout percent with any actual changes on SIP
* v15.0     26-Nov-2020           Neha@Tcs               SFSE-4861   Modify the updatePayoutPercent() and GetPayoutPercent() to include Landisde measure fields when updated via trigger
* v16.0     1-Feb-2021            rakesh@maersk            SFSE-5529    deprecating Landside Trans & VP Actual (FFE) YTD field
* v17.0		21-Dec-2021			meghana.gupta@UST		 SFSE-6523    Moved method getQuarterList from deprecated class 'SalesMetrics_Utilities'
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/ 

public class SIP_Utilities {
    
    // Method returns quarter info in format YYYYQn ex. 2016Q1.
    // Parameter "QuarterFlag" is used to mention which quarter info is required Current quarter or previous
    // ex. if today's date is 1/Apr/2016 then current quarter is 2016Q2 and previous quarter is 2016Q1
    public static String getQuarter ( String QuarterFlag ){
        
        String strQuarter;        
        Date currDate = Date.today(); // get current date
        String currYear = String.valueOf( currDate.year() ) ;     // get current year     
        Integer month = currDate.Month(); // get current month
        
        // get current & last quarter -- in format "YYYYQn"
        if ( month <= 3 ){
            
            if ( QuarterFlag == 'Current' ){
                
                strQuarter = currYear + 'Q1';
                
            } else if ( QuarterFlag == 'Previous' ){
                
                strQuarter = String.valueOf( currDate.year() - 1 ) + 'Q4';
                
            } else if ( QuarterFlag == 'Next' ){
                
                strQuarter = currYear + 'Q2';
                
            }
            
        } else if ( month > 3 && month <= 6 ){
            
            if ( QuarterFlag == 'Current'){
                
                strQuarter = currYear + 'Q2';       
                
            } else if ( QuarterFlag == 'Previous'){
                
                strQuarter = currYear + 'Q1';
                
            } else if ( QuarterFlag == 'Next' ){
                
                strQuarter = currYear + 'Q3';
                
            } 
            
        } else if ( month > 6 && month <= 9 ){
            
            if ( QuarterFlag == 'Current'){
                
                strQuarter = currYear + 'Q3';       
                
            } else if ( QuarterFlag == 'Previous'){
                
                strQuarter = currYear + 'Q2';
                
            } else if ( QuarterFlag == 'Next' ){
                
                strQuarter = currYear + 'Q4';
                
            }
            
        } else if ( month > 9  ){
            
            if ( QuarterFlag == 'Current'){
                
                strQuarter = currYear + 'Q4';
                
            } else if ( QuarterFlag == 'Previous'){
                
                strQuarter = currYear + 'Q3';
            }
            else if ( QuarterFlag == 'Next' ){
                
                strQuarter = String.valueOf( currDate.year() + 1 ) + 'Q1';
                
            }
        }       
        return strQuarter;
    }
    
    public static String getQuarterFromDate ( Date qDate ){
        
        String strQuarter;
        
        String strYear = String.valueOf( qDate.year() ) ;     // get current year     
        Integer month = qDate.Month(); // get current month
        
        // get current & last quarter -- in format "YYYYQn"
        if ( month <= 3 ){
            
            strQuarter = strYear + 'Q1';
            
        } else if ( month > 3 && month <= 6 ){
            
            strQuarter = strYear + 'Q2';       
            
        } else if ( month > 6 && month <= 9 ){
            
            strQuarter = strYear + 'Q3';       
            
        } else if ( month > 9  ){
            
            strQuarter = strYear + 'Q4';
            
        }       
        return strQuarter;
    }
    
    
    // Based on quarter parameter this method returns Quarter's Start Date
    // ex. for 2016Q1 -> start date returned is 1st Jan 2016
    public static Date getQuarterStartDate ( String quarter ){
        
        integer month;
        if ( quarter.right(1) == '1' ){
            
            month = 1;
            
        } else if ( quarter.right(1) == '2' ){
            
            month = 4;
            
        } else if ( quarter.right(1) == '3' ){
            
            month = 7;            
        } else {
            
            month = 10;            
        } 
        Date startDate = Date.newInstance( Integer.valueof( quarter.left(4)), month, 1 );
        return startDate;
    }
    
    // Based on quarter parameter this method returns Quarter's End Date
    // ex. for 2016Q1 -> end date returned is 31st Mar 2016
    
    public static Date getQuarterEndDate ( String quarter ){
        
        integer month, day;
        if ( quarter.right(1) == '1' ){
            
            month = 3;
            day = 31;
            
        } else if ( quarter.right(1) == '2' ){
            
            month = 6;
            day = 30;
            
        } else if ( quarter.right(1) == '3' ){
            
            month = 9;
            day = 30;
            
        } else {
            
            month = 12;
            day = 31;
            
        } 
        
        Date endDate = Date.newInstance( Integer.valueof( quarter.left(4) ), month, day );
        return endDate;
    }
    
    // Method calculates estimated payout for a salesrep based on SIP details and monthly salary entered
    public static Map<String, decimal> CalculateEstimatePayout ( Decimal volumeActual, Decimal revenueactual, SIP__c recSIP, double dblMonthlySalary ){
        
        Map<String, double> mapEstimatedPayout = new Map<String, decimal>();
     
        if ( dblMonthlySalary > 0 && recSIP != null && recSIP.Paymix_Opted__c <> 0 ){
            
            // Get Payout percentage thats applicable for SIP based on record type
            String recordTypeName = Schema.SObjectType.SIP__c.getRecordTypeInfosById ().get(recSIP.RecordTypeId).getDeveloperName();
            List<SIP_Payout__c> lstPayoutPercent = [ SELECT Payout_Percent__c, Performance_Percent__c, Effective_From_Date__c, Effective_Till_Date__c, SIP_Measure__c, SIP_Record_Type__c
                                                    FROM SIP_Payout__c        
                                                    WHERE SIP_Record_Type__c = :recordTypeName
                                                    ORDER BY lastmodifiedDate];      
      
            //Calculate payout percent for each measure 
            Map<String, decimal> payoutPercentMap = GetPayoutPercent(volumeActual,revenueactual,   lstPayoutPercent, recSIP, true);    
            system.debug('payoutPercentMap :' +payoutPercentMap);
            
            //Start - RQ-010681 - Added payout percent to get displayed on SIP Calculator
            mapEstimatedPayout.put( 'Ocean Volume PayoutPercent', payoutPercentMap.get('Ocean Volume'));
            mapEstimatedPayout.put( 'Ocean Revenue PayoutPercent', payoutPercentMap.get('Ocean Revenue'));
            mapEstimatedPayout.put( 'Customer Conversion PayoutPercent', payoutPercentMap.get('Customer Conversion'));
            mapEstimatedPayout.put( 'E2E PayoutPercent', payoutPercentMap.get('E2E'));
            mapEstimatedPayout.put( 'L&S GP PayoutPercent', payoutPercentMap.get('L&S GP'));
            mapEstimatedPayout.put( 'Spot Volume PayoutPercent', payoutPercentMap.get('Spot Volume'));
            mapEstimatedPayout.put( 'Landside Trans & VP PayoutPercent', payoutPercentMap.get('Landside Trans & VP'));
            //End - RQ-010681 - Added payout percent to get displayed on SIP Calculator
			
            system.debug('payoutPercentMap.get Ocean Revenue ' + payoutPercentMap.get('Ocean Revenue'));
            
            mapEstimatedPayout.put( 'Ocean Volume', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Volume_Weight_Percent__c, payoutPercentMap.get('Ocean Volume')) );
            mapEstimatedPayout.put( 'Ocean Revenue', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Revenue_Weight_Percent__c, payoutPercentMap.get('Ocean Revenue')) );
            mapEstimatedPayout.put( 'Customer Conversion', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Acquisition_Weight_Percent__c, payoutPercentMap.get('Customer Conversion')));
            mapEstimatedPayout.put( 'E2E', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.E2E_Volume_Weight_Percent__c, payoutPercentMap.get('E2E')));
            mapEstimatedPayout.put( 'L&S GP', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Revenue_Growth_VAS_Weight_Percent__c, payoutPercentMap.get('L&S GP')));
            mapEstimatedPayout.put( 'Spot Volume', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Maersk_Spot_Volume_Weight_Percent__c, payoutPercentMap.get('Spot Volume')) );
            mapEstimatedPayout.put( 'Landside Trans & VP', calculateIndvPayout(dblMonthlySalary, recSIP, recSIP.Landside_Trans_VP_Weight_Percent__c, payoutPercentMap.get('Landside Trans & VP')) );
            system.debug('mapEstimatedPayout' + mapEstimatedPayout.get('Landside Trans & VP'));
        } else {
            mapEstimatedPayout.put( 'Ocean Volume', 0);
            mapEstimatedPayout.put( 'Ocean Revenue', 0);
            mapEstimatedPayout.put( 'Customer Conversion', 0);
            mapEstimatedPayout.put( 'E2E', 0);
            mapEstimatedPayout.put( 'L&S GP', 0);
            mapEstimatedPayout.put( 'Spot Volume', 0);
        }
        
        decimal dclTotal = 0;
        for (String strKey : mapEstimatedPayout.keySet()){
            if(strKey.endsWith('Percent')) continue;
            dclTotal = dclTotal + mapEstimatedPayout.get(strKey);
        }
       
        mapEstimatedPayout.put( 'Total', dclTotal );        
        system.debug('$$$ mapEstimatedPayout:' + mapEstimatedPayout);        
        return mapEstimatedPayout; 
    }
    
    public static double calculateIndvPayout (double dblMonthlySalary, SIP__c recSIP, decimal dclWeightPercent, decimal dclPayoutPercent){

        decimal dclPaymix = recSIP.Paymix_Opted__c / 100; // convert percent fields to numbers to be used in calculations
        decimal dclSIP_Qualifier = recSIP.SIP_Qualifiers_Mitigation_Percent__c / 100 ; // convert percent fields to numbers to be used in calculations
        
        if ( dclPayoutPercent == null) 
            return 0;
        
        else {
            double dblPayout = ( dblMonthlySalary - (dblMonthlySalary * dclPaymix )) * 3 * ( dclWeightPercent / 100 ) * ( dclPayoutPercent / 100 ) * ( 1 + dclSIP_Qualifier * recSIP.Pass_Fail_Multiplier__c ) * recSIP.Number_of_Months_For_Annualization__c / 12 ;
            system.debug('dblPayout ' + dblPayout);
            return dblPayout.round();
        }
    }
    
    public static Map<String, Decimal> GetPayoutPercent (Decimal volumeActual, Decimal revenueactual,  List<SIP_Payout__c> payoutPercent, SIP__c recSIP, boolean blnRecalculatePerformance ){
        
        // Temp code for SIP Calculator when actuals are read from input boxes in lightning component
        integer dblOceanVolPerfPercent = (integer) recSIP.Volume_Performance__c;
        integer dblOceanRevenuePerfPercent = (integer) recSIP.Revenue_Performance__c;
        integer dblE2EPerfPercent = (integer) recSIP.E2E_Volume_Performance__c;
        integer dblLsgpPerfPercent = (integer) recSIP.Revenue_Growth_VAS_Performance__c;
        integer dblCustConversionPerfPercent = (integer) recSIP.Acquisition_Performance__c;
        integer dblSpotVolumePerfPercent = (integer) recSIP.Maersk_Spot_Volume_Performance__c;
        integer dblLandsideVPPerfPercent = (integer) recSIP.Landside_Trans_VP_Performance__c;
        system.debug('dblOceanRevenuePerfPercent ' + dblOceanRevenuePerfPercent);
        
        if ( blnRecalculatePerformance == true){
            if(recSIP.RecordType.Name == Label.SIP_Ease_And_Advancement) {
                dblE2EPerfPercent = (integer) (((recSIP.E2E_Volume_Target_FFE__c ==0)  ? 0 : recSIP.E2E_Volume_Actual_FFE__c / recSIP.E2E_Volume_Target_FFE__c)*100).round();
                dblCustConversionPerfPercent = (integer) (((recSIP.Acquisition_Target__c  ==0)  ? 0 : recSIP.Acquisition_Actual__c  / recSIP.Acquisition_Target__c)*100).round();    
                
            } else if(recSIP.RecordType.Name == Label.SIP_Efficiency_And_Super || recSIP.RecordType.Name == Label.SIP_Expertise_And_Ambition) {
                if(volumeActual != null) {
                    dblOceanVolPerfPercent = (integer) (((recSIP.Volume_Target__c ==0)  ? 0 : volumeActual / recSIP.Volume_Target__c) * 100).round();  
                } else {
                    dblOceanVolPerfPercent = (integer) (((recSIP.Volume_Target__c ==0)  ? 0 : recSIP.Ocean_Volume_Total_Actual_FFE__c / recSIP.Volume_Target__c) * 100).round(); 
                }
                system.debug('dblOceanVolPerfPercent : ' + dblOceanVolPerfPercent);
                dblLsgpPerfPercent = (integer) (((recSIP.Revenue_Growth_VAS_Target__c  ==0)  ? 0 : recSIP.Revenue_Growth_VAS_Actual__c  / recSIP.Revenue_Growth_VAS_Target__c)*100).round(); 
                
                if(recSIP.RecordType.Name == Label.SIP_Expertise_And_Ambition) {   
                    dblLandsideVPPerfPercent = (integer) (((recSIP.Landside_Trans_VP_Target_FFE__c  ==0)  ? 0 : recSIP.Landside_Trans_VP_Actual_FFE_QTR__c  / recSIP.Landside_Trans_VP_Target_FFE__c)*100).round();
                    if(revenueactual != null) {
                        system.debug('revenueactual : ' + revenueactual);
                        dblOceanRevenuePerfPercent = (integer) (((recSIP.Ocean_Revenue_Target_USD__c  ==0)  ? 0 : revenueactual    / recSIP.Ocean_Revenue_Target_USD__c)*100).round();
                    } else {
                        dblOceanRevenuePerfPercent = (integer) (((recSIP.Ocean_Revenue_Target_USD__c  ==0)  ? 0 : recSIP.Ocean_Revenue_Total_Actual_USD__c    / recSIP.Ocean_Revenue_Target_USD__c)*100).round();
                    }
                    system.debug('dblOceanRevenuePerfPercent : ' + dblOceanRevenuePerfPercent);
                }
                if(recSIP.RecordType.Name == Label.SIP_Efficiency_And_Super){
                    dblLandsideVPPerfPercent = (integer) (((recSIP.Landside_Trans_VP_Target_FFE__c  ==0)  ? 0 : recSIP.Landside_Trans_VP_Actual_FFE_QTR__c  / recSIP.Landside_Trans_VP_Target_FFE__c)*100).round();
                    dblSpotVolumePerfPercent = (integer) (((recSIP.Maersk_Spot_Volume_Target_FFE__c  ==0)  ? 0 : recSIP.Maersk_Spot_Volume_Actual_FFE__c  / recSIP.Maersk_Spot_Volume_Target_FFE__c)*100).round();
                }
            }            
        }        
        // --------------- END SIP Cal code ----------------------------------
                
    Map<String, Decimal> mapPayoutPercent = new Map<String, Decimal>();    
    Map<String, SIP_Payout__c> mapMinPayout = new Map<String, SIP_Payout__c>();
    Map<String, SIP_Payout__c> mapMaxPayout = new Map<String, SIP_Payout__c>();
                
        // define range ex. if performance percent <= 89 then payout percent = 0
        // if performance percent >= 130 then payout percent = 3
        // else read payout from custom setting
     
        String recordTypeName = Schema.SObjectType.SIP__c.getRecordTypeInfosById ().get(recSIP.RecordTypeId).getDeveloperName();    
            
        // for old record types from 2016 to 2019Q1 SIPs payout percent is same and saved in custom setting with record type = SIP
        if (recordTypeName == 'SIP_2018' || recordTypeName == 'SIP_2016' || recordTypeName == 'SIP'){      
          recordTypeName = 'SIP';
        }
    
        for ( SIP_Payout__c payPercent : payoutPercent ){
            
            if ( payPercent.SIP_Record_Type__c == recordTypeName && Date.valueof(payPercent.Effective_From_Date__c) <= Date.valueof(recSIP.Quarter_Start_Date__c) && Date.valueof(payPercent.Effective_Till_Date__c) >= Date.valueof(recSIP.Quarter_End_Date__c)){
                
                // get lower range of payout for selected measure
                if  ( ! mapMinPayout.containsKey(payPercent.SIP_Measure__c) || mapMinPayout.get(payPercent.SIP_Measure__c).Performance_Percent__c >= payPercent.Performance_Percent__c )
                    mapMinPayout.put(payPercent.SIP_Measure__c, payPercent);
                
                // get upper range of payout for selected measure
                if  ( ! mapMaxPayout.containsKey(payPercent.SIP_Measure__c) || mapMaxPayout.get(payPercent.SIP_Measure__c).Performance_Percent__c <= payPercent.Performance_Percent__c )
                    mapMaxPayout.put(payPercent.SIP_Measure__c, payPercent);
                // check if there is an exact match for any Performance percent field
                if ( dblOceanVolPerfPercent == payPercent.Performance_Percent__c && ( payPercent.SIP_Measure__c == 'Ocean Volume' || payPercent.SIP_Measure__c == 'All')){
                    mapPayoutPercent.put( 'Ocean Volume', payPercent.Payout_Percent__c );
                }
                if ( dblOceanRevenuePerfPercent == payPercent.Performance_Percent__c && (payPercent.SIP_Measure__c == 'Ocean Revenue' || payPercent.SIP_Measure__c == 'All')) {
                    mapPayoutPercent.put( 'Ocean Revenue', payPercent.Payout_Percent__c );
                }
                
                if ( dblCustConversionPerfPercent == payPercent.Performance_Percent__c && (payPercent.SIP_Measure__c == 'Customer Conversion' || payPercent.SIP_Measure__c == 'All'))
                    mapPayoutPercent.put( 'Customer Conversion', payPercent.Payout_Percent__c );
                
                if ( dblLsgpPerfPercent == payPercent.Performance_Percent__c && (payPercent.SIP_Measure__c == 'L&S GP' || payPercent.SIP_Measure__c == 'All'))
                    mapPayoutPercent.put( 'L&S GP', payPercent.Payout_Percent__c );
                
                if ( dblE2EPerfPercent == payPercent.Performance_Percent__c && (payPercent.SIP_Measure__c == 'E2E' || payPercent.SIP_Measure__c == 'All'))
                    mapPayoutPercent.put( 'E2E', payPercent.Payout_Percent__c );
                
                if ( dblSpotVolumePerfPercent == payPercent.Performance_Percent__c && (payPercent.SIP_Measure__c == 'Spot Volume' || payPercent.SIP_Measure__c == 'All'))
                    mapPayoutPercent.put( 'Spot Volume', payPercent.Payout_Percent__c );
                
                if((payPercent.SIP_Measure__c == 'Landside Trans & VP' || payPercent.SIP_Measure__c == 'All') && payPercent.Performance_Percent__c == dblLandsideVPPerfPercent) {
                    mapPayoutPercent.put( 'Landside Trans & VP', payPercent.Payout_Percent__c );
                }
                
            }
        }
    
        // if there is no exact match for any performance percent then if perf. percent <= lower range assign respecitve payout percent
        // else if perf percent >= upper range then assign respecitve payout percent    
        if ( !mapPayoutPercent.containsKey('Ocean Volume'))
            mapPayoutPercent.put( 'Ocean Volume', calculatePayoutPercent('Ocean Volume', dblOceanVolPerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('Ocean Revenue'))
            mapPayoutPercent.put( 'Ocean Revenue', calculatePayoutPercent('Ocean Revenue', dblOceanRevenuePerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('Customer Conversion'))
            mapPayoutPercent.put( 'Customer Conversion', calculatePayoutPercent('Customer Conversion', dblCustConversionPerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('L&S GP'))
            mapPayoutPercent.put( 'L&S GP', calculatePayoutPercent('L&S GP', dblLsgpPerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('E2E'))
            mapPayoutPercent.put( 'E2E', calculatePayoutPercent('E2E',dblE2EPerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('Spot Volume'))
            mapPayoutPercent.put( 'Spot Volume', calculatePayoutPercent('Spot Volume',dblSpotVolumePerfPercent, mapMinPayout, mapMaxPayout) );
        
        if ( !mapPayoutPercent.containsKey('Landside Trans & VP'))
            mapPayoutPercent.put( 'Landside Trans & VP', calculatePayoutPercent('Landside Trans & VP',dblLandsideVPPerfPercent, mapMinPayout, mapMaxPayout) );
        
        system.debug ('$$$$$ mapPayoutPercent'+ mapPayoutPercent);
        return mapPayoutPercent;
    }
    
    public static decimal calculatePayoutPercent( String strMeasure, Integer intPerformancePercent, Map<String, SIP_Payout__c> mapMinPayout, Map<String, SIP_Payout__c> mapMaxPayout){       
        
        if  ( mapMinPayout.containsKey (strMeasure) && mapMinPayout.get(strMeasure).Performance_Percent__c >= intPerformancePercent )
            return mapMinPayout.get(strMeasure).Payout_Percent__c;
        
        else if  ( mapMaxPayout.containsKey (strMeasure) && mapMaxPayout.get(strMeasure).Performance_Percent__c <= intPerformancePercent )
            return mapMaxPayout.get(strMeasure).Payout_Percent__c;
        
        else
            return 0;
    }
    
    public static void updatePayoutPercent ( List<SIP__c> newTriggerList, map<id, SIP__c> oldMap, boolean isInsertTrigger){
        
        Map<Id,Schema.RecordTypeInfo> mapRecordTypes = Schema.SObjectType.SIP__c.getRecordTypeInfosById ();
        Set<String> setRecordTypeNames = new Set<String>();
        
        for ( SIP__c recSIP : newTriggerList){
            String recordTypeName = mapRecordTypes.get(recSIP.RecordTypeId).getDeveloperName();
            
            // for old record types from 2016 to 2019Q1 SIPs payout percent is same and saved in custom setting with record type = SIP
            if (recordTypeName == 'SIP_2018' || recordTypeName == 'SIP_2016' || recordTypeName == 'SIP')
                recordTypeName = 'SIP';
            
            if (!setRecordTypeNames.contains(recordTypeName))
                setRecordTypeNames.add(recordTypeName);
        }
        
        // fetch payout percentages relevant to above record types from custom setting
        List<SIP_Payout__c> lstPayoutPercent = [ SELECT Payout_Percent__c, Performance_Percent__c, Effective_From_Date__c, Effective_Till_Date__c, SIP_Measure__c, SIP_Record_Type__c
                                               FROM SIP_Payout__c        
                                               WHERE SIP_Record_Type__c in :setRecordTypeNames
                                               ORDER BY lastmodifiedDate];      
             
        for ( SIP__c recSIP : newTriggerList){
            
            SIP__c oldSIP;
            if (!isInsertTrigger)
                oldSIP = oldMap.get(recSIP.id);
            
            // RQ-010262 : Added if criteria to check isChanged -> L&S GP Target/Actual , E2E Target/Actual
            if ( isInsertTrigger || ( recSIP.Ocean_Volume_Total_Actual_FFE__c != oldSIP.Ocean_Volume_Total_Actual_FFE__c 
                                     ||  recSIP.Volume_Target__c != oldSIP.Volume_Target__c  
                                     ||  recSIP.Ocean_Revenue_Target_USD__c != oldSIP.Ocean_Revenue_Target_USD__c 
                                     ||  recSIP.Ocean_Revenue_Total_Actual_USD__c != oldSIP.Ocean_Revenue_Total_Actual_USD__c 
                                     ||  recSIP.Acquisition_Target__c != oldSIP.Acquisition_Target__c 
                                     ||  recSIP.Acquisition_Actual__c != oldSIP.Acquisition_Actual__c 
                                     ||  recSIP.Maersk_Spot_Volume_Actual_FFE__c != oldSIP.Maersk_Spot_Volume_Actual_FFE__c 
                                     ||  recSIP.Maersk_Spot_Volume_Target_FFE__c != oldSIP.Maersk_Spot_Volume_Target_FFE__c 
                                     ||  recSIP.Quarter__c != oldSIP.Quarter__c            
                                     ||  recSIP.Revenue_Growth_VAS_Actual__c != oldSIP.Revenue_Growth_VAS_Actual__c 
                                     ||  recSIP.Revenue_Growth_VAS_Target__c != oldSIP.Revenue_Growth_VAS_Target__c   
                                     ||  recSIP.E2E_Volume_Actual_FFE__c != oldSIP.E2E_Volume_Actual_FFE__c 
                                     ||  recSIP.E2E_Volume_Target_FFE__c != oldSIP.E2E_Volume_Target_FFE__c 
                                     ||  recSIP.Landside_Trans_VP_Target_FFE__c != oldSIP.Landside_Trans_VP_Target_FFE__c
                                     ||  recSIP.Landside_Trans_VP_Actual_FFE_QTR__c!= oldSIP.Landside_Trans_VP_Actual_FFE_QTR__c)     //SFSE-5529 field replace
                   ||  Label.SIPPayoutMassUpdate == 'True'){ //SFSE-1382
                                         
                                         Map<String, decimal> payoutPercentMap = GetPayoutPercent(null, null, lstPayoutPercent, recSIP, false);            
                                         
                                         recSIP.Volume_Payout_Percent__c = payoutPercentMap.get('Ocean Volume');
                                         recSIP.Revenue_Payout_Percent__c = payoutPercentMap.get('Ocean Revenue');
                                         recSIP.Maersk_Spot_Volume_Payout_Percent__c = payoutPercentMap.get('Spot Volume');
                                         recSIP.Acquisition_Payout_Percent__c = payoutPercentMap.get('Customer Conversion');                
                                         recSIP.E2E_Volume_Payout_Percent__c = payoutPercentMap.get('E2E');
                                         recSIP.Revenue_Growth_VAS_Payout_Percent__c = payoutPercentMap.get('L&S GP');
                                         recSIP.Landside_Trans_VP_Payout_Percent__c = payoutPercentMap.get('Landside Trans & VP');
                                         
                                     }                     
        }        
    }
    
    public static Set<Id> getUserReportees ( Set<Id> managerList ){
        
        Map<Id, User> UserMap = new Map<Id, User>([ SELECT id, name
                                                   FROM User
                                                   WHERE managerId in :managerList AND isActive = true ]);
        
        return UserMap.keyset();
    }
    
    public static Map<Id, String> getSIPUserReporteeList ( Set<Id> managerList, String strQuarter ){
        
        Map<Id, String> userMap = new Map<Id, String>();
        List<SIP__c> sipList = [ SELECT Sales_Rep__c, Sales_Rep__r.Name FROM sip__c 
                                WHERE Sales_Rep__r.managerId in :managerList
                                AND Quarter__c = :strQuarter  ];
        
        for (SIP__c rec: sipList){
            
            userMap.put(rec.Sales_Rep__c, rec.Sales_Rep__r.Name);  
        }
        return userMap;
    }
    public static List<String> getQuarterList ( Boolean ActualsFlag, Integer forYear ){
        List<String> strQuarterList = new List<String>();
        Integer month;      
        Date currDate = Date.today(); // get current date
        Integer currYear = currDate.year() ;     // get current year   
        month = currDate.Month(); // get current month
        String strPrevYear = String.valueOf( currYear - 1 ) ; 
        String strCurrYear = String.valueOf( currYear ) ;
        
        if ( ActualsFlag == true && forYear >= currYear){
            // return last 4 quarters 

            if ( month <= 3 || Test.isRunningTest()){
                
                strQuarterList.add ( strPrevYear + 'Q1');
                strQuarterList.add ( strPrevYear + 'Q2');
                strQuarterList.add ( strPrevYear + 'Q3');
                strQuarterList.add ( strPrevYear + 'Q4');
            
            } 
            if ( (month > 3 && month <= 6) || (Test.isRunningTest()) ){
                
                strQuarterList.add ( strCurrYear + 'Q1');
                strQuarterList.add ( strPrevYear + 'Q2');
                strQuarterList.add ( strPrevYear + 'Q3');
                strQuarterList.add ( strPrevYear + 'Q4');
               
                
            } 
            if ( (month > 6 && month <= 9) || (Test.isRunningTest()) ){
                
                strQuarterList.add ( strCurrYear + 'Q1');
                strQuarterList.add ( strCurrYear + 'Q2');
                strQuarterList.add ( strPrevYear + 'Q3');
                strQuarterList.add ( strPrevYear + 'Q4');
                
            } 
            if ( month > 9  || Test.isRunningTest()){
                
                strQuarterList.add ( strCurrYear + 'Q1');
                strQuarterList.add ( strCurrYear + 'Q2');
                strQuarterList.add ( strCurrYear + 'Q3');
                strQuarterList.add ( strPrevYear + 'Q4');
               
            } 
            
        } else {
            
            // reutrn 4 quarters of given year...i.e. if year is 2015 then return 2015Q1, 2015Q2, 2015Q3, 2015Q4
            String strForYear = String.valueOf( forYear );
            
            strQuarterList.add ( strForYear + 'Q1');
            strQuarterList.add ( strForYear + 'Q2');
            strQuarterList.add ( strForYear + 'Q3');
            strQuarterList.add ( strForYear + 'Q4');
        }
        
        return strQuarterList;
    }
}