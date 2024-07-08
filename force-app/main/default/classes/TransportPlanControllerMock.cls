@isTest
global class TransportPlanControllerMock implements HttpCalloutMock{
global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
    	string sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W"}';
         response.setBody(sampleBody);
        response.setStatusCode(200);
        return response; 
    }
}