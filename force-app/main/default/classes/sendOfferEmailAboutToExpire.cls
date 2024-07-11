/*  
* Class is contrller for Flow - Send Email for Offer Information Expired
* Version   Date            Owner                   Description
* --------  -----------     -------------------     -----------
* 1.0       19-Jun-2023     Vazid@UST               Send notification to customer if offer is about Expire.
* 2.0       11-july-2023     Bharti                 Added the code to add banner for CC recipients in reminder offer
                                                    This flow is invoking from "Send Email for Offer Information Expired" Flow
* 3.0       26-July-2023     Aditi                  SFSE-11754 Added links for terms and conditions  
* 4.0       26-July-2023     Seba                   SFSE-11769 Added code for email template UI modifications 
* 5.0       31-July-2023     Bharti                 SFSE-11769 Added code for sending attachments with reminder email
* 6.0       22-Nov-2023     Arpitha                 SFSE-13164 Changes made in Terms and Conditions.

*/
public class sendOfferEmailAboutToExpire {
    
    public Opportunity opty{get;set;} 
    public String OptyId {get; set;}
    public String agreementStartDate {get; set;}
    public String agreementEndDate {get; set;}
    public string lastname {get; set;}
    public String optyProductNames {get; set;}
    public String loggedInUserName{get; set;}
    public String offerName{get;set;}
    public string message {get; set;}  
    public string msg{get;set;} 
    public boolean clearFormat {set; get;} 
    public String src {get; set;} 
    public string accountName {get; set;}
    public string offerURL{get; set;}
    public String showBannerInEmail {get; set;}
    
    //SFSE-11754
    public String showOceanLink{ get; set;}
    public String showLNSLink{ get; set;}
    public String showMCSLink{ get; set;}
    public String showCaptainPeterLink{get;set;}
    public String showMaerskGoLink{get;set;}
    public String showValueProtectLink{get;set;}
    public String oceanLink{ get; set;}
    public String mcsLink{ get; set;}
    public String lnsLink{ get; set;}
    public String captainPeterLink{get;set;}
    public String maerskGoLink{get;set;}
    public String valueProtectLink{get;set;}
    public String maerskCustomServicesProducts{get;set;}
    public String lnsProducts{get;set;}
    public String oceanProducts{get;set;}
    
    
    public sendOfferEmailAboutToExpire(){
        showBannerInEmail ='false';
        //SFSE-11754
        showOceanLink = 'false';
        showLNSLink = 'false';
        showMCSLink = 'false';
        showCaptainPeterLink = 'false';
        showMaerskGoLink = 'false';
        showValueProtectLink = 'false';
        
        src = ApexPages.currentPage().getParameters().get('src');
        OptyId = ApexPages.currentPage().getParameters().get('optyId');
        offerName = ApexPages.currentPage().getParameters().get('offerName');
        lastname = ApexPages.currentPage().getParameters().get('ContactlastName');
        loggedInUserName = ApexPages.currentPage().getParameters().get('salesUserName');
        optyProductNames = ApexPages.currentPage().getParameters().get('optyProductNames');
        agreementStartDate = ApexPages.currentPage().getParameters().get('agreementStartDate');
        agreementEndDate = ApexPages.currentPage().getParameters().get('agreementEndDate');
        accountName = ApexPages.currentPage().getParameters().get('accountName');
        //SFSE-11754
        showOceanLink = ApexPages.currentPage().getParameters().get('showOceanLink');
        showMCSLink = ApexPages.currentPage().getParameters().get('showMCSLink');
        showLNSLink = ApexPages.currentPage().getParameters().get('showLNSLink');        
        showCaptainPeterLink = ApexPages.currentPage().getParameters().get('showCaptainPeterLink'); 
        showMaerskGoLink = ApexPages.currentPage().getParameters().get('showMaerskGoLink'); 
        showValueProtectLink = ApexPages.currentPage().getParameters().get('showValueProtectLink'); 
        maerskCustomServicesProducts = ApexPages.currentPage().getParameters().get('maerskCustomServicesProducts'); 
        lnsProducts = ApexPages.currentPage().getParameters().get('lnsProducts'); 
        oceanProducts = ApexPages.currentPage().getParameters().get('oceanProducts'); 
        
               
        oceanLink = System.label.OceanLinkOneClickJourney;
        mcsLink = System.label.MCSLinkOneClickJourney;
        lnsLink = System.label.LNSLinkOneClickJourney;
        captainPeterLink = System.label.CaptainPeterLinkOneClickJourney;
        maerskGoLink = System.label.MaerskGoLinkOneClickJourney;
        valueProtectLink = System.label.ValueProtectLinkOneClickJourney;
        
       
        
        if(ApexPages.currentPage().getParameters().get('url')!=NULL){
            SiteDetail mySiteDetail;
            Site mySite = [select Id from Site where Name =: System.label.IAcceptOfferConfirmationPageURL];
            if(mySite != null){
             mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
            }
          offerURL = mySiteDetail.SecureURL+'/s/?str='+ ApexPages.currentPage().getParameters().get('url'); 
        }
      
        if(src != null && src=='html'){
            clearFormat = true;
        }
         //sfse-11632
         if(ApexPages.currentPage().getparameters().get('showBanner') != null){
            showBannerInEmail = 'true';
            
           
        }
    }
    
