/*
 * Author   : Jiji
 * Purpose  : Utility test class for creating Case related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-002633   06-May-2016 Jiji@UST                Created.
 * 2.0      RQ-004054   25-May-2016 Nisha@UST               Changed the financial types. 
 * 
 */

@isTest
public class FinancialData_Test {
    public static boolean bCreate = true;
    public static integer iNumberOfFinancialDetails = 5;
    public static list<Financial_Details__c> lstFinancialDetails;
    public static Case caseInstance = null;
    //public static List<Case> lstCases = new List<Case>();
    
    public static testMethod void createFinancialRecords() {
        If(caseInstance == NULL){
            CaseData_Test.iNumberOfCases = 1;
            CaseData_Test.createClaimCases();
            caseInstance = CaseData_Test.lstCases[0];       
        }
        List<String> TypeString = new List<String> {'Filed Amount', 
                                                    'Estimated Settlement',
                                                    'Maximum Liability',
                                                    'Cargo Claim Paid',
                                                    'Submitted Amount',
                                                    'P&I Reimbursement',
                                                    'Recovery Obtained',
                                                    'Commercial Claim Paid',
                                                    'Sum of Incurred Cost'
                                                    };
        lstFinancialDetails = new list<Financial_Details__c>();
        for(integer i=0; i<iNumberOfFinancialDetails; i++) {
            Financial_Details__c fdIterator = new Financial_Details__c();
            fdIterator.Claim__c = caseInstance.Id;
            fdIterator.Local_Currency__c = 'INR';
            fdIterator.Local_Amount__c = 1000;
            fdIterator.Type__c = TypeString[i];
            fdIterator.Conversion_Date__c =  System.today();
            lstFinancialDetails.add(fdIterator);
        }
        
        if(bCreate) {
            insert lstFinancialDetails;
        }
    }
}