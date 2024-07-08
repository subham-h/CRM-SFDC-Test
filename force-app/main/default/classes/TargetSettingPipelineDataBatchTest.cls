/*
* Author    : Arpitha J
* Description   : Test class for TargetSettingPipelineDataBatch
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                   17-07-23    Arpitha@maersk           Created. 
* 2.0                   09-02-2023  Arpitha@maersk           Added logic to cover TargetSettingPipelineDataSchedule class
* 
*/
@isTest
Public class TargetSettingPipelineDataBatchTest{
    
    
    static testmethod void dataSetup() {
        test.starttest();
         String currYear = String.valueof(Date.today().year());
         Database.BatchableContext bc;
         List<Target_Item__c>targetList = new List<Target_Item__c>();  
         List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
         Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
         5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
         Integer currMonth = Date.today().month();
        
        
         Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
         Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
         
         
         Geography__c testCountry = new Geography__c();
         testCountry.Name = 'India';
         testCountry.Active__c =true;
         testCountry.GEO_Code__c = 'IN';
         testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
         testCountry.Is_Port__c = false;
         testCountry.Type_Of_Location__c = 'Country';
         insert testCountry;
         
         BDA__c testCluster = new BDA__C ();
         testCluster.Name = 'West Africa Area';
         testCluster.Type__c = 'Cluster';
         testCluster.BDA_Code__c = 'WAF';
         testCluster.GEO_ID__c= 'dsaewetwer';
         testCluster.Active__c  =  true;
         insert testCluster;
         
         BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
         bdaGeo.BDA__c = testCluster.Id;
         bdaGeo.Geography__c = country.Id;
         insert bdaGeo;
         TriggerExecutionController.skipAllTriggers(true);
         User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         Account accRec = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', true);
         
         Target__c tar = TestBusinessHelper.createSalesTarget(maerskLineUser,'2024','USD','Monthly',true);
         
         
         Contact contact = TestBusinessHelper.createContact(accRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         
         Opportunity opportunity = TestBusinessHelper.createOpportunity(accRec, contact, null, 'ShippingCargoServices','Maersk Line', true);
         system.debug('==opportunity=='+opportunity);
         opportunity.Liner_Brand__c = 'Maersk Line';
         opportunity.StageName ='Identifying';
         opportunity.CloseDate = system.today();
         opportunity.First_Shipment_Date__c=system.today()+1;
         opportunity.Last_Shipment_Date__c=system.today()+30;
         opportunity.Cargo_Type__c = 'Dry';
         opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
         opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
         TriggerExecutionController.skipAllTriggers(true);
         update opportunity;
         
         TriggerExecutionController.skipAllTriggers(true);  
         Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
         product.Portfolio__c='LnS';
         product.Family = 'Air & LCL'; 
         product.OIPC_Code__c='12345';
         product.Version__c=1;
         product.IsActive=true;
         product.Product_Status__c='Ready-to-sell';
         update product;
         
         Legacy_Product_Mapping__c lpm  = TestBusinessHelper.createSalesTargetProductMapping('4PL PF',product,true);
         
         Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c();
         tbm.Salesforce_Brand__c ='Maersk Line';
         tbm.BrandMnA__c = 'Maersk Line';
         insert tbm;
         
         Map<Id,Product2>prodMap = new Map<Id,Product2>([Select id,Family from product2 where IsActive = True]);
         Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
         
         TriggerExecutionController.skipAllTriggers(true);
         //Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.id, null, testCountry, state, true);
         //system.debug('==Oli1='+Oli1);
         //insert opptyprod;
         
         TriggerExecutionController.skipAllTriggers(true);
         Opportunity_Product__c opptyprod = new Opportunity_Product__c(
         OpportunityId__c = opportunity.id,
         Quantity__c = 1,
         Product2ID__c= product.id, 
         UnitPrice__c = 1,
         Opt_Out_Auto_Quantity_Scheduling__c = false,
         Tender_Target__c = 1,
         Nominated_Quantity__c = 1,
         Country__c = testCountry.id,
         Product_Revenue_Per_Unit__c = 1
         );
         insert opptyprod;
        
         Opportunity_Product_Schedule__c ops = new Opportunity_Product_Schedule__c();
         ops.Opportunity_Product__c=opptyprod.Id;
         ops.Schedule_Date__c=system.today();
         ops.Quantity__c=100;
         ops.Revenue__c=100;
         insert ops;
         
         Integer monthData = (Date.today().month())+1;
         
         Opportunity_Product_Schedule__c ops1 = new Opportunity_Product_Schedule__c();
         ops1.Opportunity_Product__c=opptyprod.Id;
         ops1.Schedule_Date__c=Date.newInstance(Date.today().year(),monthData, Date.today().Day());
         ops1.Quantity__c=100;
         ops1.Revenue__c=100;
         insert ops1;
        
        
         system.debug('==opptyprod=='+opptyprod);
         Target_Item_Group__c tig = new Target_Item_Group__c();
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=country.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         targetList = [select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Id=:tItem.id];
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         targetMeasureInsertList.add(measureRecGP);
                        
                        
        /*Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=tItem.id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
            measureRecVol.put(mapMonth.get(currMonth),10000);
        }
        targetMeasureInsertList.add(measureRecVol);*/
         
         insert targetMeasureInsertList;
         
         TargetSettingPipelineDataBatch bClass = new TargetSettingPipelineDataBatch(tar.Id);
         bClass.start(bc);
         bClass.execute(bc,targetList);
         //bClass.finish(bc);
         test.stoptest();
        }
        
        static testmethod void dataSetup1() {
             test.starttest();
         String currYear = String.valueof(Date.today().year());
         Database.BatchableContext bc;
         List<Target_Item__c>targetList = new List<Target_Item__c>();  
         List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
         Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
         5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
         Integer currMonth = Date.today().month();
        
        
         Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
         Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
         
        
        Geography__c testCountry = new Geography__c();
         testCountry.Name = 'India';
         testCountry.Active__c =true;
         testCountry.GEO_Code__c = 'IN';
         testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
         testCountry.Is_Port__c = false;
         testCountry.Type_Of_Location__c = 'Country';
         insert testCountry;
         
         BDA__c testCluster = new BDA__C ();
         testCluster.Name = 'West Africa Area';
         testCluster.Type__c = 'Cluster';
         testCluster.BDA_Code__c = 'WAF';
         testCluster.GEO_ID__c= 'dsaewetwer';
         testCluster.Active__c  =  true;
         insert testCluster;
         
         BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
         bdaGeo.BDA__c = testCluster.Id;
         bdaGeo.Geography__c = country.Id;
         insert bdaGeo;
         TriggerExecutionController.skipAllTriggers(true);
         User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         Account accRec = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', true);
        
         Target__c tar = TestBusinessHelper.createSalesTarget(maerskLineUser,'2024','USD','Monthly',true);
         
         
         Contact contact = TestBusinessHelper.createContact(accRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         
         Opportunity opportunity = TestBusinessHelper.createOpportunity(accRec, contact, null, 'ShippingCargoServices','Maersk Line', true);
         system.debug('==opportunity=='+opportunity);
         
         Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
         product.Portfolio__c='LnS';
         product.Family = 'Air & LCL'; 
         product.OIPC_Code__c='12345';
         product.Version__c=1;
         product.IsActive=true;
         product.Product_Status__c='Ready-to-sell';
         update product;
         
         Legacy_Product_Mapping__c lpm  = TestBusinessHelper.createSalesTargetProductMapping('4PL PF',product,true);
         
         Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c();
         tbm.Salesforce_Brand__c ='Maersk Line';
         tbm.BrandMnA__c = 'Maersk Line';
         insert tbm;
         
         Map<Id,Product2>prodMap = new Map<Id,Product2>([Select id,Family from product2 where IsActive = True]);
         Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
         
         TriggerExecutionController.skipAllTriggers(true);
         //Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.id, null, testCountry, state, true);
         //system.debug('==Oli1='+Oli1);
         //insert opptyprod;
         
         TriggerExecutionController.skipAllTriggers(true);
         Opportunity_Product__c opptyprod = new Opportunity_Product__c(
         OpportunityId__c = opportunity.id,
         Quantity__c = 1,
         Product2ID__c= product.id, 
         UnitPrice__c = 1,
         Opt_Out_Auto_Quantity_Scheduling__c = false,
         Tender_Target__c = 1,
         Nominated_Quantity__c = 1,
         Country__c = testCountry.id,
         Product_Revenue_Per_Unit__c =1
         );
         insert opptyprod;
         
         Integer monthData = (Date.today().month())+1;
         
         Opportunity_Product_Schedule__c ops = new Opportunity_Product_Schedule__c();
         ops.Opportunity_Product__c=opptyprod.Id;
         ops.Schedule_Date__c=system.today();
         ops.Quantity__c=100;
         ops.Revenue__c=100;
         insert ops;
         
         Opportunity_Product_Schedule__c ops1 = new Opportunity_Product_Schedule__c();
         ops1.Opportunity_Product__c=opptyprod.Id;
         ops1.Schedule_Date__c=Date.newInstance(Date.today().year(),monthData, Date.today().Day());
         ops1.Quantity__c=100;
         ops1.Revenue__c=100;
         insert ops1;
         
         
         
         opportunity.Liner_Brand__c = 'Maersk Line';
         opportunity.StageName ='Closed Won';
         opportunity.CloseDate = system.today();
         opportunity.First_Shipment_Date__c=system.today()+1;
         opportunity.Last_Shipment_Date__c=system.today()+30;
         opportunity.Cargo_Type__c = 'Dry';
         opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
         opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
         TriggerExecutionController.skipAllTriggers(true);
         update opportunity;
         
         TriggerExecutionController.skipAllTriggers(true);  
        
        
         system.debug('==opptyprod=='+opptyprod);
         Target_Item_Group__c tig = new Target_Item_Group__c();
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=country.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
        
         insert tItem;
         
         targetList = [select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Id=:tItem.id];
         
         /*Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         targetMeasureInsertList.add(measureRecGP);*/
                        
                        
        Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=tItem.id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
            measureRecVol.put(mapMonth.get(currMonth),10000);
        }
        targetMeasureInsertList.add(measureRecVol);
         
         insert targetMeasureInsertList;
         
         TargetSettingPipelineDataBatch bClass = new TargetSettingPipelineDataBatch(tar.Id);
         bClass.start(bc);
         bClass.execute(bc,targetList);
         //bClass.finish(bc);
         test.stoptest();
        }
         
        static testmethod void dataSetup2() {
        test.starttest();
         String currYear = String.valueof(Date.today().year());
         Database.BatchableContext bc;
         List<Target_Item__c>targetList = new List<Target_Item__c>();  
         List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
         Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
         5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
         Integer currMonth = Date.today().month();
        
        
         Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
         Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
         
         
         Geography__c testCountry = new Geography__c();
         testCountry.Name = 'India';
         testCountry.Active__c =true;
         testCountry.GEO_Code__c = 'IN';
         testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
         testCountry.Is_Port__c = false;
         testCountry.Type_Of_Location__c = 'Country';
         insert testCountry;
         
         BDA__c testCluster = new BDA__C ();
         testCluster.Name = 'West Africa Area';
         testCluster.Type__c = 'Cluster';
         testCluster.BDA_Code__c = 'WAF';
         testCluster.GEO_ID__c= 'dsaewetwer';
         testCluster.Active__c  =  true;
         insert testCluster;
         
         BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
         bdaGeo.BDA__c = testCluster.Id;
         bdaGeo.Geography__c = country.Id;
         insert bdaGeo;
         TriggerExecutionController.skipAllTriggers(true);
         User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         Account accRec = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', true);
         
         Target__c tar = TestBusinessHelper.createSalesTarget(maerskLineUser,'2024','USD','Monthly',true);
         
         
         Contact contact = TestBusinessHelper.createContact(accRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         
         Opportunity opportunity = TestBusinessHelper.createOpportunity(accRec, contact, null, 'ShippingCargoServices','Maersk Line', true);
         system.debug('==opportunity=='+opportunity);
         opportunity.Liner_Brand__c = 'Maersk Line';
         opportunity.StageName ='Identifying';
         opportunity.CloseDate = system.today();
         opportunity.First_Shipment_Date__c=system.today()+1;
         opportunity.Last_Shipment_Date__c=system.today()+30;
         opportunity.Cargo_Type__c = 'Dry';
         opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
         opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
         TriggerExecutionController.skipAllTriggers(true);
         update opportunity;
         
         TriggerExecutionController.skipAllTriggers(true);  
         Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
         product.Portfolio__c='LnS';
         product.Family = 'Air & LCL'; 
         product.OIPC_Code__c='12345';
         product.Version__c=1;
         product.IsActive=true;
         product.Product_Status__c='Ready-to-sell';
         update product;
         
         Legacy_Product_Mapping__c lpm  = TestBusinessHelper.createSalesTargetProductMapping('4PL PF',product,true);
         
         Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c();
         tbm.Salesforce_Brand__c ='Maersk Line';
         tbm.BrandMnA__c = 'Maersk Line';
         insert tbm;
         
         Map<Id,Product2>prodMap = new Map<Id,Product2>([Select id,Family from product2 where IsActive = True]);
         Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
         
         TriggerExecutionController.skipAllTriggers(true);
         //Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.id, null, testCountry, state, true);
         //system.debug('==Oli1='+Oli1);
         //insert opptyprod;
         
         TriggerExecutionController.skipAllTriggers(true);
         Opportunity_Product__c opptyprod = new Opportunity_Product__c(
         OpportunityId__c = opportunity.id,
         Quantity__c = 1,
         Product2ID__c= product.id, 
         UnitPrice__c = 1,
         Opt_Out_Auto_Quantity_Scheduling__c = false,
         Tender_Target__c = 1,
         Nominated_Quantity__c = 1,
         Country__c = testCountry.id,
         Product_Revenue_Per_Unit__c = 1
         );
         insert opptyprod; 
         
         Opportunity_Product_Schedule__c ops = new Opportunity_Product_Schedule__c();
         ops.Opportunity_Product__c=opptyprod.Id;
         ops.Schedule_Date__c=system.today();
         ops.Quantity__c=100;
         ops.Revenue__c=100;
         insert ops;
         
         Integer monthData = (Date.today().month())+1;
         
         Opportunity_Product_Schedule__c ops1 = new Opportunity_Product_Schedule__c();
         ops1.Opportunity_Product__c=opptyprod.Id;
         ops1.Schedule_Date__c=Date.newInstance(Date.today().year(),monthData, Date.today().Day());
         ops1.Quantity__c=100;
         ops1.Revenue__c=100;
         insert ops1;
        
        
         system.debug('==opptyprod=='+opptyprod);
         Target_Item_Group__c tig = new Target_Item_Group__c();
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=country.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         targetList = [select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Id=:tItem.id];
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         targetMeasureInsertList.add(measureRecGP);
                        
                        
        /*Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=tItem.id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
            measureRecVol.put(mapMonth.get(currMonth),10000);
        }
        targetMeasureInsertList.add(measureRecVol);*/
         
         insert targetMeasureInsertList;
         
         TargetSettingPipelineDataBatch bClass = new TargetSettingPipelineDataBatch(tar.Id);
         bClass.start(bc);
         bClass.execute(bc,targetList);
         //bClass.finish(bc);
         test.stoptest();
        }
        
        static testmethod void dataSetup4() {
             test.starttest();
         String currYear = String.valueof(Date.today().year());
         Database.BatchableContext bc;
         List<Target_Item__c>targetList = new List<Target_Item__c>();  
         List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
         Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
         5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
         Integer currMonth = Date.today().month();
        
        
         Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null, true);
         Geography__c state = TestBusinessHelper.createGeography('Karnataka', 'State', country.Id, true);
         
         
         Geography__c testCountry = new Geography__c();
         testCountry.Name = 'India';
         testCountry.Active__c =true;
         testCountry.GEO_Code__c = 'IN';
         testCountry.GEO_ID__c = '10Z2W9Zkjh3q4cf6';
         testCountry.Is_Port__c = false;
         testCountry.Type_Of_Location__c = 'Country';
         insert testCountry;
         
         BDA__c testCluster = new BDA__C ();
         testCluster.Name = 'West Africa Area';
         testCluster.Type__c = 'Cluster';
         testCluster.BDA_Code__c = 'WAF';
         testCluster.GEO_ID__c= 'dsaewetwer';
         testCluster.Active__c  =  true;
         insert testCluster;
         
         BDA_Geography__c bdaGeo = new BDA_Geography__c(); 
         bdaGeo.BDA__c = testCluster.Id;
         bdaGeo.Geography__c = country.Id;
         insert bdaGeo;
         TriggerExecutionController.skipAllTriggers(true);
         User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         Account accRec = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', true);
         
         Target__c tar = TestBusinessHelper.createSalesTarget(maerskLineUser,'2024','USD','Monthly',true);
         
         
         Contact contact = TestBusinessHelper.createContact(accRec, 'Customer_Contact', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);

         
         Opportunity opportunity = TestBusinessHelper.createOpportunity(accRec, contact, null, 'ShippingCargoServices','Maersk Line', true);
         system.debug('==opportunity=='+opportunity);
         
         Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
         product.Portfolio__c='LnS';
         product.Family = 'Air & LCL'; 
         product.OIPC_Code__c='12345';
         product.Version__c=1;
         product.IsActive=true;
         product.Product_Status__c='Ready-to-sell';
         update product;
         
         Legacy_Product_Mapping__c lpm  = TestBusinessHelper.createSalesTargetProductMapping('4PL PF',product,true);
         
         Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c();
         tbm.Salesforce_Brand__c ='Maersk Line';
         tbm.BrandMnA__c = 'Maersk Line';
         insert tbm;
         
         Map<Id,Product2>prodMap = new Map<Id,Product2>([Select id,Family from product2 where IsActive = True]);
         Map<String,Legacy_Product_Mapping__c>legacyProdMapping = new Map<String,Legacy_Product_Mapping__c>();
         
         TriggerExecutionController.skipAllTriggers(true);
         //Opportunity_Product__c Oli1 = TestBusinessHelper.createOpportunityLineItemCustom(opportunity, product.id, null, testCountry, state, true);
         //system.debug('==Oli1='+Oli1);
         //insert opptyprod;
         
         TriggerExecutionController.skipAllTriggers(true);
         Opportunity_Product__c opptyprod = new Opportunity_Product__c(
         OpportunityId__c = opportunity.id,
         Quantity__c = 1,
         Product2ID__c= product.id, 
         UnitPrice__c = 1,
         Opt_Out_Auto_Quantity_Scheduling__c = false,
         Tender_Target__c = 1,
         Nominated_Quantity__c = 1,
         Country__c = testCountry.id,
         Product_Revenue_Per_Unit__c = 1
         );
         insert opptyprod; 
         
         Opportunity_Product_Schedule__c ops = new Opportunity_Product_Schedule__c();
         ops.Opportunity_Product__c=opptyprod.Id;
         ops.Schedule_Date__c=system.today();
         ops.Quantity__c=100;
         ops.Revenue__c=100;
         insert ops;
         
         
         Integer monthData = (Date.today().month())+1;
         
         Opportunity_Product_Schedule__c ops1 = new Opportunity_Product_Schedule__c();
         ops1.Opportunity_Product__c=opptyprod.Id;
         ops1.Schedule_Date__c=Date.newInstance(Date.today().year(),monthData, Date.today().Day());
         ops1.Quantity__c=100;
         ops1.Revenue__c=100;
         insert ops1;
         
         opportunity.Liner_Brand__c = 'Maersk Line';
         opportunity.StageName ='Closed Won';
         opportunity.CloseDate = system.today();
         opportunity.First_Shipment_Date__c=system.today()+1;
         opportunity.Last_Shipment_Date__c=system.today()+30;
         opportunity.Cargo_Type__c = 'Dry';
         opportunity.OwnerId = maerskLineUser.Id; //creating oppty owner
         opportunity.Offer_Type__c = 'Offer containing Standard T&Cs';
         TriggerExecutionController.skipAllTriggers(true);
         update opportunity;
         
         TriggerExecutionController.skipAllTriggers(true);  
        
        
         system.debug('==opptyprod=='+opptyprod);
         Target_Item_Group__c tig = new Target_Item_Group__c();
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=country.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         targetList = [select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Id=:tItem.id];
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         targetMeasureInsertList.add(measureRecGP);
                        
                        
        /*Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=tItem.id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
            measureRecVol.put(mapMonth.get(currMonth),10000);
        }
        targetMeasureInsertList.add(measureRecVol);*/
         
         insert targetMeasureInsertList;
         
         TargetSettingPipelineDataBatch bClass = new TargetSettingPipelineDataBatch(tar.Id);
         bClass.start(bc);
         bClass.execute(bc,targetList);
         //bClass.finish(bc);
         SchedulableContext sc;
         TargetSettingPipelineDataSchedule sch = new TargetSettingPipelineDataSchedule();
         sch.execute(sc); 
         test.stoptest();
        }
}