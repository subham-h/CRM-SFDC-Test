/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0      SFSE-11312  16-June-2023    Seba                  Modified the code for updating Opportunity Offer Status field
 * 2.0      SFSE-11211                  Arpitha               Modified the logic to handle status 
 * 3.0      SFSE-11233  23-June-2023    Vinay                 Added Method sendConfirmationEmails 
 * 4.0      SFSE-11627  06-june-2023    Bharti                Added code to send mail to people who are in CC.
 * 5.0		SFSE-11211	05-July-2023    Vinay				  Added logic to update opportunity one more time in Catch block.	
 * 6.0		SFSE-11668	10-July-2023    Vinay				  Added logic to return status when offer status is recalled.
 * 7.0      SFSE-12098  25-August-2023  Aditi                 Added condition in SOQL to query only 'Active' OpportunityTeamMembers	
 * 8.0      SFSE-12956  17-October-2023	Bharti                Added condition to expire Email on the date of close date also .	
*/
public WITHOUT SHARING class OfferConfirmationPageController {
    
    @AuraEnabled
    public static String updateRecordsAndNotify(String offerDetails){
        
      //offerDetails, an input, is a encrypted value in form of offerId+ContactEmail address        
        System.debug('offer details' + offerDetails );
      String status;
      Opportunity opty;
      Offer_Information__c offer;  
      String decodedString;
      String [] ccMailAddress;
      Set<String> setContactEmails = new Set<String>();
      String offerId;
      String email;
      List<Contact> listCon = new List<Contact>();
        
      // Decrypting the encrypted OfferId+Email.  
      EncryptionAndDecryptionController edc= new EncryptionAndDecryptionController();
      decodedString = edc.decryptData(offerDetails);
        
      // Splitting the OfferId and Email and assigning to respective variables.  
      if(decodedString!=NULL){
      offerId= decodedString.subString(0,18);
      email = decodedString.subString(18,decodedString.length());
      }  
        
        if(email!=NULL){  
      listCon =[SELECT Id,Name,Email FROM Contact WHERE Email=:email];}
      
      if(offerId!=NULL){  
      offer =[SELECT Id,Opportunity__c,Offer_Status__c,CreatedBy.Email,CreatedBy.FirstName,CreatedBy.LastName,CC_Recipients__c,To_Recipient__r.Email FROM Offer_Information__c WHERE Id =: offerId];
      }          
      
      if(offer!=NULL){
         
          if(offer.To_Recipient__c!=NULL){
          setContactEmails.add(offer.To_Recipient__r.Email);
		  }          
          
          ccMailAddress = offer.CC_Recipients__c!=NULL?offer.CC_Recipients__c.Split(','):NULL;
          if(ccMailAddress!=NULL){
          for(String emails : ccMailAddress){
              setContactEmails.add(emails.trim());
          }}
                    
          opty = [SELECT Id,Owner.Email,StageName,Reason_For_Close__c,Opportunity_Ref__c,Name,Offer_Status__c,CloseDate FROM Opportunity WHERE Id=: offer.Opportunity__c];
                     
          // If the offer is already Accepted or offer is expired or Recalled then returning the status back to Aura.
          // SFSE-11668 - Added Recalled.
          if(offer.Offer_Status__c ==System.Label.Offer_Accepted || offer.Offer_Status__c ==System.Label.OfferExpired || offer.Offer_Status__c==System.Label.Offer_Recalled){
          	Status = offer.Offer_Status__c;}
          //Handling scenerio where if close date is today user will not be able to accept the offer
          if(opty.CloseDate <= Date.Today()){
              status=label.OfferExpired;
          }
          
          // if the offer status is Sent then update Offer and Opportunity records and 
          // return the status as Offer and Opportunity Updated back to Aura and send confirmation email to customer and 
          // another Email to Opportunity Team Members.
          else if(offer.Offer_Status__c ==System.Label.Offer_Sent){
              system.debug('We are Here--->');
              try{
                    offer.Offer_Status__c=System.Label.Offer_Accepted;
                    offer.Date_Accepted__c = system.today();
                    if(listCon.size()>0){
                    offer.Accepted_by__c = listCon[0].Id;   
                    }
                    update offer;
                  
                    opty.StageName=system.label.Opportunity_Closed_Won;
                    opty.Reason_For_Close__c=system.label.Opportunity_Closed_Reason; 
                    opty.Offer_Status__c = System.Label.Offer_Accepted; // Updating the opportunity Offer Status:SFSE-11312
                    update opty;
                  
                  sendConfirmationEmails(opty,offer,listCon[0],'Success',setContactEmails);
                  status ='Offer and Opportunity Updated';
              }
              
              catch(exception e){
     //if records update fails then call checkAndUpdateOpportunity future method and return the status to Aura as "Failed to Update"
     //And Send confirmation Email to Customer and another email to Opportunity Team members to update opportunity Stage as Closed/Won.
           	      checkAndUpdateOpportunity(opty.Id);             		
                  sendConfirmationEmails(opty,offer,listCon[0],'Failed',setContactEmails);
                  status ='Failed to Update';
              }
          }
      }    
      return status;  
    }
/* sendConfirmationEmails - This method will send the confirmation Emails to Customer and another email to Opportunity Team Members
 *  when customer clicks on I accept button in Offer Email sent.
*/
    public static void sendConfirmationEmails(Opportunity op, Offer_Information__c offer, Contact con,String result,Set<string> mailAdresses){
        
        List<Messaging.SingleEmailMessage> listMailsToSent = new List<Messaging.SingleEmailMessage>();
        List<String> listOptyTeamEmails = new List<string>();
        List<String> listFileIds = new List<string>();
       
        
        User user = [SELECT Name,FirstName,LastName from User where id =: offer.CreatedById];
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address=:system.label.OneClickOWDdisplayName LIMIT 1];
        
        if(op!=NULL){
          for(OpportunityTeamMember member:[SELECT Id, User.Email FROM OpportunityTeamMember WHERE OpportunityId=:op.Id AND User.isActive = TRUE]){
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
        pg.getParameters().put('optyId', op.Id);
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
        mailToOptyTeam.setSubject(system.label.I_Accept_SubjectToOptyTeam.replace('{optyRef}', op.Opportunity_Ref__c));
        String Recordlink = URL.getOrgDomainUrl().toExternalForm()+'/'+op.Id;
        if(result=='Success'){  
            String msg = system.label.I_Accept_Success_Message.replace('{OptyName}', op.Name).replace('{URL}', Recordlink);
            //mailToOptyTeam.setHtmlBody('The customer has accepted the offer and the opportunity '+op.Name+' has been closed won.  Please take any necessary follow up actions including rate filing if required. Thank you'); }
            mailToOptyTeam.setHtmlBody(msg); }
        else{
            String msg = system.label.I_Accept_Failed_Message.replace('{OptyName}', op.Name).replace('{URL}', Recordlink);
            //mailToOptyTeam.setHtmlBody('The customer has accepted the offer and the opportunity '+op.Name+' can now be moved to Closed Won stage. Please take any necessary follow up actions including rate filing if required and closing the opportunity. Thank you');}
           mailToOptyTeam.setHtmlBody(msg); }
        mailToOptyTeam.setOrgWideEmailAddressId(owea.Id);
        listMailsToSent.add(mailToOptyTeam);
        
       //Sending both Email at a time.
       if(!listMailsToSent.isEmpty()){
            Messaging.sendEmail(listMailsToSent); 
            
        } 
        
    }
    
/* checkAndUpdateOpportunity - As an edge case, When customer accepts offer and When opportunity fails to update,
   We need to atleast update Opportunity Offer status to Accepted/Completed, 
   Even if this update fails, we are creating a record in Global Error Log object.   
*/    
    @future
    public static void checkAndUpdateOpportunity(String optyId){
        
        Opportunity op = [SELECT Id,StageName FROM Opportunity WHERE ID =: optyId];
        
        if(op!=NULL && op.StageName!=system.label.Opportunity_Closed_Won){
          op.Offer_Status__c = System.Label.Offer_Accepted; 
          Database.SaveResult sr = Database.update(op);               
          if(!sr.isSuccess()){
          ErrorLogger.writeErrors('SFDC', 'I Accept Offer', 'updateRecordsAndNotify', new list<Database.SaveResult>{sr}, new list<Opportunity>{op});  
          }  
        }        
    }
}