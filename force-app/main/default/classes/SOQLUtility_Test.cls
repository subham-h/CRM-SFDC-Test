/*
 * Purpose  : Test SOQLUtility. 
 *        
 * Revision Ref Number	Date        Owner                   Description
 * -------- ---------- 	-----------	------------------- 	-----------
 * 1.0		RQ-003315	04-Apr-2016	Ragu@UST				Created.
 * 2.0      SFSE-9819   09-Dec-2022 Vazid					Added getSelectQueryAvoidFormulaSystemFields method
 */
@isTest
private class SOQLUtility_Test {

    static testMethod void test_getSelectQuery() {
		String strQuery1 = SOQLUtility.getSelectQuery(new Task());
		System.assertNotEquals(strQuery1, '');
        String strQuery2 = SOQLUtility.getSelectQueryAvoidFormulaSystemFields(new Task());
    }

}