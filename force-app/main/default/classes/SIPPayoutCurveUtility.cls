/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
* 2.0		SFSE-10354  23-Feb-2023		Jothsana@Maersk				code updated to insert related SIP Payout Curve Detail Records on insert/update of SIP Payout Curve Records
*/
public class SIPPayoutCurveUtility {
    
    public static void sipPayoutCurveDuplicateCheck(List<SIP_Payout_Curve__c> lstSIPPayoutCurve, String errorMessage){
        Set<Id> sipKPIIds = new Set<Id>();
        //Map with key as a unique combination of SIP KPI, Brand, Effective Period Year, Effective Period Quarter and Geographical validity
        //Value as a record.
        Map<String, SIP_Payout_Curve__c> mapIdToKey = new Map<String, SIP_Payout_Curve__c>();
        for(SIP_Payout_Curve__c sipPayoutCurveRec : lstSIPPayoutCurve){
            sipKPIIds.add(sipPayoutCurveRec.SIP_KPI__c);
            String key;
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q1')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q1';
                mapIdToKey.put(key, sipPayoutCurveRec );
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q2')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q2';
                mapIdToKey.put(key, sipPayoutCurveRec );
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q3')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q3';
                mapIdToKey.put(key, sipPayoutCurveRec );
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q4')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q4';
                mapIdToKey.put(key, sipPayoutCurveRec );
            }
            
        }
        //Getting existed active payout curve records matches with same SIP KPI and Geographical validity global
        List<SIP_Payout_Curve__c> listExisitingCurves = [SELECT Id, Brand__c, SIP_KPI__c, Active__c, Geographical_Validity__c, Effective_Period_Year__c, Effective_Period_Quarter__c 
                                                         FROM SIP_Payout_Curve__c 
                                                         WHERE SIP_KPI__c in :sipKPIIds AND Geographical_Validity__c = 'Global' AND Active__c = true];
        
