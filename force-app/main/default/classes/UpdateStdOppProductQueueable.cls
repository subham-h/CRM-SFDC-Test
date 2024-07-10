public class UpdateStdOppProductQueueable implements Queueable {
     private List<Opportunity_Product__c> customObjList;
     private List<OpportunityLineItem> lstStandardOLI= new List<OpportunityLineItem>();
     private Map<Id,OpportunityLineItem> mapOfCustomOLIwithOLI = new  Map<Id,OpportunityLineItem>();
     private Map<Id,Opportunity_Product__c> mapOfCustomOLI = new  Map<Id,Opportunity_Product__c>();
     public UpdateStdOppProductQueueable(List<Opportunity_Product__c> objList,list<Opportunity_Product_Schedule__c> sch, Map<Id,Opportunity> opportunityMap, Map<id,Boolean> OpportunityClosedmap) {
        customObjList = objList;
    }
   
    public void execute(QueueableContext context) {
    Set<Id> standardObjectIds = new Set<Id>();
        List<OpportunityLineItem> standardObjList = new List<OpportunityLineItem>();
        // Collect the IDs of related standard objects
        for (Opportunity_Product__c customObj : customObjList) {
            standardObjectIds.add(customObj.ID);
            mapOfCustomOLI.put(customObj.ID,customObj);
        }
       try{
         for(OpportunityLineItem oli:[SELECT Id, Opportunity_Product__c,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, 
                                    Amend_Expected_FFE__c, Amend_Gross_Profit_per_unit__c, Product2Id, HasSchedule,Country__c, opportunityId,UnitPrice,
                                    Executing_City_State__c, Executing_City_State__r.Name, Trade_Route__r.Name, Quantity, Warehouse_Site__c, Warehouse_Site__r.Name FROM OpportunityLineItem 
                                    WHERE Opportunity_Product__c IN :standardObjectIds]){
                                        
                if(mapOfCustomOLI.containsKey(oli.Opportunity_Product__c) && mapOfCustomOLI.get(oli.Opportunity_Product__c)!= null){
                    Boolean isChanged = false;
                    Opportunity_Product__c customObj = mapOfCustomOLI.get(oli.Opportunity_Product__c);
                    if(customObj.UnitPrice__c != oli.unitPrice || customObj.quantity__c != oli.quantity){
                        isChanged = true;
                    }
                    oli.Actuals_Loaded__c = customObj.Actuals_Loaded__c;
                    oli.Amend_Gross_Profit_per_unit__c = customObj.Amend_Gross_Profit_per_unit__c ;
                    oli.Amend_Expected_FFE__c = customObj.Amend_Expected_FFE__c != null ? customObj.Amend_Expected_FFE__c : customObj.quantity__c;
                    oli.Blue_Collar_FTEs__c=customObj.Blue_Collar_FTEs__c;
                    oli.Building_Lease__c=customObj.Building_Lease__c;
                    oli.Cargo_Type__c=customObj.Cargo_Type__c;
                    oli.Comments__c=customObj.Comments__c;
                    //oli.CreatedById=customObj.CreatedById;
                    oli.ServiceDate=customObj.ServiceDate__c;
                    oli.Debug__c=customObj.Debug__c;
                    oli.Direct_Variable_Cost__c=customObj.Direct_Variable_Cost__c;
                    oli.Discount=customObj.Discount__c;
                    oli.EBIT__c=customObj.EBIT__c;
                    oli.Exclude_from_OMEB__c=customObj.Exclude_from_OMEB__c;
                    oli.Exclude_from_SIP__c=customObj.Exclude_from_SIP__c;
                    oli.Executing_City_State__c=customObj.Executing_City_State__c;
                    //to do oli.Country__c=customObj.Country__c;
                    oli.Country__c=customObj.Country__c;
                    oli.Fixed_Costs__c=customObj.Fixed_Costs__c;
                    oli.UnitPrice=customObj.UnitPrice__c;
                    oli.Import_Export__c=customObj.Import_Export__c;
                    oli.Indirect_FTEs__c=customObj.Indirect_FTEs__c;
                    oli.Invalid_Warehouse_Site__c=customObj.Invalid_Warehouse_Site__c;
                    oli.IsWndProduct__c=customObj.IsWndProduct__c;
                    oli.L_S_Product__c=customObj.L_S_Product__c;
                    //oli.LastModifiedById=customObj.LastModifiedById;
                    oli.Description=customObj.Description__c;
                    //oli.ListPrice=customObj.List_Price__c;
                    oli.Material_Handling_Equipment_Investments__c=customObj.Material_Handling_Equipment_Investments__c;
                    oli.Ocean_Product__c=customObj.Ocean_Product__c;
                    //oli.OpportunityId=customObj.OpportunityId__c;
                    //oli.Name=customObj.Name;
                    oli.OpportyProductExtID__c=customObj.OpportyProductExtID__c;
                    oli.Opt_Out_Auto_Quantity_Scheduling__c=customObj.Opt_Out_Auto_Quantity_Scheduling__c;
                    oli.Capital_Expenditure__c=customObj.Capital_Expenditure__c;
                    oli.Total_Tender_FFE_per_Route_Direction__c=customObj.Total_Tender_FFE_per_Route_Direction__c;
                  
                    oli.Previous_Tender_Target__c=customObj.Previous_Tender_Target__c;
                    //oli.Product2Id=customObj.Product2ID__c;
                    // oli.ProductCode=customObj.ProductCode__c;
                    // oli.Quantity=customObj.Quantity__c;
                    oli.Schedule_Details__c=customObj.Schedule_Details__c;
                    oli.Schedule_Product__c=customObj.Schedule_Product__c;
                    oli.SG_A__c=customObj.SG_A__c;
                    oli.Special_Cargo__c=customObj.Special_Cargo__c;
                    // oli.Subtotal=customObj.Subtotal__c;
                    oli.Tender_Target__c=customObj.Tender_Target__c;
                    oli.Total_Configurations__c=customObj.Total_Configurations__c;
                    oli.Total_Configurations_Filled__c=customObj.Total_Configurations_Filled__c;
                    oli.Total_Mandatory_Configuration__c=customObj.Total_Mandatory_Configuration__c;
                    oli.Total_Mandatory_Configuration_Filled__c=customObj.Total_Mandatory_Configuration_Filled__c;
                    oli.Trade_Guidance_Id__c=customObj.Trade_Guidance_Id__c;
                    oli.Trade_Route__c=customObj.Trade_Route__c;
                    oli.Warehouse_Site__c=customObj.Warehouse_Site__c;
                    oli.WND_Location_Type__c=customObj.WND_Location_Type__c;
                    oli.Commitment__c=customObj.Commitment__c;
                    standardObjList.add(oli);
                    if(isChanged){
                        lstStandardOLI.add(oli);
                    }
                }
            }
            if(!standardObjList.isEmpty()){
                update standardObjList;
            }
           
            
            if(!lstStandardOLI.isEmpty()  ){
                OpptyLineItemSchedulingHelper.reCreateScheduleOppLineItem(lstStandardOLI,false);
            }
          
        }catch(Exception ex){
           ErrorLogger.writeErrors( 'SFDC', 'InsertStdOppProductQueueable', 'InsertStdOppProductQueueable.execute', new list<Exception>{ex});
        }

    }
    }