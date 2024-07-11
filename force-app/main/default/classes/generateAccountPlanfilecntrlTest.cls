/********************************************************************************************
* Sno		Version		Story		Author				Date			Descrition
* 1.		1.0			SFSE-9838	Sidhartha@Maersk	12/11/2022		Test class for generateAccountPlanfilecntrl.
* 2.        2.0         SFSE-12520  Seba@Maersk         19/03/2024      Modified code to handle incoming PPT sections.
* 3.		3.0			SFSE-12520	Avinash@Maersk		20/03/2024		Added code to cover deleteFile method
* 4.		4.0			SFSE-13853	Seba@Maersk	        04/04/2024	    Modified code to improve the behaviour of status component
********************************************************************************************/
@isTest
public class generateAccountPlanfilecntrlTest {
    @testSetup static void setup() {
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        
        
        Contact TestCon1 =ContactDataGeneratorHelper_Test.createCustomerContact( BrandUtilities.MAERSKLINE, ClientAccount.Id, 'Qwerty@gmail.com', RunUser );
        
        Business_Plan__c bp = new Business_Plan__c();
        bp.Lead_Account__c = ClientAccount.Id;
        bp.Name = 'Test';
        bp.Liner_Brand__c = BrandUtilities.MAERSKLINE;
        insert bp;
        
        Id recordTypeId = Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName().get('External').getRecordTypeId();
        Stakeholder__c extStake1 = new Stakeholder__c(External_Stakeholder__c = TestCon1.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        //Stakeholder__c extStake5 = new Stakeholder__c(External_Stakeholder__c = TestCon5.Id, Business_Plan__c = bp.Id, RecordTypeId = recordTypeId);
        List<Stakeholder__c> exStakeList = new List<Stakeholder__c>{extStake1};
            Database.insert(exStakeList, false);
        
        
        
        Focus_Area__c fa = new Focus_Area__c(Account_Plan__c = bp.id,  TFC_Value_Driver__c = 'Strategies',Archived__c = false, 
                                             Name = 'test focus'); insert fa;
        Focus_Area__c fa1 = new Focus_Area__c(Account_Plan__c = bp.id,  TFC_Value_Driver__c = 'Strategies',Archived__c = false, 
                                             Name = 'test focus 1'); insert fa1;
        
        Customer_Metrics__c cm = new Customer_Metrics__c(Year__c = '2022', Business_Plan__c = bp.id, Account__c = ClientAccount.Id,
                                                         Customers_Annual_Revenue__c = 11111, EBIT__c = 1111, Net_Profit__c = 11111);
        insert cm;
        
        Customer_Coverage__c cc = new Customer_Coverage__c(Account_Plan__c= bp.id, Name = 'customer coverage', Maersk_Footprint_Ambition__c = 'test',
                                                           Maersk_Footprint_Current__c = 'test1');
        insert cc;
        
        Operational_Development__c od = new Operational_Development__c(Account_Plan__c = bp.id, Name = 'test', Status__c = 'Amber', Products_Involved__c = 'test');
        
        insert od;
        
        Maersk_Deliverables__c mskd = new Maersk_Deliverables__c(Account_Plan__c = bp.Id, Name = 'test', Focus_Area__c = fa.Id, 
                                                                 Support_Needed__c = 'test', Remarks__c = 'test', Customer_Outcome__c = 'test');
        insert mskd;
        
        Triple_Fit_Canvas__c tfcRec = new Triple_Fit_Canvas__c(Name = 'Strategies', Account_Plan__c = bp.Id, Priority__c = 1); insert tfcRec;
        
        Action__c act = new Action__c(Name= 'test', Account_Plan__c = bp.id,OwnerId= RunUser.Id, Maersk_Deliverables__c = mskd.Id, Goals__c = fa.Id,
                                     Archived__c = false, Due_date__c = system.today().addDays(3));
        Action__c act1 = new Action__c(Name= 'test1', Account_Plan__c = bp.id,OwnerId= RunUser.Id, Maersk_Deliverables__c = mskd.Id, Goals__c = fa.Id,
                                     Archived__c = false, Due_date__c = system.today().addDays(4));
        List<Action__c> action = new List<Action__c>{act,act1};
        Database.insert(action,false);
        
    }
    
    @isTest static void generateAccountPlanfileTest(){
        generateAccountPlanfilecntrl ctrl = new generateAccountPlanfilecntrl();
        Test.startTest();
        Business_Plan__c bp = [SELECT Id, Name FROM Business_Plan__c];  
        generateAccountPlanfilecntrl.checkFileIfPresent(bp.Id);
        generateAccountPlanfilecntrl.getAccountPlanDetails(bp.Id,new List<String>{'Growth Outlook'});
        generateAccountPlanfilecntrl.getCustomerCoverageDetails(bp.Id);
        generateAccountPlanfilecntrl.getOperationDevelopmentsDetails(bp.Id);
        generateAccountPlanfilecntrl.getStakeholderDetails(bp.Id);
        generateAccountPlanfilecntrl.getTripefitCanvasDetails(bp.Id);
        generateAccountPlanfilecntrl.getCustomerMetricDetails(bp.Id);
        generateAccountPlanfilecntrl.getLoggedInUserInfo();
        Test.stopTest();
    }
    
    
    @isTest static void generateAccountPlanfileTest1(){
        Business_Plan__c bp = [SELECT Id, Name FROM Business_Plan__c];
        Test.setMock(HttpCalloutMock.class, new generateAccountPlanHttpCalloutMockImpl());
        Test.startTest();
        generateAccountPlanfilecntrl.generatefile(bp.Id,new List<String>());
        generateAccountPlanfilecntrl.generateppt(bp.Id,new List<String>{'Growth Outlook, Action'}); 
        generateAccountPlanfilecntrl.fetchAccountPlanPPTSectionMetadata();
        Test.stopTest();
    }
    
    //SFSE-12520
    @isTest static void deletefileTest(){
        Business_Plan__c bp = [SELECT Id, Name FROM Business_Plan__c];
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = bp.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        Test.startTest();
        generateAccountPlanfilecntrl.deletefile(documents[0].Id,bp.Id);
        generateAccountPlanfilecntrl.fetchAccPlanDocGenerationUsageData();
        Test.stopTest();
        
    }
    
}