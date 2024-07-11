/*************************************************************************************************************************************************
 * Description : This is a test class created to cover below class :
 * 1.  OppAttachRelatedListController
 * 
 * Version Date         Owner                                    Ref Number    Description
**************************************************************************************************************************************
* 1.0     17/5/2014    UST                                      Modified as part of cleanup Activity
 * 2.0     14/10/2014   revathy.sudhindran@ust-global.com        #RQ-000058    Commented the statements containing Potential_FFE__c field of Quote Object.
 * 3.0     12/02/2015   Ranjini.Janardhanan@ust-global.com       #RQ-000875    Removed Profile Name hard coding.
 * 4.0     03-03-2017   deepak.r.mahapatra@in.ibm.com            #RQ-004643    Delete Quoting Tool Field in the User object
 * 5.0     04-04-2017   Abby.Abraham@ust-global.com              #RQ-004759    Modified test class to accomodate User Country Mandatory Validation Rule
 * 6.0     26-04-2017   Rathish.Rajendran@ust-global.com         #RQ-004168    Added Account.MSL_Account_Owner__c. Removed fields Account.MSL_Export_Rep_Maersk_Id__c and Account.Export_Rep__c.
 * 7.0     06-06-2019   manjunath.c.holekade@maersk.com          #RQ-010819    Removal of references of deprecated fields 
 * 8.0     14-04-2020   Amritesh@UST                             #RQ-013373    Fixed bad cluster value
 * 9.0     08-06-2022   Ronnie@SF                                SPI-100       Removed brand hardcoding
**************************************************************************************************************************************************/
 
