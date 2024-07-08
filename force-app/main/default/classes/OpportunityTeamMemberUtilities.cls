/*
* Trigger Handler Utility Class for Opportunity Trigger
* 
* Version  Date         Owner                                    RQ#           Description
****************************************************************************************************************************************
* 1.0      08/02/2016   meghana.gupta@ust-global.com           #RQ-002301     Opportunity Trigger - Refactoring.
* 2.0      08/10/2017   uvais.komath@ust-global.com            #RQ-005320     Made Class without sharing.
* 3.0      08/11/2017   Sandhya.Sambasivan@ust-global.com      #RQ-005318     Remove Owner
* 4.0      01-Jul-2019  manjunath.c.holekade@maersk.com        #RQ-010753     Remove validation related to User and Opp'ty liner brand mismatch
* 4.1      26-Nov-2019  meghana.gupta@ust-global.com           #RQ-012622     In case owner and creator is same, add user as "Opportunity owner" instead of 'Opportunity Creator'
* 5.1      23-Jan-2020  Neha@TCS                               #RQ-012907     Add Opportunity Owner where Owner is updated manually and it is not changed the Role in Opportunity Team 
*/

public without sharing class OpportunityTeamMemberUtilities {
    
    public static void shareContract( List<OpportunityTeamMember> newOTMList, map<Id, OpportunityTeamMember> oldOpptyMeMMap, Set<Id> optmIds) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> oldUserIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
         Map<Id, Id> oppIdtoOwnerId = new Map<Id, Id>();
        if(newOTMList !=null && newOTMList.size() > 0) {
            for(OpportunityTeamMember oppMr: newOTMList){
                if(oldOpptyMeMMap !=null && !oldOpptyMeMMap.isEmpty()){
                    OpportunityTeamMember oldOpTM = (OpportunityTeamMember) oldOpptyMeMMap.get(oppMr.Id);
                    oldUserIds.add(oldOpTM.UserId); 
                }
                userIds.add(oppMr.UserId);
                oppIdtoOwnerId.put(oppMr.OpportunityId, oppMr.UserId);
                oppIds.add(oppMr.OpportunityId);                       
            }
        }
        List<Contract__share> contractShare = new List<Contract__share>();
        if(optmIds !=null) {
            contractShare = [SELECT Id, UserOrGroupId FROM Contract__share WHERE UserOrGroupId IN: optmIds];   
        }else{
            contractShare = [SELECT Id, UserOrGroupId FROM Contract__share WHERE UserOrGroupId IN: oldUserIds];
        }
        
        If(contractShare.size() > 0) {
            delete contractShare;
        }
        List<Opportunity_Contract__c> lstContract = [SELECT Id, Contract__c, Opportunity__c from Opportunity_Contract__c where Opportunity__c  IN:oppIds];
        List<Contract__Share> cOShareListToCreate = new List<Contract__Share>();
        Map<Id, List<Id>> mapOfOppIdtoContractId = new Map<Id,List<Id>>();
        for(Opportunity_Contract__c coN: lstContract) {
            Contract__Share coNtoShare = new Contract__Share();
            coNtoShare.ParentId =  coN.Contract__c;
            coNtoShare.UserOrGroupId = oppIdtoOwnerId.get(coN.Opportunity__c);
            coNtoShare.RowCause = 'Manual';
            coNtoShare.AccessLevel = 'Read';  
            cOShareListToCreate.add(coNtoShare);
            system.debug('cOShareListToCreate ' + cOShareListToCreate);
        } 
        try{
            if(newOTMList !=null && newOTMList.size() > 0) {
                Database.insert(cOShareListToCreate); 
            }
        } Catch(Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Contract', 'OpportunityUtilities.shareContract', new list<Exception>{e});
        }
    }
    public static void UpdateOpportunityTeam( List<Opportunity> newOpptyList, Map<Id, Opportunity> oldOpptyMap, Boolean isTriggerInsert ){
        /*
        1. Opportunity Creator should have R/W access on Opportunity
        2. Old Opportunity Owner's role should be changed to Team Member
        */
        system.debug('$$$ UpdateOpportunityTeam: '+ newOpptyList);
        
        if(Generic_TriggerHandler.validateRunForMethod('OpportunityTeamMemberUtilities.UpdateOpportunityTeam', 1)){ 
            
            Map<Id, Opportunity> newOpptyMap = new Map<Id, Opportunity>();
            Map<Id, String> userIdToTeamMemberRoleMap;
            Map<Id, Opportunity> oppToOppMbrMap = new Map< Id, Opportunity >();
            List<OpportunityTeamMember> oppTeamMbrsToUpsert = new List<OpportunityTeamMember>();
            // List<OpportunityTeamMember> oppTeamMbrsToBeUpdated = new List<OpportunityTeamMember>();
            Map<Id, Set<Id>> OpptyToUserMap_ForShareUpdate = new Map<Id, Set<Id>>();
            Set<Id> setUserIdsForShareUpdate = new Set<Id>();
            
            if ( !isTriggerInsert ){
                
                // get existing opportunity team list
                oppToOppMbrMap = new Map< Id, Opportunity >( [SELECT Id, (SELECT id, UserId, User.Liner_Brand__c, TeamMemberRole FROM OpportunityTeamMembers) 
                                                              FROM Opportunity 
                                                              WHERE Id IN : oldOpptyMap.keySet()] );
            }
            
            for( Opportunity oppty : newOpptyList ){
                
                newOpptyMap.put( oppty.id, oppty); // map created so to assign error to a particular opportunity
                
                // prepare a map of user id to role for new users to be added to the opportunity team
                userIdToTeamMemberRoleMap = new Map<Id,String>();
                
                // on opportunity creation add opportunity creator to the team 
                // 4.1 - added condition oppty.CreatedById != oppty.OwnerId
                if ( isTriggerInsert && oppty.CreatedById != oppty.OwnerId ){             
                    
                    userIdToTeamMemberRoleMap.put( oppty.CreatedById, Label.Team_Role_Label_Opportunity_Creator );
                    
                }
                
                // on opportunity update add opportunity creator to the team. Opprtunity Creator should remian same.
                // Do not add a user to team who is presnet already in list as Team member again.
                if ( !isTriggerInsert && (oldOpptyMap.get(oppty.Id).ownerId <> Null) && 
                    oldOpptyMap.get(oppty.Id).ownerId <> oppty.ownerId){             
                        Map<Id, String> oppTeamMap = new Map<Id, String>();
                        for( OpportunityTeamMember oppMbr : oppToOppMbrMap.get( oppty.id ).OpportunityTeamMembers ){
                            oppTeamMap.put(oppMbr.UserId, oppMbr.TeamMemberRole);
                        }
                        System.debug('$$$ oppTeamMap'+oppTeamMap);
                        System.debug('$$$ oldOpptyMap'+oldOpptyMap);
                        if(!oppTeamMap.containsKey(oldOpptyMap.get(oppty.Id).ownerId)|| 
                           (oppTeamMap.containsKey(oldOpptyMap.get(oppty.Id).ownerId) && ((oppTeamMap.get(oldOpptyMap.get(oppty.Id).ownerId) <> Label.Team_Role_Label_Opportunity_Creator)||
                                                                                          (oppTeamMap.get(oldOpptyMap.get(oppty.Id).ownerId) <> Label.Team_Role_Label_Team_Member)))){                                                                                        
                                                                                              userIdToTeamMemberRoleMap.put( oldOpptyMap.get(oppty.Id).ownerId, Label.Team_Role_Label_Team_Member );
                                                                                              System.debug('$$$ userIdToTeamMemberRoleMap:::::::'+userIdToTeamMemberRoleMap);
                                                                                          }
                    }
                
                
                if ( !isTriggerInsert && oppty.ownerId <> Null &&  oldOpptyMap.get(oppty.Id).ownerId <> oppty.ownerId){                     
                    userIdToTeamMemberRoleMap.put(oppty.ownerId, Label.Team_Role_Opportunity_Owner);
                    
                }
                
                System.debug('$$$ userIdToTeamMemberRoleMap: ' + userIdToTeamMemberRoleMap);
                system.debug('$$$ oppTeamMbrsToUpsert: update' + oppTeamMbrsToUpsert);
                // add opportunity team member to the list to be inserted
                for ( Id userId : userIdToTeamMemberRoleMap.keyset() ){
                    
                    OpportunityTeamMember newOTM = new OpportunityTeamMember();
                    newOTM.OpportunityId = oppty.Id;
                    newOTM.UserId = userId;  
                    newOTM.TeamMemberRole = userIdToTeamMemberRoleMap.get( userId );
                    oppTeamMbrsToUpsert.add( newOTM );              
                    
                }
                system.debug('$$$ oppTeamMbrsToUpsert: insert' + oppTeamMbrsToUpsert);
                // prepare a map & set of user ids to update newly inserted team memeber's access level to edit. By default users get Read only access
                OpptyToUserMap_ForShareUpdate.put ( oppty.Id, userIdToTeamMemberRoleMap.keyset() ); 
                setUserIdsForShareUpdate.addAll ( userIdToTeamMemberRoleMap.keyset()  );
                
            }
            
            // error handling in case updating opportunity team member fails due to some reason
            if( oppTeamMbrsToUpsert.size() > 0 ){
                
                Schema.SObjectField f = OpportunityTeamMember.Fields.Id;
                TriggerExecutionController.skipOpportunityTeamMemberTrigger(true);
                System.debug('$$$ oppTeamMbrsToUpsert:::::::'+oppTeamMbrsToUpsert);
                List<Database.UpsertResult> upsertResultList = Database.upsert( oppTeamMbrsToUpsert, f , false ); 
                System.debug('$$$ oppTeamMbrsToUpsert After:::::::'+upsertResultList);
                TriggerExecutionController.skipOpportunityTeamMemberTrigger(false);             
                
                // loop through saveResult
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    
                    // if record update failed, get error message 
                    if ( !upsertResultList[i].isSuccess() ) {
                        
                        String ErrorDesc = '';
                        for( Database.Error err : upsertResultList[i].getErrors() ) {
                            
                            ErrorDesc = ErrorDesc + err.getMessage() + '\n';
                            System.debug('$$$ ErrorDesc After:::::::'+ErrorDesc);
                            
                        }
                        newOpptyMap.get( oppTeamMbrsToUpsert[i].OpportunityId ).addError ( ErrorDesc );
                    }
                }
            }
            
            if( OpptyToUserMap_ForShareUpdate.size() > 0){
                
                //Giving access level - Edit to newly added Opportunity Team Members
                List<OpportunityShare> shares = [SELECT Id, OpportunityAccessLevel, RowCause, OpportunityId, UserOrGroupId
                                                 FROM OpportunityShare 
                                                 WHERE OpportunityId IN :OpptyToUserMap_ForShareUpdate.keySet() 
                                                 AND RowCause = 'Team' AND OpportunityAccessLevel != 'Edit'
                                                 AND UserOrGroupId in :setUserIdsForShareUpdate ]; 
                
                for (OpportunityShare share : shares){
                    
                    if ( OpptyToUserMap_ForShareUpdate.get ( share.OpportunityId ).contains( share.UserOrGroupId )){
                        
                        share.OpportunityAccessLevel = 'Edit';                      
                    }
                }                   
                database.update ( shares, false );                  
            }
        }
    }
    
    public static void validateTeamMemberList( List<OpportunityTeamMember> newOTMList){
        
        if(Generic_TriggerHandler.validateRunForMethod('OpportunityTeamMemberUtilities.validateTeamMemberList', 1)){ 
            
            //get all distinct opportunity Id's available in  newOTMList;
            Map<Id,OpportunityTeamMember> oppIdToOppTeamMbrMap = new Map<Id,OpportunityTeamMember>();
            List<OpportunityTeamMember> oppMbrsOptedOut  = new List<OpportunityTeamMember> (); // opportunity Team Members that cannot be Inserted
            
            /* #RQ-000222:-Getting the all User and Opportunity records with liner brand based on the newOTMList */
            
            Set<Id> userIds = new Set<Id>();
            Set<Id> oppIds = new Set<Id>();
            
            //Getting the opportunity and User Id's available in  newOTMList
            for(OpportunityTeamMember oppMr: newOTMList){
                
                userIds.add(oppMr.UserId);
                oppIds.add(oppMr.OpportunityId);           
                
            }
            Map<Id,User> userIdToUsrMap = new Map<Id,User>( [SELECT Id, Name, Liner_Brand__c FROM User WHERE Id IN :userIds]);//Getting the all Users based on the newOppTeamMbrList User Id's
            
            //Getting the all Opportunities based on the newOppTeamMbrList Opportunity Id's
            Map<Id,Opportunity> oppIdToOppMap = new Map<Id,Opportunity>( [SELECT Id, Name, Liner_Brand__c, OwnerId, 
                                                                          ( SELECT OpportunityId, TeamMemberRole FROM OpportunityTeamMembers WHERE TeamMemberRole LIKE :Label.Team_Role_Label_Owner+'%')
                                                                          FROM Opportunity WHERE Id IN :oppIds]); 
            
            Set<Id>existingOppIdSet = new Set<Id>(); // set of opportunity ids that already have a owner record in OpportunityTeamMember
            for ( Opportunity opp : oppIdToOppMap.values()){
                if( opp.OpportunityTeamMembers != null && opp.OpportunityTeamMembers.size() > 0){
                    existingOppIdSet.add(opp.Id); 
                }
            }
            
            for(OpportunityTeamMember oppMbr: newOTMList){
                
                // #RQ-000222:- Validating the Liner brand matching for User and Opportunity based on the newOTMList  
                if(userIdToUsrMap != null && oppIdToOppMap != null && oppMbr.UserId != null && oppMbr.TeamMemberRole != null){
                    //#RQ-000803:SAM changed to Owner
                    if(oppMbr.TeamMemberRole.contains(Label.Team_Role_Label_Owner)){ // Checking for Owner role in the Opportunity Team member list                                
                        
                        if( oppIdToOppTeamMbrMap.get( oppMbr.OpportunityId )== null && !existingOppIdSet.contains(oppMbr.OpportunityId)){
                            
                            oppIdToOppTeamMbrMap.put( oppMbr.OpportunityId, oppMbr );
                            
                        } else {                               
                            
                            oppMbr.addError(Label.Error_User_Exists_As_Owner_Creator);  // Since already an Entry with Owner role  added in List , Opting out all other Owner role Entries.
                        }
                    }                   
                }                  
            }
        }   
    }
}