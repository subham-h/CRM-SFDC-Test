/*              
* Revision Ref Number  Date        Owner					Description
* -------- ----------  ----------- -----------------		-----------
* 1.0      	SFSE-5757	26-May-2021		nitin@maersk		Code created
* 1.1      	SFSE-5757	07-Jun-2021		nitin@maersk		defect fix where CPTC was updated when Marketing opt in set to false
* 1.2      	SFSE-6116	01-July-2021	Neha@TCS			fix the exception and use Database class instead of simple insert/update
* 1.3      	SFSE-6982	13-Sept-2021	Sidahrtha@maersk	assign lead created date instead of system.now in CaptureDate of CPTC
* 2.0		SFSE-9375	22-Sep-2022		Kiran@Maersk		Contact Point Type Consent (CPTC) record Name format change
* 2.1       SFSE-9592   24-Nov-2022     Shilpa@maersk       Update Capture Date as Lead Created Date 
* 2.2       SFMC-7403   17-Jul-2023     amrutha@maersk		Fix Consent Record updates, to respect Datausepurpose as Marketing only
* 2.3       SFMC-7463   25-Sept-2023    amrutha@maersk.com  Create Lead records with a Source Brand value of ‘MaerskGo’
* 2.4       SFMC-7484   25-Oct-2023     amrutha@maersk.com  Create/Update CPE and CSC records when CPTC ic newly created or CPTC is existing
* 2.5       SFMC-7518   26-Dec-2023     amrutha@maersk.com  Fix Duplicate CPE and CSC records
* 2.6       SFMC-7535   05-Jan-2024     amrutha@maersk.com  Fix Duplicate CPE for DUP as CA
* 2.7       SFMC-7359   10-Jan-2024     amrutha@maersk.com  Fix Existing Capture Source value from getting nullified when contact alone is present
*/

