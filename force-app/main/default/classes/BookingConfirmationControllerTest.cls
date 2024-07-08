/**
 * Test class for BookingConfirmationController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0      31/10/2022   Meghna@Maersk           SC-4740       Class created
 */
@isTest
public class BookingConfirmationControllerTest {
    
    @isTest static void testGetConfirmBookingReceivers() { 
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        //String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","recipientList": [{"contactId": "CN01705924","customerId":"DK00007951","deliveryMethodData": "richa.singh@maersk.com","deliveryMethodName":"E-mail","shipmentPartyRoleTypeId": "1","shipmentPartyRoleTypeName": "Booked By"}]}';       
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        BookingConfirmationController.botInput input = new BookingConfirmationController.botInput();
		input.shipmentNumber = '507333570';
        input.externalContactId = 'CN01705924';
        input.brand = BrandUtilities.MAERSK;
        List<BookingConfirmationController.botInput> lstShipmentNumber = new List<BookingConfirmationController.botInput>();
        lstShipmentNumber.add(input);
        List<BookingConfirmationController.BookingReceivers> lstBookingReceivers = BookingConfirmationController.sendBookingConfirmation(lstShipmentNumber);
        String expectedStatus = 'Success';
        System.assertEquals(lstBookingReceivers[0].ResponseStatus, expectedStatus);   
        Test.stopTest();
}
    @isTest static void testGetConfirmBookingReceiversII() { 
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        //String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","recipientList": [{"contactId": "CN01705924","customerId":"DK00007951","deliveryMethodData": "richa.singh@maersk.com","deliveryMethodName":"E-mail","shipmentPartyRoleTypeId": "1","shipmentPartyRoleTypeName": "Booked By"}]}';       
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        BookingConfirmationController.botInput input = new BookingConfirmationController.botInput();
		input.shipmentNumber = '507333570';
        input.externalContactId = 'DK00083821';
        input.brand = BrandUtilities.MAERSK;
        List<BookingConfirmationController.botInput> lstShipmentNumber = new List<BookingConfirmationController.botInput>();
        lstShipmentNumber.add(input);
        List<BookingConfirmationController.BookingReceivers> lstBookingReceivers = BookingConfirmationController.sendBookingConfirmation(lstShipmentNumber);
        String expectedStatus = 'Unauthorized Access';
        System.assertEquals(lstBookingReceivers[0].BookingError, expectedStatus);   
        Test.stopTest();
}
    /* @isTest static void testGetConfirmBookingReceiversIII() { 
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        //String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","recipientList": [{"contactId": "CN01705924","customerId":"DK00007951","deliveryMethodData": "richa.singh@maersk.com","deliveryMethodName":"E-mail","shipmentPartyRoleTypeId": "1","shipmentPartyRoleTypeName": "Booked By"}]}';       
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        BookingConfirmationController.botInput input = new BookingConfirmationController.botInput();
		input.shipmentNumber = '50733357';
        input.externalContactId = 'DK00083821';
        input.brand = BrandUtilities.MAERSK;
        List<BookingConfirmationController.botInput> lstShipmentNumber = new List<BookingConfirmationController.botInput>();
        lstShipmentNumber.add(input);
        List<BookingConfirmationController.BookingReceivers> lstBookingReceivers = BookingConfirmationController.sendBookingConfirmation(lstShipmentNumber);
        String expectedStatus = 'Unauthorized Access';
        System.assertEquals(lstBookingReceivers[0].BookingError, expectedStatus);   
        Test.stopTest();
}*/
    @isTest static void testGetConfirmBookingReceiversIII() {
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
         String sampleBody = '{"access_token":"R2FyQUEiLCJuYmYiOjE2MDAwNjA5MDgsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJzY29wZSI6W","debugMessage":{"error":"Error"}}';        
        Test.setMock(HttpCalloutMock.class, new GenericCalloutMock(200,'Success',sampleBody,headers)); 
        BookingConfirmationController.botInput input = new BookingConfirmationController.botInput();
        input.shipmentNumber = '507333570';
        input.externalContactId = 'CN01705924';
        input.brand = BrandUtilities.MAERSK;
        List<BookingConfirmationController.botInput> lstShipmentNumber = new List<BookingConfirmationController.botInput>();
        lstShipmentNumber.add(input);
        List<BookingConfirmationController.BookingReceivers> lstBookingReceivers = BookingConfirmationController.sendBookingConfirmation(lstShipmentNumber);
        String expectedStatus = 'System Error/Unhandled Error';
        System.assertEquals(lstBookingReceivers[0].BookingError, expectedStatus);   
		Test.stopTest();
    }
}