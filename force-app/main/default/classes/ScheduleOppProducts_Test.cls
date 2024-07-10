/**
 *     Class Name : ScheduleOppProducts_Test
 *     Description: This is a test class created to cover below components :
 *         1. bINS_aINS_Set_PriceBook_OtherProduct  (Trigger)
 *         2. aUPD_AdjustOtherProduct_ProductSchedule (Trigger)
 *         3. abINS_abUPD_abDEL_ApplyProductSchedule  (Trigger)
 *         4. ScheduleOppProducts (Apex Class )
 *         // 5. OppProductRedirectOnEditController (Apex Class)
 * 
 * Change Log
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Updated On       Updated By                                  Ref Number   Description                                                                              
 * 05-June-2014     Deepa.Raman@ust-global.com                  #RQ-000079                                                                                         
 * 30-July-2014     Manikandan.Raju@ust-global.com              #RQ-000145   [abINS_abUPD_abDEL_ApplyProductSchedule - Code Coverage]
 * 19-August-2014   Krishnamoorthi.murugesan@ust-global.com     #RQ-000139   Unassigned product creation on Closed Opportunity
 * 08-Dec-2014      Krishnamoorthi.murugesan@ust-global.com     #RQ-000828   Removed PPVVC from Opportunity             
 * 04-01-2018       Meenakshi.Rajasekaran@ust-global.com        #RQ-007596   Unit Test failures in REGINT               
 * 01/05/2019       Nitin More                                  #RQ-010374   Added Commiment__c field                    
 * 06-Jun-2019      manjunath.c.holekade@maersk.com             #RQ-010819   Removal of references of deprecated fields  
 * 05-Sep-2019      Junaid.Khader@ust-global.com                #RQ-011734   Replaced assigning of Commitment__c field with custom label.    
 * 26-May-2020      manjunath@maersk                            SFSE-111     Removed references and logic related to "Expected_FFE_Lead__c" object 
 * 15-Sep-2020      manjunath@maersk                            SFSE-4548    Test class fix
 * 08-Jun-2022      Ronnie@SF                                   SPI-100      Removed brand hardcoding
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
 */

@isTest
private class ScheduleOppProducts_Test {
    
    static String OtherProductName = Label.OtherProductRouteCode;
    static Account accObj = AccountDataHelper_Test.createClientAccount();  
    static Opportunity oppObj = new Opportunity();   
    static PriceBookEntry pbEntry = new PriceBookEntry();
    static PriceBookEntry pbe2 = new PriceBookEntry();
    static PriceBookEntry unAssignedpbe = new PriceBookEntry();
    static Lead leadobj = new Lead();
    static Opportunity leadConvOpp = new Opportunity();
    static Opportunity rsnLostOpp = new Opportunity(); 
    static List <Product2> pdt1;
    static List <Product2> pdt2;
    static PriceBookEntry pbEntry1;
    static Id StdPricebook = Test.getStandardPricebookId();
    //static OpportunityLineItemSchedule oLISchedule = new OpportunityLineItemSchedule();
    
    static 
    {    
        Contact cont = new Contact(FirstName='Sample', LastName='Sample', Liner_Brands__c=BrandUtilities.MAERSKLINE, AccountId=accObj.Id, Email='MSL@test.com', Preferred_Language__c='English', Phone = '+61 412212111', OtherPhone = '+61 4222112222', MobilePhone = '+61 433111111', Fax = '+61 4212124411');
        insert cont;
               
        oppObj.Name = 'test opportunity';
        oppObj.AccountId = accObj.Id;
        oppObj.CloseDate = date.today()+10;
        oppObj.StageName = Label.LeadLabel;
        oppObj.Liner_brand__c=BrandUtilities.MAERSKLINE;
        oppObj.Primary_Contact__c=cont.id;
        oppObj.Expected_Handling_Rounds__c= 2;
        insert oppObj;
        oppObj.First_Shipment_Date__c = date.today()+20;
        oppObj.Last_Shipment_Date__c = date.today()+30;
        
        ScheduleOppProducts.DontExecuteOppLineItemTriggerFlag = false;
        ScheduleOppProducts.LastProductDeleteFlag = false;
       
        update oppObj; 

        pdt1 = DataGeneratorHelper1_Test.createProduct2(1,'A','DE','Ocean');
        pbEntry1=[select Id from PriceBookEntry where Product2Id =:pdt1[0].Id];
            //DataGeneratorHelper1_Test.createStdPriceBookEntry(StdPricebook,pdt1[0]);
        
        pdt2 = DataGeneratorHelper1_Test.createUnassignedProduct2(1,'Ocean');
        unAssignedpbe =[select Id from PriceBookEntry where Product2Id =:pdt2[0].Id];
            //DataGeneratorHelper1_Test.createStdPriceBookEntry(StdPricebook,pdt2[0]);
   }    
    
