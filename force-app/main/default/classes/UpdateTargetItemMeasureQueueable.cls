/*   
 * Revision Ref Number  Date            Owner                                  Description
 * -------- ----------  -----------     -------------------                    -----------
 * 1.0      SFSE-11477  01-Nov-2023      Vinay      							Code created
 * 
*/ 
public class UpdateTargetItemMeasureQueueable implements Queueable{
    List<Territory_Account_Association__c> taaList = new List<Territory_Account_Association__c>();
    public UpdateTargetItemMeasureQueueable(List<Territory_Account_Association__c> listTAA) {
        taaList = listTAA;
    }

    public void execute(QueueableContext context) {        
        UpdateTargetItemMeasureUtility.updateCustomerPortfolioAssigned(taaList);
    }
}