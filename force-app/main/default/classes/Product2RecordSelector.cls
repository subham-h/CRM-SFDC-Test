/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009931       23-Jan-2019     Junaid.Khader@ust-global.com        Code created
* 2.0		   SFSE-13634	   25-Mar-2024	   Jothsana@maersk.com				   Set Default GP and Default Revenue values for Segment Data of each Product
*/
public class Product2RecordSelector implements RecordSelector {
    
    private TriggerHandler productTriggerHandler; 
    public List<Product2> listNewProducts = new List<Product2>();
    public List<Product2> listProduct2ToAddPriceBookEnty = new List<Product2>();
    public Map<Id, Id> mapProductToLatestVersion = new Map<Id, Id>();
    public Map<Id,Boolean> mapofProductToIsActive = new Map<Id,Boolean>();
    
    public Product2RecordSelector(List<Product2> listProducts, Map<Id, Product2> mapOldProducts, Product2TriggerHandler productTriggerHandler) {
        this.productTriggerHandler = productTriggerHandler;
        selectRecords(listProducts, mapOldProducts);
    }
    
    public void selectRecords(list<Product2> listProducts, Map<Id, SObject> mapOldProducts) {
        Product2 oldProduct2;
        
        if(listProducts.size() > 0){
            for(Product2 rowProduct : listProducts) {
                if((productTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) && (productTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT)) {
                    listNewProducts.add(rowProduct);
                }
                if((productTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER)) {
                    if(productTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                        listProduct2ToAddPriceBookEnty.add(rowProduct);
                    } else if(productTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                        if(mapOldProducts.containsKey(rowProduct.Id) && mapOldProducts.get(rowProduct.Id) != null) {
                            oldProduct2 = (Product2)mapOldProducts.get(rowProduct.Id);
                            if(oldProduct2.isActive != rowProduct.isActive){
                                mapProductToLatestVersion.put(rowProduct.Id, rowProduct.Latest_Product_Version__c);
                                mapofProductToIsActive.put(rowProduct.Id,rowProduct.IsActive);
                            }
                        }
                    }
                }
            }
        }
        getRelatedRecords(listProducts);
    }
    
    public void getRelatedRecords(list<SObject> listProducts) {
        
    }
}