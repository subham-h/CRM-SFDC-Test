/*
Description  : Perform GCSS writeback callouts for Booking Amendment

* version    Ref Number     Date                Owner                   Description
*******************************************************************************************************************
* 1.0        SC-1601        14-07-2021          Richa@Maersk            Call GCSS Create Shipment Notes api on Booking Amendment
* 2.0        SC-882         20-07-2021          Richa@Maersk            Call GCSS Delete Equipment api on Booking Amendment
* 3.0        SC-882         31-08-2021          sriram@Maersk           Call GCSS Reprice  api to perform Repricing
* 4.0        SC-882         31-08-2021          sriram@Maersk           Call GCSS getconfirmBookingReceivers and postConfirmBooking to perfomr confirm booking operation
*-------------------------------------------------------------------------------------------------------------------
*/
public class BookingAmendmentWritebackController {
    //SC-882: Booking Amendment - Remove Containers
    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object deleteEquipment(String shipmentId,String operator,String equipmentId){ 
        operator = operator.toUpperCase();        
        String auditDetails;
        String MaerskId;
        String strObjectName = 'Equipment';
        String strModuleName = 'deleteEquipment';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/equipment/'+equipmentId+'?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);
        system.debug('End point URL $$$'+Endpoint);      
        String res;
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
                jg.writeStringField('title','Container removed');
                jg.writeStringField('text','Equipment No '+equipmentId+' on Shipment No ' +shipmentId+ ' removed by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails'+auditDetails);
                PostShipmentNotes(shipmentId,operator,auditDetails);
                System.debug('res:'+res);
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //SC-1601: Audit Tracking For Write Back 
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object postShipmentNotes(String shipmentId,String operator,string auditDetails){ 
        
        operator = operator.toUpperCase();
        String strObjectName = 'ShipmentNotes';
        String strModuleName = 'postShipmentNotes';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        system.debug('confirm booking');
        system.debug(shipmentId);
        system.debug(operator);
        system.debug(auditDetails);
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/shipmentNotes?'+Label.GCSSParamString+operator;
        System.debug('Endpoint---> '+Endpoint);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);
        req.setbody(auditDetails);       
        String res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            system.debug('confirm res');
            system.debug(res);
            if(res.contains(Label.Token_Validation_Failed) || res.contains('resubmit')){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else{
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            ErrorLogger.writeError( 'SFDC', 'ServiceView', 'BookingAmendmentWritebackController.postShipmentNotes','System.CalloutException',e.getMessage(),auditDetails);
        }        
        return res;              
    }   
    
