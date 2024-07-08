/*
 * Author   : Ragu@UST
 * Purpose  : Centralize the record selection process for Financial_Details__c object.
 *          Defines the methods which iterate and segregate the Financial_Details__c records for further use.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #RQ-002683  23-Feb-2016 Sandhya@UST             Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      SC-9293     22-12-2023 Shahanawaz@maersk 		Create feeditem on parent Case
 * 
 */

public class FinancialDetailsRecordSelector implements RecordSelector {
    
    private TriggerHandler finDetailsTriggerHandler;
    
    // This variable is used for Exchange Rate calculation (ExchangeRate class)
    public map<Id, Financial_Details__c> mapFinDetForExRate = new map<Id, Financial_Details__c>();
    public map<Id, Financial_Details__c> mapUSDLocalCurFinDet = new map<Id, Financial_Details__c>();
    public List<Financial_Details__c> finDetailsList = new List<Financial_Details__c>();
    
    public FinancialDetailsRecordSelector(list<Financial_Details__c> lstFinancialDetails, map<Id, Financial_Details__c> mapOldFinancialDetails, TriggerHandler finDetailsTriggerHandler) {
        this.finDetailsTriggerHandler = finDetailsTriggerHandler;
        
        this.selectRecords(lstFinancialDetails, mapOldFinancialDetails);
        
        if(lstFinancialDetails != null) {
            this.getRelatedRecords(lstFinancialDetails);
        }
        else if(mapOldFinancialDetails != null) {
            this.getRelatedRecords(mapOldFinancialDetails.values());
        }
    }
    
    public void selectRecords(list<Financial_Details__c> lstFinancialDetails, map<Id, sObject> mapOldFinancialDetails) {
        if(lstFinancialDetails != null) {
            for(Financial_Details__c newFinDetail : (list<Financial_Details__c>)lstFinancialDetails) {
                Financial_Details__c oldFinDetail;
                if(mapOldFinancialDetails != null && !mapOldFinancialDetails.isEmpty()) {
                    oldFinDetail = (Financial_Details__c)mapOldFinancialDetails.get(newFinDetail.Id);
                }
                if(finDetailsTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(finDetailsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
                        if((newFinDetail.Local_Amount__c != null && newFinDetail.Local_Currency__c != null && newFinDetail.Conversion_Date__c != null) 
                           && (newFinDetail.Recalculate_XRate__c == true || (newFinDetail.Local_Amount__c != oldFinDetail.Local_Amount__c || newFinDetail.Local_Currency__c != oldFinDetail.Local_Currency__c || newFinDetail.Conversion_Date__c != oldFinDetail.Conversion_Date__c)))
                        {
                            if(newFinDetail.Local_Currency__c != Label.Converted_Local_Currency){
                                mapFinDetForExRate.put(newFinDetail.Id, newFinDetail);
                            }else{
                                mapUSDLocalCurFinDet.put(newFinDetail.Id, newFinDetail);
                            }
                        }
                    } 
                    else if(finDetailsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newFinDetail.Local_Amount__c != null && newFinDetail.Local_Currency__c != null && newFinDetail.Conversion_Date__c != null && newFinDetail.Local_Currency__c == Label.Converted_Local_Currency) {
                            mapUSDLocalCurFinDet.put(newFinDetail.Id, newFinDetail);
                        }
                    }
                }
                else if(finDetailsTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(finDetailsTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newFinDetail.Local_Amount__c != null && newFinDetail.Local_Currency__c != null && newFinDetail.Conversion_Date__c != null ) {
                            if(newFinDetail.Local_Currency__c != Label.Converted_Local_Currency){
                                mapFinDetForExRate.put(newFinDetail.Id, newFinDetail);
                            }
                        }
                        //SC-9293
                        if(newFinDetail.Claim__c != null){
                            finDetailsList.add(newFinDetail);
                        }
                    }
                }
            }
        }       
    }
    
    public void getRelatedRecords(list<Financial_Details__c> lstFinancialDetails) {
        
    }
        
}