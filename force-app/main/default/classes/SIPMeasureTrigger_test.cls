/**
 *        
 * Revision  Ref Number     Date           Owner           Description
 * 1.0       SFSE-7308      22-Nov-2021    Neha@TCS        Test class for SIPMeasureTrigger logic
 * 2.0       SPI-100        27-Jun-2022    Ronnie@SF       Removed brand hardcoding
 * 3.0       SFSE-9542      12-Oct-2022    Vazid           Removed Number_of_months_for_annualization__c field reference from setupTestData method.
 * 4.0                      26-Jul-2022    Kiran            New test data framework
 */

@isTest
public with sharing class SIPMeasureTrigger_test {
    @testSetup
    static void setupTestData(){
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        TriggerExecutionController.skipAllTriggers(true);
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert adminUser;
        }
        
        List<user> usersToInsert = new List<user>();
        System.runAs(adminUser){
            User salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser1.Id = null;
            salesUser1.IsActive=true;
            salesUser1.country = 'India';
            salesUser1.Cluster__c = 'GSC';
            salesUser1.Industry_Focus__c='Retail';
            salesUser1.Segment_Focus__c='Advancement';
            salesUser1.Sales_Job_Function__c='Other';
            usersToInsert.add(salesUser1);
            
            User salesUser2 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
            salesUser2.Id = null;
            salesUser2.IsActive=true;
            salesUser2.country = 'India';
            salesUser2.Cluster__c = 'GSC';
            salesUser2.Industry_Focus__c='Retail';
            salesUser2.Segment_Focus__c='Advancement';
            salesUser2.Sales_Job_Function__c='Sales Manager';
            usersToInsert.add(salesUser2);
            
            User salesUser3 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
            salesUser3.Id = null;
            salesUser3.IsActive=true;
            salesUser3.country = 'India';
            salesUser3.Cluster__c = 'GSC';
            salesUser3.Industry_Focus__c='Retail';
            salesUser3.Segment_Focus__c='Advancement';
            salesUser3.Sales_Job_Function__c='Sales Manager';
            usersToInsert.add(salesUser3);
            
            insert usersToInsert;
        }
        TriggerExecutionController.skipAllTriggers(false);
        System.debug('usersToInsert'+usersToInsert.size());
        String strYear = String.valueOf( Date.today().year() +1 ) ; 
        
        // Insert the SIp KPI record
        SIP_KPI__c kpiRec = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'FFE',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Measure_Type__c = 'Volume',
                                          Target__c = 11,
                                          Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                          Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                          Geographical_Validity__c = 'Global',
                                          Brand__c = BrandUtilities.MAERSK);
        insert kpiRec;
        
        List<SIP_Payout_Curve__c> listSIPPayoutCurve = new List<SIP_Payout_Curve__c>();
        // Create multiple Payout cureve for Global and Region
        SIP_Payout_Curve__c payoutCurveRec = new SIP_Payout_Curve__c(Name = 'PC0001',
                                                                     Active__c = true,
                                                                     SIP_KPI__c = kpiRec.id,
                                                                     Threshold_Performance_Percent__c = 90, Threshold_Payout_Percent__c = 90,
                                                                     Target_Performance_Percent__c = 100, Target_Payout_Percent__c = 100,
                                                                     Excellence_Performance_Percent__c = 110, Excellence_Payout_Percent__c = 110,
                                                                     Cap_Performance_Percent__c = 120, Cap_Payout_Percent__c = 120,
                                                                     Effective_Period_Year__c = strYear, Effective_Period_Quarter__c = 'Q1;Q2;Q3;Q4',
                                                                     Geographical_Validity__c = 'Global', Brand__c = BrandUtilities.MAERSK);
        
        listSIPPayoutCurve.add(payoutCurveRec);
        SIP_Payout_Curve__c payoutCurveRegionRec = new SIP_Payout_Curve__c(Name = 'PC0002',
                                                                     Active__c = true,
                                                                     SIP_KPI__c = kpiRec.id,
                                                                     Threshold_Performance_Percent__c = 80, Threshold_Payout_Percent__c = 80,
                                                                     Target_Performance_Percent__c = 90, Target_Payout_Percent__c = 90,
                                                                     Excellence_Performance_Percent__c = 120, Excellence_Payout_Percent__c = 120,
                                                                     Cap_Performance_Percent__c = 130, Cap_Payout_Percent__c = 130,
                                                                     Effective_Period_Year__c = strYear, Effective_Period_Quarter__c = 'Q1;Q2;Q3;Q4',
                                                                     Geographical_Validity__c = 'Region', Brand__c = BrandUtilities.MAERSK);
        
        listSIPPayoutCurve.add(payoutCurveRegionRec);
        SIP_Payout_Curve__c payoutCurveNullbrand = new SIP_Payout_Curve__c(Name = 'PC0003',
                                                                     Active__c = true,
                                                                     SIP_KPI__c = kpiRec.id,
                                                                     Threshold_Performance_Percent__c = 88, Threshold_Payout_Percent__c = 88,
                                                                     Target_Performance_Percent__c = 120, Target_Payout_Percent__c = 130,
                                                                     Excellence_Performance_Percent__c = 230, Excellence_Payout_Percent__c = 222,
                                                                     Cap_Performance_Percent__c = 190, Cap_Payout_Percent__c = 400,
                                                                     Effective_Period_Year__c = strYear, Effective_Period_Quarter__c = 'Q1;Q2;Q3;Q4',
                                                                     Geographical_Validity__c = 'Global',Brand__c = '');
        listSIPPayoutCurve.add(payoutCurveNullbrand);
        insert listSIPPayoutCurve;
        
        // Create Payout cureve BDA 
        SIP_Payout_Curve_BDA__c payoutcurveBda = new SIP_Payout_Curve_BDA__c();
        payoutcurveBda.SIP_Payout_Curve__c = listSIPPayoutCurve[1].id;
        payoutcurveBda.BDA__c = parentBDA.id;
        insert payoutcurveBda;
        
        List<SIP_Participant__c> sipUser = new List<SIP_Participant__c>();
        
        SIP_Participant__c newSIP = new SIP_Participant__c();
        newSIP.SIP_Participant__c = usersToInsert[0].id;
        newSIP.Year__c = strYear;
        
        newSIP.Paymix__c = 80.0;        
        newSIP.Brand__c = BrandUtilities.MAERSK;
        newSIP.Region__c = parentBDA.id;
        newSIP.Area__c = childBDA.id;
        
        sipUser.add(newSIP);
        
        
        SIP_Participant__c newSIP1 = new SIP_Participant__c();
        newSIP1.SIP_Participant__c = usersToInsert[1].id;
        newSIP1.Year__c = strYear;
        
        newSIP1.Paymix__c = 80.0;        
        newSIP1.Brand__c = BrandUtilities.SEALANDAMERICAS;
        newSIP1.Region__c = parentBDA.id;
        newSIP1.Area__c = childBDA.id;     
        sipUser.add(newSIP1);
        
        SIP_Participant__c newSIP2 = new SIP_Participant__c();
        newSIP2.SIP_Participant__c = usersToInsert[2].id;
        newSIP2.Year__c = strYear;
        
        newSIP2.Paymix__c = 80.0;        
        newSIP2.Brand__c = BrandUtilities.SEALANDAMERICAS;
        newSIP2.Region__c = parentBDA.id;
        newSIP2.Area__c = childBDA.id;     
        sipUser.add(newSIP2);
         
        insert sipUser;      
            
    }

    @isTest
    static void testSIPMeasureOnInsert() {
        Test.startTest();
            List<SIP_KPI__c> sipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            SIP_Measure__c listSIPMeasure = new SIP_Measure__c();
            listSIPMeasure.SIP_Participant__c = sipparticipant[0].id;
            listSIPMeasure.SIP_KPI__c = sipkpi[0].id;
            listSIPMeasure.Weight__c = '20%';
            listSIPMeasure.Applicable_Period__c = 'Q1';
            listSIPMeasure.Target__c =6000;
            listSIPMeasure.System_Actual__c = 5000;            
            insert listSIPMeasure; 
            
            List<SIP_Measure__c> listsipmeasure1 = [select Id, Name, SIP_KPI__c, Actual__c, Applicable_Period__c, Applicable_Payout_Curve__c,Override_Actual__c, Override_Comments__c, Override_Reason_Code__c, Participant_Name__c, Payout_Frequency__c from SIP_Measure__c where Target__c =6000.0]; 
            System.assertEquals(listsipmeasure1.size(),1);
            
        Test.stopTest();
       
    }

    @isTest
    static void testSIPMeasureOnUpdate() {        
        Test.startTest();
            List<SIP_KPI__c> sipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            List<SIP_Participant__c> sipparticipant = [Select id,Region__c from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            SIP_Measure__c listSIPMeasure = new SIP_Measure__c();
            listSIPMeasure.SIP_Participant__c = sipparticipant[0].id;
            listSIPMeasure.SIP_KPI__c = sipkpi[0].id;
            listSIPMeasure.Weight__c = '30%';
            listSIPMeasure.Applicable_Period__c = 'Q1';
            listSIPMeasure.Target__c =8000;
            listSIPMeasure.System_Actual__c = 5000;           
            insert listSIPMeasure; 
            
            List<SIP_Measure__c> listsipmeasure1 = [select Id, Name, SIP_KPI__c, Actual__c, Applicable_Period__c, Applicable_Payout_Curve__c,Override_Actual__c, Override_Comments__c, Override_Reason_Code__c, Participant_Name__c, Payout_Frequency__c from SIP_Measure__c where Target__c =8000.0]; 
            listsipmeasure1[0].System_Actual__c = 9000.0;
            update listsipmeasure1;
            
            List<SIP_Measure__c> updatedlstMeasure = [select Id, Name, SIP_KPI__c, Target__c, Actual__c, System_Actual__c,Applicable_Period__c, Applicable_Payout_Curve__c from SIP_Measure__c where Applicable_Period__c ='Q1'];
            System.assertEquals(updatedlstMeasure[0].System_Actual__c,9000.0);
        
            listsipmeasure1[0].System_Actual__c = -200;
            update listsipmeasure1;
            
        Test.stopTest();
       
    }
    
     @isTest
     static void testSIPMeasureOnInsertwithzeroPerformace() {
        Test.startTest();
            List<SIP_KPI__c> sipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            SIP_Measure__c listSIPMeasure = new SIP_Measure__c();
            listSIPMeasure.SIP_Participant__c = sipparticipant[0].id;
            listSIPMeasure.SIP_KPI__c = sipkpi[0].id;
            listSIPMeasure.Weight__c = '30%';
            listSIPMeasure.Applicable_Period__c = 'Q1';
            listSIPMeasure.Target__c =5000;
            listSIPMeasure.System_Actual__c = 10;            
            insert listSIPMeasure; 
            
            List<SIP_Measure__c> listsipmeasure1 = [select Id, Name, SIP_KPI__c, Actual__c, Applicable_Period__c, Applicable_Payout_Curve__c,Override_Actual__c, Override_Comments__c, Override_Reason_Code__c, Participant_Name__c, Payout_Frequency__c from SIP_Measure__c where Target__c =5000.0]; 
            System.assertEquals(listsipmeasure1.size(),1);
            
        Test.stopTest();
       
    }
    
    @isTest
     static void testSIPMeasureOnInsertwithBrandNull() {
        Test.startTest();
            List<SIP_KPI__c> sipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
            List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.SEALANDAMERICAS limit 1];
            SIP_Measure__c listSIPMeasure = new SIP_Measure__c();
            listSIPMeasure.SIP_Participant__c = sipparticipant[0].id;
            listSIPMeasure.SIP_KPI__c = sipkpi[0].id;
            listSIPMeasure.Weight__c = '30%';
            listSIPMeasure.Applicable_Period__c = 'Q1';
            listSIPMeasure.Target__c =4000;
            listSIPMeasure.System_Actual__c = 8000;            
            insert listSIPMeasure; 
            
            List<SIP_Measure__c> listsipmeasure1 = [select Id, Name, SIP_KPI__c, Actual__c, Applicable_Period__c, Applicable_Payout_Curve__c,Override_Actual__c, Performance_Percent__c, Payout_Percent__c, Participant_Name__c, Payout_Frequency__c from SIP_Measure__c where Target__c =4000.0];          
            System.assertEquals(listsipmeasure1[0].Performance_Percent__c,200);
            
        Test.stopTest();
       
    }         
}