/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		21-Dec-2022		Vazid@UST				Test class for LoopioProjectCtrl
*/

@isTest
public class LoopioProjectCtrl_Test {
    @testSetup static void setup() {
        TriggerExecutionController.skipAllTriggers(true);
        
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);  
        TriggerExecutionController.skipAllTriggers(false);
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = mslOppty.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        Loopio__Loopio_Project__c loopioRec = new Loopio__Loopio_Project__c();
        loopioRec.Name = 'Test Loopio File_DDQ_OP-22-7787468';
        loopioRec.Loopio__Opportunity__c = mslOppty.Id;
        loopioRec.Source_Document__c = 'Test Loopio File_DDQ_13687';
        loopioRec.Request_Type__c = null;
        insert loopioRec;
    }
    
    public class Mock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('apikey','accessToken');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"totalItems":175,"totalPages":175,"items":[{"id":7772,"firstName":"Brice","lastName":"Ouedraogo","email":"brice.ouedraogo@hamburgsud.com","guid":"aad890caa1fa0ef0fa665afcd4d35e68","status":"PENDING"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockProject implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('apikey','accessToken');
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":13690,"name":"Test Loopio File_RFI_OP-22-7787468","projectType":"RFI","status":"ACTIVE","createdDate":"2023-02-06T17:25:58-05:00","dueDate":"2023-02-05T00:00:00-05:00","owner":{"id":7472,"name":"RFIP ."},"creator":{"id":7754,"name":"Salesforce Test API"},"companyName":"G M CORPORATION","description":"Requester : Vazid Shaik &#124; vazid.shaik@maersk.com"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    static testmethod void testgetOppdetails(){    
        List<Opportunity> opplist = [select Id from Opportunity limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        LoopioProjectCtrl.getOppDetails(opplist[0].Id);
        Test.stopTest();        
    }
    
    static testmethod void testContentDocs(){    
        List<Opportunity> opplist = [select Id from Opportunity limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        LoopioProjectCtrl.getContentDocs(opplist[0].Id);
        Test.stopTest();        
    }
    
    static testmethod void testupdateOppWithRequestType(){    
        List<Opportunity> opplist = [select Id from Opportunity limit 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
        
         Loopio__Loopio_Project__c loopioRec = new Loopio__Loopio_Project__c();
        loopioRec.Name = 'Test Loopio File_DDQ_OP-22-7787468';
        loopioRec.Loopio__Opportunity__c = opplist[0].Id;
        loopioRec.Source_Document__c = 'Test Loopio File_DDQ_13683';
        LoopioProjectCtrl.productWrapper loopprodWrap= new LoopioProjectCtrl.productWrapper();
        loopprodWrap.companyName = 'G M CORPORATION';
        loopprodWrap.description = 'Requester : Vazid Shaik | vazid.shaik@maersk.com';
        loopprodWrap.dueDate = '2023-02-05T00:00:00Z';
        loopprodWrap.name = 'Test Loopio File_RFI_OP-22-7787468';
        loopprodWrap.opportunityReference = 'OP-22-7787468';
		LoopioProjectCtrl.ownerId ownerIdRec= new LoopioProjectCtrl.ownerId();
        ownerIdRec.id = '7742';
        loopprodWrap.owner = ownerIdRec;
        loopprodWrap.projectType = 'RFI';
        
        LoopioProjectCtrl.contentDocWrapper contentwrapper = new LoopioProjectCtrl.contentDocWrapper();
        contentwrapper.fileBody = 'JVBERi0xLjcKCjQgMCBvYmoKKElkZW50aXR5KQplbmRvYmoKNSAwIG9iagooQWRvYmUpCmVuZG9iago4IDAgb2JqCjw8Ci9GaWx0ZXIgL0ZsYXRlRGVjb2RlCi9MZW5ndGggMTQ2MzkKL0xlbmd0aDEgMzA0NzYKL1R5cGUgL1N0cmVhbQo';
        contentwrapper.fileContentId = documents[0].Id;
        contentwrapper.fileName = 'Test Loopio File_RFI';
        contentwrapper.fileType = 'pdf';
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockProject());
        LoopioProjectCtrl.updateOppWithRequestType(opplist[0].Id,'RFI',loopioRec,loopprodWrap,null);
        LoopioProjectCtrl.updateOppWithRequestType(opplist[0].Id,'RFI',loopioRec,loopprodWrap,'64');
        Test.stopTest();        
    }
    static testmethod void testgetAPISessionId(){ 
        PageReference pageRef = Page.LoopioVFGetSessionId;
        LoopioAPIParametersCtrl.getAPISessionId();
    }
}