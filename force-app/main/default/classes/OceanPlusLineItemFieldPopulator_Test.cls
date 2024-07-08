/**
* Author   : Richa
* Purpose  : Utility test class for creating Ocean Plus Lead related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8872     04-09-2023  Richa@Maersk            Ocean Plus Lead record status update based on insert/update/delete of OPLI
* 2.0      SC-9198     06-10-2023  Richa@Maersk            Populate date of last status update
* 3.0      SC-9221     10-10-2023  Richa@Maersk           Populate the externalid of OPLIs
* 4.0      SC-9237     27-10-2023  Richa@Maersk           Capture Completed date of OPL
* 5.0       SC-9984     29-4-2024   Meghna@Maersk         Populate OwnerID
*/
@isTest
public class OceanPlusLineItemFieldPopulator_Test {
    
    @TestSetup
    static void setupTestData(){        
        Geography__c countryDE = TestBusinessHelper.createGeography('Germany', 'Country', null,'DE',true);
        Geography__c countryUS = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EU-Trade', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('North Europe Continent Area', 'Cluster', 'NEC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryDE.Id, null, true);
        TriggerExecutionController.skipAllTriggers(true); 
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', true);     
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account consigneeAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account contractualAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account priceOwnerAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(shipperAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Export',true);
        Care_Relationship__c consigneeService =TestBusinessHelper.createServiceRelationship(consigneeAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import',true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,null,null,80, true);        
    }
    
    @isTest
    public static void testUpdateProducts() { 
        // to verify if Ocean Plus Lead record status gets updated based on insert/update/delete of OPLI
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Products_Pitched__c,Completed_Date__c FROM Ocean_Plus_Lead__c Limit 1];
        System.assert(opl.Completed_Date__c == null); //verify completed date is null        
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import;Value Protect'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOPLIUpdate = new List<Ocean_Plus_Line_Item__c>();
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli.size() == 3);       
        for(Ocean_Plus_Line_Item__c opli: lstOpli){
            if(opli.Product__c == 'Intermodal Import'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
            }
            if(opli.Product__c == 'CHB Import'){
                opli.Status__c = 'Not Sold';
                opli.Reasons_for_Not_Selling__c = 'Pending';
            }
            if(opli.Product__c == 'Value Protect'){
                opli.Status__c = 'Lead for Sales';
                opli.Reasons_for_Lead_Creation__c = 'Customer wants to negotiate on the rates';
            }  
            lstOPLIUpdate.add(opli);
        }
        update lstOPLIUpdate;
        Test.startTest();
        Ocean_Plus_Lead__c opl1 = [SELECT Id,Status__c,Completed_Date__c,Products_Pitched__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341' Limit 1];
        System.assert(opl1.Status__c == 'Sold'); //If 1 OPLI is sold, parent status shpuld be Sold
        System.assert(opl1.Completed_Date__c != null); //verify completed date is not null 
        opl1.Products_Pitched__c = 'CHB Import;Value Protect'; 
        update opl1; 
        Ocean_Plus_Lead__c opl2 = [SELECT Id,Status__c,Brand__c,Products_Pitched__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341' Limit 1];
        System.assert(opl2.Status__c == 'Lead for Sales'); //If 1 OPLI is Lead for Sales with no OPLI marked as Sold, parent status shpuld be Lead for Sales
        opl2.Products_Pitched__c = 'CHB Import'; 
        update opl2;         
        Test.stopTest();
    }
    
    @isTest
    public static void testLastStatusUpdate() { 
        // to verify if Ocean Plus Line Item Last Status update date changes on status update
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Products_Pitched__c,Completed_Date__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341' Limit 1];
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import;Value Protect'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOPLIUpdate = new List<Ocean_Plus_Line_Item__c>();
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Last_Status_Update__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli[0].Last_Status_Update__c == lstOpli[1].Last_Status_Update__c); 
        for(Ocean_Plus_Line_Item__c opli: lstOpli){
            if(opli.Product__c == 'Intermodal Import'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
            }
            if(opli.Product__c == 'CHB Import'){
                opli.Status__c = 'Not Sold';
                opli.Reasons_for_Not_Selling__c = 'Pending';
            }
            if(opli.Product__c == 'Value Protect'){
                opli.Status__c = 'Lead for Sales';
                opli.Reasons_for_Lead_Creation__c = 'Customer wants to negotiate on the rates';
            }  
            lstOPLIUpdate.add(opli);
        }
        update lstOPLIUpdate;  
        Test.startTest();
             
        
        List<Ocean_Plus_Line_Item__c> lstOpli1 = [SELECT Id,Status__c,Last_Status_Update__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli1[0].Last_Status_Update__c == lstOpli1[1].Last_Status_Update__c); //last status update date got populated
        Test.stopTest();
    }
    
