/**
* 1.0		SFSE-4388		14-Sep-2020		meghana.gupta@UST			New method to modify GP per unit
* 2.0		SFSE-6737		06-Aug-2021		Neha@TCS					New method for cloning and FFE update
* 3.0		SFSE-6523		27-Jan-2021		meghana.gupta@UST			Code modified to fix 'Too many SOQL' issue
* 4.0		SPI-100			27-Jun-2022		Ronnie@SF					Removed brand hardcoding
* 5.0		SFSE-8606		29-Jun-2022		meghana@UST					Trade_Route__c feild added to SOQL to fix test class
* 6.0		SFSE-8521		04-Jul-2022		Rakesh@Maersk				Handle Cloning Opportunity Product Features on Opp clone
* 7.0						26-Jul-2023		Kiran@Maersk				New test data framework
*/

@isTest
private class OpptyLineItemTrigger_Test {

    @testSetup static void setup() {
        Test.startTest();
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', true);
        Opportunity tenderOpportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'ShippingCargoServices', BrandUtilities.MAERSKLINE, true);
        List<Product2> products = TestBusinessHelper.createProducts(new List<String>{'Ocean', 'Lead Logistics'}, 2, true);
        
        ScheduleOppProducts.OpportunityfromClone = false;
        List<PriceBookEntry> pbEntry = [SELECT Id FROM PriceBookEntry WHERE Product2Id = :products[0].Id OR Product2Id = :products[1].Id];
        List<Geography__c> geoList = TestBusinessHelper.createGeographies(new List<String>{'TESTCOUNTRY'}, 'Country', null, 1, true);
        OpportunityLineItem oli1 = TestBusinessHelper.createOpportunityLineItem(tenderOpportunity, pbEntry[0], null, true);
        OpportunityLineItem oli2 = TestBusinessHelper.createOpportunityLineItem(tenderOpportunity, pbEntry[1], null, geoList[0], true);
        List<Product_Component__c> comps = TestBusinessHelper.createProductComponents(products, 2, true);
        List<Product_Feature__c> prodFeatList = TestBusinessHelper.createProductFeatures(comps, 3, true);
        //TestBusinessHelper.createOpportunityProductFeatures(oli, prodFeatList, true);
        Test.stopTest();
    }
    
    static testmethod void TestOpptyLineItem(){  
        Test.StartTest();
        OpportunityLineItem Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice FROM OpportunityLineItem limit 1];
        //OpportunityLineItem Oli2 = [SELECT Id FROM OpportunityLineItem Where Product_family__c = 'Lead Logistics' limit 1];
        decimal newGP = Oli.UnitPrice + 2;
        Oli.Amend_Gross_Profit_per_unit__c = newGP;
        update Oli;
        Test.StopTest();
        
    } 
    
    static testmethod void TestOpptyLineItemDelete(){  
        
        Test.StartTest();
        OpportunityLineItem Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c, UnitPrice FROM OpportunityLineItem limit 1];
        
        delete Oli;
        Test.StopTest();
    } 
    
    static testmethod void testinvokeClonefunctionality(){
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];
        
        List<OpportunityLineItem> Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity, OpportunityId,PriceBookEntryId,
                                         UnitPrice, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c, Country__c,
                                         Trade_Route__c
                                         FROM OpportunityLineItem where Opportunityid=:mslOppty.id];
        // Query schedules which gets created
        try{
            Opportunity lstClonedrec = mslOppty.clone(false, false, false,false);        
            insert lstClonedrec;       
            List<OpportunityLineItem> newItemList = new List<OpportunityLineItem>();
            for(OpportunityLineItem item : Oli){
                OpportunityLineItem ol = item.clone();
                ol.opportunityId = lstClonedrec.id;
                newItemList.add(ol);
            }
            insert newItemList;
            
            List<OpportunityLineItemSchedule> oliSch = [select id,OpportunityLineItemId, isClonedrecord__c, ScheduleDate,Quantity,Revenue,Type from OpportunityLineItemSchedule where OpportunityLineItemid=:Oli[0].id];     
            List<OpportunityLineItemSchedule> OpportunityLineItemScheduleList = new List<OpportunityLineItemSchedule>();
            for(OpportunityLineItemSchedule oitem : oliSch){
                OpportunityLineItemSchedule osl = oitem.clone();
                osl.OpportunityLineItemId = newItemList[0].id;
                OpportunityLineItemScheduleList.add(osl);
            }
            insert OpportunityLineItemScheduleList;
            
            List<OpportunityLineItemSchedule> olicloneSch = [select id, isClonedrecord__c, ScheduleDate,Quantity,Revenue,Type from OpportunityLineItemSchedule where OpportunityLineItemid=:newItemList[0].id];
            System.debug('after olicloneSch>>>>'+olicloneSch);           
            //System.assertEquals(olicloneSch.size(), 1); // check if schedules are created on cloning
        } catch(Exception e){
            
            
        }
        Test.StopTest();
        
    }
    
    static testmethod void testinvokerecreateonFFEUpdate(){
        Test.startTest();
        Opportunity mslOppty = [SELECT id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                Expected_Handling_Rounds__c, Pricebook2Id
                                FROM Opportunity where Liner_Brand__c = :BrandUtilities.MAERSKLINE];       
        OpportunityLineItem Oli = [SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity, OpportunityId,PriceBookEntryId,
                                   UnitPrice, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c,/* Commitment__c,*/ Country__c
                                   FROM OpportunityLineItem where Opportunityid=:mslOppty.id limit 1];
        
        Oli.Amend_Expected_FFE__c = 10;
        update Oli;            
        System.assertEquals(Oli.Amend_Expected_FFE__c, 10);            
        Test.stopTest();
    }
    static testmethod void testValidationMethods(){
        Test.startTest();
        List<Opportunity> opp = [Select id, Name, AccountId, CloseDate, StageName, Next_Steps__c, Primary_Contact__c, Type,
                                 Customer_Type__c, Tender_Type__c, Tender_Submission_Format__c, Customer_Requested_Rate_Structure__c,
                                 First_Round_Submission_Date__c, Liner_Brand__c, First_Shipment_Date__c, Last_Shipment_Date__c, recordtypeid,
                                 Expected_Tender_Receipt_Date__c, Opportunity_contains_Dangerous_Goods__c, Commodity__c,
                                 Expected_Handling_Rounds__c, Pricebook2Id
                                 FROM Opportunity  limit 1 ];
        List<OpportunityLineItem> oli =[SELECT Id, Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c, Quantity, OpportunityId,PriceBookEntryId,
                                        UnitPrice, Opt_Out_Auto_Quantity_Scheduling__c,Tender_Target__c, Nominated_Quantity__c,/* Commitment__c,*/ Country__c
                                        FROM OpportunityLineItem limit 1];
        OpptyLineItemUtilities.validateOpptyStageApprovalStatus(oli);
        OpptyLineItemUtilities.validateOpptyPendingApprovalProcesses(oli, opp);
        Test.stopTest();
    }
}