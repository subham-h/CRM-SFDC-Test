/*
* Version       Date                Owner                                    RQ            Description
*******************************************************************************************************
* V1.0          18-Apr-2018        Jiji.Jayasingh@ust-global.com             #RQ-008175    To create Project templates, milestones and tasks when a qualified tender opportunity is created
* V2.0          18-Apr-2018        Jiji.Jayasingh@ust-global.com             #RQ-008183    Add tender handling rounds
* V3.0          18-Apr-2018        Jiji.Jayasingh@ust-global.com             #RQ-008308    Tender owner adds contracting milestones
* V4.0          06-Jun-2018        Jiji.Jayasingh@ust-global.com             #RQ-008383    Default due date to today for all milestones and tasks, if one of them has due date = past date
* V5.0          30-Jul-2018        Jiji.Jayasingh@ust-global.com             #RQ-009016    Create First round milestones and tasks while preparation rund
* V6.0          06-Aug-2018        Jiji.Jayasingh@ust-global.com             #RQ-009067    Salesforce identifies GCBP owner and assigns tasks to him(Also for RQ-009008)
* V7.0          09-Aug-2018        Junaid.Khader@ust-global.com              #RQ-008964    Added method invoked from process builder
* V8.0          13-Aug-2018        Jiji.Jayasingh@ust-global.com             #RQ-008199    To map isPrimary task from project task metadata
* V9.0          20-Aug-2018        Junaid.Khader@ust-global.com              #RQ-008507    To create SBF Review Tasks
* V10.0         29-Aug-2018        Jiji.Jayasingh@ust-global.com             #RQ-008622    Tender owner changes tender criteria after creation
* V11.0         05-Sep-2019        Jiji.Jayasingh@ust-global.com             #RQ-008779    Salesforce deletes related tasks when user deletes milestone
* V12.0         23-Oct-2018        Junaid.Khader@ust-global.com              #RQ-009512    To create Review & Update Nwgotiation tasks for trades for first ever tender
* V13           30-Oct-2018        Junaid.Khader@ust-global.com              #RQ-009421    To assign Inland Preparation task to respective Queue
* V14           07-Nov-2018        Junaid.Khader@ust-global.com              #RQ-009470    Number Of Tasks calculation for 'Quarterly follow up and SBF review' milestone
* V15           26-Nov-2018        Junaid.Khader@ust-global.com              #RQ-009651    Code to assign TCM Owner correctly
* V15           14-Feb-2019        Junaid.Khader@ust-global.com              #RQ-010078    Fixed issue in assigning Review & Update negotiation platform task
* V16           26-Feb-2021        Kiran@Maersk                              #SFSE-4384    Project Milestone names renaming and removing task creation.
* V17           22-April-2021      Neha@TCS                                  #SFSE-5804    Update the Baseline and Due to set today if its in past or to to add days
* V18           03-June-2021       Neha@TCS                                  #SFSE-6047    Added description field for each milestone and renamed fewer milestone
* V19			14-Jun-2021		   Kiran@Maersk							 	#SFSE-6393	   Project_task__c object deprecation
* V19.1         21-Jun-2021		   Meghana@UST								 #SFSE-6299    Deprecate logic to create Team_Member__c records
* V19.2         01-Jul-2021		   Meghana@UST								 #SFSE-6299    Commenting 'cloneProjectTemplates' method as it is not referenced anywhere and is causing code coverage issue.
*/

public class TenderWorkflowUtilities {
    
