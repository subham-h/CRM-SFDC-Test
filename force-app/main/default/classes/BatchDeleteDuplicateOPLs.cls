/* 
* Purpose  : Purpose of this class is to delete duplicate and untouched OPLs with unknown container/commodity
* 
* Revision     Ref Number      Date         Owner                                  Description
* --------     ----------      -----------  -------------------                    -----------
* 1.0          SC-9220         10/10/2023   Richa@Maersk              Batch class to delete duplicate OPLs with unknown container/commodity
* 2.0          SC-9584         26/01/2024   Richa@Maersk              Batch class to delete all duplicate OPLs untouched by agent
*/

global class BatchDeleteDuplicateOPLs implements Database.Batchable<sObject>  {
    public Date startDate;
    public Date endDate;
    public Integer batchSize;
    public String owner1;
    public String owner2;
    
    public BatchDeleteDuplicateOPLs(Date startDate,Date endDate,Integer batchSize,String owner1, String owner2) { 
      	this.startDate = startDate;
        this.endDate = endDate;
        this.batchSize = batchSize;
        this.owner1 = owner1;
        this.owner2 = owner2;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {   
               
        String query = 'Select id,Booking_Number__c, Container_Type__c, Commodity__c,createddate,lastmodifieddate,Status__c,OwnerId from Ocean_Plus_Lead__c where ';        
        if(startDate != null){
            query += ' CreatedDate  >= :startDate ';
        } 
        if(endDate != null){
            query += ' AND CreatedDate  <= :endDate';
        }       
        query += ' ORDER BY Booking_Number__c, CreatedDate DESC';
        if(batchSize != null){
           query += ' LIMIT ' + batchSize;
        }
        System.debug('%%%query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Ocean_Plus_Lead__c> scope) {
        Map<String, Ocean_Plus_Lead__c> bookNumberToMostRecentRecordMap = new Map<String, Ocean_Plus_Lead__c>();
        Set<String> setBookingNumbers = new Set<String>();  
        Set<String> setCurrentIds= new Set<String>(); 
        String oplDeletionFailedReason= ''; 
        List<Ocean_Plus_Lead__c> lstDeleteOPLs = new List<Ocean_Plus_Lead__c>();
        Map<String,Ocean_Plus_Lead__c> mapOPLs = new Map<String,Ocean_Plus_Lead__c>();
        Set<Ocean_Plus_Lead__c> setDelete = new Set<Ocean_Plus_Lead__c>();
        try{
            // Find the most recent record for each booking number
            for (Ocean_Plus_Lead__c record : scope) {
                String bookNumber = record.Booking_Number__c;
                
                // Check if the record is more recent than the one currently stored
                if (!bookNumberToMostRecentRecordMap.containsKey(bookNumber) || record.CreatedDate > bookNumberToMostRecentRecordMap.get(bookNumber).CreatedDate) {
                        bookNumberToMostRecentRecordMap.put(bookNumber, record); 
                    }
            }
            
            // Delete older duplicates on same day
            
            for (Ocean_Plus_Lead__c mostRecentRecord : bookNumberToMostRecentRecordMap.values()) {                         
                setCurrentIds.add(mostRecentRecord.Id);
                setBookingNumbers.add(mostRecentRecord.Booking_Number__c);
                // Add all record Ids except the most recent one to the delete list
                for (Ocean_Plus_Lead__c record : scope) {
                    if (record.Booking_Number__c == mostRecentRecord.Booking_Number__c &&
                        record.Id != mostRecentRecord.Id && record.Status__c == 'New' && (record.OwnerId == owner1 || record.OwnerId == owner2 )) {
                            setDelete.add(record);
                        }
                }
            }
            // Delete older duplicates on another day
            if(!setBookingNumbers.isEmpty()){
                for(Ocean_Plus_Lead__c opl: [Select id,Booking_Number__c, Container_Type__c, Commodity__c,createddate,lastmodifieddate,Status__c, OwnerId from Ocean_Plus_Lead__c where Booking_Number__c IN: setBookingNumbers AND  Status__c = 'New' AND (OwnerId =:Label.CrossSellInterface OR OwnerId =: Label.CaseDataInterfaceUserId ) AND Createddate <: startDate]){
                    if(setBookingNumbers.contains(opl.Booking_Number__c) ){
                        setDelete.add(opl);
                    }
                }
            }
            
            
            if(!setDelete.isEmpty()){
                lstDeleteOPLs.addAll(setDelete);
            }
            
            if(!lstDeleteOPLs.isEmpty()){
                List<Database.DeleteResult> lstOPLDeleteResult = Database.delete(lstDeleteOPLs, false );  
                for(Database.DeleteResult dr : lstOPLDeleteResult){
                    if(!dr.isSuccess()){
                        Database.Error err = dr.getErrors()[0]; 
                        oplDeletionFailedReason=oplDeletionFailedReason+'Id: '+dr.getId()+'Reason: '+dr.getErrors()+';';                       
                    }                   
                } 
                if(!oplDeletionFailedReason.equalsIgnoreCase('')){
                    ErrorLogger.writeError('SFDC', 'OceanPlusLead', 'BatchDeleteDuplicateOPLs.Execute', 'Warning', 'Deletion Failure', oplDeletionFailedReason);
                } 
                
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'BatchDeleteDuplicateOPLs', new list<Exception>{ex});
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }  
    
    
}