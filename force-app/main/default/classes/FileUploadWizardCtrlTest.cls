@isTest
public class FileUploadWizardCtrlTest{
    
    @isTest static void getJwtTokenTest() {        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        FileUploadWizardCtrl.getJwtToken();
    }
       @TestSetup 
       static void dataSetup() {
        
        Geography__c testGeo =  new Geography__c();
        testGeo.Active__c = true;
        testGeo.Type_Of_Location__c = 'Country';
        testGeo.GEO_ID__c = '10Z2W9ZTH2RUM';
        testGeo.Name = 'INDIA';
        insert testGeo;   
             
        Account testAcc = new Account();
        testAcc.RecordTypeId= '012D0000000kJKx';
        testAcc.name = 'TESTACC';
        testAcc.Country__c = testGeo.Id;
        testAcc.BillingCity = 'MUMBAI';
        insert testAcc; 
        
        
        Opportunity opp = new Opportunity(
        Name = 'OpportunityTestData',
        AccountId = testAcc.id, 
        CloseDate = system.today(),
        Controlled__c = 'Controlled',
        Type = 'Acquisition',
        Cargo_Type__c = 'Dry',
        First_Shipment_Date__c = date.today() + 10,
        Last_Shipment_Date__c = date.today() + 30,
        StageName = 'Identifying',
        Liner_Brand__c = BrandUtilities.MAERSKLINE,
        Opportunity_contains_Dangerous_Goods__c = 'No',
        Expected_Handling_Rounds__c=2);
        insert opp;
        
        String oppId=opp.id;
        String oppFileRecord='[{"sobjectType":"Opportunities_File__c","Name":"RFQ Round 2.txt","Opportunity__c":"' + opp.id + '","File_Category__c":"RFQ"}]';
        String quoteFileRecord='[{"sobjectType":"Quote__c","Name":"RFQ Round 2.txt","Source__c":"Collaboration Portal","Go_To_CoPo__c":"GoToCopo","Opportunity__c":"' + opp.id + '","Status":"Negotiation Initiated"}]';
         
        FileUploadWizardCtrl.createOppfiles(oppFileRecord,quoteFileRecord);         
        Opportunity_File__c oppFile = [Select Id,Name from Opportunity_File__c where Opportunity__c =:opp.id];
        FileUploadWizardCtrl.getoppfiledetails(oppFile.id);
        FileUploadWizardCtrl.editOppfiles(oppFile.id);
         
        FileUploadWizardCtrl.createQuote(oppFile.Id,quoteFileRecord,oppFile.id,true,'RFQ');
        GetOppFilesContentLink.contentDocWrapper cd = new GetOppFilesContentLink.contentDocWrapper();
        cd.fileName = 'Test File.txt';
        cd.fileContent = 'Test';
        
        system.debug('==cd=='+cd);
        
        GetOppFilesContentLink.createDocument(oppId,cd);  
        FileUploadWizardCtrl.errorResponse('error');
        FileUploadWizardCtrl.allvalidationchk(oppId);
   		FileUploadWizardCtrl.deleteOppFiledata(oppFile);
        FileUploadWizardCtrl.getOptionsForSelectedPicklistField();
        FileUploadWizardCtrl.chkIfOppHasProduct(oppId);
        FileUploadWizardCtrl.getQuotedetails(oppId);
        FileUploadWizardCtrl.checkifRFQ(oppId);
        FileUploadWizardCtrl.chkIfOppIsP2Q(oppId);
        }
    
    @isTest
    static void testQuoteInProgress() {
        Opportunity oppty = [SELECT Id,Customer_Journey__c,First_Shipment_Date__c,Last_Shipment_Date__c,CloseDate FROM Opportunity LIMIT 1];
        Opportunity_File__c oppFile = new Opportunity_File__c(
            Name = 'Test Doc.xlsx',
            Opportunity__c = oppty.Id,
            File_Category__c = 'RFQ'
        );
        insert oppFile;
        Quotes__c qo = [SELECT Id, Status__c FROM Quotes__c ];
        qo.Status__c = 'Negotiation Round Completed';
        update qo;
        system.debug('@@@ ' + qo);
        FileUploadWizardCtrl.createQuote(oppFile.Id,'',oppty.id,true,'RFQ');
    }
    @isTest
    static void testP2QFileUpload(){
        Opportunity oppty = [SELECT Id,Customer_Journey__c,First_Shipment_Date__c,Last_Shipment_Date__c,CloseDate FROM Opportunity LIMIT 1];
        oppty.Customer_Journey__c = 'Instant Quote (Non Negotiable)';
        Integer daysLeftInMonth = oppty.CloseDate.daysBetween(oppty.CloseDate.toStartOfMonth());
        Integer daysLeftForNextMonth = Date.daysInMonth(oppty.CloseDate.year(), oppty.CloseDate.month()) - daysLeftInMonth;
        oppty.CloseDate = System.today() + 2;
        System.debug(oppty.CloseDate);
        oppty.First_Shipment_Date__c = System.today() + 5; //+ daysLeftForNextMonth + 9;
        System.debug(oppty.First_Shipment_Date__c);
        oppty.Last_Shipment_Date__c =  System.today() + 11;// + daysLeftForNextMonth + 15;
        System.debug(oppty.Last_Shipment_Date__c);
        update oppty;
        
        Opportunity_File__c oppFile = new Opportunity_File__c(
            Name = 'Test Doc.xlsx',
            Opportunity__c = oppty.Id,
            File_Category__c = 'RFQ'
        );
        insert oppFile;
        
        Boolean res1 = FileUploadWizardCtrl.chkRFQFileUploadedP2Q(oppty.Id);
        Assert.areEqual(true,res1);
        
        delete oppFile;
        
        Boolean res2 = FileUploadWizardCtrl.chkRFQFileUploadedP2Q(oppty.Id);
        Assert.areEqual(false,res2);
        FileUploadWizardCtrl.getHerokufileapi();
        FileUploadWizardCtrl.filewrapper fw = FileUploadWizardCtrl.chkIfOppIsP2Q(oppty.Id);
        Assert.areEqual(true,fw.isp2qFileupload);
    }  
}