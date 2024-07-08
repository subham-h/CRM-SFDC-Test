/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      RQ-012405   13-Nov-2019 Neha-TCS                Record selector for OpportunitySplitTrigger
*/
public class OpportunitySplitRecordSelector implements RecordSelector {
    private TriggerHandler trgHandler;   
    public List<Id> oppid= new List<id>(); // List of Opportunities where split records are added
    public Set<Id> splitOwneridSet= new Set<id>();  
    
     public OpportunitySplitRecordSelector(list<OpportunitySplit> lstopportunitySplit, map<Id, OpportunitySplit> mapOldOpportunitySplit, OpportunitySplitTriggerHandler conOpportunitySplitTriggerHandler) {
        
        this.trgHandler = conOpportunitySplitTriggerHandler;        
        selectRecords(lstOpportunitySplit, mapOldOpportunitySplit);
        getRelatedRecords(lstopportunitySplit);
    }
        
    public void selectRecords(list<OpportunitySplit> lstOpportunitySplit, map<Id, sObject> mapOldOpportunitySplit) { 
        OpportunitySplitType recSplitType = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = :Label.Opp_Split_Ocean_LNS_Label];
        Set<Id> setOpportunitiesIDs = new Set<id>();
        // Create set only for custom split type      
        for(OpportunitySplit splitrecordids : lstopportunitySplit ){
            if(String.ValueOf(splitrecordids.SplitTypeId).equals(recSplitType.id)){
                oppid.add(splitrecordids.Opportunityid);
                splitOwneridSet.add(splitrecordids.SplitOwnerId);
            }
            
        }
       
    }

    public void getRelatedRecords(list<OpportunitySplit> lstopportunitySplit) {
            
    }  
}