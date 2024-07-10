@isTest
public class AccountPlanRestoreCntrlTest {
    
	@TestSetup
    static void setupTestData(){
        Geography__c country = TestBusinessHelper.createGeography('United States', 'Country', null, true);
        User maerskLineUser = TestBusinessHelper.createUser('Sales', Brand__mdt.getInstance('MaerskLine').MasterLabel, false);
        System.runAs(new User(Id = UserInfo.getUserId())){
            maerskLineUser.Id = null;
            maerskLineUser.FederationIdentifier='testmsluser@maersk.com';
            maerskLineUser.Cluster__c='North America Area';
            maerskLineUser.Country='United States';
            maerskLineUser.Region__c='North America Region';
            maerskLineUser.IsActive=true;
            insert maerskLineUser;
        }
        
        Account account = TestBusinessHelper.createAccount(maerskLineUser, country, 'Client_Account', false);
        account.Id = null;
        account.OwnerId = maerskLineUser.Id;     
        insert account;
        
        Business_Plan__c AccountPlanRec = TestBusinessHelper.createBusinessPlan(account,Brand__mdt.getInstance('MaerskLine').MasterLabel,true);
    }
    
    @isTest
    static void testgetObjectRecords()
    {
        Business_Plan__c accountplanRec = [select Id from Business_Plan__c LIMIT 1];
        AccountPlanRestoreCntrl.getObjectRecords();
        AccountPlanRestoreCntrl.GetWrapperOfSObjectFieldColumnActionValues('Customer_Coverage',accountplanRec.Id);
        AccountPlanRestoreCntrl.restoreObjectData(new List<Sobject>{accountplanRec});
    }
}