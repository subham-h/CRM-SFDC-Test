/**
* Date         Owner                                                    Description
**************************************************************************************************************************************
* 11/03/2016   ramadevi.palaniswamy@ust-global.com               RQ-005348: Batch apex job to update contact and user email address on Request object when there is a change
                                                                 in User/Contact in RequestContact or Email field is changed for Contact.
* 25/09/2017   Nisha.Arjunan@ust-global.com                      RQ-005636 : Update the referenced of Global Error Logger
* 28/11/2017   Meenakshi.Rajasekaran@ust-global.com              RQ-007404 : Account Owner to become a Request Contact
* 10/03/2018   Nitin More                                        #RQ-008055 : Amended to work with new data model of RS3 project
*/

global class BatchUpdateEmailAddressOnRequest implements Database.Batchable<SObject> {
  
    global Database.queryLocator start( Database.BatchableContext ctx ) {
         
        String query;
        Date dtStartDate = System.Today() - 1;
        Id strReqContactRecordId = (Id) Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        
        // Query to get the list of Request Contacts if 
        //      requestContact has been modified in last 2 days OR 
        //      corresponding contacts modified in last 2 days 
        query ='SELECT id, email__c, user__c, contact__r.LastModifiedDate, Request__c, Request__r.LastModifiedDate, Request__r.Name, Request__r.Mail_Send_To__c,Request__r.Additional_Group_Internal_Email__c, Request__r.Migrated_Emails__c';
            query += ' FROM Request_Information__c ';
            query += ' WHERE RecordTypeID = :strReqContactRecordId '; 
            query += ' AND (lastModifiedDate >= :dtStartDate OR contact__r.lastModifiedDate >= :dtStartDate )'; 
            query += ' ORDER BY Request__c';        
       
        return Database.getQueryLocator(query);
    }
    
    global void execute( Database.BatchableContext BC, List<Request_Information__c> scope ) {        

        Map<Id,String> mapRequestIDEmailToUpdate = new Map<Id,String>();
        List<Request__c> lstRequest = new List<Request__c> ();
        List<Request__c> lstRequestToUpdate = new List<Request__c> ();

        for (Request_Information__c rqCon : scope ) {
            
            String email='';
            
            if( !mapRequestIDEmailToUpdate.containsKey(rqCon.Request__c) ){   
                
                if( rqCon.Request__r.Mail_Send_To__c == 'Sales' || rqCon.Request__r.Mail_Send_To__c == 'Both' ){
                    
                    if (rqCon.User__c != NULL) { 
                        email = rqCon.email__c+';'; 
                    }
                    
                    if( rqCon.Request__r.Additional_Group_Internal_Email__c != NULL ){
                        email += rqCon.Request__r.Additional_Group_Internal_Email__c+';'; 
                    }             
                }
                
                if( rqCon.Request__r.Mail_Send_To__c == 'Customer' || rqCon.Request__r.Mail_Send_To__c == 'Both' ) {
                                        
                    if ( rqCon.contact__c != NULL) {
                        email += rqCon.email__c+';';
                    }
                    if ( rqCon.Request__r.Migrated_Emails__c!= NULL ){
                        email += rqCon.Request__r.Migrated_Emails__c+';';
                    }

                    System.debug('Customer'+email);
                }
                
                mapRequestIDEmailToUpdate.put( rqCon.Request__c, email ); 
                
            } else {

                // If the key found in map then just update the email address from Request contact   
                if(rqCon.Request__r.Mail_Send_To__c == 'Sales' && rqCon.user__c != NULL) {
                    mapRequestIDEmailToUpdate.put(rqCon.Request__c, mapRequestIDEmailToUpdate.get(rqCon.Request__c)+rqCon.email__c+';' );
                }                    
                else if(rqCon.Request__r.Mail_Send_To__c == 'Customer' && rqCon.contact__c != NULL) {
                    mapRequestIDEmailToUpdate.put(rqCon.Request__c,mapRequestIDEmailToUpdate.get(rqCon.Request__c)+rqCon.email__c+';' );
                }
                else if (rqCon.Request__r.Mail_Send_To__c == 'Both'){
                    mapRequestIDEmailToUpdate.put(rqCon.Request__c,mapRequestIDEmailToUpdate.get(rqCon.Request__c)+rqCon.email__c+';' );  
                }                     
            }
        }
        
        System.debug(mapRequestIDEmailToUpdate);
        
        if( mapRequestIDEmailToUpdate.Size() > 0){
            
            lstRequest = [SELECT Id, All_Customer_Email_Addresses__c, All_Internal_Email_Addresses__c, Mail_Send_To__c, All_Email_Updated_by_Batch_Date__c FROM Request__c WHERE Id = :mapRequestIDEmailToUpdate.Keyset()];
            
            for (Request__c req : lstRequest){
                System.debug(req.All_Email_Updated_by_Batch_Date__c);
                
                //Update the populated email value only if it is not updated by the batch today
                if( req.All_Email_Updated_by_Batch_Date__c != System.Today() ){
                    
                    req.All_Email_Updated_by_Batch_Date__c = System.Today();      
                    
                    System.debug('Not updated by Batch');
                    
                    if(req.Mail_Send_To__c == 'Sales') {
                        req.All_Internal_Email_Addresses__c= mapRequestIDEmailToUpdate.get(req.id);
                        req.All_Customer_Email_Addresses__c='';
                    
                    } else if (req.Mail_Send_To__c == 'Customer') {
                        req.All_Customer_Email_Addresses__c =mapRequestIDEmailToUpdate.get(req.id);
                        req.All_Internal_Email_Addresses__c = '';
                        
                    } else {
                        req.All_Internal_Email_Addresses__c= mapRequestIDEmailToUpdate.get(req.id);
                        req.All_Customer_Email_Addresses__c =mapRequestIDEmailToUpdate.get(req.id);
                        
                    }
                } else {
                    // If the batch has already updated the Request, just appending the email to the existing value
                    system.debug('Updated by Batch');
                    
                    req.All_Email_Updated_by_Batch_Date__c = System.Today();
                
                    if(req.All_Internal_Email_Addresses__c!= NULL || req.All_Customer_Email_Addresses__c != NULL) {
                        
                        if(req.Mail_Send_To__c == 'Sales') {
                            req.All_Internal_Email_Addresses__c= req.All_Internal_Email_Addresses__c + mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Customer_Email_Addresses__c='';
                            
                        } else if (req.Mail_Send_To__c == 'Customer') {
                            req.All_Customer_Email_Addresses__c =req.All_Customer_Email_Addresses__c + mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Internal_Email_Addresses__c = '';
                            
                        } else {
                            req.All_Internal_Email_Addresses__c = req.All_Internal_Email_Addresses__c + mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Customer_Email_Addresses__c = req.All_Customer_Email_Addresses__c + mapRequestIDEmailToUpdate.get(req.id);
                            
                        }
                    } else {
                        
                        if(req.Mail_Send_To__c == 'Sales') {
                            req.All_Internal_Email_Addresses__c= mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Customer_Email_Addresses__c = '';
                            
                        } else if (req.Mail_Send_To__c == 'Customer') {
                            req.All_Customer_Email_Addresses__c =mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Internal_Email_Addresses__c= '';
                                                            
                        } else {
                            req.All_Internal_Email_Addresses__c= mapRequestIDEmailToUpdate.get(req.id);
                            req.All_Customer_Email_Addresses__c =mapRequestIDEmailToUpdate.get(req.id);
                            
                        }                        
                    }
                }
                
                lstRequestToUpdate.add(req);
            }
            
            System.debug(lstRequestToUpdate);
            
            if( lstRequestToUpdate.size()>0 ) {
                List<Database.SaveResult> updateResultList = Database.update( lstRequestToUpdate, false );
                ErrorLogger.writeErrors('SFDC', 'Request__c', 'BatchUpdateEmailAddressOnRequest.execute()', updateResultList, lstRequestToUpdate );             
            }
        }
    }
 
    global void finish(Database.BatchableContext BC){
        
    }
}