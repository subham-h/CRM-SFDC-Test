public class TempSTSBatch1 implements Database.Batchable<sObject>, Database.Stateful {
    public Integer itr = 0;
	//public String targetId;
    //public TempSTSBatch(String targetId) {
      //  this.targetId = targetId;
    //}
	public Database.QueryLocator start(Database.BatchableContext batchableCtx) {
        //return Database.getQueryLocator([SELECT Id FROM Target_Item__c WHERE Target__c = 'a6C0D000000AB5HUAW']);
        //return Database.getQueryLocator([ SELECT Id, Sales_Target_Item_Group__c, Sales_Target_Item_Group__r.Unique_Identifier__c, Account__c FROM Target_Item__c WHERE Unique_Identifier__c = null ]);
        //return Database.getQueryLocator([ SELECT Id, Consignee__c, Price_Owner__c, Shipper__c FROM Target_Setting_Staging__c WHERE CreatedDate = TODAY ]);
        //return Database.getQueryLocator([ SELECT Id, Unique_Identifier__c, Brand__c, Country_Code__c, Product_Family__c, Target__c FROM Budget_Group__c WHERE Target__c = :this.targetId ]);
        //return Database.getQueryLocator([SELECT Id, Price_Owner__c, Shipper__c, Status__c, Measure_Dimension__c, Consignee__c FROM Target_Setting_Staging__c WHERE Measure_Dimension__c LIKE '%Actuals%' AND Status__c = 'New']);
        return Database.getQueryLocator([SELECT Id, Status__c, Correlation_Id__c FROM Target_Setting_Staging__c WHERE Measure_Dimension__c = 'Previous Year Actuals' AND Status__c = 'New' LIMIT 300000]);
        //return Database.getQueryLocator([SELECT Id FROM Target_Item__c WHERE Target__c = 'a6C0D000000AB5HUAW']);
    }
    
    //public void execute(Database.BatchableContext batchableCtx, List<Target_Item__c> listTargetItem) {
    public void execute(Database.BatchableContext batchableCtx, List<Target_Setting_Staging__c> listStaging) {
    //public void execute(Database.BatchableContext batchableCtx, List<Budget_Group__c> listBudgetGroup) {
    	/*for (Target_Setting_Staging__c eachStaging :listStaging) {
            eachStaging.Status__c = 'New';
        }
        update listStaging;*/
         delete listStaging;
        //BudgetGroupTriggerHelper.createCorrespondingTargetItemGroup(listBudgetGroup);
        /*Map<String, Account> mapAccountByCustomerCode = new Map<String, Account>();
        Set<String> setCustomerCode = new Set<String>();
        for (Target_Setting_Staging__c eachStaging :listStaging) {
            if (String.isNotBlank(eachStaging.Price_Owner__c)) setCustomerCode.add(eachStaging.Price_Owner__c);
            if (String.isNotBlank(eachStaging.Shipper__c)) setCustomerCode.add(eachStaging.Shipper__c);
            if (String.isNotBlank(eachStaging.Consignee__c)) setCustomerCode.add(eachStaging.Consignee__c);
        }
        mapAccountByCustomerCode = TargetSettingStagingTriggerHelper.getAccountByCustomerCode(setCustomerCode);
                    System.debug('mapAccountByCustomerCode: ' + mapAccountByCustomerCode.size());
        for (Target_Setting_Staging__c eachStaging :listStaging) {
        	if (mapAccountByCustomerCode.get(eachStaging.Price_Owner__c) != null) {
                eachStaging.Price_Owner_Account_Id__c = mapAccountByCustomerCode.get(eachStaging.Price_Owner__c).Id;
            }
            if (mapAccountByCustomerCode.get(eachStaging.Consignee__c) != null) {
                eachStaging.Consignee_Account_Id__c = mapAccountByCustomerCode.get(eachStaging.Consignee__c).Id;
            }
            if (mapAccountByCustomerCode.get(eachStaging.Shipper__c) != null) {
                eachStaging.Shipper_Account_Id__c = mapAccountByCustomerCode.get(eachStaging.Shipper__c).Id;
            }
            eachStaging.Status__c = 'New';
            System.debug(eachStaging);
        }
        Database.update(listStaging, true);*/
        /*String accountId = ''; 
        for (Target_Item__c eachTargetItem :listTargetItem) {
            accountId = eachTargetItem.Account__c == null ? 'NOACC' : eachTargetItem.Account__c;
            eachTargetItem.Unique_Identifier__c = eachTargetItem.Sales_Target_Item_Group__r.Unique_Identifier__c 
                + (eachTargetItem.Account__c == null ? 'NOACC' : eachTargetItem.Account__c);
        }
        
        Database.update(listTargetItem, false);*/
        /*List<Target_Item__c> setId = new List<Target_Item__c>();
        for (Database.SaveResult eachSr :Database.update(listTargetItem, false)) {
            if (!eachSr.isSuccess()) {
                String errorMsg = eachSr.getErrors().get(0).getMessage();
                System.debug(errorMsg);
                errorMsg = errorMsg.removeStart('duplicate value found: Unique_Identifier__c duplicates value on record with id: ');
				//errorMsg = errorMsg.left(18);
				errorMsg.trim();
                System.debug('errorMsg: ' + errorMsg);
               	setId.add(new Target_Item__c(Id = errorMsg));
            }
        }
        delete setId;*/
    	/*List<Account> liAccount = new List<Account>();
        for (Target_Setting_Staging__c eachStaging :listStaging) {
            if (String.isNotBlank(eachStaging.Price_Owner__c)) {
                liAccount.add(new Account(Customer_Code__c = eachStaging.Price_Owner__c
                                         , Name = 'PY Actuals Account ' + String.valueOf(this.itr)
                                         , RecordTypeId = '012D0000000kJKxIAM'));
            }
            if (String.isNotBlank(eachStaging.Shipper__c)) {
                liAccount.add(new Account(Customer_Code__c = eachStaging.Shipper__c
                                         , Name = 'PY Actuals Account ' + String.valueOf(this.itr)
                                         , RecordTypeId = '012D0000000kJKxIAM'));
            }
            if (String.isNotBlank(eachStaging.Consignee__c)) {
                liAccount.add(new Account(Customer_Code__c = eachStaging.Consignee__c
                                         , Name = 'PY Actuals Account ' + String.valueOf(this.itr)
                                         , RecordTypeId = '012D0000000kJKxIAM'));
            }
            itr++;
        }
        insert liAccount;*/
    }
    
    public void finish(Database.BatchableContext batchableCtx) {
        System.debug('DONE!');
    }
}