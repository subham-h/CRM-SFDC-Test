/*      
* Revision  Ref Number      Date            Owner                           Description
* --------  ----------      -----------     -------------------             -------------------------
* 1.0       SFSE-10984      16-May-2023     mahanthi.devi@maersk.com        To replicate standard OLI Trigger Logic on cutom object Opportunity Product .
* 2.0       SFSE-10900      29-May-2023     Samarpreet@maersk.com           Add Logic for Opportunity Product Platform Event  .
* 3.0       SFSE-9052       02-Jun-2023     Kiran@Maersk                    Removing the logic implemented as part of SFSE-8521
* 4.1       SFSE-11281      15-Aug-2023     Jothsana@Maersk                 OMEB new product Air/LCL & MCS product changes
* 4.2       SFSE-11517      15-Aug-2023     Aleena@Maersk                   OMEB new product Air/LCL & MCS product changes
* 4.3       SFSE-12203      25-Aug-2023     Kiran@Maersk                    OMEB new products Air/LCL & MCS Live issue fixes
* 4.4       SFSE-12888      11-Oct-2023     Aleena@Maersk                   Opportunity Event record selection on delete of Opportunity Product
* 5.0       SFSE-12722      20-Oct-2023     Kiran@Maersk                    SOQL101 Error fixes
* 6.0       SFSE-11753      03-11-23        Ritika@Maersk                   To change the product family references to custom label
* 7.0       SFSE-13716      21-Dec-2023     Aleena@Maersk                   OIPC Code null then issue in any update.     
* 8.0       SFSE-13638      30-Jan-2024     Samar@maersk.com                Opportunity product revenue schedule
* 9.0       SFSE-14324      21-Mar-2024     ramadevi@maersk                 Update the Recommendation is the Opportunity Product is deleted  
* 10.0      SFSE-14428      23-Apr-2024     Avinash@Maersk                  Refine the code to overcome the governor limits.
* 11.0      SFSE-14825      28-May-2024     Avinash@Maersk                  "Cargo type" on Opportunity level
*/
public class OpportunityProductRecordSelector {

    public static boolean oppProductTrigger = true;
    public Set<Id> oppIAcceptSet = new Set<Id>();
    public Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
    public List<Opportunity_Product__c> lstAmendedFFEProducts = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstChangedCountryProduct = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstsetSalesPrice = new List<Opportunity_Product__c>();
    public Map<id,Boolean> closedOppMap = new map<id,Boolean>();
    public Boolean VRBypassIsActive;
    public Boolean isClone = false;
    public List<Opportunity_Product__c> lstSetQuantityToProductOwnerTarget = new List<Opportunity_Product__c>();
    //public List<Opportunity_Product__c> lstSetQuantityToNominatedQuantity = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstAmendGP = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstOmebCheck = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstOCFforAPAregion = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> lstOptOutSelected = new List<Opportunity_Product__c>();
    public List<Opportunity_Product__c> approvedSGOptyQuoteStage = new List<Opportunity_Product__c>();      //Opportunity with Approval solution gate and quoting stage
    public List<String> solutionGateOpportunityStages = new List<String>();
    public List<Opportunity_Product__c> OppProdOpptyWithPendingApprovals = new List<Opportunity_Product__c>();      //Opportunity with Approval solution gate and quoting stage
    public List<Opportunity_Product__c> lstChangedAnnualizedGrossProfitCLProduct = new List<Opportunity_Product__c>();  
    public List<Id> lstOpptyProductIdtoProcess = new List<Id>(); // List to hold values of Opportunity product id to process Opportunity platform Event in Update/ Insert
    public List<Id> lstOpptyProductIdonDelete = new List<Id>(); // List to hold values of Opportunity product id to process Opportunity platform Event in Delete
    public Set<Id> lstOfOpportunityProductForEvent = new Set<Id>(); //12888
    public Set<Id> lstOfOpportunityProductForEventDel = new Set<Id>();
    public List<Opportunity_Product__c> lstAmendedRevenueProducts = new List<Opportunity_Product__c>(); // SFSE-13638
    public static map<Id, Opportunity> opptyMap = new map<Id, Opportunity>();//SFSE-14428
    public static map<Id,Product2> prodMap = new map<Id,Product2>();//SFSE-14428
    static Set<Id> opptyHasPendingApprovalProcesses = new Set<Id>();//SFSE-14428

