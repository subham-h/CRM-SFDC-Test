/*
* Author   : Nayana 
* Purpose  : Test class for TempBatchUpdateBookbyOrContractualOPLs
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9662    13/02/2024    Nayana@Maersk      Test the batch class TempBatchUpdateBookbyOrContractualOPLs
*/
@isTest
public class TempBatchUpdtBookbyOrContractualOPLTest {
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
        Account bookedByAcc = TestBusinessHelper.createAccount('Client_Account', true);
        //Shipment__c shp = TestBusinessHelper.createShipment('224069341', true); 
        shp.Booked_By_Customer_SCV_Code__c = bookedByAcc.SCV_Code__c;
        update shp;
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
        Contact bookedByCon = TestBusinessHelper.createContact(bookedByAcc,'Customer_Contact','Maersk Line', true);
        bookedByCon.Email = 'booked@xyz.com';
        bookedByCon.FirstName = 'bookedBy';
        bookedByCon.External_ID__c = 'ConEx123';
        update bookedByCon;
        bookedByAcc.SCV_Code__c = '1234';
        bookedByAcc.BillingCountry = 'Germany' ;
        bookedByAcc.BillingCity = 'abc';
        update bookedByAcc;
        contractualAcc.SCV_Code__c = '4567';
        contractualAcc.BillingCountry = 'Germany' ;
        contractualAcc.BillingCity = 'abc';
        update contractualAcc;
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(shipperAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',true);
        Care_Relationship__c consigneeService =TestBusinessHelper.createServiceRelationship(consigneeAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',true);
        Care_Relationship__c bookedByService =TestBusinessHelper.createServiceRelationship(bookedByAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',true);
        Care_Relationship__c contractualService =TestBusinessHelper.createServiceRelationship(contractualAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',true);
        
        //TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,'4567',priceOwnerAcc.SCV_Code__c,80, true);
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069342','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,'4567',null,80, true);
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069343','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,null,priceOwnerAcc.SCV_Code__c,80, true);
        opl1.Arrival_Date__c  = System.today().addDays(10);
        opl1.Booked_By_SCV_Code__c = '1234';
        opl2.Arrival_Date__c = System.today().addDays(10);
        opl3.Departure_Date__c  = System.today().addDays(-5);
        update opl1;
        update opl2;
        update opl3;
        TriggerExecutionController.skipAllTriggers(false);
        Test.setCreatedDate(opl2.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(opl3.Id, Datetime.now().addDays(-2));
    }
    @isTest
    public static void updateExternalId() { 
        /*List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
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
        update lstOPLUpdate;*/
        //System.assert(lstOPLUpdate.size() == 3); // verify the size before batch run
        List<Ocean_Plus_Lead__c> lstOPL = [Select Id,CreatedDate,Status__c,Direction__c,Brand__c,Booked_By_SCV_Code__c, Contractual_SCV_Code__c,Service_Relationship_BookedBy__c,Service_Relationship_Contractual__c,BookedBy_Country__c,BookedBy_City__c,Contractual_Country__c,Contractual_City__c from Ocean_Plus_Lead__c];
        system.debug('lstOPL++'+lstOPL);
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
       	TempBatchUpdateBookbyOrContractualOPLs  be = new TempBatchUpdateBookbyOrContractualOPLs('New',System.today()-3, System.today()+1,10);
		 database.executeBatch(be);
        TriggerExecutionController.skipAllTriggers(false);
        //List<Ocean_Plus_Lead__c> lstOPL = [Select Id,CreatedDate,Status__c,Booking_Number__c,CXLeadExternalId__c from Ocean_Plus_Lead__c];
        Test.stopTest();
        //System.debug('###lstOPL'+lstOPL);
        //System.assert(lstOPL[0].CXLeadExternalId__c== lstOPL[0].Booking_Number__c); // verify the dupicates have been removed after batch run
    }
    
    
}