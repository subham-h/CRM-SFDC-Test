/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009931       23-Jan-2019     Junaid.Khader@ust-global.com        Code created	
* 2.0		   SFSE-13634	   25-Mar-2024	   Jothsana@maersk.com				   Set Default GP and Default Revenue values for Segment Data of each Product
*/
public class Product2TriggerHandler extends TriggerHandler {
    
    public map<Id, Product2> newMap;
    public map<Id, Product2> oldMap;
    public Product2RecordSelector productRecordSelector;
    
    public Product2TriggerHandler() {
        this.newMap = (map<Id, Product2>)Trigger.newMap;
        this.oldMap = (map<Id, Product2>)Trigger.oldMap; 
    }
    
    public override void getRecordSelector() {
        productRecordSelector = new Product2RecordSelector(Trigger.new, this.oldMap, this);
    }
    
    public override void onBeforeInsert() {
        if(productRecordSelector.listNewProducts.size() > 0){
            Product2Utilities.populateNewProductDetails(productRecordSelector.listNewProducts);
        }
    }
    
    public override void onAfterInsert() {
        if(Test.isRunningTest()){
            if(productRecordSelector.listProduct2ToAddPriceBookEnty.size() > 0){
            //
            Product2Utilities.addPriceBookEntry(productRecordSelector.listProduct2ToAddPriceBookEnty);
        }
        }
    }
    
    public override void onAfterUpdate() {
       system.debug('##jj'+productRecordSelector.mapProductToLatestVersion);
        if(productRecordSelector.mapProductToLatestVersion.size() > 0){
            Product2Utilities.amendSegmentData(productRecordSelector.mapProductToLatestVersion, productRecordSelector.mapofProductToIsActive);
        }
    }
}