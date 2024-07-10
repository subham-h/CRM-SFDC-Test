@isTest
public class DisplayShipmentAccConControllerTest {
    
    @isTest
    public static void getAccountContactInfo(){
        TriggerExecutionController.skipAllTriggers(true);
        
        Account acc = new Account(Name ='Test Account SHipment', SCV_Code__c ='331s4019201');
        insert acc;
        
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
        conInstance.External_ID__c = 'TestExt123';
        insert conInstance;
        
        Shipment__c ship = new Shipment__c();
        ship.Shipment_Number__c = '226658426';
        ship.Business_Unit_Id__c = '2162';
        ship.Business_Unit__c = 'Maersk China Shipping (Qingdao)';
        ship.Booked_By_Customer_SCV_Code__c = '331s4019201';
        ship.Price_Owner_SCV_Code__c = '331s4019201';
        insert ship;
        
        Party__c party = new Party__c();
        party.Contact_Person__c = 'TestExt123';
        party.Customer_Name__c = 'SAFROUND LOGISTICS CO LTD';
        party.Scv_Customer_Code__c = '331s4019201';
        party.Tp_Doc_Number__c = '226658426';
        party.Shipment_Number__c = '226658426';
        party.Party_Role_Type_Id__c = '9L3DLF9721UJB';
        party.Party_Role_Type_Name__c = 'Booked By';
        insert party;
        
        TriggerExecutionController.skipAllTriggers(false);
        
        Test.startTest();
        DisplayShipmentAccountContactController.getAccountContactDetails(ship.Id);
        DisplayShipmentAccountContactController.getAccountContactDetails(party.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testErrorMessages(){
        TriggerExecutionController.skipAllTriggers(true);
        
        Shipment__c ship = new Shipment__c();
        ship.Shipment_Number__c = '226658426';
        ship.Business_Unit_Id__c = '2162';
        ship.Business_Unit__c = 'Maersk China Shipping (Qingdao)';
        ship.Booked_By_Customer_SCV_Code__c = '331s4019201';
        ship.Price_Owner_SCV_Code__c = '331s4019201';
        insert ship;
        
        Party__c party = new Party__c();
        party.Contact_Person__c = 'TestExt123';
        party.Customer_Name__c = 'SAFROUND LOGISTICS CO LTD';
        party.Scv_Customer_Code__c = '331s4019201';
        party.Tp_Doc_Number__c = '226658426';
        party.Shipment_Number__c = '226658426';
        party.Party_Role_Type_Id__c = '9L3DLF9721UJB';
        party.Party_Role_Type_Name__c = 'Booked By';
        insert party;
        
        TriggerExecutionController.skipAllTriggers(false);
        
        DisplayShipmentAccountContactController.getAccountContactDetails(ship.Id);
        DisplayShipmentAccountContactController.getAccountContactDetails(party.Id);
        
        Test.startTest();
        ship.Booked_By_Customer_SCV_Code__c = '';
        ship.Price_Owner_SCV_Code__c = '';
        update ship;
        
        party.Contact_Person__c = '';
        party.Scv_Customer_Code__c = '';
        update party;
        
        DisplayShipmentAccountContactController.getAccountContactDetails(ship.Id);
        DisplayShipmentAccountContactController.getAccountContactDetails(party.Id);
        Test.stopTest(); 
    }
    
}