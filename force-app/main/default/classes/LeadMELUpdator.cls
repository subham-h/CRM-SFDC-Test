/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7512   15-Feb-2024 Ranjan@maersk           Created
*/
public without sharing class LeadMELUpdator { 
    public static void updateToMEL(Map<Id,Lead> leadMap,Boolean isUpdateRequired){
        if(!Generic_TriggerHandler.validateRunForMethod('LeadMELUpdator.updateToMEL', 1)){
            return;
        }//avoid recursion
        Set<Id> indivIdSet=new Set<Id>();//individal id to Lead Id Map
        Map<Id,Lead> leadToMMCTrueUpdate=new Map<Id,Lead>();//lead with Maersk marketing consent true
        Map<Id,Lead> leadToMMCFalseUpdate=new Map<Id,Lead>();//lead with Maersk marketing consent false
        Set<Id> leadsWithIndivIdSet=new Set<Id>();//all the leads having individual id associated with it 
        for(Lead leadTempObj: leadMap.values()){
            if(leadTempObj.IndividualId==null && leadTempObj.Maersk_Marketing_Consent__c){
                leadTempObj.Maersk_Marketing_Consent__c=false;
                leadToMMCFalseUpdate.put(leadTempObj.Id, leadTempObj);
            }else{
                indivIdSet.add(leadTempObj.IndividualId);
                leadsWithIndivIdSet.add(leadTempObj.Id);
            }
        }
        List<ContactPointTypeConsent> consentList =new List<ContactPointTypeConsent>();
        if(!indivIdSet.isEmpty()){//if the individual is is present
            consentList =[SELECT PartyId, PrivacyConsentStatus ,DataUsePurpose.Name,BusinessBrand.Name
            FROM ContactPointTypeConsent
            WHERE PartyId IN :indivIdSet
            and DataUsePurpose.Name = 'Marketing' and BusinessBrand.Name = 'Maersk'];
        }
        Map<Id,List<String>> leadIdConsentStatStrLstMap=new Map<Id,List<String>>();//lead id with list of consents
        for(ContactPointTypeConsent consentTempObj:consentList){
            if(!leadIdConsentStatStrLstMap.containsKey(consentTempObj.PartyId)){
                leadIdConsentStatStrLstMap.put(consentTempObj.PartyId, new List<String>());
            }
            leadIdConsentStatStrLstMap.get(consentTempObj.PartyId).add(consentTempObj.PrivacyConsentStatus);
        }
        for(Id leadId:leadsWithIndivIdSet){
            Lead leadRec=leadMap.get(leadId);
            if(leadIdConsentStatStrLstMap.containsKey(leadRec.IndividualId) && 
                (   leadIdConsentStatStrLstMap.get(leadRec.IndividualId).contains('OptIn')||
                    leadIdConsentStatStrLstMap.get(leadRec.IndividualId).contains('Seen'))
            ){
                leadRec.Maersk_Marketing_Consent__c=true;
                leadToMMCTrueUpdate.put(leadRec.Id,leadRec); 
            }else if(leadRec.Maersk_Marketing_Consent__c){//make MMC false only
                leadRec.Maersk_Marketing_Consent__c=false;
                leadToMMCFalseUpdate.put(leadRec.Id,leadRec); 
            }
        }
        if(leadToMMCTrueUpdate.isEmpty()){//if the leads with true conditions are absent then return 
            //post the update the of False MMC leads
            updateLeads(leadToMMCFalseUpdate,isUpdateRequired);
            return;
        }
        Set<Id> leadWithMELIdSet=checkLeadsForMEL(leadToMMCTrueUpdate);
        Map<Id,CampaignMember> leaddIdCampaignMemMap=getMELCampaigns(leadWithMELIdSet);
        changeLeadRec(leaddIdCampaignMemMap,leadToMMCTrueUpdate);
        leadToMMCTrueUpdate.putAll(leadToMMCFalseUpdate);
        updateLeads(leadToMMCTrueUpdate,isUpdateRequired);

    }
    //to be called from flow
    @InvocableMethod (label='Run MEL Update on Lead on Insert')
    public static void updateMelOnInsert()
    { 
        if (!LeadRecordSelector.operationIdSetMap.containsKey('AssignLead') && LeadRecordSelector.operationIdSetMap.containsKey('MELchanges')) {
            system.enqueueJob(new LeadMELUpdatorQueueable(LeadRecordSelector.operationIdSetMap));
        }    
    }
    //On CPCT changes look for MEL condition
    public static void updateLeadOnCPTC(Set<Id> IndividualIdSet){
        if(IndividualIdSet.isEmpty()){return;}
        Map<Id,Lead> leadMap=new Map<Id,Lead>([Select Id,
                                                      IndividualId,
                                                      Maersk_Marketing_Consent__c,
                                                      FirstName,
                                                      LastName,
                                                      Company,
                                                      Email,
                                                      Country_lk__c,
                                                      LeadSource,
                                                      Status,
                                                      OwnerId from Lead where IndividualId in:IndividualIdSet]);
        if(leadMap.isEmpty()){return;}
        LeadMELUpdator.updateToMEL(leadMap, true);    
    }
    //check the fields on lead for MEL
    public static Set<Id> checkLeadsForMEL(Map<Id,Lead> leadMap){
        Set<Id> leadWithMELIdSet=new Set<Id>();
        for (Lead leadTempObj : leadMap.values()) {
            if('New'.equalsIgnoreCase( leadTempObj.status) &&
                leadTempObj.FirstName!=null &&
                leadTempObj.LastName!=null &&
                leadTempObj.Company!=null &&
                leadTempObj.Email!=null &&
                leadTempObj.Country_lk__c!=null &&
                leadTempObj.LeadSource!= null){
                leadWithMELIdSet.add(leadTempObj.id);
            }
        }
        return leadWithMELIdSet;
    }
    //get the campaign member where Category is blank or Marketing
    public static Map<Id,CampaignMember> getMELCampaigns(Set<Id> leadWithMELIdSet){
        List<CampaignMember> campaignMemList=new List<CampaignMember>();
        if(!leadWithMELIdSet.isEmpty()){
            campaignMemList=[Select id,Campaign.OwnerId,Campaign.Owner.IsActive,leadId from CampaignMember 
                                                where LeadId in: leadWithMELIdSet 
                                                and (Campaign.Campaign_Category__c='Marketing' or Campaign.Campaign_Category__c=null) 
                                                and Campaign.IsActive=true Order by Createddate ASC];
        }
        Map<Id,CampaignMember> leaddIdCampaignMemMap=new Map<Id,CampaignMember>();
        for(CampaignMember cmpMemTempObj:campaignMemList){
            leaddIdCampaignMemMap.put(cmpMemTempObj.leadId,cmpMemTempObj);   
        }
        return leaddIdCampaignMemMap;
    }
    //assign the status as MEL and change the owner to Campaign owner
    public static void changeLeadRec(Map<Id,CampaignMember> leaddIdCampaignMemMap,Map<Id,Lead> leadToUpdate){
        for(Id leadTempId:leaddIdCampaignMemMap.keyset()){
            Lead tempLeadObj=leadToUpdate.get(leadTempId);
            String OwnerType=tempLeadObj.OwnerId;
            if(OwnerType.startsWithIgnoreCase('00G') && leaddIdCampaignMemMap.get(leadTempId).Campaign.Owner.IsActive){
                tempLeadObj.OwnerId=String.valueOf(leaddIdCampaignMemMap.get(leadTempId).Campaign.OwnerId);
            }
            tempLeadObj.Status='Marketing Engaged (MEL)';

        }
    }
    //update the lead records
    public static void updateLeads(Map<Id,Lead> updateLeadMap,Boolean isUpdateRequired){
        if(!isUpdateRequired || updateLeadMap.isEmpty()){//check unnecessary record update
            return;
        }
        TriggerExecutionController.skipLeadTrigger(true);
        Database.update(updateLeadMap.values(), false);
        TriggerExecutionController.skipLeadTrigger(false);
    }
}