    //SC-882: Reprice
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object postReprice(String shipmentId,String operator){ 
        String auditDetails;
        String MaerskId;
        operator = operator.toUpperCase();
        String strObjectName = 'reprice';
        String strModuleName = 'postReprice';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/rePrice?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);  
        String res;
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
                jg.writeStringField('title','Pricing');
                jg.writeStringField('text','Pricing Details are updated for Shipment No ' +shipmentId+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                PostShipmentNotes(shipmentId,operator,auditDetails);
                return res;     
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //SC-882: confirmBookingReceivers
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object getConfirmBookingReceivers(String shipmentId,String operator){ 
        operator = operator.toUpperCase();
        String strObjectName = 'getConfirmBookingReceivers';
        String strModuleName = 'getReceivers';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/confirmBookingReceivers?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);  
        String res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);           
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200'){                
                System.debug('res:'+res);
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //SC-882: Post confirmBooking
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object postConfirmBooking(String shipmentId,String operator,string body){ 
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        String strObjectName = 'ConfirmBooking';
        String strModuleName = 'ConfirmBooking';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/confirmBooking?carrier='+operator;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);  
        req.setbody(body); 
        String res;
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
                jg.writeStringField('title','Booking Confirmed');
                jg.writeStringField('text','Booking Confirmed for Shipment No ' +shipmentId+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails'+auditDetails);
                system.debug('confirm*******');
                //callShipmentAPI(shipmentId,operator,auditDetails);
                String shipmentRes=(string)postShipmentNotes(shipmentId,operator,auditDetails);
                if(shipmentRes.contains('resubmit')){
                    system.debug('resubmit***');
                    postShipmentNotes(shipmentId,operator,auditDetails);
                }
                System.debug('res:'+res);
                return res;
            }else if(res == '400'){
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //SC-883: UTM Check
    @AuraEnabled
    //(cacheable=true)
    public static Object utmCheck(String shipmentId,String operator){ 
        String MaerskId;
        String auditDetails;
        operator = operator.toUpperCase();
        String strObjectName = 'utmCheck';
        String strModuleName = 'utmInformation';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssDetail.End_point_URL__c+'shipments/'+shipmentId+'/utmInformation?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key', gcssDetail.Authorization_Key__c);        
        req.setTimeout(Integer.valueof(gcssDetail.Timeout__c));
        req.setEndpoint(Endpoint);  
        String res;
        system.debug('Endpoint###'+Endpoint);
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssDetail);           
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssDetail);
            }else if(res == '200'){                
                System.debug('res:'+res);
                
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }   
                
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','UTM Check');
                jg.writeStringField('text','UTM Check is done for Shipment No ' +shipmentId+ ' by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                PostShipmentNotes(shipmentId,operator,auditDetails);
                return res; 
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    //sc-883: Edit Equipments
    @AuraEnabled
    //(cacheable=true)
    public static Object editEquipment(String shipmentId,String operator,String equipmentId,String equipDetails){
        system.debug('EquipmentId ##'+EquipmentId);
        String ReqBody;
        operator = operator.toUpperCase();        
        String auditDetails;
        String MaerskId;
        String strObjectName = 'EquipmentDetails';
        String strModuleName = 'editEquipmentDetails';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/equipment/'+equipmentId+'/equipmentDetails?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);
        req.setBody(equipDetails);
        system.debug('End point URL $$$'+Endpoint);      
        String res;
        system.debug('req ##'+req);
        system.debug('req body##'+req.getbody());
        try{  
            system.debug('Inside Try');
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);           
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200'){
                System.debug('res:'+res);
                
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }   
                
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','Equipment Updated');
                jg.writeStringField('text','Equipment No '+equipmentId+' on Shipment No ' +shipmentId+ ' updated by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails'+auditDetails);
                PostShipmentNotes(shipmentId,operator,auditDetails);
                System.debug('res:'+res);
                return res;
            } else {
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //sc-881: Add Equipments
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Object addEquipment(String shipmentId,String operator,String body){
        operator = operator.toUpperCase();
        String auditDetails;
        String MaerskId;
        
        String strObjectName = 'EquipmentDetails';
        String strModuleName = 'editEquipmentDetails';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        
        String Endpoint =gcssSWBDetail.End_point_URL__c+'shipments/'+shipmentId+'/equipmentDetails'+'?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);
        req.setBody(body);
        system.debug('End point URL $$$'+Endpoint);      
        String res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);           
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200' || res.contains('entityInstanceIdList')){
                System.debug('res:'+res);
                List<User> lstUser  = [Select Maersk_User_Id__c FROM User WHERE Id =: UserInfo.getUserId()];
                if(lstUser.size()>0){
                    MaerskId = lstUser[0].Maersk_User_Id__c;    
                }   
                
                JSONGenerator jg = JSON.createGenerator(false); 
                jg.writeStartObject();
                jg.writeFieldName('shipmentNotes');
                jg.writeStartArray();
                jg.writeStartObject();
                jg.writeStringField('title','Equipment Created');
                jg.writeStringField('text','Equipment created on Shipment No ' +shipmentId+ ' updated by '+ MaerskId);
                jg.writeEndObject(); 
                jg.writeEndArray();
                jg.writeEndObject();
                auditDetails = jg.getAsString();
                System.debug('***auditDetails'+auditDetails);
                PostShipmentNotes(shipmentId,operator,auditDetails);
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
    //to get commoditycodes
    @AuraEnabled
    public static object getCommodityCodes(string operator,string description){
        operator = operator.toUpperCase();
        String strObjectName = 'getConfirmBookingReceivers';
        String strModuleName = 'getReceivers';
        // Getting the Endpoint and Security details from metadata.
        GCSS_Write_Back_Services__mdt gcssSWBDetail = WebserviceUtilities.getGCSSWriteBackMetadataValue(strObjectName,strModuleName);
        ///hsCommodityCodes/fish?carrier=MAEU
        String Endpoint =gcssSWBDetail.End_point_URL__c+'hsCommodityCodes/'+description+'?carrier='+operator;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');        
        req.setHeader('content-type', 'application/json');
        req.setHeader('Consumer-Key', gcssSWBDetail.Authorization_Key__c);
        req.setHeader('RequestId', string.valueOf(UserInfo.getUserId()+''+system.now()));
        req.setTimeout(Integer.valueof(gcssSWBDetail.Timeout__c));
        req.setEndpoint(Endpoint);  
        String res;
        try{  
            res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);           
            if(res.contains(Label.Token_Validation_Failed)){    
                Cache.Org.put('FRToken'+gcssSWBDetail.Environment__c,'',300);
                res = AO_APILoginUtility.sendWriteBackRequest(req,gcssSWBDetail);
            }else if(res == '200'){                
                System.debug('res:'+res);
                return res;
            }
            
        } catch(Exception e){
            system.debug('error:'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('res.getBody() '+res);
        return res;
        
    }
    
}