/*              
* Revision   Ref Number   Date          Owner                 Description
* --------   ----------   -----------   -----------------     -----------
* 1.0        SFSE-11986   10-10-2023    Seba                  Handler for CustomerProductMetricTrigger
*/
public class CustomerProductMetricHandler extends TriggerHandler{
    public List<Customer_Product_Planning__c > newList;
    public Map<Id, Customer_Product_Planning__c > oldMap;
    
    public CustomerProductMetricHandler() {
        this.newList = (List<Customer_Product_Planning__c >) Trigger.new;
        this.oldMap = (Map<Id, Customer_Product_Planning__c >) Trigger.oldMap;
    }
    
    public override void onBeforeInsert() { 
        CustomerProductMetricHelper.checkDuplicateCustomerProductPlanning(this.newList, this.oldMap); 
    }

    public override void onBeforeUpdate() {
       CustomerProductMetricHelper.checkDuplicateCustomerProductPlanning(this.newList, this.oldMap); 
    }
}