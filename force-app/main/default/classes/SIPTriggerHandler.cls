/*
 * Author   : Meghana.Gupta@UST
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on SIP trigger.
 * 
 * Revision Ref Number      Date        Owner                Description
 * -------- ----------   -----------  -------------------   -----------
 * 1.0      #PR-0089     18-Apr-2016   Meghana.Gupta@UST   Created for implementing CBO (Centralized By Org) trigger architecture.
 * 
 */
 
public class SIPTriggerHandler extends TriggerHandler {
  
    public Map<Id, SIP__c> newMap;
    public Map<Id, SIP__c> oldMap;
      
    public SIPTriggerHandler() {
        
        this.newMap = ( map<Id, SIP__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, SIP__c> ) Trigger.oldMap; 
        
    }
    
    public override void onBeforeInsert() {
        
        SIP_Utilities.updatePayoutPercent ( Trigger.new , this.oldMap, Trigger.isInsert );
    
    }

    public override void onBeforeUpdate() {
        
        SIP_Utilities.updatePayoutPercent ( Trigger.new , this.oldMap, Trigger.isInsert );
        
    }

}