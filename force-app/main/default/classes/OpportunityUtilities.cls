/*
* Trigger Handler Utility Class for Opportunity Trigger
* 
* Version   Date            Owner                               RQ#             Description
****************************************************************************************************************************************
* 16.1      29/04/2019      Sidhartha Mohapatra                 #RQ-010374      Added Commiment__c field.
* 17.0      06-Jun-2019     manjunath.c.holekade@maersk.com     #RQ-010819      Removal of references of deprecated fields
* 17.1      06-Jun-2019     Neha- TCS                           #RQ-010548      Added method getNextQuaterStartAndEndDate() to get dates for next Quarter for Quarterly deal Opportunity
* 18.0      22-Oct-2019     Sidhartha@maersk.com                #RQ-012032      Removed auto cloning functionality.
* 19.0      25-Nov-2019     manjunath@maersk                    #RQ-012233      New method, 'addDngrsGoodsTeamMembers', for adding new dangerous cargo team members
* 20.0      16-Sep-2022     Nitin@Maersk                        SFSE-9341       Added validateFeaturesMandatory method
* 21.0      02-Jan-2023     Aleena@Maersk                       SFSE-9813       Added two methods:createOmebKpi and updateOmebKpi.
 * 22.0      01-Jun-2023     Kiran@Maersk                        SFSE-9502       Clone Opportunity & OLIs with latest version
* 23.0      04-Aug-2023     Shashi@Maersk                       SFSE-10610      Added method validateRequiredFieldsOppty
* 24.0      25-Aug-2023     Kiran@Maersk                        SFSE-12203      OMEB new products Air/LCL & MCS Live issue fixes
* 25.0      15-Sep-2023     Ritika@Maersk                       SFSE-11551      added new fields for the Opportunity_Product_Configuration__c
* 26.0      22-Sep-2023     shashi@Maersk                       SFSE-12560      Remove Validation for Contract Logistics Financial fields
* 27.0      20-Sep-2023     Shilpa@maersk
* 28.0      16-Oct-2023     Shashi@Maersk                       SFSE-12969      Added logic to nullify certain fields on oppty clone
* 29.0      16-Oct-2023     Shashi@Maersk                       SFSE-12546      Modified validateFeaturesMandatory() 
* 30.0      07-Nov-2023     Shashi@Maersk                       SFSE-12881      Added checkOpptyCloneEligibility() to check if opportunity is eligible to clone or not 
* 31.0      24-Nov-2023     Avinash@Maersk                      SFSE-13206      "clone", "renew", "report as lost" or "upgrading to the latest version" for Packaged Solutions
* 32.0      30-Nov-2023     Shilpa@Maersk                       SFSE -11497      Added logic to check which type of product added to the Opportunity and populate the Selected Product Type field accordingly.
* 33.0      06-Dec-2023     Shashi@Maersk                       SFSE-13130      Modified validateFeaturesMandatory() to remove Quarterly deals RT specific check
* 34.0      19-Dec-2023     Shashi@Maersk                       SFSE-13499      Added logic to autopopulate "Business Process" field for P2Q journey
* 35.0      04-Jan-2024     Jothsana@Maersk                     SFSE-13322      Remove the logic added for OMEB_Process_KPI__c object
* 36.0      07-Jan-2024     Sunil.bs@Maersk                     SFSE-13790      Added validation to check if Product revenue per unit field is field for Lns portfolio cases
* 37.0      18-Jan-2024     Shilpa@Maersk                       SFSE-13409      Added logic to remove the non P2Q products from opportunity when Customer Journey marked as Instant quote
* 38.0      31-Jan-2024     Avinash@Maersk                      SFSE-12654      Clone and auto-renew an opportunity with the latest solution version
* 39.0      02-Feb-2024     Shilpa@maersk                       SFSE-13802      Added logic to prevention to change customer journey field when file opportunity files is uploaded and Quote is created.
* 34.0      12-Feb-2024     Shashi@Maersk                       SFSE-12532      Optimized validateQualifyStage() for P2Q flow.
* 35.0		16-Feb-2024		Vinay@Maersk						SFSE-14250		Added Logic to Nullify Offer Status field when an Opportunity is Clonned.
* 36.0      24-Feb-2024     Shashi@Maersk                       SFSE-13681      Added logic to validate product retirement (End of sales/service)
* 37.0      22-Mar-2024     Anjali@Maersk                       SFSE-13670      Added Logic to populate X_Auto_Renew__c value and keep Auto_Renew__c in sync acc. to Agreement Dates
*38.0       27-Mar-2024     Bharti@Maersk                       SFSE-14196      Added method to show an error while updating auto renew field .
 * 39.0      15-Apr-2024     Bharti@Maersk                       SFSE-14619      Add methods to move workflow/Process Builder logic to apex.
 * 40.0      19-Apr-2024     Shashi@Maersk                       SFSE-13391      Update Record Locked field to true when Opportunity is Closed Lost/Won.
 * 41.0		 29-04-2024		 Vinay@Maersk						 SFSE-14918		 Added a check to skip creating Non OIPC in active products during Opportunity clone.
 * 42.0      02-May-2024     Shashi@Maersk                       SFSE-13391      Added logic to unlock opportunity record when opportunity is opened by LiveHelp
 * 43.0      16-May-2024     Shashi@Maersk                       SFSE-13391      For cloned oppties making record locked as false & Nullifying Reason for Unlocking, Opportunity Unlocked date.
* 44.0		 13-06-2024		 Ramya@Maersk						 SFSE-15459		 Track Product Creation (opportunity Clone)
* 45.0		 13-06-2024		 Aditi@Maersk						 SFSE-15173		 Handling exception on DML update listOpptyWithCloneSourceId
* 46.0      27-Jun-2024     Shashi@maersk                       SFSE-15486      To Allow close date change on unlocked oppty for Clerical Error reason for unlocking.
 * 47.0      03-July-2024    Shilpa@Maersk                       SFSE-15095      Added logic to validate Estimated Footprint Field for MCL Product.
//test
 */ 

