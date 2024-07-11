/*

* test class for Claims LNS Module.

*

       Date           Owner                                                Description

*********************************************************************************************************************************  

     21/2/2022    divya.kumari@maersk.com                       testMajorIncidentCreation:Testing creation of majorincident    
     21/2/2022    divya.kumari@maersk.com                       testCreateClaimEventLNS:Testing creation of ClaimEvent              
     21/2/2022    divya.kumari@maersk.com                       testControllingEntity:Testing creation of ControllingEntity        
     21/2/2022    divya.kumari@maersk.com                       testCreateInsurancePolicy:Testing creation of InsurancePolicy    
     21/2/2022    divya.kumari@maersk.com                       testApprovalRequestApproverApproves:Testing creation of Approval Request and approving of the Approval Request    
     21/2/2022    divya.kumari@maersk.com                       testClaimLNSOnboarding: Claim L&s Onboarding   
     21/2/2022    divya.kumari@maersk.com                       testExternalCaseToLNSClaim: Convert LNS email to Case to claim    
     21/2/2022    divya.kumari@maersk.com                       testBOLNumberNotRequiredForLNS: Testing validation rule BoL_number_not_required_for_LNS 
     21/2/2022    divya.kumari@maersk.com                       testClaimReportedToInsurerDateRequired: Testing validation rule Claim_reported_to_Insurer_date_required 
     21/2/2022    divya.kumari@maersk.com                       testMandatoryFieldForCourtCase: Testing validation rule Mandatory_fields_for_Court_Case
     21/2/2022    divya.kumari@maersk.com                       testOtherClaimantMandatory: Testing validation rule Other_Claimant_Mandatory 
*/


    @isTest public class ClaimsForLNSTest
    {
          
    public static String strProduct = 'LNS';
            
    //Testing creation of majorincident
    @isTest
    public static void testMajorIncidentCreation()
    { 
        List<Incident__c> majincident = TestDataFactoryHelper.majorIncidentCreations();
        insert majincident;
                
        List<Incident__c> createdMajorIncident  = [SELECT id,Name,Date_of_Incident__c,Status__c, Type__c, Incident_Cause__c, Incident_Location__c, Description__c,Truck_Rail_Operator__c FROM Incident__c WHERE id=:majincident[0].id];
        System.debug('##### Majority Incident : '+createdMajorIncident);
        
        Integer year = createdMajorIncident[0].Date_of_Incident__c.year();
        Integer month = createdMajorIncident[0].Date_of_Incident__c.month();
        Integer day = createdMajorIncident[0].Date_of_Incident__c.day();
        string expectedName = createdMajorIncident[0].Type__c+' - '+createdMajorIncident[0].Incident_Cause__c+' - '+day+'/'+month+'/'+year;       
        
        System.assertEquals(createdMajorIncident.size(),1,' New Major Incident Created');        
        System.assertEquals(expectedName,createdMajorIncident[0].Name);
    }
         
    
    //Testing creation of ClaimEvent
    @isTest
    public static void testCreateClaimEventLNS()
    {   
         Contact  conInstance = TestDataFactoryHelper.createContactRecord();  
         Contact con = TestDataFactoryHelper.createContactRecord();
         Insurance_Policy__c ins=TestDataFactoryHelper.setupInsurancePolicy(strProduct);
         Incident__c incidentClaimEvent = TestDataFactoryHelper.setupClaimEvent(strProduct, null,con,ins);
         
        
         List<Incident__c> createdIncidentClaimEvent = [SELECT Name, Date_of_Incident__c,Insurance_Category__c , Insured_Vessel__c, Insured_Voyage__c, Route_Code__c,Insurance_Policy__c,Location__c FROM Incident__c WHERE id=:incidentClaimEvent.id];
         System.debug('##### Created Claim Event : '+createdIncidentClaimEvent);

        Integer year = createdIncidentClaimEvent[0].Date_of_Incident__c.year();
        Integer month = createdIncidentClaimEvent[0].Date_of_Incident__c.month();
        Integer day = createdIncidentClaimEvent[0].Date_of_Incident__c.day();
        string expectedName = 'United States'+' - '+day+'/'+month+'/'+year+' - '+createdIncidentClaimEvent[0].Insurance_Category__c;        
        
        //test created claim event
         System.assertEquals(createdIncidentClaimEvent.size(),1,' New Claim event Created');
         System.assertEquals(expectedName, createdIncidentClaimEvent[0].Name );
         System.assertEquals('Cargo Liabilities',createdIncidentClaimEvent[0].Insurance_Category__c);
         System.assertEquals(ins.id,createdIncidentClaimEvent[0].Insurance_Policy__c);
                
     }


    //Testing creation of controllingentity
     @isTest
     public static void testControllingEntity()
     {

        Controlling_Entity__c entityIterator = TestDataFactoryHelper.controllingEntityCreations();       
        // insert entity; 

        List<Controlling_Entity__c> createdentity  = [SELECT id,Name,OwnerId FROM Controlling_Entity__c WHERE id=:entityIterator.id];
        string expectedName = createdentity[0].Name;
        System.debug('##### Controlling Entity : '+createdentity);
        System.debug('##### Controlling Entity OwnerId : '+createdentity[0].OwnerId);
         
        System.assertEquals(createdentity.size(),1,'New controlling entity Created');            
        System.assertEquals(expectedName,createdentity[0].Name);
         
     }
    
            
    //Testing creation of InsurancePolicy
    @isTest 
    public static void testCreateInsurancePolicy()
    {
        Insurance_Policy__c insurancePolicy = TestDataFactoryHelper.setupInsurancePolicy(strProduct);
        //query created insurance policy
        List<Insurance_Policy__c> createdInsurancePolicy  = [SELECT id, Name, Policy_Start_Date__c , Policy_End_Date__c ,Deductible__c, Policy_Cover__c , P_I_Club__c,Insurance_category__c,Geographic_Scope__c,Insurer__c FROM Insurance_Policy__c WHERE id=:insurancePolicy.id ];
        System.debug('##### Created Insurance Policy : '+createdInsurancePolicy);

        Integer year = createdInsurancePolicy[0].Policy_Start_Date__c.year(); 
        string expectedName = createdInsurancePolicy[0].Insurance_category__c+'  - '+year+'  - '+createdInsurancePolicy[0].Geographic_Scope__c+'  - '+createdInsurancePolicy[0].Insurer__c;
        
        //Test created insurance policy        
        System.assertEquals(createdInsurancePolicy.size(),1,' New Insurance Policy Created');
        System.assertEquals(expectedName,createdInsurancePolicy[0].Name,'Name Matched');
        
    }
          

    //Testing creation of Approval Request and approving of the Approval Request
   /* @isTest
    public static void testApprovalRequestApproverApproves()
    {   
        Contact con = TestDataFactoryHelper.createContactRecord();
        Insurance_Policy__c ins=TestDataFactoryHelper.setupInsurancePolicy(strProduct);
        TestDataFactoryHelper.createExternalCases();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
        
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        List<Case> caseInstance = [SELECT id, RecordTypeId,Status,Origin_Country__c,Liner_Brand__c,Sub_Type__c,Destination_Country__c from Case WHERE id=:externalCase[0].id];        
        System.debug('##### Converted claim case : '+caseInstance);    
                                  
        Incident__c incidentClaimEvent = TestDataFactoryHelper.setupClaimEvent(strProduct, null,con,ins);
        Contact conInstance = TestDataFactoryHelper.createContactRecord();
        Controlling_Entity__c entityIterator = TestDataFactoryHelper.controllingEntityCreations();
        System.debug('##### contro : '+entityIterator);

        Test.startTest();        
        //create approval request to approve it
        Approval_Request__c  approvalrequest = TestDataFactoryHelper.lnsApprovalAccept(caseInstance[0],incidentClaimEvent,conInstance,entityIterator);        
        
        System.debug('##### Created Approval Request : '+approvalrequest);
        
        //query created approval request
        List<Approval_Request__c>  createdApprovalrequest = [SELECT id,Liner_Brand__c,Sub_Type__c ,Approval_Status__c from Approval_Request__c];
        Test.stopTest();
        
        //test the created request is approved
        System.assertEquals('Approved',createdApprovalrequest[0].Approval_Status__c);
        System.assertEquals(caseInstance[0].Liner_Brand__c, createdApprovalrequest[0].Liner_Brand__c);
        System.assertEquals(caseInstance[0].Sub_Type__c, createdApprovalrequest[0].Sub_Type__c);
        System.assertEquals(createdApprovalrequest.size(),1,' New Approval Request Created');
        
    }*/
                          
            
    //Claim L&s Onboarding
    public static testMethod Messaging.InboundEmailResult testClaimLNSOnboarding()
    {
        
        Messaging.InboundEmailResult result = TestDataFactoryHelper.sendEmailToBA();
        System.assertEquals( result.success , true);
        return result;
     }   


     //Convert LNS email to Case to claim
    @isTest 
    public static void testExternalCaseToLNSClaim()
    {
        
        //creating External case
        TestDataFactoryHelper.createExternalCases();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
        
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        List<Case> claimCase = [SELECT id, RecordTypeId,Status,Origin_Country__c from Case WHERE id=:externalCase[0].id];        
        System.debug('##### Converted claim case : '+claimCase);
        
        //get the record type name of the converted case
        String recordtypeName = StaticFactory.getRecordTypeNameById('Case', claimCase[0].RecordTypeId);
        
        //test the case is converted to claim
        System.assertEquals(claimCase.size(),1,' Converted claim case');
        System.assertEquals('Claim', recordTypeName);
            
    }
        

    //Testing the validation rule - BoL_number_not_required_for_LNS
    @isTest
    public static void testBOLNumberNotRequiredForLNS()
    {
        TestDataFactoryHelper.createExternalCases();
        Contact  conInstance = TestDataFactoryHelper.createContactRecord();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
                Test.startTest();        
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        Case claimCase = [SELECT id, RecordTypeId,Status,Type,Sub_Type__c from Case WHERE id=:externalCase[0].id];        
        System.debug('##### Converted claim case- : '+claimCase);
                Test.stopTest();        
        try
        {
            externalCase[0].BoL_Number__c = '919191919';
            update externalCase[0];
        }
        Catch(Exception ex)
        {
            system.debug('##### The Error is : '+ex);
            System.Assert(ex.getMessage().contains('BoL number should not be entered for Maersk L&amp;S.'));
        }
        
    }


    //Testing the validation rule - Claim_reported_to_Insurer_date_required
    @isTest
    public static void testClaimReportedToInsurerDateRequired()
    {            
        TestDataFactoryHelper.createExternalCases();
        Contact  conInstance = TestDataFactoryHelper.createContactRecord();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
        Test.startTest();
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        Case claimCase = [SELECT id, RecordTypeId,Status,Type,Sub_Type__c from Case WHERE id=:externalCase[0].id];  
        Test.stopTest();      
        System.debug('##### Converted claim case : '+claimCase);           
        try
        {
            externalCase[0].Claim_Reported_To_Insurer__c = 'Yes';
            update externalCase[0];
        }
        Catch(Exception ex)
        {
            system.debug('##### The Error is : '+ex);
            //String testString = 'Claim Reported to Insurer is mandatory for Claim - L&amp;S. Claim Reported to Insurer Date is required when Claim Reported to Insurer is selected 'Yes'.: []';                 
            //System.Assert(ex.getMessage().contains(''));
        }
        
    }
        
    
    //Testing the validation rule - Mandatory_fields_for_Court_Case
    @isTest
    public static void testMandatoryFieldForCourtCase()
    {

        TestDataFactoryHelper.createExternalCases();
        Contact  conInstance = TestDataFactoryHelper.createContactRecord();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
        Test.StartTest();
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        Case claimCase = [SELECT id, RecordTypeId,Status,Type,Sub_Type__c,Court_Case__c from Case WHERE id=:externalCase[0].id];        
        System.debug('##### Converted claim case : '+claimCase); 
        Test.StopTest();
        try
        {
            externalCase[0].Court_Case__c = 'Yes';
            update externalCase[0];
        }
            Catch(Exception ex)
        {
        system.debug('The Error is : '+ex);
        System.Assert(ex.getMessage().contains('Please ensure that the following fields are completed: &quot;Location Indicator / Jursidiction&quot;, &quot;Chance Winning Court Case&quot; &amp; &quot;Court Case Status&quot;. [VR on 500]'));
        }
        
    }
        

    //Testing the validation rule - Other_Claimant_Mandatory        
    @isTest
    public static void testOtherClaimantMandatory()
    {

        TestDataFactoryHelper.createExternalCases();
        Contact  conInstance = TestDataFactoryHelper.createContactRecord();
        List<Case> externalCase= [SELECT id, RecordTypeId,Status from Case];
        Test.StartTest();
        //converting the created external case to Claim case
        TestDataFactoryHelper.convertExternalCaseToLnsClaim(externalCase[0]);
        
        //query the converted claim case from external case
        Case claimCase = [SELECT id, RecordTypeId,Status,Type,Sub_Type__c,Claimant_Type__c from Case WHERE id=:externalCase[0].id];        
        System.debug('##### Converted claim case : '+claimCase); 
        Test.StopTest();
        try
        {
            externalCase[0].Claimant_Type__c = 'Other';
            update externalCase[0];
        }
        Catch(Exception ex)
        {
            system.debug('##### The Error is : '+ex);
            System.Assert(ex.getMessage().contains(' Other Claimant Type is required only when Claimant Type is Other.'));
        }
    }     
     
        
    }