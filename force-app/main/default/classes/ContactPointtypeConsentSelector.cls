/*              
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -----------------       -----------
* 1.0      SFMC-7512   15-Feb-2024 Ranjan@maersk           Created
*/
public without sharing class ContactPointtypeConsentSelector implements RecordSelector {
    private TriggerHandler trgHandler;
    Public Set<Id> marketingIndivIdSet = new Set<Id> ();
    Public static Map<Id,ContactPointTypeConsent> contactPointMap=new Map<Id,ContactPointTypeConsent>();
    public ContactPointtypeConsentSelector(List<ContactPointTypeConsent> lstContPCT, 
                                            Map<Id, ContactPointTypeConsent> mapOldCPCT, 
                                            ContactPointTypeConsentTriggerHandler cpctTriggerHandler) 
    {
        
        this.trgHandler = cpctTriggerHandler;
        if(lstContPCT==null){return;} //avoid running on the delete condition 
        getParentRecords(lstContPCT);      
        selectRecords(lstContPCT, mapOldCPCT);
        
    }
    public void selectRecords(List<ContactPointTypeConsent> lstCPCT, map<Id, sObject> mapOldCPCT) {
        ContactPointTypeConsent oldCPCT;        
        for (ContactPointTypeConsent cpctObj : lstCPCT)
        {
            // if record is updated, get old lead record 
            if (mapOldCPCT != null){
                oldCPCT = (ContactPointTypeConsent) mapOldCPCT.get(cpctObj.Id);
            }
            //just check if its Maersk Marketing type consent
            if(
                trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                contactPointMap.containsKey(cpctObj.Id) &&
                contactPointMap.get(cpctObj.Id).DataUsePurposeId!=null &&
                contactPointMap.get(cpctObj.Id).BusinessBrandId!=null &&
                'Marketing'.equalsIgnoreCase(contactPointMap.get(cpctObj.Id).DataUsePurpose.Name) &&
                'Maersk'.equalsIgnoreCase(contactPointMap.get(cpctObj.Id).BusinessBrand.Name)
            )
            {
                marketingIndivIdSet.add(cpctObj.PartyId);
            }
            //update condition either the datapurpose/BusinessBrand is changed OR the consent is changed 
            //for the Maersk Marketing type CPCT
            if(
                trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER &&
                trgHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE &&
                (
                    oldCPCT.DataUsePurposeId!=cpctObj.DataUsePurposeId ||
                    oldCPCT.BusinessBrandId!=cpctObj.BusinessBrandId ||
                    (
                        contactPointMap.containsKey(cpctObj.Id) &&
                        contactPointMap.get(cpctObj.Id).DataUsePurposeId!=null &&
                        contactPointMap.get(cpctObj.Id).BusinessBrandId!=null &&
                        'Marketing'.equalsIgnoreCase(contactPointMap.get(cpctObj.Id).DataUsePurpose.Name) &&
                        'Maersk'.equalsIgnoreCase(contactPointMap.get(cpctObj.Id).BusinessBrand.Name) &&
                        oldCPCT.PrivacyConsentStatus != cpctObj.PrivacyConsentStatus
                    )
                )
            )
            {
                marketingIndivIdSet.add(cpctObj.PartyId);
            }
        }
    }
    public void getRelatedRecords(List<ContactPointTypeConsent> lstContPCT) {
    }
    /*get the information about the BusinessBrand and DataUsePurpose*/
    public void getParentRecords(List<ContactPointTypeConsent> lstContPCT) {
        if(
            contactPointMap.isEmpty() && 
            trgHandler.trigType == TriggerHandler.TriggerType.ISAFTER &&
            trgHandler.trigEvent != TriggerHandler.TriggerEvent.ISDELETE
            
        )
        {
            Set<Id> idCPCtSet=new Set<Id>();
            for(ContactPointTypeConsent tempContPointTyConObj:lstContPCT){
                idCPCtSet.add(tempContPointTyConObj.Id);
            }
            contactPointMap=new Map<Id,ContactPointTypeConsent>([Select Id,
                                    DataUsePurpose.Name,
                                    BusinessBrand.Name,
                                    DataUsePurposeId,
                                    BusinessBrandId 
                                        from ContactPointTypeConsent 
                                            where Id in:idCPCtSet]);
        }
    }
}