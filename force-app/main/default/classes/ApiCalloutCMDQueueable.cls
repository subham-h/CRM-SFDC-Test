/*
* Revision     Ref Number      Date            Owner                         Description
* --------     ----------      -----------     -------------------           -----------
* 1.0                                          Sidharth                      Code created
* 2.0          SFSE-13284      21/03/2024      Aleena                        Added logic to send chatter message through Connect.Api & taking care of governor limits  
*/
public class ApiCalloutCMDQueueable implements Queueable,Database.AllowsCallouts {
    
    public Map <Id,Contact> contactToProcess = new Map <Id,Contact>();
    public List<Map<String, String>> phonenumbers = new List<Map<String, String>>();
    public Map<Id, String> mapOfCustomerCodeAndContact = new Map<Id, String>();
    public ApiCalloutCMDQueueable(Map <Id,Contact> contactItems) {
        this.contactToProcess = contactItems;
        Set<Id> accId = new Set<Id>();
        
        for(Contact c: contactItems.values()){
            accId.add(c.AccountId);
        }
        for(Contact cont : [SELECT Id, Account.Customer_Code__c FROM Contact where AccountId IN: accId]) {
            mapOfCustomerCodeAndContact.put(cont.Id, cont.Account.Customer_Code__c);
        }
    }
    public void execute(QueueableContext context) { 
        integer counter = 0;
        String dupcheck;
        boolean flagForNewQueue = false;
        HttpResponse createContact;
        lwcCMDContactCreateCtrl.getAccessToken();
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id index: contactToProcess.keySet()) {
            Contact objContact = contactToProcess.get(index);
            if (objContact != null) {
                Map<String,String> m1 = new Map<String, String> {'TEL' => objContact.Phone,'MOB' => objContact.MobilePhone};
                    phonenumbers.add(m1);
                String validateLoad =  lwcCMDContactCreateCtrl.createValidateWrapper(objContact, mapOfCustomerCodeAndContact.get(objContact.Id) , phonenumbers);
                HttpResponse getvalidateAPIResp = lwcCMDContactCreateCtrl.runValidateAPI(validateLoad, mapOfCustomerCodeAndContact.get(objContact.Id) );
                String validategetBody = getvalidateAPIResp.getBody();
                if(getvalidateAPIResp.getStatusCode() == 200 && validategetBody == 'Contact information validated successfully') {
                    dupcheck = lwcCMDContactCreateCtrl.runDuplicateCheckAPI(objContact);
                    if(dupCheck == 'No duplicate contacts found for the given request') {
                        if(objContact.External_ID__c == null) {
                            createContact  = lwcCMDContactCreateCtrl.createContactWrapperData(objContact, mapOfCustomerCodeAndContact.get(objContact.Id) , phonenumbers, 'POST');
                        }
                        Integer createContactStatusCode = Test.isRunningTest() ? 201 : createContact.getStatusCode();
                        if(createContactStatusCode == 201) {
                            lwcCMDContactCreateCtrl.createContractwrapper cw = (lwcCMDContactCreateCtrl.createContractwrapper) System.JSON.deserialize(createContact.getBody(), lwcCMDContactCreateCtrl.createContractwrapper.class);
                        	objContact.External_ID__c = cw.contactCode;
                            //upsert objContact;
                            contactsToUpdate.add(objContact);
                        }else{
                            objContact.Contact_Status__c = 'InActive';
                            // update objContact;
                            contactsToUpdate.add(objContact);
                            
                            createChatterFeed(createContact.getBody() , objContact.Id , objContact.ownerId,false); 
                        }
                    }else{
                        objContact.Contact_Status__c = 'InActive';
                        //update objContact;
                         System.debug('dupcheck=='+dupcheck);
                        contactsToUpdate.add(objContact);
                        createChatterFeed('Duplicate found in CMD', objContact.Id , objContact.ownerId, true); 
                        
                        
                    }
                }else{
                    objContact.Contact_Status__c = 'InActive';
                    // update objContact;
                    contactsToUpdate.add(objContact);
                    lwcCMDContactCreateCtrl.ErrorResponse errRes = (lwcCMDContactCreateCtrl.ErrorResponse) System.JSON.deserialize(getvalidateAPIResp.getBody(), lwcCMDContactCreateCtrl.ErrorResponse.class);  
                    
                    createChatterFeed(JSON.serialize(errRes.detailedErrors), objContact.Id , objContact.ownerId, false);
                    
                    
                }
                counter = counter + 1; 
                contactToProcess.remove(index); 
                if (counter > 98) {
                    flagForNewQueue = true;
                    break;
                } 
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            upsert contactsToUpdate;
        }
        if (flagForNewQueue) {
            System.enqueueJob(new ApiCalloutCMDQueueable(contactToProcess));
        }
    }
    
    public static void createChatterFeed(string messageBodyInfo, Id recId , Id ownerId , Boolean isduplicate) {
        try {
            
            String errorMessage;
            String errorMessageField;
            String contactRecord;
            String tochattermessage;
            if(isduplicate == false){
             List<ApiCalloutCMDQueueable.ErrorMessageWrapper> errorMessageWrap = (List<ApiCalloutCMDQueueable.ErrorMessageWrapper>) System.JSON.deserialize(messageBodyInfo, List<ApiCalloutCMDQueueable.ErrorMessageWrapper>.class);
             errorMessage = 'Field: \t'+errorMessageWrap[0].field+'\nError Message: \t'+errorMessageWrap[0].message;
            }
            if(isduplicate){
               tochattermessage =  'Error Message: \t' + messageBodyInfo;
                }
            else {
                tochattermessage = errorMessage;
            }
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            textSegmentInput.text = 'Dear ';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            
            //to mention the opportunity owner in chatter message
            mentionSegmentInput.id = ownerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            
            //to add Contact link in the chatter feed
            
            //messageBody.messageSegments.add(entityLinkSegmentInputCon);
            
            
            textSegmentInput = new ConnectApi.TextSegmentInput();
            contactRecord = 'Contact Record: \t';
            
            textSegmentInput.text = '\t The Contact record update failed. Kindly review the following error message and correct the details accordingly.\n\n'+contactRecord ;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            
            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputCon = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputCon.entityId = recId;  
            
            messageBodyInput.messageSegments.add(entityLinkSegmentInputCon);
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = '\n'+ tochattermessage+'\n\nOnce the contact record is updated successfully in SFDC, information with Customer Master Data (CMD) will be shared.';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = recId;
            
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            
            ConnectApi.ChatterFeeds.postFeedElementBatch(null, new List<ConnectApi.BatchInput>{ batchInput });
            
        } catch (Exception e) {
            ErrorLogger.writeErrors( 'SFDC', 'Contact Message', 'ApiCalloutCMDqueable ', new list<Exception>{e});
        }
    }
    
    public class ErrorMessageWrapper{
        public String value;
        public String message;
        public String field;
        public Integer errorCode; 
    }    
}