public class OpportunityUtilities {
    public static Boolean firstRunComplete = false;
    private static List<String> lstOIPCCodesWD = Label.OIPC_Code_WD.split(';');
    private static Id supplyChainRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
    private static Id quarterlyDealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppQuarterlyDealRecordType).getRecordTypeId();
    private static Id shippingCargoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppShippingCargoRecordType).getRecordTypeId();
    private static List <String> lstProfileIDsAllowStageChngClosedUnlockedOppty = Label.Profile_ID_Allow_Stage_Change_Closed_Unlocked_Oppty.split(';');
    private static List <String> lstProfileIDsAllowUpdateClosedUnlockedOppty = Label.Profile_ID_Allow_Update_Closed_Unlocked_Oppty.split(';');
    public static void shareContract( List<Opportunity> newOppList, map<Id, Opportunity> mapOldOppty) {  
        Set<Id> oppIds = new Set<Id>();
        Set<Id> oppOwnerIds = new Set<Id>();
        Map<Id, Id> oppIdtoOwnerId = new Map<Id, Id>();
        for(Opportunity op: newOppList) {
            Opportunity oldOp = (Opportunity) mapOldOppty.get(op.Id);
            oppIds.add(op.Id);
            oppOwnerIds.add(oldOp.OwnerId);
            oppIdtoOwnerId.put(op.Id, op.OwnerId);
        }
        List<Contract__share> contractShare = [SELECT Id, UserOrGroupId FROM Contract__share WHERE UserOrGroupId IN: oppOwnerIds];
        If(contractShare.size() > 0) {
            delete contractShare;
        }
        List<Opportunity_Contract__c> lstContract = [SELECT Id, Contract__c, Opportunity__c from Opportunity_Contract__c where Opportunity__c  IN:oppIds];
        List<Contract__Share> cOShareListToCreate = new List<Contract__Share>();
        Map<Id, List<Id>> mapOfOppIdtoContractId = new Map<Id,List<Id>>();
        for(Opportunity_Contract__c coN: lstContract) {
            Contract__Share coNtoShare = new Contract__Share();
            coNtoShare.ParentId =  coN.Contract__c;
            coNtoShare.UserOrGroupId = oppIdtoOwnerId.get(coN.Opportunity__c);
            coNtoShare.RowCause = 'Manual';
            coNtoShare.AccessLevel = 'Read';  
            cOShareListToCreate.add(coNtoShare);
        } 
        try{
            Database.insert(cOShareListToCreate); 
        }
        Catch(Exception e) {
            ErrorLogger.writeErrors('SFDC', 'Contract', 'OpportunityUtilities.shareContract', new list < Exception > {
                e
            });
        }
        
    }
    
    public static void UpdateAFLSQuoteOwner( List<Opportunity> newOpptyList ) {


        Map<Id, String> oppIdToOppOwnrMap = new Map<Id, String>(); // Map to keep track of Opportunity Id to its corresponding new owner
        List<Qt_Quote__c> aflsQtListToBeUpdated = new List<Qt_Quote__c>(); // Stores AFLS Quotes for which owners need to be updated.
        
        for(Opportunity oppty : newOpptyList ){
            oppIdToOppOwnrMap.put( oppty.Id, oppty.OwnerId );                  
        }
        for( Qt_Quote__c aflsQt : [ SELECT id, ownerId, Opportunity__c FROM Qt_Quote__c where Opportunity__c IN :oppIdToOppOwnrMap.keyset() ] ){
            
            aflsQt.OwnerId = oppIdToOppOwnrMap.get( aflsQt.Opportunity__c );
            aflsQtListToBeUpdated.add( aflsQt );        
        }           
        if( !aflsQtListToBeUpdated.IsEmpty() ){
            
            database.update ( aflsQtListToBeUpdated, false );    // Updating the AFLS Quote Owner based on the corresponding Opportunity owner change
            
        }   
    }
    //RQ-010348: Start
    public static void UnlockApprovalProcessRecord(List<Opportunity> lstUnlockRecordApprovalProcess) {

        List<Opportunity> lstoppsubmitofapproval = new list<Opportunity>();
        List<Opportunity> setUpdateOppsubmitofapproval =new  List<Opportunity>();
        lstoppsubmitofapproval =  [SELECT Id, Submitted_For_approval__c FROM Opportunity where Id IN:lstUnlockRecordApprovalProcess];
        

        for(opportunity oppid : lstoppsubmitofapproval){
            oppid.Submitted_For_approval__c = false;
            setUpdateOppsubmitofapproval.add(oppid);
        }
        if(setUpdateOppsubmitofapproval.size()>0)
            update setUpdateOppsubmitofapproval ;
        
    }
    //RQ-010348:End
    
    public static void addDngrsGoodsTeamMembers(List<Opportunity> lstOpptywithDngrGoods){
        Set<String> setCountryNames = new Set<String>();
        Map<Id,String> mapOpptyIdtoRegion = new Map<Id,String>();
        Map<String, List<String>> mapRegiontoDGTeamMembers = new Map<String, List<String>>();
        Map<String, Id> mapUserNametoUserId = new Map<String, Id>();
        Map<String, String> mapCntryRegion = new Map<String,String>();
        List<OpportunityTeamMember> lstToBeInsertedOpptyTeamMem = new List<OpportunityTeamMember>();
        List<String> lstFinalUsernames = new List<String>();
        for(Opportunity lstOpptywithDngrGoodsVar:lstOpptywithDngrGoods){

            setCountryNames.add(lstOpptywithDngrGoodsVar.Opportunity_Owner_Country__c.toUpperCase());
        }

        for (BDA_Geography__c lstBDAGeo: [select Id, Geography__r.Name, BDA__r.Parent_BDA__r.Name from BDA_Geography__c where Geography__r.Name in: setCountryNames and BDA__r.Type__c = 'Cluster'
                and BDA__r.Parent_BDA__r.Type__c = 'Trade Region'
                and BDA__r.Active__c = true and BDA__r.Parent_BDA__r.Active__c = true
            ]) {
            mapCntryRegion.put(lstBDAGeo.Geography__r.Name.toUpperCase(), lstBDAGeo.BDA__r.Parent_BDA__r.Name);
        }

        for(Opportunity lstOpptywithDngrGoodsVar:lstOpptywithDngrGoods){
            mapOpptyIdtoRegion.put(lstOpptywithDngrGoodsVar.Id,mapCntryRegion.get(lstOpptywithDngrGoodsVar.Opportunity_Owner_Country__c.toUpperCase()));
        }
        String strSandboxUnigueName = '';
        if(StaticFactory.getEnvironment() == 'Sandbox') strSandboxUnigueName = URL.getSalesforceBaseUrl().getHost().substringBetween('--','.').toLowerCase();
        for(Dangerous_Goods_Mapping_Details__mdt dangGoodsMappDet : [SELECT MasterLabel,Manager_Username__c FROM Dangerous_Goods_Mapping_Details__mdt]){                                                       
            List<String> lstUsernames = dangGoodsMappDet.Manager_Username__c.split(';');
            List<String> lstUsrnameswithSandbox = new List<String>();       
            if(StaticFactory.getEnvironment() == 'Sandbox'){
                for (Integer i = 0; i < lstUsernames.size(); i++) {
                    lstUsrnameswithSandbox.add(lstUsernames[i] + '.' + strSandboxUnigueName);
                }
                mapRegiontoDGTeamMembers.put(dangGoodsMappDet.MasterLabel, lstUsrnameswithSandbox);
                lstFinalUsernames.addall(lstUsrnameswithSandbox);
            }else{
                mapRegiontoDGTeamMembers.put(dangGoodsMappDet.MasterLabel,lstUsernames);
                lstFinalUsernames.addall(lstUsernames);
            }       
        }

        for(User userVar:[select Id,Username from User where Username in :lstFinalUsernames and IsActive = true]){
            mapUserNametoUserId.put(userVar.Username, userVar.Id);
        }

        for(Id opptyId:mapOpptyIdtoRegion.keySet()){
            if(mapRegiontoDGTeamMembers.containsKey(mapOpptyIdtoRegion.get(opptyId))){
                for(String username:mapRegiontoDGTeamMembers.get(mapOpptyIdtoRegion.get(opptyId))){
                    OpportunityTeamMember opptyTeamMemObj= new OpportunityTeamMember();
                    opptyTeamMemObj.UserId = mapUserNametoUserId.get(username);
                    opptyTeamMemObj.OpportunityId = opptyId;
                    opptyTeamMemObj.TeamMemberRole = Label.Team_Role_Label_Dangerous_Goods_Solutions_Manager;
                    lstToBeInsertedOpptyTeamMem.add(opptyTeamMemObj);
                }
            }
        }
        if(lstToBeInsertedOpptyTeamMem.size() > 0){
            Database.SaveResult[] lstSaveResult = Database.Insert(lstToBeInsertedOpptyTeamMem,false);
            ErrorLogger.writeErrors('SFDC', 'Opportunity', 'OpportunityUtilities.addDngrsGoodsTeamMembers', lstSaveResult, lstToBeInsertedOpptyTeamMem);
        }
    }
    
    public static void CheckIfParent(List<Opportunity> checkIfParent) {
        Set<Id> setOpptyParentId = new Set<Id>();
        
        for(Opportunity lstOppty:checkIfParent){
            if(lstOppty.Parent_Opportunity__c!=null){
                setOpptyParentId.add(lstOppty.Id);
            }
        }

        Map<Id, Opportunity> mapParentOppty = new Map<Id, Opportunity>([SELECT Id, Parent_Opportunity__c FROM Opportunity WHERE Parent_Opportunity__c in :setOpptyParentId]);

        for(Opportunity lstOppty:checkIfParent){
            if(mapParentOppty.size()>0){
                lstOppty.addError(Label.OpptyParentExist);
            }
        }
        
    }
    //SFSE-12546
    public static void validateFeaturesMandatory(List<Opportunity> lstOppToValidate){
        
        for (Opportunity recOp : lstOppToValidate){
            Boolean IsFeaturesNotFilled = (recOp.Count_of_Total_Config_not_filled__c > 0) ? true : false;
            if(recOp.Approval_Required__c == 'No' || recOp.StageName == System.Label.Negotiating || recOp.StageName == System.Label.close_won){
                if (IsFeaturesNotFilled){
                    recOp.addError(Label.FeatureMandatory_Error);
                }
            }
        }
    }
    
    //SFSE-10610
    /**public static void validateRequiredFieldsOppty(List<Opportunity> lstOppts){
// Map to store Opportunity Ids and related Opportunity products
Map<Id, List<Opportunity_Product__c>> opportunityProdcutsMap = new Map<Id, List<Opportunity_Product__c>>();

// Collect Opportunity Ids for querying related Opportunity Products
Set<Id> opportunityIds = new Set<Id>();
for (Opportunity opportunity : lstOppts) {
opportunityIds.add(opportunity.Id);
}

// Query the related Opportunity products for all Opportunities
List<Opportunity_Product__c> allLineItems = [SELECT Id, OpportunityId__c,EBIT__c, Revenue__c, EBIT_Percent__c, Indirect_SG_A_Percent__c,NPV__c,IRR__c,Total_CAPEX__c,Capital_Expenditure__c,Building_Lease__c,Material_Handling_Equipment_Investments__c,Product_Family__c,OIPC_Product_Code__c FROM Opportunity_Product__c WHERE OpportunityId__c IN :opportunityIds];

// Populate the map with Opportunity Ids and related Opportunity products
for (Opportunity_Product__c lineItem : allLineItems) {

if (!opportunityProdcutsMap.containsKey(lineItem.OpportunityId__c)) {
opportunityProdcutsMap.put(lineItem.OpportunityId__c, new List<Opportunity_Product__c>());
}
opportunityProdcutsMap.get(lineItem.OpportunityId__c).add(lineItem);
}
// Loop through each Opportunity and its Opportunity Line Items
for (Opportunity opportunity : lstOppts) {
List<Opportunity_Product__c> lineItems = opportunityProdcutsMap.get(opportunity.Id);

// Check if any Opportunity Line Item is missing required fields
for (Opportunity_Product__c lineItem : lineItems) {
if(lineItem.OIPC_Product_Code__c!=null && lstOIPCCodesWD.contains(lineItem.OIPC_Product_Code__c)){
if (lineItem.EBIT__c==null || lineItem.Revenue__c==null || lineItem.NPV__c==null || lineItem.IRR__c==null || lineItem.Total_CAPEX__c==0.0 || lineItem.Capital_Expenditure__c==null || lineItem.Building_Lease__c==null || lineItem.Material_Handling_Equipment_Investments__c==null){
opportunity.addError(System.Label.Revenue_EBIT_Indirect_SG_A_Capex_NPV_and_IRR_fields_must_be_updated_before);
}
}
}
} 
}*/
    
    public static void validateQualifyStage(Map<Id, Opportunity> mapOppToValidate) {
    List<Opportunity> lstOpp = [Select Id,(Select Id, Opportunity__c,Status__c from Quotes1__r),Customer_Journey__c,RecordTypeId from Opportunity where ID IN :mapOppToValidate.keySet()];
        for(Opportunity opp : lstOpp){
            if(opp.Quotes1__r.size() ==0 && mapOppToValidate.containsKey(opp.Id)){
                Opportunity OppInContext = mapOppToValidate.get(opp.Id);
                if (opp.Customer_Journey__c == Label.Instant_Quote) {
                    OppInContext.addError('Please upload RFQ File in Instant Quote Tab to move beyond Designing Proposal stage');
                } else if(opp.RecordTypeId == shippingCargoRecordTypeId) {
                    OppInContext.addError('Opportunities with Tenders should upload RFQ in Tender section to move beyond Designing Proposal stage');
                }
                
            }
        }
    }

    
    //to validate Opportunity Product for OMEB 
    @InvocableMethod(label = 'Validate Product Upgrade'
        description = 'Validating product Upgrades')
    public static List<string> submitForApprovalInstanceInvocable(ApprovalWrapper[] wrapRec){
        List<string> error = new List<string>();
        ApprovalWrapper wrap = wrapRec[0];
        String opptyId = wrap.recordId;
        List < opportunity > opportunityRecord = [Select Id, Owner.Region__c, Approval_Required__c, RecordType.DeveloperName, Owner_Area_Code__c, OwnerId, Liner_Brand__c, Opportunity_Owner_Country__c, Total_GP_of_OMEB_Products__c, Requires_Custom_Integration__c, StageName, Account.Vertical__c, Requires_IT_Integration__c, Products_for_Approval__c, Approval_Status__c, Last_Shipment_Date__c FROM Opportunity WHERE id =: opptyId];
        Map<Id,boolean> MapOppToValidateOLIflag = new Map<Id,boolean>();
        MapOppToValidateOLIflag = validateProductUpgrade(opportunityRecord);
        Map<Id,String> MapOpptytoProductRetirementError = new Map<Id,String>();
        MapOpptytoProductRetirementError = validateOpptyProductRetirement(opportunityRecord, null); //SFSE-13681
        map<Id,Boolean>  mapOppToValidateSqmfield = new map<Id,Boolean>();
        mapOppToValidateSqmfield = validateFootprintSqmField(opportunityRecord);
        if(!MapOppToValidateOLIflag.isEmpty()){
            for(opportunity opp : opportunityRecord){
                if(MapOppToValidateOLIflag.containsKey(opp.id) && MapOppToValidateOLIflag.get(opp.id) == true){
                    error.add(Label.Product_upgrade_error_omeb);
                }
            }
        }
        //SFSE-13681
        if(!MapOpptytoProductRetirementError.isEmpty()){
            for(opportunity opp : opportunityRecord){
                if(MapOpptytoProductRetirementError.containsKey(opp.id) && MapOpptytoProductRetirementError.get(opp.id) != null){
                    error.add(MapOpptytoProductRetirementError.get(opp.id));
                }
            }
        }
        if(!mapOppToValidateSqmfield.isEmpty()){
            for(Opportunity opp : opportunityRecord){
                if(mapOppToValidateSqmfield.containskey(opp.id) && mapOppToValidateSqmfield.get(opp.id) == true){
                    error.add('Please update the field- Estimated Footprint Requirement in Sqm in the product screen for any MCL products to proceed with your opportunity.');
                }
            } 
        }
        return error;
    }
    
    //Wrapper class 
    public class ApprovalWrapper{
        @InvocableVariable public String recordId;
    }
    
    public static void validateOpportunityProductUpgrade(List<Opportunity> lstOppToValidate){
        Map<Id,boolean> MapOppToValidateOLIflag = new Map<Id,boolean>();
        MapOppToValidateOLIflag = validateProductUpgrade(lstOppToValidate);
        if(!MapOppToValidateOLIflag.isEmpty()){
            for(opportunity opp : lstOppToValidate){
                if(MapOppToValidateOLIflag.containsKey(opp.id) && MapOppToValidateOLIflag.get(opp.id) == true){
                    opp.addError(Label.Product_upgrade_error);
                }
            }
        }
    }
    
    public static Map<Id,Boolean> validateProductUpgrade(List<Opportunity> lstOppToValidate){
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opportunity : lstOppToValidate) {
            opportunityIds.add(opportunity.Id);
        }
        Boolean ValidateOLIflag = false;
        Map<Id,boolean> MapOppToValidateOLIflag = new Map<Id,boolean>();
        Map<Id,String> mapOfOldProductVersion = new Map<Id,String>();
        Map<Id,String> mapOfNewProductVersion = new Map<Id,String>();
        Map<Id,List<Id>> mapOfOpptyIdAndProductId = new  Map<Id,List<Id>>();
        Map<String,Boolean> mapOfProductVersionAndService = new Map<String,Boolean>();
        for(Opportunity_Product__c prod:[SELECT id, Product2ID__r.IsActive,Product2ID__r.OIPC_ProductCode_Version__c, Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c,OpportunityId__c  FROM Opportunity_Product__c WHERE OpportunityId__c IN :opportunityIds AND Product2ID__r.IsActive = false AND Product2ID__r.Latest_Product_Version__c!= null]){
            if(!mapOfOldProductVersion.containsKey(prod.Id)){
                mapOfOldProductVersion.put(prod.Id, prod.Product2ID__r.OIPC_ProductCode_Version__c);
            }
            if(!mapOfNewProductVersion.containsKey(prod.Id)){
                mapOfNewProductVersion.put(prod.Id, prod.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c );
            }   
            if(mapOfOpptyIdAndProductId.containsKey(prod.OpportunityId__c)){
                mapOfOpptyIdAndProductId.get(prod.OpportunityId__c).add(prod.Id);
            }else{
                mapOfOpptyIdAndProductId.put(prod.OpportunityId__c, new List < Id > {
                    prod.Id
                });
            }
        }
        
        if(!mapOfOldProductVersion.values().isEmpty() && !mapOfNewProductVersion.values().isEmpty()){
            Set<String> lstOipcVersions= new Set<String>();
            lstOipcVersions.addAll(mapOfOldProductVersion.values());
            lstOipcVersions.addAll(mapOfNewProductVersion.values());
            if(!lstOipcVersions.isEmpty()){
                for(Product_Feature__c feat:[SELECT id,Default_Visibility__c, Categorisation__c,Product_Component__r.Product__r.OIPC_ProductCode_Version__c  FROM Product_Feature__c WHERE Product_Component__r.Product__r.OIPC_ProductCode_Version__c IN :lstOipcVersions 
                        AND(Categorisation__c =: 'Service'
                            OR Categorisation__c =: '') ORDER BY Display_Order__c, Name
                                            ]){
                                                
                                                if(mapOfProductVersionAndService.containsKey(feat.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                                                    if(feat.Default_Visibility__c != null && feat.Categorisation__c!= null && !mapOfProductVersionAndService.get(feat.Product_Component__r.Product__r.OIPC_ProductCode_Version__c)){
                                                        mapOfProductVersionAndService.put(feat.Product_Component__r.Product__r.OIPC_ProductCode_Version__c,true);
                                                    }
                                                }else{
                                                    Boolean check= feat.Default_Visibility__c != null && feat.Categorisation__c!= null ? true : false;
                                                    mapOfProductVersionAndService.put(feat.Product_Component__r.Product__r.OIPC_ProductCode_Version__c,check);
                                                }
                                            }
            }
            for(Opportunity recOp : lstOppToValidate){
                ValidateOLIflag = false;
                if(mapOfOpptyIdAndProductId.containsKey(recOp.Id)){
                    for(Id opptyProd: mapOfOpptyIdAndProductId.get(recOp.id)){
                        if(mapOfOldProductVersion.containsKey(opptyProd) && mapOfNewProductVersion.containsKey(opptyProd)){
                            if(mapOfProductVersionAndService.containsKey(mapOfOldProductVersion.get(opptyProd)) && mapOfProductVersionAndService.containsKey(mapOfNewProductVersion.get(opptyProd))){
                                if( !mapOfProductVersionAndService.get(mapOfOldProductVersion.get(opptyProd)) && mapOfProductVersionAndService.get(mapOfNewProductVersion.get(opptyProd))){
                                    //recOp.addError(Label.Product_upgrade_error);
                                    ValidateOLIflag = true;
                                    if(!MapOppToValidateOLIflag.containskey(recOp.Id)){
                                        MapOppToValidateOLIflag.put(recOp.Id,ValidateOLIflag);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return MapOppToValidateOLIflag;
    }
    //SFSE-15095
     public static map<Id,boolean> validateFootprintSqmField(List<Opportunity> opplist){ 
         set<Id> opportunityId = new set<id>();
         map<Id,boolean> mapOfblankSqmField = new map<Id,boolean>();
         if(!opplist.isEmpty()){ 
         for(Opportunity opp : opplist){
             opportunityId.add(opp.id);
         }
       }
         for(Opportunity_product__c oli : [Select id,name,Estimated_Footprint_Requirement_in_Sqm__c,Product_Family__c,Product2ID__r.OIPC_Code__c,OpportunityId__c from Opportunity_Product__c where OpportunityId__c In : opportunityId]){
             if(oli.Estimated_Footprint_Requirement_in_Sqm__c == null && oli.Product2ID__r.OIPC_Code__c!= null && Label.Warehousing_nd_Fulfillment_Oipc_Codes.contains(oli.Product2ID__r.OIPC_Code__c)){
                 mapOfblankSqmField.put(oli.OpportunityId__c,true);
             }         
             
         }
         return mapOfblankSqmField;
         
     }
    
    //SFSE-15095
     public static void validateSqmField(List<Opportunity> opplist){
         map<Id,Boolean> mapOfSqmfield = new map<Id,Boolean>();
         mapOfSqmfield = validateFootprintSqmField(opplist);
         if(!mapOfSqmfield.isEmpty()){
             for(Opportunity opp : opplist){
                 if(mapOfSqmfield.containskey(opp.id) && mapOfSqmfield.get(opp.id) == true){   
                    opp.addError('Please update the field- Estimated Footprint Requirement in Sqm in the product screen for any MCL products to proceed with your opportunity.');       
                 }
             }
         }
     }


    
    //SFSE-12881
    /**public static void checkOpptyCloneEligibility(List<Opportunity> lstOppRec) {
for (Opportunity opportunity : lstOppRec) {
List<Opportunity_Product__c> lstoppProd = [
SELECT Id, Product2ID__r.Name, Product2ID__r.IsActive, 
Product2ID__r.Latest_Product_Version__c, 
Product2ID__r.Latest_Product_Version__r.IsActive 
FROM Opportunity_Product__c 
WHERE OpportunityId__c = :opportunity.getCloneSourceId()
];
List<String> inactiveProductNames = new List<String>();
for (Opportunity_Product__c opptyProd : lstoppProd) {
if (opptyProd.Product2ID__r.IsActive == false && (opptyProd.Product2ID__r.Latest_Product_Version__c == null || opptyProd.Product2ID__r.Latest_Product_Version__r.IsActive == false)) {
inactiveProductNames.add(opptyProd.Product2ID__r.Name);
}
}
if (!inactiveProductNames.isEmpty() && inactiveProductNames.size() == lstoppProd.size()) {
String errorMessage = String.join(inactiveProductNames, ', ') + ' cannot be cloned due to "inactive" status. Please add another product and try again.';
opportunity.addError(errorMessage);
}
}
}*/
    
    //SFSE-13499
    public static void populateBusinessProcessFieldP2Q(List<Opportunity> lstOppRec) {
    for (Opportunity oppty : lstOppRec) {
        if (oppty.Customer_Journey__c != null && oppty.Customer_Journey__c == Label.Instant_Quote) {
            oppty.Business_Process__c = 'Instant Quote';
        } else if (oppty.RecordTypeId == supplyChainRecordTypeId || oppty.RecordTypeId == quarterlyDealRecordTypeId) {
            oppty.Business_Process__c = null;
                oppty.Tender_Submission_Format__c = null;
        } else if (oppty.RecordTypeId == shippingCargoRecordTypeId && oppty.Tender_Submission_Format__c != null && oppty.Tender_Submission_Format__c != 'No Ocean Tender') {
            oppty.Business_Process__c = 'Tender';
        } else {
            oppty.Business_Process__c = null;
        }
    }
        
}
     
    @future
    public static void cloneOpporutnityProductsWithLatest(Map<Id, Id> mapClonedOpptyToSourceId){
        Map<Id, Opportunity> sourceIdtoSourceOpptyMap = new Map<Id, Opportunity>();
        Set<Id> sourceOpptyIdSet = new Set<Id>(mapClonedOpptyToSourceId.values());
        List<Opportunity> opportunities = [SELECT Id, Name, Type FROM Opportunity WHERE Id IN :sourceOpptyIdSet];
        for (Opportunity opp : opportunities) {
            sourceIdtoSourceOpptyMap.put(opp.Id, opp);
        }
        List<Opportunity> listOpptyWithCloneSourceId = new List<Opportunity>();
        for(Id clonedOpptyId : mapClonedOpptyToSourceId.keySet()){
            String sourceOpptyType = sourceIdtoSourceOpptyMap.get(mapClonedOpptyToSourceId.get(clonedOpptyId)).Type;
            listOpptyWithCloneSourceId.add(new Opportunity(Id = clonedOpptyId, Clone_Opportunity_Source__c  = mapClonedOpptyToSourceId.get(clonedOpptyId), Parent_Opportunity__c = null, First_Time_Closed_Date__c = null, Approval_Status__c = '', Type = (sourceOpptyType == 'One-off (Non Renewable)') ? '' : sourceOpptyType, Other_Reason_For_Close__c = ''));
        }
        if(listOpptyWithCloneSourceId.size() > 0){
            TriggerExecutionController.skipOpportunityTrigger(true);
            try {
            update listOpptyWithCloneSourceId;
            } catch (Exception ex) {

                ErrorLogger.writeErrors('SFDC', 'OpportunityClone', 'OpportunityUtilities.cloneOpporutnityProductsWithLatest', new list < Exception > {
                    ex
                });
            }
            TriggerExecutionController.skipOpportunityTrigger(false); 
        }
        Map<Id, List<Opportunity_Product__c>> opptyIdToProducts = new Map<Id, List<Opportunity_Product__c>>();
        Set<Id> productIds = new Set<Id>();
        Map<String, Id> mapOldProdtoLatestProduct = new Map<String, Id>();
        Map<String, Id> mapOldProdtoLatestProductSol = new Map<String, Id>();
        Map<Id, Opportunity_Product__c> mapCustomOpptyProdToClone = new Map<Id, Opportunity_Product__c>();
        Opportunity_Product__c customOpptyProdToClone;
        Set<Id> setCustomOLIs = new Set<Id>();
        List<Opportunity_Product_Configuration__c> lstProdConfigsToInsert = new List<Opportunity_Product_Configuration__c>();
        Opportunity_Product_Configuration__c prodConfigsToInsert;
        String solutionLatestVersionId;
    
        Map<Id, Opportunity_Product__c> mapCustomOpptyProducts = new Map<Id,Opportunity_Product__c>([SELECT Id, Name,Definition_Type__c,Actuals_Loaded__c,Amend_Gross_Profit_per_unit__c,Amend_Expected_FFE__c,
                                                                                                     Blue_Collar_FTEs__c,Building_Lease__c,Cargo_Type__c,Comments__c,ServiceDate__c,Debug__c,
            Direct_Variable_Cost__c, Discount__c, EBIT__c,Exclude_from_OMEB__c, Exclude_from_SIP__c,
                                                                                                     Executing_City_State__c,Country__c,Fixed_Costs__c,UnitPrice__c,Import_Export__c,
                                                                                                     Indirect_FTEs__c,IsWndProduct__c,L_S_Product__c,Legacy_Opportuntity_LineItemId__c,
                                                                                                     Description__c,List_Price__c,Material_Handling_Equipment_Investments__c,Estimated_Footprint_Requirement_in_Sqm__c,
                                                                                                     Ocean_Product__c,OpportunityId__c,OpportuntityLineItemId__c,OpportyProductExtID__c,Opt_Out_Auto_Quantity_Scheduling__c,
            Capital_Expenditure__c, Total_Tender_FFE_per_Route_Direction__c, Previous_Tender_Target__c, Product2ID__c, Product2ID__r.OIPC_Code__c, Product2ID__r.IsActive, ProductCode__c,
                                                                                                     Quantity__c,Schedule_Details__c,Schedule_Product__c,SG_A__c,Special_Cargo__c,Subtotal__c,Tender_Target__c,Total_Configurations__c,
                                                                                                     Total_Configurations_Filled__c,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c,Trade_Guidance_Id__c,Trade_Route__c,
                                                                                                     Warehouse_Site__c,WND_Location_Type__c, Destination_Country__c,Solution__r.IsActive,Solution__c,Solution__r.Latest_Product_Version__c,Product_Revenue_Per_Unit__c,Total_Product_Revenue__c
                                                                                                     FROM Opportunity_Product__c 
            WHERE OpportunityId__c in: mapClonedOpptyToSourceId.values()
        ]);
        
        for(Opportunity_Product__c customOpptyProd : mapCustomOpptyProducts.values()){
            //SFSE-14918 - Added to stop creating In Active non OIPC products to a Clonned Opportunity.
            if(String.isBlank(customOpptyProd.Product2ID__r.OIPC_Code__c) && !customOpptyProd.Product2ID__r.IsActive){
                Continue;
            }

            if(opptyIdToProducts.containsKey(customOpptyProd.OpportunityId__c)){
                opptyIdToProducts.get(customOpptyProd.OpportunityId__c).add(customOpptyProd);
            }else{
                opptyIdToProducts.put(customOpptyProd.OpportunityId__c, new List < Opportunity_Product__c > {
                    customOpptyProd
                });
            }
            
            //SFSE-13206
            if(customOpptyProd != null && customOpptyProd.Definition_Type__c == 'Packaged Solution'){
                if(customOpptyProd.Solution__c != null && customOpptyProd.Solution__r.IsActive == true && customOpptyProd.Solution__r.Latest_Product_Version__c == null){
                    solutionLatestVersionId = customOpptyProd.Solution__c;
                    //productIds.add(customOpptyProd.Product2ID__c);
                }//SFSE-12654
                else if(customOpptyProd.Solution__c != null && customOpptyProd.Solution__r.IsActive == false && customOpptyProd.Solution__r.Latest_Product_Version__c != null){
                    solutionLatestVersionId = customOpptyProd.Solution__r.Latest_Product_Version__c;
                }
            } else {
                productIds.add(customOpptyProd.Product2ID__c);
            }

            /*
            if(String.isBlank(definitionType) && customOpptyProd.Definition_Type__c !=null){
                definitionType = customOpptyProd.Definition_Type__c;
            }*/
        }
        

        //SFSE-12654
        if(solutionLatestVersionId != null && solutionLatestVersionId != ''){
            for(Product_Reference__c prodRef : [SELECT Product__c,product__r.OIPC_Code__c FROM Product_Reference__c WHERE Solution__c =: solutionLatestVersionId]){
            
                mapOldProdtoLatestProductSol.put(prodRef.product__r.OIPC_Code__c, prodRef.Product__c );
                //productIds.add(prodRef?.Product__c);
            }
        }
        //Getting the latest product Id
        //If current procuct is active and doesn't have Latest_Product_Version__c, mapping with same product Id
        //If current procuct is inactive and have Latest_Product_Version__c, mapping with same Latest_Product_Version__c Id
        //If current procuct is inactive and does't have Latest_Product_Version__c, do not map
        for(Product2 product : [SELECT Id, Name, IsActive, OIPC_Code__c, Latest_Product_Version__c, Latest_Product_Version__r.IsActive 
                                FROM Product2 
                WHERE Id IN: productIds
            ]) {

                                    /*if(definitionType == 'Packaged Solution'){
                                        mapOldProdtoLatestProductSol.put(product?.OIPC_Code__c,product?.Id);
                                    }
                                    else{*/
                                        if(product.Latest_Product_Version__c == null && product.isActive == true){
                                            mapOldProdtoLatestProduct.put(product?.OIPC_Code__c, product.Id);
                                        }else if(product.IsActive == false && product.Latest_Product_Version__c != null && product.Latest_Product_Version__r.IsActive == true){
                                            mapOldProdtoLatestProduct.put(product?.OIPC_Code__c, product.Latest_Product_Version__c); 
                                        }
                                    //}
                                }



        for(Id clonedOpptyId : mapClonedOpptyToSourceId.keySet()){
            if(opptyIdToProducts.containsKey(mapClonedOpptyToSourceId.get(clonedOpptyId))){
                for(Opportunity_Product__c customOpptyProd : opptyIdToProducts.get(mapClonedOpptyToSourceId.get(clonedOpptyId))){
                    customOpptyProdToClone = new Opportunity_Product__c();
                    customOpptyProdToClone = customOpptyProd.clone();
                    customOpptyProdToClone.Opt_Out_Auto_Quantity_Scheduling__c = false;
                    customOpptyProdToClone.OpportuntityLineItemId__c = null;
                    customOpptyProdToClone.OpportunityId__c = clonedOpptyId;
                    customOpptyProdToClone.Product2ID__c = null; // for non oipc product
                    customOpptyProdToClone.Product_Creation_Source__c = System.Label.Opportunity_Clone;
                    if( customOpptyProd.Product2ID__r.OIPC_Code__c != null && mapOldProdtoLatestProduct.containsKey(customOpptyProd.Product2ID__r.OIPC_Code__c) && customOpptyProdToClone.Solution__c == null){
                        if(customOpptyProd.Product2ID__c != mapOldProdtoLatestProduct.get(customOpptyProd.Product2ID__r.OIPC_Code__c)){
                            customOpptyProdToClone.Total_Configurations_Filled__c = 0;
                            customOpptyProdToClone.Total_Mandatory_Configuration_Filled__c = 0;
                        }
                        customOpptyProdToClone.Product2ID__c = mapOldProdtoLatestProduct.get(customOpptyProd.Product2ID__r.OIPC_Code__c);
                    } else if( customOpptyProd.Product2ID__r.OIPC_Code__c != null && customOpptyProdToClone.Solution__c != null && (mapOldProdtoLatestProductSol.containsKey(customOpptyProd.Product2ID__r.OIPC_Code__c))){

                        if(customOpptyProd.Product2ID__c != mapOldProdtoLatestProductSol.get(customOpptyProd.Product2ID__r.OIPC_Code__c)){
                            customOpptyProdToClone.Total_Configurations_Filled__c = 0;
                            customOpptyProdToClone.Total_Mandatory_Configuration_Filled__c = 0;
                        }

                        customOpptyProdToClone.Product2ID__c = mapOldProdtoLatestProductSol.get(customOpptyProd.Product2ID__r.OIPC_Code__c);
                        //SFSE-12654
                        if(solutionLatestVersionId != null && solutionLatestVersionId != ''){
                            customOpptyProdToClone.Solution__c = solutionLatestVersionId;
                        }
                    } else if(customOpptyProd.Product2ID__r.OIPC_Code__c == null && customOpptyProd.Product2ID__r.IsActive){
                        customOpptyProdToClone.Product2ID__c = customOpptyProd.Product2ID__c;
                    }
                    if (customOpptyProdToClone.Product2ID__c != null) {
                    mapCustomOpptyProdToClone.put(customOpptyProd.Id, customOpptyProdToClone);
                }

                }
            }
        }

        
        if(mapCustomOpptyProdToClone.values().size() > 0){
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt;
            try{

                insert mapCustomOpptyProdToClone.values();
            }catch(Exception ex){

                ErrorLogger.writeErrors('SFDC', 'OpportunityClone', 'OpportunityUtilities.cloneOpporutnityProductsWithLatest', new list < Exception > {
                    ex
                });
            }
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
            for(Id sourceOLIId : mapCustomOpptyProdToClone.keySet()){
                //if(mapCustomOpptyProdToClone.get(sourceOLIId).Product2ID__c == mapCustomOpptyProducts.get(sourceOLIId).Product2ID__c){
                setCustomOLIs.add(sourceOLIId);
                //}
            }
        }
        
        Set<String> featMatrix = new Set<String>();
        Map<String,String> matrixMap = new Map<String,String>();
        for(SP_Visibility_matrix__mdt rec :  SP_Visibility_matrix__mdt.getAll().values()){
            if(rec.Product_Upgrade__c==true){
                matrixMap.put(rec.Default_Visibility_Features__c+'-'+rec.Default_Visibility_SP__c,rec.Default_Visibility_SP__c);
                featMatrix.add(rec.Default_Visibility_Features__c);
            }
        }
        
        set<id> newProducts = new  set<id>();
        set<id> OldProducts = new  set<id>();
        if(setCustomOLIs.size() > 0){
            for(Opportunity_Product_Configuration__c prodConfig : [select id, name, Component_Code__c, Feature_Code__c, Opportunity_Product__c, Opportunity_Product_Cus__c, Is_Feature_Included__c,
                                                                   Configured_Product_Component__c, Configured_Product_Feature__c, Is_Specification_Parameter_Included__c, 
                                                                   Product_Component__c, Product_Feature__c, Product_Specificaiton_Parameter__c, Product_Specification_Option__c, 
                                                                   Specification_Option_Name__c, Specification_Option_Order__c, Specification_Parameter_Code__c,Opportunity_Product_Cus__r.Product2ID__r.OIPC_Code__c ,Opportunity_Product_Cus__r.Product2ID__c
                                                                   FROM Opportunity_Product_Configuration__c 
                    WHERE Opportunity_Product_Cus__c IN: setCustomOLIs
                ]) {
                                                                       if(mapOldProdtoLatestProduct.containsKey(prodConfig.Opportunity_Product_Cus__r.Product2ID__r.OIPC_Code__c) &&
                                                                          mapOldProdtoLatestProduct.get(prodConfig.Opportunity_Product_Cus__r.Product2ID__r.OIPC_Code__c) == prodConfig.Opportunity_Product_Cus__r.Product2ID__c){
                                                                              prodConfigsToInsert = new Opportunity_Product_Configuration__c();
                                                                              prodConfigsToInsert = prodConfig.clone();
                                                                              	prodConfigsToInsert.Opportunity_Product_Cus__c = mapCustomOpptyProdToClone.get(prodConfig.Opportunity_Product_Cus__c).Id;    
                                                                              lstProdConfigsToInsert.add(prodConfigsToInsert);
                                                                          }else{
                                                                              newProducts.add(mapCustomOpptyProdToClone.get(prodConfig.Opportunity_Product_Cus__c).Id); //opp prod custom oli (with prod upgraded)
                                                                              OldProducts.add(prodConfig.Opportunity_Product_Cus__c); //corresponding custom oli's (new opp prod's) old oppty prod (with lower prod version)
                                                                          }
                                                                   }
        }
        

        //adjust the configurations based on the new version 
        if(newProducts.size()>0){            
            lstProdConfigsToInsert.addAll(OpportunityAutoRenewal.updateOpportunityConfigurations(newProducts, OldProducts));
        }
        

        if(lstProdConfigsToInsert.size() > 0){
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
                bt.Skip_Validation__c = true;
                insert bt;
            try{
                insert lstProdConfigsToInsert;
            }catch(Exception ex){

                ErrorLogger.writeErrors('SFDC', 'OpportunityClone', 'OpportunityUtilities.cloneOpporutnityProductsWithLatest', new list < Exception > {
                    ex
                });
            }
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
        }
        
    }
    

    /*Method : validateOpptyForALproducts
*Author : Kiran
*functionality : Prevent updating opportunity stage if an Air&LCL product added without filling the Air_LCL_custom_backend_required__c field
*/
    public static void validateOpptyForALproducts(List<Opportunity> opptywithALProducts){
        Id supplychainrecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.OppSupplyChainServicesRecType).getRecordTypeId();
        if(opptywithALProducts != null){
            for(Opportunity opp : opptywithALProducts){
                  
                opp.addError(Label.Air_and_LCL_Non_Supply_Chain_Error);  
            }
        }
    }
    
    
    /*Method : validateOpptyForMCSproducts
*Author : Kiran
*functionality : Prevent updating opportunity stage if an Customs Services & Insurance product added without filling the Requires_Custom_Integration__c field
*/
    public static void validateOpptyForMCSproducts(List<Opportunity> opptywithMCSProducts){
        if(opptywithMCSProducts != null){
            for(Opportunity opp : opptywithMCSProducts){
                opp.addError(Label.MCS_Error);
            }
        }
    }
    
    public static void validateDestinationCountryForAirLCLproducts(map<Id,Opportunity> OpptywithDestinationCountry){
        
        List<Opportunity_Product__c> oli = [Select id,name,OpportunityId__c,Product2ID__r.Type_of_Location_Needed__c,Destination_Country__c from Opportunity_Product__c where OpportunityId__c IN : OpptywithDestinationCountry.keyset()];

        for(Opportunity_Product__c Opp : oli){
            if(Opp.Product2ID__r.Type_of_Location_Needed__c == 'Origin & Destination' && opp.Destination_Country__c == null){
                OpptywithDestinationCountry.get(Opp.OpportunityId__c).addError('Destination Country must be provided when the \'Type of Location Needed \' is set to \'Origin and Destination\' for products. Kindly ensure that the Destination Country field is filled out for the products added.');
            }
        }
    }
    
    public static void populateProductType(map<Id,Opportunity> mapofOpp){
        set<String> values = new set<string>();
        List<Opportunity_Product__c> olilist = [Select id,name,OpportunityId__c, Definition_Type__c from Opportunity_Product__c where OpportunityId__c =: mapofOpp.keyset()];
        
        for(Opportunity_Product__c oli : olilist){
            values.add(oli.Definition_Type__c);   
        }
        
        for (Opportunity opportunity : mapofOpp.values()) {
            
            if (!values.isEmpty()) {
                opportunity.Product_Solution__c = String.join(values, ',');
            } else {
                opportunity.Product_Solution__c = '';
            }
            
        }
    }
    
    public static void removeOtherReasonForClosevalue(List<Opportunity>listOfopp){
        
        if(listOfopp!=null){
            for(Opportunity opp : listOfopp){
                opp.Other_Reason_For_Close__c = '';
            }
        }    
    }
    
    
    /** 
* @description | SFSE-13790 validate Product Revenue per unit for Non-OMEB
* @param caseList accepts case list
* @return list of cases
*/  
    public static void validateRevenueFieldforNonOmeb(Map<Id,Opportunity> mapOppToValidate){
        List<id> lstProductInScope = new list<id>();
        Map<id,id> mapOppIdToThrowError = new Map<id,id>();
        //Retrive all Opportunity products associated with opportunities in scope
        List<Opportunity_Product__c> lstOppProd = [Select Id,Product2ID__c,OpportunityId__c,Product_Revenue_Per_Unit__c,Product2ID__r.Portfolio__c,Product2ID__r.Is_Product_Add_On__c from Opportunity_Product__c where OpportunityId__c IN :mapOppToValidate.keySet()];
        if(!lstOppProd.isempty()){   
            for(Opportunity_Product__c oppProd : lstOppProd){
                if(oppProd.Product_Revenue_Per_Unit__c==null && string.isnotblank(oppProd.Product2ID__c) && string.isnotblank(oppProd.Product2ID__r.Portfolio__c) && oppProd.Product2ID__r.Portfolio__c == Label.LnS_Portfolio && oppProd.Product2ID__r.Is_Product_Add_On__c == false){
                    //Using same key and value to avoid duplicate opportunity id's to thow error on
                    mapOppIdToThrowError.put(oppProd.OpportunityId__c,oppProd.OpportunityId__c);
                }
            }
        }
        if(!mapOppIdToThrowError.isempty()){
            //Loop though all the entries in the map and throw validation message on the oppropriate opportunites
            for(Id opptyId:mapOppIdToThrowError.keyset()){
                Opportunity opp = mapOppToValidate.get(opptyId);
                opp.addError(Label.Validation_Message_For_Product_Revenue);                
            }
        }
    }
    
    public static void validateCustomerJourney(Map<Id,Opportunity> oppMap){
        map<Id,Id> mapOfOpp = new map<Id,Id>();
        list<Opportunity_Product__c> listOli = [Select id,name,Product_Scope__c,OpportunityId__r.Id from Opportunity_Product__c where OpportunityId__r.Id IN:oppMap.keyset()];
        for(Opportunity_Product__c oli : listOli){
            if( oli.Product_Scope__c == null || !oli.Product_Scope__c.ContainsIgnoreCase('Included In P2Q')){
                mapOfOpp.put(oli.Id,oli.OpportunityId__r.id);
            }
        }

        if(!mapOfOpp.isEmpty()){
            for(Opportunity opp : oppMap.values()){
                opp.addError(Label.Customer_Journey);
            }
        }   
    }
    
    public static void validateOpportunityFiles(Map<Id,Opportunity> mapOfOppty){
        set<Id> oppId = new set <Id>();
        map<Id,Opportunity_File__c> mapOfOppFiles = new map<Id,Opportunity_File__c>();
        if(mapOfOppty != null){
            List<Opportunity_File__c> oppFiles = [Select id, name, Quote__c, Quote__r.name,Opportunity__c from Opportunity_File__c where Opportunity__c IN:mapOfOppty.keyset()];
            if(!oppFiles.isEmpty()){
                for(Opportunity_File__c oppfile : oppFiles){
                    if(oppfile.Quote__c != null){
                        mapOfOppFiles.put(oppfile.Opportunity__c,oppfile);
                    }
                }
            }

            if (mapOfOppFiles != null) {
                for(Opportunity_File__c F : mapOfOppFiles.values()){
                    if(mapOfOppty.containsKey(F.Opportunity__c)){
                        mapOfOppty.get(F.Opportunity__c).addError(Label.Validation_Msg_for_Customer_Journey);
                    }      
                }
            }   
        }
    }
    //SFSE-14250 For Cloned Opportunities, Nullify Offer Status Field.
    //SFSE-13391 - For cloned oppties maing record locked as false & Nullifying Reason for Unlocking, Opportunity Unlocked date.
    public static void resetFieldsOnClone(list<Opportunity> optyList){      
        for(Opportunity opty: optyList){
          opty.Offer_Status__c='';  
            opty.Record_Locked__c = false;
            opty.Reason_for_Unlocking__c = '';
            opty.Opportunity_Unlocked_Date__c = null;
        }
    }
    //SFSE-13681
    public static void validateProductRetirement(List<Opportunity> lstOppRec, Map<Id, Opportunity> mapOldOppty){
        Map<Id, String> MapOpptytoProductRetirementError = new Map<Id, String>();
        MapOpptytoProductRetirementError = validateOpptyProductRetirement(lstOppRec, mapOldOppty);
        if(!MapOpptytoProductRetirementError.isEmpty()){
            for(opportunity opp : lstOppRec){
                if(MapOpptytoProductRetirementError.containsKey(opp.id) && MapOpptytoProductRetirementError.get(opp.id) != null){
                    opp.addError(MapOpptytoProductRetirementError.get(opp.id));
                }
            }
        }
    }

    //SFSE-13681 (common method)
    public static Map<Id,String> validateOpptyProductRetirement(List<Opportunity> lstOppRec, Map<Id, Opportunity> mapOldOppty) {
    Set<Id> opportunityIds = new Set<Id>();
    Set<String> errorProductsEndOfSales = new Set<String>();
    Set<String> errorProductsInactive = new Set<String>();
    Map<Id, List<Opportunity_Product__c>> mapOfOpptyIdAndOpptyProducts = new Map<Id, List<Opportunity_Product__c>>();
    Opportunity oldOppty; 
    Map<Id, String> MapOpptytoProdRetirementError = new Map<Id, String>();

    for (Opportunity opportunity : lstOppRec) {
            opportunityIds.add(opportunity.Id);
    }

    for (Opportunity_Product__c opptyProd : [SELECT Id, Product2ID__r.Name, Product2ID__r.IsActive, Product2ID__r.Product_Status__c, Product2ID__r.End_of_Service__c, OpportunityId__c,
                                             Product2ID__r.Latest_Product_Version__r.IsActive, Product2ID__r.Latest_Product_Version__r.Product_Status__c, Product2ID__r.Latest_Product_Version__r.End_of_Service__c FROM Opportunity_Product__c 
                WHERE OpportunityId__c IN: opportunityIds
            ]) {
        if (mapOfOpptyIdAndOpptyProducts.containsKey(opptyProd.OpportunityId__c)) {
            mapOfOpptyIdAndOpptyProducts.get(opptyProd.OpportunityId__c).add(opptyProd);
        } else {
                mapOfOpptyIdAndOpptyProducts.put(opptyProd.OpportunityId__c, new List < Opportunity_Product__c > {
                    opptyProd
                });
        }
    }
        List<Opportunity_Product__c> lstOppProd = new List<Opportunity_Product__c> ();
        
        for (Opportunity opportunity : lstOppRec) {
            
            if(!mapOfOpptyIdAndOpptyProducts.isEmpty()){
                lstOppProd = mapOfOpptyIdAndOpptyProducts.get(opportunity.Id);
            }
       
            if(lstOppProd.size()>0){
                    for (Opportunity_Product__c opptyProd : lstOppProd) {           
                    String productName = '"' + opptyProd.Product2ID__r.Name + '"';
                    if(mapOldOppty != null){
                        oldOppty = (Opportunity) mapOldOppty.get(opportunity.Id);
                            if (((opportunity.Last_Shipment_Date__c != oldOppty.Last_Shipment_Date__c) || (opportunity.Approval_Required__c=='Yes' && (opportunity.StageName == System.Label.Negotiating || opportunity.StageName == System.Label.close_won))) && 
                            (opptyProd.Product2ID__r.IsActive == false && (opptyProd.Product2ID__r.Product_Status__c == 'End of Sales' || opptyProd.Product2ID__r.Latest_Product_Version__r.Product_Status__c == 'End of Sales') && ((opptyProd.Product2ID__r.End_of_Service__c < opportunity.Last_Shipment_Date__c) ||
                             (opptyProd.Product2ID__r.Latest_Product_Version__r.End_of_Service__c < opportunity.Last_Shipment_Date__c)))) {

                            errorProductsEndOfSales.add(productName);
                        } 
                    } 

                    if(opportunity.Approval_Required__c == 'No'){
                            if (opptyProd.Product2ID__r.IsActive == false && 
                                   (opptyProd.Product2ID__r.Product_Status__c == 'End of Sales' || opptyProd.Product2ID__r.Latest_Product_Version__r.Product_Status__c == 'End of Sales') && 
                                   (oldOppty.StageName == System.Label.Identifying || 
                                    oldOppty.StageName == System.Label.Qualifying || 
                                    oldOppty.StageName == System.Label.Designing_Proposal) && 
                                   opportunity.StageName != System.Label.Closed_lost) {
                            errorProductsInactive.add(productName);
                        } else if (opptyProd.Product2ID__r.IsActive == false && 
                                   (opptyProd.Product2ID__r.Product_Status__c == 'End of Sales' || opptyProd.Product2ID__r.Latest_Product_Version__r.Product_Status__c == 'End of Sales') && 
                                   (opptyProd.Product2ID__r.End_of_Service__c < opportunity.Last_Shipment_Date__c || opptyProd.Product2ID__r.Latest_Product_Version__r.End_of_Service__c < opportunity.Last_Shipment_Date__c) && 
                                   (oldOppty.StageName == System.Label.Quoting || 
                                    oldOppty.StageName == System.Label.Negotiating || 
                                    oldOppty.StageName == System.Label.Closed_lost || 
                                    oldOppty.StageName == System.Label.close_won) && 
                                   opportunity.StageName != System.Label.Closed_lost && !(oldOppty.IsClosed==true && opportunity.IsClosed==false)) { 
                            errorProductsEndOfSales.add(productName);
                        }
                    } else if (opportunity.Approval_Required__c == 'Yes') {
                            if (opptyProd.Product2ID__r.IsActive == false && 
                               (opptyProd.Product2ID__r.Product_Status__c == 'End of Sales' || opptyProd.Product2ID__r.Latest_Product_Version__r.Product_Status__c == 'End of Sales') && 
                               (opportunity.StageName == System.Label.Identifying || opportunity.StageName == System.Label.Qualifying)) { 
                            errorProductsInactive.add(productName);
                        } else if (opptyProd.Product2ID__r.IsActive == false && 
                                   (opptyProd.Product2ID__r.Product_Status__c == 'End of Sales' || opptyProd.Product2ID__r.Latest_Product_Version__r.Product_Status__c == 'End of Sales') && 
                                   (opptyProd.Product2ID__r.End_of_Service__c < opportunity.Last_Shipment_Date__c || opptyProd.Product2ID__r.Latest_Product_Version__r.End_of_Service__c < opportunity.Last_Shipment_Date__c) && 
                                   (opportunity.StageName == System.Label.Designing_Proposal || opportunity.StageName == System.Label.Quoting ||
                                   opportunity.StageName == System.Label.Negotiating)) { 
                            errorProductsEndOfSales.add(productName);
                        }
                    } 
                    
                } 
            }
        
            if (!errorProductsInactive.isEmpty()) {
                    String errorMessageInactive = String.join(errorProductsInactive,',');   
                    errorMessageInactive += ' is/are no longer available. Please update to different product(s) if you wish to continue with this Opportunity.';    
                    MapOpptytoProdRetirementError.put(opportunity.Id, errorMessageInactive);
                }else if (!errorProductsEndOfSales.isEmpty()) {
                    String errorMessageEndOfSales = String.join(errorProductsEndOfSales,',');   
                errorMessageEndOfSales += ' is/are no longer available. You can proceed with the same product(s) provided that the Agreement End Date is not greater than the End of Service Date.';   
                    MapOpptytoProdRetirementError.put(opportunity.Id, errorMessageEndOfSales);
            }
            /*else {
                    MapOpptytoProdRetirementError.put(opportunity.Id, null);
                }*/      
        }
        return MapOpptytoProdRetirementError;
    }
    
    //SFSE-13670 & SFSe-14196 Update X_Auto_Renew__c Yes/No acc. to Agreement Duration
    public static void updateXAutoRenewYesorNo(List<Opportunity> lstOppRec, Map<Id,Opportunity> oldMap){
        for(Opportunity opp:lstOppRec){
            if (oldMap != null && oldMap.get(opp.Id).X_Auto_Renew__c != opp.X_Auto_Renew__c && !oldMap.get(opp.Id).ISClosed && opp.ISClosed)  {   
                if(opp.X_Auto_Renew__c == 'Yes'){
                    opp.Auto_Renew__c = true;
                } else if(opp.X_Auto_Renew__c == 'No'){
                    opp.Auto_Renew__c = false;
                }    
            } else{
                Integer daysDiff;
                if(opp.First_Shipment_Date__c!=null && opp.Last_Shipment_Date__c!=null){
                    daysDiff = opp.First_Shipment_Date__c.daysBetween(opp.Last_Shipment_Date__c); 
                     if(daysDiff >= 90){
                        opp.X_Auto_Renew__c = 'Yes';
                        opp.Auto_Renew__c = true;
                    } else if(daysDiff < 90){
                        opp.X_Auto_Renew__c = 'No';
                        opp.Auto_Renew__c = false;
                    }
                }

            }
        }
    }
    
    
    //SFSE-14196 method to show error on auto renew field   
    public static void validationOnAutorenew(List<Opportunity> lstOppRec){
        
        If(lstOppRec.Size()>0){
            For(Opportunity opp:lstOppRec) {
                opp.addError(Label.ErrorOnAutoRenewField);
                
            }
        }
    }
    
    
    public static void updateAutoRenew(List<Opportunity> lstOppRec, Map<Id,Opportunity> oldMap) {
        for (Opportunity opp : lstOppRec) {
            if (opp.X_Auto_Renew__c == null && !opp.IsClosed) {
                opp.X_Auto_Renew__c = oldMap.get(opp.Id).X_Auto_Renew__c;
            }
        }
    }
    /* Move workflow/Process Builder logic to apex*/ 
    
    //SFSE-14619 method to Update closeDate when opp is move to Closed Lost/Won  
    public static void updateCloseDate(List<Opportunity> lstOpp){
        
        for( Opportunity opp : lstOpp){
            opp.CloseDate = system.today();
            opp.Record_Locked__c = true; //SFSE-13391
        }
        
    }
    // SFSE-14619 Update closeDate when opp is created from lead conversion
    public static void updateCloseDateOnLeadConversion(List<Opportunity> lstOpp){
        
        for( Opportunity opp : lstOpp){
            opp.CloseDate = system.today().addDays(30); 
        }
        
    }
    //SFSE-14619 Method to Update First TimeCloseDate field when opp is first time moved to close Lost/Won stage .
    public static void updateFirstTimeClosedate(List<Opportunity> lstOpp){
        
        for(Opportunity opp : lstOpp){
            opp.First_Time_Closed_Date__c = System.now();
            
        }
        
        
    }
    // SFSE-14619  Method to Update sales qualified date when opp move to from identifying stage to any other stage except closed lost/Won
    public static void updateSalesqualified(List<Opportunity> lstOpp){
        for(Opportunity opp : lstOpp){
            opp.Sales_Qualified_Date__c = System.now();
            
        }
        
        
    }
    //SFSE 14619 Update Opp. Name to specific name when Opp name given as X 
    public static void updateOppName(List<Opportunity> lstOpp){
        
        for(Opportunity opp: lstOpp){
            if(opp.Name == 'X')
                opp.Name = opp.Account_Name__c + '-' + opp.Primary_Contact_Name__c;
            
        }
        
    }
    /* END */
    
    //SFSE-13391 opening closed oppty (both locked/unlocked)
    public static void unlockOpportunityOnStageChange(List < Opportunity > lstOpp) {
            for (Opportunity opp: lstOpp) {
             if(lstProfileIDsAllowStageChngClosedUnlockedOppty.contains(StaticFactory.getCurrentUserDetails().ProfileId)){
                opp.Record_Locked__c = false;
                opp.Reason_for_Unlocking__c = 'Administrative Reasons';
                opp.Opportunity_Unlocked_Date__c = System.now();
            }
        }
    }

    //SFSE-13391 when oppty is closed & unlocked no update allowed other than these fields
    public static void validateClosedUnlockedOppty(List < Opportunity > lstOpp, Map < Id, Opportunity > oldMap) {
        Id loggedInUserId = StaticFactory.getCurrentUserDetails().ProfileId;
        Set <String> opportunityFieldsToValidate = new Set <String> ();
        if(!lstProfileIDsAllowUpdateClosedUnlockedOppty.contains(loggedInUserId)){
            for(Opportunity oppty: lstOpp){
        for (Schema.SObjectField field: Schema.SObjectType.Opportunity.fields.getMap().values()) {
            String fieldApiName = field.getDescribe().getName();
                    if(oppty.Reason_for_Unlocking__c == 'Clerical Error / Contract Alignment'){ //SFSE-15486
                        if (fieldApiName != 'CloseDate' && fieldApiName != 'First_Shipment_Date__c' && fieldApiName != 'Last_Shipment_Date__c' && fieldApiName != 'Record_Locked__c' && !field.getDescribe().isCalculated()) {
                opportunityFieldsToValidate.add(fieldApiName);
            	}
            }
                    else if (fieldApiName != 'First_Shipment_Date__c' && fieldApiName != 'Last_Shipment_Date__c' && fieldApiName != 'Record_Locked__c' && !field.getDescribe().isCalculated()) {
                        opportunityFieldsToValidate.add(fieldApiName); 
                    }
            	}
                
            for (String fieldApiName: opportunityFieldsToValidate) {
                if (oldMap.get(oppty.Id).get(fieldApiName) != oppty.get(fieldApiName)) {
                        if(oppty.Reason_for_Unlocking__c == 'Clerical Error / Contract Alignment'){
                            oppty.addError(System.Label.Closed_Unlocked_Oppty_error_ClericalErrorReason);
                        }else{
                    oppty.addError(System.Label.Closed_Unlocked_Oppty_error);
                }
            }
        }
    }

}
    }
    
    //SFSE-13391
    public static void validateUnlockedReOpenedOppty(List<Opportunity> lstOpp){
        Id loggedInUserId = StaticFactory.getCurrentUserDetails().ProfileId;
        if(!lstProfileIDsAllowStageChngClosedUnlockedOppty.contains(loggedInUserId)){
            for(Opportunity oppty: lstOpp){
                oppty.addError(System.Label.Closed_Unlocked_Oppty_error);
            }         
        }
    }

}