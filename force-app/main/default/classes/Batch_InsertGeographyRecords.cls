/*
Description: Batch class to insert Geography records post-refresh

* Version       Date            Owner                               Description
******************************************************************************************************************************************************
* v1.0			22-Feb-2019		manjunath.c.holekade@maersk.com		RQ-010022 -> Order of .csv file headers should be as follows: 	Name->GEO_Code__c->GEO_ID__c->Type_Of_Location__c
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/
 
 global class Batch_InsertGeographyRecords implements Database.Batchable<sObject>,Database.Stateful{
	global Integer intSuccessCount = 0;
	global Integer intFailedCount = 0; 
	global Database.QueryLocator start(Database.BatchableContext BC){
		String strFileName = 'PostrefreshGeographies';
		String query = 'SELECT Id,Name, Body from StaticResource where Name =:strFileName';  
		return Database.getQueryLocator(query);  
	}
   
	global void execute(Database.BatchableContext BC, List<StaticResource> scope) { 
        String strFileBody = scope[0].Body.toString();
		List<String> lstFileRows = strFileBody.split('\n');
		List<Geography__c> lstToBeInsertedGeo = new List<Geography__c>();
		User geoInterfaceUser = [select Id from User where Name = 'GEO Interface'];
		for(integer i=1; i<lstFileRows.size();i++){
			List<String> lstGeoValues = lstFileRows[i].split(',');
			Geography__c geoRecord = new Geography__c();
			if(lstGeoValues[0] != '' && lstGeoValues[0] != NULL){
				geoRecord.Name = lstGeoValues[0];
				geoRecord.Active__c = True;
				geoRecord.GEO_Code__c = lstGeoValues[1];
				geoRecord.GEO_ID__c = lstGeoValues[2];
				geoRecord.Type_Of_Location__c = lstGeoValues[3];
				geoRecord.OwnerId = geoInterfaceUser.Id;
				lstToBeInsertedGeo.add(geoRecord);
			}
		}
		Database.SaveResult[] lstSaveResults = Database.Insert(lstToBeInsertedGeo, false);
		ErrorLogger.writeErrors('SFDC', 'Geography__c', 'Batch_InsertGeographyRecords.execute', lstSaveResults, lstToBeInsertedGeo);
		for (Database.SaveResult varlstSaveResults : lstSaveResults){
			if (varlstSaveResults.isSuccess())
				intSuccessCount++;
			else
				intFailedCount++;
		}
	}
	global void finish(Database.BatchableContext BC){    
		AsyncApexJob varAsyncApexJob = [Select Id, Status, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];		
		// Email the batch job status to the submitter
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {varAsyncApexJob.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Postrefresh Geographies Insert Status: ' + varAsyncApexJob.Status);
		mail.setPlainTextBody('The "Postrefresh Geographies Insert" batch Apex job is processed with '+ intSuccessCount + ' successes and ' + intFailedCount + ' failures.'  );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}