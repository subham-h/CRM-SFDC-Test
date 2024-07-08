/**
 * This class contains unit tests for 
 *  
 *  1.OpportunityAttachmentController
 * 
 *  Created by : UST Global
 *  Created On : 21-5-2014
 * 
 * Date          Owner                             Ref.            Description
 ******************************************************************************************************************************
 * 11/02/2016    Sunu.Paul@ust-global.com          #RQ-002978      Introduced data generator classes 
 * 12/08/2016    Jiji@UST                          #RQ-004057      Remove reference to Survey_Me__c field
 * 22/08/2016    Jiji@UST                          #RQ-004319      Remove reference to Primary_Contact__c field
 * 15/06/2022    Ronnie@SF                         SPI-100         Removed brand hardcoding
 */

@isTest
private class OpportunityAttachment_Test {
    
    
    static testMethod void AttachFile() {
        TriggerExecutionController.skipAllTriggers(true);
        //#RQ-002978-Started   
        User RunUser = TestBusinessHelper.createUser( 'Integration User', BrandUtilities.MAERSKLINE, true);
         Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
        //RunUser,country,
        Account acctObj = TestBusinessHelper.createAccount('Client_Account', true);
       
        /*Contact contObj =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,acctObj.Id,
        'TestContact@testingContact23sdf.play', true,false,RunUser);//Create MSL Contact*/
        Contact contObj = TestBusinessHelper.createContact(acctObj, 'Customer_Contact', BrandUtilities.MAERSKLINE, true);
        //Create MSL Contact  
        
        Opportunity oppObj =  TestBusinessHelper.createOpportunity(acctObj, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
            //#RQ-002978-Ended
        TriggerExecutionController.skipAllTriggers(false);
        System.runAs(RunUser) {
            
            Test.startTest();
            Opportunity_Attachment__c oppAttObj = new Opportunity_Attachment__c();
            oppAttObj.Opportunity__c = oppObj.id;
            oppAttObj.Type__c = 'Other';
            
            attachment attc = new attachment();
            attc.OwnerId = UserInfo.getUserId();
            attc.ParentId = oppAttObj.id; // the record the file is attached to
            attc.body = Blob.valueof('Testing PDF');
            attc.name = 'Test Class Attachment';
            attc.IsPrivate = true;
            
            //set current page refrence
            Test.setCurrentPageReference(Page.OpportunityAttachment);
            //set quote id in page
            ApexPages.currentPage().getParameters().put('qid', oppObj.id);        
            //  obj od stndrd set contlr        
            ApexPages.StandardController sc = new ApexPages.standardController([Select id from Opportunity limit 1]);
            //object of QuoteAttachRelatedListController
            OpportunityAttachmentController oppAttachController = new OpportunityAttachmentController(sc);
            
            oppAttachController.attachment=attc;
            oppAttachController.objOppAttachment=oppAttObj;  
            oppAttachController.upload();
            
            //Covering getter and setter of objOppAttachment
            oppAttachController.setobjOppAttachment(oppAttachController.getobjOppAttachment());
            
            //Back to quote Page           
            oppAttachController.backToQuotePage();
            
            //Exception Scenario   :Attachment without ParentId
            oppAttachController.attachment = null;//Covering attachment setter
            attc= oppAttachController.attachment;//Covering attachment getter
            attc.OwnerId = UserInfo.getUserId();
            attc.name = 'Test Class Attachment';
            attc.IsPrivate = true;
            oppAttachController.attachment = attc;
            oppAttachController.upload();
            
            //Covering filesize method();
            String sizestr=oppAttachController.fileSize(1024);
            system.assert(sizestr == '1.00 KB');
            sizestr=oppAttachController.fileSize(1024*1024);
            system.assert(sizestr == '1.00 MB');
            sizestr=oppAttachController.fileSize(10241024*1024);
            system.assert(sizestr == null);
            Test.stopTest();
        }
        
    }
}