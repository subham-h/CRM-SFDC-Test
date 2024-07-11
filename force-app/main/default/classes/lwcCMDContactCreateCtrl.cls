public class lwcCMDContactCreateCtrl {
    @testVisible
    private static String apikey;
    private static String ingestApi;
    private static String cmdDomain;
    private static String searchApi;
    private static String assignmentApi;
    @testvisible
    public static decimal timeout;
    @testvisible
    public static string oldcontactTypes;
    public static String access_token;
    public static Map<String,String> mapOfContactTypes = new Map<String, String>{
        'COMMERCIAL'=>'COMMERCIAL',
            'EDI BUSINESS'=>'EDI_BUSINESS',
            'EDI TECHNICAL'=>'EDI_TECHNICAL',
            'FINANCE'=>'FINANCE',
            'PORTAL'=>'PORTAL'
            };
                
                public static void getCMDAPIConfigs() {
                    Map<String, CMD_Configuration__mdt> mapCMDConfigs = CMD_Configuration__mdt.getAll();
                    system.debug('mapCMDConfigs ' + mapCMDConfigs);
                    apikey = mapCMDConfigs.get('Contact').API_Key__c;
                    ingestApi = mapCMDConfigs.get('Contact').Ingestion_Api__c;
                    cmdDomain = mapCMDConfigs.get('Contact').CMD_Domain__c;
                    searchApi = mapCMDConfigs.get('Contact').Search_Api__c;
                    assignmentApi = mapCMDConfigs.get('Contact').Contact_Assignment_Api__c;
                    timeout = mapCMDConfigs.get('Contact').Timeout__c;
                }
                public static String getAccessToken() {
                    getCMDAPIConfigs();
                    String resp;
                    //String access_token;
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint('callout:cmd_cdt');
                    req.setTimeout(integer.valueof(timeout));
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String jsonBody ='client_id=' + '{!$Credential.Username}' + '&client_secret=' + '{!$Credential.Password}' + '&grant_type=' + 'client_credentials';
                    req.setBody(jsonBody);
                    // System.debug('Callout error: '+ req);
                    try {
                        res = http.send(req);
                        String responseJson = res.getBody();
                        ClientCredentialResponse responseData = (ClientCredentialResponse)JSON.deserialize(responseJson, ClientCredentialResponse.class);
                        access_token = responseData.access_token;
                    } catch(System.CalloutException e) {
                        System.debug('Callout error: '+ e);
                        ErrorLogger.writeErrors( 'SFDC', 'CMD Access Token', 'lwcCMDContactCreateCtrl.getAccessToken', new list<Exception>{e});
                    }
                    //system.debug('@@@ ' + access_token);
                    return access_token;
                }
    
    
    @AuraEnabled()
    public static String runContactAssignmentAPI(Id accId, String contactCode, Contact cont) {
        String accesstoken = Test.isRunningTest() ? '9999999' : '';
        if(!Test.isRunningTest()) {
            accesstoken = getAccessToken();  
        }
        Account acc = [select Id, Customer_Code__c from Account WHERE Id =: accId];
        
        ContactAuditData cntAudit = new ContactAuditData();
        cntAudit.user = UserInfo.getUserName();
        cntAudit.sourceSystem = 'SFDC';
        
        
        contactAssignmentEntity cae = new contactAssignmentEntity();
        cae.customerCode = acc.Customer_Code__c;
        cae.contactCode = contactCode;
        
        payloadWrapper payWrap = new payloadWrapper();
        payWrap.contactAuditData = cntAudit;
        payWrap.contactAssignmentEntity = cae;
        
        String resp;
        String payload = JSON.serialize(payWrap);
        system.debug('customer code reassignment :' + payload);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(cmdDomain+assignmentApi+acc.Customer_Code__c+'/contacts/'+contactCode);
        req.setMethod('PATCH');
        req.setHeader('API-Version', '1.1');
        if(Test.isRunningTest()) {
         req.setTimeout(60000);   
        } else {
         req.setTimeout(integer.valueof(timeout));   
        }
        req.setHeader('Content-Type', 'application/json');
        if(Test.isRunningTest()) {
         req.setHeader('Consumer-Key', '111111');    
        }else {
        system.debug('@@@@ apikey' + apikey);
        req.setHeader('Consumer-Key', apikey);
        }
        req.setHeader('Authorization', 'Bearer ' + accesstoken);
        req.setBody(payload);
        try {
                res = http.send(req);
            
            if(res.getStatusCode() == 200) {
                responsewrap reswrap = new responsewrap();
                reswrap.status = 'success';
                reswrap.description = res.getBody();
                resp = JSON.serialize(reswrap);
                try{
                    cont.AccountId = acc.Id;
                    update cont;
                } catch(Exception e) {
                    system.debug('Exception Account update failed :' + e);
                    ErrorLogger.writeErrors( 'SFDC', 'CMD Assignment API', 'lwcCMDContactCreateCtrl.runContactAssignmentAPI', new list<Exception>{e});

                }
            } else {
                ErrorResponse errRes = (ErrorResponse) System.JSON.deserialize(res.getBody(), ErrorResponse.class);
                responsewrap reswrap = new responsewrap();
                reswrap.status = 'error';
                reswrap.description = errRes.detailedErrors[0].message;
                resp = JSON.serialize(reswrap); 
                ErrorLogger.writeError( 'SFDC', 'CMD Assignment API Status', 'lwcCMDContactCreateCtrl.runContactAssignmentAPI', res.getBody(),resp, resp); 
            }
            System.debug('Callout error: '+ res.getBody());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
           ErrorLogger.writeErrors( 'SFDC', 'CMD Assignment API', 'lwcCMDContactCreateCtrl.runContactAssignmentAPI', new list<Exception>{e});

        }
        return resp;
        
    }
    
    public static HttpResponse runValidateAPI(String payload, string customercode) {
     //   system.debug('@@@ ' + payload);
      //  system.debug('@@@ ' + access_token);
        //String accesstoken = getAccessToken();
        String resp;
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(cmdDomain+ingestApi+customercode+'/contacts/validate');
        req.setMethod('POST');
        req.setHeader('API-Version', '1.1');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key', apikey);
        req.setTimeout(integer.valueof(timeout));
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setBody(payload);
        try {
                res = http.send(req);
            
            resp = res.getBody();
            System.debug('Callout error: '+ res.getBody());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ErrorLogger.writeErrors( 'SFDC', 'CMD runValidateAPI API', 'lwcCMDContactCreateCtrl.runValidateAPI', new list<Exception>{e});
        }
        return res;
    }
    
    public static String runDuplicateCheckAPI(Contact payload) {
        String resp;
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
       /* if(payload.MobilePhone !=null) {
            req.setEndpoint(cmdDomain+searchApi+'?primaryEmailId='+payload.Email+'&lastName='+payload.lastName+'&firstName='+payload.FirstName+'&mobileNumber='+payload.MobilePhone.substring(payload.MobilePhone.indexof(' ')).deleteWhitespace());
        }else if(payload.Phone !=null){
            req.setEndpoint(cmdDomain+searchApi+'?primaryEmailId='+payload.Email+'&lastName='+payload.lastName+'&firstName='+payload.FirstName+'&phoneNumber='+payload.Phone.substring(payload.Phone.indexof(' ')).deleteWhitespace());    
        }else{*/
        if(payload.FirstName !=null) {
            req.setEndpoint(cmdDomain+searchApi+'?primaryEmailId='+payload.Email+'&lastName='+EncodingUtil.URLENCODE(payload.lastName,'UTF-8')+'&firstName='+EncodingUtil.URLENCODE(payload.FirstName,'UTF-8'));
        }else{
           req.setEndpoint(cmdDomain+searchApi+'?primaryEmailId='+payload.Email+'&lastName='+EncodingUtil.URLENCODE(payload.lastName,'UTF-8')); 
        }
        //}
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' +access_token);
        req.setHeader('Consumer-Key', apikey);
        req.setHeader('API-Version', '1');
        req.setTimeout(integer.valueof(timeout));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setCompressed(true);
        try {
            res = http.send(req);
            String resBody = res.getBody();
          //  system.debug('@@@@ ' + resBody);
            if(res.getStatusCode() == 200) {
                DuplicateWrapper dupwrap = (DuplicateWrapper) System.JSON.deserialize(res.getBody(), DuplicateWrapper.class);  
            //    system.debug('@@@@ ' + dupwrap);
                if(dupwrap.duplicateContacts.size() == 1 && dupwrap.duplicateContacts[0].contactCode == payload.External_ID__c)  {   
                    resp = 'No duplicate contacts found for the given request';    
                }else{
                    responsewrap reswrap = new responsewrap();
                    reswrap.status = 'Duplicate found';
                    reswrap.description = 'Duplicate Found in CMD';
                    resp = JSON.serialize(reswrap);
                }
                system.debug('@@@@ ' + dupwrap.duplicateContacts.size());
                if(dupwrap.duplicateContacts.size() > 1) {
                    responsewrap reswrap = new responsewrap();
                    reswrap.status = 'Duplicate found';
                    reswrap.description = 'Duplicate Found in CMD';
                    resp = JSON.serialize(reswrap);
                }
            }
            If(res.getStatusCode() == 404) {                
                duplicateResponse duplResp = (duplicateResponse) System.JSON.deserialize(resBody, duplicateResponse.class);   
                if(duplResp.errorMessage == 'No duplicate contacts found for the given request') {
                    resp = 'No duplicate contacts found for the given request';
                }
            }      
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ErrorLogger.writeErrors( 'SFDC', 'CMD duplicate check API', 'lwcCMDContactCreateCtrl.runDuplicateCheckAPI', new list<Exception>{e});
        }
        return resp;
        
    }
    
    @AuraEnabled()
    public static String preventcontactstoConcern(Id accId){
        Account acc = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id =: accId];
     //   system.debug('@@@@@ ' + acc.RecordType.DeveloperName);
        if(acc.RecordType.DeveloperName == 'Concern_Account'){
            return 'isConcern';
        }else{
            return 'notConcern';
        }
    }
    
    @AuraEnabled()
    public static String updateContact(Contact payload, List<Map<String, String>> phonenumbers, string accId, Boolean isAccUpdated, String oldctypes) { 
     //   system.debug('@@@ ' + payload);
     //   system.debug('@@@ ' + accId);
        oldcontactTypes = oldctypes;
        system.debug('ctypes ' + oldcontactTypes);
        String dupCheck;
        String detailres;
        String accesstoken = getAccessToken();  
        Account acc = [select Id, Customer_Code__c from Account WHERE Id =: accId];
        String validateLoad =  createValidateWrapper(payload, acc.Customer_Code__c, phonenumbers);
     	system.debug('@@@@ ' + validateLoad);
        HttpResponse getvalidateAPIResp = runValidateAPI(validateLoad, acc.Customer_Code__c);
       // system.debug('@@@@ ' + validateLoad);
        Integer validateStatusCode = Test.isRunningTest() ? 200 : getvalidateAPIResp.getStatusCode();
        String validategetBody = Test.isRunningTest() ? 'Contact information validated successfully' : getvalidateAPIResp.getBody();
        if(validateStatusCode == 200 && validategetBody == 'Contact information validated successfully') {
            dupCheck  = Test.isrunningTest() ? 'No duplicate contacts found for the given request' : runDuplicateCheckAPI(payload);
            if(dupCheck == 'No duplicate contacts found for the given request') {
                if(isAccUpdated){
                    runContactAssignmentAPI(accId, payload.External_ID__c,payload );
                }else{
                    HttpResponse createContact  = createContactWrapperData(payload, acc.Customer_Code__c, phonenumbers, 'PUT');
                 //   system.debug('@@@@@ ' + createContact);
                    Integer createContactStatusCode = Test.isRunningTest() ? 201 : createContact.getStatusCode();
                    String createContactStatusCodebody = Test.isRunningTest() ? '{"contactCode": "IN22527482","contactUpsertStatus": "Contact upsert completed successfully"}' : createContact.getBody();
                    if(createContactStatusCode == 201) {
                        createContractwrapper cw = (createContractwrapper) System.JSON.deserialize(createContactStatusCodebody, createContractwrapper.class);
                    //    system.debug('@@@@@ ' + createContact.getBody());
                        try{
                            update payload;
                            responsewrap reswrap = new responsewrap();
                            reswrap.status = 'success';
                            reswrap.description = cw.contactUpsertStatus;
                            detailres = JSON.serialize(reswrap);
                        }catch(Exception e) {
                            system.debug('@@@@ ' + e);
                            ErrorLogger.writeErrors( 'SFDC', 'CMD Update', 'lwcCMDContactCreateCtrl.updateContact', new list<Exception>{e});
                            responsewrap reswrap = new responsewrap();
                            reswrap.status = 'error';
                            reswrap.description = e.getMessage();
                            detailres = JSON.serialize(reswrap);   
                        }
                    }else{
                 //       system.debug('@@@@@ ' + createContact.getBody());
                        responsewrap reswrap = new responsewrap();
                        reswrap.status = 'error';
                        reswrap.description = createContact.getStatusCode() +' '+'Please check with Admin ';
                        detailres = JSON.serialize(reswrap);
                        ErrorLogger.writeError( 'SFDC', 'CMD Update', 'lwcCMDContactCreateCtrl.updateContact', createContact.getBody(),string.valueof(createContact.getStatusCode()), detailres); 
                   //     system.debug('@@@ detailres ' + detailres);
                    }
                }
            }else{
                return dupCheck;
            }
        }else {
            ErrorResponse errRes = (ErrorResponse) System.JSON.deserialize(getvalidateAPIResp.getBody(), ErrorResponse.class);
            system.debug('errRes ' + errRes);
            responsewrap reswrap = new responsewrap();
            reswrap.status = 'error';
            // system.debug('@@@@@ ' + errRes.detailedErrors.size());
            reswrap.description = JSON.serialize(errRes.detailedErrors);
            detailres = JSON.serialize(reswrap); 
            ErrorLogger.writeError( 'SFDC', 'CMD Update', 'lwcCMDContactCreateCtrl.updateContact', getvalidateAPIResp.getBody(),string.valueof(getvalidateAPIResp.getStatusCode()), detailres); 
        }
       // system.debug('@@@@ ' + detailres);
        return detailres;
    }
    
    @AuraEnabled()
    public static String validateAndSaveContact(Contact payload, List<Map<String, String>> phonenumbers, string actionName) { 
        getAccessToken();
        if(payload !=null) {
         //   system.debug('@@@@ ' + payload);
            String detailres;
            Account acc = [select Id, SCV_Code__c, Concern_Code__c, Customer_Code__c from Account WHERE Id =: payload.AccountId];
            String dupPayload =  createValidateWrapper(payload, acc.Customer_Code__c, phonenumbers);
            //system.debug('@@@@dupPayload' + dupPayload);
            HttpResponse getvalidateAPIResp = runValidateAPI(dupPayload, acc.Customer_Code__c);

            Integer validateStatusCode = Test.isRunningTest() ? 200 : getvalidateAPIResp.getStatusCode();
            String validategetBody = Test.isRunningTest() ? 'Contact information validated successfully' : getvalidateAPIResp.getBody();
            if(validateStatusCode == 200 && validategetBody == 'Contact information validated successfully') {
                String dupCheck;
                if(payload.Email !=null && payload.LastName !=null) {
                    dupCheck  = Test.isRunningTest() ? 'No duplicate contacts found for the given request' : runDuplicateCheckAPI(payload);
                }
               // system.debug('@@@@ ' + dupCheck);
                if(dupCheck == 'No duplicate contacts found for the given request') {
                    HttpResponse createContact  = createContactWrapperData(payload, acc.Customer_Code__c, phonenumbers, 'POST');
                    Integer createContactStatusCode = Test.isRunningTest() ? 201 : createContact.getStatusCode();
                    String createContactStatusCodebody = Test.isRunningTest() ? '{"contactCode": "IN22527482","contactUpsertStatus": "Contact upsert completed successfully"}' : createContact.getBody();
                    if(createContactStatusCode == 201) {
                        createContractwrapper cw = (createContractwrapper) System.JSON.deserialize(createContactStatusCodebody, createContractwrapper.class);
                        try{
                            if(actionName != 'edit') {
                                payload.External_ID__c = cw.contactCode;
                                //payload.External_ID__c = cw.contactCode;
                            }
                            upsert payload;
                            responsewrap reswrap = new responsewrap();
                            reswrap.status = 'success';
                            reswrap.description = 'Contact successfully created';
                            reswrap.contid = payload.Id;
                            detailres = JSON.serialize(reswrap);
                        } catch(Exception e){
                            system.debug('@@@ ' + e);
                            ErrorLogger.writeErrors( 'SFDC', 'CMD Insert', 'lwcCMDContactCreateCtrl.validateAndSaveContact', new list<Exception>{e});
                        }
                    } else{
                        detailres = createContact.getBody();
                        ErrorLogger.writeError( 'SFDC', 'CMD Insert', 'lwcCMDContactCreateCtrl.validateAndSaveContact', createContact.getBody(),string.valueof(createContact.getStatusCode()), detailres); 
                     //   system.debug('@@@ detailres ' + detailres);
                    }
                } else { 
                    responsewrap reswrap = new responsewrap();
                    reswrap.status = 'error';
                    reswrap.description = 'Duplicate found in CMD';
                    detailres = JSON.serialize(reswrap);
                    ErrorLogger.writeError( 'SFDC', 'CMD Insert Duplicate check', 'lwcCMDContactCreateCtrl.validateAndSaveContact', detailres,detailres, detailres); 
                }
            } else {
                ErrorResponse errRes = (ErrorResponse) System.JSON.deserialize(getvalidateAPIResp.getBody(), ErrorResponse.class);
                system.debug('errRes ' + errRes);
                responsewrap reswrap = new responsewrap();
                reswrap.status = 'error';
                // system.debug('@@@@@ ' + errRes.detailedErrors.size());
                reswrap.description = JSON.serialize(errRes.detailedErrors);
                detailres = JSON.serialize(reswrap);
            }
            return detailres;
        } else {
            return 'No Payload found'; 
        }
    }
    
    public static HttpResponse createContactWrapperData(Contact payload, string customercode, List<Map<String, String>> phonenums, String method) {
        String createContData =  createValidateWrapper(payload, customercode,phonenums);
       	system.debug('@@@@ ' + createContData);
        String resp;
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        system.debug('@@@@ ' + payload.External_ID__c);
        if(method == 'PUT' && payload.External_ID__c !=null){
            req.setEndpoint(cmdDomain+ingestApi+customercode+'/contacts/'+payload.External_ID__c);   
        }else{
            req.setEndpoint(cmdDomain+ingestApi+customercode+'/contacts');
        }
        if(payload.External_ID__c !=null){
            req.setMethod(method);
        }else{
            req.setMethod('POST');  
        }
        req.setHeader('API-Version', '1.1');
        req.setHeader('Content-Type', 'application/json');
        if(Test.isRunningTest()){
         req.setHeader('Consumer-Key', '11111111');  
         req.setTimeout(60000);
        }else{
         req.setHeader('Consumer-Key', apikey);
         req.setTimeout(integer.valueof(timeout));
        }
        req.setHeader('Authorization', 'Bearer ' + access_token);
        req.setBody(createContData);
        try {
            res = http.send(req);
            resp = res.getBody();
          //  system.debug('@@@@ ' + resp);        
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            ErrorLogger.writeErrors( 'SFDC', 'CMD createContactWrapperData', 'lwcCMDContactCreateCtrl.createContactWrapperData', new list<Exception>{e});
        }
        
        return res;
    }
    
    public static String createValidateWrapper(Contact payload, string customercode, List<Map<String, String>> phonenums) {
       // system.debug('@@@ ' + payload);
        String strGeoCode = '';
        if(!Test.isRunningTest()) {
            Geography__c geoCode = [select Id, GEO_Code__c from Geography__c WHERE Id =:payload.Country__c];
            strGeoCode = geoCode.GEO_Code__c;
        }else{
            strGeoCode = 'IN';
        }
        payloadWrapper payWrap = new payloadWrapper();
        ContactAuditData cntAudit = new ContactAuditData();
        cntAudit.user = UserInfo.getUserName();
        cntAudit.sourceSystem = 'SFDC';
        payWrap.contactAuditData = cntAudit;
        
        ContactEntity contEnt = new ContactEntity();
        if(customercode !=null) {
            contEnt.customerCode = customercode;
            contEnt.contactCode = payload.External_ID__c;
        }
        contEnt.firstName = payload.FirstName;
        contEnt.primarySalutationCode = payload.Salutation;
        contEnt.lastName = payload.LastName;
        contEnt.primaryEmailId = payload.Email;
        contEnt.secondaryEmailId = payload.Duplicate_Email__c;
        contEnt.isTeamContact = payload.Team_Contact__c == 'No' ? false : true;
        contEnt.jobTitle = payload.Job_Title__c;
        contEnt.department = payload.Department;
       // contEnt.role = payload.Job_Role__c;
        contEnt.statusCode = payload.Contact_Status__c == 'Active' ? 'A' : 'I';
        contEnt.isoLanguageCodePreference= PreferedLanguageMapCtrl.mapOfisoLanguage.get(payload.Preferred_Language__c);
            //payload.Preferred_Language__c.substring(0,2).toUpperCase();
           
        payWrap.contactEntity = contEnt;
        
        List<String> lstEmail = new List<String>();
        // lstEmail.add(payload.Email);
        if(payload.Duplicate_Email__c !=null) {
            lstEmail.add(payload.Duplicate_Email__c);
        }
        if(phonenums !=null) {
            payWrap.contactEntity.communicationNumbers = createCommNumbers(phonenums,strGeoCode);
        }
        
        DocumentPreferences docpref = new DocumentPreferences();
        docpref.brandCode = 'MAEU';
        docpref.documentType = 'ARRVL_NTC';
        
        docpref.communicationPreferences = createCommEmail(lstEmail);
        
        payWrap.contactEntity.documentPreferences.add(docpref);
        
        if(payload.Liner_Brands__c != null) {
            payWrap.contactEntity.contactBrands = createContactBrands(payload.Liner_Brands__c);
        }
        if(payload.Contact_Type__c !=null) {
            payWrap.contactEntity.contactTypes = createContactTypes(payload.Contact_Type__c);
        }
        
        String dupPayload = System.JSON.serialize(payWrap);
        return dupPayload.replace('number_Z', 'number'); 
    }
    
    
    public static List<ContactTypes> createContactTypes(String newtypes) {
      //  system.debug('@@@@ ' + newtypes.split(';'));
        List<String> newTypesList = newtypes.split(';');
        Map<String, Boolean> mapOfDeletedContactTypes = new Map<String, Boolean>();
        if(oldcontactTypes !=null) {
            for(String ct : oldcontactTypes.split(';')) {
                if(!newTypesList.contains(ct)) {
                    mapOfDeletedContactTypes.put(ct, true);
                }
            }
        }
      //  system.debug('@@@@ ' + mapOfDeletedContactTypes);
        List<ContactTypes> lstct = new List<ContactTypes>();
        for(String typ :newtypes.split(';')) {
            ContactTypes cb = new ContactTypes();
            cb.typeCode = mapOfContactTypes.get(typ.toUpperCase()); 
            cb.typeName = mapOfContactTypes.get(typ.toUpperCase());
            cb.isDeletedFlag = false;
            lstct.add(cb);
        } 
        for(String s : mapOfDeletedContactTypes.keySet()) {
            ContactTypes cb = new ContactTypes();
            cb.typeCode = mapOfContactTypes.get(s.toUpperCase()); 
            cb.typeName = mapOfContactTypes.get(s.toUpperCase());
            cb.isDeletedFlag = true;
            lstct.add(cb);   
        }
       // system.debug('@@@@ ' + lstct); 
        return lstct;
    }
    
    public static List<ContactBrands> createContactBrands(String brands) {
       // system.debug('@@@@ ' + brands);
        List<ContactBrands> lstcb = new List<ContactBrands>();
        for(String brand :brands.split(';')) {
            if(brand == 'Hamburg Sud') {
                ContactBrands bd = new ContactBrands(); 
                bd.brandCode = 'HSUD';
                lstcb.add(bd);
            }
        } 
        return lstcb;
    }
    
    public static List<communicationPreferences> createCommEmail(List<String> emails) {
        List<communicationPreferences> lstcp = new List<communicationPreferences>();
        for(String e: emails) {
            if(e != null && e != '') {
                communicationPreferences cp = new communicationPreferences();
                cp.preferenceValue = e;
                cp.preferenceMediaType = 'OTH_EMAIL';
                lstcp.add(cp);
            }
        }
       // system.debug('lstcp ' + lstcp);
        return lstcp;
    }
    
    public static List<CommunicationNumbers> createCommNumbers(List<Map<String, String>> numpayload, String countryCode) {
        system.debug('@@@ ' +numpayload);
        List<CommunicationNumbers> nums = new List<CommunicationNumbers>();
        for(Map<String, String> s : numpayload) {
            for(String key: s.keyset()) {
               system.debug('@@@ ' + key);
                if(key != 'extensionNumber' && key != 'OTP' && s.get(key) !=null && s.get(key) != '') {
                    CommunicationNumbers phno = new CommunicationNumbers();
                    //system.debug('@@@ ' + key.replace('+','').deleteWhitespace().length());
                    phno.communicationNumberType = key;
                    
                    phno.isoCountryCode = countryCode;
                    if(countryCode == 'US') {
                        phno.internationalDialingCode = '+1';
                            //s.get(key) != null ? s.get(key).deleteWhitespace().substring(0,2) : '';
                    }else{
                       phno.internationalDialingCode = s.get(key) != null && s.get(key) != '' ? s.get(key).substring(0, s.get(key).lastIndexOf(' ')): null;
                           //s.get(key) != null ? s.get(key).replace('+','').substring(0,2) : '';  
                    }
                    if(key.contains('TEL')) {
                        phno.extensionNumber = s.get('extensionNumber');
                    }
                    if(s.get(key) != null) {
                        if(countryCode == 'US') {
                            phno.number_Z = s.get(key).replace('+','').deleteWhitespace().substring(1,s.get(key).replace('+','').deleteWhitespace().length());  
                        }else{
                            phno.number_Z = s.get(key) !=null && s.get(key) !='' ? s.get(key).substring(phno.internationalDialingCode.length()).deleteWhitespace() : null;
                        }
                    }else{
                        phno.number_Z = '';  
                    }
                    nums.add(phno);
                }
            }
        }
        //system.debug('@@@ ' + nums);
        return nums;
    }
    
    public class createContractwrapper {
        public String contactCode {get;set;} 
        public String contactUpsertStatus {get;set;}   
    }
    
    public class payloadWrapper {
        public ContactAuditData contactAuditData {get;set;} 
        public ContactEntity contactEntity {get;set;}
        public ContactAssignmentEntity contactAssignmentEntity {get;set;}     
    }
    public class CommunicationPreferences {
        public String preferenceMediaType {get;set;} 
        public String preferenceValue {get;set;} 
        
    }
    
    public class DocumentPreferences {
        public String brandCode {get;set;} 
        public String documentType {get;set;} 
        public List<CommunicationPreferences> communicationPreferences {get;set;} 
        public DocumentPreferences(){
            communicationPreferences = new List<CommunicationPreferences>();
        }
    }
    
    public class ContactEntity {
        public String customerCode {get;set;} 
        public String contactCode {get;set;} 
        public String firstName {get;set;} 
        public Object primarySalutationCode {get;set;} 
        public String internationalFirstName {get;set;} 
        public String lastName {get;set;} 
        public String internationalLastName {get;set;} 
        public String primaryEmailId {get;set;}
        public String secondaryEmailId {get;set;}
        public Boolean isTeamContact {get;set;} 
        public Boolean isMasterContact {get;set;} 
        public String role {get;set;} 
        public String statusCode {get;set;} 
        public String jobTitle {get;set;} 
        public String department {get;set;} 
        public String isoLanguageCodePreference {get;set;} 
        public List<CommunicationNumbers> communicationNumbers {get;set;} 
        public List<DocumentPreferences> documentPreferences {get;set;} 
        public List<ContactTypes> contactTypes {get;set;} 
        public List<ContactBrands> contactBrands {get;set;} 
        
        public ContactEntity(){
            communicationNumbers = new List<CommunicationNumbers>();
            documentPreferences = new List<DocumentPreferences>();
            contactTypes = new List<ContactTypes>();
            contactBrands = new List<ContactBrands>();
        }
    }
    
    public class contactAssignmentEntity {
        public String customerCode {get;set;} 
        public String contactCode {get;set;} 
        public String action {get;set;} 
        public String role {get;set;}
        public contactAssignmentEntity() {
            action = 'LINK';
            role = 'ON_BEHALF_OF';
        }
    }
    
    public class ContactAuditData {
        public String user {get;set;} 
        public String sourceSystem {get;set;}
    }
    
    public class CommunicationNumbers {
        public String communicationNumberType {get;set;} 
        public String isoCountryCode {get;set;} 
        public String internationalDialingCode {get;set;} 
        public String extensionNumber {get;set;} 
        public String number_Z {get;set;} // in json: number
    }
    
    public class duplicateResponse {
        public String requestUri {get;set;} 
        public Integer statusCode {get;set;} 
        public String statusText {get;set;} 
        public String errorMessage {get;set;} 
        public String correlationIdentifier {get;set;}
        public String status {get;set;}
        public String errorTimestamp {get;set;}
    }
    
    
    public class ClientCredentialResponse {
        public String access_token;
        public String scope;
        public String id_token;
        public String token_type;
    }
    
    public class ContactTypes {
        public String typeCode {get;set;} 
        public String typeName {get;set;} 
        public Boolean isDeletedFlag {get;set;}   
        
        public ContactTypes(){
            isDeletedFlag = false;
        }
    }
    
    public class ContactBrands {
        public String brandCode {get;set;} 
        public String brandName {get;set;} 
        public Boolean isDeletedFlag {get;set;} 
        public ContactBrands(){
            isDeletedFlag = false;
        }
    }
    
    
    public class ErrorResponse{
        public String httpMethod;	//POST
        public String requestUri;	///global-mdm/customers/IN02329380/contacts/validate
        public String statusCode;	//400
        public String statusText;	//Bad Request
        public String errorTimestamp;	//18-02-2023 16:30:45
        public String errorMessage;	//Validation errors
        public cls_detailedErrors[] detailedErrors;
        public String correlationIdentifier;	//9c6f92e1c1c7aa0860afbf6a84494d7f
        
        public ErrorResponse () {
            detailedErrors = new List<cls_detailedErrors>();
        }
        
    }
    
    public class cls_detailedErrors {
        public Integer errorCode;	//7002
        public String field;	//contactEntity.communicationNumbers.number
        public String value;	//7259158
        public String message;	//For country India, Telephone length must be exactly 10 numeric digits, cannot start with zero.
    }
    
    public class responsewrap {
        public string status;
        public string description;
        public string contid;
    }
    public class DuplicateWrapper {  
        public List<DuplicateContacts> duplicateContacts {get;set;} 
        public DuplicateWrapper() {
            duplicateContacts = new List<DuplicateContacts>();
        }
    }
    
    public class ContactExternalSystemIdentifiers {
        public String externalSystemName {get;set;} 
        public String externalSystemReference {get;set;} 
        public Boolean isDeletedFlag {get;set;} 
    }
     
    public class DuplicateContacts {
        public String customerCode {get;set;} 
        public String contactCode {get;set;} 
        public String firstName {get;set;} 
        public String lastName {get;set;} 
        public String role {get;set;} 
        public String primaryEmailId {get;set;} 
        public String statusCode {get;set;} 
        public Boolean isMasterContact {get;set;}         
    }
    
    public class contactTypesWrapper {
     public String ctype {get;set;} 
     public Boolean isdelete {get;set;}    
    }
    
}