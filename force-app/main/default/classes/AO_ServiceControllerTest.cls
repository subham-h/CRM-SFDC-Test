/**
 * Test class for AO_ServiceController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      27/06/2022   Ronnie@SF               SPI-100       Removed brand hardcoding
 * 3.0      27/09/2023   Avinash@maersk          SC-8073       Chat- Replace AO API with MEPC API for product schedules
 */

@isTest
public class AO_ServiceControllerTest {
    
    @isTest static void testGetContainerTrackingInfo() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        object response = AO_ServiceController.getContainerTrackingInfo('MRKU0960469','msk'); 
        String expectedValue = '{"isContainerSearch":true,"origin":{"terminal":"Nhava Sheva India Gateway Terminal","geo_site":"NPCHMC9MWRRH9","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"TERMINAL"},"destination":{"terminal":"Brasil Terminal Portuario","geo_site":"DOLGEEUHWCVDV","city":"Santos","state":"Sao Paulo","country":"Brazil","country_code":"BR","geoid_city":"1BX66GARX9UAH","site_type":"TERMINAL"},"containers":[{"container_num":"MRKU0960469","container_size":"40","container_type":"Dry","iso_code":"42G0","operator":"MAEU","locations":[{"terminal":"Vinay Yard","geo_site":"TDRY98QZRJ641","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"CUSTOMER LOCATION","events":[{"activity":"GATE-OUT-EMPTY","stempty":true,"actfor":"EXP","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","actual_time":"2019-06-17T19:38:00.000","rkem_move":"GATE-OUT","is_cancelled":false,"is_current":false}]},{"terminal":"Nhava Sheva India Gateway Terminal","geo_site":"NPCHMC9MWRRH9","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"TERMINAL","events":[{"activity":"GATE-IN","stempty":false,"actfor":"EXP","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-21T16:30:00.000","actual_time":"2019-06-19T05:32:00.000","rkem_move":"GATE-IN","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-21T16:30:00.000","actual_time":"2019-06-21T14:38:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":false}]},{"terminal":"Salalah Terminal","geo_site":"2LU3R3RRU5RVI","city":"Salalah","state":"","country":"Oman","country_code":"OM","geoid_city":"30ECXPXBQJMHO","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-26T13:00:00.000","actual_time":"2019-06-26T16:12:00.000","rkem_move":"DISCHARG","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK SEMBAWANG","voyage_num":"926W","vessel_num":"103","expected_time":"2019-07-01T21:30:00.000","actual_time":"2019-07-01T16:52:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":false}]},{"terminal":"Tanger Med 2","geo_site":"CDQYK28YV7BKN","city":"Port Tangier Mediterranee","state":"","country":"Morocco","country_code":"MA","geoid_city":"0C29F4LWXIITO","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"","vessel_name":"MAERSK SEMBAWANG","voyage_num":"926W","vessel_num":"103","expected_time":"2019-07-15T03:30:00.000","actual_time":"2019-07-15T13:51:00.000","rkem_move":"DISCHARG","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-07-21T23:00:00.000","actual_time":"2019-07-21T18:21:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":true}]},{"terminal":"Brasil Terminal Portuario","geo_site":"DOLGEEUHWCVDV","city":"Santos","state":"Sao Paulo","country":"Brazil","country_code":"BR","geoid_city":"1BX66GARX9UAH","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"EXP","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-08-02T18:00:00.000","is_current":false},{"activity":"GATE-OUT","stempty":false,"actfor":"DEL","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-08-02T18:00:00.000","is_current":false}]}],"eta_final_delivery":"2019-08-02T18:00:00.000","latest":{"actual_time":"2019-07-21T18:21:00.000","activity":"LOAD","stempty":false,"actfor":"","geo_site":"CDQYK28YV7BKN","city":"Port Tangier Mediterranee","state":"","country":"Morocco","country_code":"MA"},"status":"IN-PROGRESS"}]}';
        
    }
    
    @isTest static void testGetScheduleDetails() {
        // Set mock callout class 
        set<string> sitecodes  = new  set<string>{'02GYFH4R8RVY6','274LBR94PNZWE'};
            Geography__c geocode = new Geography__c();
        geocode.Name = 'Xingang';
        geocode.GEO_ID__c = '02GYFH4R8RVY6';
        geocode.GEO_Code__c = 'CNHSK';
        insert geocode;
        Geography__c geocode2 = new Geography__c();
        geocode2.Name = 'Le Havre';
        geocode2.GEO_ID__c = '274LBR94PNZWE';
        geocode2.GEO_Code__c = 'FRLEH';
        insert geocode2;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockSchedules());
        // for Non NAP Schedules
        object response = AO_ServiceController.getScheduleDetails('CNHSK','FRLEH','msk','CY','CY','2023-09-29','D','4','false',''); 
        
        // for Non NAP Schedules
        object response1 = AO_ServiceController.getScheduleDetails('CNHSK','FRLEH','msk','CY','CY','2023-09-29','D','4','true','33102410409'); 
        
        AO_ServiceController.getLocation(sitecodes); 
        test.stopTest();
        // System.assertEquals((string)response, expectedValue);      
    }
    @isTest static void testGetContainerTracking() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock());
        // Calling the getContainerTracking method from AO_ServiceController by passing the container number.
        AO_ServiceController.containerInput con = new AO_ServiceController.containerInput();
        con.containerNumber = 'MRKU0960469';
        con.botLanguage = 'English';
        con.brand = BrandUtilities.MAERSK;
        List<AO_ServiceController.containerInput> listContainers = new List<AO_ServiceController.containerInput>();
        listContainers.add(con);
        List<AO_ServiceController.trackingInfo> lstTrack = AO_ServiceController.getContainerTracking(listContainers);
        
              
    }
    @isTest static void testGetInvoiceDetails() {
        AccountData_Test.createClientAccounts();
        List<Account> lstAccounts = AccountData_Test.lstAccounts;
        lstAccounts[0].SCV_Code__c = '10000007951';
        lstAccounts[0].Customer_Code__c = 'DK00007951';
        update lstAccounts[0];
        // Set mock callout class 
        test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockInvoices());  
        object response = InvoiceDetailsController.getInvoiceDetails('589634070','','10000007951','PAID',BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase()); 
        String expectedValue =  '{ "invoiceCount":"1","invoices":[ { "invoiceNo":"5499107510","billOfLading":"589634070","invoiceType":"EXPORT","customerReferenceNo":"5499107510","invoiceDate":"/Date(1578268800000)/","dueDate":"/Date(1578355200000)/","invoicedAmount":"8357.2200","openAmount":"0.0000","currency":"AED","businessArea":"AE00","businessAreaDescription":"United Arab Emirates","invoiceId":"100020205499107510001SD 5499107510","pdfFlag":true,"isOverdue":false,"customerNumber":"AE00950841","invoiceStatusCode":"PAID","caseGuid":"","paymentDetails":{ "paymentReceiptNumber":"3400092051","paidDate":"/Date(1579046400000)/","paidCurrency":"AED","paidAmount":"8357.2200","paymentInfo":"Other Payments/Settlements","paidAmountFormatted":"8,357.22"},"invoiceAmountFormatted":"8,357.22","openAmountFormatted":"","allocationId":"100020205499107510001","nonPayableReason":"","invoiceUID":"000001"}],"responseMetaData":{ "currencies":[ "AED"],"invoicesTypes":[ "EXPORT"]}}';       
        object responseapi = InvoiceDetailsController.downloadInvoiceDetails('100020205499107510001SD 5499107510','10000007951','PAID'); 
        String expectedapiValue  = '{"fileContent":"JVBERi0xLjMNCiXi48/TDQolUlNUWFBERjMgUGFyYW1ldGVyczogREpSU1RYaA0KJURldnR5cGUgWlNXSU5DRiAgRm9udCBIRUxWRSAgICBib2xkIExhbmcgRU4gU2NyaXB0OiAgMCAtPi9DMDAxDQoyIDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnREZXNjcmlwdG9yDQovQXNjZW50IDcxOA0KL0NhcEhlaWdodCA3MTgNCi9EZXNjZW50IC0yMDcNCi9GbGFncy"}';
        object responseapiNexus = TransportScheduleServiceController.getTransportScheduleNexus('L2V','319E','30 Jun, 2021','5 Jul, 2023'); 
        //String expectedapiValue  = '{"fileContent":"JVBERi0xLjMNCiXi48/TDQolUlNUWFBERjMgUGFyYW1ldGVyczogREpSU1RYaA0KJURldnR5cGUgWlNXSU5DRiAgRm9udCBIRUxWRSAgICBib2xkIExhbmcgRU4gU2NyaXB0OiAgMCAtPi9DMDAxDQoyIDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnREZXNjcmlwdG9yDQovQXNjZW50IDcxOA0KL0NhcEhlaWdodCA3MTgNCi9EZXNjZW50IC0yMDcNCi9GbGFncy"}';
        
        test.stopTest();
        
    }  
    @isTest static void testGetInvoiceDetailsWithoutAccount() {
        
        // Set mock callout class 
        test.startTest();        
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockInvoices());  
        object response = InvoiceDetailsController.getInvoiceDetails('','589634070','10000007950','PAID',BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase()); 
        String expectedValue =  '{ "invoiceCount":"1","invoices":[ { "invoiceNo":"5499107510","billOfLading":"589634070","invoiceType":"EXPORT","customerReferenceNo":"5499107510","invoiceDate":"/Date(1578268800000)/","dueDate":"/Date(1578355200000)/","invoicedAmount":"8357.2200","openAmount":"0.0000","currency":"AED","businessArea":"AE00","businessAreaDescription":"United Arab Emirates","invoiceId":"100020205499107510001SD 5499107510","pdfFlag":true,"isOverdue":false,"customerNumber":"AE00950841","invoiceStatusCode":"PAID","caseGuid":"","paymentDetails":{ "paymentReceiptNumber":"3400092051","paidDate":"/Date(1579046400000)/","paidCurrency":"AED","paidAmount":"8357.2200","paymentInfo":"Other Payments/Settlements","paidAmountFormatted":"8,357.22"},"invoiceAmountFormatted":"8,357.22","openAmountFormatted":"","allocationId":"100020205499107510001","nonPayableReason":"","invoiceUID":"000001"}],"responseMetaData":{ "currencies":[ "AED"],"invoicesTypes":[ "EXPORT"]}}';       
        object responseapi = InvoiceDetailsController.downloadInvoiceDetails('100020205499107510001SD 5499107510','10000007951','PAID'); 
        String expectedapiValue  = '{"fileContent":"JVBERi0xLjMNCiXi48/TDQolUlNUWFBERjMgUGFyYW1ldGVyczogREpSU1RYaA0KJURldnR5cGUgWlNXSU5DRiAgRm9udCBIRUxWRSAgICBib2xkIExhbmcgRU4gU2NyaXB0OiAgMCAtPi9DMDAxDQoyIDAgb2JqDQo8PA0KL1R5cGUgL0ZvbnREZXNjcmlwdG9yDQovQXNjZW50IDcxOA0KL0NhcEhlaWdodCA3MTgNCi9EZXNjZW50IC0yMDcNCi9GbGFncy"}';
        object responseapiNexus = TransportScheduleServiceController.getTransportScheduleNexus('L2V','319E','30 Jun, 2021','5 Jul, 2023'); 
        test.stopTest();
        
    }     
       
    @isTest static void testconnectServiceUsageToHeroku() {
       
        test.startTest();        
        Test.setMock(HttpCalloutMock.class, new LWCHerokuServiceMock());  
        WebserviceUtilities.connectServiceUsageToHeroku('','Service View','Shipment Summary');        
        test.stopTest();
   }
    
     @isTest static void testBrandChange() {
       
        test.startTest(); 
           Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        string sampleBody = '{"isContainerSearch":true,"origin":{"terminal":"Nhava Sheva India Gateway Terminal","geo_site":"NPCHMC9MWRRH9","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"TERMINAL"},"destination":{"terminal":"Brasil Terminal Portuario","geo_site":"DOLGEEUHWCVDV","city":"Santos","state":"Sao Paulo","country":"Brazil","country_code":"BR","geoid_city":"1BX66GARX9UAH","site_type":"TERMINAL"},"containers":[{"container_num":"MRKU0960469","container_size":"40","container_type":"Dry","iso_code":"42G0","operator":"MAEU","locations":[{"terminal":"Vinay Yard","geo_site":"TDRY98QZRJ641","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"CUSTOMER LOCATION","events":[{"activity":"GATE-OUT-EMPTY","stempty":true,"actfor":"EXP","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","actual_time":"2019-06-17T19:38:00.000","event_time_type":"ACTUAL","event_time":"2019-06-17T19:38:00.00","eventId":"10230689480","rkem_move":"GATE-OUT","is_cancelled":false,"is_current":false}]},{"terminal":"Nhava Sheva India Gateway Terminal","geo_site":"NPCHMC9MWRRH9","city":"Jawaharlal Nehru","state":"MAHARASHTRA","country":"India","country_code":"IN","geoid_city":"20JS07ETK8AE1","site_type":"TERMINAL","events":[{"activity":"GATE-IN","stempty":false,"actfor":"EXP","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-21T16:30:00.000","actual_time":"2019-06-19T05:32:00.000","rkem_move":"GATE-IN","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-21T16:30:00.000","actual_time":"2019-06-21T14:38:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":false}]},{"terminal":"Salalah Terminal","geo_site":"2LU3R3RRU5RVI","city":"Salalah","state":"","country":"Oman","country_code":"OM","geoid_city":"30ECXPXBQJMHO","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"","vessel_name":"MAERSK GUAYAQUIL","voyage_num":"924W","vessel_num":"SP2","expected_time":"2019-06-26T13:00:00.000","actual_time":"2019-06-26T16:12:00.000","rkem_move":"DISCHARG","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK SEMBAWANG","voyage_num":"926W","vessel_num":"103","expected_time":"2019-07-01T21:30:00.000","actual_time":"2019-07-01T16:52:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":false}]},{"terminal":"Tanger Med 2","geo_site":"CDQYK28YV7BKN","city":"Port Tangier Mediterranee","state":"","country":"Morocco","country_code":"MA","geoid_city":"0C29F4LWXIITO","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"","vessel_name":"MAERSK SEMBAWANG","voyage_num":"926W","vessel_num":"103","expected_time":"2019-07-15T03:30:00.000","actual_time":"2019-07-15T13:51:00.000","rkem_move":"DISCHARG","is_cancelled":false,"is_current":false},{"activity":"LOAD","stempty":false,"actfor":"","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-07-21T23:00:00.000","actual_time":"2019-07-21T18:21:00.000","rkem_move":"LOAD","is_cancelled":false,"is_current":true}]},{"terminal":"Brasil Terminal Portuario","geo_site":"DOLGEEUHWCVDV","city":"Santos","state":"Sao Paulo","country":"Brazil","country_code":"BR","geoid_city":"1BX66GARX9UAH","site_type":"TERMINAL","events":[{"activity":"DISCHARG","stempty":false,"actfor":"EXP","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-08-02T18:00:00.000","is_current":false},{"activity":"GATE-OUT","stempty":false,"actfor":"DEL","vessel_name":"MAERSK LINS","voyage_num":"928S","vessel_num":"1AM","expected_time":"2019-08-02T18:00:00.000","is_current":false}]}],"eta_final_delivery":"2019-08-02T18:00:00.000","latest":{"actual_time":"2019-07-21T18:21:00.000","activity":"LOAD","stempty":false,"actfor":"","geo_site":"CDQYK28YV7BKN","city":"Port Tangier Mediterranee","state":"","country":"Morocco","country_code":"MA"},"status":"IN-PROGRESS"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
         // Calling the getContainerTracking method from AO_ServiceController by passing the container number.
        AO_ServiceController.containerInput con = new AO_ServiceController.containerInput();
        con.containerNumber = 'MRKU0960469';
        con.botLanguage = 'English';
        con.brand = BrandUtilities.MAERSK;
        List<AO_ServiceController.containerInput> listContainers = new List<AO_ServiceController.containerInput>();
        listContainers.add(con);
        List<AO_ServiceController.trackingInfo> lstTrack = AO_ServiceController.getContainerTracking(listContainers);      
        test.stopTest();
   }
        
   @isTest static void testconnectCxUsageToHeroku() {
       
        test.startTest();        
        Test.setMock(HttpCalloutMock.class, new LWCHerokuServiceMock());  
        WebserviceUtilities.connectServiceUsageToHeroku('','CX Package','1');        
        test.stopTest();
   }
    
}