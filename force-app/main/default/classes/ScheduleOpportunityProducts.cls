/*      
* Revision      Ref Number      Date            Owner                       Description
* --------      ----------      -----------     -------------------         -------------------------
* 1.1           SFSE-10984      24-May-2023     Kiran@Maersk                To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 2.0           SFSE-12889      16-Oct-2023     Jothsana@maersk.com         To make OLI event publish queable
* 3.0           SFSE-13638      30-Jan-2024     Samar@maersk.com            Opportunity product revenue schedule
*/

public with sharing class ScheduleOpportunityProducts {
    
    public static Map<Id, Map<Id,Decimal>> OppIdToproductquantitymap = New Map<Id, Map<Id,Decimal>>(); // To store the Quantity when Product is added.
    public static String ObjType = ''; // Store the Object which initiated the operation for public Use.
    
    // To Prevent the Unassigned Product Deletion from ApplyProductSchedule Trigger. Also to identify if User has made any operation on Unassigned Product.
    public static Boolean OtherProductFlag = False; // To Prevent the Product trigger from operating on Unassigned product when added explicitely
    public static Boolean DontReinsertOtherProductFlag = False; 
    public static Boolean UpdatedFromOppProductTrigger = False; // To Prevent the Opportunity Update Trigger Recursion when FFE is Updated explicitely
    public static Boolean DeletedfromOppProductTrigger = False; // To Prevent the Opportunity Product Delete Trigger Recursion when the Other Product is deleted.
    public static Boolean DontExecuteOppLineItemTriggerFlag = False; // To Prevent the abINS_abUPD_abDEL_ApplyProductSchedule Trigger being called when Opp data is changed
    public static Boolean OpportunityfromClone = False; // To Identify if Opportunity is being created from Clone screen.
    public static Boolean LastProductDeleteFlag = False; // To Identify if the last product is being deleted from an Opportunity
    
    public static Set<Id> OtherProductErrorSet = New Set<Id>(); // To store the Ids of Other Product which failed for update
    
    
    public static void getSchedulingLogic(Set<Id> pChangedOpportunitylst,String pObjectType){
        
        List<Opportunity_Product__c> opportunityItems = new List<Opportunity_Product__c>();
        List<Opportunity_Product_Schedule__c> lineItemSchedule = New List<Opportunity_Product_Schedule__c>();
        Map<Id, Decimal> mapOliIdToOldSalesPrice = new Map<Id, Decimal>();
        List<Opportunity_Product__c> lstOLIToUpdate = new List<Opportunity_Product__c>();
        Map<Id,Opportunity> pChangedOpportunityMap = new  Map<Id,Opportunity>();
        
        system.debug('pObjectType-->>'+pObjectType);
        
        
        ObjType = pObjectType;
        if(pObjectType == 'Opportunity'){
            for(Opportunity opp:[SELECT id,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity WHERE Id IN:pChangedOpportunityLst ]){
                pChangedOpportunityMap.put(opp.id,opp);
            }
            //Modified by UST for RQ 771 : V2.0 - Added Schedule Product Field to the Query : Start
            opportunityItems = [SELECT Id, OpportunityId__c, Quantity__c, schedule_product__c, Amend_Expected_FFE__c, UnitPrice__c, Product_Revenue_Per_Unit__c  //RQ-010441 - Mod-01 - Included 'UnitPrice' field
                                FROM Opportunity_Product__c 
                                WHERE OpportunityId__c IN : pChangedOpportunitylst AND Opt_Out_Auto_Quantity_Scheduling__c = False];
            //Modified by UST for RQ 771 : V2.0 - Added Schedule Product Field to the Query : End
            System.debug('opportunityItems-->>'+opportunityItems);
            Map<Id,Decimal> OppLineItemIdToQTYMap = New Map<Id, Decimal>();
            for( Opportunity_Product__c oli : opportunityItems ){
                OppLineItemIdToQTYMap.put(oli.Id, oli.Quantity__c);
                OppIdToproductquantitymap.put(oli.OpportunityId__c, OppLineItemIdToQTYMap);
            }
        }
        // else{
        //     if(!Trigger.isDelete)
        //         opportunityItems = Trigger.New;
        //     else
        //         opportunityItems = Trigger.Old;
        
        //     System.debug('opportunityItems-->>'+opportunityItems);
        // }
        
        //Generate the Product schedules when Product is being inseretd or Opportunity shipment dates have been changed.
        if( pObjectType == 'Opportunity'){
            
            //need to get old price of OLI 
            List<Opportunity_Product__c> lstOppLineItem = [SELECT Id, UnitPrice__c, OpportunityId__c, Quantity__c,Amend_Expected_FFE__c,Schedule_Details__c FROM Opportunity_Product__c WHERE OpportunityId__c in :pChangedOpportunitylst]; //RQ-010441 - Mod-02 - Included "Schedule_Details__c" field
            //Schedule_Details__c
            for (Opportunity_Product__c oRec : lstOppLineItem){
                mapOliIdToOldSalesPrice.put(oRec.Id, oRec.UnitPrice__c);
            }
            
            
            List<Opportunity_Product_Schedule__c> lOpportunityLineItemScheduleList = New List<Opportunity_Product_Schedule__c>(); 
            
            lOpportunityLineItemScheduleList = [SELECT Id, Opportunity_Product__r.Opt_Out_Auto_Quantity_Scheduling__c,Opportunity_Product__c, Quantity__c, Revenue__c, Schedule_Date__c, Type__c 
                                                FROM Opportunity_Product_Schedule__c 
                                                WHERE Opportunity_Product__r.OpportunityId__c IN:pChangedOpportunitylst  AND Opportunity_Product__r.Opt_Out_Auto_Quantity_Scheduling__c = False];          
            
            system.debug('lOpportunityLineItemScheduleList-->>'+lOpportunityLineItemScheduleList);
            
            if( lOpportunityLineItemScheduleList.size()>0 ){
                Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt;
                if( Limits.getDMLRows()+ lOpportunityLineItemScheduleList.size()<= 5000){                
                    TriggerExecutionController.skipOpportunityProductTrigger(true);
                    List<Database.DeleteResult> oliSchdlsDeleteResultList = Database.delete(lOpportunityLineItemScheduleList, false ); 
                    TriggerExecutionController.skipOpportunityProductTrigger(false);
                    system.debug('oliSchdlsDeleteResultList-->>'+oliSchdlsDeleteResultList);
                    ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'ScheduleOpportunityProducts.getSchedulingLogic', oliSchdlsDeleteResultList, lOpportunityLineItemScheduleList) ; // #RQ-005636               
                }else{
                    OpportunityProdSchQueueable queueableDeleteSch = new OpportunityProdSchQueueable(lOpportunityLineItemScheduleList,null,'DeleteScheduleDetailsOnCustomOLI');
                    System.enqueueJob(queueableDeleteSch);
                }
                Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
                delete btt;
            }    
            
            // Generate the Opportunity Product Schedules for new Product.
            lineItemSchedule = PrepareProductSchedules(pChangedOpportunityMap, opportunityItems);
            //Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(lstOppLineItem); //RQ-010441 - Mod-08 - Commented out usage of duplicate method
            
            
            System.debug('lstOppLineItem-->>'+lstOppLineItem);
            // Insert Product Schedules and Insert Other Product with remainining QTY Update the FFE on Opportunity
            if( lineItemSchedule.size()>0 )
            {
                Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt;
                TriggerExecutionController.skipopptyLineItemTrigger(true);
                TriggerExecutionController.skipOpportunityProductTrigger(true);
                if( Limits.getDMLRows()+ lineItemSchedule.size() < 10000){
                    System.debug('lineItemSchedule1'+lineItemSchedule);
                    List<Database.SaveResult> oliUpdateResultList=Database.insert(lineItemSchedule,false);
                    System.debug('oliUpdateResultList1'+oliUpdateResultList);
                    ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'ScheduleOpportunityProducts.getSchedulingLogic',  oliUpdateResultList, lineItemSchedule) ; // #RQ-005636
                }else{
                    OpportunityProdSchQueueable queueableInsertSch = new OpportunityProdSchQueueable(lineItemSchedule,null,'InsertScheduleDetailsOnCustomOLI');
                    System.enqueueJob(queueableInsertSch);
                }
                
                
                Map<Id, String> mapOliIdToSchDetails = OpportunityProductSchedulingHelper.prepareScheduleDetailsForOLI(lstOppLineItem); //RQ-010441 - Mod-03 - Start - Changed the order of execution
                //Prepare OLI to update for SalesPrice
                for (Opportunity_Product__c oliRec : lstOppLineItem){
                    oliRec.UnitPrice__c = mapOliIdToOldSalesPrice.get(oliRec.Id);
                    system.debug('***********'+mapOliIdToSchDetails.get(oliRec.Id));
                    oliRec.Schedule_Details__c = mapOliIdToSchDetails.get(oliRec.Id);
                    lstOLIToUpdate.add(oliRec);
                } 

                //RQ-010441 - Mod-03 - End
                if (lstOLIToUpdate.size() > 0){
                    List<Database.SaveResult> lstOliUpdateResult = Database.update(lstOLIToUpdate,false);
                    System.debug('lstOLIToUpdate2'+lstOLIToUpdate);
                    System.debug('lstOliUpdateResult2'+lstOliUpdateResult);
                    
                    ErrorLogger.writeErrors('SFDC', 'ScheduleOpportunityProducts', 'ScheduleOpportunityProducts.getSchedulingLogic',  lstOliUpdateResult, lstOLIToUpdate) ; 
                   
                }
                if(!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled()){
                    OLIEventResponseHandler.fireQueableOliEventsAsync(new List<Id>(mapOliIdToOldSalesPrice.keySet()), false, true, true,false);
                }
                if(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled()){
                    OLIEventResponseHandler.fireOliEventAsync(new List<Id>(mapOliIdToOldSalesPrice.keySet()), false, true, true,false);
                }
                TriggerExecutionController.skipOpportunityProductTrigger(false);
                TriggerExecutionController.skipopptyLineItemTrigger(false);
                
                Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
                delete btt;
            }             
        }
        
                
    }
    
    // Calculate the dates based on Opportunity shipment dates.
    public static List<Date> calculatedates(Date FirstDate, Date LastDate){
        List<Date> datelist = New List<Date>();
        Date d = FirstDate;
        if( d.day() != 1 )
            d = Date.NewInstance(d.year(),d.month(),1);
        
        if(LastDate !=null) {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(LastDate) )
            {
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(LastDate);   
        } else {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(FirstDate) )
            {
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(FirstDate);   
        }
        return datelist;            
    }
    
    //#RQ-003245: Optimized the code
    public static List<Opportunity_Product_Schedule__c> PrepareProductSchedules(Map<Id,Opportunity> ChangedOpportunityMap, List<Opportunity_Product__c> opportunityItems)
    {
        List<Opportunity_Product_Schedule__c> lineItemSchedule = new List<Opportunity_Product_Schedule__c>();
        //System.debug('opportunityItems'+opportunityItems);
        for( Opportunity_Product__c lAssociatedOppItem : opportunityItems ){
            Opportunity opp = ChangedOpportunityMap.get(lAssociatedOppItem.OpportunityId__c);
            Decimal productQuantity = 0;
            
            //Modified by UST for RQ 771 : V2.0 - Product Scheduling should happen only when Product Schedule flag on OLI is TRUE : Start
            
            if( opp != null && opp.First_Shipment_Date__c != null ){ /*RQ-009597 */
                //Modified by UST for RQ 771 : V2.0 - Product Scheduling should happen only when Product Schedule flag on OLI is TRUE : End
                
                //System.debug('entered if loop ScheduleProduct');
                //System.debug('opp:' + opp);
                //System.debug('lAssociatedOppItem:' + lAssociatedOppItem);
                // Calculate the Scheduled dates based on Opportunity shipment Dates.
                List<Date> datelist = calculatedates(opp.First_Shipment_Date__c,opp.Last_Shipment_Date__c);
                
                //System.debug('datelist-->>'+datelist);
                if( datelist != null && datelist.size()>0 ){
                    
                    // Need to take Quantity from Before Insert Trigger Instance as it get changed due to schedule added automatically                      
                    if( OppIdToproductquantitymap != null && OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId__c) != null /*&& OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId__c).get(lAssociatedOppItem.PriceBookEntryId) != null*/ ){
                        productQuantity = OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId__c).get(lAssociatedOppItem.Id);
                    }
                    else if( !ScheduleOpportunityProducts.LastProductDeleteFlag ){
                        if(lAssociatedOppItem.Amend_Expected_FFE__c != null && lAssociatedOppItem.Quantity__c != lAssociatedOppItem.Amend_Expected_FFE__c ){
                            productQuantity = lAssociatedOppItem.Amend_Expected_FFE__c;
                        }else{
                            productQuantity = lAssociatedOppItem.Quantity__c;
                        }
                    }
                    //System.debug('---productQuantity---'+productQuantity);
                    lineItemSchedule.addAll(createScheduleRecords(lAssociatedOppItem,datelist,productQuantity));
                }
            }           
        }
        return lineItemSchedule;
    }
    
    // Generic method to create schedule records for OLI based on Opportunity First & Last shipment date and OLI Quantity
    public static List<Opportunity_Product_Schedule__c> createScheduleRecords( Opportunity_Product__c oli, List<Date> dateList, Decimal productQuantity ){
        
        List<Opportunity_Product_Schedule__c> lineItemSchedule = new List<Opportunity_Product_Schedule__c>();
        Integer EfectiveDuration = datelist.size();
        //system.debug('EfectiveDuration' + EfectiveDuration);
        Integer newQuantity = Integer.ValueOf(productQuantity)/EfectiveDuration;            // Find the QTY Count that need to be divided uniformly
        //system.debug('newQuantity' + newQuantity);
        //system.debug('productQuantity' + productQuantity);
        Decimal lastQuantity = math.mod(Integer.ValueOf(productQuantity),EfectiveDuration);
        //system.debug('lastQuantity' + lastQuantity);
        
        // Prepare list of product scheduled based on datelist.
        for(Integer count=1; count<=EfectiveDuration; count++){
            //system.debug('entered for loop' );
            Opportunity_Product_Schedule__c lNewOpportunityLISchedule = new Opportunity_Product_Schedule__c();
            if (count == EfectiveDuration){
                lNewOpportunityLISchedule.Quantity__c = newQuantity + lastQuantity;
                lNewOpportunityLISchedule.Revenue__c = oli.UnitPrice__c * (newQuantity + lastQuantity); //RQ-010441 - Mod-04 - Revenue calculation
                //system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity__c);
                lNewOpportunityLISchedule.Schedule_Revenue__c = oli.Product_Revenue_Per_Unit__c != null ? oli.Product_Revenue_Per_Unit__c * (newQuantity + lastQuantity): null;
            }else {
                lNewOpportunityLISchedule.Quantity__c = newQuantity;
                lNewOpportunityLISchedule.Revenue__c = oli.UnitPrice__c * newQuantity; //RQ-010441 - Mod-05 - Revenue calculation
                //system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity__c);
                lNewOpportunityLISchedule.Schedule_Revenue__c = oli.Product_Revenue_Per_Unit__c != null ? oli.Product_Revenue_Per_Unit__c * newQuantity: null;
            }
            //System.debug('datelist.get(count)'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.Opportunity_Product__c = oli.Id;
            //System.debug('datelist.get(count)-->>'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.Schedule_Date__c = datelist.get(count -1);
            lNewOpportunityLISchedule.Type__c = 'Both'; //RQ-010441 - Mod-06 - Changed type from 'Quantity' to 'Both' to accomodate Quantity and Revenue scheduling
            if( lNewOpportunityLISchedule.Quantity__c != 0 )
                lineItemSchedule.add(lNewOpportunityLISchedule);
        }
        //System.debug('lineItemSchedule '+lineItemSchedule.size());
        return lineItemSchedule; 
    }
    
}