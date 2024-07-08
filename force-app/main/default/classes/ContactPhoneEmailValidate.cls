/**
* Description : Contact Phone Email Validate by calling Informatica webservice. 
*				This class is invoked from ContactTriggerHandler
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 28/03/2019   Sid/Nitin@Maersk         RQ-010026   Class created.
* 09/09/2020   Sidhartha@maersk	   		SFSE-3924   Deprecated buildEmailToLastModifiedUser() method.
* 09/11/2020   Sidhartha@maersk	   		SFSE-5016   Added buildEmailToLastModifiedUser() method.
* 25/11/2020   Sidhartha@maersk	   		SFSE-5224   Changing Chatter UserName From Custom Label to Custom Metadata
* 05/02/2021   Kiran@maersk			    SFSE-5479	Changing Informatica status from Custom Labels to Custom Metadata
*/
public class ContactPhoneEmailValidate implements Queueable,Database.AllowsCallouts {
    
    private Id getContactId;
    public List<String> getPhone;
    public List<Contact> lstOldContact;
    public String strContactEmail;
    public String strContactDuplicateEmail;
    public String strPhoneStatus;
    public String strMobilePhoneStatus;
    public String strFaxStatus;
    public String strEmailStatus;
    public String strDuplicateEmailStatus;

    private Contact contactRecord;
    private String getLastModifiedUserId;
    @TestVisible static map<String,String> contactPhoneStatusmap = new Map<String,String>();
    @TestVisible static map<String,String> contactEmailStatusmap = new Map<String,String>();
    private map<String,String> reasonToStatusmap;
    private map<String,String> getMapOfPhoneToFieldName;
    private map<String,String> getMapOfPhoneWithoutCountryCodeToFieldName;
    private map<String,String> getmapOfEmailIdToFieldName;
    private List<Messaging.SingleEmailMessage> emailtolastModifierlst;
    public Map<Id, Contact> mapGetOldContacts;
    
    public Contact_Informatica_Webservice__mdt contPhoneWebservice;
    public Contact_Informatica_Webservice__mdt contEmailWebservice;
    private Map<String,List<String>> contactPhoneEmailStatusMap;
    private User userRecordForChatterPost;
    static final string STATUS_UNAVAILABLE_CONST = Label.Informatica_Service_Status_Unavailable;
    static final string STATUS_TRUE_CONST = Label.Informatica_Service_Status_True;
    static final string EMAIL_VALID_DESC_CONST = Label.Informatica_Email_Valid_MasterLabel;
    static final string PHONE_VALID_DESC_CONST = Label.Informatica_Phone_Valid_MasterLabel;
    @TestVisible static Boolean makeCallout = true;

