/*
* Test class : CustomApprovalProcessHandler_test
* Revision 	Ref Number	Date			Owner					Description
* -------- 	----------	-----------		-----------------		-----------
* 1.0      	SFSE-10586	28/04/2023		Aleena@maersk			Code created for Approval History records and mail notification
* 2.0		SFSE-11157	06-Jul-2023		Kiran@Maersk			OMEB 3.1 Full Approval Process
* 3.0       SFSE-11281  11/08/2023      Aleena@Maersk           Air&LCL - New Products logic added
* 4.0       SFSE-11517  12/08/2023      Aleena@Maersk           MCS- New products logic added
* 5.0       SFSE-12126  24/08/2023      Aleena@Maersk           ECM(Last Miles) Product Logic added 
* 6.0       SFSE-12427  11/09/2023      Aleena@Maersk           ECM(Last Miles) Product-Revised story logic added
* 7.0       SFSE-13042  12/12/2023      Aleena@Maersk           Addition of Reneweal logic to remove platform for certain products
* 8.0       SFSE-13562  2/01/2024       Aleena@Maersk           Middle Mile Prouct added for OMEB, logic added to insert Approval History
* 9.0		SFSE-13561	19/01/2024		Jothsana@Maersk			SMD(Supply Chain Management - Destination (USA)) - New Product Logic added
* 10.0		SFSE-14118	11/03/2024		Jothsana@Maersk			Removing Maersk Flow(MF1) from OMEB
* 11.0		SFSE-14873	28-05-2024		Jothsana@Maersk			Addition of logic to remove platform steps for certain products for Renewal,Addition Business opportunities
*/

