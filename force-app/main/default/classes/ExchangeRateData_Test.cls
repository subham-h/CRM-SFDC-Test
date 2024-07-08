/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Incident related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 
*/

@isTest
public class ExchangeRateData_Test {
    
    public static boolean bCreate = true;
    public static list<Exchange_Rate__c> lstExchageRates;
    
    public static testMethod void createExchageRates() {
        if(lstExchageRates == null) {
            lstExchageRates = new list<Exchange_Rate__c>();
            Exchange_Rate__c exchageRateIterator1 = new Exchange_Rate__c();
            exchageRateIterator1.CurrencyISOCode__c = 'USD';
            exchageRateIterator1.ConversionRate__c = 1;
            lstExchageRates.add(exchageRateIterator1);
            
            Exchange_Rate__c exchageRateIterator2 = new Exchange_Rate__c();
            exchageRateIterator2.CurrencyISOCode__c = 'INR';
            exchageRateIterator2.ConversionRate__c = 0.015;
            lstExchageRates.add(exchageRateIterator2);
        }
        
        if(bCreate) {
            upsert lstExchageRates;
        }
    }
    
}