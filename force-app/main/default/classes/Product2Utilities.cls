/*              
* Revision     Ref Number      Date            Owner                               Description
* -----------------------------------------------------------------------------------------
* 1.0          RQ-009931       23-Jan-2019     Junaid.Khader@ust-global.com        Code created
* 2.0		   RQ-011978	   25-Sep-2019	   manjunath.c.holekade@maersk.com     Enable "Revenue Scheduling"
* 2.1          RQ-012235       25-Nov-2019     nitin.v.more@maersk.com             Set Family to Ocean if its created by route interface user.
* 2.0          SFSE-5089       12-Apr-2021     meghana.gupta@ust.com               Set Portfolio to Ocean if its created by route interface user.
* 3.0          SFSE-14236      03-Mar-2024     Sunil.bs@maersk.com                 Set Default Gp and default revenue values for new price book entry
* 4.0		   SFSE-13634	   25-Mar-2024	   Jothsana@maersk.com				   Set Default GP and Default Revenue values for Segment Data of each Product
*/

public class Product2Utilities {
    
    public static void populateNewProductDetails(List<Product2> listProducts){
        for(Product2 rowProduct : listProducts){
            If(UserInfo.getName() == Label.IntegrationRouteUser) {
                rowProduct.isActive = true;
                rowProduct.Family = Label.Ocean_Product;
                rowProduct.Name = rowProduct.Description + ' ' + rowProduct.Route_Direction_Code__c;
                rowProduct.Portfolio__c = Label.Ocean_Product;
                rowProduct.Include_in_SIP__c = true;
            }
            rowProduct.CANUSEQUANTITYSCHEDULE = true;
            rowProduct.CANUSEREVENUESCHEDULE = true;  //RQ-011978
        }
    }
    
    
    public static void addPriceBookEntry(List<Product2> listProduct2ToAddPriceBookEnty){
        Id idStandardPriceBook;
        List<PricebookEntry> listPriceBookEntryToInsert;
        PricebookEntry newPricebookEntry;
        
        if(Test.isRunningTest()) {
            idStandardPriceBook = Test.getStandardPricebookId();
        } else {
            for(PriceBook2 rowPriceBook : [SELECT Id FROM PriceBook2 WHERE IsStandard = true LIMIT 1]){
                idStandardPriceBook = rowPriceBook.Id;
            }
        }
        if(idStandardPriceBook != null){
            listPriceBookEntryToInsert = new List<PricebookEntry>();
            for(Product2 rowProduct : listProduct2ToAddPriceBookEnty){
                newPricebookEntry = new PricebookEntry();
                newPricebookEntry.Pricebook2Id = idStandardPriceBook;
                newPricebookEntry.Product2Id = rowProduct.Id;
                newPricebookEntry.UnitPrice = 1;
                newPricebookEntry.IsActive = (rowProduct.Family == Label.Ocean_Product) ? true : rowProduct.isActive;
                listPriceBookEntryToInsert.add(newPricebookEntry);
            }
            if(listPriceBookEntryToInsert.size() > 0){
                List<Database.SaveResult> listPbeInsertResult = Database.Insert(listPriceBookEntryToInsert, false);
                ErrorLogger.writeErrors('SFDC', 'Product2Utilities', 'addPriceBookEntry', listPbeInsertResult, listPriceBookEntryToInsert);
            }
        }
    }
    
    public static void amendSegmentData(Map<Id, Id> mapProductToLatestVersion, Map<Id,Boolean> mapofProductToIsActive){
        List<Segment_Data__c> listSegmentData = new List<Segment_Data__c>();
        List<Segment_Data__c> listSegmentDataToInsert = new List<Segment_Data__c>();
        Set<Id> LatestversionIds = new Set<Id>();
        for(Id prod : mapProductToLatestVersion.Keyset()){
            LatestversionIds.add(mapProductToLatestVersion.get(prod));
        }
        List<Segment_Data__c> ExistinglistSegmentData = [Select id,Name,Product__c,Segmentation__c, Revenue_unit__c, Default_GP_Margin__c, Default_GP_unit__c,Type__c from Segment_Data__c WHERE Product__c IN :LatestversionIds and Type__c =: 'Revenue'];
        listSegmentData = [Select id,Name,Product__c,Segmentation__c, Revenue_unit__c,Active__c, Type__c, Default_GP_Margin__c, Default_GP_unit__c from Segment_Data__c WHERE Product__c IN :mapProductToLatestVersion.keySet() and Type__c =: 'Revenue'];
        for(Segment_Data__c row : listSegmentData){
            if(listSegmentData.size() > 0 && ExistinglistSegmentData.isEmpty()){
                if(mapProductToLatestVersion.containsKey(row.Product__c) && mapProductToLatestVersion.get(row.Product__c) != null){
                    Segment_Data__c sgd = new Segment_Data__c();
                    sgd.Product__c = mapProductToLatestVersion.get(row.Product__c);
                    sgd.Segmentation__c = row.Segmentation__c;
                    sgd.Revenue_unit__c = row.Revenue_unit__c;
                    sgd.Default_GP_Margin__c = row.Default_GP_Margin__c;
                    sgd.Active__c = row.Active__c;
                    sgd.Type__c = row.Type__c;
                    listSegmentDataToInsert.add(sgd);
                }
            }
            if(!mapofProductToIsActive.KeySet().isEmpty()){
                row.Active__c = mapofProductToIsActive.get(row.Product__c);
            }
            listSegmentDataToInsert.add(row);
        }
        if(listSegmentDataToInsert.size() > 0){
            Database.UpsertResult[] listSgdUpdateResult =  Database.upsert(new List<Segment_Data__c>(listSegmentDataToInsert), false);
            ErrorLogger.writeErrors('SFDC', 'Product2Utilities', 'amendSegmentData', listSgdUpdateResult, listSegmentDataToInsert);
        }
    }
}