    //SFSE-14324
    public Map<String,String> oppToUpdateRecomm = new Map<String,String>();
    public set<Id> oppRecomUpdateType = new set<Id>();
    
    //SFSE-15073 - Customer Insight
    public Set<Id> OppIdSet = new Set<Id>();
    public Map<Id,Recommendation__c> OppIdWithRecomMap = new Map<Id,Recommendation__c>();
    
    //SFSE-14825
    public static Set<string> setOptyToUpdtCargoType = new Set<String>();

     public OpportunityProductRecordSelector(list<Opportunity_Product__c> lstNewoppProducts, map<Id, Opportunity_Product__c> OldoppProducts, TriggerHandler opptyProductTriggerHandler/*, map<Id, Opportunity> opptyMap, map<Id,Product2> prodMap*/) {//Commented as part of SFSE-14428
        
        //SFSE-9417 Sales stages to not to allow deleting Products
        solutionGateOpportunityStages = Label.Solution_Gate_Opportunity_Stages.split(',');
        Set<Id> omebOpptyIds = new Set<Id>();
        
        //SFSE-14428 - start
        set<Id> opptyIds = new set<Id>();
        set<Id> prodIds = new set<Id>();
        if(opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
            for(Opportunity_Product__c newOpptyProduct : lstNewoppProducts){
                opptyIds.add(newOpptyProduct.opportunityId__c);
                prodIds.add(newOpptyProduct.Product2ID__c);
            }
        }
        else if(opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE){
            for(Opportunity_Product__c newOpptyProduct : OldoppProducts.values()){
                opptyIds.add(newOpptyProduct.opportunityId__c);
                prodIds.add(newOpptyProduct.Product2ID__c);
            }
        }
         
         //SFSE-14825 - Added Cargo_Type__c to below query
         if((opptyIds.size() > 0 && opptyMap.isEmpty()) || opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
             for(Opportunity opty : [SELECT id, Name, Cargo_Type__c,IsClosed, StageName, Approval_Status__c, Requires_Custom_Integration__c, Requires_IT_Integration__c, Must_Go_To_OMEB__c, 
                                     RecordTypeId, RecordType.DeveloperName, TotalOpportunityQuantity, First_Shipment_Date__c, Last_Shipment_Date__c
                                     FROM Opportunity WHERE Id IN: opptyIds]){
                                         opptyMap.put(opty?.id,opty);
                                     }
         }
        
        if((prodIds.size() > 0 && prodMap.isEmpty()) || opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) {
            for(Product2 prod2 : [Select id, Name, Include_in_OMEB_Approvals__c,Portfolio__c,Is_Product_Solution__c from Product2 where id=:prodIds]){
                prodMap.put(prod2?.id,prod2);
            }
        }
        //SFSE-14428 - end
     
        for (Opportunity opptyRecord : opptyMap.values() ){
            if(opptyRecord.Must_Go_To_OMEB__c){
                omebOpptyIds.add(opptyRecord.Id);
            }
        }
        
        if( omebOpptyIds.size() > 0 && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && (opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
             opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE || opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE) ){
                 if(opptyHasPendingApprovalProcesses.isEmpty()){//SFSE-14428
                     opptyHasPendingApprovalProcesses = getPendingApprovalProcesses(omebOpptyIds);
                 }
             }
        
        Set<Id> lChangedOppSet = new Set<Id>();    // Store Ids of Opportunity whose Products are being operated
        Opportunity_Product__c oldOP;
        //Get the logged User in value from the custom setting Validation_Rules_Bypass__c
        Validation_Rules_Bypass__c VRBypass = Validation_Rules_Bypass__c.getInstance(UserInfo.getUserId());
        VRBypassIsActive = VRBypass.Active__c;
        //Get Opp Id on creation, updated and deletion of opportunity Product
        
        // Get list of product oipc code to check for OMEB conditions
        Set<String> setOmebProdOipcCode = new Set<String>();
        for (Products_For_Approval__mdt pf : Products_For_Approval__mdt.getAll().values()){
            if(pf.Active__c){
                setOmebProdOipcCode.add(pf.OIPC_Code__c);
            }
        }
        
        if(trigger.isInsert || trigger.isUpdate){
            for(Opportunity_Product__c lOppProd : lstNewoppProducts){  
                if(OldoppProducts != null){
                    oldOP = OldoppProducts.get(lOppProd.id);
                }
                
                if(lOppProd.isClone()) {
                    isClone = true;
                } else {
                    isClone = false;
                }
                if( Trigger.isUpdate && lOppProd.Schedule_Count__c != oldOP.Schedule_Count__c){
                    oppProductTrigger = FALSE;      
                }
                
                //SFSE-14825
                if(Trigger.isAfter && ((Trigger.isInsert && lOppProd?.Cargo_Type__c != null && lOppProd?.Cargo_Type__c != '') || (Trigger.isUpdate && lOppProd?.Cargo_Type__c != OldoppProducts.get(lOppProd.id)?.Cargo_Type__c ))){
                    setOptyToUpdtCargoType.add(lOppProd?.OpportunityId__c);
                }
                
                if( Trigger.isInsert || (Trigger.isUpdate && lOppProd.Quantity__c != OldoppProducts.get(lOppProd.id).Quantity__c )){
                    lChangedOppSet.add(lOppProd.OpportunityId__c);
                }
                
                if( Trigger.isUpdate && Trigger.isAfter && ( lOppProd.Amend_Expected_FFE__c != null)){
                    lstAmendedFFEProducts.add(lOppProd);
                }
                
                if( Trigger.isUpdate && Trigger.isAfter && lOppProd.Product_Revenue_Per_Unit__c != null  && lOppProd.Product_Revenue_Per_Unit__c  != OldoppProducts.get(lOppProd.id).Product_Revenue_Per_Unit__c ){// SFSE-13638
                    lstAmendedRevenueProducts.add(lOppProd);
                }
                if( Trigger.isUpdate && lOppProd.Country__c != OldoppProducts.get(lOppProd.id).Country__c){
                    lstChangedCountryProduct.add(lOppProd);
                }
                if(lOppProd.OIPC_Product_Code__c != null){
                if( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                    (lOppProd.Annualized_Gross_Profit__c != OldoppProducts.get(lOppProd.id).Annualized_Gross_Profit__c ||
                     (lOppProd.Amend_Expected_FFE__c != null && lOppProd.Amend_Expected_FFE__c != lOppProd.Quantity__c) || 
                     (lOppProd.Amend_Gross_Profit_per_unit__c  != null && lOppProd.Amend_Gross_Profit_per_unit__c  != lOppProd.UnitPrice__c)) && 
                    (Label.Depot_Oipc_Codes.contains(lOppProd.OIPC_Product_Code__c) || Label.Warehousing_nd_Fulfillment_Oipc_Codes.contains(lOppProd.OIPC_Product_Code__c)) && lOppProd.Country__c == OldoppProducts.get(lOppProd.id).Country__c){
                       lstChangedAnnualizedGrossProfitCLProduct.add(lOppProd);
                    }}
                
                Id oppShippingCargoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType ).getRecordTypeId();
                //v6.0 - If Oppty record type = complex and Product family = Ocean and Product Owner Target is changed
                
                if (opptyMap != null && opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE ){
                    
                    if ((opptyMap.get(lOppProd.OpportunityId__c).RecordTypeId ==  oppShippingCargoRecordTypeId || opptyMap.get(lOppProd.OpportunityId__c).RecordType.DeveloperName ==  Label.OppSupplyChainServicesRecType)
                        && lOppProd.Tender_Target__c != OldoppProducts.get(lOppProd.id).Tender_Target__c
                        && lOppProd.Product_Family__c == 'Ocean' && lOppProd.Opt_Out_Auto_Quantity_Scheduling__c == false
                        && opptyMap.get(lOppProd.OpportunityId__c).IsClosed == false
                        && lOppProd.Quantity__c != lOppProd.Tender_Target__c){
                            
                            lstSetQuantityToProductOwnerTarget.add(lOppProd);
                        } 
                    
                    // If Oppty record type = complex and Product family = Ocean and Nominated Quantity__c is changed
                    // Soft deprecating Nominated Quantity - SFSE-10599
                    /*if ((opptyMap.get(lOppProd.OpportunityId__c).RecordTypeId == oppShippingCargoRecordTypeId || opptyMap.get(lOppProd.OpportunityId__c).RecordType.DeveloperName ==  Label.OppSupplyChainServicesRecType)
                        && lOppProd.Nominated_Quantity__c != OldoppProducts.get(lOppProd.id).Nominated_Quantity__c
                        && lOppProd.Product_Family__c == 'Ocean' && lOppProd.Opt_Out_Auto_Quantity_Scheduling__c == false
                        && opptyMap.get(lOppProd.OpportunityId__c).IsClosed == false
                        && lOppProd.Quantity__c != lOppProd.Nominated_Quantity__c){
                            
                            lstSetQuantityToNominatedQuantity.add(lOppProd);
                        } */
                }
                
                //SFSE-4388 -- Update Schedule with updated Gp per unit 
                if( Trigger.isUpdate && Trigger.isAfter && lOppProd.Amend_Gross_Profit_per_unit__c  != null && lOppProd.Amend_Gross_Profit_per_unit__c  != OldoppProducts.get(lOppProd.id).UnitPrice__c ){
                    lstAmendGP.add(lOppProd);
                }
                //12888- Opportunity Event 
                if(opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                   (opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
                   (opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE &&
                   ((lOppProd.Total_Price__c!= null && lOppProd.Total_Price__c!=oldOP.Total_Price__c)
                       ||(lOppProd.Quantity__c!= null && lOppProd.Quantity__c!=oldOP.Quantity__c)  
                       ||(lOppProd.Trade_Route__c!= null && lOppProd.Trade_Route__c!=oldOP.Trade_Route__c)
                       ||(lOppProd.Special_Cargo__c!= null && lOppProd.Special_Cargo__c!=oldOP.Special_Cargo__c) 
                      )))){
                        lstOfOpportunityProductForEvent.add(lOppProd.OpportunityId__c);  
                }
                
                // SFSE-5309
                if(lOppProd.OIPC_Product_Code__c != null){
                if ( ( Trigger.isInsert && setOmebProdOipcCode.contains(lOppProd.OIPC_Product_Code__c))
                    || (Trigger.isUpdate && 
                        (  (lOppProd.Amend_Gross_Profit_per_unit__c  != null && lOppProd.Amend_Gross_Profit_per_unit__c  != oldOP.UnitPrice__c) 
                         || (lOppProd.Amend_Expected_FFE__c != null && lOppProd.Amend_Expected_FFE__c != oldOP.Quantity__c )
                         || ( lOppProd.Total_Price__c != oldOP.Total_Price__c )
                         ||  lOppProd.Annualized_Gross_Profit__c     != oldOP.Annualized_Gross_Profit__c    
                         ||  lOppProd.Product2ID__c != oldOP.Product2ID__c
                         ||  lOppProd.OpportunityId__c != oldOP.OpportunityId__c 
                         ||  lOppProd.Exclude_from_OMEB__c != oldOP.Exclude_from_OMEB__c)
                        && (setOmebProdOipcCode.contains(lOppProd.OIPC_Product_Code__c) || setOmebProdOipcCode.contains(oldOP.OIPC_Product_Code__c))) 
                   ){
                       lstOmebCheck.add(lOppProd);
                   }}
                else if((prodMap.get(lOppProd.Product2ID__c).Name) == Label.OMEBProductFamily){
                        if ( ( Trigger.isInsert )
                    || (Trigger.isUpdate && 
                        (  (lOppProd.Amend_Gross_Profit_per_unit__c  != null && lOppProd.Amend_Gross_Profit_per_unit__c  != oldOP.UnitPrice__c) 
                         || (lOppProd.Amend_Expected_FFE__c != null && lOppProd.Amend_Expected_FFE__c != oldOP.Quantity__c )
                         || ( lOppProd.Total_Price__c != oldOP.Total_Price__c )
                         ||  lOppProd.Annualized_Gross_Profit__c     != oldOP.Annualized_Gross_Profit__c    
                         ||  lOppProd.Product2ID__c != oldOP.Product2ID__c
                         ||  lOppProd.OpportunityId__c != oldOP.OpportunityId__c 
                         ||  lOppProd.Exclude_from_OMEB__c != oldOP.Exclude_from_OMEB__c)
                        ) 
                   ){
                       lstOmebCheck.add(lOppProd);
                   }
                    
                   }

                //10656
                
                if(Trigger.isUpdate && lOppProd != null &&
                   (((prodMap.containsKey(lOppProd.Product2ID__c) && (prodMap.get(lOppProd.Product2ID__c).Portfolio__c) == 'LnS') ||
                     ((prodMap.containsKey(lOppProd.Product2ID__c) && (prodMap.get(lOppProd.Product2ID__c).Portfolio__c) == 'Ocean'))) && 
                    ((OldoppProducts.containsKey(lOppProd.id) && lOppProd.Special_Cargo__c != OldoppProducts.get(lOppProd.id).Special_Cargo__c) ||
                     (OldoppProducts.containsKey(lOppProd.id) && lOppProd.Total_Mandatory_Configuration_Filled__c != OldoppProducts.get(lOppProd.id).Total_Mandatory_Configuration_Filled__c))))
                    
                {
                    oppIAcceptSet.add(lOppProd.OpportunityId__c);
                }
                
                //SFSE-8606
                if( Trigger.isUpdate && lOppProd.Opt_Out_Auto_Quantity_Scheduling__c == true && lOppProd.Opt_Out_Auto_Quantity_Scheduling__c  !=  oldOP.Opt_Out_Auto_Quantity_Scheduling__c ){
                    lstOptOutSelected.add(lOppProd);
                }
                
                //SFSE-9417
                if( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT &&
                   opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  
                   opptyMap.get(lOppProd.OpportunityId__c).Must_Go_To_OMEB__c &&
                   solutionGateOpportunityStages.contains(opptyMap.get(lOppProd.OpportunityId__c).StageName) && prodMap.containskey(lOppProd.Product2ID__c) && prodMap.get(lOppProd.Product2ID__c).Include_in_OMEB_Approvals__c == true){
                       approvedSGOptyQuoteStage.add(lOppProd);
                   }
                
                if( (opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) &&
                   opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE &&  
                   opptyMap.get(lOppProd.OpportunityId__c).Must_Go_To_OMEB__c &&
                   opptyHasPendingApprovalProcesses.contains(lOppProd.OpportunityId__c) && prodMap.containskey(lOppProd.Product2ID__c) && prodMap.get(lOppProd.Product2ID__c).Include_in_OMEB_Approvals__c == true ){
                       OppProdOpptyWithPendingApprovals.add(lOppProd);
                   }
                
                  if( opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER  && ( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT ||  (opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE   &&
                    (lOppProd.Quantity__c != OldoppProducts.get(lOppProd.id).Quantity__c  || lOppProd.Total_Price__c != OldoppProducts.get(lOppProd.id).Total_Price__c  || 
                    lOppProd.Trade_Route__c != OldoppProducts.get(lOppProd.id).Trade_Route__c  || lOppProd.Executing_City_State__c != OldoppProducts.get(lOppProd.id).Executing_City_State__c || lOppProd.isDummyOnOppProduct__c != OldoppProducts.get(lOppProd.id).isDummyOnOppProduct__c ||
                    lOppProd.Special_Cargo__c != OldoppProducts.get(lOppProd.id).Special_Cargo__c) ) ) ) {
                         lstOpptyProductIdtoProcess.add(lOppProd.id);
                    }   
            }
        }
        if(trigger.isDelete){
            for(Opportunity_Product__c lOppProd : OldoppProducts.values())
            {
                lstOfOpportunityProductForEventDel.add(lOppProd.Id);//12888
                lChangedOppSet.add(lOppProd.OpportunityId__c);
                oppIAcceptSet.add(lOppProd.OpportunityId__c);
                if (setOmebProdOipcCode.contains(lOppProd.OIPC_Product_Code__c)){
                    lstOmebCheck.add(lOppProd);
                }
                system.debug('lstOmebCheck@@'+lstOmebCheck);
                //SFSE-9417
                if( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE &&
                   opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                   opptyMap.get(lOppProd.OpportunityId__c).Must_Go_To_OMEB__c &&
                   solutionGateOpportunityStages.contains(opptyMap.get(lOppProd.OpportunityId__c).StageName) && prodMap.containskey(lOppProd.Product2ID__c) && prodMap.get(lOppProd.Product2ID__c).Include_in_OMEB_Approvals__c == true){
                       approvedSGOptyQuoteStage.add(lOppProd);
                   }
                
                if( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE &&
                   opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && 
                   opptyMap.get(lOppProd.OpportunityId__c).Must_Go_To_OMEB__c &&
                   opptyHasPendingApprovalProcesses.contains(lOppProd.OpportunityId__c) && prodMap.containskey(lOppProd.Product2ID__c) && prodMap.get(lOppProd.Product2ID__c).Include_in_OMEB_Approvals__c == true ){
                       OppProdOpptyWithPendingApprovals.add(lOppProd);
                   }
                
                if((opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE) ){
                    lstOpptyProductIdonDelete.add(lOppProd.id);
                }

                //SFSE-14324
                /*List<Recommendation_Condition__c> recomList = [SELECT id,Expected_Value__c from Recommendation_Condition__c where Recommendation_Definition__r.Recommendation_Target__c = 'Opportunity' and Recommendation_Definition__r.IsActive__c=true and Object_Name__c = 'Opportunity_Product__c' and Field_Name__c ='OIPC_Product_Code__c' and Condition__c = 'in'];
                List<String> OceanProductList = new List<String>();
                if(recomList.size()>0){
                    OceanProductList.addAll(recomList[0].Expected_Value__c.split('\\,'));
                }*/
                List<String> OceanProductList = new List<String>();
                OceanProductList.addAll(Label.Ocean_Products_for_Intermodal_Recommendation.split('\\,'));
                
                if(opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && (OceanProductList<>NULL && OceanProductList.size()>0 && OceanProductList.contains(lOppProd.OIPC_Product_Code__c))) {
                    getRelatedRecommendations(opptyIds);
                    system.debug('OppIdWithRecomMap==>'+OppIdWithRecomMap);
                    if(!(oppToUpdateRecomm<> null && oppToUpdateRecomm.containsKey(String.valueof(lOppProd.OpportunityId__c))) &&( OppIdWithRecomMap<> null && OppIdWithRecomMap.containskey(lOppProd.OpportunityId__c))){
                    oppToUpdateRecomm.put(String.valueof(lOppProd.OpportunityId__c),String.valueof(OppIdWithRecomMap.get(lOppProd.OpportunityId__c).Recommendation_Id__c ));
                    }                    
                }
                
                if(opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && lOppProd.OIPC_Product_Code__c == Label.Intermodal_Product_Code) {
                    getRelatedRecommendations(opptyIds);
                    system.debug('OppIdWithRecomMap==>'+OppIdWithRecomMap);
                    if(!(oppToUpdateRecomm<> null && oppToUpdateRecomm.containsKey(String.valueof(lOppProd.OpportunityId__c)) ) &&( OppIdWithRecomMap<> null && OppIdWithRecomMap.containskey(lOppProd.OpportunityId__c))){
                        system.debug('OppIdWithRecomMap.get(lOppProd.OpportunityId__c)==>'+OppIdWithRecomMap.get(lOppProd.OpportunityId__c));
                        oppToUpdateRecomm.put(String.valueof(lOppProd.OpportunityId__c),String.valueof(OppIdWithRecomMap.get(lOppProd.OpportunityId__c).Recommendation_Id__c));
                    
                    }
                    oppRecomUpdateType.add(lOppProd.Id);
                }
                system.debug('oppRecomUpdateType==>'+oppRecomUpdateType);
                system.debug('oppToUpdateRecomm==>'+oppToUpdateRecomm);
                //recommendation-end
                
                //SFSE-14825
                if( opptyProductTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISDELETE && opptyProductTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER){
                    setOptyToUpdtCargoType.add(lOppProd?.OpportunityId__c);
                } 
            }           
        }
        
