/*
* Purpose  : Centralize the record selection process for User object.
*          Defines the methods which iterate and segregate the User records for further use.
* 
* Revision Ref Number   Date            Owner                           Description
* -------- ----------   -----------     -------------------             --------------------------------------------------------
* 19.0     SFSE-111     26-May-2020     manjunath@maersk                   Removed references and logic related to "Expected_FFE_Lead__c" object
* 20.0     SFSE-4383    05-Nov-2020     Neha@TCS                           Added condition for creation of Tender structure for Simple Tender
* 21.0     SFSE-5309    16-Mar-2021     Meghana.Gupta@Ust                  Recalculate Must got to Omeb if Agreement dates or estimated duration is changed
* 22.0     SFSE-5787    12-Apr-2021     Kiran@Maersk                       Removing Territory__c references to deprecate the custom field
* 23.0     SFSE-6108    24-Nov-2021     Rakesh@Maersk                     adding new Tender format in the condition
* 24.0     SFSE-6523    21-Dec-2021     Meghana.Gupta@Ust                   Removing references to lists related to Sales Metric object
* 25.0     SFSE-9017    04-Aug-2022     Meghana.Gupta@Ust                   Create Product Features if Oppty with no features is reopened
* 26.0     SFSE-9341    16/09/2022      Nitin@Maersk                       Created lstOpptyInClosedWonStage to validate mandatory features
* 27.0     SFSE-9417    18-Oct-2022     Kiran@Maersk                        adding oppty into lstOpptyReevaluateOMEB when brand is getting changed
* 28.0     SFSE-9813    02-Jan-2023     Aleena@Maersk                       adding oppty into oppUpdateOMEBKpiId & oppCreateOMEBKpiId when Approval Status is getting changed
* 29.0     SFSE- 10762  23-may-2023     Shilpa@Maersk                       Adding Approval History object in line No 84 to show the correct object 
* 30.0     SFSE-10900   29-May-2023     Samarpreet@maersk.com               Add Logic for to all OpportunityProduct Platform Event on stage Change.
* 31.0     SFSE-9502    01-Jun-2023     Kiran@Maersk                        Adding logic to populate Clone Opportunity Source
* 32.0     SFSE-10859   26-jun-2023     ramya.s@maersk.com                  Hard stop inactive products
* 33.0     SFSE-11594   30-Jun-2023     Sriram@maersk                      Opportunity Auto Renewal 
* 34.0     SFSE-11001   27-July-2023    Ramya.S@maersk.com                 P2 New End Date Passed Logic
* 35.0     SFSE-10610   04-Aug-2023     Shashi@Maersk                      created lstNonOmebOppty & lstOmebOppty to check mandatory fields for opportunities moving beyond designing proposal stage.
* 36.0     SFSE-11844   11-Aug-2023     Vazid@UST                          Added logic to prompt at upon closure of the opportunity if GP is 100k or above
* 36.1      SFSE-11281  15-Aug-2023     Jothsana@Maersk                     OMEB new product Air/LCL & MCS product changes
* 36.2      SFSE-11517  15-Aug-2023     Aleena@Maersk                       OMEB new product Air/LCL & MCS product changes
* 37.0      SFSE-12208  18-Aug-2023     Sriram@Maersk                       Additional Criteria on Agreement Date for Auto-renewal trigger
* 38.0      SFSE-12203  25-Aug-2023     Kiran@Maersk                        OMEB new products Air/LCL & MCS Live issue fixes
* 39.0      SFSE-12560  22-Sep-2023     shashi@Maersk                       Remove Validation for Contract Logistics Financial fields 
* 40.0      SFSE-12320  24-Sep-2023     Shashi@Maersk                       Added auto renew checkbox logic to trigger renewals
* 41.0      SFSE-12888  11-Oct-2023     Aleena@Maersk                       Added logic for Opportunity Platform event
* 42.0      SFSE-12546  16-Oct-2023     Shashi@Maersk                       Added logic for mandatory SP configurations filled
* 43.0      SFSE-12722  20-Oct-2023     Kiran@Maersk                        SOQL101 Error fixes
* 44.0      SFSE-12881  10-Nov-2023     Shashi@Maersk                       Added logic to select clone records
* 45.0      SFSE-13206  24-Nov-2023     Samar@Maersk                        "clone", "renew", "report as lost" or "upgrading to the latest version" for Packaged Solutions
* 46.0      SFSE-13499  19-Dec-2023     Shashi@Maersk                       Added logic to select oppty records to autopopulate "Business Process" field for P2Q journey
* 47.0      SFSE-13322  04-Jan-2024     Jothsana@Maersk                     Remove the logic added for OMEB_Process_KPI__c object
* 48.0      SFSE-13409  18-Jan-2024     Shilpa@Maersk                       Added logic to remove the non P2Q products from opportunity when Customer Journey marked as Instant quote.
* 49.0      SFSE-13852  29-Jan-2024     Avinash@Maersk                      Backend Data updates when Customer Journey field is updated in Oppty Details
* 50.0		SFSE-14043  31-01-2024	    Ramadevi@maersk						Update the Customer Type to BCO when Customer Journey is Instant Quote (Non Negotiable)  
* 51.0		SFSE-12654	01-02-2024		Avinash@Maersk						Clone and auto-renew an opportunity with the latest solution version
* 52.0      SFSE-13802  02-02-2024      Shilpa@maersk                       Added logic to prevention to change customer journey field when file opportunity files is uploaded and Quote is created.
* 53.0		SFSE-14250	16-02-2024		Vinay@Maersk						Added Logic to Nullify Offer Status field when an Opportunity is Clonned.
* 54.0      SFSE-13681  24-02-2024      Shashi@Maersk                       Added logic to select records for End of sales/service conditions.
* 55.0		SFSE-14064	01-03-2024	    Vinay@Maersk						Added new logic for Auto Renewals of Opportunities
* 56.0      SFSE-14525  11-03-2023      BHARTI@MAERSK                       Bug fix for RFQ, triggered code in after insert context as well
* 57.0      SFSe-14196   18-03-2024     Bharti@Maersk                       Added a logic to validate opportunity while updating  auto renew Drop Down
* 58.0      SFSE-14324   21/03/2024     ramadevi@maersk                     Update the Recommendation is the Opportunity is updated
* 59.0      SFSE-13670   22-03-2024     Anjali@Maersk                       Added logic to populate X_Auto_Renew__c and keep Auto_Renew__c in sync
* 60.0		SFSE-14511	 08-04-2024		Avinash@Maersk						Site ID status update
*61.0       SFSE-14619  15-04-2024      Bharti@Maersk                       Added logic in Before Insert and Update to move the workflows/Builder logic into apex .
* 62.0		SFSE-14210	19-04-2024		Jothsana@Maersk						Added logic to call product stamping when agreement dates are changed on opportunity
* 63.0    SFSE-13391  02-May-2024     Shashi@Maersk                       Added logic to unlock opportunity record when opportunity is opened by LiveHelp
* 64.0    SFSE-14519  03-05-2024    Avinash@Maersk                         Allow both the BCO & FFW as Customer Type for P2Q
* 65.0    SFSE-14883  06-05-2024    Avinash@Maersk             P2Q Open Issues
* 66.0    SFSE-15070  30-05-2024    ramadevi@Maersk                         Update the Recommendation status to Obsolete on Opportunity Closed Lost
* 67.0    SFSE-14825  05-06-2024    Avinash@Maersk                         Cargo type on opportunity level
* 68.0    SFSE-15095  03-07-2024    Shilpa@Maersk                          Added logic to validate Estimated Footprint Field for MCL Product.
*/

