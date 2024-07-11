/*
* Author   : Sreya@Maersk
* Purpose  : controller class for Accept_CaseController VF page     
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-010129   12-03-2019  Sreya@Maersk            Class contains the logic for 'Accept Case' List View Button.
* 2.0      SC-1250     05-11-2019  Sainavya.yerrabelli@ust Traiged cases should not changed to In Progress so the condition is removed.
*/

public class Accept_CaseController {
    ApexPages.StandardSetController standardSetController;
    
    public string acceptMessages{get;set;}
    
    public Accept_CaseController(ApexPages.StandardSetController standardSetController){
        acceptMessages = ' ';
        this.standardSetController = standardSetController;
        System.debug('feature2 chnages');
    }


    
    public void getMessage(){
        List<Case> listViewRecords =(List<Case>) standardSetController.getRecords();
        
        // get the selected cases from the list view
        List<Case> selectedListViewRecords = (List<Case>) standardSetController.getSelected();
        
        //Query for the required fields for the selected records
        Map<Id,Case> lstSelectedRecords = new Map<Id,Case>();       
        for(Case objCS : [select Id,CaseNumber,Status,Subject,OwnerId,Owner.Type,Type,Sub_Type__c,RecordTypeId,RecordType.DeveloperName from case where id in: selectedListViewRecords])
        { 
            lstSelectedRecords.put(objCS.Id, objCS);
        }  
        
        String rejectedCaseNumbers = '';
        List<Case> casesToUpdate = new List<Case>();
        String acceptedCaseNumbers = '';
        String errorCaseNumbers = '';
        
        // Set the alert message is not selected any values from the list view.
        if(selectedListViewRecords.isEmpty()){
            acceptMessages += 'Please select at least one case' + '\n';
        }
        
        //Check if the Owner is of type User or Queue.
        if(lstSelectedRecords.size()>0 && lstSelectedRecords != null){
            for(String cs : lstSelectedRecords.keyset()){
                if(lstSelectedRecords.get(cs).Owner.Type == 'User'){                 
                    rejectedCaseNumbers = rejectedCaseNumbers + ' ' + string.valueOf(lstSelectedRecords.get(cs).caseNumber);
                }
                else{
                    casesToUpdate.add(lstSelectedRecords.get(cs)); 
                }                
            }    
        }
        
        // Update the Owner with current User and status with In Progress for the cases with owner Queue
        if(casesToUpdate.size()>0 && casesToUpdate != null){
            for(Case cs : casesToUpdate){
                cs.OwnerId = UserInfo.getUserId();
           }
            system.debug('casesToUpdate'+casesToUpdate);
            Database.saveresult[] updateResults =  Database.update(casesToUpdate,false);
            for(Integer i=0;i<updateResults.size();i++){
                if(updateResults.get(i).isSuccess()){
                    acceptedCaseNumbers = acceptedCaseNumbers + ' ' + string.valueOf(lstSelectedRecords.get(updateResults.get(i).getId()).caseNumber);
                }
                else{
                    errorCaseNumbers = errorCaseNumbers + ' ' + string.valueOf(lstSelectedRecords.get(casesToUpdate.get(i).Id).caseNumber);
                    system.debug('error cases'+errorCaseNumbers);
                }
            }
        }
        // Set the Alert message for the cases got updated successfully.
        if(!String.isBlank(acceptedCaseNumbers)){           
            acceptMessages += Label.Accept_Case + '\n'+ acceptedCaseNumbers + '\n\n' ;
        }
        
         // Set the alert with reject message for the cases with owner 'User'
        if(!String.isBlank(rejectedCaseNumbers)){          
            acceptMessages += Label.Reject_Case + '\n'+ rejectedCaseNumbers + '\n\n';
        }
        
        // Set the Alert message for the cases not updated.
        if(!String.isBlank(errorCaseNumbers)){
            acceptMessages += Label.Error_Case + '\n'+ errorCaseNumbers +'\n';
        }        
    } 
    // Refresh the previous window on closing the alert toast.
    Public PageReference retURLFunction(){
        PageReference cancel = standardSetController.cancel();
        return cancel;
    }
}