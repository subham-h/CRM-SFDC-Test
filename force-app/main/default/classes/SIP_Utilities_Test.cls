/**
* Test class for : SIP_Utilities

* Date         Owner                                                    Description
**************************************************************************************************************************************
* 27/09/2016   meghana.gupta@ust-global.com               SIP Release 3 changes
* 22/01/2018   meghana.gupta@ust-global.com               RQ-007413: Update test classes as per methods added/removed from SIP_Utilities
* 24/0/2020    Amritesh@ust-global.com                    RQ-013054 - updated test method for getQuarter
*/

@isTest
private class SIP_Utilities_Test{
        
    static testMethod void testSIPUtilities() {
        
        if ( UserDataGeneratorHelper_Test.salesUser == null ){
            
            UserDataGeneratorHelper_Test.initializeSalesUser();
        
        } 
        
        UserDataGeneratorHelper_Test.MSLsalesUser.managerId = UserDataGeneratorHelper_Test.SalesUser.id;
        update UserDataGeneratorHelper_Test.MSLsalesUser;
      
        
        List<SIP_Payout__c> lstPayoutPercent = new List<SIP_Payout__c>();
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 90, 90, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'SIP', 'All'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 102, 120, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'SIP', 'All'));
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 110, 200, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3),'SIP', 'All'));        
        lstPayoutPercent.add( SIPDataGeneratorHelper.addSIP_Payout( 100, 100, date.newinstance(2016, 1, 1), date.newinstance(2019, 31, 3), 'SIP', 'All'));
               
        insert lstPayoutPercent;
        
        Test.startTest();     
        
        SIP_Utilities.getQuarter ('Current');
        SIP_Utilities.getQuarter ('Previous');
        SIP_Utilities.getQuarter ('Next');
        
        SIP_Utilities.getQuarterStartDate('2016Q1');
        SIP_Utilities.getQuarterStartDate('2016Q2');
        SIP_Utilities.getQuarterStartDate('2016Q3');
        SIP_Utilities.getQuarterStartDate('2016Q4');
        
        SIP_Utilities.getQuarterEndDate('2016Q1');
        SIP_Utilities.getQuarterEndDate('2016Q2');
        SIP_Utilities.getQuarterEndDate('2016Q3');
        SIP_Utilities.getQuarterEndDate('2016Q4');
        
        SIP_Utilities.getQuarterFromDate( Date.newInstance( 2016, 1, 1 ));
        SIP_Utilities.getQuarterFromDate( Date.newInstance( 2016, 4, 1 ));
        SIP_Utilities.getQuarterFromDate( Date.newInstance( 2016, 8, 1 ));
        SIP_Utilities.getQuarterFromDate( Date.newInstance( 2016, 11, 1 ));
        
        List<Id> userList = new List<id>();
        userList.add(UserDataGeneratorHelper_Test.SalesUser.id);
        
        Set<Id> userSet = new Set<Id>();
        userSet.add(UserDataGeneratorHelper_Test.SalesUser.id);
        
        SIP_Utilities.getSIPUserReporteeList (userSet, '2016Q3');
         SIP_Utilities.getUserReportees (userSet);
        Test.stopTest();
            
    }

}