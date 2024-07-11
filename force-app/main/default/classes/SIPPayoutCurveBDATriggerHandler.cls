/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
*/

public class SIPPayoutCurveBDATriggerHandler extends TriggerHandler{
    
    public map<Id, SIP_Payout_Curve_BDA__c> newMap;
    public map<Id, SIP_Payout_Curve_BDA__c> oldMap;
    public SipPayoutCurveBDATriggerHandler() {
        this.newMap = ( map<Id, SIP_Payout_Curve_BDA__c> ) Trigger.newMap;
        this.oldMap = ( map<Id, SIP_Payout_Curve_BDA__c> ) Trigger.oldMap; 
    }
    
    // Get valid records based on criteria
    public SIPPayoutCurveBDARecordSelector sipPayoutCurveBDARecordSelector;
    public override void getRecordSelector() {
        sipPayoutCurveBDARecordSelector = new SIPPayoutCurveBDARecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(SIPPayoutCurveBDARecordSelector.lstPayoutCurveBDA.size() > 0){
            SIPPayoutCurveBDAUtility.sipPayoutCurveBDADuplicateCheck(SIPPayoutCurveBDARecordSelector.lstPayoutCurveBDA, SIPPayoutCurveBDARecordSelector.mapPayoutCurve, Label.SIPPayoutCurveBDADuplicateError);
        }
    }
    
    public override void onBeforeUpdate() {
        if(SIPPayoutCurveBDARecordSelector.lstPayoutCurveBDA.size() > 0){
            SIPPayoutCurveBDAUtility.sipPayoutCurveBDADuplicateCheck(SIPPayoutCurveBDARecordSelector.lstPayoutCurveBDA, SIPPayoutCurveBDARecordSelector.mapPayoutCurve, Label.SIPPayoutCurveBDADuplicateError);
        }
    }

}