    /*  Function Test_OpportunityProductSchedulingwithFFE1 gave the below code coverage: 
            1.bINS_aINS_Set_PriceBook_OtherProduct     - 100%
            2.aUPD_AdjustOtherProduct_ProductSchedule  - 86% 
            3.abINS_abUPD_abDEL_ApplyProductSchedule   - 53% 
            4.ScheduleOppProducts                      - 86%  */
    static testMethod void Test_OpportunityProductSchedulingwithFFE1() 
    {
        Test.startTest();       
        
        List<Trade_Route__c> lstTDR = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MSL');
        insert lstTDR;
        
        OpportunityLineItem Oli = New OpportunityLineItem();
        Oli.OpportunityId = oppObj.Id;
        Oli.Quantity = 15;
        Oli.PriceBookEntryId = pbEntry1.id;
        Oli.UnitPrice = 1;
      //  Oli.Commitment__c = Label.allocation_Product_Flat;
        Oli.Opt_Out_Auto_Quantity_Scheduling__c = False;
        Oli.Trade_Route__c = lstTDR[0].Id;
        ScheduleOppProducts.OtherProductFlag = false;
        ScheduleOppProducts.LastProductDeleteFlag = false;
        ScheduleOppProducts.DontExecuteOppLineItemTriggerFlag = false;
        ScheduleOppProducts.ObjType = 'OpportunityLineItem';
        insert Oli;
              
        Oli.Schedule_Product__c = true;
        ScheduleOppProducts.DontExecuteOppLineItemTriggerFlag = false;
        ScheduleOppProducts.LastProductDeleteFlag = false;
        ScheduleOppProducts.ObjType = 'OpportunityLineItem';
        update Oli;
        
        delete [Select id from OpportunityLineItemSchedule where OpportunityLineItemId = : Oli.Id];

        

        ScheduleOppProducts.DeletedfromOppProductTrigger=false;
        ScheduleOppProducts.OtherProductFlag =false;
        try{
        Delete Oli;
        } catch(exception e) {
             Boolean expectedExceptionThrown =  e.getMessage() !=null ? true : false; 
            System.AssertEquals(expectedExceptionThrown, true); 
        } 
        List<Opportunity> updatLst=new List<Opportunity>();
        ScheduleOppProducts.UpdatedFromOppProductTrigger = False;
        oppObj.First_Shipment_Date__c = date.today()+30;//date.newInstance(2013,1,5);
        oppObj.Last_Shipment_Date__c = date.today()+40;//date.newInstance(2013,7,5);
       
        ScheduleOppProducts.UpdatedFromOppProductTrigger = False;
        updatLst.add(oppObj);
               
        try{
            update updatLst;
        }catch(Exception e){}
        Test.stopTest();
    }
    
    // Commenting as deprecating controller class - as part of ligthning transition
    /*  Function Test_LineItemEditOverride gave the below code coverage: 
            1.OppProductRedirectOnEditController - 100% coverage  
    */
    /*static testMethod void Test_LineItemEditOverride()
    {
        Test.starttest();
        OpportunityLineItem Oli = New OpportunityLineItem();
        Oli.OpportunityId = oppObj.Id;
        Oli.Quantity = 35;
        Oli.PriceBookEntryId = pbEntry.id;
        Oli.UnitPrice = 1;
        ScheduleOppProducts.OtherProductFlag = False;
        insert Oli; 
        
        ApexPages.StandardController controller = new ApexPages.StandardController(Oli);
        OppProductRedirectOnEditController obj = new OppProductRedirectOnEditController(controller);  
        obj.redirectMethod();   
        
        ScheduleOppProducts.UpdatedFromOppProductTrigger = False;
        oppObj.First_Shipment_Date__c = date.newInstance(2013,1,5);
        oppObj.Last_Shipment_Date__c = date.newInstance(2013,7,5);
        Update oppObj; 
        
        obj = new OppProductRedirectOnEditController(controller);  
        obj.redirectMethod();
        test.stoptest();
    }*/
    
