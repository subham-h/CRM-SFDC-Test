/**
 * Description: Test class for GetReferences
 * 
 * Version       Date                Owner                     Ref                  Description
 *******************************************************************************************************************
 * v1.0          
 * v2.0          28/06/2022          Ronnie@SF                 SPI-100              Removed brand operator code hardcoding
 *-------------------------------------------------------------------------------------------------------------------
 */

@isTest
public class GetReferencesTest {
    
    public static TestMethod void testShipmentReference(){
        Test.setMock(HttpCalloutMock.class, new ShipmentReferenceMock());
        Test.startTest();
        Object obj = GetReferences.getShipmentReferences('910736807', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());
        String expected = '{"shipmentNumber":"910736807","references":[{"referenceType":"Reference","id":"8Q9F5LT6J0LIB","typeId":"1400","name":"Shipment Priority","value":"HOTBOX"},{"referenceType":"Reference","city":"Bremerhaven, Bremen, Germany","country":"Germany","cityId":"3EX4F5S3MB4OU","id":"2AONNFT6J0P3B","typeId":"3LCH6ODKUUD1Q","name":"Cargo HS Code","value":"843061","direction":"Final Vessel Discharge"}]}';
        system.assertEquals(expected, (String)obj);
        Test.stopTest();
    }
    
    public static TestMethod void testContainerReference(){
        Test.setMock(HttpCalloutMock.class, new ShipmentReferenceMock());
        Test.startTest();
        Object obj = GetReferences.getContainerReferences('293903431', '5YQCDSH460Q3B', BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toLowerCase());
        String expected = '{"shipmentNumber":"293903431","equipmentAssignmentId":"5YQCDSH460Q3B","references":[{"referenceType":"Reference","id":"MKJOWXPH70Q3B","typeId":"1022","name":"Carrier Seal","value":"CN9331698"}]}';
        system.assertEquals(expected, (String)obj);
        Test.stopTest();
    }

}