 /*   
 public static void cloneProjectTemplates(Map<id, Opportunity> OldOppToClonedOppMap, Set<Id> setComplexOppIds){
        List<Project_Template__c> listProjectTemplatesToInsert = new List<Project_Template__c>();
        Project_Template__c newProjectTemplate;
        Set<Id> setAccIds =  new Set<Id>();//RQ-009067
        Map<Id, String> mapOpportunityToLeadRoute = new Map<Id, String>();
        
        for(Project_Template__c projectTemplateRow : [SELECT Id, Name, Customer_Type__c, Tender_Type__c, Reference_Date__c, Rate_Expiry_Date__c ,
                                                          Does_the_Customer_Require_a_SBF_Clause__c, SBF_Formula__c, TCM_Service_Level__c,
                                                          SBF_Review__c, Add_New_Surcharges_in_the_Contract__c,
                                                          Does_The_Customer_Have_Non_Standard_PCD__c, Lead_Route__r.Trade__c,
                                                          Does_the_Customer_Accept_GRI__c, Does_the_Customer_Have_a_VIP_Programme__c,
                                                          Lead_Route__c,Average_Weight_of_20_Containers__c, Average_Weight_of_40_Containers__c,
                                                          Additional_Detention_Demurrage_Needs__c, NAP_Codes__c, 
                                                          Can_We_Deviate_From_Requested_Ports__c,
                                                          Can_We_Deviate_From_The_Service_Mode__c, Does_the_Customer_have_Extended_Credit__c,
                                                          Does_Customer_Have_Index_Linked_Rates__c, Do_We_Have_Any_NAP_for_the_Customer__c,
                                                          Equalised_Formula_Pricing_for_Equipment__c, Equalised_Surcharges_for_Dangerous_Cargo__c,
                                                          Equipment_Alignment_Pricing_Formula__c, Inland_Delivery_Method__c,
                                                          Inland_Delivery_Pricing_Required__c, Non_Standard_Invoice_Issuance_Date__c,
                                                          New_or_Existing_Contract__c, Other_Liner_Brands_Involved_in_Tender__c,
                                                          Separate_or_Combined_Tender_Submission__c, Special_Terms_and_Conditions__c,
                                                          VIP_Details__c,Comments__c, Opportunity__c, Contract_Effective_Date__c,
                                                          Contract_Expiry_Date__c, Rate_Effective_Date__c ,Hazardous_Commodity__c,AFLS_Commodity_Code__c,FMC__c
                                                      FROM Project_Template__c
                                                      WHERE Opportunity__c IN :setComplexOppIds
                                                          AND Reference_Date__c != null]) {
            if(OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).Id != null) {
                newProjectTemplate = projectTemplateRow.clone(false, true);
                newProjectTemplate.ownerId = OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).ownerId;
                newProjectTemplate.Name = OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).Name+' Tender-Template '+ System.Today().format();
                if(newProjectTemplate.Name.length() > 80)
                    newProjectTemplate.Name = newProjectTemplate.Name.substring(0, 80);
                newProjectTemplate.Handling_Rounds__c = 1;
                newProjectTemplate.Opportunity__c = OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).Id;
                newProjectTemplate.Reference_Date__c = OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).Expected_Tender_Receipt_Date__c;
                newProjectTemplate.Stage__c = 'Tender preparation';
                if(projectTemplateRow.TCM_Service_Level__c != null)
                    newProjectTemplate.TCM_Service_Level__c = projectTemplateRow.TCM_Service_Level__c;
                if(projectTemplateRow.Contract_Expiry_Date__c != null)
                    newProjectTemplate.Contract_Effective_Date__c =  projectTemplateRow.Contract_Expiry_Date__c.addDays(1);
                if(newProjectTemplate.Contract_Effective_Date__c != null && projectTemplateRow.Contract_Effective_Date__c != null && projectTemplateRow.Contract_Expiry_Date__c != null)
                    newProjectTemplate.Contract_Expiry_Date__c = newProjectTemplate.Contract_Effective_Date__c.addDays(projectTemplateRow.Contract_Effective_Date__c.DaysBetween(projectTemplateRow.Contract_Expiry_Date__c ));
                if(projectTemplateRow.Rate_Expiry_Date__c != null)
                    newProjectTemplate.Rate_Effective_Date__c = projectTemplateRow.Rate_Expiry_Date__c.addDays(1);
                if(newProjectTemplate.Rate_Effective_Date__c != null && projectTemplateRow.Rate_Effective_Date__c != null && projectTemplateRow.Rate_Expiry_Date__c != null)
                    newProjectTemplate.Rate_Expiry_Date__c = newProjectTemplate.Rate_Effective_Date__c.addDays(projectTemplateRow.Rate_Effective_Date__c.DaysBetween(projectTemplateRow.Rate_Expiry_Date__c ));
                listProjectTemplatesToInsert.add(newProjectTemplate);
                
                if(String.isNotBlank(projectTemplateRow.Lead_Route__r.Trade__c)){
                    mapOpportunityToLeadRoute.put(OldOppToClonedOppMap.get(projectTemplateRow.Opportunity__c).Id, (projectTemplateRow.Lead_Route__r.Trade__c+' Trade'));
                }
            }
        }
        If(listProjectTemplatesToInsert.Size() > 0){
            List<Database.SaveResult> lstProjTempInsertResult= database.insert(listProjectTemplatesToInsert, false);
            ErrorLogger.writeErrors('SFDC', 'OpportunityUtilities', 'CreateProjectTemplates', lstProjTempInsertResult, listProjectTemplatesToInsert);
            List<Id> lstProjTempId = new List<Id>();
            for(Database.SaveResult sr :lstProjTempInsertResult){
                if(sr.isSuccess()){
                    lstProjTempId.add(sr.getId());
                } 
            }
            if(lstProjTempId.size() >0){
                Map<Id, Opportunity> newOpportunityMap = new Map<Id, Opportunity>();
                for(Opportunity oppRow : OldOppToClonedOppMap.values()){
                    setAccIds.add(oppRow.AccountId);//RQ-009067
                    newOpportunityMap.put(oppRow.Id, oppRow);
                }
                TenderWorkflowUtilities.CreateProjectMilestones(listProjectTemplatesToInsert, 'Preparation', null,null, 0, newOpportunityMap, mapOpportunityToLeadRoute);
            }
        }
    }*/
        
