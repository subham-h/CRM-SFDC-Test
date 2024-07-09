/*
* Author   : Sreya@Maersk
* Purpose  : controller class for Accept_CaseController VF page     
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010129   12-03-2019  Sreya@Maersk            Class contains the logic for 'Accept Case' List View Button.
* 2.0      SC-1250     05-11-2019  Sainavya.yerrabelli@ust Traiged cases should not changed to In Progress so the condition is removed.
*/

public class Accept_CaseController {
    public String createAccount(String name){     
        Account acc = new Account();        
        acc.Name = name;        
        system.debug('account test');       
        return acc.Name;         
    }
    
}