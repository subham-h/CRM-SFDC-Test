/**
* Test Class for DuplicateCaseManagerExtension
* 
*Version    Date           Owner                                      RQ#               Description
*********************************************************************************************************************************  
 * 1.0       April 6,2015    Ranjini.Janardhanan@ust-global.com       #RQ-001140        Code created.
 * 2.0       19-Aug-2015     Sandhya.Sambasivan@ust-global.com        #RQ-001361        Stop Cases from different Liner Brands showing when managing duplicates
 * 3.0       01-Jan-2016     meghana.gupta@ust-global.com             #RQ-002192        Rename test class, add comments and optimization
 * 4.0       05-Nov-2016     nisha.arjunan@ust-global.com             #RQ-004464        Rewrite according to the new standards.
 * 5.0       29-June-2021    Richa@Maersk                             SC-2693           Code cleanup to take care of timeout and 101 SOQL exception 
 * 6.0       27-Jun-2022     Ronnie@SF                                SPI-100           Removed brand hardcoding
 * 7.0       04-Apr-2023     Nayana@maersk.com                        SC-6887           Added methods to cover DuplicateCaseManagerExtensionLWC class
*/

@isTest
public class DuplicateCaseManagerExtension_Test {
    @isTest
    static void testDuplicateCaseMerge() {
        list<Case> lstCases = new list<Case>();
        Group testGroup = new Group(Name='test group', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
              
        CaseData_Test.iNumberOfCases = 5;       
        CaseData_Test.createExternalCases();        
        lstCases = CaseData_Test.lstCases;  
        lstCases[0].OwnerId  = testGroup.Id;
        lstCases[1].OwnerId  = testGroup.Id;
        lstCases[2].OwnerId  = testGroup.Id;
        lstCases[3].OwnerId  = testGroup.Id;
        Test.startTest();
        update lstCases;
        System.debug('#####Inside testlstCases'+lstCases.size());
       
        //Construct your pagereference       
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
        
        TriggerExecutionController.skipCaseTrigger(true);  
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));
        controller.srchCaseNumber = controller.threadDuplicates[4].ca.CaseNumber;
        controller.threadDuplicates[1].isChecked = true;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
        
        controller.searchCase();       
        controller.mergeCases();
        
