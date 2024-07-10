/*
 * Author   : Ragu@UST
 * Purpose  : Generic SObject related utility methods.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      General  	29-Nov-2016 Ragu@UST            	Created.
 * 		
 */

public class SObjectUtilities {

	// Returns set<Id> for the given list<sObject>
	public static set<Id> getIds(list<sObject> lstSObjects) {
		set<Id> setIds = new set<Id>();
		for(sObject sObj : lstSObjects) {
			setIds.add((Id)sObj.get('Id'));
		}
		return setIds;
	}

}