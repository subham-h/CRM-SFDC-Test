/**
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Rev  Story       Name            Date                Comments
* 1. SFSE-10656   Anjali           10/06/2023          Code to check validations for I agree
* 2. SFSE-10933   Bharti           12/06/2023          Added Tender and Mandatory feature method to check validation.
* 3. SFSE-11668   Vinay            17/07/2023          Added code to validate Opportunity Stage and Offer Status on Opportunity.
* 4. SFSE-11800   Bharti           18/07/2023          Remove tender validation method 
* 5. SFSE-11734   Bharti           21/07/2023          Adding a method to check logged in user has I_Agree_Access_Permission set or not.
* 6.              Aditi            11/08/2023          Code Refinement/Optimization
* 7. SFSE-12185   Bharti           21/08/2023          Added condition in ineligibleProductValidation method to exclude E commerce product.
* 8. SFSE-12080   Aditi            24/08/2023          Removed Validation of I_Agree_Access_Permission set to enable Global Roll Out
* 9. SFSE-12956   Aditi            10/10/2023          Changed lstOppToUpdate to setOppToUpdate (List to Set)
* 10. SFSE-11497  Shilpa           30/11/2023          Added logic to not send the offer if opportunity has solution added.
* 11. SFSE-13467  Aditi            18/12/2023          Added logic to check if opportunity products are Included In Email Agreement
Rakesh Modified to enable one time/ batch run - Aditi is testing
* 12. SFSE-13329  Shashi           09/04/2024          Added Validations for I agree Contracting Process for P2Q.
* 13. SFSE-14825  Avinash          29/05/2024          "Cargo type" on Opportunity level 
**/


public class OneClickValidationHelper{
    
    public static Map<String, One_Click_Error_Code__mdt> mapEd = new Map<String, One_Click_Error_Code__mdt>();
    public static Set<Opportunity> setOppToUpdate = new Set<Opportunity>();
    public static Map<Id, Boolean> mapOppToQualify = new Map<Id, Boolean>();
    public static String eCommProductCodes = Label.ECommerceProductCodes;
    public static String disqualifiedProducts  = '';
    
    /*
* Method to call to check for all validations on the basis of source. Some validations need not be checked in case the source is 'trigger'.
* @param - setOppIds -> set of opportunity Ids to check for One-Click Validations
* @param - source -> string, can be 'lwc' or 'trigger'
*/
    public static Map<Id, String> checkAllValidation(Set<Id> setOppIds, String source){
        List<Opportunity> lstOppDetails = new List<Opportunity>();        
        List<Opportunity_Product__c> lstOppProducts = new List<Opportunity_Product__c>();
        Map<Id, List<Opportunity_Product__c>> mapOfOppToOli = new Map<Id, List<Opportunity_Product__c>>();
        Map<Id, String> mapOppErr = new Map<Id, String>();
        String oppTeamMember;
        String customPermissionError;
        String errCode = '';
        String errSuccessBody = '';
        disqualifiedProducts = '';
        mapEd = One_Click_Error_Code__mdt.getAll();
        
        
      
        if(setOppIds != null && setOppIds.size() > 0){
            //Querying on the opportunity and Opportunity Products to Validate
            lstOppDetails = getOppDetails(setOppIds);
            lstOppProducts = getOppOLIDetails(setOppIds);
            
            //Mapping Opportunities to their Products
            mapOfOppToOli = getOppOLIDetailsMap(lstOppProducts);
            
            // Method to Validate Opportunity for Errors
            mapOppErr = validateOpportunity(lstOppDetails, mapOfOppToOli);
            System.debug('@@@@setOppToUpdate'+setOppToUpdate);
            errSuccessBody = JSON.serialize(setOppToUpdate);
            System.debug('@@@@errSuccessBody'+errSuccessBody);
            if(source =='lwc') {
                
                oppTeamMember = hasAccessValidation(lstOppDetails[0]);
                errCode += oppTeamMember;
                
                //SFSE-11668 - When the opportunity Stage is Closed Won or Closed Lost or Offer Status is Accepted/Completed then Show Message
                if(lstOppDetails[0].CloseDate <= System.today() || lstOppDetails[0].Offer_Status__c == Label.Offer_Accepted)
                    errCode += mapEd.get('Opportunity_Closed').Error_Code__c;
                mapOppErr.put(lstOppDetails[0].Id, mapOppErr.get(lstOppDetails[0].Id) + errCode);
            } else {
                try{
                    if(errSuccessBody !=null && !String.isBlank(errSuccessBody)) {
                        if(!System.isFuture() && !System.isBatch()) {
                            updateOpportunity(errSuccessBody);
                        } else{
                            updateOpportunityAsync(errSuccessBody);
                        }
                    }
                } catch(Exception e){
                    System.debug('Exception: ' + e);
                }   
            }
        }
        System.debug('mapOppErr=='+mapOppErr);
        return mapOppErr;
    }
    
