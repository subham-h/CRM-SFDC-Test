/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OpportunityeventV4 {
    public static Map<Id, OpportunityMessage> mapOpptyResponse = new Map<Id, OpportunityMessage>();    

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
        public String customerRequestedRateStructure {get;set;} 
        public long expectedTenderReceiptDate {get;set;} 
        public long firstRoundSubmissionDate {get;set;} 
        public String opportunityOfferType {get;set;} 
        public Boolean isDoubleDown {get;set;} 
        public Customer customer {get;set;} 
        public List<OpportunityTeam_z> opportunityTeam {get;set;} 
        public List<OpportunityProduct_z> opportunityLineItem {get;set;} 
        public List<Negotiation_z> negotiations {get;set;}
        public List<Offer_z> offers {get;set;}
        
        public OpportunityMessage() {
            opportunityTeam = new List<OpportunityTeam_z>();
            opportunityLineItem = new List<OpportunityProduct_z>();
            negotiations = new List<Negotiation_z>();
            offers =  new List<Offer_z>();
            customer = new Customer();
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

    public class OpportunityTeam_z {
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

    public class Results {
        @InvocableVariable
        public String serializedJSON1;
        @InvocableVariable
        public String serializedJSON2;
        @InvocableVariable
        public String serializedJSON3;
        @InvocableVariable
        public String serializedJSON4;
        
        public Results(){
            serializedJSON1 = '';
            serializedJSON2 = '';
            serializedJSON3 = '';
            serializedJSON4 = '';
        }
    }

    public static void prepareOppEventData (set<Id> oppId) {
        getOpportnityDetails(oppId);
        Map<Id,List<Negotiation_z>> mapofNegotiations = getOppQuoteData(oppId);
        Map<ID,List<Offer_z>> mapofOffer = getOppOfferInfo(oppId);

        for(Id opportunityId : oppId){
            OpportunityMessage ms= mapOpptyResponse.get(opportunityId);
            if(mapofNegotiations.containskey(opportunityId)){
                 ms.negotiations = mapofNegotiations.get(opportunityId);
            }
            if(mapofOffer.containsKey(opportunityId)){
                  ms.offers = mapofOffer.get(opportunityId);
            }
          
            system.debug('OpportunityMessage '+ms );
            System.debug(JSON.serialize(ms));
        }
    }
   
      
    public static Map<Id, OpportunityMessage> getOpportnityDetails(Set<Id> oppId) {
        String serializedOppWrapper = '';
        
        
        for (Opportunity opp : [SELECT Id,Offer_Type__c, Customer_Requested_Rate_Structure__c,Tender_Submission_Format__c,Opportunity_contains_Dangerous_Goods__c, IsClosed,Double_Down__c, First_Round_Submission_Date__c, Expected_Tender_Receipt_Date__c, Owner.Name,Cargo_Type__c,
                                Owner.country, Owner.Email, Owner.Maersk_User_Id__c, Account.Name, Account.Customer_Code__c, Account.Concern_Code__c, Account.Represents_Concern__c, Name, First_Shipment_Date__c, Last_Shipment_Date__c, Opportunity_Ref__c, Liner_brand__c, StageName, Type,
                                Reason_For_Close__c, IsWon, (SELECT id, Product_Family__c,Cargo_Type__c,OpportunityId__c, name, Product2ID__r.name,Product2ID__r.Route_Direction_Code__c, ProductCode__c,Trade_Route__r.Route_Code__c, Product2ID__r.family, Country__r.Name,Quantity__c,
                                Product2ID__r.Portfolio__c,Trade_Route__r.Operator__c,Trade_Route__r.Name,Trade_Route__r.Direction__c,Trade_Route__r.Route_Direction_Code__c,Product2ID__r.Family_Code__c,Product2ID__r.OIPC_Code__c,Special_Cargo__c,Import_Export__c,Country__r.GEO_Code__c,
                                Executing_City_State__r.GEO_Code__c,Product2ID__r.OIPC_Version__c FROM Opportunity_Products__r) ,(SELECT id,Name, TeamMemberRole, User.email,user.Maersk_User_Id__c,user.Geo_Code__c  FROM OpportunityTeamMembers )
                                FROM Opportunity WHERE Id IN: oppId]) {
                                    
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
                                    oppMessage.cargoTypeCode = opp.Cargo_Type__c != null ?opp.Cargo_Type__c:'' ;
                                    oppMessage.containsDangerousGoods = opp.Opportunity_contains_Dangerous_Goods__c != null? opp.Opportunity_contains_Dangerous_Goods__c:'' ;
                                    oppMessage.preferedTenderFormat = opp.Tender_Submission_Format__c!= null ? opp.Tender_Submission_Format__c:'' ;
                                    oppMessage.customerRequestedRateStructure = opp.Customer_Requested_Rate_Structure__c !=null ?opp.Customer_Requested_Rate_Structure__c :'';
                                    oppMessage.opportunityOfferType = opp.Offer_Type__c != null ?opp.Offer_Type__c :'' ;
                                    oppMessage.isDoubleDown = opp.Double_Down__c;
                                    
                                    oppMessage.Customer.customerCode = opp.Account.Customer_Code__c != null ? opp.Account.Customer_Code__c: '';
                                    oppMessage.Customer.customerName = opp.Account.Name;
                                    oppMessage.Customer.concernCode = opp.Account.Concern_Code__c != null? opp.Account.Concern_Code__c:'';
                                    oppMessage.Customer.isConcern = opp.Account.Represents_Concern__c;

                                    List<OpportunityTeam_z> oppTeamMember= new List<OpportunityTeam_z>();
                                    
                                    for(OpportunityTeamMember oppTeam:opp.OpportunityTeamMembers){
                                        OpportunityTeam_z oppT = new OpportunityTeam_z();
                                        oppT.associateName = oppTeam.Name ;
                                        oppT.associateUniqueCode = oppTeam.user.Maersk_User_Id__c !=null ? oppTeam.user.Maersk_User_Id__c : '';
                                        oppT.iso2CountryCode = oppTeam.user.Geo_Code__c ;
                                        oppT.emailAddress = oppteam.User.email;
                                        oppT.memberRoleName = oppTeam.TeamMemberRole;
                                        oppTeamMember.add(oppT);
                                    }
                                    
                                  
                                    oppMessage.opportunityTeam= oppTeamMember;


                                    for(Opportunity_Product__c oli: opp.Opportunity_Products__r) {
                                        
                                        OpportunityProduct_z productwrapper = new OpportunityProduct_z();
                                        productwrapper.lineItemId = oli.Id;
                                        productwrapper.lineItemName = oli.Name;
                                        productwrapper.lineItemQuantity = String.valueof(oli.Quantity__c);
                                        productwrapper.cargoType = oli.Cargo_Type__c!= null ? oli.Cargo_Type__c :'' ;
                                        productwrapper.specialCargo = oli.Special_Cargo__c!= null ?oli.Special_Cargo__c:'';
                                        productwrapper.importExport = oli.Import_Export__c!= null  ?oli.Import_Export__c :'' ;


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
                                        td.routeCode = oli.Trade_Route__r.Route_Direction_Code__c !=null ? oli.Trade_Route__r.Route_Direction_Code__c : '';
                                        td.routeName = oli.Trade_Route__r.Name != null ?oli.Trade_Route__r.Name :'' ;
                                        td.cardinalDirection = oli.Trade_Route__r.Direction__c!=null ? oli.Trade_Route__r.Direction__c :'' ;
                                        productwrapper.route = td;
                                        
                                        SelectedProduct selectpro= new SelectedProduct();
                                      
                                        Product prod= new Product();
                                        prod.productCode = oli.Product2ID__r.OIPC_Code__c;
                                        prod.productName = oli.Product2ID__r.Name;
                                        prod.productVersion = oli.Product2ID__r.OIPC_Version__c;
                                        prod.productFamily.productFamilyCode = oli.Product2ID__r.Family_Code__c;
                                        prod.productFamily.productFamilyName = oli.Product_Family__c;
                                        prod.productFamily.productPortfolio = oli.Product2ID__r.Portfolio__c;
                                        selectpro.product= prod;
                                        productwrapper.selectedProduct = selectpro;
                                        oppMessage.opportunityLineItem.add(productwrapper);                                        
                                    }
                                    mapOpptyResponse.put(opp.Id, oppMessage);
                                } 
        return mapOpptyResponse;
    }

    public static  Map<Id,List<Negotiation_z>> getOppQuoteData(Set<Id> oppId) {
        
        Map<String,Negotiation_z> mapOfNegotiation = new Map<String,Negotiation_z>();
        Map<Id,List<Negotiation_z>> mapOfOppIdandListNegotiation = new Map<Id,List<Negotiation_z>>();
        Map<String,Id> mapOfOppandNegotiation = new Map<String,Id>();
        // Map<String,List<Negotiation_Files_z>> mapofNegotiationFil= new map<String,List<Negotiation_Files_z>>();
    
        for (Opportunity_File__c oppFile : [SELECT File_Category__c, Name,Quote__c,File_Reference__c, Quote__r.Name, Quote__r.Negotiation_Id__c,Quote__r.Negotiation_Round__c, Quote__r.Status__c,Quote__r.Opportunity__c 
                                            FROM Opportunity_File__c WHERE Opportunity__c IN : oppId])
                                            {
                                                Negotiation_z negotiation = new Negotiation_z();
                                                negotiation.negotiationId = oppFile.Quote__c;
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
                                                String[] part = tempFileName.split('\\.');
                                                quotFile.fileExtension = part[1];
                                                quotFile.fileName = oppFile.File_Reference__c+'-'+part[0];
                                                mapOfNegotiation.get(oppFile.Quote__c).negotiationFiles.add(quotFile);
                                            }

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
        return mapOfOppIdandListNegotiation;                        
                                    
    }

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




    public static Long convertToEpoch(Date dt){
        Long epochDate;
        if(dt !=null) {
            Date dtToconVert = dt;
            Datetime dtTime = dtToconVert;
            epochDate = dtTime.getTime()/1000;
        }
        return epochDate;
    }
}