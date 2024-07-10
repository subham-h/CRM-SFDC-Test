/**
 * Trigger Handler Utility Class for Opportunity Trigger
 * 
 * Version  Date         Owner                                  RQ#           Description
 ****************************************************************************************************************************************
 * 1.0      08/02/2016   meghana.gupta@ust-global.com           #RQ-002301     Opportunity Trigger - Refactoring.
 *                                                                             Removed AFLS trace related code that used to populate Debug field 
 * 2.0      28/06/2017   Sandhya.Sambasivan@ust-global.com      #RQ-005190     Change 'Move To Tender' to a chatter feed button 
 * 3.0      11/09/2017   meghana.gupta@ust-global.com           #RQ-005471     Opportunity Trigger Optimization 
 * 4.0      31-Jul-2017  Sandhya.Sambasivan@ust-global.com      #RQ-005318     Populate Territory for Opportunity
 * 5.0      31/10/2017   Nisha.arjunan@ust-global.com           #RQ-005636     Update references of GlobalErrorLogger
 * 6.0      18-Jun-2018  Jiji.Jayasingh@ust-global.com          #RQ-008607     To deprecate the Move to Tender functionality.
 * 7.0      21-Aug-2018  Jiji.Jayasingh@ust-global.com          #RQ-009064     Update definition of BCO/complex tender
 * 8.0      20-09-2018   Jiji.Jayasingh@ust-global.com          #RQ-009337     Changed the Fast Track & Tender Type field value assignment logic on Tenders
 * 9.0      09/11/2018   meghana.gupta@ust-global.com           #RQ-007839     To fix exception if Account is not entered 
 * 10.0     18-Mar-2019  Junaid.Khader@ust-global.com           #RQ-009058     Removed methods (populateTerritory & validateAndPopulateCluster) which were referencing out of box Territory model
 * 11.0     06-Jun-2019  manjunath.c.holekade@maersk.com        #RQ-010819     Removal of references of deprecated fields 
 * 11.1     15-Jun-2019  Neha - TCS                             #RQ-011020     Need to set the Tender type as Simple(irrecpective of rate structure) for new Tender format value "No Ocean Tender", so populateTenderType() is modified
 * 11.2     03-04-2020   Sidhartha@maersk                       RQ-013016      Removed populateOpportunityOwner method 
 * 11.3     05-Nov-2020  Neha@TCS                               SFSE-4383      Set the Tender type as blank for No ocean tender
 * 11.4     24-Nov-2021  Rakesh@Maersk                          SFSE-6108      adding new Tender format in the condition
 * 11.5     17-Jun-2022  Ronnie@SF                              SPI-100        Removed brand hardcoding (from commented code)
 * 11.6     25-07-2023   Vinay                                  SFSE-10656     Added populateCreatorRole method
 * 11.7     29-01-2024   Avinash@maersk                         SFSE-13852     Backend Data updates when Customer Journey field is updated in Oppty Details
 * 11.8     31-02-2024   Jothsana@maersk                        SFSE-13703     Removing the references of Creator Role
 * 11.9     31-01-2024   Ramadevi@maersk                        SFSE-14043     Update the Customer Type to BCO when Customer Journey is Instant Quote (Non Negotiable) 
 * 12.0     21/03/2024   ramadevi@maersk                        SFSE-14324     Update the Recommendation is the Opportunity is updated 
 * 13.0     08-04-2024   Avinash@Maersk                         SFSE-14511     Site ID status update
 * 14.0     03-05-2024   Avinash@Maersk                         SFSE-14519     Allow both the BCO & FFW as Customer Type for P2Q
 * 15.0     30-05-2024   ramadevi@Maersk                        SFSE-15070     Update the Recommendation status to Obsolete on Opportunity Closed Lost
 * 16.0   	05-06-2024   Avinash@Maersk                         SFSE-14825     Cargo type on Opportunity level
 */

