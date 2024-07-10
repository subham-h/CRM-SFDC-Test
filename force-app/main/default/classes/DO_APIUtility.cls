/*
Description  : Perform callout to get Id_Token for DO API, and methods to make post and get call to post instant DO and polling the status.

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          08/03/2021          sandeep.sankhla@maersk.com                    Perform callout to get Id_Token for DO API.
* V2.0          20/04/2023          ayush.kumar@maersk.com                        Changing the API callout for instant response through SSDO.
* V3.0 			22/05/2023			nayana.sharma@maersk.com					  Changed format to formatGmt for date field due to bug SC-8068
*-------------------------------------------------------------------------------------------------------------------
*/
public class DO_APIUtility {
    
    
    //DOR-4331 
    public static String getDOIdToken(AO_Services__mdt custommetadata) { 
        
        String idToken = (String)Cache.Org.get('DOToken'+custommetadata.Environment__c);   
        
        if (idToken == null || idToken == '') {            
            HttpRequest req = new HttpRequest();           
            String reqbody = 'grant_type=client_credentials&client_id={!$Credential.Username}&client_secret={!$Credential.Password}';           
            req.setEndpoint('callout:'+custommetadata.NamedCred__c);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setBody(reqbody);
            Http http = new Http();
            
            HTTPResponse res = http.send(req);           
            String resStr =  res.getBody(); 
            system.debug('-resStr---'+resStr);
            Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(resStr);
            idToken = (String)mapResponse.get('access_token');            
            if(idToken != null){                
                Cache.Org.put('DOToken'+custommetadata.Environment__c, idToken,3600);                               
            }
            
        }
        System.debug('***idToken '+idToken);
        return  idToken;        
    }
    
