/*
Description  :   

* version       Date                Owner                                       Description
******************************************************************************************************************************************************
* V1.0          11/03/2016          meghana.gupta@ust-global.com        #PR-0089:Code created for SIP payout calculation
* V2.0          22/11/2016          abby.abraham@ust-global.com         #RQ-004510 : Show Revenue section for the records less than or equal to 2016
* v3.0          30/05/2018          manjunath.c.holekade@maersk.com     RQ-008638 -> Mod-01 - Included payout related performance fields
* v4.0          12-Sep-2018         manjunath.c.holekade@maersk.com     RQ-009077 -> Replaced team performance fields with individual payout
* v5.0          15-Mar-2019         meghana.gupta@ust-global.com        RQ-010223 -> For Quarter from 2019Q2 onwards show temporary message that feature not available
* v6.0          15-Apr-2019         sidhartha@maersk                    RQ-010303 -> Removed all the old codes which was used in vf page
* v6.1          06-May-3019         sidhartha@maersk                    RQ-010681 -> Added Payout Percentage calulation
* v7.0          09-Jan-2019         Neha@TCS                            RQ-012775 -> Modified calculatePayout() to inclue one more parameter for spot volume and necessary changes are made other respective areas
* v8.0     		06-Mar-2020			Meghana@UST							RQ-013156 - Remove references of deprecated fields
------------------------------------------------------------------------------------------------------------------------------------------------------>
*/

public class SIP_CalculatePayoutController {
    
    @AuraEnabled
    public static sipPayoutWrapper initMethod(Id recSIPId){
        
        sipPayoutWrapper sipPayWrap = new sipPayoutWrapper();
        SIP__c recSIP = [ SELECT id, Volume_Payout_Percent__c, Revenue_Payout_Percent__c, Revenue_Growth_VAS_Payout_Percent__c, 
                         E2E_Volume_Payout_Percent__c, Acquisition_Payout_Percent__c, Maersk_Spot_Volume_Payout_Percent__c,
                         E2E_Volume_Actual_FFE__c, Volume_Actual__c, Ocean_Revenue_Actual_USD__c,
                         Maersk_Spot_Volume_Actual_FFE__c,Acquisition_Actual__c,
                         Revenue_Growth_VAS_Actual__c,Revenue_Growth_VAS_Target__c
                         FROM SIP__c
                         WHERE id = :recSIPId];
        
        sipPayWrap.dblvolumeActual = recSIP.Volume_Actual__c;
        sipPayWrap.dblrevenueActual = recSIP.Ocean_Revenue_Actual_USD__c;
        sipPayWrap.dblspotVolumeActual = recSIP.Maersk_Spot_Volume_Actual_FFE__c;// this is new added for RQ-012775
        sipPayWrap.dblacquistionActual = recSIP.Acquisition_Actual__c;
        sipPayWrap.dblrevenueGrowthVASActual = recSIP.Revenue_Growth_VAS_Actual__c;
        sipPayWrap.dble2evolumeActual = recSIP.E2E_Volume_Actual_FFE__c;
        sipPayWrap.dblrevenueGrowthVASTarget = recSIP.Revenue_Growth_VAS_Target__c;
        
        sipPayWrap.dbloceanrevenuePayoutpercen = recSIP.Revenue_Payout_Percent__c;
        sipPayWrap.dbllnSPayoutpercen = recSIP.Revenue_Growth_VAS_Payout_Percent__c;
        sipPayWrap.dblocenVolPayoutpercen = recSIP.Volume_Payout_Percent__c;
        sipPayWrap.dble2ePayoutpercen = recSIP.E2E_Volume_Payout_Percent__c;
        sipPayWrap.dblcustconvrPayoutpercen = recSIP.Acquisition_Payout_Percent__c;
        sipPayWrap.dblspotVolumePayoutpercen = recSIP.Maersk_Spot_Volume_Payout_Percent__c; 
        
        return sipPayWrap;        
    }
    // wrapper class for SIP payout lightinng component
    public class sipPayoutWrapper {
        
