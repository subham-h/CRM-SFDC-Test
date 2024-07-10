/*
* Version       Date                Owner                                    RQ            Description
*******************************************************************************************************
* V1.0          18/04/2018        Jiji.Jayasingh@ust-global.com              #RQ-008308    Tender owner adds milestones
* V2.0          30/07/2018        Jiji.Jayasingh@ust-global.com              #RQ-009016    Remove code for adding first handling round
* V3.0          30/08/2018        Junaid.Khader@ust-global.com               #RQ-008769    Validation added
*/
public class AddRoundsToTemplateLightningCntrl {
    
    //Get the project template record during page load
    @AuraEnabled
    public static Project_Template__c getTenderDetails(Id projTempId){
        Project_Template__c ptRecord;
        ptRecord = [SELECT Id, Opportunity__c, OwnerId, Handling_Rounds__c, Reference_Date__c,SBF_Formula__c, Rate_Effective_Date__c, Rate_Expiry_Date__c, Contract_Effective_Date__c FROM Project_Template__c WHERE Id = :projTempId];  
        return ptRecord;
    }
    //To check whether the contract details already exists or not
    @AuraEnabled
    public static Boolean getContractDetails(Id projTempId){
        
        Boolean isContractExist = False;
        List<Project_Milestone_Mapping__mdt> lstProjMilestone = new List<Project_Milestone_Mapping__mdt> ();
        lstProjMilestone = CreateMilestoneMetadata();
        Set<String> setMilestoneAlias = new Set<String>();
        for( Project_Milestone_Mapping__mdt mtdt  : lstProjMilestone){
            setMilestoneAlias.add(mtdt.Milestone_Alias__c);
        }
        List<Project_Milestones__c> lstProjectMilestone =  new List<Project_Milestones__c>();
        if(projTempId != null && setMilestoneAlias.Size() > 0 ){
            for(Project_Milestones__c pt :[Select Id,Milestone_Alias__c 
                                    From Project_Milestones__c 
                                    where Project_Template__c = :projTempId 
                                    and Milestone_Alias__c IN :setMilestoneAlias]){
                lstProjectMilestone.add(pt) ;
             }
             if(lstProjectMilestone.size() > 0){
                isContractExist = True;
             }
        }
        return isContractExist;
    }
    //Validate dates
    @AuraEnabled
    public static String validateDates(String receiptDate, String submitDate, Project_Template__c ptRec, String typeString){
        Boolean isCorrectDates = False;
        Date recDate = Date.valueOf(receiptDate);
        Date subDate = Date.valueOf(submitDate);
        
		If(recDate >= subDate){
            If(typeString == Label.Contracting){
               return Label.ContractingRoundErrorMessage;
            }
            else If(typeString == Label.Subsequent_Handling_Round){
               return Label.AddRoundsToTemplateAlert1;
            }
             
        } else if(ptRec != null && ptRec.Handling_Rounds__c >= 1){
            String taskName = (ptRec.Handling_Rounds__c > 1) ? ('Submitted to customer - Round '+ptRec.Handling_Rounds__c) : ('Submitted to customer - Round 1');
            Project_Milestones__c projectTaskRecord = [SELECT Due_Date__c FROM Project_Milestones__c 
                                                       WHERE Project_Template__c = :ptRec.Id
                                                           AND Name = :taskName
                                                       LIMIT 1];
            if(projectTaskRecord.Due_Date__c != null && projectTaskRecord.Due_Date__c > recDate)
                return Label.AddRoundsToTemplateAlert2;
        }
        return null;
    }
    //Save action method
    @AuraEnabled
    public static TenderWorkflowUtilities.saveProjectMilestoneWrapper saveRecords (String receiptDate, String submitDate, Project_Template__c ptRecord){
        List<Project_Template__c> lstProjTemplate = new List<Project_Template__c>();
        lstProjTemplate.add(ptRecord);
        
        Map<Id, Opportunity> mapOpportunity =getOpportunityMap(ptRecord);
        TenderWorkflowUtilities.saveProjectMilestoneWrapper responseString = TenderWorkflowUtilities.CreateProjectMilestones(lstProjTemplate, Label.Contracting,  receiptDate,submitDate, ptRecord.Handling_Rounds__c, mapOpportunity, null);
        return responseString;
    }
    
    //Save action method
    @AuraEnabled
    public static TenderWorkflowUtilities.saveProjectMilestoneWrapper saveTemplateRecord (String referenceDate, String receiptDate, String submitDate, Project_Template__c ptRecord){
        list<Project_Template__c> lstPTRecordToUpdate = new list<Project_Template__c>();
        list<Project_Template__c> lstProjTemplate = new list<Project_Template__c>();
        lstProjTemplate.add(ptRecord);
        Map<Id, Opportunity> mapOpportunity =getOpportunityMap(ptRecord);
        TenderWorkflowUtilities.saveProjectMilestoneWrapper projMilestoneResponse = new TenderWorkflowUtilities.saveProjectMilestoneWrapper(false,false);
        //Create subsequent round milestones and tasks
        projMilestoneResponse = TenderWorkflowUtilities.CreateProjectMilestones(lstProjTemplate, Label.Subsequent_Handling_Round, receiptDate,submitDate, ptRecord.Handling_Rounds__c, mapOpportunity, null);
        
        //If milestones and tasks created successfully, update handling round in project template
        if(projMilestoneResponse.isSaveSuccess == true){
            ptRecord.Handling_Rounds__c = ptRecord.Handling_Rounds__c+1 ;
            lstPTRecordToUpdate.add(ptRecord);
            
            List<Database.SaveResult> lstProjTempInsertResult = database.update(lstPTRecordToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'addRoundsToTemplateLightningCntrl', 'saveTemplateRecord', lstProjTempInsertResult, lstPTRecordToUpdate);
            for(Database.SaveResult sr :lstProjTempInsertResult){
                if(sr.isSuccess()){
                    projMilestoneResponse.isSaveSuccess = true;
                }
            } 
        }
        return projMilestoneResponse;        
    } 
    
    public static List<Project_Milestone_Mapping__mdt> CreateMilestoneMetadata(){
        String mileStoneTypeString = Label.Contracting;
        List<Project_Milestone_Mapping__mdt> lstProjMilestone = new List<Project_Milestone_Mapping__mdt> ();
       
        //Fetch contracting project milestone mapping metadata type
        for(Project_Milestone_Mapping__mdt projMilestoneMapping : [SELECT MasterLabel,DeveloperName, 
                                                                   Milestone_Name__c, Order__c, Milestone_Alias__c,
                                                                   Baseline_Dates__c, Milestones_Grouping__c,
                                                                   Reference_Date__c
                                                                 FROM Project_Milestone_Mapping__mdt 
                                                                 WHERE Milestones_Grouping__c = :mileStoneTypeString 
                                                                  ORDER BY Order__c]){
            
               lstProjMilestone.add(projMilestoneMapping);                                                    
        }
        return lstProjMilestone;
    }
    public static Map<Id, Opportunity> getOpportunityMap(Project_Template__c ptRecord){
        map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>();
        if(ptRecord.Opportunity__c != null){
            for(Opportunity opp : [Select Id, Expected_Tender_Receipt_Date__c, First_Round_Submission_Date__c 
                                   FROM Opportunity 
                                   WHERE Id = :ptRecord.Opportunity__c]){
                mapOpportunity.put(opp.Id, opp);            
            }
        }
        return mapOpportunity;
    }
}