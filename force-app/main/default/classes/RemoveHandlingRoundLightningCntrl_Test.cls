@isTest
public class RemoveHandlingRoundLightningCntrl_Test {
      
    public static testMethod void testRemoveHandlingRound(){
        Boolean responseMessage = false;
        
        Project_Template__c pt = new Project_Template__c(
            Name = 'Test Project Template',
            Handling_Rounds__c = 2
        );
        insert pt; 
        
        Project_Milestones__c pm = new Project_Milestones__c(
            Name = 'Test Project Template - Round 2',
            Project_Template__c = pt.id
        );
        insert pm;
                
        RemoveHandlingRoundLightningCntrl.removeLatestHandlingRoundRecord(pt.Id);
       
    }
}