/*              
* Revision   Ref Number       Date        Owner                       Description
* --------  ------------   ------------  ---------------------       ----------------------
* 1.0         SC-9978      02-May-2024    Richa@maersk.com           Wrapper class for publishing Case events
*/

public without sharing class CaseEventResponseWrapper {
    public static Map<Id, Message> mapCaseResponse = new Map<Id, Message>(); 
    public static Map<Id,Case> mapCaseDetails= new Map<Id,Case>();
    public class serviceCase {
        public header header;
        public message message;
        public string topic;
        public string key;
        
        public serviceCase(header header, message message, string topic,string key) {
            this.header = header;
            this.message = message;
            this.topic = topic;
            this.key = key;
        }
    }    
    
    public class header{        
        public string version;
        public string systemz;
        public string messageId;
        public long eventTimestamp;
        public string eventNotificationName;
        public string transactionType;
        public header(){           
            version = '';
            systemz = '';
            messageId = '';
            eventTimestamp = 0;
            eventNotificationName = '';
            transactionType = '';
        }
    }
    
    public Static header getHeader(String eventNotification,String transactionType){
        Datetime dt = Datetime.now();
        header pRec = new header();        
        pRec.version = '1.0.0';
        pRec.systemz = 'sfdc';
        pRec.messageId = String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        pRec.eventNotificationName = eventNotification != null ? eventNotification:'live';
        pRec.transactionType = transactionType != null ? transactionType:'create';
        return pRec;
    }      
    
    public class message {
        public String caseIdentifier {get;set;}         
        public String caseNumber {get;set;} 
        public String caseProcess {get;set;} 
        public String caseSubject {get;set;} 
        public String caseDescription {get;set;} 
        public long caseOpenDatetime {get;set;} 
        public long caseCloseDatetime {get;set;} 
        public long caseLastModifiedDatetime {get;set;} 
        public String brandName {get;set;} 
        public String invoiceNumber {get;set;} 
        public String localServiceLevel {get;set;} 
        public Locations locations {get;set;} 
        public ParentCase parentCase {get;set;} 
        public Customer customer {get;set;} 
        public Contact contact {get;set;} 
        public String caseOwnerName {get;set;} 
        public String caseOwnerIdentifier {get;set;} 
        public String caseResolvedReasonName {get;set;} 
        public String issueRaisedByName {get;set;} 
        public String suppliedEmailAddress {get;set;} 
        public String caseChannel {get;set;} 
        public String caseStatusName {get;set;}
        public List<CaseComments> caseComments {get;set;} 
        public Message() {
            caseComments = new List<CaseComments>();           
            locations = new Locations();
            parentCase = new ParentCase();
            customer = new Customer();
            contact = new Contact();
        }        
    }
    
    public class Locations {
        public String countryName {get;set;} 
        public String countryClusterName {get;set;} 
    }
    
    public class ParentCase {
        public String parentCaseIdentifier {get;set;} 
        public String parentCaseNumber {get;set;}     
        public ParentCase(){
            parentCaseIdentifier = '';
            parentCaseNumber ='' ;
        }
    }    
    
    public class Customer {
        public String customerIdentifier {get;set;} 
        public String customerCode {get;set;} 
        public String alternativeCode {get;set;} 
        public String countryName {get;set;}  
    }    
    
    public class Contact {
        public String contactName {get;set;} 
        public String telecommunicationNumber {get;set;}
        public String emailAddress {get;set;} 
    }     
    
    public class CaseComments {
        public String comments {get;set;}    
    } 
    
    public class Results implements CustomEventResponseParentWrapper{        
        public String kafkakey;
        public String transactionType;
        public String publishingRecordId;        
        public DateTime publisherLastModifiedDate;
        public String eventType;
        public String serializedJSON1;
        public String serializedJSON2;
        public String serializedJSON3;
        public String serializedJSON4;
        public String serializedJSON5;
        public String serializedJSON6;
        
        public Results(){
            this.kafkakey = '';
            this.transactionType = '';
            this.publishingRecordId = '';
            this.publisherLastModifiedDate = null;
            this.eventType = '';
            this.serializedJSON1 = '';
            this.serializedJSON2 = '';
            this.serializedJSON3 = '';
            this.serializedJSON4 = '';
            this.serializedJSON5 = '';
            this.serializedJSON6 = '';
        }
        
        public String getKafkakey() {
            return this.kafkakey;
        }        
        public String getTransactionType() {
            return this.transactionType;
        }        
        public String getPublishingRecordId() {
            return this.publishingRecordId;
        }
        public DateTime getPublisherLastModifiedDate() {
            return this.publisherLastModifiedDate;
        }        
        public String getEventType() {
            return this.eventType;
        }
        public String getSerializedJSON1() {
            return this.serializedJSON1;
        }        
        public String getSerializedJSON2() {
            return this.serializedJSON2;
        }
        public String getSerializedJSON3() {
            return this.serializedJSON3;
        }
        public String getSerializedJSON4() {
            return this.serializedJSON4;
        }
        public String getSerializedJSON5() {
            return this.serializedJSON5;
        }
        public String getSerializedJSON6() {
            return this.serializedJSON6;
        }
    }
    
    
    public static List<Results> prepareCaseEventData (Map<Id,EventTypeWrapper> mapCases) {
        List<Results> responses = new List<Results>();        
        if(!mapCases.isEmpty()){
            getCaseDetails(mapCases); 
        }
        
        for(Id caseId : mapCases.keySet()){
            Results result = new Results();
            Message tempMessage = new Message(); 
            EventTypeWrapper eventWrapper = mapCases.get(caseId);
            if(mapCaseDetails.containsKey(caseId)){
                result.kafkakey = mapCaseDetails.get(caseId).CaseNumber;
                result.publisherLastModifiedDate = mapCaseDetails.get(caseId).LastModifiedDate;
            }
            if(mapCaseResponse.containsKey(caseId)){
                tempMessage = mapCaseResponse.get(caseId);
            }
            result.publishingRecordId = caseId;
            if(eventWrapper != null) {
                result.transactionType = eventWrapper.transactionType;
                result.eventType = eventWrapper.eventType;
            }
            String messageJson= JSON.serialize(tempMessage);
            result.serializedJSON1 = messageJson.length()>0 && messageJson.length()< 131000 ? messageJson.subString(0,messageJson.length()): messageJson.length()> 131000? messageJson.subString(0,131000) : '';
            result.serializedJSON2 = messageJson.length()>=131000 && messageJson.length()< 262000 ?  messageJson.subString(131000,messageJson.length()): messageJson.length()> 262000? messageJson.subString(131000,262000) :'';
            result.serializedJSON3 = messageJson.length()>=262000 && messageJson.length()< 393000 ?  messageJson.subString(262000,messageJson.length()): messageJson.length()> 393000? messageJson.subString(262000,393000) :'';
            result.serializedJSON4 = messageJson.length()>=393000 && messageJson.length()< 524000 ?  messageJson.subString(393000,messageJson.length()): messageJson.length()> 524000? messageJson.subString(393000,524000) :'';
            result.serializedJSON5 = messageJson.length()>=524000 && messageJson.length()< 655000 ?  messageJson.subString(524000,messageJson.length()): messageJson.length()> 655000? messageJson.subString(524000,655000) :'';
            result.serializedJSON6 =messageJson.length()>=655000 && messageJson.length()< 786000 ?  messageJson.subString(655000,messageJson.length()): messageJson.length()> 786000? messageJson.subString(655000,786000) :'';
            responses.add(result);
            
        }        
        return responses;
    }
    
    public static void getCaseDetails(Map<Id,EventTypeWrapper> mapCases) {
        for (Case objCase : [SELECT Id,CaseNumber,AccountId,Subject,Description,ClosedDate,LastModifiedDate,Contact.Phone,Contact.Email,Liner_Brand__c,Disputed_Invoice_Number__c,Care_Level__c,Case_Country__c,Parent_Case_Number__c,Account.Customer_Code__c,SCV_Code__c,Account_Country__c,Contact_Name__c,Case_Cluster__c,OwnerId,Owner.Name,Resolved_Reason__c,SuppliedName,SuppliedEmail,Case_Channel__c,Status,CreatedDate,ParentId,RecordType.Name,(SELECT Commentbody FROM CaseComments) FROM Case where Id in :mapCases.keySet()]) {                                  
            if(!mapCaseDetails.containsKey(objCase.Id)){
                mapCaseDetails.put(objCase.Id,objCase);
            }
            Message caseMessage  = new Message();            
            caseMessage.caseIdentifier = objCase.Id;
            caseMessage.caseNumber = objCase.CaseNumber;
            caseMessage.caseProcess = objCase.RecordType.Name;
            caseMessage.caseSubject = objCase.Subject != null ? objCase.Subject:'';
            caseMessage.caseDescription = objCase.Description != null ? objCase.Description:'';
            
            Datetime createdDT = objCase.CreatedDate;
            Datetime modifiedDT = objCase.LastModifiedDate;
            caseMessage.caseOpenDatetime =  createdDT.getTime()/1000;
            caseMessage.caseLastModifiedDatetime =  modifiedDT.getTime()/1000;
            if(objCase.ClosedDate !=null) {
                Datetime closeDT = objCase.ClosedDate;
                caseMessage.caseCloseDatetime =  closeDT.getTime()/1000;                                    
            }
            
            caseMessage.brandName = objCase.Liner_Brand__c != null ? objCase.Liner_Brand__c:'';
            caseMessage.invoiceNumber = objCase.Disputed_Invoice_Number__c != null ? objCase.Disputed_Invoice_Number__c:'';
            caseMessage.localServiceLevel = objCase.Care_Level__c != null ? objCase.Care_Level__c:'';  
            caseMessage.Locations.countryName = objCase.Case_Country__c != null ? objCase.Case_Country__c: '';
            caseMessage.Locations.countryClusterName = objCase.Case_Cluster__c != null ? objCase.Case_Cluster__c: '';
            caseMessage.ParentCase.parentCaseIdentifier = objCase.ParentId;
            caseMessage.ParentCase.parentCaseNumber = objCase.Parent_Case_Number__c != '0' ? objCase.Parent_Case_Number__c: '';
            caseMessage.Customer.customerIdentifier = objCase.AccountId;
            caseMessage.Customer.customerCode = objCase.Account.Customer_Code__c != null ? objCase.Account.Customer_Code__c: '';
            caseMessage.Customer.alternativeCode = objCase.SCV_Code__c != null ? objCase.SCV_Code__c: '';
            caseMessage.Customer.countryName = objCase.Account_Country__c != null? objCase.Account_Country__c:'';
            caseMessage.Contact.contactName = objCase.Contact_Name__c != null? objCase.Contact_Name__c:'';
            caseMessage.Contact.telecommunicationNumber = objCase.Contact.Phone != null? objCase.Contact.Phone:'';
            caseMessage.Contact.emailAddress = objCase.Contact.Email != null? objCase.Contact.Email:'';
            caseMessage.caseOwnerName = objCase.Owner.Name; 
            caseMessage.caseOwnerIdentifier = objCase.OwnerId;
            caseMessage.caseResolvedReasonName = objCase.Resolved_Reason__c != null ? objCase.Resolved_Reason__c:'';
            caseMessage.issueRaisedByName = objCase.SuppliedName != null ? objCase.SuppliedEmail:'';
            caseMessage.suppliedEmailAddress = objCase.SuppliedEmail != null ? objCase.SuppliedEmail:'';
            caseMessage.caseChannel = objCase.Case_Channel__c != null ? objCase.Case_Channel__c:'';
            caseMessage.caseStatusName = objCase.Status;
            
            List<CaseComments> lstCaseComments= new List<CaseComments>();
            for(CaseComment comm: objCase.CaseComments) {
                CaseComments comWrapper = new CaseComments();
                comWrapper.comments = comm.CommentBody!= null ?comm.CommentBody:'';
                lstCaseComments.add(comWrapper);                                        
            } 
            caseMessage.caseComments = lstCaseComments; 
            mapCaseResponse.put(objCase.Id, caseMessage);                                    
        } 
    }
    
}