        for(SIP_Payout_Curve__c sipPayoutCurveRec : listExisitingCurves){
            String key;
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q1')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q1';
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveRec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q2')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q2';
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveRec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q3')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q3';
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveRec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveRec.Effective_Period_Quarter__c.contains('Q4')){
                key = sipPayoutCurveRec.SIP_KPI__c +'_'
                    + sipPayoutCurveRec.Brand__c +'_'
                    + sipPayoutCurveRec.Effective_Period_Year__c + '_'
                    + sipPayoutCurveRec.Geographical_Validity__c + '_Q4';
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveRec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
        }
    }
    public static void sipPayoutCurveDetailRecordcreate(List<SIP_Payout_Curve__c> lstSIPPayoutCurve){
        //To get related SIP Payout Curve Detail records for updated SIP Payout Curve Record
        
        Set<Id> sipCurveIds = new Set<Id>();
        for(SIP_Payout_Curve__c sipPayoutCurveRec1 : lstSIPPayoutCurve){
            sipCurveIds.add(sipPayoutCurveRec1.id);
        }
        
        list<SIP_Payout_Curve_Detail__c> query = [Select id,name from SIP_Payout_Curve_Detail__c where SIP_Payout_Curve__c IN: sipCurveIds];
            
            if(query!=null){
                try {
                    delete query;//Delete retrieved SIP Payout Curve Detail records
                } catch (DmlException e) {
                    system.debug('DML exception');
                }
            }
        list<SIP_Payout_Curve_Detail__c> SipPayoutCurveDetailrec1 = new list<SIP_Payout_Curve_Detail__c>();
        
        for(SIP_Payout_Curve__c sipPayoutCurveRec : lstSIPPayoutCurve){
         
            decimal count = sipPayoutCurveRec.Threshold_Performance_Percent__c;
            decimal cap = sipPayoutCurveRec.Cap_Performance_Percent__c;
            decimal ThresPayoutPercent = sipPayoutCurveRec.Threshold_Payout_Percent__c;
            decimal TarPayoutPercent = sipPayoutCurveRec.Target_Payout_Percent__c;
            decimal CapPayoutPercent = sipPayoutCurveRec.Excellence_Payout_Percent__c;
            //Incremental Coefficient for Payout%
            decimal Thresholdpayoutpercent = ((sipPayoutCurveRec.Target_Payout_Percent__c - sipPayoutCurveRec.Threshold_Payout_Percent__c)/(sipPayoutCurveRec.Target_Performance_Percent__c - sipPayoutCurveRec.Threshold_Performance_Percent__c))*0.1;
            decimal Targetpayoutpercent = ((sipPayoutCurveRec.Excellence_Payout_Percent__c - sipPayoutCurveRec.Target_Payout_Percent__c)/(sipPayoutCurveRec.Excellence_Performance_Percent__c - sipPayoutCurveRec.Target_Performance_Percent__c))*0.1;
            decimal Excellencepayoutpercent = ((sipPayoutCurveRec.Cap_Payout_Percent__c - sipPayoutCurveRec.Excellence_Payout_Percent__c)/(sipPayoutCurveRec.Cap_Performance_Percent__c - sipPayoutCurveRec.Excellence_Performance_Percent__c))*0.1;
            
            if(count == sipPayoutCurveRec.Threshold_Performance_Percent__c){
                
                SIP_Payout_Curve_Detail__c SipPayoutCurveDetailrec2 = new SIP_Payout_Curve_Detail__c();
                SipPayoutCurveDetailrec2.Payout_Percent__c = ThresPayoutPercent;
                SipPayoutCurveDetailrec2.Payout_Percent__c = SipPayoutCurveDetailrec2.Payout_Percent__c.setScale(1, System.RoundingMode.HALF_UP)+0.000;
                SipPayoutCurveDetailrec2.Performance_Percent__c = count;
                SipPayoutCurveDetailrec2.SIP_Payout_Curve__c = sipPayoutCurveRec.Id;
                
                SipPayoutCurveDetailrec1.add(SipPayoutCurveDetailrec2);
                count+=0.1;
            }
            //Calculation for Threshold Payout%
            while(count <= sipPayoutCurveRec.Target_Performance_Percent__c && count > sipPayoutCurveRec.Threshold_Performance_Percent__c){
               
                SIP_Payout_Curve_Detail__c SipPayoutCurveDetailrecThreshold = new SIP_Payout_Curve_Detail__c();
                SipPayoutCurveDetailrecThreshold.Payout_Percent__c = ThresPayoutPercent + Thresholdpayoutpercent;
                SipPayoutCurveDetailrecThreshold.Payout_Percent__c = SipPayoutCurveDetailrecThreshold.Payout_Percent__c.setScale(1, System.RoundingMode.HALF_UP)+0.000;
                SipPayoutCurveDetailrecThreshold.Performance_Percent__c = count;
                SipPayoutCurveDetailrecThreshold.SIP_Payout_Curve__c = sipPayoutCurveRec.Id;
                SipPayoutCurveDetailrec1.add(SipPayoutCurveDetailrecThreshold); 
                
                count = count+0.1;
                ThresPayoutPercent += Thresholdpayoutpercent; 
            }
            //Calculation for Target Payout%
            while(count <= sipPayoutCurveRec.Excellence_Performance_Percent__c && count > sipPayoutCurveRec.Target_Performance_Percent__c){
                
                SIP_Payout_Curve_Detail__c SipPayoutCurveDetailrecTarget = new SIP_Payout_Curve_Detail__c();
                SipPayoutCurveDetailrecTarget.Payout_Percent__c = TarPayoutPercent + Targetpayoutpercent;
                SipPayoutCurveDetailrecTarget.Payout_Percent__c = SipPayoutCurveDetailrecTarget.Payout_Percent__c.setScale(1, System.RoundingMode.HALF_UP)+0.000;
                SipPayoutCurveDetailrecTarget.Performance_Percent__c = count;
                SipPayoutCurveDetailrecTarget.SIP_Payout_Curve__c = sipPayoutCurveRec.Id;
                SipPayoutCurveDetailrec1.add(SipPayoutCurveDetailrecTarget);
                
                count = count+0.1;
                TarPayoutPercent += Targetpayoutpercent; 
                
            }
            //Calculation for Excellence Payout%
            while(count <= sipPayoutCurveRec.Cap_Performance_Percent__c && count >= sipPayoutCurveRec.Excellence_Performance_Percent__c){
                
                SIP_Payout_Curve_Detail__c SipPayoutCurveDetailrecExc = new SIP_Payout_Curve_Detail__c();
                SipPayoutCurveDetailrecExc.Payout_Percent__c = CapPayoutPercent + Excellencepayoutpercent;
                SipPayoutCurveDetailrecExc.Payout_Percent__c = SipPayoutCurveDetailrecExc.Payout_Percent__c.setScale(1, System.RoundingMode.HALF_UP)+0.000;
                SipPayoutCurveDetailrecExc.Performance_Percent__c = count;
                SipPayoutCurveDetailrecExc.SIP_Payout_Curve__c = sipPayoutCurveRec.Id;
                SipPayoutCurveDetailrec1.add(SipPayoutCurveDetailrecExc);
                
                count = count+0.1;
                CapPayoutPercent += Excellencepayoutpercent; 
                
            }  
        }
        
            Insert SipPayoutCurveDetailrec1; //Inserting related SIP Payout Curve Detail records
    } 
}