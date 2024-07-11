/*
* Description: This is a test class created to cover below Classes:
                1.  EnrollmentWizardController.class
                2.  EnrollmentWizardHelper.class
                3.  OnBordingPlanTriggerhandler.class
                4.  NewHireModuleTriggerHandler.class
                
*Vesrion Date             Owner                             Description
*************************************************************************************************
* 1.0    11/10/2014   madhava.kotte@ust-global.com          #PR-0028 :Code created.
                      Deepa.Raman@ust-global.com
*/
@isTest
public class EnrollmentWizard_Test {

    //Declared the below variable as public for reusing this in some other test classes
    public static Module__c moduleInsert;
    public static Module_Assignment__c assignmentInsert;
    public static Program_Module__c recProgModule;
    public static Onboarding_Plan__c onbPlanInsert;
    static Onboarding_Program__c recProgram;
    static List<Onboarding_Plan__c> onbPlanLst;
    public static Onboarding_Plan__c onbPlan;
    
    static
    {

        // create Module record
        moduleInsert = DataGeneratorHelper1_Test.createModule();
        
        //create Module assignment record
        assignmentInsert = DataGeneratorHelper1_Test.createModuleAssignment( moduleInsert.id );
        
        // create module assigment content record
        DataGeneratorHelper1_Test.createAssignmentContent( assignmentInsert.id );
        
        // Change Module status to ready
        DataGeneratorHelper1_Test.updateModuleStatus( moduleInsert, 'Ready' );
        
        // create onboarding program
        recProgram  = DataGeneratorHelper1_Test.createOnboardingProgram();
        
        // create onboarding program module
        recProgModule = DataGeneratorHelper1_Test.createOnboardingProgramModule( recProgram.id, moduleInsert.id );
        
        // Change program status to ready
        DataGeneratorHelper1_Test.updateProgramStatus( recProgram, 'Ready' );
        
        CollaborationGroup  cGrp = DataGeneratorHelper1_Test.createGroup();
        
        // create onboarding plans
        onbPlanLst = DataGeneratorHelper1_Test.createOnboardingPlans( 3 , cGrp.id );
        onbPlanInsert = onbPlanLst.get(0);
       
        onbPlan = onbPlanLst.get(1);
        DataGeneratorHelper1_Test.updatePlanStatus( onbPlan , 'Enrolled');

    }
    
    
    
    /**
    * For Enrolling the Onboarding program to plan
    */
    testMethod static void EnrollmentForOnboarding() {
    
        test.startTest();       
        
        Map<id,Program_Module__c> progrmModuleMap= new Map<id,Program_Module__c>();
        List<onboarding_plan__c> onbLst = new List<onboarding_plan__c>();
        
        EnrollmentWizardController enrollOnbPlan = new EnrollmentWizardController();
        
        enrollOnbPlan.getEnrollOptions();
        enrollOnbPlan.getProgramsPicklist();
        enrollOnbPlan.selectedEnrollment = 'op';
        enrollOnbPlan.NextProcess();
        enrollOnbPlan.searchText = '';
        enrollOnbPlan.searchOnbPlan();
        enrollOnbPlan.searchText = 'Test';
        enrollOnbPlan.searchOnbPlan();
        enrollOnbPlan.isMyOwnPlans = true;
        enrollOnbPlan.searchText = 'Test';
        enrollOnbPlan.searchOnbPlan();
        
        enrollOnbPlan.getOnboardingPlanWrapperList();
        
        System.assert(enrollOnbPlan.getOnboardingPlanWrapperList().size() == 2);
        
        enrollOnbPlan.getOnboardingPlanWrapperList().get(0).isSelected = true;
        enrollOnbPlan.setSelectedPlanWrapperList();
        enrollOnbPlan.gotoEnrollMntProcess();
        enrollOnbPlan.ProcessSelectedPlans();
        enrollOnbPlan.onbProgram = recProgram.id;
        enrollOnbPlan.nextStep();
        
        onbPlanInsert.status__c = 'Enrolled';
        onbPlanInsert.Onboarding_Program__c = enrollOnbPlan.onbProgram;
        onbPlanInsert.Enrolled_Or_Onboarded__c = 1; 

        for(onboarding_plan__c onbObj : [SELECT id, name, status__c FROM Onboarding_Plan__c WHERE id =: onbPlanInsert.id]){
        
            onbLst.add(onbObj);
            System.assert(onbObj.status__c == 'Enrolled', true);
            
        }
        
        update onbLst;

        progrmModuleMap.put(recProgModule.id, recProgModule); 
        EnrollmentWizardHelper.createNewHireModuleFromPModule(onbLst,progrmModuleMap.values());
        
        System.assert(enrollOnbPlan.isOnbPlanComplted, true);

        enrollOnbPlan.PAGE_SIZE = 2;
        enrollOnbPlan.con = new ApexPages.StandardSetController(onbPlanLst);
        enrollOnbPlan.getOnboardingPlanWrapperList();
        enrollOnbPlan.isModuleAvailable = false;
        enrollOnbPlan.updateRecordIndex();
        enrollOnbPlan.donext();
        enrollOnbPlan.doprevious();
        enrollOnbPlan.con.save();
        enrollOnbPlan.dolast();
        enrollOnbPlan.dofirst();
        enrollOnbPlan.onbProgram = recProgram.id;
        enrollOnbPlan.selectedEnrollment = 'ah';
        
        System.assert(enrollOnbPlan.onbProgram != null,true);
        
        enrollOnbPlan.nextStep();

        test.stopTest();
    
    }
    
    
    
