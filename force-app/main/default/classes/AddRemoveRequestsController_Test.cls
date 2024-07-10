/* Date         Owner                   Ref Number            Description
**************************************************************************************************************************
* 15/10/2020   meghana.gupta@ust        SFSE-4767             Safmarine brand deprecated
* 07/06/2022   Ronnie@SF                SPI-100               Removing brand hardcodings

*/

@isTest
public class AddRemoveRequestsController_Test {
    
    @testSetup static void setup() {
        
        if (UserDataGeneratorHelper_Test.SystemAdminUser == null) {
            UserDataGeneratorHelper_Test.initializeSystemAdminUser();
        }
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            RateSheetData_Test.assignGSCPermissionSet(UserDataGeneratorHelper_Test.SystemAdminUser.Id);
            RateSheetData_Test.assignPricingManagerPermissionSet(UserDataGeneratorHelper_Test.SEASystemAdminUser.Id);
        }
        
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country');       
        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );
        List<Pricing_Management__c> lstPricingMgmt = new List<Pricing_Management__c>();
        Account clientAcc = AccountDataHelper_Test.createClientAccount();    
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser) {
            List<Product2> prodList = DataGeneratorHelper1_Test.createProduct2WithEquipsAndCommodities( 1,'B','DE','Ocean');
            lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'FAK', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
            lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Scrap Metal', '20DRY;20REEF;40HREF', '1 Month', '1', true, '20DRY;20REEF;20DRY', '1 Month', '1', true));
            lstPricingMgmt.add(RateSheetData_Test.preparePricingMgmtRec(prodList[0].Id, 'Animal Fodder', '20DRY;20REEF', '1 Month', '1', true, '20DRY;20REEF', '1 Month', '1', true));
        }

        System.runAs(UserDataGeneratorHelper_Test.SEASystemAdminUser){
            insert lstPricingMgmt;
        }
        
        Request__c req1 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.FWD, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;40DRY' );
        //Request__c req4 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.SEALAND, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;' );
        //Request__c req5 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.SEAGO, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[0].Id, lstPricingMgmt[0].Commodity__c, '20DRY;' );
        //Request__c req2 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.FWD, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[1].Id, lstPricingMgmt[1].Commodity__c, '20DRY;40DRY' );
        //Request__c req3 = RateSheetData_Test.createRequest(clientAcc.id, BrandUtilities.MAERSKLINE, 'No', 'Merged LQB & CL', System.Label.BCO, 'No', 'Customised', 'Both', 'New', lstPricingMgmt[2].Id, lstPricingMgmt[2].Commodity__c, '20DRY;40DRY' );
        
        System.runAs(UserDataGeneratorHelper_Test.SystemAdminUser){
            req1.Status__c = 'Active';
            req1.Team__c = 'GSC';
            update req1;
            
      		/*
            req2.Status__c = System.Label.Request_Status_Inactive;
            req2.Team__c = 'GSC';
            update req2;
            
            req3.Status__c = 'Active';
            req3.Team__c = 'GSC';
            update req3;
            
            req4.Status__c = 'Active';
            req4.Team__c = 'GSC';
            update req4;
            
            req5.Status__c = 'Inactive due to Policy Change';
            //req5.Team__c = 'Rate Sheet Governance';
            update req5;*/
        }
        lstPricingMgmt[0].Active_FWD__c = true;
        lstPricingMgmt[0].Active_BCO__c = true;
        lstPricingMgmt[0].Equipment_Types_BCO__c = '20DRY';
        
        lstPricingMgmt[1].Active_FWD__c = true;
        lstPricingMgmt[2].Equipment_Types_BCO__c = '20DRY';
        
        System.runAs(UserDataGeneratorHelper_Test.SEASystemAdminUser) {
            update lstPricingMgmt;
        }
        
    }
    
    @isTest 
    static void TestMethod3() {
        Test.startTest();
        AddRemoveRequestsController  addremoveRequest = new AddRemoveRequestsController();
        AddRemoveRequestsController.ReqConWrapper wrapper = new AddRemoveRequestsController.ReqConWrapper();
        String rateSheetRecTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, OwnerId,Owner.Email,Account__r.SCV_Code__c, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name,Requested_By__c
                              FROM Request__c Where recordTypeId = :rateSheetRecTypeId Limit 1];
        Map<String, ID> ContactRecordTypeMap = ContactDataGeneratorHelper_Test.getContactRecordType ();  
        Contact customerContact = new Contact();
        customerContact.LastName = 'Test Class Contact' + Math.random();
        customerContact.FirstName = BrandUtilities.MAERSKLINE;
        customerContact.Email = 'test@test.com';
        customerContact.Preferred_Language__c = 'English';
        //customerContact.Primary_Contact__c = PrimaryFlag;
        customerContact.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        customerContact.RecordTypeId = ContactRecordTypeMap.get('Customer Contact');
        customerContact.AccountId = request.Account__r.Id;
        Database.Insert(customerContact);
        
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Add');
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'User', 'Add');
        //AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Remove');
        List<Request_Information__c> lstReqInformation = new List<Request_Information__c>();
        lstReqInformation.add(new Request_Information__c(Request__c = request.Id, User__c = request.OwnerId, Contact__c = null));
        
        insert lstReqInformation;
        String userEmail = request.Owner.Email;
        AddRemoveRequestsController.getRequests('123', userEmail, 'User', 'Add');
        String[] lstUniqIdSplit = New String[]{};
        List<String> idString = new List<String>();       
        lstUniqIdSplit.add(request.id);
        lstUniqIdSplit.add(lstReqInformation[0].Id);
        lstUniqIdSplit.add(request.OwnerId);
        lstUniqIdSplit.add('User');
        lstUniqIdSplit.add('Remove');
        idString.add(String.join(lstUniqIdSplit,';'));
        
        AddRemoveRequestsController.getRequests('', userEmail, 'User', 'Remove');
        
        String[] lstUniqIdSplit1 = New String[]{};
        List<String> idString1 = new List<String>();
        lstUniqIdSplit1.add(request.id);
        lstUniqIdSplit1.add('');
        lstUniqIdSplit1.add(customerContact.Id);
        lstUniqIdSplit1.add('Contact');
        lstUniqIdSplit1.add('Add');
        idString1.add(String.join(lstUniqIdSplit1,';'));
        system.debug('@@@@' +idString1);
        AddRemoveRequestsController.addReqInfo(idString1); 
        test.stopTest();
        
    }
    @isTest 
    static void TestMethod4() {
        test.startTest();
        AddRemoveRequestsController  addremoveRequest = new AddRemoveRequestsController();
        AddRemoveRequestsController.ReqConWrapper wrapper = new AddRemoveRequestsController.ReqConWrapper();
        String rateSheetRecTypeId =  Schema.SObjectType.Request__c.getRecordTypeInfosByName().get( Label.RateSheetRequestRecordType).getRecordTypeId();        
        Request__c request = [SELECT Id, Status__c,OwnerId,Account__r.SCV_Code__c, Pricing_Management__c, Pricing_Management__r.Commodity__c, Pricing_Management__r.Product__r.Name,Requested_By__c
                              FROM Request__c Where recordTypeId = :rateSheetRecTypeId Limit 1];
        
        Map<String, ID> ContactRecordTypeMap = ContactDataGeneratorHelper_Test.getContactRecordType ();
        List<Contact> lstTobeinsertedContacts = new List<Contact>();
        Contact customerContact = new Contact();
        customerContact.LastName = 'Test Class Contact' + Math.random();
        customerContact.FirstName = BrandUtilities.MAERSKLINE;
        customerContact.Email = 'test@test.com';
        customerContact.Preferred_Language__c = 'English';
        customerContact.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        customerContact.RecordTypeId = ContactRecordTypeMap.get('Customer Contact');
        customerContact.AccountId = request.Account__r.Id;
        lstTobeinsertedContacts.add(customerContact);    
        Database.Insert(lstTobeinsertedContacts);
        
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Add');
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'User', 'Add');
        List<Request_Information__c> lstReqInformation = new List<Request_Information__c>();
        lstReqInformation.add(new Request_Information__c(Request__c = request.Id, User__c = null, Contact__c = customerContact.Id, Change_Status__c = 'Remove'));
        insert lstReqInformation;
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Add');
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Remove');
        AddRemoveRequestsController.getRequests('123', 'test@test.com', 'Contact', 'Add');
        
        String[] lstUniqIdSplit1 = New String[]{};
        List<String> idString1 = new List<String>();
        lstUniqIdSplit1.add(request.id);
        lstUniqIdSplit1.add(lstReqInformation[0].Id);
        lstUniqIdSplit1.add(customerContact.Id);
        lstUniqIdSplit1.add('Contact');
        lstUniqIdSplit1.add('Add');
        idString1.add(String.join(lstUniqIdSplit1,';'));
        system.debug('@@@@' +idString1);
        test.stopTest();
    }   
}