/*
* Queueable class for Merging Cases.
* 
*Version    Date           Owner                                      RQ#           Description
1.0      16-02-2021      ramadevi@ust                               SC-172          Implement Case Merge - Case Merge is done asynchronously with Queueable class        
*/
public class CaseMergeQueueable implements Queueable
{
    public final List<Id> DuplicateCaseIds;
    public final Case ParentCase;
    public CaseMergeQueueable(List<Id> DuplicateCaseIds,Case ParentCase)
    {
        this.DuplicateCaseIds = DuplicateCaseIds;
        this.ParentCase = ParentCase;
    }
    public void execute(QueueableContext context)
    {         
        
        try{
            // Do Case Merge with first 2 Duplicate Cases and chain the next cases 
            if(DuplicateCaseIds.size() > 2){
                List<Id> dupCaseIdsToChain = new List<Id>();
                List<Id> dupCaseIds = new List<Id>();
                for(Id cId : DuplicateCaseIds){
                    if(DuplicateCaseIds.indexof(cId) == 0 ||DuplicateCaseIds.indexof(cId) == 1) {
                        dupCaseIds.add(cId);
                    } else {
                        dupCaseIdsToChain.add(cId);
                    }
                    
                }        
                
                system.debug('dupCaseIds  ####'+dupCaseIds);
                system.debug('dupCaseIdsToChain ####'+dupCaseIdsToChain);
                
                TriggerExecutionController.skipCaseTrigger(true);
                List<Database.MergeResult>  mergeresults = Database.Merge(ParentCase,dupCaseIds,false);
                TriggerExecutionController.skipCaseTrigger(false);
                system.debug('mergeresults ###'+mergeresults);
                
                
                System.enqueueJob(new CaseMergeQueueable(dupCaseIdsToChain,ParentCase));
            } else {
                TriggerExecutionController.skipCaseTrigger(true);
                List<Database.MergeResult>  mergeresults = Database.Merge(ParentCase,DuplicateCaseIds,false);
                TriggerExecutionController.skipCaseTrigger(false);
                system.debug('mergeresults ###'+mergeresults);
            }
        } 
        catch(Exception ex){
            ErrorLogger.writeError('SFDC', 'Case', 'CaseMergeQueueable.execute(mergeresults)', ex.getTypeName(), ex.getMessage(), ''); 
                
        }
        
    }
}