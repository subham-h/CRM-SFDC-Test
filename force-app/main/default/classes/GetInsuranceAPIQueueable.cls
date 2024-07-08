/**
 * Revision 	Ref Number  	Date          Owner                          Description
 * -------- 	----------  	-----------   -------------------            -----------
 * 1.0          RQ-012785       30/12/2019    sidhartha                      Code created
 * 2.0          RQ-013124       19/03/2019    sidhartha                      Added PriceOwnerCheck API
 * 3.0          SPI-100         28/06/2022    Ronnie@SF                      Removed brand operator code hardcoding
 */
public class GetInsuranceAPIQueueable implements Queueable,Database.AllowsCallouts {
    private string getAuthToken;
    private User userId;
    public 	String strBody;
    private string strendPointUrl;
    public 	HTTPResponse getQuoteResponse;
    public List<QuoteLineItem> qLToUpdate = new List<QuoteLineItem>();
    public E2EInsuranceResponseWrapper responseWrapper;
    public map<Id, QuoteLineItem> mapUpdateQuoteLineItem = new map<Id, QuoteLineItem>();
    public map<String,String> e2eErrorMsg = new map<String,String>();
    List<QuoteLineItem> lstqLtoUpdate = new List<QuoteLineItem>();
    @TestVisible static Boolean makeCallout = true;
    QuoteLineItem lstQLI;
    public Map < Id, QuoteLineItem > QLToProcess = new Map < Id, QuoteLineItem >();
    public GetInsuranceAPIQueueable(Map <Id,QuoteLineItem> quoteLineItems) {
        this.QLToProcess = quoteLineItems;
        system.debug('QLToProcess' + this.QLToProcess);      
        userId = [select Maersk_User_Id__c from User where Id =: UserInfo.getUserId()];
        for(E2E_Insurance_Error_Messages__mdt errMsg: InsuranceAPIUtility.getErrorCodeMsg()) {
            e2eErrorMsg.put(errMsg.Error_Code__c, errMsg.Error_Message__c);
        }
    }
    
