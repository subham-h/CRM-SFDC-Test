/****
* Story Number      Date        Owner                        Description
***********************************************************************************************
*  SFSE-9733        19/01/2023    Bharti&Aditi            Code Created
*/

@isTest
public class Batch_Escalation_Approval_SchedulerTest {
    
    @testSetup static void setup() {
        String MSLconObj1Email = Label.ContactIdForEsclationRecord;
        User RunUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        TriggerExecutionController.skipAllTriggers(true);
        Account ClientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Contact cont = new Contact();
        cont.AccountId = ClientAccount.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = MSLconObj1Email;
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert cont;
        List<Approval_Process_Escalation_Matrix__c> appList = new List<Approval_Process_Escalation_Matrix__c>();
        Approval_Process_Escalation_Matrix__c apm1 = new  Approval_Process_Escalation_Matrix__c();
        apm1.Area_code__c ='UKI';
        apm1.Gate_Name__c = 'Qualification';
        apm1.Process_Name__c ='Qualification Gate Products LL';
        apm1.Product_for_approval__c = '4PL,SCM,CCL,CS,WD,ECM';
        apm1.Current_owner__c = userInfo.getUserId();
        apm1.Escalation_owner__c = userInfo.getUserId();
        appList.add(apm1);
        Approval_Process_Escalation_Matrix__c apm2 = new  Approval_Process_Escalation_Matrix__c();
        apm2.Area_code__c ='UKI';
        apm2.Gate_Name__c = 'Qualification';
        apm2.Process_Name__c ='Pre-Win Gate Finance LL CCL ECM';
        apm2.Product_for_approval__c = '4PL,SCM,CCL,CS,WD,ECM';
        apm2.Current_owner__c = userInfo.getUserId();
        apm2.Escalation_owner__c = userInfo.getUserId();
        appList.add(apm2);
        insert appList;
        Opportunity mslOppty =TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        mslOppty.Approval_Status__c = 'Approved - Pre-Win Gate';
        update mslOppty;
        TriggerExecutionController.skipAllTriggers(false);
        List<Product2> lstProd = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        List<Product2> lstProd1 = DataGeneratorHelper1_Test.createProduct2( 1,'AB','DE','Lead Logistics');
        lstProd1[0].IsActive = true;
        update lstProd1;
        
        ScheduleOppProducts.OpportunityfromClone = false;
        
        List<PriceBookEntry> pbEntry = [select Id from PriceBookEntry where Product2Id =:lstProd[0].Id OR Product2Id =:lstProd1[0].Id ];
        //List<PriceBookEntry> pbEntry2 = [select Id from PriceBookEntry where Product2Id =:lstProd1[0].Id  ];
        
        Map<String, string> GeoMap = new Map<String, String>();
        GeoMap.put( 'TESTCOUNTRY', 'Country' );
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography( GeoMap );
        
        //OpportunityLineItem Oli1 = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry[0].Id );
        //OpportunityLineItem Oli2 = DataGeneratorHelper1_Test.createOpportunityLineItemWithCountry( mslOppty.Id, pbEntry[1].Id, geoList[0].Id );
        User testMSLIntgrationUser = UserDataGeneratorHelper_Test.MSLIntegrationUser;
        List<OpportunityTeamMember> oppMbrList= DataGeneratorHelper2_Test.createOppTeamMembr( 2, testMSLIntgrationUser, mslOppty.Id, 'Client Program Director', true );
    }
    
    @isTest
    static void test_BatchOfApprovalScheduler(){
        Test.StartTest();
        Batch_Escalation_Approval_Scheduler testsche = new Batch_Escalation_Approval_Scheduler();
        String sch = '0 0 12 1/1 * ? *';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }

}