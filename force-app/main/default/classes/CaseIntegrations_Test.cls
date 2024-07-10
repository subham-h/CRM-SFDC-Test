@isTest
private class CaseIntegrations_Test {
    public static List<Case> caseList = new List<Case>();
    
    private static testMethod void testClaimInsert() {
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 5;
        
        If(caseList.Size() == 0){
            CaseData_Test.createClaimCases();
            caseList = CaseData_Test.lstCases;       
        }    
        system.debug('##### ClaimIdSet -->'+caseList);    
        for(integer i = 0; i< caseList.Size(); i++){
            caseList[i].BoL_Number__c = 'BoLNum11'+i;
            caseList[i].Refresh_GCSS_Data__c = TRUE;
        }
        
        insert caseList; //Insert Claim records        
        system.debug('##### ClaimIdSet -->'+caseList);
        //Verify the records
        Set<Id>claimIdSet = new Set<Id>();
        for(Case c : caseList)
        {
            claimIdSet.Add(c.Id);
        }
        Test.StopTest();
        system.debug('##### ClaimIdSet -->'+ClaimIdSet);
        List<Case> caseRec = [Select Id from Case WHERE Id IN : claimIdSet AND Refresh_GCSS_Data__c = FALSE];
        system.assertEquals(5, caseRec.size());
    }
    
    private static testMethod void testClaimUpdate() {
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 5;
        
        If(caseList.Size() == 0){
            CaseData_Test.createClaimCases();
            caseList = CaseData_Test.lstCases;       
        } 
        
        Database.insert(caseList); //Insert Claim records 
        
        for(integer i = 0; i< caseList.Size(); i++){
            //caseList[i].BoL_Number__c = 'BoLNum11'+i;
            caseList[i].Refresh_GCSS_Data__c = TRUE;
        }
        
             Database.Update(caseList); //Insert Claim records
        //Test.StopTest();
        
        //Verify the records
        Set<Id>claimIdSet = new Set<Id>();
        for(Case c : caseList)
        {
            claimIdSet.Add(c.Id);
        }
        Test.StopTest();
        List<Case> caseRec = [Select Id from Case WHERE Id IN : claimIdSet AND Refresh_GCSS_Data__c = FALSE];
        system.assertEquals(5, caseRec.size());
    }
    
    private static testMethod void testDisputeInsert() {
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 5;        
        if(caseList.Size() == 0){
            CaseData_Test.createDisputecases();
            caseList = CaseData_Test.lstCases;       
        }    
        system.debug('##### DisputeIdSet -->'+caseList);    
        for(integer i = 0; i< caseList.Size(); i++){
            caseList[i].BoL_Number__c = 'BoLNum11'+i;            
        }
        
        insert caseList; //Insert Dispute records  
        //Verify the records
        Set<Id>setDisputeId = new Set<Id>();
        for(Case c : caseList)
        {
            setDisputeId.add(c.Id);
        }        
        Test.StopTest();
        List<Case> caseRec = [Select Id from Case WHERE Id IN : setDisputeId AND Sub_Type__c ='Dispute'];
        system.assertEquals(5, caseRec.size());
    }
    
    private static testMethod void testDisputeUpdate() {     
        Test.startTest();
        CaseData_Test.bCreate = false;
        CaseData_Test.iNumberOfCases = 5;
        Id DisputeCaseRTId = StaticFactory.getRecordTypeIdByName('Case', 'Dispute');
        If(caseList.Size() == 0){
            CaseData_Test.createExternalCases();
            caseList = CaseData_Test.lstCases;       
        } 
        
        Database.insert(caseList); //Insert External Case records         
        for(integer i = 0; i< caseList.Size(); i++){           
            caseList[i].RecordTypeId = DisputeCaseRTId;            
            caseList[i].Department__c = 'Customer Service';            
            caseList[i].Nature_of_Dispute_case__c = 'Invoice Amendment/Clarification';
            caseList[i].Invoice_Amendment_Clarification__c = 'Missing or wrong reference in the invoice';
            caseList[i].Service_Contract_Number__c = '123456ABC';
            caseList[i].Expected_Exchange_Rate__c = '2345';
            caseList[i].Invoice_Type__c = 'Freight';
            caseList[i].Type = 'Charges, Invoice & Payment';
            caseList[i].Sub_Type__c ='Dispute';
            caseList[i].Case_Visibility__c = 'All Users';
            caseList[i].Reason_For_Case__c = 'Case Reason Updated in OHP';
            caseList[i].Disputed_Invoice_Number__c = '987654321'+i;
        }
        //Test.startTest();
        Database.Update(caseList); //Insert Dispute records
              
        //Verify the records
        Set<Id>setDisputeId = new Set<Id>();
        for(Case c : caseList)
        {
            setDisputeId.Add(c.Id);
        }
        Test.StopTest();  
        List<Case> caseRec = [Select Id from Case WHERE Id IN : setDisputeId AND Sub_Type__c ='Dispute'];
        system.assertEquals(5, caseRec.size());
    }    
   
}