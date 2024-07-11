/****************************************************************************************************************
    Revision    Developer                Date                Story #                 Comments
	1.0         Meghana@UST            2/11/2020           SFSE-5023			Test class created   

*/

@IsTest 
public class ForgotPasswordController_Test {
 @IsTest public static void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
}