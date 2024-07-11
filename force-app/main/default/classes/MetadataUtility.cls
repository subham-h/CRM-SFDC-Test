/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Utility class for Email to case automation
 *              
 * Revision Ref Number  Date         Owner                   Description
 * -------- ----------  -----------  -------------------     -----------
 * 1.0      #SC-9165    29-Jul-2023  Shahanawaz@Maersk       Utility class for Email to case automation
 * 
*/
public class MetadataUtility {
    /** 
    * @description | create public groups
    * @param csvlist accepts csvlist
    * @return String
    */
    public static String createPublicGroup(List<String> csvlist){
        try{
            List<Group> grouplist = new List<Group>();        
            for(integer i=1; i< csvlist.size(); i++){
                Group gp = new Group();
                gp.Name = csvlist[i].replaceAll('\"', '').trim();
                gp.DoesIncludeBosses= false;
                grouplist.add(gp);
            }
            
            if(!grouplist.isEmpty()){
                insert grouplist;
            }
            return '';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    /** 
    * @description | create queues
    * @param strList accepts strList
    * @return String
    */
    public static String createQueue(List<String> strList){
        try{
            Map<String, Group> groupNameToGroupMap = new Map<String, Group>();
            List<Group> queueListToInsert = new List<Group>();
            Map<String, String> queueToGroupMap = new Map<String, String>();
            List<GroupMember> gmListToInsert = new List<GroupMember>();
            List<QueueSobject> supportedObjList = new List<QueueSobject>();
            for(integer i=1; i< strList.size(); i++){
                if(!strList[i].replaceAll('\"', '').trim().split(',').isEmpty()){
                    queueToGroupMap.put(strList[i].replaceAll('\"', '').trim().split(',')[0].trim(), strList[i].replaceAll('\"', '').trim().split(',')[1].trim());
                }
            }
            
            if(!queueToGroupMap.isEmpty()){
                for(Group grp : [Select Id, Name, DeveloperName, Type From Group Where Name =: queueToGroupMap.values()]){
                    groupNameToGroupMap.put(grp.Name.trim(), grp);            
                }
            }
            
            for(integer i=1; i< strList.size(); i++){
                List<String> subsetList = strList[i].trim().split(',');
                if(!subsetList.isEmpty()){
                    Group grp = new Group();
                    grp.Name = subsetList[0].replaceAll('\"', '').trim();
                    grp.DeveloperName = 'Case_' + getAPIName(subsetList[0].replaceAll('\"', '').trim(), '');
                    grp.Type = 'Queue';
                    grp.Email = subsetList[2].replaceAll('\"', '').trim();
                    grp.DoesSendEmailToMembers = false;
                    queueListToInsert.add(grp);
                }
            }
            
            if(!queueListToInsert.isEmpty()){
                insert queueListToInsert;
                for(Group grp : queueListToInsert){
                    QueueSobject qs = new QueueSobject();
                    qs.QueueId = grp.Id;
                    qs.SobjectType = 'Case';
                    supportedObjList.add(qs);
                    
                    QueueSobject qsTask = new QueueSobject();
                    qsTask.QueueId = grp.Id;
                    qsTask.SobjectType = 'Task';
                    supportedObjList.add(qsTask);
                    
                    if(groupNameToGroupMap.containsKey(queueToGroupMap.get(grp.Name))){
                        GroupMember gm = new GroupMember();
                        gm.GroupId = grp.Id;
                        gm.UserOrGroupId = groupNameToGroupMap.get(queueToGroupMap.get(grp.Name)).Id;
                        gmListToInsert.add(gm);
                    }
                }
                if(!supportedObjList.isEmpty()){
                    insert supportedObjList;
                }
                if(!gmListToInsert.isEmpty()){
                    insert gmListToInsert;
                }
            }
            return '';
        }catch(Exception e){
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    /** 
    * @description | create case origin
    * @param srBodyList accepts srBodyList
    * @return String
    */
    public static String createCaseOrigin(List<String> srBodyList){
        MetadataService.MetadataPort service = createService();
        MetadataService.StandardValue[] arr = new MetadataService.StandardValue[]{};
        MetadataService.StandardValueSet standardField = new MetadataService.StandardValueSet();
        if(!Test.isRunningTest()){
            standardField = (MetadataService.StandardValueSet) service.readMetadata('StandardValueSet', new String[] { 'CaseOrigin' }).getRecords()[0];
            arr = standardField.StandardValue;
        }
        for(integer i=1; i< srBodyList.size(); i++){
            String tempString = srBodyList[i].replaceAll('\"', '').split(',')[0];
            MetadataService.StandardValue sv = new MetadataService.StandardValue();
            sv.fullName = tempString;
            sv.default_x = false;
            arr.add(sv);
            StandardField.standardValue = arr;
        }
        List<MetadataService.SaveResult> lstResults = service.updateMetadata( new MetadataService.Metadata[] { StandardField });
        return handleSaveResults(lstResults[0]);
    }
    
    /** 
    * @description | create roles
    * @param srBodyList accepts srBodyList
    * @return String
    */
    public static String createRoles(List<String> srBodyList){
        try{
            Map<String, String> roleNameToParentRole = new Map<String, String>();
            Map<String, String> parentRoleNameToId = new Map<String, String>();
            List<UserRole> userRolesToInsert       = new List<UserRole>();
            for(integer i=1; i< srBodyList.size(); i++){
                if(!srBodyList[i].replaceAll('\"', '').trim().split(',').isEmpty()){
                    roleNameToParentRole.put(srBodyList[i].replaceAll('\"', '').trim().split(',')[0].trim(), srBodyList[i].replaceAll('\"', '').trim().split(',')[1].trim());
                }
            }
            
            if(!roleNameToParentRole.isEmpty()){
                for(UserRole thisRole : [Select Id, Name From UserRole Where Name =: roleNameToParentRole.values()]){
                    parentRoleNameToId.put(thisRole.Name.trim(), thisRole.Id);            
                }
            }
            
            for(integer i=1; i< srBodyList.size(); i++){
                List<String> subsetList = srBodyList[i].trim().split(',');
                if(!subsetList.isEmpty()){
                    UserRole thisRole = new UserRole();
                    thisRole.Name = subsetList[0].replaceAll('\"', '').trim();
                    thisRole.developerName  = MetadataUtility.getAPIName(subsetList[0].replaceAll('\"', '').trim(), null);
                    thisRole.RollupDescription = subsetList[0].trim();
                    thisRole.ParentRoleId = parentRoleNameToId.get(subsetList[1].replaceAll('\"', '').trim());
                    thisRole.CaseAccessForAccountOwner  = 'None';
                    thisRole.ContactAccessForAccountOwner  = 'None';
                    thisRole.opportunityAccessForAccountOwner  = 'EDIT';
                    userRolesToInsert.add(thisRole);
                }
            }
            
            if(!userRolesToInsert.isEmpty()){
                insert userRolesToInsert;
            }
            return '';
        }catch(Exception e){
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    /** 
    * @description | create list views
    * @param csvlist accepts csvlist
    * @return String
    */
    public static String createListViews(List<String> csvlist){
        try{
            MetadataService.MetadataPort service =  MetadataUtility.createService();
            MetadataService.ListView listView = new MetadataService.ListView();
            MetadataService.SharedTo shareView = new MetadataService.SharedTo();
            map<string,ListView> viewapi = new map<string,ListView>();

            List<string> listviewname = new List<string>();
            List<string> groupname = new List<string>();
            List<string> rolename = new List<string>();
            
            for(integer i=1;i<csvlist.size(); i++){
                string[] recordlist= csvlist[i].replaceAll('\"', '').trim().split(',');
                if(recordlist.size()>0 && !String.isEmpty(recordlist[0].trim())){
                    listviewname.add(recordlist[0]);
                }
                if(recordlist.size()>4 && !String.isEmpty(recordlist[4].trim())){
                    groupname.add(recordlist[4]);
                }
                if(recordlist.size()>5 && !String.isEmpty(recordlist[5].trim())){
                    rolename.add(recordlist[5]);
                }               
            }

            for(ListView lv:[select id,Name, DeveloperName FROM ListView WHERE Name IN:listviewname]){
                viewapi.put(lv.name,lv);
            }
            map<string,Group> groupapi = new map<string,Group>();
            for(Group gp:[select id,Name,DeveloperName from Group where Name IN:groupname]){
                groupapi.put(gp.Name,gp);
            }
                
            map<string,UserRole> roleapi = new map<string,UserRole>();
            for(UserRole role:[select id,Name,DeveloperName from UserRole where Name IN:rolename]){
                roleapi.put(role.Name,role);
            }
            
            map<string,Group> queueapi = new map<string,Group>();
            for(Group q:[select id,Name,DeveloperName from Group where Type='Queue' and Name IN:listviewname]){
                queueapi.put(q.Name,q);
            }
                       
            for(integer i=1;i<csvlist.size(); i++){
                string caseNum = 'CASES.CASE_NUMBER';
                string[] columnlist = new string[]{}; 
                List<MetadataService.ListViewFilter> filterListToAdd = new List<MetadataService.ListViewFilter>();
                string[] recordlist= csvlist[i].replaceAll('\"', '').trim().split(',');
                if(!Test.isRunningTest()){
                    listView.fullName ='Case.' + viewapi.get(recordlist[0]).DeveloperName;
                    listView.label =recordlist[0].trim();
                }
                else{
                    listView.fullName = 'Test_Queue';
                    listView.label = 'Test Queue';
                }
                if(recordlist.size()>1 && !String.isEmpty(recordlist[1].trim())){
                    string[] criterialist= recordlist[1].trim().split(';');
                    if(!criterialist.isEmpty()){
                        for(string cl:criterialist){
                            MetadataService.ListViewFilter filter = new MetadataService.ListViewFilter();
                            string[] valuelist= cl.replaceAll('\"', '').trim().split('-');
                            filter.field =valuelist[0].trim();
                            filter.operation =valuelist[1].trim();
                            filter.value=  valuelist[2].trim();                     
                            filterListToAdd.add(filter);
                        }
                        listView.filters = filterListToAdd;
                    }
                }
                
                listView.booleanFilter =recordlist[2].trim();
                if(recordlist.size()>3 && !String.isEmpty(recordlist[3].trim())){
                    columnlist= recordlist[3].trim().split(';');
                }
                if(columnlist.isEmpty() || !columnlist.contains(caseNum)){
                    columnlist.add(caseNum);
                }               
                listView.columns = columnlist;
                if(recordlist.size()>4 && !String.isEmpty(recordlist[4].trim())){
                    string[] grouplist= recordlist[4].trim().split(';');
                    list<string> grouplistInsert= new list<string>();
                    for(String g: grouplist){
                        grouplistInsert.add(groupapi.get(g).DeveloperName);                
                    }
                    shareView.group_x=grouplistInsert;
                }
                if(recordlist.size()>5 && !String.isEmpty(recordlist[5].trim())){
                    string[] rolelist= recordlist[5].trim().split(';');
                    list<string> rolelistInsert = new list<string>();
                    for(String r: rolelist){
                        if(roleapi.containsKey(r)){
                            rolelistInsert.add(roleapi.get(r).DeveloperName);  
                        }             
                    }
                    shareView.role=rolelistInsert;
                }  
                if(recordlist.size()>6 && !String.isEmpty(recordlist[6].trim())){
                    string[] portalrolelist= recordlist[5].trim().split(';');
                    list<string> portalrolelistInsert = new list<string>();
                    for(String r: portalrolelist){
                        if(roleapi.containsKey(r)){
                            portalrolelistInsert.add(roleapi.get(r).DeveloperName);                
                        }
                    }
                    shareView.portalRole=portalrolelistInsert;
                }  
                if(recordlist.size()>7 && !String.isEmpty(recordlist[7].trim())){
                    string[] portalroleSublist= recordlist[5].trim().split(';');
                    list<string> portalroleSublistInsert = new list<string>();
                    for(String r: portalroleSublist){
                        if(roleapi.containsKey(r)){
                            portalroleSublistInsert.add(roleapi.get(r).DeveloperName);                
                        }
                    }
                    shareView.portalRoleAndSubordinates=portalroleSublistInsert;
                }  
                if(recordlist.size()>8 && !String.isEmpty(recordlist[8].trim())){
                    string[] roleSublist= recordlist[5].trim().split(';');
                    list<string> roleSublistInsert = new list<string>();
                    for(String r: roleSublist){
                        if(roleapi.containsKey(r)){
                            roleSublistInsert.add(roleapi.get(r).DeveloperName);                
                        }
                    }
                    shareView.roleAndSubordinates=roleSublistInsert;
                }  
                if(recordlist.size()>9 && !String.isEmpty(recordlist[9].trim())){
                    string[] roleSubIntlist= recordlist[5].trim().split(';');
                    list<string> roleSubIntlistInsert = new list<string>();
                    for(String r: roleSubIntlist){
                        if(roleapi.containsKey(r)){
                            roleSubIntlistInsert.add(roleapi.get(r).DeveloperName);                
                        }
                    }
                    shareView.roleAndSubordinatesInternal=roleSubIntlistInsert;
                }           
                listView.queue= queueapi.get(recordlist[0].trim()).DeveloperName;                
                listView.filterScope = 'Queue';                  
                listView.sharedTo = shareView;            
                List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { listView });
            }
            return '';
        } 
        catch(Exception e){
           if(e.getMessage() != 'IO Exception: Read timed out'){
                return e.getMessage();
            }
            else{
                return '';
            }
        }
    }
    
    /** 
    * @description | create standard BA
    * @param strList accepts strList
    * @return String
    */
    public static String createBA(List<String> strList){
       Set<String> queueNameSet = new Set<String>();
        Map<String, Group> queueNameToQueueMap = new Map<String, Group>();
        for(integer i=1; i< strList.size(); i++){
            if(!strList[i].replaceAll('\"', '').trim().split(',').isEmpty() && strList[i].replaceAll('\"', '').trim().split(',').size() == 3){
                queueNameSet.add(strList[i].replaceAll('\"', '').trim().split(',')[2].trim());
            }
        }
        if(!queueNameSet.isEmpty()){
            for(Group grp : [Select Id, Name, DeveloperName From Group Where Type = 'Queue' AND Name =: queueNameSet]){
                queueNameToQueueMap.put(grp.Name.trim().toLowerCase(), grp);
            }
        }
        
        MetadataService.MetadataPort service = createService();
        MetadataService.CaseSettings caseSetting = new MetadataService.CaseSettings();
        MetadataService.EmailToCaseRoutingAddress[] routingAddList = new MetadataService.EmailToCaseRoutingAddress[]{};
        if(!Test.isRunningTest()){
            caseSetting = (MetadataService.CaseSettings) service.readMetadata('CaseSettings', new String[] { 'EmailToCaseSettings' }).getRecords()[0];
            routingAddList = caseSetting.emailToCase.routingAddresses;
        }
        for(integer i=1; i< strList.size(); i++){
            List<String> subsetList = strList[i].replaceAll('\"', '').trim().split(',');
            if(!subsetList.isEmpty()){
                MetadataService.EmailToCaseRoutingAddress newEM = new MetadataService.EmailToCaseRoutingAddress();
                newEM.addressType = 'EmailToCase';
                newEM.caseOrigin = subsetList[1];
                if(subsetList.size() == 3 && queueNameToQueueMap.containsKey(subsetList[2].trim().toLowerCase())){
                    newEM.caseOwner = queueNameToQueueMap.get(subsetList[2].trim().toLowerCase()).DeveloperName;
                    newEM.caseOwnerType = 'Queue';
                }
                newEM.casePriority = 'Medium';
                newEM.createTask = false;
                newEM.emailAddress = subsetList[0];
                newEM.routingName = subsetList[0];
                newEM.saveEmailHeaders = false;
                routingAddList.add(newEM);
            }
        }
        caseSetting.emailToCase.routingAddresses = routingAddList;
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[]{caseSetting});
        return handleSaveResults(results[0]);
    }
    
    /** 
    * @description | create custom BA
    * @param strList accepts strList
    * @return String
    */
    public static String createCustomBA(List<String> strList){
        MetadataService.MetadataPort service = MetadataUtility.createService();    
        MetadataService.EmailServicesFunction esf = new MetadataService.EmailServicesFunction();        
        if(!Test.isRunningTest()){
            esf = (MetadataService.EmailServicesFunction) service.readMetadata('EmailServicesFunction', new String[] { 'CaseEmailService' }).getRecords()[0];
            esf.emailServicesAddresses = new List<MetadataService.EmailServicesAddress>();
        }
        
        User usr = [Select Id, Username From User Where Name = 'System Owner' LIMIT 1];
        
        for(integer i=1; i < strList.size(); i++){
            List<String> subsetList = strList[i].replaceAll('\"', '').trim().split(',');
            if(!subsetList.isEmpty() && subsetList.size() == 2){
                MetadataService.EmailServicesAddress emailAddress = new MetadataService.EmailServicesAddress();
                emailAddress.developerName = subsetList[0];
                emailAddress.localPart = subsetList[1];
                emailAddress.isActive = true;
                emailAddress.runAsUser = usr.Username;
                esf.emailServicesAddresses.add(emailAddress);
             }
        }
        MetadataService.Metadata[] m1 = new MetadataService.Metadata[] {esf};
        MetadataService.UpsertResult[] s = service.upsertMetadata(m1); 
        for(MetadataService.UpsertResult sv : s){
            if(sv == null || sv.success){
                return '';
            }            
            if(sv.errors != null && !sv.errors.isEmpty()){
                String error = '';
                for(MetadataService.Error err : sv.errors){
                    error += err.message+',';
                }
                return error.removeEnd(',');
            }
        }
        return '';
    }
    
    /** 
    * @description | create custom email service records
    * @param strList accepts strList
    * @return String
    */
    public static String createCustomEmailServices(List<String> strList){
        try{
            Set<String> queueNameSet = new Set<String>();
            Set<String> localPartNameSet = new Set<String>();
            Map<String, Group> queueMap = new Map<String, Group>();
            Map<String, EmailServicesAddress> emServiceAddressMap = new Map<String, EmailServicesAddress>();
            List<Custom_Email_Service__c> cesListToInsert = new List<Custom_Email_Service__c>();
            
            for(integer i=1; i < strList.size(); i++){
                List<String> subsetList = strList[i].replaceAll('\"', '').trim().split(',');
                if(!subsetList.isEmpty() && subsetList.size() == 6){
                    if(!String.isBlank(subsetList[2].trim())){
                        queueNameSet.add(subsetList[2].trim());
                    }
                    if(!String.isBlank(subsetList[3].trim())){
                        localPartNameSet.add(subsetList[3].trim());
                    }
                }
            }
            if(!queueNameSet.isEmpty()){
                for(Group gp : [Select Id, Name From Group Where Type = 'Queue' AND Name =: queueNameSet]){
                    queueMap.put(gp.Name, gp);
                }
            }
            if(!localPartNameSet.isEmpty()){
                for(EmailServicesAddress em : [SELECT Id, DeveloperName, EmailDomainName, IsActive, LocalPart FROM EmailServicesAddress Where Function.FunctionName = 'CaseEmailService' AND LocalPart =: localPartNameSet Order by createddate DESC]){
                    emServiceAddressMap.put(em.LocalPart, em);
                }
            }
            for(integer i=1; i < strList.size(); i++){
                List<String> subsetList = strList[i].replaceAll('\"', '').trim().split(',');
                if(!subsetList.isEmpty() && subsetList.size() == 7){
                    Custom_Email_Service__c ces = new Custom_Email_Service__c();
                    ces.BA_Address__c = subsetList[0].trim();
                    ces.Origin__c = subsetList[1].trim();
                    if(!queueMap.isEmpty() && queueMap.containsKey(subsetList[2].trim())){
                        ces.Queue_Id__c = queueMap.get(subsetList[2].trim()).Id;
                    }
                    ces.Service_Address__c = (!emServiceAddressMap.isEmpty() && emServiceAddressMap.containsKey(subsetList[3].trim())) ? (emServiceAddressMap.get(subsetList[3].trim()).LocalPart + '@' + emServiceAddressMap.get(subsetList[3].trim()).EmailDomainName) : '';
                    ces.Record_Type__c = subsetList[4].trim();
                    ces.Remove_header_based_threading__c = Boolean.valueOf(subsetList[5].trim());
                    ces.Skip_Auto_Handshake__c = Boolean.valueOf(subsetList[6].trim());
                    ces.Active__c = true;
                    cesListToInsert.add(ces);
                }
            }
            
            if(!cesListToInsert.isEmpty()){
                insert cesListToInsert;
            }
            return '';
        }
        catch(Exception e){
            return e.getMessage() +' '+e.getLineNumber();
        }
    }
    
    /** 
    * @description | create auto response rule
    * @param strList accepts strList
    * @return List<FetchXmldata>
    */
    @AuraEnabled (cacheable=true)
    public static List<FetchXmldata> createAutoResponseRule(List<String> strList){       
        List<FetchXmldata> fetchXmldataList = new List<FetchXmldata>();
        for(integer i=1;i<strList.size(); i++){
            List<CriteriaItems> criteriaItemsList = new List<CriteriaItems>();
            FetchXmldata xml = new FetchXmldata();
            string[] recordlist= strList[i].trim().split(',');
            xml.booleanFilter=recordlist[0].trim();
            if(recordlist.size()>1 && !String.isEmpty(recordlist[1].trim())){
                string[] criteriaItems = recordlist[1].trim().split(';');
                for(string cl:CriteriaItems){
                    CriteriaItems c = new CriteriaItems();
                    string[] valuelist= cl.replaceAll('\"', '').trim().split('-');
                    c.field =valuelist[0].trim();
                    c.operation =valuelist[1].trim();
                    c.value=  valuelist[2].trim();                     
                    criteriaItemsList.add(c);
                }
                xml.criteriaItems=criteriaItemsList;
            }
            xml.notifyCcRecipients=recordlist[2].trim();
            xml.replyToEmail=recordlist[3].trim();
            xml.senderEmail=recordlist[4].trim();
            xml.senderName=recordlist[5].trim();
            xml.template=recordlist[6].trim();           
            fetchXmldataList.add(xml);
        }
        return fetchXmldataList;
    }
    
    /** 
    * @description | xml data wrapper class
    */
    public class FetchXmldata {
        @auraEnabled public string booleanFilter {get;set;}
        @auraEnabled public List<CriteriaItems> criteriaItems {get;set;}
        @auraEnabled public string notifyCcRecipients {get;set;}
        @auraEnabled public string replyToEmail {get;set;}
        @auraEnabled public string senderEmail {get;set;}
        @auraEnabled public string senderName {get;set;}
        @auraEnabled public string template {get;set;}
    } 
    
    /** 
    * @description | criteria items wrapper class
    */
    public class CriteriaItems {
        @auraEnabled public String field {get;set;}
        @auraEnabled public String operation {get;set;}
        @auraEnabled public String value {get;set;}
    }
    
    /** 
    * @description | create org wide addresses
    * @param strList accepts strList
    * @return String
    */
    public static String createOrgWideAddresses(List<String> strList){
        try{
            String sessionId = '';
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            if(!Test.isRunningTest()){
                PageReference sessionPage = Page.SessionId;
                String vfContent = sessionPage.getContent().toString();
                Integer startIndex = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
                Integer endIndex = vfContent.indexOf('End_Of_Session_Id');
                sessionId = vfContent.substring(startIndex, endIndex);
            }
            else{
                sessionId = UserInfo.getSessionId();
            }
            
            List<String> emailList = new List<String>();
            for(Integer i=1; i< strList.size(); i++){
                emailList.add(strList[i].replaceAll('\"', '').trim());
            }
            truncateListAndProcessOrgWide(emailList, sessionId);
            return '';
        }catch(Exception e){
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    /** 
    * @description | truncate org wide address list
    * @param emailList accepts emailList
    * @param sessionId accepts sessionId
    * @return List<String>
    */
    public static List<String> truncateListAndProcessOrgWide(List<String> emailList, String sessionId){
        List<String> emailListToProcess = new List<String>();
        List<String> emailListToReProcess = new List<String>();
        Integer size = (emailList.size() > 25) ? 25 : emailList.size();
        for(integer i = 0; i< size; i++){
            emailListToProcess.add(emailList[i]);            
        }
        if(!emailListToProcess.isEmpty()){
            processOrgWideAddressCompositeRequest(emailListToProcess, sessionId);
        }
        for(integer i = size; i< emailList.size(); i++){
            emailListToReProcess.add(emailList[i]);
        }
        if(!emailListToReProcess.isEmpty()){
            truncateListAndProcessOrgWide(emailListToReProcess, sessionId);
        }
        return emailListToReProcess;
    }
    
    /** 
    * @description | process org wide address list
    * @param emailList accepts emailList
    * @param sessionId accepts sessionId
    */
    public static void processOrgWideAddressCompositeRequest(List<String> emailList, String sessionId){
        OrgWideEmailAddressWrapper org = new OrgWideEmailAddressWrapper();
        List<CompositeRequest> compositeRequestList = new List<CompositeRequest>();
        Integer i=1;
        for(String str : emailList){
            CompositeRequest comp = new CompositeRequest();
            comp.method = 'POST';
            comp.url = '/services/data/v55.0/sobjects/OrgWideEmailAddress';
            comp.referenceId = String.valueOf(i);
            Body bod = new Body();
            bod.address = str;
            bod.displayName = nameFormat(str.substringBefore('@').replace('.', ' '));
            bod.isAllowAllProfiles = TRUE;
            comp.body = bod;
            compositeRequestList.add(comp);
            i++;
        }
        org.compositeRequest = compositeRequestList;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');        
        req.setHeader('content-type', 'application/json');
        req.setHeader ('Authorization', 'Bearer ' + sessionId); 
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+ '/services/data/v55.0/composite/');
        req.setBody(JSON.serialize(org));   
        
        HttpResponse res = h.send(req);
    }
    
    /** 
    * @description | create metadata records
    * @param metadataName accepts metadataName
    * @param srBodyList accepts srBodyList
    */
    public static void createMetadataRecords(String metadataName, List<String> srBodyList){
        try{    
            Map<String, String> fieldsAndValues = new Map<String, String>();
            List<String> fieldNames = new List<String>();
            fieldNames.addALL(srBodyList[0].replaceAll('\"', '').replaceAll('\'','').trim().split(','));
            
            Integer indexOfOnBAccount = fieldNames.IndexOf('On_Behalf_of_Account_ID__c');
            Integer indexOfCountry = fieldNames.IndexOf('Country__c');
            Integer indexOfQueueId = fieldNames.IndexOf('QueueId__c');
            Map<String, String> oBAccountIdMap = new Map<String, String>();
            Map<String, String> geoCodeIdMap = new Map<String, String>();
            Map<String, String> queueNameIdMap = new Map<String, String>();
            
            for(integer i=1; i< srBodyList.size(); i++){
                //OBOFAccount ID map
                if(fieldNames.contains('On_Behalf_of_Account_ID__c') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfOnBAccount].trim() != null){
                    oBAccountIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfOnBAccount].trim(), null);
                }
                //geoCodeIdMap ID map
                if(fieldNames.contains('Country__c') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfCountry].trim() != null ){
                    geoCodeIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfCountry].trim(), null);
                }
                //queueNameIdMap ID map
                if(fieldNames.contains('QueueId__c') && srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfQueueId].trim() != null){
                    queueNameIdMap.put(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[indexOfQueueId].trim(), null);
                }
            }
            
