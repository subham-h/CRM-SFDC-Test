/*              
* Revision Ref Number  Date        Owner                           Description
* -------- ----------  ----------- -----------------               -----------
* 1.0      RQ-004490   22-Jan-2019  Abhinav.ankit@maerak.com        Code created
* 2.0      SFSE-72     21-May-2020  Amritesh@UST                    Handled empty owner
* 2.1      SFSE-5063   11-Jan-2021  Nitin@Maersk                    Amended as per SFSE-5063 story
* 2.2      SFSE-5386   22-Jan-2021  Neha@TCS                        Amended the populateOwnershipCluster() to set country look up field based on COuntry standard field if it is not null
* 2.3      SFSE-5063   25-Jan-2021  Nitin@Maersk                    Amended populateOwnershipCluster to update ownership cluster based on country 
*                                                                   but re-run assginment rule only if its assigned to queue.
* 2.4      SFSE-5063   10-Feb-2021  Nitin@Maersk                    Removed lead.OwnerId != null check so that Ownership Cluster is set when lead created via LinkedIn 
*/

public class LeadUtilities {
    
    // populate Ownership Cluster field if Owner/Country is modified
    public static void populateOwnershipCluster( List<Lead> lstLeads, Map<Id, Lead> mapOldLeads ) { 
                 
        if(Generic_TriggerHandler.validateRunForMethod('LeadUtilities.populateCountryCluster', 1)){ // to stop recursion
            
            Set<Id> setCountryIds = new Set<Id>(); // Store Geography Ids selected in Lead
            Map<Id, Id> mapCountryToCluster = new Map<Id, Id>(); // Store Mapping between Country to Cluster(BDA) Ids
            
            Lead oldLead;           
            
            //get metadata which stores Linkedin and SFDC value for Countries coming from Linkedin
            Map<String,String> countryMap = new Map<String,String>();        // Map to store the values which is being queried from Metadata    
            for(CountryTranslation__mdt temapObj : [SELECT LinkedIn_Value__c,SFDC_Value__c FROM CountryTranslation__mdt]){
                countryMap.put(temapObj.LinkedIn_Value__c , temapObj.SFDC_Value__c);
            }
             // get country data to prepare Map for Geo name along with the id of the country which is being passed from LinkedIn
             Map<String,String> countryIdNameMap = new Map<String,String>();
             for(Geography__c geoObj : [Select id,name from Geography__c where Type_Of_Location__c ='Country']){
                 countryIdNameMap.put(geoObj.name,geoObj.id);
             }
    
            for (Lead leadRec : lstLeads){
          
                String countrySrt = '';                
                if(leadRec.Country_lk__c == NULL ){
                     if(countryMap.containsKey(leadRec.country)){
                        countrySrt = countryMap.get(leadRec.country);
                     }else{
                        countrySrt = leadRec.country; 
                     }

                    leadRec.Country_lk__c = countryIdNameMap.get(countrySrt); // set the look up field from teh standard COuntry field.           
                
                }

                if( leadRec.Country_lk__c != NULL ){
                    setCountryIds.add(leadRec.Country_lk__c);
                    system.debug('setCountryIds ' + setCountryIds);
                }
            }
            
            if (setCountryIds.size() > 0){
                //  Get Cluster for Lead  country from BDA Geography 
                for( BDA_Geography__c bdaGeoRec : [ SELECT Id, Geography__c, BDA__c FROM BDA_Geography__c WHERE Geography__c IN :setCountryIds AND BDA__r.Type__c = 'Cluster' AND BDA__r.Active__c = True ]){
                    mapCountryToCluster.put(bdaGeoRec.Geography__c, bdaGeoRec.BDA__c);
                    system.debug('mapCountryToCluster ' + mapCountryToCluster);
                }
            }
            
            for (Lead leadRec : lstLeads){
                
                if (mapOldLeads != null){
                    oldLead = mapOldLeads.get(leadRec.Id);
                }
                
                // If Insert or on update when country is changed & Country != null & country is mapped to a cluster then assign Ownership cluster to Country's Cluster
                if(leadRec.Country_lk__c != NULL && mapCountryToCluster.get(leadRec.Country_lk__c) != NULL && (mapOldLeads == null || leadRec.Country_lk__c != oldLead.Country_lk__c)){
                    system.debug('mapCountryToCluster.get(leadRec.Country_lk__c) ' + mapCountryToCluster.get(leadRec.Country_lk__c));   
                    leadRec.Country_Ownership_Cluster__c = mapCountryToCluster.get(leadRec.Country_lk__c);
                    
                } else if (mapOldLeads != null && leadRec.Country_lk__c != oldLead.Country_lk__c){
                    // if country was modified but country is not mapped to any cluster then make Ownership Cluster to null 
                    leadRec.Country_Ownership_Cluster__c = null;
                }                
                    
                // As Ownership Cluster is modified as effect of Country's change then we need to rerun assignment rules only if owner is not a user.
                // add lead to static list from Record selector which is then used in After Update Trigger 
                if (mapOldLeads != null && leadRec.Country_lk__c != oldLead.Country_lk__c && String.valueOf(leadRec.OwnerId).Substring(0,3) != '005'){
                    LeadRecordSelector.lstLeadIdsRerunAssignmentRules.add(leadRec.Id);
                }
             }
        }
    }
    
