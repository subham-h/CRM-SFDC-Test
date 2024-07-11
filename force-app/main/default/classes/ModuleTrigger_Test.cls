/**
 * Test class for 
 *  ModuleTrigger
 *  ModuleTriggerHandler
 *  ProgramModuleTrigger
 *  ProgramModuleTriggerHandler
 * 
 * Version     Date            Owner                                    RQ#                        Description
 **************************************************************************************************************************
 * 4.0         08/06/2022      Ronnie@SF                                SPI-100                    Removed brand hardcoding
 * 3.0         10/10/2016      Ramadevi.palaniswamy@ust-global.com      #RQ-004412                 Optimized the test classes
 * 2.0         02/09/2015      Sunu.Paul@ust-global.com                 #RQ-002004                 Added badge url
 * 1.0         11/10/2014      Ranjini.Janardhanan@ust-global.com       #PR-0028                   Code created 
 */

@isTest
public class ModuleTrigger_Test {
    
    static Module__c m;
    static List<Module_Assignment__c> msList;
    static List<Assignmen_Content__c> acList;
    static Onboarding_Program__c op;
    static Program_Module__c pm;
    static List<Program_Assignment__c> paList;
    static List<Program_Content__c> pcList;
    static List<ContentDocument> cdocList;
    static user salex;
    static user onboarder;
    static user newhire;
        
    /*
     * Test data creation.
     */
    static testMethod void createModule(){
        m = new Module__c();
        m.Name = 'Module 1';
        m.Category__c = 'Our Company';
        //m.Description__c = 'Test Decription'; //#SP-0013/#RQ-000640
        m.Duration__c = 20;
        m.order__c = 1;

        //RQ-004412 - Optimizing Test class - creating content document in test class
        ContentVersion contentVersion_1 = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocument cdoc =[SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId =: contentVersion_2.Id limit 1];        
        m.Badge_URL__c = cdoc.Id;
        m.Badge_Name__c = 'Handling Challenging Situations';
        System.debug (m +'Module');        
        insert m;
        
        msList = new List<Module_Assignment__c>();
        for(Integer i=0;i<10;i++){
            Module_Assignment__c ms = new Module_Assignment__c ();
            ms.Name = 'Assignment '+i;
            ms.Module__c = m.Id;
            ms.Order__c = i;    
            //ms.Description__c = 'Test Description'; //#SP-0013/#RQ-000640
            msList.add(ms);            
        }
        System.debug(msList +'Module Assignement List');
        insert msList;
        
        acList = new List<Assignmen_Content__c> ();
        for(Integer i=0;i<10;i++){
            
            Assignmen_Content__c ac = new Assignmen_Content__c ();
            ac.Name = 'Content '+i;
            ac.Module_Assignment__c = msList[i].Id;
            //ac.Description__c = 'Test Description'; //#SP-0013/#RQ-000640
            ac.Link_To_Document__c = 'www.google.com';
            acList.add(ac);
        }
        System.debug(acList +'AssignmentContent');
        insert acList;
        
        m.Status__c = 'Ready';
        update m;
    }
    
    static testMethod void createProgram (){
        op =  new Onboarding_Program__c();
        op.Name = 'Test Program';
        op.Brand__c = BrandUtilities.MAERSKLINE;
        op.Department__c = 'IT';
        //op.Description__c = 'Program Description'; //#SP-0013/#RQ-000640
        op.Source__c = 'Internal Hire';
        op.Role__c = 'Business Analyst';
        System.debug(op +'Onboarding Program');
        insert op;
    }
    
    /*
     * Test method for checking if Program Assignemnts and Program Contants are added when a Program Module is created.
     */ 
    
    static testMethod void createProgramModules() {
        createModule();
        System.debug( 'Before creation of Onboarding Program');
        createProgram();
        System.debug( 'After creation of Onboarding Program');
        
        pm = new Program_Module__c();
        pm.Onboarding_Program__c = op.Id;
        pm.Module__c = m.Id;
        insert pm;
        
        paList = [Select Id, Module_Assignment__c, Onboarding_Program__c  from Program_Assignment__c where Onboarding_Program__c =:op.Id ];
        System.assertEquals(paList.size() , 10);
        
        pcList = [Select Id, Onboarding_Program__c, Assignment_Content__c from Program_Content__c where Onboarding_Program__c =:op.Id];
        System.assertEquals(pcList.size() , 10);
    }
    
    /*
     * Test method for checking if Module duration is updated Program Module duation is also updated.
     */
    static testMethod void moduleDurationUpdate() {
        createModule();
        createProgram();
        
        pm = new Program_Module__c();
        pm.Onboarding_Program__c = op.Id;
        pm.Module__c = m.Id;
        insert pm;
        
        pm.Duration__c = 50;
        update pm;
        
        Decimal updatedDuration = [Select Id, Duration__c from Program_Module__c where Id=:pm.Id].Duration__c;
        System.debug('##### updatedDuration'+ updatedDuration);
        System.assertEquals(updatedDuration,50);
    }
    
     static testMethod void TestContentAddPropagate() {
     
     }
}