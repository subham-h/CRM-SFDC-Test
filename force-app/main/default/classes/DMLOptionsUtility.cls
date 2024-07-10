/*
* Author   : Nirmal@UST
* Purpose  : Generic class which will set DML Options and update the passed sObject.
* 
* Revision Ref Number  Date            Owner                       Description
* -------- ----------  ----------- -------------------     -----------------------------------------------------
* 1.0      #RQ-003805  15-Dec-2016     Nirmal@UST          Trigger assignment rules and auto response rules for the portal created cases.
*/


public class DMLOptionsUtility {
	
    Database.DMLOptions dmlOption;
    set<Id> setSObjectIds;
    
    public DMLOptionsUtility(set<Id> setSObjectIds, Database.DMLOptions dmlOption) {
        this.dmlOption = dmlOption;
        this.setSObjectIds = setSObjectIds;
        DMLOptionsUtilityMethod();
    }
    
    public void DMLOptionsUtilityMethod(){
        list<SObject> lstSObjects = new list<SObject>();
        for(Id idIterator : setSObjectIds) {
            lstSObjects.add(idIterator.getSObjectType().newSObject(idIterator));
        }              
        TriggerExecutionController.skipAllTriggers(true);
        Database.update(lstSObjects, dmlOption);
        TriggerExecutionController.skipAllTriggers(false); 
    }
    
}