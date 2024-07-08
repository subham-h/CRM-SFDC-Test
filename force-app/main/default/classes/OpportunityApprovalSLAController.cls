/*      
* Revision    Ref Number    Date      Owner            Description
* --------    ----------    -----------    -------------------      -------------------------
* 1.0      SFSE-10739    24-May-2023    Neha@Maersk        Apex class for displaying and updating SLA for Opportunity Approvals
*/
public without sharing class OpportunityApprovalSLAController {
    
    public static List<Approval_Process__c> approvalProcess;

    // This method will get the SLA from Approval process based on the Gate and Sub Gate type comnbination
    @AuraEnabled
    public static List<Approval_Process__c> getSLAfromApprovalProcess( String gateType, String subgateType)
    {        
        String query = 'Select id,SLA__c from Approval_Process__c where Active__c =true AND  SLA__c != null';
        if(gateType != null){
            query += ' and Gate__c =: gateType ';
        }

        if(subgateType != null){
            query += ' and Sub_Gate__c =: subgateType';
        }       
        approvalProcess = Database.query(query);
       return approvalProcess;
    }

    // This method will get the updated SLA to display in read only mode
    @AuraEnabled
    public static List<Approval_Process__c> getUpdatedSLA( String recordId)
    {        
        String query = 'Select id,SLA__c,Gate__c,Sub_Gate__c from Approval_Process__c where id  =: recordId';
        approvalProcess = Database.query(query);
       return approvalProcess;
    }

    // This method will would update the SLA on approval process records once user change them from UI
    @AuraEnabled
    public static String updateSLA( String recordId, String slaValue,String gateName, String subgateType)
    {
        try{
            List<Approval_Process__c> apList = getSLAfromApprovalProcess(gateName,subgateType);

            for(Approval_Process__c apObj:  apList){
                apObj.SLA__c = Decimal.valueOf(slaValue);               
                
            }
            update apList;
        }catch(Exception e){
            return 'ERROR';
        }
       
        return 'SUCCESS';
       
    }
}