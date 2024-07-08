/**
 * Date         Owner            Description
 ************************************************************************************************************
 * 20/10/2022  Sidhartha@Maersk  mock class for PowerBiEmbedManagerCtrl.
 */
@isTest
global class PowerBIEmbedManagerMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/x-www-form-urlencoded');
        res.setBody('{"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJ"}');
        res.setStatusCode(200);
        return res;
    }
}