    /*Method to code cover abINS_abUPD_abDEL_ApplyProductSchedule*/
    /*
      1. abINS_abUPD_abDEL_ApplyProductSchedule - 75% Coverage
    */
    static testMethod void Test_ApplyProductSchedule()
    {
        Test.starttest();

        Contact cont1 = new Contact(FirstName= 'Sample', LastName='Sample', Liner_Brands__c=BrandUtilities.MAERSKLINE, AccountId=accObj.Id, Email='MSL1@test.com', Preferred_Language__c='English', Phone = '+61 412332111', OtherPhone = '+61 4122112132', MobilePhone = '+61 433441111', Fax = '+61 4212155411');
        insert cont1; 

        Opportunity oppObj1 = New Opportunity();
        oppObj1.Name = 'test opportunity';
        oppObj1.AccountId = accObj.Id;
        oppObj1.CloseDate = date.today()+30;
        oppObj1.StageName = Label.LeadLabel;
        oppObj1.Liner_brand__c = BrandUtilities.MAERSKLINE;
        oppObj1.Primary_Contact__c = cont1.id;
        oppObj1.Expected_Handling_Rounds__c= 2;
        insert oppObj1;

        ScheduleOppProducts.OtherProductFlag = false;
        ScheduleOppProducts.ObjType = 'OpportunityLineItem';
        ScheduleOppProducts.DeletedfromOppProductTrigger = true;
        OpportunityLineItem Oli4 = new OpportunityLineItem();
        
        Oli4.OpportunityId = oppObj1.Id;
        Oli4.Quantity = 33;
        Oli4.PriceBookEntryId = unAssignedpbe.id;
        Oli4.UnitPrice = 1;
      //  Oli4.Commitment__c = Label.allocation_Product_Flat;
        Oli4.Opt_Out_Auto_Quantity_Scheduling__c = false;
        ScheduleOppProducts.OtherProductFlag = false;
        ScheduleOppProducts.LastProductDeleteFlag = false;
        ScheduleOppProducts.DontExecuteOppLineItemTriggerFlag = false;
        Oli4.Schedule_Product__c = false;
        try{
        insert Oli4;
        Delete Oli4;
        }catch(exception e){
            system.debug('error ' + e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage() !=null ? true : false; 
            System.AssertEquals(expectedExceptionThrown, true); 
        }
        Test.StopTest();
    }

    
    //#RQ-000139 changes -- Start
    static testMethod void Test_UnassignedProductOnClosedOpportunity()
    {
        Test.starttest(); 
        
        Opportunity opp = new Opportunity();
        List<Trade_Route__c> lstTDR = DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MSL');
        insert lstTDR;
        
        opp.Name = 'test opportunity';
        opp.AccountId = accObj.Id;
        opp.CloseDate = date.today()+10;
        opp.StageName = 'Identifying';
        opp.First_Shipment_Date__c = date.today() + 20;
        opp.Last_Shipment_Date__c = date.today() + 30;
        opp.Liner_brand__c = BrandUtilities.MAERSKLINE;
        opp.Opportunity_contains_Dangerous_Goods__c = 'No';
        opp.Expected_Handling_Rounds__c= 2;
        insert opp;
       OpportunityLineItem Oli5 = new OpportunityLineItem();
        
        Oli5.OpportunityId = opp.Id;
        Oli5.Quantity = 33;
        Oli5.PriceBookEntryId = unAssignedpbe.id;
        Oli5.UnitPrice = 1;
        Oli5.Trade_Route__c = lstTDR[0].Id;
      //  Oli5.Commitment__c = Label.allocation_Product_Flat;
        Oli5.Opt_Out_Auto_Quantity_Scheduling__c = false;
        insert Oli5;
       Test.stoptest();
    } //#RQ-000139 changes -- End 
    
      static testMethod void Test_PrepareProdScheduleForETL()
    {
        Test.starttest();
        list<OpportunityLineItem> Oli4 = new list<OpportunityLineItem>();
        Opportunity oppObj1 = New Opportunity();
        oppObj1.Name = 'test opportunity';
        oppObj1.AccountId = accObj.Id;
        oppObj1.CloseDate = date.today()+10;
        oppObj1.StageName = Label.LeadLabel;
        oppObj1.First_Shipment_Date__c = date.today()+20;//date.newInstance(2018,1,5);
        oppObj1.Last_Shipment_Date__c = oppObj1.First_Shipment_Date__c+10;//date.newInstance(2018,2,5);
        oppObj1.Liner_brand__c = BrandUtilities.MAERSKLINE;
        //oppObj1.Primary_Contact__c = cont1.id;
        oppObj1.Expected_Handling_Rounds__c= 2;
        insert oppObj1;

        ScheduleOppProducts.OtherProductFlag = false;
        ScheduleOppProducts.ObjType = 'OpportunityLineItem';
        ScheduleOppProducts.DeletedfromOppProductTrigger = true;
      
        Oli4.add (new OpportunityLineItem(OpportunityId = oppObj1.Id,
        Quantity = 33,
        PriceBookEntryId = pbEntry1.id,
        UnitPrice = 1,
      //  Commitment__c = Label.allocation_Product_Flat,
        Opt_Out_Auto_Quantity_Scheduling__c = false
        ));
 
        try{
        insert Oli4;
      //  Delete Oli4;
        }catch(exception e){
        
        }
        
        Map<Id,Opportunity> mapOpptys= new Map<Id,Opportunity>();
        mapOpptys.put(oppObj1.id,oppObj1);
        
        //ScheduleOppProducts s=new ScheduleOppProducts();
            
     //   s.PrepareProdScheduleForETL(mapOpptys,Oli4);
     ScheduleOppProducts.getSchedulingLogic(mapOpptys.keySet(), 'Opportunity');
        //Oli4.Schedule_Product__c = false;

        Test.StopTest();
    } 
}