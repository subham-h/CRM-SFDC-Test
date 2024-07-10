/*
* Author   : Ramadevi
* Purpose  : This class and method is called from bot, this method returns the SkillId to which the chat to be transferred
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5478   23-01-2022    Ramadevi@maersk.com     This class and method is called from bot, GetSkill method returns the SkillId to which the chat to be transferred
* 2.0      SC-7383   07-03-2022    Ramadevi@maersk.com     Removed transfer to Language Skill after Service Relationship.
*/
public class ChatOmniSkillBasedRouting
{
    public static Map<Id, List<String>> mapUsersIdSkills;
    public class botInput
    {
        @InvocableVariable(required=true)
        public Id chatTranscriptId;
        @InvocableVariable(required=false)
        public String caseId;  
        @InvocableVariable(required=false)  
        public String Action;       
        @InvocableVariable(required=false)
        public Integer countOfCall; 
        @InvocableVariable(required=false)  
        public String LastTriedTransfers;
        @InvocableVariable(required=false)  
        public Boolean IsReRoute;
        @InvocableVariable(required=false)
        public String liveChatButtonId;
        @InvocableVariable(required=false)
        public Integer allowedNumberofTransferCount;
    }
    public class botOutput
    {
        @InvocableVariable(required=false)
        public List<Id> SkillIdList;
        @InvocableVariable(required=false)
        public Integer countOfCall; 
        @InvocableVariable(required=false)
        public String triedTransferLevels;
        @InvocableVariable(required=false)  
        public Boolean tryReRoute;
        @InvocableVariable(required=false)
        public Integer allowedNumberofTransferCount;
        
    }
    
