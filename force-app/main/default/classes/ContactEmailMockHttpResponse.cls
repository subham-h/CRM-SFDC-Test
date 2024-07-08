/**
* Description : Contact Email validation Mock response class
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 27/03/2019   Nitin@Maersk        RQ-010026   Class created.
*/

@isTest
global class ContactEmailMockHttpResponse implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resEmail = new HttpResponse();
        resEmail.setHeader('Content-Type','application/json');
		resEmail.setBody('{"WebServiceResponse":{"@xmlns":"http://ws.strikeiron.com","SubscriptionInfo":{"@xmlns":"http://ws.strikeiron.com","LicenseStatusCode":"0","LicenseStatus":"Valid license key","LicenseActionCode":"0","LicenseAction":"Decremented hit count","RemainingHits":"1499882","Amount":"0"},"VerifyEmailResponse":{"@xmlns":"http://www.strikeiron.com/","VerifyEmailResult":{"ServiceStatus":{"StatusNbr":"300","StatusDescription":"Email Not Valid"},"ServiceResult":{"Timestamp":"2020-08-21T07:22:27.6938596Z","Email":{"Complete":"test1@test.com","LocalPart":"test1","DomainPart":"test.com"},"Reason":{"Code":"305","Description":"Not A Valid Mail Domain"},"Hygiene":{"HygieneResult":"Invalid","NetProtected":"false"},"SendRecommendation":{"RiskProfile":"Medium Risk","Recommendation":"Do Not Send","RecommendedRetries":"0","RecommendedRetryDelaySeconds":"0"},"DestinationCountry":{"Code":"840","Alpha2Code":"US","Alpha3Code":"USA","Name":"United States of America"},"Cached":"false","Disposable":"true","PotentiallyVulgar":"false","RoleBased":"false"}}}}}');
        //resEmail.setBody(' {"WebServiceResponse": {"@xmlns": "http://ws.strikeiron.com","SubscriptionInfo": {"@xmlns": "http://ws.strikeiron.com","LicenseStatusCode": "0","LicenseStatus": "Valid license key","LicenseActionCode": "0","LicenseAction": "Decremented hit count","RemainingHits": "286","Amount": "0"},"VerifyEmailResponse": {"@xmlns": "http://www.strikeiron.com/","VerifyEmailResult": {"ServiceStatus": {"StatusNbr": "200","StatusDescription": "Email Valid"},"ServiceResult": {"Reason": {"Code": "201","Description": "Mailbox Confirmed"},"HygieneResult": "Safe US","NetProtected": "false","NetProtectedBy": null,"SourceIdentifier": null,"Email": "test_cust_contact@gmail.com","LocalPart": "test_cust_contact","DomainPart": "gmail.com","IronStandardCertifiedTimestamp": {"@xsi:nil": "true","@xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance"},"DomainKnowledge": {"StringKeyValuePair": {"Key": "EmailSegment","Value": "Personal"}},"AddressKnowledge": {"StringKeyValuePair": {"Key": "Cached","Value": "true"}}}}}}}');
        resEmail.setStatusCode(200);
        return resEmail;
    }
}