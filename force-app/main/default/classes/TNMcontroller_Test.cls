/**

* Test class for :TNMTenderController

* Version    Date          Modified By                                    Description
* 1.0        17/4/2017     ramadevi.palaniswamy@ust-global.com            Modified as a part of CluAp release 1
* 1.1        24/6/2019     Nitin@maersk                                   RQ-011062: Amended to fix unit test failure
* 2.0        14-Aug-2019   manjunath.c.holekade@maersk.com                RQ-011436 - Removal of "Customer_Rating__c" references
* 3.0        23-Dec-2019   manjunath.c.holekade@maersk.com                RQ-012367 - Remove references/logic related to "Rate__c" and "Rate_Guidance__c" of OpptyLineItem
* 4.0        15-Sep-2020   manjunath.c.holekade@maersk.com                SFSE-4548 - Test class fix
*/
@isTest
private class TNMcontroller_Test{
    
    
    @testSetup static void setup() {
        Date startDate = Date.today();
        Date endDate = startDate.addMonths(3);
        String nextSteps = 'test1';
        String clientGrp = 'Non KC';
        String scvCode='12345';
        
        
        TriggerExecutionController.skipAllTriggers(true);
        Account clientAcc = AccountDataHelper_Test.createClientAccount(); 
        clientAcc.scv_code__c = '111';
        clientAcc.Attractiveness__c ='Key Client';
        update clientAcc;
        Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( clientAcc.id, null);        
        TriggerExecutionController.skipAllTriggers(false);
        Id StdPricebook = Test.getStandardPricebookId();
        List<Product2> pdt1 = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        pdt1[0].isActive = true;
        update pdt1;
        Corridor_guidance__c cgd =  new Corridor_guidance__c();
        cgd.Opportunity__c = mslOppty.Id;
        insert cgd;
        
        Corridor_Guidance_Detail__c cgdetail1 =  new Corridor_Guidance_Detail__c();
        cgdetail1.Corridor_Guidance__c = cgd.Id;
        insert cgdetail1;
        //insert cdList;
        PriceBookEntry pbEntry = [select Id from PriceBookEntry where Product2Id =:pdt1[0].Id];
        OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id );
    //Oli.Trade_Guidance_Id__c = cgd.Id;
        
    }
    
    static testmethod void TestOpportunityCreation(){
        Test.startTest();
        list<String> routcodeList = new list<String>();
        TenderOLIResponse t = new TenderOLIResponse();
    List<Product2> pdt1 = [select Route_Direction_Code__c from Product2 LIMIT 1];
        routcodeList.add(pdt1[0].Route_Direction_Code__c  );
        Opportunity mslOppty = [select Expected_Tender_Receipt_Date__c, First_Round_Submission_Date__c, CloseDate from Opportunity LIMIT 1];
        mslOppty.Expected_Tender_Receipt_Date__c = Date.today() + 5;
        mslOppty.First_Round_Submission_Date__c = Date.today().addMonths(3) + 6;
        mslOppty.CloseDate =  Date.today().addMonths(1);
    mslOppty.First_Shipment_Date__c = mslOppty.CloseDate + 10;
    mslOppty.Last_Shipment_Date__c = mslOppty.CloseDate + 20;
        update mslOppty;
        PageReference pageRef = Page.tnmTender; 
        Test.setCurrentPage( pageRef );     
        List<TenderOLIResponse.wrapperOLI_Rating> oliList = new List<TenderOLIResponse.wrapperOLI_Rating> ();
        List<OpportunityLineItem> toSaveOli= new List<OpportunityLineItem> ();       
        oliList  = TNMTenderController.getOLIExtracts1(routcodeList, '', '',Null,Null,Null,Null,Null,Null,false);        
        system.debug('oliList'+oliList);
        for (TenderOLIResponse.wrapperOLI_Rating wrapperOli: oliList ) {
            toSaveOli.add(wrapperOli.optylineItem);            
        }
        Boolean blnSaveResult = TNMTenderController.saveResults(toSaveOli);
        TNMTenderController.getOLIExtracts1(routcodeList, string.valueOfGmt(Date.today()), string.valueOfGmt(Date.today().addMonths(3)),'test1','Non KC','12345',Null,0,1000000,false);
        Test.stopTest();
        System.assertNotEquals(0, oliList.size());
        System.assertEquals(true, blnSaveResult);
    }
    
    static testmethod void TestOpportunityCreation_withNext100(){
        Test.startTest();
        list<String> routcodeList = new list<String>();
        /*Account clientAcc = [select Attractiveness__c from Account LIMIT 1];
        TriggerExecutionController.skipAllTriggers(true);
        clientAcc.Attractiveness__c = 'Key Client-MSL';
        update clientAcc;*/      
        Opportunity mslOppty = [select CloseDate from Opportunity LIMIT 1];
        mslOppty.CloseDate = date.today().addMonths(1);    
    mslOppty.First_Shipment_Date__c = mslOppty.CloseDate + 10;
    mslOppty.Last_Shipment_Date__c = mslOppty.CloseDate + 20;
       // mslOppty.Next_Steps__c = 'Agree targets';
        
        update mslOppty;
        List<Product2> pdt1 = [Select Route_Direction_Code__c from Product2 LIMIT 1];     
        routcodeList.add(pdt1[0].Route_Direction_Code__c  );
        
        PageReference pageRef = Page.tnmTender; 
        Test.setCurrentPage( pageRef );        
       
        List<TenderOLIResponse.wrapperOLI_Rating> oliList = new List<TenderOLIResponse.wrapperOLI_Rating> ();
        List<OpportunityLineItem> toSaveOli= new List<OpportunityLineItem> ();
        
        oliList  = TNMTenderController.getOLIExtracts1(routcodeList, '', '',Null,Null,Null,Null,Null,Null,true); 
        system.debug('AAoliList'+oliList);
        for (TenderOLIResponse.wrapperOLI_Rating wrapperOli: oliList ) {
            toSaveOli.add(wrapperOli.optylineItem);            
        }
        Boolean blnSaveResult_withNext100 = TNMTenderController.saveResults(toSaveOli);
        TNMTenderController.getOLIExtracts1(routcodeList, string.valueOfGmt(Date.today()), string.valueOfGmt(Date.today().addMonths(3)),'test1','Non KC','12345',Null,0,1000000,false);
        Test.stopTest();

        //System.assertNotEquals(0, oliList.size());
       // System.assertEquals(true, blnSaveResult_withNext100);
    }
}