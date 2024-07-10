/*
* Controller for finding duplicate cases and merging cases.
* 
*Version    Date           Owner                                      RQ#           Description
*********************************************************************************************************************************  
1.0       April 6,2015    Ranjini.Janardhanan@ust-global.com        #RQ-001140      Code created.
2.0       19-Aug-2015     Sandhya.Sambasivan@ust-global.com         #RQ-001361      Stop Cases from different Liner Brands showing when managing duplicates
3.0       07-Dec-2015     meghana.gupta@ust-global.com              #RQ-002190      To move emails & attachments to parent case asynchronously. 
                                                                                    Remove code that calculates possible duplicate case count, as code is moved to DuplicateCaseWarningExtension as part of RQ-002150                                                                                          
4.0       14-June-2016    Ananth.perumal@ust-global.com             #RQ-004078      Optimized to improve performance to resolve slowness issue in console.
5.0       1-Sep-2016      Ranjini.Janardhanan@ust-global.com        #RQ-004335      If the parent case is owned by a Queue , then Parent Case and duplicate cases will be assigned to the current user.
6.0       30-Jan-2017     IBM Support Team                          #RQ-004688      When the duplicate case is merged to the Parent Case and the child case's status is moved to 'Closed-Merged', the Case Milestones on Child Case will be completed.
7.0       24-Apr-2017     Ragu@UST                                  #RQ-004667      Rollback the transaction in case of any errors in merging the case.
8.0       24-May-2016     Ragu@UST                                  #RQ-005350      Handle and display user friendly error message if parent case update failed due to validation rules
9.0       12-Sep-2016     Ranjini.Janardhanan@ust-global.com        #RQ-005664      Parent case selected by the user.
10.0      16-Oct-2017     Nisha.Arjunan@ust-global.com              #RQ-007163      Replace BatchErrorLogger with ErrorLogger
11.0      01-Mar-2019    AniBhatn@in.ibm.com                        #RQ-010195    To Resolve Row lock issue
12.0      12-Mar-2019    Sreya@Maersk                               #RQ-010137    To make the VF page available for lightning. 
13.0      12-Nov-2019     Naved@Maersk                              #RQ-012417      Remove multiple DML Operation and create code for SCM  
14.o      13-Jan-2020    Naved@Maersk.com                           #RQ-012903       Global error Logic
15.0      24-Nov-2020     Sunil BS                                   SC-1320         To populate few child fields from parent to child and error logic for not merging without parent classification
16.0      16-02-2021      ramadevi@ust                               SC-172          Implement Case Merge   
17.0      28-04-2021      Sunil BS                                   SC-2138         To Make a check for country and direction while merging so that SCM cases with country-direction mismatch is handled
18.0      28-06-2021      Richa@Maersk                               SC-2693         Update Case Owner Manager on the merged cases
19.0      16/8/2021       Ramadevi@SUT                               SC-2668         Since Claim will have Product, included product to condition to check if Parent is classified.
20.0      18/05/2022      Richa@Maersk                               SC-5109         Added with Sharing to class and ApexSharing recalculation for 4PL
21.0      14/04/2023 	  Vivek@Maersk								 SC-7825		Added filter condition to prevent RFC update for Claim and Claim recovery recordtypes.

*/