    public ContactPhoneEmailValidate (Map<Id,Contact> mapOldContact, Id contactId, Map<String, String> mapPhoneNumberToFieldNm, Map<String, String> mapPhoneNumberWithoutCountryCodeToFieldNm, Map<String, String> mapEmailIdsToFieldName, Contact_Informatica_Webservice__mdt phoneInformaticaWebservice, Contact_Informatica_Webservice__mdt emailInformaticaWebservice) {
        If(mapOldContact != null && !mapOldContact.isEmpty()) {
            mapGetOldContacts = mapOldContact;
        }
        getContactId = contactId;
        reasonToStatusmap = new Map<String,String>();
        getMapOfPhoneToFieldName = new map<String,String>();
        getMapOfPhoneWithoutCountryCodeToFieldName = new Map<String,String>();
        getmapOfEmailIdToFieldName = new Map<String,String>();
        
        getPhone = new List<String>();
        getMapOfPhoneToFieldName = mapPhoneNumberToFieldNm;
        getMapOfPhoneWithoutCountryCodeToFieldName = mapPhoneNumberWithoutCountryCodeToFieldNm;
        if(!mapPhoneNumberToFieldNm.IsEmpty() && mapPhoneNumberToFieldNm !=null) {
            for (String pn : mapPhoneNumberToFieldNm.keyset()){
                getPhone.add(pn);
            }
        }
        
        for(String eml : mapEmailIdsToFieldName.keyset()) {
            String strFNValue = mapEmailIdsToFieldName.get(eml);
            if (strFNValue == 'Email'){
                strContactEmail = eml;
            }
            if (strFNValue == 'Duplicate_Email__c'){
                strContactDuplicateEmail = eml;
            }
        }
        getmapOfEmailIdToFieldName = mapEmailIdsToFieldName;
        
        contPhoneWebservice = phoneInformaticaWebservice;
        contEmailWebservice = emailInformaticaWebservice;
        contactPhoneEmailStatusMap = new Map<String,List<String>>();
        for(Contact_Informatica_EmailPhone_Status__mdt conEmailPhoneValidStatus : 
            [select id, masterlabel, developerName, Status_Description__c 
             from Contact_Informatica_EmailPhone_Status__mdt]){
                 if( !contactPhoneEmailStatusMap.containsKey(conEmailPhoneValidStatus.MasterLabel) ){
                     contactPhoneEmailStatusMap.put(conEmailPhoneValidStatus.MasterLabel, new List<String>{conEmailPhoneValidStatus.Status_Description__c});
                 }
                 else{
                     contactPhoneEmailStatusMap.get(conEmailPhoneValidStatus.MasterLabel).add(conEmailPhoneValidStatus.Status_Description__c);
                 }
             }
        String strChatterUsername = contPhoneWebservice.Chatter_UserName__c;
        If(contactId != null) {
            contactRecord = [SELECT Id, Name, Email_Phone_Verification_Results__c, LastModifiedById, Email, Duplicate_Email__c, Phone, MobilePhone, OtherPhone, Fax, Contact_Status__c FROM Contact WHERE Id = :contactId Limit 1];
            getLastModifiedUserId = (contactRecord != null) ? contactRecord.LastModifiedById : null;
        }
        userRecordForChatterPost = [SELECT Id FROM User WHERE UserName = :strChatterUsername Limit 1];
        
    }
    
    public void execute(QueueableContext context) { 

        List<Contact> lstContactToUpdate = new List<Contact>();
        String strPhoneStatusMessage = '';
        String strMobilePhoneStatusMessage = '';
        String strOtherPhoneStatusMessage = '';
        String strFaxStatusMessage = '';
        String strEmailStatusMessage = '';
        String strDuplicateEmailStatusMessage = '';
        FeedItem postContactChatterFeed = new FeedItem();

        if (strContactEmail != null && (contEmailWebservice.Active__c || Test.isRunningTest())){
            // Validate Contact Email
            HTTPResponse resEmail;
            if (makeCallout){
                resEmail = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strContactEmail, contEmailWebservice);
                system.debug('resEmail ' + resEmail.getBody());
                Map<String, String> mapEmailResult = ContactPhoneEmailValidateUtility.processEmailResponse(resEmail, strContactEmail);
                contactEmailStatusmap.putAll(mapEmailResult);
            }
        }
        
        if (strContactDuplicateEmail != null && (contEmailWebservice.Active__c || Test.isRunningTest())){
            // Validate Contact Duplicate Email
            HTTPResponse resDuplicateEmail;
            if (makeCallout){
                resDuplicateEmail = ContactPhoneEmailValidateUtility.getEmailValidationResponse(strContactDuplicateEmail, contEmailWebservice);
                Map<String, String> mapDuplicateEmailResult = ContactPhoneEmailValidateUtility.processEmailResponse(resDuplicateEmail, strContactDuplicateEmail);
                contactEmailStatusmap.putAll(mapDuplicateEmailResult);
            }
        }
        
