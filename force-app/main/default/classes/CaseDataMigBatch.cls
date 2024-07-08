/*
 * Author   : Pete Ryan
 * Purpose  : Migrates lookup values - Runs in backupMode = true by default to populate error log with a backup.
 * 
 * Typical Usage :
 * 
 * 1) delete old backup:
 * List<Batch_Error_Logger__c> lstErr = [SELECT Id FROM Batch_Error_Logger__c WHERE CreatedDate = TODAY AND Exception_Code__c = '20180301_01'];
 * delete lstErr;
 * 
 * 2) Run for all Record Types:
 * CaseDataMigBatch b = new CaseDataMigBatch();
 * Database.executeBatch(b);
 * 
 * CaseDataMigBatch b1 = new CaseDataMigBatch();
 * b1.strQuery = CaseDataMigBatch.RT_CLAIM_REC_QUERY;
 * Database.executeBatch(b1);
 * 
 * CaseDataMigBatch b2 = new CaseDataMigBatch();
 * b2.strQuery = CaseDataMigBatch.RT_EXT_QUERY;
 * Database.executeBatch(b2);
 * 
 * CaseDataMigBatch b3 = new CaseDataMigBatch();
 * b3.strQuery = CaseDataMigBatch.RT_ISR_QUERY;
 * Database.executeBatch(b3);
 * 
 *        
 * Revision Ref Number	Date        	Owner                   				Description
 * -------- ---------- 	-----------		------------------- 					-----------
 * 1.0		#RQ-007972	01/03/2018		peter.ryan@ust-global.com
 *
 * 
 */
