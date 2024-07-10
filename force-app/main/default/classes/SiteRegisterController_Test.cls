/****************************************************************************************************************
    Revision    Developer                Date                Story #                 Comments
	1.0         Meghana@UST            2/11/2020           SFSE-5023			Test class created   

*/

@IsTest
public class SiteRegisterController_Test {
 	
    // Test method to bring this class's test coverage over the required 75%
    @IsTest static void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }
}