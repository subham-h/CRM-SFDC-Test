/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7511   25-Jan-2024 ranjan@maersk           Identify Existing accounts for newly created and updated lead, & Giving visibility to their Sales Representatives - Apex changes
*/
//find the exact matching contact having email same as corresponding lead
//return the un matched lead whose email did not exist in the SFDC with any contact
//input the newly/updated created lead list
public without sharing class DuplicateAccountUpdator {
    public static List<Lead> assignAccountWtEmail(List<Lead> leadList){
        Map<String,Id> emailAccIdMap=new Map<String,Id>();
        List<lead> unMappedLeads=new List<lead>();
        Set<String> emailSet=new Set<String>();
        for(Lead ldObj:leadList){
            emailSet.add(ldObj.Email);
        }
        List<Contact> conList=[Select Id,AccountId,Email from Contact where Email in:emailSet];
        for(Contact conObj:conList){
            emailAccIdMap.put(conObj.Email,conObj.AccountId);
        }
        for(Lead ldObj:leadList){
            if(emailAccIdMap.containsKey(ldObj.Email)){
                ldObj.Account__c=emailAccIdMap.get(ldObj.Email);
                ldObj.Account_Match_Confidence__c=100;
            }else{
                unMappedLeads.add(ldObj);
            }
        }
        return unMappedLeads;
    }
    //find the approximately matching account with given leads using the duplicate and match rule
    //return the lead by populating the account and confidence score if at any approximate match found
    public static void assignDuplicateAccounts(List<Lead> leadList){
        List<Datacloud.FindDuplicatesResult> dtDupResList=Datacloud.FindDuplicates.findDuplicates(leadList);
        Integer ldIndex=0;
        for (Datacloud.FindDuplicatesResult findDupeResult : dtDupResList) {
            Double existingMatchScore=0;
            String accountId=null;
            Double matchConfidence=0;
            Lead ldObj=leadList.get(ldIndex);
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        Double currentMatchScore=matchRecord.getMatchConfidence();
                        String recId=matchRecord.getRecord().id;
                        if(!recId.startsWithIgnoreCase('001')){continue;}
                        accountId=(currentMatchScore>existingMatchScore?matchRecord.getRecord().id:accountId);
                        matchConfidence=(currentMatchScore>existingMatchScore?currentMatchScore:existingMatchScore);
                        existingMatchScore=currentMatchScore;
                    }
                }
            }
            ldObj.Account__c=accountId;
            ldObj.Account_Match_Confidence__c=matchConfidence;
            ldIndex++;
        }
    }
    //get the maersk email domain list from metadata
    public static Set<String> maerskEmailDomSet=new Set<String>();
    public static Set<String> getMaerskEmailSet(){
        if(!maerskEmailDomSet.isEmpty()){
            return maerskEmailDomSet;
        }
        List<Maersk_Email_Domain__mdt> medMetaList = Maersk_Email_Domain__mdt.getAll().values();
        for(Maersk_Email_Domain__mdt medObj:medMetaList){
            maerskEmailDomSet.add(medObj.Email_Domain__c);
        }
        return maerskEmailDomSet;
    }
    //check if the email has maersk domain
    public static Boolean isEmailMaerskDomain(String emailId){
        if(String.isBlank(emailid)||!emailid.containsIgnoreCase('@')){return true;}
        String emailDomain=emailId.split('@')[1];
        return DuplicateAccountUpdator.getMaerskEmailSet().contains(emailDomain.toLowerCase());
    }
    //has the lead related field changed namely Company,Country_lk__c,PostalCode,Phone
    public static Boolean hasAccRelfieldChanged(Lead oldLead,Lead newLead){
        if(oldLead.Company!=newLead.Company ||
            oldLead.Country_lk__c!=newLead.Country_lk__c||
            oldLead.PostalCode!=newLead.PostalCode||
            oldLead.Phone!=newLead.Phone)
        {
            return true;
        }
        return false;   
    }
}