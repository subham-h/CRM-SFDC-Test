/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFSE-7819   16-11-2022  Bharti.Rana@maersk     Logic to validate that only internal stakeholder can be the owner of the action       	 
*/


public class ActionRecordSelector {
    private TriggerHandler actTriggerHandler; 
       public List<Action__c> actionList = new List<Action__c>();
    
    public ActionRecordSelector(list<Action__c> lstAction, map<Id, Action__c> mapOldAction, ActionTriggerHandler actTriggerHandler) {
        this.actTriggerHandler = actTriggerHandler;
        
        selectRecords(lstAction, mapOldAction);
       
        
    }
    
    public void selectRecords(list<Action__c> lstAction, map<Id, Action__c> mapOldAction) {
        if(lstAction!=null){
            for(Action__c act : lstAction){
                
             if(trigger.isUpdate && trigger.isbefore && mapOldAction.get(act.Id).OwnerId != act.OwnerId){
                    actionList.add(act);
                    
                    
                }
                
            }
        }
        
    }
    
}