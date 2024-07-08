public class TestMockClass implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('apikey','accessToken');
        res.setHeader('Content-Type', 'application/json');
        String reqbody = ('{"status":200}');
        res.setBody(reqbody);
        res.setStatusCode(200);
        return res;
        
        
    }
    
}