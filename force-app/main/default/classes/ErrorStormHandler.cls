/*
* Author   : Jiji
* Purpose  : Handler class to handle error storm scenario while logging exceptions/errors to Global Error Logger.
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002946   04-Mar-2016 Jiji@UST                Handler class to be called to handle error storm scenario while 
*                                                          logging exceptions/errors to Global Error Logger.
* 2.0      RQ-004100   14-Jun-2016 Jiji@UST                Resolve issues in ErrorStormHandler. Fix Custom Setting Name too long
*/

public class ErrorStormHandler {
    
    // Facility to skip the error storm condition check.
    private static boolean skipErrorStormCheck = true;
    public static void skipErrorStormCheck(boolean bSkip) {
        skipErrorStormCheck = bSkip;
    }
    public static boolean skipErrorStormCheck() {
        return skipErrorStormCheck;
    }
    
    // Method to check the custom setting configuration prior to error logging
    // The system will return false, if an error storm scenario exist. Else return true.
    public static boolean isErrorStorm(string sourceString, string objectString, integer i) {
        if(skipErrorStormCheck) {
            return true;
        }
        
        Boolean writeLog = false;
        Error_Log_Configuration__c errLogConfigRecord;
        
        long lStartTime;
        Integer totalErrors;
        boolean bStopErrorLogging;
        
        // Get the custom setting key value based on the source and object string
        if(!String.isBlank(sourceString)) {
            if(!String.isBlank(objectString)) {
                // Get the custom setting records based on source and object string
                String custSettingNameString = sourceString + ':' + objectString;
                errLogConfigRecord = Error_Log_Configuration__c.getValues(custSettingNameString.left(38));
            }
            if(errLogConfigRecord == null) {
                // Get the custom setting records based on source string
                errLogConfigRecord = Error_Log_Configuration__c.getValues(sourceString.left(38));
            }
        }
        if(errLogConfigRecord == null) {
            errLogConfigRecord = Error_Log_Configuration__c.getValues(System.label.Default_Error_Logger_Category);
        }
        system.debug('****errLogConfigRecord-->'+errLogConfigRecord);
        if(errLogConfigRecord != null) {
            // Get the time value in Start Timer field.
            long startTime = 0;
            if(errLogConfigRecord.Start_Timer__c != null) {
                startTime = errLogConfigRecord.Start_Timer__c.getTime();
            }
            
            // Get current time.
            long currentTime = System.now().getTime();
            
            // Get the difference between current time and start time in minutes
            long diffInMinutes = (currentTime - startTime)/60000;
            
            /* Reset start time, Stop error logging check box, total errors and write log boolean 
if the new error is coming for the first time or after the max time is elapsed.
Error will be written to the Global error logger object. Returns true.
*/
            if(errLogConfigRecord.Start_Timer__c == null || diffInMinutes >= errLogConfigRecord.Time_Period_Minutes__c) {
                writeLog = true;
                errLogConfigRecord.Total_Errors__c = i; // Ver 2.0: Set total error count
                errLogConfigRecord.Start_Timer__c = System.now();
                errLogConfigRecord.Stop_Error_Logging__c = false;
            }
            
            // Write the log if total error is less than max error in custom setting. Increment total errors. Returns true
            if(errLogConfigRecord.Total_Errors__c < errLogConfigRecord.Max_Errors__c) {
                if(diffInMinutes < errLogConfigRecord.Time_Period_Minutes__c) {
                    writeLog = true;
                    errLogConfigRecord.Total_Errors__c = errLogConfigRecord.Total_Errors__c + i; // Ver 2.0: Set total error count
                }
            }
            else {
                // If total error is greater than max error in custom setting: Set Stop Error Logging = true,
                // Increment the total error. Dont write the exception. Returns false
                writeLog = false;
                errLogConfigRecord.Stop_Error_Logging__c = true;
                errLogConfigRecord.Total_Errors__c = errLogConfigRecord.Total_Errors__c + i; // Ver 2.0: Set total error count
            }
        }
        else {
            System.debug('##### Error occured in ErrorStormHandler as no valid configuration available in Error Log Configuration.');
            return false;
        }
        
        // Update custom setting and return the boolean
        if(errLogConfigRecord != null) {
            try {
                update errLogConfigRecord; 
            }
            catch(Exception e) {
                System.debug('##### Exception --> ' + e);
            }
        }
        return writeLog;
    }
    
}