/*
* Author   : Sidhartha
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      RQ-008771   09/08/2018  sidhartha               Code created
* 
*/
public class ContactSendLogCtrl {
    public EmailServicesFunction efn {get;set;}
    public List<EmailServicesAddress> eddList {get;set;}
    public String localPrt {get;set;}
    public String emailDomainnm {get;set;}
    public ContactSendLogCtrl (ApexPages.StandardController stdController) {
        localPrt = null;
        emailDomainnm = null;
    }
    
    public void checkuniqueEmailDomain() {
        efn = [select id from EmailServicesFunction where FunctionName ='EmailToSalesforce' limit 1];
        if(efn !=null) {
            eddList = [select Id,RunAsUserId,AuthorizedSenders,FunctionId,LocalPart,EmailDomainName from EmailServicesAddress where FunctionId =:efn.Id and RunAsUserId =:UserInfo.getUserId()];
        }
        if(eddList !=null && eddList.size() >0){
            for(EmailServicesAddress es: eddList) {
                localPrt = es.LocalPart;
                emailDomainnm = es.EmailDomainName;   
            }
            }
    }
}