/*
* Trigger Utility Class for CareTrigger and Trigger Handler class.
* 
*Version  Date         Owner                                    RQ#           Description
*******************************************************************************************************************************************
*1.0      23/02/2023   nayana.sharma@maersk.com       			SC-7120		  Created
*/
public class CareTriggerUtility {

//Wrapper to pass type of operation, user email and service resource record for the platform event
    public class serviceResourceWrap{
        public String opType;
        public String agentEmail;
        public ServiceResource srRec;
        public List<ServiceResourceSkill> srSkills;
    }        
    
/*This method checks if agents removed from Service relationship is present on any other existing Service Relationship 
* If present in existing relationship then remove from decommission set*/    
    public static List<serviceResourceWrap> getSRToDeactivate(Set<Id> setAgentsToValidate, Boolean checkSRs){
        Set<Id> setAgentsInService = new Set<Id>();
        Set<String> applicableCountries = new Set<String>();
        //List<ServiceResourceRec> listSkillWrapper = new List<ServiceResourceRec>();
        List<serviceResourceWrap> listSkillWrapper = new List<serviceResourceWrap>();
        //Check Existing service relationships only if its called from careTriggerhandler and not check this for UserTrigger
        system.debug('checkSRs'+checkSRs);
        for(General_Key_Value_Configurations__mdt mdt: [SELECT Id, label,First_Field_Value__c,First_Field_Name__c, Key__c,Second_Field_Name__c,Second_Field_Value__c
                                                         FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'Applicable_countries_omni' ]){
                                                            applicableCountries.add(mdt.First_Field_Value__c);                                                           
                                                        }
        if(!setAgentsToValidate.isEmpty() && checkSRs==true){
            //Check if agent is present in any other Service relationship before decomission of that Agent
            for(Care_Relationship__c cr:[select id,Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c,Status__c from Care_Relationship__c 
                                         where Status__c='Active' AND Country__r.Name IN :applicableCountries AND 
                                         (Care_Business_Partner__c IN :setAgentsToValidate OR GSC_Agent__c IN :setAgentsToValidate
                                                                       OR Frontline_backup__c IN :setAgentsToValidate)]){                                             
                                                                           if(setAgentsToValidate.contains(cr.Care_Business_Partner__c)){
                                                                               setAgentsToValidate.remove(cr.Care_Business_Partner__c);
                                                                           }
                                                                          if(setAgentsToValidate.contains(cr.GSC_Agent__c)){
                                                                               setAgentsToValidate.remove(cr.GSC_Agent__c);
                                                                           }
                                                                           if(setAgentsToValidate.contains(cr.Frontline_backup__c)){
                                                                               setAgentsToValidate.remove(cr.Frontline_backup__c);
                                                                           }                                             
                                                                       }
        }
            
            system.debug('setAgentsToValidate>>'+setAgentsToValidate);
            //If the agents are not present in any SRs then query the IDs,emails and pass to future method to deactivate 
            //Service resource and skill            
            if(!setAgentsToValidate.isEmpty()){
                for(ServiceResource srs:[SELECT Id,IsActive,RelatedRecordId,RelatedRecord.Email,
                                         (SELECT Id,SkillId,Skill.MasterLabel from ServiceResourceSkills)
                                         FROM ServiceResource where RelatedRecordId IN :setAgentsToValidate AND isActive=true]){
                                             serviceResourceWrap srWrap = new serviceResourceWrap();  
                                             srWrap.opType = 'DEACTIVATE';    
                                             srWrap.agentEmail = srs.RelatedRecord.Email;
                                             srWrap.srRec = new ServiceResource(
                                                 Id = srs.Id,
                                                 isActive=false                                                 
                                             );
                                             srWrap.srSkills=srs.ServiceResourceSkills !=null ? srs.ServiceResourceSkills : new List<ServiceResourceSkill>();
                                             listSkillWrapper.add(srWrap);                    
                                         }  
            }
        
        system.debug('listSkillWrapper>>'+listSkillWrapper);
        return listSkillWrapper;
    }
    
/*This method checks if agents added on Service relationship already have a Service Resource record 
* If present then remove from Service resource creation set*/    
    public static List<serviceResourceWrap> checkExistingServiceResource(Set<Id> setAgentsToCreate){
        //If Service resource is not present for the agent added on SR then pass to future method to create Service resource and skill
        Map<String,Set<Id>> mapServiceResource = new Map<String,Set<Id>>();
        Set<Id> setSRExisting = new Set<Id>();   
        Set<String> setCreateSkills = new Set<String>();
        List<serviceResourceWrap> listSkillWrapper = new List<serviceResourceWrap>();
        
        if(!setAgentsToCreate.isEmpty()){
            for(ServiceResource srs:[SELECT Id,AccountId,Description,IsActive,Name,RelatedRecordId,RelatedRecord.Email,RelatedRecord.Chat_Queues__c,
										(SELECT Id from ServiceResourceSkills)                                     
                                     FROM ServiceResource where RelatedRecordId IN :setAgentsToCreate ]){                    
                                         //If Service Resource is present and inactive for the newly added agent, it will be an update operation
                                         //Add to existing SR set if present for any agent and is active or inactive to remove those from creation set later
                                         if(!srs.IsActive || (srs.IsActive && srs.ServiceResourceSkills.isEmpty())){
                                             serviceResourceWrap srWrap = new serviceResourceWrap();  
                                             srWrap.opType = 'UPDATE';   
                                             srWrap.agentEmail = srs.RelatedRecord.Email;
                                             srWrap.srRec = new ServiceResource(
                                                 Id = srs.Id,
                                                 isActive=true
                                             );                        
                                             listSkillWrapper.add(srWrap);
                                             setSRExisting.add(srs.RelatedRecordId); //Adding in this set to later remove from main creation set
                                         }
                                         //This scenario covers when Active SR is present but new chat queue was added for the user
                                         else if(srs.IsActive && !srs.ServiceResourceSkills.isEmpty()){
                                            setCreateSkills.add(srs.RelatedRecord.Email);
                                            setSRExisting.add(srs.RelatedRecordId); 
                                         }
                                         //If Active Service Resource is present for the newly added agent then remove from creation set
                                         /*else if(srs.IsActive){                                             
                                             setSRExisting.add(srs.RelatedRecordId); 
                                         }    */                                                            
                                     }
            //Remove existing agents from creation set
            if(!setSRExisting.isEmpty()){
                setAgentsToCreate.removeAll(setSRExisting);
            }
            //Prepare wrapper for Service resource creation
            if(!setAgentsToCreate.isEmpty()){
                for(User u:[Select Id,Name, Email from User where Id in :setAgentsToCreate]){
                    serviceResourceWrap srWrap = new serviceResourceWrap();  
                    srWrap.opType = 'CREATE';  
                    srWrap.agentEmail = u.Email;
                    srWrap.srRec = new ServiceResource(
                        Name=u.Name,
                        isActive=true,
                        relatedRecordId = u.Id,
                        ResourceType = 'A'
                    );                
                    listSkillWrapper.add(srWrap);
                }
                
            }        
            //Only create service resource skill if Active SR is present
            if(!setCreateSkills.isEmpty() || setCreateSkills.size()>0){
                createSRSkill(setCreateSkills);
            }
        }
        system.debug('listSkillWrapper>>'+listSkillWrapper);
        return listSkillWrapper;
    }
    
/*This method checks if agents added on Service relationship already have a Skill created. If present then remove from Skill creation set*/    
    public static Map<String,String> checkExistingSkill(Set<Id> setAgentsToCreate){     
        system.debug('setAgentsToCreate>>>'+setAgentsToCreate);
        Set<String> setSkillToCreate = new Set<String>();
        Set<String> setSkillCheck = new Set<String>();
        Set<String> setSkillToUpdate = new Set<String>();
        Map<String,String> mapSkillToProcess = new Map<String,String>();
        
        if(!setAgentsToCreate.isEmpty()){            
            for(User u:[Select Id,Name, Email,Chat_Queues__c from User where Id in :setAgentsToCreate]){
                setSkillToCreate.add(u.Email);              
                setSkillCheck.add('z_'+u.Email); //Add z_ to the email and check for any decommissioned skill for the user email
            }            
                  
            system.debug('setSkillCheck+++'+setSkillCheck);
            system.debug('setSkillToCreate+++'+setSkillToCreate);
            //Check if Skill is present for the user's email
            for(Skill sk:[Select Id, Masterlabel,DeveloperName from Skill where Masterlabel IN :setSkillToCreate OR 
                          Masterlabel IN :setSkillCheck]){
                              //If Active Skill is present for the newly added agent then remove from creation set
                              if(!sk.Masterlabel.startsWithIgnoreCase('z_')){
                                  setSkillToCreate.remove(sk.Masterlabel);
                              }
                              //If inactive Skill is present for the newly added agent then remove from creation set and 
                              //add in update set
                              else if(sk.Masterlabel.startsWithIgnoreCase('z_')){
                                  setSkillToCreate.remove(sk.Masterlabel.removeStartIgnoreCase('z_'));
                                  setSkillToUpdate.add(sk.MasterLabel.removeStartIgnoreCase('z_'));
                              }                              
                          }
            if(!setSkillToCreate.isEmpty()){   
                for(String s:setSkillToCreate){
                    mapSkillToProcess.put(s,'CREATE');
                }                      
            }
            if(!setSkillToUpdate.isEmpty()){
                for(String s:setSkillToUpdate){
                    mapSkillToProcess.put(s,'UPDATE');
                }            
            }
        }
        return mapSkillToProcess;
    }  
    
/*This method checks if agents removed from Service relationship already have a Skill created then it has to be deactivated*/    
    public static Map<String,String> getSkillToDeactivate(Set<String> usersToDecommission){
        Map<String,String> mapSkillToProcess = new Map<String,String>();        
        for(Skill sk:[Select Id, Masterlabel,DeveloperName from Skill where Masterlabel IN :usersToDecommission]){
            mapSkillToProcess.put(sk.Masterlabel,'DEACTIVATE');
        }        
        return mapSkillToProcess;
    } 
    
/*This method checks if agents removed from Service relationship already have a Skill created then it has to be deactivated*/    
    public static void publishPlatformEvent(List<serviceResourceWrap> listSkillWrapper,Map<String,String> mapSkillToProcess){
        system.debug('listSkillWrapper+++'+listSkillWrapper);
        system.debug('mapSkillToProcess+++'+mapSkillToProcess);
        List<Skill_Event__e> listSkillEvent = new List<Skill_Event__e>();                
        if(listSkillWrapper.size()>0 || !mapSkillToProcess.isEmpty()){   
            //Create platform event instance
            Skill_Event__e thisEvent1 = new Skill_Event__e();
            thisEvent1.JSON_1__c = JSON.serialize(listSkillWrapper);
            thisEvent1.JSON_2__c = JSON.serialize(mapSkillToProcess);
            listSkillEvent.add(thisEvent1);
        }
        if(listSkillEvent.size()>0){
            try{
                List<Database.SaveResult> results = EventBus.publish(listSkillEvent);
            }
            catch(exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'SkillEvent', 'CareTriggerHandler.handleAgentsUpdate', new list<Exception>{ex}); 
            } 
        }
    }

