@IsTest
public class CustomApprovalProcessErrorMessage_Test {
    @IsTest
    static void testErrorMessageInvocableWithErrorMessageTrue() {
        CustomApprovalProcessHandler.errorMessage = true;
        List<String> expectedErrorMessage = new List<String>{ 'No applicable' };
            
            Test.startTest();
        List<String> actualErrorMessage = CustomApprovalProcessErrorMessage.errormessageInvocable();
        Test.stopTest();
        System.assertEquals(0, actualErrorMessage.size(), 'The result should be an empty list');
    }
    
    @isTest
    static void testErrorMessageInvocableWithErrorMessageFalse(){
        CustomApprovalProcessHandler.errorMessage = False;
        List<String> expectedErrorMessage = new List<String>{ 'No applicable' };
            
            Test.startTest();
        List<String> actualErrorMessage = CustomApprovalProcessErrorMessage.errormessageInvocable();
        Test.stopTest();
        
       
            
}
    
}