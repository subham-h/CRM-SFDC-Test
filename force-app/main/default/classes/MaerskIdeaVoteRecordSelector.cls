public class MaerskIdeaVoteRecordSelector implements RecordSelector {
    public TriggerHandler maerskideavoteTriggerHandler; 
    string uid = userinfo.getUserId();
    public List<Maersk_Idea_Vote__c> lstIdeaVote = new List<Maersk_Idea_Vote__c>();
    public List<Maersk_Idea_Vote__c> InsIdeaVote = new List<Maersk_Idea_Vote__c>();
    public MaerskIdeaVoteRecordSelector(list<Maersk_Idea_Vote__c> listIdeaVote, map<Id, Maersk_Idea_Vote__c> mapOldIdeaVotes, MaerskIdeaVoteTriggerHandler maerskideavoteTriggerHandler) {
        this.maerskideavoteTriggerHandler= maerskideavoteTriggerHandler;
        selectRecords(listIdeaVote, mapOldIdeaVotes);
    }
                                             
    public void selectRecords(list<Maersk_Idea_Vote__c> listIdeaVote, map<Id, sObject> mapOldIdeaVotes) {
        if(maerskideavoteTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
            if(maerskideavoteTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
                for(Maersk_Idea_Vote__c vote: (List <Maersk_Idea_Vote__c>)mapOldIdeaVotes.values()){
                    if(vote.createdbyId!=uid){
                        lstIdeaVote.add(vote);
                    }
                }
            }
        }    
        
        if(maerskideavoteTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
            if(maerskideavoteTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                set<id> mvid = new set<id>();                
                for(Maersk_Idea_Vote__c vote: listIdeaVote){
                    mvid.add(vote.Maersk_Idea__c);
                }
                List<Maersk_Idea_Vote__c> mylist= new List<Maersk_Idea_Vote__c> ();
                if(mvid.size() > 0 ){
                    for(Maersk_Idea_Vote__c v: [select id,name from Maersk_Idea_Vote__c where Maersk_Idea__c IN :mvid AND createdbyId =:uid]){
                        InsIdeaVote.add(v);
                    }
                }                               
            }
        }   
    }
    
    public void getRelatedRecords(list<Maersk_Idea_Vote__c> listIdeaVote) {
    }
}