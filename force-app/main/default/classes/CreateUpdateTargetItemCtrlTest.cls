/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0      SFSE-11362  03-July-2023  Vinay                   Test class for CreateUpdateTargetItemCtrl class
*/
@istest
public class CreateUpdateTargetItemCtrlTest {

    @testSetup
    static void setupTestData(){
       
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
        
        User user1 = TestBusinessHelper.createUser('Sales', 'MaerskLine', true);
        Assert.isNotNull(user1.Id);
        
        BDA__c bdaArea = TestBusinessHelper.createBDA('India and Bangladesh Area', 'Area', 'IBA', null, user1.Id, true);
        Assert.isNotNull(bdaArea.Id);
        
        Target__c target = TestBusinessHelper.createSalesTarget(user1, String.valueOf(Date.today().year()), 'USD', 'Monthly', TRUE);
        Assert.isNotNull(target.Id);
        
        Target_Item_Group__c targetItemGroup = TestBusinessHelper.createSalesTargetItemGroup(target, 'Hamburg Sud', testCountry, bdaGeo, '4PL PF', true);
        Assert.isNotNull(targetItemGroup.Id);
         	
    }
    
    @istest
    static void getpicklists(){
        test.startTest();
        	Map<String, String> mapMeasureType = CreateUpdateTargetItemCtrl.getPicklistValues('Target Measure','Measure Type');
        	Assert.isNotNull(mapMeasureType); 
        	Map<String, String> mapMeasureDimension = CreateUpdateTargetItemCtrl.getPicklistValues('Target Measure','Measure Dimension');
        	Assert.isNotNull(mapMeasureDimension); 
        	Map<String, String> mapPartyType = CreateUpdateTargetItemCtrl.getPicklistValues('Target Measure','Party Type');
        	Assert.isNotNull(mapPartyType); 
        	Map<String, String> mapItemType = CreateUpdateTargetItemCtrl.getPicklistValues('Target Item','Target Item Type');
        	Assert.isNotNull(mapItemType); 
        test.stopTest();
    }
    
    @istest
    static void getDetails(){

        List<Target_Item_Group__c> listTargetItemGroup = [SELECT Id FROM Target_Item_Group__c];
        Assert.areEqual(1,listTargetItemGroup.size());
        
        Test.startTest();
        	Target_Item_Group__c tg = CreateUpdateTargetItemCtrl.getDetails(listTargetItemGroup[0].Id);
        	Assert.isNotNULL(tg);
        Test.stopTest();
        
    }
   
    @istest
    static void createTargetRecordsNoAcc(){
                
        List<Target_Item_Group__c> listTargetItemGroup = [SELECT Id FROM Target_Item_Group__c];
        Assert.areEqual(1,listTargetItemGroup.size());
        
                        
        Test.startTest();
        		Target_Item__c item = new Target_Item__c();
        		item.Sales_Target_Item_Group__c = listTargetItemGroup[0].Id;
        
             Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);
        	CreateUpdateTargetItemCtrl.createTargetRecords(listTargetItemGroup[0].Id, measure, 'IN', item);
        Test.stopTest();        
    }
    
    @istest
    static void createTargetRecordsWithAcc(){
        
        
        List<Target_Item_Group__c> listTargetItemGroup = [SELECT Id FROM Target_Item_Group__c];
        Assert.areEqual(1,listTargetItemGroup.size());
        
        List<Geography__c> listGeography =[SELECT ID FROM Geography__c WHERE GEO_Code__c=:'IN'];
        
        Account concernAccount = TestBusinessHelper.createAccount('Concern_Account',False);
         concernAccount.Customer_Code__c='TEST44565CONCERNCODE';
         concernAccount.Id=NULL;
         insert concernAccount;
         Assert.isNotNull(concernAccount.Id);
       
         List<Account> listAccToInsert = new List<Account>();
        Account representAccount = TestBusinessHelper.createAccount('Client_Account',False);
        representAccount.Customer_Code__c='REPRESENTCODE123'; 
        representAccount.Represents_Concern__c=TRUE;
        representAccount.ParentId=concernAccount.Id;
        representAccount.Country__c = listGeography[0].Id;
        representAccount.SCV_Status__c = 'Active';
        representAccount.Id=NULL; 
        listAccToInsert.add(representAccount);
        
        Account normalClientAccount = TestBusinessHelper.createAccount('Client_Account',False);
        normalClientAccount.Customer_Code__c='NORMALCLIENTCODE123'; 
        normalClientAccount.Represents_Concern__c= FALSE;
        normalClientAccount.SCV_Status__c = 'Active';
        normalClientAccount.ParentId=concernAccount.Id;
        normalClientAccount.Country__c = listGeography[0].Id; 
        normalClientAccount.Id=NULL;
        listAccToInsert.add(normalClientAccount);
        
        insert listAccToInsert;
        
        Test.startTest();
        	
        		Target_Item__c item = new Target_Item__c();
        		item.Sales_Target_Item_Group__c = listTargetItemGroup[0].Id;
				item.Account__c = listAccToInsert[0].Id;        
        		
               Target_Measure__c measure = new Target_Measure__c(Measure_Type__c='Revenue',
                                                          Measure_Dimension__c='Target', Jan__c=0.12,Feb__c=1.23,
                                                          Mar__c=2.34, Apr__c=3.45, May__c=4.56, Jun__c=5.67,
                                                          Jul__c=6.78, Aug__c=7.89, Sep__c=8.90, Oct__c=9.01,
                                                          Nov__c=10, Dec__c=11);
        	CreateUpdateTargetItemCtrl.createTargetRecords(listTargetItemGroup[0].Id, measure, 'IN', item);
        Test.stopTest();
        
    }
    
}