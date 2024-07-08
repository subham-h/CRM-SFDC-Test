/*
* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          20/March/2020       Abhinav.Ankit@maersk.com       #RQ-008412 -Code Created
*/

global class Batch_InactiveContact_Deletion implements Database.Batchable<SObject>, Database.Stateful {    
    Global integer total =0;
    Global integer totalfailed =0;
    // start method of the batch to create records 
    global Database.queryLocator start( Database.BatchableContext ctx ) {
        
        // Using the same label BatchInActiveConDeletion which was created for this batch, however using it differently here
       /* String strQuery = 'SELECT Id FROM Contact where Contact_Status__c=\'Inactive\' AND LastModifiedDate <= '+ Label.BatchInActiveConDeletion +'AND Id NOT IN (SELECT ContactId FROM Case) AND Id NOT IN (SELECT ContactId FROM LiveChatTranscript)'; */
	   String strQuery = 'SELECT Id FROM Contact where Contact_Status__c=\'Inactive\' AND LastModifiedDate <= '+ Label.BatchInActiveConDeletion ;
        
        system.debug('$$$ strQuery: ' + strQuery);
        return Database.getQueryLocator(strQuery);            
    }
    
    // execute method to write business logic and refine the accouns here to determine which needs to be deleted
    global void execute( Database.BatchableContext BC, List<sObject> scope ) {        
        List<Contact> lstContact = ( List<Contact> )scope; // List Of Inactive Contact
        List<Database.deleteResult> lstDeleteResult;   
        List<Id> finalContactlisttoDelete; // this will hold the ids of Contact which are refined and needs to be deleted
       try{
            Set<Id> ContactIds = new Set<Id>(); //list to store the Contactid in scope for removing duplicates        
            for(Contact con : lstContact){
                ContactIds.add(con.Id);
            }
            system.debug('$$$ ContactIds *****: ' + ContactIds.size());
            Set<Id> ContactIdSetToRemove = new Set<Id>(); // this will hold the set of Contact id which have the related Contact, which should not be deleted
            // Query the metadata to check to iterate over objects for which related records needs to be checked
           /* List<Check_Object_for_Account_Deletion__mdt> excludeAccRecord =[Select DeveloperName,Object_name__c,Field_Name__c from Check_Object_for_Account_Deletion__mdt]; */
          //  for(Check_Object_for_Account_Deletion__mdt associatedObject :excludeAccRecord){
          //  
                String soqlquery = 'select Id,Primary_Contact__c from opportunity where Primary_Contact__c in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated;            
                 system.debug('$$$ soqlquery *****: ' + soqlquery);
            	list<sobject> sobjectQueryResult1 = Database.query(soqlquery);
                if(sobjectQueryResult1 != null){
                    for(sObject sobj : sobjectQueryResult1){  
                        system.debug('$$$ sobj *****: ' + sobj);
                        Id ContactidFromChildObject = (Id)sobj.get(opportunity.Primary_Contact__c); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery0 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				String soqlquery1 = 'select Id,ContactId from CampaignMember where ContactId in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated ;            
                system.debug('$$$ soqlquery1 *****: ' + soqlquery1);
            	list<sobject> sobjectQueryResult2 = Database.query(soqlquery1);
                if(sobjectQueryResult2 != null){
                    for(sObject sobj : sobjectQueryResult2){                   
                        Id ContactidFromChildObject = (Id)sobj.get(CampaignMember.ContactId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery1 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				
				
				String soqlquery2 = 'select Id,WhoId from Event where WhoId in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated ;            
                system.debug('$$$ soqlquery2 *****: ' + soqlquery2);
            	list<sobject> sobjectQueryResult3 = Database.query(soqlquery2);
                if(sobjectQueryResult3 != null){
                    for(sObject sobj : sobjectQueryResult3){                   
                        Id ContactidFromChildObject = (Id)sobj.get(Event.WhoId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery2 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				String soqlquery3 = 'select Id,WhoId from Task where WhoId in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated ;            
                 system.debug('$$$ soqlquery3 *****: ' + soqlquery3);
                list<sobject> sobjectQueryResult4 = Database.query(soqlquery3);
                if(sobjectQueryResult4 != null){
                    for(sObject sobj : sobjectQueryResult4){                   
                        Id ContactidFromChildObject = (Id)sobj.get(Task.WhoId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery3 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				
				String soqlquery4 = 'select Id,Contact__c from Request_Information__c where Contact__c in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated ;            
                system.debug('$$$ soqlquery4 *****: ' + soqlquery4);
            	list<sobject> sobjectQueryResult5 = Database.query(soqlquery4);
                if(sobjectQueryResult5 != null){
                    for(sObject sobj : sobjectQueryResult5){                   
                        Id ContactidFromChildObject = (Id)sobj.get(Request_Information__c.Contact__c); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery4 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				String soqlquery5 = 'select Id,ParentId from Note where ParentId in :ContactIds AND LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated;            
            	system.debug('$$$ soqlquery5 *****: ' + soqlquery5);    
           		list<sobject> sobjectQueryResult6 = Database.query(soqlquery5);
                if(sobjectQueryResult6 != null){
                    for(sObject sobj : sobjectQueryResult6){                   
                        Id ContactidFromChildObject = (Id)sobj.get(Note.ParentId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				 system.debug('$$$ soqlquery5 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
            
				String soqlquery6 = 'select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId in :ContactIds AND ContentDocument.LastModifiedDate <= '+ Label.BatchInActiveConDeletionrelated;            
                system.debug('$$$ soqlquery6 *****: ' + soqlquery6);
            	list<sobject> sobjectQueryResult7 = Database.query(soqlquery6);
                if(sobjectQueryResult7 != null){
                    for(sObject sobj : sobjectQueryResult7){                   
                        Id ContactidFromChildObject = (Id)sobj.get(ContentDocumentLink.LinkedEntityId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
            	 system.debug('$$$ soqlquery6 ContactIdSetToRemove *****: ' + ContactIdSetToRemove);
				
				String soqlquery7 = 'select Id,ContactId from User where ContactId in :ContactIds';            
                system.debug('$$$ soqlquery7 *****: ' + soqlquery7);
            	list<sobject> sobjectQueryResult8 = Database.query(soqlquery7);
                if(sobjectQueryResult8 != null){
                    for(sObject sobj : sobjectQueryResult8){                   
                        Id ContactidFromChildObject = (Id)sobj.get(User.ContactId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				
				String soqlquery8 = 'select Id,ContactId from LiveChatTranscript where ContactId in :ContactIds';            
                system.debug('$$$ soqlquery8 *****: ' + soqlquery8);
            	list<sobject> sobjectQueryResult9 = Database.query(soqlquery8);
                if(sobjectQueryResult9 != null){
                    for(sObject sobj : sobjectQueryResult9){                   
                        Id ContactidFromChildObject = (Id)sobj.get(LiveChatTranscript.ContactId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
           
           
           		String soqlquery9 = 'select Id,ContactId from Case where ContactId in :ContactIds';            
                system.debug('$$$ soqlquery9 *****: ' + soqlquery9);
            	list<sobject> sobjectQueryResult10 = Database.query(soqlquery9);
                if(sobjectQueryResult10 != null){
                    for(sObject sobj : sobjectQueryResult10){                   
                        Id ContactidFromChildObject = (Id)sobj.get(Case.ContactId); // get the ids to remove from scope which are not to be deleted.
                        ContactIdSetToRemove.add(ContactidFromChildObject);
                    }
                }
				            
            	 system.debug('$$$ soqlquery8 ContactIdSetToRemove*****: ' + ContactIdSetToRemove);
				
				/*SELECT ContentDocumentId,Id,LinkedEntityId,SystemModstamp FROM ContentDocumentLink where LinkedEntityId in ('003D000001rdQ2cIAE') and ContentDocument.LastModifiedDate >= 2020-03-25T19:39:38.000Z*/
				system.debug('$$$ ContactIdSetToRemove *****: ' + ContactIdSetToRemove.size());
				
           // }
            ContactIds.removeAll(ContactIdSetToRemove); // remove the ids which have related objects
            system.debug('$$$ ContactIds *****: ' + ContactIds.size());
            finalContactlisttoDelete = new List<Id>(ContactIds); // convert the set to list to pass for deletion
            system.debug('$$$ finalContactlisttoDelete *****: ' + finalContactlisttoDelete.size());
            if(!finalContactlisttoDelete.isEmpty()){  
			   total =total+finalContactlisttoDelete.size();
			 
            }else{
			  System.debug('$$$Batch_InactiveContact_Deletion : No Records available for Deletion');   
            }
        }
        catch(Exception e){
            totalfailed = totalfailed+1;
            System.debug(Logginglevel.ERROR, 'Exception! ' + e.getMessage());
           // ErrorLogger.writeErrors('SFDC', 'Contact', 'Batch_InactiveContact_Deletion', lstDeleteResult, lstContact);
        }
        
    }         
        
    global void finish(Database.BatchableContext BC){
		 string Finalnumber=string.valueof(total);
         string Finalnumberfailed=string.valueof(totalfailed);
		Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
		globalErrorLogger.Name = 'AbhinavTest';
		globalErrorLogger.Source_System__c = 'SFDCTest';
		globalErrorLogger.Object__c = Finalnumber;
		globalErrorLogger.Batch_Name__c = Finalnumberfailed;
		globalErrorLogger.Operation_Type__c = 'Batch Count';
	
        insert globalErrorLogger;
    }
    
}