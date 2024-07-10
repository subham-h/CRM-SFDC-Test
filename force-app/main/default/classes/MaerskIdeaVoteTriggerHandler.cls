public class MaerskIdeaVoteTriggerHandler extends TriggerHandler {
    public map<Id, Maersk_Idea_Vote__c> newMap;
    public map<Id, Maersk_Idea_Vote__c> oldMap;
    public MaerskIdeaVoteTriggerHandler() {
        this.newMap = (map<Id, Maersk_Idea_Vote__c>)Trigger.newMap;
        this.oldMap = (map<Id, Maersk_Idea_Vote__c>)Trigger.oldMap; 
    }
    
    public MaerskIdeaVoteRecordSelector IdeaVoteRecordSelector;
    public override void getRecordSelector() {
        IdeaVoteRecordSelector = new MaerskIdeaVoteRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    
    public override void onBeforeDelete() {
        MaerskIdeaVoteValidator.DisplayErrorOnMaerskIdeaVote(IdeaVoteRecordSelector.lstIdeaVote);
    }

    public override void onBeforeInsert() {
        MaerskIdeaVoteValidator.DisplayErrorOnVoteInsert(Trigger.New,IdeaVoteRecordSelector.InsIdeaVote);
    }
}