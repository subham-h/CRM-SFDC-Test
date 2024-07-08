/**
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for Case. 
 *        
 * Revision Ref Number	Date        	Owner                   				Description
 * -------- ---------- 	-----------		------------------- 					-----------
 * 1.0		#RQ-002633	18/02/2016		Ragupathivel.Thangavel@ust-global.com	Created for implementing CBO (Centralized By Org) trigger architecture.
 * 2.0      #RQ-001773  23/03/2016      Ranjini.Janardhanan@ust-global.com      Updated getLinerBrandLogic method to include Seago.
 * 3.0      #RQ-003805  13-Dec-2016     Nirmal@UST                              To trigger Assignment rules and auto response rules for portal created cases
 * 4.0      #RQ-006949  21-Sep-2017     Ranjini@UST             				Added method to generate unique code.
 * 5.0 	    IIP-149	    24-08-2020	    Avinash@ust								Import Manifest Case - Auto Update
 * 6.0      SPI-100     17-06-2022      Ronnie@SF                               Removed brand hardcoding
 */

public class CaseUtilities {
    
	// Method to generate Liner Brand Logic for case- sherin
	public static String getLinerBrandLogic(Case caseInstance) {
        
        if (caseInstance.MLL__c == true && BrandUtilities.getListOfAllNamesForBrand(BrandUtilities.MAERSKLINE).contains(caseInstance.Liner_Brand__c)) {
            return BrandUtilities.USFLAG;
        } else if (caseInstance.MLL__c == false) {
            return caseInstance.Liner_Brand__c;
        }
        return null;
	}
	
	public static Boolean fieldsChanged(Case newCase, Case oldCase, list<String> lstFieldAPINames) {
		Boolean bChanged = false;
		for(String strFieldName : lstFieldAPINames) {
			if(newCase.get(strFieldName) != oldCase.get(strFieldName)) {
				bChanged = true;
				break;
			}
		}
		return bChanged;
	}
	
    // RQ-003805 To trigger Assignment rules and auto response rules for portal created cases
    public static void fireAssignmentAndAutoResponse(set<Id> setCaseIdsToSetDMLOptions) { 
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.assignmentRuleHeader.useDefaultRule = true;
        dml.emailHeader.triggerAutoResponseEmail = true;
        DMLOptionsUtility DMLOptionsUtility_Inputs = new DMLOptionsUtility(setCaseIdsToSetDMLOptions, dml);
    }
    
    // IIP-149 - To trigger Assignment rules and auto response rules for portal created cases for agent workflow
    public static void fireAssignmentRules(set<Id> setCaseIdsToSetDMLOptionsAW){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.assignmentRuleHeader.useDefaultRule = true;
        dml.emailHeader.triggerAutoResponseEmail = false;
        DMLOptionsUtility DMLOptionsUtility_Inputs = new DMLOptionsUtility(setCaseIdsToSetDMLOptionsAW, dml);
    }
    
    //#RQ-006949. Method to generate unique code. This code will be used in the Survey record.
    public static String generateRandomUniqueCode () {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
		Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
		String uniqueString = EncodingUtil.convertToHex(hash);
		return uniqueString;
    }
}