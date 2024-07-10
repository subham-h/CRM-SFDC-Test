/**
 * Purpose  : Helper class for generating Test data for Opportunities
 * 
 * Revision   Ref Number    Date          Owner                   				Description
 * --------   ----------    -----------   -------------------     				-----------
 * 1.0        #RQ-003238    16-Jun-2016   Anisa Bhatnagar      					Move all Opportunity test data generation to Helper Class
 * 2.0	 	  #RQ-010819    06-Jun-2019   manjunath.c.holekade@maersk.com	  	Removal of references of deprecated fields 
 * 3.0        SFSE-4548     15-Sep-2020   manjunath.c.holekade@maersk.com       Test class fix
 * 4.0        SPI-100       08-Jun-2022   Ronnie@SF                             Removed brand hardcoding
 */

 @isTest
 public class OpportunityData_Test {
     
     public static boolean bCreate = true;
     public static integer iNumberOfOpportunities = 5;
     public static list<Opportunity> lstOpportunities;
     /**
     * Constructor
     **/
     public OpportunityData_Test(){        
     }
     
     /**
     * To create Test Opportunities
     **/
     public static testMethod void createMaersklineOpportunities() {
         populateCommonOpportunityFields();
         for(Opportunity oppIterator : lstOpportunities) {
             oppIterator.Name += '_' + BrandUtilities.MAERSKLINE.deleteWhitespace();
             oppIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
         }
         if(bCreate) {
             insert lstOpportunities;
         }
     }
     
     public static testMethod void populateCommonOpportunityFields() {
         lstOpportunities = new list<Opportunity>();
         // Skip Opportunity Trigger
         TriggerExecutionController.skipOpportunityTrigger(true);
         // Creating Test Opportunities requires a Test Account.
         Account testAccount = AccountDataHelper_Test.createClientAccount();
         
         for(integer i=0; i<iNumberOfOpportunities; i++) {
             Opportunity oppIterator = new Opportunity(
                 Name = 'OpportunityTestData_' + i,
                 AccountId = testAccount.Id, 
                 CloseDate = system.today()+5,
                 Controlled__c = 'Controlled',
                 Type = 'Transactional',
                 Cargo_Type__c = 'Dry',
                 First_Shipment_Date__c = date.today() + 10,
                 Last_Shipment_Date__c = date.today() + 30,
                 StageName = 'Identifying',
                 Reason_For_Close__c='',
                 Opportunity_contains_Dangerous_Goods__c = 'No',
                 Expected_Handling_Rounds__c = 2
                 /*OwnerID = [select Id from User where name = 'IBM Support Team' limit 1].Id*/);               
             lstOpportunities.add(oppIterator);
         }
     }
      
     public static testMethod void createMaersklineOpportunitiesWithPastCloseDate() {
        populateCommonOpportunityFields_CD();
        for(Opportunity oppIterator : lstOpportunities) {
            oppIterator.Name += '_' + BrandUtilities.MAERSKLINE.deleteWhitespace();
            oppIterator.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        }
        if(bCreate) {
            Validation_Rules_Bypass__c VRBypass = Validation_Rules_Bypass__c.getInstance(UserInfo.getUserId());
            //Boolean VRBypassIsActive = VRBypass.Active__c;
           	VRBypass.Active__c= true;
            upsert VRBypass;
         insert lstOpportunities;
        //database.insert(lstOpportunities, dmlOpts);
        }
    }
    
    public static testMethod void populateCommonOpportunityFields_CD() {
        lstOpportunities = new list<Opportunity>();
        // Skip Opportunity Trigger
        TriggerExecutionController.skipOpportunityTrigger(true);
        // Creating Test Opportunities requires a Test Account.
        Account testAccount = AccountDataHelper_Test.createClientAccount();
        
        for(integer i=0; i<iNumberOfOpportunities; i++) {
            Opportunity oppIterator = new Opportunity(
                Name = 'OpportunityTestData_' + i,
                AccountId = testAccount.Id, 
                CloseDate = System.today()-95,
                Controlled__c = 'Controlled',
                Type = 'Transactional',
                Cargo_Type__c = 'Dry',
                First_Shipment_Date__c = date.today() + 10,
                Last_Shipment_Date__c = date.today() + 30,
                StageName = 'Identifying',
                Reason_For_Close__c='',
                Opportunity_contains_Dangerous_Goods__c = 'No',
                Expected_Handling_Rounds__c = 2
                /*OwnerID = [select Id from User where name = 'IBM Support Team' limit 1].Id*/);               
            lstOpportunities.add(oppIterator);
        }
    }
 }