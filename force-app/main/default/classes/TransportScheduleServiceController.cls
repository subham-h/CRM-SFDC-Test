/*
* Author   : Sreya@Maersk
* Purpose  : Class for making external webservice callouts to GCSS for Transport Schedule Operation.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010359   21-May-2019 Sreya@Maersk            Handle GCSS webservice calls for transport schedule details.
* 2.0      SC-8815     22-Sept-2023 Raksha@Maersk          Replacing existing ESB API of Vessel Delay Reasons with Nexus API 
*/
public class TransportScheduleServiceController {
   @AuraEnabled(cacheable=true)
   public static Object getTransportScheduleNexus(string VesselCode, String VoyageNumber,String ETD,String ETA){
   General_Key_Value_Configurations__mdt akamaiHeader = General_Key_Value_Configurations__mdt.getInstance('AkamaiRequestHeader');
   string accessToken;
   string urlParameterString = '';
   system.debug('Parameters--'+'VesselCode:'+VesselCode+' VoyageNumber:'+VoyageNumber+' ETD:'+ETD+' ETA:'+ETA);
   string strObjectName = 'VesselDelay';
   string modulename = 'getVesselDelay';
   //Querying the meta data for getting request details
   AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename); 
   urlParameterString = '?maerskVesselCode='+VesselCode+'&voyageNumber='+VoyageNumber+'&fromDateTime='+ETD+'&toDateTime='+ETA+'&limit=25';
   urlParameterString = AOServiceDetail.End_point_URL__c+urlParameterString;  
   HttpRequest req = new HttpRequest();
   req.setMethod('GET');
   req.setHeader('Content-Type', 'application/json');
   req.setHeader('Authorization','Bearer '+accessToken);
   req.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c);
   req.setHeader('x-requestor',akamaiHeader.First_Field_Value__c);//added new header as part of Token api issue resolution from akamai
   req.setHeader('API-Version','2');       
   req.setEndpoint(urlParameterString); 
   system.debug('setEndpoint '+req);
   string res;
       try{  
           res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
            system.debug('res'+res);           
           if(res.contains(Label.Token_Validation_Failed)){    
               Cache.Org.put('FRToken'+AOServiceDetail.Environment__c+AOServiceDetail.Authorization_Key__c,'',300);
               res = AO_APILoginUtility.sendRequest(req,AOServiceDetail);
           }else{  
                System.debug('res.getBody()- '+res);
               return res;
           }        
       } catch(Exception e){
           system.debug('error:'+e.getMessage());
           ErrorLogger.writeErrors( 'SFDC', 'Case', 'ServiceViewVesselDelayReasons', new list<Exception>{e});
       }
       System.debug('res.getBody() '+res);
       return res;
   }
}