public without sharing class ConsentMgmtUtility {
    
    public static void populateIndividualIdLead(Set<Id> setLeadIds){
        
        List<Lead> lstLeadInserted = new List<Lead>();
        Set<String> setEmail = new Set<String>();
        Set<Id> setLeadId = new Set<Id>();
        Map<String, ID> mapLeadEmailToIndividualId = new Map<String, ID>();
        Map<String, ID> mapContactEmailToIndividualId = new Map<String, ID>();
        List<Lead> lstLeadToUpdate = new List<Lead>();
        Set<String> setEmailToCheckOtherLead = new Set<String>();
        Map<String, Lead> mapNameToLead = new Map<String, Lead>();
        Map<String, ID> mapEmailToIndividualID = new Map<String, ID>();
        List<Lead> lstLeadforCPTC = new List<Lead>();
        Map<String, Id> mapNameToDataUsePurpose = getDataUsePurpose();
        // Map<String, Id> mapNameToContactPointEmail = getContactPointEmail();
        // Map<String, String> mapCSCIDToCommSubscriptionConsent = getCommSubscriptionConsent();
        Map<String, Id> mapNameToBusBrandId = getBusinessBrands();
        Map<String, Id> mapNameToCommSubscriptionChannelType = getCommSubscriptionChannelType();
        List<Lead> lstOtherLead = new List<Lead>();
        Map<Id, Lead> mapIndividualIdToLead = new Map<Id, Lead>();
        Map<Id, String> mapIndIDToLeadCaptureSource = new Map<Id, String>();
        List<Contact> lstOtherContact = new List<Contact>();
        Set<Id> setIdsEmpty = new Set<Id>();
        Map<id, Individual> mapIndividualIds = new Map<Id, Individual>();
        Id busBrandId;
        
        lstLeadInserted = getInsertedLeads(setLeadIds);
        for (Lead rLead1 : lstLeadInserted){
            setEmail.add(rLead1.Email);
            setLeadId.add(rLead1.Id);
        }
        
        //get existing Individual Id for Lead and Contact
        mapLeadEmailToIndividualId = getLeadEmailToIndividualID(setEmail);
        mapContactEmailToIndividualId = getContactEmailToIndividualID(setEmail);
        mapIndividualIds = new Map<Id, Individual>([SELECT Id, Name FROM Individual where id in : mapLeadEmailToIndividualId.values() OR id in :mapContactEmailToIndividualId.values()]);
        
        for (Lead rLead2 : lstLeadInserted){
            
            Id idLeadIndId = mapLeadEmailToIndividualId.get(rLead2.Email);
            Id idContactIndId = mapContactEmailToIndividualId.get(rLead2.Email);
            
            if (idLeadIndId != null && rLead2.Marketing_Opt_In__c){
                setEmailToCheckOtherLead.add(rLead2.Email); 
                mapIndividualIdToLead.put(idLeadIndId, rLead2);
                mapIndIDToLeadCaptureSource.put(idLeadIndId, rLead2.Capture_Source__c);
                mapEmailToIndividualID.put(rLead2.Email, idLeadIndId);
                
                rLead2.IndividualId = idLeadIndId;
                
                lstLeadToUpdate.add(rLead2);
            } else if (idLeadIndId != null && ((!rLead2.Marketing_Opt_In__c || rLead2.Marketing_Opt_In__c == null)
                                               || (rLead2.Marketing_Opt_In__c && (rLead2.Source_Brand__c == null || rLead2.Capture_Source__c == null)))){
                                                   setEmailToCheckOtherLead.add(rLead2.Email); 
                                                   mapIndividualIdToLead.put(idLeadIndId, rLead2);
                                                   mapEmailToIndividualID.put(rLead2.Email, idLeadIndId);
                                                   
                                                   rLead2.IndividualId = idLeadIndId;
                                                   lstLeadToUpdate.add(rLead2);
                                               } else if (idLeadIndId == null && idContactIndId != null && rLead2.Marketing_Opt_In__c && rLead2.Source_Brand__c != null && rLead2.Capture_Source__c != null){
                                                   // Individual Id not found in lead and Marketing opt in is true then check individual Id in Contact and link
                                                   setEmailToCheckOtherLead.add(rLead2.Email); 
                                                   mapEmailToIndividualID.put(rLead2.Email, idContactIndId);
                                                   mapIndividualIdToLead.put(idContactIndId, rLead2);
                                                   rLead2.IndividualId = idContactIndId;
                                                   lstLeadToUpdate.add(rLead2);    
                                               }else if ((idLeadIndId == null && (!rLead2.Marketing_Opt_In__c || rLead2.Marketing_Opt_In__c == null)
                                                          || (rLead2.Marketing_Opt_In__c && (rLead2.Source_Brand__c == null || rLead2.Capture_Source__c == null)))
                                                         || idContactIndId != null){
                                                             // Individual Id not found in lead and Marketing opt in is false then check individual Id in Contact and link
                                                             setEmailToCheckOtherLead.add(rLead2.Email); 
                                                             mapEmailToIndividualID.put(rLead2.Email, idContactIndId);
                                                             
                                                             rLead2.IndividualId = idContactIndId;
                                                             lstLeadToUpdate.add(rLead2);    
                                                         }else if (rLead2.Marketing_Opt_In__c && rLead2.Source_Brand__c != null && rLead2.Capture_Source__c != null){
                                                             
                                                             String strName = rLead2.FirstName + ' ' + rLead2.LastName;
                                                             mapNameToLead.put(strName, rLead2);
                                                         }
        }
        
        
        // Create Individual, CPTC, CPE & CSC record for new Lead consents
        List<Individual> lstIndividualToInsert = new List<Individual>();
        List<ContactPointTypeConsent> lstCPTCtoInsert = new List<ContactPointTypeConsent>();
        List<ContactPointTypeConsent> lstCPTCToUpdate = new List<ContactPointTypeConsent>();
        List <ContactPointEmail> lstContactPointEmailToInsert = new List<ContactPointEmail>();
        List<CommSubscriptionConsent> lstCommSubscriptionConsentToInsert = new List<CommSubscriptionConsent>();
        List<CommSubscriptionConsent> lstCommSubscriptionConsentToUpdate = new List<CommSubscriptionConsent>();
        
        
        // Update CPTC & CPE with new consent details
        
        List<ContactPointTypeConsent> lstCPTCExisting = getContactPointTypeConsent(mapIndividualIdToLead.keyset());
        List<ContactPointEmail> lstCPEExisting = getContactPointEmail(mapIndividualIdToLead.keyset());        
        
        Set<Id> setIndIDCPTCNotFound = new Set<Id>();
        Set<Id> setCSCId = new Set<Id>();
        Set<Id> setCSCId1 = new Set<Id>();
        Set<Id> setCPEId = new Set<Id>();
        if (lstCPTCExisting.size() > 0){
            String cpeID = null; 
            
            for (ContactPointTypeConsent rCptc1 : lstCPTCExisting) 
                
            { 
                Lead rLeadToCheckBrand = mapIndividualIdToLead.get(rCptc1.PartyId);
                if (rCptc1.DataUsePurpose.Name == 'Marketing' && rCptc1.PartyId != null && rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.BusinessBrand.Name == 'Maersk') 
                { 
                    String leadEmailAddress = rLeadToCheckBrand.Email;
                    boolean isCPEExists = false;
                    for (ContactPointEmail rCpe1 : lstCPEExisting){
                        if (rCpe1.ParentId == rCptc1.PartyId){
                            cpeId = rCpe1.Id;
                            setCPEId.add(cpeId);
                            isCPEExists = true;
                            break;
                        }
                    }
                }
            }
            
            String strCSCTName = 'Regional market updates Email';
            String strCSCTId = mapNameToCommSubscriptionChannelType.get(strCSCTName);
            setCSCId.add(strCSCTId);
            List<CommSubscriptionConsent> existingCSCs = getCommSubscriptionConsent(setCPEId, setCSCId);
            boolean isCSCExists = false; 
            String strCSCTName1 = 'New solutions, products and services Email';
            String strCSCTId1 = mapNameToCommSubscriptionChannelType.get(strCSCTName1);
            setCSCId1.add(strCSCTId1);
            List<CommSubscriptionConsent> existingCSCs1 = getCommSubscriptionConsent(setCPEId, setCSCId1);
            boolean isCSCExists1 = false; 
            
            for (ContactPointTypeConsent rCptc1 : lstCPTCExisting) 
                
            { 
                Lead rLeadToCheckBrand = mapIndividualIdToLead.get(rCptc1.PartyId);

                if (rCptc1.DataUsePurpose.Name == 'Marketing' && rCptc1.PartyId != null && rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.BusinessBrand.Name == 'Maersk') 

                { 
                    String leadEmailAddress = rLeadToCheckBrand.Email;
                    for (CommSubscriptionConsent existingCSC : existingCSCs) 
                    { 
                        if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC.Privacy_Consent_Status__c == 'OptOut') 
                        { 
                            existingCSC.Privacy_Consent_Status__c = 'OptIn';
                            existingCSC.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                            lstCommSubscriptionConsentToUpdate.add(existingCSC);
                            isCSCExists = true; 
                            break; 
                        } 
                        if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC.Privacy_Consent_Status__c == 'OptIn') 
                        { 
                            isCSCExists = true; 
                            break; 
                        } 
                    } 
                    if (!isCSCExists) {        
                        
                        
                        CommSubscriptionConsent rCommSubscriptionConsent = new CommSubscriptionConsent();
                        rCommSubscriptionConsent.Name = leadEmailAddress + '-Regional market updates';
                        if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime = rLeadToCheckBrand.Lead_Submission_Date__c	;  
                        }else {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime =  rLeadToCheckBrand.CreatedDate;
                        }
                        rCommSubscriptionConsent.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                        if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
                        }else {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.CreatedDate.format('yyyy-MM-dd')); 
                        }   
                        rCommSubscriptionConsent.BusinessBrandId = rCptc1.BusinessBrandId;
                        rCommSubscriptionConsent.Privacy_Consent_Status__c = 'OptIn';
                        rCommSubscriptionConsent.ContactPointId = cpeID;
                        rCommSubscriptionConsent.CommSubscriptionChannelTypeId = strCSCTId;
                        lstCommSubscriptionConsentToInsert.add(rCommSubscriptionConsent);
                    } 
     
                    for (CommSubscriptionConsent existingCSC1 : existingCSCs1) 
                    { 
                        if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC1.Privacy_Consent_Status__c == 'OptOut') 
                        { 
                            existingCSC1.Privacy_Consent_Status__c = 'OptIn';
                            existingCSC1.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                            lstCommSubscriptionConsentToUpdate.add(existingCSC1);
                            isCSCExists1 = true; 
                            break; 
                        } 
                        if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC1.Privacy_Consent_Status__c == 'OptIn') 
                        { 
                            isCSCExists1 = true; 
                            break; 
                        } 
                    } 
                    if (!isCSCExists1) {        
       
                        CommSubscriptionConsent rCommSubscriptionConsent = new CommSubscriptionConsent();
                        rCommSubscriptionConsent.Name = leadEmailAddress + '-New solutions, products and services';
                        if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime = rLeadToCheckBrand.Lead_Submission_Date__c;  
                        }else {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime =  rLeadToCheckBrand.CreatedDate;
                        }
                        rCommSubscriptionConsent.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                        if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
                        }else {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.CreatedDate.format('yyyy-MM-dd')); 
                        }   
                        rCommSubscriptionConsent.BusinessBrandId = rCptc1.BusinessBrandId;
                        rCommSubscriptionConsent.Privacy_Consent_Status__c = 'OptIn';
                        rCommSubscriptionConsent.ContactPointId = cpeID;
                        rCommSubscriptionConsent.CommSubscriptionChannelTypeId = strCSCTId1;
                        lstCommSubscriptionConsentToInsert.add(rCommSubscriptionConsent);
                    }   
                    
                }
                
                
                // create new ContactPointEmail if it dosent exists
                if (cpeId == null && rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.BusinessBrand.Name == 'Maersk' && rCptc1.DataUsePurpose.Name == 'Marketing')
                {
                    ContactPointEmail sContactPointEmail = new ContactPointEmail(); 
                    sContactPointEmail.EmailAddress = rLeadToCheckBrand.Email; 
                    sContactPointEmail.ParentId = rCptc1.PartyId; 
                    lstContactPointEmailToInsert.add(sContactPointEmail);    
                }
                
            }
            
            
            // Insert new ContactPointEmail records if not already present
            if (lstContactPointEmailToInsert.size() > 0){            
                List<Database.SaveResult> lstCPESaveResult = Database.Insert(lstContactPointEmailToInsert, false);
                ErrorLogger.writeErrors('SFDC', 'ContactPointTypeConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCPESaveResult, lstContactPointEmailToInsert);
            }
            
            for (ContactPointTypeConsent rCptc1 : lstCPTCExisting) 
                
            { 
                Lead rLeadToCheckBrand = mapIndividualIdToLead.get(rCptc1.PartyId);
                if (rCptc1.DataUsePurpose.Name == 'Marketing' && rCptc1.PartyId != null && rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.BusinessBrand.Name == 'Maersk') 
                {                    
                    String leadEmailAddress = rLeadToCheckBrand.Email;
                    ContactPointEmail rContactPointEmail = null;
                    for (ContactPointEmail cpe : lstContactPointEmailToInsert) {
                        if (cpe.ParentId == mapIndividualIds.get(rCptc1.PartyId).Id) {
                            rContactPointEmail = cpe;
                            cpeID = rContactPointEmail.Id;
                            break; // Exit the loop once the record is found
                        }
                    }
                    
                    if (rContactPointEmail != null) {
                        
                        for (CommSubscriptionConsent existingCSC : existingCSCs) 
                        { 
                            if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC.Privacy_Consent_Status__c == 'OptOut') 
                            { 
                                existingCSC.Privacy_Consent_Status__c = 'OptIn';
                                existingCSC.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                                lstCommSubscriptionConsentToUpdate.add(existingCSC);
                                isCSCExists = true; 
                                break; 
                            } 
                            if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC.Privacy_Consent_Status__c == 'OptIn') 
                            { 
                                isCSCExists = true; 
                                break; 
                            } 
                        }
                        
                        if (!isCSCExists){        
                            
                            CommSubscriptionConsent rCommSubscriptionConsent = new CommSubscriptionConsent();
                            rCommSubscriptionConsent.Name = leadEmailAddress + '-Regional market updates';
                            if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                                rCommSubscriptionConsent.ConsentCapturedDateTime = rLeadToCheckBrand.Lead_Submission_Date__c	;  
                            }else {	 
                                rCommSubscriptionConsent.ConsentCapturedDateTime =  rLeadToCheckBrand.CreatedDate;
                            }
                            rCommSubscriptionConsent.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                            if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                                rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
                            }else {	 
                                rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.CreatedDate.format('yyyy-MM-dd')); 
                            }   
                            rCommSubscriptionConsent.BusinessBrandId = rCptc1.BusinessBrandId;
                            rCommSubscriptionConsent.Privacy_Consent_Status__c = 'OptIn';
                            rCommSubscriptionConsent.ContactPointId = cpeID;
                            rCommSubscriptionConsent.CommSubscriptionChannelTypeId = strCSCTId;
                            lstCommSubscriptionConsentToInsert.add(rCommSubscriptionConsent);

                            boolean isCSCExists2 = false; 
                            
                            for (CommSubscriptionConsent existingCSC1 : existingCSCs1) 
                            { 
                                if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC1.Privacy_Consent_Status__c == 'OptOut') 
                                { 
                                    existingCSC1.Privacy_Consent_Status__c = 'OptIn';
                                    existingCSC1.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                                    lstCommSubscriptionConsentToUpdate.add(existingCSC1);
                                    isCSCExists2 = true; 
                                    break; 	
                                } 
                                if (rLeadToCheckBrand.Marketing_Opt_In__c && existingCSC1.Privacy_Consent_Status__c == 'OptIn') 
                                { 
                                    isCSCExists2 = true; 
                                    break; 
                                } 
                                
                            } 
                            if (!isCSCExists2){        

                                CommSubscriptionConsent sCommSubscriptionConsent = new CommSubscriptionConsent();
                                sCommSubscriptionConsent.Name = leadEmailAddress + '-New solutions, products and services';
                                if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                                    sCommSubscriptionConsent.ConsentCapturedDateTime = rLeadToCheckBrand.Lead_Submission_Date__c	;  
                                }else {	 
                                    sCommSubscriptionConsent.ConsentCapturedDateTime =  rLeadToCheckBrand.CreatedDate;
                                }
                                sCommSubscriptionConsent.ConsentCapturedSource = rLeadToCheckBrand.Capture_Source__c;
                                if(rLeadToCheckBrand.Lead_Submission_Date__c !=null) {	 
                                    sCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
                                }else {	 
                                    sCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLeadToCheckBrand.CreatedDate.format('yyyy-MM-dd')); 
                                }   
                                sCommSubscriptionConsent.BusinessBrandId = rCptc1.BusinessBrandId;
                                sCommSubscriptionConsent.Privacy_Consent_Status__c = 'OptIn';
                                sCommSubscriptionConsent.ContactPointId = cpeID;
                                sCommSubscriptionConsent.CommSubscriptionChannelTypeId = strCSCTId1;
                                lstCommSubscriptionConsentToInsert.add(sCommSubscriptionConsent);
                            }   
                            
                        } 
                    } 
                }
            }  
            
            // Update Communication Subscription Consent records if already present
            if (lstCommSubscriptionConsentToUpdate.size() > 0) {
                List<Database.SaveResult> lstCommSubscriptionConsentSaveResult1 = Database.update(lstCommSubscriptionConsentToUpdate, false);
                ErrorLogger.writeErrors('SFDC', 'CommSubscriptionConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCommSubscriptionConsentSaveResult1, lstCommSubscriptionConsentToUpdate);  
            }
            // Insert new Communication Subscription Consent records if not already present
            if (lstCommSubscriptionConsentToInsert.size() > 0) {
                List<Database.SaveResult> lstCommSubscriptionConsentSaveResult = Database.Insert(lstCommSubscriptionConsentToInsert, false);
                ErrorLogger.writeErrors('SFDC', 'CommSubscriptionConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCommSubscriptionConsentSaveResult, lstCommSubscriptionConsentToInsert);
            }   
            
            for (ContactPointTypeConsent rCptc1 : lstCPTCExisting){
                setIndIDCPTCNotFound.add(rCptc1.PartyId); // add into set
                Lead rLeadToCheckBrand = mapIndividualIdToLead.get(rCptc1.PartyId);
                String strLeadCaptureSource = rLeadToCheckBrand.Capture_source__c;
                // Modify the logic to set the correct source brand
                String strBrand;
                if (rLeadToCheckBrand.Source_Brand__c == 'Maersk Go') {
                    strBrand = BrandUtilities.Maersk;
                } else {
                    strBrand = rLeadToCheckBrand.Source_Brand__c;
                }
                
                
                if (rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.PartyId == (mapIndividualIds.get(rCptc1.PartyId).Id) && rCptc1.Name.contains(rLeadToCheckBrand.Email) && rCptc1.BusinessBrand.Name == strBrand
                    && rCptc1.DataUsePurpose.Name == 'Marketing'){
                        
                        setIndIDCPTCNotFound.remove(rCptc1.PartyId); // remove from set because CPTC found for brand
                        
                        rCptc1.CaptureSource = rCptc1.CaptureSource !=null ? rLeadToCheckBrand.CreatedDate > rCptc1.CaptureDate ? strLeadCaptureSource : rCptc1.CaptureSource : strLeadCaptureSource;
                        rCptc1.PrivacyConsentStatus = 'OptIn';
                        rCptc1.Opt_Out_Source__c = null;
                        rCptc1.DoubleConsentCaptureDate = rLeadToCheckBrand.Lead_Submission_Date__c > rCptc1.CaptureDate ? rLeadToCheckBrand.Double_Consent_Capture_Date__c : rCptc1.DoubleConsentCaptureDate;
                        // rCptc1.CaptureDate = rCptc1.CaptureDate !=null ? rLeadToCheckBrand.CreatedDate > rCptc1.CaptureDate : rLeadToCheckBrand.CreatedDate : rCptc1.CaptureDate;
                        if( rCptc1.CaptureDate !=null && rLeadToCheckBrand.CreatedDate >  rCptc1.CaptureDate){
                            rCptc1.CaptureDate = rLeadToCheckBrand.CreatedDate; 
                        }                    
                        lstCPTCToUpdate.add(rCptc1);
                        if (rLeadToCheckBrand.Marketing_Opt_In__c && rCptc1.PartyId == (mapIndividualIds.get(rCptc1.PartyId).Id) && rCptc1.Name.contains(rLeadToCheckBrand.Email) && rCptc1.BusinessBrand.Name == strBrand
                            && rLeadToCheckBrand.Lead_Submission_Date__c != null && rCptc1.DataUsePurpose.Name == 'Marketing'){
                                setIndIDCPTCNotFound.remove(rCptc1.PartyId);} // remove from set because CPTC found for brand
                        break;
                    }	
                
                
                
                if (!rLeadToCheckBrand.Marketing_Opt_In__c || rLeadToCheckBrand.Marketing_Opt_In__c == null){
                    setIndIDCPTCNotFound.remove(rCptc1.PartyId); // remove from set because marketing opt in is false for lead
                    break;
                }
            }
            
            
            if (lstCPTCToUpdate.size() > 0) {
                List<Database.SaveResult> lstCPTCSaveResult = Database.Update(lstCPTCToUpdate, false);
                ErrorLogger.writeErrors('SFDC', 'ContactPointTypeConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCPTCSaveResult, lstCPTCToUpdate);          
            }
        }
        
        
        // prepare CPTC for brand for existing Individual Id
        for (Id rIndId : setIndIDCPTCNotFound){
            Lead rLeadForPartyId = mapIndividualIdToLead.get(rIndId);
            ContactPointTypeConsent rCPTCBrand = new ContactPointTypeConsent();
            String strDUPNameBrand = 'Marketing';
            String strDUPIdBrand = mapNameToDataUsePurpose.get(strDUPNameBrand);
            if (rLeadForPartyId.Source_Brand__c == 'Maersk Go') {
                busBrandId = mapNameToBusBrandId.containsKey(BrandUtilities.Maersk) ? mapNameToBusBrandId.get(BrandUtilities.Maersk) : null;}
            else{busBrandId = mapNameToBusBrandId.containsKey(rLeadForPartyId.Source_Brand__c) ? mapNameToBusBrandId.get(rLeadForPartyId.Source_Brand__c) : null;}
            if (strDUPIdBrand != null){
                rCPTCBrand.Name = mapIndividualIds.get(rIndId).Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-' +rLeadForPartyId.Email;
                rCPTCBrand.CaptureContactPointType = 'Web';
                rCPTCBrand.CaptureSource = rCPTCBrand.CaptureSource !=null ? rLeadForPartyId.CreatedDate > rCPTCBrand.CaptureDate ? rLeadForPartyId.Capture_Source__c : rCPTCBrand.CaptureSource : rLeadForPartyId.Capture_Source__c;
                rCPTCBrand.ContactPointType = 'Email';
                rCPTCBrand.DataUsePurposeId = strDUPIdBrand;
                rCPTCBrand.PartyId = rIndId;
                rCPTCBrand.DoubleConsentCaptureDate = rLeadForPartyId.Lead_Submission_Date__c > rCPTCBrand.CaptureDate ? rLeadForPartyId.Double_Consent_Capture_Date__c : rCPTCBrand.DoubleConsentCaptureDate;
                rCPTCBrand.PrivacyConsentStatus = 'OptIn';
                rCPTCBrand.BusinessBrandId = busBrandId;
                if(rLeadForPartyId.Lead_Submission_Date__c !=null) {	 
                    rCPTCBrand.CaptureDate = rLeadForPartyId.Lead_Submission_Date__c	;  
                }else {	 
                    rCPTCBrand.CaptureDate =  rLeadForPartyId.CreatedDate;
                }
                lstCPTCtoInsert.add(rCPTCBrand);
            }
        }
        
        
        // Create new Individual ID and CPTC
        if (mapNameToLead.size() > 0){
            
            for (Lead lcptc : mapNameToLead.values()){
                Individual recInd = new Individual();
                recInd.FirstName = lcptc.FirstName;
                recInd.LastName = lcptc.LastName;
                
                lstIndividualToInsert.add(recInd);
            }
            List<Database.SaveResult> lstIndividualSaveResult = Database.Insert(lstIndividualToInsert, false);
            ErrorLogger.writeErrors('SFDC', 'Individual', 'ConsentMgmtUtility.populateIndividualIdLead', lstIndividualSaveResult, lstIndividualToInsert);
            
            for (Individual ri : lstIndividualToInsert){
                Lead rLead = mapNameToLead.get(ri.FirstName + ' ' + ri.LastName);
                rLead.IndividualId = ri.Id;
                
                setEmailToCheckOtherLead.add(rLead.Email);
                mapEmailToIndividualID.put(rLead.Email, ri.Id);
                
                lstLeadToUpdate.add(rLead);
                
                // prepare CPTC record
                ContactPointTypeConsent rCPTC = new ContactPointTypeConsent();
                String strDUPName = 'Marketing';
                String strDUPId = mapNameToDataUsePurpose.get(strDUPName);
                if (rLead.Source_Brand__c == 'Maersk Go') {
                    busBrandId = mapNameToBusBrandId.containsKey(BrandUtilities.Maersk) ? mapNameToBusBrandId.get(BrandUtilities.Maersk) : null;}
                else{
                    busBrandId = mapNameToBusBrandId.containsKey(rLead.Source_Brand__c) ? mapNameToBusBrandId.get(rLead.Source_Brand__c) : null;}
                if (strDUPId != null){
                    rCPTC.Name = rLead.Name +'-'+ Datetime.now().format('yyyy-MM-dd') +'-'+ rLead.Email;
                    rCPTC.CaptureContactPointType = 'Web';
                    rCPTC.CaptureSource = rCPTC.CaptureSource !=null ? rLead.CreatedDate > rCPTC.CaptureDate ? rLead.Capture_Source__c : rCPTC.CaptureSource : rLead.Capture_Source__c;
                    rCPTC.ContactPointType = 'Email';
                    rCPTC.DataUsePurposeId = strDUPId;
                    rCPTC.PartyId = ri.Id;
                    rCPTC.PrivacyConsentStatus = 'OptIn';
                    rCPTC.DoubleConsentCaptureDate = rLead.Double_Consent_Capture_Date__c !=null ? rLead.Double_Consent_Capture_Date__c : rCPTC.DoubleConsentCaptureDate;
                    rCPTC.BusinessBrandId = busBrandId;
                    if(rLead.Lead_Submission_Date__c !=null) {	 
                        rCPTC.CaptureDate = rLead.Lead_Submission_Date__c	;  
                    }else {	 
                        rCPTC.CaptureDate =  rLead.CreatedDate;
                    }
                    lstCPTCtoInsert.add(rCPTC);
                }
                
                // Create new ContactPointEmail
                ContactPointEmail rContactPointEmail1 = new ContactPointEmail();
                String leadEmailAddress1 = rLead.Email;
                rContactPointEmail1.EmailAddress = leadEmailAddress1;  
                rContactPointEmail1.ParentId = ri.Id; 
                lstContactPointEmailToInsert.add(rContactPointEmail1);
            }
            // Insert new ConsentPointType records if not already present
            if (lstCPTCtoInsert.size() > 0){            
                List<Database.SaveResult> lstCPTCSaveResult2 = Database.Insert(lstCPTCtoInsert, false);
                ErrorLogger.writeErrors('SFDC', 'ContactPointTypeConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCPTCSaveResult2, lstCPTCtoInsert);
            }
            // Insert new ContactPointEmail records if not already present
            if (lstContactPointEmailToInsert.size() > 0){            
                List<Database.SaveResult> lstCPESaveResult2 = Database.Insert(lstContactPointEmailToInsert, false);
                ErrorLogger.writeErrors('SFDC', 'ContactPointTypeConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCPESaveResult2, lstContactPointEmailToInsert);
            }
            
            // Insert CommSubscriptionConsent records after Lead and ContactPointEmail records have been inserted
            for (Individual ri : lstIndividualToInsert) {
                Lead rLead = mapNameToLead.get(ri.FirstName + ' ' + ri.LastName);
                
                if (rLead != null) {
                    ContactPointEmail rContactPointEmail = lstContactPointEmailToInsert[lstIndividualToInsert.indexOf(ri)];
                    for (ContactPointTypeConsent rCptc1 : lstCPTCtoInsert)  {                
                        // Create new CSC records
                        String strCSCTName = 'Regional market updates Email';
                        String strCSCTId = mapNameToCommSubscriptionChannelType.get(strCSCTName);
                        CommSubscriptionConsent rCommSubscriptionConsent = new CommSubscriptionConsent();
                        rCommSubscriptionConsent.Name = rLead.Email + '-Regional market updates';
                        if(rLead.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime = rLead.Lead_Submission_Date__c	;  
                        }else {	 
                            rCommSubscriptionConsent.ConsentCapturedDateTime = rLead.CreatedDate;
                        }
                        if(rLead.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLead.Lead_Submission_Date__c.format('yyyy-MM-dd'));  
                        }else {	 
                            rCommSubscriptionConsent.EffectiveFromDate = Date.valueOf(rLead.CreatedDate.format('yyyy-MM-dd')); 
                        }   
                        rCommSubscriptionConsent.ConsentCapturedSource = rLead.Capture_Source__c;
                        rCommSubscriptionConsent.BusinessBrandId = rCptc1.BusinessBrandId;
                        rCommSubscriptionConsent.Privacy_Consent_Status__c = 'OptIn';
                        rCommSubscriptionConsent.ContactPointId = rContactPointEmail.Id;
                        rCommSubscriptionConsent.CommSubscriptionChannelTypeId = strCSCTId;
                        lstCommSubscriptionConsentToInsert.add(rCommSubscriptionConsent);
                        
                        String strCSCTName1 = 'New solutions, products and services Email';
                        String strCSCTId1 = mapNameToCommSubscriptionChannelType.get(strCSCTName1);
                        CommSubscriptionConsent rCommSubscriptionConsent1 = new CommSubscriptionConsent();
                        rCommSubscriptionConsent1.Name = rLead.Email+ '-New solutions, products and services';
                        if(rLead.Lead_Submission_Date__c !=null) {	 
                            rCommSubscriptionConsent1.ConsentCapturedDateTime = rLead.Lead_Submission_Date__c	;  
                        }else {	 
                            rCommSubscriptionConsent1.ConsentCapturedDateTime = rLead.CreatedDate;
                        }
                        rCommSubscriptionConsent1.ConsentCapturedSource = rLead.Capture_Source__c;
                        rCommSubscriptionConsent1.EffectiveFromDate = Date.valueOf(Datetime.now().format('yyyy-MM-dd'));
                        rCommSubscriptionConsent1.BusinessBrandId = rCptc1.BusinessBrandId;
                        rCommSubscriptionConsent1.Privacy_Consent_Status__c = 'OptIn';
                        rCommSubscriptionConsent1.ContactPointId = rContactPointEmail.Id;
                        rCommSubscriptionConsent1.CommSubscriptionChannelTypeId = strCSCTId1;
                        lstCommSubscriptionConsentToInsert.add(rCommSubscriptionConsent1);
                        
                    }
                }
            }
            
            // Insert new Communication Subscription Consent records if not already present
            if (lstCommSubscriptionConsentToInsert.size() > 0) {
                List<Database.SaveResult> lstCommSubscriptionConsentSaveResult2 = Database.Insert(lstCommSubscriptionConsentToInsert, false);
                ErrorLogger.writeErrors('SFDC', 'CommSubscriptionConsent', 'ConsentMgmtUtility.populateIndividualIdLead', lstCommSubscriptionConsentSaveResult2, lstCommSubscriptionConsentToInsert);
            }
        }
        
        // Get other lead records with same email and update indvidualId
        lstOtherLead = getOtherLeadsForSameEmail(setEmailToCheckOtherLead, setLeadId);
        if (lstOtherLead.size() > 0){
            for(Lead rLead3 : lstOtherLead){
                String strIndIDforEmail = mapEmailToIndividualID.get(rLead3.Email);
                
                rLead3.IndividualId = strIndIDforEmail;
                lstLeadToUpdate.add(rLead3);
            }
            
        }
        
        if (lstLeadToUpdate.size() > 0){           
            List<Database.SaveResult> lstleadSaveResult = Database.Update(lstLeadToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Lead', 'ConsentMgmtUtility.populateIndividualIdLead', lstleadSaveResult, lstLeadToUpdate);
        }
        
        // Get other contact records with same email and update indvidualId
        lstOtherContact = getOtherContactsForSameEmail(setEmailToCheckOtherLead, setIdsEmpty);      
        if (lstOtherContact.size() > 0){
            for (Contact rCnt1 : lstOtherContact){
                String strIndIdforEmail2 = mapEmailToIndividualID.get(rCnt1.Email);
                
                rCnt1.IndividualId = strIndIdforEmail2;
            }
            
            List<Database.SaveResult> lstOtherContactSaveResult = Database.Update(lstOtherContact, false);
            ErrorLogger.writeErrors('SFDC', 'Contact', 'ConsentMgmtUtility.populateIndividualIdLead', lstOtherContactSaveResult, lstOtherContact);
        }
    }
    
    public static void populateIndividualIdContact(Set<Id> setCntIds){
        
        List<Contact> lstContactInserted = new List<Contact>();
        Set<String> setEmailCnt = new Set<String>();
        Set<Id> setContactId = new Set<Id>();
        Map<String, ID> mapLeadEmailToIndividualId = new Map<String, ID>();
        Map<String, ID> mapContactEmailToIndividualId = new Map<String, ID>();
        Set<String> setEmailToCheckOtherCnt = new Set<String>();
        Map<String, ID> mapEmailToIndividualID = new Map<String, ID>();
        List<Contact> lstContactToUpdate = new List<Contact>();
        List<Lead> lstLeadToUpdate = new List<Lead>();
        List<Contact> lstOtherContact = new List<Contact>();
        List<Lead> lstOtherLead = new List<Lead>();
        Set<Id> setIdsEmpty = new Set<Id>();
        
        lstContactInserted = getInsertedContacts(setCntIds);
        
        for (Contact rc1 : lstContactInserted){
            setEmailCnt.add(rc1.Email);
            setContactId.add(rc1.Id);
        }
        
        //get existing Individual Id for Lead and Contact
        mapContactEmailToIndividualId = getContactEmailToIndividualID(setEmailCnt);
        mapLeadEmailToIndividualId = getLeadEmailToIndividualID(setEmailCnt);
        
        for (Contact rc2 : lstContactInserted){
            Id idContactIndId = mapContactEmailToIndividualId.get(rc2.Email);
            Id idLeadIndId = mapLeadEmailToIndividualId.get(rc2.Email);
            //system.debug('## inside loop rc2: ' + rc2);
            if (idContactIndId != null ){
                // Individual Id found in Contact
                setEmailToCheckOtherCnt.add(rc2.Email); 
                mapEmailToIndividualID.put(rc2.Email, idContactIndId);
                
                rc2.IndividualId = idContactIndId;
                lstContactToUpdate.add(rc2);
            } else if (idLeadIndId != null){
                // Individual Id found in Lead
                setEmailToCheckOtherCnt.add(rc2.Email); 
                mapEmailToIndividualID.put(rc2.Email, idLeadIndId);
                
                rc2.IndividualId = idLeadIndId;
                lstContactToUpdate.add(rc2);
            }
        }
        
        
        // Get other contact records with same email and update indvidualId
        lstOtherContact = getOtherContactsForSameEmail(setEmailToCheckOtherCnt, setContactId);
        if (lstOtherContact.size() > 0){
            for (Contact rc3 : lstOtherContact){
                String strIndIdforEmail2 = mapEmailToIndividualID.get(rc3.Email);
                
                rc3.IndividualId = strIndIdforEmail2;
                lstContactToUpdate.add(rc3);
            }
        }
        
        if (lstContactToUpdate.size() > 0){            
            List<Database.SaveResult> lstContactSaveResult = Database.Update(lstContactToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Contact', 'ConsentMgmtUtility.populateIndividualIdContact', lstContactSaveResult, lstContactToUpdate);
        }
        
        // Get other lead records with same email and update indvidualId
        lstOtherLead = getOtherLeadsForSameEmail(setEmailToCheckOtherCnt, setIdsEmpty);
        if (lstOtherLead.size() > 0){
            for(Lead rl1 : lstOtherLead){
                String strIndIDforEmail = mapEmailToIndividualID.get(rl1.Email);
                
                rl1.IndividualId = strIndIDforEmail;
                lstLeadToUpdate.add(rl1);
            }
        }
        
        if (lstLeadToUpdate.size() > 0){            
            List<Database.SaveResult> lstOtherleadSaveResult = Database.Update(lstLeadToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Lead', 'ConsentMgmtUtility.populateIndividualIdContact', lstOtherleadSaveResult, lstLeadToUpdate);
        }
    }
    
    private static List<Lead> getInsertedLeads(Set<Id> setIds){
        List<Lead> lstLeadCreated = new List<Lead>();
        
        if (Schema.sObjectType.Lead.isAccessible()){
            lstLeadCreated = [SELECT Id, Name, Double_Consent_Capture_Date__c, Lead_Submission_Date__c, FirstName, LastName, Email, Marketing_Opt_In__c, Source_Brand__c, Capture_Source__c, CreatedDate, IndividualId FROM Lead WHERE Id in: setIds];
        }
        return lstLeadCreated;
    }
    
    private static List<Contact> getInsertedContacts(Set<Id> setCIds){
        List<Contact> lstContactCreated = new List<Contact>();
        
        if (Schema.sObjectType.Contact.isAccessible()){
            lstContactCreated = [SELECT Id, Name, FirstName, LastName, Email, IndividualId FROM Contact WHERE Id in: setCIds ];
        }
        return lstContactCreated;
    }
    
    
    private static Map<String, ID> getLeadEmailToIndividualID(set<String> setEmailToCheck){
        Map<String, ID> mapLeadEmailIndID = new Map<String, ID>();
        
        if (Schema.sObjectType.Lead.isAccessible()){
            //get Leads with Individual ID
            List<Lead> lstLeadInd = [SELECT IndividualId, Email FROM Lead WHERE Email in: setEmailToCheck AND IndividualID != null ORDER BY LastModifiedDate ASC];
            
            for (Lead lr : lstLeadInd){
                mapLeadEmailIndID.put(lr.Email, lr.IndividualId);
            }
        }
        return mapLeadEmailIndID;
    }
    
    
    private static Map<String, ID> getContactEmailToIndividualID(set<String> setEmailToCheck){
        Map<String, ID> mapContactEmailIndID = new Map<String, ID>();
        
        if (Schema.sObjectType.Contact.isAccessible()){
            //get Contacts with Individual ID
            List<Contact> lstContactInd = [SELECT Id, IndividualId, Email FROM Contact WHERE Email in: setEmailToCheck AND IndividualID != null ORDER BY LastModifiedDate ASC];
            
            for (Contact cr : lstContactInd){
                mapContactEmailIndID.put(cr.Email, cr.IndividualId);
            }
        }
        return mapContactEmailIndID;
    }
    
    private static List<ContactPointTypeConsent> getContactPointTypeConsent(Set<Id> setIndId){
        List<ContactPointTypeConsent> lstCPTC = new List<ContactPointTypeConsent>();
        
        if (Schema.sObjectType.ContactPointTypeConsent.isAccessible()){
            lstCPTC = [SELECT CaptureDate, DoubleConsentCaptureDate, CaptureSource, Id, Name, PrivacyConsentStatus, PartyId, Party.Name, BusinessBrand.Name, DataUsePurpose.Name FROM ContactPointTypeConsent WHERE PartyId in: setIndId];
            
        }
        return lstCPTC;
    }
    
    private static List<Lead> getOtherLeadsForSameEmail(set<String> setEmailToOtherLead, set<Id> setLeadIdToExclude){
        List<Lead> lstLeadOther = new List<Lead>();
        
        if (Schema.sObjectType.Lead.isAccessible()){
            if (setLeadIdToExclude.isEmpty()){
                lstLeadOther = [SELECT Id, Email, IndividualId FROM Lead WHERE Email in: setEmailToOtherLead AND IndividualID = null ];
            } else {
                lstLeadOther = [SELECT Id, Email, IndividualId FROM Lead WHERE Email in: setEmailToOtherLead AND IndividualID = null AND ID not in: setLeadIdToExclude];
            }
        }
        return lstLeadOther;
    }
    
    private static List<Contact> getOtherContactsForSameEmail(set<String> setEmailToOtherCnt, set<Id> setCntIdToExclude){
        List<Contact> lstCntOther = new List<Contact>();
        
        if (Schema.sObjectType.Contact.isAccessible()){
            if (setCntIdToExclude.isEmpty()){
                lstCntOther = [SELECT Id, Email, IndividualId FROM Contact WHERE Email in: setEmailToOtherCnt AND IndividualID = null ];
            } else {
                lstCntOther = [SELECT Id, Email, IndividualId FROM Contact WHERE Email in: setEmailToOtherCnt AND IndividualID = null AND ID not in: setCntIdToExclude];
            }
        }
        return lstCntOther;
    }
    
    // Get CommSubscriptionChannelType details
    private static Map<String,Id> getCommSubscriptionChannelType(){
        Map<String, Id> mapNameToCSCTId = new Map<String, Id>();
        if (Schema.sObjectType.CommSubscriptionChannelType.isAccessible()){
            List<CommSubscriptionChannelType> lstCSCT = [SELECT Id, Name FROM CommSubscriptionChannelType];
            
            for (CommSubscriptionChannelType rCSCT : lstCSCT){
                mapNameToCSCTId.put(rCSCT.Name, rCSCT.Id);
            }
        }
        return mapNameToCSCTId;
    }
    
    private static Map<String,Id> getDataUsePurpose(){
        Map<String, Id> mapNameToDUPId = new Map<String, Id>();
        if (Schema.sObjectType.DataUsePurpose.isAccessible()){
            List<DataUsePurpose> lstDUP = [SELECT Id, Name FROM DataUsePurpose];
            
            for (DataUsePurpose rDUP : lstDUP){
                mapNameToDUPId.put(rDUP.Name, rDUP.Id);
            }
        }
        return mapNameToDUPId;
    }
    
    // Define the getContactPointEmail method
    Public static List<ContactPointEmail> getContactPointEmail(Set<Id> setIndId){
        List<ContactPointEmail> lstCPE = new List<ContactPointEmail>();
        
        if (Schema.sObjectType.ContactPointEmail.isAccessible()){
            lstCPE = [SELECT Id, EmailAddress, ParentId FROM ContactPointEmail WHERE ParentId in: setIndId];
            
        }
        return lstCPE;
    }
    
    
    //Define CommSubConsent
    public static List<CommSubscriptionConsent> getCommSubscriptionConsent(Set<Id> setCPEId, Set<Id> setCSCId){
        List<CommSubscriptionConsent> lstCSC = new List<CommSubscriptionConsent>();
        
        if (Schema.sObjectType.CommSubscriptionConsent.isAccessible()){
            lstCSC = [SELECT Id, ContactPointId, CommSubscriptionChannelTypeId, Privacy_Consent_Status__c  FROM CommSubscriptionConsent WHERE ContactPointId =:setCPEId and CommSubscriptionChannelTypeId =:setCSCId];
            
        }
        return lstCSC;
    }
    
    public static Map<String, Id> getBusinessBrands(){
        
        Map<String, Id> mapNameToBusBrandId = new Map<String, Id>();
        if (Schema.sObjectType.BusinessBrand.isAccessible()){            
            for (BusinessBrand busBrand : [SELECT Id, Name FROM BusinessBrand]){
                mapNameToBusBrandId.put(busBrand.Name, busBrand.Id);
            }
        }
        return mapNameToBusBrandId;
    }
}