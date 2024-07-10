/**
* Author   : Sreya V
* Purpose  : Logic for field updates on Task Object.
*        
* Revision Ref Number  Date         Owner                  Description
* -------- ----------  -----------  -------------------    -----------
* 1.0      SC-1041	    07/04/2021   Sreya@Maersk           Implementation of Country & Business Hours on Voice Call Task
* 2.0      SC-5350     16/06/2022   ayush.k@maersk			Account Name of Customer on Task
* 3.0      SC-5404     21/06/2022   Richa@maersk			Task Survey Owner update
* 4.0      SPI-100     05/07/2022   Ronnie@SF              Removed brand hardcoding
* 5.0      SC-5948     07/09/2022   Harmeet@maersk		    Removed logic for Task Survey Owner update
* 6.0      SC-6309     30/10/2022   Harmeet@maersk		    Added back the logic for Task Survey Owner update
* 7.0      SC-6304     07/11/2022   Shahanawaz@maersk	 	Update Additional Owners on Case
*/
public class TaskFieldPopulator {
    
    public static void populateCountryAndBusinessHours(List<Task> lstVoiceCallTask,List<String> lstCountryCode){
        try{
            Map<string,string > countryMap = new Map<string,string >();
            map<Id, String> mapCountryGeoIdCode = new map<Id, String>();
            
            //SC-1041 : Get Map of Geography GEO_Code__c and GEO_ID__c
            for(Geography__c geo : [SELECT Id,GEO_Code__c,GEO_ID__c FROM Geography__c WHERE Type_Of_Location__c = 'Country' and Active__c = true and GEO_Code__c in:lstCountryCode]){
                countryMap.put(geo.GEO_Code__c,geo.id);
                mapCountryGeoIdCode.put(geo.Id,geo.GEO_ID__c);
            }
            
            set<String> setBHNames = new set<String>{'Default'};
                map<String, map<String, String>> mapGeoIdLBBH = new map<String, map<String, String>>();
            //SC-1041 : get map mapGeoIdLBBH based on Country and Brand Combination and Business Hours from LBDC custom metadata.
            for(LinerBrand_Direction_and_Country__mdt LBDC : [select MasterLabel, Cluster__c, Country__c, Direction__c, Liner_Brand__c, Business_Hours__c from LinerBrand_Direction_and_Country__mdt where Country__c in:mapCountryGeoIdCode.values()]) {     
                setBHNames.add(LBDC.Business_Hours__c);           
                if(mapGeoIdLBBH.containskey(LBDC.Country__c)) {
                    mapGeoIdLBBH.get(LBDC.Country__c).put(LBDC.Liner_Brand__c, LBDC.Business_Hours__c);
                }
                else {
                    mapGeoIdLBBH.put(LBDC.Country__c, new map<String, String> {LBDC.Liner_Brand__c => LBDC.Business_Hours__c});
                } 
            } 
            map<String, BusinessHours> mapBHNameBH = new map<String, BusinessHours>();
            //SC-1041 : get map of Business Hor name and Id
            for(BusinessHours bHour : CaseTrigger_DataSetUtilities.getBHList(setBHNames)) {
                mapBHNameBH.put(bHour.Name, bHour);
            }  
            //SC-1041 : Updating Voice call Country lookup & Business Hours Lookup
            for(Task taskRec : lstVoiceCallTask){
                if(string.isNotBlank(taskRec.Country_Code__c)){
                    if(countryMap.get(taskRec.Country_Code__c) != null){
                        //SC-1041 : Updating Task Country based on Country Code
                        taskRec.Country__c = countryMap.get(taskRec.Country_Code__c); 
                    }
                }
                
                String bhName;
                if(taskRec.Country__c != null ){                             
                    if(mapCountryGeoIdCode.get(taskRec.Country__c) != null){
                        if(mapGeoIdLBBH.get(mapCountryGeoIdCode.get(taskRec.Country__c)) != null){                         
                            bhName = mapGeoIdLBBH.get(mapCountryGeoIdCode.get(taskRec.Country__c)).get(taskRec.Brand_CM__c);
                            if(bhName == null){
                                bhName = mapGeoIdLBBH.get(mapCountryGeoIdCode.get(taskRec.Country__c)).get(BrandUtilities.MAERSKLINE); 
                            }
                            if(bhName != null) {
                                //SC-1041 : Updating Task Business Hourbased on Country and Brand
                                BusinessHours bHour = mapBHNameBH.get(bhName);
                                if(bHour != null) {
                                    taskRec.Business_Hours__c = bHour.Id;
                                }                                
                            } 
                        }                        
                    }                                           
                } 
                if(bhName == null){
                    BusinessHours bHour = mapBHNameBH.get('Default');
                    if(bHour != null) {
                        taskRec.Business_Hours__c = bHour.Id;
                    }    
                }
            }        
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Task', 'TaskFieldPopulator.populateCountryAndBusinessHours', new list<Exception>{ex});  
        }
    }
    
