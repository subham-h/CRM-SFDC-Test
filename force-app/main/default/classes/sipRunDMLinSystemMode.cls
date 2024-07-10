/*
* Version		Story #			Date		    Developer		    Comments 
*  1.0			SFSE-8142		12/10/2022	    Bharti@Maersk		Code created
* Test Class : sipSearchAndBulkCreateCntrl_Test
*/
public without sharing class sipRunDMLinSystemMode {
    
    /*This method is to perform DML operation in system mode on Employee_HR_Data__c object, where user has Read access
* Performing simple DML Operation with AllOrNone so that SOM will get exception if any DML fails
*/ 
    public static String performDMLAsAdmin(List<Employee_HR_Data__c> listEmp, List<SIP_Participant__c> sipList ){
        
        String strResponseMessage = 'success';
        
        Savepoint sp = Database.setSavepoint();
        
        if(!sipList.isEmpty()){
            try{
                upsert sipList;
            }
            catch(DmlException de){
                strResponseMessage = de.getMessage();
                ErrorLogger.writeError('SFDC', 'SIP-Manage SIP Page', 'sipSearchAndBulkCreateCntrl.createSIPrecords', de.getTypeName(), de.getMessage(), de.getMessage());
            }
        }
        system.debug('strResponseMessage'+strResponseMessage);
        if(!listEmp.isEmpty() && strResponseMessage == 'success'){
            try{
                update listEmp;
            }
            catch(DmlException de){
                Database.RollBack(sp);
                strResponseMessage = de.getMessage();
                ErrorLogger.writeError('SFDC', 'SIP-Manage SIP Page', 'sipSearchAndBulkCreateCntrl.createSIPrecords', de.getTypeName(), de.getMessage(), de.getMessage());
                
            }
        }
        
        return strResponseMessage;
    }
}