/*
* Author   : Ayush.k@Maersk
* Purpose  : Modify the Content Document based on the File Type identified by IDA.
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0       SC-7054    14-Feb-2023     Ayush.k@Maersk         Created
*/

@isTest
global class FileLabel_Test {
	@TestSetup
    public static void setupTestData() {
        List<ContentVersion> lstcontentVersion = new List<ContentVersion>();
        integer intNumberOfCases = 2;
        for(integer i=0; i<intNumberOfCases; i++) {
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins_'+ i,
                PathOnClient = 'Penguins_'+i+'.jpg',
                VersionData = Blob.valueOf('Test Content_'+ i),
                IsMajorVersion = true,
                Document_Type__c = ''
            );
            lstcontentVersion.add(contentVersion);
        }
        insert lstcontentVersion;
    }
    @isTest
    private static void testFieldLabel(){
        Map<String,String> headers = new Map<String, String>();
        List<ContentVersion> documents = [SELECT Id FROM ContentVersion limit 2];
        System.debug('************'+documents);
        headers.put('Accept','application/json');
        Test.setMock(HttpCalloutMock.class, new FileLabel_Test.Mock());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = '/services/apexrest/custom-content-documents';
        req.httpMethod = 'POST';
        String reqbody= '[{"contentDocumentId" : "'+documents[0].Id+'" , "documentContentType": "Logo"},{"contentDocumentId" : "'+documents[1].Id+'" , "documentContentType": "Postal"}]';
        req.requestBody = Blob.valueof(reqbody);
        RestContext.request = req;
        RestContext.response= res;
        FileLabel.doPost();
        List<ContentVersion> updatedLstcontentVersion1 = [Select Id,Document_Type__c From ContentVersion Where id = :documents[1].Id LIMIT 1];
        System.assertEquals(true, updatedLstcontentVersion1[0].Document_Type__c == 'Postal');
        List<ContentVersion> updatedLstcontentVersion2 = [Select Id,Document_Type__c From ContentVersion Where id = :documents[0].Id LIMIT 1];
        System.assertEquals(true, updatedLstcontentVersion2[0].Document_Type__c == 'Logo');
        Test.stopTest();
    }
    
     @isTest
    public static void testException(){
        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept','application/json');
        Test.setMock(HttpCalloutMock.class, new FileLabel_Test.Mock());
        Test.startTest();
        FileLabel.doPost();
        Test.stopTest();
    }
    
     global class Mock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }
}