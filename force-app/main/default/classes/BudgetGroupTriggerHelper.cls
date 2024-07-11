public inherited sharing class BudgetGroupTriggerHelper {
    public static void mapCountryBdaDetails(List<Budget_Group__c> listNewBudgetGroup) {
        // GET ALL BDA GEOGRAPHY BY COUNTRY CODE
        GeographyHelper.getBdaGeographyByCountryCode();

        // Create a set to store unique combinations of existing records
        /*Set<String> existingCombos = new Set<String>();

        // Query existing records
        List<Budget_Group__c> existingRecords = [SELECT Brand__c, Product_Family__c, Country_Code__c, Target__c
                                                 FROM Budget_Group__c
                                                 WHERE Brand__c != null AND Product_Family__c != null AND Country_Code__c != null AND Target__c != null];

        // Populate the set with existing combinations
        for (Budget_Group__c existingRecord : existingRecords) {
            String existingCombo = existingRecord.Brand__c + '|' + existingRecord.Product_Family__c + '|' + existingRecord.Country_Code__c + '|' + existingRecord.Target__c;
            existingCombos.add(existingCombo);
        }*/
        for (Budget_Group__c eachBudgetGroup :listNewBudgetGroup) {
            if (String.isNotEmpty(eachBudgetGroup.Country_Code__c)) {
                if (GeographyHelper.mapBdaGeographyByCountryCode.containsKey(eachBudgetGroup.Country_Code__c)
                    && GeographyHelper.mapBdaGeographyByCountryCode.get(eachBudgetGroup.Country_Code__c) != null) {
                        eachBudgetGroup.Executing_Area__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachBudgetGroup.Country_Code__c).BDA__c;
                        eachBudgetGroup.Executing_Country__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachBudgetGroup.Country_Code__c).Geography__c;
                    } else {
                        eachBudgetGroup.addError(Label.countryCodeNotFound);
                    }
            } else if (eachBudgetGroup.Executing_Country__c != null) {
                if (GeographyHelper.mapCountryCodeByGeographyId.containsKey(eachBudgetGroup.Executing_Country__c)) {
                    eachBudgetGroup.Country_Code__c = GeographyHelper.mapCountryCodeByGeographyId.get(eachBudgetGroup.Executing_Country__c);
                    eachBudgetGroup.Executing_Area__c = GeographyHelper.mapBdaGeographyByCountryCode.get(eachBudgetGroup.Country_Code__c).BDA__c;
                }
            } else {
                eachBudgetGroup.addError(Label.countryMandatory );
            }
            // Unique combination validation
            /*String newCombo = eachBudgetGroup.Brand__c + '|' + eachBudgetGroup.Product_Family__c + '|' + eachBudgetGroup.Country_Code__c + '|' + eachBudgetGroup.Target__c;

            if (existingCombos.contains(newCombo)) {
                eachBudgetGroup.addError(Label.duplicateBudgetGroup);
            } else {
                existingCombos.add(newCombo);
            }*/
        }   
    }
    
    public static void updateUniqueExternalId(List<Budget_Group__c> listNewBudgetGroup) {
        for (Budget_Group__c eachBudgetGroup :listNewBudgetGroup) {
            eachBudgetGroup.Unique_Identifier__c = TargetSettingUtil.generateUniqueIdFromString(
                eachBudgetGroup.Country_Code__c + eachBudgetGroup.Brand__c + eachBudgetGroup.Product_Family__c) + eachBudgetGroup.Target__c;
        }
    }

    public static void createCorrespondingTargetItemGroup(List<Budget_Group__c> listNewBudgetGroup) {
        List<Target_Item_Group__c> listTargetGroup = new List<Target_Item_Group__c>();
        //Set<String> setUniqueId = new Set<String>();
        Target_Item_Group__c eachTargetGroup;
        for (Budget_Group__c eachBugetGrp :listNewBudgetGroup) {
            eachTargetGroup = new Target_Item_Group__c();
            //setUniqueId.add(eachBugetGrp.Unique_Identifier__c);
            BudgetGroupTriggerHelper.mapTargetFromBudgetGroup(eachBugetGrp, eachTargetGroup);
            listTargetGroup.add(eachTargetGroup);
        }

        Integer iterator = 0;
        for (Database.UpsertResult eachUr :Database.upsert(listTargetGroup, Target_Item_Group__c.Fields.Unique_Identifier__c, false)) {
            if (!eachUr.isSuccess()) {
                listNewBudgetGroup.get(iterator).addError(eachUr.getErrors().get(0).getMessage());
            }

            iterator++;
        }
    }

    public static void mapTargetFromBudgetGroup(Budget_Group__c iBudgetGroup, Target_Item_Group__c iTargetGroup) {
		iTargetGroup.Unique_Identifier__c = iBudgetGroup.Unique_Identifier__c;
        iTargetGroup.BrandMnA__c = iBudgetGroup.Brand__c;
        iTargetGroup.Country_Code__c = iBudgetGroup.Country_Code__c;
        iTargetGroup.Product_Family__c = iBudgetGroup.Product_Family__c;
        iTargetGroup.Target__c = iBudgetGroup.Target__c;
        iTargetGroup.Executing_Country__c = iBudgetGroup.Executing_Country__c;
        iTargetGroup.Budget_Group__r = new Budget_Group__c(Unique_Identifier__c = iBudgetGroup.Unique_Identifier__c);
    }
}