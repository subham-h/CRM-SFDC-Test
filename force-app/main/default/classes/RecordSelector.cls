/*
 * Author   : Ragu@UST
 * Purpose  : Enforces methods to be defined in the inherited record selector classes.
 *          Classes which are implementing this interface should define methods selectRecords(list, map) and getRelatedRecords(list). 
 * 
 * Revision Ref Number	Date        Owner                   Description
 * -------- ---------- 	-----------	------------------- 	-----------
 * 1.0		RQ-002633	18-Feb-2016	Ragu@UST				Created for implementing CBO (Centralized By Org) trigger architecture.
 * 
 */

public interface RecordSelector {
    
    void selectRecords(list<sObject> records, map<Id, sObject> oldRecords);
    void getRelatedRecords(list<sObject> records);
	
}