@future(callout=true)    
    public static void processSkillUsingMetadataApi(String SRToProcess,String SkillToProcess){
        List<serviceResourceWrap> listSkillWrapper = new List<serviceResourceWrap>();        
        Map<String,String> mapSkillToProcess = new Map<String,String>(); 
        Set<String> setCreateSkills = new Set<String>();
        Set<String> setDeactivateSkills = new Set<String>();
        List<ServiceResourceSkill> listSRSkill = new List<ServiceResourceSkill>();
        system.debug('SRToProcess++'+SRToProcess);
        system.debug('SkillToProcess'+SkillToProcess);        
        if(SRToProcess!=null && SRToProcess!=''){ 
            listSkillWrapper = (List<serviceResourceWrap>) JSON.deserialize(SRToProcess, List<serviceResourceWrap>.class);
        }
        if(SkillToProcess!=null && SkillToProcess!=''){ 
            String jsonstr = SkillToProcess.replace('\\','');
            system.debug('jsonstr'+jsonstr);            
        	mapSkillToProcess = (Map<String,String>) JSON.deserialize((String)jsonstr, Map<String,String>.class);
        }
        system.debug('listSkillWrapper>>>'+listSkillWrapper);
        system.debug('mapSkillToProcess>>>'+mapSkillToProcess);                       
        if(listSkillWrapper.size()>0){
            for(serviceResourceWrap srWrap:listSkillWrapper){ 
                if(srWrap.opType=='CREATE' || srWrap.opType=='UPDATE'){
                    setCreateSkills.add(srWrap.agentEmail);
                }
                if(srWrap.opType=='DEACTIVATE' && srWrap.srSkills!=null){
                    listSRSkill.addAll(srWrap.srSkills);
                    system.debug('listSRSkill'+listSRSkill);
                }
            }
        }
            
        if(!mapSkillToProcess.isEmpty()){
                try{
                    MetadataService.MetadataPort service = MetadataUtility.createService();
                    List<MetadataService.Skill> listSkillToUpdate = new List<MetadataService.Skill>();                  
                    //Process map of Skill 
                    for(String email:mapSkillToProcess.keySet()){
                        system.debug('optype'+mapSkillToProcess.get(email));
                        MetadataService.Skill skillRecord = new MetadataService.Skill();                          
                        skillRecord.type = 'Skill';
                        skillRecord.fullName=email.replaceAll('[^a-zA-Z0-9]','_'); 
                        //if create or update set label as email
                        if(mapSkillToProcess.get(email)=='CREATE' || mapSkillToProcess.get(email)=='UPDATE'){                            
                            skillRecord.label=email;   
                            listSkillToUpdate.add(skillRecord); 
                            setCreateSkills.add(email);
                        }                        
                        //if deactivate set label as z_email
                        else if(mapSkillToProcess.get(email)=='DEACTIVATE'){                           
                            skillRecord.label='z_'+email;                            
                            listSkillToUpdate.add(skillRecord); 
                        }
                    }
                    system.debug('listSkillToUpdate++'+listSkillToUpdate);                    
                    if(listSkillToUpdate.size()>0){
                        List<MetadataService.UpsertResult> upsertedResults = service.upsertMetadata(listSkillToUpdate);
                        system.debug('upsertedResults>>'+upsertedResults);
                    }
                }
                catch(exception ex){
                    system.debug('ex++'+ex);
                    ErrorLogger.writeErrors( 'SFDC', 'SkillError', 'ServiceResourceAndSkillHandler.processSkillUsingMetadataApi', new list<Exception>{ex});
                }
            }
        
        //Method to process service resource creation or update
        if(listSkillWrapper.size()>0){   
            try{
            	handleServiceResource(listSkillWrapper,mapSkillToProcess);
            }
            catch(exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'SRMethodError', 'ServiceResourceAndSkillHandler.processSkillUsingMetadataApi', new list<Exception>{ex});
            }
        }        
        //Method to create Service Resource skill
        if(!setCreateSkills.isEmpty()){
            createSRSkill(setCreateSkills);
        }
        //Method to delete Service Resource skill
        system.debug('listSRSkill++'+listSRSkill); 
        if(!listSRSkill.isEmpty()){
            deleteSRSkill(listSRSkill);
        }
                       
     }
