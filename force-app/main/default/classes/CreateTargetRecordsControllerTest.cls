@isTest
public class CreateTargetRecordsControllerTest {
    
    @testSetup
    static void setupTestData(){
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
        concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
        concernAccount.Id=NULL;
        insert concernAccount;
        Assert.isNotNull(concernAccount.Id);
        
        List<Account> childAccounts = new List<Account>();
        Account Acc1 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc1.Customer_Code__c='TEST445651';
        Acc1.Represents_Concern__c=TRUE;
        Acc1.ParentId=concernAccount.Id;
        Acc1.Id=NULL;
        childAccounts.add(Acc1);
        
        Account Acc3 = TestBusinessHelper.createAccount('Client_Account',False);
        Acc3.Customer_Code__c='TEST445653';
        Acc3.ParentId=concernAccount.Id;
        Acc3.Id=NULL;
        childAccounts.add(Acc3);
        
        insert childAccounts; 
        
        Geography__c country = TestBusinessHelper.createGeography('India', 'Country', null,'IN',TRUE); 
        Assert.isNotNull(country.Id);
        
        BDA__c parentBDA = TestBusinessHelper.createBDA('India, Middle East, and Africa', 'Trade Region', 'IMEA', null, UserInfo.getUserId(), true);
        Assert.isNotNull(parentBDA.Id);
        
        BDA__c childBDA = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Cluster', 'IBS', parentBDA, UserInfo.getUserId(), true);
        Assert.isNotNull(childBDA.Id);
        
        BDA_Geography__c bdaGeo = TestBusinessHelper.createBDAGeography(childBDA.Id, country.Id, null, true);
        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        Assert.isNotNull(user1.Id);
        
        Target__c target = TestBusinessHelper.createSalesTarget(user1, String.valueOf(Date.today().year()+100), 'USD', 'Monthly', TRUE);
        Assert.isNotNull(target.Id);
    }
    
    
    @istest
    static void method1(){
        //When Target Item Group, Item exists for a Target and Measure is Missing.
        List<Target__c> targets =[SELECT Id FROM Target__c];
        Assert.areEqual(1, targets.size());
        
        List<Geography__c> geographies = [SELECT Id FROM Geography__c WHERE Name='India'];
        Assert.areEqual(1, targets.size());
        
        List<BDA_Geography__c> bdaGeographies = [SELECT Id FROM BDA_Geography__c];
        Assert.areEqual(1, bdaGeographies.size());
        
        List<BDA__c> bdas =[SELECT Id FROM BDA__c WHERE Name=:'India and Bangladesh Area'];
        Assert.areEqual(1, bdas.size());
        
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Hamburg Sud', geographies[0], bdaGeographies[0], '4PL PF', false);
        targetItemGroup.Id=NULL;
        insert targetItemGroup;        
        
        List<Account> Acc = [SELECT Id FROM Account WHERE Customer_Code__c=:'TEST445653'];
        Assert.areEqual(1, Acc.size());
        
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(targets[0], targetItemGroup, null, Acc[0], null, null, null, FALSE);
        item.Id =NULL;
        item.Target_Item_Type__c ='Existing Business';
        insert item;
        
        Test.startTest();
        Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);            
        CreateTargetRecordsController.createRecords(targetItemGroup,item,measure, targets[0].Id); 
        