    //#RQ-008175 - To create Project templates, milestones and tasks when a tender opportunity is created
    public static void CreateProjectTemplates( List<Opportunity> lstNewOppty){
        Project_Template__c projTemplateRecord;
        List<Project_Template__c> lstProjTemplate = new List<Project_Template__c>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();//Ver 5.0
        Set<Id> setAccIds =  new Set<Id>();//RQ-009067
        
        //Create project template for new tender opportunities
        for(Opportunity oppRec : lstNewOppty){
            mapOpportunity.put(oppRec.Id, oppRec);//RQ-009016
            setAccIds.add(oppRec.AccountId);//RQ-009067
            projTemplateRecord = new Project_Template__c();
            projTemplateRecord.Opportunity__c = oppRec.Id;
            projTemplateRecord.OwnerId = oppRec.OwnerId;
            projTemplateRecord.Name = oppRec.Name+' Tender-Template '+system.Today().format();
            if(projTemplateRecord.Name.length() > 80){
                projTemplateRecord.Name = projTemplateRecord.Name.substring(0, 80);
            }
            projTemplateRecord.Customer_Type__c = oppRec.Customer_Type__c;
            projTemplateRecord.Tender_Type__c = oppRec.Tender_Type__c;
            projTemplateRecord.Handling_Rounds__c = 1;//RQ-009016
            projTemplateRecord.Stage__c = 'Tender Preparation';
            projTemplateRecord.Reference_Date__c = oppRec.Expected_Tender_Receipt_Date__c;
            lstProjTemplate.add(projTemplateRecord);
        }
        If(lstProjTemplate.Size() > 0){
            List<Database.SaveResult> lstProjTempInsertResult= database.insert(lstProjTemplate, false);
            ErrorLogger.writeErrors('SFDC', 'OpportunityUtilities', 'CreateProjectTemplates', lstProjTempInsertResult, lstProjTemplate);
            //insert Milestones for the new project template created
            List<Id> lstProjTempId = new List<Id>();
            for(Database.SaveResult sr :lstProjTempInsertResult){
                if(sr.isSuccess()){
                    lstProjTempId.add(sr.getId());
                } 
            }
            if(lstProjTempId.size() >0){
                TenderWorkflowUtilities.CreateProjectMilestones(lstProjTemplate, 'Preparation', null,null, 0, mapOpportunity, null);// Ver 5.0: added opp map as a parameter
            }
        }
    }
    
