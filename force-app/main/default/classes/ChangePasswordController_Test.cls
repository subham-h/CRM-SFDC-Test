/****************************************************************************************************************
    Revision    Developer                Date                Story #                 Comments
	1.0         Meghana@UST            2/11/2020           SFSE-5023			Test class created   

*/

@IsTest
public class ChangePasswordController_Test {
	
    @IsTest public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}