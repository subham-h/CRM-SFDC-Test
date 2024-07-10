/**
 * Description: Perform callout to get Insurance Details
 * 
 * Version       Date                Owner                                       Description
 *******************************************************************************************************************
 * v1.0          05/02/2020          sriram.kalluri@maersk.com                   Perform callout to get Insurance Details
 * v2.0          28/06/2022          Ronnie@SF                                   SPI-100: Removed brand operator code hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */

@isTest
public class InsuranceDetailsControllerTest {
    @isTest static void testGetInsuranceDetails() {
        // Set mock callout class \
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockInvoices()); 
        Object response = InsuranceDetailsController.getInsuranceDetails('', '7682907', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase()); 
        Test.stopTest();
    }
    
    @isTest static void testGetInsuranceDetailsWithOutAcesssToken() {
        // Set mock callout class \
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMockInvoices()); 
        Object response = InsuranceDetailsController.getInsuranceDetails('239324253', '7682907', BrandUtilities.getBrandOperatorCode(BrandUtilities.MCC)); 
        Test.stopTest();    
    }
    
    @isTest static void testGetCommodityDetails() {
        InsuranceDetailsController.getCommodityDetails('TEST');
        InsuranceDetailsController.getLocationNames(new List<String>{'TEST'});
    }   
}