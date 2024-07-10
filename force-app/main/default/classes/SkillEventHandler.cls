/**
* @description
* Author   : nayana.sharma@Maersk
* Purpose  : Handle the Insert of the Platform event Skill event 
             records and call ServiceResourceAndSkillHandler for Skill and Service resource processing 
  
* Revision Ref Number  Date           Owner                   Description
* -------- ----------  -----------    -------------------     -----------
* 1.0      SC-7120     20-Feb-2023 	  nayana.sharma@Maersk   Handler class to convert events into Skill and Service resource related records
                                                             CareTriggerClass_Test() and UserTrigger_Test() classes handle code coverage for this Class.
															 This class is configured to run using Case data interface user  
*/

public class SkillEventHandler {
    public static void handleSkills(List<Skill_Event__e> newList) {        
        String SRToProcess;
        String SkillToProcess;
        
        for (Skill_Event__e thisEvent : newList) {
            system.debug('JSON_1__c'+thisEvent.JSON_1__c);
            system.debug('JSON_2__c'+thisEvent.JSON_2__c);
            
            SRToProcess = thisEvent.JSON_1__c;
            SkillToProcess = thisEvent.JSON_2__c;            
        }           
        system.debug('SRToProcess+++'+SRToProcess);
        system.debug('SkillToProcess+++'+SkillToProcess);
        
        if(SRToProcess!=null && SkillToProcess!=null){ 
        	CareTriggerUtility.processSkillUsingMetadataApi(SRToProcess,SkillToProcess);
        }        
    }
}