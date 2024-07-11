/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          01/04/2020       Abhinav.Ankit@maersk.com                  #RQ-013222 -Code Created
*/

global class InActiveContact_Deletion_Batch implements Database.Batchable<SObject> {    
    
    global Database.queryLocator start( Database.BatchableContext ctx ) {
        
         String strQuery = 'SELECT Id FROM Contact where Contact_Status__c=\'Inactive\' AND LastModifiedDate < '+ Label.BatchInActiveConDeletion ; 
        system.debug('$$$ strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);            
    }
    
    global void execute( Database.BatchableContext BC, List<sObject> scope ) {        
        List<Contact> lstContact = ( List<Contact> )scope;
        List<Database.deleteResult> lstDeleteResult;   
        List<Id> finalContactlisttoDelete; 
        try{
            Set<Id> ContactIds = new Set<Id>();     
            for(Contact acc : lstContact){
                ContactIds.add(acc.Id);
            }
            Set<Id> ContactIdSetToRemove = new Set<Id>(); // this will hold the set of accounts id which have the related accounts, which should not be deleted
            // Query the metadata to check to iterate over objects for which related records needs to be checked
            List<Check_Object_for_Contact_Deletion__mdt> excludeConRecord =[Select DeveloperName,Object_name__c,Field_Name__c,Object_To_Skip__c from Check_Object_for_Contact_Deletion__mdt]; 
            for(Check_Object_for_Contact_Deletion__mdt associatedObject :excludeConRecord){
                if(associatedObject.Object_To_Skip__c==false){
                    if(associatedObject.Object_name__c=='ContentDocumentLink'){
						String soqlquery = 'select Id,'+associatedObject.Field_Name__c+' from '+associatedObject.Object_name__c+' where LinkedEntityId in :ContactIds AND ContentDocument.LastModifiedDate >= '+ Label.BatchInActiveConDeletionrelated;            
						system.debug('$$$ soqlquery: ' + soqlquery);						
                        list<sobject> sobjectQueryResult = Database.query(soqlquery);
						if(sobjectQueryResult != null){
							for(sObject sobj : sobjectQueryResult){                   
								Id ContactidFromChildObject = (Id)sobj.get(ContentDocumentLink.LinkedEntityId); // get the ids to remove from scope which are not to be deleted.
								ContactIdSetToRemove.add(ContactidFromChildObject);
							}
						}
                    }else if(associatedObject.Object_name__c=='CampaignMember'){
						String soqlquery = 'select Id,'+associatedObject.Field_Name__c+' from '+associatedObject.Object_name__c+' where ContactId in :ContactIds AND campaign.LastModifiedDate >= '+ Label.BatchInActiveConDeletionrelated;            
						system.debug('$$$ soqlquery: ' + soqlquery);						
                        list<sobject> sobjectQueryResult = Database.query(soqlquery);
						if(sobjectQueryResult != null){
							for(sObject sobj : sobjectQueryResult){                   
								Id ContactidFromChildObject = (Id)sobj.get(CampaignMember.ContactId); // get the ids to remove from scope which are not to be deleted.
								ContactIdSetToRemove.add(ContactidFromChildObject);
							}
						}
                    }
                    else{
                        	String soqlquery = 'select Id,'+associatedObject.Field_Name__c+' from '+associatedObject.Object_name__c+' where '+associatedObject.Field_Name__c+' in :ContactIds AND LastModifiedDate >= '+ Label.BatchInActiveConDeletionrelated;            
							system.debug('$$$ soqlquery: ' + soqlquery);							
                        	list<sobject> sobjectQueryResult = Database.query(soqlquery);
							if(sobjectQueryResult != null){
								for(sObject sobj : sobjectQueryResult){                   
									Id ContactidFromChildObject = (Id)sobj.get(associatedObject.Field_Name__c); // get the ids to remove from scope which are not to be deleted.
									ContactIdSetToRemove.add(ContactidFromChildObject);
								}
							}
                    }
                }else {
					String soqlquery = 'select Id,'+associatedObject.Field_Name__c+' from '+associatedObject.Object_name__c+' where '+associatedObject.Field_Name__c+' in :ContactIds' ;          
					system.debug('$$$ soqlquery: ' + soqlquery);							
                    list<sobject> sobjectQueryResult = Database.query(soqlquery);
						if(sobjectQueryResult != null){
							for(sObject sobj : sobjectQueryResult){                   
								Id ContactidFromChildObject = (Id)sobj.get(associatedObject.Field_Name__c); // get the ids to remove from scope which are not to be deleted.
								ContactIdSetToRemove.add(ContactidFromChildObject);
						}
					}		
				}
            }
            system.debug('$$$ ContactIdSetToRemove: ' + ContactIdSetToRemove);
            ContactIds.removeAll(ContactIdSetToRemove); // remove the ids which have related objects
            finalContactlisttoDelete = new List<Id>(ContactIds); // convert the set to list to pass for deletion
            system.debug('$$$ finalContactlisttoDelete: ' + finalContactlisttoDelete);
            if(!finalContactlisttoDelete.isEmpty()){  
                TriggerExecutionController.skipContactTrigger(true);
                lstDeleteResult = Database.Delete(finalContactlisttoDelete ,false);
                TriggerExecutionController.skipContactTrigger(false);               
                database.emptyRecycleBin(finalContactlisttoDelete);  //Remove the deleted items from Recycle bin as well.    
                
            }else{
                System.debug('$$$Batch_InactiveContact_Deletion : No Records available for Deletion');   
            }
        }
        catch(Exception e){
            System.debug(Logginglevel.ERROR, 'Exception! ' + e.getMessage());
            ErrorLogger.writeErrors('SFDC', 'Contact', 'Batch_InactiveContact_Deletion', lstDeleteResult, lstContact);
        }
        
    }         
        
    global void finish(Database.BatchableContext BC){
        
    }
    
}