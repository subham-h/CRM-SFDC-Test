public class CustomApprovalProcessErrorMessage {
   @InvocableMethod(label='Error Message' description='No Applicable Process found')
    public static List<String> errormessageInvocable(){
        if(CustomApprovalProcessHandler.errorMessage){
            system.debug(CustomApprovalProcessHandler.lsterrorMessage);
            return CustomApprovalProcessHandler.lsterrorMessage;
        }
        else{
            return CustomApprovalProcessHandler.lsterrorMessage;  
        }     
    }
}