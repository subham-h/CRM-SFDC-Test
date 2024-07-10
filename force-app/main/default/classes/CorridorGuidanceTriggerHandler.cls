/*
 * Author   : kishore.dupam@UST-Global.com
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Corridor Guidance trigger.
 * 
 * Revision Ref Number    Date            Owner                          Description
 * -------- ----------   -----------  -------------------              --------------------------------------------------------
 * 1.0      RQ-003402   20-Jul-2016     kishore.dupam@ust-global.com   Code created
 ** 
 */
 
public class CorridorGuidanceTriggerHandler extends TriggerHandler {
  
    public Map<Id, Corridor_Guidance__c> newMap;
    public Map<Id, Corridor_Guidance__c> oldMap;
    
    public CorridorGuidanceTriggerHandler() {
        
        this.newMap = ( map<Id, Corridor_Guidance__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Corridor_Guidance__c> ) Trigger.oldMap; 
        
    }
    
    public override void onBeforeInsert() {
        
       
    }

    public override void onBeforeUpdate() {
        
       
    }

    public override void onAfterInsert() {
    
        CorridorGuidanceUtilities.populateTradeGuidanceId ( newMap.values() ); 
        
    }
    
    public override void onAfterUpdate() {
        
        CorridorGuidanceUtilities.populateTradeGuidanceId ( newMap.values() );
         
    }
    
    public override void onAfterDelete() {
    
        CorridorGuidanceUtilities.deleteTradeGuidanceId( oldMap );  

     }
     
}