    /*
* Method which will call all other validation methods and get errors
* @param - lstOpps -> List of Opportunities to check for One-Click Validations
* @param - mapOppOLI -> Key: Opportunity Ids Value: List of Opportunity Products added to the Opportunity
*/     
    private static Map<Id, String> validateOpportunity(List<Opportunity> lstOpps, Map<Id, List<Opportunity_Product__c>>  mapOppOLI){
        List<Opportunity_Product__c> lstOppProd = new List<Opportunity_Product__c>();
        Map<Id, String> mapOppToError = new Map<Id, String>();
        String errors = '';
        if(lstOpps != null && lstOpps.size() > 0){
            for(Opportunity opp: lstOpps){
                errors = '';
                errors += offerTypeValidation(opp);
                errors += startEndDateAgreementCheck(opp);
                errors += omebValidation(opp);
                errors += hasProductSolution(opp);
                errors += validateP2QStageCheck(opp);
                errors += validateP2QQuote(opp);
                if(mapOppOLI.get(opp.Id) == null)
                    errors += 'NoOLIError';
                else {
                    Set<String> setErrorCheck = new Set<String>();
                    for (Opportunity_Product__c oli : mapOppOLI.get(opp.Id)) {
                        if (!setErrorCheck.contains('Agreement_Invalid_for_High_Value_Opp')) {
                            String error = agreementValidation(oli);
                            if (String.isNotBlank(error)) {
                                errors += error; 
                                setErrorCheck.add('Agreement_Invalid_for_High_Value_Opp');                                
                            }
                        }
                        if (!setErrorCheck.contains('Exceeds_Dry_Cargo_FFE')) {
                            String error = dryCargoQuantityValidation(oli);
                            if (String.isNotBlank(error)) {
                                errors += error; 
                                setErrorCheck.add('Exceeds_Dry_Cargo_FFE');                                
                            }
                        }
                        if (!setErrorCheck.contains('Exceeds_Reefer_or_Special_Cargo_FFE')) {
                            String error = reeferSpecialQuantityValidation(oli);
                            if (String.isNotBlank(error)) {
                                errors += error; 
                                setErrorCheck.add('Exceeds_Reefer_or_Special_Cargo_FFE');                                
                            }
                        }
                        if (!setErrorCheck.contains('Exceeds_Gross_Profit')) {
                            String error = grossProfitHighValidation(oli);
                            if (String.isNotBlank(error)) {
                                errors += error; 
                                setErrorCheck.add('Exceeds_Gross_Profit');                                
                            }
                        }
                        String disqualifiedProductError = ineligibleProductValidation(oli);
                        if (String.isNotBlank(disqualifiedProductError) && !errors.contains(disqualifiedProductError)) {
                            errors += disqualifiedProductError; 
                            setErrorCheck.add('Not_Qualifies_for_Email_Agreements');                                
                        }
                        
                        if (!setErrorCheck.contains('Mandatory_product_Features')) {
                            String error = mandatoryFeatureValidation(oli);
                            if (String.isNotBlank(error)) {
                                errors += error; 
                                setErrorCheck.add('Mandatory_product_Features');                                
                            }
                        }    
                    }
                }
                oppErrorUpdate(opp.Id,errors);
                mapOppToError.put(opp.Id,errors);
            }
            
        }
        return mapOppToError;
    }
    
    //Modified to add method to run when the transaction is already Asynchronous
    @future
    private static void updateOpportunity(String body) {
        updateOpportunityAsync(body);
    }
    
