/*
* Author   : Ragu
* Purpose  : Utility test class for creating Case related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-002633   06-May-2016  Ragu@UST                Created.
* 2.0      RQ-004401   29-Nov-2016  Nisha@UST               Updated createClaimCases() to include bolNumber, P&I cover and Court case details.
* 3.0      RQ-004436   12-Dec-2016  Nirmal@UST              Updated CreateClaimRecoveryCases() to include claimEvent__c field
* 4.0      RQ-005345   18-May-2016  Nirmal@UST              Created createISRCasesII to cover CaseFieldPopulator
* 5.0      RQ-008231   18-Apr-2018  Ranjini@Ust             Created createExternalCasesAndSurveys()
* 6.0      Rq-008811   10-Aug-2018  Meenakshi@UST           Created CreateDisputecases()
* 7.0      SC-394      25-06-2020   ramadevi@ust            SCM Case creation method
* 8.0      SC-390      10-06-2020   Sreya@Maersk            Created createPortalCases() method
* 9.0      SC-1160     14-10-2020   Sreya@Maers             Created createLNSCases method for the CSAT for LNS BA..
 * 10.0     SPI-100     07-06-2022   Ronnie@SF               Removing brand hardcodings
 * 11.0     SC-7347           27-03-2023   Vivek@maersk.com        Changes for CLaim/Claim Recovery records fields from Sub_Type->Type , RFC->Sub_Type to resolve RFC limits
*/

@isTest
public class CaseData_Test {
    
    public static boolean bCreate = true;
    public static integer iNumberOfCases = 5;
    public static integer iDisputeNumber = 4;//Added the variable to avoid duplicate records upon DML.
    public static list<Case> lstCases = new list<Case>();
    public static list<Survey__c> lstSurveys = new list<Survey__c>();
    
    // Use this conInstance if you have already created a Contact and you wanted to use it for Cases.
    public static Contact conInstance = null;
    