        @AuraEnabled public double dblE2eVolumePayout {get;set;}
        @AuraEnabled public double dblCustomerConversionPayout{get;set;}
        @AuraEnabled public double dblLsgpPayout {get;set;}
        @AuraEnabled public double dblOceanVolumePayout {get;set;}
        @AuraEnabled public double dblOceanrevenuePayout {get;set;}
        @AuraEnabled public double dblTotalPayout {get;set;}
        @AuraEnabled public double dblvolumeActual {get;set;}
        @AuraEnabled public double dblrevenueActual {get;set;}
        @AuraEnabled public double dblspotVolumeActual {get;set;} 
        @AuraEnabled public double dblspotVolumePayout {get;set;} 
        @AuraEnabled public double dblacquistionActual {get;set;}
        @AuraEnabled public double dblrevenueGrowthVASActual {get;set;}
        @AuraEnabled public double dblrevenueGrowthVASTarget {get;set;}
        @AuraEnabled public double dble2evolumeActual {get;set;}
        @AuraEnabled public double dbloceanrevenuePayoutpercen {get;set;}
        @AuraEnabled public double dblspotVolumePayoutpercen {get;set;} 
        @AuraEnabled public double dbllnSPayoutpercen {get;set;}
        @AuraEnabled public double dblocenVolPayoutpercen {get;set;}
        @AuraEnabled public double dble2ePayoutpercen {get;set;}
        @AuraEnabled public double dblcustconvrPayoutpercen {get;set;}
        @AuraEnabled public double dbllndsidevppayout {get;set;}
        @AuraEnabled public double dbllndsidevppayoutpercen {get;set;}
        
        public sipPayoutWrapper() {
            dblE2eVolumePayout = 0.0;
            dblCustomerConversionPayout = 0.0;
            dblLsgpPayout = 0.0;
            dblOceanVolumePayout = 0.0;
            dblOceanrevenuePayout= 0.0;
            dblTotalPayout = 0.0;
            dblvolumeActual = 0.0;
            dblspotVolumeActual =0.0;
            dblspotVolumePayout =0.0;
            dblrevenueActual = 0.0;
            dblacquistionActual = 0.0;
            dblrevenueGrowthVASActual = 0.0;
            dblrevenueGrowthVASTarget =0.0;
            dble2evolumeActual = 0.0;
            dbloceanrevenuePayoutpercen =0.0;
            dblspotVolumePayoutpercen =0.0; // added 
            dbllnSPayoutpercen = 0.0;
            dblocenVolPayoutpercen = 0.0;
            dble2ePayoutpercen = 0.0;
            dblcustconvrPayoutpercen = 0.0;
            dbllndsidevppayout = 0.0;
            dbllndsidevppayoutpercen = 0.0;
        }
        
    }
    
