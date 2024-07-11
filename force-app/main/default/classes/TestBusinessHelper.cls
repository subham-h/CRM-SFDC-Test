/**
* @description Helper class used to create objects for unit tests from business use cases. It uses the TestObjectHelper class to construct the underlying objects.
* @author Ronnie@SF
* @date 10-10-2022  
*        
* Ref. Number   Date            Developer               Description 
* ----------    -----------     -------------------     --------------------------------------------------------------------
* SFSE-11869    19-07-23        Shashi@Maersk           Product Specification Parameter (Product_Specification_Parameter__c)
* SFSE-11870    19-07-23        Shashi@Maersk           Product Specification Option (Product_Specification_Option__c)
* SFSE-11871    20-07-23        Shashi@Maersk           Opportunity Product (Opportunity_Product__c)
* SFSE-11157    22-Jul-23       Kiran@Maersk            OMEB 3.1 Objects test data creation helper methods
* SFSE-11872    24-Jul-23       Shashi@Maersk           Opportunity Product Configuration (Opportunity_Product_Configuration__c)
* SFSE-11873    24-Jul-23       Ritika@Maersk           Sales Target (Target__c)
* SFSE-11875    24-Jul-23       Ritika@Maersk           Sales Target Item Group (Target_Item_Group__c)
* SFSE-11874    24-Jul-23       Ritika@Maersk           Sales Target Item (Target_Item__c)
* SFSE-12140    14-Aug-23       Rohan@Maersk            Offer Information (Offer_Information__c)
* SFSE-12135    14-Aug-23       Shashi@Maersk           Feedback (Feedback_Data__c)
* SFSE-12136    16-Aug-23       Shashi@Maersk           Feedback Invite (Feedback_Invite__c)
* SFSE-12139    22-Aug-23       Shashi@Maersk           Feedback Response (Feedback_Response__c)
* SFSE-12137    22-Aug-23       Shashi@Maersk           Feedback Question (Feedback_Question__c)
* SFSE-12138    22-Aug-23       Shashi@maersk           Feedback Question Response (Feedback_Question_Response)
* SFSE-12287    22-Aug-23       Shashi@maersk           Feedback (Feedback__c)
* SC-8746       07-Aug-23       Richa@Maersk            Shipment object, Geography with Geo Code, Ocean Plus Lead object and Service Relationship object
* SFSE-12299    28-Aug-23       Ritika@Maersk           Sales Target Product Exclusion (Target_Product_Exclusion__c)
* SFSE-12298    28-Aug-23       Ritika@Maersk           Sales Target Item Measure (Target_Measure__c)
* SFSE-12297    28-Aug-23       Ritika@Maersk           Sales Target Load Data (Target_Data_Load__c)
* SFSE-12296    28-Aug-23       Ritika@Maersk           Sales Target Brand Mapping (Target_Brand_Mapping__c)
* SFSE-12394    28-Aug-23       Ritika@Maersk           Legacy Product Mapping (Legacy_Product_Mapping__c)
* SFSE-12301    05-Sep-23       Shashi@Maersk           Sales Budget Group (Budget_Group__c)
* SFSE-12302    12-Sep-23       Rohan@Maersk            Sales Budget Measure (Budget_Measure__c)
* SFSE-12300    13-Sep-23       Rohan@Maersk            Target Setting Staging (Target_Setting_Staging__c)
* SFSE-12883    04-Oct-23       Rohan@Maersk            Sales Target Approval Matrix (Target_Stage_Matrix__c)
* SFSE-12911    05-Oct-23       Rohan@Maersk            Sales Target Approval User (Target_Reviewer__c)
* SC-9582       03-Jan-24       Richa@Maersk            Shipment Party object (Party__c)
* SC-9545       08-Jan-24       Vivek@Maersk            Case Recommendation object (Case_Recommendation__c)
* SFSE-12654    05-Feb-24       Avinash@Maersk          Clone and auto-renew an opportunity with the latest solution version
* SFSE-13634    02-Apr-24       Jothsana@Maersk         Create Segmentation Matrix and Segment Data Records
*/

@isTest
public class TestBusinessHelper {
    
    private static Integer counter = 0;
    
