/**
* 
* Date         Owner                                                    Description
*************************************************************************************************************************************
* 12/08/2016   meghana.gupta@ust-global.com                Code Created
*/

@isTest
private class AuraResponse_Test extends AuraResponse{

    public AuraResponse_Test(){
        
        system.debug('test');
        
    }
    
    public AuraResponse_Test( Boolean isSuccess, String level, List<String> lstMessage ){
        
        super( isSuccess, level, lstMessage );
        
    }
    
    static testmethod void TestAuraResponse(){ 
        
        test.startTest();
        
        AuraResponse_Test response = new AuraResponse_Test();
        
        list<String> msgList = new List<String>();
        msgList.add('Test Failure');
        AuraResponse_Test response1 = new AuraResponse_Test( false, 'Error', msgList);
        
        test.stopTest();
    }
    
}