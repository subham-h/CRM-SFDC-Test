global class generateAccountPlanHttpCalloutMockImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"compositeResponse":[{"body":{"id":"0681q000005voUkAAI","success":true,"errors":[]},"httpHeaders":{"Location":"/services/data/v49.0/sobjects/ContentVersion/0681q000005voUkAAI"},"httpStatusCode":201,"referenceId":"refCV"}]}');
        res.setStatusCode(200);
        return res;
    }
}