    /** 
* @description | SC-5350 Account Name of Customer on Task  |
* @param lstTaskOnContacts accepts list of task
* @param mapRelatedContacts accepts related contact map
*/   
    public static void populateAccountName(List<Task> lstTaskOnContacts,Map<Id, Contact> mapRelatedContacts){
        try{
            for(Task tsk: lstTaskOnContacts){
                if(tsk.WhoId != Null){
                    tsk.account_name__c = mapRelatedContacts.get(tsk.WhoId).Account.name;
                }
                else{
                    tsk.account_Name__c = '';
                }
            }
        }        
        catch(Exception ex) {
            ErrorLogger.writeErrors( 'SFDC', 'Task', 'TaskFieldPopulator.populateAccountName', new list<Exception>{ex});  
        }
    }
    
    //Update Related Surveys owner when Task owner is changed SC - 6309
    public static void updateRelatedSurveys(Map<String, String> taskOwnerMap){
        try{
            list<Survey__c> surveyToUpdateList = new list<Survey__c>();
            
            if(!taskOwnerMap.isEmpty()){
                for(Survey__c svy : [Select Id,OwnerId,Task_Identifier__c from Survey__c WHERE Task_Identifier__c != null and Task_Identifier__c IN :taskOwnerMap.keyset()]){
                    if(taskOwnerMap.containskey(svy.Task_Identifier__c)){
                        svy.ownerId = taskOwnerMap.get(svy.Task_Identifier__c);
                        surveyToUpdateList.add(svy);
                    }         
                }
            }
            
            if(!surveyToUpdateList.isEmpty()){
                database.update(surveyToUpdateList, false);
            }
            
        }catch(Exception ex){
            ErrorLogger.writeErrors('SFDC', 'Task', 'TaskFieldPopulator.updateRelatedSurveys', new list<Exception>{ex});
        }
        
        
    }
    
    /*
* @description | SC-6304  Update case additional owners
* @param caseIdSet accepts the caseIdSet
*/
    public static void updateCaseAdditionalOwners(Set<Id> caseIdSet, Map<Id, Task> oldMap){
        try{
            List<Case> csListToUpdate = new List<Case>();
            Id caseCollaborationRecTypeId = StaticFactory.getRecordTypeIdByName('Task', 'Case Collaboration');
            for(Case cs : [Select Id, Additional_Owners__c, Additional_Teams_Involved__c, (Select Id, Status, Priority, OwnerId, Owner.Name From Tasks Where RecordTypeId =: caseCollaborationRecTypeId) From Case Where Id =: caseIdSet]){
                Case cstoUpdate = new Case();
                cstoUpdate.Id = cs.Id;
                String ownerName = '';
                List<String> strList = !String.isBlank(cs.Additional_Teams_Involved__c) ? cs.Additional_Teams_Involved__c.split(',') : new List<String>();
                List<String> addOwnerList = !String.isBlank(cs.Additional_Owners__c) ? cs.Additional_Owners__c.split(',') : new List<String>();
                for(Task t : cs.Tasks){
                    if(!addOwnerList.contains(t.Owner.Name)){
                        addOwnerList.add(t.Owner.Name);
                    }
                    if(oldMap == null){
                        if(!strList.contains(t.OwnerId)){
                            strList.add(t.OwnerId);
                        }
                    }
                }
                ownerName = ownerName.removeEnd(',');
                cstoUpdate.Additional_Owners__c = String.join(addOwnerList, ',').left(255);
                cstoUpdate.Additional_Teams_Involved__c = String.join(strList, ',');
                csListToUpdate.add(cstoUpdate);
                
            }
            if(!csListToUpdate.isEmpty()){
                TriggerExecutionController.skipCaseTrigger(true);
                update csListToUpdate;
                TriggerExecutionController.skipCaseTrigger(false);
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Task', 'TaskFieldPopulator.updateCaseAdditionalOwners', new list<Exception>{e});            
        }
    }
    
    /*
* @description | SC-6304  Create Case Team Member
* @param tskList accepts the tskList
*/
    public static void createCaseTeamMembers(List<Task> tskList){
        try{
            String roleName = General_Key_Value_Configurations__mdt.getInstance('Case_Collaborator').First_Field_Value__c;
            if(!String.isEmpty(roleName)){
                CaseTeamRole role = [Select Id from CaseTeamRole where Name =: roleName limit 1];
                List<CaseTeamMember> ctmList = new List<CaseTeamMember>();
                for(Task t : tskList){
                    CaseTeamMember ctm = new CaseTeamMember();
                    ctm.ParentId = t.WhatId;
                    ctm.MemberId = t.OwnerId;
                    ctm.TeamRoleId = role.Id;
                    ctmList.add(ctm);
                }
                if(!ctmList.isEmpty()){
                    insert ctmList;
                }
            }
        }
        catch(Exception e){
            ErrorLogger.writeErrors('SFDC', 'Task', 'TaskFieldPopulator.createCaseTeamMembers', new list<Exception>{e});
        }
    }
}