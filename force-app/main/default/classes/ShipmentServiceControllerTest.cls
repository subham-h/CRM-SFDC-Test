/**
 * Test class for ShipmentServiceController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class ShipmentServiceControllerTest {
    
    @isTest static void testGetContainerIdsByBookingNumber() {   
        Continuation conti =(Continuation)ShipmentServiceController.getContainerIdsByBookingNumber('3645645764');
        try{
            ShipmentServiceController.processShipmentDetailRes('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processShipmentDetailRes');
    }
    
    @isTest static void testGetBookingDetailsByShipmentNumber() {   
        Continuation conti =(Continuation)ShipmentServiceController.GetBookingDetailsByShipmentNumber('3645645764');
        try{
            ShipmentServiceController.processBdetailsResponse('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processBdetailsResponse');
    }
    
    @isTest static void testGetShipmentNotesPerRequest() {              
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        ShipmentServiceController.GetShipmentNotesPerRequest('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
    }
    
    @isTest static void testGetContainerCountByBookingNumber() {   
        Continuation conti =(Continuation)ShipmentServiceController.getContainerCountByBookingNumber('3645645764');
        try{
            ShipmentServiceController.processContainerCountRes('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processContainerCountRes');
    }
    
    @isTest static void testGetBookingDetailsByContainerNumber() {   
        Continuation conti =(Continuation)ShipmentServiceController.getBookingNumberByContainerNumber('MSKU8658349');
        try{
            ShipmentServiceController.processBookingDetailsByContainer('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processBookingDetailsByContainer');
    }
}