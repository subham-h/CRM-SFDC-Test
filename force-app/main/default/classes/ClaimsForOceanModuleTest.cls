/*
* test class Claim For Ocean Template Module.
* 
 Date        Owner                         Description
*********************************************************************************************************************************  
21/2/2022    kusum.jha@maersk.com          Code created.
21/2/2022    kusum.jha@maersk.com          testCreateVessel : testing creation of new Vessel 
21/2/2022    kusum.jha@maersk.com          testCreateVesselPolicy : testing creation of vessel policy for vessels.  
21/2/2022    kusum.jha@maersk.com          testCreateInsurancePolicy : testing creation of insurance policy .
21/2/2022    kusum.jha@maersk.com          testCreateMajorIncident : testing creation of Major Incident
21/2/2022    kusum.jha@maersk.com          testCreateClaimEvent : testing creation of Claim Event Incident
21/2/2022    kusum.jha@maersk.com          testCreateFinancialDetails : testing creation of Financial Detail
22/2/2022    kusum.jha@maersk.com          testApprovalRequestApproverApproves : testing creation of Approval Request and approving of the Approval Request
22/2/2022    kusum.jha@maersk.com          testApprovalRequestApproverRejects : testing creation of Approval Request and rejecting of the Approval Request
22/2/2022    kusum.jha@maersk.com          testCloseClaimCase : testing closing of created Claim Case
25/2/2022    kusum.jha@maersk.com          testExternalCaseToClaimOcean : Testing conversion of External Case to Claim Case
25/2/2022    kusum.jha@maersk.com          testMandatoryFieldForCourtCase : Testing the validation rule - Mandatory_fields_for_Court_Case
25/2/2022    kusum.jha@maersk.com          testValidateBOLNumber : Testing the validation rule - Validate_BoL_Number
25/2/2022    kusum.jha@maersk.com          testValidateClaimantType : Testing the validation rule - Validate_Capture_Claimant_Type
25/2/2022    kusum.jha@maersk.com          testValidateClaimsHubsForClaims :Testing the validation rule - Validate_Claims_Hub_for_Claims
- 27-March-2023   Vivek@maersk.com                    SC-7347 Changes for CLaim/Claim Recovery records fields from Sub_Type->Type , RFC->Sub_Type to resolve RFC limits
*/


@isTest 
public class ClaimsForOceanModuleTest {
    
    Public static Integer intNoOfVessels = 1;
    public static String strProduct = 'Ocean';
    public static String strBol = '919191900';
    
    //testing creation of new Vessel
    @isTest
    public static void testCreateVessel()
    {
        
        //method to create vessels
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);       
        Test.startTest();
        //query the created vessels
        List<Vessel__c> lstCreatedVessel = [Select id, Name ,CreatedById,LastModifiedById,OwnerId, Vessel_Name__c, Vessel_Operator__c ,Vessel_Ownership_Type__c ,Vessel_Group_Name__c ,Vessel_IMO_Number__c from Vessel__c  ];
        