    public void execute(QueueableContext context) { 
        String queryParam;
        integer counter = 0;
        boolean flagForNewQueue = false;
        String endpointUrl;
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue('cargoInsuranceStatus', 'cargoInsuranceStatus');
        AO_Services__mdt aOServiceDetails = InsuranceAPIUtility.getAOServicesMetadataValue('getInsurance');
        if(aOServiceDetails!=null) {
            endpointUrl = aOServiceDetails.End_point_URL__c;
        }
        wrapRequestBody lstRequestBody;
        for (ID index: QLToProcess.keySet()) {
            QuoteLineItem objQLI = QLToProcess.get(index);
            system.debug('objQLI ' + objQLI);
            if (objQLI != null) {
                
                lstRequestBody = new wrapRequestBody(objQLI, createGetInsuranceBody(objQLI));
                system.debug('lstRequestBody ' + lstRequestBody.strBody);
                String authToken = AO_APILoginUtility.getLoginIdToken(BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), AOServiceDetail);
                system.debug('authTokengetInsurance ' + authToken);
                if(authToken !=NULL) {
                    if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new GetInsuranceAPIMockCallout(GetInsuranceAPIMockCallout.request_mode.getInsurance));
                    getQuoteResponse = InsuranceAPIUtility.callGetInsuranceAPI(authToken, String.valueof(userId.Maersk_User_Id__c), lstRequestBody.strBody, endpointUrl);   
                    system.debug('getQuoteResponse ' + getQuoteResponse.getBody());
                    if(getQuoteResponse.getStatusCode() == 201) {
                        responseWrapper = getInsuranceResponse(getQuoteResponse.getBody());
                        system.debug('responseWrapper ' + responseWrapper);
                        if(responseWrapper.insuranceRates[0].commodityCode == QLToProcess.get(index).Insurance_Commodity__r.Name) {
                            if(responseWrapper.quoteStatus == 'Referred') {
                                lstqLtoUpdate.add(new QuoteLineItem(Id = index, 
                                                                    Target_System_Error_Code__c = responseWrapper.quoteNotes.size() > 0 ? responseWrapper.quoteNotes[0] : '', 
                                                                    Agreement_Status__c = 'Quote Rejected', 
                                                                    Agreement_Id__c = String.valueof(responseWrapper.quoteId),
                                                                    Target_System_Error_Message__c =  e2eErrorMsg.get(responseWrapper.quoteNotes[0])));
                            }else if(responseWrapper.quoteStatus == 'Quote') {
                                lstqLtoUpdate.add(new QuoteLineItem(Id = index,
                                                                    Insurance_Premium__c = responseWrapper.insuranceRates[0].policyRate,
                                                                    Premium_Currency__c = responseWrapper.premiumCurrency,
                                                                    Policy_Rate_Percentage__c = Decimal.valueof(responseWrapper.insuranceRates[0].policyRatePercentage),
                                                                    Quote_Acceptance_Deadline__c = System.today() + 30,
                                                                    Target_System_Error_Code__c = '', 
                                                                    Agreement_Status__c = 'Quote Received', 
                                                                    Agreement_Id__c = String.valueof(responseWrapper.quoteId),
                                                                    Target_System_Error_Message__c =  '',
                                                                    Target_System_Error_Message_Raw__c = '')); 
                            }
                        }
                    }else {
                        lstqLtoUpdate.add(new QuoteLineItem(Id = index,
                                                            Target_System_Error_Code__c = String.valueof(getQuoteResponse.getStatusCode()), 
                                                            Agreement_Status__c = 'API Error',
                                                            Target_System_Error_Message__c = e2eErrorMsg.get('GetInsuranceAPIfail'),
                                                            Target_System_Error_Message_Raw__c = getQuoteResponse.getBody()));  
                    } 
                } else{
                    lstqLtoUpdate.add(new QuoteLineItem(Id = index,  
                                                        Agreement_Status__c = 'API Error',
                                                        Target_System_Error_Message__c = e2eErrorMsg.get('GetInsuranceAPIfail'))); 
                }
            }
            counter = counter + 1;
            system.debug('counter ' + counter);
            QLToProcess.remove(index);
            if (counter > 98) {
                flagForNewQueue = true;
                break;
            }
        }
        try {
            system.debug('lstqLtoUpdateupdate' + lstqLtoUpdate);
            if(!lstqLtoUpdate.isEmpty()) {
                update lstqLtoUpdate;
            }
        } catch (Exception e) {
            system.debug('Exception ' + e);
        }
        system.debug('flagForNewQueue ' + flagForNewQueue);
        system.debug('QLToProcess ' + QLToProcess);
        if (flagForNewQueue) {
            System.enqueueJob(new GetInsuranceAPIQueueable(QLToProcess));
        }
    }
    
    public static String createGetInsuranceBody(QuoteLineItem quoteLineItemLst) {
        system.debug('quoteLineItemLst' + quoteLineItemLst);
        CargoInsuranceQuote createBody = new CargoInsuranceQuote();
        List<commoditiesBooked> commoditiesBookedList = new List<commoditiesBooked>();
        commoditiesBooked cb = new commoditiesBooked();
        
        createBody.carrierCode = quoteLineItemLst.Quote.Carrier_Code__c;
        createBody.priceownercode = quoteLineItemLst.Quote.Price_Owner_Code__c;
        cb.commodityCode = String.valueof(quoteLineItemLst.Insurance_Commodity__r.Name);
        commoditiesBookedList.add(cb);
        createBody.origin = quoteLineItemLst.Origin_Geo_Code__c;
        createBody.destination = quoteLineItemLst.Destination_Geo_Code__c;
        createBody.commoditiesBooked = commoditiesBookedList; 
        String finalJSON = System.json.serialize(createBody);
        system.debug('finalJSON' + finalJSON);
        return finalJSON;
    }
    
    
    public static E2EInsuranceResponseWrapper getInsuranceResponse (String resp) {
        E2EInsuranceResponseWrapper responseWrapper = (E2EInsuranceResponseWrapper )JSON.deserialize(resp, E2EInsuranceResponseWrapper.class);
        return responseWrapper;
    }
    
    
    public class wrapRequestBody {
        QuoteLineItem objQLI;
        String strBody;
        
        public wrapRequestBody(QuoteLineItem objQLI, String strBody) {
            this.objQLI = objQLI;
            this.strBody = strBody;
        }
    }
    
    public class CargoInsuranceQuote {
        public string carrierCode;
        public string priceOwnerCode;
        public string origin;
        public string destination;
        public List<CommoditiesBooked> commoditiesBooked;
        public CargoInsuranceQuote() {
            commoditiesBooked = new List<CommoditiesBooked>();
        }
    }
    public class CommoditiesBooked {
        public string commodityCode;
        public decimal policyRatePercentage;
        public string rateCurrency;
    }
    
    public class E2EInsuranceResponseWrapper {
        
        public String quoteStatus;
        public List<String> quoteNotes;
        public Integer quoteId;
        public String premiumCurrency;
        public List<InsuranceRates> insuranceRates;
    }    
    public class QuoteNotes {
    }
    
    public class InsuranceRates {
        public String commodityCode;
        public Double policyRate;
        public Double policyRatePercentage;
    }
    
}