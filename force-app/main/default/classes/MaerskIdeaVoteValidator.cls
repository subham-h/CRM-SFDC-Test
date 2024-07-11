public class MaerskIdeaVoteValidator{

    //Cannot delete others vote
    public static void DisplayErrorOnMaerskIdeaVote(list<Maersk_Idea_Vote__c> lstIdeaVote){
        for (Maersk_Idea_Vote__c vote: lstIdeaVote){
            vote.addError(Label.CannotDeleteOthersVote);
         }
    }
    
    //Cannot vote multiple times from save and Edit button    
    public static void DisplayErrorOnVoteInsert(list<Maersk_Idea_Vote__c> triggernew,list<Maersk_Idea_Vote__c> InsIdeaVote){
        for (Maersk_Idea_Vote__c vote: triggernew){
            if(InsIdeaVote.size()>0){
                vote.addError(Label.AlreadyVoted);
            }
        }
    }
    
    
}