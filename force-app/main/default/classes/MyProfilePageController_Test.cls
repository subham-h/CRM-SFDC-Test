/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
 * Guest users are never able to access this page.
 * 
 * Ref Number  Date        Owner                                  Description
 * ----------  ----        -----                                  -----------
 * RQ-004464   04-11-2016  Nisha@UST                              Removed SeeAllData=True
 * RQ-007596   05-01-2018  Meenakshi.rajasekaran@USTglobal.com    Removed SeeAllData=True from testSetContactFields method
 * SPI-100     08-06-2022  Ronnie@SF                              Removed brand hardcoding
 */
@IsTest public with sharing class MyProfilePageController_Test {
    public static testmethod void testSetContactFields() {
        //User u = [select title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                           //FROM User WHERE id =: UserInfo.getUserId()];
       UserDataGeneratorHelper_Test.initializeSystemAdminUser();
       User u = UserDataGeneratorHelper_Test.MSLsystemAdminUser;
        //u.email= 'Sasdger65wefa@maersk.com';
        u.mobilephone = '+91 1234563445';
        //u.country = 'India';
        update u;
        Contact c = new Contact();
        MyProfilePageController.setContactFields(c, u);
        system.debug(c);
        System.assertEquals(c.firstname, u.firstname, 'firstname should have been set as the firstname of the user for the contact');
        System.assertEquals(c.lastname, u.lastname, 'lastname should have been set as the lastname of the user for the contact');
    }

    public static testmethod void testSave() {
        
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
        
           User currentUser = [SELECT id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                               FROM User WHERE id =: UserInfo.getUserId()];
            
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);
            
            Account clientAcc = AccountDataHelper_Test.createClientAccount();
            
            Contact c = new Contact();
            c.LastName = 'TestContact';
            c.AccountId = clientAcc.id;
            c.title = currentUser.title;
            c.firstname = currentUser.firstname;
            c.lastname = currentUser.lastname;
            c.email = 'currentuser@gmail.com';
            c.phone = currentUser.phone;
            c.mobilephone = '+44 1111212212';
            c.fax = currentUser.fax;
            c.Liner_brands__c = BrandUtilities.MAERSKLINE;
            c.mailingstreet = currentUser.street;
            c.mailingcity = currentUser.city;
            c.mailingstate = currentUser.state;
            c.mailingpostalcode = currentUser.postalcode;
            c.mailingcountry = currentUser.country;
            System.runAs(UserDataGeneratorHelper_Test.integrationUser){   
                insert c;
            }
            
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }

            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }
}