    // Method to calculate payout for Ocean Vol, Ocean CY, L&S GP, Customer Conversion Payout
    @AuraEnabled
    public static sipPayoutWrapper calculatePayout (Id recSIPId, Decimal strSalary, Decimal e2evolumeActual,Decimal aquisActual, Decimal volumeActual,Decimal revGrowthVASActual, Decimal revenueactual, Decimal spotVolumeActual, Decimal landsidetransActual){ ///,Decimal volactual,,Decimal revenueGVactual) {
        
        sipPayoutWrapper wrapComp = new sipPayoutWrapper();
        SIP__c recSIP = [ SELECT id, Landside_Trans_VP_Target_FFE__c, Landside_Trans_VP_Weight_Percent__c, Ocean_Revenue_Total_Actual_USD__c, Ocean_Volume_Total_Actual_FFE__c, Landside_Trans_VP_Performance__c, name, E2E_Volume_Target_FFE__c, E2E_Volume_Payout_Percent__c, E2E_Volume_Weight_Percent__c, Quarter__c, Paymix_Opted__c, Revenue_Weight_Percent__c, Revenue_Payout_Percent__c,
                         SIP_Qualifiers_Mitigation_Percent__c, Pass_Fail_Multiplier__c, Number_of_Months_For_Annualization__c, 
                         Volume_Weight_Percent__c, Volume_Payout_Percent__c, E2E_Volume_Performance__c,
                         Acquisition_Weight_Percent__c, Acquisition_Payout_Percent__c,
                         Volume_Target__c, Volume_Actual__c, Ocean_Revenue_Actual_USD__c, Ocean_Revenue_Target_USD__c,Acquisition_Target__c, Acquisition_Actual__c,
                         Acquisition_Performance__c, Revenue_Performance__c,Revenue_Growth_VAS_Target__c, 
                         Volume_Performance__c, Maersk_Spot_Volume_Actual_FFE__c,Maersk_Spot_Volume_Target_FFE__c,Maersk_Spot_Volume_Weight_Percent__c, 
                         Maersk_Spot_Volume_Performance__c,RecordTypeId, RecordType.Name,RecordType.DeveloperName,
                         Revenue_Growth_VAS_Performance__c, Revenue_Growth_VAS_Payout_Percent__c, Revenue_Growth_VAS_Weight_Percent__c,
                         Revenue_Growth_VAS_Actual__c,Quarter_Start_Date__c,Quarter_End_Date__c
                         FROM SIP__c
                         WHERE id = :recSIPId];
        
        if(recSIP.RecordType.Name == Label.SIP_Ease_And_Advancement) {
            recSIP.E2E_Volume_Actual_FFE__c = (e2evolumeActual == null) ?  recSIP.E2E_Volume_Actual_FFE__c :e2evolumeActual ;  
            recSIP.Acquisition_Actual__c = (aquisActual == null) ? recSIP.Acquisition_Actual__c :aquisActual;
        }
        if(recSIP.RecordType.Name == Label.SIP_Efficiency_And_Super) {
            recSIP.Landside_Trans_VP_Actual_FFE_QTR__c = (landsidetransActual == null)?recSIP.Landside_Trans_VP_Actual_FFE_QTR__c :landsidetransActual;
            recSIP.Maersk_Spot_Volume_Actual_FFE__c = (spotVolumeActual == null)?recSIP.Maersk_Spot_Volume_Actual_FFE__c :spotVolumeActual;
            recSIP.Revenue_Growth_VAS_Actual__c = (revGrowthVASActual == null) ? recSIP.Revenue_Growth_VAS_Actual__c:revGrowthVASActual;
        }
        if(recSIP.RecordType.Name == System.Label.SIP_Expertise_And_Ambition) {
            recSIP.Landside_Trans_VP_Actual_FFE_QTR__c = (landsidetransActual == null)?recSIP.Landside_Trans_VP_Actual_FFE_QTR__c :landsidetransActual;
            recSIP.Revenue_Growth_VAS_Actual__c = (revGrowthVASActual ==null) ?recSIP.Revenue_Growth_VAS_Actual__c: revGrowthVASActual;
            
        }
        
        wrapComp.dblvolumeActual = volumeActual;
        wrapComp.dblrevenueActual = revenueactual;
        wrapComp.dblacquistionActual = aquisActual;
        wrapComp.dblrevenueGrowthVASActual = revGrowthVASActual;
        wrapComp.dble2evolumeActual = e2evolumeActual;
        wrapComp.dblspotVolumeActual = spotVolumeActual;
        wrapComp.dblrevenueGrowthVASTarget = recSIP.Revenue_Growth_VAS_Target__c;
		system.debug('wrapComp ' + wrapComp);
        Map<String, decimal> EstimatedPayout = SIP_Utilities.CalculateEstimatePayout(volumeActual, revenueactual, recSIP, double.valueof( strSalary) );  
        system.debug('$$$ EstimatedPayout' + EstimatedPayout);     
        wrapComp.dblOceanVolumePayout = EstimatedPayout.get('Ocean Volume');
        //wrapComp.dblOceanCyPayout = EstimatedPayout.get('Ocean CY');
        wrapComp.dblOceanrevenuePayout = EstimatedPayout.get('Ocean Revenue');
        wrapComp.dblspotVolumePayout = EstimatedPayout.get('Spot Volume');
        wrapComp.dblCustomerConversionPayout = EstimatedPayout.get('Customer Conversion');
        wrapComp.dblE2eVolumePayout = EstimatedPayout.get('E2E');
        system.debug('$$$ dblE2eVolumePayout' + wrapComp.dblE2eVolumePayout);  
        wrapComp.dblLsgpPayout = EstimatedPayout.get('L&S GP');
        
        
        //Start - RQ-010681 - Added payout percent to get displayed on SIP Calculator
        wrapComp.dblocenVolPayoutpercen = EstimatedPayout.get('Ocean Volume PayoutPercent');
        //wrapComp.dbloceanCYPayoutpercen = EstimatedPayout.get('Ocean CY PayoutPercent');
        wrapComp.dbloceanrevenuePayoutpercen = EstimatedPayout.get('Ocean Revenue PayoutPercent');
        wrapComp.dbllnSPayoutpercen =  EstimatedPayout.get('L&S GP PayoutPercent');
        wrapComp.dble2ePayoutpercen = EstimatedPayout.get('E2E PayoutPercent');
        wrapComp.dblcustconvrPayoutpercen = EstimatedPayout.get('Customer Conversion PayoutPercent');
        wrapComp.dblspotVolumePayoutpercen = EstimatedPayout.get('Spot Volume PayoutPercent');
        wrapComp.dbllndsidevppayout = EstimatedPayout.get('Landside Trans & VP');
        wrapComp.dbllndsidevppayoutpercen = EstimatedPayout.get('Landside Trans & VP PayoutPercent');
        //End - RQ-010681 - Added payout percent to get displayed on SIP Calculator     
        wrapComp.dblTotalPayout =  wrapComp.dbllndsidevppayout + wrapComp.dblOceanVolumePayout +  wrapComp.dblOceanrevenuePayout + wrapComp.dblCustomerConversionPayout + wrapComp.dblE2eVolumePayout + wrapComp.dblLsgpPayout + wrapComp.dblspotVolumePayout;
        return wrapComp;
    }
    
}