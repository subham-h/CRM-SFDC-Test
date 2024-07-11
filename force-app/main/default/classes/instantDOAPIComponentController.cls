/*
Description : This will call instantDO api and poll current status from instantDO API for 2 mins in every 20 seconds.Based on response we will Approve workflow status.

Version         Date            Owner                                   Description
V1.0            08/03/2021      sandeep.sankhla@maersk.com              Perform InstantDO post and get call for writ into gcss and do polling.
*/
public with sharing class instantDOAPIComponentController {

     /*
        Method Name:    getBOLNumber
        Parameters:     workflow Id.
        Description:    This method will get the bol number from workflow which will be later used for post and get call.
        RQ:             DOR-4331
    */
    @AuraEnabled
    public static DO_APIUtility.responseWrapper getBOLNumber(String strWorkflowId) {
        DO_APIUtility.responseWrapper obj = new DO_APIUtility.responseWrapper();
        for(Agent_Workflow__c objAW: [Select B_L_number__c, OwnerId, Case_ID__c from Agent_Workflow__c where Id =:strWorkflowId]){
            obj.strBOLNumber = objAW.B_L_number__c;
            obj.strCaseId = objAW.Case_ID__c;
            obj.strOwnerId = objAW.OwnerId;
        } 
        
        return obj;
    }
    
     /*
        Method Name:    postInstantDO
        Parameters:     workflow Id & BillofLading Id.
        Description:    This method will make a post call to write into GCSS API.
        Return:         This method will return wrapper object which will contain customerCode, DeliveryOrderId, CarrierCode and success and error message from API call with status code.
    */
     @AuraEnabled
    public static DO_APIUtility.responseWrapper postInstantDO(String strWorkflowId, String strBOLNumber) {
         
        string strObjectName = 'InstantDOWorkflow';
        string strModuleName = 'postInstantDO';
        //Get Request details from metadata.
        AO_Services__mdt custommetadata = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, strModuleName);               
        
        if(custommetadata != null){
            
            DO_APIUtility.responseWrapper objRW =  DO_APIUtility.sendInstantDOHTTPRequest(strWorkflowId, strBOLNumber, custommetadata);
            return objRW;
        }
        else{
            
            DO_APIUtility.responseWrapper objRW = new  DO_APIUtility.responseWrapper();
            objRW.strStatusCode = 'CMDM';
            objRW.strMessage = 'Custom Meta Data Configuration missing';
            return objRW;
        }
        
       
    }
    /*
     @AuraEnabled
    public static DO_APIUtility.responseWrapper getInstantDOStatus(String bOLNumber, string deliveryOrderId, string carrierCode, string customerCode) {
        
        string strObjectName = 'InstantDOWorkflow';
        string strModuleName = 'postInstantDO';
        //Get Request details from metadata.
        AO_Services__mdt custommetadata = WebserviceUtilities.getAOServicesMetadataValue(strObjectName, strModuleName);               
        
        
        DO_APIUtility.responseWrapper objRW = DO_APIUtility.getInstantDOStatus(bOLNumber, deliveryOrderId, carrierCode, customerCode, custommetadata);
        return objRW;
    }
    */
    @AuraEnabled
    public static DO_APIUtility.responseWrapper updateWorkflowNParent(String strAWId, string strCaseId, boolean isApproved, string strOwnerId) {
         
        DO_APIUtility.responseWrapper objRW = new  DO_APIUtility.responseWrapper();
        
        if(isApproved){
            try{
                
                Agent_Workflow__c objAW = new Agent_Workflow__c(Id = strAWId, Status__c = 'Approved');
                update objAW;
                
                Case objCase = new Case( Id = strCaseId, Status = 'Closed - Resolved', Resolution_Summary__c = System.Label.DO_Approval_Resolution_Summary);
            
           
                update objCase;
                objRW.strMessage = 'Case & Workflow Updated Successfully';
                objRW.strStatusCode = 'SUCCESS';
            }
            catch(Exception e){
                System.debug('error:'+e.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'DO_APIUtility', new list<Exception>{e});
                if(e.getMessage().contains('Please enter a Contact before progressing')){
                    objRW.strMessage = 'Please provide Contact details before closing case.';
                }
                else{
                    objRW.strMessage = e.getMessage();
                }
                
                objRW.strStatusCode = 'Error';
               
            }
            return objRW;
        }
        else{
            
            Case objCase = new Case( Id = strCaseId, Reason_For_Case__c = 'Release Delivery Order/Container Release');
            try{
                Agent_Workflow__c objAW = new Agent_Workflow__c(Id = strAWId, Status__c = 'Approved');
                update objAW;
                
                update objCase;
                objRW.strMessage = 'Reason for case is updated succesfully';
                objRW.strStatusCode = 'SUCCESS';
            }
            catch(Exception e){
                System.debug('error:'+e.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'DO_APIUtility', new list<Exception>{e});
                objRW.strMessage = e.getMessage();
                objRW.strStatusCode = 'Error';
               
            }
            return objRW;
        }
    }
    
    @AuraEnabled
    public static DO_APIUtility.responseWrapper rejectWorkflow(String strAWId, string strCaseId, string strOwnerId) {
      DO_APIUtility.responseWrapper objRW = new  DO_APIUtility.responseWrapper();
         try{
             
             Agent_Workflow__c objAW = new Agent_Workflow__c(Id = strAWId, Status__c = 'Rejected', Admin_Comments__c = 'AgentWorkflow is Rejected by Agent.', Rejection_Reason__c = 'Others');
             update objAW;
             
             Case objCase = new Case( Id = strCaseId, Status = 'Closed - Resolved', Resolution_Summary__c = 'Document submitted by you is not approved, please contact customer service for more details');
            
           
                update objCase;
                objRW.strMessage = 'Case & Workflow Updated Successfully';
                objRW.strStatusCode = 'SUCCESS';
            }
            catch(Exception e){
                System.debug('error:'+e.getMessage());
                ErrorLogger.writeErrors( 'SFDC', 'Case', 'DO_APIUtility', new list<Exception>{e});
                objRW.strMessage  = e.getMessage();
                objRW.strStatusCode = 'Error';
            }
                
               
        return objRW;
    
    }
    
    
}