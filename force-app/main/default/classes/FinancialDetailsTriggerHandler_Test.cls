/*
 This is the test class for FinanceTriggerHandler
** Version    Date            Owner                                               RQ#                 Description
*********************************************************************************************************************************  
* 1.0        12/03/2016       Sandhya.Sambasivan@ust-global.com                  #SP-0032           Code created
*/
@isTest
public class FinancialDetailsTriggerHandler_Test {

    //Test method to call webservice when finance record is inserted
    public static testmethod void test_InsertFinanceRecord (){
        
        FinancialData_Test.bCreate = false;
        FinancialData_Test.iNumberOfFinancialDetails = 5;
        
        list<Financial_Details__c> lstFinancialDetails = new list<Financial_Details__c>();
        FinancialData_Test.createFinancialRecords();
        lstFinancialDetails.addAll(FinancialData_Test.lstFinancialDetails);
        
        Test.startTest();
        insert lstFinancialDetails;
        Test.stopTest();
        
        Set<Id>finIdSet = new Set<Id>();
        for(Financial_Details__c f : lstFinancialDetails)
        {
            finIdSet.Add(f.Id);
        }

        List<Financial_Details__c> finRec = [Select Id from Financial_Details__c WHERE Id IN : finIdSet];
        system.assertEquals(5, finRec.size());
    
    }
    //Test method to call webservice when finance record is updated
    public static testmethod void test_InsertUSDFinanceRecord (){
        FinancialData_Test.bCreate = false;
        FinancialData_Test.iNumberOfFinancialDetails = 5;
        
        list<Financial_Details__c> lstFinancialDetails = new list<Financial_Details__c>();
        FinancialData_Test.createFinancialRecords();
        lstFinancialDetails.addAll(FinancialData_Test.lstFinancialDetails);
        
        
        for(Financial_Details__c f : lstFinancialDetails)
        {
            f.Local_Currency__c = 'USD';
        }
        
        Test.startTest();
        Insert lstFinancialDetails;
        Test.stopTest();
        Set<Id>finIdSet = new Set<Id>{lstFinancialDetails[0].Id, 
                                      lstFinancialDetails[1].Id, 
                                      lstFinancialDetails[2].Id, 
                                      lstFinancialDetails[3].Id, 
                                      lstFinancialDetails[4].Id};
        List<Financial_Details__c> finRec = [Select Id, Local_Amount__c, USD_Amount__c from Financial_Details__c WHERE Id IN : finIdSet];
        system.assertEquals(5, finRec.size());
        system.assertEquals(finRec[0].Local_Amount__c, finRec[0].USD_Amount__c);
    }
    //Test method to call webservice when finance record is updated
    public static testmethod void test_UpdateFinanceRecord (){
        
        FinancialData_Test.iNumberOfFinancialDetails = 5;
        
        list<Financial_Details__c> lstFinancialDetails = new list<Financial_Details__c>();
        list<Financial_Details__c> lstFinancialDetailsforUpdate = new list<Financial_Details__c>();
        FinancialData_Test.createFinancialRecords();
        lstFinancialDetails.addAll(FinancialData_Test.lstFinancialDetails);
        
        Set<Id>finIdSet = new Set<Id>();
        for(Financial_Details__c f : lstFinancialDetails)
        {
            f.Recalculate_XRate__c = True;
            finIdSet.Add(f.Id);
            lstFinancialDetailsforUpdate.add(f);
        }
        Test.startTest();
        Update lstFinancialDetailsforUpdate;
        Test.stopTest();
        
        List<Financial_Details__c> finRec = [Select Id, Recalculate_XRate__c from Financial_Details__c WHERE Id IN : finIdSet];
        system.assertEquals(5, finRec.size());
        system.assertEquals(False, finRec[0].Recalculate_XRate__c);
    }
}