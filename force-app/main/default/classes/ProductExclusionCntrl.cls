public class ProductExclusionCntrl {
    
    @AuraEnabled
    public static void createProductExclusion(String sourceSalesTargetId, String desSalesTargetId) {
        //Using Dynamic query to clone all the records from the selected target
        String query = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Target_Product_Exclusion__c());
        query = 'Select ' + query + ' from Target_Product_Exclusion__c WHERE Target__c = :sourceSalesTargetId';
        
        List<Target_Product_Exclusion__c> prodExclusionInsertList = new List<Target_Product_Exclusion__c>();
        Map<Id, Target_Product_Exclusion__c> prodExclusionMap = new Map<Id, Target_Product_Exclusion__c>((List<Target_Product_Exclusion__c>)Database.query(query));
        
        //Clone Product Exclusions from the Selected Target to the Destination Target
        if(!prodExclusionMap.isEmpty()){
            for(Target_Product_Exclusion__c prod: prodExclusionMap.values()){
                Target_Product_Exclusion__c cloneRec = new Target_Product_Exclusion__c();
                cloneRec = prod.clone(false,false,false,false);
                cloneRec.Target__c = desSalesTargetId;
                prodExclusionInsertList.add(cloneRec);
            }
            if (prodExclusionInsertList.size() > 0) {
                insert prodExclusionInsertList;
            }
        }
    }
}