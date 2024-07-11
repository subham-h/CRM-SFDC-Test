/*              
* Revision Date        Owner                    Description
* -------- ----------  -----------              -----------
* 1.0     27-Oct-2022  Sidhartha@maersk.com     Wrapper class for Opportunity publishing used in "Publish Opportunity Event" flow
* 2.0     06-Oct-2023  Aditi@maersk.com         Added businessProcess, expectedNegotiationRound, isoCurrencyCode, grossProfit
* 3.0     12-Mar-2024  Samar@maersk.com         deactivate V3 and Adding V5 event logic
* 5.0     03-Jun-2024  Avinash@maersk.com       SFSE-14825 - Cargo Type on Opportunity Level
*/
public without sharing class OpportunityEventResponseWrapper {
    public static Map<Id,Boolean> mapOfOliandDeletion= new Map<Id,Boolean>();
    public static Map<Id, Message> mapOpptyResponse = new Map<Id, Message>();    
    public static Map<Id, OpportunityMessage> mapOpportunityResponse = new Map<Id, OpportunityMessage>();
    public static Map<Id,List<Negotiation_z>> mapOfOppIdandListNegotiation = new Map<Id,List<Negotiation_z>>();
    public static Map<Id,String> mapOpptyIdandReference= new Map<Id,String>();
    public static Map<Id, List<Id>> mapOpptyIdwithListSolutionId = new Map<Id,List<Id>>();

   
    //Opportunity V4
    public class salesOpportunityData {
        public header header;
        public OpportunityMessage message;
        public string topic;
        public string key;
        
        public salesOpportunityData(header header, OpportunityMessage message, string topic,string key) {
            this.header = header;
            this.message = message;
            this.topic = topic;
            this.key = key;
        }
    }
     //Opportunty v5
     public class salesOpportunity {
        public header header;
        public message message;
        public string topic;
        public string key;
        
        public salesOpportunity(header header, message message, string topic,string key) {
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
    
     // For opportunity v5
    public Static header getheaderWrapper(String evtId,String eventNotification){
        Datetime dt = Datetime.now();
        header pRec = new header();
        pRec.eventNotificationName = eventNotification != null ? eventNotification:'live';
        pRec.version = '5.0.0';
        pRec.systemz = 'sfdc';
        pRec.messageId = evtId !=null ? evtId : String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        return pRec;
    }
    
    // For opportunity v4
    public Static header getheader(String evtId,String eventNotification){
        Datetime dt = Datetime.now();
        header pRec = new header();
        pRec.eventNotificationName = eventNotification != null ? eventNotification:'live';
        pRec.version = '4.0.0';
        pRec.systemz = 'sfdc';
        pRec.messageId = evtId !=null ? evtId : String.valueOf(math.random());
        pRec.eventTimestamp = dt.getTime()/1000;
        return pRec;
    }
 
    //SFSE-14825
    public class CargoType{
        public String cargoTypeCode;
        public String cargoTypeName;
    }
    
    //Wrapper classes used in OpportunityEvent V4
    public class OpportunityMessage {
        public String opportunityId {get;set;} 
        public String opportunityName {get;set;} 
        public String opportunityNumber {get;set;} 
        public String opportunityStage {get;set;} 
        public OpportunityCloseReason opportunityCloseReason {get;set;} 
        public long expectedAgreementStartDate {get;set;} 
        public long expectedAgreementEndDate {get;set;} 
        public String brandName {get;set;} 
        public String opportunityTypeName {get;set;} 
        public String cargoTypeCode {get;set;}
        public String containsDangerousGoods {get;set;} 
        public String preferedTenderFormat {get;set;} 
        public Decimal expectedNegotiationRound {get;set;}  
        public String customerRequestedRateStructure {get;set;} 
        public long expectedTenderReceiptDate {get;set;} 
        public long firstRoundSubmissionDate {get;set;} 
        public String opportunityOfferType {get;set;} 
        public Boolean isDoubleDown {get;set;} 
        public Customer customer {get;set;} 
        public List<BusinessProcess> businessProcesses {get;set;}
        public List<Opportunity_Team_z> opportunityTeam {get;set;} 
        public List<OpportunityProduct_z> opportunityLineItem {get;set;} 
        public List<Negotiation_z> negotiations {get;set;}
        public List<Offer_z> offers {get;set;}
        
        public OpportunityMessage() {
            opportunityTeam = new List<Opportunity_Team_z>();
            opportunityLineItem = new List<OpportunityProduct_z>();
            negotiations = new List<Negotiation_z>();
            offers =  new List<Offer_z>();
            customer = new Customer();
            businessProcesses =new List<BusinessProcess>();
            opportunityCloseReason = new OpportunityCloseReason();
            containsDangerousGoods = '';
            preferedTenderFormat = '';
            customerRequestedRateStructure = '';
        }
    }
    
    public class OpportunityCloseReason{
        public String opportunityCloseReasonCode {get;set;} 
        public String opportunityCloseReasonName {get;set;} 
        public OpportunityCloseReason(){
            opportunityCloseReasonCode ='';
            opportunityCloseReasonName ='';
        }
    }
    
    public class Customer {
        public String customerCode {get;set;} 
        public String customerName {get;set;} 
        public Boolean isConcern {get;set;} 
        public String concernCode {get;set;}
    }
    
    public class Opportunity_Team_z {
        public String associateName {get;set;} 
        public String associateUniqueCode {get;set;} 
        public String iso2CountryCode {get;set;} 
        public String emailAddress {get;set;} 
        public String memberRoleName {get;set;} 
        
    }
    
    public class OpportunityProduct_z {
        public String lineItemId {get;set;} 
        public String lineItemName {get;set;} 
        public String lineItemQuantity {get;set;} 
        public String cargoType {get;set;} 
        public String specialCargo {get;set;} 
        public String importExport {get;set;} 
        public Decimal grossProfit {get;set;}
        public String isoCurrencyCode{get;set;}
        public List<Location> locations {get;set;} 
        public Route route {get;set;} 
        public SelectedProduct selectedProduct {get;set;} 
        public Boolean isLineItemDeleted {get;set;} 
        public OpportunityProduct_z() {
            route = new Route();
            isLineItemDeleted = false;
            cargoType='';
            specialCargo='';
            importExport='';
        }
        
    }
    
    public class Location {
        public String locationCode {get;set;} 
        public String locationFunction {get;set;} 
        public Location(){
            locationCode='';
            locationFunction='';
        }
    }
    
    public class Route {
        public String routeCode {get;set;} 
        public String cardinalDirection {get;set;} 
        public String routeName {get;set;} 
        public  Route(){
            routeCode ='';
            cardinalDirection ='';
            routeName='';
        }
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
    
    
    public class Negotiation_z {
        public Integer negotiationRoundNumber {get;set;}
        public String negotiationId {get;set;}
        public long receiptDate {get;set;}
        public long submissionDate {get;set;}
        public List<Negotiation_Files_z> negotiationFiles {get;set;}
        public  Negotiation_z() {
            negotiationFiles= new List<Negotiation_Files_z>();
        }
    }
    
    public class Negotiation_Files_z {
        public String fileCategory {get;set;}
        public String fileExtension {get;set;}
        public String fileName {get;set;}
    }
    
    public class Offer_z{
        public String offerID {get;set;}
        public String offerStatusCode {get;set;}
        public long offerSentDate {get;set;}
        public long offerAcceptedDate {get;set;}
        public List<Recipient> recipient {get;set;}
        public AcceptedBy acceptedBy {get;set;}
        public CreatedBy createdBy {get;set;}
        public Offer_z(){
            recipient = new List<Recipient>();
            createdBy = new CreatedBy();
            acceptedBy = new AcceptedBy();
        }
    }
    
    public class Recipient{
        public String name {get;set;}
        public String emailAddress {get;set;}
        public Boolean isMainRecipient {get;set;}
    }
    
    public class AcceptedBy{
        public String name {get;set;}
        public String emailAddress {get;set;}
        public AcceptedBy(){
            name = '';
            emailAddress ='' ;
        }
    }
    
    public class CreatedBy{
        public String name {get;set;}
        public String emailAddress {get;set;}
        public CreatedBy(){
            name = '';
            emailAddress ='' ;
        }
    }
    
    public class BusinessProcess{
        public String code;
        public String name;
    }
    

    
     //Wrapper classes used in OpportunityEvent V5
    public class Message {
        public String opportunityId {get;set;} 
        public String opportunityName {get;set;} 
        public String opportunityNumber {get;set;} 
        public String opportunityStage {get;set;} 
        public OpportunityCloseReason opportunityCloseReason {get;set;} 
        public long expectedAgreementStartDate {get;set;} 
        public long expectedAgreementEndDate {get;set;} 
        public String brandName {get;set;} 
        public String opportunityTypeName {get;set;} 
        public List<CargoType> cargoTypes {get;set;}//SFSE-14825
        public String approvalsRequired {get;set;} 
        public String opportunityProcess {get;set;} 
        public Decimal grossProfitOpportunity {get;set;} 
        public long  opportunityCreatedDate{get;set;} 
        public String containsDangerousGoods {get;set;} 
        public String preferedTenderFormat {get;set;} 
        public Decimal expectedNegotiationRound {get;set;} 
        public String customerRequestedRateStructure {get;set;} 
        public long expectedTenderReceiptDate {get;set;} 
        public long firstRoundSubmissionDate {get;set;} 
        public String opportunityOfferType {get;set;} 
        public Boolean isDoubleDown {get;set;} 
        public Customer customer {get;set;} 
        public List<BusinessProcess> businessProcesses {get;set;}
        public List<Opportunity_Team_z> opportunityTeam {get;set;} 
        public List<OpportunityProduct> opportunityLineItem {get;set;} 
        public List<Negotiation_z> negotiations {get;set;}
        public List<Offer_z> offers {get;set;}
        
        public Message() {
            opportunityTeam = new List<Opportunity_Team_z>();
            opportunityLineItem = new List<OpportunityProduct>();
            negotiations = new List<Negotiation_z>();
            offers =  new List<Offer_z>();
            customer = new Customer();
            businessProcesses =new List<BusinessProcess>();
            opportunityCloseReason = new OpportunityCloseReason();
            containsDangerousGoods = '';
            preferedTenderFormat = '';
            customerRequestedRateStructure = '';
        }
    }

    public class OpportunityProduct{
        public String lineItemId {get;set;} 
        public String lineItemName {get;set;} 
        public String lineItemQuantity {get;set;} 
        public String cargoType {get;set;} 
        public String specialCargo {get;set;} 
        public String transportActivity {get;set;} 
        public Decimal grossProfit {get;set;}
        public String isoCurrencyCode{get;set;}
        public List<Location> locations {get;set;} 
        public Route route {get;set;} 
        public SelectedProduct_z selectedProduct {get;set;} 
        public Boolean isProductDeleted {get;set;} 
        public OpportunityProduct() {
            route = new Route();
            isProductDeleted = false;
            cargoType='';
            specialCargo='';
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
        public Solution solution {get;set;}

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
    
    public class Requests {
        @InvocableVariable
        public Opportunity oppReq;
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
        @InvocableVariable
        public String serializedJSON9;
        @InvocableVariable
        public String serializedJSON10;
        @InvocableVariable
        public String serializedJSON11;
        @InvocableVariable
        public String serializedJSON12;
        
        public Results(){
            kafkakey = '';
            serializedJSON1 = '';
            serializedJSON2 = '';
            serializedJSON3 = '';
            serializedJSON4 = '';
            serializedJSON5 = '';
            serializedJSON6 = '';
            serializedJSON7 = '';
            serializedJSON8 = '';
            serializedJSON9 = '';
            serializedJSON10 = '';
            serializedJSON11 = '';
            serializedJSON12 = '';
        }
    }
    
    @InvocableMethod(label='Get Event Details')
    public static List<Results> prepareOppEventData (List<Requests> req) {
        Set<Id> oppId = new Set<Id>();
        List<Results> responses = new List<Results>();
        
        for(Requests re: req) {
            if(re.oppReq !=null) {
                oppId.add(re.oppReq.Id);  
            }else{
                oppId.add(re.oliReq.OpportunityId__c);  
                if(re.isOliDeletd){
                    mapOfOliandDeletion.put(re.oliReq.Id,re.isOliDeletd);
                } 
            }
        }
        getOpportnityDetails(oppId);
        getOppQuoteData(oppId);
        Map<ID,List<Offer_z>> mapofOffer = getOppOfferInfo(oppId);
        
        Integer charCount = 0;
        
        for(Id opportunityId : oppId){
            Results result = new Results();
            if(mapOpptyIdandReference.containsKey(opportunityId)){
                result.kafkakey = mapOpptyIdandReference.get(opportunityId);
            }
           
            //Code used in OpportunityEvent V4
            OpportunityMessage tempOpptytMessage = new OpportunityMessage();
           
            if(mapOpportunityResponse.containsKey(opportunityId)){
                tempOpptytMessage = mapOpportunityResponse.get(opportunityId);
                //result.serializedJSON5 = JSON.serialize(mapOpportunityResponse.get(opportunityId));
            }
            
            if(mapOfOppIdandListNegotiation.containskey(opportunityId)){
                tempOpptytMessage.negotiations = mapOfOppIdandListNegotiation.get(opportunityId);
               //result.serializedJSON6 = JSON.serialize(mapOfOppIdandListNegotiation.get(opportunityId));
            }
            
            if(mapofOffer.containsKey(opportunityId)){
                tempOpptytMessage.offers = mapofOffer.get(opportunityId);
                //result.serializedJSON7 = JSON.serialize(mapofOffer.get(opportunityId));
            }
           
            String messageOpptyJson= JSON.serialize(tempOpptytMessage);
            system.debug('messageOpptyJson v4:'+messageOpptyJson); 
         
            result.serializedJSON1 = messageOpptyJson.length()>0 && messageOpptyJson.length()< 131000 ? messageOpptyJson.subString(0,messageOpptyJson.length()): messageOpptyJson.length()> 131000? messageOpptyJson.subString(0,131000) : '';
            result.serializedJSON2 = messageOpptyJson.length()>=131000 && messageOpptyJson.length()< 262000 ?  messageOpptyJson.subString(131000,messageOpptyJson.length()): messageOpptyJson.length()> 262000? messageOpptyJson.subString(131000,262000) :'';
            result.serializedJSON3 = messageOpptyJson.length()>=262000 && messageOpptyJson.length()< 393000 ?  messageOpptyJson.subString(262000,messageOpptyJson.length()): messageOpptyJson.length()> 393000? messageOpptyJson.subString(262000,393000) :'';
            result.serializedJSON4 = messageOpptyJson.length()>=393000 && messageOpptyJson.length()< 524000 ?  messageOpptyJson.subString(393000,messageOpptyJson.length()): messageOpptyJson.length()> 524000? messageOpptyJson.subString(393000,524000) :'';
            result.serializedJSON5 = messageOpptyJson.length()>=524000 && messageOpptyJson.length()< 655000 ?  messageOpptyJson.subString(524000,messageOpptyJson.length()): messageOpptyJson.length()> 655000? messageOpptyJson.subString(524000,655000) :'';
            result.serializedJSON6 =messageOpptyJson.length()>=655000 && messageOpptyJson.length()< 786000 ?  messageOpptyJson.subString(655000,messageOpptyJson.length()): messageOpptyJson.length()> 786000? messageOpptyJson.subString(655000,786000) :'';
            
            
            //Code used in OpportunityEvent V5
            Message tempMessage = new Message();
            
            if(mapOpptyResponse.containsKey(opportunityId)){
                tempMessage = mapOpptyResponse.get(opportunityId);
            }
            
            if(mapOfOppIdandListNegotiation.containskey(opportunityId)){
                tempMessage.negotiations = mapOfOppIdandListNegotiation.get(opportunityId);
            }
            
            if(mapofOffer.containsKey(opportunityId)){
                tempMessage.offers = mapofOffer.get(opportunityId);
            }
            
            String messageJson= JSON.serialize(tempMessage);
            result.serializedJSON7 = messageJson.length()>0 && messageJson.length()< 131000 ? messageJson.subString(0,messageJson.length()): messageJson.length()> 131000? messageJson.subString(0,131000) : '';
            result.serializedJSON8 = messageJson.length()>=131000 && messageJson.length()< 262000 ?  messageJson.subString(131000,messageJson.length()): messageJson.length()> 262000? messageJson.subString(131000,262000) :'';
            result.serializedJSON9 = messageJson.length()>=262000 && messageJson.length()< 393000 ?  messageJson.subString(262000,messageJson.length()): messageJson.length()> 393000? messageJson.subString(262000,393000) :'';
            result.serializedJSON10= messageJson.length()>=393000 && messageJson.length()< 524000 ?  messageJson.subString(393000,messageJson.length()): messageJson.length()> 524000? messageJson.subString(393000,524000) :'';
            result.serializedJSON11= messageJson.length()>=524000 && messageJson.length()< 655000 ?  messageJson.subString(524000,messageJson.length()): messageJson.length()> 655000? messageJson.subString(524000,655000) :'';
            result.serializedJSON12= messageJson.length()>=655000 && messageJson.length()< 786000 ?  messageJson.subString(655000,messageJson.length()): messageJson.length()> 786000? messageJson.subString(655000,786000) :'';
            
           	system.debug('messageJson v5:'+messageJson);
            responses.add(result);
           
        }
        integer sizeOfResponse = responses.size();
                
        for(integer i=0; i < (req.size()- sizeOfResponse) ; i++){
            Results emptyResult = new Results();
            responses.add(emptyResult);
        }

        return responses;
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
    
    public static void getOpportnityDetails(Set<Id> oppId) {
        String serializedOppWrapper = '';
        String orgCurr = UserInfo.getDefaultCurrency();
        
        
        
        for (Opportunity opp : [SELECT Id,Offer_Type__c, Customer_Requested_Rate_Structure__c,Tender_Submission_Format__c,Opportunity_contains_Dangerous_Goods__c, IsClosed,Double_Down__c, First_Round_Submission_Date__c, Expected_Tender_Receipt_Date__c, Owner.Name,Cargo_Type__c,Business_Process__c,
                                Expected_Handling_Rounds__c, RecordType.Name, RecordType.DeveloperName,Approval_Required__c,Estimated_Total_Opp_Gross_Profit_Cus__c,CreatedDate,Parent_Opportunity__c,Named_Account__c,Named_Account__r.Customer_Code__c,
                                Owner.country, Owner.Email, Owner.Maersk_User_Id__c, Account.Name, Account.Customer_Code__c, Account.Concern_Code__c, Account.Represents_Concern__c, Name, First_Shipment_Date__c, Last_Shipment_Date__c, Opportunity_Ref__c, Liner_brand__c, StageName, Type,
                                Reason_For_Close__c, IsWon, (SELECT id, Product_Family__c,Cargo_Type__c,OpportunityId__c, name, Product2ID__r.name,Product2ID__r.Route_Direction_Code__c, ProductCode__c,Trade_Route__r.Route_Code__c, Product2ID__r.family, Country__r.Name,Quantity__c,
                                Product2ID__r.Portfolio__c,Trade_Route__r.Operator__c,Trade_Route__r.Name,Trade_Route__r.Direction__c,Trade_Route__r.Route_Direction_Code__c,Product2ID__r.Family_Code__c,Product2ID__r.OIPC_Code__c,Special_Cargo__c,Import_Export__c,Country__r.GEO_Code__c,Solution__r.Definition_Type__c,Solution__r.Oipc_code__c,Solution__r.Name,Solution__r.Version__c, Solution__r.Minor_Version__c, Solution__r.Increment_Version__c,
                                Executing_City_State__r.GEO_Code__c,Product2ID__r.Version__c, Product2ID__r.Minor_Version__c, Product2ID__r.Increment_Version__c, Total_Price__c,Product2ID__r.Definition_Type__c,Solution__c,Definition_Type__c,Product2ID__r.Service_Model__c  FROM Opportunity_Products__r) ,(SELECT id,Name, TeamMemberRole, User.email,user.Maersk_User_Id__c,user.Geo_Code__c  FROM OpportunityTeamMembers )
                                FROM Opportunity WHERE Id IN: oppId]) {
                                    if(!mapOpptyIdandReference.containsKey(opp.Id)){
                                        mapOpptyIdandReference.put(opp.id,opp.Opportunity_Ref__c);
                                    }
                                    List<BusinessProcess> lstBusinessProcess = new List<BusinessProcess>();
                                    
                                    if(opp.Business_Process__c <> NULL){
                                        for(String bpStr : opp.Business_Process__c.split(';')){
                                            if(bpStr.contains(' ')){
                                                String camelCaseBusinessProcessValue;
                                                Integer i=0;
                                                for(String str : bpStr.split(' ')){
                                                    if(i==0){
                                                        camelCaseBusinessProcessValue = str.toLowerCase();
                                                    } else {
                                                        camelCaseBusinessProcessValue = camelCaseBusinessProcessValue + str.capitalize();
                                                    }
                                                    i=i+1;
                                                }
                                                BusinessProcess bp = new BusinessProcess();
                                                bp.code = camelCaseBusinessProcessValue;
                                                bp.name = bpStr;
                                                lstBusinessProcess.add(bp);
                                            } else {
                                                BusinessProcess bp = new BusinessProcess();
                                                bp.code = bpStr.toLowerCase();
                                                bp.name = bpStr;
                                                lstBusinessProcess.add(bp);
                                            }   
                                        }
                                    }
                                    
                                    List<Opportunity_Team_z> oppTeamMembers= new List<Opportunity_Team_z>();
                                    
                                    for(OpportunityTeamMember oppTeam:opp.OpportunityTeamMembers){
                                        Opportunity_Team_z oppTeamMem = new Opportunity_Team_z();
                                        oppTeamMem.associateName = oppTeam.Name ;
                                        oppTeamMem.associateUniqueCode = oppTeam.user.Maersk_User_Id__c !=null ? oppTeam.user.Maersk_User_Id__c : '';
                                        oppTeamMem.iso2CountryCode = oppTeam.user.Geo_Code__c ;
                                        oppTeamMem.emailAddress = oppteam.User.email;
                                        oppTeamMem.memberRoleName = oppTeam.TeamMemberRole;
                                        oppTeamMembers.add(oppTeamMem);
                                    }
                                    
                                    //Code used in OpportunityEvent V4
                                    OpportunityMessage oppMessage = new OpportunityMessage();
                                    
                                    oppMessage.opportunityId = opp.Id;
                                    oppMessage.opportunityName = opp.Name;
                                    oppMessage.opportunityNumber = opp.Opportunity_Ref__c;
                                    oppMessage.opportunityStage = opp.StageName;
                                    if(opp.IsClosed) {
                                        oppMessage.opportunityCloseReason.opportunityCloseReasonName = opp.Reason_For_Close__c !=null ? opp.Reason_For_Close__c : '';
                                        oppMessage.opportunityCloseReason.opportunityCloseReasonCode = opp.IsWon ? 'Won':'Lost';
                                    }
                                    
                                    if(opp.First_Shipment_Date__c !=null || opp.Last_Shipment_Date__c !=null) {
                                        oppMessage.expectedAgreementStartDate =  opp.First_Shipment_Date__c !=null? convertToEpoch(opp.First_Shipment_Date__c) :0;
                                        oppMessage.expectedAgreementEndDate = opp.Last_Shipment_Date__c != null ? convertToEpoch(opp.Last_Shipment_Date__c) :0 ;
                                        oppMessage.expectedTenderReceiptDate = opp.Expected_Tender_Receipt_Date__c != null ?convertToEpoch(opp.Expected_Tender_Receipt_Date__c) :0 ;
                                        oppMessage.firstRoundSubmissionDate = opp.First_Round_Submission_Date__c != null ? convertToEpoch(opp.First_Round_Submission_Date__c) : 0 ;
                                    }

                                    oppMessage.brandName = opp.Liner_Brand__c != null ? opp.Liner_Brand__c:'';
                                    oppMessage.opportunityTypeName = opp.Type;
                                    oppMessage.containsDangerousGoods = opp.Opportunity_contains_Dangerous_Goods__c != null? opp.Opportunity_contains_Dangerous_Goods__c:'' ;
                                    oppMessage.preferedTenderFormat = opp.Tender_Submission_Format__c!= null ? opp.Tender_Submission_Format__c:'' ;
                                    oppMessage.expectedNegotiationRound = opp.Expected_Handling_Rounds__c;
                                    oppMessage.customerRequestedRateStructure = opp.Customer_Requested_Rate_Structure__c !=null ?opp.Customer_Requested_Rate_Structure__c :'';
                                    oppMessage.opportunityOfferType = opp.Offer_Type__c != null ?opp.Offer_Type__c :'' ;
                                    if(opp.Business_Process__c!= null){
                                        oppMessage.businessProcesses= lstBusinessProcess;
                                    }
                                    oppMessage.isDoubleDown = opp.Double_Down__c;
                                    oppMessage.Customer.customerCode = opp.Account.Customer_Code__c != null ? opp.Account.Customer_Code__c: '';
                                    oppMessage.Customer.customerName = opp.Account.Name;
                                    oppMessage.Customer.concernCode = opp.Account.Concern_Code__c != null? opp.Account.Concern_Code__c:'';
                                    oppMessage.Customer.isConcern = opp.Account.Represents_Concern__c;
                                    oppMessage.opportunityTeam= oppTeamMembers;
                                    
                                    // Used in Opportunity V5 start
                                    Message opptyMessage  = new Message();
                                    
                                    opptyMessage .opportunityId = opp.Id;
                                    opptyMessage .opportunityName = opp.Name;
                                    opptyMessage .opportunityNumber = opp.Opportunity_Ref__c;
                                    opptyMessage .opportunityStage = opp.StageName;
                                    if(opp.IsClosed) {
                                        opptyMessage .opportunityCloseReason.opportunityCloseReasonName = opp.Reason_For_Close__c !=null ? opp.Reason_For_Close__c : '';
                                        opptyMessage .opportunityCloseReason.opportunityCloseReasonCode = opp.IsWon ? 'Won':'Lost';
                                    }
                                    
                                    if(opp.First_Shipment_Date__c !=null || opp.Last_Shipment_Date__c !=null) {
                                        opptyMessage.expectedAgreementStartDate =  opp.First_Shipment_Date__c !=null? convertToEpoch(opp.First_Shipment_Date__c) :0;
                                        opptyMessage.expectedAgreementEndDate = opp.Last_Shipment_Date__c != null ? convertToEpoch(opp.Last_Shipment_Date__c) :0 ;
                                        opptyMessage.expectedTenderReceiptDate = opp.Expected_Tender_Receipt_Date__c != null ?convertToEpoch(opp.Expected_Tender_Receipt_Date__c) :0 ;
                                        opptyMessage.firstRoundSubmissionDate = opp.First_Round_Submission_Date__c != null ? convertToEpoch(opp.First_Round_Submission_Date__c) : 0 ;
                                    }
                                    opptyMessage.brandName = opp.Liner_Brand__c != null ? opp.Liner_Brand__c:'';
                                    opptyMessage.opportunityTypeName = opp.Type;
                                    Datetime createdDT = opp.CreatedDate;
                                    opptyMessage.approvalsRequired =opp.Approval_Required__c;
                                    opptyMessage.opportunityProcess = opp.RecordType.DeveloperName;
                                    opptyMessage.grossProfitOpportunity = opp.Estimated_Total_Opp_Gross_Profit_Cus__c;
                                    opptyMessage.opportunityCreatedDate  = createdDT.getTime()/1000;
                                    opptyMessage.containsDangerousGoods = opp.Opportunity_contains_Dangerous_Goods__c != null? opp.Opportunity_contains_Dangerous_Goods__c:'' ;
                                    opptyMessage.preferedTenderFormat = opp.Tender_Submission_Format__c!= null ? opp.Tender_Submission_Format__c:'' ;
                                    opptyMessage.expectedNegotiationRound = opp.Expected_Handling_Rounds__c;
                                    opptyMessage.customerRequestedRateStructure = opp.Customer_Requested_Rate_Structure__c !=null ?opp.Customer_Requested_Rate_Structure__c :'';
                                    opptyMessage.opportunityOfferType = opp.Offer_Type__c != null ?opp.Offer_Type__c :'' ;
                                    opptyMessage.isDoubleDown = opp.Double_Down__c;
                                    if(opp.Business_Process__c!= null){
                                        opptyMessage.businessProcesses= lstBusinessProcess;
                                    }
                                    opptyMessage.Customer.customerCode = opp.Account.Customer_Code__c != null ? opp.Account.Customer_Code__c: '';
                                    opptyMessage.Customer.customerName = opp.Account.Name;
                                    opptyMessage.Customer.concernCode = opp.Account.Concern_Code__c != null? opp.Account.Concern_Code__c:'';
                                    opptyMessage.Customer.isConcern = opp.Account.Represents_Concern__c;
                                    opptyMessage.opportunityTeam= oppTeamMembers;
                                    
                                    
                                    Map<Id,Set<String>> mapOppIdtoSetOliCargoTypes = new Map<Id,Set<String>>();//SFSE-14825
                                    for(Opportunity_Product__c oli: opp.Opportunity_Products__r) {
                                        
                                        //SFSE:14825 - Start
                                        if(mapOppIdtoSetOliCargoTypes.containsKey(oli?.OpportunityId__c)){
                                            if(oli?.Cargo_Type__c != null && oli?.Cargo_Type__c != '' && !mapOfOliandDeletion.containsKey(oli?.Id)){
                                                mapOppIdtoSetOliCargoTypes.get(oli?.OpportunityId__c)?.add(oli?.Cargo_Type__c);
                                            }
                                        }
                                        else{
                                            if(oli?.Cargo_Type__c != null && oli?.Cargo_Type__c != '' && !mapOfOliandDeletion.containsKey(oli?.Id)){
                                                mapOppIdtoSetOliCargoTypes.put(oli?.OpportunityId__c,new Set<String>{oli?.Cargo_Type__c});
                                            }
                                        }
                                        //SFSE:14825 - End
                                        
                                        // Used inn v4
                                        OpportunityProduct_z productwrapper = new OpportunityProduct_z();
                                        productwrapper.lineItemId = oli.Id;
                                        productwrapper.lineItemName = oli.Name;
                                        productwrapper.lineItemQuantity = String.valueof(oli.Quantity__c);
                                        productwrapper.cargoType = oli.Cargo_Type__c!= null ? oli.Cargo_Type__c :'' ;
                                        productwrapper.specialCargo = oli.Special_Cargo__c!= null ?oli.Special_Cargo__c:'';
                                        productwrapper.importExport = oli.Import_Export__c!= null  ?oli.Import_Export__c :'' ;
                                        productwrapper.grossProfit = oli.Total_Price__c;
                                        productwrapper.isoCurrencyCode = orgCurr;
                                        productwrapper.isLineItemDeleted = mapOfOliandDeletion.containsKey(oli.Id)? mapOfOliandDeletion.get(oli.Id) : false;
                
                                        List<Location> locationfunctions = new List<Location>();
                                        Location execCountry= new Location();
                                        execCountry.locationCode=  oli.Country__r.GEO_Code__c !=null ? oli.Country__r.GEO_Code__c: '';
                                        execCountry.locationFunction ='country';
                                        locationfunctions.add(execCountry);
                                        
                                        Location execstate= new Location();
                                        execstate.locationCode=  oli.Executing_City_State__r.GEO_Code__c !=null ? oli.Executing_City_State__r.GEO_Code__c: '';
                                        execstate.locationFunction ='state';
                                        locationfunctions.add(execstate);
                                        productwrapper.locations= locationfunctions;
                                        
                                        Route td = new Route();
                                        td.routeCode = oli.Trade_Route__r.Route_Code__c !=null ? oli.Trade_Route__r.Route_Code__c : '';
                                        td.routeName = oli.Trade_Route__r.Name != null ?oli.Trade_Route__r.Name :'' ;
                                        td.cardinalDirection = oli.Trade_Route__r.Direction__c!=null ? oli.Trade_Route__r.Direction__c :'' ;
                                        productwrapper.route = td;
                                        
                                        SelectedProduct selectpro= new SelectedProduct();
                                        Product prod= new Product();
                                        String prodVersion = oli.Product2ID__r.Version__c != null  &&  oli.Product2ID__r.Minor_Version__c != null && oli.Product2ID__r.Minor_Version__c >= 0 &&  oli.Product2ID__r.Increment_Version__c!= null &&  oli.Product2ID__r.Increment_Version__c > 0 ? oli.Product2ID__r.Version__c+'.'+oli.Product2ID__r.Minor_Version__c +'.'+ oli.Product2ID__r.Increment_Version__c : oli.Product2ID__r.Version__c != null  &&  oli.Product2ID__r.Minor_Version__c != null && oli.Product2ID__r.Minor_Version__c > 0 ?  oli.Product2ID__r.Version__c+'.'+oli.Product2ID__r.Minor_Version__c : String.valueOf(oli.Product2ID__r.Version__c);
                                        
                                        prod.productCode = oli.Product2ID__r.OIPC_Code__c;
                                        prod.productName = oli.Product2ID__r.Name;
                                        prod.productVersion = prodVersion;
                                        prod.productFamily.productFamilyCode = oli.Product2ID__r.Family_Code__c;
                                        prod.productFamily.productFamilyName = oli.Product_Family__c;
                                        prod.productFamily.productPortfolio = oli.Product2ID__r.Portfolio__c;
                                        selectpro.product= prod;
                                        productwrapper.selectedProduct = selectpro;
                                        oppMessage.opportunityLineItem.add(productwrapper); 
                                        
                                        
                                        

                                        //used in Opportunity v5 start
                                        OpportunityProduct opptyProductWrapper = new OpportunityProduct();
                                        opptyProductWrapper.lineItemId = oli.Id;
                                        opptyProductWrapper.lineItemName = oli.Name;
                                        opptyProductWrapper.lineItemQuantity = String.valueof(oli.Quantity__c);
                                        opptyProductWrapper.cargoType = oli.Cargo_Type__c!= null ? oli.Cargo_Type__c :'' ;
                                        opptyProductWrapper.specialCargo = oli.Special_Cargo__c!= null ?oli.Special_Cargo__c:'';
                                        opptyProductWrapper.transportActivity = oli.Import_Export__c!= null  ?oli.Import_Export__c : null;
                                        opptyProductWrapper.grossProfit = oli.Total_Price__c;
                                        opptyProductWrapper.isoCurrencyCode = orgCurr;
                                        opptyProductWrapper.isProductDeleted = mapOfOliandDeletion.containsKey(oli.Id)? mapOfOliandDeletion.get(oli.Id) : false;
                
                                        opptyProductWrapper.locations= locationfunctions;
                                        
                                        opptyProductWrapper.route = td;
                                        
                                        SelectedProduct_z selectProduct= new SelectedProduct_z();
                                        Product_z product= new Product_z();
                                       
                                        product.productCode = oli.Product2ID__r.OIPC_Code__c;
                                        product.productName = oli.Product2ID__r.Name;
                                        product.isAddon =oli.Product2ID__r.Definition_Type__c == 'Add-On Product' ? true:false;
                                        product.isProductSolution = oli.Product2ID__r.Definition_Type__c == 'Integrated Solution' || (oli.Solution__c != null && oli.Solution__r.Definition_Type__c == 'Packaged Solution' ) ? true:false;
                                        product.productVersion = prodVersion;

                                        SoftCodedValues definitationType=  new SoftCodedValues();
                                        definitationType.entityName='Product Overview';
                                        definitationType.attributeName= 'Product Definition Type';
                                        definitationType.value=oli.Product2ID__r.Definition_Type__c;

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
                                        selectProduct.product= product;
                                        selectProduct.product.productGroups = grouplst;
                                        selectProduct.product.softCodedValues = new List<SoftCodedValues>{definitationType};

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
                                            selectProduct.product.solution = sol; 
                                        }
                                        
                                        opptyProductWrapper.selectedProduct = selectProduct;
                                        opptyMessage.opportunityLineItem.add(opptyProductWrapper); 
                                        // Used in Opportunity V5 End
                                    }
                                    
                                    //SFSE-14825
                                    List<CargoType> lstCargoTypes = new List<CargoType>();
                                    if(!mapOppIdtoSetOliCargoTypes.isEmpty() && mapOppIdtoSetOliCargoTypes != NULL && mapOppIdtoSetOliCargoTypes.containsKey(opp.Id)){
                                        for(String cargoTypeStr : mapOppIdtoSetOliCargoTypes.get(opp.Id)){
                                            CargoType cargoTypeObj = new CargoType();
                                            cargoTypeObj.cargoTypeCode = cargoTypeStr?.toUpperCase();
                                            cargoTypeObj.cargoTypeName = cargoTypeStr;
                                            lstCargoTypes.add(cargoTypeObj);
                                        }
                                    }
                                    oppMessage.cargoTypeCode = (!lstCargoTypes.isEmpty() && lstCargoTypes.size() > 0) ? lstCargoTypes[0]?.cargoTypeName : '';//SFSE-14825 : for event v4
                                    opptyMessage.cargoTypes = (!lstCargoTypes.isEmpty() && lstCargoTypes.size() > 0) ? lstCargoTypes : new List<CargoType>();//SFSE-14825 : for event v5
                                    //SFSE-14825
                                    
                                    mapOpportunityResponse.put(opp.Id, oppMessage);
                                    mapOpptyResponse.put(opp.Id, opptyMessage);
                                    
                                } 
    }
    
    public static void getOppQuoteData(Set<Id> oppId) {
        
       // Map<String,OpportunityNegotiation_z> mapOfNegotiationV3 = new Map<String,OpportunityNegotiation_z>();
        //Map<Id,List<OpportunityNegotiation_z>> mapOfOppIdandListNegotiationV3 = new Map<Id,List<OpportunityNegotiation_z>>();
        Map<String,Id> mapOfOppandNegotiationV3 = new Map<String,Id>();
        
        Map<String,Negotiation_z> mapOfNegotiation = new Map<String,Negotiation_z>();
        //Map<Id,List<Negotiation_z>> mapOfOppIdandListNegotiation = new Map<Id,List<Negotiation_z>>();
        Map<String,Id> mapOfOppandNegotiation = new Map<String,Id>();
        
        //List<OpportunityNegotiation_z> returnQuotesFiles = new List<OpportunityNegotiation_z>();
        //List<Quote_Files_z> quoteFiles = new List<Quote_Files_z>();
        for (Opportunity_File__c oppFile : [SELECT File_Category__c, Name,Quote__c,File_Reference__c, Quote__r.Name,Quote__r.Round_Receipt_Date__c,Quote__r.Submission_Date__c, Quote__r.Negotiation_Id__c,Quote__r.Negotiation_Round__c, Quote__r.Status__c,Quote__r.Opportunity__c 
                                            FROM Opportunity_File__c WHERE Opportunity__c IN : oppId]){

                                                
                                                //Code used in OpportunityEvent V4
                                                Negotiation_z negotiation = new Negotiation_z();
                                                negotiation.negotiationId = oppFile.Quote__c;
                                                negotiation.receiptDate = convertToEpoch(oppFile.Quote__r.Round_Receipt_Date__c );
                                                negotiation.submissionDate = convertToEpoch(oppFile.Quote__r.Submission_Date__c );
                                                negotiation.negotiationRoundNumber = (Integer)oppFile.Quote__r.Negotiation_Round__c;
                                                
                                                if(!mapOfNegotiation.containsKey(oppFile.Quote__c)){
                                                    mapOfNegotiation.put(oppFile.Quote__c,negotiation);
                                                }
                                                if(!mapOfOppandNegotiation.containsKey(oppFile.Quote__c)){
                                                    mapOfOppandNegotiation.put(oppFile.Quote__c,oppFile.Quote__r.Opportunity__c );
                                                }
                                                
                                                Negotiation_Files_z quotFile = new Negotiation_Files_z();
                                                quotFile.fileCategory = oppFile.File_Category__c;
                                                String tempFileName = oppFile.Name;
                                                //String[] part = tempFileName.split('\\.');
                                                quotFile.fileExtension = tempFileName.right(tempFileName.length()- (tempFileName.lastindexOf('.') + 1));
                                                quotFile.fileName = oppFile.File_Reference__c+'-'+ tempFileName.substring(0,tempFileName.lastindexOf('.'));
                                                mapOfNegotiation.get(oppFile.Quote__c).negotiationFiles.add(quotFile);
                                            }
         
        
        //Code used in OpportunityEvent V4
        if(!mapOfOppandNegotiation.keySet().isEmpty()){
            for(String negotiationId:mapOfOppandNegotiation.keySet()){ //list of negotiation id
                if(mapOfNegotiation.containsKey(negotiationId)){
                    if(mapOfOppIdandListNegotiation.containsKey(mapOfOppandNegotiation.get(negotiationId))){
                        mapOfOppIdandListNegotiation.get(mapOfOppandNegotiation.get(negotiationId)).add(mapOfNegotiation.get(negotiationId));
                    }else{
                        mapOfOppIdandListNegotiation.put(mapOfOppandNegotiation.get(negotiationId),new List<Negotiation_z>{mapOfNegotiation.get(negotiationId)});
                    }
                }
            }
        }
    }
    
    //Code used in OpportunityEvent V4
    public static Map<ID,List<Offer_z>> getOppOfferInfo(Set<Id> oppId){
        
        Map<Id,List<Offer_z>> mapOfOppandOffer= new Map<Id,List<Offer_z>>();
        List<Offer_Information__c> lstOffer= new List<Offer_Information__c>();
        List<String> setOfEmail = new List<String>();
        Map<String,Contact> mapOfContact = new Map<String,Contact>();
        for(Offer_Information__c offer:[SELECT id, Accepted_by__r.Name, Accepted_by__r.Email, CreatedBy.Name, CreatedBy.email,Offer_Status__c, Date_Sent__c, Date_Accepted__c, To_Recipient__r.Name, 
                                        To_Recipient__r.Email, CC_Recipients__c, Opportunity__c  FROM Offer_Information__c WHERE  Opportunity__c IN: oppId ])
        {
            lstOffer.add(offer);
            if(offer.CC_Recipients__c!=null){
                setOfEmail.addAll(offer.CC_Recipients__c.split(','));
            }
            
        }
        
        if(!setOfEmail.isEmpty()){
            for(Contact cont:[SELECT id,Name,Email  FROM Contact WHERE Email IN: setOfEmail]){
                mapOfContact.put(cont.email,cont);
            }
        }
        
        if(!lstOffer.isEmpty()){
            for(Offer_Information__c offer:lstOffer){
                Offer_z off = new Offer_z();
                off.offerID = offer.id;
                off.offerStatusCode = offer.Offer_Status__c;
                off.offerSentDate = offer.Date_Sent__c != null ? convertToEpoch(offer.Date_Sent__c): 0 ;
                off.offerAcceptedDate = offer.Date_Accepted__c != null ? convertToEpoch(offer.Date_Accepted__c) : 0 ;
                List<Recipient> recipients = new List<Recipient>();
                
                Recipient toRecipient = new Recipient();
                toRecipient.name = offer.To_Recipient__r.Name;
                toRecipient.emailAddress = offer.To_Recipient__r.Email;
                toRecipient.isMainRecipient = true;
                
                recipients.add(toRecipient);
                
                if(offer.CC_Recipients__c!=null){
                    for(String email : offer.CC_Recipients__c.split(',')){
                        Recipient ccRecipient= new Recipient();
                        ccRecipient.name = mapOfContact.containsKey(email) ? mapOfContact.get(email).name : '' ;
                        ccRecipient.emailAddress = mapOfContact.containsKey(email) ? mapOfContact.get(email).email : email ;
                        ccRecipient.isMainRecipient =false;
                        recipients.add(ccRecipient);
                    }
                }
                
                off.recipient = recipients;
                off.createdBy.emailAddress = offer.createdBy.email != null ?offer.createdBy.email:'';
                off.createdBy.name = offer.CreatedBy.Name!= null ?offer.CreatedBy.Name: '';
                
                off.acceptedBy.name = offer.Accepted_by__r.Name!= null ? offer.Accepted_by__r.Name:'';
                off.acceptedBy.emailAddress = offer.Accepted_by__r.Email != null ?offer.Accepted_by__r.Email:'' ;
                
                if(mapOfOppandOffer.containsKey(offer.Opportunity__c)){
                    mapOfOppandOffer.get(offer.Opportunity__c).add(off);
                }else{
                    mapOfOppandOffer.put(offer.Opportunity__c, new List<Offer_z>{off});
                }
            }
        }
        
        return mapOfOppandOffer;
    }
}