        //get opportunities and unassigned products and store it in variable
        if(lChangedOppSet.size()>0){
            opportunityMap = getOpportunities(lChangedOppSet, opptyMap);
        }
        
        //store closed opportunity in Map
        if(opportunityMap.size()>0){
            for( Opportunity opp : opportunityMap.values()){
                if(opp.IsClosed==true)
                    closedOppMap.put(opp.Id, opp.IsClosed);                 
            }
        }
    }
    
    //query for getting the opportunities
    public static map<Id,Opportunity> getOpportunities(set<id> opportunityIdSet, map<Id, Opportunity> opptyMap) {
        //map<Id, Opportunity> mapOpptys = new map<Id, Opportunity>([ SELECT id, IsClosed, TotalOpportunityQuantity, First_Shipment_Date__c, Last_Shipment_Date__c,RecordtypeId FROM Opportunity WHERE Id IN: OpportunityIdSet AND (First_Shipment_Date__c !=null OR Last_Shipment_Date__c !=null)]);    //RQ-009201
        map<Id, Opportunity> mapOpptys = new map<Id, Opportunity>();
        for(Id opptyId : opptyMap.keySet()){
            if(opportunityIdSet.contains(opptyId) && (opptyMap.get(opptyId).First_Shipment_Date__c != null || opptyMap.get(opptyId).Last_Shipment_Date__c != null)){
                mapOpptys.put(opptyId, opptyMap.get(opptyId));
            }
        }
        return mapOpptys;
    }
    
    //query to get all pending approval processes related to Opportunity
    public static Set<Id> getPendingApprovalProcesses(Set<Id> omebOpptyIds){
        Set<Id> listOpptyIDWorkItems = new Set<Id>();
        for(Approval_History__c workItem : [select id,name,TargetObjectId__c,TargetObjectId__r.Approval_Status__c 
                                            FROM Approval_History__c 
                                            WHERE TargetObjectId__c in :omebOpptyIds AND 
                                            Status__c ='Pending']){
                                                listOpptyIDWorkItems.add(workItem.TargetObjectId__c);
                                            }
        return listOpptyIDWorkItems;
    }
      
    //SFSE-15073  
    public void getRelatedRecommendations( Set<Id> lstOppty ) {
        Set<String> OppIdSet = new Set<String>();
        for(Id oppId : lstOppty){
            OppIdSet.add(String.valueof(oppId));
        }
        system.debug('fetch of recommendations');
		for(Recommendation__c recom:[SELECT id,Recommendation_Id__c,Is_valid__c,Recommended_To__c from recommendation__c where Recommended_To__c in :OppIdSet and is_valid__c = true]){
			OppIdWithRecomMap.put(id.valueof(recom.Recommended_To__c),recom);
			/* need to check if one opp has multiple recommendations
			if(OppIdWithRecomMap.containsKey(id.valueof(Recommended_To__c))){
				OppIdWithRecomMap.put(id.valueof(Recommended_To__c)).add(recom);
			} else {
				OppIdWithRecomMap.put(id.valueof(Recommended_To__c), new List<Recommendation__c>{recom});
			}*/			
		}
        system.debug('in record selector===>'+OppIdWithRecomMap);
    }

}