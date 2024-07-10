/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		05-April-2023		Aleena@maersk	    To map customer size field in account
*/
@isTest
public class CustomerSizingEventHandler_Test {
     @isTest 
    static void testValidCustomerEvent() {
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();

       
        clientAcc.Customer_Code__c='VN00829522';
        
  
        
        Update clientAcc;
        String jsonStr= '{"alternativeCode": "11100150622","alternativeCodeTypeCode": "SCV","customerCode": "VN00829522","segmentType": "Small company"}';    
        Customer_Sizing_Message__e customerSizingEvent = new Customer_Sizing_Message__e(JSON_1__c = jsonStr);
        Test.startTest();

        // Publish test event
        Database.SaveResult sr = EventBus.publish(customerSizingEvent);

        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    
    }
    @isTest 
    static void testValidCustomerEvent1() {
        
        Account clientAcc = AccountDataHelper_Test.createClientAccount();

        Update clientAcc;
        String jsonStr= '{"alternativeCode": "11100150622","alternativeCodeTypeCode": "SCV","customerCode": "BN00829522","segmentType": "Small company"}';    
        Customer_Sizing_Message__e customerSizingEvent = new Customer_Sizing_Message__e(JSON_1__c = jsonStr);
        Test.startTest();

        // Publish test event
        Database.SaveResult sr = EventBus.publish(customerSizingEvent);

        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    
    }


}