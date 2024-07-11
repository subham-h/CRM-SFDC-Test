/*
Description  : On SIP cut off day of quarter copy brand owner Ids to respective brand owner text fields in Account.

* version       Date                Owner                                       Description
*******************************************************************************************************
* V1.0          09/06/2016          meghana.gupta@ust-global.com          RQ-004052: 
* 2.0           26/09/2017          Nisha.Arjunan@ust-global.com          RQ-005636 : Update references of GlobalErrorLogger

------------------------------------------------------------------------------------------------------
*/
global class BatchSIPCutOffAccountUpdate implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start( Database.BatchableContext BC ){        
        
        // get all client accounts
        String soqlQuery = 'select id, name, Maersk_Owner_Text__c, MCC_Owner_Text__c, MLL_Owner_Text__c, Safmarine_Owner_Text__c, Seago_Owner_Text__c, ';
        soqlQuery += ' Sealand_Owner_Text__c, MSL_Account_Owner__c, MCC_Account_Owner__c, Seago_Account_Owner__c, MLL_Account_Owner__c, SEA_Account_Owner__c ';
        soqlQuery += ' from Account where recordtypeid = \'' + Label.Client_Account_Record_Type_Id + '\' ';
        
        return Database.getQueryLocator(soqlQuery);     
        
    }
    
    global void execute( Database.BatchableContext info, List<SObject> Scope ){
        
        List<Account> acclist = ( List<Account> ) Scope;    //Accounts to be Updated        
        for( Account acc: accList ){
            
            // copy brand owners to corresponding text fields
            acc.Maersk_Owner_Text__c = acc.MSL_Account_Owner__c;
            acc.MCC_Owner_Text__c = acc.MCC_Account_Owner__c;
            acc.MLL_Owner_Text__c = acc.MLL_Account_Owner__c;
            //acc.Safmarine_Owner_Text__c = acc.SCL_Account_Owner__c;
            acc.Seago_Owner_Text__c = acc.Seago_Account_Owner__c;
            acc.Sealand_Owner_Text__c = acc.SEA_Account_Owner__c;
            
        }
        
        if (Test.isRunningTest()){
            
            accList[0].name = 'Test Running';
            
        }
                
        TriggerExecutionController.skipAccountTrigger(true);
        ErrorStormHandler.skipErrorStormCheck(true);
        List<Database.SaveResult> AccountUpdateResultList = Database.update( accList, false );
        TriggerExecutionController.skipAccountTrigger(false);       
        ErrorLogger.writeErrors('SFDC', 'Account', 'BatchSIPCutOffAccountUpdate.execute()', AccountUpdateResultList, accList) ; // #RQ-005636
                
    }
    
    global void finish( Database.BatchableContext BC ) {
        
        
    }
    
}