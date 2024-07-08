/*
* Version   Date            Owner                   RQ#                 Description
***********************************************************************************************************************************************
* 1.0       16/06/2023      sriram@Maersk           SFSE-11594      -     AutoRenew Closed won opportunities 
* 2.0       08/09/2023      shashi@Maersk           SFSE-12054      -     Added new optionality structure for configurations
* 3.0       30/10/2023      Shashi@Maersk           SFSE-13127      -     Updating Renewed Opportunity Owner to Opportunity Owner who closed the Parent Opportunity
* 4.0       24-Nov-2023     Avinash@Maersk          SFSE-13206      -     "clone", "renew", "report as lost" or "upgrading to the latest version" for Packaged Solutions
* 5.0       05-Feb-2024     Avinash@Maersk          SFSE-12654      -     Clone and auto-renew an opportunity with the latest solution version
* 6.0       05-02-2024      Jothsana@Maersk         SFSE-13703      -     Check for MLL_Account_Owner__c for MLL Brand opportunity
* 7.0       07-02-2024      Aleena@Maersk           SFSE-13998      -     Removed Must Go to OMEB field should not be populated from here , on insert it should be populated.
* 8.0       11-03-2014      Arpitha@Maersk          SFSE-13671      -     Added the logic when parent opp is closed lost then type is same as parent opp and if stage is closed won then type=renewal. 
* 9.0       21-04-2024      Arpitha@Maersk          SFSE-13548      -     Added the method sendEmailToRenewalOpp to send single email message.
* 10.0      29-04-2024      Vinay@Maersk            SFSE-14918      -     Added a check to skip to include Non OIPC in active products during Opportunity clone.
* 11.0      16-May-2024     Shashi@Maersk           SFSE-13391      -     For auto renewed oppties making record locked as false & Nullifying Reason for Unlocking, Opportunity Unlocked date.
* 12.0      24-05-2024      Vinay@Maersk            SFSE-15121      -     Added logic to create Opty products and Team members only for successfully renewed Opportunities 
* 13.0      04-06-2024	    Vinay@Maersk	    SFSE-15159 	    -	  Handled Null point check for Agreement Start and End Date and Handled Null point check for Opportunity Name.	   
* 14.0      04-06-2024	    Vinay@Maersk	    SFSE-15218	    - 	  Removed try catch while creating Team members and products added Database.insert instead.
*/
public class OpportunityAutoRenewal {
    
