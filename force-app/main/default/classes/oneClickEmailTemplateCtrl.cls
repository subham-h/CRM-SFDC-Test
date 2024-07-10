/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-10740  21-May-2023   Seba                    Updated for handling email attachments and capturing email message for email sending purpose
* 2.0      SFSE-11312  15-June-2023  Seba                    Modified the code for updating Opportunity Offer Status field
* 3.0      SFSE-10847  16-June-2023  Seba                    Added code offer recall/send new offer
* 4.0      SFSE-10847  19-June-2023  Seba                    Modified code to consider the OLI structure change to Opportunity Product object
* 5.0      SFSE-11287  24-June-2023  Bharti                  Code to generate encrypted Url when clicks on I accept
* 6.0      SFSE-10740  26-June-2023  Seba                    Updated code to convert the VF email tempalte to pdf file. Updated file creation code to match the updated file structure
* 7.0      SFSE-11210  26-June-2023  Vinay                   Added the method shareOfferRecords.    
* 8.0      SFSE-11596  06-July-2023  Seba                    Modified for Email Template Edit       
* 9.0      SFSE-11627  07-July-2023  Bharti                  Added the code send an offer to cc recipients as well
* 10.0     SFSE-11632  11-July-2023  Bharti                  Added the code to add banner for CC recipients in an offer
* 11.0     SFSE-11596  14-July-2023  Seba                    Added code for the lastname fix and email attachments
* 12.0     SFSE-11804  17-July-2023  Seba                    Added code for bug fix
* 13.0     SFSE-11754  21-July-2023  Aditi                   Added code for T&C links 
* 14.0     SFSE-11804  24-July-2023  Seba                    Bug fix to make the Offer creation/Opp updation/Email sending flow stable 
* 15.0     SFSE-11769  26-July-2023  Seba                    Added code for email template UI modifications 
* 16.0     SFSE-11769  28-July-2023  Seba                    Bug fix 
* 17.0     SFSE-11769  31-July-2023  Bharti                  Bug that was showing banner in email agreement PDF fixed 
* 18.0     SFSE-11769  31-July-2023  Seba                    Fixed getVFOrigin method 
* 19.0     SFSE-12725  20-Sep-2023   Seba                    Made changes in createContentVersionRecords method to remove .pdf from file name
* 20.0     SFSE-12757  20-Sep-2023   Seba                    Fixes for Invalid Email Address - issue 
* 21.0     SFSE-13164  22-Nov-2023   Arpitha                 Changes made in Terms and Conditions.
* 22.0	   SFSE-14161  16-Feb-2024	 Vinay					 Added Code to fix the Email Content.
* 2.0	   SFSE-14161  16-may-2024	 Samar					 Sending Quote file for p2q Oppty.	
* 2.1      SFSE-15248  11-jun-2021   Shilpa                  Changed logic to show Terms and conditions.
*/
public with sharing class oneClickEmailTemplateCtrl { 
    public string message {get; set;}
    public boolean clearFormat {set; get;}  
    public Opportunity opty{get;set;}     
    public String src {get; set;} 
    public String OptyId {get; set;}
    public string firstName {get; set;} 
    public String agreementStartDate {get; set;}
    public String agreementEndDate {get; set;}
    public String offerName{get;set;}
    public String loggedInUserName{get; set;}
    public string lastname {get; set;}
    public boolean isEdit {get; set;}
    public String optyProductNames {get; set;}
    public string accountName {get; set;}
    public String optyCloseDate {get;set;}
    public String openSiteURL { get;set;} 
    public string offerURL{get; set;}
    /*SFSE-11596*/
    public String solutionText1 { get; set; }
    //public String solutionText2 { get; set; } 
    public Boolean isAlreadyLoaded { get; set; } //To track if the page just loaded
    public string greetingLineWithAddress { get; set; } 
    public String displayGreetingLineStr { get; set; }
    public String emailSignOffLine { get;set; }
    public String displayEmailSignOffStr { get; set; }
    /*SFSE-11596*/
    public String showBannerInEmail {get; set;}
    public static string oldNameInSalutationStr = ''; //SFSE-11804 
    //SFSE-11754
    public Boolean showOceanLink{ get; set;}
    public Boolean showLNSLink{ get; set;}
    // public Boolean showMCSLink{ get; set;}
    public Boolean showCaptainPeterLink{get;set;}
    public Boolean showMaerskGoLink{get;set;}
    public Boolean showValueProtectLink{get;set;}
    public List<String> listMCSProductCodes;
    public String captainPeterLink{get;set;}
    public String maerskGoLink{get;set;}
    public String valueProtectLink{get;set;}
    public List<String> params = new List<String>{};
    public static map<String,String> mapOfOceanProd{get;set;}
    public static map<String,String> mapOfLnsProd{get;set;}
    public static Map<String, Map<String, String>> mapOfProduct{get;set;}
    public String productlabel {get;set;}
    
    
    
    
    //Constructor
    public oneClickEmailTemplateCtrl(){  
        String mssgStr = 'Thank you for your interest in working with Maersk.';/*SFSE-11596*/
        src = ApexPages.currentPage().getParameters().get('src');
        OptyId = ApexPages.currentPage().getParameters().get('optyId'); 
        offerName = ApexPages.currentPage().getParameters().get('offerName');
        lastname = ApexPages.currentPage().getParameters().get('ContactlastName');
        optyProductNames = '';
        accountName =''; 
        showBannerInEmail = 'false';
        isEdit = false;
        loggedInUserName = UserInfo.getName();
        optyCloseDate = ''; 
        //SFSE-11754
        showOceanLink = false;
        showLNSLink = false;
        //showMCSLink = false;
        showCaptainPeterLink = false;
        showMaerskGoLink = false;
        showValueProtectLink = false;
        listMCSProductCodes = System.Label.MCS_Product_Codes.split(',');
        captainPeterLink = System.label.CaptainPeterLinkOneClickJourney;
        maerskGoLink = System.label.MaerskGoLinkOneClickJourney;
        valueProtectLink = System.label.ValueProtectLinkOneClickJourney;   
        mapOfProduct = new Map<String, Map<String, String>>();
        productlabel = '';
        
        
        
        
        
        
        
        
        
        
        //Updated on June 19 for the OLI data structure change
        opty = [select (select Product2ID__r.name, OIPC_Product_Code__c, Product2ID__r.Terms_Conditions__c,Product2ID__r.Portfolio__c from Opportunity_Products__r),id,Opportunity_Ref__c,Name,Owner.Name,First_Shipment_Date__c ,Last_Shipment_Date__c,closeDate,Account.Name from Opportunity where id=:OptyId];
        if(src != null && src=='html'){
            
            clearFormat = true;
        }   
        
        if(ApexPages.currentPage().getparameters().get('showBanner') != null){
            showBannerInEmail = 'true'; 
        } 
        
        //Creating the URL 
        if(ApexPages.currentPage().getParameters().get('url')!=NULL){
            SiteDetail mySiteDetail;
            Site mySite = [select Id from Site where Name =: System.label.IAcceptOfferConfirmationPageURL];
            if(mySite != null){
                mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
            }
            offerURL = mySiteDetail.SecureURL+'/s/?str='+ ApexPages.currentPage().getParameters().get('url'); 
        }
        
        //SFSE-11754
        //SFSE-15248
        if(opty.Opportunity_Products__r.size() > 0){
            for(integer i = 0; i < opty.Opportunity_Products__r.size(); i++){ 
                if(!mapOfProduct.containskey(opty.Opportunity_Products__r[i].Product2ID__r.name)){
                    if(opty.Opportunity_Products__r[i].Product2ID__r.Terms_Conditions__c != null){
                        productlabel = opty.Opportunity_Products__r[i].Product2ID__r.Terms_Conditions__c;
                        // Initialize the inner map
                        Map<String, String> innerMap = new Map<String, String>();
                        innerMap.put('Terms_Conditions__c', opty.Opportunity_Products__r[i].Product2ID__r.Terms_Conditions__c);  
                        // Check conditions and set appropriate product labels
                        if (productLabel.endsWith('stc')) {
                            innerMap.put('Product_Label', Label.oneClickEmailStandardTradingConditionTermsLabel);
                        } else if (productLabel.endsWith('MCS')) {
                            innerMap.put('Product_Label', 'Maersk Customs Services');
                        } else if (productLabel.endsWith('service')) {    
                            innerMap.put('Product_Label', Label.oneClickEmailServiceContractTermsLabel);
                        }else{
                            innerMap.put('Product_Label',opty.Opportunity_Products__r[i].Product2ID__r.name +'_' +'Terms');
                        }
                        
                        // Add the inner map to the outer map only if a condition matched
                        if (innerMap.containsKey('Product_Label')) {
                            mapOfProduct.put(opty.Opportunity_Products__r[i].Product2ID__r.name, innerMap);
                            System.debug('Added to map: ' + mapOfProduct);
                        }
                        
                    }
                }
                     
            //SFSE-11769
            if(!optyProductNames.contains(opty.Opportunity_Products__r[i].Product2ID__r.Name)){
                if(optyProductNames == '')
                    optyProductNames += opty.Opportunity_Products__r[i].Product2ID__r.Name;
                else 
                    optyProductNames += ', '+opty.Opportunity_Products__r[i].Product2ID__r.Name;
            } 
        }
    }
    
    if(opty.Account.Name != null){
        accountName = opty.Account.Name; 
    }
    
    if(opty.closeDate != null){
        Date oppCloseDt = opty.closeDate;   
        DateTime dt = DateTime.newInstance(oppCloseDt.year(),oppCloseDt.month(),oppCloseDt.day()); 
        optyCloseDate = oppCloseDt.day() + ' ' + dt.format('MMMM') + ' ' + oppCloseDt.year();
    }
    
    if(opty.First_Shipment_Date__c != null){
        Date agreementfirstDt = opty.First_Shipment_Date__c;   
        DateTime dt = DateTime.newInstance(agreementfirstDt.year(),agreementfirstDt.month(),agreementfirstDt.day()); 
        agreementStartDate = agreementfirstDt.day() + ' ' + dt.format('MMMM') + ' ' + agreementfirstDt.year();
    }
    
    if(opty.Last_Shipment_Date__c != null){
        Date agreementEndDt = opty.Last_Shipment_Date__c;   
        DateTime endDt = DateTime.newInstance(agreementEndDt.year(),agreementEndDt.month(),agreementEndDt.day()); 
        agreementEndDate = agreementEndDt.day() + ' ' + endDt.format('MMMM') + ' ' + agreementEndDt.year();   
    }
    
    /*SFSE-11596*/
    lastname = '';
    isAlreadyLoaded = false;
    solutionText1 = ApexPages.currentPage().getParameters().get('solutionText1');
    //solutionText2 = ApexPages.currentPage().getParameters().get('solutionText2');  
    greetingLineWithAddress = ApexPages.currentPage().getParameters().get('greetingLineWithAddress');
    /****************Added as part of story SFSE-13164**********************************/
    String oneClickOfferEmailDescriptionLabel = Label.oneClickOfferEmailDescriptionLabel;
    params.add(optyProductNames);
    params.add(agreementStartDate);
    params.add(agreementEndDate);
    String message = String.format(oneClickOfferEmailDescriptionLabel, params);
    mssgStr = mssgStr+message;
    /************************************************************************************/
    
    lastname = ApexPages.currentPage().getParameters().get('ContactlastName') == null ? lastname : ApexPages.currentPage().getParameters().get('ContactlastName');//11596   // SFSE-14161         
    displayGreetingLineStr = (greetingLineWithAddress == null) ? ('Dear' + ' ' +lastname + ',' + '\n\n' + mssgStr) : greetingLineWithAddress; 
    emailSignOffLine = ApexPages.currentPage().getParameters().get('emailSignOffLine');
    displayEmailSignOffStr = emailSignOffLine == null ? 'Sincerely,'+ '\n' + loggedInUserName : emailSignOffLine;
    /*SFSE-11596*/ 
} 

public PageReference setLastName() {
    try{ 
        oldNameInSalutationStr = Apexpages.currentPage().getParameters().get('oldNameInGreetingLine');//SFSE-11804
        lastname = Apexpages.currentPage().getParameters().get('ContactlastName');   
        /*SFSE-11596*/
        String salutationWithNameStr = '';
        String emailBodyStr = '';
        String salutationInGreetingStr = '';  
        /*SFSE-11804*/
        list<String> listOfFirstLastNames = new List<String>();
        
        if(oldNameInSalutationStr != null){
            if(oldNameInSalutationStr.contains(' ')){ 
                listOfFirstLastNames = oldNameInSalutationStr.split(' '); 
            }else{
                listOfFirstLastNames.add(oldNameInSalutationStr);  
            }   
        }
        /*SFSE-11804*/
        
        if(displayGreetingLineStr.length() > 0){
            if(displayGreetingLineStr.contains('\n')){
                salutationWithNameStr = displayGreetingLineStr.substringBefore('\n');// (Hi Sam) or (HiSam) or (Hi,) or (Hi ,)
                emailBodyStr = displayGreetingLineStr.substring(displayGreetingLineStr.indexOf('\n'),displayGreetingLineStr.length());//\n\nemailbodytext 
                
                if(salutationWithNameStr.contains(',')){ 
                    if(salutationWithNameStr.contains(' ')){ 
                        salutationInGreetingStr = salutationWithNameStr.substring(0,salutationWithNameStr.indexOf(' '));//Hi from (Hi Sam,)/ (Hi ,)
                    }else{  
                        salutationInGreetingStr = salutationWithNameStr.substring(0,salutationWithNameStr.indexOf(','));//Hi from (Hi,)   
                    }   
                }else{//If greeting line do not have comma  
                    if(salutationWithNameStr.contains(' ')){
                        salutationInGreetingStr = salutationWithNameStr.substring(0,salutationWithNameStr.indexOf(' '));//Hi from (Hi Sam,)/ (Hi ,)
                    }else{
                        salutationInGreetingStr =  salutationWithNameStr; 
                    }   
                } 
            }else{//If new line is not there and the salutation contains comma 
                if(displayGreetingLineStr.contains(',')){
                    salutationWithNameStr = displayGreetingLineStr.substringBefore(',');// (Hi Sam) or (HiSam) or (Hi,) or (Hi ,)
                    emailBodyStr = displayGreetingLineStr.substring(displayGreetingLineStr.indexOf(',')+1,displayGreetingLineStr.length());
                    
                    if(salutationWithNameStr.contains(' ')){
                        salutationInGreetingStr = salutationWithNameStr.substring(0,salutationWithNameStr.indexOf(' '));//Hi
                    }else{
                        salutationInGreetingStr =  salutationWithNameStr.substring(0,salutationWithNameStr.indexOf(','));  
                    } 
                }else if(!displayGreetingLineStr.contains(',')){//If new line is not there and the salutation do not contain comma
                    if(displayGreetingLineStr.contains(' ')){
                        salutationInGreetingStr = displayGreetingLineStr.substring(0,displayGreetingLineStr.indexOf(' '));//Hi
                    }else{
                        salutationInGreetingStr = displayGreetingLineStr;
                    }
                }
            } 
            /*SFSE-11804*/
            if(salutationInGreetingStr!= '' && oldNameInSalutationStr != null && listOfFirstLastNames.size() > 0 ){  
                if(listOfFirstLastNames.contains(salutationInGreetingStr)){ 
                    salutationInGreetingStr = ' ';
                }  
            }
            oldNameInSalutationStr = lastname; 
            /*SFSE-11804*/  
            displayGreetingLineStr = salutationInGreetingStr + ' ' +lastname + ',' + emailBodyStr; 
        }else{//If greetingLine is null 
            displayGreetingLineStr =  lastname;
            oldNameInSalutationStr =  ' ';/*SFSE-11804*/ 
        }
    }catch(Exception e){
        System.debug('Exception has occurred: ' + e.getMessage());
    } 
    /*SFSE-11596*/
    return null;
}

public void enableEdit(){
    isEdit = true;
    isAlreadyLoaded = true;
}
public void disableEdit(){
    isEdit = false;
    isAlreadyLoaded = true;
}

@AuraEnabled
public static Contact fetchFirstName(String contactId){
    Contact con = new Contact();
    try{
        con =[SELECT FirstName,LastName FROM Contact WHERE Id=:contactId LIMIT 1] ; 
    }
    catch(Exception e){
        system.debug('Exception occured: '+e);
    }
    return con;
}

//Method to send email from the one click email LWC component
@AuraEnabled
public static String sendEmail(String opportunityId, List<String> updatedContent, String to_AddressContactId, 
                               List<String> cc_AddressContactIds, List<String> contentVersionIdLst,
                               String subjectName,String ContactlastName,String P2Qfile, String P2QfileName){  
                                   system.debug(P2Qfile);
                                   Set<String> setOfOfferIdAndMailAddress = new Set<String>(); 
                                   String ccEmailsConcat ='';
                                   String toEmailAddress;
                                   string htmlbody; 
                                   List<Messaging.SingleEmailMessage> listEmailsToSent = new List<Messaging.SingleEmailMessage>();
                                   List<Map<String,String>> pdfContentLst = new List<Map<String,String>>();
                                   Integer numberOfTimesIterated = 0;
                                   String pdfContentBase64 = ''; 
                                   String ccRecipientsWithNullEmail = '';/*SFSE-12757*/
                                   Set<String> setToCCRecipientContactEmails = new Set<String>();/*SFSE-12757*/
                                   List<SObject> offerOpportunityDMLList = new List<Sobject>(); //List to hold the offer info/ opp records to insert/update SFSE-11804 
                                   
                                   Savepoint sp = Database.setSavepoint();      
                                   //Adding try catch - SFSE-11804 
                                   try{ 
                                       
                                       /*SFSE-12757*/
                                       Map<Id, Contact> mapIdContact = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE (Id=:to_AddressContactId OR Id IN: cc_AddressContactIds)]);
                                       if(mapIdContact.containsKey(to_AddressContactId)){
                                           if(mapIdContact.get(to_AddressContactId).Email != NULL){//If the Email field is NOT NULL 
                                               toEmailAddress = mapIdContact.get(to_AddressContactId).Email; 
                                               setToCCRecipientContactEmails.add(mapIdContact.get(to_AddressContactId).Email);
                                               mapIdContact.remove(to_AddressContactId);//Removed key-value pair of To Address contact
                                           }else{//If the Email field is NULL 
                                               if(mapIdContact.get(to_AddressContactId).Name != NULL){//NULL check on Contact Name
                                                   return String.format(Label.oneClickInvalidEmailErrorMessage, new List<String>{ mapIdContact.get(to_AddressContactId).Name }); 
                                               } 
                                           }
                                       } 
                                       //Check for CC Recipients
                                       for(Id contactId : mapIdContact.keySet()){
                                           if(mapIdContact.get(contactId).Email != NULL){//If the Email address in NOT NULL for CC Recipient
                                               ccEmailsConcat+= ccEmailsConcat == '' ? (mapIdContact.get(contactId).Email) : (',' + mapIdContact.get(contactId).Email);
                                                   setToCCRecipientContactEmails.add(mapIdContact.get(contactId).Email); 
                                           }else{//If the Email address is NULL for CC Recipient
                                               ccRecipientsWithNullEmail +=  ccRecipientsWithNullEmail == '' ? (mapIdContact.get(contactId).Name) : (', ' + mapIdContact.get(contactId).Name);
                                                   }
                                       }
                                       if(String.isNotBlank(ccRecipientsWithNullEmail)){
                                           return String.format(Label.oneClickInvalidEmailErrorMessage, new List<String>{ ccRecipientsWithNullEmail }); 
                                       } 
                                       /*SFSE-12757*/
                                       
                                       Opportunity Opty = [select id,Opportunity_Ref__c,Name,Owner.Name,Customer_Journey__c from Opportunity where id=:opportunityId];   
                                       
                                       if(Opty!=NULL){
                                           //Create offer information record
                                           Offer_Information__c offer = new Offer_Information__c();
                                           offer.Opportunity__c = opty.Id;
                                           if(to_AddressContactId != null){  
                                               offer.To_Recipient__c = to_AddressContactId;   
                                           }
                                           offer.CC_Recipients__c = ccEmailsConcat;
                                           offer.Date_Sent__c = system.today();
                                           offer.Offer_Status__c = 'Sent'; 
                                           //SFSE-11804 Adding Offer Info to be inserted in SObject list for upsert dml
                                           offerOpportunityDMLList.add(offer);
                                           Opty.offer_status__c = 'Sent'; /*Updating the opportunity Offer Status:SFSE-11312*/ 
                                           //SFSE-11804 Adding Opportunity record to be  updated in SObject list for upsert dml
                                           offerOpportunityDMLList.add(Opty); 
                                           
                                           //Upserting SObject list so that if failure occures:
                                           //the updates/insertion will rollabck,email not get sent and error toast shows up 
                                           //i.e the upsert throws exception on failure since second argument in Database.upsert is true
                                           Database.UpsertResult[] SR = Database.upsert(offerOpportunityDMLList,true);  
                                           
                                           if(SR.size() > 0){ 
                                               /*SFSE-12757*/
                                               //Set holds the combination of offerId and Email address
                                               if(!setToCCRecipientContactEmails.isEmpty()){
                                                   for(String eachRecipientEmail : setToCCRecipientContactEmails){ 
                                                       setOfOfferIdAndMailAddress.add(offer.Id + eachRecipientEmail);
                                                   }
                                               }
                                               /*SFSE-12757*/
                                               shareOfferRecords(Opty.Id, offer.Id);
                                               Map<String,String> MapOfEncryptedValue = new Map<String,String>();
                                               String encryptData;
                                               Offer_Information__c Off = [select id,Name from Offer_Information__c where Id=:offer.Id];
                                               
                                               //Calling the Encyrpt controller class and getting the encrypted value 
                                               EncryptionAndDecryptionController cls = new EncryptionAndDecryptionController();
                                               if(setOfOfferIdAndMailAddress != null){
                                                   MapOfEncryptedValue =  cls.encryptData(setOfOfferIdAndMailAddress);
                                               }
                                               
                                               PageReference pg = Page.oneClickEmailTemplate;
                                               pg.getParameters().clear();
                                               pg.getParameters().put('optyId', opportunityId);
                                               pg.getParameters().put('src', 'html');
                                               pg.getParameters().put('offerName', Off.Name);
                                               pg.getParameters().put('ContactlastName', ContactlastName);
                                               
                                               /*SFSE-11596*/   
                                               for(String updatedStr : updatedContent){  
                                                   List<String> splitLst = updatedStr.split('==');
                                                   
                                                   if(splitLst[0] == 'emailGreetingValue' && splitLst.size() > 1 ){ 
                                                       pg.getParameters().put('greetingLineWithAddress', splitLst[1]); 
                                                   }                                                     
                                                   else if(splitLst[0] == 'solutionUserValue' && splitLst.size() > 1 ){ 
                                                       pg.getParameters().put('solutionText1',splitLst[1]);  
                                                   }
                                                   /*else if(splitLst[0] == 'summaryUserValue' && splitLst.size() > 1 ){  
pg.getParameters().put('solutionText2',splitLst[1]);    
}*/
                                                   else if(splitLst[0] == 'emailSignOffValue' && splitLst.size() > 1 ){ 
                                                       pg.getParameters().put('emailSignOffLine',splitLst[1]); 
                                                   }
                                               }
                                               /*SFSE-11596*/   
                                               
                                               if(contentVersionIdLst!=null){
                                                   //Create version records(for the uploaded files) and associate them to the offer record.
                                                   setVisibilityofContentFiles(contentVersionIdLst,offer.Id); 
                                               } 
                                               //Iterating over Map of key offer Id and Mail Address combination and sending mail to each address
                                               for(String str : MapOfEncryptedValue.keyset()){                     
                                                   String encryptedData = EncodingUtil.urlEncode(MapOfEncryptedValue.get(str), 'UTF-8');
                                                   //splitting mail adddress from key of map 
                                                   String mailAddress =  str.substring(18); 
                                                   pg.getParameters().put('url',encryptedData);
                                                   Blob pdfBody;
                                                   Map<String, String> params  =  pg.getParameters(); 
                                                   //remove ekp and save_new key
                                                   params.remove('showBanner');
                                                   if(mailAddress != toEmailAddress){
                                                       pg.getParameters().put('showBanner', 'true'); 
                                                   }
                                                   if(!Test.isRunningTest()){
                                                       htmlbody = pg.getContent().toString();
                                                       /*SFSE-10740*/
                                                       if(numberOfTimesIterated<=0 && mailAddress == toEmailAddress){
                                                           pdfBody = pg.getContentAsPDF(); //Output --> Blob[9129]
                                                           pdfContentBase64 = EncodingUtil.base64Encode(pdfBody);
                                                           numberOfTimesIterated++; 
                                                       }
                                                       /*SFSE-10740*/
                                                   }
                                                   
                                                   Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                                                   //SFSE-11769
                                                   String emailSubjectStr = System.label.oneClickOfferEmailSubject;
                                                   singleMail.setSubject(emailSubjectStr);
                                                   singleMail.setToAddresses(new List<String>{mailAddress});
                                                   
                                                   singleMail.setHtmlBody(htmlbody);
                                                   
                                                   if(!contentVersionIdLst.isEmpty()){
                                                       singleMail.setEntityAttachments(contentVersionIdLst);  
                                                   }
                                                   if(Opty.Customer_Journey__c == 'Instant Quote (Non Negotiable)'  && P2Qfile != null && P2QfileName != null){
                                                       
                                                       Blob tempBlob = EncodingUtil.base64Decode(P2Qfile);
                                                       
                                                       Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                                       efa.setBody(tempBlob);
                                                       efa.setFileName(P2QfileName);
                                                       efa.setInline(false);
                                                       singleMail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                                                   }
                                                   
                                                   
                                                   listEmailsToSent.add(singleMail);
                                                   
                                               }
                                               
                                               if(!listEmailsToSent.isEmpty()){
                                                   Messaging.sendEmail(listEmailsToSent);  
                                                   //insert pdfBody as file  SFSE-10740
                                                   createContentVersionRecords(pdfContentBase64,offer.Id);  
                                               }
                                               
                                               
                                           }  
                                       }   
                                       return 'success';   
                                   }catch(Exception e){ 
                                       Database.RollBack(sp);
                                       system.debug('Exception thrown: '+e);
                                       return Label.oneClickErrorMessage;
                                   }
                                   
                               }


