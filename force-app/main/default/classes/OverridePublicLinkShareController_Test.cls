/*
* version   Date         Owner             Description
*******************************************************************************************************
* v1.0      18/06/2019   Nitin More        test class created.
*/
@isTest
private class OverridePublicLinkShareController_Test {
    @testSetup static void setup() {

        List<ContentVersion> lstCVToInsert = new List<ContentVersion>();
        lstCVToInsert.add(new ContentVersion(Title = 'testFile_Internal', PathOnClient = 'testFileInternal.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true, Internal_External__c ='Internal'));
        lstCVToInsert.add(new ContentVersion(Title = 'testFile_External', PathOnClient = 'testFileExternal.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true, Internal_External__c ='External'));
        insert lstCVToInsert;

        //system.debug('##### lstCTToInsert: ' + lstCTToInsert);
	}

    static testMethod void test_checkInternalDocument() {
    
	    ContentVersion testCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Internal_External__c = 'Internal' Limit 1];
	    Boolean isInternal;
        Test.startTest();
            isInternal = OverridePublicLinkShareController.checkInternalDocument(testCV.ContentDocumentId);
        Test.stopTest();
	    
	    System.assertEquals(isInternal, true, 'File is External');
    }

    static testMethod void test_CreateANDCheckURL() {
    
	    ContentVersion testCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Internal_External__c = 'External' Limit 1];
	    String strCreateSharedURL;
        String strCheckURL;
        Test.startTest();
            strCreateSharedURL = OverridePublicLinkShareController.createSharedUrl(testCV.ContentDocumentId);
            strCheckURL = OverridePublicLinkShareController.checkForSharedUrl(testCV.ContentDocumentId);
        Test.stopTest();
	    
	    System.assertNotEquals(strCreateSharedURL, null, 'File public url is not created');
        System.assertNotEquals(strCheckURL, null, 'File public url does not exists.');

    }

    static testMethod void test_deleteSharedURL() {
    
	    ContentVersion testCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Internal_External__c = 'External' Limit 1];
	    String strCreateSharedURL;
        Boolean blnDeletedBooleanURL = false;
        Test.startTest();
            strCreateSharedURL = OverridePublicLinkShareController.createSharedUrl(testCV.ContentDocumentId);
            blnDeletedBooleanURL = OverridePublicLinkShareController.deleteSharedURL(testCV.ContentDocumentId);
        Test.stopTest();
	    
        System.assertEquals(blnDeletedBooleanURL, true, 'public url is not deleted.');
    }
}