/*
 * Author   : Nayana Sharma
 * Purpose  : New controller for finding duplicate cases used in LWC component DuplicateCaseManagerLWC
 *          
 * Revision Ref Number  Date            Owner                   Description
 * -------- ----------  -----------     -------------------     -----------
 * 1.0      SC-6887    05-Apr-2023     Nayana.sharma@maersk.com Code created using existing DuplicateCaseManagerExtension class.
 */
public class DuplicateCaseManagerExtensionLWC {
    //public static Case focusCase;
    // We need to be able to choose which Cases are merged with the parent so we'll need a wrapper class.
    public class caseWrapper {
        @AuraEnabled public Case ca {get; set;}
        @AuraEnabled public Boolean isChecked {get; set;}
        @AuraEnabled public Boolean isParent {get; set;}
        @AuraEnabled public Boolean isFocus {get; set;}
        @AuraEnabled public String strOwnerName {get; set;}           
        
        public caseWrapper(Case ca, Boolean isChecked, Boolean isParent, Boolean isFocus) {
            this.ca = ca;
            this.strOwnerName = ca.Owner.Name;           
            this.isChecked = isChecked;
            this.isParent = isParent;
            this.isFocus = isFocus;
        }       
    }
    // To maintain the old values to display them back in case of errors    
    public class CaseStats {
        @AuraEnabled public String strStatus;
        @AuraEnabled public String strOwnerName;
        @AuraEnabled public Id ownerId;       
        
        public CaseStats(String strStatus, Id ownerId, String strOwnerName) {
            this.strStatus = strStatus;
            this.strOwnerName = strOwnerName;
            this.ownerId = ownerId;           
        }
    }    
    
    public class RecordTypeDiffException extends Exception{        
    }  
    public class RecordAlreadyExistsException extends Exception {
        
    }
    
    @AuraEnabled
	public static List<caseWrapper> getDuplicateCases(String focusCaseId) {
        Boolean isMergeClicked = false;
        set<Id> possibleDupeCaseIdsSet = new set<Id>();
        set<Id> parentCaseSet = new set<Id>();
        Case focusCase = new Case();
        List<Case> lstCases = new List<Case>();
        caseWrapper parentCaseWrapper;
        list<caseWrapper> threadDuplicates = new list<caseWrapper>();
        Case parentCase = new Case();
        
        if(focusCaseId != null) {            
            focusCase = [SELECT Id, recordtypeId, CaseNumber, Subject, Status, AccountId, Account.Name, OwnerId, Owner.Name, Case_Owner_Manager__c, SuppliedEmail,
                                    Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate, Liner_Brand__c,Product__c,Case_Visibility__c
                              FROM Case WHERE Id = :focusCaseId ]; 
            
            DateTime fromDate = focusCase.CreatedDate.addDays(-14);
            DateTime toDate = focusCase.CreatedDate.addDays(14);
            
            threadDuplicates = new list<caseWrapper>();
            
            // Get all possible duplicates including focusCase and add them to threadDuplicates so we 
            // can display everything in one list. Sorting is important as we assume the first Case in 
            // the list will be the Parent.
            // v4.0 - Added condition to check whether Thread_Topic__c is not null
            if(focuscase.Thread_topic__c != null) {
                Integer selCaseCount = 1;
                
                lstCases =  [SELECT Id, CaseNumber,RecordTypeId, Claim_Event__c, RecordType.DeveloperName,Subject, Status, AccountId, Account.Name, OwnerId, Owner.Name,Case_Owner_Manager__c,New_Mail__c,Count_Case_Emails__c, SuppliedEmail, Type, Sub_Type__c, Reason_For_Case__c, Product__c, Type_SubType__c, ParentId, Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate,Liner_Brand__c,Case_Visibility__c
                               FROM Case WHERE Thread_topic__c = :focusCase.Thread_topic__c  
                                    AND CreatedDate > :fromDate AND CreatedDate < :toDate
                                    AND Status in :Label.Non_Merged_Case_Status.split(', ')                                   
                                    AND Liner_Brand__c = :focusCase.Liner_Brand__c // #RQ-001361 - Added Liner_Brand__c filter to SOQL query
                                    AND RecordtypeId =: focusCase.recordtypeId// SC-2094: Display duplicates of same record type
                                    AND ParentId = null ORDER BY CreatedDate ASC  LIMIT 10];
                
                
                
                for(Case ca : lstCases) 
                    
                {  //RQ-010195
                                    
                    // If this Case is focusCase then we need to mark it as the focus Case so we can highlight it in the VF page.
                    if(ca.Id == focusCase.Id) {
                        threadDuplicates.add(new caseWrapper(ca, true, false, true));
                    } 
                    else {
                        //SC-172 : Select only 4 child records
                        if(selCaseCount <= 4){
                            threadDuplicates.add(new caseWrapper(ca, true, false, false));
                            selCaseCount = selCaseCount + 1;
                        } else {
                            threadDuplicates.add(new caseWrapper(ca, false, false, false));
                        }
                    }
                    possibleDupeCaseIdsSet.add(ca.Id);
                }
                
                // If one of the duplicates found is already a parent then flag it as the parent, 
                // otherwise use the first record in the list as the parent because this will be the eldest.
                if(possibleDupeCaseIdsSet.size() > 0) {
                    list<Case> caseList = [SELECT Id, ParentId, OwnerId FROM Case WHERE ParentId IN :possibleDupeCaseIdsSet];
                    
                    for(case cs : caseList) {
                        parentCaseSet.add(cs.ParentId);
                    }
                    
                    if(caseList != null && !caseList.isEmpty()) {
                        for(caseWrapper cw : threadDuplicates) {
                            if(parentCaseSet.contains(cw.ca.Id)) {
                                cw.isParent = true;
                                cw.isChecked = false;
                                parentCase = cw.ca;
                                parentCaseWrapper = cw;
                                break; // #RQ-005664 .If there are more than one case with child only the first one will be marked as the parent.
                            }
                        }
                    }
                    else {
                        threadDuplicates[0].isParent = true;
                        threadDuplicates[0].isChecked = false;
                        parentCase = threadDuplicates[0].ca;
                        parentCaseWrapper = threadDuplicates[0];
                    }
                }            
            }            
        } 
        system.debug('threadDuplicates'+threadDuplicates);
        return threadDuplicates;
    }
    
