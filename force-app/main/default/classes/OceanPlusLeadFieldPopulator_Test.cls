/**
* Author   : Richa
* Purpose  : Utility test class for creating Ocean Plus Lead related data. 
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8485    23-06-2023  Richa@Maersk            Populate Shipment and Geography lookup 
* 2.0      SC-8746    07-08-2023  Richa@Maersk            Populate Service Relationship
* 3.0      SC-8782    12-08-2023  Richa@Maersk            Populate Area and Region lookup
* 4.0      SC-8872    23-08-2023  Richa@Maersk            Populate Area and Region lookup
* 5.0      SC-9001    06-09-2023  Richa@Maersk            Update related account and contact fields on insert and update of opl
* 6.0      SC-9148    26-09-2023  Richa@Maersk            Validate OPL on status update
* 7.0      SC-9234    12-10-2023  Richa@Maersk            Add Owner Manager field for Ocean Plus Leads
* 8.0      SC-9582    18-12-2023  Richa@Maersk            Show Booked By Customer and Contact information on OPL
* 9.0      SC-9662    29-01-2024  Nayana@Maersk           Populate Service relationship Booked By and Service relationship Contractual on OPL
*10.0	   SC-9845 	  05-03-2024  Nayana@Maersk			  Logic updated for Contractual to consider Bidirectional as first priority
*/
@isTest
public class OceanPlusLeadFieldPopulator_Test {
    
