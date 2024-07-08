/**
 * Author   : Sidhartha
 *        
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-008771   09/08/2018  sidhartha               Code created
 * 2.0      SPI-100     08/06/2022  Ronnie@SF               Removed brand hardcoding
 * 
 */
@isTest
public class ContactSendLogCtrlTest {
    
    public static testMethod void getEmailFuncAdd() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.SCV_Code__c = 'SCV12344';  
        insert acc;
        
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'first';
        cont.LastName = 'last';
        cont.Email = 'Qwerty@gmail.com';
        cont.Liner_Brands__c = BrandUtilities.MAERSKLINE;
        insert cont;
        ContactSendLogCtrl csLCtrl = new  ContactSendLogCtrl(new ApexPages.StandardController(cont));
        csLCtrl.checkuniqueEmailDomain();
    }
}