    //@InvocableMethod(label='sendEmailOfferToExpire' description='Inform the customer that the "I agree" offer is about to expire')
    public static void sendEmailOfferToExpire(List<Offer_Information__c> request){
    
      Map<Id,String> mapOfEmail = new Map<Id,String>();
        Set<String> holdsKey = new Set<String>();
        set<Id> toAddressIds = new set<Id>();
        set<Id> salesUserIds = new set<Id>();
        set<Id> offerIds = new set<Id>();
        set<Id> optyIds = new set<Id>();
        Map<string,Offer_Information__c> mapOfOfferInformation = new Map<string,Offer_Information__c>();
        String maerskCustomServicesProducts;
        String lnsProducts;
        String oceanProducts;
        
        //SFSE-11754
        String showMCSLink1; 
        String showLNSLink1 ;
        String showOceanLink1;
        String showCaptainPeterLink;
        String showMaerskGoLink;
        String showValueProtectLink;
        List<String> listMCSProductCodes = System.Label.MCS_Product_Codes.split(','); 
          Map<String,List<id>> offerContentVersionMap = new Map<String,List<id>>();
          Map<Id,Id> contentDocumentOfferIdMap = new Map<Id,Id>();
        
        //Storing recipient ids and createdby ids,  recipient ids : to send notificaiton and createdby ids : to use it as sales users.
        for(Offer_Information__c req:request){
            toAddressIds.add(req.To_Recipient__c);
            salesUserIds.add(req.CreatedById);
            optyIds.add(req.Opportunity__c);
            offerIds.add(req.Id);
        }
        //fetching ContentDocumentId and storing it in a set 
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:  offerIds ]){
            
            contentDocumentOfferIdMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);// contentDoc Id --> Offer Id
        }
        
         
        //using ContentDocumentId fetching contentVersionLink
         For (ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentOfferIdMap.keyset()])
         {
             
             if(contentDocumentOfferIdMap.containsKey(cv.ContentDocumentId) && !offerContentVersionMap.containsKey(contentDocumentOfferIdMap.get(cv.ContentDocumentId))){
               offerContentVersionMap.put(contentDocumentOfferIdMap.get(cv.ContentDocumentId),new List<Id>()); // Offer Id ---> List of CV Ids 
             }
             if(offerContentVersionMap.containsKey(contentDocumentOfferIdMap.get(cv.ContentDocumentId))){
               offerContentVersionMap.get(contentDocumentOfferIdMap.get(cv.ContentDocumentId)).add(cv.Id);  
             }
        }
        
        // Mapping Opportunity as key and productNames, agreementstartdata and agreementenddate as values
        Map<Id,Map<string,string>> mapOfOptywithProductNames = new Map<Id,Map<string,string>>(); 
        List<Opportunity> optyList =[select (select Product2ID__r.name, OIPC_Product_Code__c, Product2ID__r.Portfolio__c from Opportunity_Products__r),id,Opportunity_Ref__c,Name,Owner.Name,First_Shipment_Date__c ,Last_Shipment_Date__c,closeDate,Account.Name from Opportunity where id in : optyIds];
        
        if(!optyList.isEmpty()){
            
            for(Opportunity opty : optyList){
                 //SFSE-11754
                 showMCSLink1 = 'false';
                 showLNSLink1 = 'false';
                 showOceanLink1 = 'false';
                 showCaptainPeterLink = 'false';
                 showMaerskGoLink = 'false';
                 showValueProtectLink = 'false';
                 
                Map<string,string> mapOfString = new Map<string,string>();
                
                opty.Offer_Status__c = 'Expired';
                opty.StageName = 'Closed Lost';
                opty.Reason_For_Close__c = 'Offer has expired';
                
                string optyProductNames ='';
               //SFSE-11754
                if(opty.Opportunity_Products__r.size() > 0){
                    for(integer i = 0; i < opty.Opportunity_Products__r.size(); i++){ 
                        if(listMCSProductCodes != null && listMCSProductCodes.contains(opty.Opportunity_Products__r[i].OIPC_Product_Code__c)){
                            showMCSLink1 = 'true';
                            if(maerskCustomServicesProducts==null){
                                maerskCustomServicesProducts=opty.Opportunity_Products__r[i].Product2ID__r.name;    
                            }
                            else{
                                if(!maerskCustomServicesProducts.contains(opty.Opportunity_Products__r[i].Product2ID__r.name)){
                                    maerskCustomServicesProducts+=+', '+opty.Opportunity_Products__r[i].Product2ID__r.name;
                                }
                            } 
                            maerskCustomServicesProducts = maerskCustomServicesProducts.subString(0,maerskCustomServicesProducts.length());
                        }
                        else if(opty.Opportunity_Products__r[i].Product2ID__r.Portfolio__c == 'LnS' && opty.Opportunity_Products__r[i].Product2ID__r.name!='Captain Peter' && opty.Opportunity_Products__r[i].Product2ID__r.name!='Value Protect'){
                            showLNSLink1 = 'true';
                            if(lnsProducts==null){
                                lnsProducts=opty.Opportunity_Products__r[i].Product2ID__r.name;
                            }
                            else{
                                if(!lnsProducts.contains(opty.Opportunity_Products__r[i].Product2ID__r.name)){    
                                    lnsProducts+=+', '+opty.Opportunity_Products__r[i].Product2ID__r.name;
                                }    
                            }
                                lnsProducts = lnsProducts.subString(0,lnsProducts.length());
                        }
                           
                        else if(opty.Opportunity_Products__r[i].Product2ID__r.Portfolio__c == 'Ocean' && opty.Opportunity_Products__r[i].Product2ID__r.name!='Maersk Go'){
                            showOceanLink1 = 'true';
                            if(oceanProducts==null){
                                oceanProducts=opty.Opportunity_Products__r[i].Product2ID__r.name;
                        }
                            else{
                                if(!oceanProducts.contains(opty.Opportunity_Products__r[i].Product2ID__r.name)){
                                    oceanProducts+=+', '+opty.Opportunity_Products__r[i].Product2ID__r.name;
                                }
                                oceanProducts = oceanProducts.subString(0,oceanProducts.length());
                            }
                        }
                        
                        
                        if(opty.Opportunity_Products__r[i].OIPC_Product_Code__c == 'P-P0-dw7'){
                            showCaptainPeterLink = 'true';
                        }
                        if(opty.Opportunity_Products__r[i].OIPC_Product_Code__c == 'P-P0-12l0'){
                            showMaerskGoLink = 'true';
                        }
                         if(opty.Opportunity_Products__r[i].OIPC_Product_Code__c == 'P-P0-dx5'){
                            showValueProtectLink = 'true';
                        }
                        
                        
                        
                        
                        if(!optyProductNames.contains(opty.Opportunity_Products__r[i].Product2ID__r.Name)){
                            if(optyProductNames == '')
                                optyProductNames += opty.Opportunity_Products__r[i].Product2ID__r.Name;
                            else 
                                optyProductNames += ', '+opty.Opportunity_Products__r[i].Product2ID__r.Name;
                        } 
                    }   
 
                 }
                mapOfString.put('optyProductNames', optyProductNames);
                if(opty.First_Shipment_Date__c != null){
                    Date agreementfirstDt = opty.First_Shipment_Date__c;   
                    DateTime dt = DateTime.newInstance(agreementfirstDt.year(),agreementfirstDt.month(),agreementfirstDt.day()); 
                    string agreementStartDate = agreementfirstDt.day() + ' ' + dt.format('MMMM') + ' ' + agreementfirstDt.year();
                    mapOfString.put('agreementStartDate', agreementStartDate);
                }
                if(opty.Last_Shipment_Date__c != null){
                    Date agreementEndDt = opty.Last_Shipment_Date__c;   
                    DateTime endDt = DateTime.newInstance(agreementEndDt.year(),agreementEndDt.month(),agreementEndDt.day()); 
                    string agreementEndDate = agreementEndDt.day() + ' ' + endDt.format('MMMM') + ' ' + agreementEndDt.year();   
                    mapOfString.put('agreementEndDate', agreementEndDate);
                }
                if(opty.Account.Name != null){
                    string accountName = opty.Account.Name; 
                    mapOfString.put('accountName', accountName);
                }
                
                mapOfOptywithProductNames.put(opty.Id, mapOfString);
            }
        }
        
        Map<ID, Contact> mapOfContact = new Map<ID, Contact>([SELECT Id, LastName, Name, Email FROM Contact where Id in : toAddressIds]);
        Map<ID, User> mapOfUser = new Map<ID, User>([SELECT Id, Name, Email FROM User where Id in : salesUserIds]);
        
        //To accept all domains in flow we must need to provide orgwide email address.
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address=: Label.OneClickOWDdisplayName LIMIT 1];
       
        // To send seperate email for each toaddress participant and ccaddress participants.
        for(Offer_Information__c req:request){
            //storing all To email addresses with offer Id 
           mapOfEmail.put(req.id,mapOfContact.get(req.To_Recipient__c).Email);
            //storing key as offerId : Toaddress email
            if(mapOfContact.containskey(req.To_Recipient__c)){
                holdsKey.add(req.Id + mapOfContact.get(req.To_Recipient__c).Email);
                mapOfOfferInformation.put(req.Id + mapOfContact.get(req.To_Recipient__c).Email,req);
            }            
            if(req.CC_Recipients__c != null){
                //storing key as offerId : CCaddress emails
                List<string> setOfCCaddresses  = req.CC_Recipients__c.split(',');
                for(string s: setOfCCaddresses){
                    holdsKey.add(req.Id + s);
                    mapOfOfferInformation.put(req.Id + s,req);
                }
            }
        }
     
        
        Map<String,String> encryptedValue = new Map<String,String>();
        String encryptData;
        List<String> lst = new List<string>();
        EncryptionAndDecryptionController cls = new EncryptionAndDecryptionController();
        if(holdsKey!= null){
            encryptedValue =  cls.encryptData(holdsKey); 
        }
        
        List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>();
        for(String str : encryptedValue.keyset()){
            if(mapOfOfferInformation.containskey(str) &&  mapOfContact.containskey(mapOfOfferInformation.get(str).To_Recipient__c)
               && mapOfUser.containskey(mapOfOfferInformation.get(str).CreatedById)){
                   
                   String encryptedData = EncodingUtil.urlEncode(encryptedValue.get(str), 'UTF-8');
                   //splitting mail adddress from key of map
                   String offerId =  str.substring(0, 18);
                   String toEmailAddress = mapOfEmail.get(offerId);
                   String mailAddress =  str.substring(18);
                   PageReference pg = Page.oneClickAboutToExpireTemplate;
                   pg.getParameters().clear();
                   pg.getParameters().put('optyId', mapOfOfferInformation.get(str).Opportunity__c);
                   pg.getParameters().put('src', 'html');
                   pg.getParameters().put('ContactlastName', mapOfContact.get(mapOfOfferInformation.get(str).To_Recipient__c).Name);
                   pg.getParameters().put('url',encryptedData);
                   pg.getParameters().put('salesUserName',mapOfUser.get(mapOfOfferInformation.get(str).CreatedById).Name);
                   pg.getParameters().put('optyProductNames', mapOfOptywithProductNames.get(mapOfOfferInformation.get(str).Opportunity__c).get('optyProductNames'));
                   pg.getParameters().put('agreementStartDate', mapOfOptywithProductNames.get(mapOfOfferInformation.get(str).Opportunity__c).get('agreementStartDate'));
                   pg.getParameters().put('agreementEndDate', mapOfOptywithProductNames.get(mapOfOfferInformation.get(str).Opportunity__c).get('agreementEndDate'));
                   pg.getParameters().put('accountName', mapOfOptywithProductNames.get(mapOfOfferInformation.get(str).Opportunity__c).get('accountName'));
                   pg.getParameters().put('showMCSLink', showMCSLink1);
                   pg.getParameters().put('showLNSLink', showLNSLink1);
                   pg.getParameters().put('showOceanLink', showOceanLink1);
                   pg.getParameters().put('showCaptainPeterLink', showCaptainPeterLink);
                   pg.getParameters().put('showMaerskGoLink', showMaerskGoLink);
                   pg.getParameters().put('showValueProtectLink', showValueProtectLink);
                   pg.getParameters().put('maerskCustomServicesProducts', maerskCustomServicesProducts);
                   pg.getParameters().put('lnsProducts', lnsProducts);
                   pg.getParameters().put('oceanProducts', oceanProducts);
                   
                   //sfse-11632
                   if(toEmailAddress != mailAddress){ 
                        pg.getParameters().put('showBanner', 'true');                                            
      }
                   
                   string htmlbody;
                   if(!Test.isRunningTest()){
                       htmlbody = pg.getContent().toString();
                   }else{
                       htmlbody = 'Subject : Sample';
                   }
                   Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                   if ( owea != null) {
                       singleMail.setOrgWideEmailAddressId(owea.Id);
                   }
                   
                   //SFSE-11769
                   String emailSubjectStr = 'Your Maersk offer expires in 24 hours. Claim it now.';
                   singleMail.setSubject(emailSubjectStr);
                   singleMail.setToAddresses(new List<String>{mailAddress});
                   //Adding Attachments in email body 
                   if(offerContentVersionMap.containsKey(offerId)){ 
                      singleMail.setEntityAttachments(offerContentVersionMap.get(offerId));  
                   }
                   //singleMail.setBccAddresses(new List<string>{mapOfUser.get(mapOfOfferInformation.get(str).CreatedById).Email});
                   singleMail.setHtmlBody(htmlbody); 
                   singleMailList.add(singleMail);
               }
        }
        try{
            Messaging.sendEmail(singleMailList);
        }catch(exception ex){
            ErrorLogger.writeError('SFDC', 'sendOfferEmailAboutToExpire', 'sendOfferEmailAboutToExpire.sendEmailOfferToExpire', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
        }
        
    }
    
    public PageReference setLastName() {
        lastname = Apexpages.currentPage().getParameters().get('ContactlastName');
        return null;
    }
    
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}
}