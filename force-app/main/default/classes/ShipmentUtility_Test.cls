/**
* Author   : Richa
* Purpose  : Utility test class for Shipment related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9041      11-09-2023  Richa@Maersk            Delete OceanPlusLead records with cancelled shipment status
* 2.0      SC-9582     18-12-2023  Richa@Maersk            Show Booked By Customer SCV on OPL
* 3.0      SC-9985     02-04-2024  Nayana@Maersk           Update In Progress OceanPlusLead records with Cancelled status when shipment is cancelled
*/
@isTest
public class ShipmentUtility_Test {
    
    @TestSetup
    static void setupTestData(){  
        TriggerExecutionController.skipAllTriggers(true); 
        Geography__c countryDE = TestBusinessHelper.createGeography('Germany', 'Country', null,'DE',true);
        Geography__c countryUS = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EU-Trade', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('North Europe Continent Area', 'Cluster', 'NEC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryDE.Id, null, true);        
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', true);
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,shipperAcc.SCV_Code__c,shipperAcc.SCV_Code__c,shipperAcc.SCV_Code__c,80, true);
      Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069340','DE','DE','SEA',shipperAcc.SCV_Code__c,null,null,null,17, true);
    }
    
   @isTest
    public static void testDeleteOPLOnShipmentUpdate() {  
        // to verify if OPL gets deleted if Shipment status gets changed to Cancelled
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Origin_Area__c,Origin_Region__c,Service_Relationship_Import__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Shipment__c != null); // check if shipment lookup got populated
        opl.OwnerId = Label.CrossSellInterface;
        update opl;
        Shipment__c shp = [SELECT Id,Shipment_Status__c from Shipment__c where Shipment_Number__c= '224069341'];
        Test.startTest();
        shp.Shipment_Status__c = 'Cancelled by Customer';        
        update shp;     
        Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOPL = [SELECT Id, Shipment__c,Origin_Area__c,Origin_Region__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Service_Relationship_Import__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assertEquals(0, lstOPL.size());//check if OPL gpt deleted
    }
    
     @isTest
    public static void testOPLOnShipmentInsert() {  
        // to verify if OPL gets updated if Shipment gets Inserted       
         Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,CHB_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069340'];
        System.assert(opl.Booked_By_SCV_Code__c == null);// verify Booked by SCV code is null before Shipment insert
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069340';
        shp.Booked_By_Customer_SCV_Code__c = '1234';
        insert shp;
        Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Booked_By_SCV_Code__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069340'];
        System.assertNotEquals(opl.Booked_By_SCV_Code__c, newOpl.Booked_By_SCV_Code__c);
    }
    
         @isTest
    public static void testOPLOnCancelledShipmentInsert() {  
        // to verify if OPL gets deleted if Cancelled Shipment gets Inserted       
         Test.startTest();
        Validation_Rules_Bypass__c setting = new Validation_Rules_Bypass__c();
        setting.SetupOwnerId = UserInfo.getUserId();
        setting.Active__c = true;
        insert setting;
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,CHB_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069340'];
        opl.OwnerId = Label.CrossSellInterface;
        update opl;
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069340';
        shp.Shipment_Status__c = 'Cancelled by Customer';
        insert shp;
        Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOpl = [SELECT Id, Shipment__c,Booked_By_SCV_Code__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069340'];        
        System.assertEquals(0, lstOpl.size());
    }
    
    @isTest
    public static void testOPLOnCancelShipmentInsert() {  
        User integrationUser = [SELECT Id,Name FROM User WHERE Name ='ESB Interface' LIMIT 1];         
        Validation_Rules_Bypass__c setting = new Validation_Rules_Bypass__c();
        setting.SetupOwnerId = integrationUser.Id;
        setting.Active__c = true;
        insert setting;
        // to verify if OPL gets updated to Cancelled if Cancelled Shipment gets Inserted       
        Test.startTest();        
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,Booking_Number__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c ='224069340'];
        opl.Status__c = 'In Progress';
        opl.Products_Pitched__c = 'Cargo Risk Management';
        update opl;
        System.runAs(integrationUser) {
            Shipment__c shp = new Shipment__c();
            shp.Shipment_Number__c = '224069340';
            shp.Shipment_Status__c = 'Cancelled by Customer';
            insert shp;   
        }
        Test.stopTest();        
        Ocean_Plus_Lead__c Opl2 = [SELECT Id, Shipment__c,Status__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c ='224069340'];        
        System.assertEquals('Cancelled', opl2.Status__c);
    }
    
    @isTest
    public static void testOPLOnCancelledShipmentUpdate() {  
        User integrationUser = [SELECT Id,Name FROM User WHERE Name ='ESB Interface' LIMIT 1];         
        Validation_Rules_Bypass__c setting = new Validation_Rules_Bypass__c();
        setting.SetupOwnerId = integrationUser.Id;
        setting.Active__c = true;
        insert setting;
        // to verify if OPL gets updated to Cancelled if Cancelled Shipment gets Inserted       
         Test.startTest();        
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,Booking_Number__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c ='224069341'];
        opl.Status__c = 'In Progress';
        opl.Products_Pitched__c = 'Cargo Risk Management';
        update opl;
        Shipment__c shp1 = [SELECT Id,Shipment_Status__c from Shipment__c where Shipment_Number__c= '224069341'];
        System.runAs(integrationUser) {
            shp1.Shipment_Status__c = 'Cancelled by Carrier';        
            update shp1;  
        }
        Test.stopTest();
        
        Ocean_Plus_Lead__c Opl2 = [SELECT Id, Shipment__c,Status__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c ='224069341'];        
        System.assertEquals('Cancelled', Opl2.Status__c);
    }
    
}