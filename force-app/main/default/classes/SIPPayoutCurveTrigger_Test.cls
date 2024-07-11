/**
*        
* Revision	Ref Number	Date			Owner						Description
* 1.0		SFSE-6976	27-Oct-2021		Kiran@Maersk				Test class for SIPPayoutCurveTrigger logic
* 2.0      SPI-100     27-Jun-2022     Ronnie@SF                   Removed brand hardcoding
* 3.0		SFSE-10354  23-Feb-2023		Jothsana@Maersk				Test class for SIPPayoutCurveDetailRecordCreation logic
*/


@isTest
public class SIPPayoutCurveTrigger_Test {
    
    @testSetup
    static void setupTestData(){
        if(UserDataGeneratorHelper_Test.integrationUser == null){            
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        if(UserDataGeneratorHelper_Test.MSLSystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        }
        if(UserDataGeneratorHelper_Test.salesUser == null){            
            UserDataGeneratorHelper_Test.initializeSalesUser();            
        } 
        UserDataGeneratorHelper_Test.salesUser.managerId = UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
        update UserDataGeneratorHelper_Test.salesUser ;
        
        SIP_KPI__c kpiRec = SIPDataGeneratorHelper.createSIPKPI(UserDataGeneratorHelper_Test.MSLSystemAdminUser);
        
        List<SIP_Payout_Curve__c> listSIPPayoutCurve = new List<SIP_Payout_Curve__c>();
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q1;Q2', 'Global', BrandUtilities.MAERSK ));
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q3;Q4', 'Global', BrandUtilities.MAERSK ));
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert listSIPPayoutCurve;
        }
        
        
    }
    
    @isTest
    static void testSIPPayoutCurveOnInsert() {
        SIP_KPI__C kpiRec = [Select Id from SIP_KPI__c limit 1];
        List<SIP_Payout_Curve__c> listSIPPayoutCurve = [SELECT Id FROM SIP_Payout_Curve__c];
        System.assertEquals(listSIPPayoutCurve.size(), 2);
        listSIPPayoutCurve = new List<SIP_Payout_Curve__c>();
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q1;Q2', 'Global', BrandUtilities.MAERSK ));
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q3;Q4', 'Global', BrandUtilities.MAERSK ));
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2023', 'Q1', 'Global', BrandUtilities.MAERSK ));
        Test.startTest();
        Database.insert(listSIPPayoutCurve, false);
        Test.stopTest();
        listSIPPayoutCurve = [SELECT Id FROM SIP_Payout_Curve__c];
        System.assertEquals(listSIPPayoutCurve.size(), 3);
    }
    
    @isTest
    static void testSIPPayoutCurveOnUpdate() {
        
        List<SIP_Payout_Curve__c> listPayoutCurves = [SELECT Id, Brand__c, SIP_KPI__c, Active__c, Geographical_Validity__c, Effective_Period_Year__c, Effective_Period_Quarter__c
                                                      FROM SIP_Payout_Curve__c WHERE Geographical_Validity__c = 'Global' AND Effective_Period_Year__c = '2022' AND Brand__c = :BrandUtilities.MAERSK AND Active__c = true];
        listPayoutCurves[0].Effective_Period_Quarter__c = 'Q1;Q3';
        listPayoutCurves[1].Effective_Period_Quarter__c = 'Q2;Q4';
        
        Test.startTest();
        Database.update(listPayoutCurves, false);
        Test.stopTest();
        listPayoutCurves = [SELECT Id, Brand__c, SIP_KPI__c, Active__c, Geographical_Validity__c, Effective_Period_Year__c, Effective_Period_Quarter__c
                            FROM SIP_Payout_Curve__c WHERE Geographical_Validity__c = 'Global' AND Effective_Period_Year__c = '2022' AND Brand__c = :BrandUtilities.MAERSK AND Active__c = true];
        
        System.assertEquals(listPayoutCurves[0].Effective_Period_Quarter__c, 'Q1;Q2');
        System.assertEquals(listPayoutCurves[1].Effective_Period_Quarter__c, 'Q3;Q4');
    }
    
     @isTest
    static void testSIPPayoutCurveOnUpdateDetail() {
        
        List<SIP_Payout_Curve__c> listPayoutCurves1 = [SELECT Id, Brand__c, SIP_KPI__c, Active__c, Geographical_Validity__c, Effective_Period_Year__c, Effective_Period_Quarter__c, Threshold_Performance_Percent__c, Threshold_Payout_Percent__c,
                                                      Target_Performance_Percent__c, Target_Payout_Percent__c,Excellence_Performance_Percent__c, Excellence_Payout_Percent__c, Cap_Performance_Percent__c, Cap_Payout_Percent__c 
                                                      FROM SIP_Payout_Curve__c WHERE Geographical_Validity__c = 'Global' AND Effective_Period_Year__c = '2022' AND Brand__c = :BrandUtilities.MAERSK AND Active__c = true];
        
        listPayoutCurves1[0].Threshold_Performance_Percent__c = 91;
        listPayoutCurves1[1].Threshold_Payout_Percent__c = 25;
        listPayoutCurves1[0].Target_Performance_Percent__c = 99;
        listPayoutCurves1[1].Target_Payout_Percent__c = 190;
        listPayoutCurves1[1].Excellence_Payout_Percent__c = 250;
        listPayoutCurves1[1].Cap_Payout_Percent__c = 320;
        listPayoutCurves1[0].Excellence_Performance_Percent__c = 113;
        listPayoutCurves1[0].Cap_Performance_Percent__c = 140;
        
        Test.startTest();
        Database.update(listPayoutCurves1, false);
        Test.stopTest();
        
    }
      
}