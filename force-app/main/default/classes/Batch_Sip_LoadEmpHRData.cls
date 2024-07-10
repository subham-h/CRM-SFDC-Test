/****
 * Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-8141        22/08/2022     Meghana Gupta            Code Created
*  SFSE-9542 		12/10/2022     Vazid 					Removed Months_for_annualization__c field reference from 'serializeRecord' method.
*  SFSE-10436       02/03/2023     Bharti                   Code added for blank update on SIP Ineligible field when user become eligible again.
* ***/
// batch that will iterate through records fetched from Workday and Upsert them in sfdc object
// 
global class Batch_Sip_LoadEmpHRData implements Database.Batchable<Employee_HR_Data__c>,Database.AllowsCallouts{
   
    Schema.SObjectField externalField_EmpId = Employee_HR_Data__c.Fields.Employee_ID__c; // external field used for Upsert

   global Iterable<Employee_HR_Data__c> start(Database.BatchableContext info){
       return new sipEmpHrDataIterable();
   }
   
   global void execute(Database.BatchableContext info, List<Employee_HR_Data__c> scope){
       
       List<Database.upsertResult> lstUpsertResults = database.upsert(scope, externalField_EmpId, false);
       //ErrorLogger.writeErrors('SFDC', 'SIP-Employee HR Data', 'Batch_SIP_LoadEmpHRData', lstUpsertResults, scope);
       
      // logic for blank update on sip ineligible field after  becoming that record eligible again 
       List<Employee_HR_Data__c> lstemp = new List<Employee_HR_Data__c>();
       List<Employee_HR_Data__c> empRec = new List<Employee_HR_Data__c>([SELECT Id, From_Date__c, SIP_Ineligible_Date__c FROM Employee_HR_Data__c where SIP_Ineligible_Date__c != null and SIP_Status__c ='Update Received']);
       for(Employee_HR_Data__c emp : empRec ){
       Integer numberDaysDue = emp.SIP_Ineligible_Date__c.daysBetween(emp.From_Date__c);
       system.debug('numberDaysDue'+numberDaysDue);
       if(numberDaysDue>=0){
        emp.SIP_Ineligible_Date__c =null;
            lstemp.add(emp);
           
       }
        
       }
       update lstemp;
      
       List<Batch_Error_Logger__c> lstErrorLog = new List<Batch_Error_Logger__c>();
       List<String> lstFailedExternalIds = new List<String>();
       
       for(Integer i=0; i<lstUpsertResults.size(); i++) {
           
           String strExceptionCode ='';
           String strExceptionSummary = '';
           
           Database.UpsertResult ur = lstUpsertResults[i];
           if(!ur.isSuccess()) {
               for(Database.Error errorRec : ur.getErrors()) {
                   
                   strExceptionCode = String.valueOf(errorRec.getStatusCode());
                   strExceptionSummary = errorRec.getMessage();
                   
               }
               lstFailedExternalIds.add(scope[i].Employee_ID__c);
               lstErrorLog.add(getGlobalErrorLogger( strExceptionCode, strExceptionSummary, serializeRecord(scope[i])));
           }
       }
       if(!lstErrorLog.isEmpty() && ErrorStormHandler.isErrorStorm('SFDC', 'SIP-Employee HR Data', lstErrorLog.size()) == true  ) {
           database.insert(lstErrorLog,false);
       }
       
       if(!lstFailedExternalIds.isEmpty()){
       		List<Employee_HR_Data__c> lstfailedRecords = [SELECT Id,SIP_Status__c FROM Employee_HR_Data__c WHERE Employee_ID__c in :lstFailedExternalIds ]; 
          for(Employee_HR_Data__c rec : lstfailedRecords){
               rec.SIP_Status__c='Exception';
           }
           database.update(lstfailedRecords, false);
       }

   }
    
   global void finish(Database.BatchableContext info){
   }
    
     private static Batch_Error_Logger__c getGlobalErrorLogger(  String strExceptionCode, String strExceptionSummary, String strExceptionDetails) {
         
        Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
        globalErrorLogger.Name = 'SFDC:SIP-Employee HR Data - ' + System.now().format();
        globalErrorLogger.Source_System__c = 'SFDC';
        globalErrorLogger.Object__c = 'SIP-Employee HR Data';
        globalErrorLogger.Batch_Name__c = 'Batch_SIP_LoadEmpHRData' ;
        globalErrorLogger.Operation_Type__c = 'Upsert';
        globalErrorLogger.Exception_Code__c = strExceptionCode;
        if(!String.isBlank(strExceptionSummary)) {
            globalErrorLogger.Exception_Summary__c = strExceptionSummary.left(254);
        }
        globalErrorLogger.Exception_Detail__c = strExceptionDetails;
        return globalErrorLogger;
    }
    
    private String serializeRecord(Employee_HR_Data__c rec){
        String fromDate = (rec.From_Date__c == null)? null : String.valueOf(rec.From_Date__c);
        String strRecord = 'Employee ID: ' + rec.Employee_ID__c + ', Manager: ' + rec.Manager__r.Maersk_User_Id__c + ', Sales Role: ' + rec.Sales_Role__c + ', Area: ' + rec.Area__c + ', Region: ' + rec.Region__c 
            	+ ', Brand: ' + rec.Brand__c + ', From Date: ' +  fromDate + 
           		 ', Paymix: ' + rec.Paymix__c ;
        
        return strRecord;
    }

}