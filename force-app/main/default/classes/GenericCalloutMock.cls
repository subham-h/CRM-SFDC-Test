/*
Description  : Generic Mock Callout Class 

* version    Ref Number     Date               Owner                              Description
*******************************************************************************************************************
* 1.0        SC-2784        25/08/2021         Richa@maersk.com                   Generic mock callout class 
*-------------------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class GenericCalloutMock implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<string , String> responseHeaders;

    public GenericCalloutMock(Integer code, String status, String body, Map<String,String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {        
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}