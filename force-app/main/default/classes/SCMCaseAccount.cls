/*
* Author   : Shahanawaz@maersk.com
* Purpose  : to be updated
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-5430    29-11-2022   Shahanawaz                Created.
*/

@RestResource(urlmapping = '/scmcaseaccountextraction')
global class SCMCaseAccount {
    
    public static General_Key_Value_Configurations__mdt response = General_Key_Value_Configurations__mdt.getInstance('IntegrationLogResult');
    public static General_Key_Value_Configurations__mdt custmerNameResponse = General_Key_Value_Configurations__mdt.getInstance('IDACustomerNameResponse');
    public static General_Key_Value_Configurations__mdt sONumberResponse = General_Key_Value_Configurations__mdt.getInstance('IDASONumberResponse');
    
    @HttpPost
    global static void doPost(){
        String resList;
        try{
            RestRequest req = RestContext.request;
            blob body = req.requestBody;
            System.debug('body' + body);
            string requestbody = body.toString().trim();
            System.debug('requestbody' + requestbody);
            RestResponse res = RestContext.response;
            resList = String.valueOf(res);
            ResponseWrapper resWrap = (ResponseWrapper) JSON.deserialize(requestbody.trim() ,ResponseWrapper.class); 
            System.debug('Response' + resWrap);
            String customerName = resWrap.CustomerName_db != null ? resWrap.CustomerName_db.trim() : '';
            String soNumber = resWrap.SoNumber.trim();
            system.debug('after trim'+customerName+'--'+soNumber);
            
            if(resWrap.CustomerName_db!= null && resWrap.CustomerName_db == custmerNameResponse.First_Field_Value__c){
                customerName = response.First_Field_Value__c;
            }
            if(resWrap.CustomerName_db!= null && resWrap.CustomerName_db == custmerNameResponse.Second_Field_Value__c){
                customerName = response.Second_Field_Value__c;
            }
            if(resWrap.SoNumber == sONumberResponse.First_Field_Value__c){
                soNumber = response.First_Field_Value__c;
            }
            if(resWrap.SoNumber == sONumberResponse.Second_Field_Value__c){
                soNumber = response.Second_Field_Value__c;
            }  
            
            PopulateNonKeyClientCase.populateAccountDetails(resWrap.caseId, soNumber, customerName, resWrap.CustomerName_extracted);
       
        }catch(Exception ex) {
            
            //ErrorLogger.writeErrors('SFDC', 'Case', 'SCMCaseAccount.dopost', new list<Exception>{ex});  
	        ErrorLogger.writeError('SFDC', 'Case', 'SCMCaseAccount.dopost','Unknown exception',resList,ex.getMessage() );

            
        }
    }
    
    public class ResponseWrapper{
        public String caseId;
        public String SoNumber;
        public String CustomerName_extracted;
        public String CustomerName_db;
    }
    
}