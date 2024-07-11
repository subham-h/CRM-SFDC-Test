/*
 * This is test class for loopioRequestAccessCtrl
 */ 
@isTest(seeAllData=false)
public class loopioRequestAccessCtrlTest {
    
    @istest
    static void testLoopioAccess(){
        if ( UserDataGeneratorHelper_Test.salesUser == null ){
            UserDataGeneratorHelper_Test.initializeSalesUser();
        } 
        system.runAs(UserDataGeneratorHelper_Test.SalesUser){
            loopioRequestAccessCtrl.assignLoopioPermissionSet();
        }
    }
}