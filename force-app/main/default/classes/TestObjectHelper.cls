/**
 * @description Helper class used to create raw objects, using the SmartFactory class.
 * @author Ronnie@SF
 * @date 10-10-2022
 * 
 * Ref. Number		Date			Developer				Description
 * ----------		-----------		-------------------		--------------------------------------------------------------------
 * SFSE-11869		19-07-23		Shashi@Maersk			Product Specification Parameter (Product_Specification_Parameter__c)
 * SFSE-11870		19-07-23		Shashi@Maersk			Product Specification Option (Product_Specification_Option__c)
 * SFSE-11157		22-Jul-23		Kiran@Maersk			OMEB 3.1 Objects test data creation helper methods
 * SFSE-11872       24-Jul-23       Shashi@Maersk           Opportunity Product Configuration (Opportunity_Product_Configuration__c)
 * SFSE-11873       24-Jul-23       Ritika@Maersk           Sales Target (Target__c)
 * SFSE-11875       24-Jul-23       Ritika@Maersk           Sales Target Item Group (Target_Item_Group__c)
 * SFSE-11874       24-Jul-23       Ritika@Maersk           Sales Target Item (Target_Item__c)
 * SFSE-12135       14-Aug-23       Shashi@Maersk           Feedback (Feedback_Data__c)
 * SFSE-12140       14-Aug-23       Rohan@Maersk            Offer Information (Offer_Information__c)
 * SFSE-12136       16-Aug-23       Shashi@Maersk           Feedback Invite (Feedback_Invite__c)
 * SFSE-12180       16-Aug-23       Shashi@Maersk           Feedback What Object (Feedback_What_Object__c)
 * SFSE-12139	    22-Aug-23       Shashi@Maersk           Feedback Response (Feedback_Response__c)
 * SFSE-12137	    22-Aug-23       Shashi@Maersk           Feedback Question (Feedback_Question__c)
 * SFSE-12138	    22-Aug-23       Shashi@maersk           Feedback Question Response (Feedback_Question_Response)
 * SFSE-12287	    22-Aug-23       Shashi@maersk           Feedback (Feedback__c)
 * SC-8746          07-Aug-23       Richa@Maersk            Shipment object, Geography with Geo Code, Ocean Plus Lead object and Service Relationship object
 * SFSE-12180       16-Aug-23       Shashi@Maersk           Feedback What Object (Feedback_What_Object__c)
 * SFSE-12299		28-Aug-23		Ritika@Maersk			Sales Target Product Exclusion (Target_Product_Exclusion__c)
 * SFSE-12298		28-Aug-23		Ritika@Maersk			Sales Target Item Measure (Target_Measure__c)
 * SFSE-12297		28-Aug-23		Ritika@Maersk			Sales Target Load Data (Target_Data_Load__c)
 * SFSE-12296		28-Aug-23		Ritika@Maersk			Sales Target Brand Mapping (Target_Brand_Mapping__c)
 * SFSE-12394		28-Aug-23		Ritika@Maersk			Legacy Product Mapping (Legacy_Product_Mapping__c)
 * SFSE-12301       05-Sep-23       Shashi@Maersk           Sales Budget Group (Budget_Group__c)
 * SFSE-12302    	12-Sep-23       Rohan@Maersk            Sales Budget Measure (Budget_Measure__c)
 * SFSE-12300    	13-Sep-23       Rohan@Maersk            Target Setting Staging (Target_Setting_Staging__c)
 * SFSE-12883       04-Oct-23       Rohan@Maersk      		Sales Target Approval Matrix (Target_Stage_Matrix__c)
 * SFSE-12911       05-Oct-23       Rohan@Maersk      		Sales Target Approval User (Target_Reviewer__c)
 * SC-9582 	        03-Jan-24       Richa@Maersk            Shipment Party object (Party__c)
 * SC-9545 	    	08-Jan-24       Vivek@Maersk            Case Recommendation object (Case_Recommendation__c)
 * SFSE-12654		05-Feb-24		Avinash@Maersk			Clone and auto-renew an opportunity with the latest solution version
 * SFSE-13634		02-Apr-24		Jothsana@Maersk			Create Segmentation Matrix and Segment Data Records 
 */
 
@isTest
public class TestObjectHelper {
    
    /**
     * @description Creates an admin user record
     * @param create
     * @return user
     */
    public static User createAdminUser(Boolean create) {
        User user = (User)SmartFactory.createSObject('User', false, create);
        return user;
    }
    
    /**
     * @description Creates a user record based on the profile name passed into the method
     * @param fieldValues
     * @param create
     * @return user
     */
    public static User createUser(Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('User', new Set<String>{ 'Cluster__c', 'Country', 'Liner_Brand__c', 'Maersk_User_Id__c' });
        User user = (User)SmartFactory.createSObject('User', false, fieldValues, create);
        return user;
    }
    
    /**
     * @description Creates a list of User records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return users
     */
    public static List<User> createUsers(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('User', new Set<String>{ 'Cluster__c', 'Country', 'Liner_Brand__c', 'Maersk_User_Id__c' });
        List<User> users = SmartFactory.createSObjectList('User', numberOfObjects, fieldValues, create);
        return users;
    }
    
    /**
     * @description Creates a geography record, needed in order to insert a user
     * @param fieldValues
     * @param create
     * @return geography
     */
    public static Geography__c createGeography(Map<String, Object> fieldValues, Boolean create) {
        Geography__c geography = (Geography__c)SmartFactory.createSObject('Geography__c', false, fieldValues, create);
        return geography;
    }
    
    /**
     * @description Creates a list of Geography__c records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return geography
     */
    public static List<Geography__c> createGeographies(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Geography__c> geographies = SmartFactory.createSObjectList('Geography__c', numberOfObjects, fieldValues, create);
        return geographies;
    }
    
    /**
     * @description Creates an account record
     * @param fieldValues
     * @param create
     * @return account
     */
    public static Account createAccount(Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Account', new Set<String>{ 'MSL_Account_Owner__c', 'MCC_Account_Owner__c' });
        Account account = (Account)SmartFactory.createSObject('Account', false, fieldValues, create);
        return account;
    }
    
    /**
     * @description Creates a list of accounts
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return accounts
     */
    public static List<Account> createAccounts(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Account', new Set<String>{ 'MSL_Account_Owner__c', 'MCC_Account_Owner__c' });
        List<Account> accounts = new List<Account>();
        accounts = SmartFactory.createSObjectList('Account', numberOfObjects, fieldValues, create);
        return accounts;
    }
    
    /**
     * @description Creates a contact record and associates it to an account
     * @param account
     * @param fieldValues
     * @param create
     * @return contact
     */
    public static Contact createContact(Account account, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Contact', new Set<String>{ 'Phone' });
        Contact contact = (Contact)SmartFactory.createSObject('Contact', false, fieldValues, create);
        contact.AccountId = account.Id;
        return contact;
    }
    
    /**
     * @description Creates a lead
     * @param fieldValues
     * @param brand
     * @param create
     * @return lead
     */
    public static Lead createLead(Map<String, Object> fieldValues, String brand, Boolean create) {
        SmartFactory.ExcludedFields.put('Lead', new Set<String>{ 'IsConverted' });
        SmartFactory.IncludedFields.put('Lead', new Set<String>{ 'Company', 'Email', 'LeadSource', 'Name', 'Status' });
        Lead lead = (Lead)SmartFactory.createSObject('Lead', false, fieldValues, create);
        return lead;
    }
    
