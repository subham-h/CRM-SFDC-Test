/*
*        
* Revision  Ref Number  Date      Owner            Description
* --------  ----------  -----------    -------------------      -----------
* 1.0    SFSE-7380  18-Nov-2021    Neha@TCS          Code created
* 2.0    SFSE-7837  16-Feb-2022    Kiran@Maersk        Fix issue with Payout Curve threshold kicking
* 3.0       SFSE-8223  04-Apr-2022    Meghana@ust          Fix issue to recalculate Payout % when Performance is changed to negative.
*/
public class SIPMeasureUtility {

    public static void calculatePayoutPercentforSipMeasure(Map<Id, SIP_Measure__c> newMap,List<SIP_Measure__c> lstsipMeasure, Map<Id, SIP_Participant__c> sipParticipantMap,Map<Id, List<SIP_Payout_Curve__c>> sipKPIPayoutCurveListMap ){        
           
        for(SIP_Measure__c sipmeasure : lstsipMeasure){            
            //if(sipmeasure.Target__c > 0 && (sipmeasure.System_Actual__c > 0  || sipmeasure.Override_Actual__c >0 )){
                if(sipmeasure.Performance_Percent__c <= 0){ //If Performance % is 0% , Payout % is 0 and ‘Applicable Payout Curve’ = blank . 
                    sipmeasure.Payout_Percent__c = 0;
                    sipmeasure.Applicable_Payout_Curve__c = null;
                }else{                    
                    
                    if(sipKPIPayoutCurveListMap.containsKey(sipmeasure.SIP_KPI__c) && sipKPIPayoutCurveListMap.get(sipmeasure.SIP_KPI__c) !=null && sipKPIPayoutCurveListMap.get(sipmeasure.SIP_KPI__c).size()>0){
                        SIP_Payout_Curve__c resultSIPPayoutCurve = null;                            
                        SIP_Participant__c sipParticipantObj = sipParticipantMap.get(sipmeasure.SIP_Participant__c);
                                                
                        List<SIP_Payout_Curve__c> filteredSipPayoutCurveList = new List<SIP_Payout_Curve__c>(); // list to store payout curve with brand
                        List<SIP_Payout_Curve__c> filteredSipPayoutCurveListWithNullBrand = new List<SIP_Payout_Curve__c>(); // list to store payout curve without brand 
                        // Check the necessary condition to get the correct Payout cureve record
                        List<SIP_Payout_Curve__c> listPayoutCurve = sipKPIPayoutCurveListMap.get(sipmeasure.SIP_KPI__c);
                        for(SIP_Payout_Curve__c rec : listPayoutCurve){                        
                                if(rec.Effective_Period_Year__c == sipParticipantObj.Year__c && 
                                String.valueOf(rec.Effective_Period_Quarter__c).contains(sipmeasure.Applicable_Period__c)){
                                    if(String.isNotBlank(rec.Brand__c) && rec.Brand__c == sipParticipantObj.Brand__c){
                                        filteredSipPayoutCurveList.add(rec);                                        
                                    }else if(String.isBlank(rec.Brand__c)){                                     
                                        filteredSipPayoutCurveListWithNullBrand.add(rec);                                        
                                    }
                                }
                        }                        
                        if(filteredSipPayoutCurveList != null && filteredSipPayoutCurveList.size() >0){
                            //call method to filter result where brand is not null                            
                            resultSIPPayoutCurve = getResultSIPPayoutCurve(filteredSipPayoutCurveList,sipParticipantObj);
                        }

                        // if no result found--> Check in filteredSipPayoutCurveListWithNullBrand
                        if(resultSIPPayoutCurve== null){                            
                            //call method to filter result where brand is  null
                            resultSIPPayoutCurve = getResultSIPPayoutCurve(filteredSipPayoutCurveListWithNullBrand,sipParticipantObj);
                        }                        
                        if(resultSIPPayoutCurve != null){
                            if(sipmeasure.Performance_Percent__c < resultSIPPayoutCurve.Threshold_Performance_Percent__c){
                                sipmeasure.Payout_Percent__c = 0;
                                sipmeasure.Applicable_Payout_Curve__c = resultSIPPayoutCurve.id;
                            }else if(sipmeasure.Performance_Percent__c >= resultSIPPayoutCurve.Cap_Performance_Percent__c){
                                sipmeasure.Payout_Percent__c = resultSIPPayoutCurve.Cap_Payout_Percent__c;
                                sipmeasure.Applicable_Payout_Curve__c = resultSIPPayoutCurve.id;
                            }else{
                                boolean recordNotfound = true;
                                for(SIP_Payout_Curve_Detail__c filterpayoutcurvedetailRec : resultSIPPayoutCurve.Payout_Curve_Detail__r){
                                    if(filterpayoutcurvedetailRec.Performance_Percent__c == sipmeasure.Performance_Percent__c){
                                        sipmeasure.Payout_Percent__c = filterpayoutcurvedetailRec.Payout_Percent__c;
                                        sipmeasure.Applicable_Payout_Curve__c = filterpayoutcurvedetailRec.SIP_Payout_Curve__c;
                                        recordNotfound = false;                                     
                                        break;
                                    }
                                }

                                if(recordNotfound){
                                    sipmeasure.Payout_Percent__c = 0;
                                    sipmeasure.Applicable_Payout_Curve__c = null;
                                }
                            }
                        }
                        else{
                            sipmeasure.Payout_Percent__c = 0;
                            sipmeasure.Applicable_Payout_Curve__c = null;
                        }
                    }else{
                        sipmeasure.Payout_Percent__c = 0;
                        sipmeasure.Applicable_Payout_Curve__c = null;
                    }                    
                //}
           } 
           
        }
        
    }
    // Generic method to get the Payout curve 
    public static SIP_Payout_Curve__c getResultSIPPayoutCurve(List<SIP_Payout_Curve__c> filteredSipPayoutCurveList,SIP_Participant__c sipParticipantObj){
        SIP_Payout_Curve__c resultSIPPayoutCurve = null;  

        if(filteredSipPayoutCurveList.size() == 1){
            resultSIPPayoutCurve = filteredSipPayoutCurveList[0];
        }else{
            for(SIP_Payout_Curve__c filterRec : filteredSipPayoutCurveList){
                boolean suitablePayoutCurve = false; // boolean to get the correct payout curve record
          
                if (filterRec.SIP_Payout_Curve_BDA__r != null && filterRec.SIP_Payout_Curve_BDA__r.size() > 0 ){
                    for(SIP_Payout_Curve_BDA__c payoutBDAObj : filterRec.SIP_Payout_Curve_BDA__r){
    
                        if(payoutBDAObj.BDA__c == sipParticipantObj.Area__c){
                            suitablePayoutCurve = true;
                        }else if(payoutBDAObj.BDA__c == sipParticipantObj.Region__c){
                            suitablePayoutCurve = true;                                                
                        }else if(filterRec.Geographical_Validity__c== 'Global'){
                            suitablePayoutCurve = true;
                        }
                    }
                } else {
                    if(filterRec.Geographical_Validity__c== 'Global'){
                            suitablePayoutCurve = true;
                    }
                }
               
                if(suitablePayoutCurve){
                    resultSIPPayoutCurve = filterRec;
                }
            }
        }
        return resultSIPPayoutCurve;
        
    }

}