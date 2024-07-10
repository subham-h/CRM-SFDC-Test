/* 
 * Author   : Hitha
 * Purpose  : To restrict deletion of Customer Contacts
 * 
 * Revision     Ref Number      Date            Owner                         Description
 * --------     ----------      -----------     -------------------           -----------
 * 1.0          RQ-004708       02-Feb-2017     Hitha@UST                     Display error messgae when user tries to delete Customer Contact
 */
public class ContactValidator{

    public static void DisplayErrorOnContact(list<Contact> lstCustomerContacts){
        for (Contact con: lstCustomerContacts){
            con.addError(Label.Add_Error_Do_Not_Delete_Customer_Contact);
         }
    }
}