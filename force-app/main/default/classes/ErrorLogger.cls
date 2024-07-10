/*
* Author   : Jiji
* Purpose  : Handler class to be called to store the exceptions during code execution 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002946   04-Mar-2016 Jiji@UST                Code Created
* 2.0      RQ-004100   14-Jun-2016 Jiji@UST                Resolve issues in ErrorStormHandler
* 3.0      RQ-005306   16-May-3017 Nisha@UST               Changes in ErrorLogger to support logging of record id's.
*/

public class ErrorLogger {
    
    private static Batch_Error_Logger__c getGlobalErrorLogger(String strSourceSystem, String strObjectName, String strMethodName, String strExceptionCode, String strExceptionSummary, String strExceptionDetails) {
        Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
        String nameString = (String.isBlank(strSourceSystem) ? System.label.Default_Error_Logger_Category : (String.isBlank(strObjectName) ? strSourceSystem : strSourceSystem + ':' + strObjectName));
        globalErrorLogger.Name = nameString.left(55) + ' - ' + System.now().format();
        globalErrorLogger.Source_System__c = strSourceSystem;
        globalErrorLogger.Object__c = strObjectName;
        globalErrorLogger.Batch_Name__c = strMethodName;
        globalErrorLogger.Operation_Type__c = 'Execution Error';
        globalErrorLogger.Exception_Code__c = strExceptionCode;
        if(!String.isBlank(strExceptionSummary)) {
            globalErrorLogger.Exception_Summary__c = strExceptionSummary.left(254);
        }
        globalErrorLogger.Exception_Detail__c = strExceptionDetails;
        return globalErrorLogger;
    }
    
    private static Boolean insertGlobalErrorLogger(Batch_Error_Logger__c error) {
        try {
            insert error;
        }
        catch(Exception ex) {
            return false;
        }
        return true;
    }
    
    private static Boolean insertGlobalErrorLogger(list<Batch_Error_Logger__c> lstBatchErrors) {
        try {
            insert lstBatchErrors;
        }
        catch(Exception ex) {
            return false;
        }
        return true;
    }
    
    /* 
* Purpose: Write error messages to the Global Error logger Object.
* Params,
*   strSourceSystem: Source system name where error occured. E.g. SFDC 
*   strObjectName: Name of the object as applicable.
*   strMethodName: Name of the method where exception is thrown.
*   strExceptionCode: Exception Code from exception object or external system.
*   strExceptionSummary: Summay of the exception.
*   strExceptionDetail: Detail of the exception which includes record id as well.
*/
    public static Boolean writeError(String strSourceSystem, String strObjectName, String strMethodName, String strExceptionCode, String strExceptionSummary, String strExceptionDetail) {
        if(strExceptionCode != null || strExceptionSummary != null || strExceptionDetail != null) {
            // Write exception only if this is not error storm.
            if(ErrorStormHandler.isErrorStorm(strSourceSystem, strObjectName, 1) == true) { // RQ-004100
                Batch_Error_Logger__c batchError = ErrorLogger.getGlobalErrorLogger(strSourceSystem, strObjectName, strMethodName, strExceptionCode, strExceptionSummary, strExceptionDetail);
                return insertGlobalErrorLogger(batchError);
            }
        }
        return false;
    }
    
    /* 
* Purpose: Write error messages to the Global Error logger Object.
* Params,
*   strSourceSystem: Source system name where error occured. E.g. SFDC 
*   strObjectName: Name of the object as applicable.
*   strMethodName: Name of the method where exception is thrown.
*   lstExceptions: List of exceptions.
*/
    public static Boolean writeErrors(String strSourceSystem, String strObjectName, String strMethodName, list<Exception> lstExceptions) {
        Boolean bSuccess = true;
        if(lstExceptions != null) {
            // Write exception if this is not error storm.
            if(ErrorStormHandler.isErrorStorm(strSourceSystem, strObjectName, lstExceptions.size()) == true) { // RQ-004100
                list<Batch_Error_Logger__c> lstBatchErrors = new list<Batch_Error_Logger__c>();
                for(Exception errorRec : lstExceptions) {
                    Batch_Error_Logger__c globalErrorLogger = ErrorLogger.getGlobalErrorLogger(strSourceSystem, strObjectName, strMethodName, errorRec.getTypeName(), errorRec.getMessage(), errorRec.getStackTraceString());
                    globalErrorLogger.Exception_Cause__c = String.valueOf(errorRec.getCause()); // Exception Cause
                    lstBatchErrors.add(globalErrorLogger);
                }
                return insertGlobalErrorLogger(lstBatchErrors);
            }
        }
        return false;
    }
    
