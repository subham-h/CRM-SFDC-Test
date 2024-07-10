/*              
* Revision Ref Number  Date          Owner                   Description
* -------- ----------  -----------   -----------------       -----------
* 1.0      SFSE-11211  02-August-2023   Vinay                 Re-Vamped the code after the Landing Page is taking too much time to load. 			
*/
public class OfferConfirmationQueuableHelper implements Queueable, Database.AllowsCallouts{
    String email;
    String offerId;
    
    public OfferConfirmationQueuableHelper(String email, String offerId) {  
        this.email = email;  
        this.offerId = offerId;  
    } 
    
    public void execute(QueueableContext context) {
        confirmActions(email, offerId);
    }
    
    private static void confirmActions(String email, String offerId){
        String [] ccMailAddress;
        Set<String> setContactEmails = new Set<String>();
        List<Contact> listCon = new List<Contact>();
        
        Offer_Information__c offer =[SELECT Id,Opportunity__c, Opportunity__r.StageName,Opportunity__r.Owner.Email,Opportunity__r.Reason_For_Close__c,
                                     Opportunity__r.Opportunity_Ref__c,Opportunity__r.Name,Opportunity__r.Offer_Status__c,Offer_Status__c,CreatedBy.Email,
                                     CreatedBy.FirstName,CreatedBy.LastName,CC_Recipients__c,To_Recipient__r.Email 
                                     FROM Offer_Information__c WHERE Id =: offerId];
        
        listCon =[SELECT Id,Name,Email FROM Contact WHERE Email=:email];
        
        if(offer.To_Recipient__c!=NULL){
            setContactEmails.add(offer.To_Recipient__r.Email);
        }          
        
        ccMailAddress = offer.CC_Recipients__c!=NULL?offer.CC_Recipients__c.Split(','):NULL;
        if(ccMailAddress!=NULL){
            for(String emails : ccMailAddress){
                setContactEmails.add(emails.trim());
            }
        }
        
        try{
            offer.Offer_Status__c=System.Label.Offer_Accepted;
            offer.Date_Accepted__c = system.today();
            if(listCon.size()>0){
                offer.Accepted_by__c = listCon[0].Id;   
            }
            update offer;
            
            Opportunity opty = new Opportunity(id=offer.Opportunity__c,
                                               StageName=system.label.Opportunity_Closed_Won,
                                               Reason_For_Close__c=system.label.Opportunity_Closed_Reason,
                                               Offer_Status__c = System.Label.Offer_Accepted); // Updating the opportunity Offer Status:SFSE-11312
            Database.SaveResult sr= Database.update(opty);
            if(sr.isSuccess()){
                sendConfirmationEmails(offer,listCon[0],'Success',setContactEmails);    
            }else{
                update new Opportunity(id=offer.Opportunity__c,Offer_Status__c = System.Label.Offer_Accepted);
                sendConfirmationEmails(offer,listCon[0],'Failed',setContactEmails);
            }
            
        }
        catch(exception e){
            //if records update fails update Opportunity one more time.
            //And Send confirmation Email to Customer and another email to Opportunity Team members to update opportunity Stage as Closed/Won.
            update new Opportunity(id=offer.Opportunity__c,Offer_Status__c = System.Label.Offer_Accepted);
            sendConfirmationEmails(offer,listCon[0],'Failed',setContactEmails);
        }
        
    }
    
    private static void sendConfirmationEmails(Offer_Information__c offer, Contact con,String result,Set<string> mailAdresses){
        
        List<Messaging.SingleEmailMessage> listMailsToSent = new List<Messaging.SingleEmailMessage>();
        List<String> listOptyTeamEmails = new List<string>();
        List<String> listFileIds = new List<string>();
        
        
        User user = [SELECT Name,FirstName,LastName from User where id =: offer.CreatedById];
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:system.label.OneClickOWDdisplayName LIMIT 1];
        