    //Create milestones for the new project template created
    public static saveProjectMilestoneWrapper CreateProjectMilestones( List<Project_Template__c> lstProjTemplate, String mileStoneTypeString,  String receiptDate,String submitDate, Decimal handlingRound, Map<Id, Opportunity> mapOpportunity, Map<Id, String> mapOpportunityToLeadRoute){
        Boolean isSaveSuccess = false;
        Boolean isDueDateToday = false;
        
        saveProjectMilestoneWrapper projMilestoneResponse = new saveProjectMilestoneWrapper(false,false);
        
        List<Project_Milestone_Mapping__mdt> lstProjMilestone = new List<Project_Milestone_Mapping__mdt> ();
        List<Project_Milestones__c> lstNewProjMilestone = new List<Project_Milestones__c> ();
        List<String> lstNewMilestoneName = new List<String> ();
        
        Date receivedDate;
        Date submissionDate;
        Date tenderReferenceDate;
        
        //Check for milestone type and assign date values to the variables
        If(mileStoneTypeString == Label.Subsequent_Handling_Round ||
            mileStoneTypeString == Label.Contracting){
            If(receiptDate != null && submitDate != null){
                 receivedDate = Date.Valueof(receiptDate);
                 submissionDate = Date.Valueof(submitDate);    
            }
        }
        //RQ-009016: Start
        //Fetch project milestone mapping metadata type
        String queryString = 'SELECT MasterLabel,DeveloperName, '+
                             'Milestone_Name__c, Description__c, Order__c, Milestone_Alias__c, '+
                             'Baseline_Dates__c, Milestones_Grouping__c, '+
                             'Project_Template_Reopen_Stage__c, '+
                             'Change_To_Project_Template_Stage__c, Reference_Date__c, '+
                             'isMandatory__c, Team_Owner__c '+
                             ' FROM Project_Milestone_Mapping__mdt '+
                             ' WHERE Milestones_Grouping__c = \''+mileStoneTypeString+'\'';
        If(mileStoneTypeString == Label.Preparation){
            queryString = queryString+' OR Milestones_Grouping__c =\''+Label.First_Handling_Round+'\''; 
        }
        queryString = queryString + ' ORDER BY Order__c' ;
        
        lstProjMilestone = Database.query(queryString);
        //RQ-009016: End
        system.debug('lstProjMilestone ' + lstProjMilestone);
        //Create project milestones for new project templates
        If (handlingRound == null){
            handlingRound =1;//RQ-009016
        }
        handlingRound = handlingRound+1;
        for(Project_template__c pTemp : lstProjTemplate){
            integer count =0;
            for(Project_Milestone_Mapping__mdt projMdt : lstProjMilestone){
                //RQ-009016: Start
                String msTypeString;
                If(mileStoneTypeString == Label.Preparation){
                    If(projMdt.Milestones_Grouping__c == Label.Preparation ){
                       msTypeString =  Label.Preparation;
                    } else If(projMdt.Milestones_Grouping__c == Label.First_Handling_Round ){
                        msTypeString =  Label.First_Handling_Round;
                    }
                }
                //RQ-009016: End
                Project_Milestones__c projMilestone = new Project_Milestones__c();
                projMilestone.Order__c = projMdt.Order__c;
                projMilestone.Project_Template__c = pTemp.Id;
                projMilestone.Status__c = 'Not Started';
                projMilestone.Created_from_Template__c = True;
                projMilestone.OwnerId = pTemp.OwnerId;
                projMilestone.Project_Template_Completion_Stage__c = projMdt.Change_To_Project_Template_Stage__c;
                projMilestone.Project_Template_Reopen_Stage__c = projMdt.Project_Template_Reopen_Stage__c;
                //SFSE-4384
                projMilestone.isMandatory__c = projMdt.isMandatory__c;
                projMilestone.Team_Owner__c = projMdt.Team_Owner__c;
                projMilestone.Description__c = projMdt.Description__c;
                lstNewMilestoneName.add(projMdt.Milestone_Name__c);
                
                if((mileStoneTypeString == Label.Preparation &&
                    msTypeString == Label.Preparation) || //RQ-009016
                   mileStoneTypeString == Label.Contracting ||
                   mileStoneTypeString == Label.BAF_Approval
                  ){
                    projMilestone.Name = projMdt.Milestone_Name__c;
                    projMilestone.Milestone_Alias__c = projMdt.Milestone_Alias__c;
                }
                else{
                    projMilestone.Name = projMdt.Milestone_Name__c+' - Round '+handlingRound;
                    projMilestone.Milestone_Alias__c = handlingRound+projMdt.Milestone_Alias__c;
                }
                
                Integer refDays = Integer.ValueOf(projMdt.Reference_Date__c);
                //RQ-009016: Start 
                //SFSE-4384
                if(mileStoneTypeString == Label.BAF_Approval) {
                    tenderReferenceDate = mapOpportunity.get(pTemp.Opportunity__c).First_Round_Submission_Date__c;
                }
                If(mileStoneTypeString == Label.Preparation){
                    if(msTypeString == Label.Preparation){
                        tenderReferenceDate = mapOpportunity.get(pTemp.Opportunity__c).Expected_Tender_Receipt_Date__c;
                    } else{
                        tenderReferenceDate = mapOpportunity.get(pTemp.Opportunity__c).First_Round_Submission_Date__c;
                    }
                }else  if(mileStoneTypeString == Label.Subsequent_Handling_Round || mileStoneTypeString == Label.Contracting){
                    if(projMdt.Milestone_Name__c == 'Received from customer' || projMdt.Milestone_Name__c == 'Final nomination received'){ 
                        tenderReferenceDate = receivedDate;
                    }else{
                        tenderReferenceDate = submissionDate;
                    }
                }
                system.debug('tenderReferenceDate ' + tenderReferenceDate);
                //sets baseline dates and due date to today if baseline dates in the past
                if(tenderReferenceDate != null ){
                    If(tenderReferenceDate.addDays(refDays) < Date.today()){
                        projMilestone.Baseline_Date__c = Date.today();
                        projMilestone.Due_Date__c = Date.today();
                    } else{
                        projMilestone.Baseline_Date__c = tenderReferenceDate.addDays(refDays);
                        projMilestone.Due_Date__c = tenderReferenceDate.addDays(refDays);
                   }
                }
                lstNewProjMilestone.add(projMilestone);
            }
        }
        
        if(lstNewProjMilestone.Size() >0){
            List<Database.SaveResult> lstProjMilestoneInsertResult= database.insert(lstNewProjMilestone, false);
            ErrorLogger.writeErrors('SFDC', 'OpportunityUtilities', 'CreateProjectMilestones', lstProjMilestoneInsertResult, lstNewProjMilestone);
            for(Database.SaveResult sr :lstProjMilestoneInsertResult){
                if(sr.isSuccess()){
                    isSaveSuccess = true;
                }  
            }
        }
        projMilestoneResponse = new saveProjectMilestoneWrapper(isSaveSuccess,isDueDateToday);
        return projMilestoneResponse;
    }
    
