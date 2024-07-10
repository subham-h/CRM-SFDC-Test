/****************************************************************************************************************
    Revision    Developer                Date                Story #                 Comments
	1.0         Meghana@UST            2/11/2020           SFSE-5023			Test class created   

*/

@IsTest 
public class SiteLoginController_Test {
 	@IsTest public static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}