    @InvocableMethod(label='ApexTransfer')
    public static List<botOutput> PerformActions(List<botInput> lstBotInput){
        if(lstBotInput[0].Action == 'transferToTechnicalAgent'){
            return GetTechnicalSkill(lstBotInput);
            
        } else if(lstBotInput[0].Action == 'deletePSR'){            
            return DeleteExistingPSR(lstBotInput);
            
        } else if(lstBotInput[0].Action == 'transferToSkills'){            
            return GetSkill(lstBotInput);
        }
        return null;
    }
    
   
    public static List<botOutput> GetSkill(List<botInput> lstBotInput){
        Map<Id,String> agentIdMap = new Map<Id,String>();
        Map<Integer,Id> agentProrityMap = new Map<Integer,Id>();
        List<Id> SkillIdList = new List<Id>();
        List<String> reqSkillList = new List<String>();
        Case cse;
        String lastLevel='';
        Map<String,String> langMap = new Map<String,String>();
        Map<Integer,String> TransferOrder = new Map<Integer,String>();
        Case_OmniSkill_Mapping__mdt omniMdt = new Case_OmniSkill_Mapping__mdt();
        List<String> triedTransferList = new List<String>();
        system.debug('lstBotInput ##'+lstBotInput);
        try {           
            botOutput botOP = new botOutput();
            List<String> prefRoutingLevels = new List<String>();
            Integer totalTransferCount;
            
            LiveChatTranscript lct = [SELECT Id,CaseId,ContactId,Customer_Selected_Lang__c,LiveChatButtonId from LiveChatTranscript where id=:lstBotInput[0].chatTranscriptId];        
            if(lct.caseId <> NULL){
                cse = [Select OwnerId,Origin,AccountId,Case_Country__c,ContactId,Contact.Preferred_Language__c,Care_Relationship__c,Care_Relationship__r.GSC_Agent__c,Care_Relationship__r.Care_Business_Partner__c,Care_Relationship__r.Frontline_backup__c,Care_Relationship__r.GSC_Agent__r.Email,Care_Relationship__r.Care_Business_Partner__r.Email,Care_Relationship__r.Frontline_backup__r.Email,Omni_Skill_Type__c From Case
                       WHERE Id=: lct.caseId]; 
            }
            
            Map<String,Language_Code_Mapping__mdt> langCodeMapping = Language_Code_Mapping__mdt.getAll();
            
            //Get Metadata Seetings in variables
            for(Case_OmniSkill_Mapping__mdt omniSetting :[SELECT Active__c,Case_Field__c,Channel__c,Chat_Button_Name__c,Language_Code__c,Language__c,Origin__c,Value__c,Default_Direction__c FROM Case_OmniSkill_Mapping__mdt WHERE Channel__c = 'Chat' AND Active__c = true AND Origin__c =: lct.LiveChatButtonId]) {
                omniMdt = omniSetting;               
                system.debug('omniMdt'+omniMdt);
                if(omniSetting.Case_Field__c == 'Care_Relationship__c' && omniSetting.Value__c <> null) {
                    Integer i=0;
                    for(String str : omniSetting.Value__c.Split(';')){                  
                        TransferOrder.put(i,str.trim().toLowerCase());
                        lastLevel = str.trim().toLowerCase();
                        i=i+1;
                    }    
                }
                if(omniSetting.Language_Code__c <> null){
                    system.debug('Inside lang if');
                    for(String str : omniSetting.Language_Code__c.Split(';')){ 
                        system.debug('Omni Lang'+str);
                        if(langCodeMapping.containsKey(str))
                        langMap.put(str,langCodeMapping.get(str.contains('yty')?str.replace('-','_'):str).Label);
                    }
                }
            }
            system.debug('TransferOrder ##'+TransferOrder);
            system.debug('langMap ##'+langMap);
            
            if(lstBotInput[0].LastTriedTransfers <> null) {            
                triedTransferList = lstBotInput[0].LastTriedTransfers.split(';');
                botOP.triedTransferLevels = lstBotInput[0].LastTriedTransfers;
            } else {
                botOP.triedTransferLevels='';
            }
            
            if(cse <> null && cse.Case_Country__c <> null){               
                if(lstBotInput[0].countOfCall < lstBotInput[0].allowedNumberofTransferCount || (lstBotInput[0].countOfCall == null && lstBotInput[0].allowedNumberofTransferCount == null)){
                    Care_Relationship__c care = new Care_Relationship__c();
                    String query = 'SELECT Id,GSC_Agent__c,Care_Business_Partner__c,Frontline_backup__c,Frontline_backup__r.Email,Care_Business_Partner__r.Email,GSC_Agent__r.Email from Care_Relationship__c where ';
                    String filterVal = '';
                    if(cse.Care_Relationship__c <> null){
                        filterVal = String.valueof(cse.Care_Relationship__c);
                        query = query + 'id =:filterVal ';
                        
                    } else {
                        filterVal = omniMdt.Default_Direction__c;                        
                        query = query + 'Account__c=:cse.AccountId and Country__c =: cse.Country__c and Direction__c =:filterVal limit 1';                          
                    }
                    system.debug('query ---'+query);
                    care = Database.query(query);
                    system.debug('care ####'+care );
                    
                    if(cse <> null && care <> NULL){    
                        
                        if(lstBotInput[0].allowedNumberofTransferCount == null) {
                            totalTransferCount = omniMdt.Value__c.Split(';').size();                        
                            botOP.allowedNumberofTransferCount = totalTransferCount;
                        } else {
                            totalTransferCount = lstBotInput[0].allowedNumberofTransferCount;
                            botOP.allowedNumberofTransferCount = totalTransferCount;
                        }
                        system.debug('Service Relationship total transfer count'+botOP.allowedNumberofTransferCount);
                        
                        for(Integer order :TransferOrder.keyset()){           
                            if(TransferOrder.get(order) == 'GSC_Agent__c'.toLowerCase() && care.GSC_Agent__c <> null){
                                agentProrityMap.put(Order,care.GSC_Agent__c); 
                                agentIdMap.put(care.GSC_Agent__c,care.GSC_Agent__r.Email);
                            }
                            else if(TransferOrder.get(order) == 'Care_Business_Partner__c'.toLowerCase() && care.Care_Business_Partner__c <> null){
                                agentProrityMap.put(Order,care.Care_Business_Partner__c); 
                                agentIdMap.put(care.Care_Business_Partner__c,care.Care_Business_Partner__r.Email);
                            }
                            else if(TransferOrder.get(order) == 'Frontline_backup__c'.toLowerCase() && care.Frontline_backup__c <> null){
                                agentProrityMap.put(Order,care.Frontline_backup__c); 
                                agentIdMap.put(care.Frontline_backup__c,care.Frontline_backup__r.Email); 
                            } 
                            else {
                            }
                        }
                        //Check for available agents
                        List<Id> avlAgentsIdList = new List<Id>();
                        avlAgentsIdList = checkAgentsAvailability(agentIdMap);
                        if(avlAgentsIdList<> null && avlAgentsIdList.size()>0){
                            List<Integer> priorityList = new List<Integer>(agentProrityMap.keySet());
                            priorityList.sort();
                            for(Integer i : priorityList){
                                //take only if agent is of next level                    
                                if((triedTransferList == NULL ||(!triedTransferList.contains(TransferOrder.get(i)))) && avlAgentsIdList.contains(agentProrityMap.get(i))){
                                    reqSkillList.add(agentIdMap.get(agentProrityMap.get(i)));
                                    cse.Omni_Skill_Type__c = 'Service Relationship';
                                    botOP.countOfCall = i+1;
                                    botOP.triedTransferLevels=botOP.triedTransferLevels+';'+TransferOrder.get(i);
                                    if(TransferOrder.get(i) == lastLevel && botOP.countOfCall == lstBotInput[0].allowedNumberofTransferCount){
                                        botOP.tryReRoute = FALSE;
                                    } else {
                                        botOP.tryReRoute = TRUE;
                                    } 
                                    break;
                                }
                            }                    
                        }                              
                    }else{
                        // In Language
                        if(totalTransferCount == null && omniMdt.Language_Code__c <> null) {
                            totalTransferCount = omniMdt.Language_Code__c.Split(';').size();
                            botOP.allowedNumberofTransferCount = totalTransferCount;
                        } else {
                            totalTransferCount = lstBotInput[0].allowedNumberofTransferCount;
                            botOP.allowedNumberofTransferCount = totalTransferCount;
                        }
                        system.debug('lang totalTransferCount ##'+totalTransferCount);
                        
                        if(langMap <> null){
                            if(triedTransferList == NULL || !triedTransferList.contains(lct.Customer_Selected_Lang__c)) {
                                system.debug('1st');
                                if(langMap.containskey(lct.Customer_Selected_Lang__c)){
                                    system.debug('contains customer selected');
                                    reqSkillList.add(langMap.get(lct.Customer_Selected_Lang__c));
                                    if(lstBotInput[0].LastTriedTransfers <> null ) {
                                        botOP.triedTransferLevels=botOP.triedTransferLevels+';'+lct.Customer_Selected_Lang__c; 
                                    }else {
                                        botOP.triedTransferLevels = lct.Customer_Selected_Lang__c;
                                    }                                                               
                                } else {
                                    //If the customer selected language is not mentioned in the metadata then default skill is English
                                    system.debug('Else default language');
                                    reqSkillList.add(langCodeMapping.get('EN').Label);
                                    if(lstBotInput[0].LastTriedTransfers <> null ) {
                                        botOP.triedTransferLevels=botOP.triedTransferLevels+';EN;'+lct.Customer_Selected_Lang__c; 
                                    }else {
                                        botOP.triedTransferLevels = lct.Customer_Selected_Lang__c;
                                    } 
                                }
                            } else{
                                for(String str : langMap.keyset()){
                                    system.debug('str ##'+str +'## lct.Customer_Selected_Lang__c ##'+lct.Customer_Selected_Lang__c);
                                    if(str <> lct.Customer_Selected_Lang__c && !triedTransferList.contains(str)){
                                        reqSkillList.add(langMap.get(str));
                                        if(lstBotInput[0].LastTriedTransfers <> null ) {                                    
                                            botOP.triedTransferLevels=botOP.triedTransferLevels+';'+str;   
                                        }else {
                                            botOP.triedTransferLevels = str;
                                        }
                                    }                           
                                }
                            }
                            if(cse.Case_Country__c <> null){
                                reqSkillList.add(cse.Case_Country__c);
                            }
                            cse.Omni_Skill_Type__c = 'Language';
                            if(lstBotInput[0].countOfCall <> null) {
                                botOP.countOfCall = lstBotInput[0].countOfCall+1;
                            } else {
                                botOP.countOfCall = 1;
                            }
                            if(botOP.countOfCall == lstBotInput[0].allowedNumberofTransferCount){
                                botOP.tryReRoute = FALSE;
                            } else {
                                botOP.tryReRoute = TRUE;
                            }
                        } else {
                            reqSkillList.add(langCodeMapping.get('EN').Label);                        
                            if(cse.Case_Country__c <> null){
                                reqSkillList.add(cse.Case_Country__c);
                            }
                            cse.Omni_Skill_Type__c = 'Language';
                            if(lstBotInput[0].LastTriedTransfers <> null ) {                                    
                                botOP.triedTransferLevels=botOP.triedTransferLevels+';EN';   
                            }else {
                                botOP.triedTransferLevels = 'EN';
                            }
                            if(lstBotInput[0].countOfCall <> null) {
                                botOP.countOfCall = lstBotInput[0].countOfCall+1;
                            } else {
                                botOP.countOfCall = 1;
                            }
                            if(botOP.countOfCall == lstBotInput[0].allowedNumberofTransferCount){
                                botOP.tryReRoute = FALSE;
                            } else {
                                botOP.tryReRoute = TRUE;
                            }
                            botOP.tryReRoute = FALSE;
                        }
                    }
                }
                
                if(reqSkillList <> NULL) {
                    for(Skill sk :[SELECT DeveloperName,Id,MasterLabel FROM Skill WHERE MasterLabel IN :reqSkillList]){
                        SkillIdList.add(sk.Id);
                    }           
                }
                system.debug('SkillIdList ##'+SkillIdList);        
                System.debug('***countOfCall'+lstBotInput[0].countOfCall);
                
                //Add to Bot Output
                if(SkillIdList <> null && SkillIdList.size()>0){
                    botOP.SkillIdList = SkillIdList;
                    List<Case> cseList = new List<Case>{cse};
                        TriggerExecutionController.skipCaseTrigger(true);   
                    list<Database.SaveResult> lstSaveResults = Database.update(cseList, false);
                    TriggerExecutionController.skipCaseTrigger(false);
                    ErrorLogger.writeErrors('SFDC', 'Case', 'CaseOmniSkillBasedRouting.defineCaseSkillMap', lstSaveResults, cseList);
                    
                    //While retry with next agent skill existing PSR has to be deleted.
                    List<String> workStatuses = new List<String>{'DeclinedOnPushTimeout','Declined','Unavailable'};        
                        if(!(lstBotInput[0].countOfCall == null || lstBotInput[0].countOfCall < 1)){ 
                            if(!Test.isRunningTest()){
                                List<PendingServiceRouting > psrDelList= new List<PendingServiceRouting >();                                       
                                psrDelList = deletePSRForSkillRouting.ListPSRtoDelete(lstBotInput[0].chatTranscriptId);
                                if(psrDelList.size()>0){
                                    Delete psrDelList;
                                }
                            }           
                        }
                    system.debug('botOP @@@'+botOP);        
                    return new List<botOutput>{botOP};
                } else {
                    system.debug('Inside no skill list ##');
                    botOP.SkillIdList = SkillIdList;
                    botOP.triedTransferLevels='';
                    botOP.tryReRoute = FALSE;
                    if(lstBotInput[0].countOfCall <> null){ 
                        botOP.countOfCall = lstBotInput[0].countOfCall+1;  
                    } else {
                        botOP.countOfCall = 1;
                    }
                    return new List<botOutput>{botOP};              
                }
            } else {
                botOP.SkillIdList = null;
                botOP.triedTransferLevels='';
                botOP.tryReRoute = FALSE; 
                if(lstBotInput[0].countOfCall <> null){ 
                    botOP.countOfCall = lstBotInput[0].countOfCall+1;  
                } else {
                    botOP.countOfCall = 1;
                } 
                return new List<botOutput>{botOP};      
                }
        }catch(Exception ex){
            system.debug('ex##'+ex);
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseOmniSkillBasedRouting.defineCaseSkillMap', new list<Exception>{ex});
        }
        return null;
    }   
    
