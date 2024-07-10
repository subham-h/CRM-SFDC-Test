global class BatchCaseQueueTimeBHCalculation implements Database.Batchable<SObject>, Schedulable{
    
    global Date startDate;
    global Date endDate;
    global Integer batchSize;
    Set<String> fieldSet = new Set<String>{'Owner', 'BusinessHours'};
    public BatchCaseQueueTimeBHCalculation(Date startDate, Date endDate, Integer size){
        this.startDate = startDate;
        this.endDate = endDate;
        if(size != null){
            this.batchSize = size;
        }
        else if(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size') != null && !String.isEmpty(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c)){
            this.batchSize = Integer.valueOf(General_Key_Value_Configurations__mdt.getInstance('DuplicateEmailMessageFiles_Batch_Size').First_Field_Value__c);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> fieldSet = new Set<String>{'Owner', 'BusinessHours'};
        Date startDt;
        Date endDt;
        if(startDate != null && endDate != null){
            startDt = startDate;
            endDt = endDate;
        }
        else{
            startDt = System.today() - Integer.valueOf(System.label.BatchCaseQueueTimeBHCalculation_Days);
        }
        String query ='SELECT CaseId, Case.OwnerId, Case.CreatedDate, Case.BusinesshoursId, CreatedDate, DataType, Field, OldValue, NewValue FROM CaseHistory where Case.CreatedDate >=: startDt AND (Case.Time_spent_in_Main_Queue_BH__c = null OR Case.Time_spent_in_Main_Queue_BH__c = 0) AND Case.Case_Channel__c = \'E-mail\' AND Case.RecordType.DeveloperName = \'External_Case\' AND DataType = \'EntityId\' AND Field =: fieldSet';
        if(endDt != null){
            query += ' AND Case.CreatedDate <=: endDt';
        }
        query += ' Order By CaseId ASC, createdDate ASC';
        if(Test.isRunningTest()){
            query += ' LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<CaseHistory> caseHistories){
        String defaultBH = System.label.Default_Business_Hours;
        Map<Id, List<CaseHistory>> caseIdToHistoryListMap = new Map<Id, List<CaseHistory>>();
        Set<Id> caseIdSet = new Set<Id>();
        for(CaseHistory ch : caseHistories){
            caseIdSet.add(ch.CaseId);
        }
        for(CaseHistory ch :[SELECT CaseId, Case.OwnerId, Case.CreatedDate, Case.BusinesshoursId, CreatedDate, DataType, Field, OldValue, NewValue FROM CaseHistory where CaseId IN :caseIdSet AND (Case.Time_spent_in_Main_Queue_BH__c = null OR Case.Time_spent_in_Main_Queue_BH__c = 0) AND DataType = 'EntityId' AND Field =: fieldSet]){
            if(caseIdToHistoryListMap.isEmpty() || !caseIdToHistoryListMap.containsKey(ch.CaseId)){
                caseIdToHistoryListMap.put(ch.CaseId, new List<CaseHistory>{ch});
            }
            else{
                caseIdToHistoryListMap.get(ch.CaseId).add(ch);
            }
        }
        
        List<Case> caseListToUpdate = new List<Case>();
        
        for(Id caseId : caseIdToHistoryListMap.keyset()){
            String oldBusinessHourId = '';
            Datetime queueOwnerChangetime;
            Long timeDiff = 0L;
            Boolean updateCase = false;
            for(CaseHistory ch : caseIdToHistoryListMap.get(caseId)){
                if(ch.Field == 'BusinessHours' && ch.NewValue != null){
                    oldBusinessHourId = String.valueOf(ch.NewValue);
                }
                else if(String.isEmpty(oldBusinessHourId)){
                    oldBusinessHourId = defaultBH;
                }
                if(ch.Field == 'Owner' && String.valueOf(ch.OldValue).startsWith('00G') && String.valueOf(ch.NewValue).startsWith('005')){
                    if(queueOwnerChangetime == null){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, ch.Case.CreatedDate, ch.CreatedDate);
                    }
                    else{
                        timeDiff += BusinessHours.diff(oldBusinessHourId, queueOwnerChangetime, ch.CreatedDate);
                    }
                    updateCase = true;
                    break;
                }
                else if(ch.Field == 'Owner' && String.valueOf(ch.OldValue).startsWith('00G') && String.valueOf(ch.NewValue).startsWith('00G')){
                    if(queueOwnerChangetime == null){
                        timeDiff += BusinessHours.diff(oldBusinessHourId, ch.Case.CreatedDate, ch.CreatedDate);
                    }
                    else{
                        timeDiff += BusinessHours.diff(oldBusinessHourId, queueOwnerChangetime, ch.CreatedDate);
                    }
                    queueOwnerChangetime = ch.CreatedDate;
                }
            }
            
            if(updateCase){
                Decimal d = timeDiff;
                Decimal finalTime = d.divide(3600000, 3);
                if(finalTime != null){
                    Case cs = new Case();
                    cs.Id = caseId;
                    cs.Time_spent_in_Main_Queue_BH__c = finalTime;
                    caseListToUpdate.add(cs);
                }
            }
        }
        
        if(!caseListToUpdate.isEmpty()){
            TriggerExecutionController.skipCaseTrigger(true);
            Database.SaveResult[] lstSaveResults = Database.update(caseListToUpdate, false);
            ErrorLogger.writeErrors('SFDC', 'CaseHistory', 'BatchCaseQueueTimeBHCalculation.execute', lstSaveResults, caseListToUpdate);
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchCaseQueueTimeBHCalculation(startDate, endDate, batchSize));
    }
    
}