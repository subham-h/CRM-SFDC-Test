/**
* Author   : Richa
* Purpose  : Test class for Lwc controller OceanPlusLineItemController
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8872     06-09-2023  Richa@Maersk            Ocean Plus Line Item record retreive and update
* 2.0       SC-9147     29-09-2023  Richa@Maersk            Mass update of selected OPL and OPLIs
*/

@isTest
public class OceanPlusLineItemController_Test {
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
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069342','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
    }
    
       @isTest
    public static void testUpdateProducts() { 
        // to verify if Ocean Plus Lead record status gets updated based on insert/update/delete of OPLI
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import;Value Protect'; 
        update opl; 
        OceanPlusLineItemController.getOceanPlusLineItems(opl.Id);
        List<Ocean_Plus_Line_Item__c> lstOPLIUpdate = new List<Ocean_Plus_Line_Item__c>();
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c,Partial_Booking__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli.size() == 3);       
        for(Ocean_Plus_Line_Item__c opli: lstOpli){
            if(opli.Product__c == 'Intermodal Import'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
                opli.Partial_Booking__c = false;
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
        OceanPlusLineItemController.updateOceanPlusLineItems(lstOPLIUpdate);
        Test.startTest();
        Ocean_Plus_Lead__c opl1 = [SELECT Id,Status__c,Brand__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl1.Status__c == 'Sold'); //If 1 OPLI is sold, parent status shpuld be Sold          
        Test.stopTest();
    }
    
     @isTest
    public static void testMassUpdateOPLI() { 
        // to verify if Ocean Plus Lead record and line item gets copied over to another opl
        List<Ocean_Plus_Lead__c> lstOpl = [SELECT Id,Name,Status__c,OwnerId,Products_Pitched__c FROM Ocean_Plus_Lead__c];
        lstOpl[0].Products_Pitched__c = 'Intermodal Import;CHB Import;Value Protect'; 
        Test.startTest();
        update lstOpl[0];
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c,Other_Reason__c,No_of_FFEs_sold__c,Additional_Comments__c,Partial_Booking__c FROM Ocean_Plus_Line_Item__c WHERE Ocean_Plus_Lead__c =: lstOpl[0].Id];
        List<String> lstOplIds = new List<String>();
        lstOplIds.add(lstOpl[1].Id);
        OceanPlusLineItemController.massUpdateOPLsAndOPLIs(lstOplIds,lstOpl[0].OwnerId,'In Progress',lstOpl[0].Products_Pitched__c,lstOpli);
        List<Ocean_Plus_Line_Item__c> lstOpli1 = [SELECT Id,Status__c,Product__c,Reasons_for_In_Progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_Creation__c,Other_Reason__c,No_of_FFEs_sold__c,Additional_Comments__c,Partial_Booking__c FROM Ocean_Plus_Line_Item__c WHERE Ocean_Plus_Lead__c =: lstOpl[1].Id];
        System.assert(lstOpli.size() == lstOpli1.size());      //verify if opl1 got copied over to opl 2
        Test.stopTest();
    }
    

}