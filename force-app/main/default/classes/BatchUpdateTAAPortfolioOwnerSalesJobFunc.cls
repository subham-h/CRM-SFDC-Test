/**
* -------------------------------------------------------------------------------------------------------------------------------------------------------
* Rev  Story       Name            Date                Comments
* 1. SFSE-12445   Bharti           20/09/2023          Batch created to update TAA's Portfolio_Owner_Sales_Job_Function__c field whenever
                                                       Sales_Job_function field of user record is updated .  
**/


public class BatchUpdateTAAPortfolioOwnerSalesJobFunc implements Database.Batchable<SObject>, Database.Stateful {
    public Set<Id> updatedUserId = new Set<Id>();
    public Map<Id,String> mapUserToSalesJobFunction = new map<Id,String>();
    public Set<Id> setTerrId = new Set<id>();
    public List<Territory_Account_Association__c> lstOftaaToUpdate =  new List<Territory_Account_Association__c>();
    
    public BatchUpdateTAAPortfolioOwnerSalesJobFunc (Set<Id> userId, Map<Id,String> mapUserSalesJobFunction,set<Id> terrIds) {
        this.updatedUserId = userId;
        this.mapUserToSalesJobFunction = mapUserSalesJobFunction;
        this.setTerrId = terrIds;
    }
    
    public Database.QueryLocator start( Database.BatchableContext BC ){
        String query = 'SELECT id ,End_Date__c,Portfolio_Owner_Sales_Job_Function__c,Territory__c,Territory__r.Portfolio_Owner__c from Territory_Account_Association__c ' +
            'WHERE Territory__c IN :setTerrId And (End_Date__c = null Or End_Date__c >= TODAY)' ;
        System.debug('query' + query );
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext info, List<Territory_Account_Association__c> lstTAA) {
        try{
        If(!lstTAA.isEmpty()){
            For(Territory_Account_Association__c terr : lstTAA){
                
                if(mapUserToSalesJobFunction.containsKey(terr.Territory__r.Portfolio_Owner__c)){
                    terr.Portfolio_Owner_Sales_Job_Function__c = mapUserToSalesJobFunction.get(terr.Territory__r.Portfolio_Owner__c);
                    lstOftaaToUpdate.add(terr);
                    
                }
            }
        }
        
        
        if (!lstOftaaToUpdate.isEmpty()) {
            
            Database.SaveResult[] updateResults = Database.update(lstOftaaToUpdate, True);
            ErrorLogger.writeErrors('SFDC', 'Territory_Account_Association', 'BatchUpdateTAAPortfolioOwnerSalesJobFunc', updateResults, lstOftaaToUpdate ); }
        }catch (Exception e) {
        
        ErrorLogger.writeErrors( 'SFDC', 'Territory_Account_Association', 'BatchUpdateTAAPortfolioOwnerSalesJobFunc', new list<Exception>{e});
    }
        
    }
    public void finish( Database.BatchableContext BC ) {}
}