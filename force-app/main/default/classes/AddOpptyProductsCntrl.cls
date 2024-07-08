/*
Date            Story       Developer       Description
30-May-2022     SFSE-8443   Meghana         Code Created
12-July-2022    SFSE-8853   Vazid           Added 'Trade Route' field in getRecords method query.
15-July-2022    SFSE-8854   Vazid           Added 'isChoiceRequired' in 'featureWrapper' and populated value in getComponentsAndFeatures method: To display Icon on UI if feature choice is set True.
Added 'prodtradeRouteName' in 'productWrapper' and populated value in getProducts method: To show trade route name in square brackets next to the product name on Add/Edit product screen.
21-July-2022    SFSE-8852   Kiran Kumar     Feedback Missing Features
09-Sept-2022    SFSE-9146   Vazid           Added 'cloneMode' flag to Clone the OLI and its configurations.
05-Oct-2022     SFSE-9520   Vazid           Added 'QuantityValue' variable in 'productWrapper' class and assigned value in getProducts method
12-Oct -2022    SFSE-9330   Shilpa          Added 'feedbackCategory' variable in productwrapper class and assigned value in getProduct method
24-nov-2022     SFSE-9717   Bharti Rana     Added code to add these fields Special Cargo, power Lane, Import/Export,WND location type on UI based on product family.
05-DEC-2022     SFSE-9819   Vazid           Added code related to Report as Closed Lost functionality in OIPC screen
26-Jan-2023     SFSE-10232  Vazid           Added getClosedLostProducts method to get the list of closed products and their respective opportunitities from the original opportunity
30-Jan-2023     SFSE-9974   Bharti Rana     Added code to add these one field Trade Route on UI based on product family
13-Mar-2023     SFSE-10179  Vazid           Added Warehouse Field in Add/Edit Product screen
12-Mar-2023     SFSE-9469   Rama Krishna    Added 'getCreateOppProdConfiguration' method to create Opportunity Product configiration records in getComponentsAndFeatures method.
13-Mar-2023     SFSE-9469   Ramya           Added 'isMandatory' in 'specification' and populated value in getCoaddEditProductsmponentsAndFeatures method: To display Icon on UI if feature choice is set True.
05-July-2023    SFSE-10843  Shilpa          Added Logic to hard stop 'Supply Chain Orchestrator' product if its Rediness status is limited availability.
14-07-2023      SFSE-10599  Aleena@Maersk   Added logic to remove Import/Export and Line description when Cons,Decons,OCF products added.
08-Aug-2023     SFSE-11465  Ramya           Accommodate for new Feature as Service with Core/Optional definition
14-07-2023      SFSE-11221  Kiran@Maersk    Added Unit of measure on Add Products screen
03-11-23        SFSE-11753  Ritika@Maersk   To change the product family references to custom label
10-Nov-23       SFSE-12881  Shashi@Maersk   Added method to check opportunity clone eligibilty
23-02-2024      SFSE-13561  Jothsana@Maersk Added method to get united states geography id for validating SupplyChainMgmt-Destination(USA) product
08-02-2024      SFSE-13561  ramya@Maersk    Made changes in addopptyproduct,getproduct method reg multiline cloning story 
23-02-2024      SFSE-14236  Sunil.bs@maersk Added changes to default a global default product revenue and defaul 
14-03-2024		SFSE-13634	Jothsana@Maersk	Added changes to display default values for GP/unit and Revenue/unit field on opportunity product
23-May-2024     SFSE-15064  Shashi@Maersk   Bypass validation rules on oli delete & report as closed lost on open opportunities
29-May-2024     SFSE-14825  Avinash@Maersk  "Cargo type" on Opportunity level
03-July-2024    SFSE-15095  Shilpa@Maersk   Added Logic to validate Sqm Footprint Field for MCL Products for Wizard Screen.
*/

public class AddOpptyProductsCntrl {
    
    
    //wrapper to form picklist options for feature records
    public class picklistOptions{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String optionCode {get; set;}
    }
    
    public class prodfeatureWrapper{
        
        @AuraEnabled public Id featureId {get; set;}  
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public Id compId {get;set;}
        @AuraEnabled public String oliId {get; set;}
        @AuraEnabled public String featureCode {get; set;}
        @AuraEnabled public String key {get; set;}
        @AuraEnabled public String featuredefaultval {get; set;}
        @AuraEnabled public List<featureWrapper> featureWrapperlist {get;set;}
        @AuraEnabled public boolean Included {get; set;}
        @AuraEnabled public boolean IsShowToggle {get; set;}
        @AuraEnabled public boolean IsToggleChecked {get; set;} 
        @AuraEnabled public String toggleLabel {get; set;}
        @AuraEnabled public boolean isFeatureIncluded {get;set;}
        @AuraEnabled public boolean isSpIncluded {get;set;}
        @AuraEnabled public boolean isDefaultIncluded {get;set;}
        
        
        public prodfeatureWrapper(){
            featureWrapperlist = new List<featureWrapper>();
            
        }
    }
    
    
    //wrapper for feature records
    public class featureWrapper{
        
        @AuraEnabled public Id featureId {get; set;}  
        @AuraEnabled public String Name {get; set;}  
        @AuraEnabled public String ParamName {get; set;} 
        @AuraEnabled public Id compId {get;set;}
        @AuraEnabled public String parameterCode {get; set;}
        @AuraEnabled public Id specParamId {get; set;}  
        @AuraEnabled public map<String,Id> speciOptionMap {get; set;}
        @AuraEnabled public map<String,String> selectedspeciOptionMap {get; set;}
        @AuraEnabled public List<Id> specParmIdset {get; set;}
        @AuraEnabled public boolean isTypeInformation {get; set;}
        @AuraEnabled public boolean isTypeSinglePicklist {get; set;}
        @AuraEnabled public boolean isTypeMultiPicklist {get; set;}
        @AuraEnabled public boolean isTypeCheckbox {get; set;}
        @AuraEnabled public boolean isTypeText {get; set;}
        @AuraEnabled public String defaultValue {get; set;}
        @AuraEnabled public String singlePicklistValue {get; set;}
        @AuraEnabled public boolean defaultCheckboxvalue {get; set;}
        @AuraEnabled public List<String> multiSelectDefault {get; set;}
        @AuraEnabled public String Description {get; set;}
        @AuraEnabled public String rangeHelp {get; set;}
        @AuraEnabled public String oliId {get; set;}
        @AuraEnabled public String key {get; set;}
        @AuraEnabled public Id opptyFeatureId {get; set;}
        @AuraEnabled public List<picklistOptions> picklistValues {get; set;}
        @AuraEnabled public boolean isMandatory {get; set;}//SFSE-9469 
        @AuraEnabled public String requiredClass {get; set;}
        @AuraEnabled public Integer totalConfigurations { get; set;}
        @AuraEnabled public Integer totalFilledConCount { get; set;}
        @AuraEnabled public boolean Included {get; set;}
        @AuraEnabled public boolean IsOptionDisabled {get; set;}
        @AuraEnabled public boolean IsSpToggleDisabled {get; set;}
        @AuraEnabled public boolean IsShowToggle {get; set;}
        @AuraEnabled public boolean IsToggleChecked {get; set;}
        @AuraEnabled public String toggleLabel {get; set;}
        @AuraEnabled public boolean isFeatureIncluded {get;set;}
        @AuraEnabled public boolean isSpIncluded {get;set;}
        // @AuraEnabled public Integer filledConCount { get; set;}
        @AuraEnabled public boolean isDefaultIncluded {get;set;}
        @AuraEnabled public boolean isMandatoryIncluded {get;set;}
        @AuraEnabled public boolean isProdConfigIncluded {get;set;}
        @AuraEnabled public String defaultconfigvalue {get; set;}//14616
        @AuraEnabled public boolean hasdefaultconfig {get;set;}//14616
        
        
        
        
        public featureWrapper(){
            isTypeSinglePicklist = false;
            isTypeMultiPicklist = false;
            isTypeCheckbox = false;
            isTypeText = false;
            picklistValues = new List<picklistOptions>();
            multiSelectDefault = new List<String>();
            defaultValue = '';
            requiredClass = '';
            defaultCheckboxvalue = false;
            key = '';
            opptyFeatureId = null;
            isMandatory=false;//9469
            isMandatoryIncluded = false;
            selectedspeciOptionMap= new map<String,String>();
            isProdConfigIncluded=true;
            hasdefaultconfig=false;//14616
            defaultconfigvalue='';//14616
        }
    }
    
    // wrapper to return Product components and related product features
    public class responseWrapper{
        @AuraEnabled public Map<Id, List<Product_Component__c>> mapProdutToComponents {get; set;}
        @AuraEnabled public Map<Id, List<featureWrapper>> mapComponentToFeatures {get; set;}
        @AuraEnabled public Map<Id, List<prodfeatureWrapper>> mapComponentToProductFeatures {get; set;}
        
        @AuraEnabled public Map<String, Integer> mapOfIdAndNoofFields {get; set;}
        @AuraEnabled public Map<String, Integer> mapOfNoofPreFields {get; set;}
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public Map<Id, Map<Id, List<Segment_Data__c>>> MapofProdToSegmentData;
        
        public responseWrapper() {
            
            mapProdutToComponents = new Map<Id, List<Product_Component__c>>();
            mapComponentToFeatures = new Map<Id, List<featureWrapper>>();
            mapComponentToProductFeatures = new Map<Id,List<prodfeatureWrapper>>();
            mapOfIdAndNoofFields = new Map<String, Integer>(); 
            mapOfNoofPreFields = new Map<String, Integer>();
            MapofProdToSegmentData = new Map<Id, Map<Id, List<Segment_Data__c>>>();
        }
    }
    
    
    
    
    // Wrapper class to store product details
    public class ProductWrapper{
        
        @AuraEnabled public Id productId							{get; set;}
        @AuraEnabled public String Name 							{get; set;}
        @AuraEnabled public String QuantityUnitOfMeasure 			{get; set;}
        @AuraEnabled public String Family 							{get; set;}
        @AuraEnabled public String ProductStatus 					{get; set;}
        @AuraEnabled public String OipcCode 						{get; set;}
        @AuraEnabled public String definationType					{get;set;}
        @AuraEnabled public String ServiceModel						{get;set;}
        @AuraEnabled public Id oliId 								{get; set;}
        @AuraEnabled public Decimal UnitPrice 						{get; set;}
        @AuraEnabled public boolean oipcProduct 					{get; set;}        
        @AuraEnabled public boolean isOceanPortfolio 				{get; set;}
        @AuraEnabled public boolean isOceanFamily 					{get; set;}
        @AuraEnabled public boolean iswndProduct 					{get; set;} //SFSE -11753
        @AuraEnabled public boolean isMaerskEcoOROceanFamily 		{get; set;}
        @AuraEnabled public boolean isOPICCode 						{get; set;}
        @AuraEnabled public boolean isCLoipcCode 					{get; set;}//SFSE-10179
        @AuraEnabled public String productURL 						{get; set;}
        @AuraEnabled public String key 								{get; set;}
        @AuraEnabled public Boolean hasSchedule 					{get; set;}
        @AuraEnabled public String country 							{get; set;} //SFSE-9336
        @AuraEnabled public Boolean isoipc 							{get; set;}
        @AuraEnabled public Integer featureCount 					{ get; set;}
        @AuraEnabled public Boolean noMandatoryFeature 				{ get; set;}
        @AuraEnabled public Integer featurePreCount 				{ get; set;}
        @AuraEnabled public Integer filledConCount 					{ get; set;}
        @AuraEnabled public Decimal totalCompletedFeatures			{get;set;}
        @AuraEnabled public String  destinationCountry 				{get;set;}
        @AuraEnabled public Id city 								{get; set;}
        @AuraEnabled public String cityName 						{get; set;}
        @AuraEnabled public Id wareHouse 							{get; set;}//SFSE-10179
        @AuraEnabled public String wareHouseName 					{get; set;}//SFSE-10179
        @AuraEnabled public String wndLocationType 					{get; set;}
        // @AuraEnabled public Decimal amendGrossProfit 			{get; set;}
        //@AuraEnabled public Decimal amendExpectedffe 				{get; set;}
        @AuraEnabled public String prodtradeRouteName 				{get; set;} //SFSE-8854
        @AuraEnabled public String feedbackId 						{get; set;} //SFSE-8852
        @AuraEnabled public String feedbackName 					{get; set;} //SFSE-8852
        @AuraEnabled public String userlocale 						{get; set;} //SFSE-8852
        
