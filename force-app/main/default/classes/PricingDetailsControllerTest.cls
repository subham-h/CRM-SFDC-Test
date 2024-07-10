/**
 * Description  : Test class for PricingDetailsController
 * 
 * Version       Date                Owner                         Description
 *******************************************************************************************************************
 * v1.0          08/10/2020          avinash@ust.com               Test class for PricingDetailsController
 * v2.0          28/06/2022          Ronnie@SF                     SPI-100: Removed brand operator code hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class PricingDetailsControllerTest {
	
    @isTest static void testPricingDetailsController() {
        // Set mock callout class. Reusing the GcssTasksControllerMock to set the mock        
        Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());           
        object response = PricingDetailsController.getPricingDetails('1KT000286', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());      
    }
}