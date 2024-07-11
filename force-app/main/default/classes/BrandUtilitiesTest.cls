/**
 * @description SPI-100. Test class for BrandUtilities
 * @author Ronnie@SF
 * @date 07/06/2022
 */
@isTest
private class BrandUtilitiesTest {
    
	private static final Brand__mdt BRANDS = (Brand__mdt) JSON.deserialize('{"Label":"Brand1", "MasterLabel":"Brand1", "DeveloperName":"Brand1", "All_Names__c":"Brand1,Brand 1 old", "Operator_Code__c":"BRAN1", "Account_Owner_Field__c":"Brand1_Account_Owner__c", "Short_Form__c":"BRA", "Relevant_Content_Search_Allowed__c":true, "Live_Chat_Prefix__c":"MSL_CS_", "Is_Valid_Brand__c":true, "Is_Sentiment__c":true, "MDS_Mapping__c":"abcd", "Is_Active__c":true, "Public_Group_Ids__c":"abcde", "Org_Wide_Email_Address__c":"test@example.com", "Module__c":"Service"}', Brand__mdt.class);
    private static final Sub_Brand__mdt SUBBRANDS = (Sub_Brand__mdt) JSON.deserialize('{"Label":"SubBrand1", "MasterLabel":"SubBrand1", "DeveloperName":"SubBrand1", "Operator_Code__c":"SUBB1"}', Sub_Brand__mdt.class);
    private static final Brand_File__mdt BRANDFILES = (Brand_File__mdt) JSON.deserialize('{"Label":"BrandFile1", "MasterLabel":"BrandFile1", "DeveloperName":"BrandFile1", "Brand__r":'+JSON.serialize(BRANDS)+', "Type__c":"Type1", "Location__c":"Loc1", "File_Name__c":"File1"}', Brand_File__mdt.class);
    private static final String EMPTYSTRING = '';
    
    // Test method for getAllBrands, used for exposing brands etc to LWC and Aura
    @isTest
    static void testGetAllBrands() {
        Test.startTest();
        BrandUtilities.Brands brands;
        brands = BrandUtilities.getAllBrands();
        Test.stopTest();
        System.assertNotEquals(null, brands, 'Brands is null.');
        System.assertEquals(BrandUtilities.MAERSK, brands.Maersk, 'Brand mismatch.');
    }
    
    // Test methods for getBrandOperatorCode
    
