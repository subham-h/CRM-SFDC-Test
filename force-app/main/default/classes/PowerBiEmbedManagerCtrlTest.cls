/**
* Date         Owner            Description
************************************************************************************************************
* 20/10/2022  Sidhartha@Maersk  Test class for PowerBiEmbedManagerCtrl.
* 04/12/23	  Vinay@Maersk		Added a testMethod for SFSE-12521	
*/
@isTest
public class PowerBiEmbedManagerCtrlTest {
    
    @testSetup
    static void setupTestData(){
        // insert Geography     
        Geography__c geoRecord = new Geography__c(Name='UK',Type_Of_Location__c='Country');
        insert geoRecord;
        // inseert BDA to insert  payout curve bda
        BDA__c bdarec  = new BDA__c();
        bdarec.Name = 'Tes Region';
        bdarec.BDA_Code__c = '123';
        bdarec.Type__c = 'Trade Region';
        bdarec.Active__c = true;
        bdarec.GEO_ID__c= 'test';
        insert bdarec;
        
        BDA__c bdareccluster  = new BDA__c();
        bdareccluster.Name = 'Tes area';
        bdareccluster.BDA_Code__c = '1234';
        bdareccluster.Type__c = 'Cluster';
        bdareccluster.Active__c = true;
        bdareccluster.GEO_ID__c= 'test12';
        bdareccluster.Parent_BDA__c = bdarec.id;
        insert bdareccluster;
        
        // get the sales profile and insert Sales user who sip needs to be created
        Id pid = [SELECT Id FROM Profile WHERE Name = 'Sales'].Id;
        List<User> usrlst = new List<User>();
        User usr = new User(LastName = 'sipmeasureControllerTest',Email = 'testrecord@maersk.com',Liner_Brand__c = BrandUtilities.MAERSKLINE, Cluster__c='GSC',Country='UK',Username = 'testabc999999@maersk.com',CompanyName = 'TEST',Title = 'title',Alias = 'alias',Industry_Focus__c='Retail',Segment_Focus__c='Advancement',Sales_Job_Function__c='Sales Manager',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = pid,CM_Visibility__c = 'Single Carrier');
        
        usrlst.add(usr);
        System.runAs(new User(Id = UserInfo.getUserID())){
        insert usrlst; } 
        
        String strYear = String.valueOf( Date.today().year() +1 ) ; 
        
        // Insert the SIp KPI record
        SIP_KPI__c kpiRec = new SIP_KPI__c(Name = 'Ocean Vol',
                                           KPI_Code__c = 'Test code',
                                           KPI_Incentive_Type__c = 'Target-based',
                                           KPI_Type__c = 'Core',
                                           Payout_Frequency__c = 'Annual',
                                           Unit_of_Measure__c = 'FFE',
                                           KPI_Grouping__c = 'Existing and additional business',
                                           Target__c = 11,
                                           Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                           Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                           Geographical_Validity__c = 'Global',
                                           Brand__c = BrandUtilities.MAERSK,
                                           Measure_Type__c='Volume');
        insert kpiRec;

        

        List<SIP_Participant__c> sipUser = new List<SIP_Participant__c>();
        
        SIP_Participant__c newSIP = new SIP_Participant__c();
        newSIP.SIP_Participant__c = usrlst[0].id;
        newSIP.Year__c = strYear;
        
        newSIP.Paymix__c = 80.0;        
        newSIP.Brand__c = BrandUtilities.MAERSK;
        newSIP.Region__c = bdarec.id;
        newSIP.Area__c = bdareccluster.id;
        
        sipUser.add(newSIP);
        
        insert sipUser;   
        
        SIP_Measure__c listSIPMeasure = new SIP_Measure__c();
        listSIPMeasure.SIP_Participant__c = sipUser[0].id;
        listSIPMeasure.SIP_KPI__c = kpiRec.id;
        listSIPMeasure.Weight__c = '20%';
        listSIPMeasure.Applicable_Period__c = 'Q1';
        listSIPMeasure.Target__c =6000;
        listSIPMeasure.System_Actual__c = 5000;            
        insert listSIPMeasure; 
        
    }
    
    @isTest
    static void testPowerBiTokenAndEmbededData(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PowerBIEmbedManagerMock());
        String testRes  = PowerBiEmbedManagerCtrl.getPowerBiAccessToken();
        PowerBiEmbedManagerCtrl.getEmbeddingDataForReport('111111', '22222');
        Test.stopTest();   
    }
    
    @isTest
    static void testSIPOceanLNSEmbededData(){
        List<SIP_Measure__c> lstMeasure = [SELECT Id, Applicable_Period__c ,KPI_Code__c, SIP_Participant__r.SIP_Participant__r.Name, SIP_Participant__r.SIP_Participant__r.Email, SIP_KPI__r.Product_Portfolio__c FROM SIP_Measure__c
                                           LIMIT 1];
        test.startTest();
        SIPLNSOceanTransactionDetailsCtrl.getApplicablePeriodAndProductPortfolio(lstMeasure[0].Id);
        test.stopTest();  
    }
    
    /*@isTest
    static void testGetPerformanceDashboardInfo(){
                	        
        Test.startTest();
        	PowerBiEmbedManagerCtrl.getReportWrkSpaceId();
        	PowerBiEmbedManagerCtrl.getPerformanceDashboardInfo();
        Test.stopTest();
    }*/
}