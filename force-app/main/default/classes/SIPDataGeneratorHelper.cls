/**
 * Helper class for generating Test data for :
 * 
 * Date         Owner                                                    Description
 **************************************************************************************************************************************
 * 20/05/2016   meghana.gupta@ust-global.com               PR-0089 Test data generator for SIP 
 * 27/09/2016   meghana.gupta@ust-global.com               SIP release 3 changes
 * 02/12/2016   abby.abraham@ust-global.com                SIP release 4 changes
 * 03/06/2018   Junaid.Khader@ust-global.com               Test class fix.
 * 18/03/2019   meghana.gupta@ust-global.com               RQ-010223: new method createSIP with recordtype added, method createSIPMarketPriorityAccount commented
 * 30/12/2019   meghana.gupta@ust-global.com               RQ-012475 : Change in measures applicable to different record types
 * 20/02/2020   amritesh.sahu@ust-global.com               RQ-013101 : Added @isTest annotation
 * 23/11/2020   Neha@Tcs                                   SFSE-4862   Fix the method to include the missing weight
 * 27/11/2020   Neha@TCS                                   SFSE-4861  Fix the createSip method to include landside weight fields
 * 27/06/2022   Ronnie@SF                                  SPI-100: Removed brand hardcoding
 * 12/10/2022   Vazid 									   SFSE-9542 Removed Months_for_annualization__c field reference from 'SIP_Create_Employee_HR_Data' method.
 */

@isTest 
public class SIPDataGeneratorHelper{
    
    public static SIP__c createSIP ( user SalesRep, String quarter, User runAsUser  ){
        
        //   Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByName().get('SIP').getRecordTypeId();
        Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get('Efficiency_Super_Saver').getRecordTypeId();
        SIP__c recSIP = new SIP__c();
        recSIP.recordTypeId = sipRecordTypeId;
        recSIP.Sales_rep__c = SalesRep.Id;
        recSIP.quarter__c = quarter;
        recSIP.Number_of_Months_For_Annualization__c = 12;
        recSIP.Paymix_Opted__c = 80;
        
        recSIP.Maersk_Spot_Volume_Target_FFE__c = 350;         
        recSIP.Volume_Weight__c = '70%';
        recSIP.Volume_Target__c = 100;
        
        recSIP.SIP_Qualifiers_Mitigation__c = '-20%';
        
        
        
        recSIP.Maersk_Spot_Volume_Weight__c ='0%';       
        recSIP.Revenue_Growth_VAS_Weight__c = '15%';
        recSIP.Landside_Trans_VP_Weight__c = '15%';
        recSIP.Revenue_Growth_VAS_Target__c = 100;  
        recSIP.Landside_Trans_VP_Target_FFE__c = 100;
        System.runAs( runAsUser ){ 
            
            insert recSIP;  
            
        }
        return recSIP;            
    }
    
    
    //insert SIP
    public static SIP__c createSIP ( user SalesRep, String quarter, String recordTypeName  ){
        
        Id sipRecordTypeId =  (ID)Schema.SObjectType.SIP__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        
        SIP__c recSIP = new SIP__c();
        recSIP.recordTypeId = sipRecordTypeId;
        recSIP.Sales_rep__c = SalesRep.Id;
        recSIP.quarter__c = quarter;
        recSIP.Number_of_Months_For_Annualization__c = 1;
        
        if (recordTypeName == 'Efficiency_Super_Saver'){  //||recordTypeName == 'SIP_2016'||recordTypeName == 'SIP_2018'||recordTypeName == 'SIP'){
            
            recSIP.Volume_Weight__c = '70%';
            recSIP.Volume_Target__c = 1000;
            
            recSIP.Maersk_Spot_Volume_Weight__c = '0%';
            recSIP.Maersk_Spot_Volume_Target_FFE__c = 20;
            
           // recSIP.Acquisition_Weight__c = '5%';
            recSIP.Revenue_Growth_VAS_Weight__c = '15%';
            recSIP.Revenue_Growth_VAS_Target__c = 1000;
            
            recSIP.Landside_Trans_VP_Weight__c ='15%';
            recSIP.Landside_Trans_VP_Target_FFE__c = 1000;
            
        }else if (recordTypeName == 'Expertise_Ambition'){
            recSIP.Volume_Weight__c = '25%';
            recSIP.Volume_Target__c = 100;
            
            //recSIP.Maersk_Spot_Volume_Weight__c = '0%';
            
            recSIP.Revenue_Weight__c= '25%';
            recSIP.Ocean_Revenue_Target_USD__c = 20;
            
            recSIP.Revenue_Growth_VAS_Weight__c = '25%';
            recSIP.Revenue_Growth_VAS_Target__c = 100;
            
            recSIP.Landside_Trans_VP_Weight__c ='25%';
            recSIP.Landside_Trans_VP_Target_FFE__c = 100;
            
        }else{
            
            //Twill
            recSIP.E2E_Volume_Weight__c = '50%';
            recSIP.Acquisition_Weight__c = '50%';
            
            recSIP.E2E_Volume_Target_FFE__c = 50;
            recSIP.Acquisition_Target__c = 50;            
        }
        
        recSIP.SIP_Qualifiers_Mitigation__c = '-20%';
        recSIP.Paymix_Opted__c = 80;
        if(String.isBlank(recSIP.Volume_Weight__c)) recSIP.Volume_Weight__c = '0%';
        
        return recSIP;            
    }
    