        system.debug('getPhone' + getPhone);
        if (getPhone.size() > 0 && (contPhoneWebservice.Active__c || Test.isRunningTest())){
            //Validate Contact Phone, MobilePhone and OtherPhone 
            HTTPResponse resPhone;
            if (makeCallout){
                resPhone = ContactPhoneEmailValidateUtility.getPhoneValidationResponse(getPhone, contPhoneWebservice); 
            	system.debug('resPhone ' + resPhone.getBody());
                if (getPhone.size() == 1){
                    Map<String, String> mapPhoneSingleResult = contactPhoneStatusmap = ContactPhoneEmailValidateUtility.processSinglePhoneResponse(resPhone, getPhone[0], getMapOfPhoneToFieldName, getMapOfPhoneWithoutCountryCodeToFieldName);
                    contactPhoneStatusmap.putAll(mapPhoneSingleResult);
                } else { 
                    Map<String, String> mapPhoneMultiResult = contactPhoneStatusmap = ContactPhoneEmailValidateUtility.processMultiplePhoneResponse(resPhone, getPhone, getMapOfPhoneToFieldName, getMapOfPhoneWithoutCountryCodeToFieldName);
                    contactPhoneStatusmap.putAll(mapPhoneMultiResult);
                }
            }
        }
        
    
        // Prepare to update contact etc
        system.debug('@@@@ contactPhoneStatusmap: ' + contactPhoneStatusmap);
        system.debug('@@@@ contactEmailStatusmap: ' + contactEmailStatusmap);
        system.debug('@@@@ contactPhoneEmailStatusMap: ' + contactPhoneEmailStatusMap);
        //system.debug('@@@@' + contactRecord);
        