        Target_Measure__c measure1 = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);            
        // Calling Controller one more time to cover error throwing scenario.
        CreateTargetRecordsController.createRecords(targetItemGroup,item,measure1, targets[0].Id); 
        
        Test.stopTest();                
    }
    
    @isTest
    static void method2(){
        //When Target Item Group exists for a Target but Item and Measure are Missing.
        List<Target__c> targets =[SELECT Id FROM Target__c];
        Assert.areEqual(1, targets.size());
        
        List<Geography__c> geographies = [SELECT Id FROM Geography__c WHERE Name='India'];
        Assert.areEqual(1, targets.size());
        
        List<BDA_Geography__c> bdaGeographies = [SELECT Id FROM BDA_Geography__c];
        Assert.areEqual(1, bdaGeographies.size());
        
        List<BDA__c> bdas =[SELECT Id FROM BDA__c WHERE Name=:'India and Bangladesh Area'];
        Assert.areEqual(1, bdas.size());
        
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Hamburg Sud', geographies[0], bdaGeographies[0], '4PL PF', false);
        targetItemGroup.Id=NULL;
        insert targetItemGroup;        
        
        List<Account> Acc = [SELECT Id FROM Account WHERE Customer_Code__c=:'TEST445653'];
        Assert.areEqual(1, Acc.size());
        
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(targets[0], targetItemGroup, null, Acc[0], null, null, null, FALSE);
        item.Id =NULL;
        item.Target_Item_Type__c ='Existing Business';
        item.Sales_Target_Item_Group__c=NULL;
        
        Test.startTest();
        Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);            
        CreateTargetRecordsController.createRecords(targetItemGroup,item,measure, targets[0].Id);         
        
        Test.stopTest();               
    }
    
    @isTest
    static void method3(){
        // When Budget_Group__c, Target Item Group, Item and Measure doesnt exists for a Target.
        List<Target__c> targets =[SELECT Id FROM Target__c];
        Assert.areEqual(1, targets.size());
        system.debug('targetItemGroup--->'+[SELECT Id FROM Target_Item_Group__c WHERE Target__c=:targets[0].Id]);
        
        List<Geography__c> geographies = [SELECT Id FROM Geography__c WHERE Name='India'];
        Assert.areEqual(1, targets.size());
        
        List<BDA_Geography__c> bdaGeographies = [SELECT Id FROM BDA_Geography__c];
        Assert.areEqual(1, bdaGeographies.size());
        
        List<BDA__c> bdas =[SELECT Id FROM BDA__c WHERE Name=:'India and Bangladesh Area'];
        Assert.areEqual(1, bdas.size());
        
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Hamburg Sud', geographies[0], bdaGeographies[0], '4PL PF', false);
        targetItemGroup.Id=NULL;
        targetItemGroup.Target__c =NULL;
        
        List<Account> Acc = [SELECT Id FROM Account WHERE Customer_Code__c=:'TEST445653'];
        Assert.areEqual(1, Acc.size());
        
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(targets[0], targetItemGroup, null, Acc[0], null, null, null, FALSE);
        item.Id =NULL;
        item.Sales_Target_Item_Group__c=NULL;
        item.Target_Item_Type__c ='Existing Business';
        
        Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);
        
        Test.startTest();
        CreateTargetRecordsController.createRecords(targetItemGroup,item,measure, targets[0].Id);
        Test.stopTest();                
    }
    
    @isTest
    static void method4(){
        // When Target Item Group, Item and Measure doesnt exists for a Target but Budget Group exits.
        List<Target__c> targets =[SELECT Id FROM Target__c];
        Assert.areEqual(1, targets.size());
        system.debug('targetItemGroup--->'+[SELECT Id FROM Target_Item_Group__c WHERE Target__c=:targets[0].Id]);
        
        List<Geography__c> geographies = [SELECT Id FROM Geography__c WHERE Name='India'];
        Assert.areEqual(1, targets.size());
        
        List<BDA_Geography__c> bdaGeographies = [SELECT Id FROM BDA_Geography__c];
        Assert.areEqual(1, bdaGeographies.size());
        
        List<BDA__c> bdas =[SELECT Id FROM BDA__c WHERE Name=:'India and Bangladesh Area'];
        Assert.areEqual(1, bdas.size());
        
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(targets[0], 'Hamburg Sud', geographies[0], bdaGeographies[0], '4PL PF', false);
        targetItemGroup.Id=NULL;
        targetItemGroup.Target__c =NULL;
        
        List<Account> Acc = [SELECT Id FROM Account WHERE Customer_Code__c=:'TEST445653'];
        Assert.areEqual(1, Acc.size());
        
        Target_Item__c item = TestBusinessHelper.createSalesTargetItem(targets[0], targetItemGroup, null, Acc[0], null, null, null, FALSE);
        item.Id =NULL;
        item.Sales_Target_Item_Group__c=NULL;
        item.Target_Item_Type__c ='Existing Business';
        
        Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);
        
        Budget_Group__c grp =TestBusinessHelper.createSalesBudgetGroup(targets[0],'Hamburg Sud', bdas[0], geographies[0], '4PL PF', 'ALIARAIL', TRUE);                
        List<Target_Item_Group__c> targetGroupList = [SELECT Id FROM Target_Item_Group__c WHERE Product_Family__c =: targetItemGroup.Product_Family__c
                                                      AND Executing_Country__c=: targetItemGroup.Executing_Country__c
                                                      AND BrandMnA__c=: targetItemGroup.BrandMnA__c AND Target__c=: targets[0].Id];
        
        // When a Budget Group is created, a corresponding Item Group gets created Automatically from Budget Group Trigger. Hence deleting it.
        if(targetGroupList.size()>0){
            delete targetGroupList;
        }   
        
        Test.startTest();                                
        CreateTargetRecordsController.createRecords(targetItemGroup,item,measure, targets[0].Id);        
        Test.stopTest();                
    }
    
    
}