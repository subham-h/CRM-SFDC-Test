@isTest
global class GetInsuranceAPIMockCallout implements HttpCalloutMock {
    
    global enum request_mode {authToken, getInsurance, getInsuranceRefered}
    request_mode mode;
    
    global GetInsuranceAPIMockCallout(request_mode mode) {
        this.mode = mode;
    }
    
    global HTTPResponse respond(HTTPRequest request) {    
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(mode==request_mode.authToken) {
        response.setStatusCode(200);
        response.setBody('{"idToken":"123456789"}');
        } else if (mode==request_mode.getInsurance) {
        response.setHeader('userId', '1111111111111');
        response.setHeader('requestDate', '$2019-20-07T14:51:13.533');
        response.setBody('{"quoteStatus":"Quote","quoteNotes":[],"quoteId":6495507,"premiumCurrency":"EUR","insuranceRates":[{"commodityCode":"004601","policyRate":3.072,"policyRatePercentage":0.003072}]}');
        response.setStatusCode(201);
        response.setStatus('Created');
        } else if(mode==request_mode.getInsuranceRefered) {
            response.setHeader('userId', '1111111111111');
            response.setHeader('requestDate', '$2019-20-07T14:51:13.533');
            response.setBody('{"method": "POST","requestUri": "/cargoInsurancePolicies/-/cargoInsuranceQuoteRequests","status": 400,"timestamp": "05-01-2020 17:01:56","message": "Validation errors","subErrors": [{"field": "commodityDetailsList[0].commodity","rejectedValue": "1234567890","message": "Commodity code is invalid"}],"id":"2cad7b39-e9c0-4ce5-beb9-a8a5a21a3abf"}');
                //'{"quoteStatus": "Referred","quoteNotes": ["POL009"],"quoteId": 6495607,"premiumCurrency": "EUR","insuranceRates": [{"commodityCode": "004601","policyRate": 0.0,"policyRatePercentage": 0.0}]}');
            response.setStatusCode(400);
            //response.setStatus('Created');
        } else {
            response.setStatusCode(200);
        }
        return response; 
    } 
}