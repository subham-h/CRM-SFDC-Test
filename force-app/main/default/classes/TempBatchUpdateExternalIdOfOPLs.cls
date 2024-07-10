/* 
* Purpose  : Purpose of this class is to update opl externalid
* 
* Revision     Ref Number      Date         Owner                                  Description
* --------     ----------      -----------  -------------------                    -----------
* 1.0          SC-9584       26/01/2024   Richa@Maersk              Temporary batch class for opl externalid update

*/

global class TempBatchUpdateExternalIdOfOPLs implements Database.Batchable<sObject>  {
    
    public String status;    
    public Date startDate;
    public Date endDate;
 	public Integer batchSize;    
    public TempBatchUpdateExternalIdOfOPLs(String status,Date startDate,Date endDate,Integer batchSize) { 
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
        this.batchSize = batchSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        String query = 'Select Id,CXLeadExternalId__c,Booking_Number__c,CreatedDate,Status__c,OwnerId from Ocean_Plus_Lead__c where Status__c =:status';        
        if(startDate != null){
            query += ' AND CreatedDate  >= :startDate ';
        } 
        if(endDate != null){
            query += ' AND CreatedDate  <= :endDate';
        } 
        query += ' ORDER BY CreatedDate DESC';
        if(batchSize != null){
           query += ' LIMIT ' + batchSize;
        }
        System.debug('%%%query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Ocean_Plus_Lead__c> scope) {
        List<Ocean_Plus_Lead__c> lstUpdate = new List<Ocean_Plus_Lead__c>();
        try{
            for(Ocean_Plus_Lead__c opl: scope){
                if(opl.CXLeadExternalId__c != opl.Booking_Number__c){
                    opl.CXLeadExternalId__c = opl.Booking_Number__c;
                    lstUpdate.add(opl);		
                }	
            }
            
            if(!lstUpdate.isEmpty() && lstUpdate != null){
                List<Database.SaveResult> lstOPLupdateResult = Database.update(lstUpdate, false );  
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'TempBatchUpdateExternalIdOfOPLs', new list<Exception>{ex});
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    } 
    
}