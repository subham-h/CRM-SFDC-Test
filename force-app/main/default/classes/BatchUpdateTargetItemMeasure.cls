/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      SFSE-11477  08-Nov-2023      Vinay      							Code created
 * 
*/
public class BatchUpdateTargetItemMeasure implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        
      List<Target_Setting_Batch_Query__mdt> listQuery = [ SELECT Query__c
                                                            FROM Target_Setting_Batch_Query__mdt
                                                            WHERE DeveloperName =:'Update_Credit_Eligibility']; 
       return Database.getQueryLocator(listQuery[0].Query__c); 
    }
    
    public void execute(Database.BatchableContext BC, List<Territory_Account_Association__c>scope){
     List<Territory_Account_Association__c> taaList = new list<Territory_Account_Association__c>();
        
        for(Territory_Account_Association__c taa: scope){                    
     		if((taa.Start_Date__c <= system.today() || taa.Start_Date__c>system.today())&& (taa.End_Date__c==NULL || taa.End_Date__c >= system.today())){
         	taaList.add(taa);}}  
        if(!taaList.isEmpty()){
           UpdateTargetItemMeasureUtility.updateCustomerPortfolioAssigned(taaList); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}