    //Wrapper class to set save result and due date check
    public class saveProjectMilestoneWrapper{
        @AuraEnabled 
        public Boolean isSaveSuccess {get; set;}
        @AuraEnabled
        public Boolean isDueDateToday {get; set;}
        public saveProjectMilestoneWrapper(Boolean isSaveSuccess, Boolean isDueDateToday){
            this.isSaveSuccess = isSaveSuccess;
            this.isDueDateToday = isDueDateToday;
        }
    }
    //#RQ-008622: Start
    public static void removeProjectTemplateDetails(List<Opportunity> lstNonTenderOpportunity) {
        Set<Id> oppId = new Set<Id>();
        Set<Id> setProjTempId = new Set<Id>();
        Set<Id> setProjMSId = new Set<Id>();
        List<Project_Template__c> lstProjTemp = new List <Project_Template__c>();
        List<Project_Milestones__c> lstProjMS = new List <Project_Milestones__c>();
        
        If(lstNonTenderOpportunity != null &&
           lstNonTenderOpportunity.size() > 0){
            for(opportunity opp :lstNonTenderOpportunity){
                oppId.add(opp.Id);
            }
            If(oppId.size() > 0){
                for( Project_Template__c ptRec :[Select Id from Project_Template__c Where Opportunity__c IN :oppId]){
                    setProjTempId.add(ptRec.Id);
                    lstProjTemp.add(ptRec);
                }
            }
            If(setProjTempId.size() > 0){
                for(Project_Milestones__c ProjMS :[Select Id from Project_Milestones__c Where Project_Template__c IN :setProjTempId]){
                    lstProjMS.add(ProjMS);
                    setProjMSId.add(ProjMS.Id);
                }
            }
        }
        If(lstProjMS.Size() > 0){
            delete lstProjMS;
        }
        If(lstProjTemp.Size() > 0){
            delete lstProjTemp;
        }
    }
    //RQ-008622: End
}