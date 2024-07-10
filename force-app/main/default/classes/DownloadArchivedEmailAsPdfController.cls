public with sharing class DownloadArchivedEmailAsPdfController {

    public String strFileName {get;set;}// File Name of pdf which wll be downloaded.
    public emailmessagearchival__x objEmailMessage {get;set;}
    public String strDate {get;set;}// File Name of pdf which wll be downloaded.
    public String strName{get;set;}
    public DownloadArchivedEmailAsPdfController(ApexPages.StandardController controller){
         objEmailMessage = (emailmessagearchival__x)controller.getRecord();
    
        
            strFileName = 'Your Case Number Is:';
        try{
            strFileName=objEmailMessage.Subject__c;
            strFileName = strFileName.split(',')[0];
            List<String> dateStrArray=objEmailMessage.messagedate__c.split('T')[0].split('-');
            List<String> timeStrArray=objEmailMessage.messagedate__c.split('T')[1].split(':');

            strDate= DateTime.newInstance(Integer.valueof(dateStrArray[0]),
                                        Integer.valueof(dateStrArray[1]),
                                        Integer.valueof(dateStrArray[2]),
                                        Integer.valueof(timeStrArray[0]),
                                        Integer.valueof(timeStrArray[1]),
                                        Integer.valueof(timeStrArray[2])).formatGMT('EEEE, d MMMM yyyy HH:mm');                            
            strName=' <'+objEmailMessage.fromaddress__c+'>';

        }
        catch(Exception ex){
            throw new AuraHandledException('exception error'+ex.getMessage());
        }
        
    
               
        
        
    }
}