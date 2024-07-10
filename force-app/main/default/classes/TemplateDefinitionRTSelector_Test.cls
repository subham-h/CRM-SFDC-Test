/**
* Test class for TemplateDefinitionRecordTypeSelector

Vesrion     Date                Owner                                RQ#                        Description
**************************************************************************************************************************
1.0      18/02/2015      revathy.sudhindran@ust-global.com       #RQ-000918                 Created to give test coverage
2.0      30/09/2019               Neha-TCS                       #RQ-012062                 Removing field reference reason for won
*/
@isTest  
private class TemplateDefinitionRTSelector_Test {
    
     static List<Quote_Template__c> quoteEmailTemplates;


    /* 
    * Create Test AFLS Quote 
    */    
    static void createTestQuoteTemplates(){
    
            //Getting all Account RecordTypes available in System
            Schema.DescribeSObjectResult accountSObjectResult = Schema.SObjectType.Quote_Template__c; 
            Map<ID,Schema.RecordTypeInfo> rtMapByID  = accountSObjectResult.getRecordTypeInfosByID();
            quoteEmailTemplates=new List<Quote_Template__c>();
            
            //insert Quote Email Template
             for(Schema.RecordTypeInfo recType:rtMapByID.Values()){
                
                if(recType.getName()!='Master'){ //Avoiding master record as that cannot be created
                    
                    Quote_Template__c   quoteEmailTemplate = new Quote_Template__c();
                    quoteEmailTemplate.Name = recType.getName();
                    quoteEmailTemplate.RecordTypeId=recType.getRecordTypeId();
                    quoteEmailTemplate.Body__c = 'Test Email template body {!Quote.Name} {!Quote.Phone} {!Opportunity.Name} {!Account.Name} {!Account.Phone} {!User.Username} {!User.Phone}';
                    quoteEmailTemplate.Signature__c = 'Test Email Temaplate Signature  {!User.Phone} {!User.Email}';
                    quoteEmailTemplate.Subject__c = 'Test Email Temaplate Subject {!Account.Name} - {!Quote.Name} - {!Opportunity.Name} - {!User.Username}';
                    quoteEmailTemplate.Language__c = 'English';
                    quoteEmailTemplate.Default__c = true;
                    quoteEmailTemplates.add(quoteEmailTemplate);
                }
            }
            
                insert quoteEmailTemplates;
                
            
    }       
    
    /*
    * Testing Redirect to page 
    */
     static testMethod void testRedirectToPage() {
        
            
             Test.StartTest();
             
             createTestQuoteTemplates();
             
             ApexPages.StandardController stdController;
             TemplateDefinitionRecordTypeSelector cotrollerExtn;
             PageReference pgRef;
             
              for(Quote_Template__c qtmp:quoteEmailTemplates){
                     
                     ApexPages.currentPage().getParameters().put('RecordType',qtmp.RecordTypeId);             
                     stdController = new ApexPages.standardController(qtmp);
                     cotrollerExtn= new TemplateDefinitionRecordTypeSelector(stdController);
                     pgRef = cotrollerExtn.redirectToPage();
                     System.Assert(pgRef!=null);
             }
             for(Quote_Template__c qtmp:quoteEmailTemplates){
                     
                     ApexPages.currentPage().getParameters().put('id',qtmp.Id);             
                     stdController = new ApexPages.standardController(qtmp);
                     cotrollerExtn = new TemplateDefinitionRecordTypeSelector(stdController);
                     pgRef = cotrollerExtn.redirectToPage();
                     System.Assert(pgRef!=null);
             }
             
             
             Test.stopTest();
            
     }
            
}