    //sc-172 : Method to Search the Case by Case Number
   @AuraEnabled   
    public static List<caseWrapper> searchCase(String srchCaseNumber,String focusCaseId){
        //system.debug(threadDuplicatesIn);
        system.debug(srchCaseNumber);
        system.debug(focusCaseId);
        List<caseWrapper> threadDuplicates = new List<caseWrapper>();
        Case focusCase = new Case();        
        
       system.debug('Inside search case');
       Boolean isAlreadyThere = FALSE;      
       Case srchCase;
       if(focusCaseId != null) {            
        focusCase = [SELECT Id, recordtypeId, RecordType.DeveloperName,CaseNumber, Subject, Status, Account.Name, OwnerId, Owner.Name, Case_Owner_Manager__c, SuppliedEmail,
                                Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate, Liner_Brand__c,Product__c,Case_Visibility__c
                          FROM Case WHERE Id = :focusCaseId ]; 
       }       
       
       system.debug('focuscase'+focusCase);
       try {
        system.debug('inside try searchcase'+ threadDuplicates+srchCaseNumber+focusCase);
       srchCase = [SELECT Id, CaseNumber, RecordTypeId,Claim_Event__c, Subject, Status, Account.Name, OwnerId, Owner.Name, Case_Owner_Manager__c, SuppliedEmail, 
                   Type, Sub_Type__c, Reason_For_Case__c, Product__c, Type_SubType__c, ParentId, Parent.CaseNumber, Thread_Topic__c, Country__c, 
                   Direction__c, CreatedDate,Count_Case_Emails__c,Case_Visibility__c,Liner_Brand__c,RecordType.DeveloperName,AccountId from Case WHERE casenumber=:srchCaseNumber 
                                    AND Status in :Label.Non_Merged_Case_Status.split(', ') 
                                    AND Country__c = :focusCase.Country__c 
                                    AND Direction__c = :focusCase.Direction__c 
                                    AND Liner_Brand__c = :focusCase.Liner_Brand__c 
                                    AND ParentId = null ];  
           if (srchCase <> null){
               
               if(focusCaseId==srchCase.id){
                isAlreadyThere = TRUE;
                throw new AuraHandledException('Record already selected.');
               }
               if (isAlreadyThere == FALSE){
                   caseWrapper srchCaseWrapper = new caseWrapper(srchCase,true,false,false);
                   threadDuplicates.add(srchCaseWrapper);
               }
           } else {
               throw new AuraHandledException(Label.DuplicateCaseSearchMessageLWC);  
           }
       }
       catch(RecordAlreadyExistsException ex){
        system.debug('inside catch searchcase'+ threadDuplicates+srchCaseNumber+focusCase);
        system.debug('inside catch searchcase'+ ex);
           throw new AuraHandledException(Label.DuplicateCaseManager_CaseExist); 
        
       }
       catch(Exception ex){
        system.debug('inside catch searchcase'+ ex);
           if( ex.getmessage() == 'List has no rows for assignment to SObject'){
               throw new AuraHandledException(Label.DuplicateCaseSearchMessageLWC);
           }
           else {
               throw new AuraHandledException(Label.DuplicateCaseManager_Unexpected);
           }
       }
        return threadDuplicates;
   }
    