//Method to create the content version record for the Email body PDF  
public static List<Id> createContentVersionRecords(String emailPDFContent,String offerId)
{ 
    ContentVersion contentVersionFile = new ContentVersion();  
    contentVersionFile.PathOnClient =  System.Label.oneClickEmailBodySentToCustomerFileName_Label;
    contentVersionFile.Title =  System.Label.oneClickEmailBodySentToCustomerFileName_Label.substringBefore('.pdf');
    contentVersionFile.VersionData =  EncodingUtil.base64Decode(emailPDFContent);  
    contentVersionFile.Origin ='C';  
    List<Id> recordIds = new List<Id>(); 
    Database.SaveResult SR = Database.insert(contentVersionFile, false);
    if(SR.isSuccess()){
        recordIds.add(SR.getId());  
    }
    
    //To create Content Document Links - Inesrting Content Doc Links Asynchronously
    setVisibilityofContentFiles(recordIds,offerId);
    return recordIds;
    
    
}  

/*SFSE-10740*/
@future
public static void setVisibilityofContentFiles(List<Id> contentVersionIdLst,String offerId){ 
    list<Id> DocIds = new List<Id>();
    for(ContentVersion CV: [SELECT Id, ContentDocumentId FROM ContentVersion where Id IN: contentVersionIdLst]){
        DocIds.add(CV.ContentDocumentId);  
    } 
    List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
    if(!DocIds.isEmpty()){
        for(Id conDocId: DocIds){
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocId;//Add ContentDocumentId
            cDocLink.LinkedEntityId = offerId;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            listCDL.add(cDocLink);
            
        }  
    }
    if(!listCDL.isEmpty()){
        insert listCDL;
    }
    
}

