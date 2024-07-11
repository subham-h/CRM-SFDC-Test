/**
 * Test class for RC_ContentSearchCustomizedController - Controller provides a list of relevant content for the record based on keywords (default: RC_Keywords__c)
 * Original code provided by the salesforce labs app Relevant Content <https://appexchange.salesforce.com/listingDetail?listingId=a0N3000000B5XerEAF>
 * 
 * 
 * Version History
 * ===============
 * 1. revathy.sudhindran@ust-global.com 			29/6/2015  	#RQ-001478    Suggested sales collateral to display on Salesforce Objects
 * 2. Rathish.Rajendran@ust-global.com  			26/04/2017 	#RQ-005193    Updated test class to accomodate validation rule "Validate_Internal_Contacts_Association".
 * 3. ramadevi.palaniswamy@ust-global.com 			11/16/1017 	#RQ-007289    Update the Value Proposition and Attractiveness values of Account Object Fields
 * 4. Madhubharathi.Gopalakrishnan@ust-global.com 	30/01/2018 	#RQ-007205    Remove the Eloqua managed package now moved to SFMC.
 * 5. meghana.gupta@ust-global.com		  		 	10/05/2019  #RQ-009988    Replace Value_Prosposition1__c by Value_Prosposition__c
 * 6. manjunath.c.holekade@maersk.com	  		 	06/06/2019  #RQ-010819	  Removal of references of deprecated fields
 * 7. meghana.gupta					     		 	10/09/2020  SFSE-262      Changes for new Source Brand field on leads
 * 8. Ronnie@SF                                     27/06/2022  SPI-100       Removed brand hardcoding
 */

@isTest
private class RC_ContentSearchController_Test {
    // Test User who creates & reads records through the tests
    // This is to ensure that records created can also be accessed even with private OWner
    static Contact c;
    static Account acctObj;
    static Opportunity testOpportunity;
    static Lead testlead;
    
    public static account createAccount() {
        // Account acctObj = new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createClientAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acctObj = AccountData_Test.lstAccounts[0];
        acctObj.MSL_Account_Owner__c = UserInfo.getUserId();          
        acctObj.Attractiveness__c = 'Key Client';
        acctObj.value_proposition__c = 'Ease';
        update acctObj;
        
        return acctObj;
    } 
    
    static void createContact(){
        c = new Contact();
        c.AccountId = acctObj.Id;
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'Qwerty@xyz.com';
        c.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert c;
    } 
    
    static void createOpportunity(){
        testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test';
        testOpportunity.AccountId = acctObj.Id;
        testOpportunity.Primary_Contact__c = c.Id;
        testOpportunity.Type = 'Acquisition';
        testOpportunity.Cargo_Type__c = 'Dry';
        testOpportunity.CloseDate = date.today()+30;
        testOpportunity.StageName = Label.LeadLabel;
        testOpportunity.Expected_Handling_Rounds__c = 2;
        //oppObj1.
        testOpportunity.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert testOpportunity;
    } 
    
    static void createLead(){
        
        Geography__c geoObj= new Geography__c();
        geoObj.Name='India';
        geoObj.Type_Of_Location__c='Country';
        insert geoObj;
        
        testlead = LeadDataGeneration.createLead('Test', 'UserXYZ', 'TestCompany2',geoObj.Id, BrandUtilities.MAERSK, 'testclassrunXYZ@test.com.play', null, null, 'LinkedIn');
        insert testlead;
    }
    
    /*
CreateContent - utility method to create test Content and return them in a List
Inputs:
basename = beginnging of ContentVersion.Title string, to be concatenated with an incrementing integer
objectCount = number of test records to be created
contentType:
C = Try to create Content, if possible
H = Try to create Files
Output:
List<ContentVersion> = list containing the records created
*/
    public static List<ContentVersion> CreateContent(String basename, Integer objectCount, String contentType) {
        
        // List to hold the Task sObjects
        List<ContentVersion> newContent = new List<ContentVersion>();
        
        // Create a blob to represent the file
        Blob testBlob = Blob.valueof('TestFileBlob');
        
        // Set the appropriate Content type (Content or File)
        String contentOrigin = 'C';
        Boolean contentAvailableContentTest = RC_ContentSearchCustomizedController.contentAvailableCheck();
        
        if (contentType == 'C' && contentAvailableContentTest == true) {
            // Content is requested and available, set origin to 'C' (Content)
            contentOrigin = 'C';
        }
        else {
            // Content is not available or not requested, set origin to 'H' (File)
            contentOrigin = 'H';
        }
        
        // Fill the list with test records with names initialized based on basename
        for(Integer i=0; i<objectCount; i++) {
            // Create the Content/File
            newContent.add(new ContentVersion(
                Title = basename + String.valueof(i),
                Origin = contentOrigin,
                PathOnClient = basename + String.valueof(i),
                VersionData = testBlob)
                          );
        }
        
        // Return the list of records created
        return newContent;
    }
    
