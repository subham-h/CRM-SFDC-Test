public inherited sharing class TargetSettingConstants {
    public static final String QUARTER_ONE = 'Q1';
    public static final String QUARTER_TWO = 'Q2';
    public static final String QUARTER_THREE = 'Q3';
    public static final String QUARTER_FOUR = 'Q4';
    
    public static final String BUDGET = 'Budget';
    public static final String TARGET = 'Target';
    public static final String PIPELINE = 'Pipeline';
    public static final String CY_ACTUALS = 'Actuals';
    public static final String PY_ACTUALS = 'Previous Year Actuals';
    public static final String ROLLING_FORECAST = 'Rolling Forecast';
    
    public static final String QUERY_ID_ROFO = 'ROFO';
    public static final String QUERY_ID_BUDGET = 'BUDGET';
    public static final String QUERY_ID_CYACTUALS = 'CY_ACTUALS';
    public static final String QUERY_ID_PYACTUALS = 'PY_ACTUALS';

    public static final String STAGING_STATUS_FAILED = 'Failed';
    public static final String STAGING_STATUS_EXCLUDED = 'Excluded';
    public static final String STAGING_STATUS_PROCESSED = 'Processed';
    
    public static final String STAGING_GROWTH_PERCENT = 'Growth Percent';
    
    public static final String TARGET_STATUS_CLOSED = 'Closed';
    public static final String TARGET_STATUS_CANCELLED = 'Cancelled';
    
    public static final String PARTY_PO = 'Price Owner';
    public static final String PARTY_SHIPPER = 'Shipper';
    public static final String PARTY_CONSIGNEE = 'Consignee';
    
    public static final String PARTY_PO_FIELD = 'Price_Owner';
    public static final String PARTY_SHIPPER_FIELD = 'Shipper';
    public static final String PARTY_CONSIGNEE_FIELD = 'Consignee';

    public static final String ACCOUNT_STATUS_ACTIVE = 'Active';
    
    //STATUS
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_ACTIVE = 'Active';
    
    //STAGE
    public static final String STAGE_INIT = 'New';
    public static final String STAGE_EXCLUSIONS = 'Setup Product Exclusions';
    public static final String STAGE_BUDGET = 'Load Budget';
    public static final String STAGE_PRE_CALCULATE_SALES = 'Pre-calculate Sales Target';
    public static final String STAGE_PIPELINE = 'Load Pipeline';
    public static final String STAGE_SETUP_CREATOR_AND_APPROVER = 'Setup Creator/Approver';
    public static final String STAGE_COMPLETED = 'Release for Target Planning';
    
    //STAGE STATUS
    public static final String STAGE_STATUS_NEW = 'New';
    public static final String STAGE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String STAGE_STATUS_FAILED = 'Failed';
    public static final String STAGE_STATUS_COMPLETED = 'Completed';
    
    //DATA LOAD
    public static final STRING DATA_LOAD_STATUS_COMPLETED = 'Completed';
    public static final STRING DATA_LOAD_TYPE_BUDGET = 'Budget';
    public static final STRING DATA_LOAD_LAST_YEAR_ACTUALS = 'Previous Year Actuals';
    public static final STRING DATA_LOAD_ROLLING_FORECAST = 'Rolling Forecast';
    
    //measure type
    public static final STRING GROSS_PROFIT = 'Gross Profit';
    public static final STRING VOLUME = 'Volume';
    public static final STRING GROSS_PROFIT_GROWTH_PERCENT = 'Gross Profit Growth Percent';
    public static final STRING REVENUE_GROWTH_PERCENT = 'Revenue Growth Percent';
    public static final STRING VOLUME_GROWTH_PERCENT = 'Volume Growth Percent';
    
    //Credit Eligibility
    public static final STRING NormalClientAcc = 'Normal_Client_Account_of_Concern_and_PO';
    public static final STRING GLAO = 'Global Lead Account Owner';
    public static final STRING SalesOwner = 'Sales Owner';
    
    //APPROVAL STAGES
    public static final STRING APPROVAL_STAGE_1 = 'Level 1 creator - Area Commercial FBP';
    public static final STRING APPROVAL_STAGE_2 = 'Level 2 creator - Global Account Owner';
    public static final STRING APPROVAL_STAGE_3 = 'Level 1 approver - Area Head of Sales Channel Verticalized';
    public static final STRING APPROVAL_STAGE_4 = 'Level 2 approver - Area Head of Sales Channel';
    public static final STRING APPROVAL_STAGE_5 = 'Level 3 approver - Area Sales Head';
    public static final STRING APPROVAL_STAGE_6 = 'Level 4 approver - Regional Sales Excellence';
    public static final STRING APPROVAL_STAGE_7 = 'Level 5 approver - Central Sales Channel Head';
    public static final STRING APPROVAL_STAGE_8 = 'Level 6 approver - Chief Commercial Officer';
    
    //Record Type
    public static STRING CONCERN_ACCOUNT_RECORD_TYPE = 'Concern_Account';
	public static STRING TARGET_EXCLUSION_RECORD_TYPE = 'Target_Exclusion';
    public static STRING SIP_EXCLUSION_RECORD_TYPE = 'SIP_Exclusion';
    
    //Permission Set
    public static STRING LEVEL1_APPROVER_PERMISSION_SET = 'Sales_Target_Setting_Level_1_Approval_Admin';
    
    public static STRING PURGE_STR = 'Purge_Actuals';
    
}