    /**
    * For Enrolling the Modules to Plan( Adhoc program)
    */
    testMethod static void EnrollmentForAdhoc() {
    
        test.starttest();
        
        EnrollmentWizardController enrollOnbPlan = new EnrollmentWizardController();
        
        enrollOnbPlan.selectedEnrollment = 'ah';
        
        System.assert(enrollOnbPlan.onbProgram == null,true);
        
        enrollOnbPlan.nextStep();
        enrollOnbPlan.NextProcess();
        enrollOnbPlan.searchOnbPlan();
        enrollOnbPlan.getOnboardingPlanWrapperList();
        
        System.assert(enrollOnbPlan.getOnboardingPlanWrapperList().size() == 2);
        
        enrollOnbPlan.getOnboardingPlanWrapperList().get(0).isSelected = true;
        
        enrollOnbPlan.setSelectedPlanWrapperList();
        enrollOnbPlan.ProcessSelectedPlans();
        enrollOnbPlan.allModules();
        enrollOnbPlan.getModuleWrapperList();
        enrollOnbPlan.isModuleAvailable = true;
        enrollOnbPlan.donext();
        enrollOnbPlan.doprevious();
        enrollOnbPlan.dolast();
        enrollOnbPlan.dofirst();
        
        System.assert(enrollOnbPlan.getModuleWrapperList().size() == 1);
        
        enrollOnbPlan.getModuleWrapperList().get(0).isSelected = true;
        enrollOnbPlan.selectedModule();
        enrollOnbPlan.BackToPlan();
        enrollOnbPlan.EnrollModulesToPlan();
        Map<Id,Module__c> selectedModulesMap = new Map<Id,Module__c>();
        selectedModulesMap.put( moduleInsert.id, moduleInsert );
        
        Map<Id,Onboarding_Plan__c> selectedOnbPlanMap = new Map<Id,Onboarding_plan__c>(onbPlanLst);
        //enrollOnbPlan.
        EnrollmentWizardHelper.createNewHireModuleFromModule(selectedOnbPlanMap.values(),enrollOnbPlan.selectedModulesLst);
        enrollOnbPlan.enrollOrderedModules();
        System.assert(enrollOnbPlan.isOnbPlanComplted, true);
        enrollOnbPlan.backToOnboardingPlanTab();
        enrollOnbPlan.backToModuleSelect();
        
        
        test.stopTest();
    
    }
    
    
    
    /**
    * For testing the Negative scenarios
    */
    testMethod static void EnrollmentNegativeTesting() {
    
        test.starttest();

        EnrollmentWizardController enrollOnbPlan = new EnrollmentWizardController();

        enrollOnbPlan.searchText = 'a';
        enrollOnbPlan.searchOnbPlan();
        
        System.assertequals(Label.SearchText,ApexPages.GetMessages().get(0).getSummary());
        
        enrollOnbPlan.searchText ='abce$#%^#';
        enrollOnbPlan.searchOnbPlan();
        
        System.assertequals(Label.EnterValidCharacters,ApexPages.GetMessages().get(1).getSummary());
        
        enrollOnbPlan.getOnboardingPlanWrapperList();
        enrollOnbPlan.ProcessSelectedPlans();
        
        System.assertequals(Label.IsSelectPlan,ApexPages.GetMessages().get(2).getSummary());
        
        enrollOnbPlan.onbProgram = null;
        enrollOnbPlan.nextStep();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains(Label.ProgramNotSelected)) b = true;
        }
        system.assert(b);//Assert the Page Message was Properly Displayed
    
        test.stopTest();
    
    }
    
    

}