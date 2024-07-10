/**
 * Author   : Divya Kumari & Kusum Kumari Jha
 * Purpose  : Test Data Factory for Smoke Testing Automation 
 * 
 * Date            Owner                               Description
 * -------------   -------------------------------     ------------------------------------------------------------
 * 14-Feb-2022     kusum.jha@maersk.com                createContactRecord()
 * 23-Feb-2022     kusum.jha@maersk.com                populateCommonCaseFields()
 * 23-Feb-2022     kusum.jha@maersk.com                sendEmailToBA()
 * 09-Mar-2022     kusum.jha@maersk.com                createEmailToCase(Case caseInstance)
 * 09-Mar-2022     kusum.jha@maersk.com                closeEmailToCase(Case caseInstance)
 * 09-Mar-2022     kusum.jha@maersk.com                reopenEmailToCase(Case caseInstance)
 * 18-Feb-2022      kusum.jha@maersk.com                createProActiveEmailTemplate(contact conInstance ,EmailTemplate validEmailTemplate)
 * 18-Feb-2022     kusum.jha@maersk.com                createProActiveCase(contact conInstance ,EmailTemplate createdTemplate)
 * 18-Feb-2022     kusum.jha@maersk.com                reopenProActiveCase(Case insertedCases)
 * 19-Feb-2022     divya.kumari@maersk.com             caseReopen()
 * 21-Feb-2022     kusum.jha@maersk.com                setUpVessel(Integer noOfVessels)
 * 21-Feb-2022     kusum.jha@maersk.com                setUpVesselPolicy(Vessel__c vessel, Insurance_Policy__c insurancePolicy)
 * 21-Feb-2022     kusum.jha@maersk.com                setUpInsurancePolicy(String product)
 * 21-Feb-2022     kusum.jha@maersk.com                setUpClaimEvent(String product, Vessel__c vessel , Contact con, Insurance_Policy__c ins)
 * 21-Feb-2022     divya.kumari@maersk.com             majorIncidentCreations()
 * 21-Feb-2022     kusum.jha@maersk.com                createClaimCases(String bol)
 * 21-Feb-2022     divya.kumari@maersk.com             createClaimLnsCases(contact conInstance)
 * 21-Feb-2022     kusum.jha@maersk.com                setUpFinancialDetails(Case CaseInstance, Double amount)
 * 22-Feb-2022     divya.kumari@maersk.com             controllingEntityCreations()
 * 22-Feb-2022     kusum.jha@maersk.com                closeClaimCase(Case caseInstance, Incident__c incidentClaimEvent)
 * 22-Feb-2022     kusum.jha@maersk.com                approvalAccept(Case caseInstance, Incident__c incidentClaimEvent)
 * 22-Feb-2022     divya.kumari@maersk.com             lnsApprovalAccept(Case caseInstance, Incident__c incidentClaimEvent,contact conInstance,Controlling_Entity__c entityIterator)
 * 22-Feb-2022     kusum.jha@maersk.com                approvalReject(Case caseInstance, Incident__c incidentClaimEvent)
 * 23-Feb-2022     divya.kumari@maersk.com             createClaimCaseRecordForBAuser(String BA , contact conInstance )
 * 23-Feb-2022     divya.kumari@maersk.com             convertExternalCaseToLnsClaim(Case caseInstance)
 * 23-Feb-2022     kusum.jha@maersk.com                createClaimRecoveryCases(Incident__c incidentClaimEvent)
 * 23-Feb-2022     kusum.jha@maersk.com                claimRecoveryClose(Case caseInstance)
 * 25-Feb-2022     kusum.jha@maersk.com                createExternalCases()
 * 25-Feb-2022     kusum.jha@maersk.com                convertExternalCaseToClaimOcean(Case CaseInstance)
 * 02-Mar-2022     divya.kumari@maersk.com             serviceCallCreation()
 * 25-Feb-2022     kusum.jha@maersk.com                getConnectiveTasks()
 * 03-Mar-2022     kusum.jha@maersk.com                createISRCaseMaerskLnS()
 * 03-Mar-2022     kusum.jha@maersk.com                createISRCaseML()
 * 04-Mar-2022     divya.kumari@maersk.com             maerskideasubmission()
 * 03-Mar-2022     kusum.jha@maersk.com                generateRandomString(Integer length)
 * 03-Mar-2022     kusum.jha@maersk.com                generateRandomString(String characterSet, Integer length)
 * 03-Mar-2022     kusum.jha@maersk.com                generateRandomEmail(String domain)
 * 03-Mar-2022     kusum.jha@maersk.com                generateRandomEmail()
 * 03-Mar-2022     kusum.jha@maersk.com                generateUser()
 * 03-Mar-2022     kusum.jha@maersk.com                createUser()
 * 13-Jun-2022     Ronnie@SF                           SPI-100: Removed brand hardcoding
 * 09-Sep-2022     Ronnie@SF                           CRM0000030: Improved retrieval of recordtype info
 * 27-March-2023   Vivek@maersk.com                    SC-7347 Changes for CLaim/Claim Recovery records fields from Sub_Type->Type , RFC->Sub_Type to resolve RFC limits
 * 27-March-2023     Vivek@maersk.com                populateCommonCaseFieldsClaims()

 */


