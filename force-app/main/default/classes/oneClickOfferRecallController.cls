/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0      SFSE-10847  16-June-2023  Seba                    Created class for Recall offer email template 
 * 2.0      SFSE-10847  19-June-2023  Seba                    Modified code to consider the OLI structure change to Opportunity Product object
 * 3.0      SFSE-11804  17-July-2023  Seba                    Added code for bug fix
 * 4.0      SFSE-11769  26-July-2023  Seba               	  Added code for email template UI modifications 
 * 5.0      SFSE-11769  2-July-2023  Seba               	  Bug fix
*/
public class oneClickOfferRecallController {
    public String customerName{get;set;}
    public String optyProductNames{get;set;}
    public String agreementStartDate{get;set;}
    public String agreementEndDate{get;set;} 
    public String loggedInUserName{get;set;}
        
    public oneClickOfferRecallController(){   
        loggedInUserName = ApexPages.currentPage().getParameters().get('loggedInUserName'); 
        customerName = ApexPages.currentPage().getParameters().get('customerName'); 
        optyProductNames = ApexPages.currentPage().getParameters().get('optyProductNames'); 
        agreementStartDate = ApexPages.currentPage().getParameters().get('agreementStartDate'); 
        agreementEndDate = ApexPages.currentPage().getParameters().get('agreementEndDate'); 
    }
    
    @auraEnabled
    public static Map<String,String> updateRecordsAndSendCustomerEmailNotification(String recipientName, String toRecipientEmailInOffer, Date agreementStartDate, Date agreementEndDate, String opportunityRecordId,String offerRecordId, Boolean isOfferRecallAndNew,List<String> cc_AddressContactIds){
        Map<String,String> responseMap = new Map<String,String>();
        string htmlbody = '';  String opportunityProductNames = '';String emailSubject = '';
        String agreementStartDt = '';String agreementEndDt = '';
        Offer_Information__c offerRecToUpdate = new Offer_Information__c();
        List<SObject> objectRecordsToUpdateLst = new List<SObject>();
        Opportunity oppRecToUpdate = new Opportunity();
        String currentUserName = UserInfo.getName();  
        PageReference pg = ApexPages.currentPage();
       
       
       
        //Create instances of Opportunity and Offer Info records and update the status
        offerRecToUpdate.Id = offerRecordId; offerRecToUpdate.Offer_Status__c = 'Recalled';  
        oppRecToUpdate.Id = opportunityRecordId; oppRecToUpdate.Offer_Status__c = 'Recalled'; 
        objectRecordsToUpdateLst.add(offerRecToUpdate); objectRecordsToUpdateLst.add(oppRecToUpdate); 
        //Querying opp line items to display in the VF page
        //Updated on June 19 for the OLI data structure change
        List<Opportunity_Product__c> oppLineItemLst = new List<Opportunity_Product__c>([select Product2ID__r.name from Opportunity_Product__c where OpportunityId__c = :opportunityRecordId]);//SFSE-11769
        if(oppLineItemLst.size() > 0){
            for(integer i = 0;i<oppLineItemLst.size();i++){  
                if(!opportunityProductNames.contains(oppLineItemLst[i].Product2ID__r.name))
                opportunityProductNames += i == 0 ? oppLineItemLst[i].Product2ID__r.name : ', '+oppLineItemLst[i].Product2ID__r.name;
            }
        }
         
        if(agreementStartDate != null){   
           DateTime startDt = DateTime.newInstance(agreementStartDate.year(),agreementStartDate.month(),agreementStartDate.day()); 
           agreementStartDt = agreementStartDate.day() + ' ' + startDt.format('MMMM') + ' ' + agreementStartDate.year();   
        }
        if(agreementEndDate != null){ 
           DateTime endDt = DateTime.newInstance(agreementEndDate.year(),agreementEndDate.month(),agreementEndDate.day()); 
           agreementEndDt = agreementEndDate.day() + ' ' + endDt.format('MMMM') + ' ' + agreementEndDate.year();   
        }
        
       
        if(isOfferRecallAndNew == false){ //If offer is recalled
             pg = Page.oneClickOfferRecallEmailTemplate;
             pg.getParameters().clear();     
             pg.getParameters().put('agreementStartDate', agreementStartDt);
             pg.getParameters().put('agreementEndDate', agreementEndDt);   
        }
        else{ //If offer is being updated as per customer request
            pg = Page.oneClickOfferRecallAndNewEmailTemplate;
            pg.getParameters().clear();    
        }
        pg.getParameters().put('customerName', recipientName);
        pg.getParameters().put('optyProductNames', opportunityProductNames);
        pg.getParameters().put('loggedInUserName',currentUserName); 
        if(!Test.isRunningTest()){
               htmlbody = pg.getContent().toString();
        }
        //SFSE-11769 
        emailSubject = isOfferRecallAndNew == false ? 'Your Maersk offer has expired.' : 
                                                      'We are updating your Maersk offer.';  
        
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage(); 
        singleMail.setSubject(emailSubject);
         singleMail.setToAddresses(new List<String>{toRecipientEmailInOffer}); 
         singleMail.setCcAddresses(cc_AddressContactIds);
       
        singleMail.setHtmlBody(htmlbody);
        
        try{
            /*SFSE-11804 If offer or opp update fails, rollback the update operation, throw exception and prevent email sending*/
            Database.update(objectRecordsToUpdateLst, true); 
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleMail}); 
            responseMap.put('response','success');
        }
        catch(Exception e){
           
            responseMap.put('response','exception'); 
        }
        return responseMap;
    }   
}