    /*
RC_ContentSearchCustomizedControllerUtil - utility method to perform the bulk of the unit test logic when given a test record
Inputs:
sObject = record on which to run the tests
String = sObject type of the test record
fcFlag = To set which button triggered (Find Content/ Value Proposition)
Output:
none
*/
    public static void RC_ContentSearchUtil(sObject testRecord,String sObjectType,String PageName,Boolean fcFlag) {
        
        // Determine if content is available for the org - this will determine if Content or Files is used for tests
        Boolean contentAvailableTest = RC_ContentSearchCustomizedController.contentAvailableCheck();
        
        // Initialize first batch test data by adding test data for required fields and inserting
        //  This content contains the word 'Test' and should match the RC_Keywords__c which will include the keyword 'Test'
        final Integer NUM_TEST_CONTENT_1 = 20;
        List<ContentVersion> testContentPos = CreateContent('Test Content ',NUM_TEST_CONTENT_1,'C');
        
        for(ContentVersion thisContentPos: testContentPos) {
            thisContentPos.Description = 'Test';
        }
        insert testContentPos;
        
        // Initialize second batch test data by adding test data for required fields and inserting
        //  This content does not contain any words relevant to RC_Keywords__c which will include the keyword 'Test'
        final Integer NUM_TEST_CONTENT_2 = 10;
        List<ContentVersion> testContentNeg = CreateContent('Irrelevant',NUM_TEST_CONTENT_2,'C');
        for(ContentVersion thisContentNeg: testContentNeg) {
            thisContentNeg.Description = 'Irrelevant';
        }
        insert testContentNeg;
        
        system.debug('#######passed record###'+testRecord);
        
        // Set Visualforce page
        PageReference page = new PageReference(PageName+'?id='+testRecord.Id+'&fcFlag='+fcFlag);
        Test.setCurrentPage(page);
        
        // Set the controller
        RC_ContentSearchCustomizedController controller = new RC_ContentSearchCustomizedController();
        
        /*
Constructor test
Test the member variables and query resulting from the initialization of the search using RC_Keywords__c
*/
        // Since SOSL queries return an empty set, force the addition of the first batch of test data
        //  to the SOSL results
        Map<Id, ContentVersion> searchById = new Map<Id, Contentversion>([SELECT Id FROM ContentVersion WHERE Description='Test']);
        List<Id> searchResults = new List<id>(searchById.keySet());
        Test.setFixedSearchResults(searchResults);
        
        // Ensure the sObject type is detected correctly
        System.AssertEquals(sObjectType,controller.thisObjectType);             
        
        // Test that NUM_TEST_CONTENT_1 of ContentVersion were added to recordContentAll and totalResults
        // System.assert(controller.recordSearchString.contains('Test'));
        
        /*
Test the cleanFileType and getIconFilename methods
Send in known and unknown values and test results
*/
        // Test that cleanFileType and getIconFilename handled a known value correctly
        String fileTypeTest = 'EXCEL_X';
        String fileNameTest = 'test.xlsx';
        String fileTypeTestOutput = RC_ContentSearchCustomizedController.cleanFileType(fileTypeTest,fileNameTest);
        System.assertEquals('xlsx',fileTypeTestOutput);
        String filenameTestOutput = RC_ContentSearchCustomizedController.getIconFilename(fileTypeTestOutput);
        System.assertEquals('excel.svg',filenameTestOutput);
        
        // Test that cleanFileType and getIconFilename handled an unknown value with no file extension correctly
        fileTypeTest = 'UNKNOWN_FILE_TYPE_STRING_TEST';
        fileNameTest = 'unknownfile';
        fileTypeTestOutput = RC_ContentSearchCustomizedController.cleanFileType(fileTypeTest,fileNameTest);
        System.assertEquals('unknown_file_type_string_test',fileTypeTestOutput);
        filenameTestOutput = RC_ContentSearchCustomizedController.getIconFilename(fileTypeTestOutput);
        System.assertEquals('unknown.svg',filenameTestOutput);
        
        // Test that cleanFileType and getIconFilename handled an unknown value with a file extension correctly
        fileTypeTest = 'UNKNOWN_FILE_TYPE_STRING_TEST';
        fileNameTest = 'unknownfile.wmv';
        fileTypeTestOutput = RC_ContentSearchCustomizedController.cleanFileType(fileTypeTest,fileNameTest);
        System.assertEquals('wmv',fileTypeTestOutput);
        filenameTestOutput = RC_ContentSearchCustomizedController.getIconFilename(fileTypeTestOutput);
        System.assertEquals('video.svg',filenameTestOutput);
        
        /*
Test the updateSearch method - test for Irrelevant
Search for 'Irrelevant' and NUM_TEST_CONTENT_2 should be found
*/
        // Since SOSL queries return an empty set, force the addition of the second batch of test data
        //  to the SOSL results
        searchById = new Map<Id, Contentversion>([SELECT Id FROM ContentVersion WHERE Description='Irrelevant']);
        searchResults = new List<id>(searchById.keySet());
        Test.setFixedSearchResults(searchResults);
        controller.recordSearchString = 'Irrelevant';
        controller.updateSearch();
        System.assertEquals(NUM_TEST_CONTENT_2,controller.recordContentAll.size()); 
        System.assertEquals(NUM_TEST_CONTENT_2,controller.totalResults);
        
        controller.recordContentAll[0].selected=true;
        PageReference postResult = controller.postFilesToFeed();
        //System.assertEquals(true,postResult!=null);
        
        postResult= controller.backToRecord();
    }
    
