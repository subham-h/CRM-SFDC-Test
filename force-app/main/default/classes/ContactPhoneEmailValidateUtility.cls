/**
* Description : Contact Phone Email Validate Utility 
*
* Date         Owner               RQ#         Description
************************************************************************************************************
* 28/03/2019   Nitin@Maersk        RQ-010026   Class created.
* 09/09/2020   Sidhartha@maersk	   SFSE-3924   Deprecated buildEmailToLastModifiedUser() method. Changed Email, Phone API Call from GET to POST
* 09/02/2021   Kiran@Maersk		   SFSE-5479   Changing Informatica status from Custom Labels to Custom Metadata
*/
public class ContactPhoneEmailValidateUtility {
	static final String BODY_BOUNDARY='----WebKitFormBoundary7MA4YWxkTrZu0gW';
    public static HTTPResponse getEmailValidationResponse (String strEmail, Contact_Informatica_Webservice__mdt emailWebServiceMetadata) {
        HTTPResponse res;
        Integer intEmailEndpointTimeout = Integer.ValueOf(emailWebServiceMetadata.Timeout__c);
        String emailLicense = emailWebServiceMetadata.License_Key__c;
        String strEmailEndpointURL = emailWebServiceMetadata.Host_Name__c + emailWebServiceMetadata.Query_Path__c;
        String strbody = createEmailPhonebody(null, strEmail, emailLicense);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + BODY_BOUNDARY);
        req.setTimeout(intEmailEndpointTimeout);
        req.setBody(strbody);
        req.setEndpoint(strEmailEndpointURL);
        res = (new Http()).send(req);
        return res;
    }
    
    public static Map<String, String> processEmailResponse(HttpResponse pEmailValidateResponse, String pEmail){
		Map<String, String> contactEmailStatusmap = new Map<String, String>();
        Integer emailHttpStatusCode = pEmailValidateResponse.getStatusCode();
        
        if (emailHttpStatusCode >= 200 && emailHttpStatusCode <= 400){ // http status between 200 and 299 means OK
       
            EmailResponseWrapper responseWrapper = (EmailResponseWrapper )JSON.deserialize(pEmailValidateResponse.getBody(), EmailResponseWrapper.class);
            String emailStatus =  responseWrapper.WebServiceResponse.VerifyEmailResponse.VerifyEmailResult.ServiceResult.Reason.Code;
            String emailStatusNbr = responseWrapper.WebServiceResponse.VerifyEmailResponse.VerifyEmailResult.ServiceStatus.StatusNbr;
            //system.debug('@@@@' + emailStatusNbr);
            String strGetEmail = responseWrapper.WebServiceResponse.VerifyEmailResponse.VerifyEmailResult.ServiceResult.Email.Complete;
            String emailServiceDescription =  responseWrapper.WebServiceResponse.VerifyEmailResponse.VerifyEmailResult.ServiceStatus.StatusDescription;
            if(emailServiceDescription != null && strGetEmail != null) {
                contactEmailStatusmap.put(strGetEmail,emailServiceDescription);
            }
        } else{
            // http status is not 200 the service unavailable
            contactEmailStatusmap.put(pEmail, 'UNAVAILABLE');
        }
        
        return contactEmailStatusmap;
    }
    
    public static HTTPResponse getPhoneValidationResponse (List<String> intPhone, Contact_Informatica_Webservice__mdt phoneWebServiceMetadata) {
        String strCreateUrl;
        HTTPResponse res;
        String strPhoneEndpointURL = phoneWebServiceMetadata.Host_Name__c + phoneWebServiceMetadata.Query_Path__c;
        Integer intPhoneEndpointTimeout = Integer.ValueOf(phoneWebServiceMetadata.Timeout__c);
        String phoneLicense = phoneWebServiceMetadata.License_Key__c;
		String strbody = createEmailPhonebody(intPhone, NULL, phoneLicense);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + BODY_BOUNDARY);
        req.setTimeout(intPhoneEndpointTimeout);
        req.setBody(strBody);
        req.setEndpoint(strPhoneEndpointURL);
        system.debug('req: ' + req);
        res = (new Http()).send(req);
        system.debug('res: ' + res.getBody());
        return res;    
    }
    
    public static String createEmailPhonebody(List<String> lstphoneTovalidate, String pEmail, String emailPhoneLicense) {
        String body = '--' + BODY_BOUNDARY + '\r\n';
        body += 'Content-Disposition: form-data;name="LicenseInfo.RegisteredUser.UserID"\r\n\n';
        body += emailPhoneLicense + '\r\n';
        body += '--' + BODY_BOUNDARY + '\r\n';
        if(lstphoneTovalidate != null) {
            for(integer i=0;i<lstphoneTovalidate.size();i++) {
                String strPhone = lstphoneTovalidate[i];
                strPhone = strPhone.replace(' ', '');
                body += 'Content-Disposition: form-data; name="ValidateNumberBatch.PhoneNumbers.string.string['+i+']"\r\n\n';
                body += +strPhone+'\r\n';
                body += '--' + BODY_BOUNDARY + '\r\n';
            }
        }
        if(pEmail !=null){
            body += 'Content-Disposition: form-data; name="VerifyEmail.Email"\r\n\n';
            body += pEmail +'\r\n';
        }
        body += '--' + BODY_BOUNDARY + '\r\n';
        body += 'Content-Disposition: form-data; name="format"\r\n\n';
        body += 'JSON\r\n';
        body += '--' + BODY_BOUNDARY + '--';
        return body;
    }
    
    public static Map<String, String> processSinglePhoneResponse(HttpResponse pPhoneValidateResponse, String pSinglePhone, Map<String, String> getMapOfPhoneToFieldName, Map<String, String> getMapOfPhoneWithoutCountryToFieldName){
		Map<String, String> contactPhoneStatusmap = new Map<String, String>();
        
        Integer phoneHttpStatusCode = pPhoneValidateResponse.getStatusCode();
        if (phoneHttpStatusCode >= 200 && phoneHttpStatusCode <= 299){ // http status between 200 and 299 means OK
            PhoneResponseWrapperSingleResult responsePhoneWrapperSingle = (PhoneResponseWrapperSingleResult)JSON.deserialize(pPhoneValidateResponse.getBody().replace('"Number":', '"Number_Z":'), PhoneResponseWrapperSingleResult.class);
            //system.debug('@@@@' + responsePhoneWrapperSingle); 
            String strServiceStatusNmbrSingle = responsePhoneWrapperSingle.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceStatus.StatusNbr;
            String strPhoneStatusNmbrSingle = responsePhoneWrapperSingle.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceResult.Results.GlobalPhoneEntryWithStatus.ItemStatus.StatusNbr;
            Integer numPhoneStatusNmbrSingle = Integer.valueOf(strPhoneStatusNmbrSingle);
            String strPhoneStatusDescriptionSingle = responsePhoneWrapperSingle.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceResult.Results.GlobalPhoneEntryWithStatus.ItemStatus.StatusDescription;
            String strGetPhoneNumberSingle = responsePhoneWrapperSingle.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceResult.Results.GlobalPhoneEntryWithStatus.Listing.Number_Z;
            String strGetPhoneNumberTypeSingle =  responsePhoneWrapperSingle.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceResult.Results.GlobalPhoneEntryWithStatus.Listing.Number_Type;
            String strGetWhichPhoneStatus =  getMapOfPhoneToFieldName.get(strGetPhoneNumberSingle);
            String strGetWhichPhoneWithoutCountryStatus = getMapOfPhoneWithoutCountryToFieldName.get(strGetPhoneNumberSingle);
            String strErrorSinglePhoneStatus;

            if(strGetWhichPhoneStatus != null && strPhoneStatusNmbrSingle != null && numPhoneStatusNmbrSingle >= 201 && numPhoneStatusNmbrSingle <= 401){
                contactPhoneStatusmap.put(strGetPhoneNumberSingle, strPhoneStatusDescriptionSingle);
            }else{
                contactPhoneStatusmap.put(strGetPhoneNumberSingle, Label.Informatica_Service_Status_Unavailable);
            }
        } else {
            // http status is not 200 the service unavailable
            contactPhoneStatusmap.put(pSinglePhone, Label.Informatica_Service_Status_Unavailable);
        }
        return contactPhoneStatusmap;
    }
    
    public static Map<String, String> processMultiplePhoneResponse(HttpResponse pMultiPhoneValidateResponse, List<String> pLstPhone, Map<String, String> getMapOfPhoneToFieldName, Map<String, String> getMapOfPhoneWithoutCountryToFieldName){
		Map<String, String> contactPhoneStatusmap = new Map<String, String>();
        
        Integer phoneMultipleHttpStatusCode = pMultiPhoneValidateResponse.getStatusCode();
        if (phoneMultipleHttpStatusCode >= 200 && phoneMultipleHttpStatusCode <= 299){ // http status between 200 and 299 means OK 
            PhoneResponseWrapperMultiResult responsePhoneWrapperMulti = (PhoneResponseWrapperMultiResult)JSON.deserialize(pMultiPhoneValidateResponse.getBody().replace('"Number":', '"Number_Z":'), PhoneResponseWrapperMultiResult.class);
            String strServiceStatusNmbrMulti = responsePhoneWrapperMulti.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceStatus.StatusNbr;
            String strErrorMultiPhoneStatus;
            for(PhoneResponseWrapperMultiResult.GlobalPhoneEntryWithStatus p : responsePhoneWrapperMulti.WebServiceResponse.ValidateNumberBatchResponse.ValidateNumberBatchResult.ServiceResult.Results.GlobalPhoneEntryWithStatus) {
                String strPhoneStatusDescriptionMulti = p.ItemStatus.StatusDescription;
                String strPhoneStatusDescMulti = p.ItemStatus.StatusDescription;
                String strPhoneStatusNmbrMulti = p.ItemStatus.StatusNbr;
                Integer numPhoneStatusNmbrMulti = Integer.valueOf(strPhoneStatusNmbrMulti);
                String strGetPhoneNumberMulti =  P.Listing.Number_Z;
                String strGetPhoneNumberTypeMulti =  P.Listing.Number_Type;
                String strGetWhichPhoneStatus = getMapOfPhoneToFieldName.get(P.Listing.Number_Z);
                String strGetWhichPhoneWithoutCountryStatus = getMapOfPhoneWithoutCountryToFieldName.get(P.Listing.Number_Z); 
                //system.debug('@@@@' + strGetWhichPhoneStatus);

                if(strGetPhoneNumberMulti != null && strPhoneStatusNmbrMulti != null && numPhoneStatusNmbrMulti >= 201 && numPhoneStatusNmbrMulti <= 401){
                    contactPhoneStatusmap.put(strGetPhoneNumberMulti,strPhoneStatusDescMulti);
                }
                else{
                    contactPhoneStatusmap.put(strGetPhoneNumberMulti,Label.Informatica_Service_Status_Unavailable);
                }
            }
        } else {
            // http status is not 200 the service unavailable
            for (String sPhone : pLstPhone){
                contactPhoneStatusmap.put(sPhone, Label.Informatica_Service_Status_Unavailable);
            }
        }
        return contactPhoneStatusmap;
    }
    
    public static List<Messaging.SingleEmailMessage> buildEmailToLastModifiedUser(String strlastModifiedUser, String strEmailBody) {
        User uName = [SELECT Name FROM User WHERE Id =:strlastModifiedUser];
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();    
        sendTo.add(strlastModifiedUser);
        mail.setToAddresses(sendTo);
        mail.setSubject('Contact phone/email validation failed');
        String strBody = 'Dear ' + uName.Name + ' <br /> <br />' + strEmailBody;
        mail.setHtmlBody(strBody);
        mails.add(mail);
        return mails;
    } 
    
    public static void updateContactVerificationResult(Id contactId, Map<String, String> mapEmailIdsToFieldName, Map<String, String> mapPhoneNumbersToFieldName){
        Contact updContact = new Contact();
        String strEmailPhoneResult = '';
        
        for (String sEmailFN : mapEmailIdsToFieldName.Values()){
            if (sEmailFN == 'Email'){
            	strEmailPhoneResult += (strEmailPhoneResult.length() > 0) ? ',' + 'primaryEmailValidated=' + Label.Informatica_Service_Status_Unavailable : 'primaryEmailValidated=' + Label.Informatica_Service_Status_Unavailable;  
            }
            if (sEmailFN == 'Duplicate_Email__c'){
            	strEmailPhoneResult += (strEmailPhoneResult.length() > 0) ? ',' + 'alternateEmailValidated=' + Label.Informatica_Service_Status_Unavailable : 'alternateEmailValidated=' + Label.Informatica_Service_Status_Unavailable;  
            }
        }
        
        for (String sPhoneFN : mapPhoneNumbersToFieldName.Values()){
            if (sPhoneFN == 'Phone'){
            	strEmailPhoneResult += (strEmailPhoneResult.length() > 0) ? ',' + 'officePhoneValidated=' + Label.Informatica_Service_Status_Unavailable : 'officePhoneValidated=' + Label.Informatica_Service_Status_Unavailable;  
            }
            if (sPhoneFN == 'MobilePhone'){
            	strEmailPhoneResult += (strEmailPhoneResult.length() > 0) ? ',' + 'mobilePhoneValidated=' + Label.Informatica_Service_Status_Unavailable : 'mobilePhoneValidated=' + Label.Informatica_Service_Status_Unavailable;  
            }
            if (sPhoneFN == 'Fax'){
            	strEmailPhoneResult += (strEmailPhoneResult.length() > 0) ? ',' + 'faxValidated=' + Label.Informatica_Service_Status_Unavailable : 'faxValidated=' + Label.Informatica_Service_Status_Unavailable;  
            }
        }
        
        if (strEmailPhoneResult != null){
            
            updContact.Id = contactId;
            updContact.Email_Phone_Verification_Results__c = strEmailPhoneResult;
            
            try {
                TriggerExecutionController.skipAllTriggers(true);
            	update updContact;
                TriggerExecutionController.skipAllTriggers(false);
            } catch (Exception ex){
            	//no code            
            }
        }
    }
}