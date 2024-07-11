/**
 * Test class for GcssTasksController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class GcssTasksControllerTest {
      @isTest static void testGcssTasksController() {
        // Set mock callout class         
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        object response = GcssTasksController.getGcssTasksDetails('1KT000286', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());      
    }
}