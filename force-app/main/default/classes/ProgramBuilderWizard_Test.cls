/**
 * Description: This is a test class created to cover below Classes:
 *               1.  ProgramBuilderWizardController
 *               
 * Version Date             Owner                                 Ref Number    Description
 *************************************************************************************************
 * 1.0     11/10/2014       Ranjini.Janardhanan@ust-global.com    #SP-0007      Class created.
 * 2.0     08/06/2022       Ronnie@SF                             SPI-100       Removed brand hardcoding
 */
@isTest
public class ProgramBuilderWizard_Test {
    
    private static List<Module__c> moduleList ;
    private static List<Module_Assignment__c> maList ;
    private static Onboarding_Program__c op;
    private static Program_Module__c pm;
    
    // method to create test data.
    static void createData(){
        
        //create modules.
        moduleList = new List<Module__c>();              
        for(Integer i = 0; i < 10; i++){
            
            Module__c  m = new Module__c();
            m.Name = 'Module-'+i;
            m.Category__c = 'Our Company';
           // m.Description__c = 'Test Decription'; //#SP-0013/#RQ-000640
            m.Duration__c = 20;
            m.order__c = 1;
            moduleList.add(m);
        }
        insert moduleList;
        
        //create module assignements
        maList = new List<Module_Assignment__c>();
        for(Integer i=0;i<10;i++){
            
            Module_Assignment__c ms = new Module_Assignment__c ();
            ms.Name = 'Assignment '+i;
            ms.Module__c = moduleList[i].Id;
            ms.Order__c = i;    
            //ms.Description__c = 'Test Description'; //#SP-0013/#RQ-000640
            maList.add(ms);
        }
        insert maList;
        
        //Make all modules Ready.
        for(Integer i = 0; i < 10; i++){
            moduleList[i].status__c = 'Ready';
        }
        update moduleList;       
        
        //create Program               
        op =  new Onboarding_Program__c();
        op.Name = 'Test Program';
        op.Brand__c = BrandUtilities.MAERSKLINE;
        op.Department__c = 'IT';
        //op.Description__c = 'Program Description'; //#SP-0013/#RQ-000640
        op.Source__c = 'Internal Hire';
        op.Role__c = 'Business Analyst';
        op.Status__c = 'Draft';
        insert op; 
        
        pm = new Program_Module__c();
        pm.Onboarding_Program__c = op.Id;
        pm.Module__c = moduleList[0].Id;
        pm.Order__c = 1;
        insert pm;
    }
    
    testMethod static void ProgramBuilder() {
        
        Test.startTest();
        createData();
        Test.stopTest();
        
        //Test.setCurrentPageReference(new PageReference('Page.ProgramBuilderWizardStep1')); 
        //System.currentPageReference().getParameters().put('pgmId', op.Id);        
        ApexPages.StandardController stdContrl = new Apexpages.Standardcontroller(op);   
        ProgramBuilderWizardController pmbWizard = new ProgramBuilderWizardController(stdContrl);        
        pmbWizard.loadModuleWrapperList();        
        pmbWizard.searchText = 'Module';
        pmbWizard.processSearch();               
        pmbWizard.moduleWrapperList[0].selected = true;
        pmbWizard.processSelectedModules();       
        pmbWizard.moduleOrderWrapperList[0].order = 2;
        System.assert(pmbWizard.moduleOrderWrapperList.size()==1);
        pmbWizard.createProgramModules();       
        pmbWizard.backToProgram();
        pmbWizard.backToStep1();
        
        // Adding more modules to make more coverage.
        Test.setCurrentPageReference(new PageReference('Page.ProgramBuilderWizardStep1')); 
        System.currentPageReference().getParameters().put('pgmId', op.Id);      
        pmbWizard.loadModuleWrapperList();        
        pmbWizard.searchText = 'Module';
        pmbWizard.processSearch();       
        pmbWizard.moduleWrapperList[0].selected = true;
        pmbWizard.processSelectedModules();       
        pmbWizard.moduleOrderWrapperList[0].order = 2;
        System.assert(pmbWizard.moduleOrderWrapperList.size()==1);
        pmbWizard.createProgramModules();
    }
    
    //Modules can not be added to Ready programs.
    testMethod static void ReadyprogramTest() {
        
        Test.startTest();
        createData();
        Test.stopTest();
        
        op.Status__c = 'Ready';
        update op;
        // Test.setCurrentPageReference(new PageReference('Page.ProgramBuilderWizardStep1')); 
        //System.currentPageReference().getParameters().put('pgmId', op.Id);       
        ApexPages.StandardController stdContrl = new Apexpages.Standardcontroller(op);       
        ProgramBuilderWizardController pmbWizard = new ProgramBuilderWizardController(stdContrl);   
    }
}