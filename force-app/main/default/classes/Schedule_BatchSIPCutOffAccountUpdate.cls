/*
Description  : On SIP cut off day of quarter copy brand owner Ids to respective brand owner text fields in Account.

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          09/06/2016          meghana.gupta@ust-global.com          RQ-004052: 
* V2.0          11/10/2017          meghana.gupta@ust-global.com          RQ-005510: run job a day before cut off day
------------------------------------------------------------------------------------------------------
*/

global class Schedule_BatchSIPCutOffAccountUpdate implements Schedulable {

    global void execute( SchedulableContext SC ) {
        
        // Check cut off date from Custom setting
        Integer cutOffDay = (integer) Environment_Variables__c.getInstance('SIP Cut Of Date').Value__c;
        
        cutOffDay = cutOffDay + 1; // v2.0 run job a day before cut off day.
        
        String currQuarter = SIP_Utilities.getQuarter ('Current');
        Date QuarterEndDate = SIP_Utilities.getQuarterEndDate( currQuarter );
        
        Date cutOffDate = QuarterEndDate.addDays(0 - cutOffDay); // subtract cutOffDay count from end date 
        
        // if system date matches Current Quarter End Date - Cut Off Day count from custom setting then execute batch job
        if ( cutOffDate == system.today() ){            
        
            BatchSIPCutOffAccountUpdate b = new BatchSIPCutOffAccountUpdate();
            Database.executeBatch( b, 1000 );
        }
    }
    
}