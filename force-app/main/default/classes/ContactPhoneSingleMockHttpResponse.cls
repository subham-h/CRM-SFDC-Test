/**
* Description : Contact Phone Single validation Mock response class
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 27/03/2019   Nitin@Maersk        RQ-010026   Class created.
*/

@isTest
global class ContactPhoneSingleMockHttpResponse implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resPhoneSingle = new HttpResponse();
        resPhoneSingle.setHeader('Content-Type','application/json');
        resPhoneSingle.setBody('{"WebServiceResponse":{"@xmlns":"http://ws.strikeiron.com","SubscriptionInfo":{"@xmlns":"http://ws.strikeiron.com","LicenseStatusCode":"0","LicenseStatus":"Valid license key","LicenseActionCode":"0","LicenseAction":"Decremented hit count","RemainingHits":"82","Amount":"0"},"ValidateNumberBatchResponse":{"@xmlns":"http://www.strikeiron.com","ValidateNumberBatchResult":{"ServiceStatus":{"StatusNbr":"211","StatusDescription":"Data returned for all input numbers"},"ServiceResult":{"Results":{"GlobalPhoneEntryWithStatus":{"ItemStatus":{"StatusNbr":"201","StatusDescription":"Valid Number"},"Listing":{"Number":"918046562674","CountryCode":"91","InternationalPrefix":"00","NationalPrefix":"0","CellPrefix":null,"NDC":"80","SN_From":"40000000","SN_To":"49999999","Uses_NDC":"true","Number_Type":"LandLine","CarrierName":"Bharti Airtel Ltd","Language":"hi","Country":"356","ISO":"IN","RegionCode":"KA","RegionName":"Karnātaka","City":"Bangalore","TimeZone":"Asia/Kolkata","UTC":"+05:30","DST":"false","Latitude":"12.977063","Longitude":"77.58710600000001","ErrorCode":"NoError","NationalFormat":"080 4656 2674","InternationalFormat":"+91 80 4656 2674","E164Format":"+918046562674","LinkFormat":"tel:+91-80-4656-2674"}}}}}}}}');           
        resPhoneSingle.setStatusCode(200);
        return resPhoneSingle;
    }
}