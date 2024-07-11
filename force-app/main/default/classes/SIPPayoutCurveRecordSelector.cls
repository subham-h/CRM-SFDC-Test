/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
* 2.0		SFSE-10354  23-Feb-2023		Jothsana@Maersk				code updated to insert related SIP Payout Curve Detail Records on insert/update of SIP Payout Curve Records
*/

public class SIPPayoutCurveRecordSelector implements RecordSelector {
    
    public TriggerHandler sipPayoutCurveTriggerHandler;
    public list<SIP_Payout_Curve__c> lstDupCheck_ActiveGlobalPayoutCurves = new list<SIP_Payout_Curve__c>();
    public list<SIP_Payout_Curve__c> lstPayoutCurveRec = new list<SIP_Payout_Curve__c>(); 
    Data_Load_Settings__mdt dataloadSetting = Data_Load_Settings__mdt.getInstance('SIP_Payout_CurveForcePayoutRecalculation');
    
    public SipPayoutCurveRecordSelector ( list<SIP_Payout_Curve__c> lstNewRecords, map<Id, SIP_Payout_Curve__c> mapOldRecords, TriggerHandler payoutCurveTriggerHandler) {
        
        this.sipPayoutCurveTriggerHandler = payoutCurveTriggerHandler;
        this.selectRecords(lstNewRecords, mapOldRecords);
        
        if (Test.isRunningTest())
            getRelatedRecords(lstNewRecords);
    }
    
    public void selectRecords(list<SIP_Payout_Curve__c> lstNewRecords, map<Id, sObject> mapOldRecords){
        SIP_Payout_Curve__c oldRec;
        SIP_Payout_Curve__c oldRec1;
        
        if( Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )){
            
            for(SIP_Payout_Curve__c rec : lstNewRecords) {
                if (Trigger.isUpdate )
                    oldRec = (SIP_Payout_Curve__c) mapOldRecords.get(rec.Id);
                
                if ((Trigger.isInsert || rec.SIP_Kpi__c != oldRec.SIP_Kpi__c || rec.Brand__c != oldRec.Brand__c || rec.Active__c != oldRec.Active__c
                     || rec.Geographical_Validity__c != oldrec.Geographical_Validity__c || rec.Effective_Period_Year__c != oldRec.Effective_Period_Year__c
                     || rec.Effective_Period_Quarter__c  != oldRec.Effective_Period_Quarter__c )
                    && rec.Geographical_Validity__c == 'Global' && rec.Active__c == true){
                        
                        lstDupCheck_ActiveGlobalPayoutCurves.add(rec);
                    }
            }
        }    
        
        if( Trigger.isAfter && ( Trigger.isInsert || Trigger.isUpdate )){
            
            for(SIP_Payout_Curve__c rec1 : lstNewRecords) {
                if (Trigger.isUpdate )
                    oldRec1 = (SIP_Payout_Curve__c) mapOldRecords.get(rec1.Id);
                
                if ((Trigger.isInsert || rec1.Threshold_Performance_Percent__c != oldRec1.Threshold_Performance_Percent__c || rec1.Threshold_Payout_Percent__c != oldRec1.Threshold_Payout_Percent__c || rec1.Target_Performance_Percent__c != oldRec1.Target_Performance_Percent__c
                     || rec1.Target_Payout_Percent__c != oldRec1.Target_Payout_Percent__c || rec1.Excellence_Performance_Percent__c != oldRec1.Excellence_Performance_Percent__c || rec1.Excellence_Payout_Percent__c != oldRec1.Excellence_Payout_Percent__c
                     || rec1.Cap_Performance_Percent__c != oldRec1.Cap_Performance_Percent__c || rec1.Cap_Payout_Percent__c != oldRec1.Cap_Payout_Percent__c || dataloadSetting.Value__c.equalsIgnorecase('true')) && rec1.Active__c == true){
                         
                         lstPayoutCurveRec.add(rec1);
                     }
            }
        }
        
    }
    public void getRelatedRecords( list<SIP_Payout_Curve__c> lstNewRecords){
        
    }
    
}