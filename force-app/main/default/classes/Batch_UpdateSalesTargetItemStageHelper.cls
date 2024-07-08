/*              
* Revision Ref Number  Date          Owner                  Description
* -------- ----------  -----------   -----------------      -----------
* 1.0      SFSE-11471  10-Oct-2023   Shubham                Helper class for Batch_UpdateSalesTargetItemStage running in System Context
*/
public without sharing class Batch_UpdateSalesTargetItemStageHelper {
    
    public static Boolean checkApprovalStageUpdate(String targetId, String stageName) {
        return [SELECT Id FROM Target_Item__c WHERE Target__c = :targetId AND Review_Stage__c != :stageName LIMIT 1]?.size() == 0 ? true : false;   
    }
    
    public static void updateTarget(Target__c target) {
        update target;
    }
    
    public static List<String> getReviewerList(String targetId, String stageName) {
        List<String> emailAddressList = new List<String>();
        if (stageName != TargetSettingConstants.APPROVAL_STAGE_2) {
            List<Target_Reviewer__c> targetReviewList = [SELECT Id, Related_User__c, Related_User__r.Email FROM Target_Reviewer__c WHERE 
                                                         Target_Approval_Matrix__r.Target_Stage__c = :stageName AND 
                                                         Target_Approval_Matrix__r.Target__c = :targetId AND Related_User__c != null];
            for (Target_Reviewer__c targetReview : targetReviewList) {
                emailAddressList.add(targetReview.Related_User__r.Email);
            }
        } else {
            Batch_SendApprovalEmailToGlobalOwners bch = new Batch_SendApprovalEmailToGlobalOwners(targetId, false);
            DataBase.executeBatch(bch,Integer.valueOf(Label.Items_Approval_GAO_Email_Batch_Size));
        }
        return emailAddressList;
    }
    
    public static void sendReviewEmail(String targetId, String stageName) {
        List<String> emailAddressList = getReviewerList(targetId, stageName);
        createEmail(emailAddressList,targetId);
        if (stageName == TargetSettingConstants.APPROVAL_STAGE_2) {
            Batch_UpdateItemsWithoutGAO bch = new Batch_UpdateItemsWithoutGAO(targetId,stageName);
            DataBase.executeBatch(bch, Integer.valueOf(Label.Items_Approval_Batch_Size));
        }
    }
    
    public static void createEmail(List<String> emailAddressList, String targetId) {
        if (emailAddressList != null && emailAddressList.size() > 0) {
            String subject = 'Sales Target - Ready for your review and approval';
            String targetURL = URL.getOrgDomainURL().toExternalForm() + '/' + targetId;
            String body = '<html><body>Dear Approver,<br/><br/>Sales target items are ready for your review and approval. Please login <a href="' + targetURL + '">here</a> to proceed.';
            body += '<br/><br/>Regards,<br/><br/>Sales Target Administrator<br/><br/>Note: This is an automated email. Response to this email is not monitored.</body></html>';
            sendEmail(subject, body, emailAddressList);
        }
    }
    
    public static void sendEmail(String subject, String body, List<String> toAddressesList) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setToAddresses(toAddressesList);
        mail.setHTMLBody(body);
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
    
    public static void updateTargetApprover(List<Target_Reviewer__c> approvalUserList) {
        for (Target_Reviewer__c approver  : approvalUserList) {
            approver.Approved__c = true;
        }
        update approvalUserList;
    }
    
}