/*
* Author   : Saradha
* Purpose  : Class to check Whatsapp bot Active Agents and their Capacity
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2180   27-04-2021     Saradha@UST           Created for providing Number of Active/Online Agents who havent reached their max capacity
*/
@istest()
public class AgentsOnlineWhatsAppBotTest {
    @isTest static void agentWorkTestMethod1(){

        AgentWork agtWrkObj = new AgentWork();
        agtWrkObj.UserId = UserInfo.getUserId();
        
        List<String> agtWrkList = new List<String>{agtWrkObj.UserId};
        List<List<String>> agtWrkList2 = new List<List<String>>();
        agtWrkList2.add(agtWrkList);
        AgentsOnlineWhatsAppBot.getCountOfActiveAgents(agtWrkList2);
    }
    
}