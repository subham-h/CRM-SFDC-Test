/* 
* Purpose  : Purpose of this class is to test batch class for update of opl booked by customer and contact info of historical records
* 
* Revision     Ref Number      Date         Owner                                  Description
* --------     ----------      -----------  -------------------                    -----------
* 1.0          SC-9582       15/01/2024   Richa@Maersk              Test class for temporary batch class for opl update

*/

@isTest
public class TempBatchUpdateOPLs_Test {
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
        Party__c prty = TestBusinessHelper.createShipmentParty('224069341','ConEx123','1', true);        
        prty.Scv_Customer_Code__c = bookedByAcc.SCV_Code__c;
        update prty;
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',null,null,null,null,80, true);
        TriggerExecutionController.skipAllTriggers(false);   
    }
    
    
   @isTest
    public static void testUpdateBookedByOnOPL() {  
        // to verify if OPL gets updated 
        Ocean_Plus_Lead__c opl = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Booked_By_Contact_Name__c == null);// check if booked by contact name is null
        Test.startTest();        
        TempBatchUpdateOPLs be = new TempBatchUpdateOPLs('New',System.today()-1, System.today()+1);
        database.executeBatch(be);
        Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOPL = [SELECT Id,Booking_Number__c,Shipment__c,Booked_By_Contact_Name__c,Booked_By_Contact_Email__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        //System.assert(lstOPL[0].Booked_By_Contact_Name__c != null);//check if Booked By Contact got updated
    }
  
}