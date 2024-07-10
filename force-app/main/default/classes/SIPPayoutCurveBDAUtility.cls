/*
*        
* Revision Ref Number  Date            Owner						Description
* -------- ----------  -----------     -------------------			-----------
* 1.0		SFSE-6976	25-Oct-2021		Kiran@Maersk				Code created
*/
public class SIPPayoutCurveBDAUtility {
    
    public static void sipPayoutCurveBDADuplicateCheck(List<SIP_Payout_Curve_BDA__c> lstSIPPayoutCurveBDA, Map<Id, SIP_Payout_Curve__c> mapPayoutCurve, String errorMessage){
        Set<Id> sipKPIIds = new Set<Id>();
        Set<Id> bdaIds = new Set<Id>();
        String key;
        //Map with key as a unique combination of SIP KPI, Brand, Effective Period Year, Effective Period Quarter and BDA
        //Value as a record.
        Map<String, SIP_Payout_Curve_BDA__c> mapIdToKey = new Map<String, SIP_Payout_Curve_BDA__c>();
        for(SIP_Payout_Curve_BDA__c sipPayoutCurveBDARec : lstSIPPayoutCurveBDA){
            SIP_Payout_Curve__c payoutCurveRec = mapPayoutCurve.get(sipPayoutCurveBDARec.SIP_Payout_Curve__c);
            sipKPIIds.add(payoutCurveRec.SIP_KPI__c);
            bdaIds.add(sipPayoutCurveBDARec.BDA__c);
            key = '';
            if(payoutCurveRec.Effective_Period_Quarter__c.contains('Q1')){
                key = getMapKey(payoutCurveRec, sipPayoutCurveBDARec, 'Q1', false);
                mapIdToKey.put(key, sipPayoutCurveBDARec );
            }
            if(payoutCurveRec.Effective_Period_Quarter__c.contains('Q2')){
                key = getMapKey(payoutCurveRec, sipPayoutCurveBDARec, 'Q2', false);
                mapIdToKey.put(key, sipPayoutCurveBDARec );
            }
            if(payoutCurveRec.Effective_Period_Quarter__c.contains('Q3')){
                key = getMapKey(payoutCurveRec, sipPayoutCurveBDARec, 'Q3', false);
                mapIdToKey.put(key, sipPayoutCurveBDARec );
            }
            if(payoutCurveRec.Effective_Period_Quarter__c.contains('Q4')){
                key = getMapKey(payoutCurveRec, sipPayoutCurveBDARec, 'Q4', false);
                mapIdToKey.put(key, sipPayoutCurveBDARec );
            }
        }
        
        //Getting existed records matches with same SIP KPI and BDA of currect record
        List<SIP_Payout_Curve_BDA__c> listExisitingCurveBDAs = [SELECT Id, SIP_Payout_Curve__c, BDA__c, SIP_Payout_Curve__r.Brand__c, SIP_Payout_Curve__r.SIP_KPI__c, 
                                                                SIP_Payout_Curve__r.Effective_Period_Year__c, SIP_Payout_Curve__r.Effective_Period_Quarter__c 
                                                         		FROM SIP_Payout_Curve_BDA__c 
                                                        		WHERE SIP_Payout_Curve__r.SIP_KPI__c in :sipKPIIds AND BDA__c in :bdaIds AND SIP_Payout_Curve__r.Active__c = true];
        
        for(SIP_Payout_Curve_BDA__c sipPayoutCurveBDARec : listExisitingCurveBDAs){
            key = '';
            if(sipPayoutCurveBDARec.SIP_Payout_Curve__r.Effective_Period_Quarter__c.contains('Q1')){
                key = getMapKey(null, sipPayoutCurveBDARec, 'Q1', true);
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveBDARec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveBDARec.SIP_Payout_Curve__r.Effective_Period_Quarter__c.contains('Q2')){
                key = getMapKey(null, sipPayoutCurveBDARec, 'Q2', true);
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveBDARec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveBDARec.SIP_Payout_Curve__r.Effective_Period_Quarter__c.contains('Q3')){
                key = getMapKey(null, sipPayoutCurveBDARec, 'Q3', true);
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveBDARec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
            if(sipPayoutCurveBDARec.SIP_Payout_Curve__r.Effective_Period_Quarter__c.contains('Q4')){
                key = getMapKey(null, sipPayoutCurveBDARec, 'Q4', true);
                //Checking if we have existed record with same combination
                if(mapIdToKey.containsKey(key) && mapIdToKey.get(key).Id != sipPayoutCurveBDARec.Id){
                    mapIdToKey.get(key).addError(errorMessage);
                }
            }
        }
    }
    
    public static String getMapKey(SIP_Payout_Curve__c payoutCurveRec, SIP_Payout_Curve_BDA__c sipPayoutCurveBDARec, String quarter, Boolean existedRecordsCheck){
        String key;
        if(!existedRecordsCheck){
            key = payoutCurveRec.SIP_KPI__c +'_'
            + payoutCurveRec.Brand__c +'_'
            + payoutCurveRec.Effective_Period_Year__c +'_'
            + quarter +'_'
            + sipPayoutCurveBDARec.BDA__c;
        }else{
            key = sipPayoutCurveBDARec.SIP_Payout_Curve__r.SIP_KPI__c +'_'
                + sipPayoutCurveBDARec.SIP_Payout_Curve__r.Brand__c +'_'
                + sipPayoutCurveBDARec.SIP_Payout_Curve__r.Effective_Period_Year__c + '_'
                + quarter +'_'
                + sipPayoutCurveBDARec.BDA__c;
        }
        return key;
    }

}