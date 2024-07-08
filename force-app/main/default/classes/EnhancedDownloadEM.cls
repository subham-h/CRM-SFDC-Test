/*
* Author   : Meghna@Maersk
* Purpose  : To clone the case along with attachments and contentversions linked to a case
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8241   01-August-2022  Meghna@Maersk       Download Email Message as HTML
*/
public with sharing class EnhancedDownloadEM
{
        public class WrapperEM {
        @AuraEnabled
        public String EMBody { get; set; }

        @AuraEnabled
        public String fileName { get; set; }
    }
        /** 
		* @description | SC-8241 Return Base64 for HTML download of EM record |
		* @param recordId accepts the case record Id
		* @return string base64 of HTML Body
		*/  

    @AuraEnabled
	public static WrapperEM getBase64HTML(Id recordId){	
        String EMbody;
        String strFileName;
        WrapperEM wrapper = new WrapperEM();
        List<EmailMessage> lstEM =[SELECT Id, HtmlBody,textbody,FromName,ToAddress,Subject, CreatedDate, CcAddress FROM EmailMessage where id=:recordId];
        String emCreatedDate = lstEM[0].CreatedDate.format();
        String headers='<div>From: '+lstEM[0].FromName+'<br>Sent: '+emCreatedDate+'<br>To: '+lstEM[0].ToAddress+'<br>Cc: '+(!String.isBlank(lstEM[0].CcAddress) ? lstEM[0].CcAddress : '')+'<br>Subject: '+lstEM[0].Subject+'<br><br><br><div>';
  
        EMBody=headers+lstEM[0].HtmlBody;
        strFileName = 'Your Case Number Is:';
        try{
            strFileName=lstEM[0].Subject;
            strFileName = strFileName.split(',')[0];

        }
        catch(Exception ex){
            system.debug('exception error'+ex.getMessage());
        }
        if(lstEM[0].HtmlBody==null && lstEM[0].textBody!=null)
        {
            EMbody=headers+lstEM[0].textbody;
        }
         else if(EMBody==null && lstEM[0].textbody==null){
            throw new AuraHandledException('Missing email body!!Please contact System Administrator for support');             
        }
       
        
        String Base64EMBody = EncodingUtil.base64Encode(Blob.valueof(EMBody));
        Blob blbEMbody= Blob.valueof(EMBody);
        wrapper.EMBody = Base64EMBody;
        wrapper.fileName= strFileName;
        return wrapper;
      
        
	}
   
}