@isTest
public class TestDataFactoryHelper {
    public static boolean booCreate = true;
    public static integer intNumberOfCases = 5;
    public static list<Case> lstCases = new list<Case>();
    public static Contact conInstance = null;
    public static id SYSADMIN_PROFILE_ID = [select id from Profile where name = 'System Administrator'][0].id;
    public static Set<String> setPriorRandoms;

 //create contact record for BA user
    public static Contact createContactRecord() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();            
            conInstance = ContactData_Test.lstContacts[0];
         }
        system.debug(conInstance);
        return conInstance;
    }
    
    private static void populateCommonCaseFields() {
         conInstance = CreateContactRecord();
         lstCases = new list<Case>();
        for(integer i=0; i<intNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Subject = 'CaseTestData Subject_' + i;
            caseIterator.Description = 'CaseTestData Description_' + i;
            caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
            caseIterator.ContactId = conInstance.Id;
            caseIterator.AccountId = conInstance.AccountId;
            caseIterator.Status = 'New';
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'Amend Booking Details';
            caseIterator.Country__c = conInstance.Country__c;
            caseIterator.Cargo_Classification__c ='US Military (USM)';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Direction__c = 'Export';
            caseIterator.Case_Channel__c = 'Email';
            caseIterator.Origin = 'MSLUSEXP';
            caseIterator.Case_Visibility__c = 'All Users';
            lstCases.add(caseIterator);
        }
    }

    private static void populateCommonCaseFieldsClaims() {
        conInstance = CreateContactRecord();
        lstCases = new list<Case>();
       for(integer i=0; i<intNumberOfCases; i++) {
           Case caseIterator = new Case();
           caseIterator.Subject = 'CaseTestData Claims Subject_' + i;
           caseIterator.Description = 'CaseTestData Description_' + i;
           caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
           caseIterator.ContactId = conInstance.Id;
           caseIterator.AccountId = conInstance.AccountId;
           caseIterator.Status = 'New';
           caseIterator.Type = 'Claim - Ocean';
           caseIterator.Sub_Type__c = 'Commercial Claim';
           caseIterator.Country__c = conInstance.Country__c;
           caseIterator.Cargo_Classification__c ='US Military (USM)';
           caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
           caseIterator.Direction__c = 'Export';
           caseIterator.Case_Channel__c = 'Email';
           caseIterator.Origin = 'MSLUSEXP';
           caseIterator.Case_Visibility__c = 'All Users';
           lstCases.add(caseIterator);
       }
   }
    
   public static Messaging.InboundEmailResult sendEmailToBA() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'test email-to-case';
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'user@acme.com';
        env.toAddress = 'testba@test.com';
           
        EmailMessageInbound emailHandler = new EmailMessageInbound();
        Messaging.InboundEmailResult result = emailHandler.handleInboundEmail(email, env);
        return result;
    }
    
    //create a case record for BA user.
     public static List<Case> createEmailToCase() {
        PopulateCommonCaseFields();
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
            caseIterator.SuppliedEmail = 'Testone@gmail.com';
            caseIterator.Case_Channel__c = 'Email';
        }
        
        if(booCreate) {
            insert lstCases;
        }
         return lstCases;
    }
    
    //close the email-to-case case
    public static void closeEmailToCase(Case caseInstance) {
        caseInstance.Status = 'Closed - Not a case';
        caseInstance.Product__c = 'Ocean';
        caseInstance.Type = 'Cargo/Container';
        caseInstance.Sub_Type__c = 'Container Status';
        caseInstance.Reason_For_Case__c ='Container Maritime Tracking Request';
        update caseInstance;
    }
    
    public static void reopenEmailToCase(Case caseInstance) {
        EmailMessage emailMssg = new EmailMessage();
        emailMssg.fromaddress = 'Test@maersk.com';
        emailMssg.incoming = true;
        emailMssg.toaddress = 'test1@maersk.com';
        emailMssg.subject = 'Test Email';
        emailMssg.textbody = 'testing';
        emailMssg.Subject = 'testing';
        emailMssg.parentid = caseInstance.Id;
        insert emailMssg;
        
        caseInstance.Status = 'In Progress';
        //caseInstance.Case_Reopened__c =Boolean.valueOf('true');
        update caseInstance;
    }
    
    //create a proactive email template
    public static List<ProActive_Email_Templates__c> createProActiveEmailTemplate(contact conInstance ,EmailTemplate validEmailTemplate) {
        // create a list of proactiveEmailTemplate object i.e. pTempList
        List<ProActive_Email_Templates__c> pTempList = new List<ProActive_Email_Templates__c>();
       
        for(Integer i=0;i<2;i++) {
            ProActive_Email_Templates__c ProEmailTemp = new ProActive_Email_Templates__c();
            ProEmailTemp.Contact__C = conInstance.Id;
            ProEmailTemp.Name = 'Pro Active Email Template Testing Module';
            ProEmailTemp.Type__c = 'Booking';
            ProEmailTemp.Sub_Type__c ='Amend Booking Details';
            ProEmailTemp.Reason_For_Case__c='Amend Booking Details';
            ProEmailTemp.Country__c = conInstance.Country__c;
            ProEmailTemp.Case_Visibility__c = 'Multi-Carrier';
            ProEmailTemp.Product__c='SCM';
            ProEmailTemp.To_Email_Address__c='test@test.com';
            ProEmailTemp.CC_Email_Address__c='test@test.com';
            ProEmailTemp.ReplyTo_Email_Address__c = 'testba@test.com';
            ProEmailTemp.Brand__c = BrandUtilities.MAERSKLS;
            if(i==0){
                ProEmailTemp.Email_Template_API_Name__c=validEmailTemplate.id; // emailTemplate Id
            } else {
                ProEmailTemp.Email_Template_API_Name__c='Test';
            }
            pTempList.add(ProEmailTemp);
            }
        return pTempList;        
    }
    
    public static void createProActiveCase(contact conInstance ,EmailTemplate createdTemplate) {
        //Create Document       
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;     
        
        //Get Content Version       
        ContentVersion cv1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];         
        //Get Content Documents
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
        
        ProActive_Email_Templates__c ProEmailTemp = new ProActive_Email_Templates__c();
        ProEmailTemp.Contact__C = conInstance.Id;
        ProEmailTemp.Name = 'Pro Active Email Template Testing Module';
        ProEmailTemp.Type__c = 'Carrier booking';
        ProEmailTemp.Sub_Type__c ='Amend Booking Details';
        ProEmailTemp.Reason_For_Case__c='Customer change request';
        ProEmailTemp.Country__c = conInstance.Country__c;
        ProEmailTemp.Case_Visibility__c = 'Multi-Carrier';
        ProEmailTemp.Product__c='SCM';
        ProEmailTemp.To_Email_Address__c='test@test.com';
        ProEmailTemp.CC_Email_Address__c='test@test.com';
        ProEmailTemp.ReplyTo_Email_Address__c = 'testba@test.com';
        ProEmailTemp.Email_Template_API_Name__c=createdTemplate.id; 
        ProEmailTemp.Brand__c = BrandUtilities.MAERSKLS;
        insert ProEmailTemp;

        proActiveEmailController.EmailContent eCon= new proActiveEmailController.EmailContent();
        eCon.to = new List<String>{'test@test.com'};
        eCon.cc = new List<String>{'testcc@test.com'};
        eCon.subject=createdTemplate.Subject;
        eCon.bodyHTML=createdTemplate.Body;
        eCon.templateAPIName='TestTemplate';
        eCon.templateId=createdTemplate.Id;
        eCon.contactId=conInstance.Id;
        eCon.type='Carrier booking';
        eCon.subType='Amend Booking Details';
        eCon.product='SCM';
        eCon.country=conInstance.Country__c;
        eCon.reason='Customer change request';
        eCon.caseVisibility='Multi-Carrier';
        eCon.DocIds = cd.Id;//Adding attachment
        eCon.Brand = BrandUtilities.MAERSKLS;
        eCon.proActiveTempId = ProEmailTemp.Id;
        String JSONstr = JSON.serialize(eCon); 
        
        //Upon clicking send email
        proActiveEmailController.createCaseSendEmail(JSONstr);
    }
    
    //reopen proactive case on receiving email 
    public static void reopenProActiveCase(Case insertedCases) {
        EmailMessage emailMssg = new EmailMessage();
        emailMssg.fromaddress = 'Test@lns.maersk.com';
        emailMssg.incoming = true;
        emailMssg.toaddress = 'test1@maersk.com';
        emailMssg.subject = 'Test Email';
        emailMssg.textbody = 'testing';
        emailMssg.Subject = 'testing';
        emailMssg.parentid = insertedCases.Id;
        insert emailMssg;
        
        case cases = [Select Id , Status,Case_Reopened__c From Case Where id=:insertedCases.id];
        cases.Status = 'In Progress';
        cases.Case_Reopened__c =Boolean.valueOf('true');
        update cases;
    }
   
    public static void  caseReopen() {
     contact conInstance;
     String BA;
     Case c = [select id,Status,Case_Reopened__c,type from case  limit 1];
     Survey__c s = [select Comments__c from Survey__c  limit 1];
     s.Comments__c='Reopen the case';
     update s;
    } 
    
    //create a Vessel
    public static List<Vessel__c> setUpVessel(Integer noOfVessels) {
        List<Vessel__c> vesselsList = new List<Vessel__c>();
        for(integer i=0; i< noOfVessels; i++) {
            Vessel__c vessels = new Vessel__c();   
            vessels.Name = 'VesselCode UT 123';
            vessels.Vessel_Name__c = 'Vessel UT';
            vessels.Vessel_Operator__c = 'ALI';
            vessels.Vessel_Ownership_Type__c = 'Own';
            vessels.Vessel_Group_Name__c = 'Vessel Group UT';
            vessels.Vessel_IMO_Number__c = 'IMO-123';
            vesselsList.add(vessels);
        }
        insert vesselsList;
        return vesselsList;
    }
    
    //setup vessel policy
    public static Vessel_Policy__c setUpVesselPolicy(Vessel__c vessel, Insurance_Policy__c insurancePolicy) {
        Vessel_Policy__c vesselPolicy = new Vessel_Policy__c();
        
        vesselPolicy.Name = 'Vessel Policy UT';
        vesselPolicy.Vessel__c = vessel.Id;
        vesselPolicy.Insurance_Policy__c = insurancePolicy.Id;
        vesselPolicy.Vessel_Policy_Start_Date__c = Datetime.newInstance(2022, 2, 20);
        vesselPolicy.Vessel_Policy_End_Date__c = Datetime.newInstance(2024, 2, 17);
        insert vesselPolicy;
        return vesselPolicy;
    }

    //setup Insurance Policy
    public static Insurance_Policy__c setUpInsurancePolicy(String product) {
    
        Insurance_Policy__c insurancePolicy = new Insurance_Policy__c();
        insurancePolicy.Name = 'Insurance Policy UT '+product;
        insurancePolicy.Policy_Start_Date__c = Datetime.newInstance(2022, 2, 20);
        insurancePolicy.Policy_End_Date__c = Datetime.newInstance(2024, 2, 17);
        insurancePolicy.Deductible__c = 3000;
        if(product == 'Ocean') {
            insurancePolicy.Policy_Cover__c ='Vsl/Voy/Incident (Costs not subject to deductible)';
            insurancePolicy.P_I_Club__c = 'Britannia';
        }
        if(product=='LNS') {
            insurancePolicy.Insurance_category__c='Cargo Liabilities';
            insurancePolicy.Geographic_Scope__c='test';
            insurancePolicy.Insurer__c='test123';
        }
        insert insurancePolicy;
        return insurancePolicy;
    }

    //setup claim event
    public static Incident__c setUpClaimEvent(String product, Vessel__c vessel , Contact con, Insurance_Policy__c ins) {
        Id RecordTypeIdClaimEvent = StaticFactory.getRecordTypeIdByName('Incident__c', 'Claim Event');
        Incident__c incidentClaimEvent = new Incident__c();
        
        incidentClaimEvent.recordTypeId = RecordTypeIdClaimEvent;
        incidentClaimEvent.Name = 'Claim Incident UT'+product;
        incidentClaimEvent.Date_of_Incident__c = Datetime.newInstance(2022, 2, 21);
        if(product=='Ocean') {
            incidentClaimEvent.Insurance_Category__c = 'Maersk Ocean';
            incidentClaimEvent.Insured_Vessel__c = vessel.id;
            incidentClaimEvent.Insured_Voyage__c = 'Voyage UT 123';
            incidentClaimEvent.Route_Code__c = 'RUT3';
        }
        
        if(product=='LNS') {
            incidentClaimEvent.Insurance_Category__c = 'Cargo Liabilities';
            incidentClaimEvent.Location__c = con.Country__c;
            incidentClaimEvent.Insurance_Policy__c = ins.id;  
        }
         insert incidentClaimEvent;
         return incidentClaimEvent;
    }
    
    //create major incident
    public static List<Incident__c> majorIncidentCreations() {
        Id RecordTypeIdMajorIncident = StaticFactory.getRecordTypeIdByName('Incident__c', 'Major Incident');
        List<Incident__c> lstmajincident = new list<Incident__c>();
        for(integer i=0; i<5; i++) {
            Incident__c incidentIterator = new Incident__c();
            incidentIterator.recordTypeId = RecordTypeIdMajorIncident;
            incidentIterator.Name='test MI 123';
            date mydate = date.parse('05/11/2012');
            incidentIterator.Date_of_Incident__c=mydate;
            incidentIterator.Status__c='New';
            incidentIterator.Type__c='Air';
            incidentIterator.Incident_Cause__c='Aeroplane Crash';
            incidentIterator.Incident_Location__c='In the Sky';
            incidentIterator.Description__c='test';
            incidentIterator.Truck_Rail_Operator__c='Air';    
            lstmajincident.add(incidentIterator);
        }
        system.debug('incident-'+lstmajincident);  
        return lstmajincident;      
    }
    
    public static list<Case> createClaimCases(String bol) {
        populateCommonCaseFieldsClaims();
        Id claimRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim');
        
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = claimRTId;
            caseIterator.Type = 'Claim - Ocean';
            caseIterator.BoL_Number__c = bol; 
            caseIterator.P_I_Cover__c = 'Yes';
            caseIterator.Court_Case__c = 'Yes';
            caseIterator.Chance_Winning_Court_Case__c = 67;
            caseIterator.Location_Indicator_Jurisdiction__c = caseIterator.Country__c;
            caseIterator.Court_Case_Status__c = 'On Appeal';
            caseIterator.Claim_Filed_Date__c = System.today() - 1;
        }
        
        if(booCreate) {
            insert lstCases;
        }
        return lstCases;
    }
    
    public static list<Case> createClaimLnsCases(contact conInstance) {
        Id RecordTypeIdCase = StaticFactory.getRecordTypeIdByName('Case', 'Claim');
        
        List<Case > lstCases = new list<Case>();

                Case caseIterator = new Case();
                caseIterator.Subject = 'CaseTestData Subject_' ;
                caseIterator.Description = 'CaseTestData Description_';
                caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
                caseIterator.ContactId = conInstance.Id;
                caseIterator.recordTypeId =RecordTypeIdCase;
                caseIterator.AccountId = conInstance.AccountId;
                caseIterator.Type = 'Booking';
                caseIterator.Sub_Type__c = 'New Booking Request';
                caseIterator.Reason_For_Case__c = 'Booking Request';
                caseIterator.Country__c = conInstance.Country__c;
        caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
                caseIterator.Direction__c = 'Export';
                caseIterator.Case_Channel__c = 'Email';
                caseIterator.Origin = 'LNSBDEXE';
                caseIterator.Case_Visibility__c = 'All Users';
                
        if(caseIterator.recordTypeId == RecordTypeIdCase) {
                    caseIterator.recordTypeId =RecordTypeIdCase;
                    caseIterator.Type = 'Claim - L&S';
                    update caseIterator;
                }
                lstCases.add(caseIterator);
 
        if(booCreate) {
            insert lstCases;
        }
        return lstCases;
    }
    
    //Set up Financial details
    public static void setUpFinancialDetails(Case CaseInstance, Double amount) {
        integer iNumberOfFinancialDetails = 5;
        list<Financial_Details__c> lstFinancialDetails;
        
        List<String> TypeString = new List<String> {'Filed Amount', 
                                                    'Estimated Settlement',
                                                    'Maximum Liability',
                                                    'Cargo Claim Paid',
                                                    'Submitted Amount',
                                                    'P&I Reimbursement',
                                                    'Recovery Obtained',
                                                    'Commercial Claim Paid',
                                                    'Sum of Incurred Cost'
                                                    };
        lstFinancialDetails = new list<Financial_Details__c>();
        for(integer i=0; i<iNumberOfFinancialDetails; i++) {
            Financial_Details__c fdIterator = new Financial_Details__c();
            fdIterator.Claim__c = caseInstance.Id;
            fdIterator.Local_Currency__c = 'INR';
            fdIterator.Local_Amount__c = amount;
            fdIterator.USD_Amount__c = amount*2;
            fdIterator.Type__c = TypeString[i];
            fdIterator.Conversion_Date__c =  System.today();
            lstFinancialDetails.add(fdIterator);
        }
            insert lstFinancialDetails;
    }
    
    //controlling entity
    public static Controlling_Entity__c controllingEntityCreations(){ 
        Contact cons = createContactRecord();
        Controlling_Entity__c entityIterator = new Controlling_Entity__c();
        entityIterator.Name='test123';
        entityIterator.Entity_Code__c='t234';
        entityIterator.Status__c='Active';
        entityIterator.Ownership_Type__c='Holding Company';
        entityIterator.Country__c=cons.Country__c;
        insert entityIterator;
       // lstcontentity.add(entityIterator);
        return entityIterator;
    }
    
    //Close Claim
    public static void closeClaimCase(Case caseInstance, Incident__c incidentClaimEvent) {
        caseInstance.Sub_Type__c = 'Commercial Claim';
        caseInstance.Status = 'Closed - Paid';
        caseInstance.Claim_Event__c = incidentClaimEvent.id;
        caseInstance.Nature_Of_Damage__c = 'Additional Costs - Dry';
        caseInstance.Cause_of_Damage__c = 'Additional Cost';
        caseInstance.Claims_Hub__c = 'Global Claims';
        caseInstance.Claimant_Type__c = 'Direct Customer';
        update caseInstance;
    }
    
    public static Approval_Request__c  approvalAccept(Case caseInstance, Incident__c incidentClaimEvent) {
        Id RecordTypeIdApprovalRequest = StaticFactory.getRecordTypeIdByName('Approval_Request__c', 'Claim Approval'); 
        list<User> lstUsers = UserData_Test.createCustomerusers();
                
        caseInstance.Status = 'In Progress';
        CaseInstance.Claim_Event__c = incidentClaimEvent.Id;
        caseInstance.Sub_Type__c = 'Commercial Claim';
        caseInstance.Nature_Of_Damage__c = 'Additional Costs - Dry';
        caseInstance.Cause_of_Damage__c = 'Additional Cost';
        caseInstance.Claims_Hub__c = 'Global Claims';
        caseInstance.Claimant_Type__c = 'Direct Customer';        
        update caseInstance;
        
        Approval_Request__c approvalRequest = new Approval_Request__c();
        approvalRequest.recordTypeId = RecordTypeIdApprovalRequest;
        approvalRequest.Case__c = caseInstance.Id;
        approvalRequest.Approval_Status__c = 'New';
        approvalRequest.Bill_of_Lading_Number__c =  caseInstance.BoL_Number__c; 
        approvalRequest.Requested_Amount_Currency__c = 'INR';
        approvalRequest.Requested_Amount__c = 3000.00;
        approvalRequest.SFDC_Approver__c = lstUsers[0].id;
        insert approvalrequest;
        Approval_Request__c createdApprovalRequest = [SELECT id, Approval_Status__c FROM Approval_Request__c WHERE id=: approvalrequest.id];
        createdApprovalRequest.Approval_Status__c = 'Approved';
        createdApprovalRequest.Approver_s_Comments__c = 'approve for test ';
        createdApprovalRequest.Approved_Amount__c = 300;
        update createdApprovalRequest;
        
        return createdApprovalRequest;
    }
    
    public static Approval_Request__c  lnsApprovalAccept(Case caseInstance, Incident__c incidentClaimEvent,contact conInstance,Controlling_Entity__c entityIterator) {
        Id RecordTypeIdApprovalRequest = StaticFactory.getRecordTypeIdByName('Approval_Request__c', 'Claim Approval');
        list<User> lstUsers = UserData_Test.createCustomerusers();
            
        caseInstance.Status = 'Awaiting Customer Input';
        CaseInstance.Claim_Event__c = incidentClaimEvent.Id;
        caseInstance.Sub_Type__c = 'Cargo Liabilities';
        caseInstance.Nature_Of_Damage__c = 'Cargo Loss/Damage';
        caseInstance.Cause_of_Damage__c = 'Assault/Fight involving third party';
        caseInstance.Claim_Event__c = incidentClaimEvent.id;
        caseInstance.Claims_Hub__c = 'Global Claims';
        caseInstance.Origin_Country__c = conInstance.Country__c ;
        caseInstance.Destination_Country__c = conInstance.Country__c;
        caseInstance.Controlling_Entity__c = entityIterator.id;
        caseInstance.Claim_Reported_To_Insurer__c = 'No';
        caseInstance.Claimant_Type__c = 'Direct Customer';
        date mydate = date.parse('05/11/2012');
        caseInstance.Time_Bar__c=mydate;        
        caseInstance.ContactId = conInstance.Id;                
        update caseInstance;
        
        Approval_Request__c approvalRequest = new Approval_Request__c();
        approvalRequest.recordTypeId = RecordTypeIdApprovalRequest;
        approvalRequest.Case__c = caseInstance.Id;
        approvalRequest.Approval_Status__c = 'New';
        approvalRequest.Requested_Amount_Currency__c = 'INR';
        approvalRequest.Requested_Amount__c = 3000.00;
        approvalRequest.SFDC_Approver__c = lstUsers[0].id;
        insert approvalrequest;
        Approval_Request__c createdApprovalRequest = [SELECT id, Approval_Status__c FROM Approval_Request__c WHERE id=: approvalrequest.id];
        createdApprovalRequest.Approval_Status__c = 'Approved';
        createdApprovalRequest.Approver_s_Comments__c = 'approve for test ';
        createdApprovalRequest.Approved_Amount__c = 300;
        update createdApprovalRequest;
        
        return createdApprovalRequest;
    }

    public static Approval_Request__c  approvalReject(Case caseInstance, Incident__c incidentClaimEvent) {
        Id RecordTypeIdApprovalRequest = StaticFactory.getRecordTypeIdByName('Approval_Request__c', 'Claim Approval');
        list<User> lstUsers = UserData_Test.createCustomerusers();
        
        caseInstance.Status = 'In Progress';
        CaseInstance.Claim_Event__c = incidentClaimEvent.Id;
        caseInstance.Sub_Type__c = 'Commercial Claim';
        caseInstance.Nature_Of_Damage__c = 'Additional Costs - Dry';
        caseInstance.Cause_of_Damage__c = 'Additional Cost';
        caseInstance.Claim_Event__c = incidentClaimEvent.id;
        caseInstance.Claims_Hub__c = 'Global Claims';
        caseInstance.Claimant_Type__c = 'Direct Customer';     
        update caseInstance;
        
        Approval_Request__c approvalRequest = new Approval_Request__c();
        approvalRequest.recordTypeId = RecordTypeIdApprovalRequest;
        approvalRequest.Case__c = caseInstance.Id;
        approvalRequest.Approval_Status__c = 'New';
        approvalRequest.Bill_of_Lading_Number__c =  caseInstance.BoL_Number__c; 
        approvalRequest.Requested_Amount_Currency__c = 'INR';
        approvalRequest.Requested_Amount__c = 3000.00;
        approvalRequest.SFDC_Approver__c = lstUsers[0].id;
        insert approvalrequest;
        Approval_Request__c createdApprovalRequest = [SELECT id, Approval_Status__c FROM Approval_Request__c WHERE id=: approvalrequest.id];
        createdApprovalRequest.Approval_Status__c = 'Rejected (Approver)';
        createdApprovalRequest.Approver_s_Comments__c = 'Rejected for test ';
        createdApprovalRequest.Approved_Amount__c = 300;
        update createdApprovalRequest;
        
        return createdApprovalRequest;
    }
    
    public static List<Case> createClaimCaseRecordForBAuser(String BA , contact conInstance) {
        Id RecordTypeIdCase = StaticFactory.getRecordTypeIdByName('Case', 'Claim');   
    
        List<Case > lstCases = new list<Case>();
        if(BA =='testbaclaimlns@.com') {
              
            for(integer i=0; i<5; i++) {
                Case caseIterator = new Case();
                caseIterator.Description = 'CaseTestData Description_' + i;
                caseIterator.recordTypeId =RecordTypeIdCase;
                caseIterator.Type = 'Claim - L&S';
                caseIterator.Country__c = conInstance.Country__c;
                caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
                caseIterator.Case_Channel__c = 'Email';
                caseIterator.Origin = 'LNSGLOBALCLM';
                caseIterator.Case_Visibility__c = 'All Users';
                lstCases.add(caseIterator);
          }
        }
         system.debug('cases-'+lstCases);  
         return lstCases;
    }
      
    public static void convertExternalCaseToLnsClaim(Case caseInstance) {
        Id claimRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim');
        caseInstance.Liner_Brand__c = BrandUtilities.MAERSKLS;
        caseInstance.RecordTypeId = claimRTId;
        caseInstance.Type = 'Claim - L&S';
        caseInstance.Origin = 'LNSBDEXE';
        caseInstance.Origin_Country__c = conInstance.Country__c ;
        caseInstance.Destination_Country__c = conInstance.Country__c;        
        caseInstance.Product__c='Cold Chain Logistics';
        update caseInstance;        
    }   

    public static void createClaimRecoveryCases(Incident__c incidentClaimEvent) {
        populateCommonCaseFieldsClaims();        
        Id claimRecoveryRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim Recovery');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = claimRecoveryRTId;
            CaseIterator.claim_event__c = incidentClaimEvent.id;
            caseIterator.Type = 'Claim Recovery';
            caseIterator.Sub_Type__c = 'Claim Recovery';
            caseIterator.Time_Bar__c = System.today();
        }
        
        if(booCreate) {
            insert lstCases;
        }
    }
    
    public static void claimRecoveryClose(Case caseInstance) {
        caseInstance.Status = 'Recovery Failed';
        caseInstance.Rejection_Reason__c= 'Lack of Documents';
        caseInstance.Recovery_Type__c  = 'Insurance';
        update caseInstance;
    }
    
    public static void createExternalCases() {
        PopulateCommonCaseFields();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Product__c = 'Ocean';
        }
        
        if(booCreate) {
            insert lstCases;
        }
    }
    
    public static void convertExternalCaseToClaimOcean(Case CaseInstance) {
        Id claimRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim');
        caseInstance.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        caseInstance.RecordTypeId = claimRTId;
        caseInstance.Type = 'Claim - Ocean';
        caseInstance.Sub_Type__c = 'Commercial Claim';
        update caseInstance;
    }
    
    public static Sales_Call__c serviceCallCreation() {
       Contact  conInstance = TestDataFactoryHelper.createContactRecord();          
       Sales_Call__c  servicecall = new Sales_Call__c();
        
        servicecall.Name = 'test';
        servicecall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        servicecall.StartDateTime__c = Datetime.newInstance(2022, 2, 17);
        servicecall.EndDateTime__c = Datetime.newInstance(2022, 2, 22);
        servicecall.Contact__c = conInstance.id;
        servicecall.Service_Type__c = 'Onboarding';    
        servicecall.Type__c = 'Service (Face-to-Face)';
        insert servicecall;
        return servicecall;
    }
    
    public static List<LS_TM_Connective_Task__c> getConnectiveTasks() {
        return [SELECT Id, OwnerId, LS_TM_Task__c, LS_TM_Status__c, LS_TM_Due_Date__c, LS_TM_Visible_Date__c, LS_TM_External_Reference_Type__c, 
                LS_TM_ETD_Date__c, LS_TM_ATD_Date__c, LS_TM_ETA_Date__c, LS_TM_ATA_Date__c, LS_TM_POR_Country__c, LS_TM_Place_of_Delivery_Country__c, 
                LS_TM_Processing_Country__c
                FROM LS_TM_Connective_Task__c];
    }
    
    public static void createISRCaseMaerskLnS() {
        conInstance = createContactRecord();         
        lstCases = new list<Case>();
        Id ISRRTId = StaticFactory.getRecordTypeIdByName('Case', 'ISR');
        for(integer i=0; i<intNumberOfCases; i++) {
           Case caseIterator = new Case();
           caseIterator.RecordTypeId = ISRRTId;
           caseIterator.ContactId = conInstance.Id;
           caseIterator.AccountId =  conInstance.AccountId;
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLS;
           caseIterator.Resolver_Dept__c = 'MC Execution: Landside Transportation';
           caseIterator.Collaboration_Reason__c = 'Document Request';
           caseIterator.Description = 'test';
           caseIterator.Country__c = conInstance.Country__c;
           caseIterator.Direction__c = 'Export';
           caseIterator.Case_Visibility__c = 'Multi-Carrier';
           caseIterator.Requestor_Dept__c = 'Multi-Carrier';
            
           lstCases.add(caseIterator);
        }
        insert lstCases;
    }
    
    public static void createISRCaseML() {
        conInstance = CreateContactRecord();
        lstCases = new list<Case>();
        Id ISRRTId = StaticFactory.getRecordTypeIdByName('Case', 'ISR');
        for(integer i=0; i<intNumberOfCases; i++) {
           Case caseIterator = new Case();
           caseIterator.RecordTypeId = ISRRTId;
           caseIterator.ContactId = conInstance.Id;
           caseIterator.AccountId =  conInstance.AccountId;
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
           caseIterator.Resolver_Dept__c = 'Ocean: Customer Service';
           caseIterator.Collaboration_Reason__c = 'Cargo Readiness';
           caseIterator.Description = 'test';
           caseIterator.Country__c = conInstance.Country__c;
           caseIterator.Direction__c = 'Export';
           caseIterator.Case_Visibility__c = 'All Users';
            
           lstCases.add(caseIterator);
        }
        insert lstCases;
    }
    
    public static Maersk_Idea__c maerskIdeaCreation() {
        User CreatedUser = createUser();

        Maersk_Idea__c maerskidea = new Maersk_Idea__c();
        System.runAs(CreatedUser) {  
        maerskidea.Maersk_Idea_Topic__c = 'Test Record-1';
        maerskidea.Outcome_Type__c = 'User Experience Enhancement';
        maerskidea.Application__c ='Transport Event Change Notification' ;
        maerskidea.Maersk_Opportunity_Problem_Statement__c ='test' ;
        maerskidea.Maersk_Idea_Description__c ='test';
        maerskidea.What_does_it_mean_for_the_Customer__c = 'test';
        insert maerskidea;
        }
        return maerskidea;
    }
    
    public static String generateRandomString(Integer length) {
        return generateRandomString('abcdefghijklmnopqrstuvwxyz1234567890', length);
    }
    
    private static String generateRandomString(String characterSet, Integer length) {
        if(setPriorRandoms == null)
            setPriorRandoms = new Set<String>();
        if(length == null) length = 1+Math.round( Math.random() * 8 );
        
        String characters = characterSet;
        String returnString = '';
        
        while(returnString.length() < length) {
            Integer charpos = Math.round( Math.random() * (characters.length()-1) );
            returnString += characters.substring( charpos , charpos+1 );
        }

        if(setpriorRandoms.contains(returnString)) {
            return generateRandomString(characterSet, length);
        } else {

            setPriorRandoms.add(returnString);
            return returnString;
        }
    }
    
    public static String generateRandomEmail(String domain)
    {
        if(domain == null || domain == '')
        domain = 'salesforce.com';
        return generateRandomString(3) + System.now().getTime() + '@' + domain; // use timestamp to ensure usernames are unique
    }
    
    public static String generateRandomEmail() {
        return generateRandomEmail(null);
    }
      
    public static User generateUser() {
          String testString = generateRandomString(8); // can't be longer than eight so we can use for alias
          String testDomain ='maersk.com';// use a long domain to avoid potential duplicate usernames
          String testEmail = generateRandomEmail(testDomain);
          Geography__c cont =   BDAGeographyData_Test.countryUS;
        return new User(lastName = testString, userName = testEmail,  profileId = SYSADMIN_PROFILE_ID, alias = testString, email = testEmail, emailEncodingKey = 'ISO-8859-1', languageLocaleKey = 'en_US', localeSidKey = 'en_US',  timeZoneSidKey = 'America/Los_Angeles',country='United States',Liner_Brand__c=BrandUtilities.MAERSKLINE,Cluster__c='North America Area');
    }
    
    public static User createUser() {
        User testUser = generateUser();
        insert testUser;
        return testUser;
    }
    }