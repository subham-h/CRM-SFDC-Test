/*
* Author   : Vivek 
* Purpose  : test class for Batch Updated fields for Party . 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0	  SC-7773		28/04/2023    Vivek@Maersk			Created the test class for batch class

*/
@isTest
public class BatchUpdateFieldsForPartyRecordTest {
    
    @isTest
    public static void updatePartyFields() {
        
        TriggerExecutionController.skipAllTriggers(true);
        
        Account acc = new Account(Name ='Test Account SHipment', SCV_Code__c ='331s4019201');
        insert acc;
        //ContactData_Test.populateCommonContactFields();
        Id customerRTId = StaticFactory.getRecordTypeIdByName('Contact', 'Customer Contact');
        Contact conInstance = new Contact();
        conInstance.AccountId = acc.Id;
        conInstance.LastName = 'Test Contact Dispute'; 
        conInstance.RecordTypeId = customerRTId;
        conInstance.Email = DateTime.now().millisecond() + 'TestContact' + Math.random() + '@test.com';
        conInstance.Phone = '+44 123412' ;
        conInstance.FirstName = 'Test' + Math.random() + DateTime.now().millisecond();
        conInstance.Liner_Brands__c = Label.LinerBrandML;
        conInstance.Country__c = acc.Country__c;
        conInstance.Contact_Status__c = 'Active';
        conInstance.External_id__c = '12345671';
        
        insert conInstance;
        
        //Shipment record
        Shipment__C thisShipment = new Shipment__c(Shipment_number__C = '12345678');
        insert thisShipment;
        
        Party__C thisParty = new Party__C(Contact_Person__c = '12345671',Party_Role_Type_Id__c='0912345',Scv_Customer_Code__c='331s4019201',Shipment_Number__c = '12345678');
        insert thisParty;
        
        Test.startTest();
        BatchUpdateFieldsForPartyRecord batch = new BatchUpdateFieldsForPartyRecord();
        Database.executeBatch(batch, 1);
        String sch = '0 0 2 * * ?';
        String jobID = system.schedule('BatchUpdateFieldsForPartyRecordTest', sch, batch);
        
        Test.stopTest();
        
    }
}