/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-007192       21-02-2019     Junaid.Khader@ust-global.com         Code created
* 2.0          SFMC-7512       19-02-2024     ranjan@maersk                        MEL status on Lead related condition 
*/

public class CampaignMemberUtilities{
    
    public static void populateAccountOwnerEmailAndUpdateLeads(List<CampaignMember> listCampaignMember, Set<Id> setAssociatedContactIds, Set<Id> setAssociatedLeadIds){
        
        Map<Id, Contact> mapContactIdToContact = new Map<Id,Contact>([SELECT Id, Account.MSL_Account_Owner__r.Email from Contact WHERE Id IN :setAssociatedContactIds]);
        Map<Id, Lead> mapLeadIdToLead = new Map<Id, Lead>();
        Map<Id, Lead> mapLeadsToUpdate = new Map<Id, Lead>();
        Map<Id,Lead> mapMMCTrueLead=new Map<Id, Lead>();
        Set<Id> leadWithMELIdSet;
        Map<Id,Id> leadIdCampaignIdMap=new Map<Id,Id> ();

        Lead leadObjectRow;
        
        if(setAssociatedLeadIds.size() > 0) {
            mapLeadIdToLead = new Map<Id,Lead>([SELECT Id, Primary_Campaign__c,
                                                        IndividualId,
                                                        Maersk_Marketing_Consent__c,
                                                        FirstName,
                                                        LastName,
                                                        Company,
                                                        Email,
                                                        Country_lk__c,
                                                        LeadSource,
                                                        Status,
                                                        OwnerId FROM Lead WHERE Id IN :setAssociatedLeadIds ]);
        }
        for(CampaignMember rowCampaignMember : listCampaignMember){
            if((rowCampaignMember.ContactId != null) && mapContactIdToContact.containsKey(rowCampaignMember.ContactId) && (mapContactIdToContact.get(rowCampaignMember.ContactId).Account.MSL_Account_Owner__r.Email != null))
            {   
                rowCampaignMember.Account_Owners_Email__c = mapContactIdToContact.get(rowCampaignMember.ContactId).Account.MSL_Account_Owner__r.Email;
            }
            if(mapLeadIdToLead.isEmpty() || rowCampaignMember.LeadId==null){
                continue;
            }
            leadObjectRow = mapLeadIdToLead.get(rowCampaignMember.LeadId);    
            if(leadObjectRow!=null && leadObjectRow.Primary_Campaign__c==null ){
                    
                leadObjectRow.Primary_Campaign__c = rowCampaignMember.CampaignId;
                mapLeadsToUpdate.put(leadObjectRow.Id, leadObjectRow);
            }
            //check for MEL condition
            if(leadObjectRow!=null && leadObjectRow.Maersk_Marketing_Consent__c && rowCampaignMember.CampaignId!=null){
                leadIdCampaignIdMap.put(leadObjectRow.Id,rowCampaignMember.CampaignId);
                mapMMCTrueLead.put(leadObjectRow.Id, leadObjectRow);
            }
        }
        //check for MEL condition
        leadWithMELIdSet=LeadMELUpdator.checkLeadsForMEL(mapMMCTrueLead);
        Boolean skipCampignMelLogic=(LeadRecordSelector.operationIdSetMap!=null &&  
        LeadRecordSelector.operationIdSetMap.containsKey('MELchanges')?true:false);
        if(leadWithMELIdSet!=null && !leadWithMELIdSet.isEmpty() && !skipCampignMelLogic){
            Map<Id,Campaign> campaignMap=new Map<Id,Campaign>([Select Id,OwnerId,Owner.IsActive from Campaign where id in:leadIdCampaignIdMap.values() and (Campaign_Category__c='Marketing' or Campaign_Category__c=null) 
                                                                and Campaign.IsActive=true]);
            for (Id leadId : leadWithMELIdSet) {
                Lead tempLeadObj=mapLeadIdToLead.get(leadId);
                String OwnerType=tempLeadObj.OwnerId;
                Campaign camptempObj=campaignMap.get(leadIdCampaignIdMap.get(leadId));
                if(camptempObj==null){continue;}
                if(OwnerType.startsWithIgnoreCase('00G') && camptempObj.Owner.IsActive){
                    tempLeadObj.OwnerId=String.valueOf(camptempObj.OwnerId);
                }
                tempLeadObj.Status='Marketing Engaged (MEL)';
                mapLeadsToUpdate.put(tempLeadObj.Id, tempLeadObj);
            }  
        }
        //end of check for MEL condition
        if(!mapLeadsToUpdate.isEmpty()){
            Boolean rerunstopped=Generic_TriggerHandler.validateRunForMethod('LeadMELUpdator.updateToMEL', 1);
            List<Database.SaveResult> listLeadUpdateResult = Database.Update(mapLeadsToUpdate.values(), false);
            ErrorLogger.writeErrors('SFDC', 'CampaignMemberUtilities', 'populateAccountOwnerEmailAndUpdateLeads', listLeadUpdateResult, mapLeadsToUpdate.values());
        }
    }
    
