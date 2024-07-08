/*
 *        
 * Revision Ref Number  Date            Owner            Description
 * -------- ----------  -----------     -------------------      -----------
 * 1.0    SFSE-7308  18-Nov-2021       Neha@TCS              Code created
 * 2.0    SFSE-8206  06-Apr-2022       Neha@TCS              include metadata to force update payout
 * 2.1    SFSE-8318   20-Apr-2022     Meghana@UST       Recalculate Payout% if Override Status is modified
*/

public class SIPMeasureRecordSelector implements RecordSelector {
    
    public TriggerHandler sipmeasureTriggerHandler;
    public Map<Id, List<SIP_Payout_Curve__c>> sipKPIPayoutCurveListMap = new Map<Id, List<SIP_Payout_Curve__c>>();
    public list<SIP_Measure__c> sipMeasureList = new list<SIP_Measure__c> ();
    public Map<Id, SIP_Participant__c> sipParticipantMap = new Map<Id, SIP_Participant__c> ();
    Data_Load_Settings__mdt dataloadSetting = Data_Load_Settings__mdt.getInstance('SIP_Measure_ForcePayoutRecalculation');
    
    public SIPMeasureRecordSelector( list<SIP_Measure__c> lstNewRecords, map<Id, SIP_Measure__c> mapOldRecords, TriggerHandler sipmeasureTriggerHandler) {        
        this.sipmeasureTriggerHandler = sipmeasureTriggerHandler;
        this.selectRecords(lstNewRecords,mapOldRecords);
    }
    
    public void selectRecords(list<SIP_Measure__c> lstNewRecords, map<Id, sObject> mapOldRecords){           
            if( Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )){
                if(Trigger.isInsert){
                    for(SIP_Measure__c res : lstNewRecords){
                        if(res.Target__c > 0 &&  (res.System_Actual__c >0 || res.Override_Actual__c >0)){
                            sipMeasureList.add(res); // to check if these values are greater than zero for insert
                        }
                    }
                }else if(Trigger.isUpdate){ // to check if target or actuals are updated
                    for(SIP_Measure__c res : lstNewRecords){
                        SIP_Measure__c recOld = (SIP_Measure__c)mapOldRecords.get(res.Id);                        
                        if(res.Target__c != recOld.Target__c || res.System_Actual__c != recOld.System_Actual__c || res.Override_Actual__c != recOld.Override_Actual__c 
                           || dataloadSetting.Value__c.equalsIgnorecase('true') || res.Override_Status__c != recOld.Override_Status__c ){                           
                            sipMeasureList.add(res);
                        }
                    }
                }
                Set<Id> sipKpiIds = new Set<Id>();
                Set<Id> sipParticipantIds = new Set<Id>();
                
                for(SIP_Measure__c rec : sipMeasureList){
                    sipKpiIds.add(rec.SIP_KPI__c);
                    sipParticipantIds.add(rec.SIP_Participant__c);
                }
                //get all the SIP Measure  data with related object fileds
                sipParticipantMap = new Map<Id, SIP_Participant__c>([Select id, Name ,Year__c, Brand__c,Area__c,Region__c  from SIP_Participant__c where Id in :sipParticipantIds ]);
                
                // Get the active payout curve with aassociated SIP KPI
                List<SIP_Payout_Curve__c> listPayoutCurve = [ select id,Name,SIP_KPI__c, Effective_Period_Year__c , Effective_Period_Quarter__c,
                Brand__c , Threshold_Payout_Percent__c, Threshold_Performance_Percent__c,Cap_Performance_Percent__c,Cap_Payout_Percent__c, Geographical_Validity__c,(select id , name, BDA__c, BDA__r.Name  from SIP_Payout_Curve_BDA__r ) , (Select id , name, SIP_Payout_Curve__c, Payout_Percent__c, Performance_Percent__c from Payout_Curve_Detail__r) from SIP_Payout_Curve__c  where SIP_KPI__r.id in :sipKpiIds and Active__c =true];

                for(SIP_Payout_Curve__c rec : listPayoutCurve){
                    if(sipKPIPayoutCurveListMap.containsKey(rec.SIP_KPI__c)){
                        List<SIP_Payout_Curve__c> sipPaymentList = sipKPIPayoutCurveListMap.get(rec.SIP_KPI__c);
                        sipPaymentList.add(rec); 
                        sipKPIPayoutCurveListMap.put(rec.SIP_KPI__c, sipPaymentList);
                    }else{
                        sipKPIPayoutCurveListMap.put(rec.SIP_KPI__c, new List<SIP_Payout_Curve__c> {rec});
                    }
                }                
            }    
    }    
    public void getRelatedRecords( list<SIP_Measure__c> lstNewRecords){
        
    } 
    
}