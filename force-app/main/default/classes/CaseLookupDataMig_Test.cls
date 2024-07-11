/*
 * Author   : Pete Ryan
 * Purpose  : Tests CaseDataMigBatch
 * 
 * Revision Ref Number	Date        	Owner                   				Description
 * -------- ---------- 	-----------		------------------- 					-----------
 * 1.0		#RQ-007972	01/03/2018		peter.ryan@ust-global.com
 *
 * 
 */
@isTest
public class CaseLookupDataMig_Test {

    // Coverage only - Creating test data not possible due to DB constraints - can't enter invalid lookups for the test data!
    static testMethod void testCaseDataMigBatch() {
        System.test.startTest();
		CaseDataMigBatch b = new CaseDataMigBatch();
        System.assert(String.isNotBlank(b.strQuery));
        System.assert(b.backupMode);
        System.assertEquals(200, b.numBatchSize);
        Database.executeBatch(b);
        System.test.stopTest();
    }
    
    static testMethod void testCaseLookupMapper() {
        
        List<CaseDataMigBatch.CaseLookupMapper> lstLM = new List<CaseDataMigBatch.CaseLookupMapper>();
        System.Test.startTest();
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Abandoned Cargo', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Additional Transport Cost', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Airfreight Cargo (consequence from delay)', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Booking Error', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Cargo Delay', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Cargo Rolling', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Labour Cost', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Longstanding', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Release Without Original B/L', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Service Contract Excess Liability', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('TPDoc/Manifest Error', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Trucker Waiting Time', 'Service Failure - Dry'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Abandoned Cargo', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Additional Transport Cost', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Airfreight Cargo (consequence from delay)', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Booking Error', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Cargo Delay', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Cargo Rolling', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Labour Cost', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Longstanding', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Release Without Original B/L', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Service Contract Excess Liability', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('TPDoc/Manifest Error', 'Service Failure - Reef'));
        lstLM.add(new CaseDataMigBatch.CaseLookupMapper('Trucker Waiting Time', 'Service Failure - Reef'));
        System.Test.stopTest();
        for (CaseDataMigBatch.CaseLookupMapper lm: lstLM) {
            System.assert(String.isNotBlank(lm.toSubType));
            System.assert(String.isNotBlank(lm.toNature));
            System.assert(String.isNotBlank(lm.toCause));
            System.assert(lm.mapped);
        }
        
    }
}