    // if in before trigger Ownership cluster is assigned based on country then rerun assignment rules to assign correct owner 
    public static void RerunAssignmentRules( List<Id> lstLeadIds) { 
        
        if(Generic_TriggerHandler.validateRunForMethod('LeadUtilities.RerunAssignmentRules', 1)){ // to stop recursion
          //  AssignLeadsUsingAssignmentRules.LeadAssign(lstLeadIds);
         /*   List<Lead> lstLeadsToUpdate = new List<Lead>();
            
            // Set DML options to rerun assignment rules for the impacted leads
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;            
            
            // re-fetch leads 
            for( Lead leadRec : [SELECT Id FROM Lead WHERE Id in :lstLeadIds] ) {
                
                leadRec.setOptions(dmo);
                lstLeadsToUpdate.add(leadRec);
             }            
          
            TriggerExecutionController.skipLeadTrigger(true);
            update lstLeadsToUpdate;   
            TriggerExecutionController.skipLeadTrigger(false);*/
        }
    }
    
    // validation before lead is converted - check if converted opportunity and contact belong to same linerbrand.
    public static void validateLeadConversion (List<Lead> lstLeads){
        
        List<Id> lstContactIds = new List<Id>();
        List<Id> lstOpptyIds = new List<Id>();
        
        // form list of converted contact ids and opportunity ids
        for (Lead leadRecord : lstLeads){
            
            lstOpptyIds.add(leadRecord.ConvertedOpportunityId);
            lstContactIds.add(leadRecord.ConvertedContactId);             
        }        
        
        // fetch Converted Contact & opportunity's Liner Brand
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Liner_Brands__c FROM Contact WHERE Id in :lstContactIds]);
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Liner_Brand__c FROM Opportunity WHERE Id in :lstOpptyIds]);
        
        for (Lead leadRecord : lstLeads){
            
            Set<String> setBrands = new Set<String>();
            
            if (mapContacts.get(leadRecord.ConvertedContactId) != null && mapOpportunities.get(leadRecord.ConvertedOpportunityId) != null){
                
                // As Contact liner brand is multi-select, break string in to a set
                if (mapContacts.get(leadRecord.ConvertedContactId).Liner_Brands__c != null){
                    setBrands.addAll(mapContacts.get(leadRecord.ConvertedContactId).Liner_Brands__c.split(';'));
                }
                
                // If Contact brand is not blank and it does not contain Oppty liner brand then show error
                if( !setBrands.isEmpty() && !setBrands.contains(mapOpportunities.get(leadRecord.ConvertedOpportunityId).Liner_Brand__c) )  {
                    leadRecord.addError(Label.LeadConversionBrandMismatchError  );
                }   
            }
        }      
        
    }
}