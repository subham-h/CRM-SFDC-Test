/*
 *        
 * Revision	Ref Number	Date			Owner						Description
 * 1.0		SFSE-6976	27-Oct-2021		Kiran@Maersk				Test class for SIPPayoutCurveBDATrigger
 */

@isTest
public class SIPPayoutCurveBDATrigger_Test {
    
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
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q1;Q2', 'Global', 'Maersk' ));
        listSIPPayoutCurve.add(SIPDataGeneratorHelper.createSIPPayoutCurve(kpiRec.Id, true, '2022', 'Q3;Q4', 'Global', 'Maersk' ));
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert listSIPPayoutCurve;
        }
        
        BDAGeographyData_Test bda = new BDAGeographyData_Test();
        
        List<BDA__c> bdas = [select id from BDA__C];
        
        List<SIP_Payout_Curve_BDA__c> listPayoutCurveBDA = new List<SIP_Payout_Curve_BDA__c>();
        listPayoutCurveBDA.add(SIPDataGeneratorHelper.createSIPPayoutCurveBDA(listSIPPayoutCurve[0].Id, bdas[0].Id ));
        listPayoutCurveBDA.add(SIPDataGeneratorHelper.createSIPPayoutCurveBDA(listSIPPayoutCurve[1].Id, bdas[0].Id ));
        
        System.runAs(UserDataGeneratorHelper_Test.MSLSystemAdminUser){
            insert listPayoutCurveBDA;
        }
   
    }
    
    @isTest
    static void testSIPPayoutCurveBDAOnInsert(){
        List<SIP_Payout_Curve__c> listSIPPayoutCurve = [SELECT Id FROM SIP_Payout_Curve__c];
        List<BDA__c> bdas = [select id from BDA__C];
        List<SIP_Payout_Curve_BDA__c> listPayoutCurveBDA = new List<SIP_Payout_Curve_BDA__c>();
        listPayoutCurveBDA.add(SIPDataGeneratorHelper.createSIPPayoutCurveBDA(listSIPPayoutCurve[0].Id, bdas[0].Id ));
        listPayoutCurveBDA.add(SIPDataGeneratorHelper.createSIPPayoutCurveBDA(listSIPPayoutCurve[1].Id, bdas[0].Id ));
        Test.startTest();
        Database.insert(listPayoutCurveBDA, false);
        Test.stopTest();
    }
    
    @isTest
    static void testSIPPayoutCurveBDAOnUpdate(){
        List<SIP_Payout_Curve__c> listSIPPayoutCurve = [SELECT Id FROM SIP_Payout_Curve__c];
        List<BDA__c> bdas = [select id from BDA__C];
        List<SIP_Payout_Curve_BDA__C> listPayoutCurveBDA = [SELECT Id, SIP_Payout_Curve__c, BDA__c FROM SIP_Payout_Curve_BDA__c];
        listPayoutCurveBDA[0].BDA__C = bdas[0].Id;
        listPayoutCurveBDA[1].BDA__C = bdas[0].Id;
        Test.startTest();
        Database.update(listPayoutCurveBDA, false);
        Test.stopTest();
    }

}