//Method to handle Service resource and Service resource skill creation
    public static void handleServiceResource(List<serviceResourceWrap> listSkillWrapper,Map<String,String> mapSkillToProcess){
        List<ServiceResource> listServiceResource = new List<ServiceResource>();
        List<ServiceResourceSkill> listSerResSkillCreate = new List<ServiceResourceSkill>();
        Set<String> setApplicableSkills = new Set<String>();
        Set<String> setDeactivateSkills = new Set<String>();
        for(serviceResourceWrap srWrap:listSkillWrapper){            
            listServiceResource.add(srWrap.srRec);            
        }
        
		//Upsert the service resources        
        if(listServiceResource.size()>0){
            try{
            	List<Database.upsertResult> srResults = Database.upsert(listServiceResource,false);
                ErrorLogger.writeErrors( 'SFDC', 'ServiceResourceError', 'ServiceResourceAndSkillHandler.handleServiceResource', srResults,listServiceResource);
                system.debug('srResults++'+srResults);                
            }
            catch(exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'ServiceResourceError', 'ServiceResourceAndSkillHandler.handleServiceResource', new list<Exception>{ex});
                system.debug('exec+++'+ex);
            }            
        }        
    }
    
    //Method to handle Service resource and Service resource creation
    public static void createSRSkill(Set<String> setCreateSkills){
        Set<String> setApplicableSkills = new Set<String>();
        Set<String> setDeactivateSkills = new Set<String>();
       	system.debug('setCreateSkills'+setCreateSkills);
       	//Add all the applicable skill to be queried 
        for(General_Key_Value_Configurations__mdt mdt: [SELECT Id, label,First_Field_Value__c,First_Field_Name__c, Key__c,Second_Field_Name__c,Second_Field_Value__c
                                                         FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'Applicable_countries_omni' ]){                                                            
                                                         setCreateSkills.add(mdt.Second_Field_Value__c);
                                                        }        
       	Map<String,Skill> mapSkills = new Map<String,Skill>();        
        Set<String> setChatQueues = new Set<String>();
        system.debug('setCreateSkills'+setCreateSkills);
        //Get SkillId and ServiceResourceId for the users to create ServiceResourceSkill based on create or update operation        
        for(Skill sk:[SELECT Id,MasterLabel from Skill where MasterLabel IN :setCreateSkills]){
            	mapSkills.put(sk.MasterLabel, sk);
        }
        /*if(test.isRunningTest()){
            user einteinUser = [select id,name,Email from user where name='Einstein User' LIMIT 1];
            mapSkills.put(einteinUser.Email, new Skill(MasterLabel=einteinUser.Email));
        }*/
        system.debug('mapSkills+++'+mapSkills);
        
        //Get Service resource record for created/updated skills, not required for deactivated skills
        Map<String,ServiceResource> mapSRs = new Map<String,ServiceResource>();
        Map<String,ServiceResource> mapSRChatQueue = new Map<String,ServiceResource>();        
        for(ServiceResource sr:[SELECT Id,RelatedRecord.Email,RelatedRecord.Chat_Queues__c from ServiceResource where 
                                RelatedRecord.Email IN :mapSkills.keySet()]){                                
       		mapSRs.put(sr.RelatedRecord.Email, sr); 
            List<String> listChatQueue = new List<String>();
            if(sr.RelatedRecord.Chat_Queues__c!=null){
                //setChatQueue.addAll(sr.RelatedRecord.Chat_Queues__c.split(';')); 
                //listChatQueue = sr.RelatedRecord.Chat_Queues__c.contains(';')? sr.RelatedRecord.Chat_Queues__c.split(';') : new List<String>{sr.RelatedRecord.Chat_Queues__c};                
            //}
            	system.debug('listChatQueue'+listChatQueue);   	
            	for(String q:setCreateSkills){  
                	if(sr.RelatedRecord.Chat_Queues__c.containsIgnoreCase(q)){
                    	mapSRs.put(q, sr);
            		//mapSRChatQueue.put(st, sr);
                	}
            	}
            }
       }        
        
        system.debug('mapSkills>>>'+mapSkills);
        system.debug('mapSRs>>>'+mapSRs);
        //Upsert Service resource skills      
        if(!mapSkills.isEmpty() && !mapSRs.isEmpty()){
            List<ServiceResourceSkill> listSRSkill = new List<ServiceResourceSkill>();
            for(String s: mapSRs.keySet()){                
                listSRSkill.add(new ServiceResourceSkill(
                SkillId = mapSkills.get(s).Id,                
                EffectiveStartDate = system.today(),   
                ServiceResourceId = mapSRs.get(s).Id
                //ServiceResourceId = mapSRChatQueue.get(s)!=null ? mapSRChatQueue.get(s).Id : mapSRs.get(s).Id                
                ));
            }
            //Upsert Service resource skills
            if(listSRSkill.size()>0){
                try{
                    List<Database.upsertResult> skResults = Database.upsert(listSRSkill,false);
                    ErrorLogger.writeErrors( 'SFDC', 'ServiceResourceError', 'ServiceResourceAndSkillHandler.handleServiceResource', skResults,listSRSkill);
                    system.debug('skResults++'+skResults);
                }
                catch(exception ex){
                    ErrorLogger.writeErrors( 'SFDC', 'SRSkillError', 'ServiceResourceAndSkillHandler.handleServiceResource', new list<Exception>{ex});
                    system.debug('err'+ex);
                }
            }
            if(test.isRunningTest()){
                deleteSRSkill(listSRSkill);
            }
        }        
    }
    
    //Handle country/ chatqueue Skills if it is added/removed on user
    public static void deleteSRSkill(List<ServiceResourceSkill> listSRSkill){
        List<ServiceResourceSkill> srSkillsToDeactivate = new List<ServiceResourceSkill>();
        /*Set<String> applicableChatQueues = new Set<String>();
        for(General_Key_Value_Configurations__mdt mdt: [SELECT Id, label,First_Field_Value__c,First_Field_Name__c, Key__c,Second_Field_Name__c,Second_Field_Value__c
                                                         FROM General_Key_Value_Configurations__mdt WHERE Key__c = 'Applicable_countries_omni' ]){                                                            
                                                         //setDeactivateSkills.add(mdt.Second_Field_Value__c);
                                                         applicableChatQueues.add(mdt.Second_Field_Value__c);
                                                         /*applicableChatQueues ='(';
                                                         applicableChatQueues += '\'' +  mdt.Second_Field_Value__c + '\',';
                                                        }
        /*applicableChatQueues = applicableChatQueues.removeEnd(',');
		applicableChatQueues += ')';
        system.debug('applicableChatQueues+++'+applicableChatQueues);*/
        system.debug('listSRSkill+++'+listSRSkill);
        try{
            List<Database.deleteResult> deleteResults = Database.delete(listSRSkill,false);
            ErrorLogger.writeErrors( 'SFDC', 'SRSkillError', 'ServiceResourceAndSkillHandler.deleteSRSkill', deleteResults,listSRSkill);
        }
        catch(exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'SRSkillError', 'ServiceResourceAndSkillHandler.deleteSRSkill', new list<Exception>{ex});
            system.debug('err'+ex);
        }
        /*if(!setDeactivateSkills.isEmpty()){
            for(ServiceResource sr:[SELECT Id,RelatedRecord.Email,RelatedRecord.Chat_Queues__c,(Select Id,SkillId,Skill.MasterLabel from ServiceResourceSkills) 
                                    from ServiceResource where RelatedRecord.Email IN :setDeactivateSkills]){
                                        Set<String> setChatQueue = new Set<String>();
                                        if(sr.RelatedRecord.Chat_Queues__c!=null){
                                            //setChatQueue.addAll(sr.RelatedRecord.Chat_Queues__c.split(';'));  
                                            listChatQueue = sr.RelatedRecord.Chat_Queues__c.contains(';')? sr.RelatedRecord.Chat_Queues__c.split(';') : new Set<String>{sr.RelatedRecord.Chat_Queues__c};             
                                                }
                                        system.debug('setChatQueue'+setChatQueue); 
                                        if(sr.ServiceResourceSkills.size()>0){
                                            for(ServiceResourceSkill srs: sr.ServiceResourceSkills){
                                                
                                            }
                                        }
                                        
            for(String st:setChatQueue){  
                if(setApplicableSkills.contains(st)){
            		mapSRChatQueue.put(st, sr);
                }
            }
            }
        }*/
    }
    
}