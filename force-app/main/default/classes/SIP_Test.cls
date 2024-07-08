/**
* Test class for : SIPDataGeneratorHelper, SIP_MyTeamListCntrl, SIPTriggerHandler, SIP_CalculatePayoutController, SIPTrigger

* Date         Owner                                                    Description
**************************************************************************************************************************************
* 20/05/2016   meghana.gupta@ust-global.com               PR-0089 Test Classes for SIP controllers
* 27/09/2016   meghana.gupta@ust-global.com               SIP Release 3 changes
* 22/01/2018   meghana.gupta@ust-global.com               RQ-007413: deprecate SIP Visualforce pages/controllers
* 15/Mar/2019  meghana.gupta@ust-global.com               RQ-010223 : call calculate lethod for all SIP record types 
* 30/12/2019   meghana.gupta@ust-global.com               RQ-012475 : Change in measures applicable to different record types
* 09/01/2020   Neha@TCS                                   RQ-012775  : New measure and payout calculation
*/


@isTest
private class SIP_Test{
      
    static testMethod void test_SIP_CalculatePayoutController() {
        
        if ( UserDataGeneratorHelper_Test.integrationUser == null ){            
            UserDataGeneratorHelper_Test.initializeIntegrationUser();  
        }
        
        if ( UserDataGeneratorHelper_Test.salesUser == null ){                
            UserDataGeneratorHelper_Test.initializeSalesUser();            
        }     
            
        Test.startTest();        
        
        // test SIPTrigger, SIPTriggerHandler
        List<SIP_Payout__c> lstPayoutPercent = new List<SIP_Payout__c>();
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 90, 90, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'SIP', 'All'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 102, 120, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'SIP', 'All'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 110, 200, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'SIP', 'All'));        
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 100, 100, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'SIP', 'All'));
             
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 90, 95, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'Efficiency_Super_Saver', 'L&S GP'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 102, 125, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'Efficiency_Super_Saver', 'L&S GP'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 110, 205, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'Efficiency_Super_Saver', 'L&S GP'));        
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 100, 105, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'Efficiency_Super_Saver', 'L&S GP'));
        
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 90, 96, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'Efficiency_Super_Saver', 'Customer Conversion'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 102, 126, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'Efficiency_Super_Saver', 'Customer Conversion'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 110, 206, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'Efficiency_Super_Saver', 'Customer Conversion'));        
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 100, 106, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'Efficiency_Super_Saver', 'Customer Conversion'));
       
        insert lstPayoutPercent;
        
        SIP__c recSIP4 = SIPDataGeneratorHelper.createSIP( UserDataGeneratorHelper_Test.SalesUser, '2019Q2', 'Efficiency_Super_Saver');
         
        System.runAs( UserDataGeneratorHelper_Test.MSLintegrationUser ){     
            insert recSIP4;            
        }
        
        SIP_CalculatePayoutController.initMethod(recSIP4.Id);
        SIP_CalculatePayoutController.calculatePayout( recSIP4.Id, 5000.0, 1100.0,100.0,100.0,100.0, 100.0,100.0,100.0);
        SIP_CalculatePayoutController.calculatePayout( recSIP4.Id, 100.0, 100.0,100.0,100.0,100.0, 100.0,100.0,100.0);       
        Test.stopTest();
        
    }
       
}