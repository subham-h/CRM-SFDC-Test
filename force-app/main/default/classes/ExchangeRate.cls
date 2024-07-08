/*
 * Author   : Sandhya@UST
 * Purpose  : Handles all Exchange Rate related functionalities.
 * 
 * Revision Ref Number  Date        	Owner                               Description
 * -------- ----------  ----------- 	--------------------------------    -----------
 * 1.0      #SP-0032  	23-Feb-2016   	Sandhya.Sambasivan@ust-global.com	Created.
 * 2.0		RQ-004427	29-Nov-2016		Nisha@UST							Connection errors to the ESB are logged in the source system error fields.
 * 3.0      RQ-007793   07-Feb-2018     Meenakshi.Rajasekaran@UST           RQ-007793 ESB service calls from salesforce through USI - New URL
 * 4.0		RQ-009450	16-Nov-2018		manjunath.c.holekade@maersk.com		Replaced hardcoded 'CurrencyConversionManagement' end-point URL with customlabel
*/

public class ExchangeRate {

    // Webservice call made to pass the field details to ESB. ESB process the request and convert the local amount to USD and update back the SFDC.
    public static void calculateExchangeRate(list<Financial_Details__c> lstFinancialDetails, String strObjectName , String strModuleName) {
        try {
            // Custom Metadata Type to store webservice details
            ESB_Webservice__mdt esbServiceDetail = WebserviceUtilities.esbMetadataValue(strObjectName, strModuleName);
            String strHeader = WebserviceUtilities.getHeader(esbServiceDetail.Module__c, esbServiceDetail.OSB_Username__c, esbServiceDetail.Password__c); //Generate XML header
            String strFooter = WebserviceUtilities.getFooter(); // Generate XML footer
            String strBody =   '<v3:GetCurrencyAmountByDateRequest xmlns:v3="' + Label.CurrencyConversionMgmt + '">'+  //RQ-009450   
                                   formRequestBody(esbServiceDetail, lstFinancialDetails, strObjectName, strModuleName)+
                               '</v3:GetCurrencyAmountByDateRequest>'; // Generate XML body
            String strXMLRequest = strHeader + strBody + strFooter; // Generate complete XML
            System.debug('calculateExchangeRate.strXMLRequest: ' + strXMLRequest);
            
            // Invoke the webservice
            // v2.0 - Added additional parameters (Object name and set of ids to the WebserviceUtilities.sendHTTPRequest)
            WebserviceUtilities.sendHTTPRequest(strXMLRequest, String.valueof(esbServiceDetail.Timeout__c), esbServiceDetail.End_point_URL__c, 'Financial_Details__c', SObjectUtilities.getIds(lstFinancialDetails));
        }
        catch(Exception e) {
            System.debug(Logginglevel.ERROR, 'Exception! ' + e.getMessage());
        }
    }
    
    // Form XML body required for Exchange Rate Integration from the sObject record list passed.
    // The fields names to be retrieved from custom metatdata type 'Webservice Field List' based on the order field.
    public static String formRequestBody(ESB_Webservice__mdt esbServiceDetail, list<sObject> lstsObject, String strObjectName, String strModuleName) {
        String strXML = '';
        map<Integer, Webservice_Field_List__mdt> fieldListingMap = WebserviceUtilities.getWebServiceFieldMetadataValue(strObjectName, strModuleName);
        
        // Iterate sObject to get the field details of corresponding object
        for(sObject s : lstsObject) {
            String strObjectTag =  '<v3:GetCurrencyAmountByDateInputInfo>'+
		                                '<v3:CurrencyFrom>'+
		                                '<v3:CurrencyISOCd>'+getXMlMapping(1, s, fieldListingMap)+'</v3:CurrencyISOCd>'+
		                                '</v3:CurrencyFrom>'+
		                                '<v3:Amount>'+getXMlMapping(2, s, fieldListingMap)+'</v3:Amount>'+
		                                '<v3:CurrencyTo>'+
		                                    '<v3:CurrencyISOCd>'+getXMlMapping(3, s, fieldListingMap)+'</v3:CurrencyISOCd>'+ //Currency ISO Code
		                                '</v3:CurrencyTo>'+
		                                '<v3:ConversionDate>'+getFormattedDate(getXMlMapping(4, s, fieldListingMap))+'</v3:ConversionDate>'+ //Conversion date
		                                '<v3:SenderSystemTransactionID>'+getXMlMapping(5, s, fieldListingMap)+'</v3:SenderSystemTransactionID>'+ // Record Id
		                            '</v3:GetCurrencyAmountByDateInputInfo>';
            
            // Append the parameter details to a string
     		strXML = strXML + strObjectTag;
        }
        return strXML;
    }
    
    // Retrive values baed on custom metdata mapping
    static String getXMlMapping(Integer i, sObject s, map<Integer, Webservice_Field_List__mdt> fieldListingMap) {
        String xmlMapping = String.valueof(fieldListingMap.get(i).Type__c == 'Field' ? s.get(fieldListingMap.get(i).Value__c) : (String)fieldListingMap.get(i).Value__c);
        return xmlMapping;
    }
    
    // Remove the trailing time details after date string
    static String getFormattedDate(String dateStr) {  
        String dateOutput = dateStr.substringBefore('00:00:00').deleteWhitespace();
    	return dateOutput;
    }
    
}