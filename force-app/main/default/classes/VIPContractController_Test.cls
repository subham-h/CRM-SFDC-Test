/**
* Version  Date           Owner                    RQ#           Description
****************************************************************************************************************************************
* 1.0      14-Jun-2019    sidhartha mohapatra      #RQ-010321     Test Class for VIPContractController.cls
* 1.1      29-Jul-2019    Meghana Gupta            #RQ-011094     Test class modifed as per chanegs done in controller class.
* 1.2      05-Aug-2019    Meghana Gupta			   #RQ-011279  	  Add code to test updateVIPRequest method
* 1.3      19-Nov-2019    Meghana Gupta			   #RQ-012416  	  Request detail creation modified to avoid duplicates
 * 1.4      27-Jun-2022    Ronnie@SF                #SPI-100       Removed brand hardcoding
*/

@isTest
public class VIPContractController_Test {
    
    @testSetup static void setup() {
        List<Trade_Route__c> tdrlst = new List<Trade_Route__c>();
        Map<String, String> GeoCountryList = new Map<String, String> ();
        GeoCountryList.put('Denmark', 'Country');
        GeoCountryList.put('China', 'Country'); 
        List<Trade_Route__c> lstTDR =  DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MSL');
        insert lstTDR;
        List<Trade_Route__c> lstTDR1 =  DataGeneratorHelper_OIPC.createTradeRoutes(1, 'MCC');
        insert lstTDR1;

        List<Geography__c> geoList = DataGeneratorHelper1_Test.createGeography ( GeoCountryList );   
       // List<Product2> listOceanProducts = DataGeneratorHelper1_Test.createProduct2( 2,'A','DE','Ocean');
        Account clientAcc = AccountDataHelper_Test.createClientAccount(null, 'Active','testAcc123');    
        
        System.debug('address '+ clientAcc.BillingAddress);
        Request__c rec = RateSheetData_Test.createVIPDeal(clientAcc.Id, BrandUtilities.MAERSKLINE, 'Standard VIP Deal', geoList[0].id, 'New');          
        insert rec;
        
        system.debug(rec);
        
        PermissionSet permissionst = [SELECT Id From PermissionSet WHERE Name = 'VIP_Deal_Approval'];
        system.runas( UserDataGeneratorHelper_Test.MSLSystemAdminUser ){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserDataGeneratorHelper_Test.MSLSystemAdminUser.Id;
            psa.PermissionSetId = permissionst.Id;       
            insert psa;  
            system.debug(psa);
        }
        
        Request_Detail__c reqd = RateSheetData_Test.createRequestDetail(rec.Id, lstTDR[0].Id, 'Port1; Port2; Port3 XYZ', 'Port4; Port5; Port6 ABC', 'New');
        insert reqd;
        
        Request_Detail__c reqdWithoutOriginDestination = RateSheetData_Test.createRequestDetail(rec.Id, lstTDR1[0].Id,'' ,'' , 'New');
        insert reqdWithoutOriginDestination;
        
        system.runas( UserDataGeneratorHelper_Test.MSLSystemAdminUser ){
            reqd.Status__c = 'Approved';
            update reqd;
            system.debug(reqd);
            
            // in case of CENVIP approval, request should be approved as well
            rec.Status__c = 'Approved';
            update rec;
            system.debug(rec);
        }        
        
        System.debug('Request Status: ' + rec.Status__c);
    }
    
    @isTest static void getRequest() {  
        
        List<Request__c> req = [Select Id, Status__c, CENVIP_Approval_required__c from Request__c LIMIT 1]; 
        System.debug(req);
        
        Test.startTest();
        VIPContractController.getVIPRequest(req[0].Id);
        VIPContractController.updateVIPRequest(req[0].Id, 'Bank Name', 'Bank Address test ', 'India', '1234567890', '1234','321', '333',  'test@test.com');
        Test.stopTest();
        system.assertEquals(req.size(), 1);
    }
    
    @isTest static void getRequestDetails() {
        
        List<Request__c> req = [Select Id,Status__c from Request__c LIMIT 1]; 
        List<Request_Detail__c> reqd = [Select Id,Origin__c,Destination__c from Request_Detail__c LIMIT 1]; 
        Test.startTest();
        VIPContractController.editOriginDestination(reqd[0].Id);
        Test.stopTest();
        system.assertEquals(req.size(), 1);
    }
    
}