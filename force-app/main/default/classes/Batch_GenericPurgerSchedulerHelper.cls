/*
 * Author   : Nisha
 * Purpose  : Retain the scheduling parameters for each object over the period for purger
 *         
 * Revision Ref Number  Date        Owner               						Description
 * -------- ----------  ----------- ----------          						-----------
 * 1.0      RQ-003324   08-Jun-2016 Nisha.Arjunan@UST   						Created. 
 * 2.0 		RQ-007205	30-Jan-2018	Madhubharathi.Gopalakrishnan@ust-global.com	Remove the Eloqua managed package now moved to SFMC.
 * 3.0      RQ-012850   10-Jan-2020 manjunath@maersk                            New method, 'purgeOppSplitSch', to purge Opportunity_Splits_Schedule__c records older than 2yrs
 * 3.1      RQ-012849   14-Jan-2020  Amritesh@UST                               Add purgeQuoteDocument method
 * 4.0      SC-146      03-Apr-2020 Avinash@UST         						Call Task Deletion - Rolling 3 Year Window
 * 5.0		SC-2929		24-Aug-2020 Meghna@maersk								Add PurgeOOOCase method
 * 6.0		SC-6296		15-June-2023 Harmeet@Maersk								Added Scheduled methods for Cargo,Equipment,Shipment,Party Records
 * 7.0		SFSE-14271  04-June-2024 Seba@Maersk								Added method for Territory Account Association purging 
 */

global class Batch_GenericPurgerSchedulerHelper {
    
    // Schedule batch class for cleaning up Global Error Logger object records every Saturday 4 AM GMT.
    // #SC-146 Added JobNumber parameter
    global void purgeGlobalErrorLogger() {
        String strObjectName = 'Batch_Error_Logger__c';
        Integer jobNumber = 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 04 ? * 7';
        System.schedule('Purge ' + strObjectName + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
    }

    // Schedule batch class for cleaning up Opportunity Splits Schedule object records(older than 2years) every Saturday 5 AM GMT.
    // #SC-146 Added JobNumber parameter
    global void purgeOppSplitSch() {
        String strObjectName = 'Opportunity_Splits_Schedule__c';
        Integer jobNumber = 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 05 ? * 7';
        System.schedule('Purge ' + strObjectName + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
    }
    
    // Schedule batch class for cleaning up Quote Document records every Sunday 4 AM GMT.
    // #SC-146 Added JobNumber parameter
    global void purgeQuoteDocument() {
        String strObjectName = 'QuoteDocument';
        Integer jobNumber = 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 04 ? * 1';
        System.schedule('Purge ' + strObjectName + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
    }
    //SC-2929:Added purgeOOOCase method to automate deletion of OOO cases on the last Sunday of every month.
     global void purgeOOOCase() {
        String strObjectName= 'Case';
        Integer jobNumber=3;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 00 17 ? * 1L';
        System.schedule('Purge OOO ' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);

        
    }

    //Purge Cargo Records which are older than 6 months SC-6296, Every Saturday 6 AM
    global void purgeCargo() {
        String strObjectName= 'Cargo__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 06 ? * 7';
        System.schedule('Purge cargo ' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
    }

    //Purge Equipment Records which are older than 6 months SC-6296, Every Saturday 7 AM
    global void purgeEquipment() {
        String strObjectName= 'Equipment__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 07 ? * 7';
        System.schedule('Purge EquipmentRecords ' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
     }

     //Purge EquipmentStuffing Records which are older than 6 months SC-6296, Every Saturday 8 AM
    global void purgeEquipmentStuffing() {
        String strObjectName= 'Equipment_Stuffing__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 08 ? * 7';
        System.schedule('Purge Equipment Stuffing ' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
     }

     //Purge Party Records which has no associated Shipment or TP_Doc SC-6296, Every Saturday 9 AM
    global void purgeParty() {
        String strObjectName= 'Party__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 09 ? * 7';
        System.schedule('Purge Party' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
     }

     //Purge Shipment Records which are older than 180 Days, Every Saturday 10 AM
    global void purgeShipment() {
        String strObjectName= 'Shipment__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        String strSchTime =  '0 0 10 ? * 7';
        System.schedule('Purge Shipment' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
     }

    //SFSE-14271: Purge Territory Account Association records with End Date lesser than last 5 calendar quarters including the current quarter, first Sunday of every quarter
    global void purgeTAA() {
        String strObjectName= 'Territory_Account_Association__c';
        Integer jobNumber= 1;
        Batch_GenericPurgerScheduler purgeScheduler = new Batch_GenericPurgerScheduler(strObjectName,jobNumber);
        //0 minutes,seconds and hours. No specific day of month. Jan, Apr, July, Oct months. (1#1)First Sunday of the mentioned months.  
        String strSchTime =  '0 0 0 ? 1,4,7,10 1#1';
        System.schedule('Purge Territory Account Association' + strObjectName +' Job #'+jobnumber + (Test.isRunningTest() ? '_Test' : ''), strSchTime, purgeScheduler);
     } 
}