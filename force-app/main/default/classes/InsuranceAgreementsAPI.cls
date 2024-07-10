/**
 * Purpose : Wrapper and Orchestraction class for Insurance Agreements API callouts
 * Test Class : QuoteTrigger_Test
 * 
 * Revision     Ref Number      Date          Owner                          Description
 * --------     ----------      -----------   -------------------            -----------
 * 1.0          RQ-012787       27/12/2019    Amritesh                       Class created
 * 1.1          RQ-012583       08/01/2019    Abhinav Ankit                  E2E Insurance: Cancel Agreement Code added 
 * 2.0          RQ-013342       31/03/2020    Amritesh                       Added timeout and Idtoken cache
 * 3.0          #SFSE-8466      20/05/2022	  Rakesh Allam                   Added Consumer Key as part of APIGEE standards
 * 3.1          SPI-100         13/06/2022    Ronnie@SF                      Removed brand hardcoding
 */ 
public with sharing class InsuranceAgreementsAPI {
    
    public class ApiCalloutQueueable implements Queueable,Database.AllowsCallouts {
        
        List<Quote> lstQuote = new List<Quote>(); 
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>(); 
        @TestVisible List<Quote> lstQuoteUpdate = new List<Quote>(); 
        List<QuoteLineItem> lstQLIUpdate = new List<QuoteLineItem>(); 
        String strRespBody ;
        String strStatusCode ;
        
        public ApiCalloutQueueable(List<Quote> lstQuote) {
            this.lstQuote = lstQuote;
        }
        public ApiCalloutQueueable(List<QuoteLineItem> lstQLI) {
            this.lstQLI = lstQLI;
        }
        
        /**
        * @description : execute method
        * @return : void
        */
        public void execute(QueueableContext context) { 
            
            List<wrapRequestBody> lstRequestBody = new List<wrapRequestBody>();
            if(!lstQuote.isEmpty()) {
                for(Quote objQuote : lstQuote) {
                    lstRequestBody.add(new wrapRequestBody(objQuote, createRequestBody(objQuote.Id)));
                }
            }
            else if(!lstQLI.isEmpty()) {
                for(QuoteLineItem objQLI : lstQLI) {
                    lstRequestBody.add(new wrapRequestBody(objQLI, createRequestBody(objQLI.Id)));                    
                }
            }
            for(wrapRequestBody objWRB : lstRequestBody) {
                String endpointUrl;
                AO_Services__mdt aOServiceDetails = InsuranceAPIUtility.getAOServicesMetadataValue('postInsuranceAgreements');
                if(aOServiceDetails!=null) {
                    endpointUrl = aOServiceDetails.End_point_URL__c;
                }
                try{
                    String idToken; //= InsuranceAPIUtility.getE2EInsuranceToken();
                    if(Test.isRunningTest()) {     
                        idToken = '12345';
                        Test.setMock(HttpCalloutMock.class, new InsuranceAPIMockCallout(InsuranceAPIMockCallout.request_mode.agreements)); 
                    } else {
                        String operatorCode = BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE);
                        idToken = AO_APILoginUtility.getLoginIdToken(operatorCode.toUpperCase(), aOServiceDetails);
                    }
                    //Added Consumer Key - #SFSE-8466
                    HTTPResponse hresp = InsuranceAPIUtility.sendRequest(endpointUrl, 'POST', objWRB.strBody, aOServiceDetails.Timeout__c, new Map<String,String>{'Authorization'=>'Bearer ' +idToken, 'Consumer-Key'=>aOServiceDetails.Authorization_Key__c});
                    System.debug('>>> InsuranceAgreementsAPI Response : ' + hresp);
                    Integer statusCode = hresp.getStatusCode();
                    strRespBody = hresp.getBody();
                    strStatusCode = String.valueof(hresp.getStatusCode());
                  //  Map<Integer, String> mapFailureStatus = new Map<Integer, String>{400=>'Bad Request',401=>'The user is not authenticated in the system',403=>'The user does not have permissions to access this endpoint',404=>'MaintainPAYGAgreement not found',500=>'Internal server error'};
                        
                        if(statusCode==201) { //success
                            if(!lstQuote.isEmpty()){
                                lstQuoteUpdate.add(updateQuote(objWRB, 'Success', ''));
                            }
                            if(objWRB.objQLI!=null && lstQuote.isEmpty()) {
                                QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objWRB.objQLI.Id,Target_System_Error_Code__c=strStatusCode,Target_System_Error_Message_Raw__c = strRespBody,Target_System_Error_Message__c=''); 
                                lstQLIUpdate.add(uptQuoteLineItem);
                            }						
                        }                            
                    else { //failure
                        if(!lstQuote.isEmpty()) {
                            lstQuoteUpdate.add(updateQuote(objWRB, 'API Failure', InsuranceAPIUtility.getErrorCodeMsg('InsuranceAgreementAPIfail')));
                        }                        
                        if(objWRB.objQLI!=null && lstQuote.isEmpty() ) {
                            QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objWRB.objQLI.Id , Agreement_Status__c='API Error',Target_System_Error_Code__c=strStatusCode,Target_System_Error_Message_Raw__c = strRespBody,Target_System_Error_Message__c=InsuranceAPIUtility.getErrorCodeMsg('InsuranceCanceAPIfail')); 
                            lstQLIUpdate.add(uptQuoteLineItem);
                        }
                    }
                } catch(Exception ex) {
                    System.debug('>>> Exception : ' + ex.getMessage());
                    System.debug('>>> Stack : ' + ex.getStackTraceString());
                    if(!lstQuote.isEmpty()){
                        lstQuoteUpdate.add(updateQuote(objWRB, 'API Failure', InsuranceAPIUtility.getErrorCodeMsg('InsuranceAgreementAPIfail')));
                    }
                    if(objWRB.objQLI!=null && lstQuote.isEmpty()) {
                        QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objWRB.objQLI.Id , Agreement_Status__c='API Error',Target_System_Error_Code__c=strStatusCode,Target_System_Error_Message_Raw__c = strRespBody,Target_System_Error_Message__c=InsuranceAPIUtility.getErrorCodeMsg('InsuranceCanceAPIfail')); 
                        lstQLIUpdate.add(uptQuoteLineItem);
                    }
                    ErrorLogger.writeErrors( 'SFDC', 'Quote', 'InsuranceAgreementsAPI.ApiCalloutQueueable', new list<Exception>{ex}); 
                }
            }
            
            if(!lstQLIUpdate.isEmpty())
                update lstQLIUpdate;
            if(!lstQuoteUpdate.isEmpty())
                update lstQuoteUpdate;
            
        }
    }
    
    /**
    * @description : to update quote details
    * @return : quote record
    */
    private static quote updateQuote(wrapRequestBody objWRB, String strStatus, String strDescription) {
        
        Quote uptQuote = new Quote(Agreement_Status__c=strStatus, Description=strDescription);
        if(objWRB.objQuote!=null) {                         
            uptQuote.Id = objWRB.objQuote.Id; //update uptQuote;
        } 
        return uptQuote;
    }
    
    /**
    * @description : to create HTTP callout request
    * @return : json string of request details
    */
    public static String createRequestBody(Id quoteId) { 
        CargoInsuranceAgreements agreements = new CargoInsuranceAgreements();
        for(QuoteLineItem objQLI : InsuranceAPIUtility.getQuoteLineItems(quoteId)) {
            if(String.isBlank(objQLI.Agreement_Status__c)) continue;
            String agreementStatus; //Agreed, Cancelled
            CargoInsuranceAgreement innerBody;
            String agreementStartDate = objQLI.Agreement_Start_Date__c==null ? '' : String.valueOf(objQLI.Agreement_Start_Date__c);
            String agreementEndDate = objQLI.Agreement_End_Date__c==null ? '' : String.valueOf(objQLI.Agreement_End_Date__c);
            Integer agreementId = (String.isNotBlank(objQLI.Agreement_Id__c) && objQLI.Agreement_Id__c.isNumeric()) ? Integer.valueOf(objQLI.Agreement_Id__c) : 0;
            String cancellationDate = '';
            if(objQLI.Agreement_Status__c.contains('Accepted')) {
                agreementStatus = 'Agreed';                
            } else if(objQLI.Agreement_Status__c.contains('Cancelled')) {
                agreementStatus = 'Cancelled';
                cancellationDate = String.valueOf(Date.today());
            } else continue;
            innerBody = createCargoInsuranceAgreement(objQLI.Quote.Carrier_Code__c, agreementId, agreementStatus, objQLI.Origin_Geo_Code__c, objQLI.Destination_Geo_Code__c, agreementStartDate, agreementEndDate, objQLI.Quote.Account.SCV_Code__c, objQLI.Quote.Account.Name, objQLI.Insurance_Commodity__r.Commodity_Code__c, objQLI.Policy_Rate_Percentage__c, objQLI.Premium_Currency__c, cancellationDate);
            System.debug('>>> agreementInnerBody : ' + innerBody);
            agreements.cargoInsuranceAgreements.add(innerBody);
        }    
        return JSON.serialize(agreements);
    }
    
    /**
    * @description : forming Cargo Insurance Wrapper format
    * @return : wrapper of CargoInsuranceAgreement
    */
    private static CargoInsuranceAgreement createCargoInsuranceAgreement(String carrierCode, Integer agreementId, string agreementStatus, string origin, string destination, string agreementStartDate, string agreementEndDate, string customerCode, string customerName, string commodityCode, decimal policyRatePercentage, string rateCurrency, string cancellationDate)
    {        
        CargoInsuranceAgreement agreement = new CargoInsuranceAgreement();
        agreement.carrierCode = carrierCode;
        agreement.agreementId = agreementId;
        agreement.agreementStatus = agreementStatus;
        agreement.origin = origin;
        agreement.destination = destination;
        agreement.agreementStartDate = agreementStartDate;
        agreement.agreementEndDate = agreementEndDate;
        agreement.customerCode = customerCode;
        agreement.customerName = customerName;
        agreement.cancellationDate = cancellationDate;
        
        InsuranceAgreementsApi.CommodityDetails cmdDet = new InsuranceAgreementsApi.CommodityDetails();
        cmdDet.commodityCode = commodityCode;
        cmdDet.policyRatePercentage = policyRatePercentage;
        cmdDet.rateCurrency = rateCurrency;   
        agreement.commodityRates.add(cmdDet);
        
        return agreement;
    }
    /*
private static ApiError parseResponse(String strBody) {
if(String.isBlank(strBody)) {
try{
ApiError respBody = (ApiError) JSON.deserialize(strBody, ApiError.class);
return respBody;
} catch(Exception ex){}
} 
return null;
}*/
    
    
    
    /**************** wrapper classes - start **************************/
    
    public class CommodityDetails {
        public string commodityCode;
        public decimal policyRatePercentage;
        public string rateCurrency;
    }
    
    public class CargoInsuranceAgreements {
        public List<CargoInsuranceAgreement> cargoInsuranceAgreements;    
        public CargoInsuranceAgreements() {
            cargoInsuranceAgreements = new List<CargoInsuranceAgreement>();
        }
    }
    
    public class CargoInsuranceAgreement {
        public string carrierCode;
        public integer agreementId;
        public string agreementStatus; //{Agreed, Cancelled}
        public string origin;
        public string destination;
        public List<CommodityDetails> commodityRates;
        public string agreementStartDate;
        public string agreementEndDate;
        public string cancellationDate;
        public string customerCode;
        public string customerName;
        
        public CargoInsuranceAgreement() {
            commodityRates = new List<CommodityDetails>();
        }
    }
    
    public class ApiError {
        public string method;
        public string requestUri;
        public string status;
        public string timestamp;
        public string message;
        public string debugMessage;
        public List<ApiValidationError> subErrors;
    }
    
    public class ApiValidationError {
        public string field;
        public string rejectedValue;
        public string message;
    }
    public class wrapRequestBody {
        Quote objQuote;
        QuoteLineItem objQLI;
        String strBody;
        
        public wrapRequestBody(Quote objQuote, String strBody) {
            this.objQuote = objQuote;
            this.strBody = strBody;
        }
        
        public wrapRequestBody(QuoteLineItem objQLI, String strBody) {
            this.objQLI = objQLI;
            this.strBody = strBody;
        }
    }
    
