public class UpdateOpportunityUnlock implements Queueable{
	private List<Opportunity> Oppid;
    
    public UpdateOpportunityUnlock(List<Opportunity> records) {
        this.Oppid = records;
       
    }
    public void execute(QueueableContext context) {
       System.debug('opportunity with Oppid: ' + Oppid);
        Approval.UnlockResult[] unlockedRersult = Approval.unlock(Oppid,false);
        for(Approval.UnlockResult lr : unlockedRersult) { 
         if (lr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully unlocked opportunity with ID: ' + lr.getId());
        
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : lr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('opportunity fields that affected this error: ' + err.getFields());
            }
        }
       }
      //  update Oppid;
    }
}