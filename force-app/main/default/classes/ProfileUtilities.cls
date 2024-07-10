/**
* Author    : Shashi@Maersk
* Purpose   : Profile utility class utilising Profile__mdt custom metadata.
* NOTE      : 
*        
* Version  Ref Number     Date             Dev                 Description
* -------- ----------  -----------   -----------------       ----------------
* 1.0      SFSE-11992   29-Jul-23     Shashi@Maersk            
* 
*/
public class ProfileUtilities {
    
    //Map of all profile metadata records.
    public static final Map<String, Profile__mdt> AllProfileMetadataMap;
    
    //Map of only active marked profile metadata records.
    public static final Map<String, Profile__mdt> ActiveProfileMetadataMap;
     
    //static profile specific variables used where profile specific logic has to be used.
    public static final String X101_CustomerServiceSalesPilot;
    public static final String X102_CustomerService;
    public static final String X501_CustomerCommunityLoginUser;
    public static final String X501_CustomerCommunityUser;
    public static final String X601_EinsteinBot;
    public static final String X701_CustomerCommunity;
    public static final String X801_ReadOnly;
    public static final String X901_CRMTeam;
    public static final String X911_InterfaceBusinessIntelligence;
    public static final String X912_InterfaceETL;
    public static final String X913_InterfaceQuoting;
    public static final String AnalyticsCloudIntegrationUser;
    public static final String AnalyticsCloudSecurityUser;
    public static final String B2BMAIntegrationUser;
    public static final String CentreTNM;
    public static final String CentreUser;
    public static final String ChatterExternalUser;
    public static final String ChatterFreeUser;
    //public static final String ChatterModeratorUser;
    //public static final String ContractManager;
    public static final String Customer_Community_Login_User;
    public static final String CustomerCommunityPlusLoginUser;
    //public static final String CustomerCommunityPlusUser;
    //public static final String Customer_Community_User;
    public static final String GSC;
    public static final String IdentityUser;
    public static final String IntegrationUser;
    public static final String LiveHelp;
    //public static final String MarketingUser;
    //public static final String MinimumAccessSalesforce;
    public static final String MinimumAccessSalesforceCustom;
    //public static final String PartnerCommunityUser;
    public static final String PremierSupportUser;
    public static final String Sales;
    public static final String SalesandMarketing;
    public static final String SalesExclusiveTPA;
    public static final String SalesInsightsIntegrationUser;
    //public static final String SalesforceAPIOnlySystemIntegrations;
    public static final String SalesforceIQIntegrationUser;
    //public static final String SolutionManager;
    //public static final String StandardPlatformUser;
    //public static final String StandardUser;
    public static final String SuperUser;
    //public static final String SystemAdministrator;
   
