/**
* Test class for : BatchSIPCutOffAccountUpdate & Schedule_BatchSIPCutOffAccountUpdate

* Date         Owner                                                    Description
**************************************************************************************************************************************
* 20/06/2016   meghana.gupta@ust-global.com               PR-0089 Test Classes for BatchSIPCutOffAccountUpdate & Schedule_BatchSIPCutOffAccountUpdate
* 03-Sep-2019  manjunath.c.holekade@maersk.com			  RQ-011882	- Updated to increase code coverage of Schedule_BatchSIPCutOffAccountUpdate class
*/


@isTest
private class BatchSIPCutOffAccountUpdate_Test{
        
    static testMethod void testBatch() {
        
        //Calculate value for SIP Cut off date so that schedule job's criteria is met to call batch job
        String currQuarter = SIP_Utilities.getQuarter ('Current');
        Date QuarterEndDate = SIP_Utilities.getQuarterEndDate( currQuarter );
        Integer cutOffDay = System.Today().daysBetween(QuarterEndDate ) -1 ;
        system.debug('$$$DEBUG cutOffDay' + cutOffDay);
        SIPDataGeneratorHelper.addEnvironment_Variables ('SIP Cut Of Date', cutOffDay );
        
        //create client account
        Account clientAccount = AccountDataHelper_Test.createClientAccount();
    
        Test.startTest();        
         // test scheduler class     
        Schedule_BatchSIPCutOffAccountUpdate schClass = new Schedule_BatchSIPCutOffAccountUpdate();
        String strSchTime = '0 8 13 14 3 ? *';
        System.schedule( 'BatchSIPCutOffAccountUpdate', strSchTime, schClass );
        
        BatchSIPCutOffAccountUpdate batchAcc = new BatchSIPCutOffAccountUpdate();
        Database.executeBatch( batchAcc );     
        Test.StopTest();

    }
    
}