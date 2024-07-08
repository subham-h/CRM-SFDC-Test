/**
 * Test class for ArrivalNoticeController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      27/06/2022   Ronnie@SF               SPI-100       Removed brand hardcoding
 */

@isTest
public class ArrivalNoticeControllerTest {
    @isTest static void testGetPartyDetails() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","tasks":[{"taskName": "Issue Arrival Notice","status": "Closed"}],"parties":[{"partyRoleTypeId":"1","partyRoleTypeName":"Consignee","scvCustomerCode":"10000007951"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        ArrivalNoticeController.botInput input = new ArrivalNoticeController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<ArrivalNoticeController.botInput> lstShipmentNumber = new List<ArrivalNoticeController.botInput>();
        lstShipmentNumber.add(input);
        List<ArrivalNoticeController.arrivalNoticeInfo> lstArrivalNoticeInfo = ArrivalNoticeController.getArrivalNotice(lstShipmentNumber);
        String expectedParty = 'Yes';
        System.assertEquals(lstArrivalNoticeInfo[0].arrivalRoleAvailable, expectedParty);   
        Test.stopTest();
    } 
     @isTest static void testGetPartyDetails1() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","tasks":[{"taskName": "Issue Arrival Notice","status": "Open"}],"parties":[{"partyRoleTypeId":"1","partyRoleTypeName":"First Notify Party","scvCustomerCode":"10000007951"}]}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        ArrivalNoticeController.botInput input = new ArrivalNoticeController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<ArrivalNoticeController.botInput> lstShipmentNumber = new List<ArrivalNoticeController.botInput>();
        lstShipmentNumber.add(input);
        List<ArrivalNoticeController.arrivalNoticeInfo> lstArrivalNoticeInfo = ArrivalNoticeController.getArrivalNotice(lstShipmentNumber);
        String expectedParty = 'Yes';
        System.assertEquals(lstArrivalNoticeInfo[0].arrivalRoleAvailable, expectedParty);   
        Test.stopTest();
    } 
      @isTest static void testGetPartyDetails2() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","debugMessage":"The shipment operator does not match the business unit operator."}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        ArrivalNoticeController.botInput input = new ArrivalNoticeController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<ArrivalNoticeController.botInput> lstShipmentNumber = new List<ArrivalNoticeController.botInput>();
        lstShipmentNumber.add(input);
        List<ArrivalNoticeController.arrivalNoticeInfo> lstArrivalNoticeInfo = ArrivalNoticeController.getArrivalNotice(lstShipmentNumber);
        System.assertEquals(lstArrivalNoticeInfo[0].arrivalRoleAvailable, null);   
        Test.stopTest();
    } 
    
     @isTest static void testGetPartyDetails3() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"debugMessage":"The shipment operator does not match the business unit operator."}';
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        ArrivalNoticeController.botInput input = new ArrivalNoticeController.botInput();
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<ArrivalNoticeController.botInput> lstShipmentNumber = new List<ArrivalNoticeController.botInput>();
        lstShipmentNumber.add(input);
        List<ArrivalNoticeController.arrivalNoticeInfo> lstArrivalNoticeInfo = ArrivalNoticeController.getArrivalNotice(lstShipmentNumber);
        System.assertEquals(lstArrivalNoticeInfo[0].arrivalRoleAvailable, null);   
        Test.stopTest();
    } 
    
     @isTest static void testGetPartyDetails4() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","tasks":[{"taskName": "Issue Arrival Notice","status": "Closed"}],"parties":[{"partyRoleTypeId":"1","partyRoleTypeName":"Doc Consignee","scvCustomerCode":"10000007951"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        ArrivalNoticeController.botInput input = new ArrivalNoticeController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<ArrivalNoticeController.botInput> lstShipmentNumber = new List<ArrivalNoticeController.botInput>();
        lstShipmentNumber.add(input);
        List<ArrivalNoticeController.arrivalNoticeInfo> lstArrivalNoticeInfo = ArrivalNoticeController.getArrivalNotice(lstShipmentNumber);
        String expectedParty = 'Yes';
        System.assertEquals(lstArrivalNoticeInfo[0].arrivalRoleAvailable, expectedParty);   
        Test.stopTest();
    } 
     
}