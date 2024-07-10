/* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   05-09-23    Anjali@maersk           Created
* 
*/
public class BudgetMeasureRecordSelector {
    public List<Budget_measure__c> befInsertList = new List<Budget_measure__c>();
    public List<Budget_measure__c> befUpdateList = new List<Budget_measure__c>();
    public BudgetMeasureRecordSelector(List<Budget_measure__c> lstNewBudgetMeasures, Map<Id, Budget_measure__c> oldBudgetMeasures, TriggerHandler BdgtMeasureTriggerHandler)
     {
       if(trigger.isInsert || trigger.isUpdate){
           for(Budget_measure__c bdgtMeasure : lstNewBudgetMeasures){   
                if(BdgtMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                    BdgtMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ) 
                  {
                     System.debug('Entered selector before insert');
                     befInsertList.add(bdgtMeasure);
                  }
                if (BdgtMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
                    BdgtMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ){
                      if(bdgtMeasure.Measure_dimension__c != oldBudgetMeasures.get(bdgtMeasure.id).Measure_dimension__c ||
                         bdgtMeasure.Measure_type__c != oldBudgetMeasures.get(bdgtMeasure.id).Measure_type__c )
                        {
                            System.debug('Entered selector before update');
                            befUpdateList.add(bdgtMeasure);
                            }    
                    }
                }
            }
        }
}