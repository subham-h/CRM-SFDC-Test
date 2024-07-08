@isTest
public class UpdateOpportunityUnlockTest {
    
    @testSetup
    public static void setup(){
        
       Account clientAcc = AccountDataHelper_Test.createClientAccount();
       TriggerExecutionController.skipOpportunityTrigger(true);
        Opportunity oppTender = OpportunityDataGeneratorHelper_Test.createMSLTenderOpportunity(clientAcc.id, null);
        TriggerExecutionController.skipOpportunityTrigger(false);
         // Insert ocean products
        List<Product2> listOceanProducts = DataGeneratorHelper1_Test.createProduct2( 1,'A','DE','Ocean');
        List<Product2> listNonOceanProducts = DataGeneratorHelper1_Test.createProduct2( 1,'B','FE','Non Ocean');
        PriceBookEntry pbEntry = [SELECT Id from PriceBookEntry WHERE Product2Id = :listOceanProducts[0].Id];
        
       /* // Insert OpportunityLineItem for tender opportunity
        TriggerExecutionController.skipopptyLineItemTrigger(true);
        DataGeneratorHelper1_Test.createOpportunityLineItem(oppTender.Id, pbEntry.Id);
        TriggerExecutionController.skipopptyLineItemTrigger(false);*/
   } 
   static testmethod  void testAcount(){
        
        List<Opportunity>  con = [select id,name from Opportunity limit 1];
         Test.startTest();
         
        UpdateOpportunityUnlock ad = new UpdateOpportunityUnlock(con);
        UpdateOpportunityUnlock updater = new UpdateOpportunityUnlock(con);
        // startTest/stopTest block to force async processes to run
               System.enqueueJob(ad);
        ID jobID = System.enqueueJob(updater);
        Test.stopTest();       
        
    }
}