public class OpportunityRecordSelector implements RecordSelector {
    
    private OpportunityTriggerHandler opptyTriggerHandler;
    
    
    public static Map<Id, Account> RelatedAccountsMap ;
    public static User loggedInUser ;
    
    public Set<Id> accountIdSet = new Set<Id>();
    public List<Opportunity> newOpptyList = new List<Opportunity>();
    public List<Opportunity> updateLinerBrandList = new List<Opportunity>(); // list of opportunity for which we need to set Liner Brand field
    public List<Opportunity> addTeamMemberOpptyList = new List<Opportunity>(); 
    public Map<Id, Opportunity> updateTeamMemberOldMap = new Map<Id, Opportunity>();
    //public List<Opportunity> aflsOwnerUpdateOpptyList = new List<Opportunity>();
    //public List<Opportunity> clonedOpptyList = new List<Opportunity>();    
    public List<Opportunity> oppOwnerUpdateOpptyList = new List<Opportunity>();
    public List<Opportunity> toCloneQuarterlyDealOpptyList = new List<Opportunity>();
    public List<Opportunity> lstComplexOpportunity = new List<Opportunity>();
    public List<Opportunity> lstNonComplexOpportunity = new List<Opportunity>();
    public List<Opportunity> lstParentOpportunity = new List<Opportunity>();
    public List<Opportunity> lstFastTrackOpportunity = new List<Opportunity>();
    public List<Opportunity> lstClonedQuarterlyDeal = new List<Opportunity>();
    public List<Opportunity> lstUnlockRecordApprovalProcess = new List<Opportunity>();  // #RQ-008100
    public List<Opportunity> lstOpptywithDngrGoods = new List<Opportunity>(); //RQ-012233 - Mod-01
    public List<Opportunity> isSalesStageChanged = new List<Opportunity>();//10859
    public List<Id> lstOfOpptyForOpptyEvent = new List<Id>(); //12888
    public map<Id,Opportunity> mapOpptyInQualifyingStage = new map<Id,Opportunity>();
    public List<Id> lstOpptyReevaluateOMEB = new List<Id>(); //SFSE-5309
    public List<Id> lstOppRejectedOMEBIds = new List<Id>(); //SFSE-9268
    public List<Opportunity> lstReopenedOppty = new List<Opportunity>(); //SFSE-9017
    public Boolean oppOwnerUpdated = false;
    public List<Opportunity> lstOpptyInClosedWonStage = new List<Opportunity>();
    public List<Opportunity> lstOpptyInQualifyingStage = new List<Opportunity>();
    public List<Opportunity> lstPEPOpptyHasPendingApprovals = new List<Opportunity>();
    //public List<OpportunityLineItem > oliList = new List<OpportunityLineItem>();
    map<Id,List<OpportunityLineItem>> mapOfOli = new map<Id,List<OpportunityLineItem>>();
    public List<Opportunity> lstOpptyclosedwonLost = new List<Opportunity>();
    public List<Id> lstForOLIEvent = new List<Id>(); //SFSE-9813
    public Map<Id, Id> mapClonedOpptyToSourceId = new Map<Id, Id>(); //SFSE-9502
    public set<id> autoRenewalOpportunities = new set<id>();
    //public List<Opportunity> lstNonOmebOppty = new List<Opportunity>(); //SFSE-10610
    //public List<Opportunity> lstOmebOppty = new List<Opportunity>(); //SFSE-10610
    public List<Opportunity> lstOpptyClosedBy90Days = new List<Opportunity>();//SFSE-11001
    public List<Opportunity> lstOpptyIDClosedBy90Days = new List<Opportunity>(); //SFSE-11001
    public List<Id> lstOfOptyIdsForFBs = new List<Id>();//SFSE-11844 
    public Set<Id> oppIAcceptSet = new Set<Id>();
    public List<Opportunity> checkForAirLclProd = new List<Opportunity>();  //SFSE-11281
    public List<Opportunity> checkForMCSProd = new List<Opportunity>();     //SFSE-11517
    private Map<Id, List<Opportunity_Product__c>> mapOpportunityToAirLclMcsOmebProducts = new Map<Id, List<Opportunity_Product__c>>();
    private List<String> airlclOipcCodes = new List<String>();
    private List<String> mcsOipcCodes = new List<String>();
    public List<Opportunity> lstForOpptyProductUpgrade = new List<Opportunity>(); // SFSE-11466
    public Map<Id,Opportunity> mapValidateRevenueFieldForNonOmeb = new Map<Id,Opportunity>();
    private final String maerskCustomHubOIPCCode = 'P-P0-2kld';
    public Map<Id,Opportunity> checkDestinationCountry = new Map<Id,Opportunity>();
	public List<Opportunity> lstOpptyValidateSP = new List<Opportunity>(); //SFSE-12546
    //public List<Opportunity> lstCloneOppty = new List<Opportunity>();
    //public set<Id> lstOppIdwithInactivePS = new set<Id>(); //SFSE-13206 //Commented as part of SFSE-12654
    public map<Id,Opportunity> opplist = new map<Id,Opportunity>();
    //public List<Id> lstOppIdForRenewalCheck = new List<Id>(); //SFSE-13206 //Commented as part of SFSE-12654
    public list <Opportunity> checkToUpdateOtherClosedReason = new list<Opportunity>();
    public List<Opportunity> lstOpptyPopulateBusinessProcessField = new List<Opportunity>(); //SFSE-13499
    public map<Id,Opportunity> lstOpptyToCheckCustomerJourney = new map<Id,Opportunity>();//SFSE-SFSE-13409
    public list<Opportunity> lstOppCustJrnyFieldstoUpdt = new list<Opportunity>();
    Public map<Id,Opportunity> mapToOppvalidateOpportunityFiles = new map<Id,Opportunity>();
    Public list<Opportunity> listOpportuntiyOnClone = new list<Opportunity>();
   	public List<Opportunity_Product__c> lstOfOMEBoli = new List<Opportunity_Product__c>();
    private Set<String> OMEBproductsOipcCodes = new Set<String>();
    public set<Id> OpptyId = new Set<Id>();
    public List<Opportunity> lstOpptyValidateProductRetirement = new List<Opportunity>(); //SFSE-13681    
    public List<Opportunity> lstOpptyXAutoRenew = new List<Opportunity>();//SFSE-13670
    public list<Opportunity> lstForValidateOpp = new List<Opportunity>();
     public list<Opportunity> lstToUpdateOpp = new List<Opportunity>();//SFSE-14619
    public list<Opportunity> lstToUpdateFirstTimeCloseDate = new List<Opportunity>(); //SFSE-14619
    public list<Opportunity> lstToUpdateOppName = new List<Opportunity>();//SFSE-14619
    public list<Opportunity> lstToUpdateOppOnLeadConversion  = new List<Opportunity>(); //sfse-14619
    public list<opportunity> lstToUpdateSalesQualifieddate = new List<Opportunity>(); //sfse-14619
    public Map<String,List<Opportunity_Product__c>> mapOptyIdToProdWithValidWarehouseSites = new Map<String,List<Opportunity_Product__c>>();//SFSE-14511
    public List<Opportunity> lstOptyWithInvalidWarehouseSites = new List<Opportunity>();//SFSE-14511
    public Map<Id, Opportunity> MapValidateClosedUnlockedOppty = new Map<Id, Opportunity>(); //SFSE-13391
    public List<Opportunity> lstOpptyValidateClosedUnlockedOppty = new List<Opportunity>(); //SFSE-13391
    public List<Opportunity> lstReOpenedUnlockedOpportunity = new List<Opportunity>(); //SFSE-13391
    public list<Opportunity> lstOppValidateFootprintRequirementSqm = new list<Opportunity>();

