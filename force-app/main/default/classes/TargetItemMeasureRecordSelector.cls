/*
*  User Story       Date        Developer       Functionality
*  SFSE-11420       30/08/2023  Anjali          Created
*  SFSE-10711       05/09/2023  Aditi           Create Sales Target Item Measure records with Measure_Dimension__c = 'Target' on after insert of 
                                                Sales Target Item Measure records with Measure_Dimension__c = 'Previous Year Actuals'
   SFSE-13010       18/10/2023  Arpitha J       Applying percent to target dimension records  
   SFSE- 10712      07/11/2023   Bharti         Assigning Sales Rep to target for Measure_Dimension__c = 'Target' on after Insert Of targetMeasure
*/
public class TargetItemMeasureRecordSelector  {
    public List<Target_measure__c> befInsertList = new List<Target_measure__c>();
     public List<Target_measure__c> befUpdateList = new List<Target_measure__c>();
    //SFSE-10711
    public List<Target_measure__c> afterInsertList = new List<Target_measure__c>();
    public List<Target_measure__c> afterUpdateList = new List<Target_measure__c>();
    public Map<Id, Target_measure__c> oldTargetMeasureMap = new Map<Id, Target_measure__c>();
    public list<Target_measure__c> afterInsertMeasureList = new List<Target_measure__c>();
    public List<Target_measure__c> afterUpdateMeasureList = new List<Target_measure__c>();
    
    public TargetItemMeasureRecordSelector(List<Target_measure__c> lstNewTargetMeasures, Map<Id, Target_measure__c> oldTargetMeasures, TriggerHandler ItemMeasureTriggerHandler)
    {
        if(trigger.isInsert || trigger.isUpdate){
            for(Target_measure__c itemMeasure : lstNewTargetMeasures){  
                if(ItemMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
            ItemMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ) 
        {
          System.debug('Entered selector before insert');
          befInsertList.add(itemMeasure);
        }

 

        if (ItemMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && 
            ItemMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ){
                if(itemMeasure.Measure_dimension__c != oldTargetMeasures.get(itemMeasure.id).Measure_dimension__c ||
                  itemMeasure.Measure_type__c != oldTargetMeasures.get(itemMeasure.id).Measure_type__c ||
                  itemMeasure.Party_Type__c != oldTargetMeasures.get(itemMeasure.id).Party_Type__c ||
                  itemMeasure.Credit_Eligible__c != oldTargetMeasures.get(itemMeasure.id).Credit_Eligible__c ){
                    System.debug('Entered selector before update');
                    befUpdateList.add(itemMeasure);
                }    
        }
                //SFSE-10711
                if(ItemMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER
                   && (itemMeasure.Measure_Dimension__c == TargetSettingConstants.PY_ACTUALS || itemMeasure.Measure_Dimension__c == TargetSettingConstants.TARGET)){
                    if (ItemMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)
                        afterInsertList.add(itemMeasure);
                    else if (ItemMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE)
                        oldTargetMeasureMap = oldTargetMeasures;
                        afterUpdateList.add(itemMeasure);
                }
                //10712
                if(ItemMeasureTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    if(ItemMeasureTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                        if( itemMeasure.Measure_Dimension__c == 'Target'){
                           
                        afterInsertMeasureList.add(itemMeasure);
                        }}
                  
                }
            }
        }
    }
}