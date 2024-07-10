@isTest
global class CallReportSchedulerErrorCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        string sampleBody = 'Request-URI Too Large';
        response.setBody(sampleBody);
        response.setStatusCode(414);
        return response; 
    }
}