/**
 * Test class for TransportPlanController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class TransportPlanControllerTest {
      @isTest static void testTransportPlanController() {
        // Set mock callout class         
        Test.setMock(HttpCalloutMock.class, new TransportPlanControllerMock());           
        object response = TransportPlanController.getTransportPlan('1KT000286', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());      
    }
}