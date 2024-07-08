@isTest
public class ValidateRecordsTest {
    
    @IsTest(SeeAllData=true)
    static void testDataValidation(){
        User salesUser = TestBusinessHelper.createUser('Sales', BrandUtilities.MAERSKLINE, true);
        
        PermissionSet ps = [SELECT Id 
                            FROM PermissionSet 
                            WHERE Name = 'Live_Help_Permission_Set'];
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = ps.Id);
        }
        
        Boolean bErrors = false;
        String strExceptionDetails = '';
        List<String> errorMessageList = new List<String>();
        String query = 'SELECT Id FROM ';
        query = query + Label.Object_Name + ' ';
        query = query + Label.Condition;
        System.debug('query '+query);
        List<Sobject> records = Database.query(query);
        System.debug('records size '+records.size() );
        List<Database.SaveResult> result;
        Test.startTest();
        System.runAs(salesUser){
            result = Database.update(records, false);   
        }
        Test.stopTest();
        
        for(Integer i=0; i<result.size(); i++){
            Database.SaveResult sr = result[i];
            if(!sr.isSuccess()){
                for(Database.Error errorRec : sr.getErrors()) {
                    if(!bErrors){
                        bErrors = true;
                    }
                    strExceptionDetails = records[i].Id + ' => ' + errorRec.getMessage();
                    errorMessageList.add(strExceptionDetails);
                }
            }
        }
        
        System.debug('errorMessageList size '+errorMessageList.size());
        for(String errorRecord : errorMessageList){
            System.debug(errorRecord);
        }
    }
}