        Test.stopTest();
        //test the created vessels
        System.assertEquals(lstCreatedVessel.size(),intNoOfVessels ,'New Vessel Created');
        System.assert(lstCreatedVessel[0].CreatedById == lstCreatedVessel[0].LastModifiedById, 'Created by and last modified id is same');
        System.assert(lstCreatedVessel[0].CreatedById == lstCreatedVessel[0].OwnerId, 'Created by and owner Id is same');
        System.assertEquals('Vessel UT',lstCreatedVessel[0].Vessel_Name__c ,'Vessel Name Matched');
        System.assertEquals('ALI', lstCreatedVessel[0].Vessel_Operator__c, 'Vessel Operator Matched');
    }
    
    //testing creation of vessel policy for vessels.
    @isTest
    public static void testCreateVesselPolicy()
    {
        
        //creating vessel and insurance policy which are required for creating vessel policy
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);       
        Insurance_Policy__c insurancePolicy = TestDataFactoryHelper.setUpInsurancePolicy(strProduct);
        Test.startTest();
        //creating vessel Policy
        Vessel_Policy__c vesselPolicy =TestDataFactoryHelper.setUpVesselPolicy(lstVessels[0],insurancePolicy);        
         
        //query created vessel policy
        List<Vessel_Policy__c> lstCreatedVesselPolicy = [SELECT id ,Vessel__c, Insurance_Policy__c,Name from Vessel_Policy__c where id=:vesselPolicy.id];
       
        
        String strExpectedVesselPolicyName = lstVessels[0].Name+' - '+insurancePolicy.Name;
        Test.stopTest();
        //Test  created vessel policy
        System.assertEquals(lstCreatedVesselPolicy.size(), 1, 'created vessel policy is 1');
        System.assertEquals(strExpectedVesselPolicyName, lstCreatedVesselPolicy[0].Name , 'vessel policy name assigned according to the flow');
        System.assertEquals(lstVessels[0].id, lstCreatedVesselPolicy[0].Vessel__c , 'vessel policy is created for the given vessel');
        System.assertEquals(insurancePolicy.Id, lstCreatedVesselPolicy[0].Insurance_Policy__c,'given insurance policy is assigned to vessel policy');
        
    }
    
    //testing creation of insurance policy
    @isTest 
    public static void testCreateInsurancePolicy()
    {
        //method to create insurance policy
        Insurance_Policy__c insurancePolicy =TestDataFactoryHelper.setUpInsurancePolicy(strProduct);
        Test.startTest();
        //query created insurance policy
        List<Insurance_Policy__c> lstCreatedInsurancePolicy  = [SELECT id, Name,CreatedById,LastModifiedById,OwnerId,Policy_Year__c, Policy_Start_Date__c , Policy_End_Date__c ,Deductible__c, Policy_Cover__c , P_I_Club__c FROM Insurance_Policy__c WHERE id=:insurancePolicy.id ];
        
        
        Integer intExpectedPolicyYear = lstCreatedInsurancePolicy[0].Policy_Start_Date__c.year();
        Test.stopTest();
        //Test  created insurance policy
        System.assertEquals(lstCreatedInsurancePolicy.size(),1,' New Insurance Policy Created');
        System.assertEquals(''+intExpectedPolicyYear, lstCreatedInsurancePolicy[0].Policy_Year__c , 'expected ploicy year is same as extracted');
        System.assertEquals('Insurance Policy UT Ocean',lstCreatedInsurancePolicy[0].Name,'Name Matched');
        System.assertEquals('Vsl/Voy/Incident (Costs not subject to deductible)',lstCreatedInsurancePolicy[0].Policy_Cover__c,'Insurance Details for Ocean Matched');
    
    }
    //testing creation of Major Incident
    @isTest
    public static void testCreateMajorIncident()
    {
        //create major Incident
        List<Incident__c> lstMajorIncidents = TestDataFactoryHelper.majorIncidentcreations();
        Test.startTest();
        insert lstMajorIncidents;
        
        //Query created major incident
        List<Incident__c> lstCreatedMajorIncident = [Select id, Name, Date_of_Incident__c,Status__c, Type__c, Incident_Cause__c, Incident_Location__c, Description__c,Truck_Rail_Operator__c from Incident__c WHERE id=:lstMajorIncidents[0].id];
        
        //creating name of incident as per flow
        Integer intYear = lstCreatedMajorIncident[0].Date_of_Incident__c.year();
        Integer intMonth = lstCreatedMajorIncident[0].Date_of_Incident__c.month();
        Integer intDay = lstCreatedMajorIncident[0].Date_of_Incident__c.day();
        string strExpectedName = lstCreatedMajorIncident[0].Type__c+' - '+lstCreatedMajorIncident[0].Incident_Cause__c+' - '+intDay+'/'+intMonth+'/'+intYear;
        Test.stopTest();
        //Test created major Incident
        System.assertEquals(lstCreatedMajorIncident.size(),1,' New Major Incident Created');
        System.assertEquals(strExpectedName, lstCreatedMajorIncident[0].Name, 'expected name of inicident is as per the flow' );       
        System.assertEquals('Air',lstCreatedMajorIncident[0].Type__c, 'type field matched');
       
        
        
    }
    //testing creation of Claim Event Incident
    @isTest
    public static void testCreateClaimEvent()
    {
        //create vessels for creating Claim Event, insurance policy and vessel policy
        List<Vessel__c> lstVessels =TestDataFactoryHelper.setUpVessel(intNoOfVessels);  
        Test.startTest();
        Insurance_Policy__c insurancePolicy = TestDataFactoryHelper.setUpInsurancePolicy(strProduct);
        Vessel_Policy__c vesselPolicy =TestDataFactoryHelper.setUpVesselPolicy(lstVessels[0],insurancePolicy); 
        
        //create Claim Event
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct, lstVessels[0],null,null);
        
        //query created claim event
        List<Incident__c> lstCreatedIncidentClaimEvent = [SELECT Name, P_I_Policy__c,Date_of_Incident__c,Insurance_Category__c , Insured_Vessel__c, Insured_Voyage__c, Route_Code__c FROM Incident__c WHERE id=:incidentClaimEvent.id];
       
        //creating name of incident as per flow
        Integer intYear = lstCreatedIncidentClaimEvent[0].Date_of_Incident__c.year();
        Integer intMonth = lstCreatedIncidentClaimEvent[0].Date_of_Incident__c.month();
        Integer intDay = lstCreatedIncidentClaimEvent[0].Date_of_Incident__c.day();
        string strExpectedName = lstVessels[0].Vessel_Name__c+'/'+lstCreatedIncidentClaimEvent[0].Insured_Voyage__c+' - '+intDay+'/'+intMonth+'/'+intYear;
        Test.stopTest();   
        //test created claim event
        System.assertEquals(lstCreatedIncidentClaimEvent.size(),1,' New Claim event Created');
        System.assertEquals(strExpectedName, lstCreatedIncidentClaimEvent[0].Name, 'expected name of inicident is as per the flow');
        System.assertEquals( lstVessels[0].id,lstCreatedIncidentClaimEvent[0].Insured_Vessel__c, 'Claim Event Created for same vessels');
        System.assertEquals(VesselPolicy.id, lstCreatedIncidentClaimEvent[0].P_I_Policy__c, 'vessel policy id and PI policy is same');
       
    }
    //testing creation of Financial Detail
    @isTest
    public static void testCreateFinancialDetails()
    {      
        Double dblAmount = 100;
        //create claim case         
        List<Case> lstCreatedCase = TestDataFactoryHelper.createClaimCases(strBol);
        Test.startTest();      
        //create financial details for the created claim case        
        TestDataFactoryHelper.setUpFinancialDetails(lstCreatedCase[0],dblAmount);
        
        //query the created financial details
        List<Financial_Details__c> lstCreatedFinancialDetail = [SELECT id, Exchange_Rate__c,USD_Amount__c, recordTypeId,Claim__c,Local_Currency__c,Local_Amount__c,Type__c,Conversion_Date__c  FROM Financial_Details__c];
        
        //calculate expected Exchange rate
        Double dblExpectedExchangeRate = ( lstCreatedFinancialDetail[0].USD_Amount__c /lstCreatedFinancialDetail[0]. Local_Amount__c);
        Test.stopTest();    
        //test the created financial details
        System.assertEquals(lstCreatedFinancialDetail.size(),5,' New financial Details Created');
        System.assertEquals(dblExpectedExchangeRate,lstCreatedFinancialDetail[0].Exchange_Rate__c, 'exchange rate is as expected');
        System.assertEquals('Filed Amount',lstCreatedFinancialDetail[0].Type__c,'Type matched');
    }
    
    //testing creation of Approval Request and approving of the Approval Request 
   /* @isTest
    public static void testApprovalRequestApproverApproves()
    {   
            
       //create claim case, financial details, vessel and claim event for the case        
        List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases(strBol);                     
        TestDataFactoryHelper.setUpFinancialDetails(lstCaseInstance[0], 100);       
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);                       
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct, lstVessels[0],null,null);
        Test.startTest();     
        
        //create approval request to approve it
        Approval_Request__c  approvalrequest = TestDataFactoryHelper.approvalAccept(lstCaseInstance[0],incidentClaimEvent );       
        
        //query created approval request
        List<Approval_Request__c>  lstCreatedApprovalrequest = [SELECT id, Liner_Brand__c,Sub_Type__c,Approval_Status__c from Approval_Request__c];
        Test.stopTest();
        //test the created request is approved
        System.assertEquals(lstCreatedApprovalrequest.size(),1,' New Approval Request Created');
        System.assertEquals(lstCaseInstance[0].Liner_Brand__c, lstCreatedApprovalrequest[0].Liner_Brand__c,' Brand of approval request is autopopulated as case');
        System.assertEquals(lstCaseInstance[0].Sub_Type__c, lstCreatedApprovalrequest[0].Sub_Type__c, 'Subtype of approval request is autopopulated as case');
        System.assertEquals('Approved',lstCreatedApprovalrequest[0].Approval_Status__c,'Status of approval request is approved');
        
    }
    //testing creation of Approval Request and rejecting of the Approval Request   
    @isTest
    public static void testApprovalRequestApproverRejects()
    {   
            
        //create claim case, financial details, vessel and claim event for the case        
        List<Case> lstcaseInstance = TestDataFactoryHelper.createClaimCases(strBol);                     
        TestDataFactoryHelper.setUpFinancialDetails(lstcaseInstance[0],100);        
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);                       
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct, lstVessels[0],null,null);
        Test.startTest();        
        //create approval request to approve it
        Approval_Request__c  approvalrequest = TestDataFactoryHelper.approvalReject(lstCaseInstance[0],incidentClaimEvent );       
        
        //query created approval request
        List<Approval_Request__c>  lstCreatedApprovalrequest = [SELECT id, Liner_Brand__c,Sub_Type__c, Approval_Status__c from Approval_Request__c];
        Test.stopTest();
        //test the created request is rejected
        System.assertEquals(lstCreatedApprovalrequest.size(),1,' New Approval Request Created');
         System.assertEquals(lstCaseInstance[0].Liner_Brand__c, lstcreatedApprovalrequest[0].Liner_Brand__c, ' Brand of approval request is autopopulated as case');
        System.assertEquals(lstCaseInstance[0].Sub_Type__c, lstCreatedApprovalrequest[0].Sub_Type__c, 'Subtype of approval request is autopopulated as case');
        System.assertEquals('Rejected (Approver)',lstCreatedApprovalrequest[0].Approval_Status__c, 'Status of approval request is rejected');
    }*/
    //testing closing of created Claim Case
    @isTest
    public static void testCloseClaimCase()
    {
        //create claim case, financial details, vessel and claim event for the case  
        List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases(strBol);  
        Test.startTest();
        TestDataFactoryHelper.setUpFinancialDetails(lstCaseInstance[0],100);
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);                     
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct,lstVessels[0],null,null);        
        
        //close the claim case
        TestDataFactoryHelper.closeClaimCase(lstCaseInstance[0],incidentClaimEvent);
        //query the updated claim case
        Case closedCase = [SELECT id,ClosedDate, Status from Case Where id=:lstCaseInstance[0].id];
        
        //excecpted close date & actual close date
        Datetime expectedCloseDate =  System.today();
        Datetime actualCloseDate = closedCase.ClosedDate ;
        Test.stopTest();
        //test the case is closed
        System.assertEquals('Closed - Paid',closedCase.Status , 'Status is closed for the case'); 
        System.assertEquals(date.newinstance(expectedCloseDate.year(), expectedCloseDate.month(),  expectedCloseDate.day()),date.newinstance(actualCloseDate.year(), actualCloseDate.month(),  actualCloseDate.day()), 'closing date is as per the flow');
        
    }
    //Testing conversion of External Case to Claim Case
    @isTest 
    public static void testExternalCaseToClaimOcean()
    {
        //creating External case
        TestDataFactoryHelper.createExternalCases();
        Test.startTest();
        List<Case> lstExternalCase= [SELECT id, RecordTypeId,Status from Case];
   
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToClaimOcean(lstExternalCase[0]);
            
        //query the converted claim case from external case
        List<Case> lstClaimCase = [SELECT id, RecordTypeId,Status from Case WHERE id=:lstExternalCase[0].id];        
           
        //get the record type name of the converted case
        String recordtypeName = StaticFactory.getRecordTypeNameById('Case', lstClaimCase[0].RecordTypeId);
        Test.stopTest();
        //test the case is converted to claim
        System.assertEquals(lstClaimCase.size(),1,' claim case Created');
        System.assertEquals('Claim', recordTypeName, 'external case is claim now');
          
    }
    //Testing the validation rule - Mandatory_fields_for_Court_Case
    @isTest
    public static void testMandatoryFieldForCourtCase()
    {
        try{
            //create claim case
            List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases(strBol); 
            Test.startTest();
            
            //update case
            lstCaseInstance[0].Court_Case_Status__c = null;
            update lstCaseInstance[0];
            Test.stopTest();
        }
        Catch(Exception ex)
        {
            
            System.Assert(ex.getMessage().contains('Please ensure that the following fields are completed: &quot;Location Indicator / Jursidiction&quot;, &quot;Chance Winning Court Case&quot; &amp; &quot;Court Case Status&quot;. [VR on 500]'), 'Validation rule passed');
        }
        
    }
    //Testing the validation rule - Validate_BoL_Number
    @isTest
    public static void testValidateBOLNumber()
    {
        try
        {   //create claim case
            List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases('919191900'); 
            Test.startTest();
            Case claimCase = [SELECT id, Status FROM Case WHERE id=:lstCaseInstance[0].id];
               
            Test.stopTest();
              
         }catch(Exception ex)
         {
                
                System.Assert(ex.getMessage().contains('BoL Number should be alpha numeric with 9 characters. [VR on 500]'), 'Validation rule passed');
         }
        
      
        
        
    }
    //Testing the validation rule - Validate_Capture_Claimant_Type
    @isTest
    public static void testValidateClaimantType()
    {
        //create claim case, financial details, vessel and claim event for the case  
        List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases(strBol);     
        Test.startTest();
        TestDataFactoryHelper.setUpFinancialDetails(lstCaseInstance[0],100);
        List<Vessel__c> lstVessels = TestDataFactoryHelper.setUpVessel(intNoOfVessels);                     
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct, lstVessels[0],null,null);        
       
        try{
            //update case
            lstcaseInstance[0].Nature_Of_Damage__c = 'Additional Costs - Dry';
            lstCaseInstance[0].Cause_of_Damage__c = 'Additional Cost';
            lstCaseInstance[0].claim_event__c = incidentClaimEvent.id;
            lstCaseInstance[0].Sub_Type__c = 'Commercial Claim';            
            lstCaseInstance[0].Status = 'Closed - Paid';
            update lstCaseInstance[0];
            
        }catch(Exception ex)
        {
           
            System.Assert(ex.getMessage().contains('Claimant Type  is required'), 'Validation rule passed');
        }
        Test.stopTest();        
    }
    
    //Testing the validation rule - Validate_Claims_Hub_for_Claims
    @isTest
    public static void testValidateClaimsHubsForClaims()
    {
        
        //create claim case, financial details, vessel and claim event for the case  
        List<Case> lstCaseInstance = TestDataFactoryHelper.createClaimCases(strBol);    
        Test.startTest();
        TestDataFactoryHelper.setUpFinancialDetails(lstCaseInstance[0],100);
        List<Vessel__c> lstVessels =TestDataFactoryHelper.setUpVessel(intNoOfVessels);                     
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setUpClaimEvent(strProduct, lstVessels[0],null,null);        
        
        try{//update case
            
            lstCaseInstance[0].Nature_Of_Damage__c = 'Additional Costs - Dry';
            lstCaseInstance[0].Cause_of_Damage__c = 'Additional Cost';
            lstCaseInstance[0].claim_event__c = incidentClaimEvent.id;
            lstCaseInstance[0].Sub_Type__c = 'Commercial Claim';
            lstCaseInstance[0].Claimant_Type__c = 'Direct Customer';
            lstCaseInstance[0].Status = 'Closed - Paid';
            update lstCaseInstance[0];
        }
        Catch(Exception ex)
        {
            
            System.Assert(ex.getMessage().contains('Please set the claim hub responsible for this claim.'), 'Validation rule passed');

        }
        Test.stopTest();
        
    }

}