            if(!oBAccountIdMap.isEmpty()){
                for(Account acc : [Select Id, Name, SCV_Code__c From Account Where SCV_Code__c != null AND SCV_Code__c=: oBAccountIdMap.keySet()]){
                    oBAccountIdMap.put(acc.SCV_Code__C, acc.Id);            
                }
            }
            
            if(!geoCodeIdMap.isEmpty()){
                for(Geography__c  gca : [Select Id, Geo_Code__c, Geo_Id__c From Geography__c Where GEO_Code__c != null AND GEO_Code__c=: geoCodeIdMap.keySet() and Type_Of_Location__c ='Country']){
                    geoCodeIdMap.put(gca.GEO_Code__c, gca.Geo_Id__C);            
                }
            }
            if(!queueNameIdMap.isEmpty()){
                for(Group grp : [Select Id, Name, DeveloperName From Group Where Type = 'Queue' AND Name =: queueNameIdMap.keySet()]){
                    queueNameIdMap.put(grp.Name, grp.Id);            
                }
            }
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            for(Integer i=1; i<srBodyList.size() ; i++){
                Metadata.CustomMetadata parentRecord = new Metadata.CustomMetadata();
                parentRecord.fullName = metadataName+'.' + srBodyList[i].split(',')[0].trim();
                parentRecord.label = srBodyList[i].replaceAll('\"', '').replaceAll('\'','').split(',')[1];
                
                for(Integer j=2 ; j<srBodyList[i].split(',').size() ; j++){
                    Metadata.CustomMetadataValue relValue = new Metadata.CustomMetadataValue();
                    relValue.field =fieldNames[j].replaceAll('\"', '').replaceAll('\'','').trim();
                    if(relValue.Field =='On_Behalf_of_Account_ID__c' && oBAccountIdMap!= null){
                        relValue.value = oBAccountIdMap.get(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[j].trim()); 
                    }
                    else if(relValue.Field =='Country__c' && geoCodeIdMap!= null){
                        relValue.value = geoCodeIdMap.get(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[j].trim());
                    }
                    else if(relValue.Field =='QueueId__c' && queueNameIdMap!= null){
                        relValue.value = queueNameIdMap.get(srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[j].trim());
                    }
                    else{
                        relValue.value = srBodyList[i].replaceAll('\"', '').replaceAll('\'','').trim().split(',')[j].trim();
                    }
                    parentRecord.values.add(relValue);
                }
                mdContainer.addMetadata(parentRecord);
            }
            CustomMetadataCallback callback = new CustomMetadataCallback();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }catch(Exception ex){
            system.debug('****In ex--->'+ex.getMessage()+' '+ex.getLineNumber());
        }
    }
    
    /** 
    * @description | create session id
    * @return MetadataService.MetadataPort
    */
    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        if(!Test.isRunningTest()){
            PageReference sessionPage = Page.SessionId;
            String vfContent = sessionPage.getContent().toString();
            Integer startIndex = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
            Integer endIndex = vfContent.indexOf('End_Of_Session_Id');
            service.SessionHeader.sessionId = vfContent.substring(startIndex, endIndex);
        }
        else{
            service.SessionHeader.sessionId = UserInfo.getSessionId();
        }
        return service;
    }
    
    /** 
    * @description | get API names
    * @param strtext accepts strtext
    * @param charToAddAtEnd accepts charToAddAtEnd
    * @return String
    */
    public static String getAPIName(String strtext, String charToAddAtEnd){
        strText = strText.replaceAll('[^a-zA-Z0-9\\s+]', '');
        strText = strText.replaceAll('  ', ' ').replaceAll(' ', '_');
        if(!String.isEmpty(charToAddAtEnd)){
            strText += charToAddAtEnd;
        }
        return strText;
    }
    
    /** 
    * @description | format name into camel case
    * @param name accepts name
    * @return String
    */
    public static String nameFormat(String name) {
        String result = '';
        if(!String.isEmpty(name)){
            for (String iter : name.split('[ ]+')) {
                if(iter != null && iter != '') {
                    if(iter.length() > 1) {  
                        result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                    }
                    else {
                        result += iter.substring(0,1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    } 
    
    /** 
    * @description | handle response
    * @param saveResult accepts saveResult
    * @return String
    */
    public static String handleSaveResults(MetadataService.SaveResult saveResult){
        if(saveResult==null || saveResult.success){
            return '';
        } 
        String error = '';
        if(saveResult.errors!=null){
            for(MetadataService.Error err : saveResult.errors){
                error = err.message + ',';
            }
        }
        return error.removeEnd(',');
    }
    
    /** 
    * @description | org wide address wrapper class
    */
    public class OrgWideEmailAddressWrapper {
        public List<CompositeRequest> compositeRequest;
    }
    
    /** 
    * @description | composite request wrapper class
    */
    public class CompositeRequest {
        public String method;
        public String url;
        public String referenceId;
        public Body body;
    }
    
    /** 
    * @description | body wrapper class
    */
    public class Body {
        public String address;
        public String displayName;
        public Boolean isAllowAllProfiles;
    }
    
}