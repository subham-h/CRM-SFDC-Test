@isTest
public class ContainerReuseManagementOperationsTest {
     @isTest static void testGetReuseDetails() {   
        Continuation conti =(Continuation)ContainerReuseManagementOperations.getReuseDetails('583879929','TCLU9249760');
        try{
        ContainerReuseManagementOperations.processReuseDetails('Continuation-1');
        }catch(Exception e){}
        system.assertEquals(conti.continuationMethod, 'processReuseDetails');
    }

}