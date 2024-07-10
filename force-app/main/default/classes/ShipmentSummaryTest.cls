@isTest
public class ShipmentSummaryTest {
    public static testMethod void testGetShipmentSummery() {
         Test.setMock(HttpCalloutMock.class, new GcssTasksControllerMock());   
         ShipmentSummary.getShipmentSummary('205384309');
         ShipmentParty.getShipmentParty('205384309','brand1');
    }
}