/*
*        
* Revision Ref Number  Date            Owner            Description
* -------- ----------  -----------     -------------------      -----------
* 1.0    SFSE-7308    18-Nov-2021      Neha@TCS               Code created
*/

public class SipMeasureTriggerHandler extends TriggerHandler{
    
    public map<Id, SIP_Measure__c> newMap;
    public map<Id, SIP_Measure__c> oldMap;
  
    public SipMeasureTriggerHandler() {
        this.newMap = ( map<Id, SIP_Measure__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, SIP_Measure__c> ) Trigger.oldMap;       
    }
    
     // Get valid records based on criteria
    public SipMeasureRecordSelector sipMeasureRecordSelector;
    public override void getRecordSelector() {
        sipMeasureRecordSelector = new SipMeasureRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(!sipMeasureRecordSelector.sipKPIPayoutCurveListMap.IsEmpty() && !sipMeasureRecordSelector.sipParticipantMap.isEmpty() && !sipMeasureRecordSelector.sipMeasureList.isEmpty()){
            SIPMeasureUtility.calculatePayoutPercentforSipMeasure (this.newMap,sipMeasureRecordSelector.sipMeasureList,sipMeasureRecordSelector.sipParticipantMap,sipMeasureRecordSelector.sipKPIPayoutCurveListMap );
        }    
    }

    public override void onBeforeUpdate() {        
       if(!sipMeasureRecordSelector.sipKPIPayoutCurveListMap.IsEmpty() && !sipMeasureRecordSelector.sipParticipantMap.isEmpty() && !sipMeasureRecordSelector.sipMeasureList.isEmpty()){
            SIPMeasureUtility.calculatePayoutPercentforSipMeasure (this.newMap,sipMeasureRecordSelector.sipMeasureList,sipMeasureRecordSelector.sipParticipantMap,sipMeasureRecordSelector.sipKPIPayoutCurveListMap );
       }        
    }
}