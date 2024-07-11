/*
* Author    : Arpitha J
* Description   : Test class for TargetSettingBaseDataBatch,TargetSettingBatchHelper
*       : 
*        
* Revision  Ref Number  Date        Owner                   Description
* --------  ----------  ----------- -------------------     -----------
* 1.0                       Arpitha@maersk           Created. 
* 2.0					29/12/23		Samar@maersk		test class fix
* 
*/
@isTest
Public class TargetSettingBaseDataBatchTest{
    static testmethod void dataSetup1() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
    bdaGeo.Geography__c = testCountry.Id;
    insert bdaGeo;
    
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    maerskLineUser.email = 'test@maersk.com';
    update maerskLineUser;
         
    Target__c tar = new Target__c();
    tar.OwnerId = maerskLineUser.Id;
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
    insert tar;
    system.debug('==tar=='+tar);
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         

    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.RecordTypeId = recordTypeId;
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Budget';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'BUDGET';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'BUDGET','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    TargetSettingBatchHelper.legacyProdMappingMethod();
    TargetSettingBatchHelper.targetBrandMappingMethod();
    TargetSettingBatchHelper.applyGrowthPercentage(1.0,1.0,1.0);
    TargetSettingConstants conClass = new TargetSettingConstants(); 
    SchedulableContext sc;
    TargetSettingBaseDataBatchSchedule sch = new TargetSettingBaseDataBatchSchedule(tar.Id,'BUDGET','1692355538','New');
    sch.execute(sc); 
    }
    
    static testmethod void dataSetup2() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    set<Id>setTargetItemId = new set<Id>();
    Database.BatchableContext bc;
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
         
          User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Rolling Forecast';
    stag.RoFo_Version__c = 'ROFOQ22023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
     Budget_Group__c bg = new Budget_Group__c();
    bg.Target__c = tar.Id;
    bg.Brand__c = 'Maersk Line';
    bg.Country_Code__c = 'IN';
    bg.Product_Family__c = '4PL PF';
    bg.Executing_Country__c = testCountry.id;
    insert bg;
    
    Budget_Measure__c bMeasureInsertRecord = new   Budget_Measure__c();
        
        if(bg.Id!=null){
            bMeasureInsertRecord.Budget_Group__c = bg.Id;
        }
        bMeasureInsertRecord.Measure_Dimension__c = stagList[0].Measure_Dimension__c;
        bMeasureInsertRecord.Measure_Type__c = stagList[0].Measure_Type__c;
        bMeasureInsertRecord.Jan__c= stagList[0].Jan__c;    
        bMeasureInsertRecord.Feb__c = stagList[0].Feb__c;
        bMeasureInsertRecord.Mar__c = stagList[0].Mar__c;
        bMeasureInsertRecord.Apr__c = stagList[0].Apr__c;
        bMeasureInsertRecord.May__c = stagList[0].May__c;
        bMeasureInsertRecord.Jun__c = stagList[0].Jun__c;
        bMeasureInsertRecord.Jul__c = stagList[0].Jul__c;
        bMeasureInsertRecord.Aug__c = stagList[0].Aug__c;
        bMeasureInsertRecord.Sep__c = stagList[0].Sep__c;
        bMeasureInsertRecord.Oct__c = stagList[0].Oct__c;
        bMeasureInsertRecord.Nov__c = stagList[0].Nov__c;
        bMeasureInsertRecord.Dec__c = stagList[0].Dec__c;
        insert bMeasureInsertRecord;
        
        Target_Item_Group__c tig = new Target_Item_Group__c();
     //tig.Staging_Reference__c = stagList[0].id;
     tig.BrandMnA__c='Hamburg Sud';
     tig.Product_Family__c = '4PL PF';
     tig.Target__c=tar.id;
     tig.Country_Code__c='IN';
     tig.Executing_Area__c=testCluster.id;
     tig.Executing_Country__c=testCountry.id;
     insert tig;
     
     Target_Item__c tItem = new Target_Item__c();
     tItem.Account__c = accRec.id;
     tItem.Sales_Target_Item_Group__c=tig.id;
         
     insert tItem;
     setTargetItemId.add(tItem.Id);
    
    Target_Measure__c measureRecGP = new Target_Measure__c();
      measureRecGP.Target_Item__c=tItem.id;
      measureRecGP.Measure_Type__c='Gross Profit';
      measureRecGP.Measure_Dimension__c='Pipeline';
      measureRecGP.Jan__c= stagList[0].Jan__c;    
      measureRecGP.Feb__c = stagList[0].Feb__c;
      measureRecGP.Mar__c = stagList[0].Mar__c;
      measureRecGP.Apr__c = stagList[0].Apr__c;
      measureRecGP.May__c = stagList[0].May__c;
      measureRecGP.Jun__c = stagList[0].Jun__c;
      measureRecGP.Jul__c = stagList[0].Jul__c;
      measureRecGP.Aug__c = stagList[0].Aug__c;
      measureRecGP.Sep__c = stagList[0].Sep__c;
      measureRecGP.Oct__c = stagList[0].Oct__c;
      measureRecGP.Nov__c = stagList[0].Nov__c;
      measureRecGP.Dec__c = stagList[0].Dec__c;
      insert measureRecGP;
                        
                        
        Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=tItem.id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        measureRecVol.Jan__c= stagList[0].Jan__c;    
        measureRecVol.Feb__c = stagList[0].Feb__c;
        measureRecVol.Mar__c = stagList[0].Mar__c;
        measureRecVol.Apr__c = stagList[0].Apr__c;
        measureRecVol.May__c = stagList[0].May__c;
        measureRecVol.Jul__c = stagList[0].Jul__c;
        measureRecVol.Aug__c = stagList[0].Aug__c;
        measureRecVol.Sep__c = stagList[0].Sep__c;
        measureRecVol.Oct__c = stagList[0].Oct__c;
        measureRecVol.Nov__c = stagList[0].Nov__c;
        measureRecVol.Dec__c = stagList[0].Dec__c;
        
        insert measureRecVol;
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'ROFO';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'ROFO','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    TargetSettingBatchHelper.calculateTargetFromBudgetGrowthPercent(bMeasureInsertRecord,measureRecGP,measureRecVol);
    TargetSettingBatchHelper.getTargetByPyId(setTargetItemId,'Gross Profit');
    }
    
    static testmethod void dataSetup3() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
   
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup4() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Previous Year Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'PY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'PY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    static testmethod void dataSetup5() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Budget';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    Budget_Group__c bg = new Budget_Group__c();
    bg.Target__c = tar.Id;
    bg.Brand__c = 'Maersk Line';
    bg.Country_Code__c = 'IN';
    bg.Product_Family__c = '4PL PF';
    bg.Executing_Country__c = testCountry.id;
    insert bg;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'BUDGET';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'BUDGET','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    static testmethod void dataSetup6() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Budget';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'BUDGET';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'BUDGET','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    static testmethod void dataSetup7() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Budget';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    Budget_Group__c bg = new Budget_Group__c();
    bg.Target__c = tar.Id;
    bg.Brand__c = 'Maersk Line';
    bg.Country_Code__c = 'IN';
    bg.Product_Family__c = '4PL PF';
    bg.Executing_Country__c = testCountry.id;
    insert bg;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup8() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.PO_Eligible__c = true;
    stag.Price_Owner__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    static testmethod void dataSetup9() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    String currYear = String.valueof(Date.today().year());
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    set<Id>targetId = new set<Id>();
    List<Target_Measure__c>targetMeasureInsertList = new List<Target_Measure__c>();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Consignee_Eligible__c = true;
    stag.Consignee__c='A5467H90';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
     Target_Item_Group__c tig = new Target_Item_Group__c();
     //tig.Staging_Reference__c = stagList[0].id;
     tig.BrandMnA__c='Maersk Line';
     tig.Product_Family__c = '4PL PF';
     tig.Target__c=tar.id;
     tig.Country_Code__c='IN';
     tig.Executing_Area__c=testCluster.id;
     tig.Executing_Country__c=testCountry.id;
     insert tig;
     
     Target_Item__c tItem = new Target_Item__c();
     tItem.Account__c = accRec.id;
     tItem.Sales_Target_Item_Group__c=tig.id;
         
     insert tItem;
     targetId.add(tItem.Id);
     List<Target_Item__c>targetList = [select id,Account__c,Sales_Target_Item_Group__c,Sales_Target_Item_Group__r.Target__r.Applicable_Year__c,Sales_Target_Item_Group__r.BrandMnA__c,Sales_Target_Item_Group__r.Country_Code__c,Sales_Target_Item_Group__r.Product_Family__c from Target_Item__c where Sales_Target_Item_Group__r.Target__r.Applicable_Year__c=:currYear AND Id=:tItem.id];
         
     Target_Measure__c measureRecGP = new Target_Measure__c();
      measureRecGP.Target_Item__c=targetList[0].id;
      measureRecGP.Measure_Type__c='Gross Profit';
      measureRecGP.Measure_Dimension__c='Pipeline';
      if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
          measureRecGP.put(mapMonth.get(currMonth),10000);
      }
      targetMeasureInsertList.add(measureRecGP);
                        
                        
        Target_Measure__c measureRecVol = new Target_Measure__c();
        measureRecVol.Target_Item__c=targetList[0].id;
        measureRecVol.Measure_Type__c='Volume';
        measureRecVol.Measure_Dimension__c='Pipeline';
        if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
            measureRecVol.put(mapMonth.get(currMonth),10000);
        }
        
         
         insert measureRecVol;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    TargetSettingBatchHelper.getTargetMeasureRecords(targetId);
    TargetSettingBatchHelper.getTargetMeasureRecordsByTargetItemId(tItem.Id);
    //TargetSettingBatchHelper.updateAggregateMeasureRecord(measureRecVol,stag);
    }
    
    static testmethod void dataSetup10() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    
     
     
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Shipper_Eligible__c = true;
    stag.Shipper__c = 'A5467H90';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    //baseBatch.finish(bc);
    }
    
    static testmethod void dataSetup11() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Rolling Forecast';
    stag.RoFo_Version__c = 'ROFOQ22023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    Target_Product_Exclusion__c tpe = new Target_Product_Exclusion__c();
    tpe.Brand__c = 'Maersk Line';
    tpe.Product_Family__c = '4PL PF';
    tpe.Target__c = tar.Id;
    //tpe.Area__c = testCluster.id;
    tpe.Country__c = testCountry.id;
    insert tpe;
    
     Budget_Group__c bg = new Budget_Group__c();
    bg.Target__c = tar.Id;
    bg.Brand__c = 'Maersk Line';
    bg.Country_Code__c = 'IN';
    bg.Product_Family__c = '4PL PF';
    bg.Executing_Country__c = testCountry.id;
    insert bg;
    
    Budget_Measure__c bMeasureInsertRecord = new   Budget_Measure__c();
        
        if(bg.Id!=null){
            bMeasureInsertRecord.Budget_Group__c = bg.Id;
        }
        bMeasureInsertRecord.Measure_Dimension__c = stagList[0].Measure_Dimension__c;
        bMeasureInsertRecord.Measure_Type__c = stagList[0].Measure_Type__c;
        bMeasureInsertRecord.Jan__c= stagList[0].Jan__c;    
        bMeasureInsertRecord.Feb__c = stagList[0].Feb__c;
        bMeasureInsertRecord.Mar__c = stagList[0].Mar__c;
        bMeasureInsertRecord.Apr__c = stagList[0].Apr__c;
        bMeasureInsertRecord.May__c = stagList[0].May__c;
        bMeasureInsertRecord.Jun__c = stagList[0].Jun__c;
        bMeasureInsertRecord.Jul__c = stagList[0].Jul__c;
        bMeasureInsertRecord.Aug__c = stagList[0].Aug__c;
        bMeasureInsertRecord.Sep__c = stagList[0].Sep__c;
        bMeasureInsertRecord.Oct__c = stagList[0].Oct__c;
        bMeasureInsertRecord.Nov__c = stagList[0].Nov__c;
        bMeasureInsertRecord.Dec__c = stagList[0].Dec__c;
        insert bMeasureInsertRecord;
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'ROFO';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'ROFO','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    
    static testmethod void dataSetup12() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Shipper_Eligible__c = true;
    stag.Shipper__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Party_Type__c='Shipper';
         measureRecGP.Credit_Eligible__c=true;
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Actuals';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup13() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.PO_Eligible__c = true;
    stag.Price_Owner__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Party_Type__c = 'Price Owner';
         measureRecGP.Credit_Eligible__c = true;
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Actuals';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup14() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Consignee_Eligible__c = true;
    stag.Consignee__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup15() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Shipper_Eligible__c = false;
    stag.Shipper__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup16() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.PO_Eligible__c = false;
    stag.Price_Owner__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    
    static testmethod void dataSetup17() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, true);
    Map<Integer,String>mapMonth = new Map<Integer,String>{1=>'Jan__c',2=>'Feb__c',3=>'Mar__c',4=>'Apr__c',
    5=>'May__c',6=>'Jun__c',7=>'Jul__c',8=>'Aug__c',9=>'Sep__c',10=>'Oct__c',11=>'Nov__c',12=>'Dec__c'};
    Integer currMonth = Date.today().month();
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Account accRec = TestBusinessHelper.createAccount(maerskLineUser, testCountry, 'Client_Account', true);
     accRec.Customer_Code__c = 'A5467H90';
     update accRec;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Actuals';
    stag.RoFo_Version__c = 'ROFOQ42023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Consignee_Eligible__c = false;
    stag.Consignee__c='A5467H90';
    stagList.add(stag);
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    insert stagList; 
    
    
         Target_Item_Group__c tig = new Target_Item_Group__c();
         //tig.Staging_Reference__c = stagList[0].id;
         tig.BrandMnA__c='Maersk Line';
         tig.Product_Family__c = '4PL PF';
         tig.Target__c=tar.id;
         tig.Country_Code__c='IN';
         tig.Executing_Area__c=testCluster.id;
         tig.Executing_Country__c=testCountry.id;
         insert tig;
         
         Target_Item__c tItem = new Target_Item__c();
         tItem.Account__c = accRec.id;
         tItem.Sales_Target_Item_Group__c=tig.id;
         
         insert tItem;
         
         Target_Measure__c measureRecGP = new Target_Measure__c();
         measureRecGP.Target_Item__c=tItem.id;
         measureRecGP.Measure_Type__c='Gross Profit';
         measureRecGP.Measure_Dimension__c='Pipeline';
         if(mapMonth.containskey(currMonth) && mapMonth.get(currMonth)!=null){
             measureRecGP.put(mapMonth.get(currMonth),10000);
         }
         insert measureRecGP;
         
         
    
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'CY_ACTUALS';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'CY_ACTUALS','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    }
    static testmethod void dataSetup18() {
    List<Target_Setting_Staging__c>stagList = new List<Target_Setting_Staging__c>();
    Database.BatchableContext bc;
    
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
         bdaGeo.Geography__c = testCountry.Id;
         insert bdaGeo;
    Target__c tar = new Target__c();
    tar.Applicable_Year__c=String.valueof(Date.today().Year());
    tar.Stage__c='New';
         
    insert tar;
    
    Product2 product = TestBusinessHelper.createProduct('Customs Services & Insurance', true); 
    product.Portfolio__c='LnS';
    product.Family = 'Air & LCL'; 
    product.OIPC_Code__c='12345';
    product.Version__c=1;
    product.IsActive=true;
    product.Product_Status__c='Ready-to-sell';
    update product;
         
    Legacy_Product_Mapping__c lpm = new Legacy_Product_Mapping__c();
    lpm.Legacy_Product_Family__c='4PL PF';
    lpm.Product__c=product.Id;
    insert lpm;
    
    Target_Brand_Mapping__c brandMap = new Target_Brand_Mapping__c();
    brandMap.Active__c = true;
    brandMap.BrandMnA__c='Maersk Line';
    brandMap.Salesforce_Brand__c = 'Maersk Line';
    insert brandMap;
    
    Target_Setting_Staging__c stag = new Target_Setting_Staging__c();
    stag.Status__c = 'New'; 
    stag.Brand__c= 'Maersk Line';
    stag.Measure_Dimension__c = 'Rolling Forecast';
    stag.RoFo_Version__c = 'ROFOQ22023';
    stag.Country_Code__c = 'IN';
    stag.Product_Family__c = '4PL PF';
    stag.Measure_Type__c='Gross Profit';
    stag.Jan__c=10.00;
    stag.Feb__c=10.00;
    stag.Mar__c=10.00;
    stag.Apr__c=10.00;
    stag.May__c=10.00;
    stag.Jun__c=10.00;
    stag.Jul__c=10.00;
    stag.Aug__c=10.00;
    stag.Sep__c=10.00;
    stag.Oct__c=10.00;
    stag.Nov__c=10.00;
    stag.Dec__c=10.00;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stag.Area__c=testCluster.id;
    stag.Country__c=testCountry.id;
    stagList.add(stag);
    insert stagList; 
    
    Target_Product_Exclusion__c tpe = new Target_Product_Exclusion__c();
    tpe.Brand__c = 'Hamburg Sud';
    tpe.Product_Family__c = '4PL PF';
    tpe.Target__c = tar.Id;
    //tpe.Area__c = testCluster.id;
    tpe.Country__c = testCountry.id;
    insert tpe;
    
     Budget_Group__c bg = new Budget_Group__c();
    bg.Target__c = tar.Id;
    bg.Brand__c = 'Maersk Line';
    bg.Country_Code__c = 'IN';
    bg.Product_Family__c = '4PL PF';
    bg.Executing_Country__c = testCountry.id;
    insert bg;
    
    Budget_Measure__c bMeasureInsertRecord = new   Budget_Measure__c();
        
        if(bg.Id!=null){
            bMeasureInsertRecord.Budget_Group__c = bg.Id;
        }
        bMeasureInsertRecord.Measure_Dimension__c = stagList[0].Measure_Dimension__c;
        bMeasureInsertRecord.Measure_Type__c = stagList[0].Measure_Type__c;
        bMeasureInsertRecord.Jan__c= stagList[0].Jan__c;    
        bMeasureInsertRecord.Feb__c = stagList[0].Feb__c;
        bMeasureInsertRecord.Mar__c = stagList[0].Mar__c;
        bMeasureInsertRecord.Apr__c = stagList[0].Apr__c;
        bMeasureInsertRecord.May__c = stagList[0].May__c;
        bMeasureInsertRecord.Jun__c = stagList[0].Jun__c;
        bMeasureInsertRecord.Jul__c = stagList[0].Jul__c;
        bMeasureInsertRecord.Aug__c = stagList[0].Aug__c;
        bMeasureInsertRecord.Sep__c = stagList[0].Sep__c;
        bMeasureInsertRecord.Oct__c = stagList[0].Oct__c;
        bMeasureInsertRecord.Nov__c = stagList[0].Nov__c;
        bMeasureInsertRecord.Dec__c = stagList[0].Dec__c;
        insert bMeasureInsertRecord;
    
    Target_Setting_Batch_Query__mdt mdt = new Target_Setting_Batch_Query__mdt();
    mdt.DeveloperName = 'ROFO';
    mdt.Query__c = 'SELECT Id, Correlation_Id__c, Country_Code__c, Unit_of_Measure__c, Status__c, Product_Family__c, Year__c, Brand__c, RoFo_Version__c, Jan__c, Feb__c, Mar__c, Apr__c, May__c, Jun__c, Jul__c, Aug__c, Sep__c, Oct__c, Nov__c, Dec__c, Message__c, Measure_Dimension__c, Measure_Type__c, IsGrowthPercent__c, Area__c, Country__c, Area__r.Parent_BDA__c FROM Target_Setting_Staging__c';
    
    TargetSettingBaseDataBatch baseBatch = new TargetSettingBaseDataBatch(tar.Id,'ROFO','1692355538','New');
    baseBatch.Start(bc);
    baseBatch.execute(bc,stagList);
    TargetSettingBatchHelper.sendEmail('Success','Budget','test@gmail.com');
    }
   }