        String strPhoneEmailStatusToUpdate = '';
        if((!contactPhoneStatusmap.isEmpty() && contactPhoneStatusmap !=null) 
            || (!contactEmailStatusmap.isEmpty() && contactEmailStatusmap !=null)) {
            if (contactRecord != null){
                   
            Boolean blnOfficePhoneBlank = (contactRecord.Phone == null) ? true : false;
            Boolean blnMobilePhoneBlank = (contactRecord.MobilePhone == null) ? true : false;
            Boolean blnOtherPhoneBlank = (contactRecord.OtherPhone == null) ? true : false;
            Boolean blnEmailBlank = (contactRecord.Email == null) ? true : false;
            Boolean blnOtherEmailBlank = (contactRecord.Duplicate_Email__c == null) ? true : false;
            
                // check Phone
                String chkPhoneStatus;
                String strPhoneChanged = (contactRecord.Phone == null) ? null : getMapOfPhoneToFieldName.get(contactRecord.Phone.replace('+','').deleteWhitespace());
                if(contactRecord.Phone != null && strPhoneChanged != null) {   
                    String strCntPh = contactRecord.Phone;
                    chkPhoneStatus = contactPhoneStatusmap.get(strCntPh.replace('+','').deleteWhitespace()); // with country code
                    if (chkPhoneStatus == null){
                        // check phone without country code
                        chkPhoneStatus = contactPhoneStatusmap.get(strCntPh.replace('+','').deleteWhitespace().substring(2));
                    }
                    if(contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkPhoneStatus)) {
                        strPhoneStatus = 'officePhoneValidated=' + STATUS_TRUE_CONST; 
                    }else{
                        strPhoneStatus = mapGetOldContacts == NULL ? 'officePhoneValidated=' + STATUS_UNAVAILABLE_CONST : NULL; 
                    }
                } 
                // system.debug('strPhoneStatus ' + strPhoneStatus); 
                // check Mobile Phone
                String chkMobilePhoneStatus;
                String strMobilePhoneChanged = (contactRecord.MobilePhone == null) ? null : getMapOfPhoneToFieldName.get(contactRecord.MobilePhone.replace('+','').deleteWhitespace());
                if(contactRecord.MobilePhone != null && strMobilePhoneChanged != null) {
                    String strCntMobilePh = contactRecord.MobilePhone;
                    chkMobilePhoneStatus = contactPhoneStatusmap.get(strCntMobilePh.replace('+','').deleteWhitespace()); // with country code
                    if (chkMobilePhoneStatus == null){
                        // check mobile phone without country code
                        chkMobilePhoneStatus = contactPhoneStatusmap.get(strCntMobilePh.replace('+','').deleteWhitespace().substring(2));
                    }
                    if(contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkMobilePhoneStatus)) {
                        strMobilePhoneStatus = 'mobilePhoneValidated=' + STATUS_TRUE_CONST; 
                    }else{
                        strMobilePhoneStatus = mapGetOldContacts == NULL ? 'mobilePhoneValidated=' + STATUS_UNAVAILABLE_CONST : NULL; 
                    }
                       
                    if ( chkMobilePhoneStatus!= null && !contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkMobilePhoneStatus) && chkMobilePhoneStatus != STATUS_UNAVAILABLE_CONST){
                        strMobilePhoneStatusMessage = 'MobilePhone';
                        if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                            blnMobilePhoneBlank = mapGetOldContacts.get(contactRecord.Id).MobilePhone == null ? true : false;
                            contactRecord.MobilePhone = mapGetOldContacts.get(contactRecord.Id).MobilePhone;
                        }else {
                            blnMobilePhoneBlank = true;
                            contactRecord.MobilePhone = '';
                        } 
                    }  
                }

                //check fax
                String chkFaxStatus;
                String strFaxChanged = (contactRecord.Fax == null) ? null : getMapOfPhoneToFieldName.get(contactRecord.Fax.replace('+','').deleteWhitespace());
                if(contactRecord.Fax != null && strFaxChanged != null) {
                    String strCntFax = contactRecord.Fax;
                    chkFaxStatus = contactPhoneStatusmap.get(strCntFax.replace('+','').deleteWhitespace()); // with country code
                    if (chkFaxStatus == null){
                        // check fax without country code
                        chkFaxStatus = contactPhoneStatusmap.get(strCntFax.replace('+','').deleteWhitespace().substring(2));
                    }
                    if(contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkFaxStatus)) {
                        strFaxStatus = 'faxValidated=' + STATUS_TRUE_CONST; 
                    }else{
                        strFaxStatus = mapGetOldContacts == NULL ? 'faxValidated=' + STATUS_UNAVAILABLE_CONST : NULL; 
                    }
                    
                    if ( chkFaxStatus != null && !contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkFaxStatus) && chkFaxStatus != STATUS_UNAVAILABLE_CONST){
                        strFaxStatusMessage = 'Fax';
                        if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                            contactRecord.Fax = mapGetOldContacts.get(contactRecord.Id).Fax;
                        }else{
                            contactRecord.Fax = '';
                        }
                    }  
                }
                   
                String chkOtherPhoneStatus;
                String strOtherPhoneChanged = (contactRecord.OtherPhone == null) ? null : getMapOfPhoneToFieldName.get(contactRecord.OtherPhone.replace('+','').deleteWhitespace());
                if(contactRecord.OtherPhone != null && strOtherPhoneChanged != null) {
                    String strCntOtherPh = contactRecord.OtherPhone;
                    chkOtherPhoneStatus = contactPhoneStatusmap.get(strCntOtherPh.replace('+','').deleteWhitespace()); // with country code
                    if (chkOtherPhoneStatus == null){
                        // check fax without country code
                        chkOtherPhoneStatus = contactPhoneStatusmap.get(strCntOtherPh.replace('+','').deleteWhitespace().substring(2));
                    }
                    if ( chkOtherPhoneStatus != null && !contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkOtherPhoneStatus) && chkOtherPhoneStatus != STATUS_UNAVAILABLE_CONST){
                        strOtherPhoneStatusMessage = 'Other Phone';
                        if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                            blnOtherPhoneBlank = mapGetOldContacts.get(contactRecord.Id).OtherPhone == null ? true : false;
                            contactRecord.OtherPhone = mapGetOldContacts.get(contactRecord.Id).OtherPhone;
                        }else{
                            blnOtherPhoneBlank = true;
                            contactRecord.OtherPhone = '';
                        }
                    }
                }

                // This check is done to cover edge case where we have valid other phone but invalid primary phone (office phone) 
                if ( contactRecord.Phone != null && strPhoneChanged != null 
                    && chkPhoneStatus != null && !contactPhoneEmailStatusMap.get(PHONE_VALID_DESC_CONST).contains(chkPhoneStatus) && chkPhoneStatus != STATUS_UNAVAILABLE_CONST
                   /*&& blnOtherPhoneBlank*/){
                        strPhoneStatusMessage = 'Phone';
                       if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                           blnOfficePhoneBlank = mapGetOldContacts.get(contactRecord.Id).Phone == null ? true :false;
                           contactRecord.Phone =  mapGetOldContacts.get(contactRecord.Id).Phone;
                       }else{
                           blnOfficePhoneBlank = true;
                           contactRecord.Phone = '';
                       }
                   } 
                
                if ( contactRecord.Phone != null && strPhoneChanged != null && blnOfficePhoneBlank && blnOtherPhoneBlank ) {
                       strPhoneStatus = 'officePhoneValidated=' + STATUS_UNAVAILABLE_CONST; 
                }
                   
                // Check Email
                String strContactEmailCheck = getmapOfEmailIdToFieldName.get(contactRecord.Email);
                String strEmailStatusResponseDesc;
                if(strContactEmailCheck != null && strContactEmailCheck == 'Email' && contactRecord.Email != null) {
                    strEmailStatusResponseDesc = contactEmailStatusmap.get(contactRecord.Email);
                    if(contactPhoneEmailStatusMap.get(EMAIL_VALID_DESC_CONST).contains(strEmailStatusResponseDesc)) {
                        strEmailStatus = 'primaryEmailValidated=' + STATUS_TRUE_CONST; 
                    }else{
                        strEmailStatus = mapGetOldContacts == NULL ? 'primaryEmailValidated=' + STATUS_UNAVAILABLE_CONST : NULL; 
                    }  
                }
                   
                // Check Other Email
                String strContactDuplicateEmailCheck = getmapOfEmailIdToFieldName.get(contactRecord.Duplicate_Email__c);
                String strDuplicateEmailStatusResponseDesc;
                if(strContactDuplicateEmailCheck != null && strContactDuplicateEmailCheck == 'Duplicate_Email__c' && contactRecord.Duplicate_Email__c != null) {
                    strDuplicateEmailStatusResponseDesc = contactEmailStatusmap.get(contactRecord.Duplicate_Email__c);
                    if (contactPhoneEmailStatusMap.get(EMAIL_VALID_DESC_CONST).contains(strDuplicateEmailStatusResponseDesc)){
                        strDuplicateEmailStatus = 'alternateEmailValidated=' + STATUS_TRUE_CONST;
                    }else{
                        strDuplicateEmailStatus = mapGetOldContacts == NULL ?  'alternateEmailValidated=' + STATUS_UNAVAILABLE_CONST : NULL;
                    }
                    if( strDuplicateEmailStatusResponseDesc != null && !contactPhoneEmailStatusMap.get(EMAIL_VALID_DESC_CONST).contains(strDuplicateEmailStatusResponseDesc) && strDuplicateEmailStatusResponseDesc != STATUS_UNAVAILABLE_CONST) {
                        strDuplicateEmailStatusMessage = 'Other Email';
                        if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                            blnOtherEmailBlank = mapGetOldContacts.get(contactRecord.Id).Duplicate_Email__c == null ?true : false;
                            contactRecord.Duplicate_Email__c = mapGetOldContacts.get(contactRecord.Id).Duplicate_Email__c;  
                        }else{
                            blnOtherEmailBlank = true;
                            contactRecord.Duplicate_Email__c = ''; 
                        }
                	}
                }                
                // This check is done to cover edge case where we have valid other email but invalid primary email
                if (strContactEmailCheck != null && strContactEmailCheck == 'Email' && contactRecord.Email != null 
                    && strEmailStatusResponseDesc != null && !contactPhoneEmailStatusMap.get(EMAIL_VALID_DESC_CONST).contains(strEmailStatusResponseDesc) && strEmailStatusResponseDesc != STATUS_UNAVAILABLE_CONST
					/*&& blnOtherEmailBlank*/){
                        strEmailStatusMessage = 'Email';
                        if(mapGetOldContacts != null && !mapGetOldContacts.isEmpty()) {
                            blnEmailBlank = mapGetOldContacts.get(contactRecord.Id).Email == null ? true : false;
                            contactRecord.Email = mapGetOldContacts.get(contactRecord.Id).Email;
                        }else{
                            blnEmailBlank = true;
                            contactRecord.Email = '';
                        }
                    } 

                if (strContactEmailCheck != null && strContactEmailCheck == 'Email' && contactRecord.Email != null && blnEmailBlank && blnOtherEmailBlank) {
                    strEmailStatus = 'primaryEmailValidated=' + STATUS_UNAVAILABLE_CONST; 
                }
               
                strPhoneEmailStatusToUpdate += (strPhoneStatus != null) ? strPhoneStatus : strPhoneEmailStatusToUpdate;
                system.debug('strPhoneEmailStatusToUpdate ' + strPhoneEmailStatusToUpdate);
                system.debug('strPhoneStatus ' + strPhoneStatus); 
                if (strMobilePhoneStatus != null)
                    strPhoneEmailStatusToUpdate += (strMobilePhoneStatus != null && strPhoneEmailStatusToUpdate.length() > 0) ? ',' + strMobilePhoneStatus : strMobilePhoneStatus;
                if (strFaxStatus != null)                    
                    strPhoneEmailStatusToUpdate += (strFaxStatus != null && strPhoneEmailStatusToUpdate.length() > 0) ? ',' + strFaxStatus : strFaxStatus;
                if (strEmailStatus != null)
                    strPhoneEmailStatusToUpdate += (strEmailStatus != null && strPhoneEmailStatusToUpdate.length() > 0) ? ',' + strEmailStatus : strEmailStatus;
                if (strDuplicateEmailStatus != null)
                    strPhoneEmailStatusToUpdate += (strDuplicateEmailStatus != null && strPhoneEmailStatusToUpdate.length() > 0) ? ',' + strDuplicateEmailStatus : strDuplicateEmailStatus;
                   
                contactRecord.Email_Phone_Verification_Results__c = strPhoneEmailStatusToUpdate;
        		//system.debug('@@@@@ Email_Phone_Verification_Results__c' + contactRecord.Email_Phone_Verification_Results__c);
                   
                String strChatterPostSuffixText = '';
                String strEmailSuffixText = '';
                
                if ( blnOfficePhoneBlank && blnMobilePhoneBlank && blnEmailBlank && blnOtherEmailBlank ){
                        contactRecord.Contact_Status__c = 'Inactive';
                        strChatterPostSuffixText = ' Please correct the details.';
                        strEmailSuffixText = '. Please correct the details.';
                } else {
                    strChatterPostSuffixText = ' Please correct the details.';
                    strEmailSuffixText = '. Please correct the details.';
                }
				//system.debug('contactRecord' + contactRecord);
                lstContactToUpdate.add(contactRecord); 
                   
                String strChatterPostText = '#' + System.Label.ChatterTopic + ' ' + 'The ';
                if (contPhoneWebservice.Send_Chatter_Post__c){
                    strChatterPostText += (strPhoneStatusMessage.length() > 0) ? strPhoneStatusMessage : '';

                    if (strMobilePhoneStatusMessage.length() > 0)
                        strChatterPostText += (strChatterPostText.endsWithIgnoreCase('The ') && strMobilePhoneStatusMessage.length() > 0) ? strMobilePhoneStatusMessage : ' and ' + strMobilePhoneStatusMessage;
					//system.debug('strOtherPhoneStatusMessage :' + strOtherPhoneStatusMessage);
                    if (strOtherPhoneStatusMessage.length() > 0)
                    strChatterPostText += (strChatterPostText.endsWithIgnoreCase('The ') && strOtherPhoneStatusMessage.length() > 0) ? strOtherPhoneStatusMessage : ' and ' + strOtherPhoneStatusMessage;
                	system.debug('strChatterPostText :' + strChatterPostText);
                }
                
                if (contEmailWebservice.Send_Chatter_Post__c){
                    if (strEmailStatusMessage.length() > 0)
                        strChatterPostText += (strChatterPostText.endsWithIgnoreCase('The ') && strEmailStatusMessage.length() > 0) ? strEmailStatusMessage : ' and ' + strEmailStatusMessage;
                        
                    if (strDuplicateEmailStatusMessage.length() > 0)
                        strChatterPostText += (strChatterPostText.endsWithIgnoreCase('The ') && strDuplicateEmailStatusMessage.length() > 0) ? strDuplicateEmailStatusMessage : ' and ' + strDuplicateEmailStatusMessage;
                }
                //system.debug('@@@@@ strChatterPostText: ' + strChatterPostText);

                // build chatter post for invalid number / email details
                if (!strChatterPostText.endsWithIgnoreCase('The ')){
                    strChatterPostText += ' used are invalid.' + strChatterPostSuffixText;
                    
                    postContactChatterFeed.Body =  strChatterPostText;
                    postContactChatterFeed.ParentId = contactRecord.Id ;
                    postContactChatterFeed.CreatedById = userRecordForChatterPost.Id; 
                }                
                // build email to last modified user with same details as chatter post with link to contact
                String strEmailText = 'The contact' + ' '+ '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+contactRecord.Id+'">'+contactRecord.Name+'</a></html>' + ' '+ 'you recently updated in Salesforce has the following details updated incorrectly: ';
                if (contPhoneWebservice.Send_Email_To_Last_Modified__c){
                    strEmailText += (strPhoneStatusMessage.length() > 0) ? strPhoneStatusMessage : '';
                    if (strMobilePhoneStatusMessage.length() > 0)
                        strEmailText += (strEmailText.endsWithIgnoreCase('incorrectly: ') && strMobilePhoneStatusMessage.length() > 0) ? strMobilePhoneStatusMessage : ' ,' + strMobilePhoneStatusMessage;
                    
                    if (strOtherPhoneStatusMessage.length() > 0)
                        strEmailText += (strEmailText.endsWithIgnoreCase('incorrectly: ') && strOtherPhoneStatusMessage.length() > 0) ? strOtherPhoneStatusMessage : ' ,' + strOtherPhoneStatusMessage;
                }
                if (contPhoneWebservice.Send_Email_To_Last_Modified__c){
                    if (strEmailStatusMessage.length() > 0)
                        strEmailText += (strEmailText.endsWithIgnoreCase('incorrectly: ') && strEmailStatusMessage.length() > 0) ? strEmailStatusMessage : ' ,' + strEmailStatusMessage;
                    
                    if (strDuplicateEmailStatusMessage.length() > 0)
                        strEmailText += (strEmailText.endsWithIgnoreCase('incorrectly: ') && strDuplicateEmailStatusMessage.length() > 0) ? strDuplicateEmailStatusMessage : ' ,' + strDuplicateEmailStatusMessage;
                }
                if (!strEmailText.endsWithIgnoreCase('incorrectly: ')){
                    strEmailText += strEmailSuffixText;
                    emailtolastModifierlst = ContactPhoneEmailValidateUtility.buildEmailToLastModifiedUser(getLastModifiedUserId,strEmailText);
                    
                    system.debug('@@@@@ strEmailText: ' + strEmailText);
                    system.debug('@@@@@ emailtolastModifierlst: ' + emailtolastModifierlst);
                }
            }
        }
        try {
            ContactTriggerHandler.inRecursiveUpdate = true;
            List<Database.SaveResult> lstSaveResult = Database.Update(lstContactToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Contact', 'ValidateContactPhoneEmail', lstSaveResult, lstContactToUpdate);
        	//system.debug('@@@@@ ContactPhoneEmail lstSaveResult: ' + lstSaveResult);
        	ContactTriggerHandler.inRecursiveUpdate = false;
            
            for (Database.SaveResult sr : lstSaveResult){
                if (sr.isSuccess()) {
                    // chatter post
                    if (postContactChatterFeed != null) {
                        insert postContactChatterFeed;
                    }
                    // email to last modified user
                    if(emailtolastModifierlst.size() > 0 && emailtolastModifierlst != null) {
                        Messaging.sendEmail(emailtolastModifierlst);  
                    }
                } 
            }

        } catch (Exception e) { 
            //no code
        }
    }

}