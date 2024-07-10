/*
* Author   : Nisha
* Purpose  : Test Class for CaseFCRCalculation
*        
* Revision Ref Number  Date         Owner                   Description
* -------- ----------  -----------  -------------------     -----------
* 1.0      RQ-004667  20-Apr-2017  Nisha@UST                Test Class for CaseFCRCalculation
* 2.0      Rq-008811  10-Aug-2018  Meenakshi@UST            Included Dispute case records to test
*/
@isTest
public class CaseFCRCalculation_Test {
    
    public static testMethod void test_populateFCRCall(){
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();
        list<Case> lstChildCse = new list<Case>();
        list<Case> lstParentCse1 = new list<Case>();
        list<Case> lstChildCse1 = new list<Case>();
        set<Id> selectedChildIds = new set<Id>();
        CaseData_Test.createExternalCases();       
        lstparentCse = CaseData_Test.lstCases;
        insert lstParentCse;
        system.debug('parent case id ##'+lstParentCse[0].Id);
        
        ActivityData_Test.iNumberOfTask = 5;
        ActivityData_Test.bCreate = false;
        ActivityData_Test.createTasks();
        list<Task> lstTasksChild = new list<Task>();
        
        CaseData_Test.createExternalCases();
        lstChildCse = CaseData_Test.lstCases; 
        insert lstChildCse; 
        
        Test.starttest();
        for(Case childCseInbndAct: lstChildCse){        
            for(Task taskIterator : ActivityData_Test.lstTasks) {
                taskIterator.WhatId = childCseInbndAct.Id;
                taskIterator.Type = 'Call';
                taskIterator.Direction__c = 'Inbound';
                lstTasksChild.add(taskIterator);
                selectedChildIds.add(childCseInbndAct.Id);
            }       
            
        }
        insert lstTasksChild;       
        
        system.debug('Child task size ###'+lstTasksChild.size());
        for(Case lstUpdateChildStatus : lstChildCse){
            lstUpdateChildStatus.parentId = lstParentCse[0].Id;
            lstUpdateChildStatus.Status = 'Closed - Merged';
        }
        update lstChildCse;
        
        list<Case> lstUpdatedParentCase = new list<Case>([SELECT Id,status, FCR_Inbound_Calls__C, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Case_Comment__c FROM Case where Id =: lstParentCse[0].Id ]); 
        system.debug('Tasks on Parent'+[SELECT id from Task where WhatId = : lstParentCse[0].Id]);
        System.assertEquals(lstUpdatedParentCase[0].FCR_Inbound_Calls__c, 5);
        Test.Stoptest();
        
    }
    
