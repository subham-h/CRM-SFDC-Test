/**
 * An apex page controller that exposes the site login functionality
 
 /****************************************************************************************************************
    Revision    Developer                Date            Story #                 Comments
	* 			Nisha@UST  			   04-Nov-2016 		RQ-004464 			Removed SeeAllData=True from testMethod
	2.0         Meghana@UST            2/11/2020        SFSE-5023			In order to upgrade API version, removed test method from this class   
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    
    global SiteLoginController () {}
    
}