    // Test to ensure constructor fails gracefully if not given a record (e.g. during new record creation)
    static testMethod void RC_ContentSearchCustomizedControllerTestMethod_Negative() {
        // Set Visualforce page with no recordID
        PageReference page = new PageReference('RC_RelevantContentSalesCall');
        Test.setCurrentPage(page); 
        // Set the controller
        Test.StartTest();
        RC_ContentSearchCustomizedController controller = new RC_ContentSearchCustomizedController();
        Test.stopTest();
        
        // Test that controller.showForm is set to false
        System.assertEquals(false,controller.showForm);
        
        // Test that controller.thisRecord is not initalized
        System.assertEquals(null,controller.thisRecord);
    }
    
    // Test the myTaskList page and controller using an Opportunity record
    static testMethod void RC_ContentSearchCustomizedControllerTestMethod_Opportunity() {
        
        // Create a test opportunity which will contain the RC_Keywords__c formula field
        String testSObjectType = 'Opportunity';
        // Call the utility function to run the tests on the Opportunity
        createAccount();
        createContact();
        Test.startTest();
        createOpportunity();
        RC_ContentSearchUtil(testOpportunity,testSObjectType,'RC_RelevantContentSalesCall',true);
        Test.stopTest();
    }
    
    // Test the myTaskList page and controller using a Lead record
    static testMethod void RC_ContentSearchCustomizedControllerTestMethod_Lead() {
        
        Test.StartTest();
        createLead();
        // Specify the test record sObject type
        String testSObjectType = 'Lead';
        // Call the utility function to run the tests on the Opportunity
        RC_ContentSearchUtil(testlead,testSObjectType,'RC_RelevantContentSalesCall',true);
        test.stopTest();
    }
    
    static testMethod void RC_ContentSearchCustomizedControllerTestMethod_Account() {
        
        // Create a test Account which will contain the RC_Keywords__c formula field
        String testSObjectType = 'Account';
        
        Test.startTest();
        createAccount();
        createContact();
        
        RC_ContentSearchUtil(acctObj,testSObjectType,'RC_RelevantContentSalesCall',false);
        Test.stopTest();
    }
}