/**
* Test class for : ProjectTemplateTrigger

* Date         Owner                                           Description
******************************************************************************************************************************
* 25/04/2018   jiji.jayasingh@ust-global.com               		Test Class for ProjectTemplateTrigger
*/


@isTest
private class ProjectTemplateTrigger_Test {
    
	static testMethod void test_insertProjectTemplate() {
        Test.startTest();
        	List<Project_Template__c> projTemptoInsert = new List<Project_Template__c>();
        
            Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
            Opportunity mslOppty2 = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null);
            Project_Template__c projTempRec = new Project_Template__c();
            projTempRec.Name = 'Test Project Template';
            projTempRec.Opportunity__c = mslOppty2.Id;
            try{
                insert projTempRec;
            
                Project_Template__c dupProjTempRec = new Project_Template__c();
                dupProjTempRec.Name = 'Test Duplicate Project Template';
                dupProjTempRec.Opportunity__c = mslOppty2.Id;
                
        		insert dupProjTempRec;
            }
            catch(exception e){
                system.debug(e);
                System.Assert(e.getMessage().contains(system.label.TenderWorkflowError));
            }
        Test.stopTest();
        
    }
}