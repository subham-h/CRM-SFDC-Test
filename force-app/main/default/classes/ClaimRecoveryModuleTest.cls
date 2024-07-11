/*
* test class Claim Recovery Module.
* 
 Date        Owner                         Description
*********************************************************************************************************************************  
23/2/2022    kusum.jha@maersk.com          Code created.
23/2/2022    kusum.jha@maersk.com          testCreateClaimRecovery : testing the creation of Claim Recovery Case
23/2/2022    kusum.jha@maersk.com          testCloseClaimRecovery : Testing the closing of Claim Recovery Case
25/2/2022    kusum.jha@maersk.com          testValidateClaimRecovery : validating Validation Rule - Validate_Claim_Recovery
*/

@isTest
public class ClaimRecoveryModuleTest {
    
    public static Integer intNoOfVessels = 5;
    
    @isTest
    public static void testCreateClaimRecovery()
    {
        //creating vessels and incident claim event   
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);
        Test.startTest();
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent('Ocean', lstVessels[0],null,null);
        
        //creating claim recovery case
        TestDataFactoryHelper.createClaimRecoveryCases(incidentClaimEvent);
        
        //query the created claim recovery case
        List<Case> lstCreatedCase = [SELECT id,RecordTypeId, CreatedById , OwnerId, Status FROM Case limit 1];
        
        //get the record type name of the converted case
        String strRecordtypeName = StaticFactory.getRecordTypeNameById('Case', lstCreatedCase[0].RecordTypeId);
        Test.stopTest();
        //test the case is converted to claim
        System.assertEquals(lstCreatedCase.size(),1, 'checking case size');
        System.assertEquals('Claim Recovery', strRecordTypeName, 'checking record type name');
        System.assertEquals(lstCreatedCase[0].CreatedById , lstCreatedCase[0].OwnerId, 'checking createdby id');
        
            
    }
    
    @isTest
    public static void testCloseClaimRecovery()
    {

        //creating vessels and incident claim event   and claim recovery case
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);  
        Test.startTest();
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent('Ocean', lstVessels[0],null,null);        
        TestDataFactoryHelper.createClaimRecoveryCases(incidentClaimEvent);   
        
         //query the created claim recovery case
        List<Case> lstCreatedCase = [SELECT id, Status FROM Case limit 1];
        
        //close the created claim recovery case
        TestDataFactoryHelper.claimRecoveryClose(lstCreatedCase[0]);
        
        //query the closed claim recovery case
        Case closedCase = [SELECT id, Status,Duration_Of_Case_Closed_first_time__c FROM Case WHERE id=: lstCreatedCase[0].id];
        Test.stopTest();
        //test the close claim revovery case
        System.assertEquals('Recovery Failed',closedCase.Status,'checking recovery status');
        
    }
    
    @isTest
    public static void testValidateClaimRecovery()
    {
        //creating vessels and incident claim event   
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels); 
        Test.startTest();
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent('Ocean', lstVessels[0],null,null);
        
        //creating claim recovery case
        TestDataFactoryHelper.createClaimRecoveryCases(incidentClaimEvent);
        //query the created claim recovery case
        List<Case> lstCreatedCase = [SELECT id,RecordTypeId,Time_Bar__c , Status FROM Case limit 1];
        
        try{
            
            lstCreatedCase[0].Time_Bar__c = null;
            update lstCreatedCase[0];
        }
        catch(Exception ex)
        {
             system.debug(LoggingLevel.WARN,'##### The Error is : '+ex);

        }
        Test.stopTest();
    }
}