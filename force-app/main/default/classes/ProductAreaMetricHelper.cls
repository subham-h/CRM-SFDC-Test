public class ProductAreaMetricHelper {
    public static void validateMetrics(List<Product_Area_Metric__c> newList) {
        Set<Id> parentIds = new Set<Id>();//will contain parent ids of new child obj
        Set<String> productSet = new Set<String>();
        List<Product_Area_Metric__c> productList = new List<Product_Area_Metric__c>();
        String key = '';
        for(Product_Area_Metric__c pm : newList){
            if (pm.Customer_Product_Metric__c != null && pm.Area__c != null) {
                key = pm.Customer_Product_Metric__c + '_' + pm.Area__c;
                if (productSet.contains(key)) {
                    pm.addError(Label.Product_Area_Error);
                } else {
                    productSet.add(key);
                    productList.add(pm);
                    parentIds.add(pm.Customer_Product_Metric__c);
                }
            } 
        }
        Map<Id,Set<String>> mapCustomerMetricIncomingAreas =  new Map<Id, Set<String>>();//will contain parent ids, along with areas of existing child objs
        for(Product_Area_Metric__c pm : [SELECT Id,Area__c,Customer_Product_Metric__c from Product_Area_Metric__c where Customer_Product_Metric__c  IN : parentIds ]){
            if(!mapCustomerMetricIncomingAreas.containsKey(pm.Customer_Product_Metric__c)){
                mapCustomerMetricIncomingAreas.put(pm.Customer_Product_Metric__c, new Set<String>());
            }
            mapCustomerMetricIncomingAreas.get(pm.Customer_Product_Metric__c).add(pm.Area__c);
            
        }
        for(Product_Area_Metric__c pm: productList){ 
            if(mapCustomerMetricIncomingAreas.containsKey(pm.Customer_Product_Metric__c)){
                if(mapCustomerMetricIncomingAreas.get(pm.Customer_Product_Metric__c).contains(pm.Area__c)){
                    pm.addError(Label.Product_Area_Error);
                }
            }
        }     
    }
}