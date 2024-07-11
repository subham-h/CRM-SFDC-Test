/*
* Author   : Abby 
* Purpose  : Gives abstract view of all the business logic / functionality implemented on Module trigger.
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-004392   21/12/2016  abby.abraham@ust        Code created
* 2.0      RQ-004731   27/01/2016  abby.abraham@ust        Optimised Code
*
*/  

public class ModuleTriggerHandler extends TriggerHandler {

    public map<Id, Module__c> newMap;
    public map<Id, Module__c> oldMap;
    public ModuleTriggerHandler() {
        this.newMap = (map<Id, Module__c>)Trigger.newMap;
        this.oldMap = (map<Id, Module__c>)Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        ModuleFieldPopulator.updateBadgeContentVersionId(Trigger.new);
    }
    
    public override void onBeforeUpdate() {
        ModuleFieldPopulator.updateBadgeContentVersionId(Trigger.new);
    }
    
}