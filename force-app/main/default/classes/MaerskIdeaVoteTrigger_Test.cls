@isTest

public class MaerskIdeaVoteTrigger_Test {
    static testMethod void VoteCheck() {
        List<Maersk_Idea_Vote__c> lstVote= new list<Maersk_Idea_Vote__c>();
        Maersk_Idea__c maerskidea = TestDataFactoryHelper.maerskIdeaCreation();
        Maersk_Idea_Vote__c mv = new Maersk_Idea_Vote__c();
        mv.Maersk_Idea__c=maerskidea.Id;
        lstVote.add(mv);
        insert lstVote;    
        MaerskIdeaVoteValidator.DisplayErrorOnMaerskIdeaVote(lstVote);    
        delete lstVote;
    }
}