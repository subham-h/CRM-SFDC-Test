/*
* Purpose   : Batch class scheduled to Reparent the cases to avoid Sharing recalculation issues 
*
* Revision  Ref Number    Date          Owner                   Description
* --------  ----------    -----------   -------------------     -----------
* 1.0       #SC-774       16-Jul-2020   ramadevi@ust-global.com      Code created to reparent the cases to new Accounts to Avoid Sharing recalculation issues 
*/

Public class BatchAccountSkewResolution implements Database.Batchable<sObject>,Database.Stateful{

  
   //public String strLabelValue;
   public boolean runNextBatch = true;
   public final Skewed_Account_Records__c SkewAcc;
   public Integer caseCounter = 0;
   public Integer accCounter = 1;
   public List<Id> ErrIdList = new List<Id>();
   public Id accId=null;
   public boolean ErrorOnBatchexe = false;
   
   public BatchAccountSkewResolution(){
       //runNextBatch = runNextBatch;        
       list<Skewed_Account_Records__c> SkewAccList =[SELECT Id,Account_name__c,Case_count_Limit__c,Error_count__c,Name,Status__c,Total_Cases__c FROM Skewed_Account_Records__c where Status__c = null];
       SkewAcc = SkewAccList[0];
       if(SkewAccList.size() == 1){
           runNextBatch = false;
       }
       system.debug('In Constructor:  SkewAcc  ####'+SkewAcc  );
   }


   public Database.QueryLocator start(Database.BatchableContext BC){
      system.debug('--Start Method--');
      String Query ='SELECT AccountId,Id FROM Case WHERE AccountId ='+'\''+SkewAcc.Name+'\''+' ORDER BY CreatedDate ASC ';
      system.debug('Query ##'+Query );
      SkewAcc.Status__c = 'In-Progress';
      update SkewAcc;
      return Database.getQueryLocator(Query);
   }

   public void execute(Database.BatchableContext BC, List<case> scope){     
       system.debug('--Execute Method--');  
       list<case>lstCase = new list<case>();
       TriggerExecutionController.skipAllTriggers(true);
       TriggerExecutionController.skipCaseTrigger(true);
       TriggerExecutionController.skipContactTrigger(true);
       TriggerExecutionController.skipAccountTrigger(true);
       try {       
       
       system.debug('AccId ###'+accId);
        for(case c: scope){
            Integer SkewAccCaseCntLimit = Integer.valueof(SkewAcc.Case_count_Limit__c);
            if(caseCounter == 0 || math.mod(caseCounter,SkewAccCaseCntLimit) == 0){
                // Create new Account                
                accId = createAccount(SkewAcc.Name,accCounter);
                accCounter = accCounter + 1;
            }
            if(accId != NULL) {
                c.AccountId = accId;  
                system.debug('Case Account'+c.AccountId);                    
                lstCase.add(c);
            }
            caseCounter = caseCounter +1; 
            system.debug('Increment done:'+caseCounter );
        }  
        
        
        if(lstCase.size()>0){
             Database.SaveResult[] results  = Database.update(lstCase,false);
             ErrorLogger.writeErrors('SFDC', 'case', 'BatchAccountSkewResolution.execute()', results  , lstCase); 
             //capture the errored count 
             for(Integer i=0;i<results.size();i++){
                if (results.get(i).isSuccess()){
                    results.get(i).getId();
            
                }else if (!results.get(i).isSuccess()){
                    // DML operation failed
                    ErrIdList.add(lstCase.get(i).Id);
                 }
            }
             
        }    
        
        TriggerExecutionController.skipAllTriggers(false);
        TriggerExecutionController.skipCaseTrigger(false);
        TriggerExecutionController.skipContactTrigger(false);
        TriggerExecutionController.skipAccountTrigger(false);  
        system.debug('AccId ###'+accId);
        } catch (Exception e){
            system.debug('Error on Batch Execution'+e.getMessage());
            ErrorLogger.writeErrors('SFDC', 'case', 'BatchAccountSkewResolution.execute()', new List<Exception>{e});
            ErrorOnBatchexe = true;
        }
   }

    public void finish(Database.BatchableContext BC){
        system.debug('--Final Method--');
        if(ErrorOnBatchexe == True) {
            SkewAcc.Status__c = 'Errored';
        } else {
            SkewAcc.Status__c = 'Completed';
        }
        SkewAcc.Error_count__c = ErrIdList.size();
        update SkewAcc;
    
        if(runNextBatch){ 
            system.debug('before next batch run');    
            if(!Test.isRunningTest()) {  
                BatchAccountSkewResolution  b =new BatchAccountSkewResolution();
                //Integer.valueof(system.label.Case_update_Batch_size)
                Database.executeBatch(b,Integer.valueof(system.label.Account_Skew_Batch_Size));
            }
        }  
    }
   
   public id createAccount(String dataskewId, Integer counter){
    
    Account currAcc = [SELECT id,Name,RecordTypeId,OwnerId,MCC_Account_Owner_Maersk_Id__c,MLL_Account_Owner_Maersk_Id__c,MSL_Account_Owner_Maersk_Id__c,SEA_Account_Owner_Maersk_Id__c,Seago_Account_Owner_Maersk_Id__c,Customer_SOP__c,Country__c,Phone,Fax,BillingAddress,ShippingAddress,Address_Type__c,parentid from Account where id =: Id.valueof(dataskewId) ];
    Account cloneacc = currAcc.clone(false,true);
    cloneacc.parentid = dataskewId;
    cloneacc.Name = cloneacc.Name+'_Archive_'+counter;
    
    TriggerExecutionController.skipAllTriggers(true);
    TriggerExecutionController.skipAccountTrigger(true);
       
    insert cloneacc;
    
    TriggerExecutionController.skipAllTriggers(false);
    TriggerExecutionController.skipAccountTrigger(false);
    
    return cloneacc.id;
}
}