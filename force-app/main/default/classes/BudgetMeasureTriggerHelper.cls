/* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   05-09-23    Anjali@maersk           Created
* 2.0       SFSE-11420  09-09-23    Anjali@maersk           Added checkforDuplicateBudgetMeasure method
*/
public inherited sharing class BudgetMeasureTriggerHelper {
    public static void checkForDuplicateBudgetMeasure(List<Budget_measure__c> newBudgetMeasures) {
        // Create a set to store the unique keys
        Set<String> uniqueKeys = new Set<String>();
        Set<Id> budgetGroupIds = new Set<Id>();
        Set<Id> budgetMeasureIds = new Set<Id>();
        Set<String> measureDimensionSet=new Set<String>();
        Set<String> measureTypeSet=new Set<String>();
        
        // Collect the unique keys from the incoming Target Measures and check for duplicates
        for (Budget_measure__c budgetMeasure : newBudgetMeasures) {
            budgetGroupIds.add(budgetMeasure.Budget_group__c);
            budgetMeasureIds.add(budgetMeasure.Id);
            String uniqueKey = generateUniqueKey(budgetMeasure);
            
            // Check if the unique key already exists in the set
            if (uniqueKeys.contains(uniqueKey)) {
                    budgetMeasure.addError(Label.duplicateBudgetMeasure);
            } else {
                uniqueKeys.add(uniqueKey); // Add the unique key to the set for future checks
            }
        }      
        // Query existing Target Measures to check for duplicates
        Set<String> existingUniqueKeys = new Set<String>();
        for (Budget_measure__c existingMeasure : [SELECT Measure_dimension__c, Measure_type__c, Budget_group__c 
                                                  FROM Budget_measure__c 
                                                  WHERE Budget_group__c IN :budgetGroupIds AND
                                                  Id NOT IN :budgetMeasureIds]) {
                                                      String uniqueKey = generateUniqueKey(existingMeasure);
                                                      existingUniqueKeys.add(uniqueKey);
                                                      System.debug('Uniquee:' + uniqueKey);                                                                                     
                                                  }
        
        // Check for duplicates and add error messages to the duplicate records
        for (Budget_measure__c budgetMeasure : newBudgetMeasures) {
            String uniqueKey = generateUniqueKey(budgetMeasure);
            System.debug('Uniquee:' + uniqueKey); 
            // Check if the unique key already exists in the existing records
            if (existingUniqueKeys.contains(uniqueKey)) {
                    budgetMeasure.addError(Label.duplicateBudgetMeasure);
            } else {
                existingUniqueKeys.add(uniqueKey); // Added the key to the set for future checks
            }
        }
    }
    // Helper method to generate a unique key based on measure dimension
    private static String generateUniqueKey(Budget_measure__c budgetMeasure) {
        String measureDimension = budgetMeasure.Measure_dimension__c;
        String measureType = budgetMeasure.Measure_type__c;
        String budgetGroup = budgetMeasure.Budget_group__c;
        String uniqueKey = measureDimension + '_' + measureType + '_' + budgetGroup;
        return uniqueKey;
    }
}