    @isTest
    static void testGetBrandOperatorCode() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getBrandOperatorCode(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Operator_Code__c, operatorCode, 'Operator code mismatch.');
    }
    
    @isTest
    static void testGetBrandOperatorCodeNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getBrandOperatorCode(null);
        Test.stopTest();
        System.assertEquals(EMPTYSTRING, operatorCode, 'Operator code mismatch.');
    }
    
    @isTest
    static void testGetBrandOperatorCodeEmptyString() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getBrandOperatorCode('');
        Test.stopTest();
        System.assertEquals(EMPTYSTRING, operatorCode, 'Operator code mismatch.');
    }
    
    // Test methods for getBrandShortForm
    
    @isTest
    static void testGetBrandShortForm() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String shortForm = BrandUtilities.getBrandShortForm(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Short_Form__c, shortForm, 'Short form mismatch.');
    }
    
    @isTest
    static void testGetBrandShortFormNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String shortForm = BrandUtilities.getBrandShortForm(null);
        Test.stopTest();
        System.assertEquals(EMPTYSTRING, shortForm, 'Short form mismatch.');
    }
    
    @isTest
    static void testGetBrandShortFormEmptyString() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String shortForm = BrandUtilities.getBrandShortForm('');
        Test.stopTest();
        System.assertEquals(EMPTYSTRING, shortForm, 'Short form mismatch.');
    }
    
    // Test method for getBrandVipContractBrand
    @isTest
    static void testGetBrandVipContractBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String vipContractBrand = BrandUtilities.getBrandVipContractBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Vip_Contract_Brand__c, vipContractBrand, 'VIP contract mismatch.');
    }
    
    // Test method for getBrandVipContractCompany
    @isTest
    static void testGetBrandVipContractCompany() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String vipContractCompany = BrandUtilities.getBrandVipContractCompany(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Vip_Contract_Company__c, vipContractCompany, 'VIP contract company mismatch');
    }
    
    // Test method for getBrandWebsite
    @isTest
    static void testGetBrandWebsite() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String website = BrandUtilities.getBrandWebsite(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Website__c, website, 'Website mismatch.');
    }
    
    // Test method for getBrandEmailDomain
    @isTest
    static void testGetBrandEmailDomain() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String emailDomain = BrandUtilities.getBrandEmailDomain(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Email_Domain__c, emailDomain, 'Email domain mismatch.');
    }
    
    // Test method for getMDSMapping
    @isTest
    static void testGetMDSMapping() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String mdsMapping = BrandUtilities.getMDSMapping(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.MDS_Mapping__c, mdsMapping, 'MDS mapping mismatch.');
    }
    
    // Test method for getPublicGroupIds
    @isTest
    static void testGetPublicGroupIds() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String publicGroupIds = BrandUtilities.getPublicGroupIds(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Public_Group_Ids__c, publicGroupIds, 'Group mismatch.');
    }
    
    // Test method for getDisputeEmailAddress
    @isTest
    static void testGetDisputeEmailAddress() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String disputeEmailAddress = BrandUtilities.getDisputeEmailAddress(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Dispute_Email_Address__c, disputeEmailAddress, 'Dispute Email Address mismatch.');
    }
    
    // Test method for getListOfAllNamesForBrand
    @isTest
    static void testGetListOfAllNamesForBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> allNames = BrandUtilities.getListOfAllNamesForBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assert(allNames.size() > 1, 'Size of allNames too small.');
        System.assert(allNames.contains(BRANDS.MasterLabel), 'Brand name missing.');
    }
    
    // Test method for getListOfAllNamesForBrand with null input
    @isTest
    static void testGetListOfAllNamesForBrandNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> allNames = BrandUtilities.getListOfAllNamesForBrand(null);
        Test.stopTest();
        System.assertNotEquals(null, allNames, 'Returned null.');
        System.assert(allNames.isEmpty(), 'Names list not empty.');
    }
    
    // Test methods for getAllNamesForBrand
    
    @isTest
    static void testGetAllNamesForBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> allNames = BrandUtilities.getAllNamesForBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assert(allNames.size() > 1, 'Size of allNames too small.');
        System.assert(allNames.contains(BRANDS.MasterLabel), 'Brand name missing.');
    }
    
    @isTest
    static void testGetAllNamesForBrandNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> allNames = BrandUtilities.getAllNamesForBrand(null);
        Test.stopTest();
        System.assertNotEquals(null, allNames, 'Returned null.');
        System.assert(allNames.isEmpty(), 'Names list not empty.');
    }
    
    @isTest
    static void testGetAllNamesForBrandEmptyString() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> allNames = BrandUtilities.getAllNamesForBrand('');
        Test.stopTest();
        System.assertNotEquals(null, allNames, 'Returned null.');
        System.assert(allNames.isEmpty(), 'Names list not empty.');
    }
    
    // Test method for getAllBrandsMap
    @isTest
    static void testGetAllBrandsMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, Brand__mdt> brandMap = BrandUtilities.getAllBrandsMap();
        Test.stopTest();
        System.assert(brandMap.size() > 0, 'Brand map size is 0.');
    }
    
    // Test method for getAllBrandsList
    @isTest
    static void testGetAllBrandsList() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> brandList = BrandUtilities.getAllBrandsList();
        Test.stopTest();
        System.assert(brandList.size() > 0, 'Brand list size is 0.');
        System.assertEquals(true, brandList.contains(BRANDS.MasterLabel), 'Missing masterlabel.');
    }

	// Test method for getAllBrandsListWithRCSearchAllowed
    @isTest
    static void testGetAllBrandsListWithRCSearchAllowed() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> brandList = BrandUtilities.getAllBrandsListWithRCSearchAllowed();
        Test.stopTest();
        System.assert(brandList.size() > 0, 'Brand list size is 0.');
    }
    
    // Test method for getAllBrandsListWithRCSearchAllowed
    @isTest
    static void testGetAllSentimentBrandsList() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        List<String> brandList = BrandUtilities.getAllSentimentBrandsList();
        Test.stopTest();
        System.assert(brandList.size() > 0, 'Brand list size is 0.');
    }
    
    // Test method for getAllBrandsString
    @isTest
    static void testGetAllBrandsString() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String brands = BrandUtilities.getAllBrandsString();
        Test.stopTest();
        System.assertNotEquals(null, brands, 'Brands are null.');
    }
    
    // Test method for getBrandAndAccountOwnerMap
    @isTest
    static void testGetBrandAndAccountOwnerMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> brandAndAccOwner = BrandUtilities.getBrandAndAccountOwnerMap();
        Test.stopTest();
        System.assert(brandAndAccOwner.size() > 0, 'Brand and Account Owner map size is 0.');
        System.assertEquals(BRANDS.Account_Owner_Field__c, brandAndAccOwner.get(BRANDS.MasterLabel), 'Account owner mismatch.');
    }
    
    // Test method for getShortFormAndBrandMap
    @isTest
    static void testGetShortFormAndBrandMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> shortFormAndBrand = BrandUtilities.getShortFormAndBrandMap();
        Test.stopTest();
        System.assert(shortFormAndBrand.size() > 0, 'Short Form and Brand map size is 0.');
        System.assertEquals(BRANDS.MasterLabel, shortFormAndBrand.get(BRANDS.Short_Form__c), 'Short form mismatch.');
    }
    
    // Test method for getBrandAndOperatorCodeMap
    @isTest
    static void testGetBrandAndOperatorCodeMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> brandAndOperatorCode = BrandUtilities.getBrandAndOperatorCodeMap();
        Test.stopTest();
        System.assert(brandAndOperatorCode.size() > 0, 'Brand and Operator Code map size is 0.');
        System.assertEquals(BRANDS.Operator_Code__c, brandAndOperatorCode.get(BRANDS.MasterLabel), 'Operator code mismatch.');
    }
    
    // Test method for getLiveChatPrefixAndBrandMap
    @isTest
    static void testGetLiveChatPrefixAndBrandMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> liveChatPrefixAndBrand = BrandUtilities.getLiveChatPrefixAndBrandMap();
        Test.stopTest();
        System.assert(liveChatPrefixAndBrand.size() > 0, 'Live Chat Prefix and Brand map size is 0.');
        System.assertEquals(BRANDS.MasterLabel, liveChatPrefixAndBrand.get(BRANDS.Live_Chat_Prefix__c), 'Live chat prefix mismatch.');
    }
    
    // Test method for hasLiveChatDeployment
    @isTest
    static void testHasLiveChatDeployment() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Boolean hasLiveChatDeployment = BrandUtilities.hasLiveChatDeployment(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(true, hasLiveChatDeployment, 'Live chat prefix is not set.');
    }
    
    // Test method for getBrandAndOrgWideEmailAddressIdMap
    @isTest
    static void getBrandAndOrgWideEmailAddressIdMap() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> orgWideEmailAddresses = BrandUtilities.getBrandAndOrgWideEmailAddressIdMap();
        Test.stopTest();
        if (BrandUtilities.getAllBrandsList().size() == 1) {
            System.assert(orgWideEmailAddresses.isEmpty(), 'Org wide email address from test data exists.');
        }
    }
    
    // Test methods for getBrandOrSubBrandOperatorCode
    
    @isTest
    static void testGetBrandOrSubBrandOperatorCodeBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getBrandOrSubBrandOperatorCode(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Operator_Code__c, operatorCode, 'Operator Code mismatch.');
    }
    
    @isTest
    static void testGetBrandOrSubBrandOperatorCodeSubBrand() {
        BrandUtilities.setSubBrandMock(SUBBRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getBrandOrSubBrandOperatorCode(SUBBRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(SUBBRANDS.Operator_Code__c, operatorCode, 'Operator Code mismatch.');
    }
    
    // Test method for getOperatorCodeFromShortForm
    @isTest
    static void testGetOperatorCodeFromShortForm() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getOperatorCodeFromShortForm(BRANDS.Short_Form__c);
        Test.stopTest();
        System.assertEquals(BRANDS.Operator_Code__c, operatorCode, 'Operator Code mismatch.');
    }
    
    // Test method for getOperatorCodeFromShortForm with null input
    @isTest
    static void testGetOperatorCodeFromShortFormNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getOperatorCodeFromShortForm(null);
        Test.stopTest();
        System.assertEquals(null, operatorCode, 'Operator Code not null.');
    }
    
    // Test Aura Enabled method getOperatorCodeBasedOnShortForm
    @isTest
    static void testGetOperatorCodeBasedOnShortForm() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getOperatorCodeBasedOnShortForm(BRANDS.Short_Form__c);
        Test.stopTest();
        System.assertEquals(BRANDS.Operator_Code__c, operatorCode, 'Operator Code mismatch.');
    }
    
    // Test Aura Enabled method getShortFormBasedOnOperatorCode
    @isTest
    static void testGetShortFormBasedOnOperatorCode() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String shortForm = BrandUtilities.getShortFormBasedOnOperatorCode(BRANDS.Operator_Code__c);
        Test.stopTest();
        System.assertEquals(BRANDS.Short_Form__c, shortForm, 'Short Form mismatch.');
    }
    
    // Test Aura Enabled method getShortFormBasedOnOperatorCode with null input
    @isTest
    static void testGetShortFormBasedOnOperatorCodeNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String shortForm = BrandUtilities.getShortFormBasedOnOperatorCode(null);
        Test.stopTest();
        System.assertEquals(null, shortForm, 'Short Form not null.');
    }
    
    // Test Aura Enabled method getBrandBasedOnOperatorCode
    @isTest
    static void testGetBrandBasedOnOperatorCode() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String brand = BrandUtilities.getBrandBasedOnOperatorCode(BRANDS.Operator_Code__c);
        Test.stopTest();
        System.assertEquals(BRANDS.MasterLabel, brand, 'Brand label mismatch.');
    }
    
    // Test Aura Enabled method getBrandBasedOnOperatorCode with null input
    @isTest
    static void testGetBrandBasedOnOperatorCodeNull() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String brand = BrandUtilities.getBrandBasedOnOperatorCode(null);
        Test.stopTest();
        System.assertEquals(null, brand, 'Brand label mismatch.');
    }
    
    // Test Aura Enabled method getOperatorCodeBasedOnBrand
    @isTest
    static void testGetOperatorCodeBasedOnBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String operatorCode = BrandUtilities.getOperatorCodeBasedOnBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Operator_Code__c, operatorCode, 'Operator Code mismatch.');
    }
    
    // Test Aura Enabled method getVipContractBrandBasedOnBrand
    @isTest
    static void testGetVipContractBrandBasedOnBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String vipContractBrand = BrandUtilities.getVipContractBrandBasedOnBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Vip_Contract_Brand__c, vipContractBrand, 'VIP Bontract Brand mismatch.');
    }
    
    // Test Aura Enabled method getVipContractCompanyBasedOnBrand
    @isTest
    static void testGetVipContractCompanyBasedOnBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String vipContractCompany = BrandUtilities.getVipContractCompanyBasedOnBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Vip_Contract_Company__c, vipContractCompany, 'VIP Contract Company mismatch.');
    }
    
    // Test Aura Enabled method getWebsiteBasedOnBrand
    @isTest
    static void testGetWebsiteBasedOnBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String website = BrandUtilities.getWebsiteBasedOnBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Website__c, website, 'Website mismatch.');
    }
    
    // Test Aura Enabled method getEmailDomainBasedOnBrand
    @isTest
    static void testGetEmailDomainBasedOnBrand() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        String emailDomain = BrandUtilities.getEmailDomainBasedOnBrand(BRANDS.MasterLabel);
        Test.stopTest();
        System.assertEquals(BRANDS.Email_Domain__c, emailDomain, 'Email Domain mismatch.');
    }
    
    // Test Aura Enabled method getBrandAndOperatorCode
    @isTest
    static void testGetBrandAndOperatorCode() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> brandAndOperatorCode = BrandUtilities.getBrandAndOperatorCode();
        Test.stopTest();
        System.assert(brandAndOperatorCode.size() > 0, 'Brand and operator code map size is 0.');
        System.assertEquals(BRANDS.Operator_Code__c, brandAndOperatorCode.get(BRANDS.MasterLabel), 'Operator Code mismatch.');
    }
    
    // Test Aura Enabled method getBrandAndOperatorCodeForServiceView
    @isTest
    static void testGetBrandAndOperatorCodeForServiceView() {
        BrandUtilities.setBrandMock(BRANDS);
        Test.startTest();
        Map<String, String> brandAndOperatorCode = BrandUtilities.getBrandAndOperatorCodeForServiceView();
        Test.stopTest();
        System.assert(brandAndOperatorCode.size() > 0, 'Brand and operator code map size is 0.');
        System.assertEquals(BRANDS.Operator_Code__c, brandAndOperatorCode.get(BRANDS.MasterLabel), 'Operator Code mismatch.');
    }

    @IsTest 
    static void testGetBrandOrSubBrandFileLocation() {
        BrandUtilities.setBrandFileMock(BRANDFILES);
        Test.startTest();
        String loc = BrandUtilities.getBrandOrSubBrandFileLocation(BRANDS.MasterLabel, BRANDFILES.Type__c);
        Test.stopTest();
        System.assertEquals(BRANDFILES.Location__c, loc, 'Location mismatch');
    }

    @IsTest 
    static void testGetBrandOrSubBrandFileName() {
        BrandUtilities.setBrandFileMock(BRANDFILES);
        Test.startTest();
        String filename = BrandUtilities.getBrandOrSubBrandFileName(BRANDS.MasterLabel, BRANDFILES.Type__c);
        Test.stopTest();
        System.assertEquals(BRANDFILES.File_Name__c, filename, 'File Name mismatch');
    }
}