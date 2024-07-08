/*
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
*                                
* 1.0       SFSE-14216  05-06-2024   Bharti					Added condition to validate Product family and ICB check & removed account validation .	
* 
*/

public inherited sharing class TargetSettingStagingTriggerHelper extends TriggerHandler {
    
    public static void initAndValidateData(List<Target_Setting_Staging__c> listNewStaging) {
        Map<String, Account> mapAccountByCustomerCode = new Map<String, Account>();
        // GET BRAND PICKLIST VALUES
        Set<String> setBrand = TargetSettingStagingTriggerHelper.getBrandPicklist();
        //GET PRODUCT FAMILY PICKLIST VALUES
        Set<String> setProductFamily = TargetSettingStagingTriggerHelper.getproductFamilyPicklist();
      
        // GET BRAND MAPPING
        Map<String, String> mapBrandMapping = TargetSettingStagingTriggerHelper.getBrandMapping();
        // GET GEOGRAPHY DATA
        GeographyHelper.getBdaGeographyByCountryCode();
        //GET ACCOUNT BY CUSTOMER CODE
        Set<String> setCustomerCode = new Set<String>();
        for (Target_Setting_Staging__c eachStaging :listNewStaging) {
            if (String.isNotBlank(eachStaging.Price_Owner__c)) setCustomerCode.add(eachStaging.Price_Owner__c);
            if (String.isNotBlank(eachStaging.Shipper__c)) setCustomerCode.add(eachStaging.Shipper__c);
            if (String.isNotBlank(eachStaging.Consignee__c)) setCustomerCode.add(eachStaging.Consignee__c);
        }
        mapAccountByCustomerCode = TargetSettingStagingTriggerHelper.getAccountByCustomerCode(setCustomerCode);
        for (Target_Setting_Staging__c eachStaging :listNewStaging) {
            // UPDATE MEASURE DIMENSION
            if (String.isNotBlank(eachStaging.RoFo_Version__c)) {
                eachStaging.Measure_Dimension__c = TargetSettingUtil.getMeasureFromRofoVersion(eachStaging.RoFo_Version__c);
                eachStaging.Year__c = TargetSettingUtil.getYearRofoVersion(eachStaging.RoFo_Version__c);
            } else {
                // VALIDATE ACCOUNTS WITH CUSTOMER CODES IN PO, SHIPPER, CONSIGNEE
                if (String.isNotBlank(eachStaging.Price_Owner__c)) {
                    TargetSettingStagingTriggerHelper.validateAccount(eachStaging, TargetSettingConstants.PARTY_PO_FIELD, mapAccountByCustomerCode);                
                }
                if (String.isNotBlank(eachStaging.Shipper__c)) {
                    TargetSettingStagingTriggerHelper.validateAccount(eachStaging, TargetSettingConstants.PARTY_SHIPPER_FIELD, mapAccountByCustomerCode);
                }
                if (String.isNotBlank(eachStaging.Consignee__c)) {
                    TargetSettingStagingTriggerHelper.validateAccount(eachStaging, TargetSettingConstants.PARTY_CONSIGNEE_FIELD, mapAccountByCustomerCode);
                }
            }
            // VALIDATE COUNTRY CODE AND MARK RECORD FAIL
            if (GeographyHelper.mapBdaGeographyByCountryCode.get(eachStaging.Country_Code__c) != null) {
                eachStaging.Country__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachStaging.Country_Code__c).Geography__c;
                eachStaging.Area__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachStaging.Country_Code__c).BDA__c;
            } else {
                if (eachStaging.Country_Code__c != null && eachStaging.Country_Code__c.length() > 2) {
                    eachStaging.Status__c = TargetSettingConstants.STAGING_STATUS_EXCLUDED;
                } else {
                    eachStaging.Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                }
                eachStaging.Message__c = Label.stgNoCountryFound;
                continue;
            }
            // VALIDATE BRAND, IF MAPPING EXISTS THEN MAP ELSE MARK RECORD FAIL
            if (!setBrand.contains(eachStaging.Brand__c)) {
                if (mapBrandMapping.get(eachStaging.Brand__c) != null) {
                    eachStaging.Brand__c = mapBrandMapping.get(eachStaging.Brand__c);
                } else {
                    eachStaging.Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                    eachStaging.Message__c = Label.stgBrandNotFound;
                    continue;
                }
            }
            //Validate product family
          
            if(!setProductFamily.contains(eachStaging.Product_Family__c)) {
                if(eachStaging.Product_Family__c != null){
                    eachStaging.Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                }
                eachStaging.Message__c = Label.stgNoPFFound;
                continue;

            }
            //validate if ICB is true or not
            if(eachStaging.isICB__c){
                
                eachStaging.Status__c = 'Excluded'; 
                eachStaging.Message__c = Label.stgICB; 
                continue;
            }

        }
    }
    
    public static void evaluateCreditEligibility(List<Target_Setting_Staging__c> listNewStaging) {
        List<Target_Setting_Staging__c> listStagingUpdate = new List<Target_Setting_Staging__c>();
        AssessCreditEligibility evalulator = new AssessCreditEligibility();
        // GET CREDIT ELIGIBILITY FOR EACH STAGING RECORD
        Map<Id, CreditEligibilityUtility.EligibilityWrapper> mapEligibilityByStagingId = evalulator.determineAccountEligibility(listNewStaging);
        for (Id eachStagingId :mapEligibilityByStagingId.keySet()) {
            listStagingUpdate.add(new Target_Setting_Staging__c(
                    Id = eachStagingId
                ,   PO_Eligible__c = mapEligibilityByStagingId.get(eachStagingId).poCreditEligible
                ,   Shipper_Eligible__c = mapEligibilityByStagingId.get(eachStagingId).shipperCreditEligible
                ,   Consignee_Eligible__c = mapEligibilityByStagingId.get(eachStagingId).consigneeCreditEligible
            ));
        }

        Database.update(listStagingUpdate, true);
    }
    
    private static void validateAccount(Target_Setting_Staging__c stagingRecord, String partyType, Map<String, Account> mapAccountByCustomerCode) {
        if (mapAccountByCustomerCode.get((String) stagingRecord.get(partyType + '__c')) != null) {
            //Commented as part of SFSE -14216
           /* if (!TargetSettingConstants.ACCOUNT_STATUS_ACTIVE.equals(mapAccountByCustomerCode.get((String) stagingRecord.get(partyType + '__c')).SCV_Status__c)) {
                stagingRecord.Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
                stagingRecord.Message__c = String.format(Label.stgAccountNotActive, new List<Object>{partyType});
            }*/
            stagingRecord.put(partyType + '_Account_Id__c', mapAccountByCustomerCode.get((String) stagingRecord.get(partyType + '__c')).Id);
        } else {
           // stagingRecord.Status__c = TargetSettingConstants.STAGING_STATUS_FAILED;
            //stagingRecord.Message__c = String.format(Label.stgAccountNotFound, new List<Object>{ partyType });
        }
    }
    
    public static Map<String, Account> getAccountByCustomerCode(Set<String> setCustomerCode) {
        Map<String, Account> retVal = new Map<String, Account>();
        for (Account eachAccount :[ SELECT Id
                                        , SCV_Status__c
                                        , Customer_Code__c
                                    FROM Account
                                    WHERE Customer_Code__c IN :setCustomerCode ]) {
            retVal.put(eachAccount.Customer_Code__c, eachAccount);
        }
        
        return retVal;
    }
    
    private static Map<String, String> getBrandMapping() {
        Map<String, String> retVal = new Map<String, String>();
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Transaction_Mapping').getRecordTypeId();
        for (Target_Brand_Mapping__c eachbrandMapping :[    SELECT Id
                                                                , BrandMnA__c
                                                                , GDA_Brand__c
                                                            FROM Target_Brand_Mapping__c
                                                            WHERE RecordTypeId = :recordTypeId
                                                                AND Active__c = true ]) {
            retVal.put(eachbrandMapping.GDA_Brand__c, eachbrandMapping.BrandMnA__c);
        }

        return retVal;
    }
 
    private static Set<String> getBrandPicklist() {
        Set<String> retVal = new Set<String>();
        List<Schema.PicklistEntry> listPicklistEntry = 
            Schema.SObjectType.Target_Item_Group__c.fields.getMap().get('BrandMnA__c').getDescribe().getPicklistValues();
        for (Schema.PicklistEntry eachPl : listPicklistEntry) {
            retVal.add(eachPl.getValue());
        }

        return retVal;
    }
   //SFSE-14216
    private static Set<String> getproductFamilyPicklist(){
        Set<String> retVal = new Set<String>();
        List<Schema.PicklistEntry> listPicklistEntry = 
            Schema.SObjectType.Target_Item_Group__c.fields.getMap().get('Product_Family__c').getDescribe().getPicklistValues();
        for (Schema.PicklistEntry eachPl : listPicklistEntry) {
            retVal.add(eachPl.getValue());
        }

        return retVal;

    }
}