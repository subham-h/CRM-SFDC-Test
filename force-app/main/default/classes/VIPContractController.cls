/**
 * Version  Date           Owner                    RQ#            Description
 ****************************************************************************************************************************************
 * 1.0      14-Jun-2019    sidhartha mohapatra      #RQ-010321     Apex class for vIPContract LWC
 * 2.0      27-Jun-2019    sidhartha mohapatra      #RQ-011128     get Origin Destination for editing requestDetailLWC
 * 2.1      31-Jul-2019    Meghana Gupta            #RQ-011094     Modified method to fetch request and request details for Output generation into 1 method and split origin/destination
 * 2.2      05-Aug-2019    Meghana Gupta            #RQ-011279     Added bank fields in SOQL in getVIPRequest method. Run class in system mode. Add updateVIPRequest method
 * 2.3      07-Aug-2019    Meghana Gupta            #RQ-011279     Modifed updateVIPRequest method to add try/catch in order to return user friendly  error message
 * 2.4      04-Oct-2019    Sidhartha                #RQ-012074     Added logic to dispaly 'ALL PORTS' when Origin and Destination is blank.
 * 2.5      16-Oct-2019    Sidhartha                #RQ-012266     Added payout_currency__c field.
 * 3.0      14-Nov-2019    Meghana                  #RQ-012416     editOriginDestination: fix exception List has no rows for assignment
 * 4.0      19-Dec-2019    manjunath@maersk         #RQ-012809     Display the correct affiliate related content on VIP agreement
 * 5.0      06-Jul-2020    Neha@TCS                 #SFSE-1124     Commddity is to be displayed with spacing after semicolon if output document
 * 6.0      22-Jun-2022    Ronnie@SF                #SPI-100       Removed brand hardcoding
 */