    /* 
* Purpose: Write error messages to the Global Error logger Object.
* Params,
*   strSourceSystem: Source system name where error occured. E.g. SFDC 
*   strObjectName: Name of the object as applicable.
*   strMethodName: Name of the method where exception is thrown.
*   lstSaveResults: List of Database.SaveResult.
*/
    public static Boolean writeErrors(String strSourceSystem, String strObjectName, String strMethodName, list<Database.SaveResult> lstSaveResults, list<sObject> lstSObjects) {
        if(lstSaveResults != null) {
            // Write exception if this is not error storm.
            if(ErrorStormHandler.isErrorStorm(strSourceSystem, strObjectName, lstSaveResults.size()) == true) { // RQ-004100
                Boolean bErrors = false;
                String strExceptionCode = '';
                String strExceptionSummary = '';
                String strExceptionDetails = '';
                
                for(Integer i=0; i<lstSaveResults.size(); i++) {
                    Database.SaveResult sr = lstSaveResults[i];
                    if(!sr.isSuccess()) {
                        strExceptionDetails = strExceptionDetails + lstSObjects[i].Id + ' => ';
                        for(Database.Error errorRec : sr.getErrors()) {
                            if(!bErrors) {
                                strExceptionCode = String.valueOf(errorRec.getStatusCode());
                                strExceptionSummary = errorRec.getMessage();
                                bErrors = true;
                            }
                            strExceptionDetails = strExceptionDetails + errorRec.getMessage() + '; ';
                        }
                        strExceptionDetails = strExceptionDetails + '\n\n';
                    }
                }
                if(bErrors) {
                    Batch_Error_Logger__c batchError = ErrorLogger.getGlobalErrorLogger(strSourceSystem, strObjectName, strMethodName, strExceptionCode, strExceptionSummary, strExceptionDetails);
                    return insertGlobalErrorLogger(batchError);
                }
            }
        }
        return false;
    }
    
    /* 
* Purpose: Write error messages to the Global Error logger Object.
* Params,
*   strSourceSystem: Source system name where error occured. E.g. SFDC 
*   strObjectName: Name of the object as applicable.
*   strMethodName: Name of the method where exception is thrown.
*   lstUpsertResults: List of Database.UpsertResult.
*/  
    public static Boolean writeErrors(String strSourceSystem, String strObjectName, String strMethodName, list<Database.UpsertResult> lstUpsertResults, list<sObject> lstSObjects) {
        if(lstUpsertResults != null) {
            // Write exception if this is not error storm.
            if(ErrorStormHandler.isErrorStorm(strSourceSystem, strObjectName, lstUpsertResults.size()) == true) {
                Boolean bErrors = false;
                String strExceptionCode = '';
                String strExceptionSummary = '';
                String strExceptionDetails = '';
                
                for(Integer i=0; i<lstUpsertResults.size(); i++) {
                    Database.UpsertResult ur = lstUpsertResults[i];
                    if(!ur.isSuccess()) {
                        strExceptionDetails = strExceptionDetails + lstSObjects[i].Id + ' => ';
                        for(Database.Error errorRec : ur.getErrors()) {
                            if(!bErrors) {
                                strExceptionCode = String.valueOf(errorRec.getStatusCode());
                                strExceptionSummary = errorRec.getMessage();
                                bErrors = true;
                            }
                            strExceptionDetails = strExceptionDetails + errorRec.getMessage() + '; ';
                        }
                        strExceptionDetails = strExceptionDetails + '\n\n';
                    }
                }
                if(bErrors) {
                    Batch_Error_Logger__c batchError = ErrorLogger.getGlobalErrorLogger(strSourceSystem, strObjectName, strMethodName, strExceptionCode, strExceptionSummary, strExceptionDetails);
                    return insertGlobalErrorLogger(batchError);
                }
            }
        }
        return false;
    }
    
    /* 
* Purpose: Write error messages to the Global Error logger Object.
* Params,
*   strSourceSystem: Source system name where error occured. E.g. SFDC 
*   strObjectName: Name of the object as applicable.
*   strMethodName: Name of the method where exception is thrown.
*   lstDeleteResults: List of Database.DeleteResult.
*/  
    public static Boolean writeErrors(String strSourceSystem, String strObjectName, String strMethodName, list<Database.DeleteResult> lstDeleteResults, list<sObject> lstSObjects) {
        if(lstDeleteResults != null) {
            // Write exception if this is not error storm.
            if(ErrorStormHandler.isErrorStorm(strSourceSystem, strObjectName, lstDeleteResults.size()) == true) {
                Boolean bErrors = false;
                String strExceptionCode = '';
                String strExceptionSummary = '';
                String strExceptionDetails = '';
                
                for(Integer i=0; i<lstDeleteResults.size(); i++) {
                    Database.DeleteResult dr = lstDeleteResults[i];
                    if(!dr.isSuccess()) {
                        strExceptionDetails = strExceptionDetails + lstSObjects[i].Id + ' => ';
                        for(Database.Error errorRec : dr.getErrors()) {
                            if(!bErrors) {
                                strExceptionCode = String.valueOf(errorRec.getStatusCode());
                                strExceptionSummary = errorRec.getMessage();
                                bErrors = true;
                            }
                            strExceptionDetails = strExceptionDetails + errorRec.getMessage() + '; ';
                        }
                        strExceptionDetails = strExceptionDetails + '\n\n';
                    }
                }
                if(bErrors) {
                    Batch_Error_Logger__c batchError = ErrorLogger.getGlobalErrorLogger(strSourceSystem, strObjectName, strMethodName, strExceptionCode, strExceptionSummary, strExceptionDetails);
                    return insertGlobalErrorLogger(batchError);
                }
            }
        }
        return false;
    }
    
}