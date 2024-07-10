@isTest
public class InlandContainerMoveDetailsTest {
     @isTest static void testGetInlandContainerMoveDetailsUsingShiment() {   
        Continuation conti =(Continuation)InlandContainerMoveDetails.getInlandContainerMoveDetails('867487767',null,null,'shipment');
        try{
        InlandContainerMoveDetails.processInlandContainerMove('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processInlandContainerMove');
    }
    @isTest static void testGetInlandContainerMoveDetailsUsingWO() {   
        Continuation conti =(Continuation)InlandContainerMoveDetails.getInlandContainerMoveDetails(null,'32633082',null,'workOrder');
        try{
        InlandContainerMoveDetails.processInlandContainerMove('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processInlandContainerMove');
    }
     @isTest static void testGetInlandContainerMoveDetailsUsingCNO() {   
        Continuation conti =(Continuation)InlandContainerMoveDetails.getInlandContainerMoveDetails(null,null,'MNBU3591430','container');
        try{
        InlandContainerMoveDetails.processInlandContainerMove('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processInlandContainerMove');
    }
     @isTest static void testGetOperationDetailsByOperationID() {   
        Continuation conti =(Continuation)InlandContainerMoveDetails.getOperationDetailsByOperationID('A12731A5425848CFB83FE6920AFEC516');
        try{
        InlandContainerMoveDetails.processInlandContainerMoveByOperationID('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processInlandContainerMoveByOperationID');
    }
    
    @isTest static void getInlandTMSDetails() { 
        Test.setMock(HttpCalloutMock.class, new AO_ServiceHttpCalloutMock()); 
        InlandContainerMoveDetails.getInlandTMSDetails('600112233','','','shipment');
    }
}