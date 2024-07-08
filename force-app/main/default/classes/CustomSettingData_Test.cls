/*
 * Author   : Nisha
 * Purpose  : Utility test class for creating Custom Setting related data. 
 *
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-003324    06-Jun-2016 Nisha.Arjunan@UST       Created.
 * 2.0	    SC-146	     03-Apr-2020 Avinash@UST		     Call Task Deletion - Rolling 3 Year Window
 */
@isTest
public class  CustomSettingData_Test{
    
    // #SC-146 - Added Value for Order (Required Field)
    public static testMethod void createCleanupTestData(){          
        Purge_Configuration__c customCln1 = new Purge_Configuration__c(Name = 'Account1',
        Object_Name__c = 'Account',
        Field_Name__c = 'AnnualRevenue',
        Order__c = 1,
        Job_Number__c = 1,
        Operation__c = '<=',
        Value__c = '12345');
        insert customCln1;
        
        DateTime dt = DateTime.now();
        String strDatetime = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''); 
        Purge_Configuration__c customCln = new Purge_Configuration__c(Name = 'Account2',
        Object_Name__c = 'Account',
        Field_Name__c = 'LastModifiedDate',
        Order__c = 1,
        Job_Number__c = 1,
        Operation__c = '<',
        Value__c = strDatetime);
        insert customCln; 
        
        //SC-2929
        Purge_Configuration__c customCln2 = new Purge_Configuration__c(Name = 'Spam OOO Case',
        Object_Name__c = 'Case',
        Field_Name__c = 'Accountid',
        Job_Number__c = 3,                                                             
        Operation__c = '!=',
        Days_To_Skip__c=0 ,                                                              
        No_Of_Days_To_Delete__c=35,                                                              
        Value__c ='NULL');
        insert customCln2;
        
    }
}