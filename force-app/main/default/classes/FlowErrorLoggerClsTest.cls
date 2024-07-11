@isTest
public class FlowErrorLoggerClsTest {
    
        static testmethod void testFlowErrorLogger(){
            
            List<FlowErrorLoggerCls.ReturnVariables> flowValues=new List<FlowErrorLoggerCls.ReturnVariables>();
            List<string> strList = new List<string>();
            FlowErrorLoggerCls.ReturnVariables f1=new FlowErrorLoggerCls.ReturnVariables();
            
            List<string> error =new List<String>();
            error.add('This error occurred: FIELD_CUSTOM_VALIDATION_EXCEPTION: Please enter a valid country from the list held in the Geography');
            f1.flowMessage=error;
            flowValues.add(f1);
            //flowValues.add();
            test.startTest();
            	FlowErrorLoggerCls.callErrorLoggerClass(flowValues);
            test.stopTest();
            
            
        }
}