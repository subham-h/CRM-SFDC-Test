/**
 * Test class for DeadlineServiceController
 * 
 * Version  Date         Owner                   RQ#           Description
 *******************************************************************************************************************
 * 1.0                                                         Class created
 * 2.0      28/06/2022   Ronnie@SF               SPI-100       Removed brand operator code hardcoding
 */

@isTest
public class DeadlineServiceControllerTest {
    
    @isTest static void testGetDeadlineDetails() {   
        Continuation conti =(Continuation)DeadlineServiceController.getDeadlineDetails('3645645764', '234', '', 'test', '', BrandUtilities.MCC_MDSMAPPING);
        try {
            DeadlineServiceController.processDeadlineDetails('Continuation-1');
        } catch(Exception e) {}
        system.assertEquals(conti.continuationMethod, 'processDeadlineDetails');
    }
}