    public static testMethod void test_populateFCRFields(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse = new list<Case>();
        list<Case> lstChildCse = new list<Case>();
        list<Case> lstParentCse1 = new list<Case>();
        list<Case> lstChildCse1 = new list<Case>();
        set<Id> selectedChildIds = new set<Id>();
        CaseData_Test.createExternalCases();       
        lstparentCse = CaseData_Test.lstCases;
        insert lstParentCse;
        
        system.debug('parent case id ##'+lstParentCse[0].Id);
        //  CaseData_Test.createDisputecases(); //Add dispute cases
        // lstparentCse1 = CaseData_Test.lstCases;
        //insert lstParentCse1;
        
        ActivityData_Test.iNumberOfTask = 5;
        ActivityData_Test.bCreate = false;
        ActivityData_Test.createTasks();
        list<Task> lstTasksChild = new list<Task>();
        
        EmailMessageData_Test.iNumberOfEmailMessages = 5;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssg = new list<EmailMessage>();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        
        CaseData_Test.createExternalCases();
        lstChildCse = CaseData_Test.lstCases; 
        insert lstChildCse; 
        
        // CaseData_Test.createDisputecases(); //Add dispute cases
        //lstChildCse1 = CaseData_Test.lstCases;
        //insert lstChildCse1;
        
        EmailMessageData_Test.createEmailMessage();     
        for(Case childCseInbndAct: lstChildCse){        
            for(Task taskIterator : ActivityData_Test.lstTasks) {
                taskIterator.WhatId = childCseInbndAct.Id;
                taskIterator.Type = 'Call';
                taskIterator.Direction__c = 'Inbound';
                lstTasksChild.add(taskIterator);
                selectedChildIds.add(childCseInbndAct.Id);
            }       
            for(EmailMessage emailMessageIterator :  EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = childCseInbndAct.Id;
                lstEmailMssgChild.add(emailMessageIterator);
            }           
        }
        Test.startTest();
        insert lstTasksChild;
        
        
        insert lstEmailMssgChild;
        
        
        system.debug('Child task size ###'+lstTasksChild.size());
        system.debug('Child email list size ###'+lstEmailMssgChild.size());
        
        
        
        /*EmailMessageData_Test.createEmailMessage();
for(Case parentCseInbndAct: lstParentCse){             
for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
emailMessageIterator.parentid = parentCseInbndAct.Id;
lstEmailMssg.add(emailMessageIterator);
}   
}
//Considering the Email Messages are moved manually
insert lstEmailMssg;*/
        
        for(Case lstUpdateChildStatus : lstChildCse){
            lstUpdateChildStatus.parentId = lstParentCse[0].Id;
            lstUpdateChildStatus.Status = 'Closed - Merged';
        }
        
        CaseFCRCalculation.calculateFcrInParentDuplicate(lstParentCse[0].Id, selectedChildIds);
        
        update lstChildCse;
        //update lstChildCse1;        
        
        system.debug('Updated chils case ###'+ [select id,status from case where id=:lstChildCse[0].Id]);
        
        list<Case> lstUpdatedParentCase = new list<Case>([SELECT Id,status, FCR_Inbound_Calls__C, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Case_Comment__c FROM Case where Id =: lstParentCse[0].Id ]); 
        system.debug('Parent case ##'+lstUpdatedParentCase);    
        system.debug('Emails on Parent'+[SELECT id from EmailMessage where parentid = : lstParentCse[0].Id]);
        system.debug('Tasks on Parent'+[SELECT id from Task where WhatId = : lstParentCse[0].Id]);
        //System.assertEquals(lstUpdatedParentCase[0].FCR_Inbound_Calls__c, 5);
        System.assertEquals(lstUpdatedParentCase[0].FCR_Inbound_Contact_Emails__c, 0);
        System.assertEquals(lstUpdatedParentCase[0].FCR_Inbound_Case_Comment__c, 0);
        Test.stopTest();
    }
    
    public static testMethod void test_populateFCRFieldsforDisputecase(){
        integer i =0;
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.iDisputeNumber = 3;
        CaseData_Test.conInstance = conInstance;
        list<Case> lstParentCse1 = new list<Case>();
        list<Case> lstChildCse1 = new list<Case>();
        
        CaseData_Test.createDisputecases(); //Add dispute cases
        lstparentCse1 = CaseData_Test.lstCases;
        for(i=0;i<CaseData_Test.iNumberOfCases;i++){
            lstparentCse1[i].Disputed_Invoice_Number__c = '123456789'+i;
            
        }
        insert lstParentCse1;
        
        ActivityData_Test.iNumberOfTask = 5;
        ActivityData_Test.bCreate = false;
        ActivityData_Test.createTasks();
        list<Task> lstTasksChild = new list<Task>();
        
        EmailMessageData_Test.iNumberOfEmailMessages = 5;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssg = new list<EmailMessage>();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        
        for(Case parentCseInbndAct: lstParentCse1){             
            for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = parentCseInbndAct.Id;
                lstEmailMssg.add(emailMessageIterator);
            }   
        }
        //TriggerExecutionController.skipEmailMessageTrigger(true);
        insert lstEmailMssg;
        
        Test.startTest();        
        CaseData_Test.iDisputeNumber = 6;    
        CaseData_Test.createDisputecases(); //Add dispute cases
        lstChildCse1 = CaseData_Test.lstCases;       
        insert lstChildCse1;
        
        EmailMessageData_Test.createEmailMessage();     
        for(Case childCseInbndAct: lstChildCse1){        
            for(Task taskIterator : ActivityData_Test.lstTasks) {
                taskIterator.WhatId = childCseInbndAct.Id;
                taskIterator.Type = 'Call';
                taskIterator.Direction__c = 'Inbound';
                lstTasksChild.add(taskIterator);
            }       
            for(EmailMessage emailMessageIterator :  EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.parentid = childCseInbndAct.Id;
                lstEmailMssgChild.add(emailMessageIterator);
            }           
        }
        insert lstTasksChild;
        insert lstEmailMssgChild;
        
