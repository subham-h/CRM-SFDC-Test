/**
 * Author   : Avinash
 * Purpose  : Utility class to hold simple and reusable functionalities for auto populating Agent Workflow fields. 
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      IIP-149   24-08-2020     Avinash@UST            Created and optimized for implementing CBO (Centralized By Org) trigger architecture
 * 2.0      SC-1141   07-10-2020     Sriram@maersk          Update recordtype to spot FMC,owner assignement, Region and GSC 
 * 3.0      IIP-926   15-02-2021     Sandeep@UST            Update all converted formula-->LongTextArea fields to with same values as formula on before insert but with new line character instead <br> tag so that they can come properly in export from reports.
 * 4.0      SPI-100   27-06-2022     Ronnie@SF              Removed brand carrier code hardcoding
 */

public class AgentWorkflowFieldPopulator {
    
    //2.0 SC-1141
    public static void updateSpotFMCFields(List<Agent_Workflow__c> listAW,map<Id,Geography__c> agentAndCountryMap){
        Id spotFMCRTId = StaticFactory.getRecordTypeIdByName('Agent_Workflow__c', Label.Spot_FMC);
        map<String,SPOT_FMC_Country_GSC_Mapping__mdt> countryGSCMap = AgentWorkflowRecordSelector.getCountryGSCMapping();
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateSpotFMCFields()', 1)) {
                for(Agent_Workflow__c agentWorkFlow:listAW){
                    if(string.isNotBlank(agentWorkFlow.Country__c) && agentAndCountryMap.containsKey(agentWorkFlow.Country__c)){
                         string geoId = agentAndCountryMap.get(agentWorkFlow.Country__c).GEO_ID__c;
                        if(agentWorkFlow.Carrier__c != BrandUtilities.getBrandShortForm(BrandUtilities.SEALAND) || string.isBlank(agentWorkFlow.Carrier__c)){                           
                            agentWorkFlow.Region__c = countryGSCMap.get(geoId).Region__c ;
                            agentWorkFlow.GSC__c = countryGSCMap.get(geoId).Sites__c;
                            agentWorkFlow.OwnerId = countryGSCMap.get(geoId).Queue_Id__c;                            
                        }else{                             
                             agentWorkFlow.Region__c = countryGSCMap.get(geoId).Region__c ;
                              //assign to MNL queue
                             agentWorkFlow.GSC__c = 'MNL';                           
                             agentWorkFlow.OwnerId = Label.Spot_FMC_MNL_Queue;
                        }                           
                        
                    }else{
                             if(agentWorkFlow.Carrier__c != BrandUtilities.getBrandShortForm(BrandUtilities.SEALAND) || string.isBlank(agentWorkFlow.Carrier__c)){                           
                                 //assign to global queue
                                  agentWorkFlow.OwnerId = Label.Spot_FMC_Global_Queue;
                                 
                             }else{
                                 //assign to MNL queue
                                 agentWorkFlow.GSC__c = 'MNL';     
                                 agentWorkFlow.OwnerId = Label.Spot_FMC_MNL_Queue;                                 
                             }
                            
                    }
                    agentWorkFlow.RecordTypeId = spotFMCRTId ;                   
                    
                }                
            }
        } Catch(Exception ex){            
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateSpotFMCFields', new list<Exception>{ex});  
        }
        
    }
    
    //Method to Update Case owner,Status and Resolution Summary as agent workflow owner when workflow is auto-approved.
    //This logic will execute only on insert
    public static void updateCaseOwnerOnAWAutoApproved(List<Agent_Workflow__c> listAW,Set<Id> setAutoApprovedAWCases,Map<Id,Case> mapRelatedCases){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateCaseOwnerOnAWAutoApproved()', 1)) {
                if(!setAutoApprovedAWCases.isEmpty()){
                    if(!system.isFuture()){
                        updateCaseOwnerOnAWAutoApprovedFuture(setAutoApprovedAWCases);
                    }
                    else{
                        updateCaseOwnerOnAWAutoApprovedNOTFuture( listAW,mapRelatedCases );
                    }
                }
            }
        }
        Catch(Exception ex){            
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateCaseOwnerOnAWAutoApproved', new list<Exception>{ex});  
        }
    }
    
    //Future method for updateCaseOwnerOnAWAutoApproved
    @future
    public static void updateCaseOwnerOnAWAutoApprovedFuture(Set<Id> caseIds){
        List<Case> listCase = new List<Case>();
        for(Case cse : [Select OwnerId,Status,Resolution_Summary__c from Case where Id IN:caseIds]){
            cse.OwnerId = Label.System_Owner;
            cse.Status = 'Closed - Resolved';
            cse.Resolution_Summary__c = 'Approved'; 
            listCase.add(cse);
        }
        
        if(listCase.size() > 0){
            TriggerExecutionController.skipCaseTrigger(true);
            update listCase;
            TriggerExecutionController.skipCaseTrigger(false);
        }
    }
    
    //Update Case Owner as AW Owner,Status and Resolution Summary when Agent Workflow Approved / Rejected
    public static void updateCaseClosureOwnerOnAWClosure(List<Agent_Workflow__c> listAW,Map<Id,Case> mapRelatedCases){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateCaseClosureOwnerOnAWClosure()', 1)) {
                List<Case> listCase = new List<Case>();
                for( Agent_Workflow__c newAW : listAW ){
                    Case cse = mapRelatedCases.get(newAW.Case_ID__c);
                    //cse.OwnerId = newAW.OwnerId;
                    cse.Status = 'Closed - Resolved';
                    cse.Resolution_Summary__c = newAW.Status__c == 'Approved' ? 'Approved' : 'Rejected - ' + newAW.Rejection_Reason__c;
                    listCase.add(cse);
                }
                
                if(listCase.size() > 0)
                    update listCase;
            }
        }
        Catch(Exception ex){
            system.debug(  ':::ERROR:::' + ex.getMessage() );            
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateCaseClosureOwnerOnAWClosure', new list<Exception>{ex});  
        }
    }
    
    //Update child workflow status on basis parent workflows
    public static void updateChildWorkflowStatus( List<Agent_Workflow__c> listAW,Map<Id,Agent_Workflow__c> mapRelatedAW ){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateChildWorkflowStatus()', 1)) {
                for(Agent_Workflow__c newAW : listAW){
                    newAW.Status__c = mapRelatedAW.get(newAW.ParentId__c).Status__c;
                    newAW.Rejection_Reason__c = mapRelatedAW.get(newAW.ParentId__c).Status__c != null && mapRelatedAW.get(newAW.ParentId__c).Status__c == 'Rejected' ? mapRelatedAW.get(newAW.ParentId__c).Rejection_Reason__c : '';
                    newAW.Admin_Comments__c = mapRelatedAW.get(newAW.ParentId__c).Status__c != null && mapRelatedAW.get(newAW.ParentId__c).Status__c == 'Rejected' ? mapRelatedAW.get(newAW.ParentId__c).Admin_Comments__c : '';
                    newAW.OwnerId = mapRelatedAW.get(newAW.ParentId__c).OwnerId;
                }
                //Updating Child AW records
                update listAW;
            }
        }
        Catch(Exception ex){
            system.debug( '::ERROR::'  + ex.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateChildWorkflowStatus', new list<Exception>{ex});  
        }
    }
    
    //Updating Agent Workflow owner as Case Owner
    public static void updateAgentWorkflowOwner( List<Agent_Workflow__c> listAW, Map<Id,Case> mapRelatedCases ){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateAgentWorkflowOwner()', 1)) {
                for(Agent_Workflow__c newAW : listAW){
                    newAW.ownerid = mapRelatedCases.get( newAW.Case_ID__c ).OwnerId;
                }
            }
        }Catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateAgentWorkflowOwner', new list<Exception>{ex});  
        }
    }
    
    public static void updateCaseOwnerOnAWAutoApprovedNOTFuture( List<Agent_Workflow__c> listAW,Map<Id,Case> mapRelatedCases ){
        List<Case> listCase = new List<Case>();
        for( Agent_Workflow__c aw :listAW ){
            Case cse = mapRelatedCases.get(aw.Case_ID__c);
            cse.OwnerId = Label.System_Owner;
            cse.Status = 'Closed - Resolved';
            cse.Resolution_Summary__c = 'Approved';
            listCase.add(cse);
        }
        
        if(listCase.size() > 0)
            update listCase;
    }
    
    //Method to update agent workflow status field basis Approvals needed field as per workflow queue management rules
    /*public static void updateStatusbasisApprovalNeeded(List<Agent_Workflow__c> listAW){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateStatusbasisWorkflowQmanagement()', 1)) {
                for(Agent_Workflow__c newAW : listAW){
                    newAW.Status__c = newAW.Approvals_Needed__c != null && newAW.Approvals_Needed__c != '' && newAW.Approvals_Needed__c.split(';').size() < 3 ? 
                        			  (newAW.Approvals_Needed__c.contains('Counter') ? 'Request Submitted': (newAW.Approvals_Needed__c.contains('AFR') ? 'Approved by counter' : (
                                      newAW.Approvals_Needed__c.contains('ACR') ? 'Approved by AFR' : ''))): 'Request Submitted'; 
                }
            }
        }Catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateStatusbasisWorkflowQmanagement', new list<Exception>{ex});  
        }
    }*/
    
    //Method to update agent workflow longTextArea fields based on formulas and to add line breaks instead <bR> tag for all HBL , HSS formulas so that they can come properly in export from report.
    public static void updateLongTextAreaFields(List<Agent_Workflow__c> listAW){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateLongTextAreaFields()', 1)) {
                for(Agent_Workflow__c newAW : listAW){
                    
                    if(newAW.Type__c == 'House BL'){
                         newAW.HBL_Consignee_Party_Details__c = ((newAW.HBL_Consignee_Name__c == '') ? '' : newAW.HBL_Consignee_Name__c) + '\n '+
                                                                    ((newAW.HBL_Consignee_Street_Address__c == '')? '': newAW.HBL_Consignee_Street_Address__c) + '\n ' +
                                                                    ((newAW.HBL_Consignee_City__c == '')? '': (((newAW.HBL_Consignee_Postal_Code__c == '')? (newAW.HBL_Consignee_City__c + '\n '):newAW.HBL_Consignee_City__c))) + 
                                                                    ((newAW.HBL_Consignee_Postal_Code__c == '')? '': ' - '+newAW.HBL_Consignee_Postal_Code__c) + '\n ' +
                                                                    ((newAW.HBL_Consignee_Country_Sub_Division_Name__c == '' || newAW.HBL_Consignee_Country_Sub_Division_Name__c == null)? '': newAW.HBL_Consignee_Country_Sub_Division_Name__c+ '\n ')  +
                                                                    ((newAW.HBL_Consignee_Country_Name__c == '')? '': newAW.HBL_Consignee_Country_Name__c) + '\n ' +
                                                                    ((newAW.HBL_Consignee_Type_of_Code__c == '' || newAW.HBL_Consignee_Type_of_Code__c == null)? '': newAW.HBL_Consignee_Type_of_Code__c) + 
                                                                    ((newAW.HBL_Consignee_Code__c == '' || newAW.HBL_Consignee_Code__c == null)? '': (((newAW.HBL_Consignee_Type_of_Code__c == '' || newAW.HBL_Consignee_Type_of_Code__c == null)? newAW.HBL_Consignee_Code__c : ' : ' +newAW.HBL_Consignee_Code__c)));
                        
                        newAW.HBL_Consignor_Party_Details__c = ((newAW.Consignors_Name__c == ''||newAW.Consignors_Name__c == null) ? '' : newAW.Consignors_Name__c+ '\n ') +
                                                                ((newAW.Consignor_Street_Address__c == '' ||newAW.Consignor_Street_Address__c == null )? '': newAW.Consignor_Street_Address__c+ '\n ')  +
                                                                ((newAW.Consignors_City__c == '' ||newAW.Consignors_City__c == null )? '': (((newAW.Consignors_Postal_Code__c == '' ||newAW.Consignors_Postal_Code__c == null)? (newAW.Consignors_City__c + '\n '):newAW.Consignors_City__c))) + 
                                                                ((newAW.Consignors_Postal_Code__c == '' || newAW.Consignors_Postal_Code__c == null)? '': ' - '+newAW.Consignors_Postal_Code__c + '\n ') +
                                                                (((newAW.Consignors_Sub_Div_Name__c == '' || newAW.Consignors_Sub_Div_Name__c == null))? '': newAW.Consignors_Sub_Div_Name__c+'\n ') +
                                                                ((newAW.Consignors_Country_Name__c == '' ||newAW.Consignors_Country_Name__c == null)? '': newAW.Consignors_Country_Name__c+ '\n ')  +
                                                                ((newAW.Consignor_Code_Type__c == '' || newAW.Consignor_Code_Type__c == null)? '': newAW.Consignor_Code_Type__c) + 
                                                                ((newAW.Consignor_Code__c == '' || newAW.Consignor_Code__c == null)? '': (((newAW.Consignor_Code_Type__c == '' || newAW.Consignor_Code_Type__c == null)? newAW.Consignor_Code__c : ' : ' +newAW.Consignor_Code__c)));
					
                     	newAW.HBL_First_Notify_Party_Details__c = ((newAW.HBL_First_Notify_Party_Name__c == '') ? '' : newAW.HBL_First_Notify_Party_Name__c) + '\n '+
                                                                    ((newAW.HBL_First_Notify_Party_Street_Address__c == '')? '': newAW.HBL_First_Notify_Party_Street_Address__c) + '\n ' +
                                                                    ((newAW.HBL_First_Notify_Party_City__c == '')? '': (((newAW.HBL_First_Notify_Party_Postal_Code__c == '')? (newAW.HBL_First_Notify_Party_City__c + '\n '):newAW.HBL_First_Notify_Party_City__c))) + 
                                                                    ((newAW.HBL_First_Notify_Party_Postal_Code__c == '')? '': ' - '+newAW.HBL_First_Notify_Party_Postal_Code__c) + '\n ' +
                                                                    ((newAW.HBL_1st_Notify_Party_Country_SubDiv_Name__c == '' || newAW.HBL_1st_Notify_Party_Country_SubDiv_Name__c == null)? '': newAW.HBL_1st_Notify_Party_Country_SubDiv_Name__c+'\n ') +
                                                                    ((newAW.HBL_First_Notify_Party_Country_Name__c == '')? '': newAW.HBL_First_Notify_Party_Country_Name__c) + '\n ' +
                                                                    ((newAW.HBL_First_Notify_Party_Type_of_Code__c == '' || newAW.HBL_First_Notify_Party_Type_of_Code__c == null)? '': newAW.HBL_First_Notify_Party_Type_of_Code__c) + 
                                                                    ((newAW.HBL_First_Notify_Party_Code__c == '' || newAW.HBL_First_Notify_Party_Code__c == null)? '': (((newAW.HBL_First_Notify_Party_Type_of_Code__c == '' || newAW.HBL_First_Notify_Party_Type_of_Code__c == null)? newAW.HBL_First_Notify_Party_Code__c : ' : ' +newAW.HBL_First_Notify_Party_Code__c)));

						
                  
                        
                    
                    }
                    else if(newAW.Type__c == 'HSS'){
                        
                   newAW.HSS_Buyer_Party_Details__c = ((newAW.HSS_Buyer_Name__c == '') ? '' : newAW.HSS_Buyer_Name__c) + '\n '+
                                                                    ((newAW.HSS_Buyer_Street_Address__c == '')? '': newAW.HSS_Buyer_Street_Address__c) + '\n ' +
                                                                    ((newAW.HSS_Buyer_City__c == '')? '': (((newAW.HSS_Buyer_Postal_Code__c == '')? (newAW.HSS_Buyer_City__c + '\n '):newAW.HSS_Buyer_City__c))) + 
                                                                    ((newAW.HSS_Buyer_Postal_Code__c == '')? '': ' - '+newAW.HSS_Buyer_Postal_Code__c) + '\n ' +
                                                                    ((newAW.HSS_Buyer_Country_Sub_Division_Name__c == '' || newAW.HSS_Buyer_Country_Sub_Division_Name__c == null)? '': newAW.HSS_Buyer_Country_Sub_Division_Name__c + '\n ') +
                                                                    ((newAW.HSS_Buyer_Country_Name__c == '')? '': newAW.HSS_Buyer_Country_Name__c) + '\n ' +
                                                                    ((newAW.HSS_Buyer_Type_of_Code__c == '' || newAW.HSS_Buyer_Type_of_Code__c == null)? '': newAW.HSS_Buyer_Type_of_Code__c) + 
                                                                    ((newAW.HSS_Buyer_Code__c == '' || newAW.HSS_Buyer_Code__c == null)? '': (((newAW.HSS_Buyer_Type_of_Code__c == '' || newAW.HSS_Buyer_Type_of_Code__c == null)? newAW.HSS_Buyer_Code__c : ' : ' +newAW.HSS_Buyer_Code__c)));
					
                        
                   
                     newAW.HSS_Seller_Party_Details__c = ((newAW.HSS_Seller_Name__c == '') ? '' : newAW.HSS_Seller_Name__c) + '\n '+
                                                                    ((newAW.HSS_Seller_Street_Address__c == '')? '': newAW.HSS_Seller_Street_Address__c) + '\n ' +
                                                                    ((newAW.HSS_Seller_City__c == '')? '': (((newAW.HSS_Seller_Postal_Code__c == '')? (newAW.HSS_Seller_City__c + '\n '):newAW.HSS_Seller_City__c))) + 
                                                                    ((newAW.HSS_Seller_Postal_Code__c == '')? '': ' - '+newAW.HSS_Seller_Postal_Code__c) + '\n ' +
                                                                    ((newAW.HSS_Seller_Country_Sub_Division_Name__c == '' || newAW.HSS_Seller_Country_Sub_Division_Name__c == null)? '': newAW.HSS_Seller_Country_Sub_Division_Name__c+ '\n ')  +
                                                                    ((newAW.HSS_Seller_Country_Name__c == '')? '': newAW.HSS_Seller_Country_Name__c) + '\n ' +
                                                                    ((newAW.HSS_Seller_Type_of_Code__c == '' || newAW.HSS_Seller_Type_of_Code__c == null)? '': newAW.HSS_Seller_Type_of_Code__c) + 
                                                                    ((newAW.HSS_Seller_Code__c == '' || newAW.HSS_Seller_Code__c == null)? '': (((newAW.HSS_Seller_Type_of_Code__c == '' || newAW.HSS_Seller_Type_of_Code__c == null)? newAW.HSS_Seller_Code__c : ' : ' +newAW.HSS_Seller_Code__c)));
                    
					 newAW.HSS_Consignor_Party_Details__c = ((newAW.Consignors_Name__c == '' ||newAW.Consignors_Name__c == null) ? '' : newAW.Consignors_Name__c+ '\n ') +
                                                                    ((newAW.Consignor_Street_Address__c == ''||newAW.Consignor_Street_Address__c == null)? '': newAW.Consignor_Street_Address__c+ '\n ')  +
                                                                    ((newAW.Consignors_City__c == '' ||newAW.Consignors_City__c == null)? '': (((newAW.Consignors_Postal_Code__c == '' ||newAW.Consignors_Postal_Code__c == null)? (newAW.Consignors_City__c + '\n '):newAW.Consignors_City__c))) + 
                                                                    ((newAW.Consignors_Postal_Code__c == '' ||newAW.Consignors_Postal_Code__c == null)? '': ' - '+newAW.Consignors_Postal_Code__c+ '\n ') + 
                                                                    ((newAW.Consignors_Sub_Div_Name__c == '' || newAW.Consignors_Sub_Div_Name__c == null)? '': newAW.Consignors_Sub_Div_Name__c + '\n ') +
                                                                    ((newAW.Consignors_Country_Name__c == '' ||newAW.Consignors_Country_Name__c == null)? '': newAW.Consignors_Country_Name__c+ '\n ')  +
                                                                    ((newAW.Consignor_Code_Type__c == '' || newAW.Consignor_Code_Type__c == null)? '': newAW.Consignor_Code_Type__c) + 
                                                                    ((newAW.Consignor_Code__c == '' || newAW.Consignor_Code__c == null)? '': (((newAW.Consignor_Code_Type__c == '' || newAW.Consignor_Code_Type__c == null)? newAW.Consignor_Code__c : ' : ' +newAW.Consignor_Code__c)));

                    
                    	  }
    
                    
                } 
            }
        }Catch(Exception ex){ 
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateLongTextAreaFields', new list<Exception>{ex});  
        }
    }
    
    //Method to assign record type basis agent workflow type
    public static void updateWorkflowRecordType(List<Agent_Workflow__c> listAW){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('AgentWorkflowFieldPopulator.updateWorkflowRecordType()', 1)) {
                Id spotFMCRTId = StaticFactory.getRecordTypeIdByName('Agent_Workflow__c', Label.Spot_FMC);
                Id customManifestRTId = StaticFactory.getRecordTypeIdByName('Agent_Workflow__c', Label.Custom_Manifest);
                
                for(Agent_Workflow__c newAW : listAW){
                    system.debug('---recordtype--1----'+newAW.RecordTypeId);
                    
                    //added by sandeep
                    if(string.isBlank(newAW.RecordTypeId) || newAW.RecordTypeId == null){
                        system.debug('---recordtype------'+newAW.RecordTypeId);
                        
                        newAW.RecordTypeId = newAW.Type__c != null && newAW.Type__c != '' ? 
                            ((newAW.Type__c == 'House BL' || newAW.Type__c == 'HSS' || newAW.Type__c == 'CFS') ? customManifestRTId : 
                             (newAW.Type__c == 'Incorrect Party Details' || newAW.Type__c == 'Incorrect Digital Signature' || newAW.Type__c == 'DnD and/or Penalty Fees Missing') ? spotFMCRTId : '') : '';
                        
                    }
                }
            }
        }Catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Agent_Workflow__c', 'AgentWorkflowFieldPopulator.updateWorkflowRecordType', new list<Exception>{ex});  
        }
    }
    
    /** 
    * @description | create feed item
    * @param agentWorkflowListForFeed accepts list of Agent_Workflow__c
    */
    public static void createFeedItem(List<Agent_Workflow__c> agentWorkflowListForFeed){
        List<FeedItemUtility.FeedItemWrapper> feedItemWrapList = new List<FeedItemUtility.FeedItemWrapper>();
        for(Agent_Workflow__c aw : agentWorkflowListForFeed){
            FeedItemUtility.FeedItemWrapper feedWrap = new FeedItemUtility.FeedItemWrapper(aw.Id, aw.Case_ID__c, 'Agent Workflow');
            feedItemWrapList.add(feedWrap);
        }
        
        if(!feedItemWrapList.isEmpty()){
            FeedItemUtility.createFeedItem(feedItemWrapList);
        }
    }
}