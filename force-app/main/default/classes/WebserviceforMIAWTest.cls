@isTest
public class WebserviceforMIAWTest{
    @isTest
    public static void testGetCaseInfo(){       
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getTokenforMessagingForWeb/test.test@abc.com';
        req.httpMethod = 'Get';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        WebserviceforMIAW.doGet();
        Test.stopTest();
    }
}