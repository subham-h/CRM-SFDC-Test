/*
Description  : Generic class to get GCCS's archived data through docBrokerId

* version    Ref Number     Date               Owner                              Description
*******************************************************************************************************************
* 1.0        SC-6596       07/02/2023         sunil.bs@maersk.com                 Perform callouts to get GCCS's archived booking data 
                                                                                  like booking confimation, verify copy, seaway bill and bill of lading
*-------------------------------------------------------------------------------------------------------------------
*/
public class DocEmailAttachmentController {
    
    public static General_Key_Value_Configurations__mdt replyToAddress = General_Key_Value_Configurations__mdt.getInstance('ChatBotReplyToAddress');
    public static General_Key_Value_Configurations__mdt menuName1 = General_Key_Value_Configurations__mdt.getInstance('ChatBotMenuName1');
    public static General_Key_Value_Configurations__mdt menuName2 = General_Key_Value_Configurations__mdt.getInstance('ChatBotMenuName2');
    
     @AuraEnabled(cacheable=true)
     public static list<DocEmailAttachmentUtility.bookingoutput> validateIsCustomer(string brand,string externalContactId, string menuName, string bookingNumber, string caseNumber){
           
            String AccountId;
            String postConfirmBooking;
            Map<String,Object> mapBookingConfirmationResponse;
            String jsonS;
            String confirmBookingReceivers;
            Boolean isException = false;
            String errorReceived;
            List<DocEmailAttachmentUtility.bookingoutput> lstBookingReceiversResult = new List<DocEmailAttachmentUtility.bookingoutput>();
            List<Object> dataList=new List<Object>();
            List<BodyData> reclist = new List<BodyData>();

            try{
                string operatorCode = brandutilities.getBrandOperatorCode(brand);
                confirmBookingReceivers = (String)BookingAmendmentWritebackController.getConfirmBookingReceivers(bookingNumber,operatorCode);
                if(confirmBookingReceivers == 'Read timed out'){
                    lstBookingReceiversResult = getBookingInfo(null,Label.ReadTimedOut);
                    isException = true;   
                }
            }
            catch(Exception ex)
            {
                system.debug('***exception error in confirm Booking Receivers'+ex.getMessage()+'**'+ex.getLineNumber());
                lstBookingReceiversResult = getBookingInfo(null,ex.getMessage());
                isException = true;
            }
            
            if(!isException){
                Map<String,Object> maprecipientResponse = (Map<String,Object>)JSON.deserializeUntyped(confirmBookingReceivers);
                 List<Object> lstrecipient = (List<Object>) maprecipientResponse.get('recipientList'); 
                if(lstrecipient!=null){
                    for(object obj:lstrecipient)
                    {  
                        Map<String,Object> resData = (Map<String,Object>)obj;
                        if(resData.get('shipmentPartyRoleTypeName')=='Booked By'){
                            AccountId = (string)resData.get('customerId');
                            break;
                        }
                        
                    }
                    system.debug('reclist is null here'+reclist+'reclist size'+reclist.size());
                    for(Object obj1: lstrecipient){
                        
                        
                        Map<String,Object> rData = (Map<String,Object>)obj1;
                        if(rData.get('customerId')== AccountId && rData.get('contactId')==externalContactId && rData.get('deliveryMethodName')=='E-mail' )
                        {  
                            
                            JSONGenerator gen = JSON.createGenerator(true);    
                            gen.writeStartObject();
                            reclist.add(getData((string)rData.get('contactId'),(string)rData.get('customerId'),(string)rData.get('deliveryMethodId'),(string)rData.get('shipmentPartyRoleTypeId')));
                            gen.writeObjectField('recipientList', reclist);
                            gen.writeEndObject();
                            jsonS = gen.getAsString();
                            break;
                            
                        }
                        else
                        {
                            lstBookingReceiversResult = getBookingInfo(null,'Unauthorized Access');
                        }
                    }
                }
                
                else{
                    
                    errorReceived = (String)maprecipientResponse.get('debugMessage'); 
                    lstBookingReceiversResult = getBookingInfo(null,errorReceived);
                }
                
                if(reclist.size()>0){
                    lstBookingReceiversResult = getBookingInfo(null,'Valid Customer');
                }
                
                else{
                     lstBookingReceiversResult = getBookingInfo(null,'Unauthorized Access');
                }
            }
         return lstBookingReceiversResult;
    }
        
    

