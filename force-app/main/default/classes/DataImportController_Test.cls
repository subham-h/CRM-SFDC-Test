@istest
public class DataImportController_Test {
	
    @istest
    public static void uploadDataTest(){
       String config ='Territory_Account_Association';
       String data;
       String operation ='Create'; 
        Account clientAcc = AccountDataHelper_Test.createClientAccount();
       
        //data ='[["Account Concern Code","Territory Name","Brand","Account Name","Key Client","Portfolio Owner Responsibility"],["Test,"Aleena Akthar","Maersk Line","AccountName","TRUE","Sales Owner"],["Test","Shubham Jain","Maersk Line","D8ZSESHUMAXD8ZS","TRUE","Sales Owner"]]';
        data ='[["Account Concern Code","Territory Name","Brand","Account Name","Key Client","Portfolio Owner Responsibility"],["Test","Aleena Akthar","Maersk Line","';
		data+=clientAcc.Name+'","TRUE","Sales Owner"],["Test","Shubham Jain","Maersk Line","';
		data+=clientAcc.Name+'","TRUE","Sales Owner"]]';
       Test.startTest();
        DataImportController.uploadData(config, operation, null);
       Test.stopTest(); 
    }
    
    @isTest
    static void test1() {
        //List<Map<String,String>> configList = DataImportController.getConfigs();
        List<Data_Import_Setup__mdt> configList = DataImportController.getConfigs();
        DataImportController.getConfiguration('Territory_Account_Association');
        String headers = '["Account Concern Code","Territory Name","Brand","Account Name","Key Client","Portfolio Owner Responsibility"]';
        String config ='Territory_Account_Association';
        String message = DataImportController.validateHeaders(config,headers);
        DataImportController.getReportId();
    }
}