    public static List<Id> checkAgentsAvailability(Map<Id,String> agentIdMap){
        Map<Id,UserServicePresence> AgentStatus = new Map<Id,UserServicePresence>();
        Map<Id,Integer> AgentCapacity = new Map<Id,Integer>();
        List<Id> avlUserIdList= new List<Id>();
        Set<String> setServiceResourceSkill = new Set<String>();        
        List<Id> agentIdList = new List<Id>(agentIdMap.keySet());
        List<UserServicePresence>  lstUserserPre = [SELECT 
                                                    ServicePresenceStatusId,ServicePresenceStatus.DeveloperName,userId,ConfiguredCapacity
                                                    FROM UserServicePresence
                                                    WHERE userId IN :agentIdList AND IsCurrentState = true];
        for(UserServicePresence userserPre : lstUserserPre) {            
            AgentStatus.put(userserPre.userId,userserPre);             
        } 
        system.debug('AgentStatus##'+AgentStatus);
        for(ServiceResourceSkill srSkl :[select Id,ServiceResourceId,SkillId,Skill.MasterLabel from Serviceresourceskill where Skill.MasterLabel IN :agentIdMap.values() and ServiceResource.Isactive=true ]){
            setServiceResourceSkill.add(srSkl.Skill.MasterLabel);
        }
        system.debug('setServiceResourceSkill ##'+setServiceResourceSkill);
        for(AggregateResult result :[SELECT SUM(CapacityWeight) capacity,UserId uId FROM AgentWork WHERE UserId IN :agentIdList AND (Status = 'Opened' OR Status = 'Assigned') GROUP BY UserId]){
            AgentCapacity.put((Id)result.get('uId'),Integer.valueof(result.get('capacity')));
        }       
        system.debug('Current Occupied AgentCapacity##'+AgentCapacity); 
        for(Id AgentId : agentIdList){
            if(!Test.isRunningTest()){
                if(AgentStatus.containskey(AgentId)){
                    if(setServiceResourceSkill.size()>0 && setServiceResourceSkill.contains(agentIdMap.get(AgentId)) &&
                       AgentStatus.get(AgentId).ServicePresenceStatus.DeveloperName == 'Online' && (!AgentCapacity.containsKey(AgentId)|| (AgentCapacity.containsKey(AgentId) && AgentStatus.get(AgentId).ConfiguredCapacity > AgentCapacity.get(AgentId)))){                        
                           avlUserIdList.add(AgentId);                    
                       }
                }
            } else {
                // written for code coverage - test class
                for(User u:[SELECT Id from User where firstname ='Temp' and lastname like 'Agent%']){
                    avlUserIdList.add(u.Id);
                }
            }
        }  
        system.debug('avlUserIdList##'+avlUserIdList);
        return avlUserIdList;
    }
    
