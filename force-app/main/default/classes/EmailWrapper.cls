/*
 * Author   : Ranjini@UST
 * Purpose  : Wrapper class for Email message.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      RQ-006949   21-Sep-2017 Ranjini@UST             Created.
 */
public class EmailWrapper {
	
    public String strObject;
	public String strType;
	public String strFieldName;
	public Boolean bSaveAsActivity;
	public Boolean bDoChatterPost;
	public list<EmailDetail> lstEmailDetails;
	public enum EmailStatus {TEMPLATE_NOT_FOUND, TEMPLATE_FOUND, SUCCESS, FAILED}
	
	public EmailWrapper() {
		lstEmailDetails = new list<EmailDetail>();
	}
	
	public EmailWrapper(String objectName, String operationType) {
		strObject = objectName;
		strType = operationType;
		lstEmailDetails = new list<EmailDetail>();
		
		Email_Rule__mdt emailRule = EmailUtility.getEmailRule(strObject, strType);
		strFieldName = emailRule.Target_Object__c;
		bSaveAsActivity = emailRule.Save_As_Activity__c;
		bDoChatterPost = emailRule.Do_Chatter_Post__c;
	}
    
    public Class EmailDetail {
        public sObject sObj;
		public Id idOrgWideEmailAddress;
		public String strReplyToAddress;
		public String strChatterContent;
		public EmailStatus mailStatus;
		public list<Messaging.SendEmailError> lstSendEmailErrors;
		public list<String> lstFilterValues = new list<String>();
    }
    
}