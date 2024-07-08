/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		17-05-2024		Vazid@UST				This is a test class for CaseRecommendationManager
*/

@isTest
public class CaseRecommendationManagerTest {
	 Public static List<Case> lstCases = new List<case>();
    public static List<Case_Recommendation__c> caseRecomList = new List<Case_Recommendation__c>();
    
    @TestSetup
    static void setupTestData(){
        
        Geography__c countryIN = TestBusinessHelper.createGeography('India', 'Country', null,'IN',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('India and Bangladesh Area and Region', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'null', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryIN.Id, null, true);
        
        Account acc = TestBusinessHelper.createAccount('Unassigned', false);
        acc.Id = null;
        acc.Name = 'Test Account';
        acc.Country__c = countryIN.Id;
        insert acc;
        
        Contact con = TestBusinessHelper.createContact(acc, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        con.Id = null;
        con.Country__c = acc.Country__c;
        insert con;
        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue = TestBusinessHelper.createQueueSobject(testGroup,'Case',true);
        
        Case cs = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs.Id = null;
        cs.Subject = 'Test 224069341';
        cs.Case_Channel__c = 'E-mail';
        cs.Description = 'Test new case';
        cs.Product__c = 'Ocean';
        cs.Case_Channel__C = 'E-mail';
        cs.Origin = 'MSLINEXP';
        cs.Country__c = countryIN.Id;
        cs.type = 'Charges, Invoice & Payment';
        cs.Sub_Type__c = 'Invoice / Payer Party';
        cs.Reason_For_Case__c = 'Invoice Query';
        cs.suppliedEmail = 'abc@gmail.com';
		cs.Cluster__c = childBDA.id;
        cs.Region__c  = parentBDA.id;
        cs.OwnerId = testGroup.Id;
        lstCases.add(cs);

        
        Case cs2 = TestBusinessHelper.createCase(acc, con, 'External_Case', false);
        cs2.Id = null;
        cs2.Subject = 'Test2 224069341';
        cs2.Case_Channel__c = 'E-mail';
        cs2.Description = 'Test2 new case';
        cs2.Product__c = 'Ocean';
        cs2.Case_Channel__C = 'E-mail';
        cs2.Origin = 'MSLINEXP';
        cs2.Country__c = countryIN.Id;
        cs2.type = 'Charges, Invoice & Payment';
        cs2.Sub_Type__c = 'Invoice / Payer Party';
        cs2.Reason_For_Case__c = 'Invoice Query';
        cs.suppliedEmail = 'abc@gmail.com';
		cs2.Cluster__c = childBDA.id;
        cs2.Region__c  = parentBDA.id;
        cs2.OwnerId = testGroup.Id;
        lstCases.add(cs2);
        insert lstCases;
                
        Case_Recommendation__c emailRecommendationRecord1 = TestBusinessHelper.createCaseRecommendation( 'Email_Recommendation', false);
        emailRecommendationRecord1.id = null;
        emailRecommendationRecord1.Case__c = cs.Id;
		caseRecomList.add(emailRecommendationRecord1);
        Case_Recommendation__c resolutionRecommendationRecord1 = TestBusinessHelper.createCaseRecommendation('Resolution_Recommendation',  false);
        resolutionRecommendationRecord1.Email_Recommendation__c = 'Dear Chris, \n\n Please proceed with the case updates.\n\n thanks and Regards\n\n';
        resolutionRecommendationRecord1.id = null;
        resolutionRecommendationRecord1.Case__c = cs.Id;
        resolutionRecommendationRecord1.Priority__c = 1;
        resolutionRecommendationRecord1.Recommendation_Summary__c = '[Proceed further]';
        resolutionRecommendationRecord1.Action_Status__c = 'Hold';
		caseRecomList.add(resolutionRecommendationRecord1);
        Case_Recommendation__c resolutionRecommendationRecord2 = TestBusinessHelper.createCaseRecommendation('Resolution_Recommendation',  false);
        resolutionRecommendationRecord2.Email_Recommendation__c = 'Dear Chris, \n\n BL and shipments are released.\n\n thanks and Regards\n\n';
        resolutionRecommendationRecord2.id = null;
        resolutionRecommendationRecord2.Case__c = cs2.Id;
        resolutionRecommendationRecord2.Priority__c = 1;
        resolutionRecommendationRecord1.Action_Status__c = 'Released';
        resolutionRecommendationRecord2.Recommendation_Summary__c = 'BL has been released, Shipment has been shipped';
		caseRecomList.add(resolutionRecommendationRecord2);
        insert caseRecomList;
        
        
    }
    
    @isTest
    public static void testupdateCaseRecordsToRemoveCheckerQueue(){
        List<Case> caseList = [Select Id from Case];
        set<Id> idsList = new set<Id>();
        for(Case caseRec: caseList){
            idsList.add(caseRec.Id);
        }
        Test.startTest();
        CaseRecommendationManager.updateCaseRecordsToRemoveCheckerQueue(idsList);
        Test.stopTest();
        system.assertNotEquals(([Select Count() from Case where AI_Recommendation_Status__c = 'No Resolution']),0);

    }
    
    @isTest
    public static void testupdateCaseRecordsWithCheckerQueue(){
        List<Case> caseList = [Select Id from Case];
        set<Id> idsList = new set<Id>();
        for(Case caseRec: caseList){
            idsList.add(caseRec.Id);
        }
        Test.startTest();
        CaseRecommendationManager.updateCaseRecordsWithCheckerQueue(idsList);
        Test.stopTest();
        system.assertNotEquals(([Select Count() from Case where AI_Recommendation_Status__c = 'On Hold']),0);
    }
    
}