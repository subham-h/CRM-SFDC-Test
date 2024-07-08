/**
* Description : Mock response class

* Date         Owner                                                    Description
*************************************************************************************************************************************
* 19/04/2017   meghana.gupta@ust-global.com               cluAP release 1: Code Created
* 02/01/2019   Junaid.Khader@ust-global.com               Content in setBody Changed for code coverage improvement.
*/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json;charset=utf-8');
        //res.setBody(' {"message":"","success":true,"code":0,"metadata":"","data":[{"actuals_summary":15960.5,"route_dir":"1CE","cy_summary":1359,"sumactualffe":500}]}');
        res.setBody(' { "message":"", "success":true, "code":0, "metadata":"", "data":[{ "actuals_summary":15960.5, "route_dir":"1CE", "cy_summary":1359, "sumactualffe":500, "sumcy": 500, "sumrevenue": 500, "origin_city__code": "Lon", "destination_city_code": "DXB", "origin_cluster__code": "Abc", "destination_cluster__code": "Def" }]}');
        res.setStatusCode(200);
        return res;
    }
}