public inherited sharing class TargetItemGroupTriggerHelper {
    
    public static void mapCountryBdaDetails(List<Target_Item_Group__c> listNewTargetItem) {
    // GET ALL BDA GEOGRAPHY BY COUNTRY CODE
        GeographyHelper.getBdaGeographyByCountryCode();
        // Create a set to store unique combinations of existing records
        /*Set<String> existingCombos = new Set<String>(); 
        // Query existing records
        List<Target_Item_Group__c> existingRecords = [SELECT BrandMnA__c, Product_Family__c, Country_Code__c, Target__c
                                                      FROM Target_Item_Group__c
                                                      WHERE BrandMnA__c != null AND Product_Family__c != null AND Country_Code__c != null AND Target__c != null];
        
        // Populate the set with existing combinations
        for (Target_Item_Group__c existingRecord : existingRecords) {
            String existingCombo = existingRecord.BrandMnA__c + '|' + existingRecord.Product_Family__c + '|' + existingRecord.Country_Code__c + '|' + existingRecord.Target__c;
            existingCombos.add(existingCombo);
        }     */
    for (Target_Item_Group__c eachTargetItem : listNewTargetItem) {
        if (String.isNotEmpty(eachTargetItem.Country_Code__c)) {
            if (GeographyHelper.mapBdaGeographyByCountryCode.containsKey(eachTargetItem.Country_Code__c)
                && GeographyHelper.mapBdaGeographyByCountryCode.get(eachTargetItem.Country_Code__c) != null) {
                    
                    eachTargetItem.Executing_Area__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachTargetItem.Country_Code__c).BDA__c;
                    eachTargetItem.Executing_Country__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachTargetItem.Country_Code__c).Geography__c;
                } else {
                    eachTargetItem.addError(Label.countryCodeNotFound);
                }
        } else if (eachTargetItem.Executing_Country__c != null) {
            if (GeographyHelper.mapCountryCodeByGeographyId.containsKey(eachTargetItem.Executing_Country__c)) {
                eachTargetItem.Country_Code__c = GeographyHelper.mapCountryCodeByGeographyId.get(eachTargetItem.Executing_Country__c);
                eachTargetItem.Executing_Area__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachTargetItem.Country_Code__c).BDA__c;
            }
        } else {
            eachTargetItem.addError(Label.countryMandatory);
        }
        
        // Unique combination validation
            /*String newCombo = eachTargetItem.BrandMnA__c + '|' + eachTargetItem.Product_Family__c + '|' + eachTargetItem.Country_Code__c + '|' + eachTargetItem.Target__c;
            
            if (existingCombos.contains(newCombo)) {
                eachTargetItem.addError(Label.duplicateTargetItemGroup);
            } else {
                existingCombos.add(newCombo);
            }*/
        }
    } 
    public static void updateUniqueExternalId(List<Target_Item_Group__c> listNewTargetItem) {
        for (Target_Item_Group__c eachTargetItem :listNewTargetItem) {
            eachTargetItem.Unique_Identifier__c = TargetSettingUtil.generateUniqueIdFromString(
                eachTargetItem.Country_Code__c + eachTargetItem.BrandMnA__c + eachTargetItem.Product_Family__c) + eachTargetItem.Target__c;
        }
    }
}