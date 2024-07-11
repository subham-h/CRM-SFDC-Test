public class Batch_UpdateShareRecordsQueueable implements Queueable{
    
    public List<Target_Item__Share> listIncomingTargetItem;
    public Map<String, Set<Id>> mapUserIdByApprovalKey;

    public Batch_UpdateShareRecordsQueueable( List<Target_Item__Share> listIncomingTargetItem) {

       this.listIncomingTargetItem = listIncomingTargetItem;
        //this.mapUserIdByApprovalKey = mapUserIdByApprovalKey;

    }
    
    public void execute(QueueableContext qc) {  
        List<Target_Item__Share> lstItemShare = new List<Target_Item__Share>();
        for(Target_Item__Share shareRec : listIncomingTargetItem){
            shareRec.AccessLevel = 'Read';
            lstItemShare.add(shareRec);
        }
        if(!lstItemShare.isEmpty()){
            Database.SaveResult[] listSaveResult = Database.update(lstItemShare, false);
            ErrorLogger.writeErrors('SFDC', 'Item Sharing Update', 'Batch_UpdateShareRecords', listSaveResult, lstItemShare);
        }
    }

}