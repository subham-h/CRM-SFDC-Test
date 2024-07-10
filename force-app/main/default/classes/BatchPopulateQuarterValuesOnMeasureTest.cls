@isTest
public class BatchPopulateQuarterValuesOnMeasureTest {
    static String adminId; 
     static string currentYear = String.ValueOf(Date.Today().year());
    @testSetup static void setup(){
        TriggerExecutionController.skipAccountTrigger(true);
        
        //Concern Account 
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
          //Represent Concern of Concern Account 
        Account Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc1.Customer_Code__c='TEST445651';
        Acc1.Represents_Concern__c=TRUE;
        Acc1.ParentId=concernAccount.Id;
        Acc1.Id=NULL;
        insert Acc1;
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); 
        Assert.isNotNull(country.Id);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        Assert.isNotNull(parentBDA.Id);
        
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBC', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA.Id);
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        Assert.isNotNull(bdaGeo.Id);
        
        Id recordTypeId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c br = new Target_Brand_Mapping__c();
        br.RecordtypeId = recordTypeId;
        br.Salesforce_Brand__c=BrandUtilities.SEAGO;
        br.Active__c=True;
        br.BrandMnA__c='Sealand Europe';
        insert br;
           
        Test.startTest();       
        
        
        User adminUser = TestBusinessHelper.createUser('System Administrator', BrandUtilities.MAERSKLINE, false);	
        adminUser.Id = null;
        adminUser.IsActive=true;
        adminUser.country = 'India';
        System.runAs(new User(Id = UserInfo.getUserId())){
        insert adminUser;
            
        }
        Assert.isNotNull(adminUser.Id);
        adminId = adminUser.Id;
        List<User> usersToInsert = new List<User>();
        List<SIP_KPI__c> lstSipKpi = new List<SIP_KPI__c>();
        User salesUser;
         System.runAs(adminUser){
            
            salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.HAMBURGSUD, false);
            salesUser.Id = null;
            salesUser.IsActive=true;
            salesUser.country = 'India';
            salesUser.Cluster__c = 'Centre Function';
            salesUser.Segment_Focus__c='Advancement';
            salesUser.Sales_Job_Function__c='Sales Manager';
            salesUser.FirstName='Manager';
            salesUser.LastName='Manager For Subordinates';    
            insert salesUser;   
                                       