    @AuraEnabled
    public static void createParentChildRelationship(String threadDuplicatesIn, String parentCaseIn){
      try{
        System.debug('threadDuplicates'+threadDuplicatesIn);
        System.debug('parentCaseIn'+parentCaseIn);
        //caseWrapper cw = (caseWrapper)JSON.deserialize(str,caseWrapper.class);
        List<caseWrapper> threadDuplicates = (List<caseWrapper>)JSON.deserialize(threadDuplicatesIn,List<caseWrapper>.class);
        Case parentCase = (Case)JSON.deserialize(parentCaseIn,Case.class);
        set<Id> selectedChildIds = new set<Id>();       
        list<Case> lstCasesToUpdate = new List<Case>();
        Integer selectedChildCount = 0;  
            for(Integer i = 0; i < threadDuplicates.size(); i++) {
                  // If the child has been selected and its NOT the Parent then add it to list to be merged.
                  if(threadDuplicates[i].isChecked == true && !threadDuplicates[i].isParent && parentCase.Liner_Brand__c==threadDuplicates[i].ca.Liner_Brand__c && parentCase.Case_Visibility__c==threadDuplicates[i].ca.Case_Visibility__c) {
                      threadDuplicates[i].ca.ParentId = parentCase.Id;
                      selectedChildCount = selectedChildCount + 1;
                       lstCasesToUpdate.add(threadDuplicates[i].ca);
                        
              }
            }
              system.debug('Count test'+selectedChildCount);
                  if(selectedChildCount == 0){
                      //Show Exception when no cases are selected for mapping "create Parent-child relationship"
                     throw new AuraHandledException(Label.DuplicateCaseManager_ChildCaseNumbersNull); 
                   }         
          
        TriggerExecutionController.skipCaseTrigger(true); 
        if(Schema.sObjectType.Case.isUpdateable())
            {
                update lstCasesToUpdate; 
            }
        TriggerExecutionController.skipCaseTrigger(false); 
      }
        catch (Exception ex){ 
        	throw new AuraHandledException(ex.getmessage()); 
        }
        
    }
    
