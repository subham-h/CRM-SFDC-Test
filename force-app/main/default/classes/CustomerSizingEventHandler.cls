/*  
* Version	Date			Owner					Description
* --------	-----------		-------------------		-----------
* 1.0		05-April-2023		Aleena@maersk	   SFSE-10198-To map customer size field in account
*/
public class CustomerSizingEventHandler {
    public static list<Account> lstAccountUpdate = new List<Account>();
    public static Set<String> setofCustomercode = new Set<String>();
    public static Set<String> setofexistCustomercode = new Set<String>();
    public String jsonSTR;
    
    public void onAfterInsert(List<Customer_Sizing_Message__e>custSizingEventMessList){
        List<CustomerSizingWrapper> deserializedData = new List<CustomerSizingWrapper>();
        for(Customer_Sizing_Message__e custSizing:custSizingEventMessList){
            if(custSizing.JSON_1__c!=null){
                jsonSTR = custSizing.JSON_1__c;
                deserializedData.add(parse(jsonSTR));
            }
        }
        lstAccountUpdate = updateAccount(deserializedData);
        list<Batch_Error_Logger__c> lstOfGlobalErrorLogger = new List<Batch_Error_Logger__c>();
        try {
            if(!setofCustomercode.isEmpty()){
                system.debug('sets'+ setofCustomercode);
                for(String s:setofCustomercode){
                    Batch_Error_Logger__c b = new Batch_Error_Logger__c();
                    b.Name='SFDC:Account-Customer Sizing - ' + System.now().format();
                    b.Batch_Name__c='CustomerSizingEventHandler';
                    b.Operation_Type__c='insert';
                    b.Exception_Summary__c=s+'Customer Code is missing';
                    lstOfGlobalErrorLogger.add(b);
                }
                insert lstOfGlobalErrorLogger;
            }
            if(lstAccountUpdate.size() > 0 && !lstAccountUpdate.isEmpty()) {
                Database.SaveResult[] srList = Database.update(lstAccountUpdate, false);
                ErrorLogger.writeErrors('SFDC', 'Customer Sizing', 'CustomerSizingEventHandler.onAfterInsert', srList, lstAccountUpdate);
                
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ErrorLogger.writeErrors( 'SFDC', 'Customer Sizing', 'CustomerSizingEventHandler.onAfterInsert', new list<Exception>{e});  
        }
    }
    
    
    public static CustomerSizingWrapper parse(String jsonSTR){
        CustomerSizingWrapper cst = (CustomerSizingWrapper)JSON.deserialize(jsonStr, CustomerSizingWrapper.class);
        return cst;
    }
    
    public static List<Account> updateAccount(List<CustomerSizingWrapper> custSizewrp){
        Map<String,String> mapofCustomercodetoSize = new Map<String,String>();
        for(CustomerSizingWrapper cst : CustSizewrp ){
            if(cst.customerCode != null){
            mapofCustomercodetoSize.put(cst.customerCode,cst.segmentType);
                setofCustomercode.add(cst.customerCode);
            }
        }
        List<Account> lstOfAccountCstmrCode = [Select id,Customer_Code__c,Customer_Size__c from Account where Customer_Code__c in:mapofCustomercodetoSize.keySet()];
        System.debug(lstOfAccountCstmrCode);
        for(Account a : lstOfAccountCstmrCode) { 
            setofexistCustomercode.add(a.Customer_Code__c);
            a.Customer_Size__c=mapofCustomercodetoSize.get(a.Customer_Code__c); 
            System.debug(a.Customer_Size__c);
        }
        setofCustomercode.removeAll(setofexistCustomercode);
        System.debug('set'+setofCustomercode);
        
        return lstOfAccountCstmrCode; 
    } 
    
    Public class CustomerSizingWrapper {
        Public String customerCode{get;set;}
        Public String segmentType{get;set;}
    }
}