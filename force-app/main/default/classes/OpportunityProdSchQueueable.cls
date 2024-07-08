/*      
* Revision      Ref Number      Date            Owner                       Description
* --------      ----------      -----------     -------------------         -------------------------
* 1.1                           5-JUNE-2023     Samar@Maersk                To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
*/
public class OpportunityProdSchQueueable implements Queueable {
    
    private List<Opportunity_Product_Schedule__c> lstOppProductSch;
    private List<OpportunityLineItemSchedule> lstOLISch;
    private String operation;
        
    
    public OpportunityProdSchQueueable(List<Opportunity_Product_Schedule__c> lstOppProductSch, List<OpportunityLineItemSchedule> lstOLISch , String operation){
                                                     this.lstOppProductSch = lstOppProductSch;
                                                     this.lstOLISch = lstOLISch;
                                                     this.operation = operation;
        
    }
    
    private List<Opportunity_Product__c> lstOppProduct;
    private List<OpportunityLineItem> lstOLI;
    public OpportunityProdSchQueueable(List<Opportunity_Product__c> lstOppProduct, List<OpportunityLineItem> lstOLI , String operation){
                                                     this.lstOppProduct = lstOppProduct;
                                                     this.lstOLI = lstOLI;
                                                     this.operation = operation;
        
    }
    
    public void execute(QueueableContext context) {
        try{
            if(operation =='DeleteScheduleDetailsOnCustomOLI' && !lstOppProductSch.isEmpty()){

                TriggerExecutionController.skipOpportunityProductTrigger(true);
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityTrigger(true);
                List<Database.DeleteResult> oliSchdlsDeleteResultList = Database.delete(lstOppProductSch, false ); 
                TriggerExecutionController.skipOpportunityProductTrigger(false);   
                TriggerExecutionController.skipopptyLineItemTrigger(false); 
                TriggerExecutionController.skipOpportunityTrigger(false);             
                ErrorLogger.writeErrors('SFDC', 'OpportunityProdSchQueueable', 'OpportunityProdSchQueueable.DeleteScheduleDetailsOnCustomOLI', oliSchdlsDeleteResultList, lstOppProductSch) ; 

            } else if(operation =='InsertScheduleDetailsOnCustomOLI' && !lstOppProductSch.isEmpty()){
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                List<Database.SaveResult> oliUpdateResultList=Database.insert(lstOppProductSch,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'OpportunityProdSchQueueable', 'OpportunityProdSchQueueable.InsertScheduleDetailsOnCustomOLI',  oliUpdateResultList, lstOppProductSch) ; 
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                TriggerExecutionController.skipOpportunityProductTrigger(false);

            } else if( operation =='DeleteScheduleDetailsOnOLI' && !lstOLISch.isEmpty()){

                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                List<Database.DeleteResult> oliSchdlsDeleteResultList = Database.delete(lstOLISch, false ); 
                TriggerExecutionController.skipopptyLineItemTrigger(false);  
                TriggerExecutionController.skipOpportunityProductTrigger(false);              
                ErrorLogger.writeErrors('SFDC', 'OpportunityProdSchQueueable', 'OpportunityProdSchQueueable.DeleteScheduleDetailsOnOLI', oliSchdlsDeleteResultList, lstOLISch) ;

            }else if (operation =='InsertScheduleDetailsOnOLI' && !lstOLISch.isEmpty()){
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                List<Database.SaveResult> oliUpdateResultList=Database.insert(lstOLISch,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  oliUpdateResultList, lstOLISch) ; // #RQ-005636
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                TriggerExecutionController.skipOpportunityProductTrigger(false);
            } 
            // Try for bug fix - Rama - SFSE-13321
            else if(operation =='UpdateScheduleDetailsOnCustomOLI' && !lstOppProductSch.isEmpty()){
                //Updating the Opportunity Product Schedules are recreated
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                List<Database.SaveResult> oliUpdateResultList=Database.update(lstOppProductSch,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'ScheduleOpportunityProducts.getSchedulingLogic',  oliUpdateResultList, lstOLISch) ; // #RQ-005636
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                TriggerExecutionController.skipOpportunityProductTrigger(false);
            } else if(operation =='UpdateCustomOpportunityProduct' && !lstOppProductSch.isEmpty()){
                //Updating the Opportunity Product after Opportunity Product Schedules are recreated
                List<Database.SaveResult> oliUpdateResultList=Database.update(lstOppProduct,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'ScheduleOpportunityProducts.getSchedulingLogic',  oliUpdateResultList, lstOLISch) ; // #RQ-005636
            }
            else if(operation =='UpdateScheduleDetailsOnOLI' && !lstOppProductSch.isEmpty()){
                //Updating the Opportunity Product Schedules are recreated
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                List<Database.SaveResult> oliUpdateResultList=Database.update(lstOppProductSch,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  oliUpdateResultList, lstOLISch) ; // #RQ-005636
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                TriggerExecutionController.skipOpportunityProductTrigger(false);
            } else if(operation =='UpdateOpportunityProduct' && !lstOppProductSch.isEmpty()){
                //Updating the Opportunity Product after Opportunity Product Schedules are recreated
                List<Database.SaveResult> oliUpdateResultList=Database.update(lstOppProduct,false);
                System.debug('oliUpdateResultList'+oliUpdateResultList);
                ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  oliUpdateResultList, lstOLISch) ; // #RQ-005636
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OpportunityProdSchQueueable', 'OpportunityProdSchQueueable.execute', new list<Exception>{ex});

        }
       
       
        
        
    }

}