public with sharing class DuplicateCaseManagerExtension {
    
    public static Boolean bDuplicateCaseManager = false;
    public Case parentCase {get; set;}
    private caseWrapper parentCaseWrapper;
    public list<caseWrapper> threadDuplicates {get; set;}
    public Boolean isMergeClicked {get;set;} //#RQ-005664.
    public string srchCaseNumber{get;set;} //sc-172
    public Case focusCase;
    public List<Case> lstCases = new List<Case>();
    
    // We need to be able to choose which Cases are merged with the parent so we'll need a wrapper class.
    public class caseWrapper {
        public Case ca {get; set;}
        public Boolean isChecked {get; set;}
        public Boolean isParent {get; set;}
        public Boolean isFocus {get; set;}
        public String strOwnerName {get; set;}        
        
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
        public String strStatus;
        public String strOwnerName;
        public Id ownerId;       
        
        public CaseStats(String strStatus, Id ownerId, String strOwnerName) {
            this.strStatus = strStatus;
            this.strOwnerName = strOwnerName;
            this.ownerId = ownerId;           
        }
    }
    
    public class ParentClassificationException extends Exception{
    }
    //SC-172 : Custom Exception for Case Merge
    public class RecordTypeDiffException extends Exception{        
    }    
    public class LimitChildCaseNumbersException extends Exception{
    }
    public class RecordAlreadyExistsException extends Exception {
        
    }
    public class ClosedCaseException extends Exception{
        
    }
    public class CountryandDirectionMismatchException extends Exception{
        
    }
    
    public DuplicateCaseManagerExtension(ApexPages.StandardController controller) {
        isMergeClicked = false;
        set<Id> possibleDupeCaseIdsSet = new set<Id>();
        set<Id> parentCaseSet = new set<Id>();
        
        if(controller.getRecord().Id != null) {            
            focusCase = [SELECT Id, recordtypeId, CaseNumber, Subject, Status, Account.Name, OwnerId, Owner.Name, Case_Owner_Manager__c, SuppliedEmail,
                                    Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate, Liner_Brand__c,Product__c,Case_Visibility__c
                              FROM Case WHERE Id = :controller.getRecord().Id ]; // #RQ-001361 - Added Liner_Brand__c in the SOQL query
            
            DateTime fromDate = focusCase.CreatedDate.addDays(-14);
            DateTime toDate = focusCase.CreatedDate.addDays(14);
            
            threadDuplicates = new list<caseWrapper>();
            
            // Get all possible duplicates including focusCase and add them to threadDuplicates so we 
            // can display everything in one list. Sorting is important as we assume the first Case in 
            // the list will be the Parent.
            // v4.0 - Added condition to check whether Thread_Topic__c is not null
            if(focuscase.Thread_topic__c != null) {
                Integer selCaseCount = 1;
                
                lstCases =  [SELECT Id, CaseNumber, Claim_Event__c, recordtypeId,Subject, Status, Account.Name, OwnerId, Owner.Name,Case_Owner_Manager__c,New_Mail__c,Count_Case_Emails__c, SuppliedEmail, Type, Sub_Type__c, Reason_For_Case__c, Product__c, Type_SubType__c, ParentId, Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate,Liner_Brand__c,Case_Visibility__c
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
    }
    
    // Action that merges the child Cases to the parent Case.
    public void mergeCases() {
    try{ 
        //To avoid null pointer exception and to show an exception to select a parent.
        if (parentCase == null){
            throw new LimitChildCaseNumbersException(Label.DuplicateCaseManager_SelectParent);
        }else {
            //Since the claim cases will not have Product, modified the below condition
            //SC-2668:Modified the condition to include Product for Claim.
            if((parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claim) && (String.isBlank(parentCase.Type) || String.isBlank(parentCase.Sub_Type__c) || String.isBlank(parentCase.Product__c))) || (parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && (String.isBlank(parentCase.Product__c) || String.isBlank(parentCase.Type) || String.isBlank(parentCase.Sub_Type__c)))){
                throw new ParentClassificationException('Parent Not classified');
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
                   // if(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery) && ((parentCase.recordtypeId == StaticFactory.getRecordTypeIdByName('Case',Label.Claim) && threadDuplicates[i].ca.Claim_Event__c<>null) || parentCase.recordtypeId <> StaticFactory.getRecordTypeIdByName('Case',Label.Claim))){
                     //  throw new RecordTypeDiffException('Claim Recovery can only linked to a Claim Event or a Claim.');           }
                    
                    //SC-2094
                     if(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.External_Case) && (parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case',Label.External_Case))){
                        throw new RecordTypeDiffException(Label.DuplicateCaseManager_ExternalCaseException);           
                    }
                    if((threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claim)||(threadDuplicates[i].ca.recordtypeId == StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery)&&threadDuplicates[i].ca.Claim_Event__c<>null)) && (parentCase.recordtypeId<>StaticFactory.getRecordTypeIdByName('Case',Label.Claim))){
                        throw new RecordTypeDiffException(Label.DuplicateCaseManager_ClaimCaseException);           
                    }
                    //SC-2135 Checking if the duplicate list contains any closed cases
                    if(Label.Closed_Case_Status.contains(threadDuplicates[i].ca.Status)){
                        
                        throw new ClosedCaseException(Label.DuplicateCaseManager_ClosedCaseException);
                    }
                    
                     if(threadDuplicates[i].ca.Country__c!= parentCase.Country__c || threadDuplicates[i].ca.Direction__c!= parentCase.Direction__c){
                        
                        throw new CountryandDirectionMismatchException(Label.DuplicateCaseManager_CountryandDirectionMismatch);
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
                throw new LimitChildCaseNumbersException(Label.DuplicateCaseManager_SelectChild); 
            }else if(selectedChildCount > 4){         
                // Allow only 4 childs can be selected
                throw new LimitChildCaseNumbersException(Label.DuplicateCaseManager_MergeLimit);              
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
                
                // If Merging is success, a success messege will be shwon....
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.Duplicate_Case_Merge_Success));
                
                //#RQ-005664.Once Merge selected the we will disable the Merge button and Paren Chaild rows in the table.
                isMergeClicked = true;
                
                // RQ-004688 - Calling completeMilestones() methods to complete the Milestones on Duplicate Case(Child Case) when it is merged to Parent Case.
                CaseEntitlements.completeMilestones(selectedChildIds);
                
                /*// Call to future method to move emails and email attachments from merged child cases to parent case
                mergeCaseEmailsAndAttachments(selectedChildIds, parentCase.Id);
                //return null;*/
                
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
                ErrorLogger.writeErrors('SFDC', 'Case', 'DuplicateCaseManagerExtension.merge',new list<Exception>{ex});
                resetValues(threadDuplicates, mapCaseIdStats); 
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    list<String> msg = ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1].split(':');
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,msg[0] ));
                } else {
                    system.debug(ex.getCause()+'$$$$$$$'+ex.getMessage());                   
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.Duplicate_Case_Merge_Error));                
                }
                
              //  return null;
            }
            finally {
                TriggerExecutionController.skipCaseTrigger(false);
            }
                
        }
    }
        catch (ParentClassificationException ex){
        isMergeClicked = false;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.Parent_Case_Not_Classified_Error));        
        }
    catch (RecordTypeDiffException ex){
        isMergeClicked = false;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getMessage()));        
        }
    catch (LimitChildCaseNumbersException ex){
        isMergeClicked = false;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getmessage() ));
        }
     catch (ClosedCaseException ex){
        isMergeClicked = false;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getmessage() ));
        }
        
     catch (CountryandDirectionMismatchException ex){
        isMergeClicked = false;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getmessage() ));
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
    
    // #RQ-005664. If the user selects a different parent the child checkbox will be un checked and new parent will be selected.
    public void selectParent(){
        try{
            Id newParentId= System.currentPagereference().getParameters().get('selectedParentId'); 
            Id oldParentCaseId;
            //When a Merge Case button is clicked from Layout, there is a chance that the list to show zero cases, when the cases are searched and selected as Parent, parentCase will not be set at that time and exception will be shown to avoid that the below condition is added
            if(parentCase <> null){
                oldParentCaseId = parentCase.Id;            
            }
            if(oldParentCaseId != newParentId){                
                for(Integer i = 0; i < threadDuplicates.size(); i++) {
                    // The variable parentCase is updated to the new Case selected.                          
                    if(threadDuplicates[i].ca.Id == newParentId){                   
                        parentCase = threadDuplicates[i].ca;    
                        //Show error message if the Claim recovery is selected as Parent.
                        if(parentCase.recordtypeid==StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery))
                        {
                            throw new RecordTypeDiffException(Label.DuplicateCaseManager_ClaimRecoveryParentError);
                        }
                        threadDuplicates[i].isParent = true;
                        threadDuplicates[i].isChecked = false;
                        //Once the Parent is selected the parentCaseWrapper needs to be updated as new selected parent.
                        parentCaseWrapper = threadDuplicates[i];       
                    }
                    else { 
                        // isParent needs to be unchecked for the old parent case.               
                        if(threadDuplicates[i].isParent == true){                   
                            threadDuplicates[i].isParent = false;
                            threadDuplicates[i].isChecked = true; 
                       }                   
                    }
                }
            } else {
                //Show error message if the Claim recovery is selected as Parent.
                if(parentCase.recordtypeid==StaticFactory.getRecordTypeIdByName('Case', Label.Claims_Recovery))
                {
                    throw new RecordTypeDiffException(Label.DuplicateCaseManager_ClaimRecoveryParentError);
                }
            }
        }
        catch (RecordTypeDiffException ex){
            isMergeClicked = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getMessage()));        
        }
    }
    
    // Action that redirects user from Duplicate Case Manager page to case detail.
    public PageReference done() {
        return null;
    }
   
   //sc-172 : Method to Search the Case by Case Number
   public void searchCase(){
       system.debug('Inside search case');
       Boolean isAlreadyThere = FALSE;      
       Case srchCase;
       try {
       srchCase = [SELECT Id, CaseNumber, RecordTypeId,Claim_Event__c, Subject, Status, Account.Name, OwnerId, Owner.Name, Case_Owner_Manager__c, SuppliedEmail, Type, Sub_Type__c, Reason_For_Case__c, Product__c, Type_SubType__c, ParentId, Parent.CaseNumber, Thread_Topic__c, Country__c, Direction__c, CreatedDate,Count_Case_Emails__c,Case_Visibility__c,Liner_Brand__c from Case WHERE casenumber=:srchCaseNumber 
                                    AND Status in :Label.Non_Merged_Case_Status.split(', ') 
                                    AND Country__c = :focusCase.Country__c 
                                    AND Direction__c = :focusCase.Direction__c 
                                    AND Liner_Brand__c = :focusCase.Liner_Brand__c 
                                    AND ParentId = null ];  
           if (srchCase <> null){
               for(caseWrapper cw:threadDuplicates){
                   if(cw.ca.id == srchCase.id && cw.isChecked == TRUE){
                       isAlreadyThere = TRUE;
                       throw new RecordAlreadyExistsException('Record already selected.');                     
                   } else if(cw.ca.id == srchCase.id && cw.isChecked == FALSE){
                      isAlreadyThere = TRUE;
                      cw.isChecked = TRUE;
                   }
               }
               if (isAlreadyThere == FALSE){
                   caseWrapper srchCaseWrapper = new caseWrapper(srchCase,true,false,false);
                   threadDuplicates.add(srchCaseWrapper);
               }
           } else {
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.DuplicateCaseSearchMessage));
           }
       }
       catch(RecordAlreadyExistsException ex){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.DuplicateCaseManager_CaseExist));
        
       }
       catch(Exception ex){
           if( ex.getmessage() == 'List has no rows for assignment to SObject'){
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.DuplicateCaseSearchMessage));
           }
           else {
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.DuplicateCaseManager_Unexpected));
           }
       }
   }
    
    
    //SC-2138 To Update Parent case id on child cases when "create Parent-child relationship" button is clicked
    public void createParentChildRelationship(){
      try{
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
                     throw new LimitChildCaseNumbersException(Label.DuplicateCaseManager_ChildCaseNumbersNull); 
                   }
                
          
          
        TriggerExecutionController.skipCaseTrigger(true); 
        if(Schema.sObjectType.Case.isUpdateable())
            {
                update lstCasesToUpdate; 
            }
        TriggerExecutionController.skipCaseTrigger(false); 
      }
        catch (LimitChildCaseNumbersException ex){       
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getmessage() ));
        }
        
    }
  

        
}