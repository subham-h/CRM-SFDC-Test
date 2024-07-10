/**
 * Author   : Nisha
 * Purpose  : Utility test class for creating SalesCall related data. 
 *
 * Revision Ref Number  Date         Owner                    Description
 * -------- ----------  -----------  -------------------      -----------
 * 1.0      RQ-004292   13/08/2016   Nisha.arjunan@UST        Created.
 * 2.0      RQ-004396   11/4/2016    ramadevi@UST             Added the method to create sales calls
 * 3.0      RQ-005371   11/4/2016    meghana.gupta@UST        Added the method to create sales calls with Type
 * 4.0      RQ-009006   26/09/2018   Nitin More               Updated createSalesCallWithEvent method to set recordtypeid
 * 5.0      RQ-004190   26-09-2019   meghana.gupta@UST        Update method createSalesCalls - add check if account/contact is not null. Change Event type to Others.
 * 6.0      RQ-012152   05-10-2019   Neha@TCS                 Remove reference of Sales and Business review call record type
 * 7.0      SPI-100     08-+6-2022   Ronnie@SF                Removed brand hardcoding
 */

@istest
public class SalesCallData_Test{
    
    public static boolean bCreate = true;
    public static integer iNumberOfSalesCall = 1;
    public static list<Sales_Call__c> lstsalesCall;
    //public static Id salesCallRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Sales Call');
    //public static Id businessReviewRTID = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Business Review');
    public static Id serviceCallRecordTypeId = StaticFactory.getRecordTypeIdByName('Sales_Call__c', 'Service Call');
    
    public static testMethod void createServiceCallWithEvent() {
        UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
        Account acc =  new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'QwertyMynewContact@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);
        lstsalesCall = new list<Sales_Call__c>();
        for(integer i = 0; i < iNumberOfSalesCall; i++)
        {
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Do_Not_Create_Event__c = false;
            salCall.Name = 'UnitTest1'; 
            salCall.Contact__c = cont.Id;
            salCall.RecordTypeId = serviceCallRecordTypeId;
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = 'Service (Face-to-Face)';
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Manager__c = UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            lstsalesCall.add(salCall);            
        }
        if(bCreate) {
            insert lstsalesCall;
        }   
    }
    /*public static testMethod void createSalesCallWithEvent()
    {
         UserDataGeneratorHelper_Test.initializeSystemAdminUser();  
         Account acc =  new Account();
       AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
       AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'QwertyMynewContact@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);
        lstsalesCall = new list<Sales_Call__c>();
        for(integer i = 0; i < iNumberOfSalesCall; i++)
        {
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Do_Not_Create_Event__c = false;
            salCall.Name = 'UnitTest1'; 
            salCall.Contact__c = cont.Id;
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = 'Sales Call (Face-to-Face)';
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Manager__c = UserDataGeneratorHelper_Test.MSLSystemAdminUser.id;
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            salCall.RecordTypeId = salesCallRTID;
            lstsalesCall.add(salCall);            
        }
        if(bCreate) {
            insert lstsalesCall;
        }
    }*/
    
    public static testMethod void createSalesCallWithOutEvent()
    {
        Account acc =  new Account();
        AccountData_Test.iNumberOfAccounts = 1;
        TriggerExecutionController.skipAllTriggers(true);
        AccountData_Test.createDraftAccounts();
        TriggerExecutionController.skipAllTriggers(false);
        acc =AccountData_Test.lstAccounts[0];  
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        TriggerExecutionController.skipAllTriggers(true);
        insert cont;
        TriggerExecutionController.skipAllTriggers(false);
        lstsalesCall = new list<Sales_Call__c>();
        for(integer i = 0; i < iNumberOfSalesCall; i++)
        {
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Name = 'UnitTest2';
            salCall.Do_Not_Create_Event__c = true; 
            salCall.Liner_Brand__c = BrandUtilities.MAERSKLINE;
            salCall.Contact__c = cont.Id;
            lstsalesCall.add(salCall);             
        }
        if(bCreate) {
            insert lstsalesCall;
        }
    }
    
    // To create given number of Sales Calls
    public static Void createSalesCalls(Integer count,Account clientAcc,Contact c,String linerBrand)
    {
        list<Sales_Call__c > scList = new list<Sales_Call__c>();
        for(integer i = 0; i < count; i++)
        {
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Do_Not_Create_Event__c = false;
            salCall.Name = 'UnitTest1';
            
            //RQ-004190 - add null check for account and contact
            if (clientAcc != null)
                salCall.Account__c = clientAcc.Id;
            
            if (c != null)
                salCall.Contact__c = c.Id;
            
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = 'Other'; // RQ-004190
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Liner_Brand__c = linerBrand;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            scList.add(salCall);            
        }
        insert scList;
    }
    
    // To create given number of Sales Calls
    public static void createSalesCallsWithType( Integer count, Account clientAcc, Contact c, String linerBrand, string type){
        
        list<Sales_Call__c > scList = new list<Sales_Call__c>();
        for(integer i = 0; i < count; i++)
        {
            Sales_Call__c salCall = new Sales_Call__c();
            salCall.Do_Not_Create_Event__c = false;
            salCall.Name = 'UnitTest1';
            salCall.Account__c = clientAcc.Id;
            salCall.Contact__c = c.Id;
            salCall.StartDateTime__c = system.now();
            salCall.EndDateTime__c = system.now()+ 1;
            salCall.Type__c = type;
            salCall.OwnerId = Userinfo.getUserId();
            salCall.Liner_Brand__c = linerBrand;
            salCall.Location__c = 'Trivandrum';
            salCall.Event_Description__c = 'Testing';
            salCall.Confirmation_Letter__c = 'Test Confirm';
            salCall.Objective__c = 'Test Objective';
            salCall.Persuasive_Selling_Pitch__c = 'Test';
            salCall.Post_Call_Notes__c = 'Test with multiple invitees';
            scList.add(salCall);            
        }
        TriggerExecutionController.skipSalesCallTrigger(false);
        insert scList;
    }   
}