    /**
     * @description Creates an account based on record type
     * @param recordType
     * @param create
     * @return account
     */
    public static Account createAccount(String recordType, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'BillingStreet' => 'Test street ' + counter,
            'Customer_Group__c' => 'SCPI',
            'Name' => recordType,
            'SCV_Code__c' => 'test' + counter,
            'SCV_Status__c' => 'Active'
        };
        Account account = TestObjectHelper.createAccount(defaults, create);
        account.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        if (create) {
            insert account;
        }
        return account;
    }
    
    /**
     * @description Creates an account based on record type, with account owner and country
     * @param user
     * @param geography
     * @param recordType
     * @param create
     * @return account
     */
    public static Account createAccount(User user, Geography__c geography, String recordType, Boolean create) {
        Account account = createAccount(recordType, false);
        account.Id = null;
        account.Country__c = geography != null ? geography.Id : null;
        account.MSL_Account_Owner__c = user != null ? user.Id : null;
        if (create) {
            insert account;
        }
        return account;
    }
    
    /**
     * @description Creates a list of accounts, one for each record type passed in to the method
     * @param recordTypes
     * @param create
     * @return accounts
     */
    public static List<Account> createAccounts(List<String> recordTypes, Boolean create) {
        //Geography__c geography = createGeography('United Kingdom', 'Country', null, true);
        Integer amount = recordTypes.size();
        
        List<String> names = new List<String>();
        List<String> ids = new List<String>();
        List<String> scvCodes = new List<String>();
        for (Integer i = 0; i < recordTypes.size(); i++) {
            names.add(recordTypes[i]);
            ids.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypes[i]).getRecordTypeId());
            scvCodes.add('test' + i);
        }
        
        Map<String, Object> defaults = new Map<String, Object>{
            'BillingStreet' => 'Test street',
            //'Country__c' => geography.Id,
            'Customer_Group__c' => 'SCPI',
            'Name' => names,
            'RecordTypeId' => ids,
            'SCV_Code__c' => scvCodes,
            'SCV_Status__c' => 'Active'
        };
        List<Account> accounts = TestObjectHelper.createAccounts(amount, defaults, create);
        
        if (create) {
            insert accounts;
        }
        return accounts;
    }
    
    /**
     * @description Creates contact with brand and record types of account and contact as input
     * @param accRecordType
     * @param conRecordType
     * @param brand
     * @param create
     * @return contact
     */
    public static Contact createAccountAndContact(String accRecordType, String conRecordType, String brand, Boolean create) {
        Geography__c geography = createGeography('United Kingdom', 'Country', null, create);
        Map<String, Object> accDefaults = new Map<String, Object>{
            'Name' => accRecordType
        };
        Map<String, Object> conDefaults = new Map<String, Object>{
            'LastName' => conRecordType.remove('_'),
            'Email' => brand.deleteWhitespace() + '@test.com'
        };
        
        Account account = TestObjectHelper.createAccount(accDefaults, create);
        account.Country__c = geography.Id;
        account.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(accRecordType).getRecordTypeId();
        if (create) {
            insert account;
        }
        Contact contact = TestObjectHelper.createContact(account, conDefaults, create);
        contact.Country__c = account.Country__c;
        contact.Liner_Brands__c = brand;
        contact.RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(conRecordType).getRecordTypeId();
        if (create) {
            insert contact;
        }
        return contact;
    }
    
    /**
     * @description Creates contact with brand, account and contact record type as input
     * @param account
     * @param recordType
     * @param brand
     * @param create
     * @return contact
     */
    public static Contact createContact(Account account, String recordType, String brand, Boolean create) {
        counter++;
        String emailDomain = recordType.containsIgnoreCase('Internal') ? '@maerskline.com' : '@test.com';
        Map<String, Object> defaults = new Map<String, Object>{
            //'Phone' => '+44 123456',
            'Unique_User_ID__c' => 'Id' + counter,
            'LastName' => recordType.remove('_'),
            'Email' => recordType.remove('_') + brand.deleteWhitespace() + emailDomain
        };
        Contact contact = TestObjectHelper.createContact(account, defaults, create);
        contact.Country__c = account.Country__c;
        contact.Liner_Brand__c = brand;
        contact.Liner_Brands__c = brand;
        contact.Liner_Brands_Text__c = brand;
        contact.RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        if (create) {
            insert contact;
        }
        return contact;
    }
    
    /**
     * @description Creates contacts with different record types
     * @param account
     * @param recordTypes
     * @param brand
     * @param create
     * @return contacts
     */
    public static List<Contact> createContacts(Account account, List<String> recordTypes, String brand, Boolean create) {
        List<String> newRTs = new List<String>();
        for (String s : recordTypes) {
            newRTs.add(s.remove('_'));
        }        
        Map<String, Object> defaults = new Map<String, Object>{
            'LastName' => newRTs,
            'Liner_Brand__c' => brand,
            'Liner_Brands__c' => brand,
            'Liner_Brands_Text__c' => brand
        };
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < recordTypes.size(); i++) {
            String emailDomain = recordTypes[i] != null && recordTypes[i].containsIgnoreCase('Internal') ? '@maerskline.com' : '@test.com';            
            Contact con = TestObjectHelper.createContact(account, defaults, create);
            con.AccountId = account.Id;
            con.Email = recordTypes[i].remove('_') + brand.deleteWhitespace() + i + emailDomain;
            con.RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypes[i]).getRecordTypeId();
            con.Unique_User_ID__c = 'Id' + i;
            contacts.add(con);
        }
        if (create) {
            insert contacts;
        }
        return contacts;
    }
    
    /**
     * @description Creates a lead
     * @param brand
     * @param create
     * @return lead
     */
    public static Lead createLead (String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Test',
            'Liner_Brand__c' => brand,
            'Source_Brand__c' => brand
        };
        Lead lead = TestObjectHelper.createLead(defaults, brand, create);
        if (create) {
            insert lead;
        }
        return lead;
    }
    
    /**
     * @description Creates a lead
     * @param ownerId
     * @param campaignId
     * @param brand
     * @param create
     * @return lead
     */
    public static Lead createLead (Id ownerId, Id campaignId, String brand, Boolean create) {
        Lead lead = createLead(brand, false);
        lead.Id = null;
        lead.OwnerId = ownerId;
        lead.Primary_Campaign__c = campaignId;
        if (create) {
            insert lead;
        }
        return lead;
    }
    
    /**
     * @description Creates an opportunity with some pre-filled fields and links it to an account and, if provided, a contact
     * @param account
     * @param contact
     * @param user
     * @param recordType
     * @param brand
     * @param create
     * @return opportunity
     */
    public static Opportunity createOpportunity(Account account, Contact contact, User user, String recordType, String brand, Boolean create) {
        Map<String, Object> defaults;
        Id contactId = contact != null ? contact.Id : null;
        Id userId = user != null ? user.Id : null;
        
        defaults = new Map<String, Object>{
            'AccountId' => account.Id,
            'CloseDate' => date.today() + 10,
            'First_Shipment_Date__c' => date.today() + 30,
            'Last_Shipment_Date__c' => date.today() + 40,
            'Liner_Brand__c' => brand,
            'Name' => recordType,
            'Opp_Owners_Manager__c' => userId,
            'Primary_Contact__c' => contactId,
            'StageName' => 'Identifying',
            'Expected_Handling_Rounds__c' => 2.00
        };
        switch on recordType {
            when 'Opportunity_Record_Type' { // "Dry Opportunity"
                defaults.putAll(new Map<String, Object>{
                    'Cargo_Type__c' => 'DRY',
                    'Opportunity_contains_Dangerous_Goods__c' => 'No',
                    'Type' => 'Transactional'
                });
            }
            when 'ShippingCargoServices' { // "Tender Opportunity"
                defaults.putAll(new Map<String, Object>{
                    'Cargo_Type__c' => null,
                    'Commodity__c' => 'Pharmaceuticals',
                    'Customer_Requested_Rate_Structure__c' => 'Yes',
                    'Customer_Type__c' => 'BCO',
                    'Expected_Tender_Receipt_Date__c' => Date.today() + 360,
                    'First_Round_Submission_Date__c' => Date.today() + 400,
                    'Next_Steps__c' => ' ',
                    'Opportunity_contains_Dangerous_Goods__c' => 'Yes - Support Needed',
                    'Tender_Submission_Format__c' => 'Customer specific format',
                    'Tender_Type__c' => 'Complex',
                    'Type' => 'Acquisition'
                });
            }
            when 'Quarterly_Deal' { // "Quarterly Deal"
                defaults.putAll(new Map<String, Object>{
                    'Commodity__c' => 'Pharmaceuticals',
                    'Freetime_Terms__c' => 'No',
                    'Opportunity_contains_Dangerous_Goods__c' => 'No',
                    'Type' => 'Quarterly Deal Acquisition'
                });
            }
        }
        Opportunity opportunity = TestObjectHelper.createOpportunity(account, contact, defaults, create);
        opportunity.Named_Account__c = account.Id;
        opportunity.RecordTypeId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        if (create) {
            insert opportunity;
        }
        return opportunity;
    }
    
    /**
     * @description Creates an opportunity with some pre-filled fields and links it to an account and, if provided, a contact
     * @param account
     * @param contact
     * @param user
     * @param recordTypes
     * @param brand
     * @param create
     * @return opportunity
     */
    public static List<Opportunity> createOpportunities(Account account, Contact contact, User user, List<String> recordTypes, String brand, Boolean create) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (String rt : recordTypes) {
            Opportunity opp = createOpportunity(account, contact, user, rt, brand, false);
            opp.Id = null;
            opportunities.add(opp);
        }
        if (create) {
            insert opportunities;
        }
        return opportunities;
    }

    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param priceBookEntry
     * @param tradeRoute
     * @param create
     * @return opportunityLineItem
     */
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opportunity, PriceBookEntry priceBookEntry, Trade_Route__c tradeRoute, Boolean create) {
        if (tradeRoute == null) {
            tradeRoute = createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, create)[0];
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Country__c' => null,
            'OpportunityId' => opportunity.Id,
            'Opt_Out_Auto_Quantity_Scheduling__c' => false,
            'Quantity' => 1,
            'Trade_Route__c' => tradeRoute.Id,
            'Tender_Target__c' => 1,
            'UnitPrice' => 1
        };
        OpportunityLineItem opportunityLineItem = TestObjectHelper.createOpportunityLineItem(opportunity, defaults, true);
        opportunityLineItem.PriceBookEntryId = priceBookEntry.Id;
        if (create) {
            insert opportunityLineItem;
        }
        return opportunityLineItem;
    }
    
    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param priceBookEntry
     * @param tradeRoute
     * @param geography
     * @param create
     * @return opportunityLineItem
     */
    public static OpportunityLineItem createOpportunityLineItem(Opportunity opportunity, PriceBookEntry priceBookEntry, Trade_Route__c tradeRoute, Geography__c geography, Boolean create) {
        if (tradeRoute == null) {
            tradeRoute = createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, create)[0];
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Country__c' => geography.Id,
            'OpportunityId' => opportunity.Id,
            'Opt_Out_Auto_Quantity_Scheduling__c' => false,
            'Quantity' => 1,
            'Trade_Route__c' => tradeRoute.Id,
            'Tender_Target__c' => 1,
            'UnitPrice' => 1
        };
        OpportunityLineItem opportunityLineItem = TestObjectHelper.createOpportunityLineItem(opportunity, defaults, create);
        opportunityLineItem.PriceBookEntryId = priceBookEntry.Id;
        if (create) {
            insert opportunityLineItem;
        }
        return opportunityLineItem;
    }
    
    /**
     * @description Creates an OpportunityTeamMember
     * @param user
     * @param opportunity
     * @param teamRole
     * @param create
     * @return opportunityTeamMember
     */
    public static OpportunityTeamMember createOpportunityTeamMember(User user, Opportunity opportunity, String teamRole, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'UserId' => user.Id,
            'OpportunityId' => opportunity.Id,
            'TeamMemberRole' => teamRole
        };
        OpportunityTeamMember opportunityTeamMember = TestObjectHelper.createOpportunityTeamMember(user, opportunity, defaults, teamRole, create);
        if (create) {
            try {
                upsert opportunityTeamMember;
            } catch (Exception e) {
                for (ApexPages.Message msg : ApexPages.getMessages()) {
                    if (String.valueOf(msg) == Label.Error_User_Exists_As_Owner_Creator) {
                        System.assertEquals(Label.Error_User_Exists_As_Owner_Creator, msg.getSummary());
                    }
                }
            }
        }
        return opportunityTeamMember;
    }
    
    /**
     * @description Creates a contract (Contract__c) and links it to an account
     * @param account
     * @param brand
     * @param create
     * @return contract
     */
    public static Contract__c createContract(Account account, String brand, Boolean create) {
        if (account == null) {
            account = TestObjectHelper.createAccount(null, create);
            if (create) {
                insert account;
            }
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Agreement_Type_Code__c' => 'Credit_Agreement',
            'Brand_Name__c' => brand,
            'Customer__c' => account.Id,
            'Effective_Date__c' => System.today(),
            'Expiration_Date__c' => System.today() + 10,
            'Is_FMC_Contract__c' => false,
            'Is_Master_Contract__c' => false,
            'Status__c' => 'Draft'
        };
        Contract__c contract = TestObjectHelper.createContract(account, defaults, create);
        if (create) {
            insert contract;
        }
        return contract;
    }
    
    /**
     * @description Creates an opportunity contract
     * @param opportunity
     * @param contract
     * @param create
     * @return opportunityContract
     */
    public static Opportunity_Contract__c createOpportunityContract(Opportunity opportunity, Contract__c contract, Boolean create) {
        Opportunity_Contract__c  opportunityContract = TestObjectHelper.createOpportunityContract(opportunity, contract, null, create);
        if (create) {
            insert opportunityContract;
        }
        return opportunityContract;
    }
    
    /**
     * @description Creates a product
     * @param family
     * @param create
     * @return product
     */
    public static Product2 createProduct(String family, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test' + counter,
            'ProductCode' => 'A' + counter,
            'Direction__c' => 'DE' + counter,
            'Description' => 'Atlantic North',
            'IsActive' => true,
            'OIPC_Code__c'=>  'P_P0_Test'+ String.valueof(counter),
            'Family' => family,
            'Route_Direction_Code__c' => 'A' + counter +  'DE' + counter,
            'CanUseRevenueSchedule' => true,
            'CanUseQuantitySchedule' => true
        };
        Product2 product = TestObjectHelper.createProduct2(defaults, create);
        if (create) {
            insert product;
        }
        return product;
    }
    
    /**
     * @description Creates a list of products
     * @param family, amount, create
     * @return product
     */
    public static List<Product2> createProducts(List<String> family, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'ProductCode' => 'A',
            'Direction__c' => 'DE',
            'Description' => 'Atlantic North',
            'IsActive' => true,
            'OIPC_Code__c'=>  'P_P0_Test',
            'Family' => family,
            'CanUseRevenueSchedule' => true,
            'CanUseQuantitySchedule' => true
        };
        List<Product2> products = TestObjectHelper.createProduct2s(amount, defaults, create);
        if (create) {
            insert products;
        }
        return products;
    }
    
    /**
     * @description Creates a list of product components
     * @param products
     * @param amount
     * @param create
     * @return productComponents
     */
    public static List<Product_Component__c> createProductComponents(List<Product2> products, Integer amount, Boolean create) {
        List<Id> productIds = new List<Id>();
        for (Product2 p : products) {
            productIds.add(p.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Product__c' => productIds
        };
        List<Product_Component__c> productComponents = TestObjectHelper.createProductComponents(amount, defaults, create);
        if (create) {
            insert productComponents;
        }
        return productComponents;
    }
    
    /**
     * @description Creates a list of product features
     * @param productComponents
     * @param amount
     * @param create
     * @return productFeatures
     */
    public static List<Product_Feature__c> createProductFeatures(List<Product_Component__c> productComponents, Integer amount, Boolean create) {
        List<Id> productComponentIds = new List<Id>();
        for (Product_Component__c pc : productComponents) {
            productComponentIds.add(pc.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Enabled__c' => true,
            'Name' => 'Test',
            'Product_Component__c' => productComponentIds
            
        };
        List<Product_Feature__c> productFeatures = TestObjectHelper.createProductFeatures(amount, defaults, create);
        if (create) {
            insert productFeatures;
        }
        return productFeatures;
    }
    
    /**
     * @description Creates a list of product features
     * @param opportunityLineItem
     * @param productFeatures
     * @param create
     * @return opportunityProductFeatures
     */
    public static List<Opportunity_Product_Feature__c> createOpportunityProductFeatures(OpportunityLineItem opportunityLineItem, List<Product_Feature__c> productFeatures, Boolean create) {
        Integer amount = productFeatures.size();
        List<Id> productFeatureIds = new List<Id>();
        for (Product_Feature__c pc : productFeatures) {
            productFeatureIds.add(pc.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Enabled__c' => true,
            'Name' => 'Test',
            'Opportunity_Product__c' => opportunityLineItem.Id,
            'Product_Feature__c' => productFeatureIds
        };
        List<Opportunity_Product_Feature__c> opportunityProductFeatures = TestObjectHelper.createOpportunityProductFeatures(amount, defaults, create);
        if (create) {
            insert opportunityProductFeatures;
        }
        return opportunityProductFeatures;
    }
    
    /**
     * @description Creates a list of pricing management records
     * @param product
     * @param user
     * @param commodities
     * @param amount
     * @param create
     * @return pricingManagements
     */
    public static List<Pricing_Management__c> createPricingManagements(Product2 product, User user, List<String> commodities, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Active_BCO__c' => true,
            'Active_FWD__c' => true,
            'Commodity__c' => commodities,
            'Equipment_Types_BCO__c' => new List<String>{'20DRY', '20DRY;20REEF;40HREF'},
            'Equipment_Types_FWD__c' => new List<String>{'20DRY;20REEF', '20DRY;20REEF;20DRY'},
            'Min_Threshold_FFE_per_week_BCO__c' => '1',
            'Min_Threshold_FFE_per_week_FWD__c' => '1',
            'Product__c' => product.Id,
            'RecordTypeId' => Schema.SObjectType.Pricing_Management__c.getRecordTypeInfosByName().get('Commodity').getRecordTypeId(),
            'Validity_BCO__c' => '1 Month',
            'Validity_FWD__c' => '1 Month'
        };
        List<Pricing_Management__c> pricingManagements = TestObjectHelper.createPricingManagements(amount, defaults, create);
        if (create) {
            System.runAs(user) {
                insert pricingManagements;
            }
        }
        return pricingManagements;
    }
    
    /**
     * @description Creates a list of trade routes
     * @param operators
     * @param amount
     * @param create
     * @return tradeRoutes
     */
    public static List<Trade_Route__c> createTradeRoutes(List<String> operators, Integer amount, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Active__c' => true,
            'Description__c' => 'Trade Routes' + counter,
            'Direction__c' => 'W',
            'Name' => 'Trade Route' + counter,
            'Operator__c' => operators,
            'Route_Code__c' => 'FA' + counter
            //'Route_Direction_Code__c' => 'FAW' + counter
        };
        List<Trade_Route__c> tradeRoutes = TestObjectHelper.createTradeRoutes(amount, defaults, create);
        if (create) {
            insert tradeRoutes;
        }
        return tradeRoutes;
    }
    
    /**
     * @description Creates a list of quotes
     * @param opportunity
     * @param amount
     * @param create
     * @return quotes
     */
    public static List<Quote> createQuotes(Opportunity opportunity, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Effective_From_Date__c' => Date.today(),
            'ExpirationDate' => Date.today() + 30,
            'Name' => opportunity.Name,
            'OpportunityId' => opportunity.Id,
            'Segment__c' => 'BCO'
        };
        List<Quote> quotes = TestObjectHelper.createQuotes(amount, defaults, create);
        if (create) {
            insert quotes;
        }
        return quotes;
    }
    
    /**
     * @description Creates a Case record
     * @param account
     * @param contact
     * @param recordType
     * @param create
     * @return c
     */
    public static Case createCase(Account account, Contact contact, String recordType, Boolean create) {
        Id geographyId = contact != null ? contact.Country__c : createGeography('United Kingdom', 'Country', null, create).Id;
        Map<String, Object> defaults = new Map<String, Object>{
            'Case_Channel__c' => 'Telephone',
            'Case_Visibility__c' => 'All Users',
            'Country__c' => geographyId,
            'Direction__c' => 'Export',
            'Liner_Brand__c' => BrandUtilities.MAERSKLINE,
            'Origin' => 'MSLUSEXP',
            'Status' => 'New',
            'Subject' => recordType
        };
        Case c = TestObjectHelper.createCase(defaults, create);
        c.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        c.AccountId = account != null ? account.Id : null;
        c.ContactId = contact != null ? contact.Id : null;        
        setCaseTypeAndSubType(c, recordType);
        if ('Claims_Recovery'.EqualsIgnoreCase(recordType)) {
            List<Incident__c> incidents = new List<Incident__c>();
            incidents.addAll(createIncidents('Claim_Event', 1, create));
            c.Claim_Event__c = incidents[0].Id;
            c.Time_Bar__c = System.today();
        }
        if('ISR'.EqualsIgnoreCase(recordType)){
           c.Resolver_Dept__c = 'Ocean: Customer Service';
           c.Collaboration_Reason__c = 'Cargo Readiness';
        }
        if('Dispute'.EqualsIgnoreCase(recordType)){
            c.Department__c = 'Customer Service';            
            c.Nature_of_Dispute_case__c = 'Invoice Amendment/Clarification';
            c.Invoice_Amendment_Clarification__c = 'Missing or wrong reference in the invoice';
            c.Service_Contract_Number__c = '123456ABC';
            c.Expected_Exchange_Rate__c = '2345';
            c.Invoice_Type__c = 'Freight';
        }
        if ('Claim'.EqualsIgnoreCase(recordType)) {
            Integer bolNumberIncrement = 0;
            List<Incident__c> incidents = new List<Incident__c>();
            incidents.addAll(createIncidents('Claim_Event', 1, create));
            c.Claim_Event__c = incidents[0].Id;
            c.Type = 'Claim - Ocean';
            c.BoL_Number__c = '12345678'+bolNumberIncrement; 
            c.P_I_Cover__c = 'Yes';
            c.Court_Case__c = 'Yes';
            c.Chance_Winning_Court_Case__c = 67;
            //c.Location_Indicator_Jurisdiction__c = geographyId;
            c.Court_Case_Status__c = 'On Appeal';
            c.Claim_Filed_Date__c = System.today() - 1;
            
        }
        if (create) {
            insert c;
        }
        return c;
    }
    
    /**
     * @description Creates Case records
     * @param account
     * @param contact
     * @param recordType
     * @param amount
     * @param create
     * @return cases
     */
    public static List<Case> createCases(Account account, Contact contact, String recordType, Integer amount, Boolean create) {
        Id geographyId = contact != null ? contact.Country__c : createGeography('United Kingdom', 'Country', null, create).Id;
        Map<String, Object> defaults = new Map<String, Object>{
            'Case_Channel__c' => 'Telephone',
            'Case_Visibility__c' => 'All Users',
            'Country__c' => geographyId,
            'Direction__c' => 'Export',
            'Liner_Brand__c' => BrandUtilities.MAERSKLINE,
            'Origin' => 'MSLUSEXP',
            'Status' => 'New',
            'Subject' => recordType
        };
        
        List<Incident__c> incidents = new List<Incident__c>();
        if ('Claims_Recovery'.EqualsIgnoreCase(recordType)) {
            incidents.addAll(createIncidents('Claim_Event', amount, create));
        }
        
        List<Case> cases = TestObjectHelper.createCases(amount, defaults, create);
        for (Integer i = 0; i < amount; i++) {
            Case c = cases[i];
            c.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            c.AccountId = account != null ? account.Id : null;
            c.ContactId = contact != null ? contact.Id : null;
            setCaseTypeAndSubType(c, recordType);
            if (incidents.size() > 0) {
                c.Claim_Event__c = incidents[i].Id;
                c.Time_Bar__c = System.today();
            }
        }
        if (create) {
            insert cases;
        }
        return cases;
    }
    
    /**
     * @description Sets the Type and Sub-Type fields on case, based on the record type
     * @param c
     * @param recordType
     */
    private static void setCaseTypeAndSubType(Case c, String recordType) {
        switch on recordType {
            when 'Claim' {
                c.Type = 'Claim - Ocean';
                c.Sub_Type__c = 'Commercial Claim';
            }
            when 'Claims_Recovery' {
                c.Type = 'Claim';
                c.Sub_Type__c = 'Claim Recovery';
            }
            when 'Dispute' {
                c.Type = 'Non-Case';
                c.Sub_Type__c = 'Spam/Case Created in Error';
            }
            when 'External_Case' {
                c.Type = 'Booking';
                c.Sub_Type__c = 'New Booking Request';
            }
            when 'ISR' {
                c.Type = 'Documentation';
                c.Sub_Type__c = 'Request Arrival Notice';
            }
        }
    }
    
    /**
     * @description Creates a user with a certain profile and brand
     * @param profileName
     * @param brand
     * @param create
     * @return user
     */
    public static User createUser(String profileName, String brand, Boolean create) {
        counter++;
        String regExp = '[;& ]';
        String replacement = '';
        Map<String, Object> defaults = new Map<String, Object>{
            'Liner_Brand__c' => brand,
            'Maersk_User_Id__c' => 'ABC' + counter,
            'Email' => profileName.deleteWhitespace() + brand.replaceAll(regExp, replacement) + '@maersk.com'
        };
        if (profileName == ProfileUtilities.Sales || profileName == ProfileUtilities.X102_CustomerService || profileName == ProfileUtilities.X101_CustomerServiceSalesPilot) {
            defaults.put('CM_Visibility__c', 'Single Carrier');
        }
        User user = TestObjectHelper.createUser(defaults, create);
        Geography__c geography = createGeography('TESTCOUNTRY', 'Country', null, true);
        user.Country = geography.Name;
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        if (create) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert user;
            }
        }
        return user;
    }
    
    /**
     * @description Creates a map with User records and their emails as key
     * @param profileNames
     * @param brand
     * @param create
     * @return userMap
     */
    public static Map<String, User> createUsers(List<String> profileNames, String brand, Boolean create) {
        Integer amount = profileNames.size();
        String regExp = '[;& ]';
        String replacement = '';
        Map<String, Object> defaults = new Map<String, Object>{
            'Liner_Brand__c' => brand
        };
        List<User> users = TestObjectHelper.createUsers(amount, defaults, create);
        Geography__c geography = createGeography('TESTCOUNTRY', 'Country', null, true);
        
        Integer i = 0;
        for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN :profileNames]) {
            users[i].Country = geography.Name;
            users[i].Email = profileNames[i].deleteWhitespace().toLowerCase() + brand.replaceAll(regExp, replacement).toLowerCase() + '@maersk.com';
            users[i].ProfileId = p.Id;
            if (p.Name == ProfileUtilities.Sales || p.Name == ProfileUtilities.SuperUser) {
                users[i].CM_Visibility__c = 'Single Carrier';
            }
            i++;
        }
        if (create) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert users;
            }
        }
        Map<String, User> userMap = new Map<String, User>();
        for (User u : users) {
            userMap.put(u.Email, u);
        }
        return userMap;
    }
    
    /**
     * @description Inserts a GroupMember record for a certain user and group
     * @param userId
     * @param groupId
     */
    public static void addUserToGroup(Id userId, Id groupId) {
        GroupMember gm = new GroupMember();
        gm.UserorGroupId = userId;
        gm.groupId = groupId;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert gm;
       }
    }
    
    /**
     * @description Creates a Permission Set Assignment
     * @param permission
     * @param user
     */
    public static void createPermissionSetAssignment(String permission, User user) {
        List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permission];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user.id;
        psa.PermissionSetId = permissionSet[0].id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert psa;
        }
    }
    
    /**
     * @description Creates an Account Team Member
     * @param accountId
     * @param userId
     * @param teamMemberRole
     */
    public static void createAccountTeamMember(Id accountId, Id userId, String teamMemberRole) {
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = accountId;
        atm.TeamMemberRole = teamMemberRole;
        atm.UserId = userId;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert atm;
        }
    }
    
    /**
     * @description Creates a BDA__c record
     * @param bdaName
     * @param typeOfBDA
     * @param bdaCode
     * @param parentBDA
     * @param userId
     * @param create
     * @return bda
     */
    public static BDA__c createBDA(String bdaName, String typeOfBDA, String bdaCode, BDA__c parentBDA, Id userId, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'BDA_Code__c' => bdaCode,
            'GEO_ID__c' => 'Test' + typeOfBDA.left(3) + counter,
            'Name' => bdaName
        };
        BDA__c bda = TestObjectHelper.createBDA(defaults, create);
        bda.Active__c = true;
        bda.Default_Account_Owner__c = userId;
        bda.Parent_BDA__c = parentBDA != null ? parentBDA.Id : null;
        bda.Type__c = typeOfBDA;
        if (create) {
            insert bda;
        }
        return bda;
    }
    
    /**
     * @description Creates a list of BDA__c records
     * @param typeOfBDA
     * @param bdaCodes
     * @param parentBDA
     * @param userId
     * @param create
     * @return bdas
     */
    public static List<BDA__c> createBDAs(String bdaName, String typeOfBDA, List<String> bdaCodes, BDA__c parentBDA, Id userId, Boolean create) {
        counter++;
        Integer amount = bdaCodes.size();
        Id parentBDAId = parentBDA != null ? parentBDA.Id : null;
        Map<String, Object> defaults = new Map<String, Object>{
            'Active__c' => true,
            'BDA_Code__c' => bdaCodes,
            'Default_Account_Owner__c' => userId,
            'GEO_ID__c' => 'Test' + typeOfBDA.left(3) + counter,
            'Name' => bdaName,
            'Parent_BDA__c' => parentBDAId,
            'Type__c' => typeOfBDA
        };
        List<BDA__c> bdas = TestObjectHelper.createBDAs(amount, defaults, create);
        if (create) {
            insert bdas;
        }
        return bdas;
    }
    
    /**
     * @description Create BDA_Geography__c record
     * @param bdaId
     * @param geoId
     * @param linkId
     * @param create
     * @return bdaGeographies
     */
    public static BDA_Geography__c createBDAGeography(Id bdaId, Id geoId, String linkId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'BDA__c' => bdaId,
            'Geography__c' => geoId,
            'Link_Id__c' => linkId
        };
        BDA_Geography__c bdaGeography = TestObjectHelper.createBDAGeography(defaults, create);
        if (create) {
            insert bdaGeography;
        }
        return bdaGeography;
    }
    
    /**
     * @description Creates a list of BDA_Geography__c records
     * @param bdaGeoMap
     * @param create
     * @return bdaGeographies
     */
    public static List<BDA_Geography__c> createBDAGeographies(Map<Id, Id> bdaGeoMap, Boolean create) {
        Integer amount = bdaGeoMap.size();
        Map<String, Object> defaults = new Map<String, Object>();
        List<Id> bdaIds = new List<Id>();
        List<Id> geoIds = new List<Id>();
        for (Id bdaId : bdaGeoMap.keySet()) {
            bdaIds.add(bdaId);
            geoIds.add(bdaGeoMap.get(bdaId));
        }
        defaults.put('BDA__c', bdaIds);
        defaults.put('Geography__c', geoIds);
        List<BDA_Geography__c> bdaGeographies = TestObjectHelper.createBDAGeographies(amount, defaults, create);
        if (create) {
            insert bdaGeographies;
        }
        return bdaGeographies;
    }
    
    /**
     * @description Creates a Geography__c record with a dummy country
     * @param name
     * @param locationType
     * @param parentGeography
     * @param create
     * @return geography
     */
    public static Geography__c createGeography(String name, String locationType, Id parentGeography, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => name,
            'Parent_Geography__c' => parentGeography
        };
        Geography__c geography = TestObjectHelper.createGeography(defaults, create);
        geography.Active__c = true;
        geography.Type_Of_Location__c = locationType;
        if (create) {
            insert geography;
        }
        return geography;
    }
    
    /**
     * @description Creates a list of Geography__c records
     * @param names
     * @param locationType
     * @param parentGeographies
     * @param amount
     * @param create
     * @return geographies
     */
    public static List<Geography__c> createGeographies(List<String> names, String locationType, List<Id> parentGeographies, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Active__c' => true,
            'Name' => names,
            'Parent_Geography__c' => parentGeographies,
            'Type_Of_Location__c' => locationType
        };
        List<Geography__c> geographies = TestObjectHelper.createGeographies(amount, defaults, create);
        if (create) {
            insert geographies;
        }
        return geographies;
    }
    
    /**
     * @description Creates a Group record
     * @param typeOfGroup
     * @param create
     * @return g
     */
    public static Group createGroup(String typeOfGroup, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => typeOfGroup,
            'Type' => typeOfGroup
        };
        Group g = TestObjectHelper.createGroup(defaults, create);
        if (create) {
            insert g;
        }
        return g;
    }
    
    /**
     * @description Creates a CollaborationGroup record
     * @param create
     * @return cg
     */
    public static CollaborationGroup createCollaborationGroup(Boolean create) {
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'TestClean_Group';
        cg.CollaborationType = 'Public';
        if (create) {
            insert cg;
        }
        return cg;
    }
    
    /**
     * @description Creates a QueueSobject record
     * @param g
     * @param sObjectType
     * @param create
     * @return queueSobject
     */
    public static QueueSobject createQueueSobject(Group g, String sObjectType, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'QueueId' => g.Id,
            'SobjectType' => sObjectType
        };
        QueueSobject queueSobject = TestObjectHelper.createQueueSobject(defaults, create);
        if (create) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert queueSobject;
            }
        }
        return queueSobject;
    }
    
    /**
     * @description Creates a list of Incident__c records, with a child Vessel__c record
     * @param recordType
     * @param amount
     * @param create
     * @return incidents
     */
    public static List<Incident__c> createIncidents(String recordType, Integer amount, Boolean create) {
        Vessel__c vessel = createVessel(create);
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => recordType,
            'Date_of_Incident__c' => System.now(),
            'Insurance_Category__c' => 'Maersk Ocean',
            'Insured_Vessel__c' => vessel.Id,
            'Insured_Voyage__c' => 'Test Voyage',
            'RecordTypeId' => SObjectType.Incident__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId()
        };
        List<Incident__c> incidents = TestObjectHelper.createIncidents(amount, defaults, create);
        if (create) {
            insert incidents;
        }
        return incidents;
    }
    
    /**
     * @description Creates a Vessel record
     * @param create
     * @return vessel
     */
    public static Vessel__c createVessel(Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test Vessel',
            'Vessel_Name__c' => 'Test Vessel'
        };
        Vessel__c vessel = TestObjectHelper.createVessel(defaults, create);
        if (create) {
            insert vessel;
        }
        return vessel;
    }
    
    /**
     * @description Creates a list of Rate_Structure_Item_List__c records
     * @param amount
     * @param create
     * @return rateStructureItemLists
     */
    public static List<Rate_Structure_Item_List__c> createRateStructureItemLists(Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'IsActive__c' => true,
            'Product_Family__c' => 'Ocean'
        };
        List<Rate_Structure_Item_List__c> rateStructureItemLists = TestObjectHelper.createRateStructureItemLists(amount, defaults, create);
        if (create) {
            insert rateStructureItemLists;
        }
        return rateStructureItemLists;
    }
    
    /**
     * @description Creates a Rate_Structure_Item_List__c record
     * @param create
     * @return rateStructureItemList
     */
    public static Rate_Structure_Item_List__c createRateStructureItemList(Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test Rate Structure Item List',
            'Charge_Name__c' => 'Bunker Adjustment Factor',
            'New_Code__c' => 'BAF',
            'Type__c' => 'Required - BAF',
            'Sales_Approach__c' => 'Subject to and Floating',
            'IsActive__c' => true,
            'Order__c' => 1,
            'Product_Family__c' => 'Ocean',
            'Charge_Type__c' => 'Mandatory',
            'Occurrence__c' => 'Transportation',
            'Cargo_type__c' => ''
        };
        Rate_Structure_Item_List__c rateStructureItemList = TestObjectHelper.createRateStructureItemList(defaults, create);
        if (create) {
            insert rateStructureItemList;
        }
        return rateStructureItemList;
    }
    
    /**
     * @description Creates a Rate_Structure__c record
     * @param opportunity
     * @param create
     * @return rateStructure
     */
    public static Rate_Structure__c createRateStructure(Opportunity opportunity, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Description__c' => 'Test Rate Structure',
            'Opportunity__c' => opportunity.Id,
            'Status__c' => 'Not Approved'
        };
        Rate_Structure__c rateStructure = TestObjectHelper.createRateStructure(defaults, create);
        if (create) {
            insert rateStructure;
        }
        return rateStructure;
    }
    
    /**
     * @description Creates a Corridor_Guidance__c record
     * @param opportunity
     * @param product
     * @param create
     * @return corridorGuidance
     */
    public static Corridor_Guidance__c createCorridorGuidance(Opportunity opportunity, Product2 product, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Comments' => 'Test',
            'Opportunity__c' => opportunity.Id,
            'Product__c' => product.Id,
            'Status' => 'Approved'
        };
        Corridor_Guidance__c corridorGuidance = TestObjectHelper.createCorridorGuidance(defaults, create);
        if (create) {
            insert corridorGuidance;
        }
        return corridorGuidance;
    }
    
    /**
     * @description Creates a Corridor_Guidance_Detail__c record
     * @param corriodorGuidance
     * @param originId
     * @param destinationId
     * @param recordType
     * @param create
     * @return corridorGuidanceDetail
     */
    public static Corridor_Guidance_Detail__c createCorridorGuidanceDetail(Corridor_Guidance__c corriodorGuidance, Id originId, Id destinationId, String recordType, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Comments__c' => 'Test Comment',
            'Corridor_Guidance__c' => corriodorGuidance.Id,
            'CY_Per_FFE__c' => 20,
            'Destination_Cluster__c' => 'Test Cluster2',
            'Destination__c' => DestinationId,
            'Name' => recordType,
            'Origin_Cluster__c' => 'Test Cluster1',
            'Origin__c' => originId,
            'RecordTypeId' => SObjectType.Corridor_Guidance_Detail__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId(),
            'Relative_CY_vs_Trade__c' => 40,
            'Target_Volume_FFE__c' => 50,
            'Trade_Average_CY__c' => 60,
            'Weekly_FFE__c' => 40
        };
        Corridor_Guidance_Detail__c corridorGuidanceDetail = TestObjectHelper.createCorridorGuidanceDetail(defaults, create);
        if (create) {
            insert corridorGuidanceDetail;
        }
        return corridorGuidanceDetail;
    }
    
    /**
     * @description Creates a Environment_Variables__c record
     * @param name
     * @param num
     * @param value
     */
    public static void createEnvironmentVariable(String name, Integer num, String value) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => name,
            'Value__c' => num,
            'Value_String__c' => value
        };
        Environment_Variables__c environmentVariable = TestObjectHelper.createEnvironmentVariable(defaults);
        insert environmentVariable;
    }
    
    /**
     * @description Creates a Request__c record
     * @param account
     * @param brand
     * @param recordType
     * @param geographyId
     * @param pricingManagement
     * @param create
     * @return request
     */
    public static Request__c createRequest(Account account, String brand, String recordType, Id geographyId, Pricing_Management__c pricingManagement, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Liner_Brand__c' => brand,
            'RecordTypeId' => SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId()
        };
        
        switch on recordType {
            when 'VIP_Deal' {
                defaults.putAll(new Map<String, Object>{
                    'Account_Address__c' => 'Test',
                    'Country_Sales_Office__c' => geographyId,
                    'Payout_Type__c' => 'Fixed Amount Progressive Tier',
                    'Status__c' => 'New',
                    'VIP_Deal_Type__c' => 'Standard VIP Deal'
                });
            }
            when 'Rate_Request' {
                defaults.putAll(new Map<String, Object>{
                    'Account__c' => account.Id,
                    'Additional_Group_Internal_Email__c' => 'ratesheet@test.com',
                    'BCO_FWD__c' => 'FWD',
                    'Commodity_Rate_Sheet__c' => pricingManagement.Commodity__c,
                    'Equipment_Types__c' => '20DRY;40DRY',
                    'Existing_Contract_ID__c' => '123',
                    'Mail_Send_To__c' => 'Both',
                    'OD_Pairs__c' => 'Customised',
                    'Output__c' => 'Merged LQB & CL',
                    'Pricing_Management__c' => pricingManagement.Id,
                    'Requested_By__c' => null,
                    'Shipper_Owner_Container__c' => 'No',
                    'Special_Deals__c' => 'No',
                    'Status__c' => 'Active',
                    'Team__c' => 'GSC'
                });
            }
        }
        
        Request__c request = TestObjectHelper.createRequest(defaults, create);
        request.Account__c = account.Id;
        if (create) {
            insert request;
        }
        return request;
    }
    
    /**
     * @description Creates a Request__c record
     * @param account
     * @param brand
     * @param recordType
     * @param geographyId
     * @param pricingManagement
     * @param bcoFWD
     * @param create
     * @return request
     */
    public static Request__c createRequest(Account account, String brand, String recordType, Id geographyId, Pricing_Management__c pricingManagement, String bcoFWD, Boolean create) {
        Request__c request = createRequest(account, brand, recordType, geographyId, pricingManagement, false);
        request.Id = null;
        request.BCO_FWD__c = bcoFWD;
        if (create) {
            insert request;
        }
        return request;
    }
    
    /**
     * @description Creates a Request_Detail__c record
     * @param request
     * @param tradeRouteId
     * @param origin
     * @param destination
     * @param create
     * @return requestDetail
     */
    public static Request_Detail__c createRequestDetail(Request__c request, Id tradeRouteId, String origin, String destination, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Destination__c' => destination,
            'Origin__c' => origin,
            'Route__c' => tradeRouteId,
            'Status__c' => 'New',
            'VIP_Deal__c' => request.Id
        };
        Request_Detail__c requestDetail = TestObjectHelper.createRequestDetail(defaults, create);
        if (create) {
            insert requestDetail;
        }
        return requestDetail;
    }
    
    /**
     * @description Creates a list of Task records
     * @param amount
     * @param create
     * @return tasks
     */
    public static List<Task> createTasks(Integer amount, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Subject' => 'Test' + counter,
            'Status' => 'Not Started',
            'Priority' => 'Normal',
            'ActivityDate' => Date.today(),
            'Notify_Assignee__c' => true
        };
        List<Task> tasks = TestObjectHelper.createTasks(amount, defaults, create);
        if (create) {
            insert tasks;
        }
        return tasks;
    }
    
    /**
     * @description Creates a list of Task records
     * @param whatId
     * @param whoId
     * @param amount
     * @param create
     * @return tasks
     */
    public static List<Task> createTasks(Id whatId, Id whoId, Integer amount, Boolean create) {
        
        List<Task> tasks = createTasks(amount, false);
        for (Task t : tasks) {
            t.Id = null;
            t.WhatId = whatId;
            t.WhoId = whoId;
        }
        if (create) {
            insert tasks;
        }
        return tasks;
    }
    
    /**
     * @description Creates a list of Event records
     * @param amount
     * @param create
     * @return events
     */
    public static List<Event> createEvents(Integer amount, Boolean create) {
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Subject' => 'Test' + counter,
            'StartDateTime' => System.today(),
            'EndDateTime' => System.today() + 1
        };
        List<Event> events = TestObjectHelper.createEvents(amount, defaults, create);
        if (create) {
            insert events;
        }
        return events;
    }
        
    /**
     * @description Creates a list of Event records
     * @param whatId
     * @param whoId
     * @param amount
     * @param create
     * @return events
     */
    public static List<Event> createEvents(Id whatId, Id whoId, Integer amount, Boolean create) {
        List<Event> events = createEvents(amount, false);
        for (Event e : events) {
            e.Id = null;
            e.WhatId = whatId;
            e.WhoId = whoId;
        }
        if (create) {
            insert events;
        }
        return events;
    }
    
    /**
     * @description Creates a Business_Plan__c record
     * @param account
     * @param brand
     * @param create
     * @return businessPlan
     */
    public static Business_Plan__c createBusinessPlan(Account account, String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Lead_Account__c' => account.Id,
            'Liner_Brand__c' => brand,
            'Name' => 'Test'
        };
        Business_Plan__c businessPlan = TestObjectHelper.createBusinessPlan(defaults, create);
        if (create) {
            insert businessPlan;
        }
        return businessPlan;
    }
    
    /**
     * @description Creates a Sales_Call__c record
     * @param account
     * @param contact
     * @param brand
     * @param create
     * @return salesCall
     */
    public static Sales_Call__c createSalesCall(Account account, Contact contact, String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Account__c' => account.Id,
            'Contact__c' => contact.Id,
            'EndDateTime__c' => System.now() + 1,
            'Lead_Account__c' => account.Id,
            'Liner_Brand__c' => brand,
            'OwnerId' => Userinfo.getUserId(),
            'Name' => brand,
            'StartDateTime__c' => System.now(),
            'Type__c' => 'Other'
        };
        Sales_Call__c salesCall = TestObjectHelper.createSalesCall(defaults, create);
        if (create) {
            insert salesCall;
        }
        return salesCall;
    }
    
    /**
     * @description Creates an Attachment record
     * @param parentId
     * @param isPrivate
     * @param create
     * @return attachment
     */
    public static Attachment createAttachment(Id parentId, Boolean isPrivate, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Body' => Blob.valueOf('Test'),
            'IsPrivate' => isPrivate,
            'Name' => 'Test',
            'ParentId' => parentId
        };
        Attachment attachment = TestObjectHelper.createAttachment(defaults, create);
        if (create) {
            insert attachment;
        }
        return attachment;
    }
    
    /**
     * @description Creates an Initiative__c record
     * @param account
     * @param businessPlan
     * @param recordType
     * @param create
     * @return initiative
     */
    public static Initiative__c createInitiative(Account account, Business_Plan__c businessPlan, String recordType, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Account__c' => account.Id,
            'Business_Plan__c' => businessPlan.Id,
            'Name' => 'Test',
            'RecordTypeId' => Schema.SObjectType.Initiative__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId(),
            'Share_with_Customer__c' => true,
            'Status__c' => 'In Progress'
        };
        Initiative__c initiative = TestObjectHelper.createInitiative(defaults, create);
        if (create) {
            insert initiative;
        }
        return initiative;
    }
    
    /**
     * @description Creates an Relink_Contact_Childs__c record
     * @param account
     * @param contact
     * @param create
     * @return relinkContactChilds
     */
    public static Relink_Contact_Childs__c createRelinkContactChilds(Account account, Contact contact, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Master_Contact_Id__c' => contact.Id,
            'Name' => 'Test',
            'New_Contacts_Account_Id__c' => account.Id,
            'New_Contact_Id__c' => contact.Id,
            'Status__c' => 'New'
        };
        Relink_Contact_Childs__c relinkContactChilds = TestObjectHelper.createRelinkContactChilds(defaults, create);
        if (create) {
            insert relinkContactChilds;
        }
        return relinkContactChilds;
    }
    
    /**
     * @description Creates a list of Qt_Quote__c records
     * @param opportunity
     * @param amount
     * @param create
     * @return quotes
     */
    public static List<Qt_Quote__c> createQtQuotes(Opportunity opportunity, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Opportunity__c' => opportunity.Id,
            'Qt_Created_By__c' => 'SNA140',
            'Qt_Customer_Code__c' => '12345',
            'Qt_Carrier__c' => BrandUtilities.getBrandOperatorCode(BrandUtilities.MAERSKLINE),
            'Qt_External_Id__c' => opportunity.Opportunity_Ref__c
        };
        List<Qt_Quote__c> quotes = TestObjectHelper.createQtQuotes(amount, defaults, create);
        if (create) {
            insert quotes;
        }
        return quotes;
    }
    
    /**
     * @description Creates a AFLS_Quote_Attachment__c record
     * @param quote
     * @param create
     * @return aFLSQuoteAttachment
     */
    public static AFLS_Quote_Attachment__c createAFLSQuoteAttachment(Qt_Quote__c quote, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Quote__c' => quote.Id
        };
        AFLS_Quote_Attachment__c aFLSQuoteAttachment = TestObjectHelper.createAFLSQuoteAttachment(defaults, create);
        if (create) {
            insert aFLSQuoteAttachment;
        }
        return aFLSQuoteAttachment;
    }
    
    /**
     * @description Creates a SIP_KPI__c record
     * @param brand
     * @param create
     * @return sipKPI
     */
    public static SIP_KPI__c createSIPKPI(String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Brand__c' => BrandUtilities.MAERSK,
            'Effective_From_Date__c' => System.today() - 15,
            'Effective_To_Date__c' => System.today() + 15,
            'Geographical_Validity__c' => 'Global',
            'KPI_Code__c' => 'Test code',
            'KPI_Grouping__c' => 'Existing and additional business',
            'KPI_Incentive_Type__c' => 'Target-based',
            'KPI_Type__c' => 'Core',
            'Payout_Frequency__c' => 'Annual',
            'Name' => 'Test',
            'Target__c' => 11,
            'Measure_Type__c' => 'Revenue'
            };
        SIP_KPI__c sipKPI = TestObjectHelper.createSIPKPI(defaults, create);
        if (create) {
            insert sipKPI;
        }
        return sipKPI;
    }
    
    /**
     * @description Creates a list of SIP_Payout_Curve__c records
     * @param sipKPI
     * @param effectivePeriodYears
     * @param effectivePeriodQuarters
     * @param brand
     * @param create
     * @return sipPayoutCurves
     */
    public static List<SIP_Payout_Curve__c> createSIPPayoutCurves(SIP_KPI__c sipKPI, List<String> effectivePeriodYears, List<String> effectivePeriodQuarters, String brand, Boolean create) {
        Integer amount = effectivePeriodYears.size();
        Map<String, Object> defaults = new Map<String, Object>{
            'Active__c' => true,
            'Brand__c' => brand,
            'Cap_Payout_Percent__c' => 120,
            'Cap_Performance_Percent__c' => 120,
            'Effective_Period_Quarter__c' => effectivePeriodQuarters,
            'Effective_Period_Year__c' => effectivePeriodYears,
            'Excellence_Payout_Percent__c' => 110,
            'Excellence_Performance_Percent__c' => 110,
            'Geographical_Validity__c' => 'Global',
            'Name' => 'Test',
            'SIP_KPI__c' => sipKPI.Id,
            'Target_Payout_Percent__c' => 100,
            'Target_Performance_Percent__c' => 100,
            'Threshold_Payout_Percent__c' => 90,
            'Threshold_Performance_Percent__c' => 90
        };
        List<SIP_Payout_Curve__c> sipPayoutCurves = TestObjectHelper.createSIPPayoutCurves(amount, defaults, create);
        if (create) {
            insert sipPayoutCurves;
        }
        return sipPayoutCurves;
    }
    
    /**
     * @description Creates a Request_Information__c record
     * @param request
     * @param user
     * @param contact
     * @param create
     * @return requestInformation
     */
    public static Request_Information__c createRequestInformation(Request__c request, User user, Contact contact, Boolean create) {
        Id contactId = contact != null ? contact.Id : null;
        Id userId = user != null ? user.Id : null;
        Map<String, Object> defaults = new Map<String, Object>{
            'Contact__c' => contactId,
            'Name' => 'Test',
            'Request__c' => request.Id,
            'User__c' => userId
        };
        Request_Information__c requestInformation = TestObjectHelper.createRequestInformation(defaults, create);
        if (create) {
            insert requestInformation;
        }
        return requestInformation;
    }
    
    /**
     * @description Creates a Campaign record
     * @param brand
     * @param create
     * @return campaign
     */
    public static Campaign createCampaign(String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{};
        Campaign campaign = TestObjectHelper.createCampaign(defaults, create);
        campaign.IsActive = true;
        campaign.Liner_Brand__c = brand;
        campaign.Name = 'Test';
        if (create) {
            insert campaign;
        }
        return campaign;
    }
    
    /**
     * @description Creates a CampaignMember record
     * @param campaign
     * @param lead
     * @param create
     * @return campaignMember
     */
    public static CampaignMember createCampaignMember(Campaign campaign, Lead lead, Boolean create) {
        Map<String, Object> defaults = populateCampaignMemberDefaults(campaign);
        defaults.put('LeadId', lead.Id);
        CampaignMember campaignMember = TestObjectHelper.createCampaignMember(defaults, create);
        if (create) {
            insert campaignMember;
        }
        return campaignMember;
    }
    
    /**
     * @description Creates a CampaignMember record
     * @param campaign
     * @param contact
     * @param create
     * @return campaignMember
     */
    public static CampaignMember createCampaignMember(Campaign campaign, Contact contact, Boolean create) {
        Map<String, Object> defaults = populateCampaignMemberDefaults(campaign);
        defaults.put('ContactId', contact.Id);
        CampaignMember campaignMember = TestObjectHelper.createCampaignMember(defaults, create);
        if (create) {
            insert campaignMember;
        }
        return campaignMember;
    }
    
    /**
     * @description Populates the default fields for Campaign Member
     * @param campaign
     * @return defaults
     */
    private static Map<String, Object> populateCampaignMemberDefaults(Campaign campaign) {
        Map<String, Object> defaults = new Map<String, Object>{
            'CampaignId' => campaign.Id,
            'LastName' => 'Test',
            'Status' => 'Sent'
        };
        return defaults;
    }
    
    /**
     * @description Creates a Stakeholder__c record
     * @param externalStakeHolder
     * @param businessplan
     * @param create
     * @return stakeHolder
     */
    public static Stakeholder__c createStakeHolder(Id externalStakeHolder, Business_Plan__c businessPlan, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Business_Plan__c' => businessPlan.Id,
            'External_Stakeholder__c' => externalStakeHolder,
            'RecordTypeId' => Schema.SObjectType.Stakeholder__c.getRecordTypeInfosByDeveloperName().get('External').getRecordTypeId()
        };
        Stakeholder__c stakeHolder = TestObjectHelper.createStakeHolder(defaults, create);
        if (create) {
            insert stakeHolder;
        }
        return stakeHolder;
    }
    
    /**
     * @description Creates a Territory__c record
     * @param user
     * @param create
     * @return territory
     */
    public static Territory__c createTerritory(User user, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Portfolio_Owner__c' => user.Id,
            'RecordTypeId' => Schema.SObjectType.Territory__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId()
        };
        Territory__c territory = TestObjectHelper.createTerritory(defaults, create);
        if (create) {
            insert territory;
        }
        return territory;
    }
    
    /**
     * @description Creates a Territory_Account_Association__c record
     * @param territory
     * @param account
     * @param responsibility
     * @param productResponsibility
     * @param brand
     * @param create
     * @return territoryAccountAssociation
     */
    public static Territory_Account_Association__c createTerritoryAccountAssociation(Territory__c territory, Account account, String responsibility, String productResponsibility, String brand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Account__c' => account.Id,
            'Brand__c' => brand,
            'Portfolio_Owner_Responsibility__c' => responsibility,
            'Product_Responsibility__c' => productResponsibility,
            'Territory__c' => territory.Id
        };
        Territory_Account_Association__c territoryAccountAssociation = TestObjectHelper.createTerritoryAccountAssociation(defaults, create);
        if (create) {
            insert territoryAccountAssociation;
        }
        return territoryAccountAssociation;
    }
    
    /**
     * @description Creates a User_Cluster__c record
     * @param userId
     * @param clusterId
     * @param create
     * @return userCluster
     */
    public static User_Cluster__c createUserCluster(Id userId, Id clusterId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'BDA__c' => clusterId,
            'User__c' => userId
        };
        User_Cluster__c userCluster = TestObjectHelper.createUserCluster(defaults, create);
        if (create) {
            insert userCluster;
        }
        return userCluster;
    }

    /**
     * @description Creates an EventRelation record
     * @param eventId
     * @param relationId
     * @param create
     * @return eventRelation
     */
    public static EventRelation createEventRelation(Id eventId, Id relationId, Boolean create) {
        EventRelation eventRelation = new EventRelation();
        eventRelation.EventId = eventId;
        eventRelation.RelationId = relationId;
        if (create) {
            insert eventRelation;
        }
        return eventRelation;
    }
    
    /**
     * @description Creates a New_Hire_Module__c record
     * @param badgeName
     * @param onboardingPlanId
     * @param create
     * @return newHireModule
     */
    public static New_Hire_Module__c createNewHireModule(String badgeName, Id onboardingPlanId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Badge_Name__c' => badgeName,
            'Category__c' => 'Our Company',
            'Duration__c' => 2,
            'Name' => 'Test',
            'Onboarding_Plan__c' => onboardingPlanId,
            'Order__c' => 1,
            'Status__c' => 'Not Started'
        };
        New_Hire_Module__c newHireModule = TestObjectHelper.createNewHireModule(defaults, create);
        if (create) {
            insert newHireModule;
        }
        return newHireModule;
    }
    
    /**
     * @description Creates a New_Hire_Assignments__c record
     * @param newHireModule
     * @param create
     * @return newHireAssignment
     */
    public static New_Hire_Assignments__c createNewHireAssignment(New_Hire_Module__c newHireModule, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'New_Hire_Module__c' => newHireModule.Id,
            'Status__c' => 'Not Started'
        };
        New_Hire_Assignments__c newHireAssignment = TestObjectHelper.createNewHireAssignment(defaults, create);
        if (create) {
            insert newHireAssignment;
        }
        return newHireAssignment;
    }
    
    /**
     * @description Creates an Onboarding_Plan__c record
     * @param groupId
     * @param create
     * @return onboardingPlan
     */
    public static Onboarding_Plan__c createOnboardingPlan(String groupId, Boolean create) {
        Map<String, User> users = createUsers(new List<String>{'System Administrator', 'Integration User', 'Sales'}, BrandUtilities.MAERSKLINE, true);
        Map<String, Object> defaults = new Map<String, Object>{
            'Buddy__c' => users.get('integrationusermaerskline@maersk.com'),
            'Chatter_Group_URL__c' => '?g='+ groupId,
            'Coordinator__c' => Userinfo.getUserId(),
            'Enrolled_Or_Onboarded__c' => 1,
            'Name' => 'Test',
            'New_Hire__c' => users.get('salesmaerskline@maersk.com'),
            'Onboarder__c' => users.get('systemadministratorrmaerskline@maersk.com'),
            'Start_Date__c' => Date.today(),
            'Status__c' => 'Enrolled'
        };
        Onboarding_Plan__c onboardingPlan = TestObjectHelper.createOnboardingPlan(defaults, create);
        if (create) {
            insert onboardingPlan;
        }
        return onboardingPlan;
    }
    
    /**
     * SFSE-11869   
     * @description Creates a list of Product Specification Parameters
     * @param productFeatures
     * @param amount
     * @param create
     * @return productSpecificationParameters
     */
    public static List<Product_Specification_Parameter__c> createProductSpecificationParameters(List<Product_Feature__c> productFeatures,Integer amount, Boolean create) {
        List<Id> productFeaturesIds = new List<Id>();
        for (Product_Feature__c pf : productFeatures) {
            productFeaturesIds.add(pf.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Product_Feature__c' => productFeaturesIds
            
        };
        List<Product_Specification_Parameter__c> productSpecificationParameters = TestObjectHelper.createProductSpecificationParameters(amount, defaults, create);
        if (create) {
            insert productSpecificationParameters;
        }
        return productSpecificationParameters;
    }

    /**
     * SFSE-11870   
     * @description Creates a list of Product Specification Options
     * @param productSpecificationParameters
     * @param amount
     * @param create
     * @return List<Product_Specification_Option__c>
     */    
    public static List<Product_Specification_Option__c> createProductSpecificationOptions(List<Product_Specification_Parameter__c> productSpecificationParameters, Integer amount, Boolean create) {
        List<Id> productSpecificationParametersIds = new List<Id>();
        for(Product_Specification_Parameter__c psp : productSpecificationParameters){
            productSpecificationParametersIds.add(psp.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Product_Specification_Parameter__c' => productSpecificationParametersIds
        };
        List<Product_Specification_Option__c> productSpecificationOptions = TestObjectHelper.createProductSpecificationOptions(amount, defaults, create);
        if (create) {
            insert productSpecificationOptions;
        }
        return productSpecificationOptions;
    }
    
    /**
     * SFSE-11873   
     * @description Creates a single Sales Target
     * @param user
     * @param curr
     * @param cadence
     * @param create
     * @return Target__c
     */   
    
    public static Target__c createSalesTarget(User user, String year, String curr, String cadence, Boolean create){
        System.debug(create);
        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId' => user.Id,
            'Cadence__c' => cadence,
            'Currency__c' => curr,
            'Applicable_Year__c' => year,
            'Name' => 'Test'
        };
        Target__c SalesTarget = TestObjectHelper.createSalesTarget(defaults, create);
        System.debug(SalesTarget.Id);
        if (create) {
            insert SalesTarget;
        }
        return SalesTarget;
    }
    
    /**
     * SFSE-11873   
     * @description Creates a list of Sales Target
     * @param user
     * @param currencyList
     * @param cadenceList
     * @param amount
     * @param create
     * @return List<Target__c>
     */   
    
    public static List<Target__c> createSalesTargets(User user, List<String> yearList,  List<String> currencyList, List<String> cadenceList, Integer amount, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId' => user.Id,
            'Cadence__c' => cadenceList,
            'Currency__c' => currencyList,
            'Name' => 'Test',
            'Applicable_Year__c' => yearList
        };
        List<Target__c> SalesTargets = TestObjectHelper.createSalesTargets(amount, defaults, create);
        if (create) {
            insert SalesTargets;
        }
        return SalesTargets;
    }
    
    /**
     * SFSE-11875   
     * @description Creates a Sales Target Item Group
     * @param SalesTargets
     * @param BDA_Geography__c bDAGeo
     * @param productFamily
     * @param create
     * @return Target_Item_Group__c
     */ 
    public static Target_Item_Group__c createSalesTargetItemGroup(Target__c salesTarget, String brand, Geography__c  executingCountry, BDA_Geography__c bDAGeo, String productFamily, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Target__c' => salesTarget,
            'BrandMnA__c' => brand,
            'Product_Family__c' => productFamily,
            'Executing_Country__c' => executingCountry,
            'BDA_Geography__c' => bDAGeo,
            'Name' => 'Test'
        };
        Target_Item_Group__c SalesTargetItemGroup = TestObjectHelper.createSalesTargetItemGroup(defaults, create);
        if (create) {
            insert SalesTargetItemGroup;
        }
        return SalesTargetItemGroup;
    }
    
    /**
     * SFSE-11875   
     * @description Creates a list of Sales Target Item Group
     * @param SalesTargetsList
     * @param BDA_Geography__c BDAGeo
     * @param productFamilyList
     * @param amount
     * @param create
     * @return List<Target_Item_Group__c>
     */ 
    public static List<Target_Item_Group__c> createSalesTargetItemGroups(List<Target__c> salesTargetsList, List<String> brandList, List<Geography__c>  executingCountrysList, BDA_Geography__c bdaGeo, List<String> productFamilyList, Integer amount, Boolean create) {
        List<Id> SalesTargetsIds = new List<Id>();
        for(Target__c stid : salesTargetsList){
            SalesTargetsIds.add(stid.Id);
        }
        List<Id> ExecutingCountryIds = new List<Id>();
        for(Geography__c ecid : executingCountrysList){
            ExecutingCountryIds.add(ecid.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Target__c' => SalesTargetsIds,
            'BrandMnA__c' => brandList,
            'Product_Family__c' => productFamilyList,
            'Executing_Country__c' => executingCountryIds,
            'BDA_Geography__c' => bdaGeo,
            'Name' => 'Test'+counter
        };
        List<Target_Item_Group__c> SalesTargetItemGroups = TestObjectHelper.createSalesTargetItemGroups(amount, defaults, create);
        if (create) {
            insert SalesTargetItemGroups;
        }
        return SalesTargetItemGroups;
    }
    
    /**
     * SFSE-11874   
     * @description Creates a Sales Target Item
     * @param SalesTargetItemGroup
     * @param account
     * @param create
     * @return Target_Item__c
     */ 
    
    public static Target_Item__c createSalesTargetItem(Target__c salesTarget, Target_Item_Group__c salesTargetItemGroup, String reviewStage, Account account, Geography__c controllingCountry, BDA__c controllingArea, String salesChannelItem, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Target__c' => salesTarget,
            'Sales_Target_Item_Group__c' => salesTargetItemGroup,
            'Controlling_Country_Item__c' => controllingCountry,
            'Controlling_Area__c' => controllingArea,
            'Review_Stage__c' => reviewStage,
            'Sales_Channel__c' => salesChannelItem,
            'Account__c' => account
        };
        Target_Item__c SalesTargetItem = TestObjectHelper.createSalesTargetItem(defaults, create);
        if (create) {
            insert SalesTargetItem;
        }
        return SalesTargetItem;
    }
    
    /**
     * SFSE-11874   
     * @description Creates a list of Sales Target Item
     * @param SalesTargetItemGroupList
     * @param account
     * @param amount
     * @param create
     * @return List<Target_Item__c>
     */ 
    
    public static List<Target_Item__c> createSalesTargetItems(List<Target_Item_Group__c> salesTargetItemGroupList, Account account, Integer amount, Boolean create) {
        List<Id> SalesTargetItemIds = new List<Id>();
        for(Target_Item_Group__c sti : salesTargetItemGroupList){
            SalesTargetItemIds.add(sti.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Sales_Target_Item_Group__c' => SalesTargetItemIds,
            'Name' => 'Test'+counter,
            'Account__c' => account
        };
        List<Target_Item__c> SalesTargetItems = TestObjectHelper.createSalesTargetItems(amount, defaults, create);
        if (create) {
            insert SalesTargetItems;
        }
        return SalesTargetItems;
    }
    
    /**
     * @description Creates Warehouse_Site__c
     * @return Warehouse_Site__c
     */
    public static Warehouse_Site__c createWarehouseSite(Id countryId,Boolean create){
        Warehouse_Site__c wh = new Warehouse_Site__c();
        wh.Site_Id__c = '12345';
        wh.Name = 'Test Warehouse Site';
        wh.Country__c = countryId;
        wh.Status__c = 'Active';
        if(create){
            insert wh;
        }
        
        return wh;
    }
    
    /**
     * @description validate whether product is contract logistics or not
     * @param productId
     * @return Boolean
     */
    public static boolean isProductCL(Id productId){
        Boolean isProductCL = false;
        
        Contract_Logistics_OIPC_Code__mdt mdtRec = Contract_Logistics_OIPC_Code__mdt.getInstance('CL_OIPC_Codes');
        
        Product2 prod = new Product2();
        prod = [Select OIPC_Code__c from Product2 where Id =: productId];
        
        isProductCL = prod != null && mdtRec != null && mdtRec?.MasterLabel?.contains(prod?.OIPC_Code__c) ? true : false;
        
        return isProductCL;
    }

    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param tradeRoute
     * @param create
     * @return Opportunity_Product__c
     */
    public static Opportunity_Product__c createOpportunityLineItemCustom(Opportunity opportunity, Id productId, Trade_Route__c tradeRoute, Boolean create) {
        if (tradeRoute == null) {
            tradeRoute = createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, create)[0];
        }
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
        Warehouse_Site__c wh = new Warehouse_Site__c();
        if(productId != null && TestBusinessHelper.isProductCL(productId)){
            wh = TestBusinessHelper.createWarehouseSite(country.Id,true);
        }
        Map<String, Object> defaults = new Map<String, Object>{
                'Country__c' => country.Id,
                'OpportunityId__c' => opportunity.Id,
                'Product2ID__c' => productId,
                'Opt_Out_Auto_Quantity_Scheduling__c' => false,
                'Quantity__c' => 1,
                'Trade_Route__c' => tradeRoute.Id,
                'Tender_Target__c' => 1,
                'UnitPrice__c' => 1,
                'Product_Revenue_Per_Unit__c' => 1,
                'Cargo_Type__c' => 'Dry',
                'Estimated_Footprint_Requirement_in_Sqm__c' => 100,
                'Warehouse_Site__c' => wh?.Id
         };
        Opportunity_Product__c opportunityLineItemCustom = TestObjectHelper.createOpportunityLineItemCustom(opportunity, defaults, true);
        if (create) {
            insert opportunityLineItemCustom;
        }
        return opportunityLineItemCustom;
    }
    
    /**
     * @description Creates an opportunity line item
     * @param opportunity
     * @param productId
     * @param tradeRoute
     * @param country
     * @param state
     * @param create
     * @return Opportunity_Product__c
     */
    public static Opportunity_Product__c createOpportunityLineItemCustom(Opportunity opportunity, Id productId, Trade_Route__c tradeRoute, Geography__c country, Geography__c state, Boolean create) {
        if (tradeRoute == null) {
            tradeRoute = createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, create)[0];
        }
        
        Warehouse_Site__c wh = new Warehouse_Site__c();
        if(productId != null && TestBusinessHelper.isProductCL(productId)){
            wh = TestBusinessHelper.createWarehouseSite(country.Id,true);
        }
        
        Map<String, Object> defaults = new Map<String, Object>{
                'Country__c' => country.Id,
                'Executing_City_State__c' => state.Id,
                'OpportunityId__c' => opportunity.Id,
                'Product2ID__c' => productId,
                'Opt_Out_Auto_Quantity_Scheduling__c' => false,
                'Quantity__c' => 1,
                'Trade_Route__c' => tradeRoute.Id,
                'Tender_Target__c' => 1,
                'UnitPrice__c' => 1,
                'Product_Revenue_Per_Unit__c' => 1,
                'Cargo_Type__c' => 'Dry',
                 'Estimated_Footprint_Requirement_in_Sqm__c' => 100,
                'Warehouse_Site__c' => wh?.Id
         };
        Opportunity_Product__c opportunityLineItemCustom = TestObjectHelper.createOpportunityLineItemCustom(opportunity, defaults, create);
        opportunityLineItemCustom.Import_Export__c = 'Import';               
        if (create) {
            insert opportunityLineItemCustom;
        }
        return opportunityLineItemCustom;
    }
    
    /**
     * @description Creates list of custom opportunity line item
     * @param opportunity
     * @param productIds
     * @param tradeRoute
     * @param country
     * @param state
     * @param create
     * @return List<Opportunity_Product__c>
     */
    public static List<Opportunity_Product__c> createOpportunityLineItemCustoms(Opportunity opportunity, Set<Id> productIds, Trade_Route__c tradeRoute, Geography__c country, Geography__c state, Boolean create) {
        if (tradeRoute == null) {
            tradeRoute = createTradeRoutes(new List<String>{BrandUtilities.MCC}, 1, create)[0];
        }
        Map<String, Object> defaults;
        Opportunity_Product__c opportunityLineItemCustom;
        List<Opportunity_Product__c> listOpportunityLineItemCustom = new List<Opportunity_Product__c>();
        for(Id prodId : productIds){
            Warehouse_Site__c wh = new Warehouse_Site__c();
            if(prodId != null && TestBusinessHelper.isProductCL(prodId)){
                wh = TestBusinessHelper.createWarehouseSite(country.Id,true);
            }
            defaults = new Map<String, Object>{
                'Country__c' => country.Id,
                    'Executing_City_State__c' => state.Id,
                    'OpportunityId__c' => opportunity.Id,
                    'Product2ID__c' => prodId,
                    'Opt_Out_Auto_Quantity_Scheduling__c' => false,
                    'Quantity__c' => 1,
                    'Trade_Route__c' => tradeRoute.Id,
                    'Tender_Target__c' => 1,
                    'UnitPrice__c' => 1,
                    'Product_Revenue_Per_Unit__c' => 1,
                    'Cargo_Type__c' => 'Dry',
                    'Estimated_Footprint_Requirement_in_Sqm__c' => 100,
                    'Warehouse_Site__c' => wh?.Id
                    };
            opportunityLineItemCustom = TestObjectHelper.createOpportunityLineItemCustom(opportunity, defaults, create);
            listOpportunityLineItemCustom.add(opportunityLineItemCustom);
        }
        
        if (create) {
            insert listOpportunityLineItemCustom;
        }
        return listOpportunityLineItemCustom;
    }
    
    /**
     * @description Creates an Approval Process
     * @param process
     * @param Approver
     * @param Escalation Approver
     * @param vertical
     * @param areaCode
     * @param Region
     * @return Approval_Process__c 
     */
    public static Approval_Process__c  createApprovalPorcess(String processName, String gateName, String subGateName, Integer order, Integer sla, Boolean isActive, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
                    'Name' => processName,
                    'Gate__c' => gateName,
                    'Sub_Gate__c' => subGateName,
                    'Order__c' => order,
                    'SLA__c' => sla,
                    'Active__c' => isActive
         };
        Approval_Process__c approvalProcess = TestObjectHelper.createApprovalProrcess(defaults, create);
        if (create) {
            insert approvalProcess;
        }
        return approvalProcess;
    }
    
    /**
     * @description Creates an Approval Process Matrix
     * @param process
     * @param country
     * @param area
     * @param region
     * @param productsForApprovalCode
     * @param approver
     * @param escalationApprover
     * @param totalGP
     * @param vertical
     * @param isAutoApproved
     * @param create
     * @return Approval_Process_Escalation_Matrix__c
     */
    public static Approval_Process_Escalation_Matrix__c createApprovalPorcessMatrix(Approval_Process__c process, Geography__c country, String area, String region, String productsForApprovalCode, User approver, User EscalationApprover, String totalGP, String vertical, Boolean isAutoApproved, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
                'Approval_Process_Name__c' => process.Id,
                'Country__c' => country,
                'Area_code__c' => area,
                'Brand__c' => BrandUtilities.MAERSKLINE,
                'Current_owner__c' => approver,
                'Escalation_owner__c' => EscalationApprover,
                'Step_Name__c' => process.Name,
                'Total_GP__c' => totalGP,
                'Vertical__c' => vertical,
                'Product_for_approval__c' => productsForApprovalCode,
                'Key__c' => process.Name,
                'Auto_Approved__c' => isAutoApproved,
                'Active__c' => true
                };
        Approval_Process_Escalation_Matrix__c approvalProcessMatrix = TestObjectHelper.createApprovalProrcessMatrix(defaults, create);
        if (create) {
            insert approvalProcessMatrix;
        }
        return approvalProcessMatrix;
    }
    
    /** 
     * @description Creates a list of Opportunity Product Configurations
     * @param opportunityProduct
     * @param productSpecificationParameters
     * @param productSpecificationOptions
     * @param amount
     * @param create
     * @return List <Opportunity_Product_Configuration__c>
     */    
    public static List <Opportunity_Product_Configuration__c> createOpportunityProductConfigurations(Opportunity_Product__c opportunityProduct, List<Product_Specification_Parameter__c> productSpecificationParameters, List<Product_Specification_Option__c> productSpecificationOptions, Integer amount, Boolean create){
        /**List<Id> opportunityProductsIds = new List<Id>();
        for(Opportunity_Product__c opptyprod : opportunityProducts){
            opportunityProductsIds.add(opptyprod.Id);
        }*/
        List<Id> prodspecparamIds = new List<Id>();
        for(Product_Specification_Parameter__c prodspec : productSpecificationParameters){
            prodspecparamIds.add(prodspec.Id);
        }
        List<Id> prodspecoptionIds = new List<Id>();
        for(Product_Specification_Option__c prodspecoption : productSpecificationOptions){
            prodspecoptionIds.add(prodspecoption.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Opportunity_Product_Cus__c' => opportunityProduct.Id,
            'Product_Specificaiton_Parameter__c' => prodspecparamIds,
            'Product_Specification_Option__c' => prodspecoptionIds
        };
        List<Opportunity_Product_Configuration__c> OpportunityProductConfigurations = TestObjectHelper.createOpportunityProductConfigurations(amount, defaults, create);
        if (create) {
            insert OpportunityProductConfigurations;
        }
        return OpportunityProductConfigurations;
    }
    
    /** 
     * @description Creates a list of Parent BDAs
     * @param Cluster BDAs
     * @param Region BDAs
     * @param user
     * @param External unique LinkIDs
     * @param amount
     * @param create
     * @return List<Parent_BDA__c>
     */ 
    public static List<Parent_BDA__c> createParentBDAs(List<BDA__c> clusters, List<BDA__c> regions, User user, List<String> linkIds, integer amount, Boolean create){
        List<Id> clusterIds = new List<Id>();
        List<Id> regionIds = new List<Id>();
        for(BDA__c cluster : clusters){
            clusterIds.add(cluster.Id);
        }
        for(BDA__c region : regions){
            regionIds.add(region.Id);
        }
        Map<String,Object> defaults = new Map<String,Object>{
                'Name' => 'Test',
                'Child_BDA__c' => clusterIds,
                'Parent_BDA__c' => regionIds,
                'OwnerId' => user.Id,
                'Link_ID__c' => linkIds
                };
        List<Parent_BDA__c> parentBDAs = TestObjectHelper.createParentBDAs(amount, defaults, create);
        if(create)
        {
            insert parentBDAs;
        }
        return parentBDAs;
    }
    /**    
    * @description Creates an OfferInformation
    * @param offerStatus
    * @param user
    * @param opportunity
    * @param recipient
    * @param create
    * @return <Offer_Information__c>
    */
     public static Offer_Information__c createOfferInformation(String offerStatus, User user,Opportunity opportunity, Contact acceptedBy,Contact recipient, Boolean create) {

        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId' => user.Id,
            'Offer_Status__c' => offerStatus,
            'Opportunity__c' => opportunity,
            'Date_Accepted__c' => date.Today(),
            'Date_Sent__c' => date.Today(),
            'To_Recipient__c' => recipient,
            'Accepted_by__c' => acceptedBy
        };
        Offer_Information__c offerInformation = TestObjectHelper.createOfferInformation(defaults, create);
        if (create) {
            insert offerInformation;
        }
        return offerInformation;
    }
       /**    
    * @description Creates a list of OfferInformation
    * @param List <String> offerStatus
    * @param List<user>
    * @param List<opportunity>
    * @param List<recipient>
    * @param create
    * @param amount
    * @return List<Offer_Information__c>
    */
     public static List<Offer_Information__c> createOfferInformations(List<String> offerStatus, User user,List<Opportunity> opportunity, List<Contact> acceptedBy,List<Contact> recipient, integer amount, Boolean create) {
        
        List<Id> opportunityIDs = new List<Id>();
        for(Opportunity oppty : opportunity){
            opportunityIDs.add(oppty.Id);
        }
        List<Id> acceptedByIDs = new List<Id>();
        for(Contact con : acceptedBy){
            acceptedByIDs.add(con.Id);
        }
        List<Id> recipientIDs = new List<Id>();
        for(Contact con : recipient){
            recipientIDs.add(con.Id);
        }
        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId' => user.Id,
            'Offer_Status__c' => offerStatus,
            'Opportunity__c' => opportunityIDs,
            'Date_Accepted__c' => date.Today(),
            'Date_Sent__c' => date.Today(),
            'To_Recipient__c' => recipientIDs,
            'Accepted_by__c' => acceptedByIDs
        };
        List<Offer_Information__c> offerInformations = TestObjectHelper.createOfferInformations(amount,defaults, create);
        if (create) {
            insert offerInformations;
        }
        return offerInformations;
    }
     /**    
     * @description Create Feedback_Data__c
     * @param user
     * @param widgetHeaderText
     * @param functionality
     * @param overlayRestrictionDays
     * @param Type
     * @param whatObject
     * @param isActive
     * @param create
     * @return Feedback_Data__c
     */ 
    public static Feedback_Data__c createFeedbackData(User user, String widgetHeaderText, String functionality, double overlayRestrictionDays, String Type, String whatObject, Boolean isActive, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
            'Header_Text__c'=>widgetHeaderText,
            'Functionality__c'=>functionality,
            'Overlay_Restriction_Days__c'=>overlayRestrictionDays,
            'Type__c'=>Type,
            'What_Object__c'=>whatObject,
            'isActive__c'=>isActive,
            'Name'=>'Test',
            'OwnerId'=>user.Id
         };
        Feedback_Data__c feedbackData = TestObjectHelper.createFeedbackData(defaults, create);
        if (create) {
            insert feedbackData;
        }
        return feedbackData;
    }
    
    /** 
     * @description Create List<Feedback_Data__c>
     * @param user
     * @param List<String> widgetHeaderText
     * @param List<String> functionality
     * @param List<Double> overlayRestrictionDays
     * @param List<String> types
     * @param List<String> whatObject
     * @param isActive
     * @param amount
     * @param create
     * @return List<Feedback_Data__c>
     */ 
    public static List<Feedback_Data__c> createFeedbackDatas(User user, List<String> widgetHeaderText, List<String> functionality, List<Double> overlayRestrictionDays, List<String> types, List<String> whatObject, Boolean isActive,Integer amount, Boolean create){
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Header_Text__c'=>widgetHeaderText,
            'Functionality__c'=>functionality,
            'Overlay_Restriction_Days__c'=>overlayRestrictionDays,
            'Type__c'=>types,
            'What_Object__c'=>whatObject,
            'isActive__c'=>isActive,
            'Name'=>'Test'+counter,
            'OwnerId'=>user.Id
         };
        List<Feedback_Data__c> feedbackDatas = TestObjectHelper.createFeedbackDatas(amount, defaults, create);
        if (create) {
            insert feedbackDatas;
        }
        return feedbackDatas;
    }
    
    /** 
     * @description Create Feedback_Invite__c
     * @param user (owner)
     * @param user (participant)
     * @param Feedback__c
     * @param Status
     * @param create
     * @return Feedback_Invite__c
     */ 
    public static Feedback_Invite__c createFeedbackInvite(User owner, User participant, Feedback__c feedback, String status, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId'=>owner.Id,
             'Participant__c'=>participant.Id,
             'Feedback__c'=>feedback.Id,
             //'WhatId__c'=>feedbackWhatObject.Id,
             'Status__c'=>status,
             'Name'=>'TEST',
             'Invite_Date__c'=>Date.today()
        };
        Feedback_Invite__c feedbackInvite = TestObjectHelper.createFeedbackInvite(defaults, create);
        if (create) {
            insert feedbackInvite;
        }
        return feedbackInvite; 
        
    }
    
    /** 
     * @description Create List<Feedback_Invite__c>
     * @param Owner
     * @param participant
     * @param  List<Feedback__c>
     * @param List<String> Status
     * @param amount
     * @param create
     * @return List<Feedback_Invite__c>
     */ 
    public static List<Feedback_Invite__c> createFeedbackInvites(User owner, User participant, List<Feedback__c> feedbacks, List<String> status,Integer amount, Boolean create){
        List<Id> feedbackIds = new List<Id>();
        for(Feedback__c feedback : feedbacks){
            feedbackIds.add(feedback.Id);
        }
        
        /**List<Id> feedbackWhatObjectIds = new List<Id>();
        for(Feedback_What_Object__c feedbackWhatObject : feedbackWhatObjects){
            feedbackWhatObjectIds.add(feedbackWhatObject.Id);
        }*/
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'OwnerId'=>owner.Id,
             'Participant__c'=>participant.Id,
             'Feedback__c'=>feedbackIds,
             //'WhatId__c'=>feedbackWhatObjectIds,
             'Status__c'=>status,
             'Name'=>'TEST'+counter,
             'Invite_Date__c'=>Date.today()
        };
       List<Feedback_Invite__c> feedbackInvites = TestObjectHelper.createFeedbackInvites( amount, defaults, create);
        if (create) {
            insert feedbackInvites;
        }
        return feedbackInvites; 
    }
    /** 
     * @description Create Feedback_Response__c
     * @param User
     * @param Feedback__c
     * @param Feedback_Invite__c
     * @param create
     * @return Feedback_Response__c
     */ 
    public static Feedback_Response__c createFeedbackResponse(User owner, Feedback__c feedback, Feedback_Invite__c feedbackInvite, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
             'OwnerId'=>owner.Id,
             'Feedback__c'=>feedback.Id,
             'Feedback_Invite__c'=>feedbackInvite.Id,
             'Name'=>'TEST',
             'Completed_Date__c'=>Date.today()
        };
        Feedback_Response__c feedbackResponse = TestObjectHelper.createFeedbackResponse(defaults, create);
        if (create) {
            insert feedbackResponse;
        }
        return feedbackResponse; 
        
    }
     /**    
     * @description Create List<Feedback_Response__c>
     * @param User
     * @param List<Feedback__c>
     * @param List<Feedback_Invite__c>
     * @param amount
     * @param create
     * @return List<Feedback_Response__c>
     */ 
    public static List<Feedback_Response__c> createFeedbackResponses(User owner, List<Feedback__c> feedbacks, List<Feedback_Invite__c> feedbackInvites, Integer amount, Boolean create){
        List<Id> feedbackIds = new List<Id>();
        for(Feedback__c feedback : feedbacks){
            feedbackIds.add(feedback.Id);
        }
        
        List<Id> feedbackInviteIds = new List<Id>();
        for(Feedback_Invite__c feedbackInvite : feedbackInvites){
            feedbackInviteIds.add(feedbackInvite.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
             'OwnerId'=>owner.Id,
             'Feedback__c'=>feedbackIds,
             'Feedback_Invite__c'=>feedbackInviteIds,
             'Name'=>'TEST'+counter,
             'Completed_Date__c'=>Date.today()
        };
        List<Feedback_Response__c> feedbackResponses = TestObjectHelper.createFeedbackResponses(amount, defaults, create);
        if (create) {
            insert feedbackResponses;
        }
        return feedbackResponses; 
        
    }
    /** 
     * @description Create Feedback_Question__c
     * @param Feedback__c
     * @param questionOrder
     * @param questionType
     * @param create
     * @return Feedback_Question__c
     */ 
    public static Feedback_Question__c createFeedbackQuestion(Feedback__c feedback, Integer questionOrder, String questionType, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
                 'Feedback__c'=>feedback.Id,
                 'isMandatory__c'=>true,
                 'Question_Order__c'=>questionOrder,
                 'Question_Text__c'=>'SampleText',
                 'Question_Type__c'=>questionType,
                 'Name'=>'TEST'
        };
        Feedback_Question__c feedbackQuestion = TestObjectHelper.createFeedbackQuestion(defaults, create);
        if (create) {
            insert feedbackQuestion;
        }
        return feedbackQuestion; 
        
    }
     /**    
     * @description Create List<Feedback_Question__c> 
     * @param List<Feedback__c>
     * @param List<Integer> questionOrder
     * @param List<String> questionType
     * @param amount
     * @param create
     * @return List<Feedback_Question__c> 
     */ 
    public static List<Feedback_Question__c> createFeedbackQuestions(List<Feedback__c> feedbacks, List<Integer> questionOrders, List<String> questionTypes,  Integer amount, Boolean create){
        List<Id> feedbackIds = new List<Id>();
        for(Feedback__c feedback : feedbacks){
            feedbackIds.add(feedback.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
             'Feedback__c'=>feedbackIds,
                 'isMandatory__c'=>true,
                 'Question_Order__c'=>questionOrders,
                 'Question_Text__c'=>'SampleText'+counter,
                 'Question_Type__c'=>questionTypes,
                 'Name'=>'TEST'+counter
        };
        List<Feedback_Question__c> feedbackQuestions = TestObjectHelper.createFeedbackQuestions(amount, defaults, create);
        if (create) {
            insert feedbackQuestions;
        }
        return feedbackQuestions; 
        
    }
    /** 
     * @description Create Feedback_Question_Response__c
     * @param Feedback_Question__c
     * @param Feedback_Response__c
     * @param responseInteger
     * @param responseLongText
     * @param create
     * @return Feedback_Question_Response__c
     */     
    public static Feedback_Question_Response__c createFeedbackQuestionResponse(Feedback_Question__c feedbackQuestion,Feedback_Response__c feedbackResponse, String responseLongText, Integer responseInteger, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>{
                  'Feedback_Question__c'=>feedbackQuestion.Id,
                  'Feedback_Response__c'=>feedbackResponse.Id,
                  'Response__c'=>responseLongText,
                  'Name'=>'TEST',
                  'Response_Integer__c'=>responseInteger
        };
        Feedback_Question_Response__c feedbackQuestionResponse = TestObjectHelper.createFeedbackQuestionResponse(defaults, create);
        if (create) {
            insert feedbackQuestionResponse;
        }
        return feedbackQuestionResponse; 
        
    }
    /** 
     * @description Create List<Feedback_Question_Response__c>
     * @param List<Feedback_Question__c>
     * @param List<Feedback_Response__c>
     * @param List<String> responseLongTexts
     * @param List<Integer> responseIntegers
     * @param amount
     * @param create
     * @return List<Feedback_Question_Response__c>
     */ 
    public static List<Feedback_Question_Response__c> createFeedbackQuestionResponses(List<Feedback_Question__c> feedbackQuestions, List<Feedback_Response__c> feedbackResponses, List<String> responseLongTexts, List<Integer> responseIntegers, Integer amount, Boolean create){
        List<Id> feedbackQuestionIds = new List<Id>();
        for(Feedback_Question__c feedbackques : feedbackQuestions){
            feedbackQuestionIds.add(feedbackques.Id);
        }
        
        List<Id> feedbackResponseIds = new List<Id>();
        for(Feedback_Response__c feedbackResponse : feedbackResponses){
            feedbackResponseIds.add(feedbackResponse.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
                  'Feedback_Question__c'=>feedbackQuestionIds,
                  'Feedback_Response__c'=>feedbackResponseIds,
                  'Response__c'=>responseLongTexts,
                  'Name'=>'TEST'+counter,
                  'Response_Integer__c'=>responseIntegers
        };
        List<Feedback_Question_Response__c> feedbackQuestionResponses = TestObjectHelper.createFeedbackQuestionResponses(amount, defaults, create);
        if (create) {
            insert feedbackQuestionResponses;
        }
        return feedbackQuestionResponses; 
        
    }
     /**    
     * @description Create Feedback__c
     * @param User owner
     * @param feedbackCategory
     * @param Opportunity_Product__c
     * @param type
     * @param create
     * @return Feedback__c
     */
     public static Feedback__c createFeedback(User owner, String feedbackCategory, Opportunity_Product__c opptyProd, String type,  Boolean create){
         counter++;
         Map<String, Object> defaults = new Map<String, Object>{
                  'OwnerId'=>owner.Id,
                  'Feedback_Category__c'=>feedbackCategory,
                  'Opportunity_Product__c'=>opptyProd.Id,
                   //'Opportunity_Product_Cus__c'=>oliIds,
                   'Type__c'=>type,
                   'Related_To_ID__c'=>'12345'+counter,
                   'Related_To__c'=>'https://maersk--sit.my.salesforce.com/12345'+counter,
                  'Name'=>'TEST'
        };
        Feedback__c feedback = TestObjectHelper.createFeedback(defaults, create);
        if (create) {
            insert feedback;
        }
        return feedback; 
    }
     /**    
     * @description Create List<Feedback__c>
     * @param User owner
     * @param List<String> feedbackCategory
     * @param List<Opportunity_Product__c>
     * @param List<String> type
     * @param amount
     * @param create
     * @return List<Feedback__c>
     */
    public static List<Feedback__c> createFeedbacks(User owner, List<String> feedbackCategories, List<Opportunity_Product__c> opptyProds,  List<String> type, Integer amount, Boolean create){
        List<Id> opptyProdIds = new List<Id>();
        for(Opportunity_Product__c opptyprod : opptyProds){
            opptyProdIds.add(opptyprod.Id);
        }
        /**List<Id> oliIds = new List<Id>();
        for(Opportunity_Product_Cus__c opptyLineItem : oli){
            oliIds.add(opptyLineItem.Id);
        }*/
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
                  'OwnerId'=>owner.Id,
                  'Feedback_Category__c'=>feedbackCategories,
                  'Opportunity_Product__c'=>opptyProdIds,
                   //'Opportunity_Product_Cus__c'=>oliIds,
                   'Type__c'=>type,
                   'Related_To_ID__c'=>'12345'+counter,
                   'Related_To__c'=>'https://maersk--sit.my.salesforce.com/12345'+counter,
                  'Name'=>'TEST'+counter
        };
        List<Feedback__c> feedbacks = TestObjectHelper.createFeedbacks(amount, defaults, create);
        if (create) {
            insert feedbacks;
        }
        return feedbacks; 
    }
        /**
     * @description Creates a Geography__c record with specified country and geo code
     * @param name
     * @param locationType
     * @param geoCode
     * @param create
     * @return geography
     */
    public static Geography__c createGeography(String name, String locationType, Id parentGeography,  String geoCode, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => name,
            'Parent_Geography__c' => parentGeography,
            'GEO_Code__c' => geoCode,
            'Active__c' => true,
            'Type_Of_Location__c' => locationType
        };
        Geography__c geography = TestObjectHelper.createGeography(defaults, create);
        if (create) {
            insert geography;
        }
        return geography;
    }
    
    
     /**
     * @description Creates a Shipment
     * @param shipmentNumber
     * @param create
     * @return Shipment
     */
    public static Shipment__c createShipment (String shipmentNumber, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Shipment_Number__c' => shipmentNumber
        };
        Shipment__c shipment = TestObjectHelper.createShipment(defaults, create);
        if (create) {
            insert shipment;
        }
        return shipment;
    }
    
       /**
     * @description Creates an OceanPlusLead
     * @param bookingNumber
     * @param originCode
     * @param destinationCode
     * @param brand
     * @param shipperSCV,
     * @param cosigneeSCV, 
     * @param contractualSCV,
     * @param priceOwnerSCV, 
     * @param probability, 
     * @param create
     * @return OceanPlusLead
     */
    public static Ocean_Plus_Lead__c createOceanPlusLead (String bookingNumber, String originCode, String destinationCode, String brand, String shipperSCV, String cosigneeSCV,String contractualSCV, String priceOwnerSCV, Integer probability, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Booking_Number__c' => bookingNumber,
            'Origin_Country_Code__c' => originCode,
            'Destination_Country_Code__c' => destinationCode,
            'Brand__c' => brand,   
            'Shipper_SCV_Code__c' => shipperSCV,
            'Consignee_SCV_Code__c' => cosigneeSCV,
            'Contractual_SCV_Code__c' => contractualSCV,
            'Consignee_Contact_Email__c' => 'consignee@xyz.com',
            'Shipper_Contact_Email__c' => 'shipper@xyz.com',
            'Contractual_Contact_Email__c' => 'contractual@xyz.com',
            'Price_Owner_SCV_Code__c' => priceOwnerSCV,
            'CHB_IMP_Probability__c' => probability
        };
        Ocean_Plus_Lead__c opl = TestObjectHelper.createOceanPlusLead(defaults,create);
        if (create) {
            insert opl;
        }
        return opl;
    }
    
     /**
     * @description Creates a ServiceRelationship
     * @param account
     * @param country
     * @param brand
     * @param direction
     * @param create
     * @return ServiceRelationship
     */
    public static Care_Relationship__c createServiceRelationship (String account, String country, String brand, String direction, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
             'Account__c' => account,
             'Direction__c' => direction,
             'Status__c' => 'Active',
             'Service_Level__c' => 'CARE',
             'Liner_Brand__c' => brand,
             'Country__c' => country
        };
        Care_Relationship__c care = TestObjectHelper.createServiceRelationship(defaults, create);
        if (create) {
            insert care;
        }
        return care;
    }
    
    /**
     * @description Creates a Target Item Measure
     * @param SalesTargetItem
     * @param measureDimension
     * @param measureType
     * @param partyType
     * @param creditEligible
     * @param create
     * @return Target_Measure__c
     */
    public static Target_Measure__c createSalesTargetItemMeasure (Target_Item__c salesTargetItem, String measureDimension, String measureType, String partyType, Boolean creditEligible, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Credit_Eligible__c' => creditEligible,
            'Target_Item__c' => salesTargetItem,
            'Party_Type__c' => partyType,
            'Measure_Type__c' => measureType,
            'Measure_Dimension__c' => measureDimension,
            'Apr__c' => 112,
            'Aug__c' => 122,
            'Dec__c' => 234,
            'Feb__c' => 337,
            'Jan__c' => 453,
            'Jul__c' => 786,
            'Jun__c' => 877,
            'Mar__c' => 345,
            'May__c' => 678,
            'Nov__c' => 432,
            'Oct__c' => 678,
            'Sep__c' => 232
        };
        Target_Measure__c SalesTargetItemMeasure = TestObjectHelper.createSalesTargetItemMeasure(defaults, create);
        if (create) {
            insert SalesTargetItemMeasure;
        }
        return SalesTargetItemMeasure;
    }
    
    /**
     * @description Creates a list of Target Item Measure
     * @param SalesTargetItemList
     * @param measureDimensionList
     * @param measureTypeList
     * @param partyTypeList
     * @param creditEligibleList
     * @param create
     * @return List<Target_Measure__c>
     */
    public static List<Target_Measure__c> createSalesTargetItemMeasures(List<Target_Item__c> salesTargetItemsList, List<String> measureDimensionList, List<String> measureTypeList, List<String> partyTypeList, List<Boolean> creditEligibleList, Integer amount, Boolean create) {
        List<Id> SalesTargetItemIds = new List<Id>();
        for(Target_Item__c sti : salesTargetItemsList){
            SalesTargetItemIds.add(sti.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test' + counter,
            'Credit_Eligible__c' => creditEligibleList,
            'Target_Item__c' => SalesTargetItemIds,
            'Party_Type__c' => partyTypeList,
            'Measure_Type__c' => measureTypeList,
            'Measure_Dimension__c' => measureDimensionList,
            'Apr__c' => 112,
            'Aug__c' => 122,
            'Dec__c' => 234,
            'Feb__c' => 337,
            'Jan__c' => 453,
            'Jul__c' => 786,
            'Jun__c' => 877,
            'Mar__c' => 345,
            'May__c' => 678,
            'Nov__c' => 432,
            'Oct__c' => 678,
            'Sep__c' => 232
        };
        List<Target_Measure__c> SalesTargetItemMeasures = TestObjectHelper.createSalesTargetItemMeasures(amount, defaults, create);
        if (create) {
            insert SalesTargetItemMeasures;
        }
        return SalesTargetItemMeasures;
    }
    
    /**
     * @description Creates a Target Product Exclusion
     * @param Target__c
     * @param brand
     * @param area
     * @param country
     * @param region
     * @param productFamily
     * @param create
     * @return Target_Product_Exclusion__c
     */
    public static Target_Product_Exclusion__c createSalesTargetProductExclusion(Target__c salesTarget, String brand, BDA__c area, Geography__c country, BDA__c region, String productFamily, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Target__c' => salesTarget,
            'Brand__c' => brand,
            'Area__c' => area,
            'Country__c' => country,
            'Region__c' => region,
            'Product_Family__c' => productFamily
        };
        Target_Product_Exclusion__c SalesTargetProductExclusion = TestObjectHelper.createSalesTargetProductExclusion(defaults, create);
        if (create) {
            insert SalesTargetProductExclusion;
        }
        return SalesTargetProductExclusion;
    }
    
    /**
     * @description Creates a list of Target Product Exclusion
     * @param Target__c
     * @param brandList
     * @param areaList
     * @param countryList
     * @param regionList
     * @param productFamilyList
     * @param create
     * @return List<Target_Product_Exclusion__c>
     */
    public static List<Target_Product_Exclusion__c> createSalesTargetProductExclusions(List<Target__c> salesTargetList, List<String> brandList, List<BDA__c> areaList, List<Geography__c> countryList, List<BDA__c> regionList, List<String> productFamilyList, Integer amount, Boolean create) {
        List<Id> SalesTargetIds = new List<Id>();
        for(Target__c sti : salesTargetList){
            SalesTargetIds.add(sti.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test'+counter,
            'Target__c' => SalesTargetIds,
            'Brand__c' => brandList,
            'Area__c' => areaList,
            'Country__c' => countryList,
            'Region__c' => regionList,
            'Product_Family__c' => productFamilyList
        };
        List<Target_Product_Exclusion__c> SalesTargetProductExclusions = TestObjectHelper.createSalesTargetProductExclusions(amount, defaults, create);
        if (create) {
            insert SalesTargetProductExclusions;
        }
        return SalesTargetProductExclusions;
    }
    
    /**
     * @description Creates a Target Data Load
     * @param correlationId
     * @param dataLoadType
     * @param rofo
     * @param status
     * @param create
     * @return Target_Data_Load__c
     */
    public static Target_Data_Load__c createSalesTargetDataLoad(String correlationId, String dataLoadType, String rofo, String status, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Correlation_Id__c' => correlationId,
            'Data_Load_Type__c' => dataLoadType,
            'Rofo_Version__c' => rofo,
            'Status__c' => status
        };
        Target_Data_Load__c SalesTargetDataLoad = TestObjectHelper.createSalesTargetDataLoad(defaults, create);
        if (create) {
            insert SalesTargetDataLoad;
        }
        return SalesTargetDataLoad;
    }
    
    /**
     * @description Creates a list of Target Data Load
     * @param correlationIdList
     * @param dataLoadTypeList
     * @param rofoList
     * @param statusList
     * @param amount
     * @param create
     * @return List<Target_Data_Load__c>
     */
    public static List<Target_Data_Load__c> createSalesTargetDataLoads(List<String> correlationIdList, List<String> dataLoadTypeList, List<String> rofoList, List<String> statusList, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Correlation_Id__c' => correlationIdList,
            'Data_Load_Type__c' => dataLoadTypeList,
            'Rofo_Version__c' => rofoList,
            'Status__c' => statusList
        };
        List<Target_Data_Load__c> SalesTargetDataLoads = TestObjectHelper.createSalesTargetDataLoads(amount, defaults, create);
        if (create) {
            insert SalesTargetDataLoads;
        }
        return SalesTargetDataLoads;
    }
    
    /**
     * @description Creates a Target Brand Mapping
     * @param active
     * @param lnsBrand
     * @param sfBrand
     * @param create
     * @return Target_Brand_Mapping__c
     */
    public static Target_Brand_Mapping__c createSalesTargetBrandMapping(Boolean active, String lnsBrand, String sfBrand, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Active__c' => active,
            'LnS_Brand__c' => lnsBrand,
            'Salesforce_Brand__c' => sfBrand
        };
        Target_Brand_Mapping__c SalesTargetBrandMapping = TestObjectHelper.createSalesTargetBrandMapping(defaults, create);
        if (create) {
            insert SalesTargetBrandMapping;
        }
        return SalesTargetBrandMapping;
    }
    
    /**
     * @description Creates a list of Target Brand Mapping
     * @param activeList
     * @param lnsBrandList
     * @param sfBrandList
     * @param create
     * @return List<Target_Brand_Mapping__c>
     */
    public static List<Target_Brand_Mapping__c> createSalesTargetBrandMappings(List<Boolean> activeList, List<String> lnsBrandList, List<String> sfBrandList, Integer amount, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Active__c' => activeList,
            'LnS_Brand__c' => lnsBrandList,
            'Salesforce_Brand__c' => sfBrandList
        };
        List<Target_Brand_Mapping__c> SalesTargetBrandMappings = TestObjectHelper.createSalesTargetBrandMappings(amount, defaults, create);
        if (create) {
            insert SalesTargetBrandMappings;
        }
        return SalesTargetBrandMappings;
    }
    
    /**
     * @description Creates a Sales Target Product Mapping
     * @param active
     * @param legacypf
     * @param product
     * @param create
     * @return Legacy_Product_Mapping__c
     */
    public static Legacy_Product_Mapping__c createSalesTargetProductMapping(String legacypf, Product2 product, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test',
            'Legacy_Product_Family__c' => legacypf,
            'Product__c' => product
        };
        Legacy_Product_Mapping__c SalesTargetProductMapping = TestObjectHelper.createSalesTargetProductMapping(defaults, create);
        if (create) {
            insert SalesTargetProductMapping;
        }
        return SalesTargetProductMapping;
    }
    
    /**
     * @description Creates a list of Sales Target Product Mapping
     * @param active
     * @param legacypfList
     * @param productList
     * @param create
     * @return List<Legacy_Product_Mapping__c>
     */
    public static List<Legacy_Product_Mapping__c> createSalesTargetProductMappings(List<String> legacypfList, List<Product2> productList, Integer amount, Boolean create) {
        List<Id> ProductIds = new List<Id>();
        for(Product2 prod : productList){
            ProductIds.add(prod.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test'+counter,
            'Legacy_Product_Family__c' => legacypfList,
            'Product__c' => ProductIds
        };
        List<Legacy_Product_Mapping__c> SalesTargetProductMappings = TestObjectHelper.createSalesTargetProductMappings(amount, defaults, create);
        if (create) {
            insert SalesTargetProductMappings;
        }
        return SalesTargetProductMappings;
    }
    
    /**
     * @description Create Sales Budget Group
     * @param Target
     * @param Brand
     * @param countryCode
     * @param Area
     * @param Country
     * @param productFamily
     * @param StagingReference
     * @param create
     * @return Budget_Group__c
     */

    public static Budget_Group__c createSalesBudgetGroup(Target__c Target, String Brand, BDA__c Area, Geography__c Country, String productFamily, String StagingReference, Boolean create){
         counter++;
         Map<String, Object> defaults = new Map<String, Object>{
          'Target__c'=>Target.Id,
          'Brand__c' => Brand,
          'Executing_Area__c'=>Area.Id,
          'Executing_Country__c'=>Country.Id,
          'Product_Family__c'=>productFamily,
          'Staging_Reference__c'=>StagingReference,
          'Name'=>'Test'+counter

          };

        Budget_Group__c budgetGroup = TestObjectHelper.createSalesBudgetGroup(defaults, create);
        if (create) {
            insert budgetGroup;
        }
        return budgetGroup;
      }
    
    /**
     * @description Create Sales Budget Group
     * @param Target
     * @param BrandList
     * @param countryCodeList
     * @param AreaList
     * @param CountryList
     * @param productFamilyList
     * @param StagingReferenceList
     * @param amount
     * @param create
     * @return Budget_Group__c
     */
    
    public static List<Budget_Group__c> createSalesBudgetGroups(List<Target__c> targetList, List<String> brandsList, List<BDA__c> areasList, List<Geography__c> countriesList, List<String> productFamilyList, List<String> stagingReferenceList, Integer amount, Boolean create)
      {

       List<Id> TargetIds = new List<Id>();
        for(Target__c target : targetList){
            TargetIds.add(target.Id);
        }

        List<Id> areaIds = new List<Id>();
        for(BDA__c area : areasList){
            areaIds.add(area.Id);
        }

        List<Id> countryIds = new List<Id>();
        for(Geography__c country : countriesList){
            countryIds.add(country.Id);
        }

        counter++;
         Map<String, Object> defaults = new Map<String, Object>{
          'Target__c'=>TargetIds,
          'Brand__c' => brandsList,
          'Executing_Area__c'=>areaIds,
          'Executing_Country__c'=>countryIds,
          'Product_Family__c'=>productFamilyList,
          'Staging_Reference__c'=>stagingReferenceList,
          'Name'=>'Test'+counter

          };

        List<Budget_Group__c> salesBudgetGroups = TestObjectHelper.createSalesBudgetGroups(amount, defaults, create);
        if (create) {
            insert salesBudgetGroups;
        }
        return salesBudgetGroups;
      }
    
    /* 
    
        * @description Creates a Target Setting Staging
        * @param unitOfMeasure
        * @param measureDimension
        * @param status
        * @param create
        * @param salesBudgetGroup
        * @param measureDimension
        * @param measureType
        * @param brand
        * @param consignee
        * @param consigneeEligible
        * @param correlationId
        * @param countryCode
        * @param isGrowthPercent
        * @param poEligible
        * @param priceOwner
        * @param productFamily
        * @param rofoVersion
        * @param shipper
        * @param shipperEligible
        * @param year
        * @param create
        * @return <Target_Setting_Staging__c>
        */
    
         public static Target_Setting_Staging__c createTargetSettingStage(String unitOfMeasure, String measureDimension,String status,  String measureType, String brand, String consignee, Boolean consigneeEligible, String correlationId, String countryCode, Boolean isGrowthPercent, Boolean poEligible, String priceOwner, String productFamily, String rofoVersion, String shipper, Boolean shipperEligible, String year, Boolean create) {
    
            Map<String, Object> defaults = new Map<String, Object>{
                'Name' => 'Test'+counter,
                'Measure_Dimension__c' => measureDimension,
                'Measure_Type__c' => measureType,
                'Status__c' => status,
                'Unit_of_Measure__c' => unitOfMeasure,
                'Brand__c' => brand,
                'Consignee__c' => consignee,
                'Consignee_Eligible__c' => consigneeEligible,
                'Correlation_Id__c' => correlationId,
                'Country_Code__c' => countryCode,
                'IsGrowthPercent__c' => isGrowthPercent,
                'PO_Eligible__c' => poEligible,
                'Price_Owner__c' => priceOwner,
                'Product_Family__c' => productFamily,
                'RoFo_Version__c' => rofoVersion,
                'Shipper__c' => shipper,
                'Shipper_Eligible__c' => shipperEligible,
                'Year__c' => year,
                'Jan__c' => 10,
                'Feb__c' => 12,
                'Mar__c' => 14,
                'Apr__c' => 18,
                'May__c' => 19,
                'Jun__c' => 21,
                'Jul__c' => 23,
                'Aug__c' => 24,
                'Sep__c' => 25,
                'Oct__c' => 26,
                'Nov__c' => 27,
                'Dec__c' => 30
            };
    
            Target_Setting_Staging__c targetSettingStage = TestObjectHelper.createTargetSettingStage(defaults, create);
            if (create) {
                insert targetSettingStage;
            }
            return targetSettingStage;
        }
    
        /**   
        * @description Creates a list of Target Setting Staging
        * @param unitOfMeasure
        * @param measureDimension
        * @param status
        * @param create
        * @param salesBudgetGroupList
        * @param measureDimensionList
        * @param measureTypeList
        * @param brandList
        * @param consigneeList
        * @param consigneeEligibleList
        * @param correlationIdList
        * @param countryCodeList
        * @param isGrowthPercentList
        * @param poEligibleList
        * @param priceOwnerList
        * @param productFamilyList
        * @param rofoVersionList
        * @param shipperList
        * @param shipperEligibleList
        * @param yearList
        * @param create
        * @return List<Target_Setting_Staging__c>
        */
    
         public static List<Target_Setting_Staging__c> createTargetSettingStages(List<String> unitOfMeasureList, List<String> measureDimensionList, List<String> statusList,  List<String> measureTypeList, List<String> brandList, List<String> consigneeList, List<Boolean> consigneeEligibleList, List<String> correlationIdList, List<String> countryCodeList, List<Boolean> isGrowthPercentList, List<Boolean> poEligibleList, List<String> priceOwnerList, List<String> productFamilyList, List<String> rofoVersionList, List<String> shipperList, List<Boolean> shipperEligibleList, List<String> yearList, Integer amount, Boolean create) {
    
            counter++;
            Map<String, Object> defaults = new Map<String, Object>{
                'Name' => 'Test',
                'Measure_Dimension__c' => measureDimensionList,
                'Measure_Type__c' => measureTypeList,
                'Status__c' => statusList,
                'Unit_of_Measure__c' => unitOfMeasureList,
                'Brand__c' => brandList,
                'Consignee__c' => consigneeList,
                'Consignee_Eligible__c' => consigneeEligibleList,
                'Correlation_Id__c' => correlationIdList,
                'Country_Code__c' => countryCodeList,
                'IsGrowthPercent__c' => isGrowthPercentList,
                'PO_Eligible__c' => poEligibleList,
                'Price_Owner__c' => priceOwnerList,
                'Product_Family__c' => productFamilyList,
                'RoFo_Version__c' => rofoVersionList,
                'Shipper__c' => shipperList,
                'Shipper_Eligible__c' => shipperEligibleList,
                'Year__c' => yearList,
                'Jan__c' => 10,
                'Feb__c' => 12,
                'Mar__c' => 14,
                'Apr__c' => 18,
                'May__c' => 19,
                'Jun__c' => 21,
                'Jul__c' => 23,
                'Aug__c' => 24,
                'Sep__c' => 25,
                'Oct__c' => 26,
                'Nov__c' => 27,
                'Dec__c' => 30
    
            };
    
            List<Target_Setting_Staging__c> targetSettingStages = TestObjectHelper.createTargetSettingStages(amount, defaults, create);
            if (create) {
                insert targetSettingStages;
            }
    
            return targetSettingStages;
    
        }   
    
    /**   
        * @description Creates a Budget Measure
        * @param salesBudgetGroup
        * @param measureDimension
        * @param measureType
        * @param create
        * @return <Budget_Measure__c>
        */
    
         public static Budget_Measure__c createBudgetMeasure(Budget_Group__c salesBudgetGroup, String measureDimension, String measureType, Boolean create) {
    
            Map<String, Object> defaults = new Map<String, Object>{
                'Name' => 'Test',
                'Budget_Group__c' => salesBudgetGroup,
                'Measure_Dimension__c' => measureDimension,
                'Measure_Type__c' => measureType,
                'Jan__c' => 10,
                'Feb__c' => 12,
                'Mar__c' => 14,
                'Apr__c' => 18,
                'May__c' => 19,
                'Jun__c' => 21,
                'Jul__c' => 23,
                'Aug__c' => 24,
                'Sep__c' => 25,
                'Oct__c' => 26,
                'Nov__c' => 27,
                'Dec__c' => 30
            };
    
            Budget_Measure__c budgetMeasure = TestObjectHelper.createBudgetMeasure(defaults, create);
            if (create) {
                insert budgetMeasure;
            }
    
            return budgetMeasure;
        }
    
           /**    
    
        * @description Creates a list of Budget Measure
        * @param List <Budget_Group__c> salesBudgetGroup
        * @param List<String> measureDimensionList
        * @param List<String> measureTypeList
        * @param create
        * @param amount
        * @return List<Budget_Measure__c>
        */
    
         public static List<Budget_Measure__c> createBudgetMeasures(List<Budget_Group__c> salesBudgetGroupList, List<String> measureDimensionList, List<String>measureTypeList, Integer amount, Boolean create) {
    
            List<Id> salesBudgetIds = new List<Id>();
            for(Budget_Group__c i : salesBudgetGroupList){
                salesBudgetIds.add(i.Id);
            }
    
            counter++;
            Map<String, Object> defaults = new Map<String, Object>{
                'Budget_Group__c' => salesBudgetIds,
                'Name' => 'Test'+counter,
                'Measure_Dimension__c' => measureDimensionList,
                'Measure_Type__c' => measureTypeList,
                'Jan__c' => 10,
                'Feb__c' => 12,
                'Mar__c' => 14,
                'Apr__c' => 18,
                'May__c' => 19,
                'Jun__c' => 21,
                'Jul__c' => 23,
                'Aug__c' => 24,
                'Sep__c' => 25,
                'Oct__c' => 26,
                'Nov__c' => 27,
                'Dec__c' => 30
            };
    
            List<Budget_Measure__c> budgetMeasures = TestObjectHelper.createBudgetMeasures(amount, defaults, create);
            if (create) {
                insert budgetMeasures;
            }
    
            return budgetMeasures;
        }
    
      /**
     * @description Create sales Target Approval Matrix
     * @param Target
     * @param ApprovalStage
     * @param Area
     * @param SalesChannel
     * @param Vertical
     * @param create
     * @return Target_Stage_Matrix__c
     */

    public static Target_Stage_Matrix__c createSalesTargetApprovalMatrix(Target__c Target, String ApprovalStage, BDA__c Area, BDA__c region, String SalesChannel, String Vertical, Boolean create){
         
         Map<String, Object> defaults = new Map<String, Object>{
          'Target_Stage__c' => ApprovalStage,
          'Area__c' => Area.Id,
          'Region__c' => region,
          'Name' => 'Test',
          'Sales_Channel__c' => SalesChannel,
          'Target__c'=>Target.Id,
          'Vertical__c' => Vertical
          };

        Target_Stage_Matrix__c salesTargetApprovalMatrix = TestObjectHelper.createSalesTargetApprovalMatrix(defaults, create);
        if (create) {
            insert salesTargetApprovalMatrix;
        }
        return salesTargetApprovalMatrix;
      }
    
    /**
     * @description Create a list of sales Target Approval Matrix
     * @param targetList
     * @param approvalStageList
     * @param areasList
     * @param salesChannelList
     * @param verticalList
     * @param amount
     * @param create
     * @return List<Target_Stage_Matrix__c>
     */
    
    public static List<Target_Stage_Matrix__c> createSalesTargetApprovalMatrixs(List<Target__c> targetList, List<String> approvalStageList, List<BDA__c> areasList,  List<String> salesChannelList,  List<String> verticalList, Integer amount, Boolean create)
      {

        List<Id> TargetIds = new List<Id>();
        for(Target__c target : targetList){
            TargetIds.add(target.Id);
        }

        List<Id> areaIds = new List<Id>();
        for(BDA__c area : areasList){
            areaIds.add(area.Id);
        }
        counter++;
         Map<String, Object> defaults = new Map<String, Object>{
          'Target_Stage__c' => approvalStageList,
          'Target__c'=>TargetIds,
          'Area__c'=>areaIds,
          'Name'=>'Test'+counter,
          'Sales_Channel__c' => salesChannelList,
          'Vertical__c' => verticalList
          };

        List<Target_Stage_Matrix__c> salesTargetApprovalMatrixs = TestObjectHelper.createSalesTargetApprovalMatrixs(amount, defaults, create);
        if (create) {
            insert salesTargetApprovalMatrixs;
        }
        return salesTargetApprovalMatrixs;
      }
    
      /**
     * @description Create sales Target Approval User
     * @param SalesTargetApprovalMatrix
     * @param user
     * @param Approved
     * @param create
     * @return Target_Reviewer__c
     */

    public static Target_Reviewer__c createSalesTargetApprovalUser(Target_Stage_Matrix__c SalesTargetApprovalMatrix, User user, Boolean Approved, Boolean create){
         
         Map<String, Object> defaults = new Map<String, Object>{
          'Target_Approval_Matrix__c' => SalesTargetApprovalMatrix,
          'Related_User__c' => user.Id,
          'Approved__c' => Approved
          };

        Target_Reviewer__c salesTargetApprovalUser = TestObjectHelper.createSalesTargetApprovalUser(defaults, create);
        if (create) {
            insert salesTargetApprovalUser;
        }
        return salesTargetApprovalUser;
      }
    
    /**
     * @description Create a list of sales Target Approval User
     * @param SalesTargetApprovalMatrixList
     * @param user
     * @param ApprovedList
     * @param amount
     * @param create
     * @return List<Target_Reviewer__c>
     */
    
    public static List<Target_Reviewer__c> createSalesTargetApprovalUsers(List<Target_Stage_Matrix__c> SalesTargetApprovalMatrixList, User user, List<String> ApprovedList, Integer amount, Boolean create)
      {

        List<Id> TargetIds = new List<Id>();
        for(Target_Stage_Matrix__c target : SalesTargetApprovalMatrixList){
            TargetIds.add(target.Id);
        }
        counter++;
         Map<String, Object> defaults = new Map<String, Object>{
          'Target_Approval_Matrix__c' => TargetIds,
          'Related_User__c' => user.Id,
          'Name' => 'Test'+counter,
          'Approved__c' => ApprovedList
          };

        List<Target_Reviewer__c> salesTargetApprovalUsers = TestObjectHelper.createSalesTargetApprovalUsers(amount, defaults, create);
        if (create) {
            insert salesTargetApprovalUsers;
        }
        return salesTargetApprovalUsers;
    }

    /**
     * @description Creates a IntegrationStaging
     * @param operations
     * @param opsCount
     * @param relatedRecordId
     * @param create
     * @return IntegrationStaging
     */
    public static Integration_Staging__c createIntegrationStaging (String operations, Integer opsCount, String relatedRecordId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
             'Transaction__c' => 'Case Insert',
             'Operations__c' => operations,
             'Operations_Count__c' => opsCount,
             'Related_Record_Id__c' => relatedRecordId
        };
        Integration_Staging__c ins = TestObjectHelper.createIntegrationStaging(defaults, create);
        if (create) {
            insert ins;
        }
        return ins;
    }

    /**
     * @description Creates a IntegrationResults
     * @param insId
     * @param opsName
     * @param create
     * @return IntegrationResults
     */
    public static Integration_Results__c createIntegrationResults (String opsName, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
             'Operation_Name__c' => opsName,
             'Status__c' => 'New'
        };
        Integration_Results__c inRes = TestObjectHelper.createIntegrationResults(defaults, create);
        if (create) {
            insert inRes;
        }
        return inRes;
    }
    
    /**
     * @description Creates EmailMessage
     * @param csId
     * @param create
     * @return EmailMessage
     */
    public static EmailMessage createEmailMessage (Id csId, Boolean incoming, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
             'FromAddress' => 'test@maersk.com',
             'ToAddress' => 'hello@maersk.salesforce.com',
             'ToAddress' => 'test@maersk.com',
             'Subject' => 'Test email',
             'Status'  => '0',
             'TextBody'  => 'Sample Text',
             'ParentId'  => csId,
             'Incoming'  => incoming
        };
        EmailMessage emMsg = TestObjectHelper.createEmailMessage(defaults, create);
        if (create) {
            insert emMsg;
        }
        return emMsg;
    }
    
    /**
     * @description Creates ContentVersion
     * @param body
     * @param create
     * @return ContentVersion
     */
    public static ContentVersion createContentVersion (Blob body, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Title' => 'SampleTitle',
            'PathOnClient' => 'SampleTitle.jpg',
            'VersionData' => body,
            'origin' => 'H',
            'CreatedDate'  => System.now()
        };
        ContentVersion cv = TestObjectHelper.createContentVersion(defaults, create);
        if (create) {
            insert cv;
        }
        return cv;
    }
    
    /**
     * @description Creates ContentVersion
     * @param cdId
     * @param entityId
     * @param create
     * @return ContentVersion
     */
    public static ContentDocumentLink createContentDocumentLink (Id cdId, Id entityId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'ContentDocumentId' => cdId,
            'LinkedEntityId' => entityId,
            'ShareType' => 'V'
        };
        ContentDocumentLink cdl = TestObjectHelper.createContentDocumentLink(defaults, create);
        if (create) {
            insert cdl;
        }
        return cdl;
    }
    
    /**
     * @description Creates Booking_Information__c
     * @param csId
     * @param create
     * @return Booking_Information__c
     */
    public static Booking_Information__c createBookingInformation (Id csId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Bill_Of_Lading_Number__c' => '123456789',
            'Booking_Number__c' => 'Test12345'
        };
        Booking_Information__c bookInfo = TestObjectHelper.createBookingInformation(defaults, create);
        if (create) {
            insert bookInfo;
        }
        return bookInfo;
    }
    
    /**
     * @description Creates External_Party__c
     * @param csId
     * @param conId
     * @param create
     * @return External_Party__c
     */
    public static External_Party__c createExternalParty (Id csId, Id conId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Claim__c' => csId,
            'Contact__c' => conId,
            'External_Reference__c' => 'Test12345'
        };
        External_Party__c extParty = TestObjectHelper.createExternalParty(defaults, create);
        if (create) {
            insert extParty;
        }
        return extParty;
    }
    
     
    /**
     * @description Creates Case_Recommendation__c
     * @param csId
     * @param create
     * @return Case_Recommendation__c
     */
    public static Case_Recommendation__c createCaseRecommendation (String recordType, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
        };
        Case_Recommendation__c caseRecomm = TestObjectHelper.createCaseRecommendation(defaults, create);
        caseRecomm.RecordTypeId = SObjectType.Case_Recommendation__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
        if ('Email_Recommendation'.EqualsIgnoreCase(recordType)) {
            caseRecomm.Email_Recommendation__c = 'Dear User, \n\n Please accept this recommendation.\\n thanks';
            caseRecomm.Priority__c = 2;
            caseRecomm.Recommendation_Summary__c = '[Accept Recommendation]';
        }
        
        if (create) {
            insert caseRecomm;
        }
        return caseRecomm;
    }
    
    /**
     * @description Creates Equipment_Commodity__c
     * @param csId
     * @param create
     * @return Equipment_Commodity__c
     */
    public static Equipment_Commodity__c createEquipmentCommodity (Id csId, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test Container',
            'Claim__c' => csId
        };
        Equipment_Commodity__c equipCom = TestObjectHelper.createEquipmentCommodity(defaults, create);
        if (create) {
            insert equipCom;
        }
        return equipCom;
    }
    
    /**
     * @description Creates Feature records
     * @param featureName     
     * @param create
     * @return FeatureRec
     */
    public static Feature_CM__c createFeature (String featureName, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
             'Name' => featureName,
             'Description__c' => 'This is' + featureName + 'Package'
        };
        Feature_CM__c FeatureRec = TestObjectHelper.createFeature(defaults, create);
        if (create) {
            insert FeatureRec;
        }
        return FeatureRec;
    }
    
    /**
     * @description Creates Specification Parameter records
     * @param numberOfObjects 
     * @param featureName     
     * @param create
     * @return List of Specification_Parameter_CM__c
     */
    public static List<Specification_Parameter_CM__c> createSpecParams (Integer numberOfObjects,List<Feature_CM__c> listFeatures, Boolean create) {
       List<Id> featureIds = new List<Id>();
        for(Feature_CM__c ftr : listFeatures){
            featureIds.add(ftr.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test Param '+counter,
                        'Feature__c' => featureIds,
                        'Description__c' => 'Test Spec Param '+counter
                        };
        List<Specification_Parameter_CM__c> listSpecParams = TestObjectHelper.createSpecParams(numberOfObjects, defaults, create);
        if (create) {
            insert listSpecParams;
        }
        return listSpecParams;
        
        /*Map<String, Object> defaults = new Map<String, Object>();
        for (Integer j = 0; j < listFeatures.size()-1; j++) {
            //for (Integer i = 0; i < numberOfObjects; i++) {        
                defaults = new Map<String, Object>{            
                    'Name' => 'Test Param ',
                        'Feature__c' => listFeatures[j].id,
                        'Description__c' => 'Test Spec Param '
                        };
                            //}
        }
        List<Specification_Parameter_CM__c> listSpecParams = TestObjectHelper.createSpecParams(3,defaults, create);
        if (create) {
            insert listSpecParams;
        }
        return listSpecParams;*/
    }
    
    /**
     * @description Creates Specification Option records
     * @param numberOfObjects 
     * @param listSpecParams     
     * @param create
     * @return List of Specification_Option_CM__c
     */
    public static List<Specification_Option_CM__c> createSpecOptions (Integer numberOfObjects,List<Specification_Parameter_CM__c> listSpecificationParams, Boolean create) {
       List<Id> specparamIds = new List<Id>();
        for(Specification_Parameter_CM__c sp : listSpecificationParams){
            specparamIds.add(sp.Id);
        }
        counter++;
        Map<String, Object> defaults = new Map<String, Object>{
            'Name' => 'Test Option ' + counter,
                        'Specification_Parameter__c' => specparamIds,
                        'Description__c' => 'Test Spec Option ' + counter
                        };
        List<Specification_Option_CM__c> listSpecOptions = TestObjectHelper.createSpecOptions(numberOfObjects, defaults, create);
        if (create) {
            insert listSpecOptions;
        }
        return listSpecOptions;
        /* Map<String, Object> defaults = new Map<String, Object>();
        for (Integer j = 0; j < listSpecificationParams.size()-1; j++) {
            for (Integer i = 0; i < numberOfObjects; i++) {
                defaults = new Map<String, Object>{            
                    'Name' => 'Test Option ' + i,
                        'Specification_Parameter__c' => listSpecificationParams[j].Id,
                        'Description__c' => 'Test Spec Option ' + i
                        };
                            }
        }
        List<Specification_Option_CM__c> listSpecOptions = TestObjectHelper.createSpecOptions(1,defaults, create);
        if (create) {
            insert listSpecOptions;
        }
        return listSpecOptions;*/
    }
    
         /**
     * SC-9582  
     * @description Creates a Shipment Party
     * @param shipmentNumber
     * @param conPerson
     * @param partyNumber
     * @param create
     * @return Shipment
     */
    public static Party__c createShipmentParty (String shipmentNumber, String conPerson, String partyNumber, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Shipment_Number__c' => shipmentNumber,
            'Contact_Person__c' => conPerson,
            'Party_Number__c' => partyNumber
        };
        Party__c prty = TestObjectHelper.createShipmentParty(defaults, create);
        if (create) {
            insert prty;
        }
        return prty;
    }
    
    public static Target_Customer_Portfolio__C createTCPRecord (Target_Measure__c targetMeasure, Territory_Account_Association__c taa, User user, Boolean create) {
        Map<String, Object> defaults = new Map<String, Object>{
            'Assigned_Target__c' => targetMeasure ,
            'Territory_Account_Association__c' => taa,
            'Assigned_Sales_Rep__c' => user
        };
        Target_Customer_Portfolio__C tcp = TestObjectHelper.createTCP(defaults, create);
        if (create) {
            insert tcp;
        }
        return tcp;
    }
    
    //SFSE-12654
    public static Product_Reference__c createProductReference(String solutionId,List<String> productIds,Boolean create){
        Map<String, Object> defaults = new Map<String, Object>();
        for(String prodId : productIds){
            defaults.put('Product__c',prodId);
            defaults.put('Solution__c',solutionId);
        }
        Product_Reference__c prodRef = TestObjectHelper.createProductReference(defaults, create);
        if (create) {
            insert prodRef;
        }
        return prodRef;
    }
    
    //SFSE-13634
    public static Segmentation_Matrix__c createSegmentationMatrix(String parentbdaId, String childbdaId, String countryId,Boolean create){
        Map<String, Object> defaults = new Map<String, Object>();
            defaults.put('Region__c',parentbdaId);
            defaults.put('Area__c',childbdaId);
            defaults.put('Country__c',countryId);
        Segmentation_Matrix__c segmtrx = TestObjectHelper.createSegmentationMatrix(defaults, create);
        if (create) {
            insert segmtrx;
        }
        return segmtrx;
    }
    
    //SFSE-13634
    public static Segment_Data__c createSegmentaData(String productId, String SegmentId,Boolean create){
        Map<String, Object> defaults = new Map<String, Object>();
            defaults.put('Product__c',productId);
            defaults.put('Segmentation__c',SegmentId);
            defaults.put('Revenue_Unit__c',100);
            defaults.put('Default_GP__Margin',50);
            defaults.put('Active__c',true);
            defaults.put('Type__c','Revenue');
        Segment_Data__c segdata = TestObjectHelper.createSegmentData(defaults, create);
        if (create) {
            insert segdata;
        }
        return segdata;
    }
    
    //SC-10027
    public static ISR_Template__c createISRTemplate(String conId, Boolean create){
        Map<String, Object> defaults = new Map<String, Object>();
        defaults.put('Name', 'Test ISR Template');
        defaults.put('Contact__c',conId);
        defaults.put('Brand__c', 'Maersk Line');
        defaults.put('Case_Visibility__c', 'All Users');
        defaults.put('SF_4PL_Account__c', 'Unilever');
        defaults.put('Direction__c', 'Export');
        defaults.put('Resolver_Dept__c', 'Ocean: Finance - Account Receivables');
        defaults.put('Collaboration_Reason__c', 'Reconcilation');
        ISR_Template__c isrTempdata = TestObjectHelper.createISRTemplate(defaults, create);
        if (create) {
            insert isrTempdata;
        }
        return isrTempdata;
    }
}