@isTest
private class OppAttachRelatedListController_Test
{
   /* public static Profile integrationProfile=null;
    static {
          CreateIntegrationUserData_Test.initializeIntegrationUser();  
    }*/
    static testMethod void runTestSuite() {
              TriggerExecutionController.skipAllTriggers(true);
            //integrationProfile=[Select Id,Name from Profile where Name = :Label.Integration_User];   
            // TO DO: implement unit test
            Attachment objAttachment=new Attachment();
           Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
            //CreateIntegrationUserData_Test.initializeIntegrationUser();
            
            user integrationUser2= new User();                 
            integrationUser2.FirstName='Demo';                 
            integrationUser2.LastName='Test User';                 
            integrationUser2.Username='TestUser@testsfasfds1.com';                 
            integrationUser2.Email='Tests34235657dfg@ust-global.com';                 
            integrationUser2.Alias='tuser';                 
            integrationUser2.CommunityNickname='dm1';                 
            integrationUser2.TimeZoneSidKey='Europe/London';                 
            integrationUser2.LocaleSidKey='en_GB';                 
            integrationUser2.EmailEncodingKey='ISO-8859-1';                 
            integrationUser2.ProfileId=Label.Integration_User_Profile_Id;  //#RQ-000875                                
            integrationUser2.LanguageLocaleKey='en_US';
            integrationUser2.Cluster__c='Centre Function'; //'France Area';  
            integrationUser2.Country= country.Name; // #RQ-004759
            integrationUser2.Liner_Brand__c = BrandUtilities.MAERSKLINE;// Dual Brand ; Integration User  
            //integrationUser2.Quoting_Tool__c = 'Quote Builder';
            integrationUser2.Maersk_User_Id__c = 'MSL244';
        	//Added as per test class failure to avoid mixed dml exception
        	User runAsUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         	System.runAs(runAsUser){
            	insert integrationUser2;
            }
            Account clientAccount;
            //create account
            System.runAs(integrationUser2){
            	 clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
            }
         
           Contact cont=TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
               System.runAs(integrationUser2){
                cont.Id = null;
                cont.LastName = 'CustomerContactMaersk';
                cont.Phone = '+44 123456';
                cont.MobilePhone = '+44 123456';
                cont.OtherPhone = '+44 123456';
                cont.Fax = '+44 123456';
                insert cont;
             }
        
             Test.startTest();
             
            //create opportunity
            
        
            System.runAs(integrationUser2){
            Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
            setting.Active__c  = true; 
            insert setting;
           Opportunity oppObj = TestBusinessHelper.createOpportunity(clientAccount, cont, integrationUser2, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        
            
            //create quote
            Quote quoteObj = new Quote();
            quoteObj.Name='testQuote';
            quoteObj.Effective_From_Date__c = Date.today();
            quoteObj.ExpirationDate = Date.today() + 30;
           // quoteObj.Potential_FFE__c=100;
            quoteObj.OpportunityId=oppObj.Id;
            quoteObj.Segment__c='Forwarder';
            insert quoteObj;
        
            Opportunity_Attachment__c oppAttObjSingle = new Opportunity_Attachment__c();
            oppAttObjSingle .Opportunity__c=oppObj.id;
            oppAttObjSingle .Type__c='Other';
            insert oppAttObjSingle ;
            
            attachment attcSingle=new attachment();
            attcSingle.OwnerId = UserInfo.getUserId();
            attcSingle.ParentId = oppAttObjSingle .id; // the record the file is attached to
            attcSingle.body=Blob.valueof('Testing PDF1');
            attcSingle.name='Test Class Attachment1';
            attcSingle.IsPrivate = true;
            insert attcSingle;

            List<Attachment> attList = new List<Attachment>();
            List<Opportunity_Attachment__c> oppAttachment = new list<Opportunity_Attachment__c>();
            
            for(Integer i=0; i<10;i++) {
                Opportunity_Attachment__c oppAttObj = new Opportunity_Attachment__c();
                oppAttObj.Opportunity__c=oppObj.id;
                oppAttObj.Type__c='Other';
                oppAttachment.add(oppAttObj);
            } 
             insert oppAttachment;   
               
              for(Integer i=0; i<10;i++){
                attachment attc=new attachment();
                attc.OwnerId = UserInfo.getUserId();
                attc.ParentId = oppAttachment[0].id; // the record the file is attached to
                attc.body=Blob.valueof('Testing PDF');
                attc.name='Test Class Attachment';
                attc.IsPrivate = true;
                attList.add(attc);
            }
           
            insert attList;
            
            System.assertEquals(attList.size(),10);
            
            //set current page refrence
            Test.setCurrentPageReference(Page.OpportunityAttachRelatedList);
            
            //set quote id in page
            ApexPages.currentPage().getParameters().put('Id',oppObj.id);        
            
            //  obj od stndrd set contlr        
            ApexPages.StandardController sc = new ApexPages.standardController(oppObj);
            
            //object of QuoteAttachRelatedListController
            OpportunityAttachRelatedListController oppAttchRelatedListController = new OpportunityAttachRelatedListController(sc);

                // calling del functionality
                oppAttchRelatedListController .strOppAttachId=oppAttObjSingle.id;         
                 oppAttchRelatedListController .delAttachement();

                 //system.assertEquals('/'+quoteObj.id,oppAttchRelatedListController .strGetVal);
                 
                 //call attach functionality
                oppAttchRelatedListController .attachFile();
                //system.assertEquals('/apex/QuoteAttachment?qid='+oppObj.id,oppAttchRelatedListController .strGetVal);
                
                //call view functinality
                ApexPages.currentPage().getParameters().put('attachid',attcSingle.id);           
                oppAttchRelatedListController.viewAttachement();
                system.assertEquals('/servlet/servlet.FileDownload?file='+attcSingle.id,oppAttchRelatedListController .strGetVal);
               
                   //call the getQuoteAttachmentWrapper method and should show 5 at a time because of pagination
                oppAttchRelatedListController.getQuoteAttachmentWrapper();
                //system.assertEquals(oppAttchRelatedListController .getAttach().size(),5);
                
            //call next button Functionality
            oppAttchRelatedListController.next();
            //system.assertEquals(oppAttchRelatedListController.getblShowPrev(), true);
            
            //call previous button Functionality
            oppAttchRelatedListController .previous();
            //system.assertEquals(oppAttchRelatedListController.getblShowNext(), true);        
           }
            Test.stopTest();
    }
}