    @isTest
    public static void createExternalCases() {
        populateCommonCaseFields();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
  //Without country and Account 
   @isTest
   public static void createExternalCasesII() {
        populateCommonCaseFieldsII();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    
    @isTest
    public static void createEmailtoCase() {
        populateCommonCaseFields();
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
            caseIterator.SuppliedEmail = 'Testone@gmail.com';
            caseIterator.Type = 'Non-Case';
            caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    //SC - 390 : Create portal cases
    @isTest
    public static void createPortalCases() {
        populateCommonCaseFields();
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
           caseIterator.Case_Channel__c = 'Portal';
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    
    @isTest
    public static void createExternalUSFCases() {
        populateCommonCaseFields();
        
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.MLL__c = true;
            caseIterator.Cargo_Classification__c = 'US Military (USM)';
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
            
    @isTest
    public static void createClaimCases() {
        populateCommonCaseFieldsClaims();
        Integer bolNumberIncrement = 0;
        Id claimRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = claimRTId;
            caseIterator.Type = 'Claim - Ocean';
            
            // RQ-004401
            caseIterator.BoL_Number__c = '12345678'+bolNumberIncrement; 
            caseIterator.P_I_Cover__c = 'Yes';
            caseIterator.Court_Case__c = 'Yes';
            caseIterator.Chance_Winning_Court_Case__c = 67;
            caseIterator.Location_Indicator_Jurisdiction__c = caseIterator.Country__c;
            caseIterator.Court_Case_Status__c = 'On Appeal';
            caseIterator.Claim_Filed_Date__c = System.today() - 1;
            bolNumberIncrement++;
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    
    @isTest
    public static void createISRCases() {
        populateCommonCaseFields();
        Id isrrtid = StaticFactory.getRecordTypeIdByName('Case', 'ISR');
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        
        list<Case> parentlistCase = new list<Case>();
        for(integer i=0; i<2; i++) {
            Case parentcase = new Case();
            parentcase.Subject = 'Parent Case Test Booking' + i;
            parentcase.Description = 'Parent Case Test Booking Description_' +i ;
            parentcase.RecordTypeId = extCaseRTId;
            parentcase.Thread_topic__c = 'Test'; // RQ-004464 
            parentcase.ContactId = conInstance.Id;
            parentcase.AccountId = conInstance.AccountId;
            parentcase.Status = 'New';
            parentcase.Type = 'Booking';
            parentcase.Sub_Type__c = 'New Booking Request';
            parentcase.Reason_For_Case__c = 'Booking Request';
            parentcase.Country__c = conInstance.Country__c;
            parentcase.Cargo_Classification__c ='US Military (USM)';
            parentcase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            parentcase.Direction__c = 'Export';
            parentcase.Case_Channel__c = 'Telephone';
            parentcase.Origin = 'MSLUSEXP';
            parentcase.Case_Visibility__c = 'All Users';
            parentlistCase.add(parentcase);
        }
        TriggerExecutionController.skipAllTriggers(true);
            insert parentlistCase; 

   
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = isrrtid;
            caseIterator.Type = 'Non-Case';
            caseIterator.Requestor_Dept__c = 'Single Carrier';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales';
            caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
            caseIterator.ParentId = parentlistCase[0].Id;
        }
        
        if(bCreate) {
           Test.startTest();
            insert lstCases;
                       TriggerExecutionController.skipAllTriggers(false);
           Test.stopTest();
        }
    }
    @isTest
    public static void createISRCasesII() {
                   TriggerExecutionController.skipAllTriggers(true);
        populateCommonCaseFields();
        Id isrrtid = StaticFactory.getRecordTypeIdByName('Case', 'ISR');
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        
        list<Case> parentlistCase = new list<Case>();
        for(integer i=0; i<2; i++) {
            Case parentcase = new Case();
            parentcase.Subject = 'Test ISR Parent Case' +i;
            parentcase.Description = 'Test ISR Parent Case' +i;
            parentcase.RecordTypeId = extCaseRTId;
            parentcase.Thread_topic__c = 'Test'; // RQ-004464 
            parentcase.ContactId = conInstance.Id;
            parentcase.AccountId = conInstance.AccountId;
            parentcase.Status = 'New';
            parentcase.Type = 'Booking';
            parentcase.Sub_Type__c = 'New Booking Request';
            parentcase.Reason_For_Case__c = 'Booking Request';
            parentcase.Country__c = conInstance.Country__c;
            parentcase.Cargo_Classification__c ='US Military (USM)';
            parentcase.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            parentcase.Direction__c = 'Export';
            parentcase.Case_Channel__c = 'Telephone';
            parentcase.Origin = 'MSLUSEXP';
            parentcase.Case_Visibility__c = 'All Users';
            parentlistCase.add(parentcase);
        }
           
            insert parentlistCase; 
           

        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = isrrtid;
            caseIterator.Type = 'Non-Case';
            caseIterator.Requestor_Dept__c = 'Single Carrier';
            caseIterator.Product__c = 'Ocean';
            caseIterator.Liner_Brand__c = 'Maersk Line';
            caseIterator.Resolver_Dept__c = 'Ocean: Sales';
            caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
            //caseIterator.Reason_for_case__c= 'Damage/Loss of Cargo';
            caseIterator.On_Behalf_Account__c = conInstance.AccountId;
            caseIterator.ParentId = parentlistCase[0].Id;
        }
        
        if(bCreate) {
           Test.startTest();
            insert lstCases;
                       TriggerExecutionController.skipAllTriggers(false);
           Test.stopTest();
        }
    }
    
    @isTest
    public static void createClaimRecoveryCases() {
        populateCommonCaseFieldsClaims();
        IncidentData_Test.createClaimEventIncidents();
        List<Incident__c> testIncident = new List<incident__c>();
        testincident.addall(IncidentData_Test.lstIncidents);
        Id claimRecoveryRTId = StaticFactory.getRecordTypeIdByName('Case', 'Claim Recovery');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = claimRecoveryRTId;
            CaseIterator.claim_event__c = testincident[0].id;
            caseIterator.Type = 'Claim Recovery';
            caseIterator.Sub_Type__c = 'Claim Recovery';
            caseIterator.Time_Bar__c = System.today();
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    
    // This method is to 'Closed - Resolved' the cases which are in current test context
    @isTest
    public static void closeResolveCase() {
        for(Case caseIterator : lstCases) {
            caseIterator.Status = 'Closed - Resolved';
      	  caseIterator.OwnerId = UserInfo.getUserId();
          caseIterator.Type =  'Booking';
          caseIterator.Sub_Type__c = 'New Booking Request';
          caseIterator.Reason_For_Case__c = 'Booking Request';
        }
    }
  
  // This method is to 'Closed - Not a case' the cases which are in current test context
  @isTest
  public static void closeNotACase() {
        for(Case caseIterator : lstCases) {
            caseIterator.Status = 'Closed - Not a case';
      caseIterator.OwnerId = UserInfo.getUserId();
          caseIterator.Type =  'Non-Case';
          caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
        }
    }
    
    @isTest
    private static void populateCommonCaseFields() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        
        lstCases = new list<Case>();
        for(integer i=0; i<iNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Subject = 'CaseTestData Subject_' + i;
            caseIterator.Description = 'CaseTestData Description_' + i;
            caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
            caseIterator.ContactId = conInstance.Id;
            caseIterator.AccountId = conInstance.AccountId;
            caseIterator.Status = 'New';
            caseIterator.Type = 'Booking';
            caseIterator.Sub_Type__c = 'New Booking Request';
            caseIterator.Country__c = conInstance.Country__c;
            caseIterator.Cargo_Classification__c ='US Military (USM)';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Direction__c = 'Export';
            caseIterator.Case_Channel__c = 'Telephone';
            caseIterator.Origin = 'MSLUSEXP';
            caseIterator.Case_Visibility__c = 'All Users';
            
            lstCases.add(caseIterator);
        }
    }
  //For the use of case without contact and account
  @isTest
  private static void populateCommonCaseFieldsII() {
        
        
        lstCases = new list<Case>();
        for(integer i=0; i<iNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Subject = 'CaseTestData Subject_' + i;
            caseIterator.Description = 'CaseTestData Description_' + i;
            caseIterator.Thread_topic__c = 'Test'; // RQ-004464            
            caseIterator.Status = 'Triaged';
            caseIterator.Type = 'Prior To Booking';
            caseIterator.Sub_Type__c = 'Cargo Restrictions/Support Enquiry';
            caseIterator.Country__c = BDAGeographyData_Test.countryUK.Id;
            caseIterator.Cargo_Classification__c ='US Military (USM)';
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Direction__c = 'Export';
            caseIterator.Case_Channel__c = 'Chat';
            caseIterator.SuppliedEmail = Null;
            caseIterator.Origin = 'MSLUSEXP';
            caseIterator.Case_Visibility__c = 'All Users';
            lstCases.add(caseIterator);
        }
    }
    
    //  #RQ-008231
    @isTest
    public static void createExternalCasesAndSurveys() {
        populateCommonCaseFields();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        Integer index = 0;
        for(Case c: lstCases) {
            c.RecordTypeId = extCaseRTId;
            c.Status ='Closed - Resolved';
            c.Resolution_Summary__c = 'Resolved'; 
            c.Send_Case_Closure__c ='Yes';
            c.type='Booking';
            c.Sub_Type__c='New Booking Request'; 
            c.Reason_For_Case__c = 'Booking Request';
            c.Liner_Brand__c  = BrandUtilities.MAERSKLINE;
            c.Country__c = BDAGeographyData_Test.countryRU.Id;
            c.Security_Code__c = '1235' + index++;
        }
        
        if(bCreate) {
            insert lstCases;
            for(Case c: lstCases) {
                lstSurveys.add(new Survey__c(Case__c = c.Id, Ease_to_Resolve_Issue__c = 3, Case_Security_Code__c = c.Security_Code__c, Liner_Brand__c = c.Liner_Brand__c));
            }
            try
            {
             insert lstSurveys;
            } catch(Exception e)
            {
              System.debug(e);
            }
        }
    }
    
    @isTest
    private static void populateCommonCaseFieldsIII() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 2;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[1];
        }
        
        lstCases = new list<Case>();
        for(integer i=0; i<iNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Subject = 'CaseTestData Subject_' + i;
            caseIterator.Description = 'CaseTestData Description_' + i;
            caseIterator.Thread_topic__c = 'Test'; // RQ-004464 
            caseIterator.ContactId = conInstance.Id;
            caseIterator.AccountId = conInstance.AccountId;
            caseIterator.Status = 'New';            
            caseIterator.Country__c = conInstance.Country__c;            
            caseIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            caseIterator.Direction__c = 'Export';
            caseIterator.Case_Channel__c = 'Telephone';
            //caseIterator.Origin = 'MSLUSEXP';          
            caseIterator.Department__c = 'Customer Service';            
            caseIterator.Nature_of_Dispute_case__c = 'Invoice Amendment/Clarification';
            caseIterator.Invoice_Amendment_Clarification__c = 'Missing or wrong reference in the invoice';
            caseIterator.Service_Contract_Number__c = '123456ABC';
            caseIterator.Expected_Exchange_Rate__c = '2345';
            caseIterator.Invoice_Type__c = 'Freight';
            caseIterator.Type = 'Charges, Invoice & Payment';
            caseIterator.Sub_Type__c ='Dispute';
            caseIterator.Case_Visibility__c = 'All Users';
            caseIterator.Reason_For_Case__c = 'Case Reason Updated in OHP';
            
            lstCases.add(caseIterator);
        }
    }

    @isTest
    private static void populateCommonCaseFieldsClaims() {
        if(conInstance == null) {
            ContactData_Test.iNumberOfContacts = 1;
            ContactData_Test.createCustomerContacts();
            conInstance = ContactData_Test.lstContacts[0];
        }
        
        lstCases = new list<Case>();
        for(integer i=0; i<iNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Subject = 'CaseTestData Claim Subject_' + i;
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
            caseIterator.Case_Channel__c = 'Telephone';
            caseIterator.Origin = 'MSLUSEXP';
            caseIterator.Case_Visibility__c = 'All Users';
            
            lstCases.add(caseIterator);
        }
    }
    
        //#RQ-008811 New Dispute Record type
        @isTest
        public static void createDisputecases() {
        populateCommonCaseFieldsIII();
        Id disputeCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'Dispute');
        Integer index = 0;
        for(Case c: lstCases) {
            c.RecordTypeId = disputeCaseRTId; 
            c.Disputed_Invoice_Number__c = '1234'+iDisputeNumber+'6789'+index++;
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
   //SC-394
   @isTest
   public static void createSCMCases() {
        populateCommonCaseFields();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
            caseIterator.SuppliedEmail = 'Testone@gmail.com';
            caseIterator.Type = 'Non-Case';
            caseIterator.Sub_Type__c = 'Spam';
            caseIterator.Origin ='SCMGLOBALAMT';
            caseIterator.product__c= 'SCM';
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
    @isTest
    public static void createLNSCases() {
        populateCommonCaseFields();
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
            caseIterator.SuppliedEmail = 'Testone@gmail.com';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.Type = 'Non-Case';
            caseIterator.Sub_Type__c = 'Spam/Case Created in Error';
        }
        
        if(bCreate) {
            insert lstCases;
        }
    }
//To improve code coverage for CaseEntitlements
@isTest
public static void createEmailtoCaseEntitlements() {
        populateCommonCaseFields();
            Id slaProcessId = Id.valueOf(Label.TestClean_SLAProcessID);
            Date dtStart = System.today();
            Date dtEnd = System.today() + 30;
        List<Entitlement> entList = [SELECT id, 
                           assetId,Name,Liner_Brand_Logic__c,AccountId,Status,StartDate,EndDate 
                           FROM Entitlement WHERE Liner_Brand_Logic__c = 'Default'];
         Entitlement defaultEntitlement=entList[0].clone(false, true, false, false);
         defaultEntitlement.AccountId = entList[0].AccountId;
         defaultEntitlement.Name = Label.DefaultEntitlementName;
         defaultEntitlement.StartDate = dtStart;
         defaultEntitlement.EndDate = dtEnd;
         insert defaultEntitlement;
        Id extCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'External Case');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = extCaseRTId;
            caseIterator.Subject = 'Test Case_CaseTestData.generateTestRecord';
            caseIterator.SuppliedEmail = 'Testone@gmail.com';
            caseIterator.Case_Channel__c = 'E-mail';
            caseIterator.Type =null;
            caseIterator.Sub_Type__c = null;
        }
        
        if(bCreate) {
            insert lstCases;
            lstCases[0].type = 'Booking';
            lstCases[0].Sub_Type__c = 'New Booking Request';
            lstCases[0].Reason_for_case__c ='Booking Request';
            lstCases[0].status = 'Closed - Resolved';
            lstCases[0].Resolution_Summary__c = 'Test';
            update lstCases[0];
        }
    }
}