/*
Class Name : ScheduleOppProducts
Description  :  1. Called in abINS_abUPD_abDEL_ApplyProductSchedule trigger   
2. Generate the Product schedules when Product is being inseretd or Opportunity shipment dates have been changed.
3. Update the FFE on Opportunity.
4. Calculate the dates based on Opportunity shipment dates.
Created By   : Cognizant Technology Solutions
Created On   : 19/07/2013
Change Log   :
------------------------------------------------------------------------------------------------------------------------------------------
V#     RQ       Created/Updated By                    Date             Description   

1.0              CTS                               19/07/2013                                           
2.0              CTS              
30/10/2013      RQ 771 Unassigned Product should be re-inserted  UST Global                               
only other OLI insert happens
3.0 RQ-001533   UST-Global                         09/06/2015                                                     UST Global     
4.0 RQ-002170   UST - Global                       5/11/2015       Optimise number of SOQL queries made for Standard Pricebook  UST Global  
5.0 #RQ-003743  Madhava.kotte@ust-global.com       04/05/2016      Updated for implementing CBO (Centralized By Org) trigger architecture.
6.0 #RQ-005636  Nisha@UST                          26/09/2017      Update references of GlobalErrorLogger
7.0 #RQ-007309  Jagadeesan@UST                     08/03/2018      Added logic for Amend Expected FFE value based schedule record creation
8.0 #RQ-009597  Sidhartha Mohapatra                26/11/2018      Removing auto creation of Unassigned Product and updating FFE
8.1 #RQ-009597  Sidhartha/Nitin                    14/12/2018      Defect fix
8.2 #RQ-009890  Sidhartha/Nitin                    24/01/2019      DataLoad Schedule creation defect fix.
9.0 #RQ-010441  Manjunath Holekade                 22-Apr-2019     Mod-01 to Mod-06 - Code added/modified to include "Revenue Scheduling"
                                                                   Mod-07 - Commented out ETL related scheduling code
                                                                   Mod-08 - Commented out duplicate method and it's usage
10.0#RQ-010441  Manjunath Holekade                 06-Jun-2019     Removal of references of deprecated fields                                                                  
-------------------------------------------------------------------------------------------------------------------------------------------- 
*/

