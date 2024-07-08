/*
* Author   : Sreya@Maersk
* Purpose  : Class for making external webservice callouts for getting Haulage Information.
* 
* Revision Ref Number   Date            Owner                   Description
* -------- ----------   -----------     -------------------     -----------
* 1.0      SC-153       15-09-2020      Sreya@Maersk            API calls to get Export and Import Haulage details.
* 2.0      SC-2260      15-04-2021      Sriram@maersk           Migrating from ESB to GCSS API
*/
public class HaulageInformationController {
    
    @AuraEnabled
    public static Object GetHaulageInformation(String shipmentId,String tpDocId,string operator){
        string urlParameterString = ''; 
        string strObjectName = '';
        string modulename = '';
        operator = operator.toUpperCase();
        //shipmentId is used to make export haulage API call
        if(string.isNotBlank(shipmentId)){
            
            strObjectName = 'ExportHaulage';
            modulename = 'getExportHaulage';
            urlParameterString = 'shipments/'+shipmentId+'/haulageDetails?';
        }
        //tpDocId is used to make import haulage API call
        else if(string.isNotBlank(tpDocId)){
            
            strObjectName = 'ImportHaulage';
            modulename = 'getImportHaulage';
            urlParameterString = 'tpDocs/'+tpDocId+'/importHaulageDetails?';
            
        }        
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamString+operator;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        system.debug('setEndpoint '+req);
        string res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
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
    
    @AuraEnabled(cacheable=true)
    public static Object exportMerchantHaulage(String body, String shipmentno, String operator, String orderNo){
        string urlParameterString = ''; 
        string strObjectName = 'ExportHaulage';
        string strModuleName = 'getExportHaulage';
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        urlParameterString = 'shipments/'+shipmentno+'/exportMerchantHaulageOrders/'+orderNo+'?carrier=';    
        
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        urlParameterString = gcssSWBDetail.End_point_URL__c+urlParameterString+operator;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setBody(body);
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(urlParameterString);
        string res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200'){       
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }   
                
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','Merchant Haulage Update');
                jg.writeStringField('text','Merchant Haulage Updated for Shipment No ' +shipmentno+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails'+auditDetails);
                BookingAmendmentWritebackController.PostShipmentNotes(shipmentno,operator,auditDetails);
                System.debug('****res:'+res);
                return res;
            }else if(res == '400'){
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage()+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('****res.getBody() '+res);
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static Object addExportMerchantHaulage(String body, String shipmentno, String operator){
        string urlParameterString = ''; 
        string strObjectName = 'ExportHaulage';
        string strModuleName = 'getExportHaulage';
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        String haulageNumber = '';
        urlParameterString = 'shipments/'+shipmentno+'/exportMerchantHaulageOrders?carrier=';    
        
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        urlParameterString = gcssSWBDetail.End_point_URL__c+urlParameterString+operator;           
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        system.debug(req.getMethod());
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setBody(body);
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(urlParameterString);
        string res;
        Object getResponse;
        HaulageWrapper haulwrap = new HaulageWrapper();
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            system.debug('****res-->'+res);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }
            Map<String, Object> objmap = (Map<String, Object>)JSON.deserializeUntyped(res);
            haulageNumber = (String)objmap.get('haulageOrderNumber');
            haulwrap.haulNumber = haulageNumber;
            if(!String.isEmpty(haulageNumber)){       
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','Merchant Haulage Added');
                jg.writeStringField('text','Merchant Haulage Added for Shipment No ' +shipmentno+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails add'+auditDetails);
                BookingAmendmentWritebackController.PostShipmentNotes(shipmentno,operator,auditDetails);
                //Make a GET request to display default haulage order recipients
                getResponse = GetExportHaulageInformationFromHaulageNumber(shipmentno, haulageNumber, operator);
                system.debug('****getResponse-->'+getResponse);
                haulwrap.haulDetail = getResponse;
                return haulwrap;
            }
            else if(!String.isEmpty(res)){
                haulwrap.haulDetail = res;
                return haulwrap;
            }
        }catch(Exception e){
            system.debug('****exception-->'+e.getMessage()+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return haulwrap;
    }

    @AuraEnabled(cacheable=true)
    public static Object GetExportHaulageInformationFromHaulageNumber(String shipmentno,String haulageNumber,string operator){
        string urlParameterString = ''; 
        string strObjectName = 'ExportHaulage';
        string modulename = 'getExportHaulage';
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        urlParameterString = 'shipments/'+shipmentno+'/exportMerchantHaulageOrders/'+haulageNumber+'?';       
        
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString+Label.GCSSParamString+operator;           
        System.debug('urlParameterString '+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
        req.setEndpoint(urlParameterString); 
        system.debug('setEndpoint '+req);
        string res;
        try{  
            res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            system.debug('****res-->'+res);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
                res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            }else{
                return res;
            }
            
        } catch(Exception e){
            system.debug('****error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
    }
    
    @AuraEnabled
    public static Object patchExportMerchantHaulage(String body, String shipmentno, String operator, String haulageNumber){
        string urlParameterString = ''; 
        string strObjectName = 'ExportHaulage';
        string strModuleName = 'getExportHaulage';
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        urlParameterString = 'shipments/'+shipmentno+'/exportMerchantHaulageOrders/'+haulageNumber+'?carrier=';
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        urlParameterString = gcssSWBDetail.End_point_URL__c+urlParameterString+operator;     
        system.debug('****urlParameterString-->'+urlParameterString);
        HttpRequest req = new HttpRequest();
        req.setMethod('PATCH');
        system.debug(req.getMethod());
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key',gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setBody(body);
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(urlParameterString);
        string res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            system.debug('****patch res-->'+res);
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200'){       
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }   
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','Merchant Haulage Update receivers');
                jg.writeStringField('text','Merchant Haulage receivers Updated for Shipment No ' +shipmentno+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                BookingAmendmentWritebackController.PostShipmentNotes(shipmentno,operator,auditDetails);
                return res;
            }
            else if(res == '400'){
                return res;
            }
        } catch(Exception e){
            system.debug('****error:'+e.getMessage()+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return res;
    }
    
    public class HaulageWrapper{
        @AuraEnabled
        public String haulNumber;
        @AuraEnabled
        public Object haulDetail;
    }
}