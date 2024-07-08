/*
* Author   : Sreya@Maersk
* Purpose  : Class for making external webservice callouts to GCSS for Transport Document Management Operation.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010357   10-May-2019 Sreya@Maersk            Handle GCSS webservice calls for transport document details.
* 2.0      SC-948      14/09/2021  Richa@Maersk            Rest Callout to GCSS tpdoc endpoint for parties
* 3.0      SC-7123     01/07/2023  Harmeet@Maersk          Get Contact Details on basis of ExternalId      
*/
public class TransportDocumentServiceController {

    // Handling the web service callout for getting transport document details by tpDOc Number.
    @AuraEnabled(continuation=true cacheable=true)
    public static Object getTransportDocumentDetails(string TransportDocumentNumber){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        system.debug('TransportDocumentNumber'+TransportDocumentNumber);
        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetTransportDocument.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
 
        String SecurityHeader = getTpDocSecurityHeader(esbServiceDetail);
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);   
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody =  '<v21:GetTransportDocumentDetailsRequest>'
            +'<v21:TransportDocumentNumber>'+ TransportDocumentNumber +'</v21:TransportDocumentNumber>' 
            +'</v21:GetTransportDocumentDetailsRequest>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
         req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        
        /*http httpobj = new http();
        httpresponse res = httpobj.send(req);
        system.debug('Response is' +res.getBody());
        return res.getBody();*/

         // Creating continuation object for making the callout.
        Continuation con = new Continuation(120);
        con.state = con.addHttpRequest(req);
        con.continuationMethod='processTransportResponse';
        system.debug('con@@'+con);
        return con; 
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Object processTransportResponse(Object state) {
        //getting the service response for GetTransportDocumentDetailsRequest service.
        HttpResponse response;
        try{
            response = Continuation.getResponse((String)state); 
            system.debug('response@@'+response.getBody());
        }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }      
        return response.getBody();        
    }
    
     //Preparing the security header for the request which is common for all the transport document management operations.
    public static String getTpDocSecurityHeader(ESB_Webservice__mdt esbServiceDetail){
      String securityHeader =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://services.apmoller.net/ManagementFramework/CommonIdentifier/v2" xmlns:v21="http://services.apmoller.net/AMM/TransportDocumentManagement/v2">'
            +'<soapenv:Header>'
            +'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
            +'<wsse:UsernameToken wsu:Id="UsernameToken-1" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
            +'<wsse:Username>'+ esbServiceDetail.OSB_Username__c +'</wsse:Username>'
            +'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ esbServiceDetail.Password__c +'</wsse:Password>'
            +'</wsse:UsernameToken>'
            +'</wsse:Security>' ;
        return securityHeader;       
    }
    
        //Rama - #RQ-012078 
    @AuraEnabled(continuation=true cacheable=true)
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
         
    }
    
   @AuraEnabled
    public static Object getTPDocDetails(string TransportDocumentNumber, string operator){
        system.debug('TransportDocumentNumber'+TransportDocumentNumber);
        string strObjectName = 'TPDocParties';
        string strModuleName = 'getTPDocParties';
        operator = operator.toUpperCase();
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, strModuleName); 
        string Endpoint =aoServiceDetail.End_point_URL__c+'tpDocs/'+TransportDocumentNumber+'/parties?'+'carrier='+operator;
        System.debug('Endpoint---> '+Endpoint);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', aoServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(aoServiceDetail.Timeout__c));
        req.setEndpoint(Endpoint);            
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
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'TransportDocumentServiceController.getTPDocDetails', new list<Exception>{e});
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;        
    }

     @AuraEnabled(cacheable=true)
     public static list<Contact> getContactDetails(list<String> contactPersonList){

        list<Contact> conlist = new list<Contact>();
        conlist = [SELECT id,Name,External_ID__c from contact where External_ID__c in :contactPersonList];
        return conlist;
     }
    
    @AuraEnabled(cacheable=true)
    public static Object getTransportDocumentDetailsRes(string TransportDocumentNumber){
         General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        string strObjectName = 'Case';
        string strModuleName = 'SFDC.GetTransportDocument.REQUEST';
        
        // Getting the Endpoint and Security details from ESB Service metadata.
        ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);
 
        String SecurityHeader = getTpDocSecurityHeader(esbServiceDetail);
        String commonHeader =  WebserviceUtilities.getShipmentServiceHeader(esbServiceDetail);   
        String strHeader = SecurityHeader+commonHeader;
        
        String strBody =  '<v21:GetTransportDocumentDetailsRequest>'
            +'<v21:TransportDocumentNumber>'+ TransportDocumentNumber +'</v21:TransportDocumentNumber>' 
            +'</v21:GetTransportDocumentDetailsRequest>';
        
        String strFooter = WebserviceUtilities.getShipmentServiceFooter();
        
        String strXMLRequest = strHeader + strBody + strFooter;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
         req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        req.setBody(strXMLRequest);
        req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
        req.setEndpoint(esbServiceDetail.End_point_URL__c);
        
        http httpobj = new http();
        httpresponse res = httpobj.send(req);
        return res.getBody();  
    }  









    
}