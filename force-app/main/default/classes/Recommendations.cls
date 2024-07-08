/**
 * Purpose  : Gives abstract view of all the business logic / functionality implemented on Case trigger.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      SC-7083     18-03-2023  ramadevi@maersk.com     Methods used to make a callout to get the Recommendations.
 * 2.0      SC-7911     16/05/2023  ramadevi@maersk.com     add Akamai Header to avoid 403 errors
 */
public class Recommendations{
    public static String constructRequestBodyForNBA(List<Sobject> records,NBA_Settings__mdt NBAmdt){
         try{
                system.debug('###Inside Recommendations Class'); 
                List<SObject> castRecords;
                Schema.SObjectType sObjectType = records.getSObjectType();
                if (sObjectType != null)
                {
                    String listType = 'List<' + sObjectType + '>';
                    castRecords = (List<SObject>)Type.forName(listType).newInstance();
                    castRecords.addAll(records);
                }
                List<String> keys = new List<String>();
                if(NBAmdt <> NULL){
                     keys = NBAmdt.Keys__c.split(',');
                }
                //Prepare the request and call the callout method               
                JSONGenerator jsn = JSON.createGenerator(false); 
                jsn.writeStartObject();
                jsn.writeStringField('Modulename',NBAmdt.Callout_Module_Name__c);
                jsn.writeFieldName('data');
                for(SObject cs:castRecords){                    
                    system.debug('Inside loop ##'+cs);
                    jsn.writeStartObject();
                    for(String s : keys){
                        system.debug('s---'+s);
                        List<String> keyVal = s.split('=');                         
                        if(keyVal <> null) {
                            system.debug('keyVal[0]###'+keyVal[0]);
                            
                            if(keyVal[0] == 'Case_Record_Type'){
                                jsn.writeStringField(keyVal[0],keyVal[1]);
                            } else {
                                if(cs.get(keyVal[1]) <> NULL) {
                                    jsn.writeStringField(keyVal[0],String.valueof(cs.get(keyVal[1])));
                                }
                            }
                        }
                        /*jsn.writeStringField('Product',cs.Product__c);
                        jsn.writeStringField('Type',cs.Type);
                        jsn.writeStringField('Sub_Type',cs.Sub_type__c);
                        jsn.writeStringField('Case_Channel',cs.Case_Channel__c);
                        jsn.writeStringField('Case_Status',cs.Status); */
                    }
                    jsn.writeEndObject();
                }
                jsn.writeEndObject();
                system.debug('before request body ##'+jsn);
                String requestBody = jsn.getAsString();
                System.debug('Request Bdy ##'+requestBody);
                //List<Case_Recommendation__c> caseRecomList = Recommendations.getRecommendations(requestBody,lstCase[0].Id);
                //return caseRecomList;
                return requestBody;
        } catch(Exception e){            
            system.debug('Exception###'+e);
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'Recommendations.constructRequestBodyForNBA', new list<Exception>{e});
            return null;
        }
    }
    //@Future(callout=true)
    public static String getRecommendations(String requestBody,String CaseId,String strObjectName,String modulename){        
        String responseBody;
        //String strObjectName = 'NBARecommendation';
        //String modulename = 'api-recommendations';
        Case caseToUpdate = new Case();
        caseToUpdate.Id = CaseId;
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        system.debug('AOServiceDetail##'+AOServiceDetail);
        List<Case_Recommendation__c> caseRecList = new List<Case_Recommendation__c>();
        List<Case_Recommendation__c> caseRecLstToUpdt = new List<Case_Recommendation__c>();
        List<Case_Recommendation__c> caseRecLstToInsrt = new List<Case_Recommendation__c>();
        try{ 
            String accessToken = AO_APILoginUtility.getFRToken(AOServiceDetail);
            system.debug('accessToken##'+accessToken);
            List<Case_Recommendation__c> returncseRecom =  new List<Case_Recommendation__c>();
            
            
            List<String> rIdList = new List<String>();
            //API callout
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                request.setMethod('POST');            
                request.setHeader('Content-Type', 'application/json'); 
                request.setHeader('Consumer-Key',AOServiceDetail.Authorization_Key__c); 
                request.setHeader('X-Requestor',AOServiceDetail.Akami_Key__c);
                if(accessToken != null){
                 request.setHeader('Authorization', 'Bearer ' +accessToken);
                }
                request.setEndpoint(AOServiceDetail.End_point_URL__c);                    
                request.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
                request.setBody(requestBody);      
                system.debug('Request ###'+request);          
                response = http.send(request);
                System.debug('@@@@response'+response.getBody());
                if (response.getStatusCode() == 200){   
                    responseBody = response.getBody();
                } 
                if (response.getStatusCode() != 200){
                    ErrorLogger.writeError( 'SFDC', 'Case', 'Recommendations.getRecommendations', string.ValueOf(response.getStatusCode())+'-'+response.getStatus() ,CaseId+';'+AOServiceDetail.Authorization_Key__c+';'+AOServiceDetail.End_point_URL__c ,response.getBody() );
                }
            return responseBody;
            
        } catch(Exception e){
            system.debug('Exception###'+e);
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'Recommendations.getRecommendations', new list<Exception>{e});
            return null;
        } 
        //return null;
    }     
    
}