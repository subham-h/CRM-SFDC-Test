/*
Date            Story       Developer       Description
			       							Code Created
29-Jun-2022		SFSE-8624	Kiran			Custom lookup for Executive City / State
14-Mar-2023		SFSE-10179  Vazid			Added new method : testFindRecordsrWareHouse
06-Nov-2023		SFSE-13253	Seba	        Added code to increase coverage
*/
@isTest
public class CustomLookupControllerTest {
    
    public static TestMethod void testGeoSearch(){
        Geography__c geo1 = new Geography__c();
        geo1.Name = 'India';
        geo1.GEO_ID__c = 'geo1';
        geo1.GEO_Code__c = 'IN';
        geo1.Type_Of_Location__c = 'Country';
        geo1.Active__c = true;
        insert geo1;
        
        Geography__c geo2 = new Geography__c();
        geo2.Name = 'Savannah';
        geo2.GEO_ID__c = '0FW19NDUZ2NI7';
        geo2.GEO_Code__c = 'USSAV';
        geo2.Type_Of_Location__c = 'City';
        geo2.Active__c = true;
        geo2.Is_Port__c = true;
        geo2.Parent_Geography__c = geo1.Id;
        insert geo2;
        
        List<Geography__c> geoTerminalList = new List<Geography__c>();
        Geography__c geo3 = new Geography__c();
        geo3.Name = 'Lay by Berth Savannah';
        geo3.GEO_ID__c = 'CA0RCRMUDBUGY';
        geo3.GEO_Code__c = 'USSAVLB';
        geo3.Type_Of_Location__c = 'Terminal';
        geo3.Active__c = true;
        geo3.Parent_Geography__c = geo2.Id;
        geoTerminalList.add(geo3);
        
        Geography__c geo4 = new Geography__c();
        geo4.Name = 'Savannah Delta Trucking';
        geo4.GEO_ID__c = '0TUE3U1V12AGV';
        geo4.GEO_Code__c = 'USSAVDT';
        geo4.Type_Of_Location__c = 'Terminal';
        geo4.Active__c = true;
        geo4.Parent_Geography__c = geo2.Id;
        geoTerminalList.add(geo4);
        insert geoTerminalList;
        
        CustomLookupController.search('', 'Geography__c', '');
        CustomLookupController.search('Savannah', 'Geography__c', '');
        CustomLookupController.search('Savannah', 'Geography__c', 'GEO_ID__c =\'0TUE3U1V12AGV\'');
    }
    
    public static TestMethod void testAccountContactSearch(){
        TriggerExecutionController.skipAllTriggers(true);
        ContactData_Test.iNumberOfContacts = 1;
        ContactData_Test.createCustomerContacts();
        
        CustomLookupController.search('', 'Contact', '');
        CustomLookupController.search('Customer', 'Contact', '');
        CustomLookupController.search('', 'Account', '');
    }
    
    public static TestMethod void testFindRecords(){
        Geography__c geo1 = new Geography__c();
        geo1.Name = 'India';
        geo1.GEO_ID__c = 'geo1';
        geo1.GEO_Code__c = 'IN';
        geo1.Type_Of_Location__c = 'Country';
        geo1.Active__c = true;
        insert geo1;
        
        Geography__c geo2 = new Geography__c();
        geo2.Name = 'Mumbai';
        geo2.GEO_ID__c = '0FW19NDUZ2NI7';
        geo2.GEO_Code__c = 'USSAV';
        geo2.Type_Of_Location__c = 'City';
        geo2.Active__c = true;
        geo2.Is_Port__c = true;
        geo2.Parent_Geography__c = geo1.Id;
        insert geo2;
        
        List<sobject> records = CustomLookupController.findRecords('bai', 'Geography__c', '', geo1.Id);
        System.assertEquals(records.size(), 1); 
        List<sobject> records1 = CustomLookupController.findRecords('bai', 'Geography__c', '', '');//SFSE-13253
        System.assertEquals(records1.size(), 0); 
        List<sobject> users =  CustomLookupController.findRecords('', 'User', '', ''); 
        System.assertEquals(users.size()>0, TRUE);                
        List<sobject> bdas =  CustomLookupController.findRecords('in', 'BDA__c', ' Active__c = TRUE', ''); 
        System.assertEquals(bdas.size(), 0);                
    }
    
    //SFSE-10179
    public static TestMethod void testFindRecordsrWareHouse(){
        Geography__c geo1 = new Geography__c();
        geo1.Name = 'India';
        geo1.GEO_ID__c = 'geo1';
        geo1.GEO_Code__c = 'IN';
        geo1.Type_Of_Location__c = 'Country';
        geo1.Active__c = true;
        insert geo1;

        Warehouse_Site__c warRec = new Warehouse_Site__c();
        warRec.Site_Id__c = 'test001';
        warRec.Name = 'test';
        warRec.Country__c = geo1.id;
        insert warRec;

        List<sobject> records = CustomLookupController.findRecords('tes', 'Warehouse_Site__c', '', geo1.Id);

        System.assertEquals(records.size(), 1);
    }
    //SFSE-11362
    public static testMethod void getAccounts(){
        List<sobject> records = CustomLookupController.findRecords('tes', 'Account', '', '');
    }
}