    //SFSE-14324
    public list<String> oppIdListForRecom = new list<String>();
    public list<String> oppIdListToCheckRecomStatus = new list<String>();
    public list<Opportunity> OppHasRecomm = new list<Opportunity>();

    //SFSE-15070
    public list<Id> oppIdToUpdateStatus = new list<Id>();

    //SFSE-15073 - Customer Insight
    public List<Id> recomList = new List<Id>();
	public Map<id,Map<Id,Recommendation__c>> OppIdWithRecomMap = new Map<id,Map<Id,Recommendation__c>>();
    
    //SFSE-14825
    public Map<Id,Opportunity> mapOppoIdsWithInstantQuote = new Map<Id,Opportunity>();
    
    // constructor 
    public OpportunityRecordSelector( List<Opportunity> lstOppty, map<Id, Opportunity> mapOldOppty, OpportunityTriggerHandler opptyTriggerHandler) {
        
        this.opptyTriggerHandler = opptyTriggerHandler;
        for (Opportunity opptyRecord : lstOppty ){
            accountIdSet.add(opptyRecord.AccountId);
        }
        getRelatedRecords( lstOppty );
        
        selectRecords(lstOppty, mapOldOppty); 
        getRelatedOlis(lstOppty);
        // call method to set all required opportunity lists
        
        getLoggedInUser();
          
    }
    
    // Method to check different conditions and form opportunity lists that will be used in UserTriggerHandler
    public void selectRecords(list<Opportunity> triggerNewOpptyList, map<Id, sObject> mapOldOppty) {
        
                
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType ).getRecordTypeId();
        Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        Id quarterlyDealRecTypeId=System.Label.QuarterlyDealsRecordTypeId;
        
        if (triggerNewOpptyList != null){
            
            //SFSE-9417 Preventing updation of Opportunity liner brand from PEP brand to Non-PEP brand when PEP Opportunity has pending approvals
            List<String> listPEPBrands = new List<String>();
            Set<Id> opptyHasPendingApprovals = new Set<Id>();
            Set<Id> omebOpptyIds = new Set<Id>();
            for (Brand__mdt brand : Brand__mdt.getAll().values()) {
                if(brand.OMEB_Enabled__c){
                    listPEPBrands.add(brand.MasterLabel);
                }
            }
            
            for (Opportunity opptyRecord : triggerNewOpptyList ){

                if(opptyRecord.Must_Go_To_OMEB__c){
                    omebOpptyIds.add(opptyRecord.Id);
                }
            }
            
            //SFSE:14511 - Start
            for (Opportunity opptyRecord : triggerNewOpptyList ){
                if(opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                    Opportunity oldOpptyrec =(Opportunity) mapOldOppty.get(opptyRecord.Id);
                    if(opptyRecord.StageName != oldOpptyrec.StageName && opptyRecord.StageName == 'Closed Won'){
                       lstOptyWithInvalidWarehouseSites.add(opptyRecord);
                    }
                }
            }
            if(!lstOptyWithInvalidWarehouseSites.isEmpty() && lstOptyWithInvalidWarehouseSites.size() > 0){
                for(Opportunity_Product__c opptyProd : [SELECT Id, OpportunityId__c,Is_Invalid_Warehouse_Site__c FROM Opportunity_Product__c WHERE OpportunityId__c in :lstOptyWithInvalidWarehouseSites AND Is_Invalid_Warehouse_Site__c = true]){
                    if(opptyProd != null){
                        if(mapOptyIdToProdWithValidWarehouseSites.containsKey(opptyProd?.OpportunityId__c)){
                        	mapOptyIdToProdWithValidWarehouseSites.get(opptyProd?.OpportunityId__c).add(opptyProd);
                        }
                        else{
                            mapOptyIdToProdWithValidWarehouseSites.put(opptyProd?.OpportunityId__c,new List<Opportunity_Product__c>{opptyProd});
                        }
                    }
                }
            }
            //SFSE:14511 - End
            
            if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE){
                
                 if(omebOpptyIds.size() > 0){
                    for(Approval_History__c appHistory : [select id,name,TargetObjectId__r.name,TargetObjectId__r.Approval_Status__c, TargetObjectId__r.Liner_Brand__c  from Approval_History__c  
                                                          WHERE TargetObjectId__c  In : triggerNewOpptyList AND 
                                                          Status__c = 'Pending']){
                                                              opptyHasPendingApprovals.add(appHistory.TargetObjectId__c);
                                                          }
                } 
                /*for(OpportunityLineItem oli : [select id,name,Opportunity.Id from OpportunityLineItem where Opportunity.Id In : opptyHasPendingApprovals]){
                    oliList.add(oli);
                }*/
                
                for (Products_For_Approval__mdt prodForApproval : Products_For_Approval__mdt.getAll().values()) {
                    if(prodForApproval.Active__c && prodForApproval.Product_Approval_Code__c.startsWith('AL')){
                        airlclOipcCodes.add(prodForApproval.OIPC_Code__c);
                    }else if(prodForApproval.Active__c && prodForApproval.Product_Approval_Code__c.startsWith('MC') && prodForApproval.OIPC_Code__c != maerskCustomHubOIPCCode){
                        mcsOipcCodes.add(prodForApproval.OIPC_Code__c);
                    }
                }
                
                for(Opportunity_Product__c opptyProd : [SELECT Id, OpportunityId__c, Exclude_from_OMEB__c, OIPC_Product_Code__c, Product2ID__r.Name,Product2ID__r.Type_of_Location_Needed__c, Definition_Type__c,
                                                        Product2ID__r.OIPC_Code__c, Product2ID__r.Include_in_OMEB_Approvals__c, Product2ID__r.Family,  Product2ID__r.Family_Code__c ,Solution__r.IsActive,Solution__c
                                                        FROM Opportunity_Product__c 
                                                        WHERE OpportunityId__c in :triggerNewOpptyList AND (Product2ID__r.OIPC_Code__c IN :airlclOipcCodes or Product2ID__r.OIPC_Code__c IN :mcsOipcCodes)]){
                                                            if(mapOpportunityToAirLclMcsOmebProducts.containsKey(opptyProd.OpportunityId__c)){
                                                                mapOpportunityToAirLclMcsOmebProducts.get(opptyProd.OpportunityId__c).add(opptyProd);
                                                            }else{
                                                                mapOpportunityToAirLclMcsOmebProducts.put(opptyProd.OpportunityId__c, new List<Opportunity_Product__c>{opptyProd});
                                                            }
                                                        /* if(Product2ID__r.Type_of_Location_Needed__c != null && Product2ID__r.Type_of_Location_Needed__c == 'Origin & Destination'){
                                                            if(mapOfOliCestinationCountry.containskey(opptyProd.OpportunityId__c)){
                                                                mapOfOliCestinationCountry.get(opptyProd.OpportunityId__c).add(opptyProd);
                                                              
                                                           }
                                                            else{
                                                                mapOfOliCestinationCountry.put(opptyprod.OpportunityId__c,new list<Opportunity_Product__c>{opptyProd}); 
                                                            }
                                                        
                                                        }  */ 
                                                        }
            }
            
            
            // RQ-009420 Start
            Set<String> setCustomerType = new Set<String>();
            for(Project_Template_Mapping__mdt projTemplateRow : Project_Template_Mapping__mdt.getAll().values() ){
                if(projTemplateRow.isQualified__c && projTemplateRow.MasterLabel != null){
                    if(projTemplateRow.MasterLabel.split('_').size() > 1){
                        setCustomerType.add(projTemplateRow.MasterLabel.split('_')[0]);
                    }
                }
            }
            // RQ-009420 End
            