    // insert custom setting 
    public static SIP_Payout__c addSIP_Payout ( Integer PerformancePercent, Integer PayoutPercent, Date EffStartDate, Date EffEndDate, String strRecordType, String strMeasure ){
        
        SIP_Payout__c customSettingVal = new SIP_Payout__c();
        customSettingVal.Name = ( PerformancePercent + '_' + strRecordType + '_' + strMeasure).left(38);
        customSettingVal.Performance_Percent__c = PerformancePercent;
        customSettingVal.Payout_Percent__c = PayoutPercent;
        customSettingVal.Effective_From_Date__c = EffStartDate;
        customSettingVal.Effective_Till_Date__c = EffEndDate;
        customSettingVal.SIP_Measure__c = strMeasure;
        customSettingVal.SIP_Record_Type__c = strRecordType;
        
        return customSettingVal; 
        
    }
    
    // insert custom setting 
    public static void addEnvironment_Variables ( String name, Integer value ){
        
        Environment_Variables__c customSettingVal = new Environment_Variables__c();
        customSettingVal.Name = name;
        customSettingVal.Value__c = value ;
        
        insert customSettingVal; 
        
    }
    
    public static SIP_KPI__c createSIPKPI(User runAsUser){
        SIP_KPI__c kpiRec = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'FFE',
                                          Measure_Type__c = 'Volume',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Target__c = 11,
                                          Effective_From_Date__c = System.today() - 15,
                                          Effective_To_Date__c = System.today() + 15,
                                          Geographical_Validity__c = 'Global',
                                          Brand__c = BrandUtilities.MAERSK);
        
        System.runAs(runAsUser){
            insert kpiRec;
        }
        
        return kpiRec;
    }
    
    public static SIP_Payout_Curve__c createSIPPayoutCurve(Id kpiRecId, Boolean isActive, String effectivePeriodYear, String effectivePeriodQuarter, String geographicalValidity, String brand ){
        
        SIP_Payout_Curve__c payoutCurveRec = new SIP_Payout_Curve__c(Name = 'PC0001',
                                                                     Active__c = isActive,
                                                                     SIP_KPI__c = kpiRecId,
                                                                     Threshold_Performance_Percent__c = 90, Threshold_Payout_Percent__c = 90,
                                                                     Target_Performance_Percent__c = 100, Target_Payout_Percent__c = 100,
                                                                     Excellence_Performance_Percent__c = 110, Excellence_Payout_Percent__c = 110,
                                                                     Cap_Performance_Percent__c = 120, Cap_Payout_Percent__c = 120,
                                                                     Effective_Period_Year__c = effectivePeriodYear, Effective_Period_Quarter__c = effectivePeriodQuarter,
                                                                     Geographical_Validity__c = geographicalValidity, Brand__c = brand);
        return payoutCurveRec;
    }
    
    public static SIP_Payout_Curve_BDA__c createSIPPayoutCurveBDA(Id payoutCurveID, Id BDAId ){
        
        SIP_Payout_Curve_BDA__c payoutCurveBDARec = new SIP_Payout_Curve_BDA__c(SIP_Payout_Curve__c = payoutCurveID,
                                                                               BDA__c = BDAId);
        return payoutCurveBDARec;
    }
    
    public static Employee_HR_Data__c SIP_Create_Employee_HR_Data(Id employeeId, String empCode, Id managerId, String strArea, String strRegion, String strBrand, Date fromDate, Date toDate, String strRole ){
        Employee_HR_Data__c emp = new Employee_HR_Data__c( Employee__c = employeeId, 
                                                          Manager__c = managerId,
            							From_Date__c = fromDate, Area__c = strArea, Brand__c = strBrand,
                                        Paymix__c = 90,Region__c =strRegion, Sales_Role__c =strRole, 
                                                          Employee_ID__c = empCode);
        return emp;
    }
}