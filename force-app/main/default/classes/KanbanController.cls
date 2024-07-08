/*
* Revision Ref Number  Date             Owner                                Description
* -------- ----------  -----------    -------------------                 -------------------------
* 1.0       SFSE-12515  25-11-23     Aleena & Jothsana                   Class to handle all logic for 'The Plan' - Listview and kanbanview
*/
public with sharing class KanbanController{
    @AuraEnabled
    public static Wrapper getRelatedRecords(String parentField, String parentId, String objectName, String fieldName, String fieldsToFetch){
        
        Wrapper wrapperResponse = new Wrapper();
        
        String query = 'SELECT Id, ';
        query = query + fieldsToFetch + ' FROM ' + objectName + ' WHERE ' + parentField + '=:parentId AND Archived__c = false';
        System.debug('query ' + query);
        
        List<Sobject> relatedRecords = Database.query(query);
        System.debug('relatedRecords ' + relatedRecords.size());
        
        List<Action__c> actions = (List<Action__c>)relatedRecords;
        System.debug('actions ' + actions.size());
        
        wrapperResponse.relatedRecords = relatedRecords;
        
        Map<String, Integer> stageNameMap = new Map<String, Integer>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            if (!stageNameMap.containsKey(pickListVal.getValue())){
                stageNameMap.put(pickListVal.getValue(), 0);
            }
        }
        for (Action__c action : actions){
            if (stageNameMap.containsKey(action.Priority__c)){
                Integer count = 0;
                count = stageNameMap.get(action.Priority__c);
                stageNameMap.put(action.Priority__c, ++count);
            }
        }
        List<StageObject> pickValList = new List<StageObject>();
        for (String stage : stageNameMap.keySet()){
            StageObject pickVal = new StageObject();
            pickVal.stage = stage;
            pickVal.noRecords = stageNameMap.get(stage);
            pickValList.add(pickVal);
        }
        wrapperResponse.pickVals = pickValList;
        
        return wrapperResponse;
    }
    
    @AuraEnabled
    public static Wrapper updateRecord(String recordId, String status, String fieldName){
        try{
            // Update the record
            Action__c updatedAction = new Action__c(
                Id = recordId
            );
            if (fieldName == 'Priority__c'){
                updatedAction.Priority__c = status;
            } else if (fieldName == 'Status__c'){
                updatedAction.Status__c = status;
            }
            system.debug(updatedAction.Priority__c);
            system.debug(updatedAction.Status__c);
            
            update updatedAction;
            
            // Return the updated records
            return getRelatedRecords('Account_Plan__c', updatedAction.Account_Plan__c, 'Action__c', 'Priority__c', 'Name,Account_Plan__c,Status__c,Priority__c');
        } catch (Exception e){
            System.debug('Error updating record: ' + e.getMessage());
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createRecord(String objectApiName, Map<String, Object> fields){
        SObject newRecord = Schema.getGlobalDescribe().get(objectApiName).newSObject();
        
        for (String fieldName : fields.keySet()){
            newRecord.put(fieldName, fields.get(fieldName));
        }
        
        try{
            insert newRecord;
            return newRecord.Id;
        } catch (Exception e){
            throw new AuraHandledException('Error creating record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getPicklistValues(){
        List<String> picklistValues = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Action__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p : ple){
            picklistValues.add(p.getLabel());
        }
        
        return picklistValues;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Business_Plan__c> getAccountPlans(){
        return [SELECT Id, Name
                FROM Business_Plan__c];
    }
    
    public class Wrapper{
        @AuraEnabled
        public List<Sobject> relatedRecords = new List<Sobject>();
        @AuraEnabled
        public List<StageObject> pickVals = new List<StageObject>();
    }
    
    public class StageObject{
        @AuraEnabled
        public String stage = '';
        @AuraEnabled
        public Integer noRecords = 0;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Action__c> ActionList(String parentId){
        List<Action__c> lstActions = [select id, name, Goals__c, Goals__r.Name, Priority__c, Status__c, Due_Date__c, Account_Plan__c, Account_Plan__r.Name,Timeline__c,OwnerId,Owner.Name
                                      from Action__c
                                      where Account_Plan__c = :parentId and Archived__c = false];
        system.debug(lstActions);
        return lstActions;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Focus_Area__c> GoalList(String parentId){
        List<Focus_Area__c> lstGoals = [select id, Name, TFC_Value_Driver__c, Account_Plan__c, Right_to_Win__c, Account_Plan__r.Name
                                        from Focus_Area__c
                                        where Account_Plan__c = :parentId and Archived__c=false];
        system.debug(lstGoals);
        return lstGoals;
    }
    
    @AuraEnabled(cacheable = true)
    public static list<Action__c> ActionunderGoal(String parentId){
        List<Action__c> lstofActionwithGoals = new List<Action__c>();
        List<Action__c> lstofAction = [Select id, name, Goals__c, Goals__r.Name, Priority__c, Status__c, Due_Date__c,Account_Plan__c, Account_Plan__r.Name,Timeline__c,OwnerId,Owner.Name
                                       from Action__c
                                       where id = :parentId];
        if (!lstofAction.isEmpty() && lstofAction[0].Goals__c != null){
            lstofActionwithGoals = [SELECT Id, Name, Goals__c, Goals__r.Name, Priority__c, Status__c, Due_Date__c,Account_Plan__c, Account_Plan__r.Name,Timeline__c,OwnerId,Owner.Name
                                    FROM Action__c
                                    WHERE Goals__c = :lstofAction[0].Goals__c and Archived__c = false];
        }
        return lstofActionwithGoals;
    }
    
    @AuraEnabled
    public static void deleteRecord(String ObjectapiName, String recordId){
        try{
            system.debug('ObjectapiName'+ObjectapiName);
            system.debug('recordId'+recordId);
            if (ObjectapiName == 'Action__c'){
                delete new Action__c(
                    Id = recordId
                );
            } else if (ObjectapiName == 'Focus_Area__c'){
                delete new Focus_Area__c(
                    Id = recordId
                );
            }
        } catch (Exception e){
            throw new AuraHandledException('Error deleting record: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateActionRecord(String recordId, Map<String, Object> fields) {
        try {
            system.debug('recoed id'+ recordId);
            // Update the record
            Action__c updatedAction = new Action__c(Id = recordId);
            
            // Set updated fields
            for (String fieldName : fields.keySet()) {
                updatedAction.put(fieldName, fields.get(fieldName));
            }
            
            update updatedAction;
            
            // Return the updated records
           
        } catch (Exception e) {
            system.debug('entered in apex class');
            System.debug('Error updating record: ' + e.getMessage());
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }
    
}