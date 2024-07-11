@isTest
public class PartyDetailRolesControllerTest {
    @isTest static void testGetPartyRoleDetailsExport() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Booked by"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailRolesController.botInput input = new PartyDetailRolesController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailRolesController.botInput> lstShipmentNumber = new List<PartyDetailRolesController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailRolesController.partyRoleInfo> lstPartyRoleInfo = PartyDetailRolesController.getPartyRole(lstShipmentNumber);
        GCSSPartyDetailsController.getGCSSPartyDetailsFortpDoc(input.shipmentNumber, input.scvCode,input.brand);
         boolean isExport = true;
         System.assertEquals(lstPartyRoleInfo[0].isExport, isExport);   
        Test.stopTest();
    } 
     @isTest static void testGetPartyRoleDetailsImport() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Release to party"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailRolesController.botInput input = new PartyDetailRolesController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailRolesController.botInput> lstShipmentNumber = new List<PartyDetailRolesController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailRolesController.partyRoleInfo> lstPartyRoleInfo = PartyDetailRolesController.getPartyRole(lstShipmentNumber);
         boolean isImport = true;
         System.assertEquals(lstPartyRoleInfo[0].isImport, isImport);   
        Test.stopTest();
    } 
     @isTest static void testGetPartyRoleDetailsInvoice() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Invoice Party"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailRolesController.botInput input = new PartyDetailRolesController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailRolesController.botInput> lstShipmentNumber = new List<PartyDetailRolesController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailRolesController.partyRoleInfo> lstPartyRoleInfo = PartyDetailRolesController.getPartyRole(lstShipmentNumber);
         boolean isInvoice = true;
         System.assertEquals(lstPartyRoleInfo[0].isInvoice, isInvoice);   
        Test.stopTest();
    }
    
     @isTest static void testGetPartyRoleDetailsGeneric() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"Yes","verifyCustomerRoleResponse":[{"partyRoleTypeId":"1","partyRoleTypeName":"Test"}]}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));           
        PartyDetailRolesController.botInput input = new PartyDetailRolesController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailRolesController.botInput> lstShipmentNumber = new List<PartyDetailRolesController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailRolesController.partyRoleInfo> lstPartyRoleInfo = PartyDetailRolesController.getPartyRole(lstShipmentNumber);
         boolean isGeneric = true;
         System.assertEquals(lstPartyRoleInfo[0].isGeneric, isGeneric);   
        Test.stopTest();
    }
    
      @isTest static void testGetPartyRoleNotAvaialble() { 
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","customerRoleAvailable":"No"}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers));       
        PartyDetailRolesController.botInput input = new PartyDetailRolesController.botInput();
        input.shipmentNumber = '507333553';
        input.scvCode = '10000007951';
        input.brand = BrandUtilities.MAERSK;
        List<PartyDetailRolesController.botInput> lstShipmentNumber = new List<PartyDetailRolesController.botInput>();
        lstShipmentNumber.add(input);
        List<PartyDetailRolesController.partyRoleInfo> lstPartyRoleInfo = PartyDetailRolesController.getPartyRole(lstShipmentNumber);
         boolean isGeneric = False;
        System.assertEquals(lstPartyRoleInfo[0].isGeneric, isGeneric);   
        Test.stopTest();
    }   
}