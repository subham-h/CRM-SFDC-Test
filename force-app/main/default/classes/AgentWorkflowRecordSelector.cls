/*
* Author   : Avinash@UST
* Purpose  : Centralize the record selection process for Agent Workflow object.
*          Defines the methods which iterate and segregate the Agent Workflow records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      IIP-149     24-08-2020  Avinash@ust            Import Manifest Case - Auto Update
* 2.0      SC-1141     07-10-2020  Sriram@maersk          Update recordtype to spot FMC,owner assignement, Region and GSC
* 3.0      SC-9293     22-12-2023  Shahanawaz@maersk      Create feeditem on parent Case
*/
public class AgentWorkflowRecordSelector implements RecordSelector{
    
    private TriggerHandler awTriggerHandler;
    
    //List to populate recordtypes. Record type needed in order to render the correct lightning record page
    public List<Agent_Workflow__c> listToPopulateRecordTypes = new List<Agent_Workflow__c>();
    
    //To Store related Case record Details
    public Set<Id> setAutoApprovedAWCases = new Set<Id>();
    public Set<Id> setCaseIds = new Set<Id>();
    public Map<Id,Case> mapRelatedCases = new Map<Id,Case>();
    
    //To Store related agent workflow record details
    public Set<Id> setRelatedAW = new Set<Id>();
    public Map<Id,Agent_Workflow__c> mapRelatedAW = new Map<Id,Agent_Workflow__c>(); 
    public List<Agent_Workflow__c> listChildToUpdate = new List<Agent_Workflow__c>();
    
    public List<Agent_Workflow__c> listAutoApprovedAW = new List<Agent_Workflow__c>();
    public List<Agent_Workflow__c> listClosedAW = new List<Agent_Workflow__c>();
    
    public List<Agent_Workflow__c> listSpotFMCRecords = new List<Agent_Workflow__c>();
    public set<string> geoIds = new set<string>();
    public map<Id,Geography__c> agentAndCountryMap = new map<Id,Geography__c>(); 
    
    public List<Agent_Workflow__c> agentWorkflowListForFeed = new List<Agent_Workflow__c>();
    //List for Approval needed
    //public List<Agent_Workflow__c> listApprovalNeededAW = new List<Agent_Workflow__c>();
     
    public AgentWorkflowRecordSelector(list<Agent_Workflow__c> lstAW, map<Id, Agent_Workflow__c> mapOldAW, TriggerHandler awTriggerHandler) {
        this.awTriggerHandler = awTriggerHandler;
        this.selectRecords(lstAW, mapOldAW);
        
        if(lstAW != null) {
            this.getRelatedRecords(lstAW);
        }
        else if(mapOldAW != null) {
            this.getRelatedRecords(mapOldAW.values());
        }
    }

    public void selectRecords(list<Agent_Workflow__c> lstAW, map<Id, sObject> mapOldAW) {
        Id customManifestRTId = StaticFactory.getRecordTypeIdByName('Agent_Workflow__c', Label.Custom_Manifest);
        //Id deliveryOrderRTID = StaticFactory.getRecordTypeIdByName('Agent_Workflow__c', Label.Delivery_Order);
        
        if(lstAW != null){
            for(Agent_Workflow__c newAW : lstAW){
                Agent_Workflow__c oldAW;
                if(mapOldAW != null && !mapOldAW.isEmpty()) {
                    oldAW = (Agent_Workflow__c)mapOldAW.get(newAW.Id);
                    
                    if(oldAW.Case_ID__c != newAW.Case_ID__c){
                        setCaseIds.add(oldAW.Case_ID__c);
                    }
                }
                 // Store CaseId
                if(newAW.Case_ID__c != null) {
                    setCaseIds.add(newAW.Case_ID__c);
                    //SC-9293
                    if(oldAW == null){
                        agentWorkflowListForFeed.add(newAW);
                    }
                }
                
                //Adding workflows to list to populate appropriate record type
                listToPopulateRecordTypes.add(newAW);
                
                //Segregate Workflows basis record type
                if(newAW.RecordTypeId == customManifestRTId){
                    
                    //Populate list of auto-approved agent workflows
                    if(string.isEmpty(newAW.ParentId__c) && newAW.Status__c == 'Approved' && oldAW == null){
                        setAutoApprovedAWCases.add(newAW.Case_ID__c);
                        listAutoApprovedAW.add(newAW);
                    }
                    else if(string.isEmpty(newAW.ParentId__c) && (newAW.Status__c == 'Approved' || newAW.Status__c == 'Rejected') && newAW.Status__c != oldAW.Status__c){//Populate list if closed agent workflows
                        listClosedAW.add(newAW);
                        mapRelatedAW.put(newAW.Id,newAW);
                    }
                }
                /*else if(newAW.RecordTypeId == deliveryOrderRTID){
                    listApprovalNeededAW.add(newAW);
                }*/
                
                
                List<String> typelist = Label.SPOTFMCTypeValues.split(',');
                //add listSpotFMCRecords 2.0 SC-1141 
                if(newAW.Type__c!=null && typelist.contains(newAW.Type__c)){
                    listSpotFMCRecords.add(newAW);
                    if(newAW.Country__c!=null){
                       geoIds.add(newAW.Country__c);
                    }                   
                }
                
            }
        }
    }
    
    //get SPOT_FMC_Country_GSC_Mapping 
    public static map<String, SPOT_FMC_Country_GSC_Mapping__mdt> getCountryGSCMapping() {  
            map<String,SPOT_FMC_Country_GSC_Mapping__mdt> countryGSCMap = new map<String,SPOT_FMC_Country_GSC_Mapping__mdt>();
            for(SPOT_FMC_Country_GSC_Mapping__mdt tsd : [SELECT Id, DeveloperName, Label, Country_Name__c, GEO_ID__c, Queue_Id__c, Queue_Name__c,REGION__c,Sites__c FROM SPOT_FMC_Country_GSC_Mapping__mdt]) {
                String mapKey = tsd.GEO_ID__c;
                countryGSCMap.put(mapKey, tsd);
            }
        return countryGSCMap;
    }
    
    public void getRelatedRecords(list<Agent_Workflow__c> lstAW) {
        getRelatedCases();
        getChildAW();
        getGeGeography();
    }
    
    //Retrieve Geography records
    public void getGeGeography(){
         if(!geoIds.isEmpty()){
            agentAndCountryMap = new Map<Id,Geography__c>([Select Id,GEO_ID__c from Geography__c where Id IN :geoIds]);
        }
    }
    
    //Retrieve related cases
    public void getRelatedCases(){
        if(!setCaseIds.isEmpty()){
            mapRelatedCases = new Map<Id,Case>([Select Id,OwnerId,Status,Resolution_Summary__c from Case where Id IN :setCaseIds]);
        }
    }
    
    //Retrieve child agent workflows
    public void getChildAW(){
        if(!mapRelatedAW.isEmpty()){
            listChildToUpdate = [Select Id,Status__c,Rejection_Reason__c,ParentId__c,Admin_Comments__c FROM Agent_Workflow__c WHERE ParentId__c IN :mapRelatedAW.keySet()];
        }
    }
}