    @AuraEnabled(cacheable=true)
    public static string DocBrokerIdIdentifier(string brand, string menuName, string bookingNumber, string caseNumber){
                    string response;
                try{                   
                    String strObjectName = 'docBrokerEmailAttach';
                    String modulename = 'docBrokerEmailAttach';
                    String Endpoint;
                    string idOrgWideEmailAddress;
                    string autoReplyEmailAddress;
                    Map<String, Id> linerBrandOrgIdMap = BrandUtilities.getBrandAndOrgWideEmailAddressIdMap();

                    AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, moduleName); 
                    string operatorCode = brandutilities.getBrandOperatorCode(brand);
                    operatorCode = operatorCode.toUpperCase();
                                        
                    if(menuName == menuName1.First_Field_Name__c){
                     Endpoint =aoServiceDetail.End_point_URL__c+'shipments/'+bookingNumber+'/docBrokerId/'+'?carrier='+operatorCode;
                    }        
              
                    if(menuName == menuName1.Second_Field_Name__c || menuName == menuName2.First_Field_Name__c || menuName == menuName2.Second_Field_Name__c){
                     Endpoint =aoServiceDetail.End_point_URL__c+'tpDocs/'+bookingNumber+'/docBrokerId/'+'?carrier='+operatorCode;
                    }      
                    

                    //First callout is to get the Docbrokerid of the associated document requested for the current booking number
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');        
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Consumer-Key', aoServiceDetail.Authorization_Key__c);       
                    req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
                    req.setEndpoint(Endpoint);               
              
                 
                        response = AO_APILoginUtility.sendRequest(req,aoServiceDetail);                       
                        if(response.contains(Label.Token_Validation_Failed)){    
                            Cache.Org.put('FRToken'+aoServiceDetail.Environment__c+aoServiceDetail.Authorization_Key__c,'',300);
                            response = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
                        }
               
                        return response;                                   
            
        } catch(Exception e){
            system.debug('Exception is' +e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'DocBrokerIdIdentifier'+caseNumber, new list<Exception>{e});
        }  
            return response;
        
    }
    
   
       /** 
      * @description | SC-6596  Method is invoked from chatbot |
      * @param bookingNumber accepts the bookingNumber
      * @param operatorCode accepts the operatorCode
      * @param menuName accepts the menuName
      */
      @AuraEnabled(cacheable=true)
      @future(callout=true)
      public static void sendDocBrokerIdEmailAttachments(string bookingNumber,string brand, string menuName, string caseNumber, string docbrokeruniqueid,string externalContactId){
                string error;
                list<string> docBrokerStatus = new list<string>();

          try{  string idOrgWideEmailAddress = replyToAddress.Second_Field_Value__c;
                string autoReplyEmailAddress = replyToAddress.First_Field_Value__c;
                Map<String, Id> linerBrandOrgIdMap = BrandUtilities.getBrandAndOrgWideEmailAddressIdMap();
                string operatorCode = brandutilities.getBrandOperatorCode(brand);
                operatorCode = operatorCode.toUpperCase();

                String strObjectName2 = 'docBrokerArchEmaAtta';
                String modulename2 = 'docBrokerArchEmaAtta';
                AO_Services__mdt aoServiceDetail2 = WebserviceUtilities.getAOServicesMetadataValue(strObjectName2, modulename2);            
                String Endpoint2 =aoServiceDetail2.End_point_URL__c+docbrokeruniqueid+'?carrier='+operatorCode;
                  
               //Second callout is to get the archived document using the Docbrokerid received from the first callout 
                Http h2 = new Http();
                HttpRequest req2 = new HttpRequest();
                req2.setMethod('GET');        
                req2.setHeader('Content-Type', 'application/json');
                req2.setHeader('Consumer-Key', aoServiceDetail2.Authorization_Key__c);       
                req2.setTimeout(Integer.valueof(aoServiceDetail2.Timeout__c));
                req2.setEndpoint(Endpoint2);               
                String res2;
             
                    res2 = AO_APILoginUtility.sendRequest(req2,aoServiceDetail2);
                    System.debug('***res'+res2); 
                    if(res2.contains(Label.Token_Validation_Failed)){    
                        Cache.Org.put('FRToken'+aoServiceDetail2.Environment__c+aoServiceDetail2.Authorization_Key__c,'',300);
                        res2 = AO_APILoginUtility.sendRequest(req2,aoServiceDetail2);
                    }
             
             if(!String.isblank(res2) && !res2.containsIgnoreCase('Read timed out') && !res2.containsIgnoreCase('debugMessage')){

                 system.debug('res2 '+res2);
        
                 Map<String,Object> maprecipientResponse = (Map<String,Object>)JSON.deserializeUntyped(res2);
                 string pdfContentbase64 = (string) maprecipientResponse.get('pdfContent');
                 blob pdfContentInBlob = EncodingUtil.base64Decode(pdfContentbase64);

                 case caseInscope =  [select id,contactid,Case_Country__c,Direction__c from case where caseNumber =:caseNumber];
                 /*
                 //Needed to set orgwideaddress
                  if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(brand) && caseInScope.Case_Country__c == 'Philippines' && caseInScope.Direction__c == 'Domestic') {
                       idOrgWideEmailAddress = linerBrandOrgIdMap.get('MCCPH');
                  } else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(brand) && caseInScope.Case_Country__c == 'Tanzania') {
                       idOrgWideEmailAddress = linerBrandOrgIdMap.get('MSLTZ');
                  } else {
                       idOrgWideEmailAddress = linerBrandOrgIdMap.get('Maersk Line');
                  }   */                       
                 
                 Map<string,string> docIdMethods = new Map<string,string>();                     
                 List<General_Key_Value_Configurations__mdt> lstGeneralkeyValueConfigmdt = [SELECT Id, First_Field_Value__c, Second_Field_Value__c
                                                                                         FROM 
                                                                                         General_Key_Value_Configurations__mdt 
                                                                                         WHERE 
                                                                                         Key__c = 'GCSSDocBrokerIdMethod'
                                                                                         ];  
                 for(General_Key_Value_Configurations__mdt mdt : lstGeneralkeyValueConfigmdt){
                     docIdMethods.put(mdt.First_Field_Value__c,mdt.Second_Field_Value__c);
                 }
                 
                 
                  //Send a email to the customer/contact with the requested document 
                  list<Messaging.SingleEmailMessage> lstEmailMessages = new list<Messaging.SingleEmailMessage>();
                  Map<Id, String> mapChatterPostContent = new Map<Id, String>();
               
                  Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                                emailMessage.setTemplateId(docIdMethods.get(menuName));
                                emailMessage.setTargetObjectId(caseInscope.Contactid);
                                emailMessage.setWhatId(caseInscope.Id); 
                                emailMessage.setSubject('Booking Confirmation : '+bookingNumber);
                                //Chatter post              
                                emailMessage.setOrgWideEmailAddressId(idOrgWideEmailAddress);                      
                                emailMessage.setReplyTo(autoReplyEmailAddress);
                                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                                Messaging.EmailFileAttachment ema = new Messaging.EmailFileAttachment();
                                                              ema.setFileName(menuName+' '+bookingNumber + '.pdf');
                                                              ema.setBody(pdfContentInBlob);
                                                              ema.setContentType('application/pdf');
                                attachments.add(ema);
                                emailMessage.setFileAttachments(attachments);
                                                               
                     lstEmailMessages.add(emailMessage);
                     list<Messaging.SendEmailResult> lstEmailResults = Messaging.sendEmail(lstEmailMessages);
                   
                    }else{
                        //This else block is to capture reponse Issue for 1st API Callout
                        
                            if(String.isblank(res2)){
                                docBrokerStatus.add('Empty Response');
                                ErrorLogger.writeError('SFDC', 'User', 'sendDocBrokerIdEmailAttachments', 'No Document Broker Id found for the Booking Number '+caseNumber,'','');  
                            }
                            
                           else if(res2.containsIgnoreCase('debugMessage')){
                                Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res2);
                                error = (String) mapResponse.get('debugMessage');
                                ErrorLogger.writeError('SFDC', 'User', 'sendDocBrokerIdEmailAttachments '+caseNumber, error,'','');  

                            }
                                                        
                            else{
                                ErrorLogger.writeError('SFDC', 'User', 'sendDocBrokerIdEmailAttachments ', 'Read timed out '+caseNumber,'','');  
 
                            }
                        
                    }
                                   
                }catch(Exception ex) {
                    system.debug(+ex+' at '+ex.getLineNumber());
                    ErrorLogger.writeErrors('SFDC', 'User', 'sendDocBrokerIdEmailAttachments'+' '+caseNumber, new list<Exception>{ex});  
                }    
        }
    
    
    public static List<DocEmailAttachmentUtility.bookingoutput> getBookingInfo(string Status, string botOutputMessage){
        List<DocEmailAttachmentUtility.bookingoutput> lstBookingOutput = new List<DocEmailAttachmentUtility.bookingoutput>();
        DocEmailAttachmentUtility.bookingoutput Booking = new DocEmailAttachmentUtility.bookingoutput();                  
        Booking.Status = Status;
        Booking.botOutputMessage = botOutputMessage;
        lstBookingOutput.add(Booking);
        return lstBookingOutput;
    }
    
    /** 
    * @description | SC-4740 send email to contacts via bot  |
    * @param contactId accepts contactId
    * @param deliveryMethodId accepts deliveryMethodId
    * @param deliveryMethodId accepts shipmentPartyRoleTypeId
    * @return BodyData containing BodyData
    */ 
    public static BodyData getData(String contactId,String customerId,String deliveryMethodId,String shipmentPartyRoleTypeId)
    {
        BodyData bd = new BodyData();
        bd.contactId=contactId;
        bd.customerId=customerId;
        bd.deliveryMethodId=deliveryMethodId;
        bd.shipmentPartyRoleTypeId=shipmentPartyRoleTypeId;
        return bd;
        
    }
    
    public class BodyData{
        public string contactId;
        public string customerId;
        public string deliveryMethodId;
        public string shipmentPartyRoleTypeId;
        
    }
    
}