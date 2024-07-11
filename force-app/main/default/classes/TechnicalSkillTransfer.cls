/*
* Author   : Ramadevi
* Purpose  : This class and method is called from bot, this method returns the Technical Skill Id
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5478   23-01-2022    Ramadevi@maersk.com     This class and method is called from bot, this method returns the Technical Skill Id
*/
public class TechnicalSkillTransfer{
    public class botInput
    {
        @InvocableVariable(required=true)
        public String LiveChatButtonId;
    }
    
    @InvocableMethod(label='GetTechnicalSkill')
    public static List<List<Id>> GetTechnicalSkill(List<botInput> lstBotInput){
        try {
            Case_OmniSkill_Mapping__mdt OmniData = [SELECT Id,Technical_Skill_Id__c from Case_OmniSkill_Mapping__mdt where Origin__c =: lstBotInput[0].LiveChatButtonId];
            if(OmniData <> null){
                List<Id> TechnicalSkillId =  new List<Id>{Id.valueof(OmniData.Technical_Skill_Id__c)};
                system.debug('Technical Skill Id##'+TechnicalSkillId );
                return new List<List<Id>> {TechnicalSkillId};
            }            
        } catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'TechnicalSkillTransfer.GetTechnicalSkill', new list<Exception>{ex});
        }
        return null;
    }
}