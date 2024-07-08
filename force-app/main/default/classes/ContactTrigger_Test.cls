/**
* Test class for ContactTriggerHandler class called by the single Object trigger on Contact object.
* 
* Version    Date           Owner                                      RQ#            Description
*********************************************************************************************************************************  
* 1.0         28/01/2015   Sandhya.Sambasivan@ust-global.com          #RQ-000874      Code created as part of #RQ-000874 - Single Trigger Model   
* 2.0         01/04/2015   Revathy.Sudhindran@ust-global.com          #RQ-000946      Change one liner brand per Email on contact logic to Trigger                                                                      
* 3.0         25/08/2015   Madhava.kotte@ust-global.com               #RQ-001857      Update unique email address for internal contacts
* 4.0         11/11/2015   Sunu.Paul@ust-global.com                   #PR-0055        Introduced Seago Brand and data generator classses   
* 5.0         04/02/2016   Sunu.Paul@ust-global.com                   #RQ-002775      Optimize code to use less methods 
* 6.0         24/03/2016   Dinesh.Moorthy@ust-global.com              #RQ-002098      Decommission Customer Subscription management
* 7.0         03/05/2016   Sandhya.Sambasivan@ust-global.com          #RQ-003041      Added Liner Brand for internal contact
* 8.0         30/03/2017   Nisha.Arjunan@ust-global.com               #RQ-005057      In populating 'Unique_Email_Address__c'"$LINER BRAND - $EMAIL is only applicable for  non deduped Non-shipping Party Contacts
* 8.1         24/01/2017   Nisha.Arjunan@ust-global.com               #RQ-007579      All the contacts are deduped, no need of LinerBrand-email combination in Unique_Email__c field
* 9.0         15/10/2020   Meghana@UST            					   SFSE-4767	   Remove safmarine brand related tests
* 10.0        08/06/2022   Ronnie@SF                                  SPI-100         Removed brand hardcoding
* 11.0        09/03/2023   Shubham@maersk                             SFSE-10558      Added SCPI_TAX_EXEMPT customer group
* 12.0			04/10/2023	Kiran@Maersk												Adding new test data framework
* 13.0        06/02/2024   Kusum@maersk                               SFSE-14006      The last contact that has an email address under the SCPI account cannot be removed
* 14.0        02/04/2024   Shilpa@maersk                              SFSE-14585       Added Testmethod to associate contacts to the accounts.
*
*/


@isTest 
private class ContactTrigger_Test {
    
    /*public static Account ClientAccount = AccountDataHelper_Test.createClientAccount();
public static Account UnAssignedAccount = AccountDataHelper_Test.createUnassignedAccount();
public static Account draftAcc = AccountDataHelper_Test.createDraftAccount();
public static Account nonShippingPartyAccount = AccountDataHelper_Test.createNonShippingPartyAccount(); // v8.0 #RQ-005057*/
    
