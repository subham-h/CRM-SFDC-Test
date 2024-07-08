/**
 * @description SPI-100. This class contains methods for interacting with the generic custom metadata objects for brand and sub brand.
 * @author Ronnie@SF
 * @date 07/06/2022
 * 2.0 SFSE-8493   04-Aug-2022     Vazid@UST 	Added Hamburg Sud and Alianca brands in the logic.
 */
public virtual with sharing class BrandUtilities {
    
    // Maps containing all brands and sub brands respectively and later used in various methods in this class.
    private static final Map<String, Brand__mdt> BRANDMETADATAACTIVE;
    private static final Map<String, Brand__mdt> BRANDMETADATAALL;
    private static final Map<String, Sub_Brand__mdt> SUBBRANDMETADATA;
    private static final Map<String, Brand_File__mdt> BRANDFILEMETADATA;
    private static final String COMMA = ',';
    private static final String SEMICOLON = ';';
    
    // Static brand variables used where brand specific logic is needed.
    public static final String MAERSK;
    public static final String MAERSKL;
    public static final String MAERSKLINE;
    public static final String MAERSKLS;
    public static final String MCC;
    public static final String MLL;
    public static final String SAFMARINE;
    public static final String SEAGO;
    public static final String SEALAND;
    public static final String SEALANDAMERICAS;
    public static final String SEALANDASIA;
    public static final String SEALANDEUROPE;
    public static final String USFLAG;
    public static final String TWILL;
    public static final String HAMBURGSUD;//SFSE-8493
    public static final String ALIANCA;//SFSE-8493
    
    // Static brand-related variables used where brand specific logic is needed.
    public static final String MCC_MDSMAPPING;
    
    // Populate the brand maps and static variables
    static {
        BRANDMETADATAACTIVE = new Map<String, Brand__mdt>();
        BRANDMETADATAALL = new Map<String, Brand__mdt>();
        Map<String, Brand__mdt> brandMdtTemp = Brand__mdt.getAll();
        for (String key : brandMdtTemp.keySet()) {
            BRANDMETADATAALL.put(brandMdtTemp.get(key).MasterLabel, brandMdtTemp.get(key));
        }
        for (String key : BRANDMETADATAALL.keySet()) {
            if (BRANDMETADATAALL.get(key).Is_Active__c) {
                BRANDMETADATAACTIVE.put(BRANDMETADATAALL.get(key).MasterLabel, BRANDMETADATAALL.get(key));
            }
        }
        SUBBRANDMETADATA = new Map<String, Sub_Brand__mdt>();
        SUBBRANDMETADATA.putAll(Sub_Brand__mdt.getAll());

        BRANDFILEMETADATA = new Map<String, Brand_File__mdt>();
        
        // Brands
        MAERSK = Brand__mdt.getInstance('Maersk') != null ? Brand__mdt.getInstance('Maersk').MasterLabel : '';
        MAERSKL = 'Maersk L'; // Not a brand
        MAERSKLINE = Brand__mdt.getInstance('MaerskLine') != null ? Brand__mdt.getInstance('MaerskLine').MasterLabel : '';
        MAERSKLS = Brand__mdt.getInstance('MaerskLS') != null ? Brand__mdt.getInstance('MaerskLS').MasterLabel : '';
        MCC = Brand__mdt.getInstance('MCC') != null ? Brand__mdt.getInstance('MCC').MasterLabel : '';
        MLL = Brand__mdt.getInstance('MLL') != null ? Brand__mdt.getInstance('MLL').MasterLabel : '';
        SAFMARINE = Brand__mdt.getInstance('Safmarine') != null ? Brand__mdt.getInstance('Safmarine').MasterLabel : '';
        SEAGO = Brand__mdt.getInstance('Seago') != null ? Brand__mdt.getInstance('Seago').MasterLabel : '';
        SEALAND = Brand__mdt.getInstance('Sealand') != null ? Brand__mdt.getInstance('Sealand').MasterLabel : '';
        SEALANDAMERICAS = Brand__mdt.getInstance('SealandAmericas') != null ? Brand__mdt.getInstance('SealandAmericas').MasterLabel : '';
        SEALANDASIA = Brand__mdt.getInstance('SealandAsia') != null ? Brand__mdt.getInstance('SealandAsia').MasterLabel : '';
        SEALANDEUROPE = Brand__mdt.getInstance('SealandEurope') != null ? Brand__mdt.getInstance('SealandEurope').MasterLabel : '';
        USFLAG = Brand__mdt.getInstance('USFlag') != null ? Brand__mdt.getInstance('USFlag').MasterLabel : '';

        // Sub Brands
        TWILL = Sub_Brand__mdt.getInstance('Twill') != null ? Sub_Brand__mdt.getInstance('Twill').MasterLabel : '';
        
        //SFSE-8493
		HAMBURGSUD = Brand__mdt.getInstance('HamburgSud') != null ? Brand__mdt.getInstance('HamburgSud').MasterLabel : '';
        ALIANCA = Brand__mdt.getInstance('Alianca') != null ? Brand__mdt.getInstance('Alianca').MasterLabel : '';

        
        // Brand specific variables
        MCC_MDSMAPPING = BrandUtilities.getMDSMapping(MCC);
    }
    
    /**
     * @description Brand mocking used in unit test
     * @param mapping
     */
    @TestVisible
    public static void setBrandMock(Brand__mdt mapping) {
        BRANDMETADATAACTIVE.put(mapping.DeveloperName, mapping);
        BRANDMETADATAALL.put(mapping.DeveloperName, mapping);
    }
    
    /**
     * @description Sub-brand mocking used in unit test
     * @param mapping
     */
    @TestVisible
    public static void setSubBrandMock(Sub_Brand__mdt mapping) {
        SUBBRANDMETADATA.put(mapping.DeveloperName, mapping);
    }
    
    /**
     * @description Brand File mocking used in unit test
     * @param mapping
     */
    @TestVisible
    public static void setBrandFileMock(Brand_File__mdt mapping) {
        BRANDFILEMETADATA.put(mapping.DeveloperName, mapping);
    }
    
    /**
     * @description Populate the map BRANDFILEMETADATA upon request.
     */
    private static void populateBrandFileMetadata() {
        for (Brand_File__mdt brandFile : [
            SELECT MasterLabel, Brand__c, Brand__r.MasterLabel, Sub_Brand__c, Sub_Brand__r.MasterLabel, Type__c, Location__c, File_Name__c 
            FROM Brand_File__mdt
            ]) {
                BRANDFILEMETADATA.put(brandFile.MasterLabel, brandFile);
            }
    }
    
    /**
     * @description Returns the operator code for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandOperatorCode(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Operator_Code__c : '';
    }
    
    /**
     * @description Returns the brand for a specific operator code. Considers active records in the Brand metadata.
     * @param operatorCode
     * @return String
     */
    public static String getBrandFromOperatorCode(String operatorCode) {
        if (String.isNotBlank(operatorCode)) {
            for (String b : BRANDMETADATAACTIVE.keySet()) {
                if (BRANDMETADATAACTIVE.get(b).Operator_Code__c == operatorCode) {
                    return BRANDMETADATAACTIVE.get(b).MasterLabel;
                }
            }
        }
        return null;
    }
    
    /**
     * @description Returns the short form for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandShortForm(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Short_Form__c : '';
    }
    
    /**
     * @description Returns the VIP contract brand for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandVipContractBrand(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Vip_Contract_Brand__c : '';
    }
    
    /**
     * @description Returns the VIP contract company for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandVipContractCompany(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Vip_Contract_Company__c : '';
    }
    
    /**
     * @description Returns the website for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandWebsite(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Website__c : '';
    }
    
    /**
     * @description Returns the email domain for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandEmailDomain(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Email_Domain__c : '';
    }
    
    /**
     * @description Returns the mapped operator code for the MDS system. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getMDSMapping(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).MDS_Mapping__c : '';
    }
    
    /**
     * @description Returns the public group id(s) for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getPublicGroupIds(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Public_Group_Ids__c : '';
    }
    
    /**
     * @description Returns the dispute email address for a specific brand. Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getDisputeEmailAddress(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).Dispute_Email_Address__c : '';
    }
    
    /**
     * @description Returns the field Brand__mdt.All_Names__c, a string with comma separated previous/future names, configured for a particular brand. Used when brand names change.
     * Considers all records in the Brand metadata.
     * @param brand
     * @return String
     */
    public static String getBrandAllNames(String brand) {
        return BRANDMETADATAALL.containsKey(brand) ? BRANDMETADATAALL.get(brand).All_Names__c : '';
    }
    
    /**
     * @description Returns a list of strings with existing and previous/future names configured for a particular brand. Used when brand names change. Considers all records in the Brand metadata.
     * @param brand
     * @return List<String>
     */
    public static List<String> getListOfAllNamesForBrand(String brand) {
        List<String> allNames = new List<String>();
        String allNamesStr = getBrandAllNames(brand);
        if (String.isNotBlank(allNamesStr)) {
            allNames = allNamesStr.split(COMMA);
        }
        return allNames;
    }
    
    /**
     * @description Returns a map with all active brand records.
     * @return Map<String, Brand__mdt>
     */
    public static Map<String, Brand__mdt> getAllBrandsMap() {
        return BRANDMETADATAACTIVE;
    }
    
    
    /**
     * @description Return a list of strings with all active brand records.
     * @return List<String>
     */
    public static List<String> getAllBrandsList() {
        List<String> brands = new List<String>();
     	for (String brand : BRANDMETADATAACTIVE.keySet()) {
            brands.add(brand);
        }
        return brands;
    }
    
    /**
     * @description Return a String with all active brands separated by semicolon.
     * @return String
     */
    public static String getAllBrandsString() {
        return String.join(getAllBrandsList(), SEMICOLON);
    }
    
    /**
     * @description Return a list of strings with active brands that allow Relevant Content (RC) search.
     * @return List<String>
     */
    public static List<String> getAllBrandsListWithRCSearchAllowed() {
        List<String> brands = new List<String>();
     	for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (BRANDMETADATAACTIVE.get(brand).Relevant_Content_Search_Allowed__c) {
                brands.add(brand);
            }
        }
        return brands;
    }
    
    /**
     * @description Return a list of strings with active brands that are marked as sentiment brands.
     * @return List<String>
     */
    public static List<String> getAllSentimentBrandsList() {
        List<String> brands = new List<String>();
     	for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (BRANDMETADATAACTIVE.get(brand).Is_Sentiment__c) {
                brands.add(brand);
            }
        }
        return brands;
    }
    
    /**
     * @description Return a map with active brands and account owner field.
     * @return Map<String, String>
     */
    public static Map<String, String> getBrandAndAccountOwnerMap() {
        Map<String, String> brandAndAccOwner = new Map<String, String>();
        for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Account_Owner_Field__c)) {
                brandAndAccOwner.put(brand, BRANDMETADATAACTIVE.get(brand).Account_Owner_Field__c);
            }
        }
        return brandAndAccOwner;
    }
    
    /**
     * @description Return a map with short form and brand. Considers only active brands.
     * @return Map<String, String>
     */
    public static Map<String, String> getShortFormAndBrandMap() {
        Map<String, String> shortFormAndBrand = new Map<String, String>();
        for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Short_Form__c)) {
                shortFormAndBrand.put(BRANDMETADATAACTIVE.get(brand).Short_Form__c, brand);
            }
        }
        return shortFormAndBrand;
    }
    
    /**
     * @description Return a map with brand and operator code. Considers only active brands.
     * @return Map<String, String>
     */
    public static Map<String, String> getBrandAndOperatorCodeMap() {
        Map<String, String> brandAndOperatorCode = new Map<String, String>();
        for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Operator_Code__c)) {
                brandAndOperatorCode.put(brand, BRANDMETADATAACTIVE.get(brand).Operator_Code__c);
            }
        }
        return brandAndOperatorCode;
    }
    
    /**
     * @description Return a map with brand and operator code. Considers only active brands that have the service view flag set.
     * @return Map<String, String>
     */
    public static Map<String, String> getBrandAndOperatorCodeForServiceViewMap() {
        Map<String, String> brandAndOperatorCode = new Map<String, String>();
        for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Operator_Code__c) && BRANDMETADATAACTIVE.get(brand).Module__c == 'Service') {
                brandAndOperatorCode.put(brand, BRANDMETADATAACTIVE.get(brand).Operator_Code__c);
            }
        }
        return brandAndOperatorCode;
    }
    
    /**
     * @description Return operator code based on short form. Considers only active brands.
     * @param shortForm
     * @return String
     */
    public static String getOperatorCodeFromShortForm(String shortForm) {
        if (String.isNotBlank(shortForm)) {
            for (String brand : BRANDMETADATAACTIVE.keySet()) {
                if (BRANDMETADATAACTIVE.get(brand).Short_Form__c == shortForm) {
                    return BRANDMETADATAACTIVE.get(brand).Operator_Code__c;
                }
            }
        }
        return null;
    }
    
    /**
     * @description Return short form based on operator code. Considers only active brands.
     * @param operatorCode
     * @return String
     */
    public static String getShortFormFromOperatorCode(String operatorCode) {
        if (String.isNotBlank(operatorCode)) {
            for (String brand : BRANDMETADATAACTIVE.keySet()) {
                if (BRANDMETADATAACTIVE.get(brand).Operator_Code__c == operatorCode) {
                    return BRANDMETADATAACTIVE.get(brand).Short_Form__c;
                }
            }
        }
        return null;
    }
    
    /**
     * @description Return a map with live chat prefix and brand. Considers only active brands.
     * @return Map<String, String>
     */
    public static Map<String, String> getLiveChatPrefixAndBrandMap() {
        Map<String, String> liveChatPrefixAndBrand = new Map<String, String>();
        for (String brand : BRANDMETADATAACTIVE.keySet()) {
            if (String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Live_Chat_Prefix__c)) {
                // The developer name of Chat Deployment is used, so using underscore instead of space
                liveChatPrefixAndBrand.put(BRANDMETADATAACTIVE.get(brand).Live_Chat_Prefix__c, brand.replace(' ', '_'));
            }
        }
        return liveChatPrefixAndBrand;
    }
    
    /**
     * @description Return a map with brand and org wide email address id. Considers all brand records.
     * @return Map<String, String>
     */
    public static Map<String, Id> getBrandAndOrgWideEmailAddressIdMap() {
        Map<String, Id> brandAndOrgWideEmailAddressId = new Map<String, String>();
        Set<String> orgWideEmailAddresses = new Set<String>();
        for (String brand : BRANDMETADATAALL.keySet()) {
            if (String.isNotBlank(BRANDMETADATAALL.get(brand).Org_Wide_Email_Address__c)) {
                orgWideEmailAddresses.add(BRANDMETADATAALL.get(brand).Org_Wide_Email_Address__c);
            }
        }
        for (OrgWideEmailAddress owea : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :orgWideEmailAddresses]) {
            for (String brand : BRANDMETADATAALL.keySet()) {
                if (String.isNotBlank(BRANDMETADATAALL.get(brand).Org_Wide_Email_Address__c) && owea.Address == BRANDMETADATAALL.get(brand).Org_Wide_Email_Address__c) {
                    brandAndOrgWideEmailAddressId.put(brand, owea.Id); // Multiple brands can have the same org wide email address
                }
            }
        }
        return brandAndOrgWideEmailAddressId;
    }
      
    //Test
    public static string getBrandAndOrgWideEmailAddress(string brand) {
    		    String orgWideEmailAddress;
                orgWideEmailAddress = BRANDMETADATAALL.get(brand).Org_Wide_Email_Address__c;
        	    return orgWideEmailAddress;     
    }
    
    /**
     * @description Return a boolean identifying if the brand has a Live Chat Dpeloyment or not - i.e. if the brand has a Live_Chat_Prefix__c value in Brand__mdt. 
     * Note that developerName is used, so using underscore instead of space. Considers only active brands.
     * @return Map<String, String>
     */
    public static Boolean hasLiveChatDeployment(String developerName) {
        String brand = String.isNotBlank(developerName) ? developerName.replace('_', ' ') : null;
        return BRANDMETADATAACTIVE.containsKey(brand) && String.isNotBlank(BRANDMETADATAACTIVE.get(brand).Live_Chat_Prefix__c) ? true : false;
    }
    
    /**
     * @description Returns the operator code for a specific brand or sub brand. Brand takes precedence over sub brand.
     * Considers all brand records.
     * @param brand
     * @return String
     */
    public static String getBrandOrSubBrandOperatorCode(String brand) {
        if (BRANDMETADATAALL.containsKey(brand)) {
            return BRANDMETADATAALL.get(brand).Operator_Code__c;
        } else if (SUBBRANDMETADATA.containsKey(brand)) {
            return SUBBRANDMETADATA.get(brand).Operator_Code__c;
        }
        return null;
    }

    /**
     * @description Returns the file location of a file related to a brand or sub brand. Brand takes precedence over sub brand.
     * @param brand 
     * @param type 
     * @return String
     */
    public static String getBrandOrSubBrandFileLocation(String brand, String type) {
        if (BRANDFILEMETADATA.isEmpty()) { populateBrandFileMetadata(); }
        for (Brand_File__mdt brandFile : BRANDFILEMETADATA.values()) {
            if (brandFile.Brand__r.MasterLabel == brand &&
                brandFile.Type__c == type) {
                return brandFile.Location__c;
            } else if (brandFile.Sub_Brand__r.MasterLabel == brand &&
                brandFile.Type__c == type) {
                return brandFile.Location__c;
            }
        }
        return null;
    }

    /**
     * @description Returns the file location of a file related to a brand or sub brand. Brand takes precedence over sub brand.
     * @param brand 
     * @param type 
     * @return String
     */
    public static String getBrandOrSubBrandFileName(String brand, String type) {
        if (BRANDFILEMETADATA.isEmpty()) { populateBrandFileMetadata(); }
        for (Brand_File__mdt brandFile : BRANDFILEMETADATA.values()) {
            if (brandFile.Brand__r.MasterLabel == brand &&
                brandFile.Type__c == type) {
                return brandFile.File_Name__c;
            } else if (brandFile.Sub_Brand__r.MasterLabel == brand &&
                brandFile.Type__c == type) {
                return brandFile.File_Name__c;
            }
        }
        return null;
    }
    
    /* Aura enabled methods and inner class */
    
    /**
     * @description Returns a list of strings with existing and previous/future names configured for a particular brand. Used when brand names change.
     * Considers all brand records.
     * @param brand
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getAllNamesForBrand(String brand) {
        List<String> allNames = new List<String>();
        String allNamesStr = getBrandAllNames(brand);
        if (String.isNotBlank(allNamesStr)) {
            allNames = allNamesStr.split(COMMA);
        }
        return allNames;
    }
    
    /**
     * @description Get all brands.
     * @return Brands
     */
    @AuraEnabled (cacheable=true)
    public static Brands getAllBrands() {
        return new Brands(new BrandUtilities());
    }
    
    /**
     * @description Return operator code based on short form. Considers only active brand records.
     * @param shortForm
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getOperatorCodeBasedOnShortForm(String shortForm) {
        return getOperatorCodeFromShortForm(shortForm);
    }
    
    /**
     * @description Return short form based on operator code. Considers only active brand records.
     * @param operatorCode
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getShortFormBasedOnOperatorCode(String operatorCode) {
        return getShortFormFromOperatorCode(operatorCode);
    }
    
    /**
     * @description Return operator code based on brand. Considers all brand records.
     * @param brand
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getOperatorCodeBasedOnBrand(String brand) {
        return getBrandOperatorCode(brand);
    }
    
    /**
     * @description Return brand based on operator code. Considers only active brand records.
     * @param operatorCode
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getBrandBasedOnOperatorCode(String operatorCode) {
        return getBrandFromOperatorCode(operatorCode);
    }
    
    /**
     * @description Returns the VIP contract brand for a specific brand. Considers all brand records.
     * @param brand
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getVipContractBrandBasedOnBrand(String brand) {
        return getBrandVipContractBrand(brand);
    }
    
    /**
     * @description Returns the VIP contract company for a specific brand. Considers all brand records.
     * @param brand
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getVipContractCompanyBasedOnBrand(String brand) {
        return getBrandVipContractCompany(brand);
    }
    
    /**
     * @description Returns the website for a specific brand. Considers all brand records.
     * @param brand
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getWebsiteBasedOnBrand(String brand) {
        return getBrandWebsite(brand);
    }
    
    /**
     * @description Returns the email domain for a specific brand. Considers all brand records.
     * @param brand
     * @return String
     */
    @AuraEnabled (cacheable=true)
    public static String getEmailDomainBasedOnBrand(String brand) {
        return getBrandEmailDomain(brand);
    }
    
    /**
     * @description Return a map with brand and operator code. Considers only active brand records.
     * @return Map<String, String>
     */
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getBrandAndOperatorCode() {
        return getBrandAndOperatorCodeMap();
    }
    
    /**
     * @description Return a map with brand and operator code. Considers only active brand records.
     * @return Map<String, String>
     */
    @AuraEnabled (cacheable=true)
    public static Map<String, String> getBrandAndOperatorCodeForServiceView() {
        return getBrandAndOperatorCodeForServiceViewMap();
    }
    
    /**
     * @description Inner class with brands exposed to LWC and Aura
     */
    public class Brands extends BrandUtilities {
        
        BrandUtilities brandUtils;
        
        @AuraEnabled
        public String MAERSK {get;set;}
        @AuraEnabled
        public List<String> MAERSK_ALLNAMES {get;set;}
        @AuraEnabled
        public String MAERSKLINE {get;set;}
        @AuraEnabled
        public List<String> MAERSKLINE_ALLNAMES {get;set;}
        @AuraEnabled
        public String MAERSKLS {get;set;}
        @AuraEnabled
        public List<String> MAERSKLS_ALLNAMES {get;set;}
        @AuraEnabled
        public String MCC {get;set;}
        @AuraEnabled
        public List<String> MCC_ALLNAMES {get;set;}
        @AuraEnabled
        public String MCC_MDSMAPPING {get;set;}
        @AuraEnabled
        public String MCC_OPERATORCODE {get;set;}
        @AuraEnabled
        public String MLL {get;set;}
        @AuraEnabled
        public List<String> MLL_ALLNAMES {get;set;}
        @AuraEnabled
        public String MLL_OPERATORCODE {get;set;}
        @AuraEnabled
        public String SEAGO {get;set;}
        @AuraEnabled
        public List<String> SEAGO_ALLNAMES {get;set;}
        @AuraEnabled
        public String SEALAND {get;set;}
        @AuraEnabled
        public List<String> SEALAND_ALLNAMES {get;set;}
        @AuraEnabled
        public String USFLAG {get;set;}
        @AuraEnabled
        public List<String> USFLAG_ALLNAMES {get;set;}
        //SFSE-8493
        @AuraEnabled
        public String HAMBURGSUD {get;set;}
        @AuraEnabled
        public List<String> HAMBURGSUD_ALLNAMES {get;set;}
        @AuraEnabled
        public String ALIANCA {get;set;}
        @AuraEnabled
        public List<String> ALIANCA_ALLNAMES {get;set;}
        
        public Brands(BrandUtilities brandUtils) {
            this.brandUtils = brandUtils;
            this.MAERSK = BrandUtilities.MAERSK;
            this.MAERSKLINE = BrandUtilities.MAERSKLINE;
            this.MAERSKLS = BrandUtilities.MAERSKLS;
            this.MCC = BrandUtilities.MCC;
            this.MLL = BrandUtilities.MLL;
            this.SEAGO = BrandUtilities.SEAGO;
            this.SEALAND = BrandUtilities.SEALAND;
            this.USFLAG = BrandUtilities.USFLAG;
            //SFSE-8493
            this.HAMBURGSUD = BrandUtilities.HAMBURGSUD;
            this.ALIANCA = BrandUtilities.ALIANCA;
            
            this.MAERSK_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.MAERSK);
            this.MAERSKLINE_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.MAERSKLINE);
            this.MAERSKLS_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.MAERSKLS);
            this.MCC_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.MCC);
            this.MLL_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.MLL);
            this.SEAGO_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.SEAGO);
            this.SEALAND_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.SEALAND);
            this.USFLAG_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.USFLAG);
            //SFSE-8493
            this.HAMBURGSUD_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.HAMBURGSUD);
            this.ALIANCA_ALLNAMES = BrandUtilities.getAllNamesForBrand(this.ALIANCA);
            
            this.MLL_OPERATORCODE = BrandUtilities.getBrandOperatorCode(this.MLL);
            this.MCC_OPERATORCODE = BrandUtilities.getBrandOperatorCode(this.MCC);
            this.MCC_MDSMAPPING = BrandUtilities.getMDSMapping(this.MCC);
        }
    }
}