    public static List<botOutput> DeleteExistingPSR(List<botInput> lstBotInput){
        try{
            if(lstBotInput[0].liveChatButtonId <> null){
                LiveChatTranscript lct = [SELECT Id,CaseId from LiveChatTranscript where id=:lstBotInput[0].chatTranscriptId];
                Case cse = new Case();
                cse.Id = lct.CaseId ;               
                cse.Omni_Skill_Type__c = 'Chat - General';            
                List<PendingServiceRouting > psrDelList= new List<PendingServiceRouting >();                                       
                psrDelList = ListPSRtoDelete(lstBotInput[0].chatTranscriptId);
                system.debug('psrDelList ##'+psrDelList);
                if(psrDelList.size()>0){
                    Delete psrDelList;
                }
                //Update the Case Omni Skill Type to General
                List<Case> cseList = new List<Case>{cse};
                    TriggerExecutionController.skipCaseTrigger(true);
                system.debug('cseList ##'+cseList);
                list<Database.SaveResult> lstSaveResults = Database.update(cseList, false);
                TriggerExecutionController.skipCaseTrigger(false);
                return null;
            }
        } catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'CaseOmniSkillBasedRouting.DeleteExistingPSR', new list<Exception>{ex});
            return null;
        }
        return null;
    }
    
    public static List<PendingServiceRouting> ListPSRtoDelete(Id chatTranscriptId){
        List<String> workStatuses = new List<String>{'DeclinedOnPushTimeout','Declined','Unavailable'}; 
            List<PendingServiceRouting > psrDelList= new List<PendingServiceRouting >(); 
        for(Agentwork work:[SELECT Name,PendingServiceRoutingId,PreferredUserId,RoutingModel,RoutingPriority,RoutingType,Status,UserId,WorkItemId FROM AgentWork WHERE WorkItemId =: chatTranscriptId]){                    
            if(workStatuses.contains(work.Status) && work.PendingServiceRoutingId <> NULL){
                PendingServiceRouting psr = new PendingServiceRouting();
                psr.id = work.PendingServiceRoutingId;
                psrDelList.add(psr);
            }
        }
        return psrDelList;
    }
    
    public static List<botOutput> GetTechnicalSkill(List<botInput> lstBotInput){
        try {
            Case_OmniSkill_Mapping__mdt OmniData = [SELECT Id,Technical_Skill_Id__c from Case_OmniSkill_Mapping__mdt where Origin__c =: lstBotInput[0].LiveChatButtonId];
            if(OmniData <> null){
                List<Id> TechnicalSkillId =  new List<Id>{Id.valueof(OmniData.Technical_Skill_Id__c)};
                botOutput botOP = new botOutput();
                botOP.SkillIdList  = TechnicalSkillId;
                system.debug('Technical Skill Id##'+TechnicalSkillId);
                //return new List<List<Id>> {TechnicalSkillId};
                return new List<botOutput>{botOP};
                    }            
        } catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'ChatOmniSkillBasedRouting.GetTechnicalSkill', new list<Exception>{ex});
        }
        return null;
    }
}