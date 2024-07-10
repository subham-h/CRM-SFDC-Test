/** 
* @description 
* Author   : Sunil.bs@maersk.com
* Purpose  : Utility class to hold simple and reusable functionalities for Omni Automation 
*        
* Revision Ref Number  Date        Owner                   		Description
* -------- ----------  ----------- -------------------     		-----------
* 1.0      SC-7996   15-Jun-2023   Sunil.bs@maersk.com          Created for automating Omni Onboarding of countries
* 2.0      SC-8936   12-Feb-2024   Vivek@Maersk.com				Updated method addCaseOmniMappingsRecords() to allow adding additional skills for Non Short Transit and other scenarios
*/
public class omniMetadataUtility{
    
    /** 
* @description | SC-7996 Adds Skills into system by adding them as skills in setup|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/
    public static String createSkills(List<String> srBodyList){
        try{map<string,id> skillMap = new map<string,id>();
            list<Skill> skillToInsertList = new list<Skill>();
            list<skill> skillsToProcess = new list<skill>();
            set<skill> skillsToProcessSet = new set<skill>();
            
            String sessionId = '';
            if(!Test.isRunningTest()){
                sessionId = getSessionId();
            }
            else{
                sessionId = UserInfo.getSessionId();
            }
            
            Integer counter = 1;
            for(Skill SkillInstance:[select id from skill where masterlabel like 'z_%']){
                counter++;
            }
            //Fetch all existing skills
            for(skill skillInstance:[select id,masterLabel from skill]){
                string skillName = skillInstance.MasterLabel;
                skillName = skillName.normalizeSpace();
                skillName = skillName.trim();
                skillMap.put(skillName.toUpperCase(),skillInstance.id);
            }
            
            for(integer i=1; i< srBodyList.size(); i++){
                //Check if skill already exists in the system, if not then create it
                String skillInstance = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                skillInstance = skillInstance.normalizeSpace();
                skillInstance = skillInstance.trim();
                if(!skillMap.containskey(skillInstance.toUpperCase())){              
                    Skill newSkill = new Skill();       
                    newSkill.Masterlabel = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    newSkill.Masterlabel = newSkill.Masterlabel.normalizeSpace();
                    newSkill.Masterlabel = newSkill.Masterlabel.trim();
                    
                    //Remove alphanumeric characters so that we can format dev name
                    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
                    string DeveloperName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    Matcher matcher = nonAlphanumeric.matcher(DeveloperName);
                    DeveloperName = matcher.replaceAll(' ');
                    DeveloperName = DeveloperName.normalizeSpace();
                    DeveloperName = DeveloperName.trim();
                    newSkill.DeveloperName = DeveloperName.replaceall(' ','_');
                    skillsToProcessSet.add(newSkill);
                }
            }
            
            if(!skillsToProcessSet.isempty()){
                skillsToProcess.addall(skillsToProcessSet);
                truncateListAndProcess200RecordsSkills(skillsToProcess,sessionId);
            }
            return '';
           }catch(Exception e){
               system.debug('Omni error '+e.getMessage()+' '+e.getLineNumber());
               return e.getMessage()+' '+e.getLineNumber();
           }
    } 
    
    
    /** 
* @description | SC-7996 Add service resource and associated skills to users |
* @param srBodyList accepts the XL file uploaded in list<string> format
*/ 
    public static string userServiceResourceAndSkillsUpsert(List<String> srBodyList){
        
        try { Map<string,id> skillMap = new Map<string,id>();
             list<string> UserWithUpdatesNeededList = new list<string>();
             list<Id> UserWithUpdatesNeededUserIdList = new list<Id>();
             Map<string,user > UserWithUpdatesNeededMap = new Map<string,user>();
             Map<id,ServiceResource > existingserviceResourceMap = new Map<id,ServiceResource>();
             Set<ServiceResource> createServiceResourceSet = new Set<ServiceResource>();
             list<ServiceResource> createServiceResourcelist = new list<ServiceResource>();
             set<ServiceResourceSkill> createServiceResourceSkillset = new set<ServiceResourceSkill>();
             list<ServiceResourceSkill> createServiceResourceSkillList = new list<ServiceResourceSkill>();
             Map<string,string> existingserviceResourceSkillMap = new Map<string,string>();
             list<id> allserviceResourceInScopeIdList = new list<id>();
             
             //Retrieve all existing skills in the system
             for(skill skillInstance:[select id,masterLabel from skill]){
                 string skillName = skillInstance.MasterLabel;
                 skillName = skillName.normalizeSpace();
                 skillName = skillName.trim();
                 skillMap.put(skillName.toUpperCase(),skillInstance.id);
             }
             
             //Fetch all APM Id's of users who needs skill addition
             integer n=1;
             for(n=1; n< srBodyList.size(); n++){                   
                 list<string> userList = new list<string>();
                 string dataSize = srBodyList[n].replaceAll('"', '');
                 Integer userSize =  dataSize.replaceAll('\"', '').trim().split(',').size();
                 Integer j = 1;
                 
                 for(j=1;j<usersize;j++){
                     
                     string data = srBodyList[n].replaceAll('\"', '');                      
                     data = data.replaceAll('"', '').trim().split(',')[j].trim();
                     data = data.normalizespace();
                     data = data.trim();
                     string UsersMaerskUserId = data;
                     UserWithUpdatesNeededList.add(UsersMaerskUserId);
                 }
             }
             //Map APM id's of users with user records
             for(user userInstance:[select id,Maersk_User_Id__c,Name from user where Maersk_User_Id__c in:UserWithUpdatesNeededList]){
                 UserWithUpdatesNeededUserIdList.add(userInstance.id);
                 UserWithUpdatesNeededMap.put(userInstance.Maersk_User_Id__c,userInstance);          
             }
             
             
             //Fetch already existing 'service resource' records
             for(ServiceResource ServiceResourceInstance:[select id,RelatedRecordId,Name from ServiceResource where RelatedRecordId in:UserWithUpdatesNeededUserIdList]){
                 existingserviceResourceMap.put(ServiceResourceInstance.RelatedRecordId,ServiceResourceInstance);
             }
             
             // If they are new users yet to be onboarded to omni create service resource for them newly
             integer i = 1;
             for(i=1; i< srBodyList.size(); i++){
                 list<string> userList = new list<string>();
                 string dataSize = srBodyList[i].replaceAll('\"', '');
                 dataSize = dataSize.normalizespace();
                 dataSize = dataSize.trim();
                 Integer userSize =  dataSize.replaceAll('"', '').trim().split(',').size();
                 integer j = 1;
                 
                 for(j=1;j<usersize;j++){
                     string data = srBodyList[i].replaceAll('"', '');
                     data = data.normalizespace();
                     data = data.trim();
                     data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                     string UsersMaerskUserId = data;
                     User UserInstance = UserWithUpdatesNeededMap.get(UsersMaerskUserId);
                     
                     if(UserInstance!=null){
                         //Create service resource record only if it does not exist in system yet for the user
                         if(!existingserviceResourceMap.containskey(UserInstance.id)){
                             ServiceResource ServiceResourceInstance = new ServiceResource();
                             ServiceResourceInstance.Name = UserInstance.Name;
                             ServiceResourceInstance.RelatedRecordId = UserInstance.id;
                             ServiceResourceInstance.IsActive = true;
                             ServiceResourceInstance.ResourceType = 'A';
                             createServiceResourceSet.add(ServiceResourceInstance);
                         }
                     }
                 }
             }
             
             if(!createServiceResourceSet.isEmpty()){
                 createServiceResourcelist.addall(createServiceResourceSet);
                 database.insert (createServiceResourcelist,false);
             }
             
             //Fetch all service resources in the system including the ones we just created
             map<id,serviceresource> allserviceResourceMap = new  map<id,serviceresource>();
             for(serviceresource ServiceResourceInstance:[select id,RelatedRecordId,Name from ServiceResource where RelatedRecordId in:UserWithUpdatesNeededUserIdList]){
                 allserviceResourceMap.put(ServiceResourceInstance.RelatedRecordId,ServiceResourceInstance);
                 allserviceResourceInScopeIdList.add(ServiceResourceInstance.id);
             }
             
             //Map already existing 'service resource skill' records
             for(ServiceResourceskill ServiceResourceskillInstance:[select id,ServiceResourceId,skillid from ServiceResourceskill where ServiceResourceId in:allserviceResourceInScopeIdList]){
                 existingserviceResourceSkillMap.put(string.valueof(ServiceResourceskillInstance.ServiceResourceId)+';'+string.valueof(ServiceResourceskillInstance.skillid),ServiceResourceskillInstance.skillid);
             }
             
             
             //Loop though all users and assign skills for them
             integer m =1;
             for(m=1; m< srBodyList.size(); m++){
                 string SkillLabel = srBodyList[m].replaceAll('\"', '').trim().split(',')[0].trim();
                 skillLabel = skillLabel.normalizeSpace();
                 skillLabel = skillLabel.trim();
                 SkillLabel = SkillLabel.toUpperCase();
                 //Check if its a valid skill existing in the system
                 Id skillIdInstance = skillMap.get(SkillLabel);
                 if(string.isnotblank(skillIdInstance)){
                     list<string> userList = new list<string>();
                     string dataSize = srBodyList[m].replaceAll('"', '');
                     dataSize = dataSize.normalizespace();
                     dataSize = dataSize.trim();
                     Integer userSize =  dataSize.replaceAll('\"', '').trim().split(',').size();
                     integer j = 1;
                     
                     for(j=1;j<usersize;j++){
                         string data = srBodyList[m].replaceAll('"', '');
                         data = data.normalizespace();
                         data = data.trim();
                         data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                         string UsersMaerskUserId = data;
                         User UserInstance = UserWithUpdatesNeededMap.get(UsersMaerskUserId);  
                         if(UserInstance !=null){
                             if(allserviceResourceMap.containskey(UserInstance.id)){
                                 //Create the record only if the user does not have the skill yet
                                 ID userServiceResourceInstance = allserviceResourceMap.get(UserInstance.id).id;
                                 if(!existingserviceResourceSkillMap.containskey(string.valueof(userServiceResourceInstance)+';'+string.valueof(skillIdInstance))){
                                     //Create service resource skill instance and add to list to be inserted
                                     ServiceResourceSkill ServiceResourceSkillInstance = new ServiceResourceSkill(); 
                                     ServiceResourceSkillInstance.ServiceResourceId = allserviceResourceMap.get(UserInstance.id).id;  
                                     ServiceResourceSkillInstance.EffectiveStartDate = Date.today().addDays(-2);
                                     ServiceResourceSkillInstance.SkillId = skillIdInstance;
                                     createServiceResourceSkillset.add(ServiceResourceSkillInstance);
                                 }
                             }
                         }
                     }
                 }
                 
             }
             
             
             if(!createServiceResourceSkillset.isEmpty()){
                 createServiceResourceSkilllist.addall(createServiceResourceSkillset);
                 database.insert(createServiceResourceSkilllist,false);
             }
             return '';
            }catch(Exception e){
                system.debug(+e.getMessage()+' '+e.getLineNumber());
                return e.getMessage()+' '+e.getLineNumber();
            }
        
    }
    