public without sharing class CustomApprovalProcessHandler {
    public static boolean errorMessage=false;
    public static boolean toCheckNAMcountries=false;
    public static String opptyId;
    private static String opptyType;
    public static String productForApproval;
    public static String approvalStatus;
    public static String opptyowner;
    public static String comment ;
    public static String processName;
    public static List<String> processNameList;
    public static String guid;
    public static List<String> agpLMlessthan = new List<String>();
    public static List<String> agpLMmorethan = new List<String>();
    public static List<String> agpMM = new List<String>(); //13562
    public class ApprovalProcessException extends Exception {}
    
    private static Opportunity opportunityRecord;
    private static List<Opportunity_Product__c> opptyProducts;
    private static List<Opportunity_Product__c> lstOfoliCS = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliSMD = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliMC = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliLM = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliMM = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliWD = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> pursuitProductLstofOliWd = New List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliCL = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliGH = new List<Opportunity_Product__c>();
    private static List<Opportunity_Product__c> lstOfoliGL = new List<Opportunity_Product__c>();
    private static List<BDA_Geography__c> lstOfNAMcountries = new List<BDA_Geography__c>(); //12427
    private static List<String> lstofProductForApproval;
    private static List<Approval_Process_Escalation_Matrix__c> approvalMatrixAll;
    private static List<Approval_Process_Escalation_Matrix__c> approvalMatrixAutoApproved;
    private static List<Approval_Process_Escalation_Matrix__c> approvalMatrixCSWDCL;
    private static List<Approval_Process_Escalation_Matrix__c> pursuitProductapprovalMatrixWd;
    private static List<Approval_Process_Escalation_Matrix__c> approvalMatrixNonCSWDCL;
    private static Map<String, List<Approval_Process_Escalation_Matrix__c>> processToMatrixMap;
    private static String productCodeWithoutCSWDCL;
    private static String productCodeWithCSWDCL;
    private static String productCodeWithMC;
    private static String productCodeWithAL;
    private static String productCodeWithLM;
    private static String productCodeWithMM; //13562
    private static String pursuitGateProductCodeWithWd;
    
    private static Set<String> setExecutingCountries;
    private static List<String> lstProcessNamesAutoApproved;
    Private static List<String> queryForAgpLM = new List<String>();
     Private static List<String> queryForAgpMM = new List<String>(); //13562
    private static Map<String,String> mapOfKey;
    private static Map<String, String> mapOfCountriesNAM = new Map<String, String>();
    private static String Approved = System.label.Status_Approved;
    private static String Pending = System.label.Status_Pending;
    private static String keyTemp='';
    private static String userRegion;
    private static List<String> MCSgt50kregions = new List<string>{'Asia Pacific Region','Latin America Region','India, Middle East, and Africa'};
        private static List<String> MCSgt100kregions = new List<string>{'Europe Region','India, Middle East, and Africa'};
            private static Boolean reqFromShowNextApprover;
    private static List<Approval_Process_Escalation_Matrix__c> approvalMatrixForShowNextApprover;
    Public static List<Decimal> lsttotalSumOfAGPofMC = new list<Decimal>();
    Public static List<Decimal> lstofAGPofLM = new list<Decimal>();
    Public static List<Decimal> lstofAGPofMM = new list<Decimal>();//13562
    private static List<String> lstOIPCCodesWD = new List<String>();
    private static List<String> lstOIPCCodesCS = new List<String>();
    private static List<String> lstOIPCCodesGH = new List<String>();
    private static List<String> lstOIPCCodesSMD = new List<String>();
    private static List<String> lstOIPCCodesCSwithoutMCS = new List<String>();
    private static List<String> lstOIPCCodesLM = new List<String>();
    private static List<String> lstOIPCCodesMM = new List<String>(); //13562
    private static final String pursuit = System.Label.Pursuit_Gate;
    private static final String qualification = System.Label.Feasibility_Gate;
    private static final String solution = System.Label.Solution_Gate;
    private static final String prewin = System.Label.Pre_Win_Gate;
    
    
    public static set<Id> apHistoryResultSuccessIds = new set<Id>(),
        apHistoryResultSuccessIdsForAutoApproved = new set<Id>();
    public static set<Id> apHistoryInsert = new set<Id>();
    public static List<String> query = new List<String>();
    //public static List<String> lstofProductwithoutGP = new List <String>(); 
    public static Decimal totalGrossProfit;
    public static Decimal totalSumOfAGPofMC = 0;
    
    public static Decimal sla;
    
    public static List<Approval_History__c> lstapprovalhistoryrecords = new List<Approval_History__c> (),
        lstAutoApprovedapprovalhistoryrecords = new List<Approval_History__c> ();  
    public static List<Approval_Process_Escalation_Matrix__c> lstOfAppMatrixVerticalNull = new List<Approval_Process_Escalation_Matrix__c>(),
        lstofAppMatrixforCL        = new List<Approval_Process_Escalation_Matrix__c>(),
        lstofAppMatrixforWD		 = new List<Approval_Process_Escalation_Matrix__c>(),
        lstofAppMatrixforCS        = new List<Approval_Process_Escalation_Matrix__c>(),
        lstOfAppMatrix             = new List<Approval_Process_Escalation_Matrix__c>(),
        lstOfAppMatrixforSales     = new List<Approval_Process_Escalation_Matrix__c>(),
        lstOfAppMatrixwithNoGP     = new List<Approval_Process_Escalation_Matrix__c> (),   
        lstOfAppMatrixforAutoApproved = new List<Approval_Process_Escalation_Matrix__c> (),
        lstofAppMatrixforCSwithNoGP = new List<Approval_Process_Escalation_Matrix__c> (),
        lstofAppMatrixforWDwithNoGP = new List<Approval_Process_Escalation_Matrix__c> (),  
        lstofAppMatrixforCLwithNoGP = new List<Approval_Process_Escalation_Matrix__c> (),
        lstCS                      = new List<Approval_Process_Escalation_Matrix__c>(),
        lstWD                      = new List<Approval_Process_Escalation_Matrix__c>(), 
        lstCL                      = new List<Approval_Process_Escalation_Matrix__c>(); 
    public static Map<Id,Decimal> mapOfAnnulaizedGPforMC = new Map<Id,Decimal> ();
    public static Map<Id,Decimal> mapOfAnnulaizedGPforLM = new Map<Id,Decimal> ();
    public static Map<Id,Decimal> mapOfAnnulaizedGPforMM = new Map<Id,Decimal> ();
    public static Map<Id,String> mapOfExecutingCountryCS = new Map<Id,String> (),
        mapOfExecutingCountryWD = new Map<Id,String> (),
        mapOfExecutingCountrySMD = new Map<Id,String> (),
        mapOfExecutingCountryCL = new Map<Id,String> (),
        mapOfExecutingCountryGH = new Map<Id,String> (),
        mapOfExcetingCountryLM = new Map<Id,String>(),
        mapOfExecutingCountryMM = new Map<Id,String>(),
        mapOfExecutingCountryGL = new Map<Id,String> ();
    public static Map<Id, String> mapOfExecutingCountryWDPursuitProduct = New Map<Id, String>();
    private static Map<String,Set<String>> mapOfproductcodetoExecCountry = New Map<String,Set<String>>();
    public static String customLabelforPursuitGate = System.label.OMEB_Pursuit_Gate_Sales;
    public static string ReplyEmailAddress = system.label.Opportunity_Approval_Email_Address;
    public static string ReqAirLCLcheck = '';
    public static List<String> lsterrorMessage = new List<String>();
    public static List<String> productCodeForCS = new List<String>();
    public static List<String> productCodeForWD = new List<String>();
    public static List<String> productCodeForCL = new List<String>();
    public static List<String> productCodeForGH = new List<String>();
    public static List<String> productCodeForGL = new List<String>();
    public static List<String> productCodeForMC = new List<String>();
    public static List<String> productCodeForMM = new list<String>(); //13562
    public static List<String> productCodeForLM = new list<String>();
    public static List<String> productCodeForSMD = new list<String>();
    public static List<String> productCodeForNonLM = new list<String>();
    public static Map<String,Products_For_Approval__mdt> mapProdApprcodetomdt = new Map<String,Products_For_Approval__mdt>();//SFSE-14873

    public static Savepoint sp;
    
    //This method is to get value from Opportunity flow 
    @InvocableMethod(label='Submit For Approval' description='Submitting for approval')
    public static list<String> submitForApprovalInstanceInvocable(ApprovalWrapper[] wrapRec){
        sp = Database.setSavepoint();
        reqFromShowNextApprover = false;
        ApprovalWrapper wrap = wrapRec[0];
        opptyId = wrap.recordId; // get Opportunity Id from apex action in flow
        comment = wrap.inputComment; // get comment from screen flow
        processNameList = wrap.processNameList;
        if(wrap.reqFromShowNextApprover != null && wrap.reqFromShowNextApprover){
            reqFromShowNextApprover = wrap.reqFromShowNextApprover;
        }
        system.debug('processNameList=='+processNameList);
        system.debug('reqFromShowNextApprover@@ '+reqFromShowNextApprover);
        Map<String, List<Approval_History__c>> mapApprovalHistoryToCreate = new Map<String, List<Approval_History__c>>();
        List<Approval_History__c> lstApprovalHistories = new List<Approval_History__c>();
        approvalMatrixCSWDCL = new List<Approval_Process_Escalation_Matrix__c>();
        pursuitProductapprovalMatrixWd = New List<Approval_Process_Escalation_Matrix__c>();
        approvalMatrixNonCSWDCL = new List<Approval_Process_Escalation_Matrix__c>();
        lstProcessNamesAutoApproved = new List<String>();
        approvalMatrixAll = new List<Approval_Process_Escalation_Matrix__c>();
        approvalMatrixAutoApproved = new List<Approval_Process_Escalation_Matrix__c>();
        approvalMatrixForShowNextApprover = new List<Approval_Process_Escalation_Matrix__c>();
        productForApproval = '';
        
        if(processNameList != null && processNameList.size() > 0){
            try{
                
                opportunityRecord = [Select Id, Owner.Region__c, Approval_Required__c, RecordType.DeveloperName,Type, Owner_Area_Code__c, OwnerId, Liner_Brand__c, Opportunity_Owner_Country__c, Total_GP_of_OMEB_Products__c,Requires_Custom_Integration__c
                                     ,StageName, Account.Vertical__c, Products_for_Approval__c,Requires_IT_Integration__c, Approval_Status__c FROM Opportunity WHERE id =:opptyId];
                
                if(opportunityRecord.Requires_IT_Integration__c!=null){
                    ReqAirLCLcheck = opportunityRecord.Requires_IT_Integration__c;
                }
                
                if(opportunityRecord.Products_for_Approval__c != null && opportunityRecord.Products_for_Approval__c != ''){
                    productForApproval = opportunityRecord.Products_for_Approval__c;
                }
                if(opportunityRecord.Type != null){
                    opptyType = opportunityRecord.Type;
                }
                getUserRegion();
                
                lstofProductForApproval = new List<String>();
                if(!String.isEmpty(productForApproval)){
                    lstofProductForApproval = productForApproval.split(';');    
                }
                
                List<String> pursuitProductCodeforWD = New List<String>();
                productCodeForCS = new List<String>();
                productCodeForWD = new List<String>();
                productCodeForGH = new List<String>();
                productCodeForSMD = new List<String>();
                for(String str : lstofProductForApproval){
                    if(str.contains(System.Label.OMEB_MDM)){ //13562
                        productCodeForMM.add(str);
                    }
                    if(str.contains(System.Label.OMEB_LM)){ 
                        productCodeForLM.add(str); 
                    }
                    if(!str.contains(System.Label.OMEB_LM)){
                        productCodeForNonLM.add(str);
                    }
                    if(str.contains(System.Label.OMEB_MC)){
                        productCodeForMC.add(str);
                    }
                    if(str.contains(System.Label.OMEB_CS)){
                        productCodeForCS.add(str);
                    }
                    if(str.contains(System.Label.OMEB_SMD)){
                        productCodeForSMD.add(str);
                    }
                    if(str.contains(System.Label.OMEB_WD) || str.startsWith(System.Label.OMEB_CL)){
                        productCodeForWD.add(str);
                    }
                    if(str.contains(System.Label.OMEB_GH) || str.startsWith(System.Label.OMEB_GL)){
                        productCodeForGH.add(str);
                    }
                    
                }
                //to get oipc codes from Products For Approval Metadata for omeb products
                List<Products_For_Approval__mdt> productsForApprovalList =Products_For_Approval__mdt.getAll().values();
                For(Products_For_Approval__mdt prodApproval : productsForApprovalList){
                    mapProdApprcodetomdt.put(prodApproval.Product_Approval_Code__c, prodApproval);
                    if(prodApproval.Active__c == true){
                        if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_WD) && !productCodeForWD.isEmpty()){
                            lstOIPCCodesWD.add(prodApproval.OIPC_Code__c);
                        }
                        if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_CS) && !productCodeForCS.isEmpty()){
                            lstOIPCCodesCS.add(prodApproval.OIPC_Code__c);
                        }
                        if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_SMD) && !productCodeForSMD.isEmpty()){
                            lstOIPCCodesSMD.add(prodApproval.OIPC_Code__c);
                        }
                        if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_GH) && !productCodeForGH.isEmpty()){
                            lstOIPCCodesGH.add(prodApproval.OIPC_Code__c);
                        }
                        if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_MDM) && !productCodeForMM.isEmpty()){ //13562
                            lstOIPCCodesMM.add(prodApproval.OIPC_Code__c);
                        }
                        if(prodApproval.Product_Approval_Code__c.contains('LM') && !productCodeForLM.isEmpty()){
                            lstOIPCCodesLM.add(prodApproval.OIPC_Code__c);
                        }if(prodApproval.Product_Approval_Code__c.contains(System.Label.OMEB_MC) && prodApproval.Product_Approval_Code__c != 'MC9' && !productCodeForMC.isEmpty()){
                            lstOIPCCodesCSwithoutMCS.add(prodApproval.OIPC_Code__c);
                        }
                    }
                }
                
                // To query list of countries under NAM region for Last miles Product 
                if(productCodeForLM!=null){
                    //12427
                    String NorthAmericaArea = System.label.North_America_Area;
                    lstOfNAMcountries = [select id, name, BDA__r.Name, Geography__r.Name, bda__r.Parent_BDA__r.Name from BDA_Geography__c where Geography__r.Type_Of_Location__c = 'Country' and BDA__r.Name =:NorthAmericaArea and Geography__r.Active__c = true];
                    
                    system.debug('lstOfNAMcountries'+lstOfNAMcountries);
                    if(!lstOfNAMcountries.isEmpty()){
                        for(BDA_Geography__c con:lstOfNAMcountries){
                            system.debug(con.Geography__r.Name);
                            
                            system.debug(con.Geography__r.Name);
                            mapOfCountriesNAM.put(con.Geography__r.Name, con.BDA__r.Name);
                            
                        }
                    }
                }
                // To fetch executing country of OMEB Products which required Approvers based on executing Country and Annualized GP for MCS
                opptyProducts = [SELECT id, Name, Annualized_Gross_Profit__c, Product2ID__c,Exclude_from_OMEB__c, Product2ID__r.Name, Product2ID__r.OIPC_Code__c, Product_Family__c, OpportunityId__r.id, Country__r.Name,OpportunityId__r.Opportunity_Owner_Country__c,
                                 OpportunityId__r.Products_for_Approval__c
                                 FROM Opportunity_Product__c  WHERE OpportunityId__c =:opptyId];
                system.debug('opptyProducts=='+opptyProducts);
                for(Opportunity_Product__c opptyProd : opptyProducts){
                    
                    system.debug('lstOIPCCodesCSwithoutMCS'+lstOIPCCodesCSwithoutMCS);
                    system.debug('OIPC_Code__c'+opptyProd.Product2ID__r.OIPC_Code__c);
                    if(!lstOIPCCodesCSwithoutMCS.isEmpty()){ 
                        if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesCSwithoutMCS.contains(opptyProd.Product2ID__r.OIPC_Code__c)){
                            lstOfoliMC.add(opptyProd);}}
                    if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesCS.contains(opptyProd.Product2ID__r.OIPC_Code__c) ){
                        lstOfoliCS.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesSMD.contains(opptyProd.Product2ID__r.OIPC_Code__c) ){
                        lstOfoliSMD.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesWD.contains(opptyProd.Product2ID__r.OIPC_Code__c) && opptyProd.Country__r.Name != opptyProd.OpportunityId__r.Opportunity_Owner_Country__c && processNameList.contains(Label.OMEB_Pursuit_Gate_Products)){
                        lstOfoliWD.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesWD.contains(opptyProd.Product2ID__r.OIPC_Code__c) && !processNameList.contains(Label.OMEB_Pursuit_Gate_Products)){
                        lstOfoliWD.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesWD.contains(opptyProd.Product2ID__r.OIPC_Code__c) && reqFromShowNextApprover){
                        lstOfoliWD.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c != null && lstOIPCCodesGH.contains(opptyProd.Product2ID__r.OIPC_Code__c)){
                        lstOfoliGH.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c !=null && lstOIPCCodesLM.contains(opptyProd.Product2ID__r.OIPC_Code__c)){
                        lstOfoliLM.add(opptyProd);
                    }else if(opptyProd.Product2ID__r.OIPC_Code__c !=null && lstOIPCCodesMM.contains(opptyProd.Product2ID__r.OIPC_Code__c)){
                        lstOfoliMM.add(opptyProd); //13562
                    }
                    
                }
                // To store different Annualized GP of MC products except MCS.
                if(productCodeForMC!=null && !lstOfoliMC.isEmpty()){
                    for(Opportunity_Product__c oli:lstOfoliMC){
                        if(!mapOfAnnulaizedGPforMC.containsKey(oli.id)){
                            mapOfAnnulaizedGPforMC.put(oli.id, oli.Annualized_Gross_Profit__c);
                        }
                        
                    } 
                }
                // for Last Miles product to have individual AGP
                if(productCodeForLM!=null && !lstOfoliLM.isEmpty()){
                    for(Opportunity_Product__c oli:lstOfoliLM){
                        if(mapOfproductcodetoExecCountry.containsKey('LM')){
                            mapOfproductcodetoExecCountry.get('LM').add(oli.Country__c);
                        }
                        else {
                            mapOfproductcodetoExecCountry.put('LM',new Set<String>{oli.Country__c});
                        }
                        if(!mapOfCountriesNAM.containskey(oli.Country__r.Name)){
                         
                            if(!mapOfAnnulaizedGPforLM.containsKey(oli.id)){
                                if(oli.Annualized_Gross_Profit__c < 50000){
                                    agpLMlessthan.add('<50000');
                                } else{
                                    mapOfAnnulaizedGPforLM.put(oli.id, oli.Annualized_Gross_Profit__c);
                                }
                            }
                            
                        }
                        else{
                            if(mapOfCountriesNAM.containskey(oli.Country__r.Name)){ 
                                toCheckNAMcountries=true; }
                        } 
                    }
                }
                lstofAGPofLM = mapOfAnnulaizedGPforLM.values();
                system.debug('lstofAGPofLM'+lstofAGPofLM);
                // To call AGP mrthod to send Agp of individual products
                if(!lstofAGPofLM.isEmpty()){
                    for(Decimal d:lstofAGPofLM){
                        
                        queryForAgpLM=toCalculateTottalAGPforLM(d);
                    }
                }
                
                //for Middle Mile Annualized GP of individual product - //13562
                if(productCodeForMM!=null && !lstOfoliMM.isEmpty()){
                    for(Opportunity_Product__c oli:lstOfoliMM){
                        if(!mapOfAnnulaizedGPforMM.containsKey(oli.id)){
                            mapOfAnnulaizedGPforMM.put(oli.id, oli.Annualized_Gross_Profit__c);
                        }
                        
                        if(!mapOfExecutingCountryMM.containsKey(oli.id)){
                            mapOfExecutingCountryMM.put(oli.id, oli.Country__c);
                        }
                        
                         if(mapOfproductcodetoExecCountry.containsKey('MM')){
                            mapOfproductcodetoExecCountry.get('MM').add(oli.Country__c);
                        }
                        else {
                            mapOfproductcodetoExecCountry.put('MM',new Set<String>{oli.Country__c});
                        }
                    }
                }
                
                lstofAGPofMM =  mapOfAnnulaizedGPforMM.values();
                system.debug('lstofAGPofMM'+lstofAGPofMM);
                // To call AGP mrthod to send Agp of individual Middle Mile products
                if(!lstofAGPofMM.isEmpty()){
                    for(Decimal d:lstofAGPofMM){
                        queryForAgpMM=toCalculateTottalAGPforMM(d);
                        
                        system.debug(queryForAgpMM+'queryForAgpMM');
                    }
                }
                
                lsttotalSumOfAGPofMC=mapOfAnnulaizedGPforMC.values();
                system.debug(lsttotalSumOfAGPofMC);
                if(!mapOfAnnulaizedGPforMC.isEmpty()){ // for MCS Products to sum up AGP
                    lsttotalSumOfAGPofMC=mapOfAnnulaizedGPforMC.values();
                    for(decimal digit :lsttotalSumOfAGPofMC) 
                    { 
                        totalSumOfAGPofMC = totalSumOfAGPofMC*10 + digit;
                    }
                    system.debug(totalSumOfAGPofMC);
                }
                if(productCodeForCS != null){
                    for(Opportunity_Product__c oli:lstOfoliCS){
                        if(!mapOfExecutingCountryCS.containsKey(oli.id)){
                            mapOfExecutingCountryCS.put(oli.id, oli.Country__c);
                        }
                         if(mapOfproductcodetoExecCountry.containsKey('CS')){
                            mapOfproductcodetoExecCountry.get('CS').add(oli.Country__c);
                        }
                        else {
                            mapOfproductcodetoExecCountry.put('CS',new Set<String>{oli.Country__c});
                        }
                    }
                }
                if(productCodeForSMD != null){
                    for(Opportunity_Product__c oli:lstOfoliSMD){
                        if(!mapOfExecutingCountrySMD.containsKey(oli.id)){
                            mapOfExecutingCountrySMD.put(oli.id, oli.Country__c);
                        }
                         if(mapOfproductcodetoExecCountry.containsKey('SMD')){
                            mapOfproductcodetoExecCountry.get('SMD').add(oli.Country__c);
                        }
                        else {
                            mapOfproductcodetoExecCountry.put('SMD',new Set<String>{oli.Country__c});
                        }
                    }
                }
                system.debug(productCodeForCS+'productCodeForCS');
                system.debug('lstOfoliLM'+lstOfoliLM);
                if(productCodeForLM != null){
                    for(Opportunity_Product__c oli:lstOfoliLM){
                        if(!mapOfExcetingCountryLM.containsKey(oli.id)){
                            mapOfExcetingCountryLM.put(oli.id, oli.Country__c);
                        }
                    }
                }
                //for WD and CL
                if(productCodeForWD!=null){
                    for(Opportunity_Product__c oli:lstOfoliWD){
                        if(!mapOfExecutingCountryWD.containsKey(oli.id)){
                            mapOfExecutingCountryWD.put(oli.id, oli.Country__c);
                            if(oli.Annualized_Gross_Profit__c >= 100000){
                                if(mapOfproductcodetoExecCountry.containsKey('WD')){
                                    mapOfproductcodetoExecCountry.get('WD').add(oli.Country__c);
                                }
                                else {
                                    mapOfproductcodetoExecCountry.put('WD',new Set<String>{oli.Country__c});
                                }
                            }else{
                                if(mapOfproductcodetoExecCountry.containsKey('CL')){
                                    mapOfproductcodetoExecCountry.get('CL').add(oli.Country__c);
                                }
                                else {
                                    mapOfproductcodetoExecCountry.put('CL',new Set<String>{oli.Country__c});
                                }
                            }
                        }
                    }
                }
   
                if(productCodeForGH!=null){
                    for(Opportunity_Product__c oli:lstOfoliGH){
                        if(!mapOfExecutingCountryGH.containsKey(oli.id)){
                            mapOfExecutingCountryGH.put(oli.id, oli.Country__c);
                            if(oli.Annualized_Gross_Profit__c >= 100000){
                                if(mapOfproductcodetoExecCountry.containsKey('GH')){
                                    mapOfproductcodetoExecCountry.get('GH').add(oli.Country__c);
                                }
                                else {
                                    mapOfproductcodetoExecCountry.put('GH',new Set<String>{oli.Country__c});
                                }
                            }else{
                                if(mapOfproductcodetoExecCountry.containsKey('GL')){
                                    mapOfproductcodetoExecCountry.get('GL').add(oli.Country__c);
                                }
                                else {
                                    mapOfproductcodetoExecCountry.put('GL',new Set<String>{oli.Country__c});
                                }
                            }
                        }
                    }
                }
                //to add in a map of code to executing country 
               
                String valueToRemove = System.Label.Pre_Win_Gate_Auto_Approval_Last_Mile;
                String valueToRemoveProducts = System.label.Pre_Win_Gate_Products;
                // To filter processNameList
                if(!productCodeForLM.isEmpty()){
                    if(!productCodeForLM.isEmpty() && productCodeForNonLM.isEmpty() && !agpLMlessthan.isEmpty() && mapOfAnnulaizedGPforLM.isEmpty() && toCheckNAMcountries==false ){
                        for (Integer i = processNameList.size() - 1; i >= 0; i--) {
                            if (processNameList[i] == valueToRemoveProducts ) {
                                processNameList.remove(i);
                            }
                            
                        }
                    }
                    
                    if((!agpLMlessthan.isEmpty() && !mapOfAnnulaizedGPforLM.isEmpty()) ||agpLMlessthan.isEmpty() || toCheckNAMcountries){
                        for (Integer i = processNameList.size() - 1; i >= 0; i--) {
                            if (processNameList[i] == valueToRemove) {
                                processNameList.remove(i);
                            }  
                        }
                    }
                }
                // For Auto-Approved
                for(String procesName : processNameList){
                    if(procesName.containsIgnoreCase('Auto') || 
                       ( ((productForApproval.containsIgnoreCase('CL') || productForApproval.containsIgnoreCase('GL'))||productForApproval.containsIgnoreCase('AL') || productForApproval.containsIgnoreCase('MC') || (productForApproval.containsIgnoreCase('LM') && procesName.containsIgnoreCase('Auto')) ) &&
                        !(productForApproval.containsIgnoreCase('4PL') || productForApproval.containsIgnoreCase('SCM') || productForApproval.containsIgnoreCase('CCL') || productForApproval.containsIgnoreCase('ECM') || productForApproval.containsIgnoreCase('CS') || productForApproval.containsIgnoreCase('WD') || productForApproval.containsIgnoreCase('GH')) && 
                        (procesName.containsIgnoreCase(pursuit) || procesName.containsIgnoreCase(qualification)))){
                           lstProcessNamesAutoApproved.add(procesName);
                       }
                }
                System.debug(' lstProcessNamesAutoApproved '+lstProcessNamesAutoApproved);
                // This method is to fetch all Matrix Records
                getApprovalProcessMatrix();
                
                System.debug( ' lstofProductForApproval '+lstofProductForApproval);
                productCodeWithoutCSWDCL = '';
                productCodeWithCSWDCL = '';
                productCodeWithMC='';
                productCodeWithAL='';
                productCodeWithLM='';
                productCodeWithMM= ''; //13562
                pursuitGateProductCodeWithWd = '';
                
                for(String code : lstofProductForApproval){
                    
                    if(code.contains(Label.OMEB_CS) || code.contains(Label.OMEB_WD) ||  code.startsWith(Label.OMEB_CL) || code.startsWith(Label.OMEB_GH) || code.startsWith(Label.OMEB_GL) || code.contains(Label.OMEB_SMD)){
                        productCodeWithCSWDCL += code +',';
                    }else if(code.contains(Label.OMEB_MC) && (!code.contains('MC9'))){
                        productCodeWithMC += code + ',';
                    }else if(code.contains(Label.OMEB_AL)){
                        productCodeWithAL += code + ',';
                    }else if(code.contains('LM')){
                        productCodeWithLM +=code + ',';
                    }else if(code.contains(Label.OMEB_MDM)){ //13562
                        productCodeWithMM +=code + ',';
                    }
                    else{
                        productCodeWithoutCSWDCL += code +',';
                    }
                }
                system.debug(productCodeWithoutCSWDCL+'productCodeWithoutCSWDCL');
                productCodeWithoutCSWDCL = productCodeWithoutCSWDCL.removeEnd(',');
                productCodeWithCSWDCL = productCodeWithCSWDCL.removeEnd(',');
                productCodeWithMC = productCodeWithMC.removeEnd(',');
                productCodeWithLM = productCodeWithLM.removeEnd(',');
                productCodeWithMM = productCodeWithMM.removeEnd(','); //13562
                // pursuitGateProductCodeWithWd = pursuitGateProductCodeWithWd.removeEnd(',');
                for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixAll){
                    for(string str : setExecutingCountries){
                        system.debug('str=='+str);
                    }
                    system.debug('matrix.Country__c==='+matrix.Country__c);
                    // This to add  list for executing country products
                    if(setExecutingCountries.contains(matrix.Country__c) && !matrix.Auto_Approved__c){
                        approvalMatrixCSWDCL.add(matrix);
                    }
                    
                    // This to add list for owner country products
                    if(matrix.Country__c != null && matrix.Country__r.Name == opportunityRecord.Opportunity_Owner_Country__c && !matrix.Auto_Approved__c ){
                        
                        approvalMatrixNonCSWDCL.add(matrix);
                    }
                    // This to add list for auto-approved 
                    if(matrix.Auto_Approved__c){
                        approvalMatrixAutoApproved.add(matrix);
                    }
                    // }
                }
                for(String procesName : processNameList){
                    lstApprovalHistories = approvalHistoryRecord(procesName);
                    System.debug('procesName @@@ '+procesName+ '\t lstApprovalHistories@@@ '+lstApprovalHistories.size());
                    mapApprovalHistoryToCreate.put(procesName, lstApprovalHistories);
                }
                
                if(!reqFromShowNextApprover){
                    String exMsg;
                    lstApprovalHistories = new List<Approval_History__c>();
                    for(String procesName : mapApprovalHistoryToCreate.keySet()){
                        System.debug('procesName @@@ '+procesName+ '\t lstApprovalHistories@@@ '+mapApprovalHistoryToCreate.get(procesName).size());
                        if(mapApprovalHistoryToCreate.get(procesName).size() == 0){
                            exMsg = procesName +' do not have approval process matrix records with satisified criteria';
                            //throw new ApprovalProcessException(exMsg);
                        }else{
                           
                            lstApprovalHistories.addAll(mapApprovalHistoryToCreate.get(procesName));
                        }
                    }
                    
                    System.debug('lstapprovalhistoryToCreate size '+mapApprovalHistoryToCreate.values().size());
                    if(mapApprovalHistoryToCreate.values().size() > 0){
                        approvalHistoryRecordCreate(lstApprovalHistories);
                        System.debug('errorMessage @@ '+errorMessage+'\n lsterrorMessage'+lsterrorMessage);
                        if(!errorMessage){
                            updateOpportunityStatus();
                        }
                    }
                }else{
                    showNextApprovalProcess.approvalMatrixForShowNextApprover = approvalMatrixForShowNextApprover;
                }
            }catch(exception ex){
                errorMessage = true;
                lsterrorMessage.add(ex.getMessage());
                System.debug('An exception occurred: ' + ex.getMessage());
                System.debug('Exception Type: ' + ex.getTypeName());
                System.debug('Exception Line Number: ' + ex.getLineNumber());
                Database.rollback(sp);
                system.debug('testline'+ex.getLineNumber());
                ErrorLogger.writeErrors( 'SFDC', 'OMEB 3.0', 'CustomApprovalProcessHandler.submitForApprovalInstanceInvocable', new list<Exception>{ex});
            }
        }
        else{
            errorMessage = true;
            lsterrorMessage.add(System.Label.OMEB_No_Applicable);
        }
        return lsterrorMessage;
    }
    
    private static Opportunity updateOpportunityStatus(){
        String submit = System.label.Submit;
        List<Approval_Status_Stage_Mapping__mdt> lstOfCustomMetaData = [Select id, Process_name__c,Next_value__c,StageName__c from Approval_Status_Stage_Mapping__mdt where Action__c=:submit];
        List<Approval_Status_Stage_Mapping__mdt> statusStageMetadata = Approval_Status_Stage_Mapping__mdt.getAll().values();
        String gateNameFromProcess = processNameList[0].split(' ')[0];
        String gateNameFromMD;
        Opportunity opptyToUpdateApprovalStatus;
        for(Approval_Status_Stage_Mapping__mdt statusStageMD : statusStageMetadata){
            gateNameFromMD = statusStageMD.MasterLabel.split(' ')[0];
            if(gateNameFromProcess == gateNameFromMD && statusStageMD.Action__c == submit){
                opptyToUpdateApprovalStatus = new Opportunity(Id = opportunityRecord.Id, Approval_Status__c = statusStageMD.Next_value__c);
            }
        }
        
        if(lstProcessNamesAutoApproved.size() == processNameList.size()){
            for(Approval_Status_Stage_Mapping__mdt statusStageMD : statusStageMetadata){
                if(statusStageMD.Current_value__c == opptyToUpdateApprovalStatus.Approval_Status__c && statusStageMD.Action__c == 'Approved'){
                    opptyToUpdateApprovalStatus = new Opportunity(Id = opportunityRecord.Id, Approval_Status__c = statusStageMD.Next_value__c);
                    if(statusStageMD.StageName__c != null && statusStageMD.StageName__c != '' ){
                        
                        opptyToUpdateApprovalStatus.StageName = statusStageMD.StageName__c;
                    }
                }
            }
        }
        System.debug('opptyToUpdateApprovalStatus >> '+opptyToUpdateApprovalStatus);
        update opptyToUpdateApprovalStatus;
        return opptyToUpdateApprovalStatus;
    }
    
    private static void getApprovalProcessMatrix(){
        
        
        processToMatrixMap = new Map<String, List<Approval_Process_Escalation_Matrix__c>>();
        String vertical = '';
        String ownerCountry = opportunityRecord.Opportunity_Owner_Country__c;
        if(opportunityRecord.Account != null && opportunityRecord.Account.Vertical__c != null){
            vertical = opportunityRecord.Account.Vertical__c; 
        }
       
        setExecutingCountries = new Set<String>();
        
        if(!lstOfoliCS.isEmpty()){
            setExecutingCountries.addAll(mapOfExecutingCountryCS.values());
        }
        if(!lstOfoliSMD.isEmpty()){
            setExecutingCountries.addAll(mapOfExecutingCountrySMD.values());
        }
        if(!lstOfoliWD.isEmpty()){
            setExecutingCountries.addAll(mapOfExecutingCountryWD.values());
        }
        if(!lstOfoliGH.isEmpty()){
            setExecutingCountries.addAll(mapOfExecutingCountryGH.values());
        }
        if(!lstOfoliLM.isEmpty()){
            setExecutingCountries.addAll(mapOfExcetingCountryLM.values());
        }
        //13562
        if(!lstOfoliMM.isEmpty()){
            setExecutingCountries.addAll(mapOfExecutingCountryMM.values());
        }
        
        System.debug('setExecutingCountries '+setExecutingCountries.size());
        for(string str:setExecutingCountries ){
        }
        List<Approval_Process__c> lstofAppProcess = [Select Id, Name, SLA__c, Active__c, Sub_Gate__c 
                                                     FROM Approval_Process__c WHERE Name IN :processNameList AND Active__c = true ];
        
        System.debug('lstofAppProcess '+lstofAppProcess.size());
        
        String query = 'Select Id, Step_Name__c, Auto_Approved__c, Total_GP__c, Current_owner__c,Current_owner__r.DelegatedApproverId, Key__c, Product_for_approval__c, Country__c, Country__r.Name, '
            +'Approval_Process_Name__c, Approval_Process_Name__r.Name, Approval_Process_Name__r.SLA__c, Region__c,Response_type__c, Area_code__c, '
            +'Approval_Process_Name__r.Gate__c, Current_owner__r.Name ';
        query += ' FROM Approval_Process_Escalation_Matrix__c ';
        query += ' WHERE Approval_Process_Name__c IN :lstofAppProcess and Vertical__c =: vertical and Active__c = true ';
        
        if( !setExecutingCountries.isEmpty() ){
            query += ' AND (Country__c IN: setExecutingCountries OR Country__r.Name =: ownerCountry ) ';
        }else{
            query += ' AND Country__r.Name =: ownerCountry ';
        }
        System.debug('query '+query);
        
        approvalMatrixAll = Database.query(query);
        
        if(!lstProcessNamesAutoApproved.isEmpty()){
            query = 'Select Id, Step_Name__c, Auto_Approved__c, Total_GP__c, Current_owner__c,Current_owner__r.DelegatedApproverId, Key__c, Product_for_approval__c, Country__c, Country__r.Name, '
                +'Approval_Process_Name__c, Approval_Process_Name__r.Name,Response_type__c, Approval_Process_Name__r.SLA__c, Region__c, Area_code__c, '
                +'Approval_Process_Name__r.Gate__c, Current_owner__r.Name ';
            query += ' FROM Approval_Process_Escalation_Matrix__c ';
            query += ' WHERE Auto_Approved__c = true and Active__c = true ';
            approvalMatrixAutoApproved = Database.query(query);
            if(!approvalMatrixAutoApproved.isEmpty()){
                approvalMatrixAll.addAll(approvalMatrixAutoApproved);
            }
        }
        approvalMatrixAutoApproved = new List<Approval_Process_Escalation_Matrix__c>();
        
        for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixAll){
            if(processToMatrixMap.containsKey(matrix.Approval_Process_Name__r.Name)){
                processToMatrixMap.get(matrix.Approval_Process_Name__r.Name).add(matrix);
            }else{
                processToMatrixMap.put(matrix.Approval_Process_Name__r.Name, new List<Approval_Process_Escalation_Matrix__c>{matrix});
            }
        }
        
        
    }
    
    private static List<Approval_History__c> approvalHistoryRecord(String procesName){
        System.debug('procesName -- '+procesName + ' -- matrix size -- '+ (processToMatrixMap.containsKey(procesName) ? processToMatrixMap.get(procesName).size() : 0));
        List<Approval_History__c> lstapprovalhistory = new List<Approval_History__c> ();
        mapOfKey = new Map<String,String>();
        totalGrossProfit = opportunityRecord.Total_GP_of_OMEB_Products__c;
        List<String> query = toCalculateTottalGP();
        List<String> queryForAgpMC = toCalculateTottalAGP();
        
        System.debug('query '+query);
        System.debug('queryForAgpMC '+queryForAgpMC);
        Approval_History__c app;
        
        if(!procesName.startsWithIgnoreCase(customLabelforPursuitGate) && !procesName.containsIgnoreCase('Auto')){
            String productCodeWithCSWDCLrenewal ='';
            productCodeWithCSWDCLrenewal = productCodeWithCSWDCL;
            productCodeWithCSWDCLrenewal = String.join((SkipApprovals(productCodeWithCSWDCLrenewal, procesName)),',');//SFSE-14873
            
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixCSWDCL){
                if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithCSWDCLrenewal) && (query.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                    if(!reqFromShowNextApprover){
                        app = new Approval_History__c();
                        app = getAppRecord(matrix, procesName);
                        lstapprovalhistory.add(app);
                        System.debug('lstapprovalhistory Qualification >> '+lstapprovalhistory);
                    }else{
                        approvalMatrixForShowNextApprover.add(matrix);
                    }
                }
            }
        }
        system.debug(approvalMatrixNonCSWDCL.size());
        
        if(!procesName.containsIgnoreCase('Auto')){
            String productCodeWithoutCSWDCLrenewal ='';   
            productCodeWithoutCSWDCLrenewal = productCodeWithoutCSWDCL;
            productCodeWithoutCSWDCLrenewal = String.join((SkipApprovals(productCodeWithoutCSWDCLrenewal, procesName)),',');//SFSE-14873
            
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixNonCSWDCL){
                if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithoutCSWDCLrenewal) && (query.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                    if(!reqFromShowNextApprover){
                        app = new Approval_History__c();
                        app = getAppRecord(matrix, procesName);
                        lstapprovalhistory.add(app);
                    }else{
                        approvalMatrixForShowNextApprover.add(matrix);
                    }
                }
            }
        }
        
        if( procesName.containsIgnoreCase('Auto')){
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixAutoApproved){
                if(procesName == matrix.Approval_Process_Name__r.Name){
                    if(!reqFromShowNextApprover){
                        app = new Approval_History__c();
                        app = getAppRecord(matrix, procesName);
                        lstapprovalhistory.add(app);
                    }else{
                        approvalMatrixForShowNextApprover.add(matrix);
                    }
                }
            }
        }
        
        if(!procesName.containsIgnoreCase('Auto') && productCodeWithMC!=''){
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixNonCSWDCL){
                
                if(procesName.contains('Product')){
                    if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithMC) && (queryForAgpMC.contains(matrix.Total_GP__c))){
                        system.debug('Total GP of MAtrix@@'+matrix.Total_GP__c); 
                        if(!reqFromShowNextApprover){
                            app = new Approval_History__c();
                            app = getAppRecord(matrix, procesName);
                            lstapprovalhistory.add(app);
                        }else{
                            approvalMatrixForShowNextApprover.add(matrix);
                        }
                    }else if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithMC) && (queryForAgpMC.isEmpty()) && (matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                        system.debug('Total GP of MAtrix@@'+matrix.Total_GP__c); 
                        if(!reqFromShowNextApprover){
                            app = new Approval_History__c();
                            app = getAppRecord(matrix, procesName);
                            lstapprovalhistory.add(app);
                        }else{
                            approvalMatrixForShowNextApprover.add(matrix);
                        }
                    }
                }
                else {
                    if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithMC) && (matrix.Total_GP__c == null || matrix.Total_GP__c == '') && !lstofProductForApproval.contains('MC9')){
                        if(!reqFromShowNextApprover){
                            app = new Approval_History__c();
                            app = getAppRecord(matrix, procesName);
                            lstapprovalhistory.add(app);
                        }else{
                            approvalMatrixForShowNextApprover.add(matrix);
                        }
                    }
                }
            }
        }
        
        if(!procesName.containsIgnoreCase('Auto') && productCodeWithAL != ''){
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixNonCSWDCL){
                if(procesName != 'Solution Gate Platform'){
                    if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithAL) && (query.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                        
                        if(!reqFromShowNextApprover){
                            app = new Approval_History__c();
                            app = getAppRecord(matrix, procesName);
                            lstapprovalhistory.add(app);
                        }else{
                            approvalMatrixForShowNextApprover.add(matrix);
                        }
                    }
                }else{
                    if(ReqAirLCLcheck != 'No, this is not required. Customer system will not connect with Maersk in any way'){
                        if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix, productCodeWithAL) && (query.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                            
                            if(!reqFromShowNextApprover){
                                app = new Approval_History__c();
                                app = getAppRecord(matrix, procesName);
                                lstapprovalhistory.add(app);
                            }else{
                                approvalMatrixForShowNextApprover.add(matrix);
                            }
                        }
                    }
                }
            }
        }
        // for LM products
        system.debug(productCodeWithLM);
        if(!procesName.containsIgnoreCase('Auto') && productCodeWithLM!=''){
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixCSWDCL){
                
                if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix,productCodeWithLM) && (queryForAgpLM.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                    if(!reqFromShowNextApprover){
                        app = new Approval_History__c();
                        app = getAppRecord(matrix, procesName);
                        lstapprovalhistory.add(app);
                    }else{
                        approvalMatrixForShowNextApprover.add(matrix);
                    }
                }
            }
        }
        // for MM products - //13562
        if(!procesName.containsIgnoreCase('Auto') && productCodeWithMM!=''){
            for(Approval_Process_Escalation_Matrix__c matrix : approvalMatrixCSWDCL){
               
                
                if(procesName == matrix.Approval_Process_Name__r.Name && isProduct(procesName, matrix,productCodeWithMM) && (queryForAgpMM.contains(matrix.Total_GP__c) || matrix.Total_GP__c == null || matrix.Total_GP__c == '')){
                    if(!reqFromShowNextApprover){
                        app = new Approval_History__c();
                        app = getAppRecord(matrix, procesName);
                        lstapprovalhistory.add(app);
                    }else{
                        approvalMatrixForShowNextApprover.add(matrix);
                    }
                }
            }
        }
        
        return lstapprovalhistory;
    }
    
    private static Approval_History__c getAppRecord(Approval_Process_Escalation_Matrix__c matrix, String procesName){
        //String productInfoStamp = OMEBProductStampCLs.getProductInfo(productForApproval,opptyId,matrix);
        Approval_History__c app = new Approval_History__c();
        //app.Opportunity_Product__c = productInfoStamp;
        app.Type__c = System.label.OMEB_typeInitial_submission;
        app.Step_Name__c = matrix.Step_Name__c;
        app.Submitter_Comments__c = comment;
        app.TargetObjectId__c = opptyId;
        app.Process_Name__c = procesName;
        if(matrix.Auto_Approved__c){
            app.Status__c = Approved;
            app.Approved_By__c = UserInfo.getUserId();
            app.Assigned_To__c = UserInfo.getUserId();
        }else{
            app.Status__c = Pending;
            app.Approved_By__c = matrix.Current_owner__c;
            app.Assigned_To__c = matrix.Current_owner__c;
        }
        app.Approval_Step__c = matrix.ID;
        String keywithResponse = matrix.Key__c+'-'+matrix.Response_type__c;
        if(mapOfKey.containsKey(keywithResponse)&& matrix.Response_type__c==System.Label.First_Response) {
            keyTemp = mapOfKey.get(keywithResponse);
            system.debug(matrix.Response_type__c);
        }else{
            string gd = getGUID();
            keyTemp = gd + matrix.Key__c;
            mapOfKey.put(keywithResponse, keyTemp);
        }
        app.key__c = keyTemp;
        app.SLA__c = matrix.Approval_Process_Name__r.SLA__c;
        if(matrix.Current_owner__r.DelegatedApproverId != null){
            app.Delegated_approver__c = matrix.Current_owner__r.DelegatedApproverId;
        }
        system.debug('key'+app.key__c+' '+app.Step_Name__c+''+app.Assigned_To__c+''+matrix.Response_type__c);
        
        return app;
    }
    
    // This method to generate GUID- Generate the unique id
    public static String getGUID(){  
        Blob b;
        String h;
        b = Crypto.GenerateAESKey(128);
        h = EncodingUtil.ConvertTohex(b);
        guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        System.debug(guid);
        return guid;
    }
    
    //This method to check Process Name is from product 
    public static boolean isProduct(String processName,Approval_Process_Escalation_Matrix__c apMatrixRec,String productforapprovals){
        boolean isProduct = false;
        if(!processName.startsWithIgnoreCase(customLabelforPursuitGate)){
            for(String str:apMatrixRec.Product_for_approval__c.split(',')){
                String prodcode ='';
                prodcode = str;
                if(!str.contains('4PL')){
                    prodcode =str.replaceAll('[0-9]', '');}
                if(mapOfproductcodetoExecCountry.containsKey(prodcode)){
                    if(mapOfproductcodetoExecCountry.get(prodcode).contains(apMatrixRec.Country__c) && productforapprovals.contains(str)){
                        isProduct = true;
                        break;
                    }
                }else if(productforapprovals.contains(str)){
                        isProduct = true;
                        break;
                }
            }
        }else{
            isProduct=true;
        }
        return isProduct;
    }
     // This method is to calculate Total Annualized GP of MM products - //13562
    public static List<String> toCalculateTottalAGPforMM(Decimal checkAGP){
        system.debug('checkAGP'+checkAGP);
        if(checkAGP == null){
            return agpMM;} 
       if((checkAGP >250000) && (processNameList.contains('Pre-Win Gate Products') )) {
            agpMM.add('>250000'); 
        }
        if(checkAGP >=100000){
          
            agpMM.add('>100000'); 
        }
        
        return agpMM;
    }
    // This method is to calculate Total Annualized GP of LM products
    public static List<String> toCalculateTottalAGPforLM(Decimal checkAGP){
        system.debug('checkAGP'+checkAGP);
        if(checkAGP == null){
            return agpLMmorethan;} 
        if((checkAGP >=250000) && (processNameList.contains('Pre-Win Gate Products') )){
            agpLMmorethan.add('>250000'); 
        }
        else if((checkAGP >50000) && (processNameList.contains('Pre-Win Gate Products') )) {
            agpLMmorethan.add('>50000'); 
        }
        
        return agpLMmorethan;
    }
    // This method is to calculate Total Annualized GP of MCS Products
    public static List<String> toCalculateTottalAGP(){
        List<String> tempTotalAGP = new List<String>();
        if(totalSumOfAGPofMC == null){
            return tempTotalAGP;}
        if(totalSumOfAGPofMC>1000000){
            tempTotalAGP.add('>1000000');
        }
        if(totalSumOfAGPofMC>100000 && MCSgt100kregions.contains(userRegion)){
            tempTotalAGP.add('>100000'); 
        }
        if(totalSumOfAGPofMC>50000 && MCSgt50kregions.contains(userRegion)){
            tempTotalAGP.add('>50000'); 
        }
        return tempTotalAGP;
    }
    
    
    //This method to calculate Total GP
    public static List<String> toCalculateTottalGP(){
        List<String> tempTotalGP = new List<String>();        
        if(totalGrossProfit==null){
            return tempTotalGP;
        }
        if(totalGrossProfit<1000000){
            tempTotalGP.add('<1000000'); 
        }
        if(totalGrossProfit<5000000){
            tempTotalGP.add('<5000000') ;
        }
        if(totalGrossProfit>1000000){
            tempTotalGP.add('>1000000') ;
        }
        if(totalGrossProfit>5000000){
            tempTotalGP.add('>5000000') ;
        }
        return tempTotalGP;
    }
    //SFSE-14873 Method to calculate which gates/subgates needs to be skipped for Renewal and Additional Business opportunities
    private static List<String> SkipApprovals(String lstofcodes, String processName){
        List<String> productCodesListOwnCountry = new List<String>(lstofcodes.split(','));
        List<String> productcodestoremove = new List<String>();
        if(opptyType == 'Renewal'){
                for (Integer i = 0; i < productCodesListOwnCountry.size(); i++){
                    if(mapProdApprcodetomdt.containsKey(productCodesListOwnCountry[i])){
                        if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Renewal__c){
                            if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Pursuit_for_Renewal__c != null && processName.containsIgnorecase(Label.Pursuit_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Pursuit_for_Renewal__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Qualification_for_Renewal__c != null && processName.containsIgnorecase(Label.Feasibility_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Qualification_for_Renewal__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_solution_for_Renewal__c != null && processName.containsIgnorecase(Label.Solution_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_solution_for_Renewal__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Pre_Win_for_Renewal__c != null && processName.containsIgnorecase(Label.Pre_Win_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Pre_Win_for_Renewal__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }
                        }
                    }
                }
            }else if(opptyType == 'Additional Business'){
                for (Integer i = 0; i < productCodesListOwnCountry.size(); i++){
                    if(mapProdApprcodetomdt.containsKey(productCodesListOwnCountry[i])){
                        if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Renewal__c){
                            if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Pursuit_for_Additional_Business__c != null && processName.containsIgnorecase(Label.Pursuit_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Pursuit_for_Additional_Business__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Qualification_for_Add_Business__c != null && processName.containsIgnorecase(Label.Feasibility_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Qualification_for_Add_Business__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_solution_for_Additional_Business__c != null && processName.containsIgnorecase(Label.Solution_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Solution_for_Additional_Business__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }else if(mapProdApprcodetomdt.get(productCodesListOwnCountry[i]).Skip_Pre_Win_for_Additional_Business__c != null && processName.containsIgnorecase(Label.Pre_Win_Gate)){
                                List<String> tempkey = mapProdApprcodetomdt.get(productCodesListOwnCountry[i])?.Skip_Pre_Win_for_Additional_Business__c?.split(';');
                                if(tempkey.contains(processName)){
                                    productCodesListOwnCountry.remove(i);
                                }
                            }
                        }
                    }
                }
            }
        return productCodesListOwnCountry;
    }
    
    private static void approvalHistoryRecordCreate(List<Approval_History__c> lstapprovalhistoryToCreate){
        if(lstapprovalhistoryToCreate.isEmpty()){
            errorMessage = true;
            lsterrorMessage.add(System.Label.OMEB_No_Applicable);
        }else {
            errorMessage= false;
        }
        apHistoryResultSuccessIds = new Set<Id>();
        if(!lstapprovalhistoryToCreate.isEmpty() && lsterrorMessage.isEmpty()) {   
            Database.SaveResult[] apHistoryResult = Database.insert(lstapprovalhistoryToCreate, true);
            ErrorLogger.writeErrors('SFDC', 'OMEB 3.0', 'CustomApprovalProcessHandler.approvalHistoryRecordCreate ', apHistoryResult, lstapprovalhistoryToCreate);
            for (Database.SaveResult sr : apHistoryResult) {
                if (sr.isSuccess()) {
                    apHistoryResultSuccessIds.add(sr.getId());
                }
            }
            sendEmailAlert(apHistoryResultSuccessIds); 
        }
    }
    
    
    private static void getUserRegion(){
        
        List<BDA_Geography__c> bdaGeographies = [SELECT Id, Geography__c, BDA__c, BDA__r.Name, BDA__r.Parent_BDA__r.name, Geography__r.Name, bda__r.BDA_Code__c, bda__r.Type__c, bda__r.GEO_ID__c
                                                 FROM BDA_Geography__c 
                                                 WHERE BDA__r.Type__c = 'Cluster' AND Geography__r.Type_Of_Location__c = 'Country' AND bda__r.Active__c = true AND Geography__r.Name =: opportunityRecord.Opportunity_Owner_Country__c];
        
        if(bdaGeographies.size() > 0){
            System.debug('bdaGeographies '+bdaGeographies[0].BDA__r.Parent_BDA__r.Name);
            userRegion = bdaGeographies[0].BDA__r.Parent_BDA__r.Name;
        }
        
    }
    
    //This method is to send email alert to assigned approver
    public static void sendEmailAlert(set<Id> aphIds){
        String Template = System.Label.OMEB_ApprovalHistory;
        List<Approval_History__c> lstOfappHistoryEmail = [select Id, Approved_By__r.Email,Approved_By__c, TargetObjectId__c, Status__c,Delegated_approver__c,Delegated_approver__r.Email, Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover, Approved_By__r.UserPreferencesReceiveNoNotificationsAsApprover from Approval_History__c where Id in :aphIds]; 
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name=:Template limit 1];
        
        for(Approval_History__c ap:lstOfappHistoryEmail){
            if(ap.Status__c == Pending){
                if(ap.Approved_By__r.UserPreferencesReceiveNoNotificationsAsApprover == false){
                    emailList.add(createEmail(ap,et,ap.Approved_By__r.Email));
                }
                if(ap.Delegated_approver__c != null && ap.Delegated_approver__r.UserPreferencesReceiveNotificationsAsDelegatedApprover == true){
                    emailList.add(createEmail(ap,et,ap.Delegated_approver__r.Email));
                }
            }
        }
        system.debug('emailList@@'+emailList);
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList,false);
        }
    }
    
    // This method is create template for email
    public static Messaging.SingleEmailMessage createEmail(Approval_History__c ap, EmailTemplate  et, string approverEmail){
        set<string>setEmailAddress = new set<String>();
        system.debug('approverEmail@@@@'+approverEmail);
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setTemplateId(et.id);
        String[] toAddresses = new String[] {approverEmail};//,approverEmail
            emailMsg.setToAddresses(toAddresses);
        emailMsg.setTargetObjectId(ap.Approved_By__c);
        emailMsg.setWhatId(ap.Id);
        emailMsg.setSaveAsActivity(false);
        emailMsg.setUseSignature(false);
        emailMsg.setTreatTargetObjectAsRecipient(false);
        emailMsg.setReplyTo(ReplyEmailAddress);
        
        return emailMsg;
    }
    
    //Wrapper class 
    public class ApprovalWrapper{
        @InvocableVariable public String recordId;
        @InvocableVariable public String inputComment;
        @InvocableVariable public String processName;
        @InvocableVariable public List<String> processNameList;
        @InvocableVariable public Boolean reqFromShowNextApprover;
    }
    
}