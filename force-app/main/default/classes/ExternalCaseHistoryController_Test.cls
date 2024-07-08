/*
 * Created By   : Shahanawaz@Maersk
 * Purpose  : Test class for ExternalCaseHistoryController LWC controller 
 *              
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      #SC-9190    25-Oct-2023 Shahanawaz@Maersk       Created
 * 
*/
@isTest
public class ExternalCaseHistoryController_Test {
    
    @isTest
    public static void testExternalCaseHistoryRetrieval(){
        ExternalCaseHistoryController.getCaseHistoryList(null);
    }

}