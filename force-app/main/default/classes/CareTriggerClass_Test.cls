/**
* Test class for : CareTriggerHandler
*
* Date         Owner                                   Ref Number     Description
*************************************************************************************************************************************
* 04/11/2017   nirmal.christopher@ust-global.com                      Code updated for code coverage
* 07/06/2022   Ronnie@SF                               SPI-100        Removed brand hardcoding
* 28/08/2023   Richa@Maersk                            SC-8922        Update Ocean Plus Lead on creation/updation of Service Relationship records
* 29-01-2024   Nayana@Maersk                           SC-6992        Populate Service relationship Booked By and Service relationship Contractual on OPL
*/

@isTest
private Class CareTriggerClass_Test {
    @TestSetup
    static void setupTestData(){ 
        TriggerExecutionController.skipAllTriggers(true); 
        Geography__c countryDE = TestBusinessHelper.createGeography('Germany', 'Country', null,'DE',true);
        Geography__c countryUS = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EU-Trade', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('North Europe Continent Area', 'Cluster', 'NEC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryDE.Id, null, true);  
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account consigneeAcc = TestBusinessHelper.createAccount('Client_Account', true);  
        Account contractualAcc = TestBusinessHelper.createAccount('Client_Account', true); 
        Account bookedByAcc = TestBusinessHelper.createAccount('Client_Account', true);
        bookedByAcc.BillingCountry = 'Germany' ;
        bookedByAcc.BillingCity = 'abc';
        update bookedByAcc;        
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(shipperAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Export',true);
        Care_Relationship__c consigneeService =TestBusinessHelper.createServiceRelationship(consigneeAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import',true);
        Care_Relationship__c contractualService =TestBusinessHelper.createServiceRelationship(contractualAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',true);
        contractualAcc.BillingCountry = 'Germany' ;
        contractualAcc.BillingCity = 'abc';
        update contractualAcc;        
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,shipperAcc.SCV_Code__c,80, true);
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', false); 
        shp.Booked_By_Customer_SCV_Code__c = contractualAcc.SCV_Code__c;
        shp.id = null;
        insert shp;
        TriggerExecutionController.skipAllTriggers(true);  
        opl1.Departure_Date__c = System.today() + 5;
        opl1.Arrival_Date__c = System.today() + 15;
        update opl1;        
        TriggerExecutionController.skipAllTriggers(false);  
        //Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069340','DE','DE','SEA',shipperAcc.SCV_Code__c,null,null, true);  
    }
    
@isTest
public static void generateTestRecord () {

Test.StartTest();

Geography__c geo = new Geography__c();
geo.Name = 'TestGeography';
geo.Type_Of_Location__c='Country';
geo.GEO_ID__c = '9999999999999';
insert geo;

Geography__c cityGeo = new Geography__c();
cityGeo.Name = 'Los Santos';
cityGeo.Type_Of_Location__c='City';
cityGeo.GEO_ID__c = '99999KML';
cityGeo.Parent_Geography__c = geo.id;
insert cityGeo ;

Geography__c geo1 = new Geography__c();
geo1.Name = 'TestGeography 1';
geo1.Type_Of_Location__c='Country';
geo1.GEO_ID__c = '9999999999998';
insert geo1;

BDA__c reg = new BDA__c();
reg.Name = 'test Region';
reg.BDA_Code__c = '2222222222222';
reg.Default_Account_Owner__c = UserInfo.getUserId();
reg.GEO_ID__c = '12122121';
reg.Type__c = 'Trade Region'; 
insert reg;

BDA__c clu = new BDA__c();
clu.Name = 'test Cluster';
clu.BDA_Code__c = '1111111111111';
clu.Default_Account_Owner__c = UserInfo.getUserId();
clu.Type__c = 'Cluster';
clu.Parent_BDA__c = reg.Id;
clu.GEO_ID__c = '9999999999999';
insert clu;

BDA_Geography__c bdaGeo = new BDA_Geography__c();
bdaGeo.Geography__c = geo.Id;
bdaGeo.BDA__c = clu.Id;
insert bdaGeo;

CM_Geo_Data__c bhMappingRec = new CM_Geo_Data__c();
bhMappingRec.Name = 'testBHMap';
bhMappingRec.Clusters_Country_Code__c = '9999999999998';
bhMappingRec.External_Geo_Code__c = '1111111111111';
bhMappingRec.Liner_Brand__c = BrandUtilities.MAERSKLINE;
insert bhMappingRec;

Account account1 = new Account();
account1.Name = 'UniteTestAccountName';
account1.BillingStreet = '403 McAdoo St';
account1.BillingCity = 'Los Santos';
account1.BillingState = 'NM';
account1.BillingPostalCode = '87901';
account1.BillingCountry = 'US';
account1.Country__c=geo.id;
insert account1;

Care_Relationship__c care1 = new Care_Relationship__c();
care1.Care_Relationship_Name__c = 'TestCare1';
care1.Service_Level__c = 'CARE';
care1.Direction__c = 'Export';
care1.Country__c = geo.Id;
care1.Account__c = account1.Id;
care1.Status__c = 'Active';
insert care1;

care1.Country__c = geo.Id;
care1.Cluster__c = clu.Id;
update care1;

care1.Country__c = geo1.Id;
care1.Cluster__c = null;
update care1;

Care_Relationship__c CRAssert = [SELECT Id, Account__c, Country_ID_Text__c, Account_ID_Text__c, Country__c FROM Care_Relationship__c WHERE Id = :care1.id];
System.assertEquals(care1.Account__c, CRAssert.Account_ID_Text__c);
System.assertEquals(care1.Country__c, CRAssert.Country_ID_Text__c);

Test.stopTest();
}
    
    @isTest
    public static void testCareRelationshipInactive() { 
        // to verify if Ocean Plus Lead's SR gets removed automatically on deactivating SR
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Departure_Date__c,Arrival_Date__c,Service_Relationship_Import__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c,Service_Relationship_Export__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Export__c != null);       
        List<Care_Relationship__c> lstCare = new List<Care_Relationship__c>();
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c]){
            care.Status__c = 'False';
            lstCare.add(care);
        }
        update lstCare;        
        Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Service_Relationship_Import__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(newOpl.Service_Relationship_Export__c == null); //deactivation of SR removes the lookup
    }
    
    @isTest
    public static void testCareRelationshipInsertUpdate() { 
        // to verify if Ocean Plus Lead's SR gets linked/removed automatically on updating SR
        Test.startTest();
        List<Care_Relationship__c> lstUpdateCare = new List<Care_Relationship__c>();
        List<Care_Relationship__c> lstDeleteCare = new List<Care_Relationship__c>();
        String accId;
        String countryId;
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c,Account__c,Country__c from Care_Relationship__c]){
            if(care.Direction__c == 'Import') {   
                care.Direction__c = null;
                lstUpdateCare.add(care);
            }
            if(care.Direction__c == 'Export') { 
                accId = care.Account__c;
                countryId = care.Country__c;
                lstDeleteCare.add(care);
            }
            
        }     
        update lstUpdateCare;  
        delete lstDeleteCare;
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Import__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c,Service_Relationship_Export__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Import__c == null); // change in direction of SR removes the lookup
        System.assert(opl.Service_Relationship_Export__c == null); // deletion of SR removes the lookup
        List<Care_Relationship__c> lstNewUpdateOnCare = new List<Care_Relationship__c>();
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c from Care_Relationship__c]){
            if(care.Direction__c == null)    
                care.Direction__c = 'Import';
            lstNewUpdateOnCare.add(care);
        }
        update lstNewUpdateOnCare;  
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(accId, countryId, BrandUtilities.MAERSKLINE,'Export',true);
        Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Service_Relationship_Import__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(newOpl.Service_Relationship_Import__c != null); // change in direction of SR adds the lookup
        System.assert(newOpl.Service_Relationship_Export__c != null); // insertion of SR adds the lookup
    }
    
       @isTest
    public static void testCareRelationshipAccountUpdate() { 
        // to verify if Ocean Plus Lead's SR gets removed automatically on updating Account
        Test.startTest();
        List<Care_Relationship__c> lstUpdateCare = new List<Care_Relationship__c>();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Import__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c,Service_Relationship_Export__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Import__c != null); 
        System.assert(opl.Service_Relationship_Export__c != null); 
        Account extraAcc = TestBusinessHelper.createAccount('Client_Account', true);
        List<Account> lstAcc = [Select Id, Name,SCV_Code__c from Account order by createddate desc limit 1];
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c,Account__c,Country__c from Care_Relationship__c]){
           	care.Account__c = lstAcc[0].Id;
            lstUpdateCare.add(care);
        }       
        update lstUpdateCare; 
        Ocean_Plus_Lead__c newOpl = [SELECT Id,Brand__c,Service_Relationship_Import__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c,Service_Relationship_Export__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
		System.assert(newOpl.Service_Relationship_Import__c == null); // change in Account of SR removes the lookup
        System.assert(newOpl.Service_Relationship_Export__c == null); // change in Account of SR removes the lookup
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void testCareRelationshipAccUpdateContractual() { 
        // to verify if Ocean Plus Lead's SR gets removed automatically on updating Account
        Test.startTest();
        List<Care_Relationship__c> lstUpdateCare = new List<Care_Relationship__c>();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Contractual__c,Contractual_SCV_Code__c,Contractual_Country__c,Contractual_City__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Contractual__c != null); 
        Account extraAcc = TestBusinessHelper.createAccount('Client_Account', true);
        List<Account> lstAcc = [Select Id, Name,SCV_Code__c from Account order by createddate desc limit 1];
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c,Account__c,Country__c from Care_Relationship__c]){
           	care.Account__c = lstAcc[0].Id;
            lstUpdateCare.add(care);
        }       
        update lstUpdateCare; 
        Ocean_Plus_Lead__c newOpl = [SELECT Id,Brand__c,Service_Relationship_Contractual__c,Contractual_SCV_Code__c,Contractual_Country__c,Contractual_City__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
		System.assert(newOpl.Service_Relationship_Contractual__c == null); // change in Account of SR removes the lookup        
        Test.stopTest();        
    }
    @isTest
    public static void testCareRelationAccountUpdateBookedby() {  
        // to verify if OPL gets updated if Shipment gets Inserted       
       	Test.startTest();
        List<Care_Relationship__c> lstUpdateCare = new List<Care_Relationship__c>();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,Service_Relationship_BookedBy__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341' limit 1];
        System.assert(opl.Booked_By_SCV_Code__c != null);     
        System.assert(opl.Service_Relationship_BookedBy__c != null); 
        Account extraAcc = TestBusinessHelper.createAccount('Client_Account', true);
        List<Account> lstAcc = [Select Id, Name,SCV_Code__c from Account order by createddate desc limit 1];
        for(Care_Relationship__c care: [SELECT Id,Direction__c,Account__r.SCV_Code__c,Status__c,Account__c,Country__c from Care_Relationship__c]){
           	care.Account__c = lstAcc[0].Id;
            lstUpdateCare.add(care);
        }       
        update lstUpdateCare; 
        Ocean_Plus_Lead__c newOpl = [SELECT Id,Brand__c,Service_Relationship_BookedBy__c,Booked_By_SCV_Code__c,BookedBy_Country__c,BookedBy_City__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
		System.assert(newOpl.Service_Relationship_BookedBy__c == null); // change in Account of SR removes the lookup        
        Test.stopTest();   
    }
}