    @TestSetup
    static void setupTestData(){      
        TriggerExecutionController.skipAllTriggers(true);
        Geography__c countryDE = TestBusinessHelper.createGeography('Germany', 'Country', null,'DE',true);
        Geography__c countryUS = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);
        BDA__c parentBDA = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EU-Trade', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('North Europe Continent Area', 'Cluster', 'NEC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryDE.Id, null, true);       
        //Geography__c city = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);
        List<Account> accList = new List<Account>();
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', false);        
        accList.add(shipperAcc);
        Account consigneeAcc = TestBusinessHelper.createAccount('Client_Account', false);
        accList.add(consigneeAcc);
        Account contractualAcc = TestBusinessHelper.createAccount('Client_Account', false);
        accList.add(contractualAcc);
        Account contractualAcc2 = TestBusinessHelper.createAccount('Client_Account', false);
        accList.add(contractualAcc2);
        Account priceOwnerAcc = TestBusinessHelper.createAccount('Client_Account', false);
        accList.add(priceOwnerAcc);
        Account bookedByAcc = TestBusinessHelper.createAccount('Client_Account', false);
        accList.add(bookedByAcc);
        for(Account acc:accList){
            acc.id=null;
            acc.MSL_Account_Owner__c = UserInfo.getUserId();
        }
        insert accList;
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', true); 
        shp.Booked_By_Customer_SCV_Code__c = bookedByAcc.SCV_Code__c;
        update shp;
        List<Contact> conList = new List<Contact>();
        Contact shipperCon = TestBusinessHelper.createContact(shipperAcc,'Customer_Contact','Maersk Line', false);
        shipperCon.Email = 'shipper@xyz.com';
        shipperCon.FirstName = 'shipper';
        //update shipperCon;
        conList.add(shipperCon);
        Contact consigneeCon = TestBusinessHelper.createContact(consigneeAcc,'Customer_Contact','Maersk Line', false);
        consigneeCon.Email = 'consignee@xyz.com';
        consigneeCon.FirstName = 'consignee';
        //update consigneeCon;
        conList.add(consigneeCon);
        Contact contractualCon = TestBusinessHelper.createContact(contractualAcc,'Customer_Contact','Maersk Line', false);
        contractualCon.FirstName = 'contractual';
        contractualCon.Email = 'contractual@xyz.com';
        //update contractualCon;  y
        conList.add(contractualCon);
        Contact bookedByCon = TestBusinessHelper.createContact(bookedByAcc,'Customer_Contact','Maersk Line', false);
        bookedByCon.Email = 'booked@xyz.com';
        bookedByCon.FirstName = 'bookedBy';
        bookedByCon.External_ID__c = 'ConEx123';
        //update bookedByCon;
        conList.add(bookedByCon);
        for(Contact con:conList){
            con.id=null;
        }
        insert conList;
        List<Care_Relationship__c> careList = new List<Care_Relationship__c>();
        Care_Relationship__c shipperService =TestBusinessHelper.createServiceRelationship(shipperAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Export',false);
        careList.add(shipperService);
        Care_Relationship__c consigneeService =TestBusinessHelper.createServiceRelationship(consigneeAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import',false);
        careList.add(consigneeService);
        Care_Relationship__c bookedByService =TestBusinessHelper.createServiceRelationship(bookedByAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',false);
        careList.add(bookedByService);
        Care_Relationship__c contractualService =TestBusinessHelper.createServiceRelationship(contractualAcc.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Import/Export',false);
        careList.add(contractualService);
        Care_Relationship__c contractualService2 =TestBusinessHelper.createServiceRelationship(contractualAcc2.Id, countryDE.Id, BrandUtilities.MAERSKLINE,'Export',false);
        careList.add(contractualService2);
        for(Care_Relationship__c cr:careList){
            cr.id=null;
        }
        insert careList;
        bookedByAcc.SCV_Code__c = '1234';
        bookedByAcc.BillingCountry = 'Germany' ;
        bookedByAcc.BillingCity = 'abc';
        update bookedByAcc;
        contractualAcc.SCV_Code__c = '4567';
        contractualAcc.BillingCountry = 'Germany' ;
        contractualAcc.BillingCity = 'abc';
        update contractualAcc;
        contractualAcc2.SCV_Code__c = '896523';
        contractualAcc2.BillingCountry = 'Germany' ;
        contractualAcc2.BillingCity = 'def';
        update contractualAcc2;
        Party__c prty = TestBusinessHelper.createShipmentParty('224069341','ConEx123','1', true);
        TriggerExecutionController.skipAllTriggers(false);
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
        //Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069340','DE','DE','SEA',shipperAcc.SCV_Code__c,null,null,null,17, true);
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069342','DE','DE','MSL',shipperAcc.SCV_Code__c,null,null,null,17, true);
    }
    
   @isTest
    public static void testPopulateCountryAndSR() {  
        // to verify if Country/Area/Region and SR lookup on OPL populate/change according to Country Code and Direction on OPL
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Origin_Area__c,Origin_Region__c,Service_Relationship_Import__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Shipment__c != null);
        System.assert(opl.Origin_Country__c != null); 
        System.assert(opl.Origin_Area__c != null); 
        System.assert(opl.Origin_Region__c != null); 
        System.assert(opl.Service_Relationship_Import__c != null);
        System.assert(opl.Service_Relationship_Export__c != null);        
        opl.Origin_Country_Code__c = 'US';
        opl.CHB_IMP_Probability__c = null;
        opl.CHB_EXP_Probability__c = 90;
        update opl;     
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Origin_Area__c,Origin_Region__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Service_Relationship_Import__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Origin_Country__c != newOpl.Origin_Country__c);
        System.assert(opl.Origin_Area__c != newOpl.Origin_Area__c);
        System.assert(opl.Origin_Region__c != newOpl.Origin_Region__c);
        System.assert(opl.Service_Relationship_Export__c != newOpl.Service_Relationship_Export__c);
        Test.stopTest();
    }
    
  @isTest
    public static void testUpdateOnOPLAndSR() { 
        // to verify if SR lookup changes on OPL on update of SR record as well as OPL record
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Import__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c,Service_Relationship_Export__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        opl.Origin_Country_Code__c = 'US';
        opl.BKS_EXP_Probability__c = 90;        
        update opl;         
        List<Care_Relationship__c> lstCare = new List<Care_Relationship__c>();
        for(Care_Relationship__c care: [SELECT Id,Direction__c from Care_Relationship__c]){
            care.Status__c = 'False';
            lstCare.add(care);
        }
        update lstCare;       
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Service_Relationship_Import__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Export__c != newOpl.Service_Relationship_Export__c);
        Test.stopTest();
    }
    
     @isTest
    public static void testUpdateOnBrand() { 
        // to verify if SR lookup changes on OPL on update of Brand on OPL
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        opl.Brand__c = 'SEA';        
        update opl;  
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Service_Relationship_Export__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Service_Relationship_Export__c != newOpl.Service_Relationship_Export__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateProducts() { 
        // to verify if Ocean Plus Line Items get inserted/deleted automatically on change of Product on Ocean Plus Lead record
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Product__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli.size() == 2); // insert scenario
        opl.Products_Pitched__c ='Intermodal Import;Value Protect'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOpli1 = [SELECT Id,Product__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341' order by createddate asc];
        System.assert(lstOpli1[0].Product__c == 'Intermodal Import'); // update scenario
        System.assert(lstOpli1[1].Product__c == 'Value Protect');
        opl.Products_Pitched__c =null;
        opl.Status__c = 'New';
        update opl; 
        //Test.stopTest();
        List<Ocean_Plus_Line_Item__c> lstOpli2 = [SELECT Id,Product__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli2.size() == 0); // delete scenario       
        Test.stopTest();
    }
    
     @isTest
    public static void testUpdateAccountAndContact() { 
        // to verify if Account details are getting populated
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipper_SCV_Code__c,Consignee_SCV_Code__c,Contractual_SCV_Code__c,Price_Owner_SCV_Code__c,Consignee_Address__c,Shipper_Address__c,Consignee_Contact_Email__c,Shipper_Contact_Email__c,Contractual_Contact_Email__c,Consignee_Contact_Name__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Consignee_Address__c != null); // check if customer address got populated on insert 
        System.assert(opl.Shipper_Address__c != null); 
        System.assert(opl.Consignee_Contact_Name__c != null); // check if consignee contact name got populated on insert 
        opl.Shipper_SCV_Code__c = opl.Consignee_SCV_Code__c;
        opl.Consignee_SCV_Code__c = opl.Contractual_SCV_Code__c;
        opl.Contractual_SCV_Code__c = opl.Price_Owner_SCV_Code__c;
        opl.Price_Owner_SCV_Code__c = opl.Consignee_SCV_Code__c;
        opl.Shipper_Contact_Email__c = opl.Consignee_Contact_Email__c;
        opl.Consignee_Contact_Email__c = opl.Contractual_Contact_Email__c;       
        opl.Contractual_Contact_Email__c = opl.Shipper_Contact_Email__c;       
        update opl; 
        //Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id,Shipper_SCV_Code__c,Consignee_SCV_Code__c,Contractual_SCV_Code__c,Price_Owner_SCV_Code__c,Consignee_Address__c,Shipper_Address__c,Consignee_Contact_Name__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Consignee_Address__c != newOpl.Consignee_Address__c); // check if customer address got updated on scv change
        System.assert(opl.Shipper_Address__c != newOpl.Shipper_Address__c); 
        System.assert(opl.Consignee_Contact_Name__c != newOPL.Consignee_Contact_Name__c); // check if consignee contact name got updated on email change 
        Test.stopTest();
    }  
     @isTest
    public static void testUpdateAccountContactNullValues() { 
        // to verify if Account details are getting removed if SCV is null
         Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipper_SCV_Code__c,Consignee_SCV_Code__c,Contractual_SCV_Code__c,Price_Owner_SCV_Code__c,Consignee_Address__c,Shipper_Address__c,Consignee_Contact_Name__c,Consignee_MSL_Account_Owner__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(opl.Consignee_Address__c != null); // check if customer address got populated on insert 
        System.assert(opl.Shipper_Address__c != null); 
        System.assert(opl.Consignee_Contact_Name__c != null); // check if consignee contact name got populated on insert 
        opl.Shipper_SCV_Code__c = null;
        opl.Consignee_SCV_Code__c = null;
        opl.Contractual_SCV_Code__c = null;
        opl.Price_Owner_SCV_Code__c = null;
        opl.Consignee_Contact_Email__c = null;
        opl.Shipper_Contact_Email__c = null;
        opl.Contractual_Contact_Email__c = null;
        update opl; 
        //Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id,Shipper_SCV_Code__c,Consignee_SCV_Code__c,Contractual_SCV_Code__c,Price_Owner_SCV_Code__c,Consignee_Address__c,Shipper_Address__c,Consignee_Contact_Name__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        System.assert(newOpl.Consignee_Address__c == null); // check if customer address got removed on scv null
        System.assert(newOpl.Shipper_Address__c== null); 
        System.assert(newOpl.Consignee_Contact_Name__c == null); // check if consignee contact name got removed on email null 
        Test.stopTest();
    }
    
      @isTest
    public static void testUpdateOPLStatus() { 
        // to verify if Ocean Plus Lead Status matches that of child records
        Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Brand__c,Service_Relationship_Export__c, Shipment__c,Origin_Country_Code__c,Origin_Country__c,Destination_Country_Code__c,Destination_Country__c,Direction__c,CHB_IMP_Probability__c,BKS_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069341'];
        opl.Products_Pitched__c = 'Intermodal Import;CHB Import;CHB Export;Intermodal Export'; 
        update opl; 
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Product__c,Status__c,Reasons_for_In_progress__c,Reasons_for_Selling__c,Reasons_for_Not_Selling__c,Reasons_for_Lead_creation__c FROM Ocean_Plus_Line_Item__c WHERE Booking_Number__c= '224069341'];
        System.assert(lstOpli.size() == 4); 
        opl.Status__c ='Sold';
        try{
           update opl;
        } catch(Exception e){
            system.debug('Error is' +e.getMessage()); //catch trigger adderrror message
        }        
        Test.stopTest();
            
    }
    
    @isTest
    public static void testUpdateOPLOwner() { 
        // to verify if Ocean Plus Lead Owner Manager got updated
        Test.startTest();
        User usrMngr = TestBusinessHelper.createUser('System Administrator','Maersk Line',true);
        usrMngr.ManagerId = UserInfo.getUserId();
        TriggerExecutionController.skipAllTriggers(true);
        update usrMngr; 
        TriggerExecutionController.skipAllTriggers(false);
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        for(Ocean_Plus_Lead__c opl: [SELECT Id,Brand__c,OwnerId FROM Ocean_Plus_Lead__c]){
            opl.OwnerId = usrMngr.Id; 
            lstOPLUpdate.add(opl);
        }  
      
        update lstOPLUpdate;        
        List<Ocean_Plus_Lead__c> lstOPL = [SELECT Id,Brand__c,OwnerId,Owner_Manager__c FROM Ocean_Plus_Lead__c];
        System.assert(lstOPL[0].Owner_Manager__c != null);  // verify Owner manager got populated 
        usrMngr.ManagerId = null;
        update usrMngr; 
         List<Ocean_Plus_Lead__c> lstOPLUpdate1 = new List<Ocean_Plus_Lead__c>();       
        for(Ocean_Plus_Lead__c opl1: [SELECT Id,Brand__c,OwnerId FROM Ocean_Plus_Lead__c]){
            opl1.OwnerId = UserInfo.getUserId(); 
            lstOPLUpdate1.add(opl1);
        }           
        update lstOPLUpdate1;
         List<Ocean_Plus_Lead__c> lstOPLUpdate2 = new List<Ocean_Plus_Lead__c>();       
        for(Ocean_Plus_Lead__c opl2: [SELECT Id,Brand__c,OwnerId FROM Ocean_Plus_Lead__c]){
            opl2.OwnerId = usrMngr.Id; 
            lstOPLUpdate2.add(opl2);
        }           
        update lstOPLUpdate2;
        //Test.stopTest();
        List<Ocean_Plus_Lead__c> lstOPL1 = [SELECT Id,Brand__c,OwnerId,Owner_Manager__c FROM Ocean_Plus_Lead__c];
        System.assert(lstOPL1[0].Owner_Manager__c == null);  // verify Owner manager got removed 
        Test.stopTest();
            
    }
    
    @isTest
    public static void testOPLOnShipmentInsert() {  
        // to verify if OPL gets updated if Shipment gets Inserted       
       	Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Booked_By_SCV_Code__c,CHB_EXP_Probability__c FROM Ocean_Plus_Lead__c WHERE Booked_By_SCV_Code__c!= '1234' limit 1];
        Shipment__c shp = new Shipment__c();
        shp.Shipment_Number__c = '224069342';
        shp.Booked_By_Customer_SCV_Code__c = '1234';
        insert shp;
        //Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Booked_By_SCV_Code__c,BookedBy_Country__c,BookedBy_City__c,Service_Relationship_BookedBy__c FROM Ocean_Plus_Lead__c WHERE Booking_Number__c= '224069342'];
        System.assert(opl.Booked_By_SCV_Code__c != newOpl.Booked_By_SCV_Code__c);
        Assert.areNotEqual(newOpl.BookedBy_Country__c,null,'Bookedby country');
        Assert.areNotEqual(newOpl.BookedBy_City__c,null,'Bookedby city');
        Test.stopTest();
    }
    
    @isTest
    public static void testContractualScvCodeUpdate() {  
       	Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Contractual_SCV_Code__c,Service_Relationship_Contractual__c FROM Ocean_Plus_Lead__c WHERE Contractual_SCV_Code__c!= '1234' limit 1];
        opl.Contractual_SCV_Code__c = '1234';
        update opl;
        //Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Contractual_SCV_Code__c,Contractual_Country__c,Contractual_City__c,Service_Relationship_Contractual__c FROM Ocean_Plus_Lead__c WHERE Contractual_SCV_Code__c= '1234'];
        Assert.areNotEqual(newOpl.Service_Relationship_Contractual__c,null,'Contractual SR');
        System.assert(opl.Service_Relationship_Contractual__c != newOpl.Service_Relationship_Contractual__c);
        Assert.areNotEqual(newOpl.Contractual_Country__c,null,'Contractual country');
        Assert.areNotEqual(newOpl.Contractual_City__c,null,'Contractual city');
        Test.stopTest();
    }
    
    @isTest
    public static void testContractualScvCodeUpdate2() {  
       	Test.startTest();
        Ocean_Plus_Lead__c opl = [SELECT Id,Shipment__c,Contractual_SCV_Code__c,Service_Relationship_Contractual__c FROM Ocean_Plus_Lead__c WHERE Contractual_SCV_Code__c!= '896523' limit 1];
        opl.Contractual_SCV_Code__c = '896523';
        update opl;
        //Test.stopTest();
        Ocean_Plus_Lead__c newOpl = [SELECT Id, Shipment__c,Contractual_SCV_Code__c,Contractual_Country__c,Contractual_City__c,Service_Relationship_Contractual__c FROM Ocean_Plus_Lead__c WHERE Contractual_SCV_Code__c= '896523'];
        Assert.areNotEqual(newOpl.Service_Relationship_Contractual__c,null,'Contractual SR');
        System.assert(opl.Service_Relationship_Contractual__c != newOpl.Service_Relationship_Contractual__c);
        Assert.areNotEqual(newOpl.Contractual_Country__c,null,'Contractual country');
        Assert.areNotEqual(newOpl.Contractual_City__c,null,'Contractual city');
        Test.stopTest();
    }
}