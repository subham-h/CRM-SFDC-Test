@isTest
global class CaseTranslatorMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        string responseString ='[ { "detectedLanguage": { "language": "en", "score": 1.0 }, "translations": [ { "text": "Hello", "to": "en" } ] } ]';
        if (req.getEndpoint().endsWith('en')) {
            responseString ='[ { "detectedLanguage": { "language": "ja", "score": 1.0 }, "translations": [ { "text": "Hello", "to": "en" } ] } ]';
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseString);
        res.setStatusCode(200);
        res.setStatus('Success');
        /*if(req.getMethod().equalsIgnoreCase( 'POST')){
           res.setStatus('Created');
        }*/
        return res;
       }
}