        if(offer.Opportunity__c!=NULL){
            for(OpportunityTeamMember member:[SELECT Id, User.Email FROM OpportunityTeamMember WHERE OpportunityId=:offer.Opportunity__c]){
                listOptyTeamEmails.add(member.User.Email);
            }}
        // Attachments of offer are placed in Content Version object in order to fetch the content versionIds, first we are 
        // fetching the ContentDocumentId from ContentDocumentLink
        List<Id> listDocIds= new List<Id>();
        for(ContentDocumentLink CDL: [SELECT Id,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:offer.Id]){
            listDocIds.add(CDL.ContentDocumentId);
        }
        // After getting the contentDocumentIds we are fetching the content Version records
        // Note: Directly Guest user is not getting content version ids hence followed this approach.
        List<Id> listContentVersionIds = new List<Id>();
        for(ContentVersion CV: [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:listDocIds]){
            listContentVersionIds.add(CV.Id);
        }
        
        // Contructing the Email that has to  be sent to Customer.
        for(string toAndCCMailAddress : mailAdresses){
            
            Messaging.SingleEmailMessage mailToCustomer = new Messaging.SingleEmailMessage();
            mailToCustomer.setSubject(system.label.I_Accept_SubjectToCustomer.replace('{ContactName}',con.Name));
            //mailToCustomer.setToAddresses(new List<String>{con.email});
            mailToCustomer.setToAddresses(new List<String>{toAndCCMailAddress});
            mailToCustomer.setCcAddresses(new List<String> {offer.CreatedBy.Email});
            PageReference pg = Page.oneClickOfferConfirmationEmailTemplate;
            pg.getParameters().clear();
            pg.getParameters().put('optyId', offer.Opportunity__c);
            pg.getParameters().put('name', con.Name);
            pg.getParameters().put('offercreatedby', offer.CreatedBy.FirstName +' '+ offer.CreatedBy.LastName);
            
            String strHtmlBody;
            if(!Test.isRunningTest()){
                strHtmlBody = pg.getContent().toString();
            }
            else{
                strHtmlBody='Test Email'; 
            }
            mailToCustomer.setHtmlBody(strHtmlBody);
            mailToCustomer.setOrgWideEmailAddressId(owea.Id);
            if(!listContentVersionIds.isEmpty()){
                mailToCustomer.setEntityAttachments(listContentVersionIds);   
            }
            listMailsToSent.add(mailToCustomer);
        }
        
        // Constructing the Email that has to be sent to opportunity Team members
        Messaging.SingleEmailMessage mailToOptyTeam = new Messaging.SingleEmailMessage();
        mailToOptyTeam.setToAddresses(listOptyTeamEmails);
        //mailToOptyTeam.setSubject('The offer for '+op.Opportunity_Ref__c+' has been accepted by the customer');
        mailToOptyTeam.setSubject(system.label.I_Accept_SubjectToOptyTeam.replace('{optyRef}', offer.Opportunity__r.Opportunity_Ref__c));
        String Recordlink = URL.getOrgDomainUrl().toExternalForm()+'/'+offer.Opportunity__r.Id;
        if(result=='Success'){  
            String msg = system.label.I_Accept_Success_Message.replace('{OptyName}', offer.Opportunity__r.Name).replace('{URL}', Recordlink);
            //mailToOptyTeam.setHtmlBody('The customer has accepted the offer and the opportunity '+op.Name+' has been closed won.  Please take any necessary follow up actions including rate filing if required. Thank you'); }
            mailToOptyTeam.setHtmlBody(msg); }
        else{
            String msg = system.label.I_Accept_Failed_Message.replace('{OptyName}', offer.Opportunity__r.Name).replace('{URL}', Recordlink);
            //mailToOptyTeam.setHtmlBody('The customer has accepted the offer and the opportunity '+op.Name+' can now be moved to Closed Won stage. Please take any necessary follow up actions including rate filing if required and closing the opportunity. Thank you');}
            mailToOptyTeam.setHtmlBody(msg); }
        mailToOptyTeam.setOrgWideEmailAddressId(owea.Id);
        listMailsToSent.add(mailToOptyTeam);
        
        //Sending both Email at a time.
        if(!listMailsToSent.isEmpty()){
            Messaging.sendEmail(listMailsToSent);    
        } 
        
    }
    
}