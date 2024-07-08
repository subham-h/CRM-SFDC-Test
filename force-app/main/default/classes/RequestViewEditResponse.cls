public class RequestViewEditResponse extends AuraResponse {
    
    @AuraEnabled public Request__c request { get; set; }
    @AuraEnabled public Boolean blnIsSuccess { get; set; }
    @AuraEnabled public String strMessage { get; set;}   
    @AuraEnabled public List<String> listCommodity{ get; set; }
    @AuraEnabled public List<String> listEquipmentTypes{ get; set; }
    @AuraEnabled public String strPricingName { get; set; }
    @AuraEnabled public Pricing_Management__c pricingMgmt { get; set; }  
    @AuraEnabled public String strRouteDirId{ get; set; }
    @AuraEnabled public Map<String, String> requestfieldMap { get; set; }
    @AuraEnabled public Map<String, boolean> fieldEditAccessMap { get; set; }
    @AuraEnabled public Map<String, boolean> mapFieldViewAccess { get; set; }
    @AuraEnabled public String strLoggedInUserName { get; set;}
    @AuraEnabled public Id idRequestInfoContactRecordType { get; set;}
    @AuraEnabled public String strRateSheetType { get; set; }
    @AuraEnabled public Map<String, String> mapHelpText { get; set; }
    @AuraEnabled public List<String> lstChangeType{ get; set; }
    @AuraEnabled public List<String> lstRateSheetAddition{ get; set; }
    @AuraEnabled public List<String> lstOutput{ get; set; }
    @AuraEnabled public List<String> lstStatus { get; set; }
    
    public RequestViewEditResponse(){
        
		mapHelpText = new Map<String, String>();
        requestfieldMap = new Map<String, String>(); 
        fieldEditAccessMap = new  Map<String, boolean>();
        mapFieldViewAccess = new  Map<String, boolean>();
        blnIsSuccess = true;
        strPricingName = null;
        strRateSheetType = null;
        strLoggedInUserName= null;
        strRouteDirId=null;
        strMessage = '';
        listCommodity = new List<String>();
        listEquipmentTypes = new List<String>();
        lstChangeType = new List<String>();
        lstRateSheetAddition = new List<String>();
        lstOutput = new List<String>();
        lstStatus = new List<String>();
        
        String recTypeId = Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get( Label.RequestDetail_ContactRecordType).getRecordTypeId();
        idRequestInfoContactRecordType = (ID) recTypeId;
    }
    
}