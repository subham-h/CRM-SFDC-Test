/*
 * Author   : Ragu
 * Purpose  : Archive EmailMessages to save data storage. 
 *        
 * Revision Ref Number	Date        Owner                   Description
 * -------- ---------- 	-----------	------------------- 	-----------
 * 1.0		RQ-003182	21-Mar-2016	Ragu@UST	
 * 2.0		SFSE-9819	09-Dec-2022 Vazid			
 *  
 */

public with sharing class SOQLUtility {
    
    public static string getSelectQuery(SObject sObj) {
    	String strFields = '';
		for(Schema.SObjectField field : sObj.getSObjectType().getDescribe().fields.getMap().values()) {
		   strFields += field.getDescribe().getName() + ', ';
		}
		
		if(strFields.length() > 0) {
			strFields = strFields.subString(0, strFields.length() - 2);
		}
		return 'select ' + strFields + ' from ' + sObj.getSObjectType();
    }
    
    //SFSE-9819 : Below method is used to get all fields for related sobject except formula, system fields and fields marked as unique
    public static string getSelectQueryAvoidFormulaSystemFields(SObject sObj) {
        String strFields = '';
        for(Schema.SObjectField field : sObj.getSObjectType().getDescribe().fields.getMap().values()) {
            if(field.getDescribe().getCalculatedFormula() == null && !field.getDescribe().isCalculated() && field.getDescribe().iscreateable() && !field.getDescribe().isunique())
                
                strFields += field.getDescribe().getName() + ', ';
        }
        
        if(strFields.length() > 0) {
            strFields = strFields.subString(0, strFields.length() - 2);
        }
       return strFields;
    }
}