        for(Case lstUpdateChildStatus : lstChildCse1){
            lstUpdateChildStatus.parentId = lstParentCse1[0].Id;
            lstUpdateChildStatus.Status = 'Closed - Merged';
            //added test
            lstUpdateChildStatus.OwnerId=UserInfo.getUserId();
        }
        
        
        update lstChildCse1;
        Test.stopTest();
        
        list<Case> lstUpdatedParentCase = new list<Case>([SELECT Id, FCR_Inbound_Calls__C, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Case_Comment__c FROM Case where Id =: lstParentCse1[0].Id ]); 
        Assert.areEqual(5, lstUpdatedParentCase[0].FCR_Inbound_Calls__c);
        Assert.areEqual(0, lstUpdatedParentCase[0].FCR_Inbound_Contact_Emails__c);
        Assert.areEqual(0, lstUpdatedParentCase[0].FCR_Inbound_Case_Comment__c);
    }
    
    public static testMethod void test_populatePostClosureActivityDate(){
        
        ContactData_Test.bCreate = false;
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();   
        Contact conInstance = ContactData_Test.lstContacts[0];
        conInstance.Email = 'Test@test.com';
        insert conInstance;
        
        list<Case> lstParentCse = new list<Case>();
        list<Case> lstChildCse = new list<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.conInstance = conInstance;
        CaseData_Test.createExternalCases();
        lstparentCse = CaseData_Test.lstCases;
        lstparentCse[0].Type = 'Booking';
        lstparentCse[0].Sub_Type__c = 'New Booking Request';  
        lstparentCse[0].Reason_For_Case__c = 'Booking Request';
        lstparentCse[0].Resolution_Summary__c = 'Solved';
        lstparentCse[0].Status = 'Closed - Resolved';
        lstparentCse[0].FCR_Process_Date__c = System.now();
        insert lstParentCse;
        
        CaseData_Test.createExternalCases();
        lstChildCse = CaseData_Test.lstCases;
        insert lstChildCse;
        
        ActivityData_Test.iNumberOfTask = 5;
        ActivityData_Test.bCreate = false;
        ActivityData_Test.createTasks();
        list<Task> lstTasksChild = new list<Task>();
        
        EmailMessageData_Test.iNumberOfEmailMessages = 5;
        EmailMessageData_Test.bCreate = false;
        EmailMessageData_Test.createEmailMessage();
        list<EmailMessage> lstEmailMssgChild = new list<EmailMessage>();
        for(Case childCseInbndAct : lstChildCse) {
            for(Task taskIterator : ActivityData_Test.lstTasks) {
                taskIterator.WhatId = childCseInbndAct.Id;
                taskIterator.Type = 'Call';
                taskIterator.Direction__c = 'Inbound';
                lstTasksChild.add(taskIterator);
            }
            
            for(EmailMessage emailMessageIterator : EmailMessageData_Test.lstEmailMessages) {
                emailMessageIterator.ParentId = childCseInbndAct.Id;
                lstEmailMssgChild.add(emailMessageIterator);
            }       
        }
        Test.startTest();
        insert lstTasksChild;
        insert lstEmailMssgChild;
        
        for(Case lstUpdateChildStatus : lstChildCse) {
            lstUpdateChildStatus.ParentId = lstParentCse[0].Id;
            lstUpdateChildStatus.Status = 'Closed - Merged';
        }
        
        update lstChildCse; 
        
        list<Case> lstUpdatedParentCase = new list<Case>([SELECT Id, FCR_Inbound_Calls__C, FCR_Inbound_Contact_Emails__c, FCR_Inbound_Case_Comment__c, FCR_Post_Closure_Activity_Date__c FROM Case where Id =: lstParentCse[0].Id ]);
        list<Case> lstChildCreatedDate = new list<Case>( [SELECT Id, CreatedDate FROM Case where Id =: lstChildCse[0].Id ]);
        Test.stopTest();
        
        //System.assertEquals(lstUpdatedParentCase[0].FCR_Post_Closure_Activity_Date__c, lstChildCreatedDate[0].CreatedDate);     
    }
    
}