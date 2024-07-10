/*  
* Class is contrller for Flow - Send Email for Offer Information Expired(Deactivated)
  Class is contrller for Batch - BatchSendEmailForOfferInfoExpired
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		19-Jun-2023		Vazid@UST				Send notification to customer if offer is already expired
This flow is invoking from "Send Email for Offer Information Expired" Flow (Deactivated)
* 2.0       26-July-2023    Seba           			SFSE-11769:Added code  for email template UI modifications 
* 3.0       28-July-2023    Seba           			SFSE-11769: Bug fix
*4.0        15-Oct-2023     Bharti                  Added code to update Offer status field of failed Opportunities as 'Expired' .
*/
public class sendOfferEmailforExpired {
    
    public string lastname {get; set;}
    public String optyProductNames {get; set;}
    public String OptyId {get; set;}
    public String agreementStartDate {get; set;}
    public String agreementEndDate {get; set;}
    public String closeDate {get; set;}
    public String loggedInUserName{get; set;}
    
    public sendOfferEmailforExpired(){   
        
        lastname = ApexPages.currentPage().getParameters().get('ContactlastName');
        OptyId = ApexPages.currentPage().getParameters().get('optyId');
        loggedInUserName = ApexPages.currentPage().getParameters().get('SalesUserName');
        optyProductNames = ApexPages.currentPage().getParameters().get('optyProductNames');
        agreementStartDate = ApexPages.currentPage().getParameters().get('agreementStartDate');
        agreementEndDate = ApexPages.currentPage().getParameters().get('agreementEndDate');
        closeDate = ApexPages.currentPage().getParameters().get('closeDate');//SFSE-11769
    }
    
    //@InvocableMethod(label='sendEmailOfferExpired' description='Inform the customer that the "I agree" offer is expired')
    
