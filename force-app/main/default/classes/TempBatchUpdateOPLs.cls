/* 
* Purpose  : Purpose of this class is to update opl booked by customer and contact info of historical records
* 
* Revision     Ref Number      Date         Owner                                  Description
* --------     ----------      -----------  -------------------                    -----------
* 1.0          SC-9582       15/01/2024   Richa@Maersk              Temporary batch class for opl update
* 2.0          SFMC-7564     02/02/2024   Amrutha@maersk            Replaced Booked_By_Contact_Id__c with Booked_By_Contac__c

*/

global class TempBatchUpdateOPLs implements Database.Batchable<sObject> {
    public String status;    
    public Date startDate;
    public Date endDate;
    
    public TempBatchUpdateOPLs(String status,Date startDate,Date endDate) { 
        this.status = status;
        this.startDate = startDate;
        this.endDate = endDate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        String query = 'Select Id,Booking_Number__c,Shipment__c,Booked_By_SCV_Code__c,Booked_By_Customer_Name__c,Booked_By_Address__c, Booked_By_Contact_Name__c, Booked_By_Contact_Email__c,Booked_By_Contact__c,Booked_By_Contact_Phone_Number__c from Ocean_Plus_Lead__c where Booked_By_SCV_Code__c = null AND Status__c =:status';        
        if(startDate != null){
            query += ' AND LastModifiedDate  >= :startDate ';
        } 
        if(endDate != null){
            query += ' AND LastModifiedDate  <= :endDate';
        } 
         System.debug('%%%query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Ocean_Plus_Lead__c> scope) {
        List<Ocean_Plus_Lead__c> lstUpdate = new List<Ocean_Plus_Lead__c>();
        Set<String> setBookingNumbers = new Set<String>(); 
        Set<String> setContactExId = new Set<String>();  
        Map<String,Contact > mapBookedByContact = new Map<String,Contact>();
        Map<String,Party__c> mapBookedByParty = new Map<String,Party__c>();
        try{
            System.debug('%%%scope'+scope);
            for(Ocean_Plus_Lead__c obj: scope){            
                setBookingNumbers.add(obj.Booking_Number__c);  
            }            
            
            if(!setBookingNumbers.isEmpty()){
                for(Party__c prty: [Select Id,Contact_Person__c,Shipment__c,Shipment_Number__c,Scv_Customer_Code__c,Customer_Name__c from Party__c where Shipment_Number__c IN :setBookingNumbers AND Party_Number__c = '1' AND Contact_Person__c != null]){
                    mapBookedByParty.put(prty.Shipment_Number__c,prty); 
                    setContactExId.add(prty.Contact_Person__c);
                }
            }
            
            if(!setContactExId.isEmpty()) {
                for(Contact con: [Select Id,Name,External_ID__c,Email, Phone,MobilePhone from Contact where External_ID__c != null and External_ID__c IN :setContactExId]){
                    mapBookedByContact.put(con.External_ID__c,con);                
                }
            } 
            
            if(!setBookingNumbers.isEmpty() && !mapBookedByContact.isEmpty() && !mapBookedByParty.isEmpty()){
                for(Ocean_Plus_Lead__c newopl: scope){
                    if(mapBookedByParty.containsKey(newopl.Booking_Number__c)){
                         if(mapBookedByParty.get(newopl.Booking_Number__c).Contact_Person__c != Null && mapBookedByContact.get(mapBookedByParty.get(newopl.Booking_Number__c).Contact_Person__c) != Null){
                            newopl.Booked_By_Contact__c = mapBookedByContact.get(mapBookedByParty.get(newopl.Booking_Number__c).Contact_Person__c).Id;
                        }
                        lstUpdate.add(newopl);
                    }
                }
            }		
            
            if(!lstUpdate.isEmpty()){
                List<Database.SaveResult> lstOPLupdateResult = Database.update(lstUpdate, false );  
                ErrorLogger.writeErrors('SFDC', 'TempBatchUpdateOPLs', 'TempBatchUpdateOPLs.execute()', lstOPLupdateResult  , lstUpdate);            
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'TempBatchUpdateOPLs', 'TempBatchUpdateOPLs', new list<Exception>{ex});
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    } 
    
}