    // Action that merges the child Cases to the parent Case.
    @AuraEnabled
    public static void mergeCases(String threadDuplicatesIn, String parentCaseWrapperIn){
        System.debug('threadDuplicates'+threadDuplicatesIn);
        //System.debug('parentCaseIn'+parentCaseIn);
        System.debug('parentCaseWrapperIn'+parentCaseWrapperIn);
        
        List<caseWrapper> threadDuplicates = (List<caseWrapper>)JSON.deserialize(threadDuplicatesIn,List<caseWrapper>.class);
        //Case parentCase = (Case)JSON.deserialize(parentCaseIn,Case.class);
        caseWrapper parentCaseWrapper = (caseWrapper)JSON.deserialize(parentCaseWrapperIn,caseWrapper.class);
        Case parentCase = parentCaseWrapper.ca;
        Boolean isMergeClicked = false;
        try{ 
            //To avoid null pointer exception and to show an exception to select a parent.
            if (parentCase == null){
                throw new AuraHandledException(Label.DuplicateCaseManager_SelectParent);
            }else {
                //Since the claim cases will not have Product, modified the below condition
                //SC-2668:Modified the condition to include Product for Claim.
                if((parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claim) && (String.isBlank(parentCase.Type) || String.isBlank(parentCase.Sub_Type__c) || String.isBlank(parentCase.Product__c))) || (parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && (String.isBlank(parentCase.Product__c) || String.isBlank(parentCase.Type) || String.isBlank(parentCase.Sub_Type__c)))){
                    throw new AuraHandledException(Label.Parent_Case_Not_Classified_Error);
                }
                set<Id> selectedChildIds = new set<Id>();       
                list<Case> lstCasesToUpdate = new List<Case>();
                System.debug('##### parentCase '+parentCase.Id);
                // For resetting the values in-case of errors. 
                map<Id, CaseStats> mapCaseIdStats = new map<Id, CaseStats>();
                Boolean isOwnerQueue = false;
                List<User> lstUser = new List<User>(); //for storing logged in user details
                String caseOwnerManager = '';
                set<Id> set4PLCaseIds = new Set<Id>();//Bug fix - SC-5109
                
                // RQ-004335  Checking if the parent case is owned by a Queue or User.
                if(parentCase.OwnerID.getSObjectType() != User.getSObjectType()) { 
                    mapCaseIdStats.put(parentCase.Id, new CaseStats(parentCase.Status, parentCase.OwnerID, parentCaseWrapper.strOwnerName));                
                    parentCase.OwnerID = UserInfo.getUserId();
                    parentCaseWrapper.strOwnerName = UserInfo.getName(); 
                    isOwnerQueue = true;               
                }
                if(isOwnerQueue){
                lstUser = [Select Manager.Name FROM User WHERE Id =: UserInfo.getUserId() ]; 
                    if(!lstUser.isEmpty() && lstUser.size()>0){
                    caseOwnerManager = lstUser[0].Manager.Name;   
                    }  
                }
                else{
                caseOwnerManager = parentCase.Case_Owner_Manager__c;
                }
            
                //SC-172: Case Merge : Allow only upto 4 child cases to be selected at a time to merge
                Integer selectedChildCount = 0;        
                // Go through the possible duplicates and decide what to merge...
                for(Integer i = 0; i < threadDuplicates.size(); i++) {
                    // If the child has been selected and its NOT the Parent then add it to list to be merged.
                    if(threadDuplicates[i].isChecked == true && !threadDuplicates[i].isParent) {
                            
                    // Check if claim recovery case is been merged non claim case.
                    if(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery) && ((parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',Label.Claim) && threadDuplicates[i].ca.Claim_Event__c<>null) || parentCase.recordtypeId <> StaticFactory.getRecordTypeIdByName('Case',Label.Claim))){
                        throw new AuraHandledException('Claim Recovery can only linked to a Claim Event or a Claim.'); 
                    }
                        //SC-2094
                        if(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && (parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case',Label.External_Case))){
                            throw new AuraHandledException(Label.DuplicateCaseManager_ExternalCaseException);           
                        }
                        if((threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claim)||(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery)&&threadDuplicates[i].ca.Claim_Event__c<>null)) && (parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case',Label.Claim))){
                            throw new AuraHandledException(Label.DuplicateCaseManager_ClaimCaseException);           
                        }
                        //SC-2135 Checking if the duplicate list contains any closed cases
                        if(Label.Closed_Case_Status.contains(threadDuplicates[i].ca.Status)){
                            
                            throw new AuraHandledException(Label.DuplicateCaseManager_ClosedCaseException);
                        }
                        
                        if(threadDuplicates[i].ca.Country__c!= parentCase.Country__c || threadDuplicates[i].ca.Direction__c!= parentCase.Direction__c){
                            
                            throw new AuraHandledException(Label.DuplicateCaseManager_CountryandDirectionMismatch);
                        }
                        
                        
                        mapCaseIdStats.put(threadDuplicates[i].ca.Id, new CaseStats(threadDuplicates[i].ca.Status, threadDuplicates[i].ca.OwnerId, threadDuplicates[i].strOwnerName));
                        
                        threadDuplicates[i].ca.ParentId = parentCase.Id;
                        threadDuplicates[i].ca.Status = System.Label.Case_Merged_Status;
                        threadDuplicates[i].ca.OwnerId = parentCase.OwnerID;
                        threadDuplicates[i].strOwnerName = parentCaseWrapper.strOwnerName;                    
                        threadDuplicates[i].ca.Case_Owner_Manager__c = caseOwnerManager;
                        threadDuplicates[i].ca.Case_Duplicate_Flag__c = true;
                        threadDuplicates[i].ca.Product__c = parentCase.Product__c;
                        threadDuplicates[i].ca.Sub_Type__c = parentCase.Sub_Type__c;
                        threadDuplicates[i].ca.Type = parentCase.Type;
                        //Start SC-7825   added filer to prevent RFC field update for Claim, Claim Recovery recordtypes
                 		if(threadDuplicates[i].ca.recordtypeId != StaticFactory.getRecordTypeIdByName('Case', Label.Claim)&&(threadDuplicates[i].ca.recordtypeId != StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery)) && (parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case',Label.Claim) && parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery))){
                    	threadDuplicates[i].ca.Reason_For_Case__c = parentCase.Reason_For_Case__c;
                 		}
                    	//End SC-7825
                        //SC 2135 Check if any child case has emails then check response recevive flag on parent
                        if(threadDuplicates[i].ca.Count_Case_Emails__c>0)
                        {
                        parentCase.New_Mail__c=true;
                        }
                        selectedChildCount = selectedChildCount + 1;
                        selectedChildIds.add(threadDuplicates[i].ca.Id);
                        lstCasesToUpdate.add(threadDuplicates[i].ca);
                    }
                }
                
                //SC-172
                if(selectedChildCount == 0){
                    //Show Exception when no cases are selected and Merge Case button.
                    throw new AuraHandledException(Label.DuplicateCaseManager_SelectChild); 
                }else if(selectedChildCount > 4){         
                    // Allow only 4 childs can be selected
                    throw new AuraHandledException(Label.DuplicateCaseManager_MergeLimit);              
                }
                
                
                // Create SavePoint to rollback the transaction when parent case update is failed which is initiated from child case trigger via future method.
                SavePoint sp = Database.setSavepoint();
                try {
                    DuplicateCaseManagerExtension.bDuplicateCaseManager = true;
                    TriggerExecutionController.skipCaseTrigger(true);     
                    //Commenting  as part of #RQ-012417        
                    //update lstCasesToUpdate; 
                    Set<String> objectFields = Schema.SObjectType.case.fields.getMap().keySet();  
                    
                    // RQ-005350: Remember that inorder to process FCR on parent, child cases should already have ParentId.  
                    Case parentCase2 = CaseFCRCalculation.calculateFcrInParentDuplicate(parentCase.Id, selectedChildIds);
                    parentCase2.OwnerId = parentCase.OwnerId;
                    //  Adding Parent case in child case list
                    lstCasesToUpdate.add(parentCase2);
                    
                    if(Schema.sObjectType.Case.isUpdateable())
                    {
                        update lstCasesToUpdate;
                    }
                    
                    //Apex sharing recalculation for 4PL
                    set4PLCaseIds.add(parentCase.Id);  
                    set4PLCaseIds.addAll(selectedChildIds);
                    if(!set4PLCaseIds.isEmpty()){
                    ApexSharingUtility.updateSharing(set4PLCaseIds,'Case','Case_Visibility__c','Edit','Manual',true);
                    }                    
                    
                    //#RQ-005664.Once Merge selected the we will disable the Merge button and Paren Chaild rows in the table.
                    isMergeClicked = true;
                    
                    // RQ-004688 - Calling completeMilestones() methods to complete the Milestones on Duplicate Case(Child Case) when it is merged to Parent Case.
                    CaseEntitlements.completeMilestones(selectedChildIds);
                    
                    //Call queueable method to merge Emails, Attachments,Case Comments
                    List<Id> childIds = new List<Id>();
                    childIds.AddAll(selectedChildIds);
                    Case parent = new Case();
                    parent.Id = parentCase.Id;  
                    parent.New_Mail__c=parentCase.New_Mail__c;
            if(isOwnerQueue){                
                    parent.Case_Owner_Manager__c = caseOwnerManager;
                    }
                    System.enqueueJob(new CaseMergeQueueable(childIds,Parent));
                    
                }
                catch (Exception ex) {
                    
                    Database.rollback(sp); // RQ-005350
                    //#RQ-012417 -Error Handel
                    isMergeClicked = false;
                    ErrorLogger.writeErrors('SFDC', 'Case', 'DuplicateCaseManagerExtensionLWC.merge',new list<Exception>{ex});
                    resetValues(threadDuplicates, mapCaseIdStats); 
                    if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                        list<String> msg = ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1].split(':');
                        throw new AuraHandledException(msg[0]);     
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,msg[0] ));
                    } else {
                        system.debug(ex.getCause()+'$$$$$$$'+ex.getMessage());    
                        throw new AuraHandledException(Label.Duplicate_Case_Merge_Error);     
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.Duplicate_Case_Merge_Error));                
                    }
                    
                //  return null;
                }
                finally {
                    TriggerExecutionController.skipCaseTrigger(false);
                }
                    
            }
        }
        catch (RecordTypeDiffException ex){
            isMergeClicked = false;
            throw new AuraHandledException(ex.getMessage());   
            }
            
        }
        
        private static void resetValues(list<caseWrapper> threadDuplicates, map<Id, CaseStats> mapCaseIdStats) {
            for(caseWrapper cw : threadDuplicates) {
                if(mapCaseIdStats.containsKey(cw.ca.Id)) {
                    cw.ca.Status = mapCaseIdStats.get(cw.ca.Id).strStatus;
                    cw.ca.OwnerId = mapCaseIdStats.get(cw.ca.Id).ownerId;
                    cw.strOwnerName = mapCaseIdStats.get(cw.ca.Id).strOwnerName;                
                }
            }
    }
    
    
}