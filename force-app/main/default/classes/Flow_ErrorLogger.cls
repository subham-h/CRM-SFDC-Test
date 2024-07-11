public class Flow_ErrorLogger {
    
    
    @future
    public static void createErrorLogger(List<String> errorMessage){
        system.debug('Inside Future');
        system.debug('## errorMessage size: ' + errorMessage.size());
        List<Batch_Error_Logger__c> globalErrors=new List<Batch_Error_Logger__c>();
        
        try{
            for(string errMsg:errorMessage){
                
                system.debug('## errMsg: ' + errMsg);
                
                Batch_Error_Logger__c globalErrorLogger = new Batch_Error_Logger__c();
                String nameString = 'Stale User Flow';
                globalErrorLogger.Name = nameString+ ''+' - ' + System.now().format();
                globalErrorLogger.Source_System__c = 'SFDC';
                globalErrorLogger.Object__c = 'User';
                globalErrorLogger.Batch_Name__c = 'Stale User Flow';
                globalErrorLogger.Operation_Type__c = 'User Update';
                globalErrorLogger.Exception_Summary__c = errMsg.left(254) ;
                system.debug('## errLogger: ' + globalErrorLogger);
                globalErrors.add(globalErrorLogger);
            }
            if(!globalErrors.isEmpty())
            database.insert (globalErrors);
            
        }catch(DMLException e){
            system.debug(e.getMessage());
            //ErrorLogger.writeError('SFDC', 'Global error Logger', 'Flow_ErrorLogger.createErrorLogger', e.getTypeName(), e.getMessage(), e.getStackTraceString());    
            
        }
        
        
    }
    
}