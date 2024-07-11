/*
 * Author   : Ragu@UST
 * Purpose  : This class is centralized controller for all the triggers; it is one of the component in Central Control Layer.
 *			All object specific triggers will delegates it control to run() method in this class, TriggerHandler then validate the current execution and dispatches the events 
 *			to corresponding <<Object>>TriggerHandler if that particular event method is overridden.
 * 
 * Revision Ref Number	Date        Owner                   Description
 * -------- ---------- 	-----------	------------------- 	-----------
 * 1.0		RQ-002633	10-Feb-2016	Ragu@UST				Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0   	RQ-004145   21-Jul-2016 Jiji@UST               	To skip current trigger for current user based on Trigger Execution Controller custom setting 
 * 
 * 
 */

public virtual class TriggerHandler {
	
	public enum TriggerType {ISBEFORE, ISAFTER}
	public enum TriggerEvent {ISINSERT, ISUPDATE, ISDELETE, ISUNDELETE}
	public TriggerType trigType;
	public TriggerEvent trigEvent;
	
	public void run() {
		if(!validateRun()) {
			return;
		}
	
		// Dispatch controls to the corresponding handler methods
		if(Trigger.isBefore) {
			trigType = TriggerType.ISBEFORE;
			if(Trigger.isInsert) {
				trigEvent = TriggerEvent.ISINSERT;
				this.getRecordSelector();
				this.onBeforeInsert();
			}
			else if(Trigger.isUpdate) {
				trigEvent = TriggerEvent.ISUPDATE;
				this.getRecordSelector();
				this.onBeforeUpdate();
			}
			else if(Trigger.isDelete) {
				trigEvent = TriggerEvent.ISDELETE;
				this.getRecordSelector();
				this.onBeforeDelete();
			}
		}
		else if(Trigger.isAfter) {
			trigType = TriggerType.ISAFTER;
			if(Trigger.isInsert) {
				trigEvent = TriggerEvent.ISINSERT;
				this.getRecordSelector();
				this.onAfterInsert();
			}
			else if(Trigger.isUpdate) {
				trigEvent = TriggerEvent.ISUPDATE;
				this.getRecordSelector();
				this.onAfterUpdate();
			}
			else if(Trigger.isDelete) {
				trigEvent = TriggerEvent.ISDELETE;
				this.getRecordSelector();
				this.onAfterDelete();
			}
			else if(Trigger.isUndelete) {
				trigEvent = TriggerEvent.ISUNDELETE;
				this.getRecordSelector();
				this.onAfterUndelete();
			}
		}
	}

	// Validate and decides whether trigger should continue to run or not
    private Boolean validateRun() {
        if(!Trigger.isExecuting) {
            throw new NotATriggerContextException('TriggerHandler called outside of the Trigger context.');
        }
        
        if(TriggerExecutionController.skipAllTriggers()) {
            return false;
        }
        
        // v2.0 - Start
        String sObjectName;
        if(Trigger.isInsert || Trigger.isUpdate) {
            sObjectName = String.ValueOf(trigger.new[0].getSObjectType());
        }
        else if(Trigger.isDelete){
            sObjectName = String.ValueOf(trigger.old[0].getSObjectType()); 
        }
        
        if(TriggerExecutionController.skipTriggerOnObject(sObjectName)) {
            return false;
        }
        // v2.0 - End
        
        return true;
    }
	
	// Virtula empty methods for all possible events
	protected virtual void getRecordSelector(){}
	protected virtual void onBeforeInsert(){}
	protected virtual void onBeforeUpdate(){}
	protected virtual void onBeforeDelete(){}
	protected virtual void onAfterInsert(){}
	protected virtual void onAfterUpdate(){}
	protected virtual void onAfterDelete(){}
	protected virtual void onAfterUndelete(){}
	
	// Custom Exceptions
	public class NotATriggerContextException extends Exception {}

}