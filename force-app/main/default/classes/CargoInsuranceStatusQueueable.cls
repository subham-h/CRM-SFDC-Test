/**
 * Revision 	Ref Number  	Date          Owner                     Description
 * -------- 	----------  	-----------   -------------------       -----------
 * 1.0          RQ-012785       30/12/2019    sidhartha                 Code created
 * 2.0          RQ-013124       19/03/2019	  sidhartha                 Added PriceOwnerCheck API
 * 3.0          SPI-100         28/06/2022    Ronnie@SF                 Removed brand operator code hardcoding
 */
public class CargoInsuranceStatusQueueable implements Queueable,Database.AllowsCallouts {
    
    
    private User userId;
    public 	String strBody;
    public 	HTTPResponse getQuoteResponse;
    public List<QuoteLineItem> qLToUpdate = new List<QuoteLineItem>();
    public E2EInsuranceResponseWrapper responseWrapper;
    List<QuoteLineItem> lstqLtoUpdate = new List<QuoteLineItem>();
    @TestVisible static Boolean makeCallout = true;
    List<QuoteLineItem> QLI = new List<QuoteLineItem>();
    public map<String,String> e2eErrorMsg = new map<String,String>();
    public List<QuoteLineItem> ql = new List<QuoteLineItem>();
    public String authToken;
    public Map < Id, QuoteLineItem > QLToProcess = new Map < Id, QuoteLineItem >();
    public List<QuoteLineItem> firstQueueSuccessQL = new List <QuoteLineItem> ();
    public Map < Id, QuoteLineItem > MapfirstQueueSuccessQL = new Map < Id, QuoteLineItem >();
    public CargoInsuranceStatusQueueable(Map <Id,QuoteLineItem> quoteLineItems) {
        this.QLToProcess = quoteLineItems;
        system.debug('this.QLToProcess ' + this.QLToProcess);
        Set<Id> setqLId = new Set<Id>();
        userId = [select Maersk_User_Id__c from User where Id =: UserInfo.getUserId()];
    }
    
    public void execute(QueueableContext context) { 
        String queryParam;
        integer counter = 0;
        boolean flagForNewQueue = false;
        AO_Services__mdt AOServiceDetail = WebserviceUtilities.getAOServicesMetadataValue('cargoInsuranceStatus', 'cargoInsuranceStatus');
        String endpointUrl;
        for (ID index: QLToProcess.keySet()) {
            QuoteLineItem objQLI = QLToProcess.get(index);
            system.debug('objQLI ' + objQLI);
            if (objQLI != null) {
                try {
                    queryParam = '?carrierCode='+objQLI.Quote.Carrier_Code__c+'&origin='+objQLI.Origin_Geo_Code__c+'&destination='+objQLI.Destination_Geo_Code__c +'&commodityCode='+objQLI.Insurance_Commodity__c +'&priceOwnerCode='+objQLI.Quote.Price_Owner_Code__c;
                    if(AOServiceDetail!=null) {
                        endpointUrl = AOServiceDetail.End_point_URL__c;
                        endpointUrl = endpointUrl+queryParam; 
                    }
                    String authToken = AO_APILoginUtility.getLoginIdToken(BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE).toUpperCase(), AOServiceDetail);
                    if(authToken !=NULL) {
                        system.debug('authTokencarogchk ' + authToken);
                        if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.priceOwnerchk));
                        if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new CargoInsuranceStatusQueueableMock(CargoInsuranceStatusQueueableMock.request_mode.priceOwnerchkng));
                        getQuoteResponse = InsuranceAPIUtility.callGetInsuranceAPICheckCity(authToken, String.valueof(userId.Maersk_User_Id__c), endpointUrl);
                        system.debug('getQuoteResponse ' + getQuoteResponse.getBody());    
                        if (getQuoteResponse.getStatusCode() == 200) {
                            responseWrapper = getInsuranceResponse(getQuoteResponse.getBody());
                            if(responseWrapper.insuranceAvailable[0].insuranceStatusCode == 1 || responseWrapper.insuranceAvailable[0].insuranceStatusCode == 2) {
                                firstQueueSuccessQL.add(objQLI);
                                MapfirstQueueSuccessQL.put(objQLI.Id, objQLI);
                            } else if(responseWrapper.insuranceAvailable[0].insuranceStatusCode == 3 || responseWrapper.insuranceAvailable[0].insuranceStatusCode == 4){
                                QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objQLI.Id , Agreement_Status__c='Quote Rejected',
                                                                                   Target_System_Error_Code__c=String.valueof(responseWrapper.insuranceAvailable[0].insuranceStatusCode),
                                                                                   Target_System_Error_Message__c=responseWrapper.insuranceAvailable[0].insuranceStatusNote); 
                                lstqLtoUpdate.add(uptQuoteLineItem);
                            }
                        } else {
                            QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objQLI.Id , Target_System_Error_Message__c=InsuranceAPIUtility.getErrorCodeMsg('GetInsuranceAPIfail'), Agreement_Status__c='API Error'); 
                            lstqLtoUpdate.add(uptQuoteLineItem);
                        }
                    } else {
                        QuoteLineItem uptQuoteLineItem = new QuoteLineItem(Id=objQLI.Id , Target_System_Error_Message__c=InsuranceAPIUtility.getErrorCodeMsg('GetInsuranceAPIfail'), Agreement_Status__c='API Error'); 
                        lstqLtoUpdate.add(uptQuoteLineItem);
                    }
                } catch (Exception ex) {
                    system.debug(ex.getMessage());
                } 
                counter = counter + 1;              
                //remove current element after api call
                QLToProcess.remove(index);
                //Just for creating new queue
                if (counter > 98) {
                    flagForNewQueue = true;
                    break;
                } 
            }
        }
        try{
            update lstqLtoUpdate;
        } Catch (Exception e) {
            
        }        
        //call another callout for all successful records
        if (firstQueueSuccessQL.size() > 0) {
            if(!Test.isRunningTest()) {
                System.enqueueJob(new GetInsuranceAPIQueueable(MapfirstQueueSuccessQL));
            }
        } 
        //If callout limit exceed for 1 transaction
        if (flagForNewQueue) {
            System.enqueueJob(new CargoInsuranceStatusQueueable(QLToProcess));
        }
    }
    
    public static E2EInsuranceResponseWrapper getInsuranceResponse (String resp) {
        E2EInsuranceResponseWrapper responseWrapper = (E2EInsuranceResponseWrapper )JSON.deserialize(resp, E2EInsuranceResponseWrapper.class);
        return responseWrapper;
    }
    public class E2EInsuranceResponseWrapper {
        public List<insuranceAvailable> insuranceAvailable;
        
        public E2EInsuranceResponseWrapper() {
            insuranceAvailable = new List<insuranceAvailable>();
        }
    }  
    
    public class insuranceAvailable {
        public integer insuranceStatusCode;
        public string insuranceStatusNote;
    }	
}