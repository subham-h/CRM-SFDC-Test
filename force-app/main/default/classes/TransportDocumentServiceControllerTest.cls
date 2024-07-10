@isTest
public class TransportDocumentServiceControllerTest {
    
    @isTest static void testGetTransportDocumentDetails() {   
        Continuation conti =(Continuation)TransportDocumentServiceController.getTransportDocumentDetails('3645645764');
        try{
        TransportDocumentServiceController.processTransportResponse('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processTransportResponse');
    }
    
    //RQ-012078 - Shipment Notes at TP Doc Level
    @isTest static void testGetShipmentNotesatTPDocLevel() {   
        Continuation conti =(Continuation)TransportDocumentServiceController.getShipmentNotesatTPDocLevel('3645645764','msk','test');
        try{
        TransportDocumentServiceController.processShipmentNotesatTPDocLevel('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processShipmentNotesatTPDocLevel');
    }
    
    @isTest static void testgetTPDocDetails() {   
    Exception capturedException;
    try{
        TransportDocumentServiceController.getTPDocDetails('3645645764','msk');
    }catch(Exception e) {
        capturedException = e;
    }
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
   
    }
}