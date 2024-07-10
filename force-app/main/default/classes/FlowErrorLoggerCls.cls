public class FlowErrorLoggerCls {
    @InvocableMethod
    public static void callErrorLoggerClass(List<ReturnVariables> flowValues){
        Integer count = 0;
        try{
            for(ReturnVariables rv:flowValues){
               system.debug('Error message' +rv.flowMessage); 
               Flow_ErrorLogger.createErrorLogger(rv.flowMessage);
               count++;
                //if(count==1)
                    //break;
            }
        }catch(Exception e){
            ErrorLogger.writeError('SFDC', 'Global error Logger', 'FlowErrorLoggerCls.callErrorLoggerClass', e.getTypeName(), e.getMessage(), e.getStackTraceString());    
            
        }

    }
    
    public class ReturnVariables{
        @invocablevariable
        public List<string> flowMessage;
        
      
    }
}