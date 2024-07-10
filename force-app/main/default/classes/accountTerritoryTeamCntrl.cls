/*
*  * Story Number      Date        Owner                              Description
***********************************************************************************************
*  SFSE-5365        26/05/2021     Meghana Gupta            Code Created
*  SFSE-5366        22/06/2021     Neha@TCS                 created method fetchOneTeamDetails() to get the 
one team sales
*  SFSE- 7692       07/03/2022     Neha@TCS                 for Sales control, role is displayed as Sales Owner
* SFSE-12844        05/10/2023     Bharti@maersk            Added condition in query to fetch only active TAA .
*  SFSE-13491       14-dec-2023     Bharti                  Remove hardcoding of Portfolio owner Responsibility

*/

public without sharing class accountTerritoryTeamCntrl {
    
    // wrapper class to hold list of team members and boolean to check for add/edit access
    public class AccountTeamResponse{

        @AuraEnabled public List<TeamMember> lstAccountTeamMembers {get; set;}
        @AuraEnabled public boolean blnHasAddEditAccess {get; set;}

        public AccountTeamResponse(){
            lstAccountTeamMembers = new List<TeamMember>();
            blnHasAddEditAccess = false;
        }
    }

     //wrapper class to hold team member details
     public class TeamMember {
        
        @AuraEnabled public Id recId {get; set;}
        @AuraEnabled public String userUrl {get; set;}

        @AuraEnabled public String teamMember {get; set;}
        @AuraEnabled public String role {get; set;}
        @AuraEnabled public String country {get; set;}
        @AuraEnabled public String scope {get; set;}
        @AuraEnabled public String brand {get; set;}
        @AuraEnabled public String territory {get; set;}
        @AuraEnabled public String territoryUrl {get; set;}
        @AuraEnabled public String cssClass {get; set;}


        // contructor method to copy team member details from Territory_Account_Association__c record
        public TeamMember(Territory_Account_Association__c taaRecord){

            recId = taaRecord.Id;
            userUrl= '/' + taaRecord.Territory__r.Portfolio_Owner__c;
            teamMember = taaRecord.Territory__r.Portfolio_Owner__r.Name;
			if(taaRecord.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_SALES_CONTROL){
				role = TAASettingConstants.POR_SALES_CONTROL ;	
			}
			else{
				role = taaRecord.Portfolio_Owner_Responsibility__c;
			}
            country = taaRecord.Territory__r.Portfolio_Owner_Country__c;
            brand = taaRecord.Brand__c;
            territory = taaRecord.Territory__r.Name;
            territoryUrl = '/' + taaRecord.Territory__c;

            // based on portfolio owner responsbility set scope
            if (taaRecord.Portfolio_Owner_Responsibility__c == 'Influencer - Country'){
                scope = taaRecord.Territory__r.Portfolio_Owner_Country__c;
            
            } else if (taaRecord.Portfolio_Owner_Responsibility__c == 'Influencer - Region'){
                scope = taaRecord.Territory__r.Portfolio_Owner_Region__c;
            
            } else if (taaRecord.Portfolio_Owner_Responsibility__c == 'Influencer - Area'){
                scope = taaRecord.Territory__r.Portfolio_Owner_Area__c;
            
            } else {
                scope = '';
            } 
            cssClass= 'slds-hide'; // to hide actions button (Edit/Delete)
        }

        // contructor method to copy team member details from Territory_Account_Association__c record
        public TeamMember(AccountTeamMember tmRecord, boolean isEditable){

            recId = tmRecord.Id;
            userUrl= '/' + tmRecord.UserId;
            teamMember = tmRecord.User.Name;
            role = tmRecord.TeamMemberRole;
            country = tmRecord.User.Country;
            scope = '';
            brand = tmRecord.User.Liner_Brand__c;
            territory = 'Manually Added';
            territoryUrl = '/' + tmRecord.UserId;

            if (isEditable){
                cssClass= 'slds-show'; // to show actions button (Edit/Delete)
            }else{ 
                cssClass= 'slds-hide'; // to hide actions button (Edit/Delete)
            }
        }
    }

    @AuraEnabled(cacheable = false)
    public static AccountTeamResponse getDataRows(Id accountId){

        // fetch record type id for Portfolio
        Id portfolioRecordTypeId = Schema.SObjectType.Territory__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
        AccountTeamResponse response = new AccountTeamResponse();
        Id parentId;
        Set<Id> setUsersAddedToList = new Set<Id>();
    
        User loggedInUser = StaticFactory.getCurrentUserDetails(); // get user details profile & brand

        Set<String> allowedProfiles = new Set<String>(Label.AddAccountTeamAccessProfiles.split(';')); // get profiles that are allowed to add/edit team members

        // Check if logged in user can add/edit team members based on allowed profiles
        if ( allowedProfiles.contains(loggedInUser.Profile.Name)){
            response.blnHasAddEditAccess = true;
        } 

        List<Account> lstAccount = [SELECT Id, ParentId FROM Account WHERE ID = :accountId];
        parentId = lstAccount[0].ParentId;
        
        //get portfolio records
        List<Territory_Account_Association__c> lstTerrAcc = [SELECT Id, Territory__r.Portfolio_Owner__c, Territory__r.Portfolio_Owner__r.Name, Portfolio_Owner_Responsibility__c,
                                                                Territory__r.Portfolio_Owner_Country__c , Territory__r.Portfolio_Owner_Region__c, Territory__r.Portfolio_Owner_Area__c,
                                                                Brand__c, Territory__r.Name, Territory__c, Represents_Concern__c
                                                                FROM Territory_Account_Association__c 
                                                                WHERE Account__c = :accountId AND Territory__r.RecordTypeId = :portfolioRecordTypeId
                                                                AND (End_Date__c =null Or End_Date__c >= TODAY) AND Start_Date__c <= TODAY];

        system.debug('### direct portfolio team: ' + lstTerrAcc);

        for (Territory_Account_Association__c assocRecord :  lstTerrAcc){

            // For direct connections if role is other than Global Account Owner list the team member 
            // Or if role = Global Account Owner and Represents Concern = true
            if ( assocRecord.Portfolio_Owner_Responsibility__c != TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER || (assocRecord.Portfolio_Owner_Responsibility__c == TAASettingConstants.POR_GLOBAL_ACCOUNT_OWNER && assocRecord.Represents_Concern__c == true)){
                
                if (!setUsersAddedToList.contains(assocRecord.Territory__r.Portfolio_Owner__c)){
                    setUsersAddedToList.add(assocRecord.Territory__r.Portfolio_Owner__c);
                    response.lstAccountTeamMembers.add(new TeamMember(assocRecord));
                }
            }

            // if logged in user is part of team then he has add/edit access
            if (loggedInUser.Id == assocRecord.Territory__r.Portfolio_Owner__c){
                response.blnHasAddEditAccess = true;
            }
        }

        system.debug('### parentId: ' + parentId);

        // check for Global Account Owner in same hierarchy
        String strQuery = 'SELECT Id, Territory__r.Portfolio_Owner__c, Territory__r.Portfolio_Owner__r.Name, Portfolio_Owner_Responsibility__c, Territory__r.Portfolio_Owner_Country__c , ';
        strQuery += ' Territory__r.Portfolio_Owner_Region__c, Territory__r.Portfolio_Owner_Area__c,Brand__c, Territory__r.Name, Territory__c, Represents_Concern__c, Account__r.ParentId';
        strQuery += ' FROM Territory_Account_Association__c ';
        strQuery += ' WHERE Portfolio_Owner_Responsibility__c = \'Global Account Owner\' AND Represents_Concern__c = true ';
        strQuery += ' AND Start_Date__c <= TODAY AND (End_Date__c = NULL OR End_Date__c >= TODAY) ';
        strQuery += ' AND Territory__r.RecordTypeId = :portfolioRecordTypeId AND Account__c != :accountId AND ';
        
        if (parentId == null){
            strQuery += ' Account__r.ParentId = :accountId ';
        }
        else{
            strQuery += ' (Account__r.ParentId = :parentId OR Account__c = :parentId  OR Account__r.ParentId = :accountId ) ';
        }

        List<Territory_Account_Association__c> lstTerrParentAcc = database.query(strQuery);
        for (Territory_Account_Association__c assocRecord :  lstTerrParentAcc){

            if (!setUsersAddedToList.contains(assocRecord.Territory__r.Portfolio_Owner__c)){ 
                setUsersAddedToList.add(assocRecord.Territory__r.Portfolio_Owner__c);
                response.lstAccountTeamMembers.add(new TeamMember(assocRecord));
            }
            
            if (loggedInUser.Id == assocRecord.Territory__r.Portfolio_Owner__c){
                response.blnHasAddEditAccess = true;
            }
        }
        system.debug('### indirect postfolio team: ' + lstTerrParentAcc);

        //get manually added records
        List<AccountTeamMember> lstAccTeamMembers = [SELECT Id, TeamMemberRole, User.Name, User.Country, UserId, User.Liner_Brand__c 
                                                   FROM AccountTeamMember WHERE AccountId = : accountId];
        
        system.debug('### manually added team: ' + lstAccTeamMembers);

        for (AccountTeamMember tmRecord :  lstAccTeamMembers){
            boolean isEditable = false;

            if ( allowedProfiles.contains(loggedInUser.Profile.Name) || linerBrandCompare(loggedInUser.Liner_Brand__c, tmRecord.User.Liner_Brand__c)){
                isEditable = true;
            }

            if (!setUsersAddedToList.contains(tmRecord.UserId)){
                setUsersAddedToList.add(tmRecord.UserId);
                response.lstAccountTeamMembers.add(new TeamMember(tmRecord, isEditable));
            }

            if (loggedInUser.Id == tmRecord.UserId){
                response.blnHasAddEditAccess = true;
            }
        }      
        return response;
    }

    //Logic to check if current user has any linerbrand matching with the team member
    public static boolean linerBrandCompare(String strUserlinerBrand, String strMemberLinerBrand) {
        
        boolean blnMatchFound = false;
        List<String> lstUserLinerBrands = strUserlinerBrand.split(';');
        Set<String> setMemberLinerBrands = new Set<String>(strMemberLinerBrand.split(';'));
             
        for( String userLinerBrand : lstUserLinerBrands) {
            if( setMemberLinerBrands.contains(userLinerBrand)){
                blnMatchFound = true;
                break;
            }
        }        
        return blnMatchFound;
    }

    @AuraEnabled
    public static String addEditTeamMember ( String accountId, String userId, String role, String teamMemberId){
        
        String returnMessage = 'success';
        try {

            AccountTeamMember rec = new AccountTeamMember();
            rec.TeamMemberRole = role;

            if (teamMemberId == null){
                rec.UserId = userId;
                rec.AccountId = accountId;

                Map<String,String> mapAccess = new Map<String, String>();
                List<String> lstAccessLevel = Label.AccountTeamMemberAccess.split(';');
                for (String str : lstAccessLevel){
                    List<String> lst = str.split('=');
                    mapAccess.put(lst[0], lst[1]);
                }
                rec.AccountAccessLevel = mapAccess.get('AccountAccessLevel');
                rec.OpportunityAccessLevel = mapAccess.get('OpportunityAccessLevel');
                rec.CaseAccessLevel = mapAccess.get('CaseAccessLevel');
                rec.ContactAccessLevel = mapAccess.get('ContactAccessLevel');
                
                insert rec;
            } else {
                rec.Id = teamMemberId;
                update rec;
            }
                
        }catch( DmlException dmEx){
            
            returnMessage =  dmEx.getDMLMessage(0);  
            
        } catch( Exception ex){
            
            returnMessage = ex.getMessage();              
        }
        return returnMessage;
    }

    @AuraEnabled
    public static String deleteTeamMember ( String teamMemberId){
        String returnMessage = 'success';
        try {
            AccountTeamMember rec = new AccountTeamMember();
            rec.Id = teamMemberId;
            delete rec;

        } catch( DmlException dmEx){
            returnMessage =  dmEx.getDMLMessage(0);  
            
        } catch( Exception ex){
            returnMessage = ex.getMessage();              
        }
        return returnMessage; 
    }
    // Method created to fetch the one Team sales details
    @AuraEnabled
    public static Map<string,String> fetchOneTeamDetails(Id accountId){
        Map<String, String> resultMap = null;
        Id clientaccRecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();  
        List<Account> lstAcc = [SELECT Id,Sales_Group__c FROM Account WHERE id = :accountId AND RecordTypeId = :clientaccRecordTypeid];        
        Map<String, OneTeamSales_Information__mdt> mapOTSInformation = OneTeamSales_Information__mdt.getAll();
        Map<String, String> otsinfo = new Map<String, String>();        
        for(String OTSInfoKey :mapOTSInformation.keySet()){
            otsinfo.put(mapOTSInformation.get(OTSInfoKey).Group_Name__c,mapOTSInformation.get(OTSInfoKey).Email_ID__c);
        }        
        if(lstAcc[0].Sales_Group__c !=null && otsinfo.containsKey(lstAcc[0].Sales_Group__c)){
            resultMap = new Map<String, String>();
            resultMap.put('EMAIL',otsinfo.get(lstAcc[0].Sales_Group__c));
            resultMap.put('GROUPNAME',lstAcc[0].Sales_Group__c);            
        }
        system.debug('resultMap>>>'+resultMap);
        return resultMap;
    }
}