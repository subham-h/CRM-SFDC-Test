/*
* Test class for 
    AssignmentContentTrigger
  AssignmentContentTriggerHandler
* 
*Vesrion    Date                Owner                                RQ#                        Description
**************************************************************************************************************************
1.0         11/12/2014      Ranjini.Janardhanan@ust-global.com       #PR-0028                   Code created 
                            Madhava.kotte@ust-global.com                          
*/                           
@isTest (seeAlldata = true)
private class AssignmentContentTrigger_Test {
    
    /**
    * For testing the Assignment content Trigger handler class
    */
    testMethod static void InsertPrgmCont_HireContent() {
    
        
        //for inserting the Onboarding Program
        Onboarding_Program__c onbProgram = DataGeneratorHelper2_Test.createOnboardingProgram ();
        
        //for update the Onboarding Program
        //onbProgram.Status__c = 'Ready';
        //update onbProgram;
        
        //for inserting the Program module
        Program_Module__c programModule = DataGeneratorHelper2_Test.createProgramModule(onbProgram.id);

        //for inserting the program assignment
        Program_Assignment__c prgmAssgn = DataGeneratorHelper2_Test.createProgramAssignment(programModule.id,onbProgram.id);
        
        //for inserting the New hire module
        New_Hire_Module__c nhMdle= DataGeneratorHelper2_Test.createNewHireModule();

        //for inserting the new hire assignment with program module assignment
        New_Hire_Assignments__c nhAssgn1 = DataGeneratorHelper2_Test.createNewHireAssignments(nhMdle.id);
                
        //for inserting the content
        Assignmen_Content__c content = DataGeneratorHelper2_Test.createAssignmenContent();
        
        for(Program_Content__c prgmCont : [SELECT id, name FROM Program_Content__c WHERE Assignment_Content__c =: content.id]){
        
            System.assertequals(prgmCont != null, true);
        }
        
        for(New_Hire_Content__c nhCont : [SELECT id, name FROM New_Hire_Content__c WHERE Assignment_Content__c =: content.id]){
        
            System.assertequals(nhCont != null, true);
            
        }

        
    }
    
}