public string lexOrigin {get{ 
    return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
} set;}

/*Below code generates dynamic VF page links as follows:
https://maersk--clmsit--c.sandbox.vf.force.com for sandboxes and 
https://maersk--sit--c.visualforce.com for SIT/UAT/ Production*/
@AuraEnabled(cacheable=true)
public static string getVFOrigin() {
    string vfOrigin = '';
    string baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
    /*SFSE-11769*/
    //If base url domain part contains 'sandbox'
    if(baseURL.split('.my.')[0].contains('sandbox')){ 
        vfOrigin = baseURL.substringBefore('.sandbox')+'--c.'+'sandbox'+'.vf.force.com';   
    }else{ 
        vfOrigin = baseURL.split('.my.')[0] + System.Label.oneClickVFOriginURL; 
    } 
    /*SFSE-11769*/
    return vfOrigin;
}

@auraEnabled 
public static offer_information__c fetchActiveOfferInformation(String opportunityId){
    List<Offer_Information__c> activeOfferLst = new List<Offer_Information__c>();   
    Offer_Information__c offerRec = null;
    try{
        activeOfferLst = [select id,name,offer_status__c,To_Recipient__r.Email,To_Recipient__r.Name,Opportunity__r.First_Shipment_Date__c,Opportunity__r.Last_Shipment_Date__c,CC_Recipients__c from offer_information__c where opportunity__c= :opportunityId and (offer_status__c = 'Sent') limit 1];
        if(!activeOfferLst.isEmpty()){
            offerRec = activeOfferLst[0];
        }
        return offerRec; 
    }catch(Exception e){
        system.debug('Exception thrown:'+e);
        return null; 
    }
    
    
}

