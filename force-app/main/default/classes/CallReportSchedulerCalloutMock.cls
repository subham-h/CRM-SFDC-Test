@isTest
global class CallReportSchedulerCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        string sampleBody = '"__ROW_TYPE",__INTERVAL,ev-1615542247395,_0,_1,_2,_3,_4,_5,_6'+ '\n' +
            '3,0,null,701.0,0.0,505.0,59.0,96.0,534.0,0.0'+ '\n' +
            '0,1615852800000,Panama (PA),246.0,0.0,195.0,12.0,15.0,219.0,0.0'+ '\n' +
            '0,1615852800000,Costa Rica (CR),131.0,0.0,62.0,30.0,46.0,80.0,0.0'+ '\n' +
            '0,1615852800000,Israel (IL),121.0,0.0,113.0,2.0,1.0,89.0,0.0'+ '\n' +
            '0,1615852800000,United Kingdom (GB),82.0,0.0,43.0,5.0,18.0,49.0,0.0'+ '\n' +
            '0,1615852800000,Dominican Republic (DO),40.0,0.0,27.0,3.0,4.0,30.0,0.0'+ '\n' +
            '0,1615852800000,Turkey (TR),37.0,0.0,35.0,0.0,0.0,35.0,0.0'+ '\n' +
            '0,1615852800000,Venezuela (VE),24.0,0.0,17.0,3.0,5.0,19.0,0.0'+ '\n' +
            '0,1615852800000,Sweden (SE),13.0,0.0,13.0,0.0,0.0,13.0,0.0'+ '\n' +
            '0,1615852800000,Slovenia (SI),7.0,0.0,0.0,4.0,7.0,0.0,0.0';
        response.setBody(sampleBody);
        response.setStatusCode(200);
        return response; 
    }
}