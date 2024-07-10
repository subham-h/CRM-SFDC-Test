@isTest
global class LWCHerokuServiceMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        //request.set
        HttpResponse response = new HttpResponse();
        
        response.setHeader('Content-Type', 'application/json');        
        string sampleBody = '';
        response.setBody(sampleBody);
        response.setStatusCode(200);
        
        return response;
        
    }
    
}