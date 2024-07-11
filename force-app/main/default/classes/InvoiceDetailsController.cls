/*
Description  : Perform callout to get Invoice Details

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0          10/01/2020          sreya.v@maersk.com                    Perform callout to get Invoice Details
* V2.0          04/12/2020          sriram@maersk.com                     As pet API updates modified the perameters
* V3.0          24/08/2022          raksha.n@maersk.com                 Perform callout to get Invoice Details in base64 format.
*-------------------------------------------------------------------------------------------------------------------
*/

global with sharing class InvoiceDetailsController {
        
    @AuraEnabled(cacheable=true)
    public static object getInvoiceDetails(string invoice,string tpDocNumber,string scvCode,string invoiceType, string operator){
       
        system.debug('Perameters--->'+tpDocNumber + scvCode + invoiceType + operator);
        
        List<string> creditCountries = Label.CreditCountries.split(',');
        string isCreditCountry;
        string customerCodeCMD;
        string accessToken;
        string searchby,searchbyId;
        
        // Getting customer code and country name for matching scvcode
        Account[] acc = [select Id,Customer_Code__c,Country__r.name from account where SCV_Code__c =: scvCode limit 1];
        
        if(!acc.isEmpty()){
            customerCodeCMD = acc[0].Customer_Code__c;
            //check if the country is in creditcountry with list mentioned in the custom label "CreditCountries"
            if(creditCountries.contains(acc[0].Country__r.name)){
                isCreditCountry = 'true';
            }else{
                 isCreditCountry = 'false';
            }

            if(!String.isBlank(invoice)){
                 searchby = '&isSelected=true&searchType=INV_NOS';
                 searchbyId = invoice;
            }else if(!String.isBlank(tpDocNumber)){
                 searchby = '&isSelected=true&searchType=BOL_IDS';
                 searchbyId = tpDocNumber;
            }

             string strObjectName = 'InvoiceDetails';
             string modulename = 'getInvoice';
             //Querying the meta data for getting request details
             AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
             //Get the access token 
            // accessToken = AO_APILoginUtility.getLoginIdToken(operator,AOServiceDetail);
             accessToken = AO_APILoginUtility.getFRTokenMyfinance(AOServiceDetail);
        
           
            system.debug('accessToken'+accessToken);
            if(accessToken != null){             
               
                
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Content-Type', 'application/json');
                //setting Authorization header with the access token
                //req.setHeader('Authorization',accessToken);
                req.setHeader('Authorization','Bearer '+accessToken);
                req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
                //req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
                  req.setEndpoint(AOServiceDetail.End_point_URL__c+'?customerCode='+scvCode+'&customerCodeCMD='+customerCodeCMD+ '&carrierCode='+operator.toUpperCase()+'&invoiceType='+invoiceType+'&isCreditCountry='+isCreditCountry+'&ids='+searchbyId+searchby); 
                  
                system.debug('setEndpoint'+req.getEndpoint());
                http httpobj = new http();
                httpresponse res;
                try{
                    res = httpobj.send(req);
                    system.debug('response'+res.getBody());
                } catch(Exception e){
                    //throwing the exception message in case of any service exception
                    system.debug('error:'+e.getMessage());
                    throw new AuraHandledException(e.getMessage());
                }
                system.debug('res.getBody'+res.getBody());
                return res.getBody();
            }
            else{
                //Setting custom message if access token is not retrieved correctly.
                message msg = new message();
                msg.noAccountMessage = Label.AccessTokenFailed;
                system.debug('noAccountMessage'+JSON.serialize( msg));
                return JSON.serialize( msg);
            }
        }
        else{
            // Setting custom message if Account not existing for the customer code input from lwc
            message msg = new message();
            msg.noAccountMessage = Label.NoAccountMsg;
            system.debug('noAccountMessage'+JSON.serialize( msg));
            return JSON.serialize( msg);
        }
    }

    @AuraEnabled(cacheable=true)
    public static string downloadInvoiceDetails(string invoiceId,string scvCode, string operator){
        string accessToken;
        string customerCodeCMD;
        string pdfTemplate;
        string languageIso;
        string cur;
        string documentType;
        String result='';
        system.debug('Parameters--->'+invoiceId);
        system.debug('scvCode--->'+scvCode);
        system.debug('operator--->'+operator);
        // Getting customer code and country name for matching scvcode
        Account[] acc = [select Id,Customer_Code__c,Country__r.name from account where SCV_Code__c =: scvCode limit 1];
        
        if(!acc.isEmpty()){
            customerCodeCMD = acc[0].Customer_Code__c;
        }
        pdfTemplate='X';
        languageIso='EN';
        cur='USD';
        documentType='INVOICE';

        string strObjectName = 'InvoiceDownload';
        string modulename = 'getInvoiceDownload';
        //Querying the meta data for getting request details
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
        //Get the access token 
        accessToken = AO_APILoginUtility.getFRTokenMyfinance(AOServiceDetail);
        if(accessToken != null){                                            
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            //setting Authorization header with the access token
            //req.setHeader('Authorization',accessToken);
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
            //req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
            req.setEndpoint(AOServiceDetail.End_point_URL__c+'/'+invoiceId+'?customerCodeCMD='+customerCodeCMD+ '&pdfTemplate='+pdfTemplate+ '&languageIso='+languageIso+ '&carrierCode='+operator.toUpperCase()+'&currency='+cur+'&documentType='+documentType);             
            http httpobj = new http();
            httpresponse res;
            try{
                res = httpobj.send(req);
                //Converting Map<String,Object> to String to capture the Base64 format
                Map<String, Object> responsemap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                result=string.valueOf(responsemap.get('fileContent'));  
                      
            } catch(Exception e){
                //throwing the exception message in case of any service exception
                system.debug('error:'+e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            system.debug('result'+result);
            return result;
        }
        else{
            //Setting custom message if access token is not retrieved correctly.
            message msg = new message();
            msg.noAccountMessage = Label.AccessTokenFailed;
            system.debug('noAccountMessage'+JSON.serialize( msg));
            return JSON.serialize( msg);
        } 
    }

    public class message{
        @AuraEnabled public string noAccountMessage{get;set;}
    }
}