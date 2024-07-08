/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7692   27-May-2024 Ranjan@maersk           Created
*/
public without sharing class SoftRegistrationUtility {
    public static Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Engagement_Tracker__c.getRecordTypeInfosByName();
    public static Map<Id,Lead> leadMap=new Map<Id,Lead>();
    public static Map<Id,Contact> conMap=new Map<Id,Contact>();
    public static Map<Id,Lead> leadToUpdate=new Map<Id,Lead>();
    public static Map<Id,Contact> conToUpdate=new Map<Id,Contact>();
    public static Map<Id,Engagement_Tracker__c> etMap=new Map<Id,Engagement_Tracker__c>();
    public static Map<Id,Engagement_Tracker__c> etConMap=new Map<Id,Engagement_Tracker__c>();
    public static Map<Id,Lead> queryLead(Set<Id> leadIds){
        Set<Id> leadIdtoQuerySet=new Set<Id>(); 
        for(Id leadId:leadIds){
            if(!leadMap.containsKey(leadId)){
                leadIdtoQuerySet.add(leadId);
            }
        }
        if(!leadIdtoQuerySet.isEmpty()){
            Map<id,Lead> ldTempMap=new Map<id,Lead>([Select Id,Email,Email_Verified__c,IndividualId from Lead where Id in:leadIdtoQuerySet]);
            leadMap.putAll(ldTempMap);
        }
        return leadMap;
    }
    public static void saveLead(){
        if(!leadToUpdate.isEmpty()){
            Database.update(leadToUpdate.values(), false);
        }
    }
    public static Map<Id,Contact> queryContact(Set<Id> conIds){
        Set<Id> conIdtoQuerySet=new Set<Id>();
        for(Id conId:conIds){
            if(!conMap.containsKey(conId)){
                conIdtoQuerySet.add(conId);
            }
        }
        if(!conIdtoQuerySet.isEmpty()){
            Map<id,Contact> conTempMap=new Map<id,Contact>([Select Id,Email,Email_Verified__c,IndividualId,FirstName,LastName,Name from Contact where Id in:conIdtoQuerySet]);
            conMap.putAll(conTempMap);
        }
        return conMap;
    }
    public static void saveContact(){
        if(!conToUpdate.isEmpty()){
            Database.update(conToUpdate.values(), false);
        }
    }
    public static Engagement_Tracker__c setDefaultFieldsEgTrc(){
        Engagement_Tracker__c engTrackObj=new Engagement_Tracker__c();
        //engTrackObj.Email_Verified__c=('ACCOUNT_REGISTERED'.equalsIgnoreCase(eventType)?false: true);
        engTrackObj.Engagement_Type__c='User Account Registration';
        engTrackObj.Lead_Source__c='User Account Registration';
        engTrackObj.Source_Brand__c='Maersk';
        engTrackObj.RecordTypeId=rtMapByName.get('User Registration').getRecordTypeId();
        return engTrackObj;
    }
    Public static Engagement_Tracker__c parse(String jsonStr){
        Map<String, Object> row = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        Map<String,String> fieldFromToMap=SoftRegistrationUtility.getPtEvtMetadata('msk.customeridentity.userprofile.topic.confidential.any.v3');
        Engagement_Tracker__c engTrackObj=setDefaultFieldsEgTrc();
        //exception for campaign fields
        if(row.containsKey('Campaign')){
            Map<String, Object> campaignRow = (Map<String, Object>)row.get('Campaign');
            row.remove('Campaign');
            row.putAll(campaignRow);
        }
        for(String keyStr:row.keySet()){
            if(!fieldFromToMap.containsKey(keyStr.toLowerCase()))
            {   
                continue;
            }
            engTrackObj.put(fieldFromToMap.get(keyStr.toLowerCase()), ArtemisEMPUtility.formatValue('Engagement_Tracker__c', fieldFromToMap.get(keyStr.toLowerCase()), row.get(keyStr)));
            
        }

        //separate logic for country
        if(row.containsKey('country')){
            String countryName=''+row.get('country')+'';
            engTrackObj.country__c= SoftRegistrationUtility.getCountryId(countryName);
        }
        if(row.containsKey('eventType')){
            Map<String,String> ciamFromToMap=SoftRegistrationUtility.fetchSFMCKeyValueMap('CIAM Mapping');
            Map<String,String> ciamCriteriaMap=SoftRegistrationUtility.fetchSFMCKeyValueMap('Event Consumption Criteria');
            String eventtype=''+row.get('eventType')+'';
            if(!ciamFromToMap.containsKey(eventtype.toLowerCase())){return null;}
            String registraionSource=''+row.get('registrationSource')+'';
            String isNewsAndMarketingAccepted=''+row.get('isNewsAndMarketingAccepted')+'';
            if(!ciamCriteriaMap.get('registrationsource').contains(registraionSource)){return null;}
            if(!ciamCriteriaMap.get('isnewsandmarketingaccepted').equalsIgnoreCase(isNewsAndMarketingAccepted) &&
            'ACCOUNT_REGISTERED'.equalsIgnoreCase(eventType)){return null;}
            engTrackObj.Email_Verified__c=('ACCOUNT_REGISTERED'.equalsIgnoreCase(eventType)?false: true);
            engTrackObj.Registration_Status__c=ciamFromToMap.get(eventtype.toLowerCase()); 
        }
        //logic for eventype
        return engTrackObj;
    }
    public static void stampLeadContact(Set<Id> leadToMakeEmVerTrueIds, Set<Id> conToMakeEmVerTrueIds){
        if(!leadToMakeEmVerTrueIds.isEmpty()){
            queryLead(leadToMakeEmVerTrueIds);
        }
        for(Id leadId:leadToMakeEmVerTrueIds){
            if(leadMap.containsKey(leadId)&& leadMap.get(leadId).Email_verified__c==false){
                Lead ldTempObj=leadMap.get(leadId);
                ldTempObj.Email_verified__c=true;
                leadToUpdate.put(ldTempObj.Id, ldTempObj);
            }
        }
        if(!conToMakeEmVerTrueIds.isEmpty()){
            queryContact(conToMakeEmVerTrueIds);
        }
        for(Id conId:conToMakeEmVerTrueIds){
            if(conMap.containsKey(conId)&& conMap.get(conId).Email_verified__c==false){
                Contact conTempObj=conMap.get(conId);
                conTempObj.Email_verified__c=true;
                conToUpdate.put(conTempObj.Id, conTempObj);
            }
        }
    }
    public static void searchETs(Map<String,List<Lead>> emailIdLeadListMap){
        etMap=new Map<Id,Engagement_Tracker__c>([Select Id,Email_Verified__c,Lead__c,Contact__c,Email__c from Engagement_Tracker__c where Email__c in:emailIdLeadListMap.keySet() and Lead__c=null and contact__c=null]);
        if(etMap==null || etMap.IsEmpty()){
            return;
        }
        for(Engagement_Tracker__c etTempObj:etMap.values()){
            List<Lead> ldTemlList=emailIdLeadListMap.get(etTempObj.Email__c);
            for(Lead ldObj:ldTemlList){
                ldObj.Email_Verified__c=(etTempObj.Email_Verified__c?etTempObj.Email_Verified__c:ldObj.Email_Verified__c);
            }
        }

    }
    public static void searchConRelETs(Map<String,List<Contact>> emailIdConListMap){
        etConMap=new Map<Id,Engagement_Tracker__c>([Select Id,Email_Verified__c,Lead__c,Contact__c,Email__c from Engagement_Tracker__c where Email__c in:emailIdConListMap.keySet() and contact__c=null]);
        if(etConMap==null || etConMap.IsEmpty()){
            return;
        }
        for(Engagement_Tracker__c etTempObj:etConMap.values()){
            List<Contact> conTemlList=emailIdConListMap.get(etTempObj.Email__c);
            for(Contact conObj:conTemlList){
                conObj.Email_Verified__c=(etTempObj.Email_Verified__c?etTempObj.Email_Verified__c:conObj.Email_Verified__c);
            }
        }

    }
    public static void updateEtOnLeadConvert(Map<Id,Lead>convertingLeadsMap){
        Map<Id,Engagement_Tracker__c> etTempMap=new Map<Id,Engagement_Tracker__c>([Select Id,Email_Verified__c,Lead__c,Contact__c from Engagement_Tracker__c where Lead__c in:convertingLeadsMap.keySet()]);
        if(etTempMap==null || etTempMap.IsEmpty()){
            return;
        }
        for(Engagement_Tracker__c etTempObj:etTempMap.values()){
            etTempObj.contact__c=convertingLeadsMap.get(etTempObj.Lead__c).convertedcontactId;
        }
        List<Database.SaveResult> etSaveLst=Database.update(etTempMap.values(), false);
    }
    public static void updateETs(Map<String,List<Lead>> emailIdLeadListMap){
        for(Engagement_Tracker__c etTempObj:etMap.values()){
            etTempObj.Lead__c=emailIdLeadListMap.get(etTempObj.Email__c).get(0).Id;
        }
        List<Database.SaveResult> saveEtResult=Database.update(etMap.values());
    }
    public static void updateConETs(Map<String,List<Contact>> emailIdConListMap){
        for(Engagement_Tracker__c etTempObj:etConMap.values()){
            etTempObj.contact__c=emailIdConListMap.get(etTempObj.Email__c).get(0).Id;
        }
        List<Database.SaveResult> saveEtResult=Database.update(etConMap.values());
    }
    public static void searchLeadAndContact(List<Engagement_Tracker__c> engageTrackList){
        Set<String> emailSet=new Set<String>();
        Set<String> customerCodeSet=new Set<String>();
        for(Engagement_Tracker__c etObj:engageTrackList){
            emailSet.add(etObj.Email__c);
            customerCodeSet.add(etObj.Customer_Code__c);
        }
        Map<String,Contact> mailConMap=new Map<String,Contact>();
        conMap=new Map<Id,Contact>([Select Id,Email,Email_Verified__c,IndividualId,FirstName,LastName,Name from Contact where Email in:emailSet or SCV_Code__c in:customerCodeSet order by createddate desc]);
        for(Contact conObj:conMap.values()){
            mailConMap.put(conObj.Email, conObj);
        }
        emailSet.clear();
        for(Engagement_Tracker__c etObj:engageTrackList){
            if(mailConMap.containsKey(etObj.Email__c)){
                etObj.contact__c=mailConMap.get(etObj.Email__c).Id;
                etObj.Email_Verified__c=(mailConMap.get(etObj.Email__c).Email_Verified__c==true 
                                        && etObj.RecordTypeId==rtMapByName.get('Form Submission').getRecordTypeId()?
                                        true:etObj.Email_Verified__c);
                continue;
            }
            emailSet.add(etObj.Email__c);
        }
        if(emailSet.isEmpty()){return;}
        leadMap=new Map<Id, Lead>  ([Select Id,Email,Email_Verified__c,IndividualId from Lead where Email in:emailSet order by createddate desc]);
        Map<String,Lead> mailLdMap=new Map<String,Lead>();
        for(Lead ldObj:leadMap.values()){
            mailLdMap.put(ldObj.Email, ldObj);
        }
        for(Engagement_Tracker__c etObj:engageTrackList){
            if(mailLdMap.containsKey(etObj.Email__c) && etObj.contact__c==null){
                etObj.lead__c=mailLdMap.get(etObj.Email__c).Id;
                etObj.Email_Verified__c=(mailLdMap.get(etObj.Email__c).Email_Verified__c==true 
                                        && etObj.RecordTypeId==rtMapByName.get('Form Submission').getRecordTypeId()?
                                        true:etObj.Email_Verified__c);
            }
        }

    }
    public static Map<String,Map<String,String>> sfmcMetadataMap=new  Map<String,Map<String,String>>();
    Public static Map<String,String> fetchSFMCKeyValueMap(String mappingType){
        if(sfmcMetadataMap.containsKey(mappingType)){
            return sfmcMetadataMap.get(mappingType);
        }
        Map<String, SFMC_Key_Value__mdt> sfmcKeyValMap = SFMC_Key_Value__mdt.getAll();        
        for(SFMC_Key_Value__mdt thisData: sfmcKeyValMap.Values()){
            if(!sfmcMetadataMap.containsKey(thisData.Mapping_Type__c)){
                sfmcMetadataMap.put(thisData.Mapping_Type__c, new Map<String,String>());
            }
            sfmcMetadataMap.get(thisData.Mapping_Type__c).put(thisData.Key__c.toLowerCase(),thisData.Value__c);
        }
        return sfmcMetadataMap.get(mappingType);
    }
    
    Public static Map<String,Id> countryNameIdMap=new Map<String,Id>();
    public static Id getCountryId(String countryName){
        if(countryNameIdMap.isEmpty()){
            List<Geography__c> geoList=[select id,name from Geography__c where Type_Of_Location__c ='Country'];
            for(Geography__c countryObj:geoList){
                countryNameIdMap.put(countryObj.name.toLowerCase(), countryObj.Id);
            }
        }
        return countryNameIdMap.get(countryName.toLowerCase());
    }
    public static Map<String,Map<String,String>> ptEvtMetadataMap=new  Map<String,Map<String,String>>();
    public static Map<String,String> getPtEvtMetadata(string topicName){
        if(ptEvtMetadataMap.containsKey(topicName)){
            return ptEvtMetadataMap.get(topicName);
        }
        Map<String, EMP_Consumer_settings__mdt> mapConsumerData = EMP_Consumer_settings__mdt.getAll();        
        for(EMP_Consumer_settings__mdt peMetaObj:mapConsumerData.values()){
            if(!ptEvtMetadataMap.containsKey(peMetaObj.Topic_Type__c)){
                ptEvtMetadataMap.put(peMetaObj.Topic_Type__c, new Map<String,String>());
            }
            ptEvtMetadataMap.get(peMetaObj.Topic_Type__c).put(peMetaObj.Json_Key__c.toLowerCase(),peMetaObj.Field_Value__c);
        }
        return ptEvtMetadataMap.get(topicName);
    }
    Public static void changeLeadConsent(Map<Id,Engagement_Tracker__c> leadIdETMap){
        queryLead(leadIdETMap.keyset());
        List<Lead> leadUpdateforConsent=new List<Lead>();
        TriggerExecutionController.skipAllTriggers(true);
        for (Id leadId : leadIdETMap.keySet()) {
            Engagement_Tracker__c etTempObj=leadIdETMap.get(leadId);
            Lead leadObj=leadMap.get(leadId);
            leadObj.Marketing_Opt_In__c =true;
            leadObj.LeadSource=etTempObj.Lead_Source__c;
            leadObj.Capture_Source__c=etTempObj.Capture_Source__c;
            leadUpdateforConsent.add(leadObj);
        }
        List<Database.SaveResult> ldSaveResult= Database.update(leadUpdateforConsent,false);
        system.debug(ldSaveResult.get(0));
        ConsentMgmtUtility.populateIndividualIdLead(leadIdETMap.keyset());
        TriggerExecutionController.skipAllTriggers(false);

    }
    Public static void changeContactConsent(Map<Id,Engagement_Tracker__c> conIdETMap){
        queryContact(conIdETMap.keySet());
        Map<Id,Contact> conWithoutIndividualMap=new  Map<Id,Contact>(); 
        Map<Id,Contact> conWithIndividualMap=new  Map<Id,Contact>(); 
        Map<Id,Id> individualIdConIdMap=new Map<Id,Id>();
        for(Id conId:conIdETMap.keySet()){
            Contact con=conMap.get(conId);
            if(con.IndividualId==null){
                conWithoutIndividualMap.put(con.Id,con);
            }else{
                conWithIndividualMap.put(con.Id,con);
                individualIdConIdMap.put(con.IndividualId,con.Id);
            }
        }
        processConWithIndId(conWithIndividualMap,individualIdConIdMap,conIdETMap);
        processConWithoutIndId(conWithoutIndividualMap,conIdETMap);
        
    }
    public static void processConWithIndId(Map<Id,Contact> conWithIndividualMap,
                                        Map<Id,Id> individualIdConIdMap,
                                        Map<Id,Engagement_Tracker__c> conIdETMap)
    {
        if(conWithIndividualMap.isEmpty()){return;}
        List<ContactPointTypeConsent> cptcList=[select Id,PartyId,CaptureDate,CaptureSource,PrivacyConsentStatus from 
                                                            ContactPointTypeConsent 
                                                            where PartyId=:individualIdConIdMap.keyset() and 
                                                            DataUsePurposeId=:SoftRegistrationUtility.getDataUsePurpose('Marketing')
                                                            and BusinessBrandId=:SoftRegistrationUtility.getBusinessBrands(BrandUtilities.Maersk)];
        Map<Id,Individual> conIdIndividualMap=new  Map<Id,Individual> ();
        Set<Id> individualWithCPCTSet=new  Set<Id> ();
        for(ContactPointTypeConsent cpctObj:cptcList){
            Id contactId=individualIdConIdMap.get(cpctObj.PartyId);
            individualWithCPCTSet.add(cpctObj.PartyId);
            cpctObj.PrivacyConsentStatus='OptIn';
            cpctObj.CaptureSource=conIdETMap.get(contactId).Capture_Source__c;
            cpctObj.CaptureDate=conIdETMap.get(contactId).createddate;
        }
        for(Contact con:conWithIndividualMap.values()){
            if(!individualWithCPCTSet.contains(con.IndividualId)){
                Individual idObj=new Individual(id=con.IndividualId);
                conIdIndividualMap.put(con.Id,idObj);
            }
        }
        if(!conIdIndividualMap.isEmpty()){
            createCPTC(conIdIndividualMap,conWithIndividualMap,conIdETMap);
        }
        Map<id,ContactPointEmail> cpeMap=new Map<id,ContactPointEmail>([select Id,ParentId,EmailAddress from 
                                                    ContactPointEmail 
                                                    where ParentId=:individualIdConIdMap.keyset()]);
        Map<Id,ContactPointEmail> individualWithCPEMap=new  Map<Id,ContactPointEmail> ();
        Map<Id,ContactPointEmail> cpeToUpdate=new Map<Id,ContactPointEmail>();
        for(ContactPointEmail cpeObj:cpeMap.values()){
            Id contactId=individualIdConIdMap.get(cpeObj.ParentId);
            Contact conTempObj=conWithIndividualMap.get(contactId);
            individualWithCPEMap.put(cpeObj.ParentId,cpeObj);
            if(cpeObj.EmailAddress!=null && !cpeObj.EmailAddress.equalsIgnoreCase(conTempObj.Email)){
                cpeObj.EmailAddress=conTempObj.Email;
                cpeToUpdate.put(cpeObj.Id,cpeObj);
            }
        }
        conIdIndividualMap.clear();
        for(Contact con:conWithIndividualMap.values()){
            if(!individualWithCPEMap.containsKey(con.IndividualId)){
                Individual idObj=new Individual(id=con.IndividualId);
                conIdIndividualMap.put(con.Id,idObj);
            }
        }
        if(!conIdIndividualMap.isEmpty()){
            Map<Id,ContactPointEmail> conPointEmailMap=createCPE(conIdIndividualMap,conWithIndividualMap);
            SoftRegistrationUtility.createCSC(conPointEmailMap,conWithIndividualMap,conIdETMap);
        }
        List<CommSubscriptionConsent> cSCList=[Select id,ContactPointId,consentCapturedSource,ConsentCapturedDateTime,Privacy_Consent_Status__c,CommSubscriptionChannelTypeId from CommSubscriptionConsent where ContactPointId=:cpeMap.keySet() and(
                                                    CommSubscriptionChannelTypeId=:getCommSubscriptionChannelType('Regional market updates Email') Or
                                                    CommSubscriptionChannelTypeId=:getCommSubscriptionChannelType('New solutions, products and services Email')
                                                    )];
        Map<Id,Map<Id,CommSubscriptionConsent>> cpeIdCscMap=new Map<Id,Map<Id,CommSubscriptionConsent>> (); 
        for (CommSubscriptionConsent cseTempObj : cSCList) {
            if(!cpeIdCscMap.containsKey(cseTempObj.ContactPointId)){
                cpeIdCscMap.put(cseTempObj.ContactPointId,new Map<Id,CommSubscriptionConsent>());
            }
            cpeIdCscMap.get(cseTempObj.ContactPointId).put(cseTempObj.CommSubscriptionChannelTypeId,cseTempObj);
        }
        Map<Id,CommSubscriptionConsent> cscToUpdateMap=new Map<Id,CommSubscriptionConsent> ();
        List<CommSubscriptionConsent> cscToUpsert=new List<CommSubscriptionConsent>();
        Map<Id,ContactPointEmail> conPointEmailMap=new Map<Id,ContactPointEmail> ();
        for(Id individualId:individualWithCPEMap.keyset())
        {
            Id cpeId=individualWithCPEMap.get(individualId).Id;
            Id contactId=individualIdConIdMap.get(individualId);
            Contact conTempObj=conWithIndividualMap.get(contactId);
            conPointEmailMap.put(contactId,individualWithCPEMap.get(individualId));
            if(!cpeIdCscMap.containsKey(cpeId)){
                //no CSC exists here
            }
            Map<Id,CommSubscriptionConsent> channaltypeIdCSCMap=cpeIdCscMap.get(cpeId);
            if(channaltypeIdCSCMap.containsKey(getCommSubscriptionChannelType('Regional market updates Email'))){
                CommSubscriptionConsent cscTempObj=channaltypeIdCSCMap.get(getCommSubscriptionChannelType('Regional market updates Email'));
                cscTempObj.consentCapturedSource =conIdETMap.get(contactId).Capture_Source__c;
                cscTempObj.ConsentCapturedDateTime=conIdETMap.get(contactId).createddate;
                cscTempObj.Privacy_Consent_Status__c = 'OptIn';
                //update regional market update Email CSC
                cscToUpdateMap.put(cscTempObj.Id,cscTempObj);
            }else{
                CommSubscriptionConsent cscRegionMerUpdObj=setCSCDefaultFields(conPointEmailMap,conTempObj,conIdETMap);
                cscRegionMerUpdObj.Name = conTempObj.Email + '-Regional market updates';
                cscRegionMerUpdObj.CommSubscriptionChannelTypeId=getCommSubscriptionChannelType('Regional market updates Email');
                cscToUpsert.add(cscRegionMerUpdObj);
                //create a regional market update Email CSC;
            }
            if(channaltypeIdCSCMap.containsKey(getCommSubscriptionChannelType('New solutions, products and services Email'))){
                //update a New solutions, products and services Email
                CommSubscriptionConsent cscTempObj=channaltypeIdCSCMap.get(getCommSubscriptionChannelType('New solutions, products and services Email'));
                cscTempObj.consentCapturedSource =conIdETMap.get(contactId).Capture_Source__c;
                cscTempObj.ConsentCapturedDateTime=conIdETMap.get(contactId).createddate;
                cscTempObj.Privacy_Consent_Status__c = 'OptIn';
                //update regional market update Email CSC
                cscToUpdateMap.put(cscTempObj.Id,cscTempObj);
            }else{
                CommSubscriptionConsent cscNewProSolSerObj=setCSCDefaultFields(conPointEmailMap,conTempObj,conIdETMap);
                cscNewProSolSerObj.Name = conTempObj.Email + '-New solutions, products and services';
                cscNewProSolSerObj.CommSubscriptionChannelTypeId=getCommSubscriptionChannelType('New solutions, products and services Email');
                cscToUpsert.add(cscNewProSolSerObj);
                //create a New solutions, products and services Email;
            }
        }
        //CPE ro update
        If(!cpeToUpdate.isEmpty()){
            List<Database.SaveResult> lstIndividualSaveResult = Database.Update(cpeToUpdate.Values(), false);
        }
        //Update CPTC
        if(cptcList!=null &&!cptcList.isEmpty()){
            Update cptcList;
        }
        //Upsert the CSC records
        if(!cscToUpdateMap.isEmpty() || !cscToUpsert.isEmpty()){
            cscToUpsert.addAll(cscToUpdateMap.values());
            List<Database.UpsertResult> lstIndividualSaveResult = Database.Upsert(cscToUpsert, false);
        }
    }
    public static void processConWithoutIndId(Map<Id,Contact> conWithoutIndividualMap,
                                        Map<Id,Engagement_Tracker__c> conIdETMap)
    {
        if(conWithoutIndividualMap.isEmpty()){return;}
        Map<Id,Individual> conIdIndividualMap=createIndividual(conWithoutIndividualMap.values());
        for (Id conId : conIdIndividualMap.keySet()) {
            Contact conTempObj=conWithoutIndividualMap.get(conId);
            Individual idvidObj= conIdIndividualMap.get(conId);
            conTempObj.IndividualId=idvidObj.Id;
            conToUpdate.put(conTempObj.Id,conTempObj);
        }
        createCPTC(conIdIndividualMap,conWithoutIndividualMap,conIdETMap);
        Map<Id,ContactPointEmail> conPointEmailMap=createCPE(conIdIndividualMap,conWithoutIndividualMap);
        SoftRegistrationUtility.createCSC(conPointEmailMap,conWithoutIndividualMap,conIdETMap);
    }
    /*method to create individual id for the contact*/
    public static Map<Id,Individual> createIndividual(List<Contact> conList){
        Map<Id,Individual> conIdIndividualMap=new Map<Id,Individual>();
        for (Contact conObj : conList){
            Individual recInd = new Individual();
            recInd.FirstName = conObj.FirstName;
            recInd.LastName = conObj.LastName;
            conIdIndividualMap.put(conObj.Id,recInd);
        }
        List<Database.SaveResult> lstIndividualSaveResult = Database.Insert(conIdIndividualMap.values(), false);
        return conIdIndividualMap;
    }
    public static void createCPTC(Map<Id,Individual> conIdIndividualMap,Map<Id,Contact> contactMap,Map<Id,Engagement_Tracker__c> conIdETMap){
        Map<Id,ContactPointTypeConsent> conIdCPTCMap=new Map<Id,ContactPointTypeConsent>();
        for(Contact conObj:contactMap.values()){
            ContactPointTypeConsent cptcObj = new ContactPointTypeConsent();
            cptcObj.Name = conObj.Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-'+ conObj.Email;
            cptcObj.CaptureContactPointType = 'Web';
            cptcObj.CaptureSource =conIdETMap.get(conObj.Id).Capture_Source__c;
            cptcObj.ContactPointType = 'Email';
            cptcObj.DataUsePurposeId=SoftRegistrationUtility.getDataUsePurpose('Marketing');
            cptcObj.PartyId = conIdIndividualMap.get(conObj.Id).Id;
            cptcObj.PrivacyConsentStatus='OptIn';
            cptcObj.BusinessBrandId= SoftRegistrationUtility.getBusinessBrands(BrandUtilities.Maersk);
            cptcObj.CaptureDate=conIdETMap.get(conObj.Id).createddate;
            conIdCPTCMap.put(conObj.Id,cptcObj);
            
        }
        List<Database.SaveResult> lstSaveResult = Database.Insert(conIdCPTCMap.values(), false);

    }
    Public static Map<Id,ContactPointEmail> createCPE(Map<Id,Individual> conIdIndividualMap,Map<Id,Contact> contactMap){
        Map<Id,ContactPointEmail> conPointEmailMap=new Map<Id,ContactPointEmail> ();
        for(Contact conObj:contactMap.values()){
            // Create new ContactPointEmail
            ContactPointEmail contactPointEmailObj = new ContactPointEmail();
            contactPointEmailObj.EmailAddress = conObj.Email;  
            contactPointEmailObj.ParentId = conIdIndividualMap.get(conObj.Id).Id; 
            conPointEmailMap.put(conObj.Id,contactPointEmailObj);
        }
        List<Database.SaveResult> lstSaveResult = Database.Insert(conPointEmailMap.values(), false);
        return conPointEmailMap;
    }
    Public static Map<Id,List<CommSubscriptionConsent>>  createCSC(Map<Id,ContactPointEmail> conPointEmailMap,Map<Id,Contact> contactMap,Map<Id,Engagement_Tracker__c> conIdETMap){
        Map<Id,List<CommSubscriptionConsent>> cscMap=New Map<Id,List<CommSubscriptionConsent>>();
        List<CommSubscriptionConsent> cscToInsert=new List<CommSubscriptionConsent>();
        for(Contact conObj:contactMap.values()){
            List<CommSubscriptionConsent> cscList=New List<CommSubscriptionConsent>();
            CommSubscriptionConsent cscRegionMerUpdObj=setCSCDefaultFields(conPointEmailMap,conObj,conIdETMap);
            cscRegionMerUpdObj.Name = conObj.Email + '-Regional market updates';
            cscRegionMerUpdObj.CommSubscriptionChannelTypeId=getCommSubscriptionChannelType('Regional market updates Email');
            cscList.add(cscRegionMerUpdObj);
            CommSubscriptionConsent cscNewProSolSerObj=setCSCDefaultFields(conPointEmailMap,conObj,conIdETMap);
            cscNewProSolSerObj.Name = conObj.Email + '-New solutions, products and services';
            cscNewProSolSerObj.CommSubscriptionChannelTypeId=getCommSubscriptionChannelType('New solutions, products and services Email');
            cscList.add(cscNewProSolSerObj);
            cscToInsert.addAll(cscList);
            cscMap.put(conObj.Id,cscList);
        }
        List<Database.SaveResult> lstSaveResult = Database.Insert(cscToInsert, false);
        return cscMap;
    }
    public static CommSubscriptionConsent setCSCDefaultFields(Map<Id,ContactPointEmail> conPointEmailMap,Contact conObj,Map<Id,Engagement_Tracker__c> conIdETMap){
        CommSubscriptionConsent cscObj=new CommSubscriptionConsent();
        cscObj.ConsentCapturedDateTime=conIdETMap.get(conObj.Id).createddate;
        cscObj.EffectiveFromDate=conIdETMap.get(conObj.Id).createddate.date();
        cscObj.consentCapturedSource =conIdETMap.get(conObj.Id).Capture_Source__c;
        cscObj.BusinessBrandId =getBusinessBrands(BrandUtilities.Maersk);
        cscObj.Privacy_Consent_Status__c = 'OptIn';
        cscObj.ContactPointId =conPointEmailMap.get(conObj.Id).Id;
        return cscObj;
    }
    // Get CommSubscriptionChannelType details
    public static Map<String, Id> mapNameToCSCTId = new Map<String, Id>();
    public static Id getCommSubscriptionChannelType(String name){
        if (mapNameToCSCTId.isEmpty() ){
            List<CommSubscriptionChannelType> lstCSCT = [SELECT Id, Name FROM CommSubscriptionChannelType];
            
            for (CommSubscriptionChannelType rCSCT : lstCSCT){
                mapNameToCSCTId.put(rCSCT.Name, rCSCT.Id);
            }
        }
        return mapNameToCSCTId.get(name);
    }
    public static Map<String, Id> mapNameToDUPId=new Map<String, Id>();
    public static Id getDataUsePurpose(String name){
        if (mapNameToDUPId.isEmpty() ){
            List<DataUsePurpose> lstDUP = [SELECT Id, Name FROM DataUsePurpose];
            
            for (DataUsePurpose rDUP : lstDUP){
                mapNameToDUPId.put(rDUP.Name, rDUP.Id);
            }
        }
        return mapNameToDUPId.get(name);
    }
    public static Map<String, Id> mapNameToBusBrandId = new Map<String, Id>();
    public static Id getBusinessBrands(String name){
        if (mapNameToBusBrandId.isEmpty()){            
            for (BusinessBrand busBrand : [SELECT Id, Name FROM BusinessBrand]){
                mapNameToBusBrandId.put(busBrand.Name, busBrand.Id);
            }
        }
        return mapNameToBusBrandId.get(name);
    }   
}