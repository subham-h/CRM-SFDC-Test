/*
* version       Date                Owner                                   			   RQ		   Description
***************************************************************************************************************************************************
* V1.0          18/04/2018        madhubharathi.goplakrishnan@ust-global.com              RQ-008184    Tender Owner removes handling rounds
*
*/
public without sharing class RemoveHandlingRoundLightningCntrl {
    //Remove the latest subsequent handling round added to a project template
    @AuraEnabled
    public static Boolean removeLatestHandlingRoundRecord(Id recordId){

        List<Project_MileStones__c> lstProjectMileStone = new List<Project_MileStones__c>();
        Project_Template__c ptempRecord;
        String roundString; 
        Boolean responseMessage = False;
        
        if(recordId != null){
            //fetch the project template details based on the record id.
         	ptempRecord= [Select Id,Handling_Rounds__c FROM Project_Template__c Where Id = :recordId];
            roundString = ' - Round '+ptempRecord.Handling_Rounds__c;
            If(ptempRecord.Handling_Rounds__c < 2){
                //show the error message if there is no subsequent round to delete
				responseMessage = False;
            }
            else{
                //fetch the subsequent rounds to delete
                for( Project_Milestones__c pm: [SELECT Id,Name 
                                                FROM Project_Milestones__c 
                                                WHERE Project_Template__c = :recordId 
                                                AND Name Like : ('%' +roundString+'%') 
                                                ORDER BY CreatedDate DESC] ){
                    lstProjectMileStone.add(pm);
                }
            }
            // Delete milestones
            if(lstProjectMileStone.size() > 0){
                List<Database.DeleteResult> deleteResults = Database.delete(lstProjectMileStone, false);
                ErrorLogger.writeErrors('SFDC', 'Project_Milestone__c','removeLatestHandlingRoundRecord',deleteResults,lstProjectMileStone);
                for(Database.DeleteResult dr : deleteResults) {  
                    if (dr.isSuccess()) {
                        responseMessage = True;  
                    }
                }
                // if milestones and tasks are deleted successfully, update handling round in project template
                if(responseMessage == True){                             
                    Project_Template__c ptRecordtoUpdate = new Project_Template__c();
                    ptRecordtoUpdate.Id = recordId;  
                    ptRecordtoUpdate.Handling_Rounds__c = ptempRecord.Handling_Rounds__c-1 ;
                    Database.SaveResult ptResults = database.update( ptRecordtoUpdate, false);  
                    if (ptResults.isSuccess()) {
                        responseMessage = True;
                    }                    
                }                                           
            }                         
        } 
        return responseMessage;
    }  
}