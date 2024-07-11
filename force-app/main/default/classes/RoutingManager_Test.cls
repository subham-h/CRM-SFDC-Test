/*
* Author   : Urvish@UST
* Purpose  : Test class for RoutingManager Rest resource class.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2149    27-07-2021    Urvish@UST               Created.
* 2.0      SC-4822    07-04-2022    Sriram@maersk            Updated
*/

@isTest
public class RoutingManager_Test {
    
    @isTest public static void testdoGetph(){
        Test.startTest();
        TriggerExecutionController.skipAccountTrigger(true);
        createRoutingRecord();
        
        TriggerExecutionController.skipAccountTrigger(false);
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/routing'; 
        req.params.put('ani', '123456789');
        req.params.put('dnis', '1234567890');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RoutingManager.RoutingWrapper response = new RoutingManager.RoutingWrapper();
         response = RoutingManager.doGet();
         Test.stopTest(); 
        
    }
    
    @isTest public static void testdoGetooo(){
        
        Test.startTest();
        TriggerExecutionController.skipAccountTrigger(true);
        createRoutingRecord();
        
        TriggerExecutionController.skipAccountTrigger(false);
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/routing'; 
        req.params.put('ani', '123456789');
        req.params.put('pin', '1234');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RoutingManager.RoutingWrapper response = new RoutingManager.RoutingWrapper();
         response = RoutingManager.doGet();
         Test.stopTest(); 
        
    }
    
    @isTest public static void testdoGeterror(){
        
       Test.startTest();
        TriggerExecutionController.skipAccountTrigger(true);
        createRoutingRecord();
        
        TriggerExecutionController.skipAccountTrigger(false);
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/routing'; 
        req.params.put('ani', '123456789');
        req.params.put('dnis', '1234567812');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RoutingManager.RoutingWrapper response = new RoutingManager.RoutingWrapper();
         response = RoutingManager.doGet();
         Test.stopTest(); 
        
    }

    public static void createRoutingRecord(){
        
        list<Account> lstClientAccounts = new list<Account>();
        AccountData_Test.iNumberOfAccounts = 1;
        AccountData_Test.createClientAccounts();
        lstClientAccounts =AccountData_Test.lstAccounts;      
        lstClientAccounts[0].SCV_Status__c = 'Suspended';
        lstClientAccounts[0].Customer_Status_Reason__c = 'Unethical Behaviour';
        update lstClientAccounts;
        
        UserData_Test.iNumberOfUsers = 1;
        UserData_Test.createCustomerusers();
        
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createInternalContacts();
        
        UserData_Test.lstUsers[0].Email = ContactData_Test.lstContacts[0].Email;
        
        ContactData_Test.lstContacts[0].Telephony_Agent_ID__c = '123';
        update UserData_Test.lstContact[0];
        update UserData_Test.lstUsers[0];
        update ContactData_Test.lstContacts[0];
        
        Routing_Maersk__c objRouting = new Routing_Maersk__c();
        objRouting.ANI__c = '+1 23456789';
        objRouting.Main_Line_Number__c = '+1 234567890';
        objRouting.Site_Code__c = 'tests';
        objRouting.Primary_Target__c = ContactData_Test.lstContacts[0].Id;
        objRouting.Contact__c = ContactData_Test.lstContacts[0].Id;
        objRouting.Account__c = lstClientAccounts[0].id;
        insert objRouting;
        
        OutOfOffice obj = new OutOfOffice();
        obj.UserId = UserData_Test.lstUsers[0].Id;
        obj.StartDate = system.today();
        obj.EndDate = system.today();
        obj.Message = 'Public Holiday';
        insert obj;
    }

}