      @isTest
    public static void testExternalIdUpdate() { 
        // to verify if Ocean Plus Line Item External Id got updated
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        for(Ocean_Plus_Lead__c opl:[SELECT Id,Brand__c,Products_Pitched__c FROM Ocean_Plus_Lead__c]){
            opl.Products_Pitched__c = 'CHB Import;Value Protect';        
            lstOPLUpdate.add(opl);
        }
        Test.startTest();
        update lstOPLUpdate;       
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Product__c,Booking_Number__c,OPLIExternalId__c FROM Ocean_Plus_Line_Item__c];
        System.assert(lstOpli.size() == 4);   // number of oplis
        List<Ocean_Plus_Line_Item__c> lstOpliWithExId = [SELECT Id,Status__c,Product__c,Booking_Number__c,OPLIExternalId__c FROM Ocean_Plus_Line_Item__c where OPLIExternalId__c != null];
        System.assert(lstOpliWithExId.size() == 2);  // number of oplis with external Id
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',null,null,null,null,80, true);
        opl3.Products_Pitched__c = 'CHB Import;Value Protect'; 
        update opl3; 
        Test.stopTest();
        List<Ocean_Plus_Line_Item__c> lstOpli1 = [SELECT Id,Status__c,Product__c,Booking_Number__c,OPLIExternalId__c FROM Ocean_Plus_Line_Item__c];
        System.assert(lstOpli1.size() == 6);   // number of oplis
       	List<Ocean_Plus_Line_Item__c> lstOpliWithExId1 = [SELECT Id,Status__c,Product__c,Booking_Number__c,OPLIExternalId__c FROM Ocean_Plus_Line_Item__c where OPLIExternalId__c != null];       
        System.assert(lstOpliWithExId1.size() == 2);  // number of oplis with external Id
    }
    @isTest
    public static void testUpdateLastModifiedDate() { 
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Products_Pitched__c,Completed_Date__c, LastUpdatedDate__c FROM Ocean_Plus_Lead__c Limit 1];
        System.assert(opl.Completed_Date__c == null);       
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import;Value Protect'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOPLIUpdate = new List<Ocean_Plus_Line_Item__c>();
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli.size() == 3);       
        for(Ocean_Plus_Line_Item__c opli: lstOpli){
            if(opli.Product__c == 'Intermodal Import'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
            }
            if(opli.Product__c == 'CHB Import'){
                opli.Status__c = 'Not Sold';
                opli.Reasons_for_Not_Selling__c = 'Pending';
            }
            if(opli.Product__c == 'Value Protect'){
                opli.Status__c = 'Lead for Sales';
                opli.Reasons_for_Lead_Creation__c = 'Customer wants to negotiate on the rates';
            }  
            lstOPLIUpdate.add(opli);
        }
        TriggerExecutionController.skipOceanPlusLeadTrigger(true);
        update lstOPLIUpdate;
        TriggerExecutionController.skipOceanPlusLeadTrigger(false);
        Integer count = 0;
        
        Test.startTest();
        lstOPLIUpdate[1].Reasons_for_Selling__c = 'Interested only for this cargo type';
        update lstOPLIUpdate[1];
        
        Ocean_Plus_Lead__c opl1 = [SELECT Id,Status__c,Completed_Date__c,Products_Pitched__c,LastUpdatedDate__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341' Limit 1];
        Assert.isTrue(opl1.LastUpdatedDate__c != opl.LastUpdatedDate__c);
        Test.stopTest();
    }
    @istest
        public static void testupdateOPLiOwner() { 
        // to verify if Ocean Plus Line Item External Id got updated
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        for(Ocean_Plus_Lead__c opl:[SELECT Id,Brand__c,Products_Pitched__c FROM Ocean_Plus_Lead__c]){
            
            opl.Products_Pitched__c = 'CHB Import;Value Protect';        
            lstOPLUpdate.add(opl);
        }
        Test.startTest();
        update lstOPLUpdate;       

        Test.stopTest();
        List<Ocean_Plus_Line_Item__c> lstOpli1 = [SELECT Id,Status__c,Owner__c,Product__c,Booking_Number__c,OPLIExternalId__c FROM Ocean_Plus_Line_Item__c];
        System.assert(lstOpli1[0].Owner__c==userinfo.getuserid());

    }
    
}