    //SC-2183
    public static responseWrapper sendInstantDOHTTPRequest(String strWFId, String billOfLadingId, AO_Services__mdt custommetadata) {
         responseWrapper resWrapper = new responseWrapper();
        
        try{  
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST'); 
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Consumer-Key', custommetadata.Authorization_Key__c);
            //SC-7757 Changing URL from /instant to /v2
            String url = custommetadata.End_point_URL__c+'v2?billOfLadingId='+billOfLadingId;   
            req.setEndpoint(url);
            
            set<Id> setCDIds = new set<Id>();
            //Check if request payload is there as attachment.
            for(ContentDocumentLink objCDL : [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId =: strWFId]){
                setCDIds.add(objCDL.ContentDocumentId);
            }
            
            blob strCVDa;
            for(ContentVersion objCV : [Select id ,VersionData from ContentVersion where ContentDocumentId IN: setCDIds AND Title = 'Instant_DO_Payload']){
                
                strCVDa = (objCV.VersionData);
            }           
            if(strCVDa != null){
                
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(strCVDa.toString());
                
                resWrapper.strCarrierCode = (string)m.get('carrierCode');
                resWrapper.strBOLNumber = billOfLadingId;
                resWrapper.strCustomerCode = (string)m.get('customerCode');
                //Changes by Ramesh Inavolu - SC-4319
                if(m.containsKey('capacity') && m.get('capacity') != null && 'Unknown'.equalsIgnoreCase(String.valueOf(m.get('capacity'))) &&
                (
                    m.containsKey('importServiceMode') && m.get('importServiceMode') != null && 'CY'.equalsIgnoreCase(String.valueOf(m.get('importServiceMode'))) || 
                    m.containsKey('importServiceMode') && m.get('importServiceMode') != null && 'SD'.equalsIgnoreCase(String.valueOf(m.get('importServiceMode')))
                )
                ){
                    List<Agent_Workflow__c> aWorkList = [Select DeliveryFromDateTime__c,ReleaseFromDateTime__c from Agent_Workflow__c where Id =:strWFId ];
                    if(aWorkList != null){
                        dateTime dateTimeToReplace = 'SD'.equalsIgnoreCase(String.valueOf(m.get('importServiceMode'))) ? aWorkList[0].DeliveryFromDateTime__c : aWorkList[0].ReleaseFromDateTime__c;
                        if(dateTimeToReplace != null){
                            Instant_DO_Wrapper responseWrapper = Instant_DO_Wrapper.parse(strCVDa.toString());
                            for(Instant_DO_Wrapper.HaulageInstructions instruction : responseWrapper.haulageInstructions){
                                Instant_DO_Wrapper.haulageOrderValidityDetails haulageOrderValidityDetails = instruction.haulageOrderValidityDetails;
                                List<Integer> releaseFromDateList = new List<Integer>();
                                for(String dateStr : dateTimeToReplace.format('yyyy-MM-dd')?.split('-')){
                                    releaseFromDateList.add(Integer.valueOf(dateStr));
                                }
                                haulageOrderValidityDetails.releaseFromDate = releaseFromDateList;
                                for(Instant_DO_Wrapper.DeliveryStops deliveryStop : instruction.DeliveryStops){
                                    deliveryStop.deliveryFromDateTimeLocal = String.valueOf(dateTimeToReplace.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
                                }
                            }
                            strCVDa = Blob.valueOf(JSON.serialize(responseWrapper));
                        }
                    }
                }
                //SC-4319 - End
                
                req.setBodyAsBlob(strCVDa);
                req.setTimeout(30000);
                
                string res;
                try{  
                    
                    system.debug('---req-----'+req);
                    
                    res = sendDORequest(req, custommetadata, resWrapper);
                    
                    system.debug('------res-----'+res);
                    resWrapper.strDeliveryOrderId = res;
                    
                } 
                catch(Exception e){
                    system.debug('error:'+e.getMessage());
                    ErrorLogger.writeError( 'SFDC', 'Case', 'DO_APILoginUtility','System.CalloutException',e.getMessage(),strWFId);
                }
                
                return resWrapper;
            }
            else {
                resWrapper.strStatusCode = '203';
                resWrapper.strMessage = 'Request Payload Not Available. We can not request for approval.';
                return resWrapper;
            }
            
            
        } 
        catch(Exception e){
            system.debug('error:'+e.getMessage() +  e.getLineNumber());
            
            ErrorLogger.writeError( 'SFDC', 'Case', 'DO_APILoginUtility','System.CalloutException',e.getMessage(),strWFId);
            resWrapper.strMessage = e.getMessage();
            return resWrapper;
        
        }
        
        
        
        
    }
    
    //SC-2183 
    public static string sendDORequest(HttpRequest req , AO_Services__mdt custommetadata, responseWrapper resWrapper) {
        String strDeliveryOrderId;
        http httpobj = new http();
        httpresponse res;
        String accessToken = getDOIdToken(custommetadata);
        String status = '';
        if(accessToken != null){ 
            //setting Authorization header with the access token
            req.setHeader('Authorization','Bearer '+accessToken);
            
            try{ 
                res = httpobj.send(req);
                system.debug('req ==> ' + req.getBody());
                system.debug('==> ' +res.getStatusCode() + ' ===> ' +  res.getBody());
                if(res.getStatusCode() == 202){
                    resWrapper.strStatusCode = '202';
                    resWrapper.strMessage = 'Approval Succesful';
                    status = res.getStatus();
                    Map<String,Object> mapResponse = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                    strDeliveryOrderId = (String)mapResponse.get('deliveryOrderId'); 
                    
                }
                else{
                    
                    resWrapper.strStatusCode = 'Error';
                    resWrapper.strMessage = 'Approval Failed.';
                    
                }
                return strDeliveryOrderId;                
            }
            catch(Exception e){               
                System.debug('error:'+e.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'DO_APILoginUtility', new list<Exception>{e});
                resWrapper.strMessage = e.getMessage();
                resWrapper.strStatusCode = 'Error';
                return e.getMessage();
            }
        }else{
            //Setting custom message if access token is not retrieved correctly.               
            resWrapper.strMessage = Label.AccessTokenFailed;
            return JSON.serialize( resWrapper);
        }
    } 
    
    //SC-7757
    //SC-2183
    /*
    public static responseWrapper getInstantDOStatus(String bOLNumber, string deliveryOrderId, string carrierCode, string customerCode, AO_Services__mdt custommetadata) {
        responseWrapper objRW = new responseWrapper();
        
        httpresponse res;
        String accessToken = getDOIdToken(custommetadata);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Consumer-Key', custommetadata.Authorization_Key__c);
        req.setHeader('Authorization','Bearer '+accessToken);
        
        // req.setEndpoint(aoServiceDetail.End_point_URL__c);
        String url = custommetadata.End_point_URL__c+deliveryOrderId+'?billOfLadingId='+bOLNumber+'&carrierCode='+carrierCode + '&customerCode='+customerCode;   
        system.debug('-----url-------'+url);
        req.setEndpoint(url);
        try{ 
            
            res = h.send(req);
            if(res.getStatusCode() == 200){
                
                DO_instantDOGetCallParser objParser = DO_instantDOGetCallParser.parse(res.getBody());
                DO_instantDOGetCallParser.InstantDeliveryOrder objID = new DO_instantDOGetCallParser.InstantDeliveryOrder();
                objID = objParser.InstantDeliveryOrder;
                system.debug('---objID--'+objID.status);
                if(objID.status == 'SUCCESS'){
                    
                    objRW.strStatusCode = '200';
                    objRW.strMessage = 'SUCCESS';
                    
                }
                
                
                objRW.strMessage = objID.status;
                
                
            }
            return objRW;
        }
        catch(Exception e){  
            
            objRW.strMessage = e.getMessage();
            System.debug('error:'+e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'DO_APILoginUtility', new list<Exception>{e});
            return objRW;
        }
        
    }
    */
    //This is response wrapper class to return all responses.
    public class responseWrapper {
        
        @AuraEnabled public string strBOLNumber{get;set;}
        @AuraEnabled public string strCaseId{get;set;}
        @AuraEnabled public string strDeliveryOrderId{get;set;}
        @AuraEnabled public string strCarrierCode{get;set;}
        @AuraEnabled public string strCustomerCode{get;set;}
        @AuraEnabled public string strMessage{get;set;}
        @AuraEnabled public string strStatusCode{get;set;}
        @AuraEnabled public string strOwnerId{get;set;}
    }
    
    
    
}