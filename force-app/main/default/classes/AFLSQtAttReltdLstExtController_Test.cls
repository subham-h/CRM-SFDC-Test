/**
 * Test class for AFLSQtAttReltdLstExtController Class.
 * 
 * Date         Owner                                     Ref.          Description
 *******************************************************************************
 * 23/07/2014   Shiva.Nampally@ust-global.com                           Code created as part of #Upstream.
 * 01/10/2014   Sandhya.Sambasivan@ust-global.com         #RQ-000261    Removed the field Opportunity_Reference_Text__c
 * 08/12/2014   Krishnamoorthi.murugesan@ust-global.com   #RQ-000828    Removed PPVVC from Opportunity
 * 12/02/2015   Ranjini.Janardhanan@ust-global.com        #RQ-000875    Removed not used profile Query.
 * 25/02/2016   Sunu.Paul@ust-global.com                  #RQ-0002978   Introduced data generator classes
 * 15/06/2022   Ronnie@SF                                 SPI-100       Removed brand hardcoding
 */ 

@isTest
private class AFLSQtAttReltdLstExtController_Test{
    system.debug('Some Change');
    static Qt_Quote__c quoteObj;
    static AFLS_Quote_Attachment__c quoteAttObjSingle;
    static Account accObj = TestBusinessHelper.createAccount('Client_Account', true);//#RQ-0002978;
    static Opportunity oppObj = TestBusinessHelper.createOpportunity(accObj, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
       //#RQ-0002978
    static
    {
        List<Qt_Quote__c> AFLSQuoteList = DataGeneratorHelper1_Test.createAFLSQuotes(oppObj.ID,1);
        quoteObj = AFLSQuoteList[0];
        quoteAttObjSingle = DataGeneratorHelper2_Test.createAFLSQuoteAttachment(quoteObj.Id);  
    }    
    
    
    static testMethod void runTestSuite() {
        
        List<Attachment> attList = DataGeneratorHelper2_Test.addAttachment ( 10 ,quoteAttObjSingle.id,'' ); 
        Test.StartTest();
        
        //set current page refrence
        Test.setCurrentPageReference(Page.AFLSQuoteAttachRelatedList);
        
        //set quote id in page
        ApexPages.currentPage().getParameters().put('Id',quoteObj.id);
        
        //  obj od stndrd set contlr   
        ApexPages.StandardController sc = new ApexPages.standardController(quoteObj);
        
        //object of QuoteAttachRelatedListController
        AFLSQuoteAttachRelatedListExtController quoteAttchRelatedListController = new AFLSQuoteAttachRelatedListExtController(sc);
        
        // calling del functionality
        quoteAttchRelatedListController.strQuotAttachId = quoteAttObjSingle.id;         
        quoteAttchRelatedListController.delAttachement();
        
        system.assertEquals('/'+quoteObj.id,quoteAttchRelatedListController.strGetVal);
        
        //call attach functionality
        quoteAttchRelatedListController.attachFile();
        system.assertEquals('/apex/AFLSQuoteAttachment?qid='+quoteObj.id,quoteAttchRelatedListController.strGetVal);
        
        //call view functinality
        ApexPages.currentPage().getParameters().put('attachid',attList[0].id);      
        quoteAttchRelatedListController.viewAttachement();
        
        system.assertEquals('/servlet/servlet.FileDownload?file='+attList[0].id,quoteAttchRelatedListController.strGetVal);
        
        //call the getQuoteAttachmentWrapper method and should show 5 at a time because of pagination
        quoteAttchRelatedListController.getQuoteAttachmentWrapper();
        //system.assertEquals(quoteAttchRelatedListController.getAttach().size(),4);
        
        //call next button Functionality
        quoteAttchRelatedListController.next();
        //system.assertEquals(quoteAttchRelatedListController.previous(), true);
        
        //call previous button Functionality
        quoteAttchRelatedListController.previous();
        //system.assertEquals(quoteAttchRelatedListController.getblShowNext(), true);        
        Test.StopTest();
    }       
    
    /* 
* Create Test AFLSQuote Attachment Extation Controller 
*/
    static testMethod void Test_AFLSQuoteAttachmentExtController(){    
        
        List<Attachment> attList = DataGeneratorHelper2_Test.addAttachment ( 10 ,quoteAttObjSingle.id,'' );
        Test.StartTest();
        
        //set current page refrence QuoteAttachRelatedList
        Test.setCurrentPageReference(Page.AFLSQuoteAttachRelatedList); 
        ApexPages.currentPage().getParameters().put('qid',quoteObj.id);     
        ApexPages.StandardController sc = new ApexPages.standardController(quoteObj);       
        AFLSQuoteAttachmentExtController aflsquoteAttchController = new AFLSQuoteAttachmentExtController(sc);
        
        aflsquoteAttchController.backToQuotePage();
        aflsquoteAttchController.setobjQuoteAttachment(quoteAttObjSingle);
        aflsquoteAttchController.getobjQuoteAttachment();
        aflsquoteAttchController.objAttachment = null;
        system.assertEquals(false, aflsquoteAttchController.bUploadMsg); 
        
        Test.setCurrentPageReference(Page.AFLSQuoteAttachment); 
        ApexPages.currentPage().getParameters().put('qid',quoteObj.id);     
        ApexPages.StandardController sc1 = new ApexPages.standardController(quoteObj);       
        AFLSQuoteAttachmentExtController aflsquoteAttchController1 = new AFLSQuoteAttachmentExtController(sc1);
        system.assertEquals(false, aflsquoteAttchController1.bUploadMsg);
        aflsquoteAttchController1.upload();
        aflsquoteAttchController1.fileSize( 1024 );
        aflsquoteAttchController1.fileSize( 23457 );
        aflsquoteAttchController1.fileSize( 1048578 );                       
        Test.StopTest();    
    }
}
