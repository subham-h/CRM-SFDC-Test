/*
* Version	Date			Owner					RQ#					Description
***********************************************************************************************************************************************
* 1.0		16/06/2023		sriram@Maersk					-           Batch to AutoRenew Closed won opportunities 
* 
*/
public class BatchOpportunityAutoRenewal implements Database.Batchable<SObject>  {
    private set<Id> OpportunityIds;
    
    public BatchOpportunityAutoRenewal(set<Id> OpportunityIds){       
        this.OpportunityIds = OpportunityIds;
    }
    
    public Database.QueryLocator start( Database.BatchableContext BC ){
        String soqlQuery = '';
        
        /*Date nthday = system.today().addDays(30);
        String closedwon = 'Closed Won';
        String renewal  = 'Renewal';
        String Acquisition  = 'Acquisition';*/
        
        set<Id> Ids = OpportunityIds;//'0067Y00000M54unQAB';
        
      // String shipingandCargorRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Shipping & Cargo Services').getRecordTypeId();
       // String supplyChainRecTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Supply Chain Services').getRecordTypeId();
        
        soqlQuery = 'SELECT Id,CloseDate,Comments_for_Lead_source__c,Owner.IsActive,Account.HSUD_Account_Owner__c,Account.HSUD_Account_Owner__r.IsActive,Account.Alianca_Account_Owner__c,Account.Alianca_Account_Owner__r.IsActive,Account.Seago_Account_Owner__c,Account.Seago_Account_Owner__r.IsActive,Account.MCC_Account_Owner__c,Account.MCC_Account_Owner__r.IsActive,Account.MSL_Account_Owner__c,Account.MSL_Account_Owner__r.IsActive,Account.MLL_Account_Owner__c,Account.MLL_Account_Owner__r.IsActive,Account.SEA_Account_Owner__c,Account.SEA_Account_Owner__r.IsActive,AccountId,Account_Plan__c,Initiative__c,Activity_Check__c,Freetime_Terms__c,Last_Shipment_Date__c,First_Shipment_Date__c,Amount,Approval_Status__c,Liner_Brand__c,'
            +'CampaignId,Actual__c,Cargo_Type__c,Clone_Opportunity_Source__c,Description,Controlled__c,Count_of_AFLS_Quotes__c,Create_By_Using__c,Current_Contract_Number__c,Custom_L_S_Solution_Required__c,Customer_Alignment__c,'
            +'Primary_Contact__c,Customer_Interested_in__c,Customer_Requested_Rate_Structure__c,Customer_Type__c,Legacy_ExtID__c,Destination__c,Double_Down__c,Dry__c,Estimated_Agreement_Duration__c,Expected_Handling_Rounds__c,ExpectedRevenue,Expected_Tender_Receipt_Date__c,'
            +'First_Round_Submission_Date__c,First_Time_Closed_Date__c,ForecastCategoryName,Framing_the_Challenge__c,Freetime_Terms_Comments__c,Implementation_Date__c,Enforceable_Contract__c,IT_Investment__c,Lead_Id__c,Lead_Route__c,'
            +'Lead_Route_Approval__c,Lead_Route_Approval_By__c,LeadSource,Legacy_System__c,Lost_Product_Parent_Opportunity__c,Move_To_Tender_Opp__c,Must_Go_To_OMEB__c,NAC_Checked__c,Named_Account__c,Named_Account_Products_Applicable__c,NAP_Comment__c,Need_SCD_Support__c,'
            +'NextStep,Next_Steps__c,Offer_Type__c,Opp_Line_Item_Quantity_Manually_Changed__c,Opp_Owners_Manager__c,Actual_Average_Est_CY__c,Opportunity_contains_Dangerous_Goods__c,Opportunity_Legacy_Id__c,Name,OwnerId,RecordTypeId,Type,Other_Sustainability_Support_needed__c,Parent_Opportunity__c,'
            +'Who_takes_the_risk_on_BAF_fluctuations__c,Tender_Submission_Format__c,Premium_Competitor__c,Premium_Over_Competition__c,Previous_Stage__c,Pricebook2Id,Strategic_Deal__c,Probability,Products_for_Approval__c,Proposal_Presentation_Date__c,Reefer__c,Commodity__c,Request_Type__c,Requires_IT_Integration__c,Sales_Qualified_Date__c,StageName,Send_To_mail__c,SendEmail_User__c,Situation_in_Brief__c,Special_Cargo__c,'
            +'Special_T_Cs__c,special_terms_comments__c,TCM_SPOC__c,Stakeholder_Mapping__c,Submitted_For_approval__c,Subsequent_Round_Receipt_Date__c,Sustainability_support_needed__c,SyncedQuoteId,Tactics__c,TCM_Involvement_Required__c,Tender_Type__c,Total_Committed_FFE__c,Uncovering_Customer_Needs__c,US_Flag_Carrier__c,Value_Proposition__c,VIP_Deal__c'  
            //  +' FROM  Opportunity WHERE StageName = \'' + closedwon + '\' and (Type = \'' + renewal + '\' OR Type = \'' + Acquisition + '\') and (RecordTypeId = \'' +shipingandCargorRecTypeId+'\' OR RecordTypeId = \''+supplyChainRecTypeId+'\') and Last_Shipment_Date__c =:nthday';
            +' FROM  Opportunity WHERE Id In: Ids';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute( Database.BatchableContext info,  List<Opportunity> Scope ){
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        set<id> oppIds = new set<id>();
        set<string> oipcCodes  = new set<string>();
        set<id> nonOIPCProductIds = new set<id>();
        map<id,list<Opportunity_Product__c>> OpporuntiyIdWithOpportunityProduct = new  map<id,list<Opportunity_Product__c>>();
        
        
        System.debug('Scope-->'+Scope );
        for(Opportunity parentOpp:Scope){
            oppIds.add(parentOpp.id);
        }
        
        
        //query Opporunity products based on Opportunity
        list<Opportunity_Product__c> opportunityProductList = [SELECT Id, Name,Commitment__c,Actuals_Loaded__c,Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c,
                                                               Blue_Collar_FTEs__c,Building_Lease__c,Cargo_Type__c,Comments__c,ServiceDate__c,Debug__c,
                                                               Direct_Variable_Cost__c,Discount__c,EBIT__c,Exclude_from_OMEB__c,Exclude_from_SIP__c,
                                                               HasSchedule__c,Executing_City_State__c,Country__c,Fixed_Costs__c,UnitPrice__c,Import_Export__c,
                                                               Indirect_FTEs__c,Invalid_Warehouse_Site__c,IsWndProduct__c,L_S_Product__c,Legacy_Opportuntity_LineItemId__c,
                                                               Description__c,List_Price__c,Material_Handling_Equipment_Investments__c,Nominated_Quantity__c,
                                                               Ocean_Product__c,OpportunityId__c,OpportuntityLineItemId__c,OpportyProductExtID__c,Opt_Out_Auto_Quantity_Scheduling__c,
                                                               Capital_Expenditure__c,Total_Tender_FFE_per_Route_Direction__c,Power_Lanes__c,Previous_Tender_Target__c,Product2ID__c,Product2ID__r.OIPC_Code__c,Product2ID__r.IsActive,ProductCode__c,
                                                               Quantity__c,Schedule_Details__c,Schedule_Product__c,SG_A__c,Special_Cargo__c,Subtotal__c,Tender_Target__c,Total_Configurations__c,
                                                               Total_Configurations_Filled__c,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c,Trade_Guidance_Id__c,Trade_Route__c,
                                                               Warehouse_Site__c,WND_Location_Type__c from Opportunity_Product__c where OpportunityId__c IN:oppIds];
        
        
        
        for(Opportunity_Product__c opportunityProdcut:opportunityProductList){
            
            //Get the product ids and OIPCS code to query products 
            if(opportunityProdcut.Product2ID__r.OIPC_Code__c != NULL){ 
                oipcCodes.add(opportunityProdcut.Product2ID__r.OIPC_Code__c);
            }else{
                nonOIPCProductIds.add(opportunityProdcut.Product2ID__c);
            }   
            
            //Map of Opportunity id and Opportunity Product
            if(OpporuntiyIdWithOpportunityProduct.containsKey(opportunityProdcut.OpportunityId__c)){
                OpporuntiyIdWithOpportunityProduct.get(opportunityProdcut.OpportunityId__c).add(opportunityProdcut);
                
            }else{
                OpporuntiyIdWithOpportunityProduct.put(opportunityProdcut.OpportunityId__c,new list<Opportunity_Product__c>{opportunityProdcut});
            }
            
        }
        
        //query products by OIPC code to get the latest Product ID 
        
        list<Product2> prodList = [select id,OIPC_Code__c from Product2 where IsActive = true and OIPC_Code__c IN:oipcCodes];       
        map<string,id> oipcCodeWithProduct = new map<string,id>();
        //map of OIPC code and Product 
        for(Product2 prod:prodList){
            oipcCodeWithProduct.put(prod.OIPC_Code__c,prod.id);
        }
        
        
        //create Opportunitis
        list<Opportunity> oppToInsert =  createOpportunities(Scope,oipcCodeWithProduct,nonOIPCProductIds,opportunityProductList);
        
        if(oppToInsert.size() > 0){
            try{
                insert oppToInsert;
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunities', new list<Exception>{ex});
            }
        }
        
        system.debug('oppToInsert data '+oppToInsert[0].id);  
        
        //Create OpportunityTeamMembers 
        createOpportunityTeamMembers(oppIds,oppToInsert);
        
        //create Opportunity Products and configurations
        createOpportunityProducts(oppToInsert,OpporuntiyIdWithOpportunityProduct,nonOIPCProductIds,oipcCodeWithProduct);
        
        
        
        
    }
    
    public void finish( Database.BatchableContext BC ) {
    }
    
    //create Opportunities 
    public list<Opportunity> createOpportunities(List<Opportunity> parenOppList,  map<string,id> oipcCodeWithProduct,set<id>  nonOIPCProductIds, list<Opportunity_Product__c> opportunityProductList)
    {           
        
        
        List<Opportunity> newOppToReturn = new List<Opportunity>();
        set<id> filteredOppIds = new set<id>();
        
        
        
        //filter the list oportunites to create based on Active Products 
        for(Opportunity_Product__c OppProduct: opportunityProductList){
            //Check opp has active products 
            if(oipcCodeWithProduct.containsKey(OppProduct.Product2ID__r.OIPC_Code__c) || nonOIPCProductIds.contains(OppProduct.Product2ID__c)){
                filteredOppIds.add(OppProduct.OpportunityId__c);
            }
        }
        
        
        for(Opportunity parentOpp:parenOppList){
            // Insert a renewed Opportunity 
            Opportunity opp  = new Opportunity();
            
            if(filteredOppIds.contains(parentOpp.id)){
                Integer numberDaysDue = parentOpp.First_Shipment_Date__c.daysBetween(parentOpp.Last_Shipment_Date__c)+1;
                
                opp.Name = 'R-'+parentOpp.Name; //append the Opportunity Name with R-name 
                opp.Last_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(numberDaysDue);//Update Agreement dates Last_Shipment_Date__c=2023-07-20 00:00:00, First_Shipment_Date__c=2023-06-21 00:00:00,
                opp.First_Shipment_Date__c = parentOpp.Last_Shipment_Date__c.addDays(1);
                
                if( parentOpp.Expected_Tender_Receipt_Date__c!= null &&  parentOpp.First_Round_Submission_Date__c!=null){ 
                    Integer tenderReceiptDate = parentOpp.Expected_Tender_Receipt_Date__c.daysBetween(parentOpp.First_Shipment_Date__c); 
                    Integer firstroundSubmissionDate  = parentOpp.First_Round_Submission_Date__c.daysBetween(parentOpp.First_Shipment_Date__c); 
                    
                    opp.Expected_Tender_Receipt_Date__c=opp.First_Shipment_Date__c.addDays(-tenderReceiptDate);
                    opp.First_Round_Submission_Date__c=opp.First_Shipment_Date__c.addDays(-firstroundSubmissionDate);
                }
                
                string accountOwner;
                boolean isAccountOwnerActive = false;
                if(parentOpp.Liner_Brand__c == 'Maersk Line'){
                    accountOwner = parentOpp.Account.MSL_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.MSL_Account_Owner__r.IsActive;
                }else if(parentOpp.Liner_Brand__c == 'MCC'){
                    accountOwner = parentOpp.Account.MCC_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.MCC_Account_Owner__r.IsActive;                    
                }else if(parentOpp.Liner_Brand__c == 'Seago'){
                    accountOwner = parentOpp.Account.Seago_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.Seago_Account_Owner__r.IsActive;                      
                }else if(parentOpp.Liner_Brand__c == 'Sealand'){
                    accountOwner = parentOpp.Account.SEA_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.SEA_Account_Owner__r.IsActive; 
                }else if(parentOpp.Liner_Brand__c == 'Hamburg Sud'){
                    accountOwner = parentOpp.Account.HSUD_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.HSUD_Account_Owner__r.IsActive;                     
                }else if(parentOpp.Liner_Brand__c =='Alianca'){
                    accountOwner = parentOpp.Account.Alianca_Account_Owner__c;
                    isAccountOwnerActive = parentOpp.Account.Alianca_Account_Owner__r.IsActive;                     
                }
                
                //check if the owner Id is Active  
                if(parentOpp.Owner.IsActive){
                    opp.OwnerId=parentOpp.OwnerId;
                }else if(isAccountOwnerActive == true){
                    opp.OwnerId = accountOwner;
                }else{
                    opp.OwnerId = '0052o000008VHerAAG';
                } 
                
                  
                opp.Parent_Opportunity__c = parentOpp.id;//Parent child relation 
                opp.StageName = 'Identifying'; // Mark as Identifying
                opp.Renewal_Opportunitity__c = true;// Mark as Renewed
                ////////////////////////////////////////////////////
                opp.Customer_Type__c= parentOpp.Customer_Type__c;
                opp.Named_Account__c= parentOpp.Named_Account__c;
                // opp.Go_Live_Date__c= parentOpp.Go_Live_Date__c;                
                opp.Expected_Handling_Rounds__c= parentOpp.Expected_Handling_Rounds__c;
                opp.Tender_Submission_Format__c=parentOpp.Tender_Submission_Format__c;
                opp.Customer_Requested_Rate_Structure__c=parentOpp.Customer_Requested_Rate_Structure__c;
                opp.AccountId=parentOpp.AccountId;
                opp.CloseDate=parentOpp.CloseDate;
                opp.Liner_Brand__c=parentOpp.Liner_Brand__c;                 
                opp.Implementation_Date__c=parentOpp.Implementation_Date__c;
                opp.RecordTypeId=parentOpp.RecordTypeId; 
                opp.Value_Proposition__c=parentOpp.Value_Proposition__c;
                opp.Primary_Contact__c=parentOpp.Primary_Contact__c;
                opp.Type= 'Renewal';
                opp.Strategic_Deal__c=parentOpp.Strategic_Deal__c; 
                opp.Double_Down__c=parentOpp.Double_Down__c;
                opp.Approval_Status__c =parentOpp.Approval_Status__c;
                opp.Situation_in_Brief__c =parentOpp.Situation_in_Brief__c;
                opp.Requires_IT_Integration__c= parentOpp.Requires_IT_Integration__c;
                opp.Estimated_Agreement_Duration__c=parentOpp.Estimated_Agreement_Duration__c;
                opp.Offer_Type__c=parentOpp.Offer_Type__c;
                opp.Activity_Check__c=parentOpp.Activity_Check__c;
                opp.Freetime_Terms__c= parentOpp.Freetime_Terms__c;
                opp.Amount=opp.Amount;                
                opp.Controlled__c=parentOpp.Controlled__c;                 
                opp.Dry__c=parentOpp.Dry__c;        
                opp.First_Time_Closed_Date__c=parentOpp.First_Time_Closed_Date__c; 
                opp.ForecastCategoryName=parentOpp.ForecastCategoryName; 
                opp.Lead_Route_Approval__c=parentOpp.Lead_Route_Approval__c; 
                opp.Move_To_Tender_Opp__c=parentOpp.Move_To_Tender_Opp__c;
                opp.Must_Go_To_OMEB__c=parentOpp.Must_Go_To_OMEB__c;
                opp.NAC_Checked__c=parentOpp.NAC_Checked__c;
                opp.Named_Account_Products_Applicable__c=parentOpp.Named_Account_Products_Applicable__c;
                //opp.Probability= parentOpp.Probability;
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
                
                
                newOppToReturn.add(opp);
            }
            
        }
        return newOppToReturn;
    }
    
    //create Opportunity Products 
    public void createOpportunityProducts(list<Opportunity> listOpportunity, map<id,list<Opportunity_Product__c>> OpporuntiyIdWithOpportunityProduct,set<id> nonOIPCProductIds,map<string,id> oipcCodeWithProduct)
    {  
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
                
                if(oipcCodeWithProduct.containsKey(opp.Product2ID__r.OIPC_Code__c) || nonOIPCProductIds.contains(opp.Product2ID__c)){
                    id product;
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
                    
                    
                    customOLI = new Opportunity_Product__c(     
                        OpportunityId__c= opprec.id,
                        Product2ID__c= product,
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
                        Exclude_from_OMEB__c= opp.Exclude_from_OMEB__c,
                        Exclude_from_SIP__c= opp.Exclude_from_SIP__c,
                        Executing_City_State__c= opp.Executing_City_State__c,
                        Country__c = opp.Country__c,
                        Fixed_Costs__c= opp.Fixed_Costs__c,
                        UnitPrice__c= opp.UnitPrice__c,
                        Import_Export__c= opp.Import_Export__c,
                        Indirect_FTEs__c= opp.Indirect_FTEs__c,
                        Invalid_Warehouse_Site__c= opp.Invalid_Warehouse_Site__c,
                        IsWndProduct__c= opp.IsWndProduct__c,
                        L_S_Product__c= opp.L_S_Product__c,
                        //Legacy_Opportuntity_LineItemId__c= opp.Legacy_Opportuntity_LineItemId__c,
                        Description__c= opp.Description__c,
                        List_Price__c= opp.List_Price__c ,
                        Material_Handling_Equipment_Investments__c= opp.Material_Handling_Equipment_Investments__c,
                        Nominated_Quantity__c= opp.Nominated_Quantity__c,
                        Ocean_Product__c= opp.Ocean_Product__c,
                        
                        //OpportuntityLineItemId__c= opp.Id,
                        OpportyProductExtID__c= opp.OpportyProductExtID__c,
                        Opt_Out_Auto_Quantity_Scheduling__c= opp.Opt_Out_Auto_Quantity_Scheduling__c,
                        Capital_Expenditure__c= opp.Capital_Expenditure__c,
                        Total_Tender_FFE_per_Route_Direction__c= opp.Total_Tender_FFE_per_Route_Direction__c,
                        Power_Lanes__c= opp.Power_Lanes__c,
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
                        Destination_Country__c = opp.Destination_Country__c
                        //, HasSchedule__c = opp.HasSchedule__c
                    );
                    oldOppwithNewOppMap.put(opp.id,customOLI);
                }
            }
        }
        
