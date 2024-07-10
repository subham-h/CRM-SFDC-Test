/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		06-Apr-2023		Bharti rana				Mass Delete TAAs from List views.
*/


public class TAAMassDeleteCntrl {
    @AuraEnabled (cacheable=false)
    public static projectResponseWrapper massDeleteAction(List<String> lstOfTAA) {
        
        List<Territory_Account_Association__c> lstOfTerritory = [Select Territory__c,Account__c, Territory__r.Name, Name, Account__r.Name,Portfolio_Owner_Responsibility__c,Product_Responsibility__c
                                                                 from Territory_Account_Association__c where id IN :lstOfTAA ];
        
        projectResponseWrapper resWrapper = new projectResponseWrapper();
        
        
        Database.deleteResult[] deleteResults = Database.delete(lstOfTerritory, false);
        
        List<Id> successIds = new List<Id>();
        for(Integer i = 0; i <lstOfTerritory.size(); i++){
            Database.deleteResult result = deleteResults[i];
            
            string errorMsg = '';
            
            if(result.isSuccess()){
                 successIds.add(result.getId());
                
            }
            else{
                resWrapper.errorMsg = result.getErrors().toString();
            }
        }
        resWrapper.successRecordSize =  successIds.size();
       
        
        
        return resWrapper;
        
    }
    public class projectResponseWrapper{
        
        @AuraEnabled public  Integer successRecordSize						{get;set;}
        @AuraEnabled public String errorMsg                                 {get;set;}    
        
    }
    
    
}