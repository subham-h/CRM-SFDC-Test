/**
 * Test class for BookingAmendmentWritebackController
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0                                                      Class created
 * 2.0      SPI-100     28/06/2022  Ronnie@SF               Removed brand operator code hardcoding
 */

@isTest
public class BookingAmendmentWritebackControllerTest {
    
    @isTest static void testPostShipmentNotes() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.postShipmentNotes('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), 'test');        
    }
    
    @isTest static void testDeleteEquipment() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.deleteEquipment('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), 'D83TK88W608KB');        
    }
    
    @isTest static void testPostReprice() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.postReprice('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());        
    }
    
    @isTest static void testGetConfirmBookingReceivers() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.getConfirmBookingReceivers('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());        
    }
    
    @isTest static void testPostConfirmBooking() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.postConfirmBooking('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), 'test');        
    }
    
    @isTest static void testAddEquipment() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.addEquipment('3645645764', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), 'test');        
    }
    
    @isTest static void testEditEquipment() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.editEquipment('507333840', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), '6UEF17ZEA1VJB', '{"bookedWeightPerContainer":21000,"shippersOwnFlag":"false","proratingType":""}');        
    }
    
    @isTest static void testGetCommodity() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());    
        BookingAmendmentWritebackController.getCommodityCodes(BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), 'fish');        
    }
    
    @isTest static void testUTMCheck() {   
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());
        BookingAmendmentWritebackController.utmCheck('507333840', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase());
    }
}