            User salesUser1 = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, false);
            salesUser1.Id = null;
            salesUser1.IsActive=true;
            salesUser1.country = 'India';
            salesUser1.Cluster__c = 'GSC';
            salesUser1.Industry_Focus__c='Retail';
            salesUser1.Segment_Focus__c='Advancement';
            salesUser1.Sales_Job_Function__c='Other';
            
            usersToInsert.add(salesUser1);
              

            User salesUser2 = TestBusinessHelper.createUser('Sales', BrandUtilities.SEALAND, false);
            salesUser2.Id = null;
            salesUser2.IsActive=true;
            salesUser2.country = 'India';
            salesUser2.Cluster__c = 'Centre Function';
            salesUser2.Segment_Focus__c='Advancement';
            salesUser2.Sales_Job_Function__c='Sales Manager';
            
            usersToInsert.add(salesUser2);                               
            insert usersToInsert;     
             
            Id managePortfolioPermissionSetId = [SELECT Id,Name FROM PermissionSet WHERE NAME ='APP_Territory_Management_Manage_Portfolios' LIMIT 1]?.Id;
            List<PermissionSetAssignment> ps =[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:managePortfolioPermissionSetId AND AssigneeId=:UserInfo.getUserId()];
            if(ps.isEmpty()){
                insert new PermissionSetAssignment(AssigneeId=UserInfo.getUserId(), PermissionSetId=managePortfolioPermissionSetId);
            } 
             
         }
        
          Territory__c ter1 = TestBusinessHelper.createTerritory(usersToInsert[0], TRUE);
          Territory__c ter2 = TestBusinessHelper.createTerritory(usersToInsert[1], TRUE);
          	
          Test.stopTest();       
        Id brandMappingRTId = Schema.SObjectType.Target_Brand_Mapping__c.getRecordTypeInfosByDeveloperName().get('Pipeline_Mapping').getRecordTypeId();
        Target_Brand_Mapping__c tbm = new Target_Brand_Mapping__c(Active__c = TRUE,Salesforce_Brand__c= 'Maersk Line', BrandMnA__c = 'Maersk Line', RecordTypeId = brandMappingRTId);
        insert tbm;   
        Target__c salesTargetTest = TestBusinessHelper.createSalesTarget(usersToInsert[0],String.ValueOf(Date.today().year()),'USD','Monthly',TRUE);
        
        List<Target_Item_Group__c> listTIG = new List<Target_Item_Group__c>();
        Target_Item_Group__c targetItemGroupTest = TestBusinessHelper.createSalesTargetItemGroup(salesTargetTest, 'Maersk Line', country , bdaGeo, '4PL PF', FALSE);
        targetItemGroupTest.Id=NULL;
        listTIG.add(targetItemGroupTest);
        
        Target_Item_Group__c targetItemGroupTest1 = TestBusinessHelper.createSalesTargetItemGroup(salesTargetTest, 'Maersk Line', country , bdaGeo, 'LCL PF', FALSE);
        targetItemGroupTest1.Id=NULL;
        listTIG.add(targetItemGroupTest1);
        
        insert listTIG;
        
        
        List<Target_Item__c> targetItems = new List<Target_Item__c>();
        
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupTest, null, Acc1, null, null, null, FALSE);
        targetItemRec.Id=NULL;
        targetItems.add(targetItemRec);
        
        Target_Item__c targetItemRec1 = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupTest1, null, Acc1, null, null, null, FALSE);
        targetItemRec1.Id=NULL;
        targetItems.add(targetItemRec1);
        
        insert targetItems;
        
        TriggerExecutionController.skipAccountTrigger(false);
          String strYear = String.valueOf( Date.today().year()) ; 
        //insert KPI Record 
           SIP_KPI__c kpiRec = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'USD',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Measure_Type__c = 'Revenue',
                                          Target__c = 11,
                                          product_Portfolio__c = 'Lns',
                                          Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                          Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                          Geographical_Validity__c = 'Global',
                                          L_S_product_family__c = '4PL PF',
                                          Brand__c = BrandUtilities.MAERSK);
        lstSipKpi.add(kpiRec);
           SIP_KPI__c kpiRec2 = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'USD',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Measure_Type__c = 'Revenue',
                                          Target__c = 11,
                                          product_Portfolio__c = 'Lns',
                                          Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                          Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                          Geographical_Validity__c = 'Global',
                                          Cumulative_Based_Crediting__c = true,
                                          Brand__c = BrandUtilities.MAERSK);
         
        lstSipKpi.add(kpiRec2);
            SIP_KPI__c kpiRec3 = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'USD',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Measure_Type__c = 'Revenue',
                                          Target__c = 11,
                                          product_Portfolio__c = 'Lns',
                                          Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                          Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                          Geographical_Validity__c = 'Global',
                                          Cumulative_Based_Crediting__c = true,
                                          L_S_product_family__c = '4PL PF;INLAND PF;LCL PF',     
                                          Brand__c = BrandUtilities.MAERSK);
        
         lstSipKpi.add(kpiRec3); 
        
          SIP_KPI__c kpiRec4 = new SIP_KPI__c(Name = 'Ocean Vol',
                                          KPI_Code__c = 'Test code',
                                          KPI_Incentive_Type__c = 'Target-based',
                                          KPI_Type__c = 'Core',
                                          Payout_Frequency__c = 'Annual',
                                          Unit_of_Measure__c = 'USD',
                                          KPI_Grouping__c = 'Existing and additional business',
                                          Measure_Type__c = 'Revenue',
                                          Target__c = 11,
                                          product_Portfolio__c = 'Lns',
                                          Effective_From_Date__c = Date.newInstance( Integer.valueOf(strYear), 1, 1 ),
                                          Effective_To_Date__c = Date.newInstance( Integer.valueOf(strYear), 12, 1 ),
                                          Geographical_Validity__c = 'Global',
                                         Cumulative_Based_Crediting__c = False,
                                          Brand__c = BrandUtilities.MAERSK);
         
        lstSipKpi.add(kpiRec4);
        insert lstSipKpi;
        
        List<SIP_Participant__c> lstSipParticipant = new List<SIP_Participant__c>();
        SIP_Participant__c newSIP1 = new SIP_Participant__c();
        newSIP1.SIP_Participant__c = usersToInsert[0].id;
        newSIP1.Year__c = strYear;
        newSIP1.Paymix__c = 80.0;        
        newSIP1.Brand__c = BrandUtilities.MAERSK;
        newSIP1.Region__c = parentBDA.id;
        newSIP1.Area__c = childBDA.id;
        lstSipParticipant.add(newSIP1);
        
        SIP_Participant__c newSIP2 = new SIP_Participant__c();
        newSIP2.SIP_Participant__c = usersToInsert[1].id;
        newSIP2.Year__c = strYear;
        newSIP2.Paymix__c = 80.0;        
        newSIP2.Brand__c = BrandUtilities.MAERSK;
        newSIP2.Region__c = parentBDA.id;
        newSIP2.Area__c = childBDA.id;
        lstSipParticipant.add(newSIP2);
        
        SIP_Participant__c newSIP = new SIP_Participant__c();
        newSIP.SIP_Participant__c = salesUser.id;
        newSIP.Year__c = strYear;
        newSIP.Paymix__c = 80.0;        
        newSIP.Brand__c = BrandUtilities.HAMBURGSUD;
        newSIP.Region__c = parentBDA.id;
        newSIP.Area__c = childBDA.id;
        lstSipParticipant.add(newSIP);
       
        insert lstSipParticipant;
    }
    @isTest
    static void insertTargetMeasureTest(){
         Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        Set<Id> sipParticipantId = new Set<Id>();
        List<Territory__c> Territories = [SELECT Id FROM Territory__c];
        List<User> user = [SELECT Id FROM User where country = 'India'];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account representConcernAcc = [SELECT Id from Account WHERE Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1]; 
        /*List<Target_Item_Group__c> targetItemGroupRec = [SELECT Id from Target_Item_Group__c ]; 
        
        List<Target_Item__c> targetItems = new List<Target_Item__c>();
        Target_Item__c targetItemRec = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec[0], null, representConcernAcc, null, null, null, FALSE);
        targetItemRec.Id=NULL;
        targetItems.add(targetItemRec);
        
        Target_Item__c targetItemRec1 = TestBusinessHelper.createSalesTargetItem(salesTargetTest, targetItemGroupRec[1], null, representConcernAcc, null, null, null, FALSE);
        targetItemRec1.Id=NULL;
        targetItems.add(targetItemRec1);
        insert targetItems; */
        
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(Territories[0], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = Date.Today();
        lstTAA.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(Territories[1], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Id = NULL; 
        TAA1.Start_Date__c = Date.Today();
        lstTAA.add(TAA1);
         insert lstTAA;
        
         //Creating Measure record for Price owner
        List<Target_Item__c> targetItems = [SELECT Id FROM Target_Item__c WHERE Account__c=: representConcernAcc.Id];
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[0], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[1], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);

        List<SIP_KPI__c> lstOfSipKpi = [Select id from SIP_KPI__c  where Measure_Type__c = 'Revenue'];
        List<Target_Customer_portfolio__c> tcp = [SELECT id,Assigned_Target__c , Assigned_Sales_Rep__c,Territory_Account_Association__c from Target_Customer_portfolio__c];
        
        List<Sip_Measure__c> lstSipMeasure = new List<Sip_Measure__c>();
          //List<SIP_KPI__c> lstOfSipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
         List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK ];
        
        
        
         SIP_Measure__c SIPMeasure2 = new SIP_Measure__c();
          SIPMeasure2.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure2.SIP_KPI__c = lstOfSipkpi[2].id;
            SIPMeasure2.Weight__c = '30%';
            SIPMeasure2.Applicable_Period__c = 'Q4';
            SIPMeasure2.Target__c =8000;
            SIPMeasure2.System_Actual__c = 5000; 
            SIPMeasure2.Load_Target_from_STS__c = true;
            SIPMeasure2.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure2);
        
        
         SIP_Measure__c SIPMeasure3 = new SIP_Measure__c();
          SIPMeasure3.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure3.SIP_KPI__c = lstOfSipkpi[1].id;
            SIPMeasure3.Weight__c = '30%';
            SIPMeasure3.Applicable_Period__c = 'Q4';
            SIPMeasure3.Target__c =8000;
            SIPMeasure3.System_Actual__c = 5000; 
            SIPMeasure3.Load_Target_from_STS__c = true;
            SIPMeasure3.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure3);
        
         SIP_Measure__c SIPMeasure4 = new SIP_Measure__c();
          SIPMeasure4.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure4.SIP_KPI__c = lstOfSipkpi[0].id;
            SIPMeasure4.Weight__c = '30%';
            SIPMeasure4.Applicable_Period__c = 'Q4';
            SIPMeasure4.Target__c =8000;
            SIPMeasure4.System_Actual__c = 5000; 
            SIPMeasure4.Load_Target_from_STS__c = true;
            SIPMeasure4.Status__c = 'Target Assigned';
            lstSipMeasure.add(SIPMeasure4);
        
         SIP_Measure__c SIPMeasure5 = new SIP_Measure__c();
          SIPMeasure5.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure5.SIP_KPI__c = lstOfSipkpi[3].id;
            SIPMeasure5.Weight__c = '30%';
            SIPMeasure5.Applicable_Period__c = 'Q4';
            SIPMeasure5.Target__c =8000;
            SIPMeasure5.System_Actual__c = 5000; 
            SIPMeasure5.Load_Target_from_STS__c = true;
            SIPMeasure5.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure5);
         
            insert lstSipMeasure; 
        List<sip_Measure__c> lst = [SELECt id,Status__c,Load_Target_from_STS__c ,SIP_Participant__c,SIP_Participant__r.SIP_Participant__c from sip_Measure__c];
       
        for(sip_Measure__c sipMeasure :lst){
            sipParticipantId.add(sipMeasure.SIP_Participant__r.SIP_Participant__c);
        }
        
        Test.startTest();
            BatchPopulateQuarterValuesOnMeasure batchTest = new BatchPopulateQuarterValuesOnMeasure(sipParticipantId,currentYear);
            Database.executeBatch(batchTest);
        Test.stopTest();
       
    }
    
    @istest
    static void firstMethod(){
      
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        
        Set<Id> sipParticipantId = new Set<Id>();
        List<Territory__c> Territories = [SELECT Id FROM Territory__c];
        List<User> user = [SELECT Id FROM User where country = 'India'];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account representConcernAcc = [SELECT Id from Account WHERE Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1];         
        
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(Territories[0], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = Date.Today();
        lstTAA.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(Territories[1], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Id = NULL; 
        TAA1.Start_Date__c = Date.Today();
        lstTAA.add(TAA1);
         insert lstTAA;
        
         //Creating Measure record for Price owner
        List<Target_Item__c> targetItems = [SELECT Id FROM Target_Item__c WHERE Account__c=: representConcernAcc.Id];
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[0], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[1], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);

        List<SIP_KPI__c> lstOfSipKpi = [Select id from SIP_KPI__c  where Measure_Type__c = 'Revenue'];
        List<Target_Customer_portfolio__c> tcp = [SELECT id,Assigned_Target__c , Assigned_Sales_Rep__c,Territory_Account_Association__c from Target_Customer_portfolio__c];
        
        List<Sip_Measure__c> lstSipMeasure = new List<Sip_Measure__c>();
          //List<SIP_KPI__c> lstOfSipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
         List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK ];
        
        
        
         SIP_Measure__c SIPMeasure2 = new SIP_Measure__c();
          SIPMeasure2.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure2.SIP_KPI__c = lstOfSipkpi[2].id;
            SIPMeasure2.Weight__c = '30%';
            SIPMeasure2.Applicable_Period__c = 'Q2';
            SIPMeasure2.Target__c =8000;
            SIPMeasure2.System_Actual__c = 5000; 
            SIPMeasure2.Load_Target_from_STS__c = true;
            SIPMeasure2.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure2);
        
        
         SIP_Measure__c SIPMeasure3 = new SIP_Measure__c();
          SIPMeasure3.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure3.SIP_KPI__c = lstOfSipkpi[1].id;
            SIPMeasure3.Weight__c = '30%';
            SIPMeasure3.Applicable_Period__c = 'Q2';
            SIPMeasure3.Target__c =8000;
            SIPMeasure3.System_Actual__c = 5000; 
            SIPMeasure3.Load_Target_from_STS__c = true;
            SIPMeasure3.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure3);
        
         SIP_Measure__c SIPMeasure4 = new SIP_Measure__c();
          SIPMeasure4.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure4.SIP_KPI__c = lstOfSipkpi[0].id;
            SIPMeasure4.Weight__c = '30%';
            SIPMeasure4.Applicable_Period__c = 'Q2';
            SIPMeasure4.Target__c =8000;
            SIPMeasure4.System_Actual__c = 5000; 
            SIPMeasure4.Load_Target_from_STS__c = true;
            SIPMeasure4.Status__c = 'Target Assigned';
            lstSipMeasure.add(SIPMeasure4);
        
         SIP_Measure__c SIPMeasure5 = new SIP_Measure__c();
          SIPMeasure5.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure5.SIP_KPI__c = lstOfSipkpi[3].id;
            SIPMeasure5.Weight__c = '30%';
            SIPMeasure5.Applicable_Period__c = 'Q2';
            SIPMeasure5.Target__c =8000;
            SIPMeasure5.System_Actual__c = 5000; 
            SIPMeasure5.Load_Target_from_STS__c = true;
            SIPMeasure5.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure5);
         
            insert lstSipMeasure; 
        List<sip_Measure__c> lst = [SELECt id,Status__c,Load_Target_from_STS__c ,SIP_Participant__c,SIP_Participant__r.SIP_Participant__c from sip_Measure__c];
       
        for(sip_Measure__c sipMeasure :lst){
            sipParticipantId.add(sipMeasure.SIP_Participant__r.SIP_Participant__c);
        }
        
        Test.startTest();
            BatchPopulateQuarterValuesOnMeasure batchTest = new BatchPopulateQuarterValuesOnMeasure(sipParticipantId,currentYear);
            Database.executeBatch(batchTest);
        Test.stopTest();
        
    }
    
     @istest
    static void secondMethod(){
      
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        
        Set<Id> sipParticipantId = new Set<Id>();
        List<Territory__c> Territories = [SELECT Id FROM Territory__c];
        List<User> user = [SELECT Id FROM User where country = 'India'];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account representConcernAcc = [SELECT Id from Account WHERE Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1];         
        
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(Territories[0], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = Date.Today();
        lstTAA.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(Territories[1], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Id = NULL; 
        TAA1.Start_Date__c = Date.Today();
        lstTAA.add(TAA1);
         insert lstTAA;
        
         //Creating Measure record for Price owner
        List<Target_Item__c> targetItems = [SELECT Id FROM Target_Item__c WHERE Account__c=: representConcernAcc.Id];
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[0], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[1], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);

        List<SIP_KPI__c> lstOfSipKpi = [Select id from SIP_KPI__c  where Measure_Type__c = 'Revenue'];
        List<Target_Customer_portfolio__c> tcp = [SELECT id,Assigned_Target__c , Assigned_Sales_Rep__c,Territory_Account_Association__c from Target_Customer_portfolio__c];
        
        List<Sip_Measure__c> lstSipMeasure = new List<Sip_Measure__c>();
          //List<SIP_KPI__c> lstOfSipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
         List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK ];
        
        
        
         SIP_Measure__c SIPMeasure2 = new SIP_Measure__c();
          SIPMeasure2.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure2.SIP_KPI__c = lstOfSipkpi[2].id;
            SIPMeasure2.Weight__c = '30%';
            SIPMeasure2.Applicable_Period__c = 'Q3';
            SIPMeasure2.Target__c =8000;
            SIPMeasure2.System_Actual__c = 5000; 
            SIPMeasure2.Load_Target_from_STS__c = true;
            SIPMeasure2.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure2);
        
        
         SIP_Measure__c SIPMeasure3 = new SIP_Measure__c();
          SIPMeasure3.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure3.SIP_KPI__c = lstOfSipkpi[1].id;
            SIPMeasure3.Weight__c = '30%';
            SIPMeasure3.Applicable_Period__c = 'Q3';
            SIPMeasure3.Target__c =8000;
            SIPMeasure3.System_Actual__c = 5000; 
            SIPMeasure3.Load_Target_from_STS__c = true;
            SIPMeasure3.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure3);
        
         SIP_Measure__c SIPMeasure4 = new SIP_Measure__c();
          SIPMeasure4.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure4.SIP_KPI__c = lstOfSipkpi[0].id;
            SIPMeasure4.Weight__c = '30%';
            SIPMeasure4.Applicable_Period__c = 'Q3';
            SIPMeasure4.Target__c =8000;
            SIPMeasure4.System_Actual__c = 5000; 
            SIPMeasure4.Load_Target_from_STS__c = true;
            SIPMeasure4.Status__c = 'Target Assigned';
            lstSipMeasure.add(SIPMeasure4);
        
         SIP_Measure__c SIPMeasure5 = new SIP_Measure__c();
          SIPMeasure5.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure5.SIP_KPI__c = lstOfSipkpi[3].id;
            SIPMeasure5.Weight__c = '30%';
            SIPMeasure5.Applicable_Period__c = 'Q3';
            SIPMeasure5.Target__c =8000;
            SIPMeasure5.System_Actual__c = 5000; 
            SIPMeasure5.Load_Target_from_STS__c = true;
            SIPMeasure5.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure5);
         
            insert lstSipMeasure; 
        List<sip_Measure__c> lst = [SELECt id,Status__c,Load_Target_from_STS__c ,SIP_Participant__c,SIP_Participant__r.SIP_Participant__c from sip_Measure__c];
       
        for(sip_Measure__c sipMeasure :lst){
            sipParticipantId.add(sipMeasure.SIP_Participant__r.SIP_Participant__c);
        }
        
        Test.startTest();
            BatchPopulateQuarterValuesOnMeasure batchTest = new BatchPopulateQuarterValuesOnMeasure(sipParticipantId,currentYear);
            Database.executeBatch(batchTest);
        Test.stopTest();
        
    }
    
    @istest
    static void thirdMethod(){
      
        Validation_Rules_Bypass__c  setting = new Validation_Rules_Bypass__c ();
        setting.Active__c  = true; 
        insert setting; 
        
        Set<Id> sipParticipantId = new Set<Id>();
        List<Territory__c> Territories = [SELECT Id FROM Territory__c];
        List<User> user = [SELECT Id FROM User where country = 'India'];
        List<BDA__c> listBDA = [SELECT Id FROM BDA__c WHERE Parent_BDA__c!=NULL AND Type__c='Cluster' AND Active__c= TRUE];
        
        Geography__c countryIndia = [SELECT Id from Geography__c WHERE GEO_Code__c = 'IN' LIMIT 1];
        Account representConcernAcc = [SELECT Id from Account WHERE Represents_Concern__c = TRUE LIMIT 1];
        Target__c salesTargetTest = [SELECT Id from Target__c LIMIT 1];         
        
        List<Territory_Account_Association__c> lstTAA = new List<Territory_Account_Association__c>();
        Territory_Account_Association__c TAA = TestBusinessHelper.createTerritoryAccountAssociation(Territories[0], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_All,BrandUtilities.MAERSKLINE, FALSE);
        TAA.Id = NULL; 
        TAA.Start_Date__c = Date.Today();
        lstTAA.add(TAA);
        
        Territory_Account_Association__c TAA1 = TestBusinessHelper.createTerritoryAccountAssociation(Territories[1], representConcernAcc, TAASettingConstants.POR_SALES_CONTROL , TAASettingConstants.PR_LnS,BrandUtilities.MAERSKLINE, FALSE);
        TAA1.Id = NULL; 
        TAA1.Start_Date__c = Date.Today();
        lstTAA.add(TAA1);
         insert lstTAA;
        
         //Creating Measure record for Price owner
        List<Target_Item__c> targetItems = [SELECT Id FROM Target_Item__c WHERE Account__c=: representConcernAcc.Id];
        Target_Measure__c targetMeasure = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[0], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);
        Target_Measure__c targetMeasure2 = TestBusinessHelper.createSalesTargetItemMeasure(targetItems[1], TargetSettingConstants.TARGET, 'Revenue', TargetSettingConstants.PARTY_PO, TRUE, TRUE);

        List<SIP_KPI__c> lstOfSipKpi = [Select id from SIP_KPI__c  where Measure_Type__c = 'Revenue'];
        List<Target_Customer_portfolio__c> tcp = [SELECT id,Assigned_Target__c , Assigned_Sales_Rep__c,Territory_Account_Association__c from Target_Customer_portfolio__c];
        
        List<Sip_Measure__c> lstSipMeasure = new List<Sip_Measure__c>();
          //List<SIP_KPI__c> lstOfSipkpi = [Select id from SIP_KPI__c where Brand__c = :BrandUtilities.MAERSK limit 1];
         List<SIP_Participant__c> sipparticipant = [Select id from SIP_Participant__c where Brand__c = :BrandUtilities.MAERSK ];
        
        
        
         SIP_Measure__c SIPMeasure2 = new SIP_Measure__c();
          SIPMeasure2.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure2.SIP_KPI__c = lstOfSipkpi[2].id;
            SIPMeasure2.Weight__c = '30%';
            SIPMeasure2.Applicable_Period__c = 'Q1';
            SIPMeasure2.Target__c =8000;
            SIPMeasure2.System_Actual__c = 5000; 
            SIPMeasure2.Load_Target_from_STS__c = true;
            SIPMeasure2.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure2);
        
        
         SIP_Measure__c SIPMeasure3 = new SIP_Measure__c();
          SIPMeasure3.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure3.SIP_KPI__c = lstOfSipkpi[1].id;
            SIPMeasure3.Weight__c = '30%';
            SIPMeasure3.Applicable_Period__c = 'Q1';
            SIPMeasure3.Target__c =8000;
            SIPMeasure3.System_Actual__c = 5000; 
            SIPMeasure3.Load_Target_from_STS__c = true;
            SIPMeasure3.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure3);
        
         SIP_Measure__c SIPMeasure4 = new SIP_Measure__c();
          SIPMeasure4.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure4.SIP_KPI__c = lstOfSipkpi[0].id;
            SIPMeasure4.Weight__c = '30%';
            SIPMeasure4.Applicable_Period__c = 'Q1';
            SIPMeasure4.Target__c =8000;
            SIPMeasure4.System_Actual__c = 5000; 
            SIPMeasure4.Load_Target_from_STS__c = true;
            SIPMeasure4.Status__c = 'Target Assigned';
            lstSipMeasure.add(SIPMeasure4);
        
         SIP_Measure__c SIPMeasure5 = new SIP_Measure__c();
          SIPMeasure5.SIP_Participant__c = sipparticipant[0].id;
            SIPMeasure5.SIP_KPI__c = lstOfSipkpi[3].id;
            SIPMeasure5.Weight__c = '30%';
            SIPMeasure5.Applicable_Period__c = 'Q1';
            SIPMeasure5.Target__c =8000;
            SIPMeasure5.System_Actual__c = 5000; 
            SIPMeasure5.Load_Target_from_STS__c = true;
            SIPMeasure5.Status__c = 'Target Assigned';
             lstSipMeasure.add(SIPMeasure5);
         
            insert lstSipMeasure; 
        List<sip_Measure__c> lst = [SELECt id,Status__c,Load_Target_from_STS__c ,SIP_Participant__c,SIP_Participant__r.SIP_Participant__c from sip_Measure__c];
       
        for(sip_Measure__c sipMeasure :lst){
            sipParticipantId.add(sipMeasure.SIP_Participant__r.SIP_Participant__c);
        }
        
        Test.startTest();
            BatchPopulateQuarterValuesOnMeasure batchTest = new BatchPopulateQuarterValuesOnMeasure(sipParticipantId,currentYear);
            Database.executeBatch(batchTest);
        Test.stopTest();
        
    }
}