        System.assertEquals( null, controller.done() );
		TriggerExecutionController.skipCaseTrigger(true);          
        DuplicateCaseManagerExtension controller1 = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));
        controller.threadDuplicates[2].isChecked = true;
        controller.threadDuplicates[3].isChecked = true;
        controller.threadDuplicates[2].isParent = true;
        controller.selectParent();
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = false;
        
        controller.mergeCases();
        TriggerExecutionController.skipCaseTrigger(false);       
        Test.stopTest();        
    }  
    
    @isTest
    static void testDuplicateCaseMergeMethod2() {        

        list<Case> lstCases = new list<Case>();
       
        CaseData_Test.iNumberOfCases = 1;
        CaseData_Test.createExternalCases();  
        lstCases = CaseData_Test.lstCases; 
        system.debug('lstCases size ##'+lstCases.size());
       
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createClaimCases();
        lstCases.addAll(CaseData_Test.lstCases);
        system.debug('lstCases size ##'+lstCases.size());        
         
        //Construct your pagereference
        System.debug('#####Inside testlstCases'+lstCases.size());
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
        
        System.debug('1st one $$$$ '+lstCases[0]);
        Test.startTest();
        TriggerExecutionController.skipCaseTrigger(true); 
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));

        controller.parentCase = null;
        controller.threadDuplicates[0].isChecked = false;
        controller.threadDuplicates[0].isParent = false;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
        
        controller.mergeCases();     
        TriggerExecutionController.skipCaseTrigger(false); 
        
        controller.srchCaseNumber = lstCases[2].CaseNumber;
        system.debug('lstCases[2] $$$'+lstCases[2]);
        controller.threadDuplicates[0].isParent = true;
        controller.searchCase();
        System.assertEquals( null, controller.done() );
        Test.stopTest();

    } 
    
    @isTest
    static void testCreateParentChildRelationship() {      
        list<Case> lstCases = new list<Case>();
        
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c = 'Multi-Carrier';
        lstCases[1].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[1].Case_Visibility__c = 'Multi-Carrier';
        update lstCases;
      
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
 
        Test.startTest();
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));

        controller.threadDuplicates[0].isChecked = false;
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
       
     
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerExecutionController.skipCaseTrigger(true); 
        controller.mergeCases();       
        controller.createParentChildRelationship();
        TriggerExecutionController.skipCaseTrigger(false); 
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCountryMismatchException() {      
        list<Case> lstCases = new list<Case>();
        
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c = 'Multi-Carrier';
        lstCases[1].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[1].Case_Visibility__c = 'Multi-Carrier';
        lstCases[1].Country__c = BDAGeographyData_Test.countryUK.Id;
        update lstCases;
      
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
 
        Test.startTest();
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));

        controller.threadDuplicates[0].isChecked = false;
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
       
     
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerExecutionController.skipCaseTrigger(true); 
        controller.mergeCases();      
        TriggerExecutionController.skipCaseTrigger(false); 
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testRecTypeException() {      
        list<Case> lstCases = new list<Case>();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createClaimRecoveryCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        Test.startTest();
        insert lstCases;
      
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
 
        TriggerExecutionController.skipCaseTrigger(true); 
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));

        controller.threadDuplicates[0].isChecked = false;
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
       
        controller.mergeCases();      
        TriggerExecutionController.skipCaseTrigger(false); 
        Test.stopTest();
    }
    
    @isTest
    static void testCreateParentChildRelationshipLWC() {      
        list<Case> lstCases = new list<Case>();
        
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c = 'Multi-Carrier';
        lstCases[1].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[1].Case_Visibility__c = 'Multi-Carrier';
        update lstCases;
      
        /*PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
 
        Test.startTest();
        DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));

        controller.threadDuplicates[0].isChecked = false;
        controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;*/
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
       
     
        /*controller.threadDuplicates[0].isParent = true;
        controller.threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;*/
        Test.startTest();
        TriggerExecutionController.skipCaseTrigger(true); 
        //controller.mergeCases();   
        List<DuplicateCaseManagerExtensionLWC.caseWrapper> threadDuplicates = new List<DuplicateCaseManagerExtensionLWC.caseWrapper>();
        threadDuplicates = DuplicateCaseManagerExtensionLWC.getDuplicateCases(lstCases[0].id);
        system.debug('wrapper>>'+threadDuplicates.size());
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
        threadDuplicates[0].isChecked = false;
        threadDuplicates[0].isParent = true;
        threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        system.debug('threadDuplicates[0]'+json.serialize(threadDuplicates[0]));
        system.debug('threadDuplicates'+json.serialize(threadDuplicates));
        DuplicateCaseManagerExtensionLWC.createParentChildRelationship(JSON.serialize(threadDuplicates),JSON.serialize(threadDuplicates[0].ca));
        TriggerExecutionController.skipCaseTrigger(false); 
        Test.stopTest();       
    }
    
    @isTest
    static void testDuplicateCaseMergeLWC() {
        list<Case> lstCases = new list<Case>();
        Group testGroup = new Group(Name='test group', Type='Queue');
		insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
              
        CaseData_Test.iNumberOfCases = 5;       
        CaseData_Test.createExternalCases();        
        lstCases = CaseData_Test.lstCases;  
        lstCases[0].OwnerId  = testGroup.Id;
        lstCases[1].OwnerId  = testGroup.Id;
        lstCases[2].OwnerId  = testGroup.Id;
        lstCases[3].OwnerId  = testGroup.Id;
        Test.startTest();
        update lstCases;
        System.debug('#####Inside testlstCases'+lstCases.size());
       
        //Construct your pagereference       
        PageReference testPage = new PageReference( '/apex/DuplicateCaseManager' );
        testPage.getParameters().put( 'id', lstCases[0].Id );
        Test.setCurrentPage(testPage);       
        
        TriggerExecutionController.skipCaseTrigger(true);  
        /*DuplicateCaseManagerExtension controller = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));
        controller.srchCaseNumber = controller.threadDuplicates[4].ca.CaseNumber;
        controller.threadDuplicates[1].isChecked = true;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;
        
        controller.searchCase();       
        controller.mergeCases();
        
        System.assertEquals( null, controller.done() );*/
		TriggerExecutionController.skipCaseTrigger(true);          
        /*DuplicateCaseManagerExtension controller1 = new DuplicateCaseManagerExtension( new ApexPages.StandardController(lstCases[0]));
        controller.threadDuplicates[2].isChecked = true;
        controller.threadDuplicates[3].isChecked = true;
        controller.threadDuplicates[2].isParent = true;
        controller.selectParent();*/
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = false;
        
        //controller.mergeCases();
        TriggerExecutionController.skipCaseTrigger(false); 
        List<DuplicateCaseManagerExtensionLWC.caseWrapper> threadDuplicates = new List<DuplicateCaseManagerExtensionLWC.caseWrapper>();
        threadDuplicates = DuplicateCaseManagerExtensionLWC.getDuplicateCases(lstCases[0].id);
        system.debug('wrapper>>'+threadDuplicates.size());
        threadDuplicates[1].isChecked = true;
        threadDuplicates[3].isChecked = false;
        threadDuplicates[2].isParent = true;
        List<DuplicateCaseManagerExtensionLWC.caseWrapper> searchedCase = new List<DuplicateCaseManagerExtensionLWC.caseWrapper>();
        searchedCase = DuplicateCaseManagerExtensionLWC.searchCase(threadDuplicates[3].ca.CaseNumber,lstCases[0].id);
        threadDuplicates.addAll(searchedCase);
        try{
        	searchedCase = DuplicateCaseManagerExtensionLWC.searchCase(threadDuplicates[1].ca.CaseNumber,lstCases[1].id);
    	}
        catch(AuraHandledException ex){
            system.debug('ex>>'+ex.getmessage());
        }
        DuplicateCaseManagerExtensionLWC.mergeCases(JSON.serialize(threadDuplicates),JSON.serialize(threadDuplicates[2]));
        Test.stopTest();        
    }  
    
    @isTest
    static void testCountryMismatchExceptionLWC() {      
        list<Case> lstCases = new list<Case>();
        
        CaseData_Test.iNumberOfCases = 2;
        CaseData_Test.createExternalCases();
        lstCases.addAll(CaseData_Test.lstCases);
        
        lstCases[0].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[0].Case_Visibility__c = 'Multi-Carrier';
        lstCases[1].Liner_Brand__c = BrandUtilities.MAERSKLS;
        lstCases[1].Case_Visibility__c = 'All Users	';
        lstCases[1].Country__c = BDAGeographyData_Test.countryUK.Id;
        update lstCases;
      
        Test.startTest();
        List<DuplicateCaseManagerExtensionLWC.caseWrapper> threadDuplicates = new List<DuplicateCaseManagerExtensionLWC.caseWrapper>();
        threadDuplicates = DuplicateCaseManagerExtensionLWC.getDuplicateCases(lstCases[0].id);
        
        threadDuplicates[0].isChecked = false;
        threadDuplicates[0].isParent = true;
        threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerRecursionCounter.isMergeFromDuplicateCaseManager = true;       
     
        threadDuplicates[0].isParent = true;
        threadDuplicates[0].ca.Liner_Brand__c = BrandUtilities.MAERSKLS;
        TriggerExecutionController.skipCaseTrigger(true); 
        try{
        	DuplicateCaseManagerExtensionLWC.mergeCases(JSON.serialize(threadDuplicates),JSON.serialize(threadDuplicates[0]));
    	}
        catch(AuraHandledException ex){
            system.debug('ex>>'+ex.getmessage());
        }     
        TriggerExecutionController.skipCaseTrigger(false); 
        Test.stopTest();
        
        
    }
      
}