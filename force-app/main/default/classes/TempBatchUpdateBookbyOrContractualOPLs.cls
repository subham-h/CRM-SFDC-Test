/* 
* Purpose  : Purpose of this class is to update Bookedby and contractual SCV details on OPLs
* 
* Revision     Ref Number      Date         Owner                Description
* --------     ----------      -----------  -------------------  -----------
* 1.0          SC-9662         12/02/2024   Nayana@Maersk        Batch class to update Bookedby and contractual SCV details on OPLs
*/

global class TempBatchUpdateBookbyOrContractualOPLs implements Database.Batchable<sObject>  {
    public String status; 
    public Date startDate;
    public Date endDate;
    public Integer batchSize;    
    
    public TempBatchUpdateBookbyOrContractualOPLs(String status,Date startDate,Date endDate,Integer batchSize) { 
        this.status = status;
      	this.startDate = startDate;
        this.endDate = endDate;
        this.batchSize = batchSize;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {   
         System.debug('start batch');      
        //String query = 'Select Id,Direction__c,Brand__c,Booked_By_SCV_Code__c, Contractual_SCV_Code__c,Service_Relationship_BookedBy__c,Service_Relationship_Contractual__c,BookedBy_Country__c,BookedBy_City__c,Contractual_Country__c,Contractual_City__c from Ocean_Plus_Lead__c where ((Booked_By_SCV_Code__c!= null AND Service_Relationship_BookedBy__c=null) OR (Contractual_SCV_Code__c  != null AND Service_Relationship_Contractual__c=null)) AND ((Days_To_Arrival__c >=-11 AND Days_To_Arrival__c <=28) OR (Days_To_Departure__c >=0 AND Days_To_Departure__c <=28))'; 
        String query = 'Select Id,Direction__c,Brand__c,Booked_By_SCV_Code__c, Contractual_SCV_Code__c,Service_Relationship_BookedBy__c,Service_Relationship_Contractual__c,BookedBy_Country__c,BookedBy_City__c,Contractual_Country__c,Contractual_City__c,Shipper_SCV_Code__c,Consignee_SCV_Code__c,Status__c,Shipper_MSL_Account_Owner__c,Consignee_MSL_Account_Owner__c,Contract_MSL_Account_Owner__c,Booked_By_MSL_Account_Owner__c,Shipper_Contact_Email__c,Consignee_Contact_Email__c,Contractual_Contact_Email__c,Booked_By_Account_Id__c, Consignee_Account_Id__c, Contractual_Account_Id__c,Booked_By_Contact_Email__c, Shipper_Account_Id__c,Contractual_Contact__c,Shipper_Contact__c,Consignee_Contact__c,Price_Owner_Account_Id__c,Price_Owner_SCV_Code__c,Booked_By_Contact__c from Ocean_Plus_Lead__c where  Status__c =:status';        
        if(startDate != null){
            query += ' AND CreatedDate  >= :startDate ';
        } 
        if(endDate != null){
            query += ' AND CreatedDate  <= :endDate';
        }       
        query += ' ORDER BY Booking_Number__c, CreatedDate DESC';
        if(batchSize != null){
           query += ' LIMIT ' + batchSize;
        }
        System.debug('%%%query***'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Ocean_Plus_Lead__c> scope) {
        System.debug('batch update');
        Set<String> setAccountSCVCodes = new Set<String>();
        Set<String> setEmails = new Set<String>();
        Map<String,Account> mapSCVAccount = new Map<String,Account>();
        Map<String,Contact> mapEmailContact = new Map<String,Contact>();

        Set<Ocean_Plus_Lead__c> setOceanPlusLeads = new Set<Ocean_Plus_Lead__c>();
        
        //List<Ocean_Plus_Lead__c> setOceanPlusToUpdate = new List<Ocean_Plus_Lead__c>();
        List<Ocean_Plus_Lead__c> lstUpdate = new List<Ocean_Plus_Lead__c>();
        try{
            for (Ocean_Plus_Lead__c newOPL:scope){
                
                if(newOPL.Booked_By_SCV_Code__c != null) {
                    setAccountSCVCodes.add(newOPL.Booked_By_SCV_Code__c);
                    setOceanPlusLeads.add(newOPL);
                    System.debug('setOceanPlusLeads'+setOceanPlusLeads);
                    System.debug('setAccountSCVCodes'+setAccountSCVCodes);
                }
                if(newOPL.Price_Owner_SCV_Code__c != null) {
                    setAccountSCVCodes.add(newOPL.Price_Owner_SCV_Code__c);
                    setOceanPlusLeads.add(newOPL);
                }
                if(newOPL.Booked_By_Contact_Email__c != null){
                    setEmails.add(newOPL.Booked_By_Contact_Email__c);
                }
                
            }
            System.debug('***setOceanPlusLeadssize'+setOceanPlusLeads.size());
            if(!setAccountSCVCodes.isEmpty()){
                for(Account acc : [Select Id,Name,Attractiveness__c,SCV_Code__c,Value_Proposition__c,Vertical__c,Country__c,Customer_Size__c,Customer_Role__c,BillingStreet,BillingCity,BillingCountry,Sales_Channel__c,MSL_Account_Owner__c,MSL_Account_Owner__r.Name from Account where SCV_Code__c != null and SCV_Code__c IN: setAccountSCVCodes]) {
                    mapSCVAccount.put(acc.SCV_Code__c,acc);  
                    System.debug(' mapSCVAccount'+ mapSCVAccount);
                }
            } 
            if(!setEmails.isEmpty()){
                for(Contact con : [Select Id,Name,Email,Phone,Account.SCV_Code__c from Contact where Email != null and Email IN: setEmails AND Contact_Status__c = 'Active']) {
                    mapEmailContact.put(con.Email,con);              
                }
            } 
            //Setting Country and City which is required for next step
            if(!setAccountSCVCodes.isEmpty() && !mapSCVAccount.isEmpty() && !setOceanPlusLeads.isEmpty()){
                for(Ocean_Plus_Lead__c newOPL : setOceanPlusLeads) {
                    if(!mapSCVAccount.isEmpty() && mapSCVAccount.containsKey(newOPL.Price_Owner_SCV_Code__c)) {      
                        newOPL.Price_Owner_Account_Id__c = mapSCVAccount.get(newOPL.Price_Owner_SCV_Code__c).Id;
                    }
                     if (!mapEmailContact.isEmpty() && mapEmailContact.containsKey(newOPL.Booked_By_Contact_Email__c) && mapEmailContact.get(newOPL.Booked_By_Contact_Email__c).Account.SCV_Code__c == newOPL.Booked_By_SCV_Code__c) {
                        newOPL.Booked_By_Contact__c = mapEmailContact.get(newOPL.Booked_By_Contact_Email__c).Id;
                        }
					lstUpdate.add(newopl);
                    System.debug('newopl'+newopl);
                }
            }
            
            if(!lstUpdate.isEmpty()){
                List<Database.SaveResult> lstOPLupdateResult = Database.update(lstUpdate, false ); 
                  
                ErrorLogger.writeErrors('SFDC', 'TempBatchUpdateBookbyOrContractualOPLs', 'TempBatchUpdateBookbyOrContractualOPLs.execute()', lstOPLupdateResult  , lstUpdate);            

            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OceanPlusLead', 'TempBatchUpdateBookbyOrContractualOPLs', new list<Exception>{ex});
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }  
    
    
}