    public static void sendEmailOfferExpired(List<Offer_Information__c> request){ 
        
        set<Id> toAddressIds = new set<Id>();
        set<Id> optyIds = new set<Id>();
        set<Id> salesUserIds = new set<Id>();
        List<Offer_Information__c> offerInfoLstToUpdate = new List<Offer_Information__c>();
        List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>(); 
        List<Opportunity> failedOpportunityList = new List<Opportunity>();
        
        //Storing recipient ids and createdby ids,  recipient ids : to send notificaiton and createdby ids : to use it as sales users.
        for(Offer_Information__c req:request){
            
            req.Offer_Status__c = 'Expired';
            toAddressIds.add(req.To_Recipient__c);
            optyIds.add(req.Opportunity__c);
            salesUserIds.add(req.CreatedById);
            offerInfoLstToUpdate.add(req);
        }
        // Mapping Opportunity as key and productNames, agreementstartdata and agreementenddate as values
        Map<Id,Map<string,string>> mapOfOptywithProductNames = new Map<Id,Map<string,string>>(); 
        List<Opportunity> optyList =[select (select Product2ID__r.name from Opportunity_Products__r),id,Opportunity_Ref__c,Name,Owner.Name,First_Shipment_Date__c ,Last_Shipment_Date__c,closeDate,Account.Name,StageName from Opportunity where id in : optyIds];
        Set<Id> failedOpportunityIds = new Set<Id>();
        if(!optyList.isEmpty()){
            
            for(Opportunity opty : optyList){
                
                Map<string,string> mapOfString = new Map<string,string>();
                
                opty.Offer_Status__c = 'Expired';
                opty.StageName = 'Closed Lost';
                opty.Reason_For_Close__c = 'Offer has expired';
                
                string optyProductNames ='';
                if(opty.Opportunity_Products__r.size()  > 0){
                    for(integer i = 0;i<opty.Opportunity_Products__r.size();i++){ 
                        //SFSE-11769
                        if(!optyProductNames.contains(opty.Opportunity_Products__r[i].Product2ID__r.Name)){//To avoid duplicate products
                            optyProductNames += i == 0 ? opty.Opportunity_Products__r[i].Product2ID__r.name : ', '+opty.Opportunity_Products__r[i].Product2ID__r.name;
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
                /*SFSE-11769*/
                if(opty.closeDate != null){
                    Date closeDt = opty.closeDate;   
                    DateTime endDt = DateTime.newInstance(closeDt.year(),closeDt.month(),closeDt.day()); 
                    string closeDateStr = closeDt.day() + ' ' + endDt.format('MMMM') + ' ' + closeDt.year();   
                    mapOfString.put('closeDate', closeDateStr);
                }
                
                mapOfOptywithProductNames.put(opty.Id, mapOfString);
            }
        }
        
        Map<ID, Contact> mapOfContact = new Map<ID, Contact>([SELECT Id, LastName, Name, Email FROM Contact where Id in : toAddressIds]);
        Map<ID, User> mapOfUser = new Map<ID, User>([SELECT Id, Name, Email FROM User where Id in : salesUserIds]);
        
        //To accept all domains in flow we must need to provide orgwide email address.
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address=:Label.OneClickOWDdisplayName LIMIT 1];
        
        for(Offer_Information__c req:request){
            if(mapOfOptywithProductNames.containskey(req.Opportunity__c) && mapOfContact.containskey(req.To_Recipient__c)
               && mapOfUser.containskey(req.CreatedById)){
                   PageReference pg = Page.oneClickExpiredTemplate;
                   pg.getParameters().clear();
                   pg.getParameters().put('optyId', req.Opportunity__c);
                   pg.getParameters().put('src', 'html');
                   pg.getParameters().put('ContactlastName', mapOfContact.get(req.To_Recipient__c).Name);
                   pg.getParameters().put('salesUserName',mapOfUser.get(req.CreatedById).Name);
                   pg.getParameters().put('optyProductNames', mapOfOptywithProductNames.get(req.Opportunity__c).get('optyProductNames'));
                   pg.getParameters().put('agreementStartDate', mapOfOptywithProductNames.get(req.Opportunity__c).get('agreementStartDate'));
                   pg.getParameters().put('agreementEndDate', mapOfOptywithProductNames.get(req.Opportunity__c).get('agreementEndDate'));
                   pg.getParameters().put('closeDate', mapOfOptywithProductNames.get(req.Opportunity__c).get('closeDate'));//SFSE-11769
                   
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
                   
                   // To send seperate email toaddress participants.
                   String emailSubjectStr = 'Your Maersk offer has expired.'; 
                   singleMail.setSubject(emailSubjectStr);
                   List<string> setOfToAddresses = new List<string>();
                   singleMail.setToAddresses(new List<string>{mapOfContact.get(req.To_Recipient__c).Email});
                   singleMail.setHtmlBody(htmlbody); 
                   singleMail.setBccAddresses(new List<string>{mapOfUser.get(req.CreatedById).Email});
                   
                   singleMailList.add(singleMail);
                   
                   // To send seperate email for ccaddress participants.
                   if(req.CC_Recipients__c != null){
                       List<string> setOfCCaddresses = req.CC_Recipients__c.split(',');
                       for(string s : setOfCCaddresses){
                           singleMail = new Messaging.SingleEmailMessage();
                           if ( owea != null) {
                               singleMail.setOrgWideEmailAddressId(owea.Id);
                           }
                           singleMail.setSubject(emailSubjectStr);
                           singleMail.setToAddresses(new List<string>{s});
                           singleMail.setHtmlBody(htmlbody);
                           singleMailList.add(singleMail);
                       }
                   }
               } 
        }
        string successMsg = 'success';
        try{
            
            if(!singleMailList.isEmpty()){
                Messaging.sendEmail(singleMailList);
            }
        }catch(exception ex){
            successMsg = ex.getMessage();
            ErrorLogger.writeError('SFDC', 'sendOfferEmailforExpired', 'sendOfferEmailforExpired.sendEmailOfferExpired', JSON.serialize(ex),ex.getMessage(),ex.getMessage());
        }
        if(!offerInfoLstToUpdate.isEmpty() && successMsg == 'success'){
            //update offerInfoLstToUpdate;
            
            Database.SaveResult[] updateResults = Database.update(offerInfoLstToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'Offer_Information__c', 'sendofferEmailforExpired', updateResults, offerInfoLstToUpdate );
            
        }
       
        
        if(!optyList.isEmpty() && successMsg == 'success'){
            
            //update optyList;
            //12961
            Database.SaveResult[] updateResults = Database.update(optyList, false);
            ErrorLogger.writeErrors('SFDC', 'Fail Update', 'sendofferEmailforExpired', updateResults, optyList );
          
            // Iterate through the update results to collect failed Opportunity IDs
            for(Database.SaveResult sr : updateResults){
                if (!sr.isSuccess()) {
                    // The update failed for this record.
                    failedOpportunityIds.add(sr.getId());
                }
            }
          
            updateOpportunityOfferStatus(failedOpportunityIds);
        }
        
    }
    /* 12961- Method for Edge case: When Opportunity fails to Update as Closed-Lost , Updating Offer status field of 
     * those opportunity record.*/
    public static void updateOpportunityOfferStatus(Set<Id> lstOpp){
        List<opportunity> lst = [Select id,Offer_Status__c,StageName from Opportunity where id IN :lstOpp];
        List<Opportunity> lstToUpdate = new List<Opportunity>();
        for(Opportunity opp : lst){
            if(opp.Offer_Status__c == 'Sent'&& opp != null && opp.StageName != system.label.Opportunity_Closed_Lost){
             opp.Offer_Status__c = 'Expired';
            lstToUpdate.add(opp);
            }
        }
        
        Database.SaveResult[] sr = Database.update(lstToUpdate, false); 
        for(Database.SaveResult updatedresult : sr){
        if(!updatedresult.isSuccess()){
        ErrorLogger.writeErrors('SFDC', 'Failed to update', 'sendofferEmailforExpired', sr, lstToUpdate );
        }
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