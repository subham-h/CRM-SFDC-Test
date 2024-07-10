/*
* Author   : Richa 
* Purpose  : Test class for BatchOPLCompletionAggregateCalculator
*
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-9742    12/06/2024    Richa@Maersk      Test the batch class which completes OPL Aggregate records
*/
@isTest
public class BatchOPLCompletionAggCalculator_Test {
    @TestSetup
    static void setupTestData(){ 
        Geography__c countryUS = TestBusinessHelper.createGeography('United States', 'Country', null,'US',true);       
        Geography__c countryDE = TestBusinessHelper.createGeography('Germany', 'Country', null,'DE',true);       
        BDA__c parentBDA = TestBusinessHelper.createBDA('Europe Region', 'Trade Region', 'EU-Trade', null, UserInfo.getUserId(), true);
        BDA__c childBDA = TestBusinessHelper.createBDA('North Europe Continent Area', 'Cluster', 'NEC', parentBDA, UserInfo.getUserId(), true);
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, countryDE.Id, null, true);
        TriggerExecutionController.skipAllTriggers(true); 
        Shipment__c shp = TestBusinessHelper.createShipment('224069341', true); 
        Account shipperAcc = TestBusinessHelper.createAccount('Client_Account', true);
        shipperAcc.Account_Address_Area__c = childBDA.Id;
        update shipperAcc;
        Account consigneeAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account contractualAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Account priceOwnerAcc = TestBusinessHelper.createAccount('Client_Account', true);
        Contact shipperCon = TestBusinessHelper.createContact(shipperAcc,'Customer_Contact','Maersk Line', true);
        shipperCon.Email = 'shipper@xyz.com';
        shipperCon.FirstName = 'shipper';
        update shipperCon;
        
        Lead lead = TestBusinessHelper.createLead(BrandUtilities.MAERSKLINE, true);
        lead.Comments_for_Lead_source__c = 'CX';
        lead.Country_Ownership_Cluster__c = childBDA.Id;
        lead.OwnerId = Label.CrossSellInterface;
        update lead;
        Test.setCreatedDate(lead.Id, Datetime.now().addDays(-1));
        Opportunity opportunity = TestBusinessHelper.createOpportunity(shipperAcc, shipperCon, null, 'ShippingCargoServices', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
        opportunity.Cargo_Type__c = 'Dry';
        opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
        opportunity.Tender_Submission_Format__c = 'No Ocean Tender';
        update opportunity;
        
        Product2 product = TestBusinessHelper.createProduct('Ocean', true);  
        product.OIPC_Code__c='12345';
        product.Portfolio__c='Ocean';
        product.Version__c=1;
        product.IsActive=true;
        product.Product_Status__c='Ready-to-sell';
        product.Latest_Product_Version__c=null;
        update product;
        Geography__c city = TestBusinessHelper.createGeography('Copenhagen', 'City', countryDE.Id, true);
        Opportunity_Product__c opptyProd = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.Id, null, countryDE, city, true);
        TriggerExecutionController.skipAllTriggers(false);   
        Ocean_Plus_Lead__c opl1 = TestBusinessHelper.createOceanPlusLead('224069341','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,priceOwnerAcc.SCV_Code__c,80, true);
        Ocean_Plus_Lead__c opl2 = TestBusinessHelper.createOceanPlusLead('224069342','DE','US','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,contractualAcc.SCV_Code__c,null,50, true);
        Ocean_Plus_Lead__c opl3 = TestBusinessHelper.createOceanPlusLead('224069343','DE','DE','MSL',shipperAcc.SCV_Code__c,consigneeAcc.SCV_Code__c,null,priceOwnerAcc.SCV_Code__c,80, true);
        Test.setCreatedDate(opl2.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(opl3.Id, Datetime.now().addDays(-2));
         
       	BatchOPLCreationAggregateCalculator btch = new BatchOPLCreationAggregateCalculator(System.today()-5,System.today()+1,null);
		Database.executeBatch(btch); 
    }
    @isTest
    public static void completeAggregateRecords() { 
        List<Ocean_Plus_Lead__c> lstOPLUpdate = new List<Ocean_Plus_Lead__c>();
        Datetime testingday = Datetime.now().addDays(-3);
       
        User agnt = TestBusinessHelper.createUser(ProfileUtilities.X101_CustomerServiceSalesPilot, BrandUtilities.MAERSKLINE, true);
        System.runAs(new User(Id = UserInfo.getUserId())){
            agnt.FederationIdentifier='testmsluser@maersk.com';
            agnt.Cluster__c='North America Area';
            agnt.Country='United States';
            agnt.Region__c='North America Region';
            agnt.IsActive=true;
       		update agnt;  
        }
       
        for(Ocean_Plus_Lead__c opl:[SELECT Id,Status__c,OwnerId,createddate FROM Ocean_Plus_Lead__c]){
            opl.OwnerId = agnt.Id;
            opl.Products_Pitched__c = 'Intermodal Import;Intermodal Export'; 
            lstOPLUpdate.add(opl);
        }	
        update lstOPLUpdate;
        System.assert(lstOPLUpdate.size() == 3,'OPL size');
        List<Ocean_Plus_Line_Item__c> lstOPLIUpdate = new List<Ocean_Plus_Line_Item__c>();
        List<Ocean_Plus_Line_Item__c> lstOpli = [SELECT Id,Status__c,Owner__c,Product__c,Reasons_for_Selling__c FROM Ocean_Plus_Line_Item__c];
        
        for(Ocean_Plus_Line_Item__c opli: lstOpli){
            opli.Owner__c = agnt.Id;
            if(opli.Product__c == 'Intermodal Import'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
            }
            if(opli.Product__c == 'Intermodal Export'){
                opli.Status__c = 'Sold';
                opli.Reasons_for_Selling__c = 'Interested as a test';
            }
            lstOPLIUpdate.add(opli);
        }
        update lstOPLIUpdate;       
        
        Test.startTest();
        Lead ld = [Select Id from Lead LIMIT 1];
        Opportunity parentOppty = [SELECT Id,StageName,CloseDate,Lead_Id__c,Comments_for_Lead_source__c from Opportunity WHERE NAME='ShippingCargoServices' LIMIT 1];
        parentOppty.StageName = 'Closed Won';    
        parentOppty.Lead_Id__c =ld.Id;
        parentOppty.Comments_for_Lead_source__c ='CX';
        update parentOppty;
        BatchOPLCompletionAggregateCalculator myBatch = new BatchOPLCompletionAggregateCalculator(System.today()-5,System.today()+1,null);
        Database.executeBatch(myBatch); 
        Test.stopTest();
    }
    
    
}