public without sharing class OpportunityFieldPopulator {    
    
    
    //SFSE-14825
    public static void validateOppoProdCargoTypeForCustJrnyOppo(Map<Id,Opportunity> mapOppoIdsWithInstantQuote){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('OpportunityFieldPopulator.validateOppoProdCargoTypeForCustJrnyOppo', 1)){
                 Set<Id> setOfOppId = new Set<Id>();
                for (Opportunity_Product__c oppProd: [Select id,Cargo_Type__c,OpportunityId__c from Opportunity_Product__c where OpportunityId__c =: mapOppoIdsWithInstantQuote.keySet()]) {
                    if (oppProd?.Cargo_Type__c != null && oppProd?.Cargo_Type__c != '' && oppProd?.Cargo_Type__c != 'Dry') {
                        setOfOppId.add(oppProd?.OpportunityId__c);
                    }
                }
                
                if (!setOfOppId.isEmpty()) {
                    for (Id oppId: setOfOppId) {
                        if(mapOppoIdsWithInstantQuote.containsKey(oppId)){
                            mapOppoIdsWithInstantQuote.get(oppId)?.addError(Label.Cargo_Type_Dry_InstantQuote_Opty);
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityFieldPopulator.validateOppoProdCargoTypeForCustJrnyOppo', new list <Exception> {ex});
        }
    }
    
    // If the user is single branded and liner brand not selected by user then populate opportunity liner brand as logged in User's liner brand.
    public static void populateLinerBrand( List<Opportunity> newOpptyList, User loggedInUser){
        
        if(Generic_TriggerHandler.validateRunForMethod('OpportunityFieldPopulator.populateLinerBrand', 1)){        
            // if logged in user is single branded
            if ( loggedInUser.Liner_Brand__c != null && loggedInUser.Liner_Brand__c.split(';').size() == 1 ){              
                for( Opportunity oppty : newOpptyList ){            
                    oppty.Liner_Brand__c = loggedInUser.Liner_Brand__c;                      
                }
            }
        }
    }
    
    //SFSE-14511 : Site ID status update
    public static void populateCountOfInvalidWarehouseSite(Map<String,List<Opportunity_Product__c>> mapOptyToProdWithValidWarehouseSites,List<Opportunity> lstOptyWithInvalidWarehouseSites){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('OpportunityFieldPopulator.populateCountOfInvalidWarehouseSite', 1)){
                for(Opportunity opty : lstOptyWithInvalidWarehouseSites){
                    if(mapOptyToProdWithValidWarehouseSites.containsKey(opty?.Id)){
                        opty.Count_of_Invalid_Warehouse_Sites__c = 1;
                    }
                    else{
                        opty.Count_of_Invalid_Warehouse_Sites__c = 0;
                    }
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityFieldPopulator.populateCountOfInvalidWarehouseSite', new list <Exception> {ex});
        }
    }

    
   /* public static void populateOpportunityOwner( List<Opportunity> newOpptyList, Map<Id, Opportunity> oldOpptyMap, boolean TriggerIsInsert, Map<Id, Account> RelatedAccounts, User loggedInUser ){
        
        system.debug('##### populateOpportunityOwner: '+ newOpptyList);
        system.debug('##### populateOpportunityOwner: '+ oldOpptyMap);
        system.debug('##### populateOpportunityOwner: '+ TriggerIsInsert);
        system.debug('##### populateOpportunityOwner: '+ RelatedAccounts);
        
        if(Generic_TriggerHandler.validateRunForMethod('OpportunityFieldPopulator.populateOpportunityOwner', 1)){ 
        
            List<Id> oppOwnerIdList = new List<Id>();
            Id newOpptyOwner;
            Account OpptyAccount;
            Opportunity oldOppty = null;
            
            for( Opportunity oppty : newOpptyList ){
                
                if ( !TriggerIsInsert ){
                    system.debug('##### TriggerIsInsert');
                    oldOppty = oldOpptyMap.get( oppty.id );
                }           
                            
                OpptyAccount = RelatedAccounts.get( oppty.AccountId );          

                // RQ-007839
                if (OpptyAccount == null){
                    oppty.addError(System.Label.OpportunityTriggerError1);
                    
                } else {
             
                    system.debug('##### OpptyAccount --> '+OpptyAccount);
                    system.debug('##### oppty.AccountId --> '+oppty.AccountId);
                    // If Opportunity belongs to a client or concern account, then assign Branded Account Owner as Opportunity Owner            
                    if ( OpptyAccount.RecordTypeId == Label.Client_Account_Record_Type_Id || OpptyAccount.RecordTypeId == Label.Concern_Account_Record_Type_Id  ){
                        
                        // Get new opportunity owner based on Account's brand owners and opportunity's liner brand
                        newOpptyOwner = getNewOpportunityOwner( oppty, OpptyAccount, loggedInUser.Mll__c );
                        system.debug('$$$ new owner: ' + newOpptyOwner);
                        // if Brand Account owner and the Creator of Opportunity are same then reset the field to false on Creation.
                        if( TriggerIsInsert && oppty.OwnerId == newOpptyOwner ){
                             oppty.Is_Create_Owner_Update__c = false;
                        
                        }else if ( (TriggerIsInsert || (oppty.OwnerId != newOpptyOwner && oldOppty.OwnerId == oppty.OwnerId )) && newOpptyOwner != null){
                             oppty.OwnerId = newOpptyOwner;
                        
                        } else if( !TriggerIsInsert && oppty.OwnerId != newOpptyOwner 
                                   && ( oldOppty.OwnerId != oppty.OwnerId ) //Branded Account Owners should not be populated as Opportunity Owner, if Owner is manually changed using 'Change' link in detail page.
                                   && ( oldOppty.Liner_Brand__c != oppty.Liner_Brand__c || oppty.Is_Create_Owner_Update__c == true )) {

                            oppty.Is_Create_Owner_Update__c = false;                        
                        }       
                    }
                    
                    // Get Opportunity Owner Ids to populate Opportunity Owners' Manager                   
                    if( oppty.OwnerId != null && ( TriggerIsInsert || ( !TriggerIsInsert && ( oldOppty.OwnerId != oppty.OwnerId)))){ //#RQ-010819 - Removed reference to Executive_Priority__c field
                        
                        oppOwnerIdList.add( oppty.OwnerId );                                    
                    }                    
                }
            }
            
            if( oppOwnerIdList.size() > 0 ){
                populateOpportunityOwnerManager( newOpptyList, oldOpptyMap, oppOwnerIdList, TriggerIsInsert );         
            }
        }
    }
    
    public static Id getNewOpportunityOwner( Opportunity Oppty, Account OpptyAccount, boolean LoggedInUser_MLL ){
        
        String OpptyLinerBrand = oppty.Liner_Brand__c;      
        Id newOpptyOwner;
        
        //#RQ-005318: If Account Brand owner is inactive, assign the creator as Opportunity Owner
        if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(OpptyLinerBrand) && 
                  OpptyAccount.MSL_Account_Owner__c != null && !LoggedInUser_MLL &&
                  OpptyAccount.MSL_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.MSL_Account_Owner__c;
                     
        } else if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SAFMARINE).contains(OpptyLinerBrand) && 
                    OpptyAccount.SCL_Account_Owner__c != null && 
                    OpptyAccount.SCL_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.SCL_Account_Owner__c;
                    
        } else if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(OpptyLinerBrand) && 
                    OpptyAccount.SEA_Account_Owner__c != null && 
                    OpptyAccount.SEA_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.SEA_Account_Owner__c;
                    
        } else if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(OpptyLinerBrand) && 
                    OpptyAccount.MCC_Account_Owner__c != null && 
                    OpptyAccount.MCC_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.MCC_Account_Owner__c;
                    
        } else if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(OpptyLinerBrand) && 
                    OpptyAccount.MLL_Account_Owner__c != null && LoggedInUser_MLL && 
                    OpptyAccount.MLL_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.MLL_Account_Owner__c;
                    
        } else if( BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEAGO).contains(OpptyLinerBrand) && 
                    OpptyAccount.Seago_Account_Owner__c != null && 
                    OpptyAccount.Seago_Account_Owner__r.isActive){
                    
            newOpptyOwner = OpptyAccount.Seago_Account_Owner__c;    
                    
        }    
        return newOpptyOwner;
    }
 */   
 /*   public static void populateOpportunityOwnerManager( List<Opportunity> newOpptyList, Map<Id, Opportunity> oldOpptyMap, List<Id> oppOwnerIdList, boolean TriggerIsInsert ){
        
        // Get opportunity owner's manager 
        Map<Id,User> userMap = new Map<Id,User>( [ SELECT Id, Manager.Id, Manager.isActive FROM User WHERE Id IN :oppOwnerIdList ] );
                    
        //Populate Opp_Owners_Manager__c field with the Owners' Manager         
        if ( userMap != null && !userMap.isEmpty() ) {
            
            for( Opportunity oppty : newOpptyList ) {
                
                if( userMap.containsKey( oppty.OwnerId )){
                         
                    //If an opportunity owner does not have a manager assigned or manager is Inactive, then opportunity owner manager field should be kept blank.                                                      
                    if( userMap.get( oppty.OwnerId ).Manager != null && userMap.get( oppty.OwnerId ).Manager.isActive ){
                      
                        oppty.Opp_Owners_Manager__c = userMap.get( oppty.OwnerId ).Manager.Id;
                    
                    } else {
                          
                        oppty.Opp_Owners_Manager__c = null;
                    
                    }                                                                        
                } 
            }
        }                  
    }
    */
    
    /*public static void SetPriceBook( List<Opportunity> newOpptyList ){
        
        // Set Standard Pricebook to newly added Opportunity        
        for( Opportunity opp : newOpptyList ) {
            opp.Pricebook2Id = Label.StandardPriceBook;   
        }
    }*/
     
    public static void populateTenderType( List<Opportunity> newOpptyList ){
        for(Opportunity oppty : newOpptyList ){
            //RQ-009337: Start
         
        // Changed teh cndition for RQ011020 to set tender type as Simple for No ocean tender
        // Added Tender_Submission_Format__c !='No Ocean Tender' as part of SFSE-6108
          oppty.Tender_Type__c = (oppty.Tender_Submission_Format__c =='No Ocean Tender' || oppty.Tender_Submission_Format__c =='Long Term Quote') ? null :((oppty.Tender_Submission_Format__c == 'Customer specific format' || oppty.Tender_Submission_Format__c == 'Submission via an online tool' || oppty.Customer_Requested_Rate_Structure__c =='Yes') && oppty.Tender_Submission_Format__c !='No Ocean Tender') ? 'Complex' : 'Simple';
            //RQ-009337: End            
        }
    }  
    
    //SFSE-13852 : Backend Data updates when Customer Journey field is updated in Oppty Details
    public static void populateCustomerJourneyBackendFields(List<Opportunity> lstOppCustJrnyFieldstoUpdt){
        try{
            if(Generic_TriggerHandler.validateRunForMethod('OpportunityFieldPopulator.populateCustomerJourneyBackendFields', 1)){
                for(Opportunity oppty : lstOppCustJrnyFieldstoUpdt ){
                    oppty.Tender_Submission_Format__c = 'Maersk Line standard format';
                    oppty.Customer_Requested_Rate_Structure__c = 'No';
                    oppty.Offer_Type__c = 'Offer containing Standard T&Cs';
                    oppty.Cargo_Type__c = 'Dry';
                    //SFSE-14043 : Default the value of Customer Type to BCO when the Customer Journey is Instant quote
                    //oppty.Customer_Type__c = 'BCO'; - Removed defaulting to BCO as part of SFSE-14519
                }
            }
        }
        catch(Exception ex) {
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityFieldPopulator.populateCustomerJourneyBackendFields', new list <Exception> {ex});
        }
    }
    
        //SFSE-14324
    /*@future
    public static void updateRecommendationAsInvalid(List<String> OpptyList,String fieldToUpdate){
        system.debug('OpptyList ==>'+OpptyList);
        List<Recommendation__c> recomList = [select id,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c from Recommendation__c where Recommended_To__c in :OpptyList and Is_valid__c=true];
        for(Recommendation__c recom : recomList){
            if(fieldToUpdate == 'Is_valid__c'){
            recom.Is_valid__c = false;
        }
            //SFSE-15070
            if( fieldToUpdate == 'Status__c' && recom.Status__c == NULL){
                recom.Is_valid__c = false;
                recom.Status__c = 'Obselete - Lost Opportunity';
            }
        }
        if(recomList<> NULL){
            update recomList;
        }
    }*/

    //Customer Insight changes
    @future
    public static void updateRecommendationAsInvalid(List<Id> RecomIdList,String fieldToUpdate){
        system.debug('RecomIdList ==>'+RecomIdList);
        List<Recommendation__c> recomList = [select id,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c from Recommendation__c where id in :RecomIdList];
        for(Recommendation__c recom : recomList){            
            if(fieldToUpdate == 'Is_valid__c'){
				recom.Is_valid__c = false;
			}
            
            //SFSE-15070
            if( fieldToUpdate == 'Status__c' && recom.status__c == NULL){
                recom.Is_valid__c = false;
                recom.Status__c = 'Obselete - Lost Opportunity';
            }
        }
        if(recomList<> NULL){
            update recomList;
        }
    }

    public static void checkRecommendationStatusOnClose(List<String> OpptyList,List<Opportunity> newOpptyList){
        List<Recommendation__c> recomList = [select id,Is_valid__c,Is_User_Action_Mandatory__c,Recommendation_Id__c,Recommendation_Item_Reference__c,Recommendation_Object__c,Recommended_To__c,RecordTypeId,Rejection_Reason__c,Status__c from Recommendation__c where Recommended_To__c in :OpptyList and Is_valid__c=true and Status__c= NULL];
        Set<String> recomAvailforOpp = new Set<String>();
        for(Recommendation__c recom:recomList){
            recomAvailforOpp.add(recom.Recommended_To__c);
        }
        for(Opportunity opty : newOpptyList){
            if(recomAvailforOpp.contains(String.valueof(opty.id))){
                opty.addError(Label.Recommendation_Error_Message);
            }
        }
    }
    //Recommendation - End
    
}