    static{
        
        //maps
        /**AllProfileMetadataMap = new Map<String, Profile__mdt>();
        ActiveProfileMetadataMap = new Map<String, Profile__mdt>();
        
        Map<String, Profile__mdt> tempMap = Profile__mdt.getAll();
        
        for (String key : tempMap.keySet()) {
            AllProfileMetadataMap.put(tempMap.get(key).MasterLabel, tempMap.get(key));
        }
        
        for (String key : AllProfileMetadataMap.keySet()) {
            if (AllProfileMetadataMap.get(key).Is_Active__c) {
                ActiveProfileMetadataMap.put(AllProfileMetadataMap.get(key).MasterLabel, AllProfileMetadataMap.get(key));
            }
        }*/
            
        //populating the static variables with their labels from their respective custom metadata records
        /**X101_CustomerServiceSalesPilot = Profile__mdt.getInstance('X101_CustomerServiceSalesPilot') != null ? Profile__mdt.getInstance('X101_CustomerServiceSalesPilot').MasterLabel : '';
        X102_CustomerService = Profile__mdt.getInstance('X102_CustomerService') != null ? Profile__mdt.getInstance('X102_CustomerService').MasterLabel : '';
        X501_CustomerCommunityLoginUser = Profile__mdt.getInstance('X501_CustomerCommunityLoginUser') != null ? Profile__mdt.getInstance('X501_CustomerCommunityLoginUser').MasterLabel : '';
        X501_CustomerCommunityUser = Profile__mdt.getInstance('X501_CustomerCommunityUser') != null ? Profile__mdt.getInstance('X501_CustomerCommunityUser').MasterLabel : '';
        X601_EinsteinBot = Profile__mdt.getInstance('X601_EinsteinBot') != null ? Profile__mdt.getInstance('X601_EinsteinBot').MasterLabel : '';
        X701_CustomerCommunity = Profile__mdt.getInstance('X701_CustomerCommunity') != null ? Profile__mdt.getInstance('X701_CustomerCommunity').MasterLabel : '';
        X801_ReadOnly = Profile__mdt.getInstance('X801_ReadOnly') != null ? Profile__mdt.getInstance('X801_ReadOnly').MasterLabel : '';
        X901_CRMTeam = Profile__mdt.getInstance('X901_CRMTeam') != null ? Profile__mdt.getInstance('X901_CRMTeam').MasterLabel : '';
        X911_InterfaceBusinessIntelligence = Profile__mdt.getInstance('X911_InterfaceBusinessIntelligence') != null ? Profile__mdt.getInstance('X911_InterfaceBusinessIntelligence').MasterLabel : '';
        X912_InterfaceETL = Profile__mdt.getInstance('X912_InterfaceETL') != null ? Profile__mdt.getInstance('X912_InterfaceETL').MasterLabel : '';
        X913_InterfaceQuoting = Profile__mdt.getInstance('X913_InterfaceQuoting') != null ? Profile__mdt.getInstance('X913_InterfaceQuoting').MasterLabel : '';
        AnalyticsCloudIntegrationUser = Profile__mdt.getInstance('AnalyticsCloudIntegrationUser') != null ? Profile__mdt.getInstance('AnalyticsCloudIntegrationUser').MasterLabel : '';
        AnalyticsCloudSecurityUser = Profile__mdt.getInstance('AnalyticsCloudSecurityUser') != null ? Profile__mdt.getInstance('AnalyticsCloudSecurityUser').MasterLabel : '';
        B2BMAIntegrationUser = Profile__mdt.getInstance('B2BMAIntegrationUser') != null ? Profile__mdt.getInstance('B2BMAIntegrationUser').MasterLabel : '';
        CentreTNM = Profile__mdt.getInstance('Centre_TNM') != null ? Profile__mdt.getInstance('Centre_TNM').MasterLabel : '';
        CentreUser = Profile__mdt.getInstance('Centre_User') != null ? Profile__mdt.getInstance('Centre_User').MasterLabel : '';
        ChatterExternalUser = Profile__mdt.getInstance('ChatterExternalUser') != null ? Profile__mdt.getInstance('ChatterExternalUser').MasterLabel : '';
        ChatterFreeUser = Profile__mdt.getInstance('ChatterFreeUser') != null ? Profile__mdt.getInstance('ChatterFreeUser').MasterLabel : '';
        //ChatterModeratorUser = Profile__mdt.getInstance('ChatterModeratorUser') != null ? Profile__mdt.getInstance('ChatterModeratorUser').MasterLabel : '';
        //ContractManager = Profile__mdt.getInstance('ContractManager') != null ? Profile__mdt.getInstance('ContractManager').MasterLabel : '';
        Customer_Community_Login_User = Profile__mdt.getInstance('CustomerCommunityLoginUser') != null ? Profile__mdt.getInstance('CustomerCommunityLoginUser').MasterLabel : '';
        CustomerCommunityPlusLoginUser = Profile__mdt.getInstance('CustomerCommunityPlusLoginUser') != null ? Profile__mdt.getInstance('CustomerCommunityPlusLoginUser').MasterLabel : '';
        //CustomerCommunityPlusUser = Profile__mdt.getInstance('CustomerCommunityPlusUser') != null ? Profile__mdt.getInstance('CustomerCommunityPlusUser').MasterLabel : '';
        //Customer_Community_User = Profile__mdt.getInstance('CustomerCommunityUser') != null ? Profile__mdt.getInstance('CustomerCommunityUser').MasterLabel : '';
        GSC = Profile__mdt.getInstance('GSC') != null ? Profile__mdt.getInstance('GSC').MasterLabel : '';
        IdentityUser = Profile__mdt.getInstance('IdentityUser') != null ? Profile__mdt.getInstance('IdentityUser').MasterLabel : '';
        IntegrationUser = Profile__mdt.getInstance('IntegrationUser') != null ? Profile__mdt.getInstance('IntegrationUser').MasterLabel : '';
        LiveHelp = Profile__mdt.getInstance('LiveHelp') != null ? Profile__mdt.getInstance('LiveHelp').MasterLabel : '';
        //MarketingUser = Profile__mdt.getInstance('MarketingUser') != null ? Profile__mdt.getInstance('MarketingUser').MasterLabel : '';
        //MinimumAccessSalesforce = Profile__mdt.getInstance('MinimumAccessSalesforce') != null ? Profile__mdt.getInstance('MinimumAccessSalesforce').MasterLabel : '';
        MinimumAccessSalesforceCustom = Profile__mdt.getInstance('MinimumAccessSalesforceCustom') != null ? Profile__mdt.getInstance('MinimumAccessSalesforceCustom').MasterLabel : '';
        //PartnerCommunityUser = Profile__mdt.getInstance('PartnerCommunityUser') != null ? Profile__mdt.getInstance('PartnerCommunityUser').MasterLabel : '';
        PremierSupportUser = Profile__mdt.getInstance('PremierSupportUser') != null ? Profile__mdt.getInstance('PremierSupportUser').MasterLabel : '';
        Sales = Profile__mdt.getInstance('Sales') != null ? Profile__mdt.getInstance('Sales').MasterLabel : '';
        SalesandMarketing = Profile__mdt.getInstance('SalesandMarketing') != null ? Profile__mdt.getInstance('SalesandMarketing').MasterLabel : '';
        SalesExclusiveTPA = Profile__mdt.getInstance('SalesExclusiveTPA') != null ? Profile__mdt.getInstance('SalesExclusiveTPA').MasterLabel : '';
        SalesInsightsIntegrationUser = Profile__mdt.getInstance('SalesInsightsIntegrationUser') != null ? Profile__mdt.getInstance('SalesInsightsIntegrationUser').MasterLabel : '';
        //SalesforceAPIOnlySystemIntegrations = Profile__mdt.getInstance('SalesforceAPIOnlySystemIntegrations') != null ? Profile__mdt.getInstance('SalesforceAPIOnlySystemIntegrations').MasterLabel : '';
        SalesforceIQIntegrationUser = Profile__mdt.getInstance('SalesforceIQIntegrationUser') != null ? Profile__mdt.getInstance('SalesforceIQIntegrationUser').MasterLabel : '';
        //SolutionManager = Profile__mdt.getInstance('SolutionManager') != null ? Profile__mdt.getInstance('SolutionManager').MasterLabel : '';
        //StandardPlatformUser = Profile__mdt.getInstance('StandardPlatformUser') != null ? Profile__mdt.getInstance('StandardPlatformUser').MasterLabel : '';
        //StandardUser = Profile__mdt.getInstance('StandardUser') != null ? Profile__mdt.getInstance('StandardUser').MasterLabel : '';
        SuperUser = Profile__mdt.getInstance('SuperUser') != null ? Profile__mdt.getInstance('SuperUser').MasterLabel : '';
        //SystemAdministrator = Profile__mdt.getInstance('SystemAdministrator') != null ? Profile__mdt.getInstance('SystemAdministrator').MasterLabel : '';*/
        
        X101_CustomerServiceSalesPilot = '101 - Customer Service & Sales (Pilot)';
        X102_CustomerService = '102 - Customer Service';
        X501_CustomerCommunityLoginUser = '501 - Customer Community Login User';
        X501_CustomerCommunityUser = '501 - Customer Community User';
        X601_EinsteinBot = '601 - Einstein Bot';
        X701_CustomerCommunity = '701 - Customer Community';
        X801_ReadOnly = '801 - Read Only';
        X901_CRMTeam = '901 - CRM Team';
        X911_InterfaceBusinessIntelligence = '911 - Interface (Business Intelligence)';
        X912_InterfaceETL = '912 - Interface (ETL)';
        X913_InterfaceQuoting = '913 - Interface (Quoting)';
        AnalyticsCloudIntegrationUser = 'Analytics Cloud Integration User';
        AnalyticsCloudSecurityUser = 'Analytics Cloud Security User';
        B2BMAIntegrationUser = 'B2BMA Integration User';
        CentreTNM = 'Centre TNM';
        CentreUser = 'Centre User';
        ChatterExternalUser = 'Chatter External User';
        ChatterFreeUser = 'Chatter Free User';
        //ChatterModeratorUser = 'Chatter Moderator User';
        //ContractManager = 'Contract Manager';
        Customer_Community_Login_User = 'Customer Community Login User';
        CustomerCommunityPlusLoginUser = 'Customer Community Plus Login User';
        //CustomerCommunityPlusUser = 'Customer Community Plus User';
        //Customer_Community_User = 'Customer Community User';
        GSC = 'GSC';
        IdentityUser = 'Identity User';
        IntegrationUser = 'Integration User';
        LiveHelp = 'LiveHelp';
        //MarketingUser = 'Marketing User';
        //MinimumAccessSalesforce = 'Minimum Access - Salesforce';
        MinimumAccessSalesforceCustom = 'Minimum Access - Salesforce Custom';
        //PartnerCommunityUser = 'Partner Community User';
        PremierSupportUser = 'Premier Support User';
        Sales = 'Sales';
        SalesandMarketing = 'Sales and Marketing';
        SalesExclusiveTPA = 'Sales Exclusive TPA';
        SalesInsightsIntegrationUser = 'Sales Insights Integration User';
        //SalesforceAPIOnlySystemIntegrations = 'Salesforce API Only System Integrations';
        SalesforceIQIntegrationUser = 'SalesforceIQ Integration User';
        //SolutionManager = 'Solution Manager';
        //StandardPlatformUser = 'Standard Platform User';
        //StandardUser = 'Standard User';
        SuperUser = 'Super User';
        //SystemAdministrator = 'System Administrator';
        
        
    }
     

}