    /** 
* @description | SC-7996 Adds Omni Supervisor and Omni presence Statuses to Users|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/ 
    public static string addPermissionsetToUsers(List<String> srBodyList,string methodName){
        
        try{List<PermissionSetAssignment> PermissionsetToUserslist = new List<PermissionSetAssignment>(); 
            Set<PermissionSetAssignment> PermissionsetToUsersSet = new Set<PermissionSetAssignment>(); 
            list<string> UserWithUpdatesNeededList = new list<string>();
            list<Id> UserWithUpdatesNeededUserIdList = new list<Id>();
            Map<string,user > UserWithUpdatesNeededMap = new Map<string,user>();
            Map<string,permissionset> allDevnameAndPermissionSetMap = new Map<string,permissionset>();
            Map<string,string> OmniSRNameMappingMap = new Map<string,string>();
            
            //Get a map of all existing permissions sets in the system
            for(permissionset permissionsetinstance:[select Name,id from permissionset]){
                allDevnameAndPermissionSetMap.put(permissionsetinstance.Name, permissionsetinstance);
            }
            
            //Get SR field and developerName Map
            for(General_Key_Value_Configurations__mdt GKVPInstance:[select id,First_Field_Name__c,First_Field_Value__c from General_Key_Value_Configurations__mdt where key__c = 'OmniSRNameMapping']){
                OmniSRNameMappingMap.put(GKVPInstance.First_Field_Name__c,GKVPInstance.First_Field_Value__c);
            }
            
            //Assign users to permission set when APM id of user is known/passed
            if (methodName == 'MaerskUserIdBased'){
                //Fetch all APM Id's of users who needs skill addition
                for(integer i=1; i< srBodyList.size(); i++){                   
                    list<string> userList = new list<string>();
                    string dataSize = srBodyList[i].replaceAll('"', '');
                    dataSize = dataSize.normalizespace();
                    dataSize = dataSize.trim();
                    Integer userSize =  dataSize.replaceAll('\"', '').trim().split(',').size();
                    Integer j = 1;
                    
                    for(j=1;j<usersize;j++){
                        string data = srBodyList[i].replaceAll('"', '');
                        data = data.normalizespace();
                        data = data.trim();
                        data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                        
                        string UsersMaerskUserId = data;
                        UserWithUpdatesNeededList.add(UsersMaerskUserId);
                    }
                }
                
                //Map APM id's of users with user records
                for(user userInstance:[select id,Maersk_User_Id__c,Name from user where Maersk_User_Id__c in:UserWithUpdatesNeededList]){
                    UserWithUpdatesNeededMap.put(userInstance.Maersk_User_Id__c,userInstance);
                    UserWithUpdatesNeededUserIdList.add(userInstance.id);
                }
                
                //Loop though the input and assign permissions to users
                integer i = 1;
                for(i=1; i< srBodyList.size(); i++){
                    list<string> userList = new list<string>();
                    string dataSize = srBodyList[i].replaceAll('"', '');
                    dataSize = dataSize.normalizespace();
                    dataSize = dataSize.trim();
                    Integer userSize =  dataSize.replaceAll('\"', '').trim().split(',').size();
                    integer j = 1;
                    
                    for(j=1;j<usersize;j++){
                        string data = srBodyList[i].replaceAll('"', '');
                        data = data.normalizespace();
                        data = data.trim();
                        data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                        userList.add(data);
                    }
                    for(string userIdInstance:userList){
                        string PermissionSetDevName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                        PermissionSetDevName = PermissionSetDevName.normalizeSpace();
                        PermissionSetDevName = PermissionSetDevName.trim();
                        if(UserWithUpdatesNeededMap.containskey(userIdInstance) && allDevnameAndPermissionSetMap.containskey(PermissionSetDevName)){
                            PermissionSetAssignment PermissionsetToUsersInstance = new PermissionSetAssignment();
                            PermissionsetToUsersInstance.AssigneeId = UserWithUpdatesNeededMap.get(userIdInstance).id;  
                            PermissionsetToUsersInstance.PermissionSetId = allDevnameAndPermissionSetMap.get(PermissionSetDevName).id;
                            PermissionsetToUsersSet.add(PermissionsetToUsersInstance);
                        }
                    }
                }                
            }
            
            //Assign users to permission set when SCV Code of account is known/passed
            else if (methodName == 'SCVcodeBased'){
                
                Map<id,string> accountAndAgentFieldMap = new Map<id,string>();
                Map<id,string> accountAndPermissionSetMap = new Map<id,string>();
                //Fetch all SVC codes of users who needs skill addition
                for(integer i=1; i< srBodyList.size(); i++){
                    string SCVcode = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    SCVcode = SCVcode.normalizeSpace();
                    SCVcode = SCVcode.trim();
                    UserWithUpdatesNeededList.add(SCvCode);
                }
                Map<string,account> associatedSCVcodeAndAccountMap = new map<string,account>();
                //Fetch all accounts who are part of provided SCV Codes
                for( Account acc :[select Id,scv_code__c, name from account where scv_code__c IN:UserWithUpdatesNeededList]){
                    associatedSCVcodeAndAccountMap.put(acc.scv_code__c,acc);
                }
               
                list<id> accountsInscope = new list<id>();
                for(integer i=1; i< srBodyList.size(); i++){
                    string careInstance = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    careInstance = careInstance.normalizeSpace();
                    careInstance = careInstance.trim();
                    string agentField = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                    agentField = agentField.normalizeSpace();
                    agentField = agentField.trim();
                    string PermissionSetDevName = srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim();
                    PermissionSetDevName = PermissionSetDevName.normalizeSpace();
                    PermissionSetDevName = PermissionSetDevName.trim();
                    
                    if(associatedSCVcodeAndAccountMap.containskey(careInstance)){
                        accountsInscope.add( associatedSCVcodeAndAccountMap.get(careInstance).id);
                        accountAndAgentFieldMap.put(associatedSCVcodeAndAccountMap.get(careInstance).id,agentField); 
                        accountAndPermissionSetMap.put(associatedSCVcodeAndAccountMap.get(careInstance).id,PermissionSetDevName);
                    }
                }
                
                for( Care_Relationship__c care :[select Id, Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c,Account_ID_Text__c, Account__c from Care_Relationship__c where Account__c =: accountsInscope]){
                    string customerServiceAgent = accountAndAgentFieldMap.get(care.Account__c);
                    customerServiceAgent = customerServiceAgent.normalizeSpace();
                    customerServiceAgent = customerServiceAgent.trim();
                    customerServiceAgent = OmniSRNameMappingMap.get(customerServiceAgent);
                    
                    id customerServiceAgentValue = (id) care.get(customerServiceAgent);
                    string PermissionSetDevName = accountAndPermissionSetMap.get(care.Account__c);
                    if(string.isnotblank(customerServiceAgentValue) && allDevnameAndPermissionSetMap.containskey(PermissionSetDevName)){
                        PermissionSetAssignment PermissionsetToUsersInstance = new PermissionSetAssignment();
                        PermissionsetToUsersInstance.AssigneeId = (id) care.get(customerServiceAgent);     
                        PermissionsetToUsersInstance.PermissionSetId = allDevnameAndPermissionSetMap.get(PermissionSetDevName).id;
                        PermissionsetToUsersSet.add(PermissionsetToUsersInstance);
                    }
                }
            }
            
            else {
                return 'Asssignment method is not valid' ;
            }           
            
            if(!PermissionsetToUsersSet.isEmpty()){
                PermissionsetToUserslist.addall(PermissionsetToUsersSet);
                //Partial Insert is done to skip already assigned users because areas may be unsure if agent who belonged to SR based routing may already have been onboarded
                database.insert(PermissionsetToUserslist,false);
            }
            return '';
           }catch(Exception e){
               system.debug('****e--->'+e.getMessage()+' '+e.getLineNumber());
               return e.getMessage()+' '+e.getLineNumber();
           }        
    }
    
    /** 
* @description | SC-7996 Add users to the correct presence config setup component|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/ 
    public static string presenceUserConfigUserUpsert(List<String> srBodyList,string methodName){
        
        try{requestBodyWrapper requestBodyWrapperInstance = new requestBodyWrapper();
            List<CompositeRequest> compositeRequestList = new List<CompositeRequest>();
            set<CompositeRequest> compositeRequestSet = new set<CompositeRequest>();
            Map<id,integer> userPresenceDeletionMap = new Map<id,integer>();
            set<id> userPresenceDeletionIdset = new set<id>();
            list<presenceUserconfigUser> userPresenceAdditionList = new list<presenceUserconfigUser>();
            Map<string,string> capacityAndPresenceConfigMap = new  Map<string,string> ();
            // list<string> UserWithUpdatesNeededList = new list<string>();
            Set<string> UserWithUpdatesNeededset = new set<string>();
            Map<id,integer> userCapacityMap = new Map<id,integer>();
            Map<id,integer> presenceConfigAndCapacityMap = new Map<id,integer>();
            list<id> UserWithUpdatesNeededIdSet = new list<id>();
            Map<string,user> UserWithUpdatesNeededMap = new Map<string,user>();        
            Map<string,string> OmniSRNameMapping = new Map<string,string>();
            String sessionId = '';
            
            if(!Test.isRunningTest()){
                sessionId = getSessionId();
            }
            else{
                sessionId = UserInfo.getSessionId();
            }
            
            //Get customer agent on SR object map
            for(General_Key_Value_Configurations__mdt OmniSRNameMappingInstance:[select First_Field_Value__c,First_Field_Name__c from General_Key_Value_Configurations__mdt where key__c = 'OmniSRNameMapping']){
                OmniSRNameMapping.put(OmniSRNameMappingInstance.First_Field_Name__c,OmniSRNameMappingInstance.First_Field_Value__c);
            }
            //Get all presence configs in the org
            for (PresenceUserConfig PresenceUserConfigUserInstance: [select id,capacity from PresenceUserConfig]){
                presenceConfigAndCapacityMap.put(PresenceUserConfigUserInstance.id,PresenceUserConfigUserInstance.capacity);
            }
            
            //Store a map of capacity and presence config of Auto-Accept
            for(General_Key_Value_Configurations__mdt capacityAndPresenceConfigInstance:[select Key__c,First_Field_Value__c from General_Key_Value_Configurations__mdt where label like 'OmniPresenceConfig%']){
                capacityAndPresenceConfigMap.put(capacityAndPresenceConfigInstance.Key__c,capacityAndPresenceConfigInstance.First_Field_Value__c);
            }     
            
            //Assign users to permission set when APM id of user is known/passed
            if (methodName == 'MaerskUserIdBased'){
                map<string,string> UserWithUpdatesNeededCapacityOverrideFlagMap = new map<string,string>();
                //Fetch all APM Id's of users who needs skill addition
                integer m = 1;
                for(m=1; m< srBodyList.size(); m++){                   
                    list<string> userList = new list<string>();
                    string dataSize = srBodyList[m].replaceAll('\"', '');
                    Integer userSize =  dataSize.replaceAll('"', '').trim().split(',').size();
                    Integer j = 2;
                    
                    for(j=2;j<usersize;j++){
                        string data = srBodyList[m].replaceAll('"', '');                      
                        data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                        data = data.normalizeSpace();
                        data = data.trim();
                        string UsersMaerskUserId = data;
                        UserWithUpdatesNeededSet.add(UsersMaerskUserId);
                        string capacityDetails = srBodyList[m].replaceAll('\"', '').trim().split(',')[0].trim()+';'+srBodyList[m].replaceAll('\"', '').trim().split(',')[1].trim();
                        UserWithUpdatesNeededCapacityOverrideFlagMap.put(UsersMaerskUserId,capacityDetails);
                    }
                }
                //Map APM id's of users with user records
                for(user userInstance:[select id,Maersk_User_Id__c,Name from user where Maersk_User_Id__c in:UserWithUpdatesNeededSet]){
                    UserWithUpdatesNeededMap.put(userInstance.Maersk_User_Id__c,userInstance);
                    UserWithUpdatesNeededIdSet.add(userInstance.id);
                }                
                Map<id,PresenceUserConfigUser> existingUserPresenceMap = new  Map<id,PresenceUserConfigUser> ();
                
                //For already existing users put them in new presence config considering their old capacities
                for (PresenceUserConfigUser PresenceUserConfigUserInstance:[select id,PresenceUserConfigId,userid from PresenceUserConfigUser where userid in: UserWithUpdatesNeededIdSet]) {
                    userPresenceDeletionIdset.add(PresenceUserConfigUserInstance.id);
                    Integer Capacity = presenceConfigAndCapacityMap.get(PresenceUserConfigUserInstance.PresenceUserConfigId);
                    
                    for(string PresenceCapacityInstance:capacityAndPresenceConfigMap.keySet()){
                        // Check for old capacity of the user and place them in the correct new Auto-Config appropriatly if overide of capacity is not request
                        if(Capacity == integer.valueof(PresenceCapacityInstance)){
                            PresenceUserConfigUser PresenceUserConfigUserAdditionInstance = new PresenceUserConfigUser();
                            PresenceUserConfigUserAdditionInstance.PresenceUserConfigId =  capacityAndPresenceConfigMap.get(PresenceCapacityInstance) ;
                            PresenceUserConfigUserAdditionInstance.userid = PresenceUserConfigUserInstance.userid;
                            existingUserPresenceMap.put(PresenceUserConfigUserAdditionInstance.userid,PresenceUserConfigUserAdditionInstance);
                        }                              
                    }
                }
                
                //Frame the deletion list, 200 records at a time is to be processed
                if(!userPresenceDeletionIdset.isempty()){
                    truncateListAndProcess200RecordsDeletion(userPresenceDeletionIdset,sessionid);
                    
                }
                
                integer i = 1;
                Integer n = 1;
                for(string userIdInScope:UserWithUpdatesNeededSet){
                    string CapacityValues= UserWithUpdatesNeededCapacityOverrideFlagMap.get(userIdInScope);
                    string userCapacityValue = '';
                    string userCapacityOverrideFlag = '';
                    userCapacityValue  = CapacityValues.replaceAll('\"', '').trim().split(';')[1].trim();
                    userCapacityOverrideFlag  = CapacityValues.replaceAll('\"', '').trim().split(';')[0].trim();
                    if(UserWithUpdatesNeededMap.containskey(userIdInScope)){
                        if(boolean.valueof(userCapacityOverrideFlag) == true){
                            
                            String capacity = userCapacityValue;
                            
                            CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
                            comp.method = 'POST';
                            comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
                            //comp.referenceId = String.valueOf(n);
                            PresenceUserConfigUserBody bod = new PresenceUserConfigUserBody();
                            bod.PresenceUserConfigId = capacityAndPresenceConfigMap.get(capacity);
                            bod.userid = UserWithUpdatesNeededMap.get(userIdInScope).id;
                            comp.body = bod;
                            compositeRequestSet.add(comp);                            
                            n++;
                        }
                        
                        //If override capacity option is not selected then consider his old capacity for assignment
                        else{
                            
                            CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
                            comp.method = 'POST';
                            comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
                            // comp.referenceId = String.valueOf(n);
                            
                            //Move the user to the corresponding Auto-Accept config considering his old capacity
                            Id userid = UserWithUpdatesNeededMap.get(userIdInScope).id; 
                            if(existingUserPresenceMap.containskey(userid)){
                                string existingPresenceConfigId = existingUserPresenceMap.get(userid).PresenceUserConfigId;
                                string capacity = string.valueof(presenceConfigAndCapacityMap.get(existingPresenceConfigId));
                                
                                
                                if(capacityAndPresenceConfigMap.containskey(capacity)){
                                    PresenceUserConfigUserBody  bod = new PresenceUserConfigUserBody();
                                    
                                    bod.PresenceUserConfigId = capacityAndPresenceConfigMap.get(capacity);
                                    bod.UserId = existingUserPresenceMap.get(userid).Userid;
                                    comp.body = bod;
                                    compositeRequestSet.add(comp);
                                    n++;
                                }    
                                
                            }
                            
                            else{                                   
                                Id userid2 = UserWithUpdatesNeededMap.get(userIdInScope).id; 
                                PresenceUserConfigUserBody  bod = new PresenceUserConfigUserBody();
                                bod.PresenceUserConfigId =  capacityAndPresenceConfigMap.get('8');
                                bod.UserId = Userid2;
                                comp.body = bod;
                                compositeRequestSet.add(comp);
                                n++;
                            }
                            
                        }
                        
                    }          
                    
                }
                
            }
            
            //Assign users to permission set when SCV Code of account is known/passed
            else if (methodName == 'SCVcodeBased'){
                Map<id,string> accountAndAgentFieldMap = new Map<id,string>();
                Map<id,string>accountAndCapacityMap    = new  Map<id,string>();
                Map<id,string> accountAndCapacityOverrideFlagMap = new  Map<id,string>();
                map<string,string> UserWithUpdatesNeededCapacityOverrideFlagMap = new map<string,string>();
                list<id> associatedAccountIds = new list<id>();
                Map<string,account> associatedSCVcodeAndAccountMap = new map<string,account>();
                
                //Fetch all SVC codes of users who needs skill addition
                for(integer i=1; i< srBodyList.size(); i++){
                    string SCVcode = srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim();
                    SCVcode = SCVcode.normalizeSpace();
                    SCVcode = SCVcode.trim();                    
                    UserWithUpdatesNeededset.add(SCvCode);
                    
                }
                
                //Fetch all accounts associated with the SCV codes passed by user
                for( Account acc :[select Id,scv_code__c from account where scv_code__c IN:UserWithUpdatesNeededset]){
                    associatedSCVcodeAndAccountMap.put(acc.scv_code__c,acc);
                    associatedAccountIds.add(acc.id);
                }
                
                //Fetch all customer agents user of the SR which belongs to the accounts associated with the SCV codes passed by user
                for(integer i=1; i< srBodyList.size(); i++){
                    string customerServiceAgentName = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                    customerServiceAgentName = customerServiceAgentName.normalizeSpace();
                    customerServiceAgentName = customerServiceAgentName.trim();
                    string customerServiceAgentDevName = OmniSRNameMapping.get(customerServiceAgentName);
                    
                    string SCVcode = srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim();
                    SCVcode = SCVcode.normalizeSpace();
                    SCVcode = SCVcode.trim();
                    
                    string capacity = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                    capacity = capacity.normalizeSpace();
                    capacity = capacity.trim();
                    
                    string capacityOverrideFlag = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    capacityOverrideFlag = capacityOverrideFlag.normalizeSpace();
                    capacityOverrideFlag = capacityOverrideFlag.trim();
                    if(associatedSCVcodeAndAccountMap.containskey(SCVcode)){
                        accountAndAgentFieldMap.put(associatedSCVcodeAndAccountMap.get(SCVcode).id,customerServiceAgentDevName); 
                        accountAndCapacityMap.put(associatedSCVcodeAndAccountMap.get(SCVcode).id,capacity); 
                        accountAndCapacityOverrideFlagMap.put(associatedSCVcodeAndAccountMap.get(SCVcode).id,capacityOverrideFlag); 
                    }
                }
                
                for( Care_Relationship__c care :[select Id, Care_Business_Partner__c,GSC_Agent__c,Frontline_backup__c,Account_ID_Text__c from Care_Relationship__c where Account_ID_Text__c =:associatedAccountIds]){
                    string customerServiceAgent = accountAndAgentFieldMap.get(care.Account_ID_Text__c); 
                    id customerServiceAgentValue = (id) care.get(customerServiceAgent);
                    if(string.isNotBlank(customerServiceAgentValue)){
                        UserWithUpdatesNeededIdSet.add((id) care.get(customerServiceAgent)); 
                        string capacityDetails = accountAndCapacityMap.get(care.Account_ID_Text__c)+';'+accountAndCapacityOverrideFlagMap.get(care.Account_ID_Text__c);
                        UserWithUpdatesNeededCapacityOverrideFlagMap.put(customerServiceAgentValue,capacityDetails);
                    }
                }
                
                Map<id,string> userAndAPMIdMap = new Map<id,string>();
                for(user u: [select id,maersk_user_id__c from user where id in:UserWithUpdatesNeededIdSet ]){
                    userAndAPMIdMap.put(u.id,u.maersk_user_id__c);
                }
                
                Map<id,PresenceUserConfigUser> existingUserPresenceMap = new  Map<id,PresenceUserConfigUser> ();
                
                //For already existing users put them in new presence config considering their old capacities
                for (PresenceUserConfigUser PresenceUserConfigUserInstance:[select id,PresenceUserConfigId,userid from PresenceUserConfigUser where userid in: UserWithUpdatesNeededIdSet]) {
                    userPresenceDeletionIdset.add(PresenceUserConfigUserInstance.id);
                    Integer Capacity = presenceConfigAndCapacityMap.get(PresenceUserConfigUserInstance.PresenceUserConfigId);
                    
                    for(string PresenceCapacityInstance:capacityAndPresenceConfigMap.keySet()){
                        // Check for old capacity of the user and place them in the correct new Auto-Config appropriatly if overide of capacity is not requested
                        if(Capacity == integer.valueof(PresenceCapacityInstance)){
                            PresenceUserConfigUser PresenceUserConfigUserAdditionInstance = new PresenceUserConfigUser();
                            PresenceUserConfigUserAdditionInstance.PresenceUserConfigId =  capacityAndPresenceConfigMap.get(PresenceCapacityInstance) ;
                            PresenceUserConfigUserAdditionInstance.userid = PresenceUserConfigUserInstance.userid;
                            existingUserPresenceMap.put(PresenceUserConfigUserAdditionInstance.userid,PresenceUserConfigUserAdditionInstance);
                        }                              
                    }
                }
                
                if(!userPresenceDeletionIdset.isempty()){
                    truncateListAndProcess200RecordsDeletion(userPresenceDeletionIdset,sessionid);                    
                }
                Integer n =1;
                Integer i= 1;
                for(id userIdInScope:UserWithUpdatesNeededIdSet){
                    string userAPMId = userAndAPMIdMap.get(userIdInScope);
                    string CapacityValues= UserWithUpdatesNeededCapacityOverrideFlagMap.get(userIdInScope);
                    string userCapacityValue = '';
                    string userCapacityOverrideFlag = '';
                    userCapacityValue  = CapacityValues.replaceAll('\"', '').trim().split(';')[1].trim();
                    userCapacityOverrideFlag  = CapacityValues.replaceAll('\"', '').trim().split(';')[0].trim();
                    if(boolean.valueof(userCapacityOverrideFlag) == true){                            
                        String capacity = userCapacityValue;
                        
                        CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
                        comp.method = 'POST';
                        comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
                        PresenceUserConfigUserBody bod = new PresenceUserConfigUserBody();
                        bod.PresenceUserConfigId = capacityAndPresenceConfigMap.get(capacity);
                        bod.userid = userIdInScope;
                        comp.body = bod;
                        compositeRequestSet.add(comp);                            
                        n++;
                    }
                    
                    //If override capacity option is not selected then consider his old capacity for assignment
                    else{
                        
                        CompositeRequest comp = new CompositeRequest('PresenceUserConfigUserAddition');
                        comp.method = 'POST';
                        comp.url = '/services/data/v55.0/sobjects/PresenceUserConfigUser';
                        
                        //Move the user to the corresponding Auto-Accept config considering his old capacity
                        if(existingUserPresenceMap.containskey(userIdInScope)){
                            string existingPresenceConfigId = existingUserPresenceMap.get(userIdInScope).PresenceUserConfigId;
                            string capacity = string.valueof(presenceConfigAndCapacityMap.get(existingPresenceConfigId));
                            
                            if(capacityAndPresenceConfigMap.containskey(capacity)){
                                PresenceUserConfigUserBody  bod = new PresenceUserConfigUserBody();                                    
                                bod.PresenceUserConfigId = capacityAndPresenceConfigMap.get(capacity);
                                bod.UserId = existingUserPresenceMap.get(userIdInScope).Userid;
                                comp.body = bod;
                                compositeRequestSet.add(comp);
                                n++;
                            }    
                            
                        }
                        
                        else{                                   
                            PresenceUserConfigUserBody  bod = new PresenceUserConfigUserBody();
                            bod.PresenceUserConfigId =  capacityAndPresenceConfigMap.get('8');
                            bod.UserId = userIdInScope;
                            comp.body = bod;
                            compositeRequestSet.add(comp);
                            n++;        
                        }
                        
                    }
                }
            }
            
            else {
                return 'Asssignment method is not valid' ;
            }
            
            if(!compositeRequestSet.isempty()){
                compositeRequestList.addall(compositeRequestset);
                truncateListAndProcess(compositeRequestList,sessionId);
            }
            
            return '';
           }catch(Exception e){
               return e.getMessage()+' '+e.getLineNumber();
           }
    }
    
    
    /** 
* @description | SC-7996 Adds Users/Groups into Omni supervisor Config setup|
* @param srBodyList accepts the XL file uploaded in list<string> format
* @param methodType accepts a string which indicates what type of insertion is needed
*/
    public static string addUserOrGroupToOmniSupervisorConfig(List<String> srBodyList,string methodType){
        
        try{
            list<OmniSupervisorConfigUser> OmniSupervisorConfigUserInsertList = new list<OmniSupervisorConfigUser>();
            list<OmniSupervisorConfigGroup> OmniSupervisorConfigGroupInsertList = new list<OmniSupervisorConfigGroup>();
            String sessionId = '';
            list<CompositeRequest> compositeRequestList = new list<CompositeRequest>();
            
            if(!Test.isRunningTest()){
                sessionId = getSessionId();
            }
            else{
                sessionId = UserInfo.getSessionId();
            }
            
            if(methodType == 'groupBased'){
                list<String> omniSupervisorConfigDevnameInScope = new list<String> ();
                list<String> omniGroupDevnameInScope = new list<String>();
                Map<string,OmniSupervisorConfig> existingOmniSupervisorConfigInScopeMap = new Map<string,OmniSupervisorConfig>();
                Map<string,group>  existingGroupInScopeMap = new Map<string,group>();
                
                //List all requested dev names
                for(integer i=1; i< srBodyList.size(); i++){
                    string omniGroupDevnameInScopeName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    omniGroupDevnameInScopeName = omniGroupDevnameInScopeName.normalizeSpace();
                    omniGroupDevnameInScopeName = omniGroupDevnameInScopeName.trim();
                    omniGroupDevnameInScope.add(omniGroupDevnameInScopeName);
                    string omniSupervisorConfigDevnameInScopeName = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                    omniSupervisorConfigDevnameInScopeName = omniSupervisorConfigDevnameInScopeName.normalizeSpace();
                    omniSupervisorConfigDevnameInScopeName = omniSupervisorConfigDevnameInScopeName.trim();
                    omniSupervisorConfigDevnameInScope.add(omniSupervisorConfigDevnameInScopeName);
                }              
                
                //Get the group from system which is part of the request
                for(Group groupInstance: [select id,developername,type from group where developername in:omniGroupDevnameInScope]){
                    existingGroupInScopeMap.put(groupInstance.developername,groupInstance);
                }
                
                //Get the Omnisupervisor config from system which is part of the request
                for(OmniSupervisorConfig OmniSupervisorConfigInstance: [select id,developername from OmniSupervisorConfig where developername in:omniSupervisorConfigDevnameInScope]){
                    existingOmniSupervisorConfigInScopeMap.put(OmniSupervisorConfigInstance.developername,OmniSupervisorConfigInstance);
                }
                
                
                for(integer i=1; i< srBodyList.size(); i++){         
                    omniSupervisorConfigGroupAdditionBody bod = new omniSupervisorConfigGroupAdditionBody();
                    OmniSupervisorConfigGroup OmniSupervisorConfigGroupInstance = new OmniSupervisorConfigGroup(); 
                    
                    CompositeRequest comp = new CompositeRequest('omniSupervisorConfigGroupAddition');
                    comp.method = 'POST';
                    comp.url = '/services/data/v55.0/sobjects/omniSupervisorConfigGroup';
                    comp.referenceId = String.valueOf(i);
                    
                    string groupDevName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    groupDevName = groupDevName.normalizeSpace();
                    groupDevName = groupDevName.trim();
                    bod.groupId = existingGroupInScopeMap.get(groupDevName).id;
                    string configDevName = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                    configDevName = configDevName.normalizeSpace();
                    configDevName = configDevName.trim();
                    if(existingOmniSupervisorConfigInScopeMap.containskey(configDevName)){
                        bod.OmniSupervisorConfigId = existingOmniSupervisorConfigInScopeMap.get(configDevName).id;
                        comp.body = bod;
                        compositeRequestList.add(comp);
                    }
                    
                    
                }
                if(!compositeRequestList.isempty()){
                    truncateListAndProcess(compositeRequestList,sessionId);
                }
            }
            
            else if(methodType == 'userBased'){         
                list<String> omniSupervisorConfigDevnameInScope = new list<String> ();
                list<String> omniUserIdInScope = new list<String>();
                list<string> UserWithUpdatesNeededList = new list<string>();
                Map<string,user> UserWithUpdatesNeededMap = new Map<string,user>();
                
                //Fetch all APM Id's of users who needs skill addition
                integer m = 1;
                for(m=1; m< srBodyList.size(); m++){                   
                    list<string> userList = new list<string>();
                    string dataSize = srBodyList[m].replaceAll('\"', '');
                    Integer userSize =  dataSize.replaceAll('"', '').trim().split(',').size();
                    Integer j = 1;
                    
                    for(j=1;j<usersize;j++){
                        string data = srBodyList[m].replaceAll('"', '');                      
                        data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                        data = data.normalizeSpace();
                        data = data.trim();
                        string UsersMaerskUserId = data;
                        UserWithUpdatesNeededList.add(UsersMaerskUserId);
                    }
                }
                
                list<id> UserWithUpdatesNeededIdList = new list<id>();
                //Map APM id's of users with user records
                for(user userInstance:[select id,Maersk_User_Id__c,Name from user where Maersk_User_Id__c in:UserWithUpdatesNeededList]){
                    UserWithUpdatesNeededMap.put(userInstance.Maersk_User_Id__c,userInstance);                    
                    UserWithUpdatesNeededIdList.add(userInstance.id);
                }
                
                for(integer i=1; i< srBodyList.size(); i++){
                    string  omniSupervisorConfigDevnameInScopeName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                    omniSupervisorConfigDevnameInScopeName = omniSupervisorConfigDevnameInScopeName.normalizeSpace();
                    omniSupervisorConfigDevnameInScopeName = omniSupervisorConfigDevnameInScopeName.trim();
                    omniSupervisorConfigDevnameInScope.add(omniSupervisorConfigDevnameInScopeName);
                }
                
                set<id> userOmniConfigDeletionIdset = new set<id>();
                for(omniSupervisorConfiguser omniSupervisorConfiguserInstance:[select id from omniSupervisorConfiguser where userid in:UserWithUpdatesNeededIdList]){
                    userOmniConfigDeletionIdset.add(omniSupervisorConfiguserInstance.id);
                }
                
                //Code piece to remove users from old omni config cause they can be put into new ones only if they are removed from old configs
                if(!userOmniConfigDeletionIdset.isempty()){
                    truncateListAndProcess200RecordsDeletion(userOmniConfigDeletionIdset,sessionid);
                }
                
                Map<string,OmniSupervisorConfig> existingOmniSupervisorConfigInScopeMap = new Map<string,OmniSupervisorConfig>();
                
                for(OmniSupervisorConfig OmniSupervisorConfigInstance: [select id,developername from OmniSupervisorConfig where developername in:omniSupervisorConfigDevnameInScope]){
                    existingOmniSupervisorConfigInScopeMap.put(OmniSupervisorConfigInstance.developername,OmniSupervisorConfigInstance);
                }
                
                integer i = 1;
                integer n = 1;
                for(i=1; i< srBodyList.size(); i++){
                    
                    list<string> userList = new list<string>();
                    string dataSize = srBodyList[i].replaceAll('"', '');
                    dataSize = dataSize.normalizespace();
                    dataSize = dataSize.trim();
                    Integer userSize =  dataSize.replaceAll('\"', '').trim().split(',').size();
                    integer j = 1;
                    
                    for(j=1;j<usersize;j++){
                        string data = srBodyList[i].replaceAll('"', '');
                        data = data.normalizespace();
                        data = data.trim();
                        data = data.replaceAll('\"', '').trim().split(',')[j].trim();
                        
                        omniSupervisorConfigUserAdditionBody bod = new omniSupervisorConfigUserAdditionBody();
                        CompositeRequest comp = new CompositeRequest('omniSupervisorConfigUserAddition');
                        comp.method = 'POST';
                        comp.url = '/services/data/v55.0/sobjects/omniSupervisorConfigUser';
                        comp.referenceId = String.valueOf(n);
                        
                        string userMaerskUserId = data;
                        if(UserWithUpdatesNeededMap.containskey(userMaerskUserId)){
                            string configDevName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                            configDevName = configDevName.normalizeSpace();
                            configDevName = configDevName.trim();
                            if(existingOmniSupervisorConfigInScopeMap.containskey(configDevName)){ 
                                bod.UserId = UserWithUpdatesNeededMap.get(userMaerskUserId).id;
                                bod.OmniSupervisorConfigId = existingOmniSupervisorConfigInScopeMap.get(configDevName).id;
                                comp.body = bod;
                                compositeRequestList.add(comp);
                                n++;
                            }
                        }
                    }
                }
                
                if(!compositeRequestList.isempty()){
                    truncateListAndProcess(compositeRequestList,sessionId);
                }
            }
            
            return '';
        }catch(Exception e){
            if(e.getMessage() != 'IO Exception: Read timed out'){
                system.debug('Myerror '+e.getMessage()+' '+e.getLineNumber());
                return e.getMessage()+' '+e.getLineNumber();
            }
            else{
                return '';
            }
        }
    }
    
    
    /** 
* @description | SC-7996 Adds CaseOmniMappings custom object records into the system|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/
    public static string addCaseOmniMappingsRecords(List<String> srBodyList){
        
        try{         
            
            String omniSkillMappingBooleanFields  = label.OmniSkillMappingBooleanFields; //Fields where Values to be updated as true for boolean fields.
            List<String> additionalSkillList  = new List<String>();
            List<Case_OmniSkill_Mappings__c> CaseOmniSkillMappingslist = new List<Case_OmniSkill_Mappings__c>();
            List<Case_OmniSkill_Mappings__c> CaseOmniSkillMappingsSet = new List<Case_OmniSkill_Mappings__c>();
            Map<string,string> omniSkillCaseFieldMap = new Map<string,string>();
            Map<string,skill> skillMap = new Map<string,skill>();
            for(skill skillInstance:[select id,masterLabel from skill]){
                string skillName = skillInstance.MasterLabel;
                skillName = skillName.normalizeSpace();
                skillName = skillName.trim();
                skillMap.put(skillName.toUpperCase(),skillInstance);
            }            
            for(General_Key_Value_Configurations__mdt omniSkillCaseFieldMapInstance:[select first_field_value__c,first_field_name__c from General_Key_Value_Configurations__mdt where key__c = 'CaseOmniSkillMappingsCaseField']){
                omniSkillCaseFieldMap.put(omniSkillCaseFieldMapInstance.first_field_name__c,omniSkillCaseFieldMapInstance.first_field_value__c);
            }
            
            for(integer i=1; i< srBodyList.size(); i++){
                string skillId1 = '';
                string skillId2 = '';
                
                Case_OmniSkill_Mappings__c CaseOmniSkillMappingsInstance = new Case_OmniSkill_Mappings__c();
                String casefieldInScope = srBodyList[i].replaceAll('\"', '').trim().split(',')[4].trim();
                casefieldInScope = casefieldInScope.normalizeSpace();
                casefieldInScope = casefieldInScope.trim();
                
                string CaseOmniSkillName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                CaseOmniSkillName = CaseOmniSkillName.normalizeSpace();
                CaseOmniSkillName = CaseOmniSkillName.trim();
                CaseOmniSkillMappingsInstance.Name =  CaseOmniSkillName;
                
                CaseOmniSkillMappingsInstance.Developer_Name__c = CaseOmniSkillMappingsInstance.Name; 
                
                String channelName = srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim();
                channelName = channelName.normalizeSpace();
                channelName = channelName.trim();
                
                CaseOmniSkillMappingsInstance.Channel__c = channelName;
                if(casefieldInScope == 'Queue'){
                    string valueInstance = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                    string valueInstanceRemoveWhiteSpace = valueInstance.normalizespace();
                    valueInstanceRemoveWhiteSpace = valueInstanceRemoveWhiteSpace.trim();
                    // valueInstanceRemoveWhiteSpace = valueInstanceRemoveWhiteSpace.deletewhitespace();
                    string valueInstanceRemoveAddtionalChar = valueInstanceRemoveWhiteSpace.replaceAll('-', '_');
                    CaseOmniSkillMappingsInstance.Value__c = 'Case_'+valueInstanceRemoveAddtionalChar;
                }
                else{
                    String skillName = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                    skillName = skillName.toUpperCase();
                    skillName = skillName.normalizeSpace();
                    skillName = skillName.trim();
                    if(skillMap.containskey(skillName)){
                        //logic to update value as 'true' for boolean fields 
                        CaseOmniSkillMappingsInstance.Value__c = omniSkillMappingBooleanFields.containsIgnoreCase(skillMap.get(skillName).MasterLabel) ? 'true' : skillMap.get(skillName).MasterLabel;
                    }
                }
                
                
                String skillName = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                skillName = skillName.toUpperCase();
                skillName = skillName.normalizeSpace();
                skillName = skillName.trim();
                if(skillMap.containskey(skillName)){
                    CaseOmniSkillMappingsInstance.Skill_Id__c = skillMap.get(skillName).id;
                    skillId1 = skillMap.get(skillName).id;
                    CaseOmniSkillMappingsInstance.Active__c = true;
                    CaseOmniSkillMappingsInstance.Case_Field__c = omniSkillCaseFieldMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[4].trim());
                    string originName =  srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                    originName = originName.normalizeSpace();
                    originName = originName.trim();
                    String Origin = originName;
                    
                    CaseOmniSkillMappingsInstance.Origin__c = LinerBrand_Direction_and_Country__mdt.getInstance(Origin).label;
                    if(casefieldInScope == 'Queue'){
                        CaseOmniSkillMappingsInstance.Mandatory__c =  true;
                    }
                    else{
                        CaseOmniSkillMappingsInstance.Mandatory__c =  false;
                    }             
                    
                }                    
                string fieldNameFormatted = srBodyList[i].replaceAll('\"', '').trim().split(',')[5].trim();
                fieldNameFormatted = fieldNameFormatted.normalizeSpace();
                fieldNameFormatted = fieldNameFormatted.trim();
                String fieldName = fieldNameFormatted;                   
                if(fieldName!='NA'){
                    String skillName2 = srBodyList[i].replaceAll('\"', '').trim().split(',')[5].trim();
                    skillName2 = skillName2.toUpperCase();
                    skillName2 = skillName2.normalizeSpace();
                    skillName2 = skillName2.trim();
                    if(skillMap.containskey(skillName2)){
                        CaseOmniSkillMappingsInstance.Value_2__c = skillMap.get(skillName2).MasterLabel;
                        skillId2 =  skillMap.get(skillName2).id;                       
                        CaseOmniSkillMappingsInstance.skill_id__c = skillId1+';'+skillId2;
                    }
                    //adding additional skills for cases of types Non Short transit, non dangerous cargo cases, etc
                    String skillName3 = srBodyList[i].replaceAll('\"', '').trim().split(',')[7].trim();
                    String additionalSkills = '';
                    additionalSkillList.addAll(skillName3.split(';'));
                    if(skillName3!= 'NA'){
                        for(String additionalSkillsTemp : additionalSkillList){
                            if(skillMap.containskey(additionalSkillsTemp.toUpperCase())){
                                additionalSkills+= ';' + skillMap.get(additionalSkillsTemp.toUpperCase()).id;
                            }/*else if(skillMap.containskey(additionalSkillsTemp.toUpperCase()) && additionalSkills != null){
additionalSkills = additionalSkills + ';' + skillMap.get(additionalSkillsTemp.toUpperCase()).id;
}*/
                        }
                    }
                    
                    //SC-10084
                    String vesselJourneyLeg = srBodyList[i].replaceAll('\"', '').trim().split(',')[8].trim();
                    if(vesselJourneyLeg != 'NA'){
                        CaseOmniSkillMappingsInstance.Vessel_Journey_Leg__c = vesselJourneyLeg;
                    }
                    
                    //add additional skills to the Skill id field
                    if(additionalSkills != null && additionalSkills != '')
                    {
                        CaseOmniSkillMappingsInstance.skill_id__c = CaseOmniSkillMappingsInstance.skill_id__c + additionalSkills;
                    }
                    
                }
                CaseOmniSkillMappingsInstance.Case_Field_2__c = omniSkillCaseFieldMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[6].trim());               
                CaseOmniSkillMappingsSet.add(CaseOmniSkillMappingsInstance);
            }
            if(!CaseOmniSkillMappingsSet.isEmpty()){
                CaseOmniSkillMappingslist.addall(CaseOmniSkillMappingsSet);
                database.insert(CaseOmniSkillMappingslist,false);  
            }
            return '';
        }catch(Exception e){
            system.debug('Omni error---->'+e.getMessage()+' LN: '+e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }
        
    }
    
    
    /** 
* @description | SC-7996 Adds records of custom object type OmniServiceRelationshipExclusion|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/
    public static string createOmniServiceRelationshipmappings(List<String> srBodyList){
        
        try{
            Set<Omni_Service_Relationship_Mappings__c	> OmniServiceRelationshipMappingsSet = new Set<Omni_Service_Relationship_Mappings__c>();
            list<Omni_Service_Relationship_Mappings__c	> OmniServiceRelationshipMappingslist = new list<Omni_Service_Relationship_Mappings__c>();
            Map<string,string> OmniServiceRelationshipMappingsAgentMap = new Map<string,string>();
            
            //Map the Omni Service Relationship Mappings Agents to their API name
            for(General_Key_Value_Configurations__mdt OmniServiceRelationshipMappingsAgentMapInstance:[select first_field_value__c,first_field_name__c from General_Key_Value_Configurations__mdt where key__c = 'OmniServiceRelationshipMappingsAgentMap']){
                OmniServiceRelationshipMappingsAgentMap.put(OmniServiceRelationshipMappingsAgentMapInstance.first_field_name__c,OmniServiceRelationshipMappingsAgentMapInstance.first_field_value__c);
            }
            
            for(integer i=1; i< srBodyList.size(); i++){
                Omni_Service_Relationship_Mappings__c OmniServiceRelationshipMappingsInstance = new Omni_Service_Relationship_Mappings__c();
                string OmniServiceRelationshipMappingsInstanceName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                OmniServiceRelationshipMappingsInstanceName = OmniServiceRelationshipMappingsInstanceName.normalizeSpace();
                OmniServiceRelationshipMappingsInstanceName = OmniServiceRelationshipMappingsInstanceName.trim();
                OmniServiceRelationshipMappingsInstance.Name = OmniServiceRelationshipMappingsInstanceName;
                
                string originName = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                originName = originName.normalizeSpace();
                originName = originName.trim();
                string origin = originName;
                OmniServiceRelationshipMappingsInstance.Origin__c = LinerBrand_Direction_and_Country__mdt.getInstance(Origin).label;     
                OmniServiceRelationshipMappingsInstance.Active__c = Boolean.valueof(srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim());
                
                string OmniServiceRelationshipMappingsAgentname = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                OmniServiceRelationshipMappingsAgentname = OmniServiceRelationshipMappingsAgentname.normalizeSpace();
                OmniServiceRelationshipMappingsAgentname = OmniServiceRelationshipMappingsAgentname.trim();
                if(OmniServiceRelationshipMappingsAgentMap.containskey(OmniServiceRelationshipMappingsAgentname)){
                    OmniServiceRelationshipMappingsInstance.Preferred_Agent__c = OmniServiceRelationshipMappingsAgentMap.get(OmniServiceRelationshipMappingsAgentname);
                    if(srBodyList[i].replaceAll('\"', '').trim().split(',').size()== 6){
                        string subTypeValue = srBodyList[i].replaceAll('\"', '').trim().split(',')[4].trim();
                        if(string.isnotblank(subTypeValue)){
                            subTypeValue = subTypeValue.normalizeSpace();
                            subTypeValue = subTypeValue.trim();
                        }
                        if(subTypeValue!= 'NA'){
                            OmniServiceRelationshipMappingsInstance.Sub_Type__c = subTypeValue;
                        }
                        
                        string rfcValue = srBodyList[i].replaceAll('\"', '').trim().split(',')[5].trim();
                        if(string.isnotblank(rfcValue)){
                            rfcValue = rfcValue.normalizeSpace();
                            rfcValue = rfcValue.trim();
                        }
                        if(rfcValue!= 'NA'){
                            OmniServiceRelationshipMappingsInstance.Reason_for_Case__c = rfcValue;
                        }
                    }
                    
                    OmniServiceRelationshipMappingsSet.add(OmniServiceRelationshipMappingsInstance);
                }
            }
            if(!OmniServiceRelationshipMappingsSet.isEmpty()){
                OmniServiceRelationshipMappingslist.addall(OmniServiceRelationshipMappingsSet);
                database.insert(OmniServiceRelationshipMappingslist,false);
            }
            return '';
        }catch(Exception e){
            system.debug('omni----->'+ e.getMessage()+' LN '+ e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }       
    }
    
    
    /*public static string createOmniClientCaseAssignments(List<String> srBodyList){
        try{
           Set<Client_Case_Assignments__c> omniSet = new Set<Client_Case_Assignments__c>();
           list<Client_Case_Assignments__c> omnilist = new list<Client_Case_Assignments__c>();
           List<String> fieldNames = new List<String>();
           Map<String, String> oBAccountIdMap = new Map<String, String>();
           Map<String, String> geoCodeIdMap = new Map<String, String>();
           Map<String, String> dedicatedAgentIdMap = new Map<String, String>();
           Map<String, String> backUpAgentIdMap = new Map<String, String>();
           Set<String> maerskUserIds = new Set<String>();


           fieldNames.addALL(srBodyList[0].replaceAll('\"', '').replaceAll('\'','').trim().split(','));
           Integer indexOfAccount = fieldNames.IndexOf('Account');
           Integer indexOfActive = fieldNames.IndexOf('Active');
           Integer indexOfBackUpAgent = fieldNames.IndexOf('Back up Dedicated Agent');
           Integer indexOfDedicatedAgent = fieldNames.IndexOf('Dedicated Agent');
           Integer indexOfDirection = fieldNames.IndexOf('Direction');
           Integer indexOfCountry = fieldNames.IndexOf('Country');
           Integer indexOfSubType = fieldNames.IndexOf('Sub Type');
           Integer indexOfName = fieldNames.IndexOf('Name');
            
           for(integer i=1; i< srBodyList.size(); i++){
            Client_Case_Assignments__c omniClientCaseAssignmentsInstance = new Client_Case_Assignments__c();
            if(fieldNames.contains('Account') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfAccount].trim() != null){
                    oBAccountIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfAccount].trim(), null);
                }
            if(fieldNames.contains('Country') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfCountry].trim() != null ){
                    geoCodeIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfCountry].trim(), null);
              }
             if(fieldNames.contains('Dedicated Agent') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfDedicatedAgent].trim() != null ){
                    dedicatedAgentIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfDedicatedAgent].trim(), null);
              }
             if(fieldNames.contains('Back up Dedicated Agent') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfBackUpAgent].trim() != null ){
                    backUpAgentIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfBackUpAgent].trim(), null);
              }
               maerskUserIds.addAll(dedicatedAgentIdMap.keySet());
           maerskUserIds.addAll(backUpAgentIdMap.keySet());
            if(!oBAccountIdMap.isEmpty()){
                for(Account acc : [Select Id, Name, SCV_Code__c From Account Where SCV_Code__c=: oBAccountIdMap.keySet()]){
                    oBAccountIdMap.put(acc.SCV_Code__C, acc.Id);
                    
                }
            }
            if(!geoCodeIdMap.isEmpty()){
                for(Geography__c  gcc : [Select Id, Geo_Code__c, Geo_Id__c From Geography__c Where GEO_Code__c=: geoCodeIdMap.keySet() and Type_Of_Location__c ='Country']){
                    geoCodeIdMap.put(gcc.GEO_Code__c, gcc.Id);
                }
            }
            if (!maerskUserIds.isEmpty()) {
                   for (User userInstance : [SELECT Id, Maersk_User_Id__c, Name FROM User WHERE Maersk_User_Id__c IN :maerskUserIds]) {
                       if (dedicatedAgentIdMap.containsKey(userInstance.Maersk_User_Id__c)) {
                           dedicatedAgentIdMap.put(userInstance.Maersk_User_Id__c, userInstance.Id);
                       }
                       if (backUpAgentIdMap.containsKey(userInstance.Maersk_User_Id__c)) {
                           backUpAgentIdMap.put(userInstance.Maersk_User_Id__c, userInstance.Id);
                       }
                   }
              }
            string omniClientCaseAssignmentsInstanceName = srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfName].trim();
            omniClientCaseAssignmentsInstanceName = omniClientCaseAssignmentsInstanceName.normalizeSpace();
            omniClientCaseAssignmentsInstanceName = omniClientCaseAssignmentsInstanceName.trim();
            omniClientCaseAssignmentsInstance.Name = omniClientCaseAssignmentsInstanceName;
            String subtypeValue = srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfSubType].trim();
            String directionValue = srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfDirection].trim();

               
            omniClientCaseAssignmentsInstance.Active__c = Boolean.valueof(srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfActive].trim());
            omniClientCaseAssignmentsInstance.Account__c= oBAccountIdMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfAccount].trim());
            omniClientCaseAssignmentsInstance.Dedicated_Agent__c=dedicatedAgentIdMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfDedicatedAgent].trim());
            omniClientCaseAssignmentsInstance.Back_up_Dedicated_Agent__c=backUpAgentIdMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfBackUpAgent].trim());
            omniClientCaseAssignmentsInstance.Country__c=geoCodeIdMap.get(srBodyList[i].replaceAll('\"', '').trim().split(',')[indexOfCountry].trim());

            omniClientCaseAssignmentsInstance.Sub_Type__c = subtypeValue;
            omniClientCaseAssignmentsInstance.Direction__c=directionValue;
            
            omniSet.add(omniClientCaseAssignmentsInstance);

           }
            if(!omniSet.isEmpty()){
            
            omnilist.addall(omniSet);
            database.insert(omnilist,false);
        }
            return '';
        }
        catch(Exception e){
           system.debug('omni----->'+ e.getMessage()+' LN '+ e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }   
    }*/
    public static string createOmniClientCaseAssignments(List<String> srBodyList){
    try {
        Set<Client_Case_Assignments__c> omniSet = new Set<Client_Case_Assignments__c>();
        List<Client_Case_Assignments__c> omnilist = new List<Client_Case_Assignments__c>();
        List<String> fieldNames = new List<String>();
        Map<String, String> oBAccountIdMap = new Map<String, String>();
        Map<String, String> geoCodeIdMap = new Map<String, String>();
        Map<String, String> dedicatedAgentIdMap = new Map<String, String>();
        Map<String, String> backUpAgentIdMap = new Map<String, String>();
        Set<String> maerskUserIds = new Set<String>();

        fieldNames.addALL(srBodyList[0].replaceAll('\"', '').replaceAll('\'','').trim().split(','));
        Integer indexOfAccount = fieldNames.IndexOf('Account');
        Integer indexOfActive = fieldNames.IndexOf('Active');
        Integer indexOfBackUpAgent = fieldNames.IndexOf('Back up Dedicated Agent');
        Integer indexOfDedicatedAgent = fieldNames.IndexOf('Dedicated Agent');
        Integer indexOfDirection = fieldNames.IndexOf('Direction');
        Integer indexOfCountry = fieldNames.IndexOf('Country');
        Integer indexOfSubType = fieldNames.IndexOf('Sub Type');
        Integer indexOfName = fieldNames.IndexOf('Name');

        for (Integer i = 1; i < srBodyList.size(); i++) {
            String[] fields = srBodyList[i].replaceAll('\"', '').replaceAll('\'', '').trim().split(',');

            if (fieldNames.contains('Account') && fields[indexOfAccount].trim() != null) {
                oBAccountIdMap.put(fields[indexOfAccount].trim(), null);
            }
            if (fieldNames.contains('Country') && fields[indexOfCountry].trim() != null) {
                geoCodeIdMap.put(fields[indexOfCountry].trim(), null);
            }
            if (fieldNames.contains('Dedicated Agent') && fields[indexOfDedicatedAgent].trim() != null) {
                dedicatedAgentIdMap.put(fields[indexOfDedicatedAgent].trim(), null);
            }
            if (fieldNames.contains('Back up Dedicated Agent') && fields[indexOfBackUpAgent].trim() != null) {
                backUpAgentIdMap.put(fields[indexOfBackUpAgent].trim(), null);
            }
        }

        maerskUserIds.addAll(dedicatedAgentIdMap.keySet());
        maerskUserIds.addAll(backUpAgentIdMap.keySet());

        if (!oBAccountIdMap.isEmpty()) {
            for (Account acc : [SELECT Id, Name, SCV_Code__c FROM Account WHERE SCV_Code__c IN :oBAccountIdMap.keySet()]) {
                oBAccountIdMap.put(acc.SCV_Code__c, acc.Id);
            }
        }
        if (!geoCodeIdMap.isEmpty()) {
            for (Geography__c gcc : [SELECT Id, Geo_Code__c, Geo_Id__c FROM Geography__c WHERE GEO_Code__c IN :geoCodeIdMap.keySet() AND Type_Of_Location__c ='Country']) {
                geoCodeIdMap.put(gcc.GEO_Code__c, gcc.Id);
            }
        }
        if (!maerskUserIds.isEmpty()) {
            for (User userInstance : [SELECT Id, Maersk_User_Id__c, Name FROM User WHERE Maersk_User_Id__c IN :maerskUserIds]) {
                if (dedicatedAgentIdMap.containsKey(userInstance.Maersk_User_Id__c)) {
                    dedicatedAgentIdMap.put(userInstance.Maersk_User_Id__c, userInstance.Id);
                }
                if (backUpAgentIdMap.containsKey(userInstance.Maersk_User_Id__c)) {
                    backUpAgentIdMap.put(userInstance.Maersk_User_Id__c, userInstance.Id);
                }
            }
        }

        for (Integer i = 1; i < srBodyList.size(); i++) {
            String[] fields = srBodyList[i].replaceAll('\"', '').replaceAll('\'', '').trim().split(',');
            Client_Case_Assignments__c omniClientCaseAssignmentsInstance = new Client_Case_Assignments__c();
            
            String omniClientCaseAssignmentsInstanceName = fields[indexOfName].trim().normalizeSpace().trim();
            omniClientCaseAssignmentsInstance.Name = omniClientCaseAssignmentsInstanceName;
            String subtypeValue = fields[indexOfSubType].trim();
            String directionValue = fields[indexOfDirection].trim();
            
            omniClientCaseAssignmentsInstance.Active__c = Boolean.valueOf(fields[indexOfActive].trim());
            omniClientCaseAssignmentsInstance.Account__c = oBAccountIdMap.get(fields[indexOfAccount].trim());
            omniClientCaseAssignmentsInstance.Dedicated_Agent__c = dedicatedAgentIdMap.get(fields[indexOfDedicatedAgent].trim());
            omniClientCaseAssignmentsInstance.Back_up_Dedicated_Agent__c = backUpAgentIdMap.get(fields[indexOfBackUpAgent].trim());
            omniClientCaseAssignmentsInstance.Country__c = geoCodeIdMap.get(fields[indexOfCountry].trim());

            omniClientCaseAssignmentsInstance.Sub_Type__c = subtypeValue;
            omniClientCaseAssignmentsInstance.Direction__c = directionValue;
            
            omniSet.add(omniClientCaseAssignmentsInstance);
        }

        if (!omniSet.isEmpty()) {
            omnilist.addAll(omniSet);
            Database.insert(omnilist, false);
        }
        
        return '';
    } catch (Exception e) {
        System.debug('omni----->' + e.getMessage() + ' LN ' + e.getLineNumber());
        return e.getMessage() + ' ' + e.getLineNumber();
    }
}

    
    /** 
* @description | SC-7996 Adds records of metadata type Liner Brand Direction And Country|
* @param srBodyList accepts the XL file uploaded in list<string> format
*/
    public static string updateLBDCMetadataRecords(List<String> srBodyList){
        
        try{    
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Map<string,string> omniCaseSkillTypeMap = new Map<string,string>();
            
            for (General_Key_Value_Configurations__mdt mapvalue: [SELECT First_Field_Name__c, First_Field_Value__c FROM General_Key_Value_Configurations__mdt WHERE Key__c LIKE '%OmniSkilltype%']) {
                omniCaseSkillTypeMap.put(mapvalue.First_Field_Value__c,mapvalue.First_Field_Name__c);
            }
            
            for(integer i=1; i< srBodyList.size(); i++){
                Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                //custom metadata name
                string originName = srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim();
                originName = originName.normalizeSpace();
                originName = originName.trim();
                customMetadata.fullName = 'LinerBrand_Direction_and_Country__mdt.'+LinerBrand_Direction_and_Country__mdt.getInstance(originName).label;               
                customMetadata.label = LinerBrand_Direction_and_Country__mdt.getInstance(originName).label;
                
                string cellValue1 = srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim();
                if(string.isNotBlank(cellValue1)){
                    cellValue1 = cellValue1.normalizeSpace();
                    cellValue1 = cellValue1.trim();
                    //If the cell value if NA/null then skip updating the field
                    if(cellValue1!='NA'){
                        Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                        //the custom field API Name that you're wanting to insert/update a value of
                        customField1.field = 'On_Behalf_of_Account_Name__c'; 
                        customField1.value = cellValue1;
                        //add the changes to list of changes to be deployed
                        customMetadata.values.add(customField1);
                    }
                }
                
                string cellValue2 = srBodyList[i].replaceAll('\"', '').trim().split(',')[2].trim();
                if(string.isNotBlank(cellValue2)){
                    cellValue2 = cellValue2.normalizeSpace();
                    cellValue2 = cellValue2.trim();
                    
                    if(cellValue2!='NA'){
                        Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
                        //the custom field API Name that you're wanting to insert/update a value of
                        customField2.field = 'Value_Proposition_Party__c'; 
                        customField2.value = cellValue2;
                        //add the changes to list of changes to be deployed
                        customMetadata.values.add(customField2); 
                    }
                }
                
                string cellValue3 = srBodyList[i].replaceAll('\"', '').trim().split(',')[3].trim();
                if(string.isNotBlank(cellValue3)){
                    cellValue3 = cellValue3.normalizeSpace();
                    cellValue3 = cellValue3.trim();
                    if(cellValue3!='NA'){
                        Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
                        //the custom field API Name that you're wanting to insert/update a value of
                        customField3.field = 'Service_Relationship_Party__c'; 
                        customField3.value = cellValue3;
                        //add the changes to list of changes to be deployed
                        customMetadata.values.add(customField3);
                    }
                    
                }
                
                Integer columnSize = srBodyList[i].replaceAll('\"', '').trim().split(',').size();
                String OmniChannelPriorityRule;
                
                for(Integer j=4;j<columnSize;j++){
                    string fieldNameFormatted = srBodyList[i].replaceAll('\"', '').trim().split(',')[j].trim();
                    fieldNameFormatted = fieldNameFormatted.normalizeSpace();
                    fieldNameFormatted = fieldNameFormatted.trim();
                    String fieldName = fieldNameFormatted;
                    if(j==4 && fieldName!='NA'){
                        OmniChannelPriorityRule = omniCaseSkillTypeMap.get(fieldName);
                    }
                    else
                        if(fieldName !='NA'){
                            OmniChannelPriorityRule = OmniChannelPriorityRule+';'+omniCaseSkillTypeMap.get(fieldName);
                        }
                }
                
                Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
                //the custom field API Name that you're wanting to insert/update a value of
                customField4.field = 'Omni_Channel_Priority_Rule__c'; 
                customField4.value = OmniChannelPriorityRule;
                //add the changes to list of changses to be deployed
                customMetadata.values.add(customField4); 
                mdContainer.addMetadata(customMetadata);
            }
            
            
            CustomMetadataCallback callback = new CustomMetadataCallback();        
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);       
            return '';
        }catch(Exception ex){
            system.debug('exx '+ex.getMessage()+' '+ex.getLineNumber());
            return ex.getMessage()+' '+ex.getLineNumber();
        }        
    }
    
    //Used for updating records of type 'custom metadata type' asyncronously 
    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                 Metadata.DeployCallbackContext context) {
                                     if (result.status == Metadata.DeployStatus.Succeeded) {
                                         system.debug('Deployment was successful' );
                                     } else {
                                         system.debug('Deployment was un-successful' );
                                     }
                                 }
    }
    
    /** 
* @description | SC-7996 common method which truncates composite calls to 25 requests per callout |
* @param dataList accepts the data to be truncated and processed.Also it recieved the current session id
*/
    public static void truncateListAndProcess(List<CompositeRequest> dataList, String sessionId){                
        List<CompositeRequest> dataListToProcess = new List<CompositeRequest>();
        List<CompositeRequest> dataListToReProcess = new List<CompositeRequest>();
        Integer size = (dataList.size() > 25) ? 25 : dataList.size();
        for(integer i = 0; i< size; i++){
            dataListToProcess.add(dataList[i]);            
        }
        if(!dataListToProcess.isEmpty()){                         
            processList(dataListToProcess, sessionId);
        }
        for(integer i = size; i< dataList.size(); i++){
            dataListToReProcess.add(dataList[i]);
        }
        if(!dataListToReProcess.isEmpty()){
            truncateListAndProcess(dataListToReProcess, sessionId);
        }
        
    }
    
    
    /** 
* @description | SC-7996 common method which truncates composite calls to 25 requests per callout |
* @param dataList accepts the data to be truncated in batch of 200 for deletion. Also it receives the current session id
*/
    public static void truncateListAndProcess200RecordsDeletion(set<id> dataList2, String sessionId){ 
        list<id> dataList = new list<id>();
        dataList.addall(dataList2);
        list<id> dataListToProcess = new list<id>();
        list<id> dataListToReProcess = new list<id>();
        Integer size = (dataList.size() > 200) ? 200 : dataList.size();
        for(integer i = 0; i< size; i++){
            dataListToProcess.add(dataList[i]);            
        }
        if(!dataListToProcess.isEmpty()){                         
            processConfigUserDeletionList(dataListToProcess, sessionId);
        }
        for(integer i = size; i< dataList.size(); i++){
            dataListToReProcess.add(dataList[i]);
        }
        if(!dataListToReProcess.isEmpty()){
            Set<id> dataListToReProcess2 = new set<id>();
            dataListToReProcess2.addall(dataListToReProcess);
            truncateListAndProcess200RecordsDeletion(dataListToReProcess2, sessionId);
        }
        
    }    
    /** 
* @description | SC-7996 common method which truncates composite calls to 200 requests per callout |
* @param dataList accepts the data to be truncated and processed in list<skill> format. Also it receives the current session id
*/
    public static void truncateListAndProcess200RecordsSkills(List<Skill> dataList, String sessionId){                
        List<Skill> dataListToProcess = new List<Skill>();
        List<Skill> dataListToReProcess = new List<Skill>();
        Integer size = (dataList.size() > 200) ? 200 : dataList.size();
        for(integer i = 0; i< size; i++){
            dataListToProcess.add(dataList[i]);            
        }
        if(!dataListToProcess.isEmpty()){                         
            processSkillList(dataListToProcess, sessionId);
        }
        for(integer i = size; i< dataList.size(); i++){
            dataListToReProcess.add(dataList[i]);
        }
        if(!dataListToReProcess.isEmpty()){
            truncateListAndProcess200RecordsSkills(dataListToReProcess, sessionId);
        }
        
    }
    
    
    /** 
* @description | SC-7996 common method which processes composite calls|
* @param dataList accepts the data to be processed and also the session id
*/
    
    public static string processList(List<CompositeRequest> dataList2, String sessionId){
        try{
            set<CompositeRequest> dataList3 = new set<CompositeRequest>();
            List<CompositeRequest> dataList = new List<CompositeRequest>();   
            
            dataList3.addall(dataList2);
            dataList.addall(dataList3);
            Integer n=0;
            for (CompositeRequest comp:dataList){
                comp.referenceId = String.valueOf(n);
                n++;
            }
            requestBodyWrapper requestBodyWrapperInstance = new requestBodyWrapper();
            requestBodyWrapperInstance.compositeRequest = dataList;
            //Make composite request callout
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');        
            req.setHeader('content-type', 'application/json');
            req.setHeader ('Authorization', 'Bearer ' + sessionId); 
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/');
            req.setBody(JSON.serialize(requestBodyWrapperInstance));   
            system.debug('Request '+JSON.serialize(requestBodyWrapperInstance));
            if(!Test.isRunningTest()){
                HttpResponse res = h.send(req);
                system.debug('Response Status ===== '+res.getStatus());
                system.debug('Response Status Code ===== '+res.getStatusCode());
                system.debug('Response Body ===== '+res.getBody());
            }
            return '';
        }
        catch(Exception e){
            system.debug('Omni error '+e.getMessage()+' '+e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    
    /** 
* @description | SC-7996 common method which processes composite calls|
* @param dataList accepts the data to be processed and also the session id
*/
    public static string processConfigUserDeletionList(list<id> dataList, String sessionId){
        try{   String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/sobjects?ids=';
            string userPresenceDeletionIdsInScope = '';
            for(id userPresenceDeletionInScope:dataList){
                if(userPresenceDeletionInScope ==dataList[0]){
                    userPresenceDeletionIdsInScope = userPresenceDeletionInScope;
                }
                else
                    userPresenceDeletionIdsInScope = userPresenceDeletionIdsInScope+','+userPresenceDeletionInScope;
            }
            endpoint = endpoint+userPresenceDeletionIdsInScope;
            
            //Make callout to remove users from existing presence config 
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('DELETE');        
            req.setHeader('content-type', 'application/json');
            req.setHeader ('Authorization', 'Bearer ' +sessionId); 
            req.setEndpoint(endpoint);
            if(!Test.isRunningTest()){
                HttpResponse res = h.send(req);
                system.debug('Response Status ===== '+res.getStatus());
                system.debug('Response Status Code ===== '+res.getStatusCode());
                system.debug('Response Body ===== '+res.getBody());
            }
            
            return '';
           }
        catch(Exception e){
            system.debug('Omni error '+e.getMessage()+' '+e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    /** 
* @description | SC-7996 common method which processes Skill calls|
* @param dataList accepts the data to be processed and also the session id
*/
    public static string processSkillList(List<Skill> dataList, String sessionId){
        try{  String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/sobjects/';
            //Make callout to remove users from existing presence config 
            string bodysend = JSON.serialize(dataList);
            string bodysendres = '{"records":'+bodysend+'}';
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');        
            req.setHeader('content-type', 'application/json');
            req.setHeader ('Authorization', 'Bearer ' +sessionId); 
            req.setEndpoint(endpoint);
            req.setBody(bodysendres);
            if(!Test.isRunningTest()){
                HttpResponse res = h.send(req);
                system.debug('Response Status ===== '+res.getStatus());
                system.debug('Response Status Code ===== '+res.getStatusCode());
                system.debug('Response Body ===== '+res.getBody());
            }                
            return '';
           }
        catch(Exception e){
            system.debug('Omni error '+e.getMessage()+' '+e.getLineNumber());
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    public class requestBodyWrapper {
        public List<CompositeRequest> compositeRequest;
    }
    
    public class CompositeRequest {
        public String method;
        public String url;
        public String referenceId;
        public Object body;
        //Dynamically form the request body
        CompositeRequest(string componentType){
            if(componentType == 'omniSupervisorConfigGroupAddition'){
                this.Body = new omniSupervisorConfigGroupAdditionBody();
            }
            
            if(componentType == 'omniSupervisorConfigUserAddition'){
                this.Body = new omniSupervisorConfigUserAdditionBody();
            }
            
            if(componentType == 'PresenceUserConfigUserAddition'){
                this.Body = new PresenceUserConfigUserBody();
            }               
        }
    }
    
    public static String getSessionId(){
        String sessionId = '';
        PageReference sessionPage = Page.SessionId;
        String vfContent = sessionPage.getContent().toString();
        Integer startIndex = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        Integer endIndex = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startIndex, endIndex);
        return sessionId;
    }
    
    
    public class omniSupervisorConfigGroupAdditionBody{
        public id GroupId;
        public id OmniSupervisorConfigId;
    }
    
    public class omniSupervisorConfigUserAdditionBody{
        public id UserId;
        public id OmniSupervisorConfigId;
    }
    
    public class PresenceUserConfigUserBody {
        public String PresenceUserConfigId;
        public String UserId;
    }   
}