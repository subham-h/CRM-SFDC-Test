/**
* Author   : Amrutha
* Purpose  : Utility test class for creating Ocean Plus Lead related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0                  23-06-2023  Amrutha@Maersk          Change the Owner id of task and Ocean_Plus_Lead__c
*/
@isTest
public class AssignToMeQACtrl_Test {
    @isTest
    public static void testPopulateFields() {
        TriggerExecutionController.skipAllTriggers(true);       
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069341';
        insert shp;
        
        BDA__c germanyBD = new BDA__c(Name = 'North Europe Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert germanyBD;
        
        Geography__c geo = new Geography__c();
        geo.Name = 'Germany';
        geo.Active__c = true;
        geo.GEO_ID__c = '10Z2W9ZTH2RUM';
        geo.GEO_Code__c = 'DE';
        geo.Type_Of_Location__c = 'Country';
        insert geo;
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl= new Ocean_Plus_Lead__c();
        opl.Booking_Number__c = '224069341';
        opl.Origin_Country_Code__c = 'DE';
        opl.Destination_Country_Code__c = 'DE';  
        opl.OwnerId= user1.id;       
        Test.startTest();
        insert opl;                     
        Test.stopTest(); 
        Ocean_Plus_Lead__c oplNew = [SELECT Id, Shipment__c,Origin_Country__c,Destination_Country__c,OwnerId FROM Ocean_Plus_Lead__c WHERE Id=: opl.Id];
        TestBusinessHelper.createTasks(oplNew.Id, null, 1, true);
        AssignToMeQACtrl.updateOPLnTasks(oplNew.Id);
        //System.assert(oplNew.Origin_Country__c != Null);
    }
    @isTest
    public static void testnonAssignUser() {
        TriggerExecutionController.skipAllTriggers(true);       
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069341';
        insert shp;
        
        BDA__c germanyBD = new BDA__c(Name = 'North Europe Continent Area', GEO_ID__c = 'NA-Trade', Default_Account_Owner__c = UserInfo.getUserId(), Type__c = 'Cluster');
        insert germanyBD;
        
        Geography__c geo = new Geography__c();
        geo.Name = 'Germany';
        geo.Active__c = true;
        geo.GEO_ID__c = '10Z2W9ZTH2RUM';
        geo.GEO_Code__c = 'DE';
        geo.Type_Of_Location__c = 'Country';
        insert geo;
        //User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl= new Ocean_Plus_Lead__c();
        opl.Booking_Number__c = '224069341';
        opl.Origin_Country_Code__c = 'DE';
        opl.Destination_Country_Code__c = 'DE';  
        opl.OwnerId= UserInfo.getUserId();       
        Test.startTest();
        insert opl;                     
        Test.stopTest(); 
        Ocean_Plus_Lead__c oplNew = [SELECT Id, Shipment__c,Origin_Country__c,Destination_Country__c,OwnerId FROM Ocean_Plus_Lead__c WHERE Id=: opl.Id];
        TestBusinessHelper.createTasks(oplNew.Id, null, 1, true);
        // Setup test data
        // Create a unique UserName
        User userForRunAs = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);

        System.runAs(userForRunAs) {
            try {
                AssignToMeQACtrl.updateOPLnTasks(oplNew.Id);
            } catch (Exception exObj) {
                //Assert.areEqual(exObj.getMessage().containsIgnoreCase('Salesforce admin'), true);
            }
        }
        //System.assert(oplNew.Origin_Country__c != Null);
    }
 
}