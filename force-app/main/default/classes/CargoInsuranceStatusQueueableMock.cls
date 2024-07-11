@isTest
global class CargoInsuranceStatusQueueableMock implements HttpCalloutMock {  

    global enum request_mode {authToken, priceOwnerchk, priceOwnerchkng, getInsurance}
    request_mode mode;
    public CargoInsuranceStatusQueueableMock(request_mode mode) {
        this.mode = mode;
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(mode==request_mode.authToken) {
            response.setStatusCode(200);
            response.setBody('{"idToken":"123456789"}');
        } else if(mode==request_mode.priceOwnerchk) {
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"agreementId": 0,"insuranceAvailable": [{"insuranceStatusCode": 1,"insuranceStatusNote": "Insurance available and customer does not have PAYG agreement"}],"minimumPremiumAmount": 45,"minimumPremiumAmountCurrencyCode": "EUR"}');
        } else if(mode==request_mode.priceOwnerchkng) {
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"agreementId": 0,"insuranceAvailable": [{"insuranceStatusCode": 3,"insuranceStatusNote": "Insurance not available for the Price Owners Country"}]}');
        }
        return response; 
    }  
}