public with sharing class ScheduleOppProducts 
{
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
    
    
    public static void getSchedulingLogic(Set<Id> pChangedOpportunityLst,String pObjectType)
    {
        List<OpportunityLineItem> opportunityItems = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lineItemSchedule = New List<OpportunityLineItemSchedule>();
        Map<Id, Decimal> mapOliIdToOldSalesPrice = new Map<Id, Decimal>();
        List<OpportunityLineItem> lstOLIToUpdate = new List<OpportunityLineItem>();
        Map<Id,Opportunity> pChangedOpportunityMap = new  Map<Id,Opportunity>();
        
        
        system.debug('pObjectType-->>'+pObjectType);
        
        ObjType = pObjectType;
        if(pObjectType == 'Opportunity')
        {
            //Getting OpportunityInfo 
            for(Opportunity opp:[SELECT id,First_Shipment_Date__c,Last_Shipment_Date__c FROM Opportunity WHERE Id IN:pChangedOpportunityLst ]){
                pChangedOpportunityMap.put(opp.id,opp);
            }
            //Modified by UST for RQ 771 : V2.0 - Added Schedule Product Field to the Query : Start
            opportunityItems = [SELECT Id, PriceBookEntryId, OpportunityId, Quantity, schedule_product__c, Amend_Expected_FFE__c, UnitPrice //RQ-010441 - Mod-01 - Included 'UnitPrice' field
                                FROM OpportunityLineItem 
                                WHERE OPPORTUNITYID IN : pChangedOpportunityLst AND Opt_Out_Auto_Quantity_Scheduling__c = False];
            //Modified by UST for RQ 771 : V2.0 - Added Schedule Product Field to the Query : End
            System.debug('opportunityItems-->>'+opportunityItems);
            Map<Id,Decimal> OppLineItemIdToQTYMap = New Map<Id, Decimal>();
            for( OpportunityLineItem oli : opportunityItems )
            {
                OppLineItemIdToQTYMap.put(oli.Id, oli.Quantity);
                OppIdToproductquantitymap.put(oli.OpportunityId, OppLineItemIdToQTYMap);
            }
        }
        // else
        // {
        //     if(!Trigger.isDelete)
        //         opportunityItems = Trigger.New;
        //     else
        //         opportunityItems = Trigger.Old;
            
        //     System.debug('opportunityItems-->>'+opportunityItems);
        // }
        
        //Generate the Product schedules when Product is being inseretd or Opportunity shipment dates have been changed.
        if( pObjectType == 'Opportunity')
        {
            //need to get old price of OLI 
            List<OpportunityLineItem> lstOppLineItem = [SELECT Id, UnitPrice, OpportunityId, Schedule_Details__c,Amend_Expected_FFE__c,Quantity  FROM OpportunityLineItem WHERE OpportunityId in :pChangedOpportunityLst ]; //RQ-010441 - Mod-02 - Included "Schedule_Details__c" field
            for (OpportunityLineItem oRec : lstOppLineItem){
                mapOliIdToOldSalesPrice.put(oRec.Id, oRec.UnitPrice);
            }
            
            
            List<OpportunityLineItemSchedule> lOpportunityLineItemScheduleList = New List<OpportunityLineItemSchedule>(); 
            
            lOpportunityLineItemScheduleList = [SELECT Id, OpportunityLineItem.Opt_Out_Auto_Quantity_Scheduling__c,OpportunityLineItemId, Quantity, Revenue, ScheduleDate, Type 
                                                FROM OpportunityLineItemSchedule 
                                                WHERE OpportunityLineItem.OpportunityId IN:pChangedOpportunityLst  AND OpportunityLineItem.Opt_Out_Auto_Quantity_Scheduling__c = False];          
            
            system.debug('lOpportunityLineItemScheduleList-->>'+lOpportunityLineItemScheduleList);
            
            if( lOpportunityLineItemScheduleList.size()>0 )
            {
                String OppSchSize = System.Label.OpportunityScheduleListSize;
                if( Limits.getDMLRows()+ lOpportunityLineItemScheduleList.size()<= Integer.valueof(OppSchSize)){
                    TriggerExecutionController.skipopptyLineItemTrigger(true);
                    TriggerExecutionController.skipOpportunityProductTrigger(true);
                    TriggerExecutionController.skipOpportunityTrigger(true);
                    TriggerExecutionController.skipOpportunityLineItemSchedule(true);
                    List<Database.DeleteResult> oliSchdlsDeleteResultList = Database.delete(lOpportunityLineItemScheduleList, false ); 
                    TriggerExecutionController.skipopptyLineItemTrigger(false); 
                    TriggerExecutionController.skipOpportunityProductTrigger(false);  
                    TriggerExecutionController.skipOpportunityTrigger(false);
                    TriggerExecutionController.skipOpportunityLineItemSchedule(false);             
                    ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic', oliSchdlsDeleteResultList, lOpportunityLineItemScheduleList) ; // #RQ-005636               
                }else{
                    OpportunityProdSchQueueable queueableDeleteSch = new OpportunityProdSchQueueable(null,lOpportunityLineItemScheduleList,'DeleteScheduleDetailsOnOLI');
                    System.enqueueJob(queueableDeleteSch);
                }
               
                
            }
            // to add change
            // Generate the Opportunity Product Schedules for new Product.
            lineItemSchedule = PrepareProductSchedules(pChangedOpportunityMap, opportunityItems);
            //Map<Id, String> mapOliIdToSchDetails = prepareScheduleDetailsForOLI(lstOppLineItem); //RQ-010441 - Mod-08 - Commented out usage of duplicate method

        
            System.debug('lstOppLineItem-->>'+lstOppLineItem);
            // Insert Product Schedules and Insert Other Product with remainining QTY Update the FFE on Opportunity
            if( lineItemSchedule.size()>0 )
            {
               
                    TriggerExecutionController.skipopptyLineItemTrigger(true);
                    TriggerExecutionController.skipOpportunityProductTrigger(true);
                    String OppSchSize = System.Label.OpportunityScheduleListSize;
                    if( Limits.getDMLRows()+ lineItemSchedule.size() <= Integer.valueof(OppSchSize)){
                        List<Database.SaveResult> oliUpdateResultList=Database.insert(lineItemSchedule,false);
                        System.debug('oliUpdateResultList'+oliUpdateResultList);
                        ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  oliUpdateResultList, lineItemSchedule) ; // #RQ-005636
                    }else{
                        OpportunityProdSchQueueable queueableInsertSch = new OpportunityProdSchQueueable(null,lineItemSchedule,'InsertScheduleDetailsOnOLI');
                        System.enqueueJob(queueableInsertSch);
                    }
                    
                    Map<Id, String> mapOliIdToSchDetails = OpptyLineItemSchedulingHelper.prepareScheduleDetailsForOLI(lstOppLineItem); //RQ-010441 - Mod-03 - Start - Changed the order of execution
                    //Prepare OLI to update for SalesPrice
                    for (OpportunityLineItem oliRec : lstOppLineItem){
                        oliRec.UnitPrice = mapOliIdToOldSalesPrice.get(oliRec.Id);
                        oliRec.Schedule_Details__c = mapOliIdToSchDetails.get(oliRec.Id);
                        lstOLIToUpdate.add(oliRec);
                    }                                                                                                                   //RQ-010441 - Mod-03 - End
                    if (lstOLIToUpdate.size() > 0){
                         // Try for bug fix - Rama - SFSE-13321
                         //String OppSchSize = System.Label.OpportunityScheduleListSize;
                         if( Limits.getDMLRows()+ lineItemSchedule.size() <= Integer.valueof(OppSchSize)){  //10000                  
                                List<Database.SaveResult> lstOliUpdateResult = Database.update(lstOLIToUpdate,false);
                                System.debug('lstOliUpdateResult'+lstOliUpdateResult);
                                ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  lstOliUpdateResult, lstOLIToUpdate) ; 
                        }else{
                                system.debug('Within else before queuable - Opportunity Product update');
                                OpportunityProdSchQueueable queueableUpdateOppProduct = new OpportunityProdSchQueueable(null,lstOLIToUpdate,'UpdateOpportunityProduct');
                                System.enqueueJob(queueableUpdateOppProduct );
                            }
                        system.debug('lstOLIToUpdate before update..'+lstOLIToUpdate.size());
                    
                        /*List<Database.SaveResult> lstOliUpdateResult = Database.update(lstOLIToUpdate,false);
                        System.debug('lstOliUpdateResult'+lstOliUpdateResult);
                        ErrorLogger.writeErrors('SFDC', 'ScheduleOppProducts', 'ScheduleOppProducts.getSchedulingLogic',  lstOliUpdateResult, lstOLIToUpdate) ; 
                        */
                    }   
                    TriggerExecutionController.skipOpportunityProductTrigger(false);
                TriggerExecutionController.skipopptyLineItemTrigger(false);

               

            }
        }
    }
    
    // Calculate the dates based on Opportunity shipment dates.
    public static List<Date> calculatedates(Date FirstDate, Date LastDate)
    {
        system.debug('entered calculatedates');
        List<Date> datelist = New List<Date>();
        
        Date d = FirstDate;
        system.debug('d' + d);
        if( d.day() != 1 )
            d = Date.NewInstance(d.year(),d.month(),1);
        system.debug('d1' + d);
        if(LastDate !=null) {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(LastDate) )
            {
                system.debug('entered while loop');
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(LastDate);   
        } else {
            Integer count = 1;
            while( count <= FirstDate.monthsBetween(FirstDate) )
            {
                system.debug('entered while loop');
                datelist.add(d);
                d=d.addMonths(1);
                count++;
            }
            datelist.add(FirstDate);   
        }
        return datelist;            
    }
    
    //#RQ-003245: Optimized the code
    public static  List<OpportunityLineItemSchedule> PrepareProductSchedules(Map<Id,Opportunity> ChangedOpportunityMap, List<OpportunityLineItem> opportunityItems)
    {
        List<OpportunityLineItemSchedule> lineItemSchedule = new List<OpportunityLineItemSchedule>();
        System.debug('opportunityItems'+opportunityItems);
        for( OpportunityLineItem lAssociatedOppItem : opportunityItems )
        {
            Opportunity opp = ChangedOpportunityMap.get(lAssociatedOppItem.OpportunityId);
            Decimal productQuantity = 0;
            
            //Modified by UST for RQ 771 : V2.0 - Product Scheduling should happen only when Product Schedule flag on OLI is TRUE : Start

            if( opp != null && opp.First_Shipment_Date__c != null )  /*RQ-009597 */
                //Modified by UST for RQ 771 : V2.0 - Product Scheduling should happen only when Product Schedule flag on OLI is TRUE : End
            {
                System.debug('entered if loop ScheduleProduct');
                System.debug('opp:' + opp);
                System.debug('lAssociatedOppItem:' + lAssociatedOppItem);
                // Calculate the Scheduled dates based on Opportunity shipment Dates.
                List<Date> datelist = calculatedates(opp.First_Shipment_Date__c,opp.Last_Shipment_Date__c);
                
                System.debug('datelist-->>'+datelist);
                if( datelist != null && datelist.size()>0 )
                {
                    
                    // Need to take Quantity from Before Insert Trigger Instance as it get changed due to schedule added automatically                      
                    if( OppIdToproductquantitymap != null && OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId) != null && OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId).get(lAssociatedOppItem.PriceBookEntryId) != null )
                        productQuantity = OppIdToproductquantitymap.get(lAssociatedOppItem.OpportunityId).get(lAssociatedOppItem.PriceBookEntryId);
                    
                    else if( !ScheduleOppProducts.LastProductDeleteFlag ){
                        if(lAssociatedOppItem.Amend_Expected_FFE__c != null && lAssociatedOppItem.Quantity != lAssociatedOppItem.Amend_Expected_FFE__c ){
                            productQuantity = lAssociatedOppItem.Amend_Expected_FFE__c;
                        }else{
                            productQuantity = lAssociatedOppItem.Quantity;
                        }
                    }
                    System.debug('---productQuantity---'+productQuantity);
                    lineItemSchedule.addAll(createScheduleRecords(lAssociatedOppItem,datelist,productQuantity));
                }
            }           
        }
        return lineItemSchedule;
    }
    
    // Generic method to create schedule records for OLI based on Opportunity First & Last shipment date and OLI Quantity
    public static List<OpportunityLineItemSchedule> createScheduleRecords( OpportunityLineItem oli, List<Date> dateList, Decimal productQuantity ){
        
        List<OpportunityLineItemSchedule> lineItemSchedule = new List<OpportunityLineItemSchedule>();
        Integer EfectiveDuration = datelist.size();
        system.debug('EfectiveDuration' + EfectiveDuration);
        Integer newQuantity = Integer.ValueOf(productQuantity)/EfectiveDuration;            // Find the QTY Count that need to be divided uniformly
        system.debug('newQuantity' + newQuantity);
        system.debug('productQuantity' + productQuantity);
        Decimal lastQuantity = math.mod(Integer.ValueOf(productQuantity),EfectiveDuration);
        system.debug('lastQuantity' + lastQuantity);
        
        // Prepare list of product scheduled based on datelist.
        for(Integer count=1; count<=EfectiveDuration; count++)
        {
            system.debug('entered for loop' );
            OpportunityLineItemSchedule lNewOpportunityLISchedule = new OpportunityLineItemSchedule();
            if (count == EfectiveDuration){
                lNewOpportunityLISchedule.Quantity = newQuantity + lastQuantity;
                lNewOpportunityLISchedule.Revenue = oli.UnitPrice * (newQuantity + lastQuantity); //RQ-010441 - Mod-04 - Revenue calculation
                system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity);
            } else {
                lNewOpportunityLISchedule.Quantity = newQuantity;
                lNewOpportunityLISchedule.Revenue = oli.UnitPrice * newQuantity; //RQ-010441 - Mod-05 - Revenue calculation
                system.debug('lNewOpportunityLISchedule.Quantity' + lNewOpportunityLISchedule.Quantity);
            }
             System.debug('datelist.get(count)'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.OpportunityLineItemId = oli.Id;
            System.debug('datelist.get(count)-->>'+count+'  '+datelist.get(count -1));
            lNewOpportunityLISchedule.ScheduleDate = datelist.get(count -1);
            lNewOpportunityLISchedule.Type = 'Both'; //RQ-010441 - Mod-06 - Changed type from 'Quantity' to 'Both' to accomodate Quantity and Revenue scheduling
            if( lNewOpportunityLISchedule.Quantity != 0 )
                lineItemSchedule.add(lNewOpportunityLISchedule);
        }
        
        return lineItemSchedule; 
    }
}