    public static void resetPrimaryCampaignOnLeads(List<CampaignMember> listOldCampaignMember, Set<Id> setAssociatedLeadOfDeletedCampaignIds, Set<Id> setAssociatedCampaignIds){
        Map<Id, CampaignMember> mapLeadIdToPrimaryCampaign = new Map<Id, CampaignMember>();
        Map<Id, Lead> mapLeadIdToLead = new Map<Id,Lead>([SELECT Id, Name, Primary_Campaign__c FROM Lead WHERE Id IN :setAssociatedLeadOfDeletedCampaignIds AND Primary_Campaign__c IN :setAssociatedCampaignIds]);
        Map<Id,Lead> mapLeadIdToLeadsToUpdate = new Map<Id,Lead>();
        Lead leadObjectRow;
        
        for(CampaignMember rowCampaignMember : [SELECT LeadId, CampaignId, CreatedDate
                                                FROM CampaignMember
                                                WHERE LeadId IN :mapLeadIdToLead.keySet()
                                                    AND CampaignId NOT IN :setAssociatedCampaignIds
                                                ORDER BY CreatedDate ASC]) {
            if(mapLeadIdToPrimaryCampaign.containsKey(rowCampaignMember.LeadId) && mapLeadIdToPrimaryCampaign.get(rowCampaignMember.LeadId) != null){
                if(rowCampaignMember.CreatedDate < mapLeadIdToPrimaryCampaign.get(rowCampaignMember.LeadId).CreatedDate)
                    mapLeadIdToPrimaryCampaign.put(rowCampaignMember.LeadId, rowCampaignMember);
            } else {
                mapLeadIdToPrimaryCampaign.put(rowCampaignMember.LeadId, rowCampaignMember);
            }
        }
        for(CampaignMember rowCampaignMember : listOldCampaignMember){
            if(rowCampaignMember.LeadId != null){
                if(mapLeadIdToLead.containsKey(rowCampaignMember.LeadId) && mapLeadIdToLead.get(rowCampaignMember.LeadId) != null){
                    leadObjectRow = mapLeadIdToLead.get(rowCampaignMember.LeadId);
                    leadObjectRow.Primary_Campaign__c = (mapLeadIdToPrimaryCampaign.containsKey(rowCampaignMember.LeadId)) ? mapLeadIdToPrimaryCampaign.get(rowCampaignMember.LeadId).CampaignId : null;
                    mapLeadIdToLeadsToUpdate.put(leadObjectRow.Id, leadObjectRow);
                }
            }
        }
        if(mapLeadIdToLeadsToUpdate.size() > 0){
            List<Database.SaveResult> listLeadUpdateResult = Database.Update(mapLeadIdToLeadsToUpdate.values(), false);
            ErrorLogger.writeErrors('SFDC', 'CampaignMemberUtilities', 'resetPrimaryCampaignOnLeads', listLeadUpdateResult, mapLeadIdToLeadsToUpdate.values());
        }
    }
}