/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-20-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Athena_HttpCallOutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        system.debug('@@@@ test ' + request);
        HTTPResponse response = new HTTPResponse(); 
        if (request.getEndpoint().endsWith('callout:AthenaFetchQuote')) {
            string sampleBody = '{"access_token":"9999999","scope":"openid ..athenaoceanrates.readonly inlandquerysvc.readonly","id_token":"0000000","token_type":"Bearer","expires_in":7199}';            
            response.setBody(sampleBody);
        }else if(request.getEndpoint().endsWith('test')){
        	string sampleBody ='{"id":"55f59770c3a69fea","method":"GET","requestUri":"/athena/v1/assemblerfiles/CP-0008136_1/1","status":500,"statusText":"Internal Server Error","timestamp":"20-05-2024 07:22:15","message":"The specified blob does not exist"}';
        	response.setBody(samplebody);
            response.setStatusCode(400);
		}else{
            string samplebody = 'test123456t6089346759345793485349867593489';
            response.setBody(samplebody);
            response.setHeader('Content-Disposition', 'form-data; name="attachment"; filename="MaerskQuote_CP-0008136_1.xlsx"');
            response.setStatusCode(200);
        }
        return response;
    }
}