    @testSetup
    static void setupTestData() {
        
        List<Contact> conListToInsertTwo = new List<Contact>();    
        List<Contact> conListToInsertThree = new List<Contact>();
        
        Test.startTest();
        TriggerExecutionController.skipAllTriggers(true);
        //User
        User maerskUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.MAERSKLINE + ';' + BrandUtilities.MAERSKLS, false);
        User sealandUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEALAND, false);
        User seagoUser = TestBusinessHelper.createUser('Integration User', BrandUtilities.SEAGO, false);
        maerskUser.Id = null;
        sealandUser.id = null;
        seagoUser.Id = null;
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User>{maerskUser, sealandUser, seagoUser};
                }
        
        //Accounts
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        Account clientAccount1 = TestBusinessHelper.createAccount('Client_Account', true);
        Account clientAccount2 = TestBusinessHelper.createAccount('Client_Account', true);
        Account nonShippingPartyAccount = TestBusinessHelper.createAccount('X3rd_Party_Account', false);
        Account unassignedAccount = TestBusinessHelper.createAccount('Unassigned', false);
        Account draftAccount = TestBusinessHelper.createAccount('Draft_Account', false);
        clientAccount.Id = null;
        nonShippingPartyAccount.Id = null;
        unassignedAccount.Id = null;
        draftAccount.Id = null;
        insert new List<Account>{clientAccount, nonShippingPartyAccount, unassignedAccount, draftAccount};
            System.debug('Number' + Limits.getQueries());
        
        //Lead
        Lead lead = TestBusinessHelper.createLead(BrandUtilities.MAERSKLINE, false);
        
        
        //Contacts
        Contact customerContactMaersk = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        Contact customerContactMaerskBulk1 = TestBusinessHelper.createContact(clientAccount1, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        Contact customerContactMaerskBulk2 = TestBusinessHelper.createContact(clientAccount2, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
        Contact customerContactSealand = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.SEALAND, false);
        Contact customerContactSeago = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.SEAGO, false);
        Contact internalContact = TestBusinessHelper.createContact(unassignedAccount, 'Internal_Contact', BrandUtilities.MAERSKLINE, false);
        Contact thirdPartyContact = TestBusinessHelper.createContact(nonShippingPartyAccount, 'Third_Party_Contact', BrandUtilities.MAERSKLINE, false);
        customerContactMaersk.Id = null;
        customerContactMaersk.LastName = 'CustomerContactMaersk';
        customerContactMaersk.Phone = '+44 123456';
        customerContactMaersk.MobilePhone = '+44 123456';
        customerContactMaersk.OtherPhone = '+44 123456';
        customerContactMaersk.Fax = '+44 123456';
        
        customerContactMaerskBulk1.Id = null;
        customerContactMaerskBulk1.LastName = 'customerContactMaerskBulk1';
        customerContactMaerskBulk1.Phone = '+44 123456';
        customerContactMaerskBulk1.MobilePhone = '+44 123456';
        customerContactMaerskBulk1.OtherPhone = '+44 123456';
        customerContactMaerskBulk1.Fax = '+44 123456';
        customerContactMaerskBulk1.Email = 'bulk1@gmail.com';
        
        customerContactMaerskBulk2.Id = null;
        customerContactMaerskBulk2.LastName = 'customerContactMaerskBulk2';
        customerContactMaerskBulk2.Phone = '+44 123456';
        customerContactMaerskBulk2.MobilePhone = '+44 123456';
        customerContactMaerskBulk2.OtherPhone = '+44 123456';
        customerContactMaerskBulk2.Fax = '+44 123456';
        customerContactMaerskBulk2.Email = 'bulk2@gmail.com';
        
        customerContactSealand.Id = null;
        customerContactSealand.LastName = 'CustomerContactSealand';
        customerContactSealand.Phone = '+44 1234567';
        customerContactSealand.MobilePhone = '+44 1234567';
        customerContactSealand.OtherPhone = '+44 1234567';
        customerContactSealand.Fax = '+44 1234567';
        
        customerContactSeago.Id = null;
        customerContactSeago.LastName = 'CustomerContactSeago';
        customerContactSeago.Phone = '+44 1234568';
        customerContactSeago.MobilePhone = '+44 1234568';
        customerContactSeago.OtherPhone = '+44 1234568';
        customerContactSeago.Fax = '+44 1234568';
        internalContact.Id = null;
        thirdPartyContact.Id = null;
        thirdPartyContact.Lead_Id__c = lead.Id;
        List<Contact> conListToInsertOne = new List<Contact>{customerContactMaersk,customerContactMaerskBulk1,customerContactMaerskBulk2, customerContactSealand, customerContactSeago, thirdPartyContact, internalContact};
            insert conListToInsertOne;
        
        Contact customerContact = new Contact();
        for(Integer i = 0; i<=110; i++){
            customerContact = TestBusinessHelper.createContact(clientAccount, 'Customer_Contact', BrandUtilities.MAERSKLINE, false);
            customerContact.Id = null;
            customerContact.LastName = 'CustomerContactMaersk '+i;
            customerContact.Email = customerContact.Email.replace('@',i+'@');
            customerContact.Phone = '+44 12346'+i;
            customerContact.MobilePhone = '+44 12346'+i;
            customerContact.OtherPhone = '+44 12346'+i;
            customerContact.Fax = '+44 123466'+i;
            conListToInsertTwo.add(customerContact);
        }
        
        
        Opportunity opportunity = TestBusinessHelper.createOpportunity(clientAccount, null, null, 'Supply_Chain_Services', BrandUtilities.MAERSKLINE, false);
        opportunity.Id = null;
        opportunity.Cargo_Type__c = 'Dry';
        opportunity.Primary_Contact__c = customerContactMaersk.Id;
        insert opportunity;
        
        Test.stopTest();
        
        insert conListToInsertTwo;
        TriggerExecutionController.skipAllTriggers(false);
    }
    
    static testmethod void validateCustomerGroup() {
        
        Account acc = [select Customer_Group__c from Account LIMIT 1];
        acc.Customer_Group__c = 'SCPI';
        update acc;
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com'];
        Contact MSLconObj1 = [SELECT Id,AccountId, Email FROM Contact WHERE LastName = 'CustomerContactMaersk' ];        
        MSLconObj1.Email = '';
        
        // SFSE : 14006_The last contact that has an email address under the SCPI account cannot be removed
        List<Contact> updateCon = [select id, AccountId, Account.Customer_Group__c from contact WHERE LastName LIKE 'CustomerContactMaerskBulk%'];
        for (Contact con: updateCon){
            con.AccountId = MSLconObj1.AccountId;           
        }
        
        Test.startTest();
        try{
            update updateCon;
            
        }
        catch(Exception e){ //Error message thrown when remove / inactivate the last contact that has an email address under this SCPI account 
            System.assert(ApexPages.GetMessages().get(0).getSummary().contains(Label.CustomerGroupError));
        }   
        
        Database.SaveResult result = Database.update(MSLconObj1, false);
        acc.Customer_Group__c = 'SCPI_TAX_EXEMPTED';
        update acc;
        result = Database.update(MSLconObj1, false);
        
        Test.stopTest();
        // SFSE : 14006_The last contact that has an email address under the SCPI account cannot be removed
        for (Contact con: [select id, AccountId, Account.Customer_Group__c from contact WHERE LastName LIKE 'CustomerContactMaerskBulk%']){
            System.assertNotEquals(con.AccountId,MSLconObj1.AccountId, 'The last contact that has an email address under the SCPI account cannot be removed');                
        }
        
    }
    /*
* Testing change Account and update Contact's Primary_Contact__c = true.The Account has closed Opportunity associated with it.
* Contact's Account gets updated and new Account's Primary_Contact__c will be updated.
*/
    static testmethod void changeAccountForClosedOpportunity(){
        Test.StartTest();
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        Account draftAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Draft_Account'];
        //Contact MSLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,MSLconObj1Email,false,true,RunUser);//Create MSL Contact
        Contact MSLconObj1 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        opportunity mslDryOpportunity = [SELECT Id, Primary_Contact__c FROM Opportunity where recordtype.DeveloperName = 'Supply_Chain_Services' LIMIT 1];
        
        //MSLconObj1.Primary_Contact__c = true; //Mark Primary_Contact__c = true
        MSLconObj1.AccountId = draftAcc.Id; //Change Account for the contact
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        
        System.runAs(RunUser){
            Database.Update(MSLconObj1); //Update Contact   
        }
        Test.stopTest();        
        
        // Account accResult = [SELECT Id //, Primary_Contact__c 
        //                      FROM Account 
        //                      WHERE ID =: draftAcc.Id];
        //;System.assertEquals(MSLconObj1.Id,accResult.Primary_Contact__c); //Verify that Account's Primary_Contact__c field is updated with Contact Id
    }
    
    
    /*
* Prevent change of Account with open opportunity for a Contact.
*/
    static testmethod void changeAccountForOpenOpportunity(){
        Test.StartTest();
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        Account draftAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Draft_Account'];
        //Contact MSLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,MSLconObj1Email,false,true,RunUser);//Create MSL Contact
        Contact MSLconObj1 = [SELECT Id, Email FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        opportunity mslDryOpportunity = [SELECT Id, Primary_Contact__c FROM Opportunity where recordtype.DeveloperName = 'Supply_Chain_Services' LIMIT 1];
        MSLconObj1.AccountId = draftAcc.Id; //Change Account
        
        
        System.runAs(RunUser){
            try{
                Database.Update(MSLconObj1);
            }
            catch(Exception e){ //Error message thrown when Account with Open opportunity is changed for a contact
                System.assert(ApexPages.GetMessages().get(0).getSummary().contains(Label.Error_Contact_with_Open_Opportunity));
            }   
        }
        Test.stopTest();
    }
    
    
    /*
* Update SCL Contact with Primary_Contact__c = true/false to check Account's SCL_Primary_Contact__c getting updated
* and other SCL Contacts in same Account is updated with Primary_Contact__c = false.
* (Multiple SCL Contacts exist for Account)
*/
    /*  static testmethod void SCLPrimaryContactUpdate(){

String SCLconObj2Email = 'QwertySCL2@gmail.com'; 
User RunUser = UserDataGeneratorHelper_Test.SCLIntegrationUser;
/*Contact SCLconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,
ClientAccount.Id,SCLconObj2Email,false,true,RunUser);//Create SCL Contact * /
Contact SCLconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,
ClientAccount.Id,SCLconObj2Email,RunUser);//Create SCL Contact

String SCLconObj3Email = 'QwertySCL3@gmail.com';
//Contact SCLconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,ClientAccount.Id,SCLconObj3Email,true,false,RunUser);//Create SCL Contact
Contact SCLconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,ClientAccount.Id,SCLconObj3Email,RunUser);//Create SCL Contact
//SCLconObj2.Primary_Contact__c = true; //Change previous Contact's Primary_Contact__c from false to true.
TriggerRecursionCounter.IsInsideContactTrigger = false;

Test.StartTest();
System.runAs(UserDataGeneratorHelper_Test.SCLIntegrationUser){
Database.update(SCLconObj2); //Update Contact
}
//Test.stopTest();// 
Account accObj = [SELECT Id//,SCL_Primary_Contact__c 
FROM Account
WHERE ID =:SCLconObj2.AccountId];

//System.assertEquals(SCLconObj2.Id, accObj.SCL_Primary_Contact__c); //Verify that Account's SCL_Primary_Contact__c field is updated with Contact

//SCLconObj2.Primary_Contact__c = false; //Change previous Contact's Primary_Contact__c from true to false.
TriggerRecursionCounter.IsInsideContactTrigger = false;
System.runAs(UserDataGeneratorHelper_Test.SCLIntegrationUser){
Database.update(SCLconObj2); //Update Contact   
}
Test.stopTest();// 

accObj = [SELECT Id//,SCL_Primary_Contact__c 
FROM Account
WHERE ID =:SCLconObj2.AccountId];

//System.assertEquals(null, accObj.SCL_Primary_Contact__c); //Verify that Account's SCL_Primary_Contact__c becomes null

}*/
    
    
    /*
* Update SEA Contact with Primary_Contact__ = true/false to check Account's SEA_Primary_Contact__c getting updated
* and other Contacts in same Account with same Liner brand is updated with Primary_Contact__c = false
* (Multiple SEA Contacts exist for Account)
*/
    static testmethod void SEAPrimaryContactUpdate(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusersealand@maersk.com' LIMIT 1];
        //Contact SEAconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEALAND,ClientAccount.Id,SEAconObj2Email,false,true,RunUser);//Create SEA Contact
        Contact SEAconObj2 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSealand'];
        //Contact SEAconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEALAND,ClientAccount.Id,SEAconObj3Email,true,false,RunUser);//Create SEA Contact-Primary flag=true
        Contact SEAconObj3 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSealand'];
        //SEAconObj2.Primary_Contact__c = true; //Change previous Contact's Primary_Contact__c from false to true. 
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        Test.StartTest();
        
        System.runAs(RunUser){
            Database.update(SEAconObj2); //Update Contact
        }
        
        Account accObj = [SELECT Id//,SEA_Primary_Contact__c 
                          FROM Account
                          WHERE ID =:SEAconObj2.AccountId]; 
        
        //System.assertEquals(SEAconObj2.Id, accObj.SEA_Primary_Contact__c); //Verify that Account's SEA_Primary_Contact__c is updated
        
        //SEAconObj2.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        System.runAs(RunUser){
            Database.update(SEAconObj2); //Update Contact
        }
        Test.stopTest();
        
        
        accObj = [SELECT Id//,SEA_Primary_Contact__c 
                  FROM Account
                  WHERE ID =:SEAconObj2.AccountId];
        //System.assertEquals(null, accObj.SEA_Primary_Contact__c);//Verify that Account's SEA_Primary_Contact__c becomes null
        
    }
    
    
    /*
* Testing Contact Update when Contact's Primary_Contact__c is set to false, update Account's Primary_Contact__c to null
* (Condition where only Single MSL Contact exist for Account)
*/
    static testmethod void changeMSLPrimaryContactToFalse(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        //Contact MSLconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,MSLconObj2Email,true,false,RunUser);//Create MSL Contact;//Create second MSL Contact with Primary Contact = true
        Contact MSLconObj2 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        //MSLconObj2.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        Test.StartTest();
        System.runAs(RunUser){
            Database.Update(MSLconObj2); //Update second MSL Contact with Primary Contact = false            
        }
        
        Account accResult = [SELECT Id//,Primary_Contact__c 
                             FROM Account
                             WHERE ID =:MSLconObj2.AccountId];
        //System.assertEquals(null, accResult.Primary_Contact__c); //Verify that Account's Primary_Contact__c is updated to null
        
        //MSLconObj2.Primary_Contact__c = true; 
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        System.runAs(RunUser){
            Database.Update(MSLconObj2); //Update SCL Contact with Primary Contact = false* 
        }            
        
        accResult = [SELECT Id//,Primary_Contact__c 
                     FROM Account
                     WHERE ID =:MSLconObj2.AccountId];
        //System.assertEquals(MSLconObj2.Id ,accResult.Primary_Contact__c); 
        
        Test.stopTest();
    }
    
    
    /*
* When SCL Contact's Primary_Contact__c is set to false, update Account's SCL_Primary_Contact__c to null
* When SCL Contact's Primary_Contact__c is set to true, update Account's SCL_Primary_Contact__c to Contact's Id
* (Condition where only Single SCL Contact exist for Account)
*/
    /*   static testmethod void changeSCLPrimaryContactToFalse(){

String SCLconObj3Email = 'QwertySCL3@gmail.com';
User RunUser = UserDataGeneratorHelper_Test.SCLIntegrationUser;
//Contact SCLconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,ClientAccount.Id,SCLconObj3Email,true,false,RunUser);//Create SCL Contact-Primary flag=true
Contact SCLconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SAFMARINE,ClientAccount.Id,SCLconObj3Email,RunUser);//Create SCL Contact
//SCLconObj3.Primary_Contact__c = false; 
TriggerRecursionCounter.IsInsideContactTrigger = false;

Test.StartTest(); 
System.runAs(UserDataGeneratorHelper_Test.SCLIntegrationUser){

Database.Update(SCLconObj3); //Update SEA Contact with Primary Contact = false

}

Account accResult = [SELECT Id//,SCL_Primary_Contact__c 
FROM Account
WHERE ID =:SCLconObj3.AccountId];
//System.assertEquals(null ,accResult.SCL_Primary_Contact__c); //Verify that Account's SCL_Primary_Contact__c is updated to null

//SCLconObj3.Primary_Contact__c = true; 

System.runAs(UserDataGeneratorHelper_Test.SCLIntegrationUser){
Database.Update(SCLconObj3); //Update SCL Contact with Primary Contact = false*
} 
Test.stopTest();        

accResult = [SELECT Id//,SCL_Primary_Contact__c 
FROM Account
WHERE ID =:SCLconObj3.AccountId];
//System.assertEquals(SCLconObj3.Id ,accResult.SCL_Primary_Contact__c); 
}
*/
    
    /*
* When SEA Contact's Primary_Contact__c is set to false, update Account's SEA_Primary_Contact__c to null
* When SEA Contact's Primary_Contact__c is set to true, update Account's SEA_Primary_Contact__c to Contact's Id
* (Condition where only Single SEA Contact exist for Account)
*/    
    static testmethod void changeSEAPrimaryContactToFalse(){        
        
        String SEAconObj3Email = 'QwertySEA3@gmail.com';
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusersealand@maersk.com' LIMIT 1];
        //Contact SEAconObj3 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEALAND,ClientAccount.Id,SEAconObj3Email,true,false,RunUser);//Create SEA Contact-Primary flag=true
        Contact SEAconObj3 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSealand'];
        //SEAconObj3.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        Test.StartTest();
        System.runAs(RunUser){
            
            Database.Update(SEAconObj3); //Update second MSL Contact with Primary Contact = false
            
        }
        
        Account accResult = [SELECT Id//,SEA_Primary_Contact__c 
                             FROM Account
                             WHERE ID =:SEAconObj3.AccountId];
        //System.assertEquals(null,accResult.SEA_Primary_Contact__c); //Verify that Account's SEA_Primary_Contact__c is null 
        
        
        //SEAconObj3.Primary_Contact__c = true; 
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        System.runAs(RunUser){
            
            Database.Update(SEAconObj3); //Update second MSL Contact with Primary Contact = false
            
        }    
        Test.stopTest();
        
        accResult = [SELECT Id//,SEA_Primary_Contact__c 
                     FROM Account
                     WHERE ID =:SEAconObj3.AccountId];
        //System.assertEquals(SEAconObj3.Id, accResult.SEA_Primary_Contact__c);
    }
    
    
    /*PR-0055-Start
* When the first Seago contact is inserted,update the Primary_Contact__c to true
*/ 
    static testmethod void ChangeSeagoContactToPrimary(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationuserseago@maersk.com' LIMIT 1];
        //Contact SGLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEAGO,ClientAccount.Id,SGLconObj1Email,true,false,RunUser);//Create SEA Contact
        Contact SGLconObj1 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSeago'];
        //SGLconObj1.Primary_Contact__c = false;
        // System.debug('************Contact Name :'+SGLconObj1.Name+'Primary Contact:'+SGLconObj1.Primary_Contact__c);
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        Test.startTest();
        System.runAs(RunUser){
            
            Database.Update(SGLconObj1); //Update first Seago Contact with Primary Contact = false
            
        } 
        
        Account accResult1 = [SELECT Id//,Seago_Primary_Contact__c 
                              FROM Account
                              WHERE ID =:SGLconObj1.AccountId];
        //System.assertEquals(null,accResult1.Seago_Primary_Contact__c); 
        
        /*
* When Seago Contact's Primary_Contact__c is set to false, update Account's Seago_Primary_Contact__c to null
* When Seago Contact's Primary_Contact__c is set to true, update Account's Seago_Primary_Contact__c to Contact's Id
* (Condition where only Single Seago Contact exist for Account)
*/  
        //SGLconObj1.Primary_Contact__c = true;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        System.runAs(RunUser){
            
            Database.Update(SGLconObj1); //Update first Seago Contact with Primary Contact = false
            
        } 
        Test.stopTest();
        Account accResult3 = [SELECT Id//,Seago_Primary_Contact__c 
                              FROM Account
                              WHERE ID =:SGLconObj1.AccountId];
        //System.assertEquals(SGLconObj1.Id,accResult3.Seago_Primary_Contact__c); 
        
    } 
    
    
    /*
* Update Seago Contact with Primary_Contact__ = true/false to check Account's Seago_Primary_Contact__c getting updated
* and other Contacts in same Account with same Liner brand is updated with Primary_Contact__c = false
* (Multiple Seago Contacts exist for Account)
*/
    static testmethod void SeagoPrimaryContactUpdate(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationuserseago@maersk.com' LIMIT 1];
        //Contact SGLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEAGO,ClientAccount.Id,SGLconObj1Email,false,true,RunUser);
        Contact SGLconObj1 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSeago'];
        
        //Contact SGLconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.SEAGO,ClientAccount.Id,SGLconObj2Email,true,false,RunUser);
        Contact SGLconObj2 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactSeago'];
        //SGLconObj1.Primary_Contact__c = true; //Change previous Contact's Primary_Contact__c from false to true.
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        Test.StartTest();
        System.runAs(RunUser){
            
            Database.update(SGLconObj1); //Update Contact
            
        }  
        
        Account accObj = [SELECT Id//,Seago_Primary_Contact__c 
                          FROM Account
                          WHERE ID =:SGLconObj1.AccountId];
        
        //System.assertEquals(SGLconObj1.Id, accObj.Seago_Primary_Contact__c); //Verify that Account's Seago_Primary_Contact__c is updated
        
        //SGLconObj1.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        System.runAs(RunUser){
            
            Database.update(SGLconObj1); //Update Contact
            
        }
        Test.stopTest();
        
        accObj = [SELECT Id//,Seago_Primary_Contact__c 
                  FROM Account
                  WHERE ID =:SGLconObj1.AccountId];
        //System.assertEquals(null, accObj.Seago_Primary_Contact__c);//Verify that Account's Seago_Primary_Contact__c becomes null
    }
    
    
    static testmethod void ChangeMCCContactToPrimary(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        //Contact MCCconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MCC,ClientAccount.Id,MCCconObj1Email,true,false,RunUser);//Create SEA Contact
        Contact MCCconObj1 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        //MCCconObj1.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        Test.startTest();
        System.runAs(RunUser){
            
            Database.Update(MCCconObj1); //Update first Seago Contact with Primary Contact = false
            
        } 
        
        Account accResult1 = [SELECT Id//,MCC_Primary_Contact__c 
                              FROM Account
                              WHERE ID =:MCCconObj1.AccountId];
        //System.assertEquals(null,accResult1.MCC_Primary_Contact__c); 
        
        /*
* When Seago Contact's Primary_Contact__c is set to false, update Account's Seago_Primary_Contact__c to null
* When Seago Contact's Primary_Contact__c is set to true, update Account's Seago_Primary_Contact__c to Contact's Id
* (Condition where only Single Seago Contact exist for Account)
*/  
        //MCCconObj1.Primary_Contact__c = true;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        System.runAs(RunUser){
            
            Database.Update(MCCconObj1); //Update first Seago Contact with Primary Contact = false
            
        } 
        Test.stopTest();
        Account accResult3 = [SELECT Id//,MCC_Primary_Contact__c 
                              FROM Account
                              WHERE ID =:MCCconObj1.AccountId];
        //System.assertEquals(MCCconObj1.Id,accResult3.MCC_Primary_Contact__c); 
    } 
    
    
    /*
* Update MCC Contact with Primary_Contact__ = true/false to check Account's MCC_Primary_Contact__c getting updated
* and other Contacts in same Account with same Liner brand is updated with Primary_Contact__c = false
* (Multiple Seago Contacts exist for Account)
*/
    static testmethod void MCCPrimaryContactUpdate(){
        
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        //Contact MCCconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MCC,ClientAccount.Id,MCCconObj1Email,false,true,RunUser);
        Contact MCCconObj1 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        
        //Contact MCCconObj2 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MCC,ClientAccount.Id,MCCconObj2Email,true,false,RunUser);
        Contact MCCconObj2 = [SELECT Id, Email, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk'];
        //MCCconObj1.Primary_Contact__c = true; //Change previous Contact's Primary_Contact__c from false to true.
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        Test.StartTest();
        System.runAs(RunUser){
            
            Database.update(MCCconObj1); //Update Contact
            
        } 
        
        Account accObj = [SELECT Id//,MCC_Primary_Contact__c 
                          FROM Account
                          WHERE ID =:MCCconObj1.AccountId];
        
        //System.assertEquals(MCCconObj1.Id, accObj.MCC_Primary_Contact__c); //Verify that Account's MCC_Primary_Contact__c is updated
        
        //MCCconObj1.Primary_Contact__c = false;
        TriggerRecursionCounter.IsInsideContactTrigger = false;
        
        System.runAs(RunUser){
            
            Database.update(MCCconObj1); //Update Contact
            
        }
        Test.stopTest(); 
        
        accObj = [SELECT Id//,MCC_Primary_Contact__c 
                  FROM Account
                  WHERE ID =:MCCconObj1.AccountId];
        //System.assertEquals(null, accObj.MCC_Primary_Contact__c);//Verify that Account's Seago_Primary_Contact__c becomes null   
    }
    
    
    /*
Test method for #RQ-000946, #RQ-001857 changes
1. To update  the Contact Liner Brand field if the Owner is a single branded user
2. To update  Contact's Unique_Email_Address__c field for customer contacts and internal contacts   
*/
    static testMethod void updateLinerBrandandUniqueEmailAddress() {
        
        String MSLconObj1Email = 'QwertyMSL1@test.com';
        User RunUser = [SELECT Id, Email FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        //Contact MSLconObj1 =ContactDataGeneratorHelper_Test.createCustomerContact(BrandUtilities.MAERSKLINE,ClientAccount.Id,MSLconObj1Email,false,true,RunUser);//Create MSL Contact
        Contact MSLconObj1 = [SELECT Id, Email, Liner_Brands__c,Unique_Email_Address__c, AccountId FROM Contact WHERE LastName = 'CustomerContactMaersk']; //Third_Party_Contact
        Contact nonShippingContact = [SELECT Id, Email, Liner_Brands__c, AccountId FROM Contact WHERE LastName = 'ThirdPartyContact']; // v8.0 #RQ-005057
        MSLconObj1.Liner_Brands__c = null;
        
        
        
        Test.StartTest(); 
        System.runAs(RunUser){
            try{
                Database.Update(MSLconObj1); //Update the Contact
            }catch(Exception ex){
                System.debug('Exception occurred');
            }
            system.debug('MSLconObj1'+ MSLconObj1.Email);
            Contact customerContactSingleBrand = [SELECT Id,Email, Liner_Brands__c, Unique_Email_Address__c, AccountId FROM Contact WHERE Id =: MSLconObj1.Id]; 
            system.debug('customerContactSingleBrand'+ customerContactSingleBrand.Email);
            System.assertEquals(customerContactSingleBrand.Liner_Brands__c, BrandUtilities.MAERSKLINE);
            System.assertEquals(customerContactSingleBrand.Unique_Email_Address__c, 'thirdpartycontactmaerskline@test.com');// v8.0 #RQ-005057
            
            // v8.0 (Start): RQ-005057
            Contact nonShippingContactSingleBrand = [SELECT Id, Liner_Brands__c, Unique_Email_Address__c, AccountId FROM Contact WHERE Id =:nonShippingContact.Id];
            
            System.assertEquals(nonShippingContactSingleBrand.Liner_Brands__c, BrandUtilities.MAERSKLINE);
            // v8.1 : #RQ-007579  (All the contacts are deduped, no need of linerbrand-email combination in Unique_Email__c field)
            System.assertEquals(nonShippingContactSingleBrand.Unique_Email_Address__c, 'thirdpartycontactmaerskline@test.com');
            
            nonShippingContact.Deduped_Contact__c = True;
            update nonShippingContact;
            Contact nonShippingContWithMultipleBrands = [SELECT Id, Liner_Brands__c, Unique_Email_Address__c, AccountId FROM Contact WHERE Id =:nonShippingContact.Id];  
            
            System.assertEquals(nonShippingContWithMultipleBrands.Unique_Email_Address__c, 'thirdpartycontactmaerskline@test.com');
            // v8.0 (End): RQ-005057
        }
        
        System.runAs(RunUser){
            //System.debug('UnAssignedAccount.RecordTypeId: ' + UnAssignedAccount.RecordTypeId);
            
            Contact conNonShipping1 = [SELECT Id, Email, Liner_Brands__c, AccountId FROM Contact WHERE LastName = 'InternalContact'];//Create internal contact. #RQ-003041
            
            for(Contact con1 : [SELECT Id, Unique_Email_Address__c, AccountId FROM Contact WHERE Id =: conNonShipping1.Id]){
                System.assertEquals(con1.Unique_Email_Address__c, 'internalcontactmaerskline@maerskline.com');
            }
            
            conNonShipping1.email = 'InternalContact1@sealandmaersk.com';        
            Database.Update(conNonShipping1); // Update the Contact        
            
            for(contact con2 : [SELECT Id, Unique_Email_Address__c, AccountId FROM Contact WHERE Id =: conNonShipping1.Id]){
                System.assertEquals(con2.Unique_Email_Address__c, 'internalcontact1@sealandmaersk.com');
            }
            
            conNonShipping1.AccountId = MSLconObj1.AccountId;
            try{
                database.update(conNonShipping1,false);
            }
            catch(Exception e){
                System.assert(ApexPages.GetMessages().get(0).getSummary().contains(Label.AddOnlyUnassignedAccounts));
            }
            Test.stopTest(); 
        }
    }
    
    @isTest
    static void updateContactBulk() {
        List<Contact> customerContacts = [SELECT Id FROM Contact where LastName like 'CustomerContactMaersk%'];
        System.debug('customerContacts size '+customerContacts.size());
    }
    
    @isTest 
    static void assignedAccountsToContacts(){
        User RunUser = [SELECT Id,Name, Email,ProfileId,LastName FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        Validation_Rules_Bypass__c customSetting = new  Validation_Rules_Bypass__c(); 
        customSetting = Validation_Rules_Bypass__c.getInstance(RunUser.ProfileId);
        customSetting.Active__c = true;
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        Account acc = [select Id,Customer_Code__c,Customer_Group__c from Account limit 1]; 
        list<Id> conId = new list<Id>();
            Contact ContacttoInsert = TestBusinessHelper.createContact(clientAccount,'Customer_Contact', BrandUtilities.MAERSKLINE, false);
            ContacttoInsert.Id = null;
            ContacttoInsert.AccountId = null;   
            ContacttoInsert.LastName = 'Test Cmd contact';
            ContacttoInsert.Customer_Code__c = '123456';
            ContacttoInsert.Contact_Status__c = 'Inactive';
            ContacttoInsert.Email = 'Testuser@gmail.com';
            Test.startTest();
            TriggerExecutionController.skipAllTriggers(false);
            insert customSetting;
            System.runAs(RunUser){
            insert ContacttoInsert;
            }   
            List<Contact> conlist = [Select Id,name,AccountId,Customer_Code__c,RecordType.DeveloperName,Email,Contact_Status__c from Contact where Id =: ContacttoInsert.id];
            System.debug('conlist'+ conlist);
            acc.Customer_Code__c = '123456';    
            Update acc;
            Test.StopTest();
            List<Account> acclist = [Select Id,name,Customer_Code__c from account]; 
            List<Contact> conlist1 = [Select Id,name,Contact_Status__c,AccountId,Customer_Code__c from Contact where AccountId!= null] ;
            for(Contact c : conlist1){
                conId.add(c.id); 
            }
            System.assertEquals(conlist1[0].Contact_Status__c, 'Active'); 
             
        }     
    
    @isTest 
    static void AssignedAccountsToConntactBatch(){
      User RunUser = [SELECT Id, Email,Name,ProfileId FROM User WHERE Email = 'integrationusermaersklinemaerskls@maersk.com' LIMIT 1];
        Account clientAccount = TestBusinessHelper.createAccount('Client_Account', false);
        Validation_Rules_Bypass__c customSetting = new  Validation_Rules_Bypass__c(); 
        customSetting = Validation_Rules_Bypass__c.getInstance(RunUser.ProfileId);
        customSetting.Active__c = true;
        System.debug('isActive' + customSetting.Active__c);
        TriggerExecutionController.skipAllTriggers(true);
        Account acc = [SELECT Id, Customer_Code__c, Customer_Group__c FROM Account LIMIT 1];
        acc.Customer_Code__c = '123456';    
        update acc;
        Test.startTest();
        insert customSetting;
        System.runAs(RunUser){
            Contact ContacttoInsert = TestBusinessHelper.createContact(clientAccount,'Customer_Contact', BrandUtilities.MAERSKLINE, false);
            ContacttoInsert.Id = null;
            ContacttoInsert.AccountId = null;   
            ContacttoInsert.LastName = 'Test Cmd contact';
            ContacttoInsert.Customer_Code__c = '123456';
            ContacttoInsert.Contact_Status__c = 'Inactive';
            ContacttoInsert.Email = 'Testuser@gmail.com';
            insert ContacttoInsert;
            String jobName = 'Test Batch Job'; // Specify a name for your scheduled job
            String schedule = '0 0 1 * * ?';
                Scheduler_BatchAssignContactsToAccounts batch = new Scheduler_BatchAssignContactsToAccounts();
                System.schedule(jobName, schedule, batch);
                List<Contact> conlist = [Select Id,name,AccountId,Customer_Code__c,Email,Contact_Status__c from Contact where Id =: ContacttoInsert.id];
            } 
            
            Test.StopTest(); 
            List<Account> acclist = [Select Id,name,Customer_Code__c from account]; 
            List<Contact> conlist1 = [Select Id,name,Contact_Status__c,AccountId,Customer_Code__c from Contact where AccountId!= null] ;
            TriggerExecutionController.skipAllTriggers(false);
            System.assertEquals(conlist1[0].Contact_Status__c, 'Active');
            
        }      
                   
}