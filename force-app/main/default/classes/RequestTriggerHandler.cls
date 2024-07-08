/*
 * Author   : Jagadeesan.Sakthivel@UST
 * Purpose  : To create follow records for Account's territory sales owner related to the Request
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------                 -----------
 * 1.0      #RQ-009384   29-Nov-2018  Jagadeesan@ust-global.com       To create follow records for Account's territory sales owner related to the Request
 * 2.0      #RQ-009707   20-Dec-2018  Junaid@ust-global.com           Added logics for update event.
 * 3.0		SFSE-6066	 29-Sep-2021  Kiran@Maersk					  Removing Territory record type references and Territory User association object deprecation
 */
 
public class RequestTriggerHandler extends TriggerHandler{
    public Map<Id, Request__c> newMap;
    public Map<Id, Request__c> oldMap;
    
    public RequestTriggerHandler() {
        this.newMap = ( map<Id, Request__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, Request__c> ) Trigger.oldMap; 
    }
    public RequestRecordSelector reqRecordSelector;
    
    public override void getRecordSelector() {
        if (reqRecordSelector == null){
            reqRecordSelector = new RequestRecordSelector( Trigger.new, this.oldMap, this);
        }
    }
    
    public override void onAfterInsert(){
        
    }
    public override void onAfterUpdate(){
        
    }
}