    private static void updateOpportunityAsync(String body) {
        List<Opportunity> opps = (List<Opportunity>)JSON.deserialize(body, List<Opportunity>.class);
        System.debug('@@@@opps'+opps);
        try{
            update opps;
        } catch(Exception ex){
            System.debug('@@@@@ ' + ex);
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'updateOpportunityAsync', new list<Exception>{ex});  
        }
    }
    
    //Checking if logged in user is an Opportunity Team Member, Opportunity Owner or Account Brand Owner
    @TestVisible private static String hasAccessValidation(Opportunity opps){
        List<Account> accList = new List<Account>();
        Id accountId = opps.AccountId;
        Set<Id> setOppTeamMemberId = new Set<Id>();
        String optyBrand = opps.Liner_Brand__c;
        Id accountOwnerId;
        List<OpportunityTeamMember> lstTeamMembers = [Select UserId  FROM  OpportunityTeamMember WHERE OpportunityId =:opps.Id AND (OpportunityAccessLevel='Edit' OR UserId =:opps.OwnerId )];
        
        for(OpportunityTeamMember otm: lstTeamMembers){            
            setOppTeamMemberId.add(otm.UserId);
        }
        
        accList = [SELECT Id, OwnerId, MSL_Account_Owner__r.Id, Alianca_Account_Owner__r.Id, HSUD_Account_Owner__r.Id, MCC_Account_Owner__r.Id,
                   MLL_Account_Owner__r.Id, Seago_Account_Owner__r.Id, SEA_Account_Owner__r.Id 
                   FROM Account WHERE Id =:accountId];
        
        if (accList.size() > 0) {
            Account acc = accList[0];
            accountOwnerId = optyBrand =='Maersk Line'?Acc.MSL_Account_Owner__r.Id:optyBrand =='MCC'?Acc.MCC_Account_Owner__r.Id:optyBrand =='Seago'?Acc.Seago_Account_Owner__r.Id:optyBrand =='Sealand'?Acc.SEA_Account_Owner__r.Id:optyBrand =='Hamburg Sud'?Acc.HSUD_Account_Owner__r.Id:optyBrand =='Alianca'?Acc.Alianca_Account_Owner__r.Id:null;
            if(AccountOwnerId !=null){
                setOppTeamMemberId.add(AccountOwnerId);
            }
           
        if(opps.Business_Process__c != 'Instant Quote'){
                if(!setOppTeamMemberId.isEmpty() && !setOppTeamMemberId.contains(UserInfo.getUserId())){
                        return mapEd.get('No_Privileges_to_Send_Offer').Error_Code__c; 
                    }
        }else{ 
            Boolean hasP2QPermissionSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Access_Opportunity_P2Q_Journey' LIMIT 1].size() > 0;
            if((!setOppTeamMemberId.isEmpty() && !setOppTeamMemberId.contains(UserInfo.getUserId())) || !hasP2QPermissionSet){
                    return mapEd.get('No_P2Q_Privileges_to_Send_Offer').Error_Code__c; 
                }
        }          
        }
        return '';
    }   
    
    //Checks if the Opportunity has Offer Type'Offer containing Standard T&Cs'
    @TestVisible private static String offerTypeValidation(Opportunity opp){
        if(opp != null && opp.Offer_Type__c != 'Offer containing Standard T&Cs') 
            return mapEd.get('Offer_Type_Invalid').Error_Code__c;
        return '';
    } 
    
    //Checks if Agreement Start and End Dates are provided
    @TestVisible private static String startEndDateAgreementCheck(Opportunity opp){
        if(opp != null && (opp.First_Shipment_Date__c == null || opp.Last_Shipment_Date__c==null)) 
            return mapEd.get('Agreement_Start_End_Date').Error_Code__c;
        return '';
    } 
    
    //Check if Opportunity is non-OMEB
    @testVisible private static String omebValidation(Opportunity opp) {
        if(opp!=null && opp.Must_Go_To_OMEB__c) 
            return mapEd.get('Send_Offer_Disabled_for_OMEB').Error_Code__c;
        return '';
    }
    
    //Check if Has Product Solution is true
    @TestVisible private static String hasProductSolution(Opportunity opp){
        if( opp!=null  && opp.Product_Solution__c!= null && opp.Product_Solution__c.contains('Solution')){
            return mapEd.get('Has_Product_Solution').Error_Code__c;
        }  
         return ''; 
    }
    
    //Checks if LnS Gross Profit is between 20K and 100k, the difference between Agreement start and end dates is less than or equal to 92 days
    @testVisible
    private static String agreementValidation(Opportunity_Product__c oli) {
        if (oli != null) {
            Integer numberDaysDue = 0;
            if(oli.OpportunityId__r.First_Shipment_Date__c != null && oli.OpportunityId__r.Last_Shipment_Date__c != null)
                numberDaysDue = oli.OpportunityId__r.First_Shipment_Date__c.daysBetween(oli.OpportunityId__r.Last_Shipment_Date__c);
            if(oli.Product2ID__r.Portfolio__c =='LnS' && oli.OpportunityId__r.Last_Shipment_Date__c != null && oli.OpportunityId__r.First_Shipment_Date__c != null 
               && (oli.OpportunityId__r.Estimated_L_S_Product_Gross_Profit1__c > 20000) &&  (numberDaysDue+1) >92)   {       
                   return mapEd.get('Agreement_Invalid_for_High_Value_Opp').Error_Code__c;  
               } 
        }
        return '';
    }
    
    //Checks if Cargo Type is 'Dry' the Estimated Ocean FFE is less than or equal to 1000
    @TestVisible private static String dryCargoQuantityValidation(Opportunity_Product__c oli) {
        if(oli.Product2ID__r.Portfolio__c =='Ocean' && oli.OpportunityId__r.RecordType.DeveloperName != 'Supply_Chain_Services' 
           &&((oli.OpportunityId__r.Cargo_Type__c == null && oli.Special_Cargo__c == null)||(oli.OpportunityId__r.Cargo_Type__c == 'Dry' && oli.OpportunityId__r.Estimated_Ocean_FFE__c >1000 ) || (oli.OpportunityId__r.Cargo_Type__c == 'Dry;Reefer' && oli.OpportunityId__r.Estimated_Ocean_FFE__c >1000 )))//SFSE-14825 : Added Dry;Reefer conditions
            return mapEd.get('Exceeds_Dry_Cargo_FFE').Error_Code__c; 
        return '';
    }
    
    //Checks if Cargo Type is 'Reefer', or there is a value selected for 'Special Cargo' on any Opportunity Product, the Estimated Ocean FFE is less than or equal to 500
    @TestVisible private static String reeferSpecialQuantityValidation(Opportunity_Product__c oli) {
        if(oli.Product2ID__r.Portfolio__c =='Ocean' && (((oli.OpportunityId__r.Cargo_Type__c == 'Reefer' || oli.Special_Cargo__c != null) && oli.OpportunityId__r.Estimated_Ocean_FFE__c >500) || (oli.OpportunityId__r.Cargo_Type__c == null && oli.Special_Cargo__c == null)))
            return mapEd.get('Exceeds_Reefer_or_Special_Cargo_FFE').Error_Code__c;
        return '';
    }
    
    //Checks if the Estimated LnS Gross Profit is less than for equal to 100K USD
    @TestVisible private static  String grossProfitHighValidation(Opportunity_Product__c oli) {
        if(oli.Product2ID__r.Portfolio__c =='LnS' && (oli.OpportunityId__r.Estimated_L_S_Product_Gross_Profit1__c > 100000))
            return mapEd.get('Exceeds_Gross_Profit').Error_Code__c;
        return '';
    }
      
    //Checks if all the Opportunity Products have all their Mandatory features filled
    @TestVisible private static String mandatoryFeatureValidation(Opportunity_Product__c oli){
        if(oli.Total_Mandatory_Configuration__c != oli.Total_Mandatory_Configuration_Filled__c)
            return mapEd.get('Mandatory_product_Features').Error_Code__c;
        return '';
    }

    //Check if the products added to the opportunity are Included In Email Agreement
    @TestVisible private static String ineligibleProductValidation(Opportunity_Product__c oli){
        if(oli.Product2ID__r.Product_Scope__c == null || (!oli.Product2ID__r.Product_Scope__c.contains('Included In Email Agreement') && oli.Product2ID__r.Product_Scope__c != null))
        {
                if(oli.Product2ID__r.Name != null && !disqualifiedProducts.contains(oli.Product2ID__r.Name))
                    disqualifiedProducts += ', '+oli.Product2ID__r.Name;
                return mapEd.get('Not_Qualifies_for_Email_Agreements').Error_Code__c;            
        }
        return '';

    }
    
    //Method to query Opportunities 
    @TestVisible private static List<Opportunity> getOppDetails(Set<Id> setOppoIds) {
        
        List<Opportunity> lstOpps = [SELECT Id,Liner_Brand__c,OwnerId,AccountId, Qualify_OneClick_Journey__c,Estimated_Total_Opportunity_Gross_Profit__c,
                                     Estimated_L_S_Product_Gross_Profit1__c, Special_Cargo__c,Cargo_Type__c, First_Shipment_Date__c, Last_Shipment_Date__c,CloseDate,
                                     Must_Go_To_OMEB__c,Offer_Type__c, Estimated_Ocean_FFE__c,Tender_Submission_Format__c,RecordType.DeveloperName,
                                     StageName,Offer_Status__c,Product_Solution__c,Business_Process__c FROM Opportunity WHERE Id IN:setOppoIds ORDER BY LastModifiedDate DESC];
        for(Opportunity opp : lstOpps)
            mapOppToQualify.put(opp.Id, opp.Qualify_OneClick_Journey__c);
        return lstOpps;
    }
    
    //Method to query Opportunity Products
    @TestVisible private static List<Opportunity_Product__c> getOppOLIDetails(Set<Id> setOppoIds) {
        return [SELECT Id, OpportunityId__r.Qualify_OneClick_Journey__c, Product2ID__r.Name,Product2ID__r.OIPC_Code__c, Product2ID__r.Product_Scope__c,
                Special_Cargo__c, OpportunityId__r.Estimated_Total_Opportunity_Gross_Profit__c,
                OpportunityId__r.Estimated_L_S_Product_Gross_Profit1__c, OpportunityId__r.Special_Cargo__c,
                OpportunityId__r.Cargo_Type__c, OpportunityId__r.First_Shipment_Date__c,OpportunityId__r.Last_Shipment_Date__c,
                Product2ID__r.Portfolio__c, OpportunityId__c, OpportunityId__r.Must_Go_To_OMEB__c, OpportunityId__r.Offer_Type__c,
                OpportunityId__r.Estimated_Ocean_FFE__c,OpportunityId__r.Tender_Submission_Format__c,OpportunityId__r.RecordType.Name,
                OpportunityId__r.RecordType.DeveloperName,Total_Mandatory_Configuration_Filled__c,Total_Mandatory_Configuration__c 
                FROM Opportunity_Product__c WHERE OpportunityId__c IN :setOppoIds ORDER BY LastModifiedDate DESC];
    }
    
    //This method maps opportunities to its products
    @TestVisible private static Map<Id, List<Opportunity_Product__c>> getOppOLIDetailsMap(List<Opportunity_Product__c> lstOppoProducts) {
        Map<Id, List<Opportunity_Product__c>> mapOppToOLI = new Map<Id, List<Opportunity_Product__c>>();
        List<Opportunity_Product__c> lstOLI;
        for(Opportunity_Product__c oppProd : lstOppoProducts) {
            lstOLI = mapOppToOLI.containsKey(oppProd.OpportunityId__c) ? mapOppToOLI.get(oppProd.OpportunityId__c) :new List<Opportunity_Product__c>();
            lstOLI.add(oppProd);
            mapOppToOLI.put(oppProd.OpportunityId__c, lstOLI);
        }
        return mapOppToOLI;
    }
    
    //Populates the list with Opportunities that need update of 'Qualify_OneClick_Journey__c' field
    @TestVisible private static void oppErrorUpdate(Id oppId, String error) {
        Opportunity oppToUpdate = new Opportunity();
        oppToUpdate.Id = oppId;
        if(String.isBlank(error))
            oppToUpdate.Qualify_OneClick_Journey__c = true;
        else 
            oppToUpdate.Qualify_OneClick_Journey__c = false;
        
        if(mapOppToQualify.get(oppId) != oppToUpdate.Qualify_OneClick_Journey__c)
            setOppToUpdate.add(oppToUpdate);
    }
    
    //Validation for P2Q stage check
    @testVisible private static String validateP2QStageCheck(Opportunity opp) {
        if(opp!=null && opp.Business_Process__c == System.Label.Business_Process_Instant_Quote && (opp.StageName == System.Label.Identifying || opp.StageName == System.Label.Qualifying || opp.StageName == System.Label.Designing_Proposal)){
            return mapEd.get('P2Q_Opportunity_Stage_Check').Error_Code__c;
        }          
        return '';
    }
    
    //Validation for P2Q Quote link
   @testVisible private static String validateP2QQuote(Opportunity opp) {
        if(opp!=null && opp.Business_Process__c == System.Label.Business_Process_Instant_Quote){
        	list<Quotes__c> lstQuote = [SELECT Id,Quote_Copo_Link__c from Quotes__c WHERE Opportunity__c =:opp.Id LIMIT 1];
            if(!lstQuote.isEmpty() && lstQuote[0].Quote_Copo_Link__c == null){
                return mapEd.get('P2Q_Quote_needed').Error_Code__c;
            }         
        }
        return '';
    }

    
}