@future
public static void shareOfferRecords(Id optyId, Id offerId){
    set<Id> setOptyMemberIds = new Set<Id>();
    List<Offer_Information__Share> listShareRecords = new List<Offer_Information__Share>();
    
    for(OpportunityTeamMember member: [SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId=: optyId]){
        setOptyMemberIds.add(member.UserId); 
    }
    
    Opportunity oppty = [SELECT Account.OwnerId FROM Opportunity WHERE Id =: optyId];
    if(oppty!=NULL){
        setOptyMemberIds.add(oppty.Account.OwnerId); 
    }
    
    if(!setOptyMemberIds.isEmpty()){
        for(Id memberId: setOptyMemberIds){
            listShareRecords.add(new Offer_Information__Share(ParentId = offerId, UserOrGroupId=memberId, AccessLevel='Read', RowCause=Schema.Offer_Information__Share.RowCause.Manual)); 
        }}
    if(!listShareRecords.isEmpty()){
        Database.insert(listShareRecords, false);            
    }
}

/*Method to validate the size of files attached is less than 25 MB*/
@auraEnabled
public static Boolean validateFileSize(List<String> contentVersionIdLst){
    Boolean isValidSize = false;
    Integer MAX_FILE_SIZE = 25000000; 
    for(ContentVersion CV: [SELECT Id, ContentSize FROM ContentVersion where Id IN: contentVersionIdLst]){
        if(cv.contentSize > MAX_FILE_SIZE){
            isValidSize = true;
            break;
        } 
    } 
    return isValidSize;
}


}