/*
* Author   : Richa 
* Purpose  : Test class for BatchDeleteDuplicateOPLs
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9584    26/10/2023    Richa@Maersk      Test the batch class to externalid of OPLs
*/
@isTest
public class TempBatchUpdateExternalIdOfOPLs_Test {
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
        Contact shipperCon = TestBusinessHelper.createContact(shipperAcc,'Customer_Contact','Maersk Line', true);
        shipperCon.Email = 'shipper@xyz.com';
        shipperCon.FirstName = 'shipper';
        update shipperCon;
        Contact consigneeCon = TestBusinessHelper.createContact(consigneeAcc,'Customer_Contact','Maersk Line', true);
        consigneeCon.Email = 'consignee@xyz.com';
        consigneeCon.FirstName = 'consignee';
        update consigneeCon;
        Contact contractualCon = TestBusinessHelper.createContact(contractualAcc,'Customer_Contact','Maersk Line', true);
        contractualCon.FirstName = 'contractual';
        contractualCon.Email = 'contractual@xyz.com';
        update contractualCon;
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(shipperAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Export',true);
        Care_Relationship__c consigneeService =TestBusinessHelper.createServiceRelationship(consigneeAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import',true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069342','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,null,80, true);
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069343','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,null,priceOwnerAcc.SCV_Code__c,80, true);
        Test.setCreatedDate(opl2.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(opl3.Id, Datetime.now().addDays(-2));
    }
    @isTest
    public static void updateExternalId() { 
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        Datetime testingday = Datetime.now().addDays(-3);
        for(Ocean_Plus_Lead__c opl:[SELECT Id,Status__c,Booking_Number__c,CXLeadExternalId__c,createddate FROM Ocean_Plus_Lead__c]){
            opl.OwnerId = Label.CrossSellInterface;           
             if(opl.Booking_Number__c == '224069341' ){
                opl.CXLeadExternalId__c = '22406934140DRY';
            }else if(opl.Booking_Number__c  == '224069342' ){
                opl.CXLeadExternalId__c = '224069342UnknownMetal';
            }else{
                 opl.CXLeadExternalId__c = '22406934220DRYUnknown';
            }
            lstOPLUpdate.add(opl);
        }	
        update lstOPLUpdate;
        System.assert(lstOPLUpdate.size() == 3); // verify the size before batch run
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
       	TempBatchUpdateExternalIdOfOPLs  be = new TempBatchUpdateExternalIdOfOPLs ('New',System.today()-3, System.today()+1,null);
		 database.executeBatch(be);
        TriggerExecutionController.skipAllTriggers(false);
        List<Ocean_Plus_Lead__c> lstOPL = [Select Id,CreatedDate,Status__c,Booking_Number__c,CXLeadExternalId__c from Ocean_Plus_Lead__c];
        Test.stopTest();
        System.debug('###lstOPL'+lstOPL);
        //System.assert(lstOPL[0].CXLeadExternalId__c== lstOPL[0].Booking_Number__c); // verify the dupicates have been removed after batch run
    }
    
    
}