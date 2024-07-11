/**
 * Test class for SpecialCargoDetailsController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class SpecialCargoDetailsControllerTest {
      @isTest static void testSpecialCargoDetailsControlle() {
        // Set mock callout class         
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        Object response = SpecialCargoDetailsController.getSpecialCargoDetails('1KT000286', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());      
    }
}