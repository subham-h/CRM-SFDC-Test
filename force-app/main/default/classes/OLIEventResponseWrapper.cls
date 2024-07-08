/*   
* Test Class:-OLIEventResponseWrapper_Test               
* Revision Date        Owner                	    Description
* -------- ----------  -----------				    -----------
* 1.0      28-03-23  Samarpreet.singh@maersk.com    Wrapper class used in "Publish OLI Event" flows.
* 2.0      26-05-23  Samarpreet.singh@maersk.com    Added logic to read from new Custom OBject for prodcut and Schedule
* 3.0 	   06-10-23	 Aditi.Srivastava@maersk.com	Added currencyCode, totalProductGrossProfit
* 3.0      12-3-24   Samar@maersk.com			    deactivate V3 and Adding V5 event logic
*/
public without sharing class OLIEventResponseWrapper {
    public static Map<Id,Boolean> mapOfOliandDeletion= new Map<Id,Boolean>();
    public static Map<Id,LineItemMessage> mapOfOLiIdAndWrapper = new map<Id, LineItemMessage>();
    public static Map<Id,Message> mapOfOLiAndWrapper = new map<Id, Message>();
    public static Map<ID,List<OpportunityLineItemSchedules_z>> mapOliIdandSchedules = new Map<Id,List<OpportunityLineItemSchedules_z>>();
    public static Map<Id,List<SelectedProductConfiguration>> mapOliIdandConfig= new Map<Id,List<SelectedProductConfiguration>>();
    public static Map<Id,String> mapOliIdandReference= new Map<Id,String>();

    // Used in V3
    public class opportunityProduct {
        public header header;
        public message message;
        public string topic;
        public string key;
        
        public opportunityProduct(header header, message message, string topic,string key) {
            this.header = header;
            this.message = message;
            this.topic = topic;
            this.key = key;
        }
    }
    // Used in V2
    public class OpportunityProductData {
        public header header;
        public LineItemMessage message;
        public string topic;
        public string key;
        
        public OpportunityProductData(header header, LineItemMessage message, string topic,string key) {
            this.header = header;
            this.message = message;
            this.topic = topic;
            this.key = key;
        }
    }
    
    public class header{
        public string eventNotificationName;
        public string version;
        public string systemz;
        public string messageId;
        public long eventTimestamp;
        public header(){
            eventNotificationName = '';
            version = '';
            systemz = '';
            messageId = '';
            eventTimestamp = 0;
        }
    }
    
    //Used in V3 Evenst
    public Static header getheaderWrapper(String evtId){
        Datetime dt = Datetime.now();
        header pRec = new header();
        pRec.eventNotificationName = 'live';
        pRec.version = '3.0.0';
        pRec.systemz = 'sfdc';
        pRec.messageId = evtId !=null ? evtId : String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        return pRec;
    }


    //Used in V2 event
    public Static header getheader(String evtId){
        Datetime dt = Datetime.now();
        header pRec = new header();
        pRec.eventNotificationName = 'live';
        pRec.version = '2.0.0';
        pRec.systemz = 'sfdc';
        pRec.messageId = evtId !=null ? evtId : String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        return pRec;
    }
    
   
    // Wrapper used in V2 Events
    public class LineItemMessage {
        public Oppty opportunity{get;set;} 
        public String lineItemId {get;set;} 
        public String lineItemName {get;set;} 
        public Decimal lineItemQuantity {get;set;} 
        public Decimal grossProfit {get; set;}
        public Boolean isLineItemDeleted {get;set;} 
        public List<Location> locations {get;set;} 
        public String cargoTypeCode {get;set;} 
        public String specialCargo {get;set;} 
        public String transportActivity {get;set;} 
        public Route route {get;set;} 
        public String isoCurrencyCode {get;set;}
        public SelectedProduct selectedProduct {get;set;} 
        public List<SelectedProductConfiguration> selectedProductConfigurations{get;set;} 
        public List<OpportunityLineItemSchedules_z> opportunityLineItemSchedules {get;set;}
        
        public LineItemMessage() {
            opportunity = new Oppty();
            opportunityLineItemSchedules = new List<OpportunityLineItemSchedules_z>();
            locations = new List<Location>();
            Route = new Route();
            isLineItemDeleted= false;
            selectedProductConfigurations= new List<SelectedProductConfiguration>();
            selectedProduct= new SelectedProduct();
        }
    }
    
    public class Oppty{
        public String opportunityId {get;set;} 
        public String opportunityNumber {get;set;} 
        public String opportunityStage {get;set;} 
    }
    
    public class SelectedProduct {
        public Product product{get;set;} 
        public SelectedProduct(){
            product= new Product();
        }
    }
    
    public class Product{
        public String productCode {get;set;} 
        public String productName {get;set;} 
        public String productVersion {get;set;}
        public ProductFamily productFamily {get;set;}
        public Product(){
            productFamily= new productFamily();
        }
    }
    
    public class ProductFamily{
        public String productFamilyCode {get;set;} 
        public String productFamilyName {get;set;} 
        public String productPortfolio {get;set;} 
    }
    
    public class SelectedProductConfiguration{
        public ProductConfiguration productConfiguration{get;set;} 
        public List<ProductConfigOption> productConfigurationOptions{get;set;} 
        public SelectedProductConfiguration(){
            productConfigurationOptions = new List<ProductConfigOption>();
            productConfiguration = new ProductConfiguration();
        }
    }
    
    public class ProductConfiguration{
        public ProductElement productElement {get;set;} 
        public String attributeName {get;set;} 
        public ProductConfiguration(){
            productElement = new ProductElement();
            attributeName='';
        }
    }
    
    public class ProductElement{
        public String productElementType {get;set;} 
        public String productElementCode {get;set;} 
        public ProductElement(){
            productElementType ='';
            productElementCode ='';
        }
    }
    
    public class ProductConfigOption{
        public String productConfigurationOptionCode {get;set;}  
        public ProductConfigOption(){
            productConfigurationOptionCode ='';
        }
    }
    
    public class OpportunityLineItemSchedules_z {
        public String lineItemScheduleId {get;set;} 
        public long lineItemScheduleDate {get;set;} 
        public Decimal lineItemScheduleQuantity {get;set;} 
        public Decimal lineItemScheduleAmount {get;set;} 
        public String lineItemScheduleDescription {get;set;} 
    }

    public class Location {
        public String locationCode {get;set;} 
        public String locationFunction {get;set;} 
    }
    
    public class Route {
        public String routeCode {get;set;} 
        public String cardinalDirection {get;set;} 
        public String routeName {get;set;} 
    }
    
    

    // Wrapper used in V3 Events
    public class Message {
        public Oppty opportunity{get;set;} 
        public String lineItemId {get;set;} 
        public String lineItemName {get;set;} 
        public Decimal lineItemQuantity {get;set;} 
        public Decimal grossProfit {get; set;}
        public Boolean isProductDeleted {get;set;} 
        public List<Location> locations {get;set;} 
        public String cargoTypeCode {get;set;} 
        public String specialCargo {get;set;} 
        public String transportActivity {get;set;} 
        public Route route {get;set;} 
        public String isoCurrencyCode {get;set;}
        public SelectedProduct_z selectedProduct {get;set;} 
        public List<SelectedProductConfiguration> selectedProductConfigurations{get;set;} 
        public List<OpportunityLineItemSchedules_z> opportunityLineItemSchedules {get;set;}
        
        public Message() {
            opportunity = new Oppty();
            opportunityLineItemSchedules = new List<OpportunityLineItemSchedules_z>();
            locations = new List<Location>();
            Route = new Route();
            isProductDeleted= false;
            selectedProductConfigurations= new List<SelectedProductConfiguration>();
            selectedProduct= new SelectedProduct_z();
        }
    }

    public class SelectedProduct_z {
        public Product_z product{get;set;} 
        public SelectedProduct_z(){
            product= new Product_z();
        }
    }
    
    public class Product_z{
        public String productCode {get;set;} 
        public String productName {get;set;} 
        public String productVersion {get;set;}
        public Boolean isAddon {get;set;}
        public Boolean isProductSolution {get;set;}
        public List<ProductGroups> productGroups {get;set;}
        public List<SoftCodedValues> softCodedValues {get;set;}
        public solution solution{get;set;}
    }

    public class ProductGroups{
        public String productGroupCode {get;set;} 
        public String productGroupLevelLabel {get;set;} 
        public String productGroupName {get;set;}
    }

    public class SoftCodedValues{
        public String entityName {get;set;} 
        public String attributeName {get;set;} 
        public String value {get;set;}
    }

    
    public class solution{
        public String solutionCode {get;set;} 
        public String solutionName {get;set;} 
        public String solutionVersion {get;set;} 
        public List<SoftCodedValues> softCodedValues {get;set;}

    }
    
    public static Long convertToEpoch(Date dt){
        Long epochDate;
        if(dt !=null) {
            Date dtToconVert = dt;
            Datetime dtTime = dtToconVert;
            epochDate = dtTime.getTime()/1000;
        }
        return epochDate;
    }
    
    public class Requests {
        @InvocableVariable
        public  Opportunity_Product_Configuration__c oliConfig;
        @InvocableVariable
        public Opportunity_Product__c oliReq;
        @InvocableVariable
        public Boolean isOliDeletd;
    }
    
    public class Results {
        @InvocableVariable
        public String kafkakey;
        @InvocableVariable
        public String serializedJSON1;
        @InvocableVariable
        public String serializedJSON2;
        @InvocableVariable
        public String serializedJSON3;
        @InvocableVariable
        public String serializedJSON4;
        
        @InvocableVariable
        public String serializedJSON5;
        @InvocableVariable
        public String serializedJSON6;
        @InvocableVariable
        public String serializedJSON7;
        @InvocableVariable
        public String serializedJSON8;
        
        public Results(){
            serializedJSON1 = '';
            serializedJSON2 = '';
            serializedJSON3 = '';
            serializedJSON4 = '';
            serializedJSON5 = '';
            serializedJSON6 = '';
            serializedJSON7 = '';
            serializedJSON8= '';
            kafkakey='';
        }
    }
    
    @InvocableMethod(label='Get OLI Event Details')
    public static List<Results> prepareOliEventData(List<Requests> requests) {
        
        Set<Id> oliRecordId= new Set<Id>();
        List<Results> response = new List<Results>();
        
        for(Requests req: requests){
            if(req.oliReq != null){
                oliRecordId.add(req.oliReq.Id);
                if(req.isOliDeletd){
                    mapOfOliandDeletion.put(req.oliReq.Id,req.isOliDeletd);
                } 
            }else{
                oliRecordId.add(req.oliConfig.Opportunity_Product_Cus__c);
                
            }
            
        }
       
        getOlidetails(oliRecordId);
        getOLIProductData(oliRecordId);
        
        for(Id oli :oliRecordId){
            Results result = new Results();
            if(mapOliIdandReference.containsKey(oli)){
                result.kafkakey = mapOliIdandReference.get(oli);
            }
            
            //used in V2 Wrapper
            LineItemMessage tempMessage1= new LineItemMessage();

            
            if(mapOfOLiIdAndWrapper.containsKey(oli)){
                tempMessage1 = mapOfOLiIdAndWrapper.get(oli);
            }
            
            if(mapOliIdandConfig.containsKey(oli)){
                tempMessage1.selectedProductConfigurations = mapOliIdandConfig.get(oli);
            }
            
            if(mapOliIdandSchedules.containsKey(oli)){
               tempMessage1.opportunityLineItemSchedules = mapOliIdandSchedules.get(oli);
            }

            String messageOLIJson= JSON.serialize(tempMessage1);

            result.serializedJSON1 = messageOLIJson.length()>0 && messageOLIJson.length()< 131000 ? messageOLIJson.subString(0,messageOLIJson.length()): messageOLIJson.length()> 131000? messageOLIJson.subString(0,131000) : '';
            result.serializedJSON2 = messageOLIJson.length()>=131000 && messageOLIJson.length()< 262000 ?  messageOLIJson.subString(131000,messageOLIJson.length()): messageOLIJson.length()> 262000? messageOLIJson.subString(131000,262000) :'';
            result.serializedJSON3 = messageOLIJson.length()>=262000 && messageOLIJson.length()< 393000 ?  messageOLIJson.subString(262000,messageOLIJson.length()): messageOLIJson.length()> 393000? messageOLIJson.subString(262000,393000) :'';
            result.serializedJSON4 = messageOLIJson.length()>=393000 && messageOLIJson.length()< 524000 ?  messageOLIJson.subString(393000,messageOLIJson.length()): messageOLIJson.length()> 524000? messageOLIJson.subString(393000,524000) :'';
            

            //used in V3 Wrapper
            Message oliMessage= new Message();

            if(mapOfOLiAndWrapper.containsKey(oli)){
                oliMessage = mapOfOLiAndWrapper.get(oli);
            }

            if(mapOliIdandConfig.containsKey(oli)){
                oliMessage.selectedProductConfigurations = mapOliIdandConfig.get(oli);
            }

            if(mapOliIdandSchedules.containsKey(oli)){
                oliMessage.opportunityLineItemSchedules = mapOliIdandSchedules.get(oli);
            }

            
            String messageJson= JSON.serialize(oliMessage);

            result.serializedJSON5 = messageJson.length()>0 && messageJson.length()< 131000 ? messageJson.subString(0,messageJson.length()): messageJson.length()> 131000? messageJson.subString(0,131000) : '';
            result.serializedJSON6 = messageJson.length()>=131000 && messageJson.length()< 262000 ?  messageJson.subString(131000,messageJson.length()): messageJson.length()> 262000? messageJson.subString(131000,262000) :'';
            result.serializedJSON7 = messageJson.length()>=262000 && messageJson.length()< 393000 ?  messageJson.subString(262000,messageJson.length()): messageJson.length()> 393000? messageJson.subString(262000,393000) :'';
            result.serializedJSON8 = messageJson.length()>=393000 && messageJson.length()< 524000 ?  messageJson.subString(393000,messageJson.length()): messageJson.length()> 524000? messageJson.subString(393000,524000) :'';
                        
            
            response.add(result);
        }
        
        integer sizeOfResponse = response.size();
       
        for(integer i=0; i < (Requests.size()- sizeOfResponse); i++){
            Results emptyResult = new Results();
            response.add(emptyResult);
        }
        
        return response;
    }
    
    
    public static void  getOlidetails(Set<Id> oliRecordId){
       
        String orgCurr = UserInfo.getDefaultCurrency();
        try{
            for(Opportunity_Product__c oli:[SELECT id,name,OpportunityId__c, Total_Price__c, OpportunityId__r.Opportunity_Ref__c, OpportunityId__r.StageName, Quantity__c, ProductCode__c, Product2ID__r.Name, Product2ID__r.Portfolio__c, Product_Family__c,Solution__r.Definition_Type__c,Solution__r.Oipc_code__c,Solution__r.Name,Solution__r.Version__c, Solution__r.Minor_Version__c, Solution__r.Increment_Version__c,
                                            Product2ID__r.Family_Code__c,Trade_Route__r.Direction__c,Trade_Route__r.Route_Direction_Code__c, Product2ID__r.OIPC_Code__c,Country__r.GEO_Code__c,Executing_City_State__r.GEO_Code__c, Cargo_Type__c, Product2ID__r.Definition_Type__c,Product2ID__r.Service_Model__c,solution__c,Product2ID__r.Family,
                                            Trade_Route__r.Route_Code__c, Trade_Route__r.Name, Trade_Route__r.Operator__c,Special_Cargo__c,Import_Export__c, Product2ID__r.OIPC_Version__c, Product2ID__r.Version__c, Product2ID__r.Minor_Version__c, Product2ID__r.Increment_Version__c,
                                            (SELECT Id,Opportunity_Product__c ,Description__c, Quantity__c,Revenue__c,Schedule_Date__c  FROM Opportunity_Product_Schedules__r ) 
                                            FROM Opportunity_Product__c  WHERE Id IN :oliRecordId])
            {   
                // code in V2 events
                LineItemMessage oliMessageWrapper = new LineItemMessage();
                Oppty opportunity= new Oppty();
                if(!mapOliIdandReference.containsKey(oli.Id)){
                    mapOliIdandReference.put(oli.Id,oli.OpportunityId__r.Opportunity_Ref__c);
                }
                
                opportunity.opportunityId = oli.OpportunityId__c;
                opportunity.opportunityNumber = oli.OpportunityId__r.Opportunity_Ref__c;
                opportunity.opportunityStage = oli.OpportunityId__r.StageName;
                oliMessageWrapper.opportunity = opportunity;
                oliMessageWrapper.isoCurrencyCode = orgCurr;
                oliMessageWrapper.grossProfit = oli.Total_Price__c;
                oliMessageWrapper.lineItemId = oli.Id;
                oliMessageWrapper.lineItemName = oli.Name;
                oliMessageWrapper.lineItemQuantity = oli.Quantity__c;
                oliMessageWrapper.cargoTypeCode = oli.Cargo_Type__c!=null?oli.Cargo_Type__c:'';
                oliMessageWrapper.isLineItemDeleted = mapOfOliandDeletion.containsKey(oli.Id)? mapOfOliandDeletion.get(oli.Id) : false;
                oliMessageWrapper.specialCargo = oli.Special_Cargo__c != null? oli.Special_Cargo__c:'';
                oliMessageWrapper.transportActivity = oli.Import_Export__c;
                
                Route td = new Route();
                td.routeCode = oli.Trade_Route__r.Route_Code__c !=null ? oli.Trade_Route__r.Route_Code__c : '';
                td.routeName = oli.Trade_Route__r.Name!=null?oli.Trade_Route__r.Name:'';
                td.cardinalDirection = oli.Trade_Route__r.Direction__c!=null?oli.Trade_Route__r.Direction__c:'';
                
              
                List<Location> locationfunctions = new List<Location>();
                Location execCountry= new Location();
                execCountry.locationCode=  oli.Country__r.GEO_Code__c !=null ? oli.Country__r.GEO_Code__c: '';
                execCountry.locationFunction ='country';
                locationfunctions.add(execCountry);
                
                Location execstate= new Location();
                execstate.locationCode=  oli.Executing_City_State__r.GEO_Code__c !=null ? oli.Executing_City_State__r.GEO_Code__c: '';
                execstate.locationFunction ='state';
                locationfunctions.add(execstate);

                Product prod= new Product();
                String prodVersion = oli.Product2ID__r.Version__c != null  &&  oli.Product2ID__r.Minor_Version__c != null && oli.Product2ID__r.Minor_Version__c >= 0 &&  oli.Product2ID__r.Increment_Version__c!= null &&  oli.Product2ID__r.Increment_Version__c > 0 ? oli.Product2ID__r.Version__c+'.'+oli.Product2ID__r.Minor_Version__c +'.'+ oli.Product2ID__r.Increment_Version__c : oli.Product2ID__r.Version__c != null  &&  oli.Product2ID__r.Minor_Version__c != null && oli.Product2ID__r.Minor_Version__c > 0 ?  oli.Product2ID__r.Version__c+'.'+oli.Product2ID__r.Minor_Version__c : String.valueOf(oli.Product2ID__r.Version__c);
                
                prod.productCode =  oli.Product2ID__r.OIPC_Code__c!=null?oli.Product2ID__r.OIPC_Code__c:'';
                prod.productName = oli.Product2ID__r.Name!=null?oli.Product2ID__r.Name:'';
                prod.productVersion =  prodVersion;
                prod.productFamily.productFamilyCode = oli.Product2ID__r.Family_Code__c!=null?oli.Product2ID__r.Family_Code__c:'';
                prod.productFamily.productFamilyName = oli.Product_Family__c!=null?oli.Product_Family__c:'';
                prod.productFamily.productPortfolio = oli.Product2ID__r.Portfolio__c!=null?oli.Product2ID__r.Portfolio__c:'';
                oliMessageWrapper.selectedProduct.product=prod;
                oliMessageWrapper.route = td;
                oliMessageWrapper.locations= locationfunctions;
                

                //Used in V3
                Message oliMessage = new Message();
                oliMessage.opportunity = opportunity;
                oliMessage.isoCurrencyCode = orgCurr;
                oliMessage.grossProfit = oli.Total_Price__c;
                oliMessage.lineItemId = oli.Id;
                oliMessage.lineItemName = oli.Name;
                oliMessage.lineItemQuantity = oli.Quantity__c;
                oliMessage.cargoTypeCode = oli.Cargo_Type__c!=null?oli.Cargo_Type__c:'';
                oliMessage.isProductDeleted = mapOfOliandDeletion.containsKey(oli.Id)? mapOfOliandDeletion.get(oli.Id) : false;
                oliMessage.specialCargo = oli.Special_Cargo__c != null? oli.Special_Cargo__c:'';
                oliMessage.transportActivity = oli.Import_Export__c;

                Product_z product= new Product_z();
                product.productCode =  oli.Product2ID__r.OIPC_Code__c !=null? oli.Product2ID__r.OIPC_Code__c:'';
                product.productName = oli.Product2ID__r.Name !=null?oli.Product2ID__r.Name:'';
                product.productVersion = prodVersion;
                product.isAddon = oli.Product2ID__r.Definition_Type__c == 'Add-On Product' ? true:false;
                product.isProductSolution = oli.Product2ID__r.Definition_Type__c == 'Integrated Solution'  || (oli.Solution__c != null && oli.Solution__r.Definition_Type__c == 'Packaged Solution' )? true:false;
                


                SoftCodedValues definitationType=  new SoftCodedValues();
                definitationType.entityName='Product Overview';
                definitationType.attributeName= 'Product Definition Type';
                definitationType.value = oli.Product2ID__r.Definition_Type__c;

                List<ProductGroups> grouplst= new List<ProductGroups>();

                if(oli.Product2ID__r.Family != null && (oli.Product2ID__r.Definition_Type__c =='Product' || oli.Product2ID__r.Definition_Type__c =='Add-On Product') ){
                    ProductGroups productFamily= new ProductGroups();
                    productFamily.productGroupLevelLabel='ProductFamily';
                    productFamily.productGroupCode=oli.product2id__r.Family_Code__c;
                    productFamily.productGroupName=oli.Product2ID__r.Family;
                    grouplst.add(productFamily);
                }
                
                if(oli.Product2ID__r.Portfolio__c != null && (oli.Product2ID__r.Definition_Type__c =='Product' || oli.Product2ID__r.Definition_Type__c =='Add-On Product') ){
                    ProductGroups portfolio= new ProductGroups();
                    portfolio.productGroupLevelLabel='ProductPortfolio';
                    portfolio.productGroupCode= oli.Product2ID__r.Portfolio__c == 'Ocean' ? 'OCEAN' : 'LOGISTICS_AND_SERVICES';
                    portfolio.productGroupName=oli.Product2ID__r.Portfolio__c;
                    grouplst.add(portfolio);
                }
                
                
                if(oli.Product2ID__r.Service_Model__c  != null &&  oli.Product2ID__r.Definition_Type__c !='Packaged Solution' ){
                    for(String serviceModel:oli.Product2ID__r.Service_Model__c.split(';')){
                        ProductGroups serviceModeGroup= new ProductGroups();
                        serviceModeGroup.productGroupLevelLabel='ServiceModel';
                        serviceModeGroup.productGroupCode=serviceModel =='Transported by Maersk' ?'transported_by_maersk': serviceModel=='Fulfilled by Maersk'? 'fulfilled_by_maersk' :serviceModel=='Managed by Maersk'? 'managed_by_maersk':'' ;
                        serviceModeGroup.productGroupName= serviceModel ;
                        grouplst.add(serviceModeGroup);
                    }
                }
                product.softCodedValues = new List<SoftCodedValues>{definitationType};
                product.productGroups = grouplst;
                oliMessage.selectedProduct.product = product;
                if(oli.Solution__c != null && oli.Solution__r.Definition_Type__c == 'Packaged Solution'){
                    String solVersion = oli.Solution__r.Version__c != null  &&  oli.Solution__r.Minor_Version__c != null && oli.Solution__r.Minor_Version__c >= 0 &&  oli.Solution__r.Increment_Version__c!= null &&  oli.Solution__r.Increment_Version__c > 0 ? oli.Solution__r.Version__c+'.'+oli.Solution__r.Minor_Version__c +'.'+ oli.Solution__r.Increment_Version__c : oli.Solution__r.Version__c != null  &&  oli.Solution__r.Minor_Version__c != null && oli.Solution__r.Minor_Version__c > 0 ?  oli.Solution__r.Version__c+'.'+oli.Solution__r.Minor_Version__c : String.valueOf(oli.Solution__r.Version__c);
                
                    Solution sol= new Solution();
                    sol.solutionCode = oli.Solution__r.Oipc_code__c;
                    sol.solutionName = oli.Solution__r.Name;
                    sol.solutionVersion = solVersion;
                    SoftCodedValues solutionDef= new SoftCodedValues();
                    solutionDef.attributeName ='Solution Definition Type';
                    solutionDef.entityName = 'Solution Overview';  
                    solutionDef.value = oli.Solution__r.Definition_Type__c;
                    sol.softCodedValues = new List<SoftCodedValues>{solutionDef};
                    product.solution = sol; 
                }
                
                
                
                oliMessage.route = td;
                oliMessage.locations= locationfunctions;
                

                mapOfOLiIdAndWrapper.put(oli.id,oliMessageWrapper);
               
                mapOfOLiAndWrapper.put(oli.id,oliMessage);

                for(Opportunity_Product_Schedule__c olis: oli.Opportunity_Product_Schedules__r){    
                    // Code used in V2 
                    OpportunityLineItemSchedules_z oppLineItemSch = new OpportunityLineItemSchedules_z();
                    oppLineItemSch.lineItemScheduleId = olis.Id;                
                    oppLineItemSch.lineItemScheduleDate = convertToEpoch(olis.Schedule_Date__c);
                    oppLineItemSch.lineItemScheduleDescription = olis.Description__c !=null ? olis.Description__c : '';        
                    oppLineItemSch.lineItemScheduleAmount = olis.Revenue__c != null ? olis.Revenue__c : 0;
                    oppLineItemSch.lineItemScheduleQuantity = olis.Quantity__c != null ? olis.Quantity__c:0;
                    if(mapOliIdandSchedules.containsKey(olis.Opportunity_Product__c)){
                        mapOliIdandSchedules.get(olis.Opportunity_Product__c).add(oppLineItemSch);
                    }else{
                        mapOliIdandSchedules.put(olis.Opportunity_Product__c,new List<OpportunityLineItemSchedules_z>{oppLineItemSch});
                    }                         
                } 
            }
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OLI', 'OLIEventResponseWrapper.getOlidetails', new list<Exception>{ex}); // #RQ-005636 
            
        }
    }
    
    public static void  getOLIProductData(Set<Id> oliRecordId){
       
        Map<Id,Set<String>> mapOfOliandComp= new Map<Id,Set<String>>();
        Map<Id,Map<String,Set<string>>> mapOfOLiwithCompAndFeat = new Map<Id,Map<String,Set<String>>>();
        Map<Id,Map<String,Set<string>>> mapOfOLiwithFeatAndParam = new Map<Id,Map<String,Set<String>>>();
        Map<Id,Map<String,Set<string>>> mapOfOLiwithParamAndOption = new Map<Id,Map<String,Set<String>>>();
        
       
        Map<Id,Set<String>> mapofIncludedfeatures = new  Map<Id,Set<String>>();
        Map<Id,Set<String>> mapofExcludedfeatures = new  Map<Id,Set<String>>();
        Map<Id,Set<String>> mapofExcludedParameters = new  Map<Id,Set<String>>();
        Map<Id,Set<String>> mapofIncludedParameters = new  Map<Id,Set<String>>();
        
        try{
            for(Opportunity_Product_Configuration__c config:[SELECT id,Opportunity_Product_Cus__c,Opportunity_Product__r.OIPC_Product_Code__c,Component_Code__c, Feature_Code__c,Specification_Parameter_Code__c,Specification_Option_Code__c,Product_Specificaiton_Parameter__r.Name,Product_Specificaiton_Parameter__r.Is_Mandatory__c,Configured_Product_Feature__r.Feature_code__c,Configured_Product_Component__r.component_code__c,
                                                             Product_Specificaiton_Parameter__r.Allow_Multiselect__c,Is_Feature_Included__c,Is_Specification_Parameter_Included__c, Product_Specificaiton_Parameter__r.Configurable_at_Contracting__c,  Product_Component__c,Product_Feature__c,Product_Specificaiton_Parameter__r.Type__c,Specification_Option_Name__c
                                                             FROM Opportunity_Product_Configuration__c WHERE  Opportunity_Product_Cus__c IN: oliRecordId AND (Product_Specificaiton_Parameter__r.type__c = 'options' OR Product_Specificaiton_Parameter__c = null) order by Specification_Option_Code__c]){
                                                                
                                                                 String featCode = config.Feature_Code__c!= null ? config.Feature_Code__c : config.Configured_Product_Feature__r.Feature_code__c != null ?config.Configured_Product_Feature__r.Feature_code__c:'';
                                                                 String compCode = config.Component_Code__c != null ?  config.Component_Code__c :  config.Configured_Product_Component__r.component_code__c!= null ?config.Configured_Product_Component__r.component_code__c:'';

                                                                    if(compCode!= null){
                                                                        
                                                                        
                                                                        // Adding value to mapOfOliandComp
                                                                        if(mapOfOliandComp.containsKey(config.Opportunity_Product_Cus__c)){
                                                                            mapOfOliandComp.get(config.Opportunity_Product_Cus__c).add(String.valueOf(compCode));
                                                                        }else{
                                                                            mapOfOliandComp.put(config.Opportunity_Product_Cus__c,new Set<String>{String.valueOf(compCode)});
                                                                        }
                                                                    }
                                                                 
                                                                    if(featCode!= null ){
                                                                        
                                                                                                                                                
                                                                        // Adding value to mapOfOLiwithCompAndFeat
                                                                        if(mapOfOLiwithCompAndFeat.containskey(config.Opportunity_Product_Cus__c)){
                                                                            if(mapOfOLiwithCompAndFeat.get(config.Opportunity_Product_Cus__c).containsKey(String.valueOf(compCode))){
                                                                                mapOfOLiwithCompAndFeat.get(config.Opportunity_Product_Cus__c).get(String.valueOf(compCode)).add(featCode);
                                                                            }else{
                                                                                mapOfOLiwithCompAndFeat.get(config.Opportunity_Product_Cus__c).put(String.valueOf(compCode),new Set<String>{featCode});
                                                                            }
                                                                        }else{
                                                                            mapOfOLiwithCompAndFeat.put(config.Opportunity_Product_Cus__c,new Map<String,Set<String>>{String.valueOf(compCode)=>new Set<String>{featCode}});
                                                                        }  
                                                                        
                                                                        if(!config.Is_Specification_Parameter_Included__c && config.Product_Specificaiton_Parameter__c == null ){
                                                                            if(config.Is_Feature_Included__c){
                                                                                if(mapofIncludedfeatures.containsKey(config.Opportunity_Product_Cus__c)){
                                                                                    if(!mapofIncludedfeatures.get(config.Opportunity_Product_Cus__c).contains(featCode)){
                                                                                        mapofIncludedfeatures.get(config.Opportunity_Product_Cus__c).add(featCode);
                                                                                    }
                                                                                }else{
                                                                                    mapofIncludedfeatures.put(config.Opportunity_Product_Cus__c, new Set<String>{featCode});
                                                                                }
                                                                            }else{
                                                                                if(mapofExcludedfeatures.containsKey(config.Opportunity_Product_Cus__c)){
                                                                                    if(!mapofExcludedfeatures.get(config.Opportunity_Product_Cus__c).contains(featCode)){
                                                                                        mapofExcludedfeatures.get(config.Opportunity_Product_Cus__c).add(featCode);
                                                                                    }
                                                                                }else{
                                                                                    mapofExcludedfeatures.put(config.Opportunity_Product_Cus__c, new Set<String>{featCode});
                                                                                }
                                                                            }     
                                                                        }
                                                                    }
                                                                 
                                                                    if(config.Specification_Parameter_Code__c!= null){
                                                                        
                                                                        // Adding value to mapOfOLiwithFeatAndParam
                                                                        if(mapOfOLiwithFeatAndParam.containskey(config.Opportunity_Product_Cus__c)){
                                                                            if(mapOfOLiwithFeatAndParam.get(config.Opportunity_Product_Cus__c).containsKey(featCode)){
                                                                                mapOfOLiwithFeatAndParam.get(config.Opportunity_Product_Cus__c).get(featCode).add(config.Specification_Parameter_Code__c);
                                                                            }else{
                                                                                mapOfOLiwithFeatAndParam.get(config.Opportunity_Product_Cus__c).put(featCode,new Set<String>{config.Specification_Parameter_Code__c});
                                                                            }
                                                                        }else{
                                                                            mapOfOLiwithFeatAndParam.put(config.Opportunity_Product_Cus__c,new Map<String,Set<String>>{featCode=>new Set<String>{config.Specification_Parameter_Code__c}});
                                                                        }    
                                                                        
                                                                        if(config.Is_Feature_Included__c && config.Specification_Parameter_Code__c != null){
                                                                            if(!config.Is_Specification_Parameter_Included__c){
                                                                                if(mapofExcludedParameters.containsKey(config.Opportunity_Product_Cus__c)){
                                                                                    if(!mapofExcludedParameters.get(config.Opportunity_Product_Cus__c).contains(config.Specification_Parameter_Code__c)){
                                                                                        mapofExcludedParameters.get(config.Opportunity_Product_Cus__c).add(config.Specification_Parameter_Code__c);
                                                                                    }
                                                                                }else{
                                                                                    mapofExcludedParameters.put(config.Opportunity_Product_Cus__c, new Set<String>{config.Specification_Parameter_Code__c});
                                                                                }
                                                                            }else{
                                                                               if(mapofIncludedParameters.containsKey(config.Opportunity_Product_Cus__c)){
                                                                                    if(!mapofIncludedParameters.get(config.Opportunity_Product_Cus__c).contains(config.Specification_Parameter_Code__c)){
                                                                                        mapofIncludedParameters.get(config.Opportunity_Product_Cus__c).add(config.Specification_Parameter_Code__c);
                                                                                    }
                                                                                }else{
                                                                                    mapofIncludedParameters.put(config.Opportunity_Product_Cus__c, new Set<String>{config.Specification_Parameter_Code__c});
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                 
                                                                    if(config.Specification_Option_Code__c!= null){
                                                                        
                                                                        if(mapOfOLiwithParamAndOption.containskey(config.Opportunity_Product_Cus__c)){
                                                                            if(mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).containsKey(config.Specification_Parameter_Code__c)){
                                                                                if( mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).get(config.Specification_Parameter_Code__c).size() == 1 && 
                                                                                    mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).get(config.Specification_Parameter_Code__c).contains(config.Specification_Parameter_Code__c)){
                                                                                        mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).put(config.Specification_Parameter_Code__c,new Set<String>{config.Specification_Option_Code__c});
                                                                                    }else{
                                                                                        mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).get(config.Specification_Parameter_Code__c).add(config.Specification_Option_Code__c);
                                                                                    }
                                                                            }else{
                                                                                mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).put(config.Specification_Parameter_Code__c,new Set<String>{config.Specification_Option_Code__c});
                                                                            }
                                                                            
                                                                        }else{
                                                                            mapOfOLiwithParamAndOption.put(config.Opportunity_Product_Cus__c,new Map<String,Set<String>>{config.Specification_Parameter_Code__c=>new Set<String>{config.Specification_Option_Code__c}});
                                                                        } 
                                                                    }else if(config.Specification_Parameter_Code__c!= null){ // Adding Specification_Parameter_Code__c in case of Empty Option Code
                                                                        
                                                                        if(mapOfOLiwithParamAndOption.containskey(config.Opportunity_Product_Cus__c)){
                                                                            if(mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).containsKey(config.Specification_Parameter_Code__c)){
                                                                                mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).get(config.Specification_Parameter_Code__c).add(config.Specification_Parameter_Code__c);
                                                                            } else{
                                                                                mapOfOLiwithParamAndOption.get(config.Opportunity_Product_Cus__c).put(config.Specification_Parameter_Code__c,new Set<String>{config.Specification_Parameter_Code__c});
                                                                            }
                                                                        }else{
                                                                            mapOfOLiwithParamAndOption.put(config.Opportunity_Product_Cus__c,new Map<String,Set<String>>{config.Specification_Parameter_Code__c=> new Set<String>{config.Specification_Parameter_Code__c}});
                                                                        }
                                                                    }
                                                                 
                                                            }
        getConfigurationData( mapOfOliandComp, mapOfOLiwithParamAndOption,mapOfOLiwithCompAndFeat, mapofIncludedfeatures, mapofExcludedfeatures,mapofExcludedParameters,mapofIncludedParameters);
            
            
        }catch(Exception ex){
            ErrorLogger.writeErrors( 'SFDC', 'OLI', 'OLIEventResponseWrapper.getOLIProductData', new list<Exception>{ex}); // #RQ-005636 
            
        }
    }
    
    public static void getConfigurationData(Map<Id,Set<String>> mapOfOliandComp, Map<Id,Map<String,Set<string>>> mapOfOLiwithParamAndOption,Map<Id,Map<String,Set<string>>> mapOfOLiwithCompAndFeat, Map<Id,Set<String>> mapofIncludedfeatures,  Map<Id,Set<String>> mapofExcludedfeatures, Map<Id,Set<String>> mapofExcludedParameters, Map<Id,Set<String>> mapofIncludedParameters){

        for(Id oliId: mapOfOliandComp.keyset()){
            List<SelectedProductConfiguration> lstSelectedConfig = new list<SelectedProductConfiguration>();

            if(mapOfOLiwithCompAndFeat.containsKey(oliId)){
                for(String feat : mapOfOLiwithCompAndFeat.get(oliId).keyset()){
                
                    for(String featRec : mapOfOLiwithCompAndFeat.get(oliId).get(feat)){  
                        SelectedProductConfiguration selectedFeature= new SelectedProductConfiguration();
                        selectedFeature.productConfiguration.attributeName ='service';
                        selectedFeature.productConfiguration.productElement.productElementCode = featRec;
                        selectedFeature.productConfiguration.productElement.productElementType = 'FEATURE';
                        
                        if(mapofIncludedfeatures.containsKey(oliId)){
                          if(mapofIncludedfeatures.get(oliId).contains(featRec)){
                                ProductConfigOption option = new ProductConfigOption();
                                option.productConfigurationOptionCode = 'INCLUDED';
                                selectedFeature.productConfigurationOptions.add(option);
                            } 
                        }
                        if(mapofExcludedfeatures.containsKey(oliId)){
                            if(mapofExcludedfeatures.get(oliId).contains(featRec)){
                                ProductConfigOption option = new ProductConfigOption();
                                option.productConfigurationOptionCode = 'NOT_INCLUDED';
                                selectedFeature.productConfigurationOptions.add(option);
                            }
                        }
                        lstSelectedConfig.add(selectedFeature);  
                    }       
                }
            }
                        
            if(mapOfOLiwithParamAndOption.containsKey(oliId)){
                for(String para : mapOfOLiwithParamAndOption.get(oliId).keySet()){
                    Boolean haveOption = false;
                    SelectedProductConfiguration selectedConfig= new SelectedProductConfiguration();
                    selectedConfig.productConfiguration.attributeName ='options';
                    selectedConfig.productConfiguration.productElement.productElementCode = para;
                    selectedConfig.productConfiguration.productElement.productElementType = 'PARAMETER';
                
                    for (String opt : mapOfOLiwithParamAndOption.get(oliId).get(para) ){
                    
                        if(opt!=para){
                            haveOption = true;
                            ProductConfigOption option = new ProductConfigOption();
                            option.productConfigurationOptionCode = opt;
                            selectedConfig.productConfigurationOptions.add(option);
                        }
                    }
                        
                    if(haveOption){
                    lstSelectedConfig.add(selectedConfig);
                    }
                        
                    SelectedProductConfiguration selectedConfig1= new SelectedProductConfiguration();
                    selectedConfig1.productConfiguration.attributeName ='service';
                    selectedConfig1.productConfiguration.productElement.productElementCode = para;
                    selectedConfig1.productConfiguration.productElement.productElementType = 'PARAMETER';
                    
    
                    if(mapofExcludedParameters.containsKey(oliId)){
                        if(mapofExcludedParameters.get(oliId).contains(para)){
                            ProductConfigOption option1 = new ProductConfigOption();
                            option1.productConfigurationOptionCode = 'NOT_INCLUDED';
                            selectedConfig1.productConfigurationOptions.add(option1);
                        }
                    }
                    if(mapofIncludedParameters.containsKey(oliId)){
                        if(mapofIncludedParameters.get(oliId).contains(para)){
                        ProductConfigOption option1 = new ProductConfigOption();
                        option1.productConfigurationOptionCode = 'INCLUDED';
                        selectedConfig1.productConfigurationOptions.add(option1);
                        }
                    }
                    lstSelectedConfig.add(selectedConfig1);
                } 
            }
            

      	 
          
            if(!mapOliIdandConfig.containsKey(oliId)){
                mapOliIdandConfig.put(oliId,lstSelectedConfig);
            }
        }
    }
}