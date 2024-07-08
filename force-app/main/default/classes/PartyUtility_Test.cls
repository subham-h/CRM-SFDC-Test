/**
* Author   : Richa
* Purpose  : Utility test class for Party related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9582     03-01-2024  Richa@Maersk            Update OceanPlusLead records with Booked By Party details
*/

@isTest
public class PartyUtility_Test {
    @TestSetup
    static void setupTestData(){
        TriggerExecutionController.skipAllTriggers(true); 
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', true);
        Account bookedByAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact bookedByCon = TestBusinessHelper.createContact(bookedByAcc,'Customer_Contact','Maersk Line', true);
        bookedByCon.Email = 'booked@xyz.com';
        bookedByCon.FirstName = 'bookedBy';
        bookedByCon.External_ID__c = 'ConEx123';
        update bookedByCon;        
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',bookedByAcc.SCV_Code__c,bookedByAcc.SCV_Code__c,bookedByAcc.SCV_Code__c,bookedByAcc.SCV_Code__c,80, true);
    }
    
    
   @isTest
    public static void testUpdateBookedByOnOPLOnPartyInsert() {  
        // to verify if OPL gets updated on Booked By party insert
        Ocean_Plus_Lead__c opl = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Shipment__c != null); 
        System.assert(opl.Booked_By_Contact_Name__c == null);// check if booked by contact name is null
        Test.startTest();        
        Party__c prty = TestBusinessHelper.createShipmentParty('224069341','ConEx123','1', true);
        Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOPL = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOPL[0].Booked_By_Contact_Name__c != null);//check if Booked By Contact got updated
    }
    
      @isTest
    public static void testUpdateBookedByOnOPLOnPartyUpdate() {  
        // to verify if OPL gets updated on Booked By party update
        Party__c prty = TestBusinessHelper.createShipmentParty('224069341',null,'1', true);
        Ocean_Plus_Lead__c opl = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Shipment__c != null); 
        System.assert(opl.Booked_By_Contact_Name__c == null);// check if booked by contact name is null
        Test.startTest();        
        prty.Contact_Person__c = 'ConEx123';
        update prty;
        System.debug('$$$prty'+prty);
        Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOPL = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOPL[0].Booked_By_Contact_Name__c != null);//check if Booked By Contact got updated
    }
}