/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Database.executeBatch(new TempOpportunityProductSchedule(), 30);
**/
public class TempOpportunityProductSchedule implements Database.Batchable<SObject> {
    
    

    public Database.QueryLocator start( Database.BatchableContext bc ){
        String soqlQuery = '';
        soqlQuery += 'SELECT id, Product_Revenue_Per_Unit__c  FROM Opportunity_Product__c WHERE Product_Revenue_Per_Unit__c != null '; 
        return Database.getQueryLocator(soqlQuery);
    }

    public void execute( Database.BatchableContext bc,  List<Opportunity_Product__c> scope ){
        Map<Id,Decimal> mapOfProdIdAndRevenue = new  Map<Id,Decimal>();
        List<Opportunity_Product_Schedule__c> lstSch= new List<Opportunity_Product_Schedule__c>();

        TriggerExecutionController.skipOpportunityProductSchedule(true);
        TriggerExecutionController.skipOpportunityProductTrigger(true);
        TriggerExecutionController.skipOpportunityTrigger(true);
        try{
            for(Opportunity_Product__c prod: scope){
               if(prod.Product_Revenue_Per_Unit__c!= null){
                mapOfProdIdAndRevenue.put(prod.Id, prod.Product_Revenue_Per_Unit__c);
                }
           }

           if(!mapOfProdIdAndRevenue.keySet().isEmpty()){
                for(Opportunity_Product_Schedule__c sch:[SELECT id,Revenue__c, Quantity__c, Schedule_Date__c,Opportunity_Product__c, Schedule_Revenue__c FROM Opportunity_Product_Schedule__c WHERE Opportunity_Product__c  IN : mapOfProdIdAndRevenue.keySet()  AND Quantity__c != null AND Schedule_Revenue__c = null]){
                    sch.Schedule_Revenue__c =  sch.Quantity__c != null && mapOfProdIdAndRevenue.containskey(sch.Opportunity_Product__c) ? sch.Quantity__c * mapOfProdIdAndRevenue.get(sch.Opportunity_Product__c):null;
                    lstSch.add(sch);
                }
           }

           if(!lstSch.isEmpty()){
                List<Database.SaveResult> results  = Database.update(lstSch,false);
                ErrorLogger.writeErrors('SFDC', 'TempOpportunityProductSchedule', 'TempOpportunityProductSchedule.execute()', results  , lstSch);
           }    
            TriggerExecutionController.skipOpportunityProductSchedule(false);
            TriggerExecutionController.skipOpportunityProductTrigger(false);
            TriggerExecutionController.skipOpportunityTrigger(false);
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'TempOpportunityProductSchedule', 'TempOpportunityProductSchedule', new list<Exception>{ex});
        }
    }


    public void finish( Database.BatchableContext bc ) {
        
    }
}