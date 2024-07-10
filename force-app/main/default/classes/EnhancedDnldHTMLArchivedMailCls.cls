/*
* Author   : Ranjan@Maersk
* Purpose  : Class To Download the Archived Email As pdf. it will convert the 
* 
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8241   20-Nov-2023  Ranjan@Maersk      Initial Version
*/
public with sharing class EnhancedDnldHTMLArchivedMailCls
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
        List<emailmessagearchival__x> lstEM=new List<emailmessagearchival__x>();
        try{
            
            if(!Test.isRunningTest()){
                 lstEM =[SELECT Id, messagedate__c,fromaddress__c, htmlbody__c,textbody__c,fromname__c,toaddress__c,subject__c,ccaddress__c FROM emailmessagearchival__x where id=:recordId];
            }else{
                emailmessagearchival__x objEM = new emailmessagearchival__x();
                objEM.Subject__c = 'Your Case Number is';
                objEM.HTMLBody__c = 'This is Just to test all the data';
                objEM.ToAddress__c = 'test@maersk.com';
                objEM.messagedate__c = '2023-09-22T17:18:58';
                objEM.fromname__c = 'QA Team';
                objEM.textbody__c= 'tst mail';
                objEM.fromaddress__c= 'test@maersk.com';
                objEM.ParentId__c = '5007E00000DCB92QAH';
                lstEM.add(objEM);
            }
        List<String> dateStrArray=lstEM[0].messagedate__c.split('T')[0].split('-');
        List<String> timeStrArray=lstEM[0].messagedate__c.split('T')[1].split(':');

        String strDate= DateTime.newInstance(Integer.valueof(dateStrArray[0]),
                                    Integer.valueof(dateStrArray[1]),
                                    Integer.valueof(dateStrArray[2]),
                                    Integer.valueof(timeStrArray[0]),
                                    Integer.valueof(timeStrArray[1]),
                                    Integer.valueof(timeStrArray[2])).formatGMT('EEEE, d MMMM yyyy HH:mm');
        String fromAddress=(lstEM[0].fromaddress__c!=null?'<'+lstEM[0].fromaddress__c+'>':'');
            String ccAddress=(lstEM[0].ccaddress__c!=null?'<br>Cc: '+lstEM[0].ccaddress__c:'');
            String headers='<div>From: '+lstEM[0].FromName__c+fromAddress+'<br>Sent: '+strDate+'<br>To: '+lstEM[0].ToAddress__c+ccAddress+'<br>Subject: '+lstEM[0].Subject__c+'<br><br><br><div>';
    
            EMBody=headers+lstEM[0].HtmlBody__c;
            strFileName = 'Your Case Number Is:';
            
            strFileName=lstEM[0].Subject__c;
            strFileName = strFileName.split(',')[0];

        
        if(lstEM[0].HtmlBody__c==null && lstEM[0].textbody__c!=null)
        {
            EMbody=headers+lstEM[0].textbody__c;
        }
         else if(EMBody==null && lstEM[0].textbody__c==null){
            throw new AuraHandledException('Missing email body!!Please contact System Administrator for support');             
        }
       
        
        String Base64EMBody = EncodingUtil.base64Encode(Blob.valueof(EMBody));
        Blob blbEMbody= Blob.valueof(EMBody);
        wrapper.EMBody = Base64EMBody;
        wrapper.fileName= strFileName;
        
    }
    catch(Exception ex){
        throw new AuraHandledException('exception error'+ex.getMessage());
    }
        return wrapper;
      
        
	}
   
}