/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
* 2.0		SFSE-10354  23-Feb-2023		Jothsana@Maersk				code updated to insert related SIP Payout Curve Detail Records on insert/update of SIP Payout Curve Records
*/

public class SipPayoutCurveTriggerHandler extends TriggerHandler{
    
    public map<Id, SIP_Payout_Curve__c> newMap;
    public map<Id, SIP_Payout_Curve__c> oldMap;
    public SipPayoutCurveTriggerHandler() {
        this.newMap = ( map<Id, SIP_Payout_Curve__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, SIP_Payout_Curve__c> ) Trigger.oldMap; 
    }
    
    // Get valid records based on criteria
    public SipPayoutCurveRecordSelector sipPayoutCurveRecordSelector;
    public override void getRecordSelector() {
        sipPayoutCurveRecordSelector = new SipPayoutCurveRecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        
        if(sipPayoutCurveRecordSelector.lstDupCheck_ActiveGlobalPayoutCurves.size() > 0){
            SipPayoutCurveUtility.sipPayoutCurveDuplicateCheck(sipPayoutCurveRecordSelector.lstDupCheck_ActiveGlobalPayoutCurves, Label.SIPPayoutCurveDuplicateError);
        }
        
    }
    
    public override void onBeforeUpdate() {
        
        if(sipPayoutCurveRecordSelector.lstDupCheck_ActiveGlobalPayoutCurves.size() > 0){
            SipPayoutCurveUtility.sipPayoutCurveDuplicateCheck(sipPayoutCurveRecordSelector.lstDupCheck_ActiveGlobalPayoutCurves, Label.SIPPayoutCurveDuplicateError);//SipPayoutCurveUtility.sipPayoutCurveDetailRecordcreate(sipPayoutCurveRecordSelector.lstDupCheck_ActiveGlobalPayoutCurves);
        }
        
    }
    public override void onAfterInsert() {
        
        if(sipPayoutCurveRecordSelector.lstPayoutCurveRec.size() > 0){
           SipPayoutCurveUtility.sipPayoutCurveDetailRecordcreate(sipPayoutCurveRecordSelector.lstPayoutCurveRec);
        }
        
    }
    public override void onAfterUpdate() {
        
        if(sipPayoutCurveRecordSelector.lstPayoutCurveRec.size() > 0){
            SipPayoutCurveUtility.sipPayoutCurveDetailRecordcreate(sipPayoutCurveRecordSelector.lstPayoutCurveRec);  
        }
        
    }
    
}