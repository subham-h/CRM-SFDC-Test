/** 
* @description 
* Author   : Partha
* Purpose  : Class to hold Custom Email-to-case logic. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-7892     05-Sep-2023 Nayana@maersk.com       Created for handling Custom Email-to-case logic.
* 2.0      SC-9381     15-Dec-2023 Nayana@maersk.com       Added Remove_header_based_threading__c field and logic related to the field
* 3.0      SC-8995     16-Jan-2023 Shahanawa@maersk.com    Updated the code for Screenshots of emails in Case Management missing
* 4.0      SC-9291     19-Mar-2024 Shahanawaz@maersk.com   Update Auto Handshake Email Address SCM KC BA
* 5.0      SC-9915     25-Mar-2024 Shahanawaz@maersk.com   Enable Votiro scan for custom Email handler
* 6.0      SC-10204    02-Jul-2024 Shahanawaz@maersk.com   Auto Populate From Address (Multiple CM BA)
*/
global class Email2CaseCustomHandler implements Messaging.InboundEmailHandler {
    public static Integer count_Duplicate_attachments_Banned = 0;
    public static Integer count_Banned_spam_attachments = 0;
    public static set<string> duplicateChecksumSet = new set<string>();
    public static set<string> spamChecksumSet = new set<string>();
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 
        Case mycase;
        List<Custom_Email_Service__c> eservicelist = new List<Custom_Email_Service__c>();
        try{        
            // 1. get the email service setting and proceed only if it exists        
            eservicelist = [select BA_Address__c,Origin__c,Queue_Id__c,Service_Address__c,Active__c,Record_type_id__c,Remove_header_based_threading__c, Skip_Auto_Handshake__c, Votiro_Scan_Enabled__c from Custom_Email_Service__c
                            where Service_Address__c =:envelope.toAddress and Active__c = true limit 1];
            if(eservicelist.isEmpty()) {
                ErrorLogger.writeError( 'SFDC', 'Case', 'Email2CaseCustomHandler -' + email.messageid, 'custom e2c', 'Wrong Email service address','Email service address does not exist or not active '+ envelope.toAddress);
                return result;
            }
            //1. ignore undelivered email
            if(email.subject != null){
                list<Undelivered_Email_Config__mdt> udeList =Undelivered_Email_Config__mdt.getAll().values();                
                for(Undelivered_Email_Config__mdt ude:udeList){                    
                    if(email.subject.containsignorecase(ude.masterlabel)){                        
                        if(ude.From_Address__c =='*'  || ude.From_Address__c.containsignorecase(email.fromAddress)){                                                       
                            createUndeliveredlog(email,eservicelist[0]);
                            return result;
                        }                            
                    }                    
                    
                }
                
            }
            // 2. Search or create the case in SF                        
            mycase= searchCaseFromThreadId( email,eservicelist[0]);
            // 3. Extract, filter and insert attachment in SF
            Map<String, ContentVersion> attachments = insertAttachments(email,mycase, eservicelist[0]);
            // 4. Creation of the Email MEssage associated with the case
            EmailMessage emailMessage = createEmailMessage(email, attachments, mycase, eservicelist[0]);
            // 5. Associate the images to the email message
            if(emailMessage != null){
                createDocumentLinks(attachments.values(), emailMessage.Id);
            }
        }catch(exception ex){
            if(ex.getMessage().containsIgnoreCase(Label.Row_Lock_error)){
                throw new MyException(ex.getMessage());
            }
            if(mycase == null){
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'Email2CaseCustomHandler -' + email.messageid +' BA-'+ eservicelist[0].BA_Address__c, new list<Exception>{ex});
            }else{
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'Email2CaseCustomHandler -' + email.messageid +' '+ mycase.id, new list<Exception>{ex});
            }
        }    
        return result;
    }   
    
    //Method to search existing case, if not present create new case
    private static Case searchCaseFromThreadId( Messaging.InboundEmail email,Custom_Email_Service__c eservice) {
        system.debug(email.headers);
        // 1. If the given Thread Id is specified
        Id caseId = EmailMessages.getRecordIdFromEmail(email.subject, email.plainTextBody, email.htmlBody);
        // If we haven't found the Case ID, try finding it using headers.
        if (caseId == null && !eservice.Remove_header_based_threading__c) {
            caseId = Cases.getCaseIdFromEmailHeaders(email.headers);
            list<case> caselist = [select id,casenumber, subject,thread_topic__c from case where id = : caseId];
            
            if(email.subject != null && !caselist.isEmpty()){
                if(!email.subject.containsIgnoreCase(caselist[0].casenumber)){
                    if(!string.isBlank(caselist[0].thread_topic__c)){
                        if(!email.subject.replaceAll( '\\s+', ' ').endsWithIgnoreCase(caselist[0].thread_topic__c)){ 
                            caseId = null;                        
                        }
                    }                    
                }
            }
        }
        if(caseId != null){
            return new case(id = caseId);           
        }
        // 4. If not found, we will create a new case for this
        
        Case newcase = new Case(
            Status='New',
            Subject=email.subject,
            SuppliedEmail=email.fromAddress, 
            SuppliedName=email.fromName,
            origin=eservice.Origin__c,
            BA_From_Address__c = eservice.BA_Address__c //SC-10204
        );
        try{
            newcase.Description= (!string.isBlank(email.plainTextBody) && email.plainTextBody.length() >= 31000) ? email.plainTextBody.substring(0, 31000) : email.plainTextBody; 
            if(string.isBlank(newcase.Description)){
                string strhtmlbody =(!string.isBlank(email.htmlBody)) ? email.htmlBody.replaceAll('<[^>]*>', '') : '';
                newcase.Description= (!string.isBlank(strhtmlbody) && strhtmlbody.length() >= 31000) ? strhtmlbody.substring(0, 31000) : strhtmlbody;
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            newcase.Description= email.plainTextBody;
        }
        if(eservice.Record_type_id__c!= null){
            newcase.recordTypeId = eservice.Record_type_id__c;
        }
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(eservice.Queue_Id__c != null){
            newcase.ownerid=eservice.Queue_Id__c;
        }else{
            dmlOpts.AssignmentRuleHeader.useDefaultRule= true; // Enable assignment rule to run when owner is not set
        }
        //SC-9291
        if(!eservice.Skip_Auto_Handshake__c){
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
        }
        dmlOpts.allowFieldTruncation = true;
        newcase.setOptions(dmlOpts);
        insert newcase;
        return newcase;
    }
    
    private static Map<String, ContentVersion> insertAttachments(Messaging.InboundEmail email,case mycase, Custom_Email_Service__c eservice) {        
        try{
            Map<String, ContentVersion> allAttachments = new Map<String, ContentVersion>();
            Map<String, ContentVersion> newAttachments = new Map<String, ContentVersion>();
            Integer count = 0;
            map<string,string> checksummap = new map<string,string>();
            //SC-8995
            Map<String, List<String>> checksumToCidListMap = new Map<String, List<String>>();
            Map<String, ContentVersion> checksumToExistingConVerMap = new Map<String, ContentVersion>();
            
            if (email.binaryAttachments != null) {
                for (Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments) {
                    //if (att.mimeTypeSubType.contains('image') && (att.body.size() < integer.valueof(label.attBodySize))) continue;//Tameem: ignore all images below 40kb size
                    
                    String cid = 'binary-content-id-' + count++;
                    String checksum = '';
                    if (att.headers != null) {
                        for (Messaging.InboundEmail.Header header : att.headers){
                            if (header.name == 'Content-ID') {
                                cid = header.value;
                                if (cid != null) cid = cid.replace('<', '').replace('>', '');
                            }
                            //SC-9915
                            if(eservice.Votiro_Scan_Enabled__c && header.name == 'X-Votiro-Attachment-Id'){
                                checksum = header.value;
                            }
                        }   
                    }
                    //SC-9915
                    if(String.isBlank(checksum) && !eservice.Votiro_Scan_Enabled__c){
                        checksum = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', att.body));
                    }
                    // Insert only if it is not a duplicate checksum                    
                    if(!checksummap.containskey(checksum)){
                        newAttachments.put(cid, new ContentVersion(
                            Title = att.filename,
                            VersionData = att.body,
                            PathOnClient = att.filename,
                            Checksum__c = checksum //SC-9915
                        ));
                        checksummap.put(checksum,cid);
                        checksumToCidListMap.put(checksum, new List<String>{cid});
                    }
                    else if(checksummap.containskey(checksum)){
                        count_Duplicate_attachments_Banned = count_Duplicate_attachments_Banned+1;
                        duplicateChecksumSet.add(checksum);
                        checksumToCidListMap.get(checksum).add(cid);
                    }
                }
                //Remove bad checksum                   
                for(Checksum__c csm:[Select Id,Checksum_value__c,File_type__c from Checksum__c where Checksum_value__c IN :checksummap.keyset()]){
                    if(checksummap.containsKey(csm.Checksum_value__c)){
                        newAttachments.remove(checksummap.get(csm.Checksum_value__c));
                        checksummap.remove(csm.Checksum_value__c);
                        count_Banned_spam_attachments = count_Banned_spam_attachments+1;
                        spamChecksumSet.add(csm.Checksum_value__c);
                    }                       
                } 
            }
            if (email.textAttachments != null) {            
                for (Messaging.InboundEmail.TextAttachment att : email.textAttachments) {                   
                    String cid = 'text-content-id-' + count++;
                    Blob body = Blob.valueof(att.body);
                    String checksum = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', body));
                    // Insert only if it is not a duplicate checksum                    
                    if(!checksummap.containskey(checksum)){
                        newAttachments.put(cid, new ContentVersion(
                            Title = att.filename,
                            VersionData = body,
                            PathOnClient = att.filename 
                        ));
                        checksummap.put(checksum,cid);
                        if(checksumToCidListMap.isEmpty() || !checksumToCidListMap.containsKey(checksum)){
                            checksumToCidListMap.put(checksum, new List<String>{cid});
                        }
                        else{
                            checksumToCidListMap.get(checksum).add(cid);
                        }
                    }
                    else if(checksummap.containskey(checksum)){
                        count_Duplicate_attachments_Banned = count_Duplicate_attachments_Banned+1;
                        duplicateChecksumSet.add(checksum);
                        if(checksumToCidListMap.isEmpty() || !checksumToCidListMap.containsKey(checksum)){
                            checksumToCidListMap.put(checksum, new List<String>{cid});
                        }
                        else{
                            checksumToCidListMap.get(checksum).add(cid);
                        }
                    }
                }
                
            }
            //Attaching incoming email as html attachment when email body>131072 characters
            if(!string.isBlank(email.htmlBody) && email.htmlBody.length() >= integer.valueof(Label.EmailMessageLimit)){
                String cid = 'Salesforce_Clipped_Email_History' + count++;
                if(email.htmlBody.contains('charset=gb2312')){
                    email.htmlBody = email.htmlBody.replace('charset=gb2312', 'charset=utf-8'); 
                }
                Blob body = Blob.valueof(email.htmlBody);            
                newAttachments.put(cid, new ContentVersion(
                    Title ='Salesforce_Clipped_Email_History.html',
                    VersionData = body,
                    PathOnClient = 'Salesforce_Clipped_Email_History.html'
                ));
            }
            
            if(!newAttachments.isEmpty() || newAttachments!=null){
                set<string> cdset = new set<string>();
                for(contentdocumentlink cd : [Select Id,contentdocumentid From contentdocumentlink Where linkedentityid in (select id from emailmessage where parentid =:mycase.id) limit 5000]){
                    cdset.add(cd.contentdocumentid);
                }
                if(!cdset.isempty()){
                    for(contentversion cv : [select id, checksum, contentdocumentid, Checksum__c from contentversion where contentdocumentid =: cdset]){
                        if(!String.isBlank(cv.Checksum__c)){
                            checksumToExistingConVerMap.put(cv.Checksum__c, cv); //SC-9915
                        }
                    }
                }
                if(!checksumToExistingConVerMap.isEmpty()){
                    for(string checksumstr : checksummap.keySet()){
                        if(checksumToExistingConVerMap.keyset().contains(checksumstr)){
                            if(newAttachments.containsKey(checksummap.get(checksumstr))){
                                newAttachments.remove(checksummap.get(checksumstr));
                                count_Duplicate_attachments_Banned = count_Duplicate_attachments_Banned+1;
                                duplicateChecksumSet.add(checksumstr);
                            }
                        }
                    }
                }         
                Database.SaveResult[] results =database.insert(newAttachments.values(),false);
                //ErrorLogger.writeErrors('SFDC', 'case', 'Email2CaseCustomHandler insert attchment-' + email.messageid, results ); 
            }
            allAttachments.putAll(newAttachments);
            //SC-8995
            if(!checksumToCidListMap.isEmpty() && !checksumToExistingConVerMap.isEmpty()){
                for(String check : checksumToExistingConVerMap.keyset()){
                    if(checksumToCidListMap.containsKey(check)){
                        for(String cid : checksumToCidListMap.get(check)){
                            allAttachments.put(cid, checksumToExistingConVerMap.get(check));
                        }
                    }
                }
            }
            return allAttachments;          
        }catch(exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'Email2CaseCustomHandler insert attchment-' + email.messageid, new list<Exception>{ex});
        }
        return new Map<String, ContentVersion>();
    }
    
    private static void createDocumentLinks(List<ContentVersion> attachments, id emailMessageId) {
        // 1. Get the Version Ids in a set (for SOQL)
        
        Set<Id> versionIds = new Set<Id>();
        for (ContentVersion att : attachments) {
            versionIds.add(att.Id);
        }
        // 2. Get the Document Ids from the Version Ids
        Set<Id> documentIds = new Set<Id>();
        for (ContentVersion att : [SELECT Id, ContentDocumentId 
                                   FROM ContentVersion
                                   WHERE Id IN :versionIds]) {
                                       documentIds.add(att.ContentDocumentId);
                                   }
        // 3. Insert the document link now!!
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (Id docId : documentIds) {
            links.add(new ContentDocumentLink(
                ShareType = 'V',
                LinkedEntityId = emailMessageId,
                ContentDocumentId = docId,
                Visibility = 'AllUsers'
            ));
        }
        Database.SaveResult[] results =database.insert(links,false);
        ErrorLogger.writeErrors('SFDC', 'case', 'Email2CaseCustomHandler insert link-' +emailMessageId, results  ,links );
    }
    
    private static EmailMessage createEmailMessage(Messaging.InboundEmail email, Map<String, ContentVersion> attachments, Case mycase, Custom_Email_Service__c eservice) {
        // 1. Generate the headers as string
        String headersAsString = '';
        string duplicateChecksumStr ='';
        String toAddressesAsString = '';
        String ccAddressesAsString = '';
        String textBody ='';
        String htmlBody ='';
        string spamChecksumStr ='';
        try{
            if(email.headers != null){
                for (Messaging.InboundEmail.Header header : email.headers) {
                    headersAsString += header.name + ': ' + header.value + '\n';
                }
                if(headersAsString.length() >31600){
                    headersAsString = headersAsString.substring(0, 31600) ;
                }
            }
            // 2. Generate the addresses as string
            
            if(email.toAddresses!=null){
                for (String toAddress : email.toAddresses) {
                    toAddressesAsString += toAddress + '; ';
                }
            }
            if(email.ccAddresses!=null){
                for (String ccAddress : email.ccAddresses) {
                    ccAddressesAsString += ccAddress + '; ';
                }
            }
            // 3. Update the inline urls 
            textBody= (!string.isBlank(email.plainTextBody) && email.plainTextBody.length() >= integer.valueof(Label.EmailMessageLimit)) ? email.plainTextBody.substring(0, integer.valueof(Label.EmailMessageLimit)) : email.plainTextBody;
            htmlBody = (!string.isBlank(email.htmlBody) && email.htmlBody.length() >= integer.valueof((Label.EmailMessageLimit))) ? email.htmlBody.substring(0, integer.valueof(Label.EmailMessageLimit)) : email.htmlBody;
            for (String cid : attachments.keySet()) {
                // WARNING: puting the inline images in the email will include it AGAIN when the agent replies to it!
                String url = '/sfc/servlet.shepherd/version/download/'+attachments.get(cid).Id;
                textBody = !string.isBlank(email.plainTextBody) ? textBody.replace('cid:' + cid, url) : null;
                htmlBody = !string.isBlank(email.htmlBody) ? htmlBody.replace('cid:' + cid, url) : null;
                htmlBody = !string.isBlank(email.htmlBody) ? htmlBody.replace('charset=gb2312', 'charset=utf-8') : null;   
            }
            
            if(!duplicateChecksumSet.isEmpty()){
                duplicateChecksumStr = string.join(duplicateChecksumSet,';');
                duplicateChecksumStr = (duplicateChecksumStr.length() >= 255 ? duplicateChecksumStr.substring(0, 255) : duplicateChecksumStr);
            }
            
            if(!spamChecksumSet.isEmpty()){
                spamChecksumStr = string.join(spamChecksumSet,';');
                spamChecksumStr = (spamChecksumStr.length() >= 255 ? spamChecksumStr.substring(0, 255) : spamChecksumStr);
            }
        }catch(exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'E2CCustomHandler warning-' + email.messageid +' BA-'+ eservice.BA_Address__c, new list<Exception>{ex});
        }
        
        List<EmailMessage> emList = new List<EmailMessage>([Select Id, Incoming, Subject, FromAddress, ToAddress, TextBody, HtmlBody, CcAddress From EmailMessage Where ParentId =: mycase.Id Order by createddate DESC LIMIT 1]);
        if(!emList.isEmpty()){
            if(String.isBlank(emList[0].ToAddress)){
                emList[0].ToAddress = '';
            }
            if(String.isBlank(emList[0].CcAddress)){
                emList[0].CcAddress = '';
            }
            if(!emList[0].Incoming && !String.isBlank(email.subject) && email.subject.containsIgnoreCase(emList[0].Subject) && emList[0].FromAddress == email.fromAddress && toAddressesAsString.containsIgnoreCase(emList[0].ToAddress) && ccAddressesAsString.containsIgnoreCase(emList[0].CcAddress) && emList[0].TextBody == textBody){
                return null;
            }
        }
        
        // 4. Create the Email Message in database
        EmailMessage emailMessage = new EmailMessage(
            Incoming = true,
            MessageIdentifier = email.messageId,
            ParentId = mycase.Id,
            TextBody = textBody, 
            HtmlBody = htmlBody, 
            Headers = headersAsString, 
            Subject = email.subject, 
            FromName = email.fromName, 
            FromAddress = email.fromAddress, 
            ToAddress = toAddressesAsString, 
            CcAddress = ccAddressesAsString,
            Status = '0', // New 
            MessageDate = Datetime.now(),
            IsClientManaged = true, // need this for attachments
            //ClientThreadIdentifier = getClientThreadIdentifier(email.headers),
            Num_of_duplicate_attachments_banned__c = count_Duplicate_attachments_Banned,
            Num_of_spam_attachments_banned__c = count_Banned_spam_attachments,
            Duplicate_Checksum__c=duplicateChecksumStr,
            Spam_Checksum__c=spamChecksumStr
        );
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.allowFieldTruncation = true;
        emailMessage.setOptions(dmlOpts);
        insert emailMessage;
        return emailMessage;
    }
    
    private static void createUndeliveredlog(Messaging.InboundEmail email, Custom_Email_Service__c eservice) {
        // 1. Generate the headers as string
        String headersAsString = '';
        if(email.headers != null){
            for (Messaging.InboundEmail.Header header : email.headers) {
                headersAsString += header.name + ': ' + header.value + '\n';
            }
            if(headersAsString.length() >31600){
                headersAsString = headersAsString.substring(0, 31600) ;
            }
        }
        // 2. Generate the addresses as string
        String toAddressesAsString = '';
        String ccAddressesAsString = '';
        if(email.toAddresses!=null){
            for (String toAddress : email.toAddresses) {
                toAddressesAsString += toAddress + '; ';
            }
        }
        if(email.ccAddresses!=null){
            for (String ccAddress : email.ccAddresses) {
                ccAddressesAsString += ccAddress + '; ';
            }
        }
        // 3. Update the inline urls 
        String textBody = (!string.isBlank(email.plainTextBody) && email.plainTextBody.length() >= 32000 ? email.plainTextBody.substring(0, 32000) : email.plainTextBody);
        String htmlBody = (!string.isBlank(email.htmlBody) && email.htmlBody.length() >= 32000 ? email.htmlBody.substring(0, 32000) : email.htmlBody);
        
        undelivered_email_log__C elog = new undelivered_email_log__C(                   
            Message_Identifier__c = email.messageId,            
            Text_Body__c = textBody, 
            HTML_Body__c = htmlBody, 
            Headers__c = headersAsString, 
            Subject__c = email.subject, 
            From_Name__c = email.fromName, 
            From_Address__c = email.fromAddress, 
            ToAddress__c = toAddressesAsString, 
            CcAddress__c = ccAddressesAsString,
            origin__c = eservice.Origin__c
        );
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.allowFieldTruncation = true;
        elog.setOptions(dmlOpts);
        insert elog;
    }
    public class MyException extends Exception{        
    }
}