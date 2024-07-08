/**
* Helper class for generating Request and RateSheet Request 
 *
 * Date         Owner                                     Ref Number    Description
**************************************************************************************************************************************
 * 27/11/2017   John.christopher@ust-global.com           #RQ-007311    Rate Sheet2.
 * 20/02/2018   meghana.gupta@ust-global.com              #RQ-007794    added new methods to create OD Pairs, requests
 * 10/03/2018   Nitin More                                #RQ-008055    added preparePricingMgmtRec and amended createPricingMgmtRec method to call preparePricingMgmtRec method
 * 04/04/2018   Nitin More                                #RQ-008277    Changed Min Threshold field from Integer to String 
 * 12/02/2019   Junaid Khader                             #RQ-010053    Removed Request_Route__c(deprecated) related code
 * 01/08/2019   Meghana Gupta                             #RQ-011094    Added methods to create request record of type "VIP Deal" and method to create Request Detail records
 * 08/06/2022   Ronnie@SF                                 SPI-100       Removed brand hardcoding
*/
       
public class RateSheetData_Test {
    
    /*** Constructor  **/    
    public RateSheetData_Test () { 
        
    }
    
     //Call method to create Test Users 
    static {
         // create method if users are created already by anyother test data generator class
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null){
            UserDataGeneratorHelper_Test.initializeSystemAdminUser(); 
        }   
    }
    
    public static void createRequestData() {
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser){
            RateSheetData_Test.assignGSCPermissionSet(UserDataGeneratorHelper_Test.SystemAdminUser.Id);
            RateSheetData_Test.assignPricingManagerPermissionSet(UserDataGeneratorHelper_Test.SCLSystemAdminUser.Id);
        }
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country');       
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );   
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();    
        List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1,'B','DE','Ocean');
        
        List<Pricing_Management__c> pmList = createPricingMgmtRec( prodList[0].Id, UserDataGeneratorHelper_Test.SCLSystemAdminUser );
        //List<Pricing_Management_Information__c> pricingInfoList = createPricingMgmtDetail(pmList, geoList);
        
        //Request__c req1 = createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Compressed Bas', 'BCO', 'No', 'Standard', 'sales', 'New', pmList[0].Id, 'Scrap Metal');
        Request__c req2 = createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', 'FWD', 'No', 'Customised', 'Both', 'New', pmList[1].Id, 'FAK', '40DRY');
       // createRequestInformation(req2.id, pricingInfoList[2].Id);
        createRequestContact(req2.id);
    }
    
    public static void createRequestContact( Id requestId){
        
        Request_Information__c reqInfoRec = new Request_Information__c();
        String contactRecTypeId = Schema.SObjectType.Request_Information__c.getRecordTypeInfosByName().get(Label.RequestDetail_ContactRecordType).getRecordTypeId();
     
        reqInfoRec.recordTypeId = contactRecTypeId;
        reqInfoRec.User__c = UserDataGeneratorHelper_Test.SystemAdminUser.id;
        reqInfoRec.Request__c = requestId;
        insert reqInfoRec;
    }
     
    public static List<Pricing_Management__c> createPricingMgmtRec(Id prodId, User runAsUser){
       
        List<Pricing_Management__c> insertList = new List<Pricing_Management__c>();
        system.runAs(runAsUser){
            
            insertList.add(preparePricingMgmtRec(prodId, 'FAK', '20DRY;20REEF', '1 Month','1', true, '20DRY;20REEF', '1 Month', '1',true));
            insertList.add(preparePricingMgmtRec(prodId, 'Scrap Metal', '20DRY;20REEF;40HREF', '1 Month','1', true, '20DRY;20REEF;', '1 Month','1',true));
            insert insertList;
        }
        return insertList;
    }
     
     public static Request__c createRequest( ID AccountId, String lbrand, String specialDeals,String output,String BcoFwd,
                                                String shipperAssociationContract,String ODpairs,String mailSendTo,
                                               String status, Id pmRecId, String commodity, String equipment ){
                                                   
              Request__c request = new Request__c();  
              request.Account__c = AccountId;
              request.Liner_Brand__c = lbrand;
              request.Special_Deals__c = specialDeals;
              request.Output__c = output;
              request.BCO_FWD__c = BcoFwd;
              request.Shipper_Owner_Container__c = shipperAssociationContract;
              request.OD_Pairs__c = ODpairs;
              request.Mail_Send_To__c = mailSendTo;
              request.Status__c = status;
              request.Requested_By__c = UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id;
              System.debug('$$$$$$$$$$$$$$$$$$$$$$$UserId: '+ request.Requested_By__c);                                   
              String rateSheetRecTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();
       
              request.RecordTypeId = rateSheetRecTypeId;
              request.Additional_Group_Internal_Email__c='Testing@testing.com';
              request.Pricing_Management__c = pmRecId;
                                                   
              //Route And Commodity Details 
              request.Commodity_Rate_Sheet__c = commodity;
              request.Equipment_Types__c = equipment;
              request.Existing_Contract_ID__c='123';
              request.Status__c = 'New';
              System.runAs( UserDataGeneratorHelper_Test.MSLSystemAdminUser ){
                  insert request; 
              }
              return request;
         }   
    
    public static Request__c createRequestContractOuptput(Id oppId){
        
        String recTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RequestContractRecordType).getRecordTypeId();
       
        Request__c req = new Request__c();
        req.RecordTypeId = recTypeId;
        req.Status__c = 'New';
        req.Opportunity__c = oppId;
        req.Comments__c = 'test record';
        
        insert req;
        return req;
    }
    
    // Used in BatchSyncRequestRouteStatusByPolicy_Test -- to be deprecated
    public static Request__c createRequest( ID AccountId, String lbrand, String specialDeals,String output,String BcoFwd,String shipperAssociationContract,String ODpairs,String mailSendTo, String status ){
        Request__c request=new Request__c();  
        request.Account__c=AccountId;
        request.Liner_Brand__c=lbrand;
        request.Special_Deals__c=specialDeals;
        request.Output__c=output;
        request.BCO_FWD__c=BcoFwd;
        request.Shipper_Owner_Container__c=shipperAssociationContract;
        request.OD_Pairs__c=ODpairs;
        request.Mail_Send_To__c=mailSendTo;
        request.Status__c=status;
        request.RecordTypeId=System.label.RateSheetRequestRecordTypeId;
        request.Additional_Group_Internal_Email__c='Testing@testing.com';
        System.runAs( UserDataGeneratorHelper_Test.MSLSystemAdminUser ){
            insert request; 
        }
        return request;
    }
    
    public static void assignGSCPermissionSet (Id idUser){
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Request_GSC'];
        insert new PermissionSetAssignment(AssigneeId = idUser, PermissionSetId = ps.Id );
    }
    
    public static void assignPricingManagerPermissionSet (Id idUser){
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Request_Pricing_Manager'];
        insert new PermissionSetAssignment(AssigneeId = idUser, PermissionSetId = ps.Id );
    }
    
    public static Pricing_Management__c preparePricingMgmtRec(Id prodId, String pCommodity, String pEquipBCO, String pValidityBCO, String pthresholdBCO, Boolean pActiveBCO, String pEquipFWD, String pValidityFWD,String pThresholdFWD, Boolean pActiveFWD){
        
        String recTypeId =  Schema.SObjectType.Pricing_Management__c.getRecordTypeInfosByName().get( Label.PricingMgmtCommodityRecordType).getRecordTypeId();
        Pricing_Management__c recPricingMgmt = new Pricing_Management__c();
        recPricingMgmt.Product__c = prodId;
        recPricingMgmt.RecordTypeId = recTypeId;
        recPricingMgmt.Commodity__c = pCommodity;
        recPricingMgmt.Equipment_Types_BCO__c = pEquipBCO;
        recPricingMgmt.Validity_BCO__c = pValidityBCO;
        recPricingMgmt.Active_BCO__c = pActiveBCO;
        recPricingMgmt.Equipment_Types_FWD__c = pEquipFWD;
        recPricingMgmt.Validity_FWD__c = pValidityFWD;
        recPricingMgmt.Active_FWD__c = pActiveFWD;
        recPricingMgmt.Min_Threshold_FFE_per_week_BCO__c = pthresholdBCO;
        recPricingMgmt.Min_Threshold_FFE_per_week_FWD__c= pThresholdFWD;
        return recPricingMgmt;
    }
    
    //#RQ-011094 - Method to create Request records of record type VIP Deals
      public static Request__c createVIPDeal (ID AccountId, String strLBrand, String vipDealType, Id countrySalesOffice,string status) {
        
        Id vipDealRecTypeId =  (ID) Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get( Label.VIPDealRequestRecordType).getRecordTypeId(); 
          Request__c rec = new Request__c(); 
          rec.RecordTypeId = vipDealRecTypeId;
          rec.Account__c = AccountId;
          rec.Liner_Brand__c = strLBrand;
          rec.VIP_Deal_Type__c = vipDealType;
          rec.Country_Sales_Office__c = countrySalesOffice;
          rec.Status__c = status;
          rec.Payout_Type__c = 'Fixed Amount Progressive Tier';
          return rec;
    }

    //#RQ-011094 - Method to create Request Detail records 
    public static Request_Detail__c createRequestDetail (ID requestId, Id prodId, String strOrigin, String strDestination,string status) {
        
        Request_Detail__c reqd = new Request_Detail__c();
        reqd.VIP_Deal__c = requestId;
        reqd.Status__c = status;
        reqd.Route__c = prodId;
        reqd.Origin__c = strOrigin;
        reqd.Destination__c = strDestination;
        return reqd;
    }    
}