    @future
    public static void OpportunityAutoRenewal(Set<Id> OpportunityIds) {
        list<Opportunity> closedOpportunitties  = new list<Opportunity>();
        map<object,List<AggregateResult>>mapOppPRodList = new map<object,List<AggregateResult>>();
        
        string  soqlQuery = 'SELECT Id,Account.Name,Owner.Name,CloseDate,Comments_for_Lead_source__c,Owner.IsActive,Account.HSUD_Account_Owner__c,Account.HSUD_Account_Owner__r.IsActive,Account.Alianca_Account_Owner__c,Account.Alianca_Account_Owner__r.IsActive,Account.Seago_Account_Owner__c,Account.Seago_Account_Owner__r.IsActive,Account.MCC_Account_Owner__c,Account.MCC_Account_Owner__r.IsActive,Account.MSL_Account_Owner__c,Account.MSL_Account_Owner__r.IsActive,Account.MLL_Account_Owner__c,Account.MLL_Account_Owner__r.IsActive,Account.SEA_Account_Owner__c,Account.SEA_Account_Owner__r.IsActive,AccountId,Account_Plan__c,Initiative__c,Activity_Check__c,Freetime_Terms__c,Last_Shipment_Date__c,First_Shipment_Date__c,Amount,Approval_Status__c,Liner_Brand__c,'
            +'CampaignId,Actual__c,Cargo_Type__c,Clone_Opportunity_Source__c,Description,Controlled__c,Count_of_AFLS_Quotes__c,Create_By_Using__c,Current_Contract_Number__c,Custom_L_S_Solution_Required__c,Customer_Alignment__c,'
            +'Primary_Contact__c,Customer_Requested_Rate_Structure__c,Customer_Type__c,Legacy_ExtID__c,Destination__c,Double_Down__c,Dry__c,Estimated_Agreement_Duration__c,Expected_Handling_Rounds__c,ExpectedRevenue,Expected_Tender_Receipt_Date__c,'
            +'First_Round_Submission_Date__c,First_Time_Closed_Date__c,ForecastCategoryName,Framing_the_Challenge__c,Freetime_Terms_Comments__c,Implementation_Date__c,Enforceable_Contract__c,IT_Investment__c,Lead_Id__c,Lead_Route__c,'
            +'Lead_Route_Approval__c,Lead_Route_Approval_By__c,LeadSource,Legacy_System__c,Lost_Product_Parent_Opportunity__c,Move_To_Tender_Opp__c,Must_Go_To_OMEB__c,NAC_Checked__c,Named_Account__c,Named_Account_Products_Applicable__c,NAP_Comment__c,Need_SCD_Support__c,'
            +'NextStep,Next_Steps__c,Offer_Type__c,Opp_Line_Item_Quantity_Manually_Changed__c,Opp_Owners_Manager__c,Actual_Average_Est_CY__c,Opportunity_contains_Dangerous_Goods__c,Opportunity_Legacy_Id__c,Name,OwnerId,RecordTypeId,Type,Other_Sustainability_Support_needed__c,Parent_Opportunity__c,'
            +'Who_takes_the_risk_on_BAF_fluctuations__c,Tender_Submission_Format__c,Premium_Competitor__c,Premium_Over_Competition__c,Previous_Stage__c,Pricebook2Id,Strategic_Deal__c,Probability,Products_for_Approval__c,Proposal_Presentation_Date__c,Reefer__c,Commodity__c,Request_Type__c,Requires_IT_Integration__c,Sales_Qualified_Date__c,StageName,Send_To_mail__c,SendEmail_User__c,Situation_in_Brief__c,Special_Cargo__c,'
            +'Special_T_Cs__c,special_terms_comments__c,TCM_SPOC__c,Stakeholder_Mapping__c,Submitted_For_approval__c,Customer_Journey__c,Subsequent_Round_Receipt_Date__c,Sustainability_support_needed__c,SyncedQuoteId,Tactics__c,TCM_Involvement_Required__c,Tender_Type__c,Total_Committed_FFE__c,Uncovering_Customer_Needs__c,US_Flag_Carrier__c,Value_Proposition__c,VIP_Deal__c,Record_Locked__c,Reason_for_Unlocking__c,Opportunity_Unlocked_Date__c'  
            //  +' FROM  Opportunity WHERE StageName = \'' + closedwon + '\' and (Type = \'' + renewal + '\' OR Type = \'' + Acquisition + '\') and (RecordTypeId = \'' +shipingandCargorRecTypeId+'\' OR RecordTypeId = \''+supplyChainRecTypeId+'\') and Last_Shipment_Date__c =:nthday';
            +' FROM  Opportunity WHERE Id In: OpportunityIds';
        
        closedOpportunitties =  Database.query(soqlQuery);
        
        set<id> oppIds = new set<id>();
        set<string> oipcCodes  = new set<string>();
        set<id> nonOIPCProductIds = new set<id>();
        map<id,list<Opportunity_Product__c>> OpporuntiyIdWithOpportunityProduct = new  map<id,list<Opportunity_Product__c>>();
        String solutionLatestVersionId;
        set<string> packagedSolutionProductIds  = new set<string>();//SFSE-12654
        for(Opportunity parentOpp:closedOpportunitties){
            oppIds.add(parentOpp.id);
        }
        
        
        //query Opporunity products based on Opportunity
        list<Opportunity_Product__c> opportunityProductList = [SELECT Id, Name,Definition_Type__c ,Commitment__c,Actuals_Loaded__c,Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c,
                                                               Blue_Collar_FTEs__c,Building_Lease__c,Cargo_Type__c,Comments__c,ServiceDate__c,Debug__c,
                                                               Direct_Variable_Cost__c,Discount__c,EBIT__c,Exclude_from_OMEB__c,Exclude_from_SIP__c,Executing_City_State__c,Country__c,Fixed_Costs__c,UnitPrice__c,HasSchedule__c,Import_Export__c,
                                                               Indirect_FTEs__c,IsWndProduct__c,L_S_Product__c,Legacy_Opportuntity_LineItemId__c,
                                                               Description__c,List_Price__c,Estimated_Footprint_Requirement_in_Sqm__c,Material_Handling_Equipment_Investments__c,Ocean_Product__c,OpportunityId__c,OpportuntityLineItemId__c,OpportyProductExtID__c,Opt_Out_Auto_Quantity_Scheduling__c,
                                                               Capital_Expenditure__c,Total_Tender_FFE_per_Route_Direction__c,Previous_Tender_Target__c,Product2ID__c,Product2ID__r.OIPC_Code__c,Product2ID__r.IsActive,ProductCode__c,
                                                               Quantity__c,Schedule_Details__c, Annualized_Gross_Profit__c,Schedule_Product__c,SG_A__c,Special_Cargo__c,Subtotal__c,Tender_Target__c,Total_Configurations__c,
                                                               Total_Configurations_Filled__c,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c,Trade_Guidance_Id__c,Trade_Route__c,Product_Revenue_Per_Unit__c,Total_Product_Revenue__c,
                                                               Warehouse_Site__c,Destination_Country__c, WND_Location_Type__c,Solution__r.IsActive,Solution__c,Solution__r.Latest_Product_Version__c  from Opportunity_Product__c where OpportunityId__c IN:oppIds];
        for(Opportunity_Product__c opportunityProdcut:opportunityProductList){
            
            //SFSE-13206
            if(opportunityProdcut != null && opportunityProdcut.Definition_Type__c == 'Packaged Solution'){
                //SFSE-12654
                if(opportunityProdcut.Solution__c != null && opportunityProdcut.Solution__r.IsActive == true && opportunityProdcut.Solution__r.Latest_Product_Version__c == null){
                    //Get the product ids to query products
                    solutionLatestVersionId = opportunityProdcut.Solution__c;
                    //packagedSolutionProductIds.add(opportunityProdcut?.Product2ID__c);  
                }
                else if(opportunityProdcut.Solution__c != null && opportunityProdcut.Solution__r.IsActive == false && opportunityProdcut.Solution__r.Latest_Product_Version__c != null){
                    solutionLatestVersionId = opportunityProdcut.Solution__r.Latest_Product_Version__c;
                }
            }else{
                //Get the product ids and OIPCS code to query products
                if(opportunityProdcut.Product2ID__r.OIPC_Code__c != NULL){ 
                    oipcCodes.add(opportunityProdcut.Product2ID__r.OIPC_Code__c);
                }else if(opportunityProdcut.Product2ID__r.IsActive){
                    nonOIPCProductIds.add(opportunityProdcut.Product2ID__c);
                }  
            }
            
            //Map of Opportunity id and Opportunity Product
            if(OpporuntiyIdWithOpportunityProduct.containsKey(opportunityProdcut.OpportunityId__c)){
                OpporuntiyIdWithOpportunityProduct.get(opportunityProdcut.OpportunityId__c).add(opportunityProdcut);
            }else{
                OpporuntiyIdWithOpportunityProduct.put(opportunityProdcut.OpportunityId__c,new list<Opportunity_Product__c>{opportunityProdcut});
            }
            
        }
        system.debug('solutionLatestVersionId :'+solutionLatestVersionId);
        map<string,id> oipcCodeWithProductAndSol = new map<string,id>();
        //SFSE-12654
        if(solutionLatestVersionId != null && solutionLatestVersionId != ''){
            for(Product_Reference__c prodRef : [SELECT Product__c,Product__r.OIPC_Code__c FROM Product_Reference__c WHERE Solution__c =: solutionLatestVersionId]){
                oipcCodeWithProductAndSol.put(prodRef.Product__r.OIPC_Code__c,prodRef.Product__c);
            }
        }
        
        //SFSE-12654 : query products by OIPC code to get the latest Product ID 
        list<Product2> prodList = new list<Product2>();
        /*if(!packagedSolutionProductIds.isEmpty()){
            prodList = [select id,OIPC_Code__c from Product2 where Id IN:packagedSolutionProductIds];
        }
        else*/
        if(!oipcCodes.isEmpty()){
            prodList = [select id,OIPC_Code__c from Product2 where IsActive = true and OIPC_Code__c IN:oipcCodes];       
        }
        
        map<string,id> oipcCodeWithProduct = new map<string,id>();

        //map of OIPC code and Product 
        for(Product2 prod:prodList){
            oipcCodeWithProduct.put(prod.OIPC_Code__c,prod.id);
        }
    
        //create Opportunitis
        map<id,Opportunity> oppToInsert =  createOpportunities(closedOpportunitties,oipcCodeWithProduct, oipcCodeWithProductAndSol,nonOIPCProductIds,opportunityProductList);
        
        //SFSE-15121
        if(!oppToInsert.isEmpty()){
           Database.saveResult[] srList  = Database.insert(oppToInsert.values(), FALSE); 
           ErrorLogger.writeErrors('SFDC', 'Opportunity Auto Renewal', 'BatchOpportunityAutoRenewal.createOpportunities', srList , oppToInsert.values());
           
            for(Id parentOpptyId: oppToInsert.keySet()){
                if(String.isBlank(oppToInsert.get(parentOpptyId).Id)){   
                 oppToInsert.remove(parentOpptyId);
                 oppIds.remove(parentOpptyId);
                 OpporuntiyIdWithOpportunityProduct.remove(parentOpptyId);                  
            }}            
        }                
        //SFSE-15121 - Added if condition
        if(!oppToInsert.isEmpty()){
        //Create OpportunityTeamMembers 
        createOpportunityTeamMembers(oppIds,oppToInsert);
        
        //create Opportunity Products and configurations
        createOpportunityProducts(oppToInsert.values(),OpporuntiyIdWithOpportunityProduct,nonOIPCProductIds,oipcCodeWithProduct,oipcCodeWithProductAndSol, solutionLatestVersionId);                
    
    }
    }
    
    
    //create Opportunities 
    public static  map<id,Opportunity> createOpportunities(List<Opportunity> parenOppList,  map<string,id> oipcCodeWithProduct, map<string,id> oipcCodeWithProductAndSol,set<id>  nonOIPCProductIds, list<Opportunity_Product__c> opportunityProductList)
    {           
        map<id,Opportunity> newOppToReturn = new map<id,Opportunity>();
        set<id> filteredOppIds = new set<id>();
        //filter the list oportunites to create based on Active Products 
        for(Opportunity_Product__c OppProduct: opportunityProductList){
            //Check opp has active products 
            if(oipcCodeWithProduct.containsKey(OppProduct.Product2ID__r.OIPC_Code__c) || nonOIPCProductIds.contains(OppProduct.Product2ID__c) || oipcCodeWithProductAndSol.containsKey(OppProduct.Product2ID__r.OIPC_Code__c) ){
                filteredOppIds.add(OppProduct.OpportunityId__c);
            }
        }
        
        for(Opportunity parentOpp:parenOppList){
            // Insert a renewed Opportunity 
            Opportunity opp  = new Opportunity();
            
            if(filteredOppIds.contains(parentOpp.id)){
                Integer numberDaysDue;
                Date formatedDate;
                String oppName;
                // Added this code as part of SFSE-15159  
                if(parentOpp.First_Shipment_Date__c!=NULL && parentOpp.Last_Shipment_Date__c!=NULL){
                   numberDaysDue = parentOpp.First_Shipment_Date__c.daysBetween(parentOpp.Last_Shipment_Date__c)+1;
                   opp.Last_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(numberDaysDue);
                   opp.First_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(1);                                         
                }
                   formatedDate = parentOpp.Last_Shipment_Date__c?.addDays(1); 
                
                if(parentOpp.Name.Contains('R - (')){
                    if(parentOpp.First_Shipment_Date__c!=NULL && formatedDate!=NULL){
                     oppName = String.valueOf(parentOpp.First_Shipment_Date__c.day()).length() == 2 ? 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name.substring(18, parentOpp.Name.length()) : 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name.substring(17, parentOpp.Name.length());   
                    }
                    else
                      oppName = 'R - '+parentOpp.Name;
                }
                else{
                  oppName = formatedDate!=NULL? 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name : 'R - '+parentOpp.Name;    
                  
                    if(oppName.length() > 120 ){
                        oppName = oppName.substring(0, 120);
                  }  
                }
                  opp.Name =  oppName;       
                       
                // Commented this code as part of SFSE-15159       
                /*Integer numberDaysDue = parentOpp.First_Shipment_Date__c.daysBetween(parentOpp.Last_Shipment_Date__c)+1;
                Date formatedDate = parentOpp.Last_Shipment_Date__c.addDays(1); 
                string oppName;
                if(parentOpp.Name.Contains('R - (')){
                     oppName = String.valueOf(parentOpp.First_Shipment_Date__c.day()).length() == 2 ? 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name.substring(18, parentOpp.Name.length()) : 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name.substring(17, parentOpp.Name.length());
                }else{
                     oppName = 'R - ('+formatedDate.day()+'-'+lookupMonthName(formatedDate)+'-'+formatedDate.year()+') '+parentOpp.Name;
                    
                    if(oppName.length() > 120 ){
                        oppName = oppName.substring(0, 120);
                    }
                }
                opp.Name =  oppName;//append the Opportunity Name with R-name 
                opp.Last_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(numberDaysDue);//Update Agreement dates Last_Shipment_Date__c=2023-07-20 00:00:00, First_Shipment_Date__c=2023-06-21 00:00:00,
                opp.First_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(1);*/                
                
                //SFSE-15512 - Added parentOpp.First_Shipment_Date__c NULL check
                if(parentOpp.Expected_Tender_Receipt_Date__c!= null && parentOpp.First_Round_Submission_Date__c!=null && parentOpp.First_Shipment_Date__c!=NULL){ 
                    Integer tenderReceiptDate = parentOpp.Expected_Tender_Receipt_Date__c.daysBetween(parentOpp.First_Shipment_Date__c); 
                    Integer firstroundSubmissionDate  = parentOpp.First_Round_Submission_Date__c.daysBetween(parentOpp.First_Shipment_Date__c);                     
                    opp.Expected_Tender_Receipt_Date__c=opp.First_Shipment_Date__c.addDays(-tenderReceiptDate);
                    opp.First_Round_Submission_Date__c=opp.First_Shipment_Date__c.addDays(-firstroundSubmissionDate);
                }
                opp.CloseDate=parentOpp.Last_Shipment_Date__c;
                
                string accountOwner;
                boolean isAccountOwnerActive = false;
                if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.MSL_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.MSL_Account_Owner__r.IsActive;
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MCC).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.MCC_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.MCC_Account_Owner__r.IsActive;                    
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEAGO).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.Seago_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.Seago_Account_Owner__r.IsActive;                      
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.SEALAND).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.SEA_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.SEA_Account_Owner__r.IsActive; 
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.HAMBURGSUD).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.HSUD_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.HSUD_Account_Owner__r.IsActive;                     
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.ALIANCA).contains(parentOpp.Liner_Brand__c)){
                    accountOwner = parentOpp.Account.Alianca_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.Alianca_Account_Owner__r.IsActive;                     
                }else if(BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MLL).contains(parentOpp.Liner_Brand__c)){  //SFSE-13703
                    accountOwner = parentOpp.Account.MLL_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.MLL_Account_Owner__r.IsActive;                     
                }
                
                //check if the owner Id is Active  
                if(parentOpp.Owner.IsActive){
                    opp.OwnerId=parentOpp.OwnerId;
                }else if(isAccountOwnerActive == true){
                    opp.OwnerId = accountOwner;
                }else{
                    opp.OwnerId = StaticFactory.getCurrentUserDetails().Id;
                } 
                
                opp.Parent_Opportunity__c = parentOpp.id; //Parent child relation 
                opp.StageName = 'Identifying'; // Mark as Identifying
                opp.Renewal_Opportunitity__c = true; // Mark as Renewed
                opp.Opportunity_contains_Dangerous_Goods__c = parentOpp.Opportunity_contains_Dangerous_Goods__c;
                opp.Customer_Type__c= parentOpp.Customer_Type__c;
                opp.Named_Account__c= parentOpp.Named_Account__c;
                opp.Expected_Handling_Rounds__c= parentOpp.Expected_Handling_Rounds__c;
                opp.Tender_Submission_Format__c=parentOpp.Tender_Submission_Format__c;
                opp.Customer_Requested_Rate_Structure__c=parentOpp.Customer_Requested_Rate_Structure__c;
                opp.AccountId=parentOpp.AccountId;
                opp.Cargo_Type__c= parentOpp.Cargo_Type__c;
                opp.Liner_Brand__c=parentOpp.Liner_Brand__c;                 
                opp.Implementation_Date__c=parentOpp.Implementation_Date__c;
                opp.RecordTypeId=parentOpp.RecordTypeId; 
                opp.Value_Proposition__c=parentOpp.Value_Proposition__c;
                opp.Primary_Contact__c=parentOpp.Primary_Contact__c;
                //If parent opp is closed lost then type is from parent opp and if its closed won then its Renewal.
                if(parentOpp.StageName == System.Label.Closed_lost){
                    opp.Type= parentOpp.Type;
                }else if(parentOpp.StageName == System.Label.close_won){
                    opp.Type= General_Key_Value_Configurations__mdt.getInstance('Renewal').First_Field_Value__c;
                }
                opp.Current_Contract_Number__c= parentOpp.Current_Contract_Number__c;
                opp.Strategic_Deal__c=parentOpp.Strategic_Deal__c; 
                opp.Double_Down__c=parentOpp.Double_Down__c;
                opp.Approval_Status__c ='';
                opp.Situation_in_Brief__c =parentOpp.Situation_in_Brief__c;
                opp.Requires_IT_Integration__c= parentOpp.Requires_IT_Integration__c;
                opp.Estimated_Agreement_Duration__c=parentOpp.Estimated_Agreement_Duration__c;
                opp.Offer_Type__c=parentOpp.Offer_Type__c;
                opp.Activity_Check__c=parentOpp.Activity_Check__c;
                opp.Freetime_Terms__c= parentOpp.Freetime_Terms__c;
                opp.Amount=opp.Amount;                
                opp.Controlled__c=parentOpp.Controlled__c;                 
                opp.Dry__c=parentOpp.Dry__c;
                opp.ForecastCategoryName=parentOpp.ForecastCategoryName; 
                opp.Lead_Route_Approval__c=parentOpp.Lead_Route_Approval__c; 
                opp.Move_To_Tender_Opp__c=parentOpp.Move_To_Tender_Opp__c;
                //opp.Must_Go_To_OMEB__c=parentOpp.Must_Go_To_OMEB__c;
                opp.NAC_Checked__c=parentOpp.NAC_Checked__c;
                opp.Named_Account_Products_Applicable__c=parentOpp.Named_Account_Products_Applicable__c;
                opp.Reefer__c=parentOpp.Reefer__c;
                opp.Request_Type__c=parentOpp.Request_Type__c;
                opp.Requires_IT_Integration__c= parentOpp.Requires_IT_Integration__c;
                opp.Sales_Qualified_Date__c=parentOpp.Sales_Qualified_Date__c;
                opp.Submitted_For_approval__c=parentOpp.Submitted_For_approval__c;
                opp.US_Flag_Carrier__c=parentOpp.US_Flag_Carrier__c;
                opp.Stakeholder_Mapping__c=parentOpp.Stakeholder_Mapping__c;
                opp.Uncovering_Customer_Needs__c=parentOpp.Uncovering_Customer_Needs__c;
                opp.Description=parentOpp.Description;
                opp.Framing_the_Challenge__c=parentOpp.Framing_the_Challenge__c;
                opp.Customer_Alignment__c=parentOpp.Customer_Alignment__c;
                opp.Need_SCD_Support__c=parentOpp.Need_SCD_Support__c;
                opp.Sustainability_support_needed__c=parentOpp.Sustainability_support_needed__c;
                opp.Other_Sustainability_Support_needed__c=parentOpp.Other_Sustainability_Support_needed__c;
                opp.Custom_L_S_Solution_Required__c=parentOpp.Custom_L_S_Solution_Required__c;
                opp.IT_Investment__c=parentOpp.IT_Investment__c;
                opp.Commodity__c=parentOpp.Commodity__c;                
                opp.Proposal_Presentation_Date__c=parentOpp.Proposal_Presentation_Date__c;
                opp.Account_Plan__c=parentOpp.Account_Plan__c;
                opp.Initiative__c=parentOpp.Initiative__c;
                opp.Lost_Product_Parent_Opportunity__c=parentOpp.Lost_Product_Parent_Opportunity__c;
                opp.CampaignId=parentOpp.CampaignId;
                opp.LeadSource=parentOpp.LeadSource;
                opp.Comments_for_Lead_source__c=parentOpp.Comments_for_Lead_source__c;
                opp.Customer_Journey__c = parentOpp.Customer_Journey__c;
                opp.Record_Locked__c = false;
            	opp.Reason_for_Unlocking__c = '';
            	opp.Opportunity_Unlocked_Date__c = null;
                newOppToReturn.put(parentOpp.id,opp);
            }
            
        }
        return newOppToReturn;
    }
    
    //create Opportunity Products 
    public static void createOpportunityProducts(list<Opportunity> listOpportunity, map<id,list<Opportunity_Product__c>> OpporuntiyIdWithOpportunityProduct,set<id> nonOIPCProductIds,map<string,id> oipcCodeWithProduct,map<string,id> oipcCodeWithProductAndSol, String solutionLatestVersionId){  
        //old oliid with new Oli 
        map<id,Opportunity_Product__c> oldOppwithNewOppMap = new  map<id,Opportunity_Product__c>();
        set<id> newProductIdSet = new set<id>();
      
        list<Opportunity_Product__c> oppProductList = new list<Opportunity_Product__c>();
        for(id oppId:OpporuntiyIdWithOpportunityProduct.keySet()){
            oppProductList.addAll(OpporuntiyIdWithOpportunityProduct.get(oppId));
        }
        
        
        for(Opportunity opprec:listOpportunity){
            for(Opportunity_Product__c opp:OpporuntiyIdWithOpportunityProduct.get(opprec.Parent_Opportunity__c)){
                Opportunity_Product__c customOLI;
                
                if( (oipcCodeWithProduct.containsKey(opp.Product2ID__r.OIPC_Code__c) && opp.solution__c == null ) || (nonOIPCProductIds.contains(opp.Product2ID__c) && opp.Product2ID__r.IsActive)  || oipcCodeWithProductAndSol.containsKey(opp.Product2ID__r.OIPC_Code__c) && opp.solution__c != null  ){
                    id product;

                    if(Opp.solution__c== null){
                        if(oipcCodeWithProduct.containsKey(opp.Product2ID__r.OIPC_Code__c)){
                            product = oipcCodeWithProduct.get(opp.Product2ID__r.OIPC_Code__c);
                            if(product != opp.Product2ID__c){
                                //Products woth new Version 
                                newProductIdSet.add(product);
                            }
                        }                
                        if(nonOIPCProductIds.contains(opp.Product2ID__c)){
                            product = opp.Product2ID__c;
                        }
                    }else{
                        if(oipcCodeWithProductAndSol.containsKey(opp.Product2ID__r.OIPC_Code__c)){
                            product = oipcCodeWithProductAndSol.get(opp.Product2ID__r.OIPC_Code__c);
                            if(product != opp.Product2ID__c){
                                //Products woth new Version 
                                newProductIdSet.add(product);
                            }
                        }
                    }
                        
                    if(product == null ){
                        Continue;
                    }

                    customOLI = new Opportunity_Product__c(     
                        OpportunityId__c= opprec.id,
                        Product2ID__c= product,
                        Solution__c = opp.Solution__c!= null?solutionLatestVersionId :null,
                        Name = opp.Name,
                        Actuals_Loaded__c= opp.Actuals_Loaded__c,
                        Amend_Gross_Profit_per_unit__c= opp.Amend_Gross_Profit_per_unit__c,
                        Amend_Expected_FFE__c= opp.Amend_Expected_FFE__c,
                        Blue_Collar_FTEs__c= opp.Blue_Collar_FTEs__c,
                        Building_Lease__c= opp.Building_Lease__c,
                        Cargo_Type__c= opp.Cargo_Type__c,
                        Comments__c= opp.Comments__c,
                        ServiceDate__c= opp.ServiceDate__c,
                        Debug__c= opp.Debug__c,
                        Direct_Variable_Cost__c= opp.Direct_Variable_Cost__c,
                        Discount__c= opp.Discount__c,
                        EBIT__c= opp.EBIT__c,
                        //Exclude_from_OMEB__c= opp.Exclude_from_OMEB__c,
                        Exclude_from_SIP__c= opp.Exclude_from_SIP__c,
                        Executing_City_State__c= opp.Executing_City_State__c,
                        Country__c = opp.Country__c,
                        Fixed_Costs__c= opp.Fixed_Costs__c,
                        UnitPrice__c= opp.UnitPrice__c,
                        Import_Export__c= opp.Import_Export__c,
                        Indirect_FTEs__c= opp.Indirect_FTEs__c,
                        IsWndProduct__c= opp.IsWndProduct__c,
                        L_S_Product__c= opp.L_S_Product__c,
                        Description__c= opp.Description__c,
                        List_Price__c= opp.List_Price__c ,
                        Material_Handling_Equipment_Investments__c= opp.Material_Handling_Equipment_Investments__c,
                        Ocean_Product__c= opp.Ocean_Product__c,
                        OpportyProductExtID__c= opp.OpportyProductExtID__c,
                        Opt_Out_Auto_Quantity_Scheduling__c= opp.Opt_Out_Auto_Quantity_Scheduling__c,
                        Capital_Expenditure__c= opp.Capital_Expenditure__c,
                        Total_Tender_FFE_per_Route_Direction__c= opp.Total_Tender_FFE_per_Route_Direction__c,
                       
                       // Power_Lanes__c= opp.Power_Lanes__c,
                        Previous_Tender_Target__c= opp.Previous_Tender_Target__c,
                        Quantity__c= opp.Quantity__c,
                        Schedule_Details__c= opp.Schedule_Details__c,
                        Schedule_Product__c= opp.Schedule_Product__c,
                        SG_A__c= opp.SG_A__c,
                        Special_Cargo__c= opp.Special_Cargo__c,
                        Subtotal__c= opp.Subtotal__c,
                        Tender_Target__c= opp.Tender_Target__c,
                        Total_Configurations__c= opp.Total_Configurations__c,
                        Total_Configurations_Filled__c= opp.Total_Configurations_Filled__c,
                        Total_Mandatory_Configuration__c= opp.Total_Mandatory_Configuration__c,
                        Total_Mandatory_Configuration_Filled__c= opp.Total_Mandatory_Configuration_Filled__c,
                        Trade_Guidance_Id__c= opp.Trade_Guidance_Id__c,
                        Trade_Route__c= opp.Trade_Route__c,
                        Warehouse_Site__c= opp.Warehouse_Site__c,
                        WND_Location_Type__c= opp.WND_Location_Type__c,
                        Commitment__c = opp.Commitment__c,
                        Destination_Country__c = opp.Destination_Country__c,
                        Product_Revenue_Per_Unit__c = opp.Product_Revenue_Per_Unit__c,
                        Product_Creation_Source__c = System.Label.Opportunity_Auto_Renewal,
                        Estimated_Footprint_Requirement_in_Sqm__c = opp.Estimated_Footprint_Requirement_in_Sqm__c
                        
                    );
    
                    oldOppwithNewOppMap.put(opp.id,customOLI);
                    
                }
            }
        }
               
        if(oldOppwithNewOppMap.size() > 0){
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
            bt.Skip_Validation__c = true;
            insert bt;
            /*
            try{              
                insert oldOppwithNewOppMap.values();             
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', new list<Exception>{ex});          
            } */
            
            //SFSE-15218
            Database.SaveResult[] SR1= Database.insert(oldOppwithNewOppMap.values(),FALSE);  
			ErrorLogger.writeErrors('SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', SR1, oldOppwithNewOppMap.values());
            
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
        }
        
        
        set<id> newProducts = new  set<id>();
        set<id> OldProducts = new  set<id>();
        //Create Opportunity Product Configurations for the products which are not updated with new version  
        List<Opportunity_Product_Configuration__c> lstProdConfigsToInsert = new List<Opportunity_Product_Configuration__c>();
        //query for product config 
        for(Opportunity_Product_Configuration__c prodConfig : [select id, name, Component_Code__c, Feature_Code__c, Opportunity_Product__c, Opportunity_Product_Cus__c, 
                                                               Product_Component__c, Product_Feature__c, Product_Specificaiton_Parameter__c, Product_Specification_Option__c, 
                                                               Specification_Option_Name__c, Specification_Option_Order__c, Specification_Parameter_Code__c, Is_Specification_Parameter_Included__c,
                                                               Is_Feature_Included__c,Configured_Product_Component__c,Configured_Product_Feature__c, Configured_Product_Feature__r.Name
                                                               FROM Opportunity_Product_Configuration__c 
                                                               WHERE Opportunity_Product_Cus__c IN :oldOppwithNewOppMap.keySet()]){
                                                                   if(!newProductIdSet.contains(oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).Product2ID__c)){                                                                          
                                                                       
                                                                       Opportunity_Product_Configuration__c prodConfigsToInsert = new Opportunity_Product_Configuration__c();
                                                                       prodConfigsToInsert.Product_Specificaiton_Parameter__c  = prodConfig.Product_Specificaiton_Parameter__c;
                                                                       prodConfigsToInsert.Product_Specification_Option__c  =  prodConfig.Product_Specification_Option__c;
                                                                       prodConfigsToInsert.Is_Specification_Parameter_Included__c = prodConfig.Is_Specification_Parameter_Included__c;
                                                                       prodConfigsToInsert.Is_Feature_Included__c = prodConfig.Is_Feature_Included__c;
                                                                       prodConfigsToInsert.Configured_Product_Component__c = prodConfig.Configured_Product_Component__c;
                                                                       prodConfigsToInsert.Configured_Product_Feature__c = prodConfig.Configured_Product_Feature__c;
                                                                       prodConfigsToInsert.Opportunity_Product_Cus__c = oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).Id;
                                                                       prodConfigsToInsert.Name = prodConfig.Configured_Product_Feature__r.Name;
                                                                       lstProdConfigsToInsert.add(prodConfigsToInsert);
                                                                   }else{
                                                                       newProducts.add(oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).id); //opp prod custom oli (with prod upgraded)
                                                                       OldProducts.add(prodConfig.Opportunity_Product_Cus__c); //corresponding custom oli's (new opp prod's) old oppty prod (with lower prod version)
                                                                   }
                                                               }
        //adjust the configurations based on the new version 
        if( newProducts.size() > 0 ){            
            lstProdConfigsToInsert.addAll(updateOpportunityConfigurations(newProducts,OldProducts));
        }
        
        if(lstProdConfigsToInsert.size() > 0){  
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt; 
            /*try{                            
                insert lstProdConfigsToInsert;
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', new list<Exception>{ex});
            }*/
            
            //SFSE-15218
            Database.SaveResult[] SR2= Database.insert(lstProdConfigsToInsert,FALSE);  
			ErrorLogger.writeErrors('SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', SR2, lstProdConfigsToInsert);
            
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
                delete btt;
        } 
    }
        
    public static List<Opportunity_Product_Configuration__c> updateOpportunityConfigurations(set<id> newProducts,set<id> OldProducts) {
    
         //Map<Id,Product_Feature__c> lstFeaturesTypeOption = new Map<Id,Product_Feature__c>;
         Set<Id> lstFeaturesTypeOption = new Set<Id>();
         map<id,id> newOppwithOldOppMap = new  map<id,id>();
        
         if (newProducts.size() == oldProducts.size()) {
             
            List<Id> newOpptyProductsList = new List<Id>(newProducts);
            List<Id> oldOpptyProdProductsList = new List<Id>(oldProducts);
        
            for (Integer i = 0; i < newOpptyProductsList.size(); i++) {
                newOppwithOldOppMap.put(newOpptyProductsList[i], oldOpptyProdProductsList[i]);
            }
        }
        
        //Create or delete Product Configuration 
        String profeatRecordTypeID = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
        //new
        list<Opportunity_Product__c> oppProdUpdated = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c from  Opportunity_Product__c where id In: newProducts];  //querying olis already inserted with new product version
        
        //new Map of Product and opty prod
        map<id,list<Opportunity_Product__c>> prodOppMap = new  map<id,list<Opportunity_Product__c>>();
        //new opty prod
        for(Opportunity_Product__c prod:oppProdUpdated){
            if(prodOppMap.containsKey(prod.Product2Id__c)){
                prodOppMap.get(prod.Product2Id__c).add(prod);
            }else{
                prodOppMap.put(prod.Product2Id__c,new list<Opportunity_Product__c>{prod});
            }
        }
        
        //old
        list<Opportunity_Product_Configuration__c> oppConfig = [select id,Name,Opportunity_Product_Cus__c,Opportunity_Product_Cus__r.Product2Id__c,Product_Specificaiton_Parameter__c,Specification_Parameter_Code__c,Specification_Option_Code__c,Is_Feature_Included__c,Is_Specification_Parameter_Included__c,
            Configured_Product_Component__c,Configured_Product_Feature__c,Feature_Default_Visibility__c,Specification_Param_Default_Visibility__c,Configured_Product_Feature__r.Feature_Code__c from Opportunity_Product_Configuration__c where Opportunity_Product_Cus__c In:OldProducts ];
        
        //old prod map psp and opc
        map<id,list<Opportunity_Product_Configuration__c>> psandPcMap = new  map<id,list<Opportunity_Product_Configuration__c>>();
        for(Opportunity_Product_Configuration__c pc:oppConfig){
            
            if(psandPcMap.containsKey(pc.Product_Specificaiton_Parameter__c)){
                psandPcMap.get(pc.Product_Specificaiton_Parameter__c).add(pc);
            }else{
                psandPcMap.put(pc.Product_Specificaiton_Parameter__c,new list<Opportunity_Product_Configuration__c>{pc});
            }
        }
        
        // query Product components new
        Map<Id, Product_Component__c> lstComponents = new Map<Id, Product_Component__c>([SELECT Id, Name, Component_Code__c, Product__c
                                                                                         FROM Product_Component__c 
                                                                                         WHERE Product__c IN:prodOppMap.keySet() ORDER BY Display_Order__c,Name]);
        
        // for above fetched components get Product Features new
        Map<Id,Product_Feature__c> lstFeatures = new Map<Id,Product_Feature__c>([SELECT Id, Name,Product_Component__c, Type__c, Value__c    , Default_Value__c, Options__c, Allow_Multiselect__c, Description__c,
                                                                                 Allow_None_Value__c, Value_Min__c, Value_Max__c, Value_Unit__c, Product_Component__r.Product__c, Choice_Required__c,Default_Visibility__c,Feature_Code__c //8854
                                                                                 FROM Product_Feature__c 
                                                                                 WHERE Product_Component__c in :lstComponents.keySet() AND RecordTypeId=:profeatRecordTypeID 
                                                                                 AND (Categorisation__c =: 'Service' OR Categorisation__c=:'') ORDER BY Display_Order__c,Name]);
        
        //new
        map<Id,Product_Specification_Parameter__c> mapofProdSpecParams = new Map<Id,Product_Specification_Parameter__c>([SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c, 
                                                                                                                         Product_Feature__r.Product_Component__r.Product__c,Product_Feature__r.Description__c,
                                                                                                                         Display_Order__c, Feature_Code__c,Product_Feature__r.Default_Visibility__c,Product_Feature__r.Product_Component__c,Description__c,Default_Visibility__c,
                                                                                                                         Product_Feature__r.Name FROM Product_Specification_Parameter__c  
                                                                                                                         WHERE Product_Feature__c in :lstFeatures.keySet() AND Type__c='options']); // and Configurable_at_Contracting__c = true]);
        
         map<string,Product_Specification_Parameter__c> SpcodetoSp = new map<string,Product_Specification_Parameter__c>();
                for(Product_Specification_Parameter__c sp:mapofProdSpecParams.values()){
                    SpcodetoSp.put(sp.Specification_Parameter_Code__c,sp);                
                }
        
        //specification parameter code vs Spec option code 
        map<string,string> specParamCodeToSpecOptionCode = new map<string,string>();
            map<string,list<Opportunity_Product_Configuration__c>> specParamCodeToconfiguration = new map<string,list<Opportunity_Product_Configuration__c>>();
            set<string> OptionstoQuery = new set<string>();
        

        map<String,Opportunity_Product_Configuration__c> mapofExistingFeature = new map<String,Opportunity_Product_Configuration__c>();
        for(Opportunity_Product_Configuration__c oppPc:oppConfig){           
                
                if(SpcodetoSp.containsKey(oppPc.Specification_Parameter_Code__c)){ 
                    
                    specParamCodeToSpecOptionCode.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.id,oppPc.Specification_Option_Code__c);
                    
                    if(!specParamCodeToconfiguration.containsKey(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c)){
                        specParamCodeToconfiguration.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c,new list<Opportunity_Product_Configuration__c> {oppPc});
                    }else{
                        specParamCodeToconfiguration.get(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Specification_Parameter_Code__c).add(oppPc);
        }
        
                    if( oppPc.Specification_Option_Code__c != null){
                        OptionstoQuery.add(oppPc.Specification_Option_Code__c);
                    }                     
                }

                if(oppPc.Product_Specificaiton_Parameter__c == null && oppPc.Is_Feature_Included__c ){
                    if(!mapofExistingFeature.containsKey(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Configured_Product_Feature__r.Feature_Code__c)){
                        mapofExistingFeature.put(oppPc.Opportunity_Product_Cus__c+'-'+oppPc.Configured_Product_Feature__r.Feature_Code__c, oppPc);
                    }
                }
            }
        
        map<string,Id> spocTospocId = new map<string,Id>();
        //Query Specification options by code and get the new list and prepare a map of SPOC vs SPO ID
        list<Product_Specification_Option__c> spOption = [SELECT id,Specification_Option_Code__c,Product_Specification_Parameter__c,Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__r.name from Product_Specification_Option__c 
                                                              WHERE Specification_Option_Code__c In:OptionstoQuery AND 
                                                              Product_Specification_Parameter__c IN :mapofProdSpecParams.keyset() AND
                                                              Product_Specification_Parameter__r.Product_Feature__r.Product_Component__r.Product__c IN:prodOppMap.keySet()];
            
        for(Product_Specification_Option__c spo:spOption){
            spocTospocId.put( spo.Product_Specification_Parameter__c + spo.Specification_Option_Code__c,spo.id);
        }
            
        
        Set<String> featMatrix = new Set<String>();
        Map<String,String> matrixMap = new Map<String,String>();
        for(SP_Visibility_matrix__mdt rec :  SP_Visibility_matrix__mdt.getAll().values()){
            if(rec.Product_Upgrade__c==true){
                matrixMap.put(rec.Default_Visibility_Features__c+'-'+rec.Default_Visibility_SP__c,rec.Default_Visibility_SP__c);
                featMatrix.add(rec.Default_Visibility_Features__c);
            }
        }
        
        list<Opportunity_Product_Configuration__c> listofConfigToCreate = new list<Opportunity_Product_Configuration__c>();
        
        for(Product_Specification_Parameter__c ps:mapofProdSpecParams.values()){
            lstFeaturesTypeOption.add(ps.Product_Feature__c);
            for(Opportunity_Product__c opc: prodOppMap.get(ps.Product_Feature__r.Product_Component__r.Product__c)){
                list<Opportunity_Product_Configuration__c> configRec = new list<Opportunity_Product_Configuration__c>();   
                     if(specParamCodeToconfiguration.containsKey(newOppwithOldOppMap.get(opc.Id)+'-'+ps.Specification_Parameter_Code__c)) { 
                        configRec = specParamCodeToconfiguration.get(newOppwithOldOppMap.get(opc.Id)+'-'+ps.Specification_Parameter_Code__c); 
                    }
                    
                //Update the configuration with new version of the SP and Options 
                    if(configRec.size()>0){
                        for(Opportunity_Product_Configuration__c config:configRec){  
                                string optionCode = specParamCodeToSpecOptionCode.get(newOppwithOldOppMap.get(opc.Id)+'-'+config.id);
                                Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                                opcObj.Opportunity_Product_Cus__c  = opc.id;
                                opcObj.Product_Specificaiton_Parameter__c  =  ps.id;
                                opcObj.Product_Specification_Option__c  =  spocTospocId.containsKey( ps.id + optionCode) ?spocTospocId.get( ps.id + optionCode): null ;
                                opcObj.Name = ps.Product_Feature__r.Name;
                                //opcObj.Name = ps.Name;
                                opcObj.Is_Specification_Parameter_Included__c = config.Is_Specification_Parameter_Included__c;
                                opcObj.Is_Feature_Included__c = config.Is_Feature_Included__c;
                                opcObj.Configured_Product_Component__c = ps.Product_Feature__r.Product_Component__c;
                                opcObj.Configured_Product_Feature__c = ps.Product_Feature__c;
                                listofConfigToCreate.add(opcObj);
                              }
                      }else {
                        if((matrixMap.get(ps.Product_Feature__r.Default_Visibility__c+'-'+ps.Default_Visibility__c)=='INCLUDED') && ps.Type__c=='options'){  //to check if both Featue and SP are included
                        Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                        opcObj.Opportunity_Product_Cus__c  = opc.id;
                        opcObj.Product_Specificaiton_Parameter__c  =  ps.id;
                        opcObj.Name = ps.Product_Feature__r.Name;
                        //opcObj.Name = ps.Name;
                        opcObj.Is_Specification_Parameter_Included__c = true;
                        opcObj.Is_Feature_Included__c = true;
                        opcObj.Configured_Product_Component__c = ps.Product_Feature__r.Product_Component__c;
                        opcObj.Configured_Product_Feature__c = ps.Product_Feature__c;
                        listofConfigToCreate.add(opcObj);  
                    } 
                }
            }
        }
        
        
        //feature only config records as per matrix
        for(Product_Feature__c pf : lstFeatures.values()) {
                for(Opportunity_Product__c opc: prodOppMap.get(pf.Product_Component__r.Product__c)){
                    if(mapofExistingFeature.containsKey(newOppwithOldOppMap.get(opc.Id)+'-'+pf.Feature_Code__c)) { 
                        Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                        opcObj.Opportunity_Product_Cus__c  = opc.id;
                        opcObj.Name = pf.Name;
                        opcObj.Is_Feature_Included__c = true;
                        opcObj.Configured_Product_Component__c = pf.Product_Component__c;
                        opcObj.Configured_Product_Feature__c = pf.Id;
                        listofConfigToCreate.add(opcObj);
                }else{
                    if(lstFeaturesTypeOption.contains(pf.Id) && featMatrix.contains(pf.Default_Visibility__c)){
                        Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                        opcObj.Opportunity_Product_Cus__c  = opc.id;
                        opcObj.Name = pf.Name;
                        opcObj.Is_Feature_Included__c = true;
                        opcObj.Configured_Product_Component__c = pf.Product_Component__c;
                        opcObj.Configured_Product_Feature__c = pf.Id;
                        listofConfigToCreate.add(opcObj);
                    }
                }
            } 
        }
        
        /*if(listofConfigToCreate.size() > 0){
            try{
                insert listofConfigToCreate;
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.updateOpportunityConfigurations', new list<Exception>{ex});
            }
        }*/
        return listofConfigToCreate;
    }
      
    //Create Opportunity TeamMembers 
    public static void createOpportunityTeamMembers(set<id> oldOppIds,  map<id,Opportunity> newOpportunities){
        list<OpportunityTeamMember> teamMemberstoInsert = new list<OpportunityTeamMember>(); 
        list<OpportunityTeamMember> teamMembers ;
        map<id,list<OpportunityTeamMember>> oppIdwithOpportunityTeam = new  map<id,list<OpportunityTeamMember>>();
        if(oldOppIds.size()>0){
            teamMembers = [Select id,OpportunityAccessLevel,Opportunity_Team_Member_Counter__c,TCM_Product__c,TeamMemberRole,User.IsActive,UserId,OpportunityId from OpportunityTeamMember where OpportunityId In:oldOppIds and User.IsActive= true];
        }
        
        for(OpportunityTeamMember oppTeamMember:teamMembers){
            if(oppIdwithOpportunityTeam.containsKey(oppTeamMember.OpportunityId)){
                oppIdwithOpportunityTeam.get(oppTeamMember.OpportunityId).add(oppTeamMember);
            }else{
                oppIdwithOpportunityTeam.put(oppTeamMember.OpportunityId, new list<OpportunityTeamMember>{oppTeamMember});
            }
        }
        
        for(id oppId:oppIdwithOpportunityTeam.keyset()){
            for(OpportunityTeamMember oppMember:oppIdwithOpportunityTeam.get(oppId)){
                if(oppMember.TeamMemberRole != 'Opportunity Owner'){
                    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                    oppTeamMember.OpportunityAccessLevel = oppMember.OpportunityAccessLevel;
                    oppTeamMember.TCM_Product__c = oppMember.TCM_Product__c;
                    oppTeamMember.TeamMemberRole = oppMember.TeamMemberRole;
                    oppTeamMember.UserId = oppMember.UserId;
                    oppTeamMember.OpportunityId = newOpportunities.get(oppMember.OpportunityId).id;
                    teamMemberstoInsert.add(oppTeamMember);
                }
            }
        }
        
        if(teamMemberstoInsert.size() > 0){
            /*try{
                insert  teamMemberstoInsert;
            }catch(Exception ex){
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityTeamMembers', new list<Exception>{ex});
            }*/
            //SFSE-15218
            Database.SaveResult[] SR3= Database.insert(teamMemberstoInsert,FALSE);  
			ErrorLogger.writeErrors('SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityTeamMembers', SR3, teamMemberstoInsert);
        }
    }
    
    private static String lookupMonthName(Date d){
        Map<Integer,String> monthNames = new Map<Integer,String>{
            1 => 'JAN',
                2 => 'FEB',
                3 => 'MAR',
                4 => 'APR',
                5 => 'MAY',
                6 => 'JUN',
                7 => 'JUL',
                8 => 'AUG',
                9 => 'SEP',
                10 => 'OCT',
                11 => 'NOV',
                12 => 'DEC'
                };
                    try {
                        return monthNames.get(d.month());
                    } catch(NullPointerException e) {
                        return NULL;
                    }
    }        
    
    //13548 method should return renewals closeddate notification
    public static map<String,Decimal> getRenewalsClosedDateNotification(){
    map<String,Decimal>mapCDNotificationDays = new map<String,Decimal>();
    List<Renewals_Closed_Date_Notification__mdt> listCountryCode = Renewals_Closed_Date_Notification__mdt.getAll().values();
     for(Renewals_Closed_Date_Notification__mdt c : listCountryCode){
            mapCDNotificationDays.put(c.Start_Months__c+'-'+c.End_Months__c,c.Notification_before_days__c);
        }
    return mapCDNotificationDays;
    }
    
    //13548 method to return the range of renewals closeddate notification
    public static String fetchXNotifyDays(Decimal actualDuration,set<String>monthRanges){
        String returnStr='';
        for(String str:monthRanges){
            List<String> months = str.split('-');
            String startMonth = months[0];
            String endMonth = String.isNotBlank(months[1]) ? months[1] : null;
            if(startMonth!='null' && endMonth!='null' && actualDuration>=Integer.valueof(startMonth) && actualDuration<=Integer.valueof(endMonth)){
                returnStr = str;    
            } 
            else if(actualDuration>=Integer.valueof(startMonth)){
                returnStr = str;      
            }
          }  
       if(returnStr!=null)
            return returnStr;
        else
            return null;
     }
     
    
    //13548 method added to send single email message
    public static void sendEmailToRenewalOpp(List<opportunity>oppList,Map<Id,Decimal>mapCDNotificationDays){
    EmailTemplate templateId = [SELECT Id, DeveloperName,Body,Subject FROM EmailTemplate WHERE DeveloperName = 'RenewalOppNotifyEmail' AND TemplateType = 'Visualforce'];
    system.debug('==templateId=='+templateId);
    OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address=:system.label.OneClickOWDdisplayName LIMIT 1];
    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(opportunity opp:oppList){
        PageReference pg = Page.RenewalOppReminderNotifyEmail;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Integer xDays;
                Date reminderDate;
                if(mapCDNotificationDays!=null && mapCDNotificationDays.containskey(opp.Id) && mapCDNotificationDays.get(opp.Id)!=null){
                    xDays = Integer.valueof(mapCDNotificationDays.get(opp.Id));
                }
                reminderDate = opp.CloseDate.addDays(-xDays);
                if(system.today()==reminderDate){
                    pg.getParameters().put('renewalOppRecId',opp.Id);
                    pg.getParameters().put('renewalOppOwnerName',opp.owner.name);
                    pg.getParameters().put('accountId',opp.accountId);
                    pg.getParameters().put('closeddate',String.valueof(opp.CloseDate));
                    pg.getParameters().put('oppName',opp.Name);
                    pg.getParameters().put('renewalParentOppName',opp.Parent_Opportunity__r.Name);
                    pg.getParameters().put('renewalParentOppId',opp.Parent_Opportunity__c);
                    pg.getParameters().put('oppAgreementEndDate',String.valueof(opp.Parent_Opportunity__r.Last_Shipment_Date__c));
                    if(mapCDNotificationDays!=null && mapCDNotificationDays.containskey(opp.Id) && mapCDNotificationDays.get(opp.Id)!=null){
                        pg.getParameters().put('xDays',string.valueof(mapCDNotificationDays.get(opp.Id)));
                    }
                    pg.getParameters().put('renewalParentOppContractNumber',opp.Parent_Opportunity__r.Current_Contract_Number__c);
                    mail.setTargetObjectId(opp.OwnerId);
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    String sub;
                    if(mapCDNotificationDays!=null && mapCDNotificationDays.containskey(opp.Id) && mapCDNotificationDays.get(opp.Id)!=null){
                        sub = 'Reminder about your renewal - '+mapCDNotificationDays.get(opp.Id)+' days remaning ';
                    }
                    String htmlbody;
                    if(test.isrunningTest()){
                        htmlbody = 'Hi Hello';
                    }
                    else{
                        htmlbody= pg.getContent().toString();
                    }
                    
                    mail.setSubject(sub);
                    mail.setHtmlBody(htmlbody);
                    mailList.add(mail);    
                }
        }
        
        if(mailList.size()>0){
            Messaging.sendEmail(mailList);
        }
    }
    
    //Wrapper class to store parent product ans parent quantities
    public class productQuantities{
        public String parentProduct{get;set;}
        public String parentQuantities{get;set;}
        
        public productQuantities(String parentProd,String parentQuantity){
            parentProduct = parentProd;
            parentQuantities = parentQuantity;
        }
    }
    
    
}