    /**
     * @description Creates an opportunity record and associates it to an account and contact (if provided)
     * @param account
     * @param contact
     * @param fieldValues
     * @param create
     * @return opp
     */
    public static Opportunity createOpportunity(Account account, Contact contact, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Opportunity', new Set<String>{ 'Primary_Contact__c' });
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity', false, fieldValues, create);
        opp.AccountId = account.Id;
        opp.Primary_Contact__c = contact != null ? contact.Id : null;
        return opp;
    }
    
    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param fieldValues
     * @param create
     * @return oli
     */
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opportunity, Map<String, Object> fieldValues, Boolean create) {
        OpportunityLineItem oli = (OpportunityLineItem)SmartFactory.createSObject('OpportunityLineItem', false, fieldValues, create);
        return oli;
    }
    
    /**
     * @description Creates an opportunity team member
     * @param user
     * @param opportunity
     * @param fieldValues
     * @param teamRole
     * @param create
     * @return otm
     */
    public static OpportunityTeamMember createOpportunityTeamMember(User user, Opportunity opportunity, Map<String, Object> fieldValues, String teamRole, Boolean create) {
        OpportunityTeamMember otm = (OpportunityTeamMember)SmartFactory.createSObject('OpportunityTeamMember', false, fieldValues, create);
        return otm;
    }
    
    /**
     * @description Creates a contract
     * @param account
     * @param fieldValues
     * @param create
     * @return con
     */
    public static Contract__c createContract(Account account, Map<String, Object> fieldValues, Boolean create) {
        Contract__c con = (Contract__c)SmartFactory.createSObject('Contract__c', false, fieldValues, create);
        con.Customer__c = account.Id;
        return con;
    }
    
    /**
     * @description Creates an opportunity contract
     * @param opportunity
     * @param contract
     * @param fieldValues
     * @param create
     * @return oppCon
     */
    public static Opportunity_Contract__c createOpportunityContract(Opportunity opportunity, Contract__c contract, Map<String, Object> fieldValues, Boolean create) {
        Opportunity_Contract__c oppCon = (Opportunity_Contract__c)SmartFactory.createSObject('Opportunity_Contract__c', false, fieldValues, create);
        oppCon.Contract__c = contract.Id;
        oppCon.Opportunity__c = opportunity.Id;
        return oppCon;
    }
    
    /**
     * @description Creates a product
     * @param fieldValues
     * @param create
     * @return product
     */
    public static Product2 createProduct2(Map<String, Object> fieldValues, Boolean create) {
        Product2 product = (Product2)SmartFactory.createSObject('Product2', false, fieldValues, create);
        return product;
    }
    
    /**
     * @description Creates a list of products
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return products
     */
    public static List<Product2> createProduct2s(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Product2', new Set<String>{ 'Route_Direction_Code__c' });
        List<Product2> products = SmartFactory.createSObjectList('Product2', numberOfObjects, fieldValues, create);
        return products;
    }
    
    /**
     * @description Creates a list of product components
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return productComponents
     */
    public static List<Product_Component__c> createProductComponents(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Product_Component__c> productComponents = SmartFactory.createSObjectList('Product_Component__c', numberOfObjects, fieldValues, create);
        return productComponents;
    }
    
    /**
     * @description Creates a list of product features
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return productFeatures
     */
    public static List<Product_Feature__c> createProductFeatures(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Product_Feature__c> productFeatures = SmartFactory.createSObjectList('Product_Feature__c', numberOfObjects, fieldValues, create);
        return productFeatures;
    }
    
    /**
     * @description Creates a list of opportunity product features
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return opportunityProductFeatures
     */
    public static List<Opportunity_Product_Feature__c> createOpportunityProductFeatures(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Opportunity_Product_Feature__c> opportunityProductFeatures = SmartFactory.createSObjectList('Opportunity_Product_Feature__c', numberOfObjects, fieldValues, create);
        return opportunityProductFeatures;
    }
    
    /**
     * @description Creates a list of trade routes
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return tradeRoutes
     */
    public static List<Trade_Route__c> createTradeRoutes(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Trade_Route__c> tradeRoutes = SmartFactory.createSObjectList('Trade_Route__c', numberOfObjects, fieldValues, create);
        return tradeRoutes;
    }
    
    /**
     * @description Creates a case record
     * @param fieldValues
     * @param create
     * @return c
     */
    public static Case createCase(Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Case', new Set<String>{ 'Country__c' });
        Case c = (Case)SmartFactory.createSObject('Case', false, fieldValues, create);
        return c;
    }
    
    /**
     * @description Creates a list of case records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return cases
     */
    public static List<Case> createCases(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Case', new Set<String>{ 'Country__c' });
        List<Case> cases = SmartFactory.createSObjectList('Case', numberOfObjects, fieldValues, create);
        return cases;
    }
    
    /**
     * @description Creates a BDA record
     * @param fieldValues
     * @param create
     * @return bda
     */
    public static BDA__c createBDA(Map<String, Object> fieldValues, Boolean create) {
        BDA__c bda = (BDA__c)SmartFactory.createSObject('BDA__c', false, fieldValues, create);
        return bda;
    }
    
    /**
     * @description Creates a list of BDA records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return bdas
     */
    public static List<BDA__c> createBDAs(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<BDA__c> bdas = SmartFactory.createSObjectList('BDA__c', numberOfObjects, fieldValues, create);
        return bdas;
    }
    
    /**
     * @description Create a BDA Geography record
     * @param fieldValues
     * @param create
     * @return BDA_Geography__c
     */
    public static BDA_Geography__c createBDAGeography(Map<String, Object> fieldValues, Boolean create) {
        BDA_Geography__c bdaGeography = (BDA_Geography__c)SmartFactory.createSObject('BDA_Geography__c', false, fieldValues, create);
        return bdaGeography;
    }
    
    /**
     * @description Creates a list of BDA Geography records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return bdaGeographies
     */
    public static List<BDA_Geography__c> createBDAGeographies(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<BDA_Geography__c> bdaGeographies = SmartFactory.createSObjectList('BDA_Geography__c', numberOfObjects, fieldValues, create);
        return bdaGeographies;
    }
    
    /**
     * @description Creates a Group record
     * @param fieldValues
     * @param create
     * @return g
     */
    public static Group createGroup(Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.ExcludedFields.put('Group', new Set<String>{ 'DoesIncludeBosses' });
        Group g = (Group)SmartFactory.createSObject('Group', false, fieldValues, create);
        return g;
    }
    
    /**
     * @description Creates a QueueSobject record
     * @param fieldValues
     * @param create
     * @return q
     */
    public static QueueSobject createQueuesObject(Map<String, Object> fieldValues, Boolean create) {
        QueueSobject q = (QueueSobject)SmartFactory.createSObject('QueueSobject', false, fieldValues, create);
        return q;
    }
    
    /**
     * @description Creates an Incident record
     * @param fieldValues
     * @param create
     * @return incident
     */
    public static Incident__c createIncident(Map<String, Object> fieldValues, Boolean create) {
        Incident__c incident = (Incident__c)SmartFactory.createSObject('Incident__c', false, fieldValues, create);
        return incident;
    }
    
    /**
     * @description Creates a list of incidents  records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return incidents
     */
    public static List<Incident__c> createIncidents(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Incident__c> incidents = SmartFactory.createSObjectList('Incident__c', numberOfObjects, fieldValues, create);
        return incidents;
    }
    
    /**
     * @description Creates a Vessel record
     * @param fieldValues
     * @param create
     * @return vessel
     */
    public static Vessel__c createVessel(Map<String, Object> fieldValues, Boolean create) {
        Vessel__c vessel = (Vessel__c)SmartFactory.createSObject('Vessel__c', false, fieldValues, create);
        return vessel;
    }
    
    /**
     * @description Creates a list of Rate_Structure_Item_List__c records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return rateStructureItemLists
     */
    public static List<Rate_Structure_Item_List__c> createRateStructureItemLists(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Rate_Structure_Item_List__c', new Set<String>{ 'Charge_Name__c', 'New_Code__c', 'Type__c', 'Sales_Approach__c', 'Charge_Type__c', 'Occurrence__c', 'Cargo_type__c' });
        List<Rate_Structure_Item_List__c> rateStructureItemLists = SmartFactory.createSObjectList('Rate_Structure_Item_List__c', numberOfObjects, fieldValues, create);
        return rateStructureItemLists;
    }
    
    /**
     * @description Creates a Rate_Structure_Item_List__c record
     * @param fieldValues
     * @param create
     * @return rateStructureItemList
     */
    public static Rate_Structure_Item_List__c createRateStructureItemList(Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.IncludedFields.put('Rate_Structure_Item_List__c', new Set<String>{ 'Charge_Name__c', 'New_Code__c', 'Type__c', 'Sales_Approach__c', 'Charge_Type__c', 'Occurrence__c', 'Cargo_type__c' });
        Rate_Structure_Item_List__c rateStructureItemList = (Rate_Structure_Item_List__c)SmartFactory.createSObject('Rate_Structure_Item_List__c', false, fieldValues, create);
        return rateStructureItemList;
    }
    
    /**
     * @description Creates a Rate_Structure__c record
     * @param fieldValues
     * @param create
     * @return rateStructure
     */
    public static Rate_Structure__c createRateStructure(Map<String, Object> fieldValues, Boolean create) {
        Rate_Structure__c rateStructure = (Rate_Structure__c)SmartFactory.createSObject('Rate_Structure__c', false, fieldValues, create);
        return rateStructure;
    }
    
    /**
     * @description Creates a Corridor_Guidance__c record
     * @param fieldValues
     * @param create
     * @return corridorGuidance
     */
    public static Corridor_Guidance__c createCorridorGuidance(Map<String, Object> fieldValues, Boolean create) {
        Corridor_Guidance__c corridorGuidance = (Corridor_Guidance__c)SmartFactory.createSObject('Corridor_Guidance__c', false, fieldValues, create);
        return corridorGuidance;
    }
    
    /**
     * @description Creates a Corridor_Guidance_Detail__c record
     * @param fieldValues
     * @param create
     * @return corridorGuidanceDetail
     */
    public static Corridor_Guidance_Detail__c createCorridorGuidanceDetail(Map<String, Object> fieldValues, Boolean create) {
        Corridor_Guidance_Detail__c corridorGuidanceDetail = (Corridor_Guidance_Detail__c)SmartFactory.createSObject('Corridor_Guidance_Detail__c', false, fieldValues, create);
        return corridorGuidanceDetail;
    }
    
    /**
     * @description Creates a Environment_Variables__c record
     * @param fieldValues
     * @return environmentVariable
     */
    public static Environment_Variables__c createEnvironmentVariable(Map<String, Object> fieldValues) {
        Environment_Variables__c environmentVariable = (Environment_Variables__c)SmartFactory.createSObject('Environment_Variables__c', false, fieldValues, true);
        return environmentVariable;
    }
    
    /**
     * @description Creates a Request__c record
     * @param fieldValues
     * @param create
     * @return request
     */
    public static Request__c createRequest(Map<String, Object> fieldValues, Boolean create) {
        //SmartFactory.IncludedFields.put('Request__c', new Set<String>{ 'Primary_Key__c' });
        Request__c request = (Request__c)SmartFactory.createSObject('Request__c', false, fieldValues, create);
        return request;
    }
    
    /**
     * @description Creates a Request_Detail__c record
     * @param fieldValues
     * @param create
     * @return requestDetail
     */
    public static Request_Detail__c createRequestDetail(Map<String, Object> fieldValues, Boolean create) {
        Request_Detail__c requestDetail = (Request_Detail__c)SmartFactory.createSObject('Request_Detail__c', false, fieldValues, create);
        return requestDetail;
    }
    
    /**
     * @description Creates a list of Pricing_Management__c records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return pricingManagements
     */
    public static List<Pricing_Management__c> createPricingManagements(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Pricing_Management__c> pricingManagements = SmartFactory.createSObjectList('Pricing_Management__c', numberOfObjects, fieldValues, create);
        return pricingManagements;
    }
    
    /**
     * @description Creates a list of Task records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return tasks
     */
    public static List<Task> createTasks(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.ExcludedFields.put('Task', new Set<String>{ 'IsRecurrence' });
        List<Task> tasks = SmartFactory.createSObjectList('Task', numberOfObjects, fieldValues, create);
        return tasks;
    }
    
    /**
     * @description Creates a list of Event records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return events
     */
    public static List<Event> createEvents(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        SmartFactory.ExcludedFields.put('Event', new Set<String>{ 'IsRecurrence' });
        List<Event> events = SmartFactory.createSObjectList('Event', numberOfObjects, fieldValues, create);
        return events;
    }
    
    /**
     * @description Creates a Business_Plan__c record
     * @param fieldValues
     * @param create
     * @return businessPlan
     */
    public static Business_Plan__c createBusinessPlan(Map<String, Object> fieldValues, Boolean create) {
        Business_Plan__c businessPlan = (Business_Plan__c)SmartFactory.createSObject('Business_Plan__c', false, fieldValues, create);
        return businessPlan;
    }
    
    /**
     * @description Creates a Sales_Call__c record
     * @param fieldValues
     * @param create
     * @return salesCall
     */
    public static Sales_Call__c createSalesCall(Map<String, Object> fieldValues, Boolean create) {
        Sales_Call__c salesCall = (Sales_Call__c)SmartFactory.createSObject('Sales_Call__c', false, fieldValues, create);
        return salesCall;
    }
    
    /**
     * @description Creates a list of Quote records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return quotes
     */
    public static List<Quote> createQuotes(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Quote> quotes = SmartFactory.createSObjectList('Quote', numberOfObjects, fieldValues, create);
        return quotes;
    }
    
    /**
     * @description Creates an Attachment record
     * @param fieldValues
     * @param create
     * @return attachment
     */
    public static Attachment createAttachment(Map<String, Object> fieldValues, Boolean create) {
        Attachment attachment = (Attachment)SmartFactory.createSObject('Attachment', false, fieldValues, create);
        return attachment;
    }
    
    /**
     * @description Creates an Initiative__c record
     * @param fieldValues
     * @param create
     * @return initiative
     */
    public static Initiative__c createInitiative(Map<String, Object> fieldValues, Boolean create) {
        Initiative__c initiative = (Initiative__c)SmartFactory.createSObject('Initiative__c', false, fieldValues, create);
        return initiative;
    }
    
    /**
     * @description Creates a Relink_Contact_Childs__c record
     * @param fieldValues
     * @param create
     * @return relinkContactChilds
     */
    public static Relink_Contact_Childs__c createRelinkContactChilds(Map<String, Object> fieldValues, Boolean create) {
        Relink_Contact_Childs__c relinkContactChilds = (Relink_Contact_Childs__c)SmartFactory.createSObject('Relink_Contact_Childs__c', false, fieldValues, create);
        return relinkContactChilds;
    }
    
    /**
     * @description Creates a list of Qt_Quote__c records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return quotes
     */
    public static List<Qt_Quote__c> createQtQuotes(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Qt_Quote__c> quotes = SmartFactory.createSObjectList('Qt_Quote__c', numberOfObjects, fieldValues, create);
        return quotes;
    }
    
    /**
     * @description Creates a AFLS_Quote_Attachment__c record
     * @param fieldValues
     * @param create
     * @return aFLSQuoteAttachment
     */
    public static AFLS_Quote_Attachment__c createAFLSQuoteAttachment(Map<String, Object> fieldValues, Boolean create) {
        AFLS_Quote_Attachment__c aFLSQuoteAttachment = (AFLS_Quote_Attachment__c)SmartFactory.createSObject('AFLS_Quote_Attachment__c', false, fieldValues, create);
        return aFLSQuoteAttachment;
    }
    
    /**
     * @description Creates a SIP_KPI__c record
     * @param fieldValues
     * @param create
     * @return sipKPI
     */
    public static SIP_KPI__c createSIPKPI(Map<String, Object> fieldValues, Boolean create) {
        SIP_KPI__c sipKPI = (SIP_KPI__c)SmartFactory.createSObject('SIP_KPI__c', false, fieldValues, create);
        return sipKPI;
    }
    
    /**
     * @description Creates a list of SIP_Payout_Curve__c records
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return sipPayoutCurves
     */
    public static List<SIP_Payout_Curve__c> createSIPPayoutCurves(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<SIP_Payout_Curve__c> sipPayoutCurves = SmartFactory.createSObjectList('SIP_Payout_Curve__c', numberOfObjects, fieldValues, create);
        return sipPayoutCurves;
    }
    
    /**
     * @description Creates a Request_Information__c record
     * @param fieldValues
     * @param create
     * @return requestInformation
     */
    public static Request_Information__c createRequestInformation(Map<String, Object> fieldValues, Boolean create) {
        Request_Information__c requestInformation = (Request_Information__c)SmartFactory.createSObject('Request_Information__c', false, fieldValues, create);
        return requestInformation;
    }
    
    /**
     * @description Creates a Campaign record
     * @param fieldValues
     * @param create
     * @return campaign
     */
    public static Campaign createCampaign(Map<String, Object> fieldValues, Boolean create) {
        Campaign campaign = (Campaign)SmartFactory.createSObject('Campaign', false, fieldValues, create);
        return campaign;
    }
 
    /**
     * @description Creates a CampaignMember record
     * @param fieldValues
     * @param create
     * @return campaignMember
     */
    public static CampaignMember createCampaignMember(Map<String, Object> fieldValues, Boolean create) {
        CampaignMember campaignMember = (CampaignMember)SmartFactory.createSObject('CampaignMember', false, fieldValues, create);
        return campaignMember;
    }
    
    /**
     * @description Creates a Stakeholder__c record
     * @param fieldValues
     * @param create
     * @return stakeHolder
     */
    public static Stakeholder__c createStakeHolder(Map<String, Object> fieldValues, Boolean create) {
        Stakeholder__c stakeHolder = (Stakeholder__c)SmartFactory.createSObject('Stakeholder__c', false, fieldValues, create);
        return stakeHolder;
    }
    
    /**
     * @description Creates a Territory__c record
     * @param fieldValues
     * @param create
     * @return territory
     */
    public static Territory__c createTerritory(Map<String, Object> fieldValues, Boolean create) {
        Territory__c territory = (Territory__c)SmartFactory.createSObject('Territory__c', false, fieldValues, create);
        return territory;
    }
    
    /**
     * @description Creates a Territory_Account_Association__c record
     * @param fieldValues
     * @param create
     * @return territoryAccountAssociation
     */
    public static Territory_Account_Association__c createTerritoryAccountAssociation(Map<String, Object> fieldValues, Boolean create) {
        Territory_Account_Association__c territoryAccountAssociation = (Territory_Account_Association__c)SmartFactory.createSObject('Territory_Account_Association__c', false, fieldValues, create);
        return territoryAccountAssociation;
    }
    
    /**
     * @description Creates a User_Cluster__c record
     * @param fieldValues
     * @param create
     * @return userCluster
     */
    public static User_Cluster__c createUserCluster(Map<String, Object> fieldValues, Boolean create) {
        User_Cluster__c userCluster = (User_Cluster__c)SmartFactory.createSObject('User_Cluster__c', false, fieldValues, create);
        return userCluster;
    }
       
    /**
     * @description Creates a New_Hire_Module__c record
     * @param fieldValues
     * @param create
     * @return newHireModule
     */
    public static New_Hire_Module__c createNewHireModule(Map<String, Object> fieldValues, Boolean create) {
        New_Hire_Module__c newHireModule = (New_Hire_Module__c)SmartFactory.createSObject('New_Hire_Module__c', false, fieldValues, create);
        return newHireModule;
    }
    
    /**
     * @description Creates a New_Hire_Assignments__c record
     * @param fieldValues
     * @param create
     * @return newHireAssignment
     */
    public static New_Hire_Assignments__c createNewHireAssignment(Map<String, Object> fieldValues, Boolean create) {
        New_Hire_Assignments__c newHireAssignment = (New_Hire_Assignments__c)SmartFactory.createSObject('New_Hire_Assignments__c', false, fieldValues, create);
        return newHireAssignment;
    }
    
    /**
     * @description Creates an Onboarding_Plan__c record
     * @param fieldValues
     * @param create
     * @return onboardingPlan
     */
    public static Onboarding_Plan__c createOnboardingPlan(Map<String, Object> fieldValues, Boolean create) {
        Onboarding_Plan__c onboardingPlan = (Onboarding_Plan__c)SmartFactory.createSObject('Onboarding_Plan__c', false, fieldValues, create);
        return onboardingPlan;
    }
    
    /**
     * SFSE-11869
     * @description Creates a list of Product Specification Parameters
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return productSpecificationParameters
     */
    public static List<Product_Specification_Parameter__c> createProductSpecificationParameters(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Product_Specification_Parameter__c> productSpecificationParameters = SmartFactory.createSObjectList('Product_Specification_Parameter__c', numberOfObjects, fieldValues, create);
        return productSpecificationParameters;
    }

    /**
     * SFSE-11870
     * @description Creates a list of Product Specification Options
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return productSpecificationOptions
     */
    public static List<Product_Specification_Option__c> createProductSpecificationOptions(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Product_Specification_Option__c> productSpecificationOptions = SmartFactory.createSObjectList('Product_Specification_Option__c', numberOfObjects, fieldValues, create);
        return productSpecificationOptions;
    }   
    
    /**
     * SFSE-11873	
     * @description Creates a Sales Target
     * @param fieldValues
     * @param create
     * @return SalesTargets
     */
    
    public static Target__c createSalesTarget(Map<String, Object> fieldValues, Boolean create) {
        Target__c SalesTarget = (Target__c)SmartFactory.createSObject('Target__c', false, fieldValues, create);
        return SalesTarget;
    }
    
    /**
     * SFSE-11873	
     * @description Creates a list of Sales Target
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return SalesTargets
     */
    public static List<Target__c> createSalesTargets(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target__c> SalesTargets = SmartFactory.createSObjectList('Target__c', numberOfObjects, fieldValues, create);
        return SalesTargets;
    }
    
    /**
     * SFSE-11875	
     * @description Creates a Sales Target Item Group
     * @param fieldValues
     * @param create
     * @return SalesTargetItemGroup
     */
     public static Target_Item_Group__c createSalesTargetItemGroup(Map<String, Object> fieldValues, Boolean create) {
        Target_Item_Group__c SalesTargetItemGroup = (Target_Item_Group__c)SmartFactory.createSObject('Target_Item_Group__c', fieldValues, create);
        return SalesTargetItemGroup;
    } 
    
    /**
     * SFSE-11875	
     * @description Creates a list of Sales Target Item Group
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return SalesTargetItemGroup
     */
     public static List<Target_Item_Group__c> createSalesTargetItemGroups(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Item_Group__c> SalesTargetItemGroups = SmartFactory.createSObjectList('Target_Item_Group__c', numberOfObjects, fieldValues, create);
        return SalesTargetItemGroups;
    }  
    
     /**
     * SFSE-11874	
     * @description Creates a Sales Target Item
     * @param fieldValues
     * @param create
     * @return SalesTargetItem
     */
    public static Target_Item__c createSalesTargetItem(Map<String, Object> fieldValues, Boolean create) {
        Target_Item__c SalesTargetItem = (Target_Item__c)SmartFactory.createSObject('Target_Item__c', fieldValues, create);
        return SalesTargetItem;
    }
    
    /**
     * SFSE-11874	
     * @description Creates a list of Sales Target Item
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return SalesTargetItems
     */
    public static List<Target_Item__c> createSalesTargetItems(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Item__c> SalesTargetItems = SmartFactory.createSObjectList('Target_Item__c', numberOfObjects, fieldValues, create);
        return SalesTargetItems;
    }

    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param fieldValues
     * @param create
     * @return oliCustom
     */
    public static Opportunity_Product__c createOpportunityLineItemCustom(Opportunity opportunity, Map<String, Object> fieldValues, Boolean create) {
        Opportunity_Product__c oliCustom = (Opportunity_Product__c)SmartFactory.createSObject('Opportunity_Product__c', false, fieldValues, create);
        return oliCustom;
    }
    
    /**
     * @description Creates an Approval Process record
     * @param fieldValues
     * @param create
     * @return approvalProcess
     */
    public static Approval_Process__c createApprovalProrcess(Map<String, Object> fieldValues, Boolean create) {
        Approval_Process__c approvalProcess = (Approval_Process__c)SmartFactory.createSObject('Approval_Process__c', false, fieldValues, create);
        return approvalProcess;
    }
    
    /**
     * @description Creates an Approval Process Matrix record
     * @param fieldValues
     * @param create
     * @return approvalProcessMatrix
     */
    public static Approval_Process_Escalation_Matrix__c createApprovalProrcessMatrix(Map<String, Object> fieldValues, Boolean create) {
        Approval_Process_Escalation_Matrix__c approvalProcessMatrix = (Approval_Process_Escalation_Matrix__c)SmartFactory.createSObject('Approval_Process_Escalation_Matrix__c', false, fieldValues, create);
        return approvalProcessMatrix;
    }
    
    /**
     * @description Creates list of opportunity product configurations
     * @param number of objects
     * @param fieldValues
     * @param create
     * @return List<Opportunity_Product_Configuration__c>
     */
    public static List<Opportunity_Product_Configuration__c> createOpportunityProductConfigurations(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Opportunity_Product_Configuration__c> OpportunityProductConfigurations = SmartFactory.createSObjectList('Opportunity_Product_Configuration__c', numberOfObjects, fieldValues, create);
        return OpportunityProductConfigurations;
    }  
    
    /**
     * @description Creates list of Parent BDAs
     * @param number of objects
     * @param fieldValues
     * @param create
     * @return List<Parent_BDA__c>
     */    
    public static List<Parent_BDA__c> createParentBDAs(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create){
        List<Parent_BDA__c> parentBDAs = SmartFactory.createSObjectList('Parent_BDA__c', numberOfObjects, fieldValues, create);
        return parentBDAs;
    }
    
    /**
     * @description Create OfferInformation
     * @param fieldValues
     * @param create
     * @return Offer_Information__c
     */  
    public static Offer_Information__c createOfferInformation(Map<String, Object> fieldValues, Boolean create) {
        Offer_Information__c offerInformation = (Offer_Information__c)SmartFactory.createSObject('Offer_Information__c',false, fieldValues, create);
        return offerInformation;
    }
        /**
     * @description Create a List of OfferInformation
     * @param fieldValues
     * @param create
	 * @param numberOfObjects
     * @return List<Offer_Information__c>
     */  
    public static List<Offer_Information__c> createOfferInformations(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Offer_Information__c> offerInformations = SmartFactory.createSObjectList('Offer_Information__c',numberOfObjects, fieldValues, create);
        return offerInformations;
    }
    /**
     * @description Create Feedback_Data__c
     * @param fieldValues
     * @param create
     * @return Feedback_Data__c
     */  
    public static Feedback_Data__c createFeedbackData(Map<String, Object> fieldValues, Boolean create) {
        Feedback_Data__c feedbackData = (Feedback_Data__c)SmartFactory.createSObject('Feedback_Data__c',false, fieldValues, create);
        return feedbackData;
    }
    /**
     * @description Create List<Feedback_Data__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_Data__c>
     */
    public static List<Feedback_Data__c> createFeedbackDatas(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_Data__c> feedbackDatas = SmartFactory.createSObjectList('Feedback_Data__c', numberOfObjects, fieldValues, create);
        return feedbackDatas;
    }
    /**
     * @description Create Feedback_What_Object__c
     * @param fieldValues
     * @param create
     * @return Feedback_What_Object__c
     */  
    public static Feedback_What_Object__c createFeedbackWhatObject(Map<String, Object> fieldValues, Boolean create) {
        Feedback_What_Object__c feedbackWhatObj = (Feedback_What_Object__c)SmartFactory.createSObject('Feedback_What_Object__c',false, fieldValues, create);
        return feedbackWhatObj;
    }
    
    /**
     * @description Create List<Feedback_What_Object__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_What_Object__c>
     */  
    public static List<Feedback_What_Object__c> createFeedbackWhatObjects(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_What_Object__c> feedbackWhatObjects = SmartFactory.createSObjectList('Feedback_What_Object__c', numberOfObjects, fieldValues, create);
        return feedbackWhatObjects;
    }
    /**
     * @description Create Feedback_Invite__c
     * @param fieldValues
     * @param create
     * @return Feedback_Invite__c
     */  
    public static Feedback_Invite__c createFeedbackInvite(Map<String, Object> fieldValues, Boolean create) {
        Feedback_Invite__c feedbackInvite = (Feedback_Invite__c)SmartFactory.createSObject('Feedback_Invite__c',false, fieldValues, create);
        return feedbackInvite;
    }
    /**
     * @description Create List<Feedback_Invite__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_Invite__c>
     */  
    public static List<Feedback_Invite__c> createFeedbackInvites(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_Invite__c> feedbackInvites = SmartFactory.createSObjectList('Feedback_Invite__c', numberOfObjects, fieldValues, create);
        return feedbackInvites;
    }
    /**
     * @description Create Feedback_Response__c
     * @param fieldValues
     * @param create
     * @return Feedback_Response__c
     */ 
    public static Feedback_Response__c createFeedbackResponse(Map<String, Object> fieldValues, Boolean create) {
        Feedback_Response__c feedbackResponse = (Feedback_Response__c)SmartFactory.createSObject('Feedback_Response__c',false, fieldValues, create);
        return feedbackResponse;
    }
    /**
     * @description Create List<Feedback_Response__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_Response__c>
     */     
    public static List<Feedback_Response__c> createFeedbackResponses(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_Response__c> feedbackResponses = SmartFactory.createSObjectList('Feedback_Response__c', numberOfObjects, fieldValues, create);
        return feedbackResponses;
    }
    /**
     * @description Create Feedback_Question__c
     * @param fieldValues
     * @param create
     * @return Feedback_Question__c
     */     
    public static Feedback_Question__c createFeedbackQuestion(Map<String, Object> fieldValues, Boolean create) {
        Feedback_Question__c feedbackQuestion = (Feedback_Question__c)SmartFactory.createSObject('Feedback_Question__c', false, fieldValues, create);
        return feedbackQuestion;
    }
     /**
     * @description Create List<Feedback_Question__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_Question__c>
     */  
    public static List<Feedback_Question__c> createFeedbackQuestions(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_Question__c> feedbackQuestions = SmartFactory.createSObjectList('Feedback_Question__c', numberOfObjects, fieldValues, create);
        return feedbackQuestions;
    }
    /**
     * @description Create Feedback_Question_Response__c
     * @param fieldValues
     * @param create
     * @return Feedback_Question_Response__c
     */     
    public static Feedback_Question_Response__c createFeedbackQuestionResponse(Map<String, Object> fieldValues, Boolean create) {
        Feedback_Question_Response__c feedbackQuestionResponse = (Feedback_Question_Response__c)SmartFactory.createSObject('Feedback_Question_Response__c', false, fieldValues, create);
        return feedbackQuestionResponse;
    }
     /**
     * @description Create List<Feedback_Question_Response__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback_Question_Response__c>
     */
    public static List<Feedback_Question_Response__c> createFeedbackQuestionResponses(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback_Question_Response__c> feedbackQuestionResponses = SmartFactory.createSObjectList('Feedback_Question_Response__c', numberOfObjects, fieldValues, create);
        return feedbackQuestionResponses;
    }
    /**
     * @description Create Feedback__c
     * @param fieldValues
     * @param create
     * @return Feedback__c
     */   
    public static Feedback__c createFeedback(Map<String, Object> fieldValues, Boolean create) {
        Feedback__c feedback = (Feedback__c)SmartFactory.createSObject('Feedback__c',false, fieldValues, create);
        return feedback;
    }
     /**
     * @description Create List<Feedback__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Feedback__c>
     */
    public static List<Feedback__c> createFeedbacks(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Feedback__c> feedbacks = SmartFactory.createSObjectList('Feedback__c', numberOfObjects, fieldValues, create);
        return feedbacks;
    }
     
     /**
     * SC-8746	
     * @description Creates a Shipment
     * @param fieldValues
     * @param create
     * @return Shipment
     */
     public static Shipment__c createShipment(Map<String, Object> fieldValues, Boolean create) {  
        Shipment__c shp = (Shipment__c)SmartFactory.createSObject('Shipment__c', false, fieldValues, create);
        return shp;
    } 
    
     /**
     * SC-8746	
     * @description Creates an OceanPlusLead
     * @param fieldValues
     * @param create
     * @return OceanPlusLead
     */
     public static Ocean_Plus_Lead__c createOceanPlusLead(Map<String, Object> fieldValues, Boolean create) {  
        Ocean_Plus_Lead__c opl = (Ocean_Plus_Lead__c)SmartFactory.createSObject('Ocean_Plus_Lead__c', false, fieldValues, create);
        return opl;
    } 
    
     /**
     * SC-8746	
     * @description Creates a ServiceRelationship
     * @param fieldValues
     * @param create
     * @return ServiceRelationship
     */
     public static Care_Relationship__c createServiceRelationship(Map<String, Object> fieldValues, Boolean create) {  
        Care_Relationship__c care = (Care_Relationship__c)SmartFactory.createSObject('Care_Relationship__c', false, fieldValues, create);
        return care;
    }   
    
    /**
     * @description Create Target_Product_Exclusion__c
     * @param fieldValues
     * @param create
     * @return Target_Product_Exclusion__c
     */
    
    public static Target_Product_Exclusion__c createSalesTargetProductExclusion(Map<String, Object> fieldValues, Boolean create) {
        Target_Product_Exclusion__c SalesTargetProductExclusion = (Target_Product_Exclusion__c)SmartFactory.createSObject('Target_Product_Exclusion__c', false, fieldValues, create);
        return SalesTargetProductExclusion;
    }
    
	/**
     * @description Create List<Target_Product_Exclusion__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Target_Product_Exclusion__c>
     */
    public static List<Target_Product_Exclusion__c> createSalesTargetProductExclusions(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Product_Exclusion__c> SalesTargetProductExclusions = SmartFactory.createSObjectList('Target_Product_Exclusion__c', numberOfObjects, fieldValues, create);
        return SalesTargetProductExclusions;
    }
    
    /**
     * @description Create Target_Measure__c
     * @param fieldValues
     * @param create
     * @return Target_Measure__c
     */
    
    public static Target_Measure__c createSalesTargetItemMeasure(Map<String, Object> fieldValues, Boolean create) {
        Target_Measure__c SalesTargetItemMeasure = (Target_Measure__c)SmartFactory.createSObject('Target_Measure__c', false, fieldValues, create);
        return SalesTargetItemMeasure;
    }
    
    /**
     * @description Create List<Target_Measure__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Target_Measure__c>
     */
    public static List<Target_Measure__c> createSalesTargetItemMeasures(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Measure__c> SalesTargetItemMeasures = SmartFactory.createSObjectList('Target_Measure__c', numberOfObjects, fieldValues, create);
        return SalesTargetItemMeasures;
    }
    
    /**
     * @description Create Target_Data_Load__c
     * @param fieldValues
     * @param create
     * @return Target_Data_Load__c
     */
    public static Target_Data_Load__c createSalesTargetDataLoad(Map<String, Object> fieldValues, Boolean create) {
        Target_Data_Load__c SalesTargetDataLoad = (Target_Data_Load__c)SmartFactory.createSObject('Target_Data_Load__c', false, fieldValues, create);
        return SalesTargetDataLoad;
    }
    
    /**
     * @description Create List<Target_Data_Load__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Target_Data_Load__c>
     */
    public static List<Target_Data_Load__c> createSalesTargetDataLoads(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Data_Load__c> SalesTargetDataLoads = SmartFactory.createSObjectList('Target_Data_Load__c', numberOfObjects, fieldValues, create);
        return SalesTargetDataLoads;
    }
    
    /**
     * @description Create Target_Brand_Mapping__c
     * @param fieldValues
     * @param create
     * @return Target_Brand_Mapping__c
     */
    public static Target_Brand_Mapping__c createSalesTargetBrandMapping(Map<String, Object> fieldValues, Boolean create) {
        Target_Brand_Mapping__c SalesTargetBrandMapping = (Target_Brand_Mapping__c)SmartFactory.createSObject('Target_Brand_Mapping__c', false, fieldValues, create);
        return SalesTargetBrandMapping;
    }
    
    /**
     * @description Create List<Target_Brand_Mapping__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Target_Brand_Mapping__c>
     */
    public static List<Target_Brand_Mapping__c> createSalesTargetBrandMappings(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Brand_Mapping__c> SalesTargetBrandMappings = SmartFactory.createSObjectList('Target_Brand_Mapping__c', numberOfObjects, fieldValues, create);
        return SalesTargetBrandMappings;
    }

    /**
     * @description Create Legacy_Product_Mapping__c
     * @param fieldValues
     * @param create
     * @return Legacy_Product_Mapping__c
     */
    public static Legacy_Product_Mapping__c createSalesTargetProductMapping(Map<String, Object> fieldValues, Boolean create) {
        Legacy_Product_Mapping__c SalesTargetProductMapping = (Legacy_Product_Mapping__c)SmartFactory.createSObject('Legacy_Product_Mapping__c', false, fieldValues, create);
        return SalesTargetProductMapping;
    }
    
    /**
     * @description Create List<Legacy_Product_Mapping__c>
     * @param numberOfObjects
     * @param fieldValues
     * @param create
     * @return List<Legacy_Product_Mapping__c>
     */
    public static List<Legacy_Product_Mapping__c> createSalesTargetProductMappings(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Legacy_Product_Mapping__c> SalesTargetProductMappings = SmartFactory.createSObjectList('Legacy_Product_Mapping__c', numberOfObjects, fieldValues, create);
        return SalesTargetProductMappings;
    }
    
    
    public static Budget_Group__c createSalesBudgetGroup(Map<String, Object> fieldValues, Boolean create) {
        Budget_Group__c SalesBudgetGroup = (Budget_Group__c)SmartFactory.createSObject('Budget_Group__c', false, fieldValues, create);
        return SalesBudgetGroup;
    }
    
    public static List<Budget_Group__c> createSalesBudgetGroups(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Budget_Group__c> SalesBudgetGroups = SmartFactory.createSObjectList('Budget_Group__c', numberOfObjects, fieldValues, create);
        return SalesBudgetGroups;
    }
    
    /**
     * @description Create budget measure
     * @param fieldValues
     * @param create
     * @return Budget_Measure__c
     */  
    
    public static Budget_Measure__c createBudgetMeasure(Map<String, Object> fieldValues, Boolean create) {
        Budget_Measure__c budgetMeasure = (Budget_Measure__c)SmartFactory.createSObject('Budget_Measure__c',false, fieldValues, create);
        return budgetMeasure;
    }
    
        /**
     * @description Create a List of BudgetMeasures
     * @param fieldValues
     * @param create
	 * @param numberOfObjects
     * @return List<Budget_Measure__c>
     */  
    
    public static List<Budget_Measure__c> createBudgetMeasures(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Budget_Measure__c> budgetMeasures = SmartFactory.createSObjectList('Budget_Measure__c',numberOfObjects, fieldValues, create);
        return budgetMeasures;
    }

  /**
     * @description Create targetSettingStage
     * @param fieldValues
     * @param create
     * @return Target_Setting_Staging__c
     */  

    public static Target_Setting_Staging__c createTargetSettingStage(Map<String, Object> fieldValues, Boolean create) {
        Target_Setting_Staging__c targetSettingStage = (Target_Setting_Staging__c)SmartFactory.createSObject('Target_Setting_Staging__c',false, fieldValues, create);
        return targetSettingStage;

    }

      /**
     * @description Create a List of BudgetMeasures
     * @param fieldValues
     * @param create
	 * @param numberOfObjects
     * @return List<Budget_Measure__c>
     */  

    public static List<Target_Setting_Staging__c> createTargetSettingStages(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Setting_Staging__c> targetSettingStages = SmartFactory.createSObjectList('Target_Setting_Staging__c',numberOfObjects, fieldValues, create);
        return targetSettingStages;

    }
      /**
     * @description Create SalesTargetApprovalMatrix
     * @param fieldValues
     * @param create
     * @return Target_Stage_Matrix__c
     */  

    public static Target_Stage_Matrix__c createSalesTargetApprovalMatrix(Map<String, Object> fieldValues, Boolean create) {
        Target_Stage_Matrix__c salesTargetApprovalMatrix = (Target_Stage_Matrix__c)SmartFactory.createSObject('Target_Stage_Matrix__c',false, fieldValues, create);
        return salesTargetApprovalMatrix;

    }

      /**
     * @description Create a List of SalesTargetApprovalMatrix
     * @param fieldValues
     * @param create
	 * @param numberOfObjects
     * @return List<Target_Stage_Matrix__c>
     */  

    public static List<Target_Stage_Matrix__c> createSalesTargetApprovalMatrixs(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Stage_Matrix__c> salesTargetApprovalMatrixs = SmartFactory.createSObjectList('Target_Stage_Matrix__c',numberOfObjects, fieldValues, create);
        return salesTargetApprovalMatrixs;

    }
    
      /**
     * @description Create sales Target Approval User
     * @param fieldValues
     * @param create
     * @return Target_Reviewer__c
     */  

    public static Target_Reviewer__c createSalesTargetApprovalUser(Map<String, Object> fieldValues, Boolean create) {
        Target_Reviewer__c salesTargetApprovalUser = (Target_Reviewer__c)SmartFactory.createSObject('Target_Reviewer__c',false, fieldValues, create);
        return salesTargetApprovalUser;

    }

      /**
     * @description Create a List of sales Target Approval User
     * @param fieldValues
     * @param create
	 * @param numberOfObjects
     * @return List<Target_Reviewer__c>
     */  

    public static List<Target_Reviewer__c> createSalesTargetApprovalUsers(Integer numberOfObjects, Map<String, Object> fieldValues, Boolean create) {
        List<Target_Reviewer__c> salesTargetApprovalUsers = SmartFactory.createSObjectList('Target_Reviewer__c',numberOfObjects, fieldValues, create);
        return salesTargetApprovalUsers;

    }

    /**
     * SC-8746	
     * @description Creates a IntegrationStaging
     * @param fieldValues
     * @param create
     * @return IntegrationStaging
     */
     public static Integration_Staging__c createIntegrationStaging(Map<String, Object> fieldValues, Boolean create) {  
        Integration_Staging__c ins = (Integration_Staging__c)SmartFactory.createSObject('Integration_Staging__c', false, fieldValues, create);
        return ins;
    }  

    /**
     * SC-8746	
     * @description Creates a IntegrationResults
     * @param fieldValues
     * @param create
     * @return IntegrationResult
     */
     public static Integration_Results__c createIntegrationResults(Map<String, Object> fieldValues, Boolean create) {  
        Integration_Results__c inRes = (Integration_Results__c)SmartFactory.createSObject('Integration_Results__c', false, fieldValues, create);
        return inRes;
    }
    
    /**
     * @description Creates EmailMessage
     * @param fieldValues
     * @param create
     * @return EmailMessage
     */
     public static EmailMessage createEmailMessage(Map<String, Object> fieldValues, Boolean create) {  
        EmailMessage emMsg = (EmailMessage)SmartFactory.createSObject('EmailMessage', false, fieldValues, create);
        return emMsg;
    }
    
    /**
     * @description Creates ContentVersion
     * @param fieldValues
     * @param create
     * @return ContentVersion
     */
     public static ContentVersion createContentVersion(Map<String, Object> fieldValues, Boolean create) {  
        ContentVersion cv = (ContentVersion)SmartFactory.createSObject('ContentVersion', false, fieldValues, create);
        return cv;
    }
    
    /**
     * @description Creates ContentDocumentLink
     * @param fieldValues
     * @param create
     * @return ContentDocumentLink
     */
     public static ContentDocumentLink createContentDocumentLink(Map<String, Object> fieldValues, Boolean create) {  
        ContentDocumentLink cdl = (ContentDocumentLink)SmartFactory.createSObject('ContentDocumentLink', false, fieldValues, create);
        return cdl;
    }
    
    /**
     * @description Creates Booking_Information__c
     * @param fieldValues
     * @param create
     * @return Booking_Information__c
     */
     public static Booking_Information__c createBookingInformation(Map<String, Object> fieldValues, Boolean create) {  
        Booking_Information__c bookInfo = (Booking_Information__c)SmartFactory.createSObject('Booking_Information__c', false, fieldValues, create);
        return bookInfo;
    }
    
    /**
     * @description Creates External_Party__c
     * @param fieldValues
     * @param create
     * @return External_Party__c
     */
     public static External_Party__c createExternalParty(Map<String, Object> fieldValues, Boolean create) {  
        External_Party__c extParty = (External_Party__c)SmartFactory.createSObject('External_Party__c', false, fieldValues, create);
        return extParty;
    }
    
    /**
     * @description Creates Case_Recommendation__c
     * @param fieldValues
     * @param create
     * @return Case_Recommendation__c
     */
     public static Case_Recommendation__c createCaseRecommendation(Map<String, Object> fieldValues, Boolean create) {  
        Case_Recommendation__c caseRecomm = (Case_Recommendation__c)SmartFactory.createSObject('Case_Recommendation__c', false, fieldValues, create);
        return caseRecomm;
    }
    
    /**
     * @description Creates Equipment_Commodity__c
     * @param fieldValues
     * @param create
     * @return Equipment_Commodity__c
     */
     public static Equipment_Commodity__c createEquipmentCommodity(Map<String, Object> fieldValues, Boolean create) {  
        Equipment_Commodity__c equipCom = (Equipment_Commodity__c)SmartFactory.createSObject('Equipment_Commodity__c', false, fieldValues, create);
        return equipCom;
    }
    
    /**
     * @description Creates Feature_CM__c
     * @param fieldValues
     * @param create
     * @return Feature_CM__c
     */
     public static Feature_CM__c createFeature(Map<String, Object> fieldValues, Boolean create) {  
        Feature_CM__c featureRec = (Feature_CM__c)SmartFactory.createSObject('Feature_CM__c', false, fieldValues, create);
        return featureRec;
    }
    
    /**
     * @description Creates Specification_Parameter_CM__c
     * @param fieldValues
     * @param create
     * @return Specification_Parameter_CM__c
     */
     public static List<Specification_Parameter_CM__c> createSpecParams(Integer numberOfObjects,Map<String, Object> fieldValues, Boolean create) {  
        //Specification_Parameter_CM__c specParam = (Specification_Parameter_CM__c)SmartFactory.createSObject('Specification_Parameter_CM__c', false, fieldValues, create);
       	List<Specification_Parameter_CM__c> specParams = SmartFactory.createSObjectList('Specification_Parameter_CM__c', numberOfObjects, fieldValues, create);
         return specParams;
    }
    
    /**
     * @description Creates Specification_Option_CM__c
     * @param fieldValues
     * @param create
     * @return List of Specification_Option_CM__c
     */
     public static List<Specification_Option_CM__c> createSpecOptions(Integer numberOfObjects,Map<String, Object> fieldValues, Boolean create) {  
         List<Specification_Option_CM__c> specOptions = SmartFactory.createSObjectList('Specification_Option_CM__c', numberOfObjects, fieldValues, create);
         //Specification_Option_CM__c specOption = (Specification_Option_CM__c)SmartFactory.createSObject('Specification_Option_CM__c', false, fieldValues, create);
        return specOptions;
    }
    
     /**
     * SC-9582 	
     * @description Creates a Shipment Party
     * @param fieldValues
     * @param create
     * @return Shipment
     */
     public static Party__c createShipmentParty(Map<String, Object> fieldValues, Boolean create) {  
        Party__c prty = (Party__c)SmartFactory.createSObject('Party__c', false, fieldValues, create);
        return prty;
    }
    
    public static Target_Customer_Portfolio__c createTCP(Map<String, Object> fieldValues, Boolean create) {  
        Target_Customer_Portfolio__c tcp = (Target_Customer_Portfolio__c)SmartFactory.createSObject('Target_Customer_Portfolio__c', false, fieldValues, create);
        return tcp;
    }
    
    //SFSE-12654
    public static Product_Reference__c createProductReference(Map<String, Object> fieldValues, Boolean create){
        Product_Reference__c prodRef = (Product_Reference__c)SmartFactory.createSObject('Product_Reference__c', false, fieldValues, create);
        return prodRef;
    }
    
    /**
     * SFSE-13634 	
     * @description Creates a Segmentation Matrix Record
     * @param fieldValues
     * @param create
     * @return Segmentation Matrix
     */
    public static Segmentation_Matrix__c createSegmentationMatrix(Map<String, Object> fieldValues, Boolean create){
        Segmentation_Matrix__c segmatrx = (Segmentation_Matrix__c)SmartFactory.createSObject('Segmentation_Matrix__c',false, fieldValues, create);
        return segmatrx;
    }
    
    /**
     * SFSE-13634 	
     * @description Creates a Segment Data Record
     * @param fieldValues
     * @param create
     * @return Segment Data
     */
    public static Segment_Data__c createSegmentData(Map<String, Object> fieldValues, Boolean create){
        Segment_Data__c segdata = (Segment_Data__c)SmartFactory.createSObject('Segment_Data__c',false, fieldValues, create);
        return segdata;
    }

    /**
     * SC-10027 	
     * @description Creates a ISR Template Record
     * @param fieldValues
     * @param create
     * @return ISR_Template__c Data
     */
    public static ISR_Template__c createISRTemplate(Map<String, Object> fieldValues, Boolean create){
        ISR_Template__c isrTempdata = (ISR_Template__c)SmartFactory.createSObject('ISR_Template__c',false, fieldValues, create);
        return isrTempdata;
    }

}