public class ProductAreaMetricHandler extends TriggerHandler{
	public List<Product_Area_Metric__c> newList;
    public Map<Id, Product_Area_Metric__c> oldMap;
    
    public ProductAreaMetricHandler() {
        this.newList = (List<Product_Area_Metric__c>) Trigger.new;
        this.oldMap = (Map<Id, Product_Area_Metric__c>) Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        ProductAreaMetricHelper.validateMetrics(this.newList);
    }
    
    public override void onBeforeUpdate() {
        List<Product_Area_Metric__c> updatedList = new List<Product_Area_Metric__c>();
        for(Product_Area_Metric__c pm : this.newList){
            if(pm.area__c != null && pm.area__c != this.oldMap.get(pm.Id).area__c){
                updatedList.add(pm);
            }
        }
        if(updatedList.size()> 0){
        	ProductAreaMetricHelper.validateMetrics(updatedList);
        }
    }
}