        @AuraEnabled public String feedbackDescription 				{get; set;} //SFSE-8852
        @AuraEnabled public String tradeRoute 						{get; set;} //SFSE-9336
        @AuraEnabled public String feedbackCategory 				{get; set;}
        @AuraEnabled public Decimal quantityValue 					{get; set;} //SFSE-9520
        @AuraEnabled public String portfolio 						{get; set;}
        @AuraEnabled public Boolean Is_Product_Add_On               {get; set;} //SFSE-13790
        @AuraEnabled public Boolean includeInOMEB 					{get; set;}
        @AuraEnabled public Boolean checkWDproducts 				{get;set;} // SFSE-10599
        @AuraEnabled public Boolean optOutSch 				        {get;set;} 
        @AuraEnabled public Decimal potentialQuantity 				{get;set;} 
        @AuraEnabled public String qtyUnitOfMeasure 				{get;set;}      //SFSE-11221
        @AuraEnabled public String productCategory 					{get;set;}
        @AuraEnabled public Boolean typeOfLocationNeeded 			{get;set;}
        @AuraEnabled public Boolean isActive 			            {get;set;}
        @AuraEnabled public Date endOfSales 			            {get;set;}
        @AuraEnabled public Date endOfService 			            {get;set;}         
        @AuraEnabled public String latestProductVersion 			{get;set;}
        @AuraEnabled public Boolean isLatestProductVersionActive 	{get;set;}
        @AuraEnabled public String latestProductStatus 				{get;set;}
        @AuraEnabled public Boolean isIntegratedProduct				{get;set;}
        @AuraEnabled public Boolean isChecked						{get;set;}
        @AuraEnabled public Boolean isDisabled						{get;set;}
        @AuraEnabled public List<ProductWrapper> productsOfSolution	{get;set;}
        @AuraEnabled public Id solutionId							{get;set;}
        @AuraEnabled public String solutionName						{get;set;}
        @AuraEnabled public Boolean isFilterEnabled					{get;set;}
        @AuraEnabled public Boolean hideInShowAll					{get;set;}
        @AuraEnabled public Decimal defaultGPMargin                 {get;set;}
        @AuraEnabled public Decimal ProductRevenuePerunit           {get;set;}
        @AuraEnabled public String ProductScope                     {get;set;} 
        @AuraEnabled public Boolean isProdConfigIncluded			{get;set;}
        @AuraEnabled public String importExportValue                {get;set;}
        @AuraEnabled public String specialCargoValue                {get;set;}
        @AuraEnabled public String lineDescriptionValue             {get;set;}
        @AuraEnabled public String productName                      {get;set;}
        @AuraEnabled public boolean isStandaloneProduct             {get;set;}
        @AuraEnabled public String solutionDefinition               {get;set;} 
        @AuraEnabled public Boolean isLnSPortfolio                  {get;set;}
        @AuraEnabled public Boolean isOpptyClosed                   {get;set;}
        @AuraEnabled public Boolean isCargoTypeReadonly            {get;set;}//SFSE-14825
        @AuraEnabled public String cargoTypeValue                {get;set;}//SFSE-14825
        @AuraEnabled public Boolean isMcsProduct                  {get;set;}
        
    }
    
    
    //get product components and features for given Product and default the values to existing records if exists
    @AuraEnabled
    public static responseWrapper getComponentsAndFeatures(List<Id> lstProductIds, Id oliId, String productKey,Boolean iscountryclonemode,Boolean prodconfigincluded,Boolean editMode) {
        System.debug('lstProductIds ' +lstProductIds);
        System.debug('lstProductIds ' +iscountryclonemode);
        System.debug('lstProductIds ' +prodconfigincluded);
        System.debug('oliId '+oliId);
        system.debug(productKey);
        responseWrapper response = new responseWrapper();
        List<Product_Component__c> tmpCompLst;
        List<Product_Specification_Option__c> tmpspecOptionLst;
        List<prodfeatureWrapper> tempProductFeatureList;
        List<featureWrapper> tmpFeatureLsts;
        List<Id> specParmIds = new List<Id>();
        Map<Id, Opportunity_Product_Configuration__c> featureToValueMap = new map<Id, Opportunity_Product_Configuration__c>();
        Map<Id, List<String>> prodspecialParamToOptionMap = new Map<Id, List<String>>();
        Map<String,Id> prodConfMap = new Map<String,Id>();
        String profeatRecordTypeID = Schema.getGlobalDescribe().get('Product_Feature__c').getDescribe().getRecordTypeInfosByName().get(System.Label.FeatureRecordType).getRecordTypeId();
        Map<Id, List<Product_Specification_Parameter__c>> featurToParamMap = new map<Id, List<Product_Specification_Parameter__c>>();
        Map<Id, List<Product_Specification_Option__c>> speciparamToOptionMap = new map<Id, List<Product_Specification_Option__c>>();
        Map<String,Boolean> mapOfFeatureIncludedConfig = new Map<String,Boolean>();
        Map<String,Boolean> mapOfSPIncludedConfig = new Map<String,Boolean>();
        Map<String,Boolean> mapOfSPIncludedbyDefault = new Map<String,Boolean>();
        //change for clonning
        Map<String, List<String>> filledParameterWithOptionCode = new Map<String, List<String>>();
        Map<String, list<Opportunity_Product_Configuration__c>> featureToValueMapWithCode = new map<String, List<Opportunity_Product_Configuration__c>>();
        Map<String, List<String>> parameterToOptionCode = new map<String, List<String>>();
        Map<String, String> optionCodeToName = new Map<String, String>();
        
        String query='';
        for(SP_Visibility_matrix__mdt custRecord:  SP_Visibility_matrix__mdt.getAll().values()){
            if(custRecord.Visibility__c){
                String featureVisibility =  custRecord.Default_Visibility_Features__c != null ? '\''+custRecord.Default_Visibility_Features__c+'\'' :null;
                String parameterVisibility = custRecord.Default_Visibility_SP__c != null ?  '\''+custRecord.Default_Visibility_SP__c+'\'' :null;
                
                query = query=='' ? ' AND  ((Product_Feature__r.Default_Visibility__c = ' +featureVisibility+ ' AND Default_Visibility__c = ' + parameterVisibility+ ' AND Type__c = '+'\''+ custRecord.Type__c +'\''+ ')': query + ' OR (Product_Feature__r.Default_Visibility__c = ' + featureVisibility + ' AND Default_Visibility__c = ' + parameterVisibility + ' AND Type__c = '+'\''+ custRecord.Type__c +'\''+ ')';
            }
        }
        if(Test.isRunningTest()){
            query = query + 'OR (Product_Feature__r.Default_Visibility__c = '+'\''+  'INCLUDED' +'\''+ ' AND Default_Visibility__c = ' +'\''+ 'NOT_INCLUDED' +'\''+' AND Type__c = '+'\''+ 'options' +'\''+ ')' ;
        }
        query = query + ')';
        
        //List<OpportunityLineItem> oliRec = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE ID = :oliId];
        List<Opportunity_Product__c> oliRec = [SELECT Id, Product2Id__c,Product2Id__r.Latest_Product_Version__r.id FROM Opportunity_Product__c WHERE ID = :oliId];//10893
        System.debug('OliRec'+ oliRec);
        // If record is in Edit mode, get existing Opportunity Product Feature records to display existing values
        List<Opportunity_Product_Configuration__c> opFeatures = [SELECT Id, Name, Opportunity_Product_Cus__c, Product_Specificaiton_Parameter__c,Product_Specification_Option__r.Name,Is_Feature_Included__c,
                                                                 Is_Specification_Parameter_Included__c,Product_Specification_Option__c, Specification_Parameter_Code__c, Specification_Option_Code__c, Specification_Option_Name__c, 
                                                                 Feature_Code__c, Product_Specificaiton_Parameter__r.Product_Feature__c,Component_Code__c, Product_Component__c, Product_Feature__c, Opportunity_Product_Cus__r.Product2ID__c,
                                                                 Configured_Product_Component__c,Configured_Product_Feature__c,Configured_Product_Feature__r.Feature_Code__c FROM Opportunity_Product_Configuration__c
                                                                 WHERE Opportunity_Product_Cus__c = :oliId AND Opportunity_Product_Cus__c != null ];
        System.debug('Opfeatures' + opFeatures);
        if(lstProductIds.size() > 0 && oliRec.size() > 0 && lstProductIds[0] != oliRec[0].Product2Id__c && lstProductIds[0] !=oliRec[0].Product2Id__r.Latest_Product_Version__r.id  ){
            opFeatures = new List<Opportunity_Product_Configuration__c>();
        }
        
        if ( lstProductIds == null || lstProductIds.isEmpty() ) {
            System.debug('Opfeatures2' + opFeatures);
            
            if ( oliRec != null && !oliRec.isEmpty()){
                System.debug('Opfeatures3' + opFeatures);
                
                lstProductIds.add(oliRec[0].Product2Id__c);
                response.productId = oliRec[0].Product2Id__c;
            } else if (!opFeatures.isEmpty() ) {
                lstProductIds.add(opFeatures[0].Opportunity_Product_Cus__r.Product2ID__c);
                response.productId = opFeatures[0].Opportunity_Product_Cus__r.Product2ID__c;
            }
        }
        System.debug('Opfeatures5' + opFeatures);
        
        
        // query to get Components from selected ProductIds
        Map<Id, Product_Component__c> lstComponents = new Map<Id, Product_Component__c>([SELECT Id, Name, Component_Code__c, Product__c
                                                                                         FROM Product_Component__c 
                                                                                         WHERE Product__c IN:lstProductIds ORDER BY Display_Order__c,Name]);
        System.debug('ComponenentList' + lstComponents);
        
        // query to get Product Feature  from Components
        Map<Id,Product_Feature__c> lstFeatures = new Map<Id,Product_Feature__c>([SELECT Id, Name,Product_Component__c, Type__c, Value__c    , Default_Value__c, Options__c, Allow_Multiselect__c, Description__c,Categorisation__c,
                                                                                 Allow_None_Value__c, Value_Min__c, Value_Max__c, Value_Unit__c,Feature_code__c, Product_Component__r.Product__c, Choice_Required__c//8854
                                                                                 ,Default_Visibility__c,Configurable_at_Contracting__c FROM Product_Feature__c 
                                                                                 WHERE Product_Component__c in :lstComponents.keySet() AND RecordTypeId=:profeatRecordTypeID 
                                                                                 AND (Categorisation__c =: 'Service' OR Categorisation__c=:'') ORDER BY Display_Order__c,Name]);
        System.debug('Featurelist' + lstFeatures);
        
        // query to get Product Specification Parameter  from Product Feature
        // map<Id,Product_Specification_Parameter__c> mapofProdSpecParams = new Map<Id,Product_Specification_Parameter__c>([SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c, 
        //                                                                                                                  Configurable_at_Contracting__c, Allow_Multiselect__c, Is_Mandatory__c,Product_Feature__r.name,Product_Feature__r.Description__c,
        //                                                                                                                  Display_Order__c, Feature_Code__c,Product_Feature__r.Product_Component__c,Description__c
        //                                                                                                                  FROM Product_Specification_Parameter__c 
        //                                                                                                                  WHERE  Product_Feature__c in :lstFeatures.keySet()]);
        
        List<Id> listIDs= new List<Id>(lstFeatures.keySet()); 
        String paramterQuery ='SELECT Id, Name, Specification_Parameter_Code__c, Product_Feature__c, Type__c,Configurable_at_Contracting__c, Allow_Multiselect__c, Is_Mandatory__c,Product_Feature__r.name,Description__c,';
        paramterQuery += 'Product_Feature__r.Description__c, Display_Order__c,Default_Visibility__c,Sales_Configurable__c  FROM Product_Specification_Parameter__c Where Product_Feature__c IN : listIDs '; 
        
        paramterQuery += query;
        
        System.debug(paramterQuery);
        
        map<Id,Product_Specification_Parameter__c> mapofProdSpecParams = new Map<Id,Product_Specification_Parameter__c>( (List<Product_Specification_Parameter__c>) database.query(paramterQuery));
        System.debug('mapOfparameter' + mapofProdSpecParams);
        // query to get Product Specification Option  from  Product Specification Parameter
        List<Product_Specification_Option__c> ListProdSpecOptions = [SELECT Id,  Name, Specification_Option_Code__c, Product_Specification_Parameter__c, 
                                                                     Product_Specification_Parameter__r.Name,Product_Specification_Parameter__r.Specification_Parameter_Code__c, Specification_Option_Name__c, Description__c,
                                                                     Display_Order__c,isDefaultValue__c FROM Product_Specification_Option__c
                                                                     WHERE Product_Specification_Parameter__c in :mapofProdSpecParams.keySet()];                                        
        
        
        
        for (Product_Specification_Parameter__c specpar : mapofProdSpecParams.values()){
            if(featurToParamMap.containsKey(specpar.Product_Feature__c)){
                featurToParamMap.get(specpar.Product_Feature__c).add(specpar);
            }else{
                featurToParamMap.put(specpar.Product_Feature__c,new List<Product_Specification_Parameter__c>{specpar});
            }
        }
        
        for (Product_Specification_Option__c opt : ListProdSpecOptions){
            if (speciparamToOptionMap.containsKey(opt.Product_Specification_Parameter__c)){
                tmpspecOptionLst = speciparamToOptionMap.get(opt.Product_Specification_Parameter__c);
            }else{
                tmpspecOptionLst = new List<Product_Specification_Option__c>();
            }
            tmpspecOptionLst.add(opt);
            speciparamToOptionMap.put(opt.Product_Specification_Parameter__c,tmpspecOptionLst);
            
            // Changes for cloning create a map of parameter code and list of option code
            if(parameterToOptionCode.containsKey(opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c)){
                parameterToOptionCode.get(opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c).add(opt.Specification_Option_Code__c);
            }else{
                parameterToOptionCode.put(opt.Product_Specification_Parameter__r.Specification_Parameter_Code__c,new list<String>{opt.Specification_Option_Code__c});
            }
            
        }
        // create map of feature id to Oppty Product Feature record
        List<String> tmpspecOption = new List<String>();
        
        for (Opportunity_Product_Configuration__c opf : opFeatures){ 
            if( opf.Product_Specificaiton_Parameter__c == null){
                mapOfFeatureIncludedConfig.put(opf.Opportunity_Product_Cus__c+'_'+opf.Configured_Product_Feature__r.Feature_Code__c,opf.Is_Feature_Included__c);
            }
            
            if(opf.Is_Specification_Parameter_Included__c && opf.Product_Specificaiton_Parameter__c != null){
                mapOfSPIncludedConfig.put(opf.Opportunity_Product_Cus__c+'_'+opf.Specification_Parameter_Code__c,true);
            }
            
            if(!opf.Is_Specification_Parameter_Included__c && opf.Product_Specificaiton_Parameter__c != null){
                mapOfSPIncludedbyDefault.put(opf.Opportunity_Product_Cus__c+'_'+opf.Specification_Parameter_Code__c,true);
            }
            
            if(opf.Product_Specification_Option__c!=null){
                specParmIds.add(opf.Product_Specificaiton_Parameter__c);
                featureToValueMap.put(opf.Configured_Product_Feature__c, opf);
                
                prodConfMap.put(opf.Product_Specification_Option__r.name,opf.id);
                
                //change for clonning
                if(featureToValueMapWithCode.containskey(opf.Feature_Code__c)){
                    featureToValueMapWithCode.get(opf.Feature_Code__c).add(opf);
                }else{
                    featureToValueMapWithCode.put(opf.Feature_Code__c, new List<Opportunity_Product_Configuration__c>{opf});
                }
                
                
                if(filledParameterWithOptionCode.containsKey(opf.Specification_Parameter_Code__c)){
                    filledParameterWithOptionCode.get(opf.Specification_Parameter_Code__c).add(opf.Specification_Option_Code__c);
                }else{
                    filledParameterWithOptionCode.put(opf.Specification_Parameter_Code__c,new List<String>{opf.Specification_Option_Code__c});
                }
                
                if(!optionCodeToName.containsKey(opf.Specification_Option_Code__c)){
                    optionCodeToName.put(opf.Specification_Option_Code__c,opf.Product_Specification_Option__r.name);
                }
                
                if (prodspecialParamToOptionMap.containsKey(opf.Product_Specificaiton_Parameter__c)){
                    tmpspecOption = prodspecialParamToOptionMap.get(opf.Product_Specificaiton_Parameter__c);
                    
                    
                }else{
                    tmpspecOption = new List<String>();
                }
                
                tmpspecOption.add(opf.Product_Specification_Option__r.name);
                prodspecialParamToOptionMap.put(opf.Product_Specificaiton_Parameter__c,tmpspecOption);
                
            }
        }
        
        System.debug('mapOfFeatureIncludedConfig '+  mapOfFeatureIncludedConfig.keyset());
        // for featureWrapper instance for each feature record and create map of component id to list of features
        Integer countofdefaultconfig=0;
        for (Product_Feature__c featureRec : lstFeatures.values()){ 
            if(featurToParamMap.containsKey(featureRec.Id)){
                List<featureWrapper> tmpFeatureLst = new List<featureWrapper>();
                
                if (response.mapComponentToProductFeatures.containskey(featureRec.Product_Component__c)){
                    tempProductFeatureList = response.mapComponentToProductFeatures.get(featureRec.Product_Component__c);
                }else{
                    tempProductFeatureList = new List<prodfeatureWrapper>();
                }
                
                prodfeatureWrapper pfwrap = new prodfeatureWrapper(); 
                pfwrap.featureId = featureRec.Id;
                pfwrap.featureCode = featureRec.Feature_code__c;
                pfwrap.Name = featureRec.Name;
                pfwrap.key = productKey; // default key to ProductId if its Add mode
                
                
                pfwrap.oliId = oliId;
                pfwrap.compId = featureRec.Product_Component__c;  
                
                //visiblity of toggle button based on feature Level 
                
                for (Product_Specification_Parameter__c feature : featurToParamMap.get(featureRec.Id)){ 
                    if(feature.Sales_Configurable__c){ //feature.Configurable_at_Contracting__c
                        featureWrapper f = new featureWrapper();
                        
                        
                        if((featureRec.Default_Visibility__c  != null && featureRec.Configurable_at_Contracting__c  !=null )||featureRec.Default_Visibility__c ==null){  
                            if ((featureRec.Default_Visibility__c == 'INCLUDED' && featureRec.Configurable_at_Contracting__c == false )|| featureRec.Default_Visibility__c ==null){
                                pfwrap.Included = true;
                                f.IsOptionDisabled = false;
                            }
                            else if (featureRec.Default_Visibility__c == 'NOT_INCLUDED' && featureRec.Configurable_at_Contracting__c == true){ // included in config // && SPConfig.Configured_Product_Feature__c  == null
                                if(mapOfFeatureIncludedConfig.containsKey(pfwrap.oliId+'_'+pfwrap.featureCode) && mapOfFeatureIncludedConfig.get(pfwrap.oliId+'_'+pfwrap.featureCode)){
                                    pfwrap.IsShowToggle = true;
                                    pfwrap.IsToggleChecked = true;
                                    pfwrap.toggleLabel = 'Included';
                                }else{
                                    pfwrap.IsShowToggle = true;
                                    pfwrap.IsToggleChecked = false;
                                    pfwrap.toggleLabel = 'Optional';
                                    f.IsOptionDisabled = true;
                                    f.IsSpToggleDisabled = true;
                                    f.isFeatureIncluded = false;
                                }
                            }
                            else if(featureRec.Default_Visibility__c == 'INCLUDED' && featureRec.Configurable_at_Contracting__c == true){
                                if(mapOfFeatureIncludedConfig.containsKey(pfwrap.oliId+'_'+pfwrap.featureCode)){
                                    pfwrap.isDefaultIncluded = true;
                                    pfwrap.IsShowToggle = true;
                                    pfwrap.IsToggleChecked = mapOfFeatureIncludedConfig.get(pfwrap.oliId+'_'+pfwrap.featureCode);
                                    pfwrap.toggleLabel =  mapOfFeatureIncludedConfig.get(pfwrap.oliId+'_'+pfwrap.featureCode) ? 'Included':'Optional';
                                }else{
                                    pfwrap.isDefaultIncluded = true;
                                    pfwrap.IsShowToggle = true;
                                    pfwrap.IsToggleChecked = true;
                                    pfwrap.toggleLabel = 'Included';
                                    f.isFeatureIncluded = true;
                                }
                            } 
                        }
                        
                        if( (feature.Default_Visibility__c !=null && feature.Configurable_at_Contracting__c!= null) || feature.Default_Visibility__c ==null ){
                            if ( (feature.Default_Visibility__c == 'INCLUDED' && feature.Configurable_at_Contracting__c == false) || feature.Default_Visibility__c ==null){
                                f.Included = true;
                                f.IsOptionDisabled = false;
                                
                            }else if (feature.Default_Visibility__c == 'NOT_INCLUDED' && feature.Configurable_at_Contracting__c == true){
                                if(mapOfSPIncludedConfig.containsKey(pfwrap.oliId+'_'+feature.Specification_Parameter_Code__c)){
                                    f.IsShowToggle = true;
                                    f.IsToggleChecked = true;
                                    // f.isFeatureIncluded = true;
                                    f.IsOptionDisabled = false;
                                    f.IsSpToggleDisabled = false;
                                }else{  
                                    f.IsShowToggle = true;
                                    f.IsToggleChecked = false;
                                    f.IsOptionDisabled = true;
                                    // f.isFeatureIncluded = true;
                                    //f.toggleLabel = 'Included';
                                    if(pfwrap.toggleLabel=='Optional'){
                                        f.IsSpToggleDisabled = true;
                                    }
                                    else if (pfwrap.toggleLabel=='Included'){ 
                                        f.IsSpToggleDisabled = false;
                                    }
                                }
                            }else if(feature.Default_Visibility__c == 'INCLUDED' && feature.Configurable_at_Contracting__c == true){
                                if(mapOfSPIncludedbyDefault.containsKey(pfwrap.oliId+'_'+feature.Specification_Parameter_Code__c)){
                                    f.isDefaultIncluded = true;
                                    f.IsShowToggle = true;
                                    f.IsOptionDisabled = true;
                                    f.IsToggleChecked = false;
                                    if(pfwrap.toggleLabel=='Optional'){
                                        f.IsSpToggleDisabled = true;
                                    }
                                    else if (pfwrap.toggleLabel=='Included'){
                                        f.IsSpToggleDisabled = false;
                                    }
                                }else{
                                    f.isDefaultIncluded = true;
                                    f.IsShowToggle = true;
                                    f.IsToggleChecked = true;
                                    f.isFeatureIncluded = true;
                                    //f.toggleLabel = 'Included';
                                    if(pfwrap.toggleLabel=='Optional'){
                                        f.IsSpToggleDisabled = true;
                                    }
                                    else if (pfwrap.toggleLabel=='Included'){
                                        f.IsSpToggleDisabled = false;
                                    }
                                }
                            }
                        }
                        
                        f.featureId = featureRec.Id;
                        f.parameterCode = feature.Specification_Parameter_Code__c;
                        f.Name = featureRec.Name;
                        f.ParamName = feature.Name;
                        f.specParamId= feature.Id;
                        f.compId = featureRec.Product_Component__c;    
                        
                        if (feature.Description__c != null){
                            f.Description = feature.Description__c.stripHtmlTags() ;
                        }
                        
                        f.key = productKey;
                        f.oliId = !iscountryclonemode ? oliId:null;
                        f.isMandatory = feature.Is_Mandatory__c;
                        if(feature.Is_Mandatory__c && (((pfwrap.Included != null && pfwrap.Included) && (f.Included != null && f.Included)) || 
                                                       ((pfwrap.Included != null && pfwrap.Included) && (f.IsToggleChecked != null && f.IsToggleChecked)) ||
                                                       ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.Included != null && f.Included)) || 
                                                       ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.IsToggleChecked != null && f.IsToggleChecked))) ){
                                                           f.isMandatoryIncluded = true;
                                                       }else if(feature.Is_Mandatory__c){
                                                           f.isMandatoryIncluded = false;
                                                       }
                        
                        if (featureToValueMap.containsKey(featureRec.Id) || featureToValueMapWithCode.containskey(pfwrap.featureCode)){
                            system.debug('enter to clone'+ pfwrap.featureCode);
                            set<String> setstr = new set<String>();
                            if(prodspecialParamToOptionMap.containsKey(feature.Id)){
                                f.defaultValue = String.join( prodspecialParamToOptionMap.get(feature.Id), ';' );  
                                setstr.Addall(prodspecialParamToOptionMap.get(feature.Id));
                            }else if( filledParameterWithOptionCode.containsKey(f.parameterCode) &&filledParameterWithOptionCode.get(f.parameterCode) != null){
                                List<String> optionPresent= new List<String>();
                                for(String optionCode:filledParameterWithOptionCode.get(f.parameterCode) ){
                                    if(parameterToOptionCode.containsKey(f.parameterCode) && parameterToOptionCode.get(f.parameterCode).contains(optionCode)){
                                        optionPresent.add(optionCodeToName.get(optionCode));
                                    }
                                }
                                f.defaultValue = !optionPresent.isEmpty() ? String.join( optionPresent, ';' ): '';
                                setstr.Addall(optionPresent);
                            }
                            system.debug('f.defaultValue1--'+ f.defaultValue);
                            
                            List<String> defaultvalset = new list<String>();
                            defaultvalset.Addall(setstr);
                            
                            f.key = featureToValueMap.containskey(featureRec.Id) ? featureToValueMap.get(featureRec.Id).Opportunity_Product_Cus__c : productKey!= null && productKey.contains('_') ? f.oliId : productKey ; // for edit mode assign Key as OLI Id
                            
                            f.key = productKey!= null && productKey.contains('_') && iscountryclonemode ? productKey: f.key;
                            f.opptyFeatureId =featureToValueMap.containskey(featureRec.Id) ? featureToValueMap.get(featureRec.Id).Id :null;
                            if(prodconfigincluded==false && iscountryclonemode==true ){
                                f.defaultValue=null;
                            }

                            if(f.defaultValue != null && (!String.isBlank(f.defaultValue)) && f.isMandatory && (((pfwrap.Included != null && pfwrap.Included) && (f.Included != null && f.Included)) || 
                                                                                                                ((pfwrap.Included != null && pfwrap.Included) && (f.IsToggleChecked != null && f.IsToggleChecked)) ||
                                                                                                                ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.Included != null && f.Included)) || 
                                                                                                                ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.IsToggleChecked != null && f.IsToggleChecked)) )) {//9469
                                                                                                                    
                                                                                                                    if(!response.mapOfNoofPreFields.containsKey(f.key)) {
                                                                                                                      //  if(editMode){
                                                                                                                        response.mapOfNoofPreFields.put(f.key, 1);
                                                                                                                       // }
                                                                                                                    }else { 
                                                                                                                       // if(editMode){
                                                                                                                        response.mapOfNoofPreFields.put(f.key, response.mapOfNoofPreFields.get(f.key) + 1);
                                                                                                                      //  }
                                                                                                                      }
                                                                                                                    
                                                                                                                }
                        }else if(oliRec.isEmpty() || (oliRec[0]!= null && lstProductIds[0] == oliRec[0].Product2Id__c) && !response.mapOfNoofPreFields.containsKey(f.key) && !response.mapOfNoofPreFields.containsKey(f.oliId)  ){
                          
                            if((prodconfigincluded == null || iscountryclonemode == null)||(!prodconfigincluded == false && !iscountryclonemode == true)|| (prodconfigincluded== false && iscountryclonemode== false) ){
                                if(f.key!= null &&  !f.key.contains('_') && !response.mapOfNoofPreFields.containsKey(f.key)){
                                    response.mapOfNoofPreFields.put(f.key, 0);
                                }else if(f.key!= null &&  f.key.contains('_') && !response.mapOfNoofPreFields.containsKey(f.key) ){
                                        response.mapOfNoofPreFields.put(f.key, 0);
                                        }
                                    }
                           
                            if(f.oliId != null && !iscountryclonemode){
                                    if(!response.mapOfNoofPreFields.containsKey(f.oliId)) {
                                    response.mapOfNoofPreFields.put(f.oliId, 0);
                                       }
                                }
                            }
                            
                        if ( iscountryclonemode==true && !response.mapOfNoofPreFields.containsKey(f.key) ){//prodconfigincluded==true
                            response.mapOfNoofPreFields.put(f.key, 0);
                        }
                        system.debug(response.mapOfNoofPreFields);
                        
                        
                        if(feature.Is_Mandatory__c){
                        }
                        if (feature.Type__c != null){
                            
                            String fType = feature.Type__c.toLowercase();
                            // if type is Options - display feature as picklist
                            if (fType == 'options' || fType == 'information'){
                                // if Allow_None_Value__c is true, then add option to select 'None'
                                if (featureRec.Allow_None_Value__c == true){
                                    picklistOptions pNone = new picklistOptions();
                                    pNone.label = '--None--';
                                    pNone.value = '';
                                    f.picklistValues.add(pNone);
                                }
                                map<String,Id> mapofIdOptions = new map<String,Id>();
                                map<String,String> selectedmapofIdOptions = new map<String,String>();
                                if(speciparamToOptionMap.containsKey(feature.Id) && !speciparamToOptionMap.get(feature.Id).isEmpty() && !speciparamToOptionMap.Isempty()){
                                    for (Product_Specification_Option__c sOption : speciparamToOptionMap.get(feature.Id)) {
                                        // get picklist values from 'Options' field
                                        picklistOptions p = new picklistOptions();
                                        
                                        if(fType == 'options'){
                                            p.label = sOption.Specification_Option_Name__c;
                                            p.value = sOption.Specification_Option_Name__c;
                                            p.optionCode =sOption.Specification_Option_Code__c;
                                            mapofIdOptions.put(sOption.Specification_Option_Name__c,sOption.Id);
                                            f.picklistValues.add(p);
                                            if (sOption.isDefaultValue__c && feature.Allow_Multiselect__c == false && fType != 'information'){//14616 start
                                            f.hasdefaultconfig =sOption.isDefaultValue__c; 
                                            f.defaultconfigvalue=sOption.Name;
                                           
                                                if(f.defaultconfigvalue !=null && f.defaultconfigvalue != '' && feature.Default_Visibility__c == 'INCLUDED' && feature.Is_Mandatory__c ){
                                  countofdefaultconfig=countofdefaultconfig+1  ;   
                               }
                                            }//14616end
                                        }else if(fType == 'information'){
                                            f.defaultValue = sOption.Description__c;
                                        }
                                    }
                                    //System.debug(f.defaultmultiselectValues + '$$$shilpa');
                                    f.speciOptionMap = mapofIdOptions;
                                }
                                
                                if(fType == 'information'){
                                    f.isTypeInformation = true;
                                }
                                // set flags as per type/Allow_Multiselect__c - these flags are them used in LWC template to show appropriate input component
                                if (feature.Allow_Multiselect__c == false && fType != 'information'){
                                    f.isTypeSinglePicklist = true; // display as single picklist
                                    f.singlePicklistValue=f.defaultValue;
                                }else {
                                    
                                    if(fType != 'information'){
                                        f.isTypeMultiPicklist = true; // display as multi-select picklist
                                    }
                                    
                                    if (!String.isBlank(f.defaultValue) && f.defaultValue!=null){
                                        f.multiSelectDefault.addAll(f.defaultValue.split(';')); // for multi-select picklist we need default vlaue as List<String>                             if(isProdConfigIncluded && iscountryclonemode )
                                        
                                        f.defaultValue = f.defaultValue.replace(';','; ');
                                        for(String str : f.multiSelectDefault){
                                            selectedmapofIdOptions.put(str,str);
                                        }
                                        
                                        f.selectedspeciOptionMap = selectedmapofIdOptions;
                                        system.debug('f.selectedspeciOptionMap--'+f.selectedspeciOptionMap);
                                    }
                                }
                            }
                        }
                        
                        f.specParmIdset = specParmIds;
                        tmpFeatureLst.add(f);
                        if(oliId == null || iscountryclonemode  ){
                            if((f.isMandatory && (((pfwrap.Included != null && pfwrap.Included) && (f.Included != null && f.Included)) || 
                                                  ((pfwrap.Included != null && pfwrap.Included) && (f.IsToggleChecked != null && f.IsToggleChecked)) ||
                                                  ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.Included != null && f.Included)) || 
                                                  ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.IsToggleChecked != null && f.IsToggleChecked)) ))){ 
                                                      
                                                      if(!response.mapOfIdAndNoofFields.containsKey(f.key)) {
                                                          response.mapOfIdAndNoofFields.put(f.key, 1);
                                                      }else {
                                                          response.mapOfIdAndNoofFields.put(f.key, response.mapOfIdAndNoofFields.get(f.key) + 1);
                                                      }
                                                  }else{
                                                      if(!response.mapOfIdAndNoofFields.containsKey(f.key)) {
                                                          response.mapOfIdAndNoofFields.put(f.key, 0);
                                                      }
                                                  }
                        }
                        else {  
                            if((f.isMandatory && (((pfwrap.Included != null && pfwrap.Included) && (f.Included != null && f.Included)) || 
                                                  ((pfwrap.Included != null && pfwrap.Included) && (f.IsToggleChecked != null && f.IsToggleChecked)) ||
                                                  ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.Included != null && f.Included)) || 
                                                  ((pfwrap.IsToggleChecked != null && pfwrap.IsToggleChecked) && (f.IsToggleChecked != null && f.IsToggleChecked)) ))){ 
                                                      if(!response.mapOfIdAndNoofFields.containsKey(f.oliId)) {
                                                          response.mapOfIdAndNoofFields.put(f.oliId, 1);
                                                      }else {
                                                          response.mapOfIdAndNoofFields.put(f.oliId, response.mapOfIdAndNoofFields.get(f.oliId) + 1);
                                                      }  
                                                  }else{
                                                      if(!response.mapOfIdAndNoofFields.containsKey(f.oliId)) {
                                                          response.mapOfIdAndNoofFields.put(f.oliId, 0);
                                                      }
                                                  }
                        }
                        if((!editMode && feature.Default_Visibility__c == 'INCLUDED')||(iscountryclonemode && (prodconfigincluded==null || prodconfigincluded==false )) ){
                          response.mapOfNoofPreFields.put(f.key, countofdefaultconfig);
                        }
                        
                        pfwrap.featureWrapperlist= tmpFeatureLst;
                        if(!tmpFeatureLst.isEmpty()){
                            tempProductFeatureList.add(pfwrap);
                            set<prodfeatureWrapper> tempset = new set<prodfeatureWrapper>();
                            tempset.addAll(tempProductFeatureList);
                            tempProductFeatureList = new List<prodfeatureWrapper>();
                            tempProductFeatureList.addAll(tempset);
                            response.mapComponentToProductFeatures.put(featureRec.Product_Component__c, tempProductFeatureList);
                        }

                    }
                }
            }
        }
        
        //form map of product to component list
        for (Product_Component__c comp : lstComponents.values()){
            if (response.mapComponentToProductFeatures.containsKey(comp.Id)){
                if (response.mapProdutToComponents.containskey(comp.Product__c)){
                    tmpCompLst = response.mapProdutToComponents.get(comp.Product__c);
                }else{
                    tmpCompLst = new List<Product_Component__c>();
                }
                
                tmpCompLst.add(comp);
                response.mapProdutToComponents.put(comp.Product__c, tmpCompLst);
            }
        }
        
        //form map of prod to map of country to segment data //SFSE-13634
        Map<Id,Id> mapProdToLatestVersion = new Map<Id,Id>();
        for(Product2 prod : [Select id,Latest_Product_Version__c from Product2 where Id in: lstProductIds]){
            if(prod.Latest_Product_Version__c != null){
                lstProductIds.add(prod.Latest_Product_Version__c);
                if(!mapProdToLatestVersion.containsKey(prod.Id)){
                    mapProdToLatestVersion.put(prod.Latest_Product_Version__c,prod.id);
                }
            }
        }
        List<Segment_Data__c> SegmentData = [select id,Country_Name__c, Product__r.id, Product__r.Name,Product__r.OIPC_Code__c,Product__r.Latest_Product_Version__c, Segmentation__r.Country__r.id, Default_GP_Margin__c, Default_GP_unit__c, Revenue_unit__c from Segment_Data__c where Product__r.IsActive =: true and Type__c =: 'Revenue' and Product__r.id in: lstProductIds];
        if(!SegmentData.isEmpty()){
            for(Segment_Data__c sgd : SegmentData){
                if(!response.MapofProdToSegmentData.containsKey(sgd.Product__r.id)){
                    response.MapofProdToSegmentData.put(sgd.Product__r.id, new Map<Id, List<Segment_Data__c>>());
                }
                
                Map<Id, List<Segment_Data__c>> innerMap = response.MapofProdToSegmentData.get(sgd.Product__r.id);
                
                if (!innerMap.containsKey(sgd.Segmentation__r.Country__r.id)) {
                    innerMap.put(sgd.Segmentation__r.Country__r.id, new List<Segment_Data__c>());
                }
                innerMap.get(sgd.Segmentation__r.Country__r.id).add(sgd);
            }
        }
        for(Id prodid : response.MapofProdToSegmentData.keyset()){
            if(mapProdToLatestVersion.containsKey(prodid)){
                response.MapofProdToSegmentData.put(mapProdToLatestVersion.get(prodid),response.MapofProdToSegmentData.get(prodid));
            }
        }
        system.debug('response'+response);
        return response;
    }
    
    // convert Product record to Product wrapper instance
    public static productWrapper convertProdToProductWrapper(Product2 prod, Set<String> oceanFamily ){
        productWrapper prodRecord = new productWrapper();
        prodRecord.Name = prod.Name;
        prodRecord.totalCompletedFeatures = 0;
        prodRecord.productId = prod.Id;
        prodRecord.productURL = '/' + prod.Id; //prod.Id;
        prodRecord.QuantityUnitOfMeasure = prod.QuantityUnitOfMeasure;
        prodRecord.Family = prod.Family;
        prodRecord.ServiceModel = prod.Service_Model__c;
        prodrecord.definationType = prod.Definition_Type__c;
        prodRecord.featureCount = 0;
        prodRecord.noMandatoryFeature = true;
        prodRecord.featurePreCount = 0;
        prodRecord.filledConCount = 0;
        prodRecord.ProductStatus = prod.Product_Status__c;
        //prodRecord.UnitPrice = prod.PricebookEntries[0].UnitPrice;
        //SFSE-14236
        /*if(!prod.PricebookEntries.isempty() && prod.PricebookEntries[0].Default_GP_per_unit__c!=null){
prodRecord.UnitPrice = prod.PricebookEntries[0].Default_GP_per_unit__c;
}*/
        
        prodRecord.OipcCode = prod.OIPC_Code__c;
        prodRecord.isoipc = prod.OIPC_Code__c !=null ? true: false;
        prodRecord.oipcProduct = (prod.OIPC_Code__c != null ? true : false);
        prodRecord.isOceanPortfolio = (oceanFamily.contains(prod.Family) ? true : false);
        prodRecord.portfolio = prod.Portfolio__c;
        prodRecord.Is_Product_Add_On = prod.Is_Product_Add_On__c;
        prodRecord.includeInOMEB = prod.Include_in_OMEB_Approvals__c;
        prodRecord.qtyUnitOfMeasure = prod.QuantityUnitOfMeasure;
        // prodRecord.typeOfLocationNeeded = (LocationType.contains(prod.Type_of_Location_Needed__c) ? true : false);
        prodRecord.isChecked = false;
        prodRecord.isDisabled = false;
        prodRecord.isFilterEnabled = false;
        prodRecord.hideInShowAll = false;
        prodRecord.ProductScope = prod.Product_Scope__c;
        prodRecord.isLnSPortfolio = (prod.Portfolio__c == 'LnS' ? true : false);  
        return prodRecord;
    }
    
    
    // query products - For Add mode - list all active products. For Edit mode - return Products related to existing OLI records
    @AuraEnabled
    public static List<productWrapper> getProducts(Id OpportunityId, Boolean editMode, Id oliId, Boolean cloneMode ) {
        
        //String oipcCodesOfWD = Label.OIPC_Code_WD;
        List<String> oipcCodesOfCLproducts= Label.OIPC_Code_WD.split(';');
        
        String singleProduct;
        
        if(oliId != null) {
            singleProduct = 'AND Id = :oliId';
        }
        List<productWrapper> result = new List<productWrapper>();
        Map<Id, Opportunity_Product__c> mapExistingOLIs = new Map<Id, Opportunity_Product__c>();//10893
        Map<String, Feedback__c> mapExistingFeedbacks = new Map<String, Feedback__c>();
        Set<String> oceanFamily = new Set<String>(Label.OpptyProduct_OceanFamily.split(';'));
        Set<String> maerskECOProduct =new Set<String>(Label.MaerskECODelivery_Product_Code.split(';'));
        Set<String> specialCargoFamily =new Set<String>(Label.SpecialCargoOceanFamily.split(';'));
        //Set<string> leadLogisticFamily =new Set<String>(Label.LeadLogisticFamily.split(';'));
        Set<String> depotOipcCodes = new Set<String>(Label.Depot_Oipc_Codes.split(';'));
        Set<String> warehousingAndFulfilmentOipcCodes = new Set<String>(Label.Warehousing_nd_Fulfillment_Oipc_Codes.split(';'));
        Set<String> oipcCode = new Set<String>(Label.OipcProductCode.split(';'));
        //SFSE-10179
        Contract_Logistics_OIPC_Code__mdt cLRec = Contract_Logistics_OIPC_Code__mdt.getInstance('CL_OIPC_Codes');
        Set<String> oipcCodeForCL = new Set<String>(cLRec.Label.split(';'));
        Id pbId;
        
        if (Test.isRunningTest()){
            pbId = Test.getStandardPricebookId();
        } else {
            List<PriceBook2> lstPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = true LIMIT 1];
            pbId = lstPB[0].Id; // Get pricebook edntry if for Standard Pricebook
        }
        
        String strProdCondition = '';
        if (editMode){
            Set<Id> setIDs = new Set<Id>();
            Set<String> oliIds = new Set<String>();
            // for edit mode get existing OLI records and fetch realted products  SFSE-8854
            //10893
            // to do HasSchedule has been removed from select 10893
            if(oliId == null) {
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c,Import_Export__c, 
                                                                       Amend_Expected_FFE__c, UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c, Product2Id__r.Latest_Product_Version__c ,Country__c,Destination_Country__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__c, Executing_City_State__r.Name, Trade_Route__r.Name, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Estimated_Footprint_Requirement_in_Sqm__c,Solution__c, Description__c,Special_Cargo__c,Definition_Type__c,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c WHERE OpportunityId__c = :OpportunityId ORDER BY Product2ID__r.Name]);  
            }else if(string.valueof(oliId).startswith('01t') ){
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, Import_Export__c,
                                                                       Amend_Expected_FFE__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c,Country__c,Destination_Country__c, Executing_City_State__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__r.Name,Estimated_Footprint_Requirement_in_Sqm__c, Trade_Route__r.Name, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Solution__c,Description__c,Special_Cargo__c, Definition_Type__c, Solution__r.Name,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c 
                                                                       WHERE OpportunityId__c = :OpportunityId AND Solution__c = :oliId ORDER BY Product2ID__r.Name ]);  
            }else {
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, Import_Export__c,
                                                                       Amend_Expected_FFE__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c, Product2Id__r.Latest_Product_Version__c, Country__c,Destination_Country__c, Executing_City_State__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__r.Name, Trade_Route__r.Name,Estimated_Footprint_Requirement_in_Sqm__c, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Solution__c,Description__c,Special_Cargo__c, Definition_Type__c,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c 
                                                                       WHERE OpportunityId__c = :OpportunityId AND Id = :oliId ORDER BY Product2ID__r.Name ]);  
            }
            
            for ( Opportunity_Product__c oli : mapExistingOLIs.values()){
                
                setIDs.add(oli.Product2Id__c);
                if(oli.Definition_Type__c == 'Product' ||  oli.Definition_Type__c == 'Add-On Product'){
                    if(oli.Product2Id__r.Latest_Product_Version__c != null){
                        setIDs.add(oli.Product2Id__r.Latest_Product_Version__c);
                    } 
                }
                
                oliIds.add(oli.Id);
                
            }
            //10893
            // to do HasSchedule has been removed from select 10893
            if(oliId == null) {
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, Import_Export__c,
                                                                       Amend_Expected_FFE__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c,Country__c,Destination_Country__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__c, Executing_City_State__r.Name, Trade_Route__r.Name, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Estimated_Footprint_Requirement_in_Sqm__c,Solution__c, Description__c,Special_Cargo__c,Definition_Type__c,Solution__r.Name,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c WHERE OpportunityId__c = :OpportunityId ORDER BY Product2ID__r.Name]);  
            }else if(string.valueof(oliId).startswith('01t') ){
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, Import_Export__c,
                                                                       Amend_Expected_FFE__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c,Country__c,Destination_Country__c, Executing_City_State__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__r.Name, Trade_Route__r.Name, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Estimated_Footprint_Requirement_in_Sqm__c,Solution__c,Description__c,Special_Cargo__c, Definition_Type__c, Solution__r.Name,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c 
                                                                       WHERE OpportunityId__c = :OpportunityId AND Solution__c = :oliId ORDER BY Product2ID__r.Name ]);  
            }else{
                mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT Id,Total_Mandatory_Configuration__c,Total_Mandatory_Configuration_Filled__c, Total_Config_Completed_Percentage__c, Import_Export__c,
                                                                       Amend_Expected_FFE__c,UnitPrice__c,Amend_Gross_Profit_per_unit__c, Product2Id__c,Country__c,Destination_Country__c, Executing_City_State__c, Total_Tender_FFE_per_Route_Direction__c,
                                                                       Executing_City_State__r.Name, Trade_Route__r.Name, Quantity__c, Warehouse_Site__c, Warehouse_Site__r.Name, Product2Id__r.QuantityUnitOfMeasure,Opt_Out_Auto_Quantity_Scheduling__c,
                                                                       Product2ID__r.OIPC_Code__c,Solution__c,Description__c,Estimated_Footprint_Requirement_in_Sqm__c,Special_Cargo__c, Definition_Type__c, Solution__r.Name,Product_Revenue_Per_Unit__c,WND_Location_Type__c,Cargo_Type__c,OpportunityId__r.isClosed,OpportunityId__r.Customer_Journey__c
                                                                       FROM Opportunity_Product__c 
                                                                       WHERE OpportunityId__c = :OpportunityId AND Id = :oliId ORDER BY Product2ID__r.Name ]);  
            }
            
            
            
            for( Feedback__c feedback : [SELECT Id, Name, Description__c, Related_To_ID__c, Related_To__c, Feedback_Category__c, Opportunity_Product_Cus__c
                                         FROM Feedback__c 
                                         WHERE Related_To_ID__c IN : oliIds AND CreatedById =: UserInfo.getUserId()
                                         ORDER by CreatedDate DESC]){
                                             if(!mapExistingFeedbacks.containsKey(feedback.Related_To_ID__c)){
                                                 mapExistingFeedbacks.put(feedback.Related_To_ID__c, feedback);
                                             }
                                         }
            strProdCondition = ' Id in :setIDs';
        } else {
            // for Add mode - fetch all active products
            strProdCondition = ' IsActive = True ';
        }
        
        String strQuery = 'SELECT Id, Name,  Route_Direction_Code__c, QuantityUnitOfMeasure, Family, Product_Status__c,Type_of_Location_Needed__c,Definition_Type__c,IsActive,End_of_Sales__c,End_of_Service__c, OIPC_Code__c,Portfolio__c,Include_in_OMEB_Approvals__c, Is_Product_Solution__c,Is_Product_Add_On__c,Service_Model__c,Product_Scope__c,Latest_Product_Version__c,Latest_Product_Version__r.IsActive,Latest_Product_Version__r.Product_Status__c,';
        strQuery += '(select id, Name, Product__c, Product__r.Name, Solution__c from Solutions__r) ';
        //strQuery += '(Select ID, Product2Id,Default_GP_Margin__c,Default_GP_per_unit__c,Default_Revenue_per_Unit__c,UnitPrice FROM PricebookEntries Where Pricebook2Id = :pbId ) ';
        // strQuery += '(Select ID, Product2Id, UnitPrice FROM PricebookEntries Where Pricebook2Id = :pbId ) ';
        strQuery += ' FROM Product2 WHERE ';
        strQuery += strProdCondition;
        strQuery += ' ORDER BY Name ';
        system.debug('query for data :'+ strQuery);
        Map<Id, Product2> productMap = new Map<Id, Product2>( (List<Product2>) database.query(strQuery));
        
        String strQuery2 = 'SELECT Id, Name,  Route_Direction_Code__c, QuantityUnitOfMeasure, Family, Product_Status__c,Type_of_Location_Needed__c,Definition_Type__c, OIPC_Code__c,Portfolio__c,Include_in_OMEB_Approvals__c,IsActive,End_of_Sales__c,  Is_Product_Solution__c,Is_Product_Add_On__c,Service_Model__c,Product_Scope__c';
        //strQuery2 += '(Select ID, Product2Id, UnitPrice,Default_GP_Margin__c,Default_GP_per_unit__c,Default_Revenue_per_Unit__c FROM PricebookEntries Where Pricebook2Id = :pbId ) ';
        // strQuery2 += '(Select ID, Product2Id, UnitPrice FROM PricebookEntries Where Pricebook2Id = :pbId ) ';
        strQuery2 += ' FROM Product2 WHERE ';
        strQuery2 += ' Id IN (select Product__c from Product_Reference__c where Solution__r.IsActive = true)';
        strQuery2 += ' ORDER BY Name ';
        system.debug('query for data :'+ strQuery2);
        Map<Id, Product2> productsOfSolutionMap = new Map<Id, Product2>( (List<Product2>) database.query(strQuery2));
        
        if (editMode){
            Set<Id> productIds = new Set<Id>();
            Map<Id, Id> mapOldProdtoLatestProduct = new Map<Id, Id>();
            if(cloneMode){
                
                for (Opportunity_Product__c oli : mapExistingOLIs.values()){
                    productIds.add(oli.Product2Id__c);
                }
                
                System.debug('productIds '+productIds);
                for(Product2 product : [SELECT Id, Name,Latest_Product_Version__c,IsActive,Definition_Type__c, Latest_Product_Version__r.IsActive 
                                        FROM Product2 
                                        WHERE Id IN :productIds]){
                                            if(product.IsActive == false && product.Latest_Product_Version__c != null
                                               && product.Latest_Product_Version__r.IsActive == true){
                                                   mapOldProdtoLatestProduct.put(product.Id, product.Latest_Product_Version__c);
                                               }
                                        }
                
            }
            
            for (Opportunity_Product__c oli : mapExistingOLIs.values()){
                Id prodId;
                
                //13664
                if(cloneMode && mapOldProdtoLatestProduct.containsKey(oli.Product2Id__c) && oli.Definition_Type__c == 'Packaged Solution'){
                    prodId = oli.Product2Id__c;
                }else if(cloneMode && mapOldProdtoLatestProduct.containsKey(oli.Product2Id__c)){
                    prodId = mapOldProdtoLatestProduct.get(oli.Product2Id__c);
                }else{
                    prodId = oli.Product2Id__c;
                }
                
                productWrapper prodRecord = convertProdToProductWrapper(productMap.get(prodId), oceanFamily);
                prodRecord.solutionId = oli.Solution__c;
                prodRecord.solutionName = oli.Solution__r.Name;
                prodRecord.isStandaloneProduct = oli.Solution__c != null || oli.Definition_Type__c == 'Packaged Solution' ||  oli.Definition_Type__c == 'Integrated Solution' ? false : true;
                prodRecord.solutionDefinition = oli.Solution__c != null ? 'Packaged Solution' : (oli.Definition_Type__c == 'Product' || oli.Definition_Type__c == 'Add-On Product') ? 'Standalone Product':  oli.Definition_Type__c;
                prodRecord.isOceanFamily = specialCargoFamily.contains(productMap.get(prodId).Family) ? true : false;
                prodRecord.iswndProduct = depotOipcCodes.contains(productMap.get(prodId).OIPC_Code__c)? true : (warehousingAndFulfilmentOipcCodes.contains(productMap.get(prodId).OIPC_Code__c)? true :false); //SFSE -11753
                    prodRecord.isOPICCode = oipcCode.contains(productMap.get(prodId).OIPC_Code__c) ? true: false;
                prodRecord.typeOfLocationNeeded = productMap.get(prodId).Type_of_Location_Needed__c == 'Origin & Destination' ? true :false;
                System.debug('LocationTypeTest'+ prodRecord.typeOfLocationNeeded);
                prodRecord.isMaerskEcoOROceanFamily =  maerskECOProduct.contains(productMap.get(prodId).OIPC_Code__c)? true: false;
                System.debug('opic code values'+productMap.get(prodId).OIPC_Code__c);
                prodRecord.isCLoipcCode = oipcCodeForCL.contains(productMap.get(prodId).OIPC_Code__c) ? true: false;//SFSE-10179
                prodRecord.oliId = oli.Id;
                prodRecord.isIntegratedProduct = productMap.get(prodId).Is_Product_Solution__c ? true : false;
                if(productMap.get(prodId).OIPC_Code__c != null){
                prodRecord.isMcsProduct = warehousingAndFulfilmentOipcCodes.contains(productMap.get(prodId).OIPC_Code__c) ? true :false;
                }    
                //13664 added if condition 
                if(oli.Definition_Type__c == 'Packaged Solution')
                {
                    prodRecord.totalCompletedFeatures = (oli.Total_Config_Completed_Percentage__c !=null ) ?  oli.Total_Config_Completed_Percentage__c : 0 ;
                    prodRecord.featurePreCount = (Integer.valueof(oli.Total_Mandatory_Configuration_Filled__c) !=null ) ? Integer.valueof(oli.Total_Mandatory_Configuration_Filled__c) : 0;                  
                }else{
                    prodRecord.totalCompletedFeatures = (oli.Total_Config_Completed_Percentage__c !=null && !mapOldProdtoLatestProduct.containsKey(oli.Product2Id__c)) ?  oli.Total_Config_Completed_Percentage__c : 0 ;
                    prodRecord.featurePreCount = (Integer.valueof(oli.Total_Mandatory_Configuration_Filled__c) !=null && !mapOldProdtoLatestProduct.containsKey(oli.Product2Id__c)) ? Integer.valueof(oli.Total_Mandatory_Configuration_Filled__c) : 0;                   
                }
                
                
                //SFSE-10599
                if(oipcCodesOfCLproducts.contains(productMap.get(prodId).OIPC_Code__c)){
                    prodRecord.checkWDproducts=true; 
                }
                else{
                    prodRecord.checkWDproducts =false;    
                }
                
                //prodRecord.filledConCount = Integer.valueof(oli.Total_Configurations_Filled__c) !=null ? Integer.valueof(oli.Total_Configurations_Filled__c) : 0;
                
                prodRecord.key = oli.Id + '_' + prodId;
                
                //SFSE-9336
                if(cloneMode){
                    
                    prodRecord.potentialQuantity = null;
                    //prodRecord.hasSchedule = false;
                    editMode=false;
                    if(!prodRecord.isOceanPortfolio){
                        prodRecord.city = null;
                        prodRecord.cityName = null;
                        prodRecord.country = '';
                        prodRecord.destinationCountry = '';
                    }else{
                        prodRecord.city = oli.Executing_City_State__c;
                        prodRecord.cityName = oli.Executing_City_State__r.Name;
                        prodRecord.country = oli.Country__c;
                    }
                    prodRecord.tradeRoute = '';
                    prodRecord.quantityValue = 1;//SFSE-9520
                    //SFSE-10179
                    prodRecord.wareHouseName = null;
                    prodRecord.wndLocationType = null;
                    prodRecord.wareHouse = null; 
                    for (Product2 prod :productMap.values()){        
                        /*if(!productMap.isempty() && productMap.get(prod.Id)!=null && !productMap.get(prod.Id).PricebookEntries.isempty() && productMap.get(prod.Id).PricebookEntries[0].Default_Revenue_per_Unit__c!=null){
prodRecord.ProductRevenuePerunit = productMap.get(prod.Id).PricebookEntries[0].Default_Revenue_per_Unit__c; 
}
if(!productMap.isempty() && productMap.get(prod.Id)!=null && !productMap.get(prod.Id).PricebookEntries.isempty() && productMap.get(prod.Id).PricebookEntries[0].Default_GP_Margin__c!=null){
prodRecord.defaultGPMargin = productMap.get(prod.Id).PricebookEntries[0].Default_GP_Margin__c;  
}*/
                        if(!productMap.isempty() && productMap.get(prod.Id)!=null && productMap.get(prod.Id).Portfolio__c == 'Ocean'){
                            prodRecord.ProductRevenuePerunit = 1;
                            prodRecord.unitprice = 1;
                        }
                    }
                    prodRecord.productName  = oli.Product2ID__r.OIPC_Code__c;    
                    
                }else{
                    
                    prodRecord.potentialQuantity = oli.Total_Tender_FFE_per_Route_Direction__c;
                    // prodRecord.hasSchedule = oli.HasSchedule__c;//to do 10893
                    prodRecord.tradeRoute = oli.Trade_Route__c;
                    prodRecord.city = oli.Executing_City_State__c;
                    prodRecord.cityName = oli.Executing_City_State__r.Name;
                    prodRecord.quantityValue = oli.Quantity__c;//SFSE-9520
                    
                    //SFSE-10179
                    prodRecord.wareHouseName = oli.Warehouse_Site__r.Name;
                    prodRecord.wndLocationType = oli.WND_Location_Type__c;
                    prodRecord.wareHouse = oli.Warehouse_Site__c;
                    prodRecord.country = oli.Country__c;
                    prodRecord.destinationCountry = oli.Destination_Country__c;
                    prodRecord.ProductRevenuePerunit = oli.Product_Revenue_Per_Unit__c;
                }
                prodRecord.optOutSch = oli.Opt_Out_Auto_Quantity_Scheduling__c;
                prodRecord.UnitPrice = oli.UnitPrice__c;
                prodRecord.importExportValue = oli.Import_Export__c;
                prodRecord.specialCargoValue = oli.Special_Cargo__c;
                prodRecord.lineDescriptionValue = oli.Description__c;
                prodRecord.isOpptyClosed = oli.OpportunityId__r.isClosed;
                prodRecord.isCargoTypeReadonly = oli.OpportunityId__r?.Customer_Journey__c != '' && oli.OpportunityId__r?.Customer_Journey__c == Label.Instant_Quote ? true : false;//SFSE-14825
                prodRecord.cargoTypeValue = oli.OpportunityId__r?.Customer_Journey__c != '' && oli.OpportunityId__r?.Customer_Journey__c == Label.Instant_Quote ? 'Dry' : oli.Cargo_Type__c;//SFSE-14825
                if(oli.Trade_Route__c != Null && cloneMode == false)//SFSE-9336
                    prodRecord.prodtradeRouteName =prodRecord.Name+ ' [' +oli.Trade_Route__r.Name+ '] ';
                else
                    prodRecord.prodtradeRouteName =prodRecord.Name;
                if(mapExistingFeedbacks.containsKey(String.valueOf(oli.Id)) && !mapOldProdtoLatestProduct.containsKey(oli.Product2Id__c)){
                    prodRecord.feedbackName = mapExistingFeedbacks.get(String.valueOf(oli.Id)).Name;
                    prodRecord.feedbackId = mapExistingFeedbacks.get(String.valueOf(oli.Id)).Id;
                    prodRecord.feedbackDescription = mapExistingFeedbacks.get(String.valueOf(oli.Id)).Description__c;
                    prodRecord.feedbackCategory = mapExistingFeedbacks.get(String.valueOf(oli.Id)).Feedback_Category__c;
                    
                    
                }else{
                    prodRecord.feedbackName = 'Report a missing product feature for '+prodRecord.Name+ ' here!';
                    
                }
                
                result.add(prodRecord);
            }
            
        } else {
            
            //for add mode assign Product Id as key
            List<Opportunity> oppList = [SELECT Id, Type FROM Opportunity WHERE Id = :OpportunityId];
            List<ProductWrapper> listProductsOfSolution = new List<ProductWrapper>();
            ProductWrapper solutionProdWrapper;
            Product2 solutionProd;
            for (Product2 prod :productMap.values()){
                if (!oppList.isEmpty() && prod.Product_Status__c == 'Limited Availability' && (oppList[0].Type == 'Acquisition' || oppList[0].Type == 'Additional Allocation' || oppList[0].Type == 'One-off (Non Renewable)') && prod.Name == 'Supply Chain Orchestrator') {
                    continue;
                } else {
                    System.debug('Product Name' + prod.Name);
                    ProductWrapper prodRecord = convertProdToProductWrapper(prod, oceanFamily);
                    if(prodRecord.definationType == 'Packaged Solution'){
                        listProductsOfSolution = new List<ProductWrapper>();
                        for(Product_Reference__c prodReference :prod.Solutions__r){
                            if(productsOfSolutionMap.containsKey(prodReference.Product__c)){
                                solutionProd = productsOfSolutionMap.get(prodReference.Product__c);
                                solutionProdWrapper = convertProdToProductWrapper(solutionProd, oceanFamily);
                                solutionProdWrapper.solutionId = prodReference.Solution__c;
                                solutionProdWrapper.isStandaloneProduct = false;
                                solutionProdWrapper.solutionDefinition = 'Packaged Solution';
                                solutionProdWrapper.isOceanFamily = specialCargoFamily.contains(solutionProd.Family) ? true : false;
                                solutionProdWrapper.iswndProduct = depotOipcCodes.contains(solutionProd.OIPC_Code__c)? true : (warehousingAndFulfilmentOipcCodes.contains(solutionProd.OIPC_Code__c)? true :false);
                                    solutionProdWrapper.isOPICCode = oipcCode.contains(solutionProd.OIPC_Code__c)? true: false;
                                solutionProdWrapper.typeOfLocationNeeded = solutionProd.Type_of_Location_Needed__c == 'Origin & Destination' ? true :false;
                                solutionProdWrapper.isIntegratedProduct = solutionProd.Is_Product_Solution__c ? true : false;
                                solutionProdWrapper.isMaerskEcoOROceanFamily =  maerskECOProduct.contains(solutionProd.OIPC_Code__c)? true: false;
                                solutionProdWrapper.isCLoipcCode = oipcCodeForCL.contains(solutionProd.OIPC_Code__c) ? true: false;
                                solutionProdWrapper.key = solutionProd.Id;
                                solutionProdWrapper.checkWDproducts = oipcCodesOfCLproducts.contains(solutionProd.OIPC_Code__c) ? true : false;
                                solutionProdWrapper.isoipc = solutionProd.OIPC_Code__c !=null ? true: false;
                                solutionProdWrapper.prodtradeRouteName =solutionProd.Name;
                                solutionProdWrapper.feedbackName = 'Report a missing product feature for '+solutionProd.Name+ ' here!';
                                //SFSE-14236
                                /*if(!productsOfSolutionMap.isempty() && productsOfSolutionMap.get(solutionProd.Id)!=null && !productsOfSolutionMap.get(solutionProd.Id).PricebookEntries.isempty() && productsOfSolutionMap.get(solutionProd.Id).PricebookEntries[0].Default_Revenue_per_Unit__c!=null){
solutionProdWrapper.ProductRevenuePerunit = productsOfSolutionMap.get(solutionProd.Id).PricebookEntries[0].Default_Revenue_per_Unit__c; 
}

if(!productsOfSolutionMap.isempty() && productsOfSolutionMap.get(solutionProd.Id)!=null && !productsOfSolutionMap.get(solutionProd.Id).PricebookEntries.isempty() && productsOfSolutionMap.get(solutionProd.Id).PricebookEntries[0].Default_GP_Margin__c!=null){
solutionProdWrapper.defaultGPMargin = productsOfSolutionMap.get(solutionProd.Id).PricebookEntries[0].Default_GP_Margin__c;  
}*/
                                if(!productsOfSolutionMap.isempty() && productsOfSolutionMap.get(solutionProd.Id)!=null && productsOfSolutionMap.get(solutionProd.Id).Portfolio__c == 'Ocean'){
                                    solutionProdWrapper.ProductRevenuePerunit = 1;
                                    solutionProdWrapper.unitprice = 1;
                                }
                                listProductsOfSolution.add(solutionProdWrapper);
                            }
                        }
                        prodRecord.productsOfSolution = listProductsOfSolution;
                    }
                    
                    System.debug('Product Name' + prod.Name);
                    prodRecord.isStandaloneProduct = prod.Definition_Type__c == 'Product' ||  prod.Definition_Type__c == 'Add-On Product' ? true: false;
                    prodRecord.solutionDefinition = (prod.Definition_Type__c == 'Product' ||  prod.Definition_Type__c == 'Add-On Product') ? 'Standalone Product':prod.Definition_Type__c;
                    prodRecord.isOceanFamily = specialCargoFamily.contains(prod.Family) ? true : false;
                    prodRecord.iswndProduct = depotOipcCodes.contains(prod.OIPC_Code__c)? true : (warehousingAndFulfilmentOipcCodes.contains(prod.OIPC_Code__c)? true :false); //SFSE -11753
                        prodRecord.isOPICCode = oipcCode.contains(prod.OIPC_Code__c)? true: false;
                    prodRecord.typeOfLocationNeeded = productMap.get(prod.ID).Type_of_Location_Needed__c == 'Origin & Destination' ? true :false;
                    prodRecord.isIntegratedProduct = productMap.get(prod.ID).Is_Product_Solution__c ? true : false;
                    prodRecord.isMaerskEcoOROceanFamily =  maerskECOProduct.contains(prod.OIPC_Code__c)? true: false;
                    prodRecord.isCLoipcCode = oipcCodeForCL.contains(prod.OIPC_Code__c) ? true: false;//SFSE-10179
                    prodRecord.key = prod.Id;
                    prodRecord.isActive = prod.IsActive;
                    prodRecord.endOfSales = prod.End_of_Sales__c;
                    prodRecord.endOfService = prod.End_of_Service__c;
                    prodRecord.latestProductVersion = prod.Latest_Product_Version__c;
                    prodRecord.productStatus = prod.Product_Status__c;
                    prodRecord.isLatestProductVersionActive = prod.Latest_Product_Version__r.IsActive;
                    prodRecord.latestProductStatus = prod.Latest_Product_Version__r.Product_Status__c;
                    prodRecord.isMcsProduct = warehousingAndFulfilmentOipcCodes.contains(prod.OIPC_Code__c) ? true :false;
                   
                    //SFSE-10599
                    if(oipcCodesOfCLproducts.contains(prod.OIPC_Code__c)){
                        prodRecord.checkWDproducts=true; 
                    }
                    else{
                        prodRecord.checkWDproducts =false;    
                    }
                    //prodRecord.hasSchedule = false;
                    editMode=false;
                    prodRecord.isoipc = prod.OIPC_Code__c !=null ? true: false;
                    prodRecord.prodtradeRouteName =prodRecord.Name;//SFSE-8854
                    prodRecord.feedbackName = 'Report a missing product feature for '+prodRecord.Name+ ' here!';//SFSE-8852
                    //SFSE-14236
                    /*if(!productMap.isempty() && productMap.get(prod.Id)!=null && !productMap.get(prod.Id).PricebookEntries.isempty() && productMap.get(prod.Id).PricebookEntries[0].Default_Revenue_per_Unit__c!=null){
prodRecord.ProductRevenuePerunit = productMap.get(prod.Id).PricebookEntries[0].Default_Revenue_per_Unit__c; 
}
if(!productMap.isempty() && productMap.get(prod.Id)!=null && !productMap.get(prod.Id).PricebookEntries.isempty() && productMap.get(prod.Id).PricebookEntries[0].Default_GP_Margin__c!=null){
prodRecord.defaultGPMargin = productMap.get(prod.Id).PricebookEntries[0].Default_GP_Margin__c;  
}*/
                    if(!productMap.isempty() && productMap.get(prod.Id)!=null && productMap.get(prod.Id).Portfolio__c == 'Ocean'){
                        prodRecord.ProductRevenuePerunit = 1;
                        prodRecord.unitprice = 1;
                    }
                    result.add(prodRecord);
                }
            }        
        }
        return result;
    }
    
    
    
    
    
    // save OLI and related features
    @AuraEnabled(cacheable = false)
    public static String addEditProducts(Map<String, Opportunity_Product__c> keyToOliMap , List<prodfeatureWrapper> featureList, Map<String, Feedback__c> keyToFeedback, boolean editMode, boolean cloneMode,boolean cloneCountryRowProducts) {
        if(cloneCountryRowProducts)//for country clone make as add mode to insert product and its config for multiple product
        {
            cloneMode=false;
            editMode = false;
        }else if (cloneMode){
            editMode = false;
        }
        Id cloneOLIRecId;
        Id countrycloneOLIRecId;
        String returnMessage = 'success';
        Database.SaveResult[] srList;
        
        
        List<Database.UpsertResult> upsertResults;
        
        try{
            if (editMode == false) {
                // for add mode , do insert and get OLI Ids of new records
                srList = Database.insert(keyToOliMap.values(), true);
            } else {
                // for edit mode do update
                srList = Database.update(keyToOliMap.values(), true);
            }
            
            system.debug(keyToOliMap.keyset());
            system.debug(keyToOliMap.values());
            
            // Iterate through each returned result
            
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Products ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Products fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            
            //SFSE-9336
            if(cloneMode){
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        cloneOLIRecId = sr.getId();
                    } 
                }
            }
            
            
            set<Id> setIds = new set<Id>();
            for( Database.SaveResult sr : srList){
                setIds.add(sr.getId());
            }
            for(String key : keyToFeedback.keySet() ){
                keyToFeedback.get(key).Related_To_ID__c = keyToOliMap.get(key).Id;
                keyToFeedback.get(key).Related_To__c =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+keyToOliMap.get(key).Id;
                keyToFeedback.get(key).Opportunity_Product_Cus__c = keyToOliMap.get(key).Id;
                
            }
            
            if (keyToFeedback.values().size() > 0){
                Database.upsert(keyToFeedback.values());
            }
            List<Opportunity_Product_Configuration__c> opFeatures = [SELECT Id, Name, Opportunity_Product_Cus__c, Product_Specificaiton_Parameter__c,Product_Specification_Option__r.Name,Is_Specification_Parameter_Included__c,
                                                                     Product_Specification_Option__c, Specification_Parameter_Code__c, Specification_Option_Code__c, Specification_Option_Name__c, 
                                                                     Feature_Code__c, Product_Specificaiton_Parameter__r.Product_Feature__c,Component_Code__c, Product_Component__c, Product_Feature__c FROM Opportunity_Product_Configuration__c
                                                                     WHERE Opportunity_Product_Cus__c = :setIds and Product_Specification_Option__c!=null];
            
            
            Map<Id,Map<Id,Map<String,Id>>> mapofOliallPramOptions = new Map<Id,Map<Id,Map<String,Id>>>();//OliNOptionParam
            Map<String,Id> mapofOptNIds = new Map<String,Id>();
            Map<Id,List<Id>> mapofOLIandIncludedParameter = new Map<Id,List<Id>>(); // map of Included Feature Record 
            Map<String,list<Id>> mapOfOLIParameterAndConfig = new Map<String,List<Id>>(); // map of  oli+'_'+Feature Record with config record
            
            
            for (Opportunity_Product_Configuration__c opf : opFeatures){
                
                
                if(!mapofOliallPramOptions.containsKey(opf.Opportunity_Product_Cus__c)){
                    Map<Id,MAp<String,Id>> tempmapofspecPram = new Map<Id,MAp<String,Id>>();
                    mapofOliallPramOptions.put(opf.Opportunity_Product_Cus__c,tempmapofspecPram);
                }
                Map<Id,Map<String,Id>> mapProdOptionValues = mapofOliallPramOptions.get(opf.Opportunity_Product_Cus__c);
                if(!mapProdOptionValues.containsKey(opf.Product_Specificaiton_Parameter__c)){
                    mapProdOptionValues.put(opf.Product_Specificaiton_Parameter__c,new Map<String,Id>());
                }
                Map<String,Id> mapofOptionNIDs = mapProdOptionValues.get(opf.Product_Specificaiton_Parameter__c);
                mapofOptionNIDs.put(opf.Product_Specification_Option__r.name,opf.Id);
                
                if(opf.Is_Specification_Parameter_Included__c && opf.Product_Specificaiton_Parameter__c != null){
                    
                    if(mapofOLIandIncludedParameter.containsKey(opf.Opportunity_Product_Cus__c)){
                        mapofOLIandIncludedParameter.get(opf.Opportunity_Product_Cus__c).add(opf.Product_Specificaiton_Parameter__c);
                    }else{
                        mapofOLIandIncludedParameter.put(opf.Opportunity_Product_Cus__c,new List<Id>{opf.Product_Specificaiton_Parameter__c});
                    }
                    
                    if(mapOfOLIParameterAndConfig.containsKey(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c)){
                        mapOfOLIParameterAndConfig.get(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c).add(opf.Id);
                    }else{
                        mapOfOLIParameterAndConfig.put(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c,new List<Id>{opf.Id});
                    }
                }
            }
            
            //As we are saving empty config records for all parameters
            List<Opportunity_Product_Configuration__c> emptyopFeatures = [SELECT Id, Name, Opportunity_Product_Cus__c, Product_Specificaiton_Parameter__c,Product_Specification_Option__r.Name,Configured_Product_Component__c,Is_Specification_Parameter_Included__c,
                                                                          Product_Specification_Option__c, Specification_Parameter_Code__c, Specification_Option_Code__c, Specification_Option_Name__c,Is_Feature_Included__c,Configured_Product_Feature__c,
                                                                          Feature_Code__c, Product_Specificaiton_Parameter__r.Product_Feature__c,Component_Code__c, Product_Component__c, Product_Feature__c FROM Opportunity_Product_Configuration__c
                                                                          WHERE Opportunity_Product_Cus__c = :setIds and Product_Specification_Option__c = null];
            
            set<Id> paramIds = new Set<id>();
            Map<Id,List<Id>> mapofOLIandIncludedFeature = new Map<Id,List<Id>>(); // map of Included Feature Record 
            Map<String,Id> mapofOLIandIncludedByDefaultSp = new Map<String,Id>(); // map of Included Feature Record 
            Map<String,Opportunity_Product_Configuration__c> mapOfOLIFeatureIAndConfig = new Map<String,Opportunity_Product_Configuration__c>(); // map of  oli+'_'+Feature Record with config record
            Map<Id,Map<Id,Id>> mapofOliallPramEmptyOptions = new Map<Id,Map<Id,Id>>();//OliNOptionParam
            
            for (Opportunity_Product_Configuration__c opf : emptyopFeatures){
                
                if(opf.Specification_Option_Code__c == null && opf.Product_Specificaiton_Parameter__c == null ){//opf.Is_Feature_Included__c
                    if(mapofOLIandIncludedFeature.containsKey(opf.Opportunity_Product_Cus__c)){
                        mapofOLIandIncludedFeature.get(opf.Opportunity_Product_Cus__c).add(opf.Configured_Product_Feature__c);
                    }else{
                        mapofOLIandIncludedFeature.put(opf.Opportunity_Product_Cus__c,new List<Id>{opf.Configured_Product_Feature__c});
                    }
                    mapOfOLIFeatureIAndConfig.put(opf.Opportunity_Product_Cus__c+'_'+opf.Configured_Product_Feature__c,opf);
                }
                
                if(opf.Specification_Option_Code__c == null  && opf.Is_Specification_Parameter_Included__c){
                    if(mapofOLIandIncludedParameter.containsKey(opf.Opportunity_Product_Cus__c)){
                        mapofOLIandIncludedParameter.get(opf.Opportunity_Product_Cus__c).add(opf.Product_Specificaiton_Parameter__c);
                    }else{
                        mapofOLIandIncludedParameter.put(opf.Opportunity_Product_Cus__c,new List<Id>{opf.Product_Specificaiton_Parameter__c});
                    }
                    
                    if(mapOfOLIParameterAndConfig.containsKey(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c)){
                        mapOfOLIParameterAndConfig.get(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c).add(opf.Id);
                    }else{
                        mapOfOLIParameterAndConfig.put(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c,new List<Id>{opf.ID});
                    }
                }
                // Sp included by default marked as false
                if(!opf.Is_Specification_Parameter_Included__c && opf.Specification_Option_Code__c == null ){
                    mapofOLIandIncludedByDefaultSp.put(opf.Opportunity_Product_Cus__c+'_'+opf.Product_Specificaiton_Parameter__c, opf.Id);
                }
                
                paramIds.add(opf.Product_Specificaiton_Parameter__c);
                if(!mapofOliallPramEmptyOptions.containsKey(opf.Opportunity_Product_Cus__c)){
                    Map<Id,Id> tempmapofEmptyspecPram = new Map<Id,Id>();
                    mapofOliallPramEmptyOptions.put(opf.Opportunity_Product_Cus__c,tempmapofEmptyspecPram);
                }
                Map<Id,Id> mapProdEmptyOptionValues = mapofOliallPramEmptyOptions.get(opf.Opportunity_Product_Cus__c);
                if(!mapProdEmptyOptionValues.containsKey(opf.Product_Specificaiton_Parameter__c)){
                    mapProdEmptyOptionValues.put(opf.Product_Specificaiton_Parameter__c,opf.Id);
                }   
            }
            
            List<Opportunity_Product_Configuration__c> lstOpptyFeatures = new List<Opportunity_Product_Configuration__c>();
            system.debug('featureList---'+featureList);
            set<Id> oppconfIds = new set<Id>();
            Map<Id,List<Id>> mapOfExcludedFeature = new Map<Id,List<Id>>();
            Map<Id,List<Id>> mapOfExcludedParameter = new Map<Id,List<Id>>();
            for (prodfeatureWrapper fe : featureList){
                
                if((fe.IsToggleChecked != null && fe.IsToggleChecked ) || ( fe.Included != null  && fe.Included ) || (fe.isDefaultIncluded != null && fe.isDefaultIncluded)){ // Check for Feature and SP Included
                    
                    Opportunity_Product_Configuration__c oppFeaturesConfig = new Opportunity_Product_Configuration__c();
                    
                    if(fe.isDefaultIncluded != null && fe.isDefaultIncluded ){
                        oppFeaturesConfig =  getCreateOppProdConfigurationFeature(fe.Name,fe.compId,fe.featureId,fe.IsToggleChecked);
                        System.debug('oppFeaturesConfigtest '+oppFeaturesConfig);
                    }else{
                        oppFeaturesConfig =  getCreateOppProdConfigurationFeature(fe.Name,fe.compId,fe.featureId,true);
                        System.debug('oppFeaturesConfigtest '+oppFeaturesConfig);
                    }
                    
                    
                    if(cloneMode){
                        oppFeaturesConfig.Opportunity_Product_Cus__c = cloneOLIRecId;
                    }else if (editMode == true){
                        oppFeaturesConfig.Opportunity_Product_Cus__c = fe.oliId; // if(mapOfOLIFeatureIAndConfig.get(oliId+'_'+featureId).Id)
                        if(mapofOLIandIncludedFeature.containsKey(fe.oliId) && mapofOLIandIncludedFeature.get(fe.oliId).contains(fe.featureId)){
                            oppFeaturesConfig.Id = mapOfOLIFeatureIAndConfig.get(fe.oliId+'_'+fe.featureId).Id;
                        }
                    }
                    else {
                        oppFeaturesConfig.Opportunity_Product_Cus__c = keyToOliMap.get(fe.key).Id; 
                    }
                    lstOpptyFeatures.add(oppFeaturesConfig); 
                    for (featureWrapper f : fe.featureWrapperlist){
                        
                        if((f.IsToggleChecked != null && f.IsToggleChecked ) || ( f.Included != null  && f.Included )){
                            if (f.isTypeMultiPicklist == true  ){ 
                                if(f.multiSelectDefault.IsEmpty() ){
                                    if(!paramIds.contains(f.specParamId) || (f.isDefaultIncluded != null && f.isDefaultIncluded) && (f.IsToggleChecked != null && f.IsToggleChecked )){
                                        if(!f.specParmIdset.contains(f.specParamId)){
                                            Opportunity_Product_Configuration__c oppFeatures = getCreateOppProdConfiguration(f.Name,null,f.specParamId,f.compId,f.featureId,true,true);
                                            if(cloneMode){
                                                oppFeatures.Opportunity_Product_Cus__c = cloneOLIRecId;
                                            }else if (editMode == true){
                                                oppFeatures.Opportunity_Product_Cus__c = f.oliId;
                                                if(mapofOLIandIncludedByDefaultSp.containsKey(f.oliId+'_'+f.specParamId)){
                                                    oppFeatures.Id = mapofOLIandIncludedByDefaultSp.get(f.oliId+'_'+f.specParamId);
                                                }else if(mapofOliallPramEmptyOptions.containskey(f.oliId) && mapofOliallPramEmptyOptions.get(f.oliId).containsKey(f.specParamId)){
                                                    oppconfIds.add(mapofOliallPramEmptyOptions.get(f.oliId).get(f.specParamId));
                                                }
                                            }
                                            else 
                                            {
                                                oppFeatures.Opportunity_Product_Cus__c = keyToOliMap.get(f.key).Id; 
                                            }
                                            lstOpptyFeatures.add(oppFeatures); 
                                        }
                                    }
                                }else{
                                    for(String optionval : f.multiSelectDefault){
                                        Opportunity_Product_Configuration__c oppFeatures = getCreateOppProdConfiguration(f.Name,f.speciOptionMap.get(optionval),f.specParamId,f.compId,f.featureId,true,true);
                                        if(cloneMode){
                                            oppFeatures.Opportunity_Product_Cus__c=cloneOLIRecId;
                                        }else if (editMode == true){
                                            oppFeatures.Opportunity_Product_Cus__c = f.oliId;
                                            if(mapofOliallPramOptions.containskey(f.oliId) && mapofOliallPramOptions.get(f.oliId).containsKey(f.specParamId)){
                                                if(mapofOliallPramOptions.get(f.oliId).get(f.specParamId).containsKey(optionval)){
                                                    oppFeatures.Id = mapofOliallPramOptions.get(f.oliId).get(f.specParamId).get(optionval);
                                                }
                                            }
                                            
                                            if(!mapofOliallPramEmptyOptions.isEmpty()){
                                                if(mapofOliallPramEmptyOptions.containskey(f.oliId) && mapofOliallPramEmptyOptions.get(f.oliId).containsKey(f.specParamId)){
                                                    oppconfIds.add(mapofOliallPramEmptyOptions.get(f.oliId).get(f.specParamId));
                                                } 
                                            }
                                            
                                        }
                                        else {
                                            oppFeatures.Opportunity_Product_Cus__c = keyToOliMap.get(f.key).Id; 
                                        }
                                        lstOpptyFeatures.add(oppFeatures);
                                        
                                    }
                                }
                                
                                if(!f.selectedspeciOptionMap.isEmpty()){
                                    for(String optionval : f.selectedspeciOptionMap.Keyset()){
                                        //if((!f.multiSelectDefault.contains(optionval) && !f.multiSelectDefault.IsEmpty()) || f.multiSelectDefault.IsEmpty()){
                                        if((!f.multiSelectDefault.contains(optionval) && !f.multiSelectDefault.IsEmpty()) || f.multiSelectDefault.IsEmpty()){
                                            if(mapofOliallPramOptions.containsKey(f.oliId) && !mapofOliallPramOptions.get(f.oliId).isEmpty() && mapofOliallPramOptions.get(f.oliId).containsKey(f.specParamId) && mapofOliallPramOptions.get(f.oliId).get(f.specParamId).containsKey(optionval)){
                                                oppconfIds.add(mapofOliallPramOptions.get(f.oliId).get(f.specParamId).get(optionval));
                                            } 
                                            if ( (editMode == true && f.multiSelectDefault.IsEmpty()) || ( cloneCountryRowProducts == true && f.multiSelectDefault.IsEmpty() )){
                                                Opportunity_Product_Configuration__c oppFeatures = getCreateOppProdConfiguration(f.Name,null,f.specParamId,f.compId,f.featureId,true, true);
                                                oppFeatures.Opportunity_Product_Cus__c = cloneCountryRowProducts && f.multiSelectDefault.IsEmpty() ?  keyToOliMap.get(f.key).Id : f.oliId;
                                                lstOpptyFeatures.add(oppFeatures);
                                            }     
                                        }
                                    }
                                }
                                
                                if(cloneCountryRowProducts == true && f.multiSelectDefault.IsEmpty()){
                                    Opportunity_Product_Configuration__c oppFeatures = getCreateOppProdConfiguration(f.Name,null,f.specParamId,f.compId,f.featureId,true, true);
                                    oppFeatures.Opportunity_Product_Cus__c = cloneCountryRowProducts && f.multiSelectDefault.IsEmpty() ?  keyToOliMap.get(f.key).Id : f.oliId;
                                    lstOpptyFeatures.add(oppFeatures);
                                }
                            } else if( f.isTypeInformation == null || !f.isTypeInformation ) {
                                
                                Opportunity_Product_Configuration__c oppFeatureRec;
                                
                                if(!String.isBlank(f.defaultValue)){
                                    oppFeatureRec = getCreateOppProdConfiguration(f.Name,f.speciOptionMap.get(f.defaultValue),f.specParamId,f.compId,f.featureId,true, true);
                                }else{
                                    if(!paramIds.contains(f.specParamId) || (f.isDefaultIncluded != null && f.isDefaultIncluded) && (f.IsToggleChecked != null && f.IsToggleChecked )){
                                        oppFeatureRec = getCreateOppProdConfiguration(f.Name,null,f.specParamId,f.compId,f.featureId,true, true);
                                    }
                                } 
                                
                                
                                //SFSE-9336
                                if(cloneMode){
                                    oppFeatureRec.Opportunity_Product_Cus__c=cloneOLIRecId;
                                }
                                else if (editMode == true){
                                    system.debug('PICKLIST-->'+f.defaultValue+'--Previousvalue--'+f.singlePicklistValue);
                                    if(oppFeatureRec!=null){
                                        oppFeatureRec.Opportunity_Product_Cus__c = f.oliId;
                                        if(!String.isBlank(f.defaultValue)){
                                            if(mapofOliallPramOptions.containskey(f.oliId) && mapofOliallPramOptions.get(f.oliId).containsKey(f.specParamId)){
                                                if(mapofOliallPramOptions.get(f.oliId).get(f.specParamId).containsKey(f.singlePicklistValue)){
                                                    oppFeatureRec.Id = mapofOliallPramOptions.get(f.oliId).get(f.specParamId).get(f.singlePicklistValue);
                                                }
                                            }else if(mapofOliallPramEmptyOptions.containskey(f.oliId) && mapofOliallPramEmptyOptions.get(f.oliId).containsKey(f.specParamId)){
                                                oppFeatureRec.Id = mapofOliallPramEmptyOptions.get(f.oliId).get(f.specParamId);
                                            }
                                        }else{
                                            if(mapofOliallPramEmptyOptions.containskey(f.oliId) && mapofOliallPramEmptyOptions.get(f.oliId).containsKey(f.specParamId)){
                                                oppFeatureRec.Id = mapofOliallPramEmptyOptions.get(f.oliId).get(f.specParamId);
                                            }
                                        }
                                        if(mapofOLIandIncludedByDefaultSp.containsKey(f.oliId+'_'+f.specParamId)){
                                            oppFeatureRec.Id = mapofOLIandIncludedByDefaultSp.get(f.oliId+'_'+f.specParamId);
                                        }
                                    }
                                } 
                                else {
                                    oppFeatureRec.Opportunity_Product_Cus__c = keyToOliMap.get(f.key).Id; 
                                }
                                if(oppFeatureRec!=null){
                                    lstOpptyFeatures.add(oppFeatureRec);
                                }
                            }
                        }else if((f.IsToggleChecked != null && !f.IsToggleChecked )){
                            if(editMode == true){
                                if(mapOfExcludedParameter.containsKey(f.oliId)){
                                    mapOfExcludedParameter.get(f.oliId).add(f.specParamId);
                                }else{
                                    mapOfExcludedParameter.put(f.oliId,new List<Id>{f.specParamId});
                                }
                            }
                        }
                        
                        if((f.isDefaultIncluded != null && f.isDefaultIncluded) && (f.IsToggleChecked != null && !f.IsToggleChecked ) && (f.isTypeInformation == null || !f.isTypeInformation)){
                            Opportunity_Product_Configuration__c oppFeatures = getCreateOppProdConfiguration(f.Name,null,f.specParamId,f.compId,f.featureId,false,false);
                            if(cloneMode){
                                oppFeatures.Opportunity_Product_Cus__c = cloneOLIRecId;
                            }else if (editMode == true){
                                oppFeatures.Opportunity_Product_Cus__c = f.oliId;
                                if(mapofOLIandIncludedByDefaultSp.containsKey(f.oliId+'_'+f.specParamId)){
                                    oppFeatures.Id = mapofOLIandIncludedByDefaultSp.get(f.oliId+'_'+f.specParamId);
                                }
                            } 
                            else {
                                oppFeatures.Opportunity_Product_Cus__c = keyToOliMap.get(f.key).Id; 
                            }
                            lstOpptyFeatures.add(oppFeatures); 
                        }
                    }
                }else if((fe.IsToggleChecked != null && !fe.IsToggleChecked ) ){ // Check for feature which are excluded 
                    if(editMode == true){
                        if(mapOfExcludedFeature.containsKey(fe.oliId)){
                            mapOfExcludedFeature.get(fe.oliId).add(fe.featureId);
                        }else{
                            mapOfExcludedFeature.put(fe.oliId,new List<Id>{fe.featureId});
                        }
                        for (featureWrapper f : fe.featureWrapperlist){
                            if( (f.IsToggleChecked != null && !f.IsToggleChecked) ){
                                if(mapOfExcludedParameter.containsKey(f.oliId)){
                                    mapOfExcludedParameter.get(f.oliId).add(f.specParamId);
                                }else{
                                    mapOfExcludedParameter.put(f.oliId,new List<Id>{f.specParamId});
                                }
                            }
                        }
                    }
                }
            }
            
            if(!mapOfExcludedFeature.keySet().isEmpty() && !mapofOLIandIncludedFeature.keySet().isEmpty()){
                
                for(Id oliId :mapofOLIandIncludedFeature.keySet()){
                    if(mapOfExcludedFeature.containsKey(oliId)){
                        for(Id featureId: mapofOLIandIncludedFeature.get(oliId)){
                            if(mapOfExcludedFeature.get(oliId).contains(featureId)){
                                oppconfIds.add(mapOfOLIFeatureIAndConfig.get(oliId+'_'+featureId).Id);
                            }
                        }
                    }
                }
            }
            
            if(!mapOfExcludedParameter.keySet().isEmpty() && !mapofOLIandIncludedParameter.keySet().isEmpty() ){
                for(Id oliId : mapofOLIandIncludedParameter.keySet()){
                    if(mapOfExcludedParameter.containsKey(oliId)){
                        for(Id parameterId: mapofOLIandIncludedParameter.get(oliId)){
                            if(mapOfExcludedParameter.get(oliId).contains(parameterId)){
                                oppconfIds.addAll(mapOfOLIParameterAndConfig.get(oliId+'_'+parameterId));
                            }
                        }
                    }
                }
            }
            
            
            system.debug('deleteoppconfIds'+oppconfIds);
            
            deleteOppProdConfiguration(oppconfIds);
            system.debug(lstOpptyFeatures);
            set<Opportunity_Product_Configuration__c> setOpptyFeatures = new set<Opportunity_Product_Configuration__c>();
            setOpptyFeatures.addAll(lstOpptyFeatures);
            List<Opportunity_Product_Configuration__c> oppconflist = new list<Opportunity_Product_Configuration__c>();
            oppconflist.addAll(setOpptyFeatures);
            
            List<Database.upsertResult> uResults = database.upsert(oppconflist, false);
            
            for(Integer i=0; i< uResults.size();i++){
                if (! uResults[i].isSuccess()) {
                    
                    for(Database.Error err : uResults[i].getErrors()) {
                        returnMessage = err.getStatusCode() + ': ' + err.getMessage();
                    }
                }
            }
        }
        catch(DmlException e) {
            system.debug('@@@@@ ' + e);
            system.debug('errorinconfig ' + e);
            returnMessage = '';
            for(Integer i=0; i < e.getNumDml(); i++) {
                returnMessage = returnMessage + e.getDmlMessage(i).unescapeHtml4() + '; ';
            }
        }
        if(cloneCountryRowProducts) {
            postOnChatter(returnMessage);
        }
        return  returnMessage;
    }    
    
    @AuraEnabled(cacheable = false)
    public static void postOnChatter(string returnMessage) {
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        if (returnMessage =='success'){
            textSegmentInput.text = 'Your product with multiple corridors was cloned successfully';
        }else{
            textSegmentInput.text = 'Your product with multiple corridors could not be cloned due to technical issue. Please try again later ';
        }
        
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        string userId = UserInfo.getUserId(); 
        feedItemInput.subjectId = userId;
        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }
    }
    
    
    /***SFSE:9819 : Modified below method to display products in opportunity page and grey out the 'Report as Closed Lost' button in OIPC screen when the opportunity has been submitted to PEP***/
    @AuraEnabled
    public static productListANDPendingApprovals getRecords(String recId){
        
        productListANDPendingApprovals prodListwrapper = new productListANDPendingApprovals();
        Set<Id> opptyHasPendingApprovalProcesses =  new set<Id>();
        
        //query to get all pending approval processes related to Opportunity
        Map<Id, Opportunity> mapOfOpportunities = new Map<Id, Opportunity>([select Id, StageName, RecordTypeId, Must_Go_To_OMEB__c from Opportunity where Id =:recId]); 
        if(!mapOfOpportunities.isEmpty() && recId != null){
            opptyHasPendingApprovalProcesses = OppLineItemRecordSelector.getPendingApprovalProcesses(mapOfOpportunities);
        }
        
        List<Opportunity_Product__c> optyLineItemList = [Select Id, Definition_Type__c, Solution__c, Solution__r.Name,Solution__r.Latest_Product_Version__c, Solution__r.Latest_Product_Version__r.isActive,Solution__r.isActive, Amend_Gross_Profit_per_unit__c, Name,Product2Id__c,Product2ID__r.Name,Quantity__c,UnitPrice__c
                                                         , Country__r.Name, Executing_City_State__r.Name, Trade_Route__r.Name, OpportunityId__r.IsClosed, Product2ID__r.Include_in_OMEB_Approvals__c,
                                                         OpportunityId__r.StageName, Total_Price__c,OpportunityId__c, OpportunityId__r.Must_Go_To_OMEB__c,Product2Id__r.isActive,Product2ID__r.Type_of_Location_Needed__c
                                                         ,Product2Id__r.Latest_Product_Version__c,Product2Id__r.End_of_Sales__c,Product2Id__r.End_of_Service__c, Product2Id__r.Latest_Product_Version__r.isActive ,Product2Id__r.Product_Status__c,Product2Id__r.Latest_Product_Version__r.Product_Status__c,Product2Id__r.Latest_Product_Version__r.End_of_Sales__c,Product2Id__r.Latest_Product_Version__r.End_of_Service__c
                                                         from Opportunity_Product__c where OpportunityId__c =: recId];
        
        prodListwrapper.opptyHasPendingApprovalProcesses = opptyHasPendingApprovalProcesses;
        prodListwrapper.oliRecList  = optyLineItemList;
        
        user currentUser = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                            street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                            FROM User
                            WHERE id = :UserInfo.getUserId()];
        prodListwrapper.userlocale= currentUser.localesidkey;
        
        return prodListwrapper;
    }
    
    @AuraEnabled //SFSE-15064 
    public static string deleteRecord(String oli, String solutionId, String opptyId){
        Boolean validationRuleBypass = false;
        List<Opportunity_Product__c> oliListToDelete = new List<Opportunity_Product__c>();
        List<Opportunity_Product_Configuration__c> lstOliConfigs = new List<Opportunity_Product_Configuration__c>();
        if(oli != null && oli != ''){
            oliListToDelete = [Select Id, Name,Definition_Type__c,OpportunityId__r.Count_Opp_Product__c,OpportunityId__r.isClosed,Product2ID__r.IsActive,Product2ID__r.Product_Status__c FROM Opportunity_Product__c WHERE id =:oli ];
            lstOliConfigs = [Select ID, Opportunity_Product_Cus__c, Name FROM Opportunity_Product_Configuration__c WHERE Opportunity_Product_Cus__c = :oli];
        }
        if(solutionId != '' && solutionId != null){
            oliListToDelete = [Select id, Name,Definition_Type__c,OpportunityId__r.Count_Opp_Product__c,OpportunityId__r.isClosed,Product2ID__r.IsActive,Product2ID__r.Product_Status__c FROM Opportunity_Product__c WHERE Solution__c =:solutionId AND OpportunityId__c = :opptyId];
      lstOliConfigs = [Select ID, Opportunity_Product_Cus__c, Name FROM Opportunity_Product_Configuration__c WHERE Opportunity_Product_Cus__c IN :oliListToDelete];
        }
        
        Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
        bt.Skip_Validation__c = true;
        insert bt;
        
        Validation_Rules_Bypass__c bypass = Validation_Rules_Bypass__c.getInstance();

           if(!oliListToDelete.isEmpty()){
                if(oliListToDelete[0].Definition_Type__c == 'Product' && oliListToDelete[0].OpportunityId__r.Count_Opp_Product__c > 1 && oliListToDelete[0].OpportunityId__r.isClosed == false 
                   && oliListToDelete[0].Product2ID__r.IsActive == false  && oliListToDelete[0].Product2ID__r.Product_Status__c == 'End of Sales'){
                    validationRuleBypass = true;
                }
          }
        
        if(validationRuleBypass){         
            bypass.Active__c = true;
            insert bypass;
        }
       
        if(!lstOliConfigs.isEmpty()){
            delete lstOliConfigs;
        }
        if(oliListToDelete.size() > 0){
            delete oliListToDelete;
        }

        Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
        delete btt;
        if(validationRuleBypass){
            Validation_Rules_Bypass__c bypassDelete = Validation_Rules_Bypass__c.getInstance();
            delete bypassDelete;
        } 
        return 'success';    
    }
    
    @AuraEnabled
    public static UserRecordAccess getRecordAccessLevel(String recordId){
        return [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND  RecordId = :recordId ];
    }
    
    @AuraEnabled
    public static string getuserlocale(){
        String returnMessage = '';
        String currentUserId = UserInfo.getUserId();
        user currentUser = [SELECT id, localesidkey FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];   
        returnMessage=   currentUser.localesidkey;
        return returnMessage;
        
    }
    
    public class featureCountResponse {
        @AuraEnabled public Boolean showBar{get;set;}
        @AuraEnabled public Decimal avg{get;set;}
        public featureCountResponse(){
            showBar = false;
            avg = 0;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static featureCountResponse getTotalFeatureNumber(String oppId){
        Decimal avg = 0;
        Decimal nCount = 0;
        Decimal nTotalCount = 0;
        featureCountResponse fcr = new featureCountResponse();
        Map<String, String> totalToavNumMap = new Map<String, String>();
        for (AggregateResult agg : [Select sum(Count_of_Total_Configuration_not_filled__c) totalnotfilled, sum(Count_Of_Total_Mandatory_Configuration__c) totalfeature from Opportunity where 
                                    Id =:oppId GROUP BY Id]) {
                                        nCount = (Decimal)agg.get('totalnotfilled');
                                        nTotalCount = (Decimal)agg.get('totalfeature');
                                        if(nCount !=null && nTotalCount !=null && nTotalCount > 0) {
                                            avg= 100 - (nCount/nTotalCount) * 100;
                                            fcr.avg = avg.round();
                                        }
                                        if(nTotalCount > 0){
                                            fcr.showBar = true;
                                            
                                        }
                                    }     
        system.debug('@@@@ ' + avg);
        return fcr;
    } 
    
    /***SFSE : 9819 STARTS HERE***/
    public class productListANDPendingApprovals{
        @AuraEnabled public  Set<Id> opptyHasPendingApprovalProcesses       {get; set;}   
        @AuraEnabled public  List<Opportunity_Product__c> oliRecList           {get; set;}
        @AuraEnabled public  string userlocale           {get; set;}
        
    }
    
    /***SFSE:9819 : Below method is used to clone the product and corresponding opportunity when user click on Report as closed Lost button on OIPC Screen***/
    @AuraEnabled //SFSE-15064 
    public static string cloneAsClosedLostOptyproduct(Id opportunityId, Id oLIId, string closedLostReason){
        Boolean validationRuleBypass = false;
        string returnMsg;
        Opportunity OptyCloneRec = new Opportunity();
        Opportunity_Product__c optyLineItemCloneRec = new Opportunity_Product__c();
        
        Id optyShippingCargoRecId = StaticFactory.getRecordTypeIdByDevName('Opportunity', Label.OppShippingCargoRecordType);
        Id optySupplychainRecId = StaticFactory.getRecordTypeIdByDevName('Opportunity', Label.OppSupplyChainServicesRecType);
        
        string optyQuery = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Opportunity());
        optyQuery = 'Select ' + optyQuery + ' from Opportunity';
        optyQuery = optyQuery + ' WHERE id =\'' + opportunityId + '\' limit 1';
        List<Opportunity> optyRecList = Database.query(optyQuery);
        
        string optyLineItemQuery = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Opportunity_Product__c());
        optyLineItemQuery = 'Select ' + optyLineItemQuery + ' ,Product2ID__r.Name from Opportunity_Product__c';
        optyLineItemQuery =  optyLineItemQuery.remove('TotalPrice,');//to do 
        //optyLineItemQuery =  optyLineItemQuery.remove('Total_Price__c,');
        optyLineItemQuery =  optyLineItemQuery + ' WHERE id =\'' + oLIId + '\' limit 1';
        List<Opportunity_Product__c> oliRecList = Database.query(optyLineItemQuery);
        
        if(!oliRecList.isEmpty()){
            optyLineItemCloneRec = oliRecList[0].clone(false,false,false,false);
        }
        
        if(!optyRecList.isEmpty() && !oliRecList.isEmpty()){
            optyRecList[0].Name = 'Closed Lost - '+optyRecList[0].Name+ ' - '+ oliRecList[0].Product2ID__r.Name;
            optyRecList[0].StageName = 'Identifying';
            optyRecList[0].Record_Locked__c = true;
            
            if(optyRecList[0].RecordTypeId != optySupplychainRecId && string.isBlank(optyRecList[0].Opportunity_contains_Dangerous_Goods__c)){
                optyRecList[0].Opportunity_contains_Dangerous_Goods__c = 'No';
            }
            
            OptyCloneRec = optyRecList[0].clone(false,true,false,false);
            OptyCloneRec.Lost_Product_Parent_Opportunity__c = optyRecList[0].Id;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Validation_Rules_Bypass__c bypass = Validation_Rules_Bypass__c.getInstance();
            Bypass_Product_Upgrade_Validation__c bt= Bypass_Product_Upgrade_Validation__c.getInstance();
            bt.Skip_Validation__c = true;
            insert bt;
            if(OptyCloneRec != null){
                List<Opportunity_Product__c> oliToDelete = [select Id,Definition_Type__c,OpportunityId__r.Count_Opp_Product__c,OpportunityId__r.isClosed,Product2ID__r.IsActive,
                                                                    Product2ID__r.Product_Status__c from Opportunity_Product__c where Id=:oLIId];
                if(!oliToDelete.isEmpty()){
                                if(oliToDelete[0].Definition_Type__c == 'Product' && oliToDelete[0].OpportunityId__r.Count_Opp_Product__c > 1 && oliToDelete[0].OpportunityId__r.isClosed == false 
                   && oliToDelete[0].Product2ID__r.IsActive == false  && oliToDelete[0].Product2ID__r.Product_Status__c == 'End of Sales'){
                                    validationRuleBypass = true;
                                }
                            }
                if(validationRuleBypass){         
                                bypass.Active__c = true;
                                insert bypass;
                            }
                       
                TriggerExecutionController.skipAccountTrigger(true);
                TriggerExecutionController.skipOpportunitySplitTrigger(true);
                Database.SaveResult optyInsertresult = Database.insert(OptyCloneRec, false);
                TriggerExecutionController.skipAccountTrigger(false);
                TriggerExecutionController.skipOpportunitySplitTrigger(false);
                
                if (optyInsertresult.isSuccess()) {
                    if(optyLineItemCloneRec != null){
                        optyLineItemCloneRec.OpportunityId__c = OptyCloneRec.Id;
                        try{
                            TriggerExecutionController.skipOpportunityProductSchedule(true);
                            TriggerExecutionController.skipOpportunityTrigger(true);
                            insert optyLineItemCloneRec;
                            TriggerExecutionController.skipOpportunityTrigger(false);
                            TriggerExecutionController.skipOpportunityProductSchedule(false);
                        }catch(DmlException ex){
                            Database.RollBack(sp);
                            returnMsg = ex.getDmlMessage(0);
                        }
                    }
                     TriggerExecutionController.skipAllTriggers(true);
                    OptyCloneRec.stageName = 'Closed Lost';
                    OptyCloneRec.Reason_For_Close__c = closedLostReason;
                    OptyCloneRec.closeDate = system.today();
                    Database.SaveResult optyupdateresult = Database.update(OptyCloneRec, false); 
                    TriggerExecutionController.skipAllTriggers(false);   
                    if (optyupdateresult.isSuccess()) {
                        returnMsg = 'success';
                        /*List<Opportunity_Product__c> oliToDelete = [select Id,Definition_Type__c,OpportunityId__r.Count_Opp_Product__c,OpportunityId__r.isClosed,Product2ID__r.IsActive,
                                                                    Product2ID__r.Product_Status__c from Opportunity_Product__c where Id=:oLIId]; */
                        List<Opportunity_Product_Configuration__c> lstOliFeat = [Select ID, Opportunity_Product_Cus__c, Name from Opportunity_Product_Configuration__c
                                                                                 where Opportunity_Product_Cus__c = :oLIId];
                        try{
                            if(!lstOliFeat.isEmpty()){
                                delete lstOliFeat;
                            }
                            
                            if(!oliToDelete.isEmpty()){
                                TriggerExecutionController.skipOpportunityTrigger(true);
                                delete oliToDelete;
                                TriggerExecutionController.skipOpportunityTrigger(false);
                            }
                        }catch(DmlException ex){
                            Database.RollBack(sp);
                            returnMsg = ex.getDmlMessage(0);
                        }
                        
                    }else{
                        Database.RollBack(sp);
                        returnMsg = optyupdateresult.getErrors()[0].getMessage();
                    }
                }else{
                    returnMsg = optyInsertresult.getErrors()[0].getMessage();
                }
            }
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
          	delete btt;
            if(validationRuleBypass){
                Validation_Rules_Bypass__c bypassDelete = Validation_Rules_Bypass__c.getInstance();
            	delete bypassDelete;
            }
            
            
        } catch(DmlException e) {
            returnMsg = e.getDmlMessage(0);
            Bypass_Product_Upgrade_Validation__c btt= Bypass_Product_Upgrade_Validation__c.getInstance();
            delete btt;
            if(validationRuleBypass){
                    Validation_Rules_Bypass__c bypassDelete = Validation_Rules_Bypass__c.getInstance();
                    delete bypassDelete;
            }
        }
        return returnMsg;
    }
    
    
    /***SFSE:9819 ENDS HERE***/
    /***SFSE:10232 STARTS HERE***/
    @AuraEnabled
    //public static List<OpportunityLineItem> getClosedLostProducts(Id recId){
    public static List<Opportunity_Product__c> getClosedLostProducts(Id recId){
        List<Opportunity_Product__c> oliRecList = [Select Id,OpportunityId__c, OpportunityId__r.Name, Definition_Type__c, Product2ID__r.Name,Product2ID__r.Family, Quantity__c,Total_Price__c from Opportunity_Product__c where OpportunityId__r.Lost_Product_Parent_Opportunity__c =: recId];
        return oliRecList;
    }
    /***SFSE:10232 ENDS HERE***/
    
    //SFSE-9469 start
    public static Opportunity_Product_Configuration__c getCreateOppProdConfiguration(String pName,Id specOptionId,Id SpecParamId,Id compId,Id featureId, Boolean isFeatureIncluded, Boolean isParameterIncluded){
        
        Opportunity_Product_Configuration__c oppFeatures = new Opportunity_Product_Configuration__c();
        oppFeatures.Name = pName;
        oppFeatures.Product_Specification_Option__c = specOptionId;
        oppFeatures.Product_Specificaiton_Parameter__c = SpecParamId;
        oppFeatures.Is_Feature_Included__c= isFeatureIncluded;
        oppFeatures.Is_Specification_Parameter_Included__c = isParameterIncluded;
        oppFeatures.Configured_Product_Component__c= compId;
        oppFeatures.Configured_Product_Feature__c= featureId;
        return oppFeatures;
    }
    //SFSE-9469 end
    
    //SFSE-9469 start
    public static void deleteOppProdConfiguration(set<Id> specOptionId){
        List<Opportunity_Product_Configuration__c> oppProdConflist = [Select Id from Opportunity_Product_Configuration__c where  ID IN:specOptionId];
        system.debug('delete--oppProdConflist: ' +oppProdConflist);
        if(!oppProdConflist.isEmpty()){
            system.debug('delete--done: ');
            delete oppProdConflist;
        }
        system.debug('delete--end: ');
    }
    //SFSE-9469 end
    
    public static Opportunity_Product_Configuration__c getCreateOppProdConfigurationFeature(String pName,Id compId,Id featureId,boolean isFeature){
        
        Opportunity_Product_Configuration__c oppFeatureConfig = new Opportunity_Product_Configuration__c();
        oppFeatureConfig.Name = pName;
        oppFeatureConfig.Is_Feature_Included__c= isFeature;
        oppFeatureConfig.Configured_Product_Component__c= compId;
        oppFeatureConfig.Configured_Product_Feature__c= featureId;
        return oppFeatureConfig;
    }
    
    
    @AuraEnabled
    public static Boolean checkServieNoServieProduct(Id opportunityId, Id oliId){
        Boolean isNoSerivce = false;
        Map<Id,boolean> MapOppToValidateOLIflag = new Map<Id,boolean>();
        Map<Id,String> mapOfOldProductVersion = new Map<Id,String>();
        Map<Id,String> mapOfNewProductVersion = new Map<Id,String>();
        Map<Id,List<Id>> mapOfOpptyIdAndProductId = new  Map<Id,List<Id>>();
        Map<String,Boolean> mapOfProductVersionAndService = new Map<String,Boolean>();
        Map<Id, Opportunity_Product__c> mapExistingOLIs = new Map<Id, Opportunity_Product__c>();
        
        if(oliId == null) {
            mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT id, Product2ID__r.IsActive,Product2ID__r.OIPC_ProductCode_Version__c, Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c,OpportunityId__c  FROM Opportunity_Product__c WHERE OpportunityId__c = :opportunityId AND Product2ID__r.IsActive = false AND Product2ID__r.Latest_Product_Version__c!= null ]);  
        }else {
            mapExistingOLIs = new Map<Id, Opportunity_Product__c>([SELECT id, Product2ID__r.IsActive,Product2ID__r.OIPC_ProductCode_Version__c, Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c,OpportunityId__c  FROM Opportunity_Product__c WHERE Id = :oliId AND Product2ID__r.IsActive = false AND Product2ID__r.Latest_Product_Version__c!= null ]);  
        }
        
        
        for(Opportunity_Product__c prod:mapExistingOLIs.values()){
            if(!mapOfOldProductVersion.containsKey(prod.Id)){
                mapOfOldProductVersion.put(prod.Id, prod.Product2ID__r.OIPC_ProductCode_Version__c);
            }
            if(!mapOfNewProductVersion.containsKey(prod.Id)){
                mapOfNewProductVersion.put(prod.Id, prod.Product2ID__r.Latest_Product_Version__r.OIPC_ProductCode_Version__c );
            }   
            
            if(mapOfOpptyIdAndProductId.containsKey(prod.OpportunityId__c)){
                mapOfOpptyIdAndProductId.get(prod.OpportunityId__c).add(prod.Id);
            }else{
                mapOfOpptyIdAndProductId.put(prod.OpportunityId__c, new List<Id>{prod.Id});
            }
        }
        
        if(!mapOfOldProductVersion.values().isEmpty() && !mapOfNewProductVersion.values().isEmpty()){
            Set<String> lstOipcVersions= new Set<String>();
            lstOipcVersions.addAll(mapOfOldProductVersion.values());
            lstOipcVersions.addAll(mapOfNewProductVersion.values());
            if(!lstOipcVersions.isEmpty()){
                for(Product_Feature__c feat:[SELECT id,Default_Visibility__c, Categorisation__c,Product_Component__r.Product__r.OIPC_ProductCode_Version__c  FROM Product_Feature__c WHERE Product_Component__r.Product__r.OIPC_ProductCode_Version__c IN :lstOipcVersions 
                                             AND (Categorisation__c =: 'Service' OR Categorisation__c=:'')]){
                                                 
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
            System.debug(mapOfProductVersionAndService.keyset());
            System.debug(mapOfProductVersionAndService.values());
            System.debug(mapOfOpptyIdAndProductId.keyset());
            System.debug(mapOfOpptyIdAndProductId.values());
            system.debug(opportunityId);
            
            if(mapOfOpptyIdAndProductId.containsKey(opportunityId)){
                for(Id opptyProd: mapOfOpptyIdAndProductId.get(opportunityId)){
                    if(mapOfOldProductVersion.containsKey(opptyProd) && mapOfNewProductVersion.containsKey(opptyProd)){
                        if(mapOfProductVersionAndService.containsKey(mapOfOldProductVersion.get(opptyProd)) && mapOfProductVersionAndService.containsKey(mapOfNewProductVersion.get(opptyProd))){
                            System.debug('is noservice '+mapOfProductVersionAndService.get(mapOfOldProductVersion.get(opptyProd)) );
                            System.debug('is noservice '+mapOfProductVersionAndService.get(mapOfNewProductVersion.get(opptyProd)) );
                            if( !mapOfProductVersionAndService.get(mapOfOldProductVersion.get(opptyProd)) && mapOfProductVersionAndService.get(mapOfNewProductVersion.get(opptyProd))){
                                isNoSerivce = true;
                            }
                        }
                    }
                }
            }
            
        }
        
        System.debug('isNoSerivce'+ isNoSerivce);
        return isNoSerivce;
    }
    
    //SFSE-12881
    @AuraEnabled
    public static String checkOpptyProdCloneEligibility(Id opportunityProductId){
        String result;
        Opportunity_Product__c oppProd = [SELECT Id, Product2ID__r.Name, Product2ID__r.IsActive, Product2ID__r.Latest_Product_Version__c, Product2ID__r.Latest_Product_Version__r.IsActive FROM Opportunity_Product__c WHERE Id = :opportunityProductId];
        //cannot be cloned
        if(oppProd.Product2ID__r.IsActive == false && (oppProd.Product2ID__r.Latest_Product_Version__c == null || oppProd.Product2ID__r.Latest_Product_Version__r.IsActive == false)){
            result = oppProd.Product2ID__r.Name;
        }
        else{
            result = 'success';
        }
        return result;
    }
    
    @AuraEnabled
    public static ProductDefinition getExistingOpptyProdDefinition(Id opportunityId){
        ProductDefinition prod = new ProductDefinition();
        //SFSE-14494
        for(Opportunity_Product__c oppProd: [SELECT Id, Definition_Type__c FROM Opportunity_Product__c WHERE OpportunityId__c =: opportunityId]){
            if(oppProd.Definition_Type__c == 'Packaged Solution' ){
                prod.isPackageSolution = true;
            }else if(oppProd.Definition_Type__c == 'Integrated Solution'){
                prod.isIntegratedSolution = true;
            }else if(oppProd.Definition_Type__c == 'Product'){
                prod.isProduct = true;
            }
        }
        return prod;
    }
    
    @AuraEnabled
    public static String getCustomerJourneyFieldValue(Id opportunityId){
        String customerJourney;
        List<Opportunity> lstOppRec = [SELECT Id, Customer_Journey__c FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        if(!lstOppRec.isEmpty()){
            customerJourney = lstOppRec[0].Customer_Journey__c;
        }else{
            customerJourney = '';
        }
        return customerJourney;
    }
    
    @AuraEnabled
    public static Id getUnitedStatesRecordId(){
        Id USrecordId;
        USrecordId = Id.valueOf([Select id from Geography__c where GEO_ID__c =: System.Label.United_States_Country and Type_Of_Location__c = 'Country'][0].id);
        return USrecordId;
    }
    
    //SFSE-14494
    public class ProductDefinition {
        @AuraEnabled public Boolean isProduct {get; set;}
        @AuraEnabled public Boolean isPackageSolution {get; set;}
        @AuraEnabled public Boolean isIntegratedSolution {get; set;}
        @AuraEnabled public Boolean isAddOn {get; set;}
        
        public ProductDefinition(){
            isProduct = false;
            isPackageSolution = false;
            isIntegratedSolution = false;
            isAddOn = false;
        }
    }
    
    @AuraEnabled //Method to check if opportunity is closed or not 
    public static String getOpptyStage(Id opportunityId){
        String stage;
        List<Opportunity> lstOppRec = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        if(!lstOppRec.isEmpty()){
            stage = lstOppRec[0].StageName;
        }else{
            stage = '';
        }
        return stage;
    }

    @AuraEnabled //Method to get segment data of a product during Multi-line Clone SFSE-13634
    public static Map<Id, Map<Id,List<Segment_Data__c>>> getSegmentData(List<Id> lstProductIds){
        Map<Id, Map<Id,List<Segment_Data__c>>> MapofProdToSegmentData = new Map<Id, Map<Id,List<Segment_Data__c>>>();
        //form map of prod to map of country to segment data //SFSE-13634
        Map<Id,Id> mapProdToLatestVersion = new Map<Id,Id>();
        for(Product2 prod : [Select id,Latest_Product_Version__c from Product2 where Id in: lstProductIds]){
            if(prod.Latest_Product_Version__c != null){
                lstProductIds.add(prod.Latest_Product_Version__c);
                if(!mapProdToLatestVersion.containsKey(prod.Id)){
                    mapProdToLatestVersion.put(prod.Latest_Product_Version__c,prod.id);
                }
            }
        }
        List<Segment_Data__c> SegmentData = [select id,Country_Name__c, Product__r.id, Product__r.Name,Product__r.OIPC_Code__c,Product__r.Latest_Product_Version__c, Segmentation__r.Country__r.id, Default_GP_Margin__c, Default_GP_unit__c, Revenue_unit__c from Segment_Data__c where Product__r.IsActive =: true and Type__c =: 'Revenue' and Product__r.id in: lstProductIds];
        if(!SegmentData.isEmpty()){
            for(Segment_Data__c sgd : SegmentData){
                if(!MapofProdToSegmentData.containsKey(sgd.Product__r.id)){
                    MapofProdToSegmentData.put(sgd.Product__r.id, new Map<Id, List<Segment_Data__c>>());
                }
                
                Map<Id, List<Segment_Data__c>> innerMap = MapofProdToSegmentData.get(sgd.Product__r.id);
                
                if (!innerMap.containsKey(sgd.Segmentation__r.Country__r.id)) {
                    innerMap.put(sgd.Segmentation__r.Country__r.id, new List<Segment_Data__c>());
                }
                innerMap.get(sgd.Segmentation__r.Country__r.id).add(sgd);
            }
        }
        for(Id prodid : MapofProdToSegmentData.keyset()){
            if(mapProdToLatestVersion.containsKey(prodid)){
                MapofProdToSegmentData.put(mapProdToLatestVersion.get(prodid),MapofProdToSegmentData.get(prodid));
            }
        }
        return MapofProdToSegmentData;
    }
    
}