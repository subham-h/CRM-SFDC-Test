/** Author   : Sandeep
* Purpose  : Batch class for Updating Agent's first response time.
* 
* -------- ----------  ----------- -------------------     -----------
*                 Created.
SC-4507    Sandeep@ust             
* 
*/
global class Batch_CalculateFirstResponseTime4PL implements Database.Batchable<SObject>,Schedulable{
    
    global Date startDate;
    global Integer batchSize;
    global Integer numberofDays;
    global Batch_CalculateFirstResponseTime4PL(Date startDate, Integer Size) {
        if(startDate != null){
            this.startDate = startDate;
        }
        if(Size != null){
            this.batchSize = size;
        }
        else if(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size') != null && !String.isEmpty(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size').First_Field_Value__c)){
            this.batchSize = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size').First_Field_Value__c);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        if(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size') != null && !String.isEmpty(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size').Second_Field_Value__c)){
            this.numberofDays = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('CalculateFirstResponseTime4PL_Batch_Size').Second_Field_Value__c);
        }     
        String query;
        Date dt = System.Today().addDays(-this.numberofDays);
        String externalCaseRTId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('External Case').getRecordTypeId();
        if(startDate != null){
            Date endDate = startDate.addDays(this.numberofDays);
            query = 'select Id from Case where RecordTypeId=: externalCaseRTId AND Case_Channel__c IN (\'E-mail\', \'Portal\') and Agent_First_Response_Time__c = null and CreatedDate >=: startDate and CreatedDate <: endDate';
        }
        else {
            query = 'select Id from Case where RecordTypeId= :externalCaseRTId AND Case_Channel__c IN (\'E-mail\', \'Portal\') and createdDate>= :dt and Agent_First_Response_Time__c = null';        
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Case> lstCases) {
        
        List<String> lstAutoReplyFromAddresses = new List<String>();
        Map<string, Org_Wide_Email_Address__mdt> orgwideaddressMap = Org_Wide_Email_Address__mdt.getAll();
        for(String brand : orgwideaddressMap.keyset()){
          lstAutoReplyFromAddresses.add(orgwideaddressMap.get(brand).Email_Address__c);
        }
        list<case> lstCasesToBeUpdated = new list<case>();
        for(case objCase: [select Id,Createddate,BusinessHoursId,(Select Id,ParentId,FromName, CreatedDate from EmailMessages where FromAddress !=: lstAutoReplyFromAddresses and Incoming = false order by createddate asc limit 1) from case where Id IN:lstCases]){
            
            if(objCase.EmailMessages.size() > 0){
                DateTime dt1 = objCase.EmailMessages[0].CreatedDate;
                DateTime dt2 = objCase.CreatedDate;
                
             /*   Long difference = BusinessHours.diff(objCase.BusinessHoursId, dt2, dt1);
                Long minutes = difference/60000;
                if(minutes == 0){
                 objCase.Agent_First_Response_Time__c = 1;
                }else{  
                 objCase.Agent_First_Response_Time__c = minutes;
                }*/
                
                Decimal difference = BusinessHours.diff(objCase.BusinessHoursId, dt2, dt1);
                Decimal hours = difference/(3600000);
                if(hours == 0){
                 objCase.Agent_First_Response_Time__c = 0.01;
                }else{  
                 objCase.Agent_First_Response_Time__c = hours.setscale(2);
                }
                lstCasesToBeUpdated.add(objCase);               
            }  
            
        }
        
        if(!lstCasesToBeUpdated.IsEmpty()){
            database.update(lstCasesToBeUpdated, false);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext SC) {
        Batch_CalculateFirstResponseTime4PL batch = new Batch_CalculateFirstResponseTime4PL(startDate, batchSize);
        Database.executeBatch(batch, batchSize);
    }
}