/**
* Test class for PartyDetailsController
* 
* Version  Date         Owner                   RQ#           Description
*******************************************************************************************************************
* 1.0                                                         Class created
* 2.0      27/06/2022   Ronnie@SF               SPI-100       Removed brand hardcoding
*/

@isTest
public class PartyDetailsControllerTest {
    
    @isTest static void testGetPartyDetails() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","tasks":[{"taskName": "Confirm Shipment","status": "Closed"},{"taskName": "Confirm Shipment","status": "Open"}],"customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Booked By"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailsController.botInput input = new PartyDetailsController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailsController.botInput> lstShipmentNumber = new List<PartyDetailsController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailsController.partyInfo> lstPartyInfo = PartyDetailsController.getPartyDetails(lstShipmentNumber);
        String expectedParty = 'Yes';
        Assert.areEqual(expectedParty, lstPartyInfo[0].customerRoleAvailable);   
        Test.stopTest();
    } 
    
    @isTest static void testGetPartyDetails1() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"No"}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        PartyDetailsController.botInput input = new PartyDetailsController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailsController.botInput> lstShipmentNumber = new List<PartyDetailsController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailsController.partyInfo> lstPartyInfo = PartyDetailsController.getPartyDetails(lstShipmentNumber);
        String expectedParty = 'No';
        Assert.areEqual(expectedParty, lstPartyInfo[0].customerRoleAvailable);    
        Test.stopTest();
    } 
    
    @isTest static void testGetPartyDetails3() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"customerRoleAvailable":"No"}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        PartyDetailsController.botInput input = new PartyDetailsController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailsController.botInput> lstShipmentNumber = new List<PartyDetailsController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailsController.partyInfo> lstPartyInfo = PartyDetailsController.getPartyDetails(lstShipmentNumber);
        String expectedParty = 'No';
        Assert.areEqual(expectedParty, lstPartyInfo[0].customerRoleAvailable);   
        Test.stopTest();
    } 
    
    @isTest static void testGetPartyDetails4() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Booked By"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailsController.botInput input = new PartyDetailsController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailsController.botInput> lstShipmentNumber = new List<PartyDetailsController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailsController.partyInfo> lstPartyInfo = PartyDetailsController.getPartyDetails(lstShipmentNumber);
        String expectedParty = 'Yes';
        Assert.areEqual(expectedParty, lstPartyInfo[0].customerRoleAvailable);   
        Test.stopTest();
    } 
}