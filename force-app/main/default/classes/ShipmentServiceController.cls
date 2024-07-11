/*
* Author   : Sreya@Maersk
* Purpose  : Class for making external webservice callouts to GCSS for Shipment Management operation.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010357   10-May-2019   Sreya@Maersk            Handle GCSS webservice calls for Shipment Summary Basic View, Container tracking Info.
* 2.0      RQ-010359   21-May-2019   Sreya@Maersk            Handle GCSS webservice calls for Shipment Notes.
* 3.0      RQ-010517   10-July-2019  Sriram@Maersk           Handle GCSS webservice calls for Container Count.
* 4.0      RQ-011142   04-Sep-2019   Sreya@Maersk            Handle GCSS webservice calls for Booking details with container number.
* 5.0      RQ-012391   18-11-2019    Sreya@Maersk            Made the getBookingNumberByContainerNumber and GetShipmentNotesPerRequest service input parameters to uppercase.
* 5.0      SC-70       06-10-2020    Naved@Maersk            Convert Soap Api to rest api for shipment notes.
*/
public class ShipmentServiceController {
    

    
    // Handling the web service callout for getting Container Ids by Booking Number.
   @AuraEnabled(continuation=true cacheable=true)
    public static Object getContainerIdsByBookingNumber(string ShipmentId){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetShipmentSummary.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getShipmentSecurityHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);       
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody =  '<v5:GetContainerIDByBookingNumberRequest>'
            +'<v5:ShipmentId>'+ shipmentId +'</v5:ShipmentId>' 
            +'</v5:GetContainerIDByBookingNumberRequest>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);
        con.continuationMethod='processShipmentDetailRes';
        system.debug(con);
        return con;
    }

    @AuraEnabled(cacheable=true)
    public static Object processShipmentDetailRes(Object state) {
        //getting the service response for getContainerIdsByBookingNumber service.
        HttpResponse response = Continuation.getResponse((String)state); 
        system.debug(response.getBody());
        return response.getBody();
        
    }
    
    // Handling the ESB service callout for getting the shipment summary details by Booking Number.
    @AuraEnabled(continuation=true cacheable=true)
    public static Object GetBookingDetailsByShipmentNumber(String shipmentId){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetShipmentSummary.REQUEST';
        system.debug('shimentId-------->'+shipmentId);
        // Getting the Endpoint and Security details from metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getShipmentSecurityHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);       
        String strHeader =  SecurityHeader+commonHeader;
        
        String strBody = '<v5:GetBookingDetailsByRequestRequest>'
            +'<v5:ShipmentId>'+ shipmentId +'</v5:ShipmentId>'  
            +'<v5:PartyDetailsRequired>true</v5:PartyDetailsRequired>'         
             +'<v5:EquipmentDetailsRequired>true</v5:EquipmentDetailsRequired>'
             +' <v5:CargoDetailsRequired>false</v5:CargoDetailsRequired>'
            +'<v5:ShipmentSummaryRequired>true</v5:ShipmentSummaryRequired>'
            +'<v5:RouteDetailsRequired>true</v5:RouteDetailsRequired>'
             +'</v5:GetBookingDetailsByRequestRequest>';
        
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);
        con.continuationMethod='processBdetailsResponse';
        system.debug(con);
        return con;

    }
    @AuraEnabled(cacheable=true)
    public static Object processBdetailsResponse(Object state) {
        //getting the service response for GetBookingDetailsByRequestRequest service.
        HttpResponse response;
        try{
            response = Continuation.getResponse((String)state); 
            system.debug(response.getBody());
        }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return response.getBody();
        
    }
    //,String shipNoteType,String shipNoteTitle
    // Handling the ESB service callout for getting the shipment Notes details by Shipment Id, Reason Type and Reason detail.
    @AuraEnabled(cacheable=true)
    public static Object GetShipmentNotesPerRequest(String shipmentId,string operator){
               
       operator = operator.toUpperCase();
        string strObjectName = 'ShipmentSummary';
        string strModuleName = 'getShipmentSummary';
        // Getting the Endpoint and Security details from metadata.
        AO_Services__mdt aoServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName,strModuleName);
    
       // string  accessToken = AO_APILoginUtility.getFRToken(AOServiceToken);  
        string Endpoint =aoServiceDetail.End_point_URL__c+'shipments/'+shipmentId+'/shipmentNotes?'+Label.GCSSParamString+operator;
      System.debug('Endpoint---> '+Endpoint);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        //req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', aoServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
        req.setEndpoint(Endpoint);
        system.debug('End point URL $$$'+Endpoint);
      //  system.debug('accessToken $$$'+accessToken);
        string res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+aoServiceDetail.Environment__c+aoServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,aoServiceDetail);
            }else{
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
              
    }
   
    //Preparing the security header for the request which is common for all the shipment management operations.
    public static String getShipmentSecurityHeader(ESB_Webservice__mdt esbServiceDetail){       
      String securityHeader =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v5="http://services.apmoller.net/AMM/ShipmentManagement/v5">'
            +'<soapenv:Header>'
            +'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
            +'<wsse:UsernameToken wsu:Id="UsernameToken-1" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            +'<wsse:Username>'+ esbServiceDetail.OSB_Username__c +'</wsse:Username>'
            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ esbServiceDetail.Password__c +'</wsse:Password>'
            +'</wsse:UsernameToken>'
            +'</wsse:Security>' ;
        return securityHeader;       
    }    
    
    

     // Handling the web service callout for getting Container count by Booking Number.
   @AuraEnabled(continuation=true cacheable=true)
    public static Object getContainerCountByBookingNumber(string ShipmentId){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');

        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetContainerCount.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getContainerCountSecurityHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);       
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody =  ' <soapenv:Body> <v5:GetContainerCountByBookingNumberRequest> <v5:ShipmentId>'+ShipmentId+'</v5:ShipmentId>'
                            +'</v5:GetContainerCountByBookingNumberRequest>   </soapenv:Body>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai

        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);
        con.continuationMethod='processContainerCountRes';
        system.debug(con);
        return con;
    }

    @AuraEnabled(cacheable=true)
    public static Object processContainerCountRes(Object state) {
        //getting the service response for getContainerCountByBookingNumber service.
        HttpResponse response = Continuation.getResponse((String)state); 
        system.debug(response.getBody());
        return response.getBody();
        
    }

     public static String getContainerCountSecurityHeader(ESB_Webservice__mdt esbServiceDetail){
      String securityHeader = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v5="http://services.apmoller.net/AMM/ShipmentManagement/v5">'
             +'<soapenv:Header>'
             +'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
              +'<wsse:UsernameToken xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="UsernameToken-1">'
             +'<wsse:Username>'+ esbServiceDetail.OSB_Username__c +'</wsse:Username>'
              +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ esbServiceDetail.Password__c +'</wsse:Password>'
              +' </wsse:UsernameToken>'
              +'</wsse:Security>';
        return securityHeader;       
    }
    //Getting booking details with container number
     @AuraEnabled(continuation=true cacheable=true)
    public static Object getBookingNumberByContainerNumber(string ContainerId){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        system.debug('ContainerId'+ContainerId);
        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetShipmentSummary.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getShipmentSecurityHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);       
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody =  '<v5:GetBookingNumberByContainerNumberRequest>'
            +'<v5:ISOSerialNum>'+ContainerId.toUpperCase()+'</v5:ISOSerialNum>'
            +'</v5:GetBookingNumberByContainerNumberRequest>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
       
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);
        con.continuationMethod='processBookingDetailsByContainer';
        return con;
    }
     @AuraEnabled(cacheable=true)
    public static Object processBookingDetailsByContainer(Object state) {
       HttpResponse response;
        try{
            response = Continuation.getResponse((String)state); 
            system.debug('response'+response.getBody());
        }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return response.getBody();
        
    }
    
    //Rama - #RQ-012078 
  /*  @AuraEnabled(continuation=true cacheable=true)
    public static Object getShipmentNotesatTPDocLevel(string TPDocNumber, String reqTtitle ,String reqType){
        system.debug('TPDocNumber'+TPDocNumber);
        system.debug('reqTtitle '+reqTtitle );
        system.debug('reqType'+reqType);
        
        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetTransportDocument.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
        
        String SecurityHeader = getTransportDocumentManagementHeader(esbServiceDetail);       
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);               
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody = '<v21:GetTransportDocumentNotesPerRequestRequest>'
         +'<v21:TransportNote>'
            +'<v21:TransportDocumentNumber>'+TPDocNumber+'</v21:TransportDocumentNumber>'
         +'</v21:TransportNote>'
         +'<v21:TransportDocumentNotesPerRequest>';
         
         if( reqTtitle != NULL && reqTtitle.replaceAll( '\\s+', '') != ''){
             strBody = strBody +'<v21:TransportDocumentNoteTitle>'+reqTtitle+'</v21:TransportDocumentNoteTitle>';
         }
         
         if(reqType != NULL && reqType.replaceAll( '\\s+', '') != '' ){
             strBody = strBody +'<v21:TransportDocumentNoteTitleType>'+reqType+'</v21:TransportDocumentNoteTitleType>';
         }
         
         strBody = strBody +'</v21:TransportDocumentNotesPerRequest>';
         strBody = strBody +'</v21:GetTransportDocumentNotesPerRequestRequest>';
                 
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
       
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        

        // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);        
        con.continuationMethod='processShipmentNotesatTPDocLevel';
        return con;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Object processShipmentNotesatTPDocLevel(Object state) {
        system.debug('inside continuation');
       HttpResponse response;
        try{
            response = Continuation.getResponse((String)state); 
            system.debug('response'+response.getBody());
        }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return response.getBody();
        
    }
    
    
    //Preparing the security header for the request for TransportDocumentManagement.
    public static String getTransportDocumentManagementHeader(ESB_Webservice__mdt esbServiceDetail){
    
    String securityHeader =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v21="http://services.apmoller.net/AMM/TransportDocumentManagement/v2">'
            +'<soapenv:Header>'
            +'      <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            +'<wsse:UsernameToken wsu:Id="UsernameToken-5">'
            +'<wsse:Username>'
            +esbServiceDetail.OSB_Username__c
            +'</wsse:Username> <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'
            +esbServiceDetail.Password__c
            +'</wsse:Password> </wsse:UsernameToken>'            
            +'</wsse:Security>' ;
        return securityHeader; 
         
    } */
    
    
       
}