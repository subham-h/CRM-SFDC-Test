@isTest
public class CMD_ServiceHttpCallOutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        system.debug('@@@@ test ' + request);
        HTTPResponse response = new HTTPResponse(); 
        response.setStatusCode(200); 
        if (request.getEndpoint().endsWith('callout:cmd_cdt')) {
            string sampleBody = '{"access_token": "eyJ0eXAiOiJKV1QiL","scope": "contact.write openid","id_token": "eyJ0eXAiOiJKV1QiL","token_type": "Bearer","expires_in": 7199}}';            
            response.setBody(sampleBody);
        } else if (request.getEndpoint().endsWith('/contacts/validate')){
            string samplebody = 'Contact information validated successfully';
            response.setBody(samplebody);
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            return response;
        } else if (request.getEndpoint().contains('/contacts/duplicate?')){
            string samplebody = '{"duplicateContacts":[{"customerCode":"DK00005980","contactCode":"DK00410338","contactExternalSystemIdentifiers":[{"externalSystemName":"CMD","externalSystemReference":"DK00410338","isDeletedFlag":false},{"externalSystemName":"SCV","externalSystemReference":"10000410338","isDeletedFlag":false}],"firstName":"GOYBBB","lastName":"JIIIIIII","role":"CUST_CONT","primaryEmailId":"goyawi9407@lieboe.com","secondaryEmailId":"goyawi10407@lieboe.com","statusCode":"A","isMasterContact":false,"communicationNumbers":[{"communicationNumberType":"TEL","isoCountryCode":"IN","internationalDialingCode":"91","number":"9159585814"},{"communicationNumberType":"MOB","isoCountryCode":"IN","internationalDialingCode":"91","number":"9105585814"},{"communicationNumberType":"FAX","isoCountryCode":"IN","internationalDialingCode":"91","number":"9155565814"}]}]}';
            response.setBody(samplebody);
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            return response;
        } else if (request.getEndpoint().contains('/customers/VN00829521/contacts')){
            string samplebody = '{"contactCode": "IN22527482","contactUpsertStatus": "Contact upsert completed successfully"}';
            response.setBody(samplebody);
            response.setHeader('Consumer-Key', 'E1111111');
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(201);
            return response;
        } else if (request.getEndpoint().endsWith('VN00829521/contacts/IN00527582')){
            string samplebody = 'Contact linked successfully to the customer';
            response.setBody(samplebody);
            response.setHeader('Consumer-Key', 'E1111111');
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            return response;
        } else {
            System.assert(false, 'unexpected endpoint ' + request.getEndpoint());
            return null;
        }
        return response;
    }
}