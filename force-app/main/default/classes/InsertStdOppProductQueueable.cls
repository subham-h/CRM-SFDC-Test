public class InsertStdOppProductQueueable implements Queueable {
    // public class InsertStdOppProductQueueable implements Queueable,Database.AllowsCallouts {
    private List<Opportunity_Product__c> customObjList;
    private List<Opportunity_Product_Schedule__c> sch;
    private Map<Id,Opportunity> opportunityMap;
    private Map<id,Boolean> OpportunityClosedmap;
     private Map<Id,Id> mapOfPriceBookEntry = new Map<Id,Id>();
     
     public InsertStdOppProductQueueable(List<Opportunity_Product__c> objList,list<Opportunity_Product_Schedule__c> sch, Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap) {
     //   public InsertStdOppProductQueueable(List<Opportunity_Product__c> objList) {
        customObjList = objList;
        sch = sch;
        this.opportunityMap = opportunityMap;
        this.OpportunityClosedmap = OpportunityClosedmap;
    }
    
    public void execute(QueueableContext context) {

         try{
              List<OpportunityLineItem> standardObjList = new List<OpportunityLineItem>();
         //if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new GetInsuranceAPIMockCallout(GetInsuranceAPIMockCallout.request_mode.getInsurance));
            Set<Id> lstOfProduct= new Set<Id>();
            for(Opportunity_Product__c customObj : customObjList){
                lstOfProduct.add(customObj.Product2ID__c);
            }

            if(!lstOfProduct.isEmpty()){
                for(PricebookEntry pbentry:[SELECT id,Product2Id FROM PricebookEntry WHERE Product2Id IN:lstOfProduct AND IsActive = true] ){
                    if(!mapOfPriceBookEntry.containskey(pbentry.Product2Id)){
                        mapOfPriceBookEntry.put(pbentry.Product2Id,pbentry.Id);
                    }
                }
            }
            
            // Iterate through the Custom Object records
            for (Opportunity_Product__c customObj : customObjList) {
             system.debug('testcustomObj'+customObj);
            
            
            // Create a new Standard Object record
            OpportunityLineItem standardObj = new OpportunityLineItem(
                Actuals_Loaded__c=customObj.Actuals_Loaded__c,
                Amend_Gross_Profit_per_unit__c=customObj.Amend_Gross_Profit_per_unit__c,
                Amend_Expected_FFE__c=customObj.Amend_Expected_FFE__c,
                Blue_Collar_FTEs__c=customObj.Blue_Collar_FTEs__c,
                Building_Lease__c=customObj.Building_Lease__c,
                Cargo_Type__c=customObj.Cargo_Type__c,
                Comments__c=customObj.Comments__c,
                 PricebookEntryId = mapOfPriceBookEntry.containskey(customObj.Product2ID__c) ? mapOfPriceBookEntry.get(customObj.Product2ID__c) :'',
                //CreatedById=customObj.CreatedById,
                Opportunity_Product__c=customObj.Id,
                ServiceDate=customObj.ServiceDate__c,
                Debug__c=customObj.Debug__c,
                Direct_Variable_Cost__c=customObj.Direct_Variable_Cost__c,
                Discount=customObj.Discount__c,
                EBIT__c=customObj.EBIT__c,
                Exclude_from_OMEB__c=customObj.Exclude_from_OMEB__c,
                Exclude_from_SIP__c=customObj.Exclude_from_SIP__c,
                Executing_City_State__c=customObj.Executing_City_State__c,
                Country__c=customObj.Country__c,
                Fixed_Costs__c=customObj.Fixed_Costs__c,
                UnitPrice=customObj.UnitPrice__c,
                Import_Export__c=customObj.Import_Export__c,
                Indirect_FTEs__c=customObj.Indirect_FTEs__c,
                Invalid_Warehouse_Site__c=customObj.Invalid_Warehouse_Site__c,
                IsWndProduct__c=customObj.IsWndProduct__c,
                L_S_Product__c=customObj.L_S_Product__c,
                //LastModifiedById=customObj.LastModifiedById,
                Description=customObj.Description__c,
                //ListPrice=customObj.List_Price__c,
                Material_Handling_Equipment_Investments__c=customObj.Material_Handling_Equipment_Investments__c,
                //Nominated_Quantity__c=customObj.Nominated_Quantity__c,
                Ocean_Product__c=customObj.Ocean_Product__c,
                OpportunityId=customObj.OpportunityId__c,
                //Name=customObj.Name,
                OpportyProductExtID__c=customObj.OpportyProductExtID__c,
                Opt_Out_Auto_Quantity_Scheduling__c=customObj.Opt_Out_Auto_Quantity_Scheduling__c,
                Capital_Expenditure__c=customObj.Capital_Expenditure__c,
                Total_Tender_FFE_per_Route_Direction__c=customObj.Total_Tender_FFE_per_Route_Direction__c,
                
                Previous_Tender_Target__c=customObj.Previous_Tender_Target__c,
                 //Product2Id=customObj.Product2ID__c,
                //ProductCode=customObj.ProductCode__c,
                Quantity=customObj.Quantity__c,
                Schedule_Details__c=customObj.Schedule_Details__c,
                Schedule_Product__c=customObj.Schedule_Product__c,
                SG_A__c=customObj.SG_A__c,
                Special_Cargo__c=customObj.Special_Cargo__c,
                //Subtotal=customObj.Subtotal__c,
                Tender_Target__c=customObj.Tender_Target__c,
                Total_Configurations__c=customObj.Total_Configurations__c,
                Total_Configurations_Filled__c=customObj.Total_Configurations_Filled__c,
                Total_Mandatory_Configuration__c=customObj.Total_Mandatory_Configuration__c,
                Total_Mandatory_Configuration_Filled__c=customObj.Total_Mandatory_Configuration_Filled__c,
                Trade_Guidance_Id__c=customObj.Trade_Guidance_Id__c,
                Trade_Route__c=customObj.Trade_Route__c,
                Warehouse_Site__c=customObj.Warehouse_Site__c,
                WND_Location_Type__c=customObj.WND_Location_Type__c,
                Commitment__c=customObj.Commitment__c
                /*
                Country__c=customObj.Country__c ,
                UnitPrice=customObj.UnitPrice__c ,
                Executing_City_State__c=customObj.Executing_City_State__c,
                Quantity=customObj.Quantity__c,
                Description=customObj.Description__c,
                OpportunityId=customObj.OpportunityId__c,
                Product2Id=customObj.Product2Id__c,
                Total_Mandatory_Configuration_Filled__c=customObj.Total_Mandatory_Configuration_Filled__c,
                Total_Tender_FFE_per_Route_Direction__c=customObj.Total_Tender_FFE_per_Route_Direction__c,
                Import_Export__c=customObj.Import_Export__c,
                Total_Mandatory_Configuration__c=customObj.Total_Mandatory_Configuration__c,
                Total_Configurations__c=customObj.Total_Configurations__c,
                Opt_Out_Auto_Quantity_Scheduling__c=customObj.Opt_Out_Auto_Quantity_Scheduling__c,
                Total_Configurations_Filled__c=customObj.Total_Configurations_Filled__c,
                WND_Location_Type__c=customObj.WND_Location_Type__c,
                Opportunity_Product__c=customObj.Id
                */
                
            );
            
            standardObjList.add(standardObj);
        }
         if(!standardObjList.isEmpty()){
        insert standardObjList;
            
            OpptyLineItemSchedulingHelper.scheduleOppLineItem(standardObjList, null, opportunityMap, OpportunityClosedmap);
        
         }
         
       
       
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'InsertStdOppProductQueueable', 'InsertStdOppProductQueueable.execute', new list<Exception>{ex});
        }
      
    }
}