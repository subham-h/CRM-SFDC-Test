/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
*/

public class SIPPayoutCurveBDARecordSelector implements RecordSelector{
    
    public TriggerHandler sipPayoutCurveBDATriggerHandler;
    public list<SIP_Payout_Curve_BDA__c> lstPayoutCurveBDA = new list<SIP_Payout_Curve_BDA__c>();
    public Map<Id, SIP_Payout_Curve__c> mapPayoutCurve;
    
    public SIPPayoutCurveBDARecordSelector ( list<SIP_Payout_Curve_BDA__c> lstNewRecords, map<Id, SIP_Payout_Curve_BDA__c> mapOldRecords, TriggerHandler payoutCurveBDATriggerHandler) {
        
        this.sipPayoutCurveBDATriggerHandler = payoutCurveBDATriggerHandler;
        this.selectRecords(lstNewRecords, mapOldRecords);
        
        if (Test.isRunningTest())
            getRelatedRecords(lstNewRecords);
    }
    
    public void selectRecords(list<SIP_Payout_Curve_BDA__c> lstNewRecords, map<Id, sObject> mapOldRecords){
        SIP_Payout_Curve_BDA__c oldRec;
        
        if( Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )){
            Set<Id> curveIds = new Set<Id>();
            for(SIP_Payout_Curve_BDA__c rec : lstNewRecords){
                curveIds.add(rec.SIP_Payout_Curve__c);
            }
            mapPayoutCurve = new Map<Id, SIP_Payout_Curve__c>([
                SELECT Id, Active__c, SIP_KPI__c, Effective_Period_Year__c, Effective_Period_Quarter__c, Brand__c 
                FROM SIP_Payout_Curve__c
                WHERE Id in :curveIds
            ]);
            for(SIP_Payout_Curve_BDA__c rec : lstNewRecords) {
                if (Trigger.isUpdate )
                    oldRec = (SIP_Payout_Curve_BDA__c) mapOldRecords.get(rec.Id);
                
                if ((Trigger.isInsert || rec.SIP_Payout_Curve__c != oldRec.SIP_Payout_Curve__c || rec.BDA__c != oldRec.BDA__c) 
                   && mapPayoutCurve.get(rec.SIP_Payout_Curve__c).Active__c == true){
                    lstPayoutCurveBDA.add(rec);
                }
            }
        }
    }
    
    public void getRelatedRecords( list<SIP_Payout_Curve_BDA__c> lstNewRecords){
        
    }

}