            for (Opportunity opptyRecord : triggerNewOpptyList ){
             //   accountIdSet.add(opptyRecord.AccountId);
                Opportunity oldOppty = new Opportunity();


                if ( opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && opptyRecord.isClone() ){
                    mapClonedOpptyToSourceId.put(opptyRecord.Id, opptyRecord.getCloneSourceId());
                }
                /* Move Process Builder  logic to apex*/ 
                  //SFSE- 14619 Update close Date when opp is created from lead conversion
               if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT
                  && OpptyRecord.Lead_Id__c != null){
                 lstToUpdateOppOnLeadConversion.add(opptyRecord);
                    
                }
                /* Move workflow logic to apex*/ 
                //SFSE- 14619 Set Opp Name when Opp name given as X
                if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT
                  && (OpptyRecord.Name == 'X')){
                  lstToUpdateOppName.add(opptyRecord);
                     
                    
                }
              
                
                //SFSE-13852 : Backend Data updates when Customer Journey field is updated in Oppty Details
                if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE){
                    //Opportunity oldOppRec = (Opportunity)mapOldOppty.get(opptyRecord.Id);
                    if(opptyRecord?.Customer_Journey__c == Label.Instant_Quote
                      && (opptyRecord?.Tender_Submission_Format__c != 'Maersk Line standard format' || opptyRecord?.Customer_Requested_Rate_Structure__c != 'No' ||
                      opptyRecord?.Offer_Type__c != 'Offer containing Standard T&Cs' || opptyRecord?.Cargo_Type__c != 'Dry')){//SFSE-14519 - Removed Customer Type 'BCO' check
                        lstOppCustJrnyFieldstoUpdt.add(opptyRecord);
                    }
                }
                                
                // SFSE-12881 
                /*if (opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && opptyRecord.isClone()){
                    lstCloneOppty.add(opptyRecord);
                 }*/
                

                //SFSE-13499
                if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && ((opptyRecord.Customer_Journey__c != null && opptyRecord.Customer_Journey__c == Label.Instant_Quote) || (opptyRecord.Tender_Submission_Format__c != null && opptyRecord.Tender_Submission_Format__c != 'No Ocean Tender'))) {
                        lstOpptyPopulateBusinessProcessField.add(opptyRecord);
                }
                
                if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                      lstOfOpptyForOpptyEvent.add(opptyRecord.id);  
                }

                //SFSE-13670
                if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT){
                    lstOpptyXAutoRenew.add(opptyRecord);
                    
                }
             
                if((opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT) &&  opptyRecord.RecordTypeId == recordTypeId){
                   // Added a condition in If for RQ-011020 for Tender format as NO Ocean Tender to exclude it from Complex Tender Opp
                    // SFSE-6108 Modified 
                    if(setCustomerType.contains(opptyRecord.Customer_Type__c) && opptyRecord.Tender_Submission_Format__c!='No Ocean Tender' && opptyRecord.Tender_Submission_Format__c!='Long Term Quote'){
                        lstComplexOpportunity.add(opptyRecord); 
                       
                    }
                    // Added a condition in If for RQ-011020 for Tender format as NO Ocean Tender to include it from Complex Tender Opp
                    // SFSE-6108 Modified
                    If((!setCustomerType.contains(opptyRecord.Customer_Type__c)) || (opptyRecord.Tender_Submission_Format__c == 'No Ocean Tender' || opptyRecord.Tender_Submission_Format__c =='Long Term Quote')){
                        lstNonComplexOpportunity.add(opptyRecord);                                
                    }  
                }

                //Update block:-
                if ( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE){
                    oldOppty = (Opportunity) mapOldOppty.get(opptyRecord.Id);
                    
                    //SFSE-14825
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE
                      && opptyRecord?.Customer_Journey__c != oldOppty?.Customer_Journey__c && opptyRecord?.Customer_Journey__c == Label.Instant_Quote){
                        mapOppoIdsWithInstantQuote.put(opptyRecord?.Id,opptyRecord);
                    }
                    
                    // SFSE- 14196 Code to validate the Opportunity to not update Auto Renew Drop Down for specific conditions
                    if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE
                      && (((oldOppty.StageName != opptyRecord.StageName) && 
                         (opptyRecord.StageName != 'Closed Lost' && opptyRecord.StageName != 'Closed Won')&&
                        (opptyRecord.X_Auto_Renew__c != oldOppty.X_Auto_Renew__c && opptyRecord.X_Auto_Renew__c != null)&&
                       (oldOppty.First_Shipment_Date__c == opptyRecord.First_Shipment_Date__c)&&
                         (oldOppty.Last_Shipment_Date__c == opptyRecord.Last_Shipment_Date__c)) ||
                         (opptyRecord.isClosed && opptyRecord.X_Auto_Renew__c != oldOppty.X_Auto_Renew__c && oldOppty.IsClosed == opptyRecord.IsClosed))){
                         
                        lstForValidateOpp.add(opptyRecord);

                    }
                    /* Move workflow logic to apex*/ 
                    //SFSE- 14619  when opp is updated to closed lost/won then update close date. 
                    if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE
                        &&(oldOppty.StageName != opptyRecord.StageName)
                        && (opptyRecord.StageName == System.Label.close_won || opptyRecord.StageName == System.Label.Closed_lost)
                        
                       ){
                           lstToUpdateOpp.add(opptyRecord);
                           
                       }
                      /* Move workflow logic to apex*/ 
                    //SFSE- 14619 when First time Opp. is move to closed lost/Won populate first time close date & when Opp move to any stage except closed Lost update sales qualified date. 
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOppty.StageName != opptyRecord.StageName){
                       if (opptyRecord.IsClosed && opptyRecord.First_Time_Closed_Date__c == null)
                    {
                                                
                        lstToUpdateFirstTimeCloseDate.add(opptyRecord); 
                    } if(oldOppty.StageName == System.Label.Identifying && opptyRecord.StageName != System.Label.Closed_lost && opptyRecord.Sales_Qualified_Date__c == null){
                            lstToUpdateSalesQualifieddate.add(opptyRecord);
                        
                    }
                        
                    }
                    
                    //SFSE-13670 & SFSE- 14196
                    if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE 
                     && (((!opptyRecord.isClosed && oldOppty.First_Shipment_Date__c != opptyRecord.First_Shipment_Date__c && oldOppty.First_Time_Closed_Date__c == null ) || 
                      (!opptyRecord.isClosed && oldOppty.Last_Shipment_Date__c != opptyRecord.Last_Shipment_Date__c && oldOppty.First_Time_Closed_Date__c == null)) ||
                      (oldOppty.IsClosed && !opptyRecord.isClosed && oldOppty.X_Auto_Renew__c == null)||
                      (!oldOppty.isClosed && opptyRecord.isClosed && (oldOppty.X_Auto_Renew__c!=opptyRecord.X_Auto_Renew__c)))
                       ){
                                lstOpptyXAutoRenew.add(opptyRecord);
                            }
                            
                  
                    //Opportunity Auto Renewal START
                    
                    list<string> recordtypes = General_Key_Value_Configurations__mdt.getInstance('Opportunity_AutoRenewal_Type_RecordType').Second_Field_Value__c.split(',');
                    list<id> recTypeIDs = new list<id>();
                    for(string rec:recordtypes){
                        recTypeIDs.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(rec).getRecordTypeId());
                    }
                    list<String> excludedStages = General_Key_Value_Configurations__mdt.getInstance('Opportunity_Excluded_Stage_Reasons').First_Field_Value__c.split(',');                    
  //SFSE-14064 - Auto Renew of Opportunity happens when Auto Renew is Checked & When Opty is Closed and Opty Closed reason not one among (System - End Date Passed,Rejected - Should not have been auto-renewed,Rejected - Duplicate)
      //Opty Record type is one among(Supply Chain Services,Shipping & Cargo Services,Quarterly NAC & BCO Deals)  
                    if(opptyRecord.Auto_Renew__c && recTypeIDs.contains(opptyRecord.RecordTypeId) && opptyRecord.First_Time_Closed_Date__c != null && oldOppty.First_Time_Closed_Date__c == null
                       && !oldOppty.isClosed && opptyRecord.isClosed && !excludedStages.contains(opptyRecord.Reason_For_Close__c)
                       && ((opptyRecord.Account_Owner_Region__c != null && General_Key_Value_Configurations__mdt.getInstance('Opportunity_AutoRenewal_Regions').First_Field_Value__c.containsIgnoreCase(opptyRecord.Account_Owner_Region__c))
                       || (opptyRecord.Account_Owner_Region__c == null && RelatedAccountsMap.get(opptyRecord.AccountId).MSL_Account_Owner__r.Region__c != null && General_Key_Value_Configurations__mdt.getInstance('Opportunity_AutoRenewal_Regions').First_Field_Value__c.containsIgnoreCase(RelatedAccountsMap.get(opptyRecord.AccountId).MSL_Account_Owner__r.Region__c))
                       || (opptyRecord.Account_Owner_Region__c == null && RelatedAccountsMap.get(opptyRecord.AccountId).MSL_Account_Owner__r.Region__c == null))
                       && General_Key_Value_Configurations__mdt.getInstance('Activate_Opportunity_AutoRenewal').First_Field_Value__c == 'Active')
                    {
                       
                       autoRenewalOpportunities.add(opptyRecord.id);
                      
                    }
                        
                    //Opportunity Auto Renewal END
                    
                    //12888- Opportunity Platform Event
                    
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER &&  (
                    opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE &&(
                        (opptyRecord.StageName!= null && opptyRecord.StageName!=oldOppty.StageName)
                    ||(opptyRecord.Liner_Brand__c!= null && opptyRecord.Liner_Brand__c!=oldOppty.Liner_Brand__c)  
                    ||(opptyRecord.OwnerId!= null && opptyRecord.OwnerId!=oldOppty.OwnerId)
                    ||(opptyRecord.AccountId != null && opptyRecord.AccountId != oldOppty.AccountId)
                    ||(opptyRecord.First_Shipment_Date__c!= null && opptyRecord.First_Shipment_Date__c!=oldOppty.First_Shipment_Date__c) 
                    ||(opptyRecord.Last_Shipment_Date__c!= null && opptyRecord.Last_Shipment_Date__c!=oldOppty.Last_Shipment_Date__c) 
                    ||(opptyRecord.IsDummyOnOpportunity__c!= null && opptyRecord.IsDummyOnOpportunity__c!=oldOppty.IsDummyOnOpportunity__c)    

                    ))){
                        lstOfOpptyForOpptyEvent.add(opptyRecord.id);  
                    }
                    
                    
                    if(oldOppty.Opportunity_contains_Dangerous_Goods__c != Label.Dangerous_Goods_Team_Support && opptyRecord.Opportunity_contains_Dangerous_Goods__c == Label.Dangerous_Goods_Team_Support && opptyRecord.RecordType.DeveloperName !=  Label.OppSupplyChainServicesRecType ) //RQ-012233 - Mod-02 - Start
                        lstOpptywithDngrGoods.add(opptyRecord);  //RQ-012233 - Mod-02 - End
                    
                    
                    
                    if (oldOppty.First_Shipment_Date__c != opptyRecord.First_Shipment_Date__c || oldOppty.Last_Shipment_Date__c != opptyRecord.Last_Shipment_Date__c || oldOppty.Estimated_Agreement_Duration__c != opptyRecord.Estimated_Agreement_Duration__c || oldOppty.Liner_Brand__c != opptyRecord.Liner_Brand__c){
                        lstOpptyReevaluateOMEB.add(opptyRecord.Id);
                    }
                    
                    if( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE &&
                        oldOppty.Liner_Brand__c != opptyRecord.Liner_Brand__c && opptyHasPendingApprovals.contains(opptyRecord.Id) ){
                        
                        lstPEPOpptyHasPendingApprovals.add(opptyRecord);
                        
                    }
                    
                    if( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.Count_Opp_Product__c != oldOppty.Count_Opp_Product__c){
                        
                        opplist.put(opptyRecord.id,opptyRecord);  
                    }

                    //SFSE-9268
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyRecord.Approval_Status__c != null && (opptyRecord.Approval_Status__c).containsIgnoreCase('Rejected')){
                        lstOppRejectedOMEBIds.add(opptyRecord.Id);
                    }
                    
                    //
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && opptyRecord.StageName != null && opptyRecord.StageName !=oldOppty.StageName && (opptyRecord.StageName == 'Closed Won' || opptyRecord.StageName == 'Closed Lost')){
                        lstOpptyclosedwonLost.add(opptyRecord);
                    }
                    
                    
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE  && opptyRecord.StageName != null && opptyRecord.StageName != oldOppty.StageName /*&& (oldOppty.StageName == System.Label.Identifying || oldOppty.StageName == System.Label.Qualifying || oldOppty.StageName == System.Label.Designing_Proposal)*/ //Removed as part of SFSE-14883
                    && (opptyRecord.StageName == System.Label.Quoting || opptyRecord.StageName == System.Label.Negotiating || opptyRecord.StageName == System.Label.close_won) && opptyRecord.Tender_Submission_Format__c != 'No Ocean Tender'&& opptyRecord.Tender_Submission_Format__c != 'Long Term Quote'){
                        //Id scRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType).getRecordTypeId();
                        //if(recordTypeId == opptyRecord.RecordTypeId){ //if oppty is Shipping & Cargo RT
                            mapOpptyInQualifyingStage.put(opptyRecord.Id,opptyRecord);    
                        //}
                    }
                    //SFSE-13391
                    if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOppty.isClosed == true && opptyRecord.isClosed == false && oldOppty.Record_Locked__c == true){
                        lstReopenedOppty.add(opptyRecord);
                    }
                    
                   
                    //SFSE-10656
                    
                    if(opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER && 
                    ((oldOppty.Estimated_Ocean_FFE__c != opptyRecord.Estimated_Ocean_FFE__c && opptyRecord.Estimated_Ocean_FFE__c > 0) ||
                        (oldOppty.Estimated_L_S_Product_Gross_Profit1__c != opptyRecord.Estimated_L_S_Product_Gross_Profit1__c)||
                        (oldOppty.Offer_Type__c != opptyRecord.Offer_Type__c) ||
                        (oldOppty.Cargo_Type__c != opptyRecord.Cargo_Type__c) || 
                        (oldOppty.Must_Go_To_OMEB__c != opptyRecord.Must_Go_To_OMEB__c) || 
                        (oldOppty.Approval_Required__c != opptyRecord.Approval_Required__c)||
                        (oldOppty.Tender_Submission_Format__c != opptyRecord.Tender_Submission_Format__c) || 
                        (opptyRecord.RecordTypeId != oldOppty.RecordTypeId) || 
                        (oldOppty.First_Shipment_Date__c != opptyRecord.First_Shipment_Date__c)||
                        (oldOppty.Last_Shipment_Date__c != opptyRecord.Last_Shipment_Date__c)||
                        (oldOppty.Count_Of_Total_Mandatory_Config__c != opptyRecord.Count_Of_Total_Mandatory_Config__c))){
                            
                            oppIAcceptSet.add(opptyRecord.Id);   
                        }
                    /*//SFSE-10610 
                    if(opptyRecord.StageName != null && opptyRecord.StageName != oldOppty.StageName && (oldOppty.StageName == System.Label.Identifying || oldOppty.StageName == System.Label.Qualifying || oldOppty.StageName == System.Label.Designing_Proposal || oldOppty.StageName == System.Label.Quoting || oldOppty.StageName == System.Label.Negotiating || oldOppty.StageName == System.Label.Closed_lost) 
                    && (opptyRecord.StageName == System.Label.Quoting || opptyRecord.StageName == System.Label.Negotiating || opptyRecord.StageName == System.Label.close_won) && opptyRecord.Approval_Required__c=='No'){
                        lstNonOmebOppty.add(opptyRecord);
                    }
                    if(opptyRecord.StageName != null && opptyRecord.StageName != oldOppty.StageName && (oldOppty.StageName == System.Label.Quoting || oldOppty.StageName == System.Label.Negotiating || oldOppty.StageName == System.Label.Closed_lost) 
                    && (opptyRecord.StageName == System.Label.Quoting || opptyRecord.StageName == System.Label.Negotiating || opptyRecord.StageName == System.Label.close_won) && opptyRecord.Approval_Required__c=='Yes'){
                        lstOmebOppty.add(opptyRecord);
                    }*/ 
                    
                    //SFSE-12546 
                    if (opptyRecord.StageName != null && opptyRecord.StageName != oldOppty.StageName && (oldOppty.StageName == System.Label.Identifying || oldOppty.StageName == System.Label.Qualifying || oldOppty.StageName == System.Label.Designing_Proposal || 
                        oldOppty.StageName == System.Label.Quoting || oldOppty.StageName == System.Label.Negotiating || oldOppty.StageName == System.Label.Closed_lost) 
                        && (opptyRecord.StageName == System.Label.Quoting || opptyRecord.StageName == System.Label.Negotiating || opptyRecord.StageName == System.Label.close_won)) {
                        lstOpptyValidateSP.add(opptyRecord);
                    }
                    
                  //SFSE-13499
                    if (opptyRecord.Customer_Journey__c != oldOppty.Customer_Journey__c || opptyRecord.Tender_Submission_Format__c != oldOppty.Tender_Submission_Format__c ||
                       (((oldOppty.IsClosed && !opptyRecord.IsClosed) || (!oldOppty.IsDummyOnOpportunity__c && opptyRecord.IsDummyOnOpportunity__c)) && oldOppty.Business_Process__c == null)) {
                        lstOpptyPopulateBusinessProcessField.add(opptyRecord);

                    }

                    newOpptyList.add(opptyRecord);  
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.StageName !=oldOppty.StageName && opptyRecord.Other_Reason_For_Close__c !=null && oldOppty.StageName == System.Label.Closed_lost){
                        checkToUpdateOtherClosedReason.add(opptyRecord);
                    }
                    
                    // If Opportunity Liner brand is null on creation or updation
                    if ( opptyRecord.Liner_Brand__c == null ){          
                        updateLinerBrandList.add(opptyRecord); // if liner brand is null then set liner brand to logged in user's brand
                    }  
                    
                    // On creation of Opportunity or Opportunity owner is updated and the new owner is not the creator of opportunity then we add new owner to Opp Team
                    if ( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || (opptyRecord.OwnerId != opptyRecord.CreatedById && ( opptyRecord.OwnerId != oldOppty.OwnerId || ScheduleOppProducts.OpportunityfromClone == true))){
                        if(opptyRecord.Opportunity_contains_Dangerous_Goods__c == Label.Dangerous_Goods_Team_Support && opptyRecord.RecordType.DeveloperName !=  Label.OppSupplyChainServicesRecType ){   //RQ-012233 - Mod-03 - Start
                            lstOpptywithDngrGoods.add(opptyRecord);
                        }                                                    //RQ-012233 - Mod-03 - End
                        addTeamMemberOpptyList.add(opptyRecord);
                        if ( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE )
                            updateTeamMemberOldMap.put(opptyRecord.id, oldOppty);               
                    }
                    
                    
                    
                    // If opportunity owner is changed then the corresponding AFLS Quote Owners should be changed
                    if ( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.OwnerId != oldOppty.OwnerId && opptyRecord.RecordType.DeveloperName !=  Label.OppSupplyChainServicesRecType ){
                        oppOwnerUpdateOpptyList.add(opptyRecord);
                    }
                    if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.StageName != oldOppty.StageName){
                        isSalesStageChanged.add(opptyRecord);
                    }
                    //#RQ-008175 - To create Project templates, milestones and tasks when a tender opportunity is created
                    if((opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) && opptyRecord.RecordTypeId == recordTypeId) {
                        lstFastTrackOpportunity.add(opptyRecord);
                    }
                    
                
                    if((opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
                        (opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && (opptyRecord.OwnerId != oldOppty.OwnerId)) && opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISAFTER)) {
                            accountIdSet.add(opptyRecord.AccountId);
                            oppOwnerUpdated = true;
                        }
                    
                    //#RQ-008622: Start
                    if((opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT || 
                        (opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE &&
                        (opptyRecord.Customer_Type__c != oldOppty.Customer_Type__c || 
                         opptyRecord.Tender_Submission_Format__c != oldOppty.Tender_Submission_Format__c ||
                        opptyRecord.Customer_Requested_Rate_Structure__c != oldOppty.Customer_Requested_Rate_Structure__c
                        ))) && 
                    opptyRecord.RecordTypeId == recordTypeId){                 
                        
                        
                        // Added a condition in If for RQ-011020 for Tender format as NO Ocean Tender to exclude it from Complex Tender Opp
                        // SFSE-6108 Modified 
                        if(setCustomerType.contains(opptyRecord.Customer_Type__c) && (oldOppty.Tender_type__c != 'Complex'|| !setCustomerType.contains(oldOppty.Customer_Type__c)) && opptyRecord.Tender_Submission_Format__c!='No Ocean Tender' && opptyRecord.Tender_Submission_Format__c!='Long Term Quote'){
                            lstComplexOpportunity.add(opptyRecord);                                
                           
                        }
                        // Added a condition in If for RQ-011020 for Tender format as NO Ocean Tender to include it from Complex Tender Opp
                        // SFSE-6108 Modified
                        If((oldOppty.Tender_type__c == 'Complex' && !setCustomerType.contains(opptyRecord.Customer_Type__c)) || (opptyRecord.Tender_Submission_Format__c == 'No Ocean Tender' || opptyRecord.Tender_Submission_Format__c =='Long Term Quote')){
                            lstNonComplexOpportunity.add(opptyRecord);                                
                        }
                    }
                    //#RQ-008622: Endlast
                    
                    if ( opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.Submitted_For_approval__c == true ){
                        lstUnlockRecordApprovalProcess.add(opptyRecord);
                        
                    } 
                    
                    if (opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.Parent_Opportunity__c != oldOppty.Parent_Opportunity__c && opptyRecord.Parent_Opportunity__c != null){
                        
                        lstParentOpportunity.add(opptyRecord);
                    }
                    
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISAFTER &&
                    opptyRecord.StageName != oldOppty.StageName ){
                        lstForOLIEvent.add(opptyRecord.Id);
                    }
                    
                    //SFSE-11844 : Get the list of opportunity Ids upon closure of the opportunity if GP is 100k or above. 
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISAFTER &&
                    opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName == Label.close_won && opptyRecord.Estimated_Total_Opp_Gross_Profit_Cus__c >= Integer.valueOf(Label.Opportunity_Total_GP)){
                        lstOfOptyIdsForFBs.add(opptyRecord.Id);
                    }
                    
                    //SFSE-11281 Air/LCL product OMEB
                    Date omebNewProductsGoLiveDate = Date.newInstance(2023, 8, 19);
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE &&
                    (opptyRecord.StageName != oldOppty.StageName || opptyRecord.Approval_Status__c != oldOppty.Approval_Status__c) && opptyRecord.StageName != Label.Closed_lost && 
                    (opptyRecord.Requires_IT_Integration__c == '' || opptyRecord.Requires_IT_Integration__c == null) && mapOpportunityToAirLclMcsOmebProducts.containsKey(opptyRecord.Id))
                     {
                        for(Opportunity_Product__c opRec : mapOpportunityToAirLclMcsOmebProducts.get(opptyRecord.Id)){
                            if(airlclOipcCodes.contains(opRec.OIPC_Product_Code__c)){
                                checkForAirLclProd.add(opptyRecord);
                            }
                        }
                    }

                    //SFSE-11517 MCS product OMEB
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && 
                    (((opptyRecord.Requires_Custom_Integration__c == '' || opptyRecord.Requires_Custom_Integration__c == null) &&
                    (opptyRecord.StageName != oldOppty.StageName || opptyRecord.Approval_Status__c != oldOppty.Approval_Status__c) && opptyRecord.StageName != Label.Closed_lost && 
                    opptyRecord.CreatedDate >= omebNewProductsGoLiveDate) || (opptyRecord.Requires_Custom_Integration__c == null && oldOppty.Requires_Custom_Integration__c != null)) && mapOpportunityToAirLclMcsOmebProducts.containsKey(opptyRecord.Id)){
                        for(Opportunity_Product__c opRec : mapOpportunityToAirLclMcsOmebProducts.get(opptyRecord.Id)){
                            if(mcsOipcCodes.contains(opRec.OIPC_Product_Code__c)){
                                checkForMCSProd.add(opptyRecord);
                            }
                        }
                    }
                    //SFSE-11466
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISAFTER && opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName != Label.Closed_lost &&
                    opptyRecord.First_Time_Closed_Date__c == null && opptyRecord.Approval_Required__c =='No' ){
                        lstForOpptyProductUpgrade.add(opptyRecord);
                    }
                    
                    //SFSE-15095
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE  && opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName != Label.Closed_lost && 
                    opptyRecord.First_Time_Closed_Date__c == null){
                        lstOppValidateFootprintRequirementSqm.add(opptyRecord);
                        System.debug(lstOppValidateFootprintRequirementSqm);
                    }
                    
                    
                    
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName != Label.Closed_lost 
                    && opptyRecord.First_Time_Closed_Date__c == null){   
                        checkDestinationCountry.put(opptyRecord.Id,opptyRecord);  
                    }
                    //SFSE-10439
                   if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyRecord.Customer_Journey__c != oldOppty.Customer_Journey__c && (opptyRecord.StageName == 'Identifying' || opptyRecord.StageName == 'Qualifying' || opptyRecord.StageName == 'Designing Proposal') && (oldOppty.Customer_Journey__c == Label.As_is_Journey || oldOppty.Customer_Journey__c == null) && opptyRecord.Customer_Journey__c==Label.Instant_Quote)
                    {
                        lstOpptyToCheckCustomerJourney.put(opptyRecord.id,opptyRecord);
                    }

                    //SFSE-13790
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && (opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName != Label.Closed_lost) && (((opptyRecord.StageName == Label.Negotiating || opptyRecord.StageName == Label.Opportunity_Closed_Won || oldOppty.StageName == Label.Opportunity_Closed_Won || oldOppty.StageName == Label.Closed_lost 
                       )&& opptyRecord.Approval_Required__c =='yes' ) || opptyRecord.Approval_Required__c =='No')){
                        mapValidateRevenueFieldForNonOmeb.put(opptyRecord.Id,opptyRecord);
                    }
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE &&  (opptyRecord.StageName != 'Negotiating' && opptyRecord.StageName != 'Quoting' && opptyRecord.StageName != 'Closed Won' && opptyRecord.StageName !='Closed Lost')
                       && (((oldOppty.Customer_Journey__c == null || oldOppty.Customer_Journey__c == Label.As_is_Journey)
                       && opptyRecord.Customer_Journey__c==Label.Instant_Quote ) || oldOppty.Customer_Journey__c == Label.Instant_Quote && opptyRecord.Customer_Journey__c==Label.As_is_Journey)){
                       mapToOppvalidateOpportunityFiles.put(opptyRecord.Id,opptyRecord); 
                }                         
                    
                    //SFSE-13681 
                    if(opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && (opptyRecord.StageName != null && oldOppty.StageName != opptyRecord.StageName && (oldOppty.Approval_Status__c == null || !oldOppty.Approval_Status__c.containsIgnoreCase('Submitted'))) || (oldOppty.Last_Shipment_Date__c != opptyRecord.Last_Shipment_Date__c)){
                        lstOpptyValidateProductRetirement.add(opptyRecord);
                    }                       
                  
                    //SFSE-14324                    
                    List<String> oppType = Label.IMCH_Product_Opportunity_Stages.split('\\,');
					List<String> oppTypeCustomerInsight = new List<String>();
					oppTypeCustomerInsight.add('Renewal');
					oppTypeCustomerInsight.add('Additional Business');
					
                    system.debug('oppType==>'+oppType);
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE) {
						
						//Rule Based Recommendation Changes
                        if((opptyRecord.AccountId != oldOppty.AccountId || (opptyRecord.Customer_Journey__c != oldOppty.Customer_Journey__c && oldOppty.Customer_Journey__c <> 'Instant Quote (Non Negotiable)')||(opptyRecord.Customer_Type__c != oldOppty.Customer_Type__c && oldOppty.Customer_Type__c == 'BCO') || (oppType.contains(oldOppty.Type) && opptyRecord.Type != oldOppty.Type && !oppType.contains(opptyRecord.Type)))){
							//SFSE-15073 - customer Insight
                            if(OppIdWithRecomMap == NULL || (OppIdWithRecomMap <> NULL && OppIdWithRecomMap.size()==0) ){
                                getRelatedRecommendations(triggerNewOpptyList);
                            }
                            if(OppIdWithRecomMap.containskey(opptyRecord.id) && OppIdWithRecomMap.get(opptyRecord.id).containsKey(System.Label.Intermodal_Rule_Recommendation_Id)){
								//add the Opp Id to the List 
								//oppIdListForRecom.add(String.valueof(opptyRecord.Id));
								recomList.add(OppIdWithRecomMap.get(opptyRecord.id).get(System.Label.Intermodal_Rule_Recommendation_Id).Id);
							}                            
                        }
						
						//Customer Insight based Recommendation
						if(opptyRecord.AccountId != oldOppty.AccountId || (opptyRecord.Customer_Journey__c != oldOppty.Customer_Journey__c && oldOppty.Customer_Journey__c <> 'Instant Quote (Non Negotiable)') || (oppTypeCustomerInsight.contains(oldOppty.Type) && opptyRecord.Type != oldOppty.Type && !oppTypeCustomerInsight.contains(opptyRecord.Type))){
							//SFSE-15073 - customer Insight
                             if(OppIdWithRecomMap == NULL || (OppIdWithRecomMap <> NULL && OppIdWithRecomMap.size()==0) ){
                                getRelatedRecommendations(triggerNewOpptyList);
                            }
                            if(OppIdWithRecomMap.containskey(opptyRecord.id) && OppIdWithRecomMap.get(opptyRecord.id).containsKey(System.Label.Intermodal_Customer_Insight_Rule_Id)){
								//oppIdListForRecom.add(String.valueof(opptyRecord.Id));
								recomList.add(OppIdWithRecomMap.get(opptyRecord.id).get(System.Label.Intermodal_Customer_Insight_Rule_Id).Id);
							}							
						}

                        //SFSE-15070
                        if(opptyRecord.StageName != oldOppty.StageName && opptyRecord.StageName == System.Label.Closed_lost ) {
                            //oppIdToUpdateStatus.add(String.valueof(opptyRecord.Id));
                            if(OppIdWithRecomMap == NULL || (OppIdWithRecomMap <> NULL && OppIdWithRecomMap.size()==0) ){
                                getRelatedRecommendations(triggerNewOpptyList);
                                system.debug('OppIdWithRecomMap==>'+OppIdWithRecomMap);
                            }
                            if(OppIdWithRecomMap.containskey(opptyRecord.id) && OppIdWithRecomMap.get(opptyRecord.id) <> NULL){
                                for(id recomId : OppIdWithRecomMap.get(opptyRecord.id).Keyset()){
                                    oppIdToUpdateStatus.add(OppIdWithRecomMap.get(opptyRecord.id).get(recomId).Id);
                                }
                            }                            
                        }
                        system.debug('recomList ####==>'+recomList);
                    }
                    
                    if(opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && opptyRecord.StageName != oldOppty.StageName && (opptyRecord.StageName == System.Label.Close_won)){
                        //Check if recommendation exist for this Opportunity
                        Boolean hasPermission = FeatureManagement.checkPermission('Recommedation_Component_Permission');
                        if(hasPermission){
                           oppIdListToCheckRecomStatus.add(String.valueof(opptyRecord.Id));
                            OppHasRecomm.add(opptyRecord); 
                        }else {
                            oppIdListForRecom.add(String.valueof(opptyRecord.Id));
                        }
                    }
                    //end                      
                    
                    //SFSE-13391 
                    if(opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOppty.IsClosed == true && opptyRecord.IsClosed == true && oldOppty.Record_Locked__c == false){
                        lstOpptyValidateClosedUnlockedOppty.add(opptyRecord);
                        MapValidateClosedUnlockedOppty.put(opptyRecord.Id,oldOppty);
                    }
                    //SFSE-13391 
                    if(opptyTriggerHandler.trigType ==TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISUPDATE && oldOppty.IsClosed == true && opptyRecord.IsClosed == false && oldOppty.Record_Locked__c == false){ 
                        lstReOpenedUnlockedOpportunity.add(opptyRecord);
                    } 
                }
                
                
                //SFSE-14250 For Cloned Opportunities, Nullify Offer Status Field.
                if (opptyTriggerHandler.trigType == TriggerHandler.TriggerType.ISBEFORE && opptyTriggerHandler.trigEvent == TriggerHandler.TriggerEvent.ISINSERT && opptyRecord.isClone()){
                    listOpportuntiyOnClone.add(opptyRecord);
                    
      				}

            }
        }
    }
    public void getRelatedRecords( list<Opportunity> newOpptyList ) {
        
        // v3.0 start
        boolean refetchMap = false;
        
        if ( RelatedAccountsMap == null){
            refetchMap = true;
        } else if(! RelatedAccountsMap.keySet().containsAll(accountIdSet)){
            refetchMap = true;
        }
        // v3.0 end
       
        //fetch related accounts only once for a trigger transaction
        if ( refetchMap ){
            
            // get Account Details in a map to retrieve brand account owner
            RelatedAccountsMap = new Map< Id, Account >( [SELECT Id, name, RecordTypeId, MSL_Account_Owner__c, MSL_Account_Owner__r.isActive,
                                                          SEA_Account_Owner__c, SEA_Account_Owner__r.isActive,
                                                          MCC_Account_Owner__c, MCC_Account_Owner__r.isActive,
                                                          MLL_Account_Owner__c, MLL_Account_Owner__r.isActive,
                                                          Seago_Account_Owner__c, Seago_Account_Owner__r.isActive,MSL_Account_Owner__r.Region__c
                                                          FROM Account 
                                                          WHERE Id IN :accountIdSet] );  
            
        }
    }
    
    public void getRelatedOlis( list<Opportunity> newOpptyList ) {
        for (Products_For_Approval__mdt prodForApproval : Products_For_Approval__mdt.getAll().values()) {
                    if(prodForApproval.Active__c){
                        OMEBproductsOipcCodes.add(prodForApproval.OIPC_Code__c);
                    }
                }
        if(!lstOpptyReevaluateOMEB.isEmpty() && !OMEBproductsOipcCodes.isEmpty()){
            lstOfOMEBoli = new List<Opportunity_Product__c>([select Id,OpportunityId__c, Exclude_from_OMEB__c, OIPC_Product_Code__c,
                                                             Product2ID__r.name,Product2ID__r.Type_of_Location_Needed__c, Definition_Type__c,
                                                             Product2ID__r.OIPC_Code__c,Product2ID__r.Include_in_OMEB_Approvals__c,
                                                             Product2ID__r.Family, Product2ID__r.Family_Code__c from Opportunity_Product__c
                                                             where OpportunityId__c in: lstOpptyReevaluateOMEB and Product2ID__r.OIPC_Code__c in: OMEBproductsOipcCodes 
           ]);
        }
    }
    
    public void getLoggedInUser() {
        
        if (loggedInUser == null){
            // get logged in user's details
            loggedInUser = [ SELECT id, Liner_Brand__c, MLL__c FROM User WHERE Id = :UserInfo.getUserId() ];
        }
    }

    //SFSE-15073
    public void getRelatedRecommendations( list<Opportunity> lstOppty ) {
        List<String> newOpptyIdList = new List<String>();
        for(Opportunity opp : lstOppty){
            newOpptyIdList.add(String.valueof(opp.id));
        }
		for(Recommendation__c recom:[SELECT id,Recommendation_Id__c,Is_valid__c,Recommended_To__c from recommendation__c where Recommended_To__c in :newOpptyIdList and is_valid__c = true]){
			if(OppIdWithRecomMap.containsKey(id.valueof(recom.Recommended_To__c))){
                OppIdWithRecomMap.get(id.valueof(recom.Recommended_To__c)).put(id.valueof(recom.Recommendation_Id__c),recom);
            } else {
                OppIdWithRecomMap.put(id.valueof(recom.Recommended_To__c),new Map<Id,Recommendation__C>());
                OppIdWithRecomMap.get(id.valueof(recom.Recommended_To__c)).put(id.valueof(recom.Recommendation_Id__c),recom);
            }
            //OppIdWithRecomMap.put(id.valueof(recom.Recommended_To__c),recom);		
		}
        system.debug('in record selector===>'+OppIdWithRecomMap);
    }
}