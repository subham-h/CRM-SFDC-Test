/*
* Author   : Joao Mota
* Purpose  : Test class for Sales_Bot_Controller Class.
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0                  21-09-2022  Joao Mota               Created.
*/
@isTest
public class Sales_Bot_Controller_Test {
    
    @isTest public static void testController(){
        
        Test.startTest();   
        Sales_Bot_Controller salesBotCtrl = new Sales_Bot_Controller();
        
        System.assertEquals(String.isBlank(salesBotCtrl.script),FALSE); 
        Test.stopTest();        
    }

}