public without sharing class VIPContractController {
    
    // wrapper class to hold Request record, list of trades/directions and Origin destiantion pairs
    public class wrapVIPRequest {
        
        @AuraEnabled public Request__c recRequest {get;set;} // request record instance
        @AuraEnabled public boolean isAddendum {get;set;} // flag to check whether to print Output doc or addendum
        @AuraEnabled public List<String> lstOdPairs {get; set;} // list of Origin-destination pairs
        @AuraEnabled public List<String> lstTrades {get; set;} // list of trades
        @AuraEnabled public List<String> lstDirections {get; set;} // list of directions
        @AuraEnabled public Boolean isAffilToBeIncld {get;set;} //RQ-012809 flag to check whether Affiliates_to_be_Included__c is set to Yes/No
        @AuraEnabled public List<String> commodityRateSheet {get; set;}  //SFSE 1124 Commodity Rate Sheet field is to be displayed with spacing after semi colon
        @AuraEnabled public String brandName {get;set;} // SPI-100: VIP contract brand
        @AuraEnabled public String companyLegalName {get;set;} // SPI-100: VIP contract company
        @AuraEnabled public String brandWebsite {get;set;} // SPI-100: Brand website
        
        public wrapVIPRequest() {
            
            this.isAddendum = false;
            this.lstOdPairs = new List<String>();      
            this.lstTrades = new List<String>();
            this.lstDirections = new List<String>();
            this.recRequest = null;
            this.isAffilToBeIncld = true;
            this.commodityRateSheet = new List<String>();
            this.brandName = '';
            this.companyLegalName = '';
            this.brandWebsite = '';
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static wrapVIPRequest getVIPRequest(String requestId) {
        
        wrapVIPRequest response = new wrapVIPRequest();
        
        // fetch request and request details        
        // v2.2 include bank fields
        List<Request__c> lstRequest = [SELECT Id, Per_Container_Payout__c, Payout_Currency__c, Bill_to_Party__c, Bill_to_Party__r.Name, Bill_to_Party_SCV_Code__c , Offsetting_or_Refund__c, Payout_Frequency__c, Name, File_on_Concern_Code__c, Account__r.Name, Account_Address__c, 
                                       Legal_Entity__c, Liner_Brand__c, Agreement_Date__c, Sales_Office__c, Amendment_Date__c, Effective_Date__c, Expiry_Date__c,
                                       Account_Concern_Code__c, Account_SCV_Code__c, Client_Owner_APMM_ID__c, Payout_Type__c, VIP_Deal_Type__c, Output_Generated__c, 
                                       Rebate_Calculation_Currency__c, Service_Contract__c, Cargo_Type__c, Commodity_Rate_Sheet__c,
                                       Tier_1_from_FFE__c, Tier_1_to_FFE__c, Tier_1_Amount_per_FFE__c, Tier_2_from_FFE__c, Tier_2_to_FFE__c, Tier_2_Amount_per_FFE__c,
                                       Tier_3_from_FFE__c, Tier_3_to_FFE__c, Tier_3_Amount_per_FFE__c, Tier_4_from_FFE__c, Tier_4_to_FFE__c, Tier_4_Amount_per_FFE__c, 
                                       Tier_5_from_FFE__c, Tier_5_to_FFE__c, Tier_5_Amount_per_FFE__c,
                                       Bank_Name__c, Bank_Account_Number__c, Bank_Code_and_Branch_Code__c, Bank_Country__c,
                                       Bank_Swift_Code__c, IBAN_Code__c, Price_Owners_Email_Address__c,Bank_Address__c,Filing_Number__c,Affiliates_to_be_Included__c,
                                       (SELECT Id, Origin__c, Destination__c, Route__r.Name, Route__r.Route_Direction_Code__c, Route__r.Route_Code__c FROM Request_Details__r)
                                       FROM Request__c
                                       WHERE Id = :requestId and Status__c = 'Approved'];
        
        response.recRequest = lstRequest.get(0);
        if (lstRequest.get(0).Affiliates_to_be_Included__c == 'No') {
            response.isAffilToBeIncld = false;
        }
        if (lstRequest.get(0).Output_Generated__c) {
            response.isAddendum = true;
        } else {
            if(lstRequest.get(0).Commodity_Rate_Sheet__c != null) {
                 response.commodityRateSheet = String.valueOf(lstRequest.get(0).Commodity_Rate_Sheet__c).split(';');
            }
            // for output doc generate od pair list
            for (Request_Detail__c recRequestDetail :lstRequest.get(0).Request_Details__r) {
                
                String strTrade = recRequestDetail.Route__r.Route_Code__c + ' - ' + recRequestDetail.Route__r.Name;
                
                response.lstTrades.add(strTrade);
                response.lstDirections.add(strTrade + ' - ' + recRequestDetail.Route__r.Route_Direction_Code__c);
                
                List<String> lstOrigins = new List<String>();
                List<String> lstDest = new List<String>();
                
                if( recRequestDetail.Destination__c == NULL && recRequestDetail.Origin__c == NULL) {
                    
                } else {
                    if (recRequestDetail.Origin__c != NULL) {
                        lstOrigins = recRequestDetail.Origin__c.split('; ');
                    } else {
                        lstOrigins.add('ALL PORTS|');   
                    }
                    if (recRequestDetail.Destination__c != NULL) {
                        lstDest = recRequestDetail.Destination__c.split('; ');
                    } else {
                        lstDest.add('ALL PORTS|');   
                    }
                }
                
                for (String strOrigin : lstOrigins) {
                    for (String strDest : lstDest) {
                        response.lstOdPairs.add(strTrade + ' - ' + recRequestDetail.Route__r.Route_Direction_Code__c + ' - ' + strOrigin.substringBefore('|') + ' - ' + strDest.substringBefore('|'));
                    }
                }               
            }            
        }
        
        response.brandName = BrandUtilities.getBrandVipContractBrand(lstRequest.get(0).Liner_Brand__c);
        response.companyLegalName = BrandUtilities.getBrandVipContractCompany(lstRequest.get(0).Liner_Brand__c);
        response.brandWebsite = BrandUtilities.getBrandWebsite(lstRequest.get(0).Liner_Brand__c);
        
        system.debug(response);
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static Request_Detail__c editOriginDestination(String reqdetailId) {
        
        system.debug('reqdetailId' + reqdetailId);
        List<Request_Detail__c> lstReqd = [SELECT Id, Name, Approver__c, VIP_Deal__c, Route__c, Status__c, Reason_for_Rejection__c, Origin__c, Destination__c
                                           FROM Request_Detail__c WHERE Id = :reqdetailId];
        
        if (lstReqd.isEmpty()) {
            return null;
        } else {
            return lstReqd[0];
        }
    }
    
    @AuraEnabled
    public static string updateVIPRequest(Id recordId, String strbankName, String strbankAddress, String strbankCountry, String strBankAccountNo, String strBankCode, String strSwiftCode, String strIbanCode, String strPricingOwnerEmail){
        
        String response = 'SUCCESS';
        
        try {
            Request__c recRequest = [SELECT Id, Trigger_Refresh_Email_Addresses__c FROM Request__c WHERE Id = :recordId];
            recRequest.Id = recordId;
            
            if (strbankName != '') {
                recRequest.Bank_Name__c = strbankName ;
            }
            
            if (strBankAccountNo != '') {
                recRequest.Bank_Account_Number__c = strBankAccountNo;
            }
            
            if (strBankCode != '') {
                recRequest.Bank_Code_and_Branch_Code__c = strBankCode ; 
            }
            
            if (strbankCountry != '') {
                recRequest.Bank_Country__c = strbankCountry;
            }
            
            if (strSwiftCode != '') {
                recRequest.Bank_Swift_Code__c = strSwiftCode;
            }
            
            if (strIbanCode != '') {
                recRequest.IBAN_Code__c = strIbanCode;
            }
            
            if (strPricingOwnerEmail != '') {
                recRequest.Price_Owners_Email_Address__c = strPricingOwnerEmail;
            }
            
            if (strbankAddress != '') {
                recRequest.Bank_Address__c = strbankAddress;
            }
            
            recRequest.Trigger_Refresh_Email_Addresses__c = recRequest.Trigger_Refresh_Email_Addresses__c ? false : true; // used a existing checkbox field to skip resubmit workflow rule execution 
            system.debug('recRequest');
            system.debug(recRequest);
            
            TriggerExecutionController.skipRequestTrigger(true);
            update recRequest;       
            TriggerExecutionController.skipRequestTrigger(false);
            system.debug(recRequest);
            
        } catch(DMLException ex) {
            response = ex.getDmlMessage(0);
            system.debug(response);
        }
        return response;
    }
}