global without sharing class CaseDataMigBatch implements Database.Batchable<SObject> {
    
	public static final String LOGMARK = '##### CaseDataMigBatch : ';
	public static final String RT_CLAIM_QUERY = 'SELECT Id, Cause_of_Damage__c, Nature_Of_Damage__c, Sub_Type__c FROM Case WHERE RecordTypeId = \'01257000000cZqlAAE\' AND Nature_Of_Damage__c IN(\'Service Failure - Dry\',\'Service Failure - Reef\')';
	public static final String RT_CLAIM_REC_QUERY = 'SELECT Id, Cause_of_Damage__c, Nature_Of_Damage__c, Sub_Type__c FROM Case WHERE RecordTypeId = \'01257000000cZqmAAE\' AND Nature_Of_Damage__c IN(\'Service Failure - Dry\',\'Service Failure - Reef\')';
	public static final String RT_EXT_QUERY = 'SELECT Id, Cause_of_Damage__c, Nature_Of_Damage__c, Sub_Type__c FROM Case WHERE RecordTypeId = \'012D0000000QoomIAC\' AND Nature_Of_Damage__c IN(\'Service Failure - Dry\',\'Service Failure - Reef\')';
	public static final String RT_ISR_QUERY = 'SELECT Id, Cause_of_Damage__c, Nature_Of_Damage__c, Sub_Type__c FROM Case WHERE RecordTypeId = \'01257000000cZqnAAE\' AND Nature_Of_Damage__c IN(\'Service Failure - Dry\',\'Service Failure - Reef\')';
    
    public Boolean backupMode {
        get {
            if (backupMode == null) {
                backupMode = true;
            }
            return backupMode;
        }
        set;
    }

    public String strQuery {
        get {
            if (strQuery == null) {
                strQuery = RT_CLAIM_QUERY;
            }
            return strQuery;
        }
        set;
    }
    
    public Integer numBatchSize {
        get {
            if (numBatchSize == null) {
	            numBatchSize = 200;
            }
            return numBatchSize;
        }
        set;
    }
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQuerylocator(this.strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> lstCase) {
        
        System.debug(Logginglevel.DEBUG, LOGMARK + 'this.strQuery=' + this.strQuery);
        System.debug(Logginglevel.DEBUG, LOGMARK + 'execute lstCase.size()=' + lstCase.size());
        
        TriggerExecutionController.skipAllTriggers(true);
        
        List<Batch_Error_Logger__c> lstBackup = new List<Batch_Error_Logger__c> ();
        List<Case> lstToUpdateCase = new List<Case>();
        for (Case c: lstCase) {
            System.debug(Logginglevel.DEBUG, LOGMARK + 'execute c.Id=' + c.Id + ': c.Cause_of_Damage__c=' + c.Cause_of_Damage__c + ', c.Nature_Of_Damage__c=' + c.Nature_Of_Damage__c);
            if (String.isNotBlank(c.Cause_of_Damage__c) && String.isNotBlank(c.Nature_Of_Damage__c)) {
	            CaseLookupMapper lm = new CaseLookupMapper(c.Cause_of_Damage__c, c.Nature_Of_Damage__c);
				System.debug(Logginglevel.DEBUG, LOGMARK + 'execute c.Id=' + c.Id + ': lm=' + lm);
                if (lm.mapped) {
                    if (this.backupMode) {
                        Batch_Error_Logger__c backupRec = new Batch_Error_Logger__c(Exception_Cause__c = 'Planned backup', Exception_Code__c = '20180301_01', Exception_Detail__c = JSON.serialize(lm), Exception_Summary__c = 'Mapped Case Id=' + c.Id, Batch_Name__c = 'CaseDataMigBatch', Object__c = 'Case', Operation_Type__c = 'Backup', Source_System__c = 'SFDC');
                        lstBackup.add(backupRec);
                    } else {
                        c.Sub_Type__c = lm.toSubType;
                        c.Nature_Of_Damage__c = lm.toNature;
                        c.Cause_of_Damage__c = lm.toCause;
	                    lstToUpdateCase.add(c);
                    }
                }
            }
        }

        if (this.backupMode) {
            if (!lstBackup.isEmpty()) {
                insert lstBackup;
            }
        } else {
            if(!lstToUpdateCase.isEmpty()) {
                List<Database.SaveResult> lstResult = Database.update(lstToUpdateCase, false );
                ErrorLogger.writeErrors('SFDC', 'Case', 'CaseDataMigBatch.execute()', lstResult, lstToUpdateCase );             
            }
        }
        
        TriggerExecutionController.skipAllTriggers(false);
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    public class CaseLookupMapper {
        
        public String fromCause {get;set;}
        public String fromNature {get;set;}
        public String toSubType {get;set;}
        public String toCause {get;set;}
        public String toNature {get;set;}
        public Boolean mapped {
            get {
                if (String.isNotBlank(fromCause) && String.isNotBlank(fromNature) && String.isNotBlank(toSubType) && String.isNotBlank(toCause) && String.isNotBlank(toNature)) {
                    mapped = true;
                } else {
                    mapped = false;
                }
                return mapped;
            }
            set;
        }
        
        public CaseLookupMapper(String fromCause, String fromNature) {
            
            this.fromCause = fromCause;
            this.fromNature = fromNature;
            
            if (this.fromCause == 'Abandoned Cargo') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Damage/Loss of Cargo';
                    this.toNature = 'Non-Delivery - Dry';
                    this.toCause = 'Misrouting';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Damage/Loss of Cargo';
                    this.toNature = 'Non-Delivery - Dry';
                    this.toCause = 'Misrouting';
                }
            } else if (this.fromCause == 'Additional Transport Cost') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Additional transport Cost';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Additional transport Cost';
                }
            } else if (this.fromCause == 'Airfreight Cargo (consequence from delay)') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Contractual Claim';
                    this.toNature = 'Service Contract Damages - Dry';
                    this.toCause = 'Airfreight';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Contractual Contract Damages - Reef';
                    this.toCause = 'Airfreight';
                }
            } else if (this.fromCause == 'Booking Error') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Booking Error';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Booking Error';
                }
            } else if (this.fromCause == 'Cargo Delay') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Delay Compensation';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Delay Compensation';
                }
            } else if (this.fromCause == 'Cargo Rolling') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Delay Compensation';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Delay Compensation';
                }
            } else if (this.fromCause == 'Labour Cost') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Labour Cost';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Labour Cost';
                }
            } else if (this.fromCause == 'Longstanding') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Other legal Claim';
                    this.toNature = 'Other legal liability - Dry';
                    this.toCause = 'Additional transport cost';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Other legal Claim';
                    this.toNature = 'Other legal liability - Reef';
                    this.toCause = 'Additional transport cost';
                }
            } else if (this.fromCause == 'Release Without Original B/L') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Damage/Loss of cargo';
                    this.toNature = 'Non-Delivery - Dry';
                    this.toCause = 'Release without Original B/L';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Damage/Loss of cargo';
                    this.toNature = 'Non-Delivery - Reef';
                    this.toCause = 'Release without Original B/L';
                }
            } else if (this.fromCause == 'Service Contract Excess Liability') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Contractual Claim';
                    this.toNature = 'Service Contract Damages - Dry';
                    this.toCause = 'Other indemnity Claim';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Contractual Claim';
                    this.toNature = 'Service Contract Damages - Reef';
                    this.toCause = 'Other indemnity Claim';
                }
            } else if (this.fromCause == 'TPDoc/Manifest Error') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Other Legal Claim';
                    this.toNature = 'Other Legal Liability - Dry';
                    this.toCause = 'TPDoc/Manifest Error';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Other Legal Claim';
                    this.toNature = 'Other Legal Liability - Reef';
                    this.toCause = 'TPDoc/Manifest Error';
                }
            } else if (this.fromCause == 'Trucker Waiting Time') {
                if (this.fromNature == 'Service Failure - Dry') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Dry';
                    this.toCause = 'Trucker waiting time';
                } else if (this.fromNature == 'Service Failure - Reef') {
                    this.toSubType = 'Commercial Claim';
                    this.toNature = 'Additional Costs - Reef';
                    this.toCause = 'Trucker waiting time';
                }
            }
        }
    }
    
}