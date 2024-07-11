global class DigitalEngagementUtilityMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        string responseString ='{\"access_token\": \"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiIxUW5mODZRTzVZY3BpOW5odnFhWXRjMEsiLCJjbGllbnRfaWQiOiI5bXFmdDQyc24xYjEzd25kZTdqMTA3NXgiLCJlaWQiOjUyNDAwMTE0MSwic3RhY2tfa2V5IjoiUzEiLCJwbGF0Zm9ybV92ZXJzaW9uIjoyLCJjbGllbnRfdHlwZSI6IlNlcnZlclRvU2VydmVyIiwicGlkIjo2MH0.v-xzGUy2_YglSEOpX9JXMqiFpWitGpUTbO_gIUB8jHY.m_8QFFW74LbZQbweFfHsvl-35lcWiwNgrD7pcVM2DJhKCNvjIampiOJJYKJ3rOFyNSWFNplpHA_7r2cX0W5jozQj1A0WCJy1Dl10zSth6QBcdjwusNb-4OzM6HJBkrdz5r1uU9jUXC2J0Cg79U_kmsZnuloyNfNdJPMgSSAq\",\"token_type\": \"Bearer\",\"expires_in\": 1079,\"scope\":\"offline data_extensions_read\",\"soap_instance_url\": \"https://mczby6dlmvjlss5z9mrfl7z2wn6q.soap.marketingcloudapis.com/\",\"rest_instance_url\": \"https://mczby6dlmvjlss5z9mrfl7z2wn6q.rest.marketingcloudapis.com/\"}';
        if (req.getEndpoint().Contains('0032o00002a9rt7AAA')) {
            responseString ='{\"links\": {\"self\": \"/v1/customobjectdata/token/a3a61a09-fbe3-4c62-b5db-e28e502b0cf2/rowset?$page=1\",\"next\": \"/v1/customobjectdata/token/a3a61a09-fbe3-4c62-b5db-e28e502b0cf2/rowset?$page=2\"},\"requestToken\": \"a3a61a09-fbe3-4c62-b5db-e28e502b0cf2\",\"tokenExpireDateUtc\": \"2024-04-05T08:41:07.543\",\"customObjectId\": \"a4a14322-3356-ee11-ba5e-48df37dc15f6\"\"customObjectKey\": \"4505CB1E-693D-4836-AFCC-3412072B9257\",\"pageSize\": 2500,\"page\": 1,\"count\": 8424683,\"top\": 0, \"items\": [{\"keys\": {\"subscriberkey\": \"0032o00002a9rt7AAA\",\"listid\": \"1858\",\"jobid\": \"4505824\",\"batchid\": \"699\",        \"eventtype\": \"email\"},\"values\": {\"emailname\": \"GLOBAL_MCO_PROD_EN_DIGITAL-LCL-H2_1766168922165_OPR_PROMOTION_ONETIME_BROAD_BRO_DROP3-APA-EN-REM\",\"eventdate\": \"3/9/2024 12:00:52 AM\",\"opened\": \"False\",\"clicked\": \"False\",\"bounced\": \"False\",\"link\": \"\",\"alias\": \"\"}}}';
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