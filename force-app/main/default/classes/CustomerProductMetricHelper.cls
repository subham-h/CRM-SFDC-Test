/*              
* Revision   Ref Number   Date          Owner                 Description
* --------   ----------   -----------   -----------------     -----------
* 1.0        SFSE-11986   10-10-2023    Seba                  Helper for CustomerProductMetricTrigger
* 2.0        SFSE-13430   09-02-2024    Anjali                Made changes to check for duplicate Product Family
*/
public class CustomerProductMetricHelper {
    
    public static void checkDuplicateCustomerProductPlanning(List<Customer_Product_Planning__c> newList, Map<Id,Customer_Product_Planning__c> oldMap) {
        
        Set<Id> setParentCustomerMetricIds = new Set<Id>();
        Set<String> incomingProductFamilies = new Set<String>();
        Set<String> keySet = new Set<String>();
        List<Customer_Product_Planning__c> filterList = new List<Customer_Product_Planning__c>();
        Set<String> customerPlanningIdSet = new Set<String>();
        
        for(Customer_Product_Planning__c eachCustomerProdMetric : newList){
               if((oldMap == null) || (oldMap.get(eachCustomerProdMetric.Id).Product_Family_Customer_Metric1__c != eachCustomerProdMetric.Product_Family_Customer_Metric1__c)){
                String key = eachCustomerProdMetric.Customer_Metrics__c + '_' + eachCustomerProdMetric.Product_Family_Customer_Metric1__c;
                if (!keySet.contains(key)) {
                    setParentCustomerMetricIds.add(eachCustomerProdMetric.Customer_Metrics__c);
                    incomingProductFamilies.add(eachCustomerProdMetric.Product_Family_Customer_Metric1__c);
                    keySet.add(key);
                    filterList.add(eachCustomerProdMetric);
                    if (oldMap != null) customerPlanningIdSet.add(eachCustomerProdMetric.Id);
                } else {
                    eachCustomerProdMetric.addError(LABEL.Duplicate_Product_Family_on_Customer_Metric);
                }
            }            
        }
        
        List<Customer_Product_Planning__c> productPlanningList = [SELECT Id, 	Product_Family_Customer_Metric1__c,Customer_Metrics__c FROM Customer_Product_Planning__c 
                                                                  WHERE Customer_Metrics__c IN :setParentCustomerMetricIds
                                                                  AND 	Product_Family_Customer_Metric1__c IN :incomingProductFamilies AND Id NOT IN :customerPlanningIdSet];
        
        keySet = new Set<String>();
        for(Customer_Product_Planning__c eachCustomerProdMetric : productPlanningList) {
            String key = eachCustomerProdMetric.Customer_Metrics__c + '_' + eachCustomerProdMetric.Product_Family_Customer_Metric1__c;
            keySet.add(key);
        }
        
        for(Customer_Product_Planning__c eachCustomerProdMetric : filterList){  
            String key = eachCustomerProdMetric.Customer_Metrics__c + '_' + eachCustomerProdMetric.Product_Family_Customer_Metric1__c;
            if (keySet.contains(key)) {
                eachCustomerProdMetric.addError(LABEL.Duplicate_Product_Family_on_Customer_Metric);
            }
        }
    }
}