/**              
* Revision Ref Number    Date            Owner                   Description
* -------- ----------   -----------  -------------------   --------------------------------------------------------
* 1.0      SFSE-9685	10-Nov-2022	 shilpa.nagtode		   Add logic to handle change in quantity/revenue on OLI Schedule records
* 2.0	   SFSE-10220   01-Feb-2023  Aditi@Maersk		   Added Offer_Type__c field value

*/
@isTest
public class OppoLineItemSchTrigger_Test {
    
    @testSetup static void setup() {
        
        TriggerExecutionController.skipAllTriggers(true);
        Account ClientAccount = AccountDataHelper_Test.createClientAccount();
        
      
		Opportunity mslOppty = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity( ClientAccount.id, null);  
		TriggerExecutionController.skipAllTriggers(false);        
        Id StdPricebook = Test.getStandardPricebookId();       
		Product2 prod = TestBusinessHelper.createProduct('Ocean', true);       
        PriceBookEntry pbEntry = [select id FROM PriceBookEntry where Product2Id =: prod.Id];        
        OpportunityLineItem Oli = DataGeneratorHelper1_Test.createOpportunityLineItem( mslOppty.Id, pbEntry.Id ); // add product to opportunity
       
        List<Trade_Route__c> lstTradeRoute = TestBusinessHelper.createTradeRoutes(new List<String>{'MCC'}, 1,true);
        Opportunity_Product__c CusOli =  TestBusinessHelper.createOpportunityLineItemCustom(mslOppty, prod.Id,lstTradeRoute[0], true);
 		
    }
    
    static testmethod void TestOpptyLineItemSchedule(){  
        Test.StartTest();
        List<Opportunity> mslOppty = [SELECT ID, Stagename, Offer_Type__c FROM Opportunity Limit 1];
        mslOppty[0].Tender_Submission_Format__c = 'No Ocean Tender';
        mslOppty[0].StageName = 'Closed Won';
        //mslOppty[0].Offer_Type__c = 'Offer containing Standard T&Cs';
        update mslOppty;
        
        List<OpportunityLineItemSchedule> insertLst = new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemSchedule> Oshlst = [select id, Quantity, Revenue,ScheduleDate, OpportunityLineItemId from OpportunityLineItemSchedule];        
        for (OpportunityLineItemSchedule OppSch : Oshlst){
            OppSch.Quantity = 40;
        	OppSch.Revenue = 30000;
            OppSch.ScheduleDate = date.today() + 5;
            
            OpportunityLineItemSchedule oliS1 = OppSch.clone();
			insertLst.add(oliS1);
        }  
        
        try{
        	update Oshlst; 
        } catch (exception ex){
            system.debug('Exception on Update: ' + ex.getMessage());
        }
        
        try{
        	insert insertLst; 
        } catch (exception ex){
            system.debug('Exception on Insert: ' + ex.getMessage());
        }
        
        try{
        	delete Oshlst; 
        } catch (exception ex){
            system.debug('Exception on delete: ' + ex.getMessage());
        }
        Test.StopTest();        
    }         
  }