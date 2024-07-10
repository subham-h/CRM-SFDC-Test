@isTest
global class ShipmentReferenceMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        if(request.getBody().contains('grant_type=client_credentials')){
            response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            response.setBody(getAccessToken());
        }
        else if(request.getEndpoint().contains('/equipment')){
            response.setHeader('Content-Type', 'application/json');
            response.setBody(getContainerReferences());
        }
        else if(request.getEndpoint().contains('/references')){
            response.setHeader('Content-Type', 'application/json');
            response.setBody(getShipmentReferences());
        }
        response.setStatusCode(200);
        return response; 
    }
    
    public static String getAccessToken(){
        return '{"access_token":"eyJ0eXAiOiJKV1QiLCJraWQiOiJ3VTNpZklJYUxPVUFSZVJCL0ZHNmVNMVAxUU09IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJON3ZLYVNubFJHbGRZUU40VnVSRXkyOWQzQUFHYXJBQSIsImN0cyI6Ik9BVVRIMl9TVEFURUxFU1NfR1JBTlQiLCJhdWRpdFRyYWNraW5nSWQiOiIyMzUzZDcyOS01Y2Y4LTRiYmItOGM5Zi03ODQ1OTY4MjdmYTgtODMwMjc4NjEiLCJpc3MiOiJodHRwczovL2lhbS5tYWVyc2suY29tL2FjbS9vYXV0aDIvbWF1IiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoiampLNVJ5MS1CNTduQ1dnazZPb3IxMUNpRzJZIiwiYXVkIjoiTjd2S2FTbmxSR2xkWVFONFZ1UkV5MjlkM0FBR2FyQUEiLCJuYmYiOjE2MjYzMjEyOTcsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6WyJCb29raW5nIiwiY2MuKi5zYWxlc2ZvcmNlLm9wZXJhdG9yIiwiY2MuKi5zYWxlc2ZvcmNlLnJlYWQiLCJjYy4qLnNhbGVzZm9yY2UucmVhZHdyaXRlIiwib3BlbmlkIl0sImF1dGhfdGltZSI6MTYyNjMyMTI5NywicmVhbG0iOiIvbWF1IiwiZXhwIjoxNjI2MzI4NDk3LCJpYXQiOjE2MjYzMjEyOTcsImV4cGlyZXNfaW4iOjcyMDAsImp0aSI6IlFtQ2huMUs0OEJIQVZ4X0F5SzhqU0FsYUhvMCJ9.xqvCLGRjWMaTq7ukr5jKd7qdNBEcud4YHHlaT89ir-AJGItG1l9w15d77r2dLFPWPeSO0C-iqBQmJvcNIL6XVpthxwNPNrI3bD2UvuwBiHGPcae0IlHkva4pwbcfn6b1uOisa9hojl3fWEOJyY2CM5QPUFHvOoMgT4penL0vQkjjq-wefWFwLSxpQd2_dcjD69C8PBMJ6ciuwWkdYCC2RFzFgyjg6J4H8vPK9YSZ6BFGIq6iZo_IBegKaUumUoKeQJ0_I5BtBMZSLC8P9zvy5cDvwmJVTDyVm9AGcCqJqiRejJcMJe1QppkTUtDq1x7Qz1_gFEiVbwpEselQFMLojg","scope":"Booking cc.*.salesforce.operator cc.*.salesforce.read cc.*.salesforce.readwrite openid","id_token":"eyJ0eXAiOiJKV1QiLCJraWQiOiJQbStTdGZEejRmY0tzdk5iUTBscGNETWlyNEk9IiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiaTVUVjFvdEJiQURTc2pXSk00ZGFTUSIsInN1YiI6Ik43dkthU25sUkdsZFlRTjRWdVJFeTI5ZDNBQUdhckFBIiwiYXVkaXRUcmFja2luZ0lkIjoiMjM1M2Q3MjktNWNmOC00YmJiLThjOWYtNzg0NTk2ODI3ZmE4LTgzMDI3ODY1Iiwicm9sZXMiOltudWxsLCJCb29raW5nIl0sImlzcyI6Imh0dHBzOi8vaWFtLm1hZXJzay5jb20vYWNtL29hdXRoMi9tYXUiLCJ0b2tlbk5hbWUiOiJpZF90b2tlbiIsImF1ZCI6Ik43dkthU25sUkdsZFlRTjRWdVJFeTI5ZDNBQUdhckFBIiwiY2FycmllciI6Ik1BRVUiLCJhenAiOiJON3ZLYVNubFJHbGRZUU40VnVSRXkyOWQzQUFHYXJBQSIsImF1dGhfdGltZSI6MTYyNjMyMTI5NywicmVhbG0iOiIvbWF1IiwiZXhwIjoxNjI2MzI4NDk3LCJ0b2tlblR5cGUiOiJKV1RUb2tlbiIsImN1c3RvbWVyX2NvZGUiOiIqLCosKiIsImlhdCI6MTYyNjMyMTI5N30.LNw1gp2jS0jBSWHlstxV0AD5AuDZ6pK3vEu6iR7b2Sr1sT_Yd8oK5UGh7mlMzf1J9tTNbCOBVVmXtLcd9dvTwwdHsX9JVzODFBGD7KYvmdlxCTXIQN23X3BcKwFjDow3IOkGp0G5fMJPwrXxPXyoyAedK7leEduk2CA3IIjt1m1q-ipzbE_1IwRXbE95HcYWqQzkHWc8do4mVSYzmQQ1Du32ZGb-XOiOQM-vA6B3IDs-CbAZVSPnBtz1Hj-srFuRfHFHmtTjMFXRPOfoALkutbQj8hho2PE78nbKgzSaD1fVQRyNTkMIt3FOvseQeNeTKHxwspO45F4j4RaIHkpTzg","token_type":"Bearer","expires_in":7199}';
    }
    
    public static String getShipmentReferences(){
        return '{"shipmentNumber":"910736807","references":[{"referenceType":"Reference","id":"8Q9F5LT6J0LIB","typeId":"1400","name":"Shipment Priority","value":"HOTBOX"},{"referenceType":"Reference","city":"Bremerhaven, Bremen, Germany","country":"Germany","cityId":"3EX4F5S3MB4OU","id":"2AONNFT6J0P3B","typeId":"3LCH6ODKUUD1Q","name":"Cargo HS Code","value":"843061","direction":"Final Vessel Discharge"}]}';
    }
    
    public static String getContainerReferences(){
        return '{"shipmentNumber":"293903431","equipmentAssignmentId":"5YQCDSH460Q3B","references":[{"referenceType":"Reference","id":"MKJOWXPH70Q3B","typeId":"1022","name":"Carrier Seal","value":"CN9331698"}]}';
    }
    
}