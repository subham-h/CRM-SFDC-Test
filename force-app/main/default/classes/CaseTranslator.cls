/*
Description  : Perform callout to Azure to get Text Translations

* version       Ref Number    Date                Owner                                       Description
*******************************************************************************************************************
* V1.0                        27/11/2023          ranjan.kumar.1@maersk.com                       Perform callout to get Translations
*-------------------------------------------------------------------------------------------------------------------
*/
public with sharing class CaseTranslator {
   public static List<TranslateWrapper> translate(List<String> textToTranslateList,String toLanguageCode)
   {
    //make callout for translation
        List<TranslateWrapper> transList;
        String strObjectName = 'AzureTextTranslation';
        String modulename = 'getTextTranslation';
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, modulename);
        try//callout inside the try 
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(AOServiceDetail.End_point_URL__c+toLanguageCode);//'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=en');
            req.setMethod('POST');
            req.setHeader('Ocp-Apim-Subscription-Key',AOServiceDetail.Authorization_Key__c); //'8cdc95fb2cc940f3afc9dc2797e48091');
                // location required if you're using a multi-service or regional (not global) resource.
            req.setHeader('Ocp-Apim-Subscription-Region', AOServiceDetail.Akami_Key__c);//'westeurope');
            req.setHeader('Content-Type','application/json');
            req.setTimeout(Integer.valueof(AOServiceDetail.Timeout__c));
            JSONGenerator jg = JSON.createGenerator(false); 
            jg.writeStartArray();
            for(String textToTranslate: textToTranslateList){
                jg.writeStartObject();
                String tempTextToTranslate=textToTranslate;
                tempTextToTranslate=(tempTextToTranslate.length()>10000?tempTextToTranslate.substring(0,9900):tempTextToTranslate);
                tempTextToTranslate=('ja'.equalsIgnoreCase(toLanguageCode)?tempTextToTranslate.stripHtmlTags():tempTextToTranslate);
                jg.writeStringField('Text',tempTextToTranslate);
                jg.writeEndObject();  
            }
            jg.writeEndArray();
            String body=jg.getAsString();  
            req.setBody(body);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode()==200)
            {   
                transList=TranslateWrapper.parse(res.getBody());//parsing in the wrapper
            }else{
                throw new calloutException(res.getBody());//when the status not equals to 200, log the exception
            }    
        } catch(Exception e){
            ErrorLogger.writeErrors( 'SFDC', 'Case', 'Translations', new list<Exception>{e});
        }
        return transList;
    }
    public class calloutException extends Exception {}
   
}