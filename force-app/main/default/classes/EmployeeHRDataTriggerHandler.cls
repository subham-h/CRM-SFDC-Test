/*              
* Version Ref Number  	Date        	Owner                   Description
* -------- ----------  ----------- 	-----------------       -----------------
* 1.0     SFSE-11111   04-Jul-2023		Vazid       		create and update Region and Area fields based on selected Country code
*/
public class EmployeeHRDataTriggerHandler extends TriggerHandler {
	public List<Employee_HR_Data__c> newList;
    public Map<Id, Employee_HR_Data__c> oldMap;
    
    public EmployeeHRDataTriggerHandler() {
        this.newList = (List<Employee_HR_Data__c>) Trigger.new;
        this.oldMap = (Map<Id, Employee_HR_Data__c>) Trigger.oldMap; 
    }
    
    public override void onBeforeInsert() {
        EmployeeHRDataTriggerHelper.mapCountryBdaDetails(this.newList, null);
    }
    
    public override void onBeforeUpdate() {
        EmployeeHRDataTriggerHelper.mapCountryBdaDetails(this.newList, this.oldMap);
    }
}