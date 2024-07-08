/*
 * Created By   : Aleena@Maersk
 * Purpose      : Centralize the record selection process for Opportunity Files object.Defines the methods which iterate and segregate the Opportunity File records for further use.
 *              
 * Revision Jira Number    Date            Owner                   Description
 * -------- ----------   -----------  -------------------   --------------------------------------------------------
 * 1.0      SFSE-12888   11-Oct-2023     Aleena@Maersk      Added logic for Opportunity V3 and V4 event record selection on update
 * 
 */
public class OpportunityFileRecordSelector {
    private OpportunityFileTriggerHandler opptyFilesTriggerHandler;
    public Set<Id> lstOfOpptyonOpptyFileForEvent = new Set<Id>(); //12888
    
    public OpportunityFileRecordSelector(list<Opportunity_File__c> lstNewOpptyFile, map<Id,Opportunity_File__c > OldOpptyFile, TriggerHandler opptyFilesTriggerHandler){
        Opportunity_File__c oldOpportunityFile;
        if(trigger.isUpdate){
            for(Opportunity_File__c newOpptyFile : lstNewOpptyFile){  
                if(OldOpptyFile != null){
                    oldOpportunityFile = OldOpptyFile.get(newOpptyFile.id);
                }
                
                if(opptyFilesTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyFilesTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                   (((newOpptyFile.File_Category__c!= null && newOpptyFile.File_Category__c=='RFQ') && newOpptyFile.Quote__c!= null )
                    || ((newOpptyFile.File_Category__c!= null && newOpptyFile.File_Category__c=='Freetime') || (newOpptyFile.Send_to_azure__c!= null && newOpptyFile.Send_to_azure__c==true))
                   )){
                    lstOfOpptyonOpptyFileForEvent.add(newOpptyFile.Opportunity__c);  
                }
                
            }
        }
    }

}