/*
* Author    : Raksha
* Purpose   : Leverage Case Sharing into Archived Case object once the Cases are archived. 
* NOTE      : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0       SC-4508     10-Jan-2023 Raksha@Maersk           Case record sharing once created/Updated
*/
public class ArchivedCaseTriggerHandler extends TriggerHandler {
    public map<Id, Archived_Case__c> newMap;
    public map<Id, Archived_Case__c> oldMap;
    public ArchivedCaseTriggerHandler() {
        this.newMap = (map<Id, Archived_Case__c>)Trigger.newMap;
        this.oldMap = (map<Id, Archived_Case__c>)Trigger.oldMap; 
    }
    
    public ArchivedCaseRecordSelector archCaseRecordSelector;
      
      public override void getRecordSelector() {
        archCaseRecordSelector = new ArchivedCaseRecordSelector(Trigger.new, this.oldMap, this);
      }
      
      //apex based sharing for 4PL case after insert
      public override void onAfterInsert() {
        if(!archCaseRecordSelector.set4PLCaseIds.isEmpty()){           
            ApexSharingUtility.updateSharing(archCaseRecordSelector.set4PLCaseIds,'Archived_Case__c','Case_Visibility__c','Edit','Manual',false);            
        }
      }

      //apex based sharing for 4PL case after Update      
      public override void onAfterUpdate() {
          if(!archCaseRecordSelector.set4PLCaseIds.isEmpty()){
              ApexSharingUtility.updateSharing(archCaseRecordSelector.set4PLCaseIds,'Archived_Case__c','Case_Visibility__c','Edit','Manual',true);                
          }
      }
}