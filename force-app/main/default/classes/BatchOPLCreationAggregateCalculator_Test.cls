/*
* Author   : Richa 
* Purpose  : Test class for BatchOPLCreationAggregateCalculator
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9742    12/06/2024    Richa@Maersk      Test the batch class which creates OPL Aggregate records
*/
@isTest
public class BatchOPLCreationAggregateCalculator_Test {
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
        Lead lead = TestBusinessHelper.createLead(BrandUtilities.MAERSKLINE, true);
        lead.Comments_for_Lead_source__c = 'CX';
        lead.Country_Ownership_Cluster__c = childBDA.Id;
        lead.OwnerId = Label.CrossSellInterface;
        update lead;
        Test.setCreatedDate(lead.Id, Datetime.now().addDays(-31));
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069342','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,null,80, true);
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069343','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,null,priceOwnerAcc.SCV_Code__c,80, true);
        Test.setCreatedDate(opl2.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(opl3.Id, Datetime.now().addDays(-2));
    }
    @isTest
    public static void createAggregateRecords() { 
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        Datetime testingday = Datetime.now().addDays(-3);
        for(Ocean_Plus_Lead__c opl:[SELECT Id,Status__c,OwnerId,createddate FROM Ocean_Plus_Lead__c]){
            opl.OwnerId = Label.CrossSellInterface;
            lstOPLUpdate.add(opl);
        }	
        update lstOPLUpdate;
        System.assert(lstOPLUpdate.size() == 3,'OPL size'); // verify the size before batch run
        Test.startTest();
       	BatchOPLCreationAggregateCalculator myBatch = new BatchOPLCreationAggregateCalculator(System.today()-5,System.today()+1,null);
		Database.executeBatch(myBatch); 
        Test.stopTest();
    }
    
    
}