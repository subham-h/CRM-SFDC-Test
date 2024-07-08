/**
* Author   : Nayana@maersk
* Purpose  : Centralize the record selection process for Care relationship object.
*          Defines the methods which iterate and segregate the Care relationship records for further use.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9662     23-01-2024  Nayana@maersk           Created for implementing trigger framework.
*/
/**
* @description CareRecordSelector
*/
public class CareRecordSelector implements RecordSelector {

    private TriggerHandler careTriggerHandler;
    public Set<String> setAccountIds = new Set<String>();    
    public Set<String> setCountryIds = new Set<String>();
    public Set<String> setValidateGeoCountry = new Set<String>();
    public Set<String> setValidateGeoCluster = new Set<String>();
    public Set<String> setOplCareId = new Set<String>();
    public Set<String> setOplAccountChange = new Set<String>();
    public Set<String> setOplCountryIds = new Set<String>();
    public Map<Id,Geography__c> mapCountries = new Map<Id,Geography__c>();
    
    /** 
    * @description | CareRecordSelector constructor
    * @param lstCare accepts care relationship list
    * @param mapOldCare accepts care relationship old map
    * @param careTriggerHandler accepts care relationship TriggerHandler context
    * SC-9662
    */
    public CareRecordSelector(list<Care_Relationship__c> lstCare, map<Id, Care_Relationship__c> mapOldCare, TriggerHandler careTriggerHandler) {
        this.careTriggerHandler = careTriggerHandler;
        this.selectRecords(lstCare, mapOldCare);
        if(lstCare != null && lstCare.size() >0) {
            this.getRelatedRecords(lstCare);
        }
    }
    
    /** 
    * @description | filter care relationship records
    * @param lstCare accepts care relationship list
    * @param mapOldCare accepts care relationship oldmap
    * SC-9662
    */
    public void selectRecords(list<Care_Relationship__c> lstCare, map<Id, sObject> mapOldCare) {
        if(lstCare != null && lstCare.size() >0) {
            for(Care_Relationship__c newCare : lstCare) {
                Care_Relationship__c oldCare;
                if(mapOldCare != null && !mapOldCare.isEmpty()) {
                    oldCare = (Care_Relationship__c)mapOldCare.get(newCare.Id);
                }            
                if(careTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) {
                    if(careTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) {
                        if(newCare.Account__c != null){
                            setAccountIds.add(newCare.Account__c);                            
                        }
                        if(newCare.Country__c != null){
                            setCountryIds.add(newCare.Country__c);
                            setValidateGeoCountry.add(newCare.Country__c);
                        }
                        if(newCare.Cluster__c != null){
                            setValidateGeoCluster.add(newCare.Cluster__c);
                        }                        
                    }
                    else if(careTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {  
                        if(newCare.Account__c != oldCare.Account__c){
                            setAccountIds.add(newCare.Account__c);
                        }
                        if(newCare.Country__c != oldCare.Country__c){
                            setCountryIds.add(newCare.Country__c);
                            setValidateGeoCountry.add(newCare.Country__c);
                        }
                        if(newCare.Cluster__c != oldCare.Cluster__c){
                            setValidateGeoCluster.add(newCare.Cluster__c);
                        }
                    }
                }
                else if(careTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER) {
                    if(careTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                        if(newCare.Account__c != null && newCare.Direction__c != null && newCare.Status__c == 'Active' && newCare.Country__c != null && newCare.Liner_Brand__c != null){
                            setOplCareId.add(newCare.Id);
                            setOplCountryIds.add(newCare.Country__c);
                        }
                    }
                    else if(careTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        if(newCare.Account__c != oldCare.Account__c){
                            setOplAccountChange.add(newCare.Id); 
                            setOplCareId.add(newCare.Id);
                            setOplCountryIds.add(newCare.Country__c);
                        }
                        if(newCare.Country__c != oldCare.Country__c || newCare.Direction__c != oldCare.Direction__c  || newCare.Status__c != oldCare.Status__c || newCare.Location__c != oldCare.Location__c || newCare.Liner_Brand__c != oldCare.Liner_Brand__c){
                            setOplCareId.add(newCare.Id);
                            setOplCountryIds.add(newCare.Country__c);
                            setOplCountryIds.add(oldCare.Country__c);
                        }
                    }
                }
            }
        }
    }
    
    /** 
    * @description | get care relationship related records
    * @param lstCare accepts care relationship list
    * SC-9662
    */
    public void getRelatedRecords(list<Care_Relationship__c> lstCare) {
    }    
}