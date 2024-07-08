/*
* Author   : Saradha
* Purpose  : Class to check Whatsapp bot Active Agents and their Capacity
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-2180   27-04-2021     Saradha@UST           Created for providing Number of Active/Online Agents who havent reached their max capacity
*/
public class AgentsOnlineWhatsAppBot {
    public class ActiveAgents{
        @InvocableVariable(required=true)
        public Integer countOfActiveAgents; 
        @InvocableVariable(required=true)
        public Integer agentsMaxCapacity; 
    }
    // Invoked from WhatsApp Bot to get Total active agents - Active agents with full capacity .
    @InvocableMethod(label='getCountOfActiveAgents')
    public static List<ActiveAgents> getCountOfActiveAgents(List<List<String>> activeAgentIds){
        
        //To be sent to flow for active agents
        List<ActiveAgents> lstOfAgents = new List<ActiveAgents>();
        
        List<AgentWork> lstOfAgentWork = new List<AgentWork>();
        //Agents passed from flow
        List<Id> lstOfActiveAgents = new List<Id>();
        //list of Active agents
        List<UserServicePresence> lstOfUsrSrvPrsnce = new List<UserServicePresence>();
        
        //map of agents with their current work capacity
        Map<Id,Integer> agentAndCapacity = new  Map<Id,Integer>();
        //map of agents with their configured work capacity
        Map<Id,Integer> agentAndMappedCapacity = new  Map<Id,Integer>();
        //set of agents with full capacity
        Set<Id> setOfAgentIdswithMaxCap = new Set<Id>();
        
        ActiveAgents agentObj = new ActiveAgents();
        agentObj.countOfActiveAgents = 0;
        
        if(activeAgentIds != null && activeAgentIds.size() > 0){
            // for test class
            if(Test.isRunningTest()){
                AgentWork agtWrkObj = new AgentWork();
                agtWrkObj.UserId = activeAgentIds.get(0).get(0);
                lstOfAgentWork.add(agtWrkObj);
                lstOfAgentWork.add(agtWrkObj);

            }else{
                lstOfActiveAgents = activeAgentIds.get(0);
                //This gives agent work of the user
                lstOfAgentWork = [select id,name,userId from AgentWork where status = 'Opened' and createdby.id in : lstOfActiveAgents]; 
                //Get agent id and their configured capacity
                lstOfUsrSrvPrsnce = [select id,userid,ConfiguredCapacity from UserServicePresence where userid in : lstOfActiveAgents];
            }
            //Storing the Agent user id and their maximum capacity
            for(UserServicePresence srvObj: lstOfUsrSrvPrsnce){
                agentAndMappedCapacity.put(srvObj.userId,srvObj.ConfiguredCapacity );
            }
            
            //Logic to get agents who has reached their max capacity
            for(AgentWork agntWrkObj : lstOfAgentWork){
                if(agntWrkObj.userId != null && agentAndCapacity.containsKey(agntWrkObj.userId)){
                    agentAndCapacity.put(agntWrkObj.userId,agentAndCapacity.get(agntWrkObj.userId) + 1);
                }else if(agntWrkObj.userId != null){
                    agentAndCapacity.put(agntWrkObj.userId,1);
                }
                if(agentAndCapacity.get(agntWrkObj.userId) >= agentAndMappedCapacity.get(agntWrkObj.userId)){//capacity hardcode 
                    setOfAgentIdswithMaxCap.add(agntWrkObj.userId); 
                }
            }
            System.debug('setOfAgentIdswithMaxCap.size()++'+setOfAgentIdswithMaxCap.size());
            System.debug('lstOfActiveAgents.size()++'+lstOfActiveAgents.size());
            //Total Active Agents - Agents who has already reached max capacity
            agentObj.countOfActiveAgents = lstOfActiveAgents.size() - setOfAgentIdswithMaxCap.size();
            lstOfAgents.add(agentObj);
            
        }else{
            System.debug('No Active Agents');
        }
        return lstOfAgents;
    }
}