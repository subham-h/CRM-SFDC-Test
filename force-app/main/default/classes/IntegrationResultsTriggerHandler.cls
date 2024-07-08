/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Integration Results trigger.
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-8789   22-Sept-2023  Shahanawaz@Maersk      Trigger Handler on Integration Results Object
 * 
*/
public class IntegrationResultsTriggerHandler extends TriggerHandler{
    
    public map<Id, Integration_Results__c> newMap;
    public map<Id, Integration_Results__c> oldMap;
    public IntegrationResultsTriggerHandler() {
        this.newMap = (map<Id, Integration_Results__c>)Trigger.newMap;
        this.oldMap = (map<Id, Integration_Results__c>)Trigger.oldMap;
    }
    
    public override void onAfterInsert(){
        IntegrationResultsTriggerHelper.handleFutureCalls(Trigger.new);
    }
    
}