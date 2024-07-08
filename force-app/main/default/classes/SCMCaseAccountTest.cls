@isTest
global class SCMCaseAccountTest {

    @isTest
    public static void testSCMCase(){
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        Test.setMock(HttpCalloutMock.class, new SCMCaseAccountTest.SCMMock());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/scmcaseaccountextraction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseId":"5001X00000JHL9R","CustomerName_extracted":"Test 1","CustomerName_db":"Test","SONumber":"2312"}');
        RestContext.request = req;
        RestContext.response= res;
        SCMCaseAccount.doPost();
        Test.stopTest();
    }

    @isTest
    public static void testException(){
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        Test.setMock(HttpCalloutMock.class, new SCMCaseAccountTest.SCMMock());
        Test.startTest();
        SCMCaseAccount.doPost();
        Test.stopTest();
    }
    
    global class SCMMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"caseId":"5001X00000JHL9R","CustomerName_extracted":"Test 1","CustomerName_db":"Test","SONumber":"2312"}');
            res.setStatusCode(200);
            return res;
        }
    }
}