        if(oldOppwithNewOppMap.size() > 0){
            try{
                insert oldOppwithNewOppMap.values();
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', new list<Exception>{ex});
            }
        }
        
        
        
        
        set<id> newProducts = new  set<id>();
        set<id> OldProducts = new  set<id>();
        //Create Opportunity Product Configurations for the products which are not updated with new version  
        
        List<Opportunity_Product_Configuration__c> lstProdConfigsToInsert = new List<Opportunity_Product_Configuration__c>();
        //query for product config 
        for(Opportunity_Product_Configuration__c prodConfig : [select id, name, Component_Code__c, Feature_Code__c, Opportunity_Product__c, Opportunity_Product_Cus__c, 
                                                               Product_Component__c, Product_Feature__c, Product_Specificaiton_Parameter__c, Product_Specification_Option__c, 
                                                               Specification_Option_Name__c, Specification_Option_Order__c, Specification_Parameter_Code__c 
                                                               FROM Opportunity_Product_Configuration__c 
                                                               WHERE Opportunity_Product_Cus__c IN :oldOppwithNewOppMap.keySet()]){
                                                                   if(!newProductIdSet.contains(oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).Product2ID__c)){                                                                          
                                                                       
                                                                       Opportunity_Product_Configuration__c prodConfigsToInsert = new Opportunity_Product_Configuration__c();
                                                                       prodConfigsToInsert.Product_Specificaiton_Parameter__c  = prodConfig.Product_Specificaiton_Parameter__c;
                                                                       prodConfigsToInsert.Product_Specification_Option__c  =  prodConfig.Product_Specification_Option__c;
                                                                       prodConfigsToInsert.Opportunity_Product_Cus__c = oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).Id;
                                                                       lstProdConfigsToInsert.add(prodConfigsToInsert);
                                                                   }else{
                                                                       newProducts.add(oldOppwithNewOppMap.get(prodConfig.Opportunity_Product_Cus__c).id);
                                                                       OldProducts.add(prodConfig.Opportunity_Product_Cus__c);
                                                                   }
                                                               }
        
        
        
        if(lstProdConfigsToInsert.size() > 0){
            try{
                insert lstProdConfigsToInsert;
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityProducts', new list<Exception>{ex});
            }
        }
        
        
        
        //adjust the configurations based on the new version 
        
        if(newProducts.size()>0){            
            updateOpportunityConfigurations(newProducts,OldProducts);            
        }
        
    }
    
    public void updateOpportunityConfigurations( set<id> newProducts,set<id> OldProducts){
        
        //Create or delete Product Configuration 
        String profeatRecordTypeID = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
        list<Opportunity_Product__c> oppProdUpdated = [select id,Product2Id__c,Product2ID__r.OIPC_Code__c from  Opportunity_Product__c where id In: newProducts];
        
        //Map of Product and op
        map<id,list<Opportunity_Product__c>> prodOppMap = new  map<id,list<Opportunity_Product__c>>();
        for(Opportunity_Product__c prod:oppProdUpdated){
            if(prodOppMap.containsKey(prod.Product2Id__c)){
                prodOppMap.get(prod.Product2Id__c).add(prod);
            }else{
                prodOppMap.put(prod.Product2Id__c,new list<Opportunity_Product__c>{prod});
            }
        }
        
        
        list<Opportunity_Product_Configuration__c> oppConfig = [select id,Name,Opportunity_Product_Cus__c,Opportunity_Product_Cus__r.Product2Id__c,Product_Specificaiton_Parameter__c,Specification_Parameter_Code__c,Specification_Option_Code__c from Opportunity_Product_Configuration__c where Opportunity_Product_Cus__c In:OldProducts ];
        //map psp and pc 
        map<id,list<Opportunity_Product_Configuration__c>> psandPcMap = new  map<id,list<Opportunity_Product_Configuration__c>>();
        for(Opportunity_Product_Configuration__c pc:oppConfig){
            
            if(psandPcMap.containsKey(pc.Product_Specificaiton_Parameter__c)){
                psandPcMap.get(pc.Product_Specificaiton_Parameter__c).add(pc);
            }else{
                psandPcMap.put(pc.Product_Specificaiton_Parameter__c,new list<Opportunity_Product_Configuration__c>{pc});
            }
        }
        
        // query Product components
        Map<Id, Product_Component__c> lstComponents = new Map<Id, Product_Component__c>([SELECT Id, Name, Component_Code__c, Product__c
                                                                                         FROM Product_Component__c 
                                                                                         WHERE Product__c IN:prodOppMap.keySet() ORDER BY Display_Order__c,Name]);
        
        
        
        // for above fetched components get Product Features
        Map<Id,Product_Feature__c> lstFeatures = new Map<Id,Product_Feature__c>([SELECT Id, Name,Product_Component__c, Type__c, Value__c    , Default_Value__c, Options__c, Allow_Multiselect__c, Description__c,
                                                                                 Allow_None_Value__c, Value_Min__c, Value_Max__c, Value_Unit__c, Product_Component__r.Product__c, Choice_Required__c//8854
                                                                                 FROM Product_Feature__c 
                                                                                 WHERE Product_Component__c in :lstComponents.keySet() AND RecordTypeId=:profeatRecordTypeID 
                                                                                 ORDER BY Display_Order__c,Name]);
        
        
        
        map<Id,Product_Specification_Parameter__c> mapofProdSpecParams = new Map<Id,Product_Specification_Parameter__c>([SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c, 
                                                                                                                         Product_Feature__r.Product_Component__r.Product__c,Product_Feature__r.Description__c,
                                                                                                                         Display_Order__c, Feature_Code__c,Product_Feature__r.Product_Component__c,Description__c
                                                                                                                         FROM Product_Specification_Parameter__c 
                                                                                                                         WHERE Product_Feature__c in :lstFeatures.keySet() and Configurable_at_Contracting__c = true]);
        
        
        
        
        //specification perameter code vs option code 
        map<string,string> specParamCodeToSpecOptionCode = new map<string,string>();
        list<Opportunity_Product_Configuration__c> opcListToDelete = new  list<Opportunity_Product_Configuration__c>();
        for(Opportunity_Product_Configuration__c oppPc:oppConfig){           
            if(!mapofProdSpecParams.containsKey(oppPc.Product_Specificaiton_Parameter__c)){
                if(oppPc.Specification_Parameter_Code__c != null && oppPc.Specification_Option_Code__c != null){ 
                    specParamCodeToSpecOptionCode.put(oppPc.Specification_Parameter_Code__c,oppPc.Specification_Option_Code__c);
                }
                opcListToDelete.add(oppPc);
            }
        }
        
        
        map<string,Id> spocTospocId = new map<string,Id>();
        //Query Specification options by code and get the new list and prepare a map of SPOC vs SPO ID
        list<Product_Specification_Option__c> spOption = [select id,Specification_Option_Code__c from Product_Specification_Option__c where Specification_Option_Code__c In:specParamCodeToSpecOptionCode.values()];
        for(Product_Specification_Option__c spo:spOption){
            spocTospocId.put(spo.Specification_Option_Code__c,spo.id);
        }
        
        //Delete Unused Product Configuration         
        if(opcListToDelete.size() > 0){
            try{
                Delete opcListToDelete;
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.updateOpportunityConfigurations', new list<Exception>{ex});
            }
        }
        
        
        list<Opportunity_Product_Configuration__c> listofSptoCreat = new list<Opportunity_Product_Configuration__c>();
        for(Product_Specification_Parameter__c ps:mapofProdSpecParams.values()){
            
            if(!psandPcMap.containskey(ps.id)){
                system.debug('test1'+psandPcMap);
                for(Opportunity_Product__c opc: prodOppMap.get(ps.Product_Feature__r.Product_Component__r.Product__c))
                {
                    
                    string spoc;
                    if(specParamCodeToSpecOptionCode.containsKey(ps.Specification_Parameter_Code__c)){ 
                        spoc = specParamCodeToSpecOptionCode.get(ps.Specification_Parameter_Code__c);
                    }
                    
                    Opportunity_Product_Configuration__c opcObj = new Opportunity_Product_Configuration__c();
                    opcObj.Opportunity_Product_Cus__c  = opc.id;
                    opcObj.Product_Specificaiton_Parameter__c  =  ps.id;
                    if(spoc != null){ 
                        opcObj.Product_Specification_Option__c  =  spocTospocId.get(spoc);
                    }
                    //from the map based on spcode get the spoid 
                    opcObj.Name = ps.Name;
                    listofSptoCreat.add(opcObj);
                }
            }
        }
        
        
        //Insert new Product Configurations 
        
        if(listofSptoCreat.size() > 0){
            try{
                insert listofSptoCreat;
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.updateOpportunityConfigurations', new list<Exception>{ex});
            }
        }
        
    }
    
    //Create Opportunity TeamMembers 
    public void createOpportunityTeamMembers(set<id> oldOppIds, list<Opportunity> newOpportunities){
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
        
        map<id,Opportunity> parentOppwithNewOpp = new map<id,Opportunity>();
        //Parent opp id with New Opportunity map 
        for(Opportunity opp:newOpportunities){
            parentOppwithNewOpp.put(opp.Parent_Opportunity__c,opp);
        }
        
        for(id oppId:oppIdwithOpportunityTeam.keyset()){
            for(OpportunityTeamMember oppMember:oppIdwithOpportunityTeam.get(oppId)){
                if(oppMember.TeamMemberRole != 'Opportunity Owner'){
                    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                    
                    oppTeamMember.OpportunityAccessLevel = oppMember.OpportunityAccessLevel;
                    oppTeamMember.TCM_Product__c = oppMember.TCM_Product__c;
                    oppTeamMember.TeamMemberRole = oppMember.TeamMemberRole;
                    oppTeamMember.UserId = oppMember.UserId;
                    oppTeamMember.OpportunityId = parentOppwithNewOpp.get(oppMember.OpportunityId).id;
                    teamMemberstoInsert.add(oppTeamMember);
                }
            }
        }
        
        if(teamMemberstoInsert.size() > 0){
            try{
                insert  teamMemberstoInsert;
            }catch(Exception ex){
                System.debug('Exception '+ex.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'BatchOpportunityAutoRenewal', 'BatchOpportunityAutoRenewal.createOpportunityTeamMembers', new list<Exception>{ex});
            }
        }
    }
    
}