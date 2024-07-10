@isTest
global class DO_PostDOHttpCalloutMock implements HttpCalloutMock{
   
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        system.debug('--request----'+request);
        if (request.getEndpoint().contains('access_token')) {
             
            //string sampleBody = '{"id_token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJuRWhqWXFQQUpwQ2NjOTBPYnR4eXZ4a3dvKzA9IiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiU0h3MVBKSVZLNm9SdEd4NElnNFRGdyIsInN1YiI6ImUyZWluc3VyYW5jZS1wcm9kIiwiZmlyc3RuYW1lIjoiU2FsZXNmb3JjZSIsImN1c3RvbWVyU3RhdGUiOiIxMDEwIiwiYXVkaXRUcmFja2luZ0lkIjoiNmU0NGFjM2QtNDQ5Mi00OWI4LWE2MTYtNmJmYTU1NmVmZWQ2LTgwOTk3NDQwIiwicm9sZXMiOlsiRG9jdW1lbnRhdGlvbiIsIkJvb2tpbmciLCJXQk9MQXBwcm92ZXIiLCJCYXNpY0N1c3RvbWVyIiwiQ29udHJhY3RSYXRlIiwiTWFlcnNrSW50ZXJuYWwiXSwiaXNzIjoiaHR0cHM6Ly9pYW0ubWFlcnNrLmNvbS9hY20vb2F1dGgyL21hdSIsInRva2VuTmFtZSI6ImlkX3Rva2VuIiwib2ZmaWNlIjoiWlpaIEVVUiBFTVBUWSAtIERLIiwiYWNyIjoiMCIsImF6cCI6ImJjYTAwMSIsImF1dGhfdGltZSI6MTU4MDc4ODQ2MiwicGVyc29uaWQiOiIxMDAwMDI0NTM4NyIsImV4cCI6MTU4MDc5NTY2MywiY3VzdG9tZXJfY29kZSI6IjEwMDAwMDA3OTUxIiwiaWF0IjoxNTgwNzg4NDYzLCJlbWFpbCI6InNhbGVzZm9yY2Uuc3lzdGVtQG1hZXJzay5jb20iLCJub25jZSI6Ik9rcFBTTUxxcEhnTUdXYUtQTVk3eSIsImxhc3RuYW1lIjoiU2FsZXNDbG91ZCIsImF1ZCI6ImJjYTAwMSIsImNhcnJpZXIiOiJNQUVVIiwib3JnLmZvcmdlcm9jay5vcGVuaWRjb25uZWN0Lm9wcyI6IlJpTUZ5LUFUMXBZTTJwTnE5Q3RjSWpiTWFhOCIsInJlYWxtIjoiL21hdSIsInRva2VuVHlwZSI6IkpXVFRva2VuIiwidXNlcm5hbWUiOiJlMmVpbnN1cmFuY2UtcHJvZCJ9.V7nrJguSviASTW2SY8XpudqB9MW3HzsD0SFKlofhezCYRV7c_KfT2t_i5SlSrCt1UHRRgUC3C-ZPw1MxyIwTvxZmnnVaK0bDrZNEVgZPtpWirsXak_DJHjCTdCVBJc6_LR7N3Pt_YmMAOkzptK3DYmTKe5sk0_J20yi6fIymr8dB4NSDNGD8WzoipprShHQAYTI9osvUguVlrBmQUAZJGrgkAYmjQxIwN3UFug8ZQ1UkQ6qpOhIRrG8gvnYjPyfip3rNEFYlLSdpcFu9oKi9Df-Ok9QEaUdh5VYn7EPlN-FZgUr4qLjOiATFX7tkIDfli42ISVtFkqx5zCcbTeGzlw","accessToken": "eyJ0eXAiOiJKV1QiLCJ6aXAiOiJOT05FIiwia2lkIjoid1UzaWZJSWFMT1VBUmVSQi9GRzZlTTFQMVFNPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJlMmVpbnN1cmFuY2UtcHJvZCIsImN0cyI6Ik9BVVRIMl9TVEFURUxFU1NfR1JBTlQiLCJhdXRoX2xldmVsIjowLCJhdWRpdFRyYWNraW5nSWQiOiI2ZTQ0YWMzZC00NDkyLTQ5YjgtYTYxNi02YmZhNTU2ZWZlZDYtODA5OTc0MzkiLCJpc3MiOiJodHRwczovL2lhbS5tYWVyc2suY29tL2FjbS9vYXV0aDIvbWF1IiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoid05pck1TcTg1akdXU0Rpa0d1ZlpBdUJuLVVRIiwibm9uY2UiOiJPa3BQU01McXBIZ01HV2FLUE1ZN3kiLCJhdWQiOiJiY2EwMDEiLCJuYmYiOjE1ODA3ODg0NjMsImdyYW50X3R5cGUiOiJ0b2tlbiIsInNjb3BlIjpbIm9wZW5pZCIsInByb2ZpbGUiLCJlbWFpbCJdLCJhdXRoX3RpbWUiOjE1ODA3ODg0NjIsInJlYWxtIjoiL21hdSIsImV4cCI6MTU4MDc5NTY2MywiaWF0IjoxNTgwNzg4NDYzLCJleHBpcmVzX2luIjo3MjAwLCJqdGkiOiJTZlBUYTV5ZWdQRzBBbTdTbXItbzA2TEV0eXcifQ.wvixA3jtNnhp43_RN7PeRvxJ_ZFutuR8F4cGGUgn_bSoGzVSLO3d-aDW4iJB7Ze6qrb_HmOGobHzJ7oEptX_bkNOuOqJkLDwRnx5UQFDN4R6JIx9TYEdF0Y6fz2jaOGmVsHC8sa0hcuh5NvtFtb55J9I45lVJqAxWIhBX634lkFO_HujmDxXuBFDfdTpOoRfsQB3rckXsHc4wLnWWYp5-6pKFhLT8CpnaYmMqW5hfZdAQJ_N_HkVfJnJUUI5VuYAYUOFQfGjRp8eRQmG-BGwERJegfYzFV4MLTDkdkJTwPuT2G8j2QwyHHbThzXkUpRpinWxfr7if2YZ5PTctQWrPA"}';            
            //string sampleBody = '{ "access_token": "eyJ0qKZuv6XyAQ", "scope": "MaerskInternal openid","id_token": "eyJ0eXAiOVuIiwiYXVkIjoieEREQjh4aW5OZmpxRzNsSEZ4TkJHQ1JHd01FTzJNalIiLCJjYXJyaWVyIjoiTbSI6Ii9tYXUiLCJleHAiOjE2MzIyNTM2NDIsInRva2VuVHlwZSI6IkpXVFRva2VuIiwiaWF0IjoxNjMyMjQ2NDQyfQ.LjO-2rv0W26zx4x8msWpxcj7q46bYDDgO30PysfOtymKMmYi3rjZXXD_Ia86oDWVgitfvL3V9JT1kqmYCT8u0kXOJCvqquBgU_XyqHehJmRQJLUBRvXogyNF_TJEsjkiPI-AveD8hThOad62YQK7e0hVN_JznKXN6eLlEc_QyHtElxoDuY_3G1ohy2Mj0K1s5nUFbExMqcfHhN6Kw2FYMVeN8uhh_zvmDhJlVw_eSKyc6Y0jSA",  "token_type": "Bearer", "expires_in": 7199}';
            string sampleBody = '{ "access_token": "eyJ0qKZuv6XyAQ", "scope": "MaerskInternal openid","id_token": "eyJ0eXAiOVuIiwiYXVkIjoieEREQjh4aW5OZmpxRzNsSEZ4TkJHQ1JHd01FTzJNalIiLCJjYXJyaWVyIjoiTbSI6Ii9tYXUiLCJleHAiOjE2MzIyNTM2NDIsInRva2VuVHlwZSI6IkpXVFRva2VuIiwiaWF0IjoxNjMyMjQ2NDQyfQ.LjO-2rv0W26zx4x8msWpxcj7q46bYDDgO30PysfOtymKMmYi3rjZXXD_Ia86oDWVgitfvL3V9JT1kqmYCT8u0kXOJCvqquBgU_XyqHehJmRQJLUBRvXogyNF_TJEsjkiPI-AveD8hThOad62YQK7e0hVN_JznKXN6eLlEc_QyHtElxoDuY_3G1ohy2Mj0K1s5nUFbExMqcfHhN6Kw2FYMVeN8uhh_zvmDhJlVw_eSKyc6Y0jSA",  "token_type": "Bearer", "expires_in": 7199}';
            response.setBody(sampleBody);
            response.setStatusCode(202);
                    
        }
        else if(request.getEndpoint().contains('billOfLadingId')){
            string sampleBody = '{"deliveryOrderId": "a84bdf70-c365-11eb-bbea-2755d6e905a6","billOfLadingId":"123456"}}';
            response.setBody(sampleBody);
            response.setStatusCode(202);
        }
        else{
            string sampleBody = '{ "access_token": "eyJ0qKZuv6XyAQ", "scope": "MaerskInternal openid","id_token": "eyJ0eXAiOVuIiwiYXVkIjoieEREQjh4aW5OZmpxRzNsSEZ4TkJHQ1JHd01FTzJNalIiLCJjYXJyaWVyIjoiTbSI6Ii9tYXUiLCJleHAiOjE2MzIyNTM2NDIsInRva2VuVHlwZSI6IkpXVFRva2VuIiwiaWF0IjoxNjMyMjQ2NDQyfQ.LjO-2rv0W26zx4x8msWpxcj7q46bYDDgO30PysfOtymKMmYi3rjZXXD_Ia86oDWVgitfvL3V9JT1kqmYCT8u0kXOJCvqquBgU_XyqHehJmRQJLUBRvXogyNF_TJEsjkiPI-AveD8hThOad62YQK7e0hVN_JznKXN6eLlEc_QyHtElxoDuY_3G1ohy2Mj0K1s5nUFbExMqcfHhN6Kw2FYMVeN8uhh_zvmDhJlVw_eSKyc6Y0jSA",  "token_type": "Bearer", "expires_in": 7199}';
            string sampleBody1 = '{"deliveryOrderId": "a84bdf70-c365-11eb-bbea-2755d6e905a6","importServiceMode": "CY","haulageInstructions": [{"containerId": "KAFD0007580"}],"deliveryOrderStatus": "CONFIRMED","instantDeliveryOrder": {"status": "SUCCESS","mapRTPStatus": "SUCCESS","createHaulageOrderStatus": "SUCCESS","sendHaulageOrderStatus": "SUCCESS","shipmentReferencesStatus": "NOTREQUESTED"}}';
         
            response.setBody(sampleBody);
            response.setStatusCode(202);
       
        }
         return response; 
       
    }
}