/**************** wrapper classes - end **************************/
    
    
/********** Swagger definition - start *************

    swagger: '2.0'
info:
  description: REST API for Cargo Insurance Agreements
  version: '1.0.0'
  title: Cargo Insurance Agreements API
host: api.maerskline.com
schemes:
  - https
paths:
  /cargoInsuranceAgreements:
    post:
      tags:
        - MaintainPAYGAgreement
      summary: Insert or Update the annual insurance agreement(s)
      description: Insert or update the annual insurance agreement(s) with new data - to be used by SFDC only.
      operationId: putAgreementUsingPUT
      consumes:
        - application/json
      produces:
        - application/json
      parameters:
        - name: Authorization
          in: header
          description: Authorization token.
          type: string
          required: true
        - in: body
          name: agreements
          description: cargoInsuranceAgreements
          required: true
          schema:
              $ref: '#/definitions/CargoInsuranceAgreements'
      responses:
        '201':
          description: Created
        '400':
          description: Bad Request.
          schema:
            $ref: '#/definitions/ApiError'
        '401':
          description: The user is not authenticated in the system
          schema:
            $ref: '#/definitions/ApiError'
        '403':
          description: The user does not have permissions to access this endpoint
          schema:
            $ref: '#/definitions/ApiError'
        '404':
          description: MaintainPAYGAgreement not found
          schema:
            $ref: '#/definitions/ApiError'
        '500':
          description: Internal server error.
          schema:
            $ref: '#/definitions/ApiError'
definitions:
  CommodityDetails:
    type: object
    required: 
      - commodityCode
      - policyRatePercentage
      - rateCurrency
    properties:
      commodityCode:
        type: string
        description: The code of the commodity covered by the agreement
      policyRatePercentage:
        type: number
        multipleOf: 0.01  # up to 2 decimal places
        description: The cost of the insurance as percentage of the value of the cargo 
      rateCurrency:
        type: string
        format: integer
        description: The currency code of the policyRate
        pattern: '[A-Z]{3}'
  CargoInsuranceAgreements:
    type: object
    properties:
      cargoInsuranceAgreements:
          type: array
          items:
            $ref: '#/definitions/CargoInsuranceAgreement'
  CargoInsuranceAgreement:
    type: object
    required:
      - carrierCode
      - agreementId
      - agreementStatus
      - origin
      - destination
      - agreementStartDate
      - agreementEndDate
      - customerCode
      - customerName
    properties:
      carrierCode:
        description: |
          Standard Carrier Alpha Code (SCAC)
          MAEU - Maersk A/S
          SAFM - Maersk A/S trading as Safmarine
          SEAU - Maersk A/S* trading as Sealand Americas
          SEJJ - Sealand Europe A/S
          MCPU - Sealand Maersk Asia Pte. Ltd.
          MAEI - Maersk Line Limited
        type: string
        enum:
          - 'MAEU'
          - 'SAFM'
          - 'SEAU'
          - 'SEJJ'
          - 'MCPU'
          - 'MAEI'
        default: 'MAEU'
      agreementId:
        type: integer
        description: The unique identifer for a PAYG Agreement
        pattern: '[0-9]{8}'
      agreementStatus:
        type: string
        enum: [Agreed, Cancelled]
      origin:
        type: string
        description: The Origin country that the agreement covers
        pattern: '[A-Z]{2}'
      destination:
        type: string
        description: The Destination country that the agreement covers
        pattern: '[A-Z]{2}'
      commodityRates:
        type: array
        items:
          $ref: '#/definitions/CommodityDetails'
      agreementStartDate:
        type: string
        format: date
        description: The date that the agreement starts
        example: "2019-20-07"
      agreementEndDate:
        type: string
        format: date
        description: The date that the agreement ends
        example: "2019-20-07"
      cancellationDate:
        type: string
        format: date
        description: The date that the agreement was cancelled
        example: "2019-20-07"
      customerCode:
        type: string
        description: The customer code of the customer who has made the agreement
        pattern: '[a-zA-Z0-9]{0,10}'
      customerName:
        type: string
        description: The name of the customer who has made the agreement
        pattern: '[a-zA-Z0-9-&/#@()]{0,40}'
  ApiError:
    type: object
    required:
      - method
      - requestUri
      - status
      - timestamp
      - message
    properties:
      method:
        description: The request method type e.g. GET, POST.
        type: string
      requestUri:
        description: The request URI.
        type: string
      status:
        description: The textual representation of the response status.
        type: string
      timestamp:
        description: The date and time (dd-MM-yyyy hh:mm:ss) the error occured.
        type: string
      message:
        description:  High level error message.
        type: string
      debugMessage:
        description: Detailed error message.
        type: string
      subErrors:
        description: The list of invalid fields in the request.
        type: array
        items:
          $ref: '#/definitions/ApiValidationError'
  ApiValidationError:
    type: object
    required:
      - field
      - rejectedValue
      - message
    properties:
      field:
        description: The field that has failed validation.
        type: string
      rejectedValue:
        description: The value that has failed validation.
        type: string
      message:
        description: The reason and advice for failed validation.
        type: string
        
********** Swagger definition - end *************/

}