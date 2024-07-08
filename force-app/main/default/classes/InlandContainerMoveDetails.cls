/*
* Author   : Sriram.kalluri@Maersk.com
* Purpose  : Class  to get the details of InlandContainerMoveDetails
* 
* Revision   Ref Number    Date             Owner                            Description
* --------   ----------    -----------      -------------------              -----------
* 1.0        SC-154        08-March-2021    Sriram.kalluri@Maersk.com        performs callout to get the details of InlandContainerMoveDetails
* 2.0        SC-2196       01-06-2021       Sriram.kalluri@Maersk.com        performs callout to get the details of container moves by OperationId
*/
public with sharing class InlandContainerMoveDetails {
    @AuraEnabled(continuation=true cacheable=true)
    public static Object getInlandContainerMoveDetails(string shipmentno,string workOrder,string container,string searchBy){
        General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
        system.debug('workOrder-->'+workOrder);
        system.debug('shipmentno-->'+shipmentno);

    string strObjectName = 'Case';
    string strModuleName = 'SFDC.InlandContainerMove.REQUEST';
    // Getting the Endpoint and Security details from ESB Service metadata.
    ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);

    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    Blob headerValue = Blob.valueOf(esbServiceDetail.OSB_Username__c + ':' + esbServiceDetail.Password__c);
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);  
    req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
    req.setHeader('Authorization', authorizationHeader);  
    req.setHeader('content-type', 'application/json');
    req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
    
    if(searchBy == 'shipment'){
     req.setEndpoint(esbServiceDetail.End_point_URL__c+'/GetInlandContainerMoveDetailsByShipmentNumber?shipment_number='+shipmentno); 
    }else if(searchBy == 'container'){
      req.setEndpoint(esbServiceDetail.End_point_URL__c+'/GetInlandContainerMoveDetailsByContainerNumber?container_number='+container); 
    }else if(searchBy == 'workOrder'){
      req.setEndpoint(esbServiceDetail.End_point_URL__c+'/GetInlandContainerMoveDetailsByWorkOrderNumber?workorder_number='+workOrder); 
    }
    

    // Creating continuation object for making the callout.
    Continuation con = new Continuation(120);
    con.state = con.addHttpRequest(req);
    con.continuationMethod='processInlandContainerMove';
    system.debug('con---->'+con);
    return con;    

    }
    
    @AuraEnabled(cacheable=true)
    public static Object processInlandContainerMove(Object state) {
    //getting the service response for processInlandContainerMove service.
    HttpResponse response;        
    string res;
    try{       
        response = Continuation.getResponse((String)state); 
        if(response.getStatusCode()==200){
            res = response.getBody();             
        }else if(response.getStatusCode()==500){
            message msg = new message();
            msg.Error = 'Internal Server Error';
            system.debug('Error'+JSON.serialize( msg));
            return JSON.serialize( msg);
        }
    }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    return res;    
}

 //performs callout to get the details of container moves by OperationId
 @AuraEnabled(continuation=true cacheable=true)
    public static Object getOperationDetailsByOperationID(string OperationID){
     General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
    system.debug('OperationID-->'+OperationID);
    string strObjectName = 'Case';
    string strModuleName = 'SFDC.InlandContainerMoveByOperationID.REQUEST';
    // Getting the Endpoint and Security details from ESB Service metadata.
    ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.getESBShipmentMetadataValue(strObjectName,strModuleName);

    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    Blob headerValue = Blob.valueOf(esbServiceDetail.OSB_Username__c + ':' + esbServiceDetail.Password__c);
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);  
    req.setHeader('Authorization', authorizationHeader);  
    req.setHeader('content-type', 'application/json');
    req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
    req.setTimeout(Integer.valueof(esbServiceDetail.Timeout__c));
    
    if(OperationID != null){
     req.setEndpoint(esbServiceDetail.End_point_URL__c+'?operationId='+OperationID); 
    }    

    // Creating continuation object for making the callout.
    Continuation con = new Continuation(120);
    con.state = con.addHttpRequest(req);
    con.continuationMethod='processInlandContainerMoveByOperationID';
    system.debug('con---->'+con);
    return con;    

    }

    @AuraEnabled(cacheable=true)
    public static Object processInlandContainerMoveByOperationID(Object state) {
    //getting the service response for processInlandContainerMove service.
    HttpResponse response;        
    string res;
    try{       
        response = Continuation.getResponse((String)state); 
        if(response.getStatusCode()==200){
            res = response.getBody();             
        }else if(response.getStatusCode()==500){
            message msg = new message();
            msg.Error = 'Internal Server Error';
            system.debug('Error'+JSON.serialize( msg));
            return JSON.serialize( msg);
        }
    }
        catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    return res;    
}
    
    public class message{
        @AuraEnabled public string Error{get;set;}
    }
    
     //SAP TMS call to get inland details 
    @AuraEnabled(cacheable=true)
    public static Object getInlandTMSDetails(string shipmentno,string workOrder,string container,string searchBy){ 
        string strObjectName = 'InlandTMS';
        string modulename = 'getInlandTMS';
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        //setting Authorization header with the access token
        // req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        
        //set enpoint 
        if(searchBy == 'shipment'){
            req.setEndpoint(AOServiceDetail.End_point_URL__c+'?bookingNumber='+shipmentno); 
        }else if(searchBy == 'container'){
            req.setEndpoint(AOServiceDetail.End_point_URL__c+'?containerNumber='+container); 
        }else if(searchBy == 'workOrder'){
            req.setEndpoint(AOServiceDetail.End_point_URL__c+'?workOrderNumber='+workOrder); 
        }
       
        string res;
        try{  
            res = AO_APILoginUtility.sendTMSRequest(req,AOServiceDetail);            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }

}