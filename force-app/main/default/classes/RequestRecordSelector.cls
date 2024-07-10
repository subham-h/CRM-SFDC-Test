/*
 * Author   : Jagadeesan.Sakthivel@UST
 * Purpose  : To create follow records for Account's territory sales owner related to the Request
 * 
 * Revision Ref Number      Date        Owner                             Description
 * -------- ----------   -----------  -------------------             -----------------------------------------------------------------------------------
 * 1.0      #RQ-009384   29-Nov-2018  Jagadeesan@ust-global.com       To create follow records for Account's territory sales owner related to the Request
 * 2.0      #RQ-009707   20-Dec-2018  Junaid@ust-global.com           Added logics for update event.
 * 3.0      #RQ-010316	 13-May-2019  Meghana.gupta@ust-global.com 	  Added VIP Deal recordtype
 *
 */
 
public class RequestRecordSelector implements RecordSelector{
    
    public List<Request__c> lstRequestRecord = new List<Request__c>();
    public Map<Id, Id> mapRequestToOldRequester = new Map<Id, Id>();
    private RequestTriggerHandler reqTriggerHandler;

    public RequestRecordSelector( List<Request__c> RequestList, map<Id, Request__c> oldRequestMap, RequestTriggerHandler reqTriggerHandler) {
        this.reqTriggerHandler = reqTriggerHandler;
        selectRecords(RequestList, oldRequestMap); 
        getRelatedRecords(RequestList); 
        
    }
    
    public void selectRecords(list<Request__c> RequestList, map<Id, sObject> oldRequestMap) {
    
        if(RequestList != null){
            Id rateSheetRecTypeId =  (ID) Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
            Id vipDealRecTypeId =  (ID) Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get( Label.VIPDealRequestRecordType).getRecordTypeId(); // v3.0: get recordtypeid for VIP deals
            Request__c oldRequest;
            
            for(Request__c reqRecord : RequestList ){
                
                // v3.0: add vip deals recordtype check
                if((reqRecord.recordTypeId == rateSheetRecTypeId || reqRecord.recordTypeId == vipDealRecTypeId) && reqTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    
                    if(reqTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                        lstRequestRecord.add(reqRecord);
                    
                    } else if(reqTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        
                        oldRequest = (Request__c) oldRequestMap.get(reqRecord.Id);
                        if((reqRecord.Requested_By__c != oldRequest.Requested_By__c && reqRecord.recordTypeId == rateSheetRecTypeId) ){
                            
                            if(reqRecord.Requested_By__c != null)
                                lstRequestRecord.add(reqRecord);
                            if(oldRequest.Requested_By__c != null)
                                mapRequestToOldRequester.put(reqRecord.Id, oldRequest.Requested_By__c);
                        
                        } else if((reqRecord.OwnerId != oldRequest.OwnerId && reqRecord.recordTypeId == vipDealRecTypeId) ){
                            // v3.0: for VIP deals if owner is changed then add new owner as follower and remove old owner
                            lstRequestRecord.add(reqRecord);
                            if(oldRequest.OwnerId != null)
                                mapRequestToOldRequester.put(reqRecord.Id, oldRequest.OwnerId);
                        }
                    }
                }
            }
         }
    }
    public void getRelatedRecords( list<Request__c> newRequestList ) {
    }

}