/**
 * An apex page controller that exposes the site forgot password functionality
/****************************************************************************************************************
    Revision    Developer                Date                Story #                 Comments
	1.0         Meghana@UST            2/11/2020           SFSE-5023			In order to upgrade API version, removed test method from this class   

*/

public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
    
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    } 
}