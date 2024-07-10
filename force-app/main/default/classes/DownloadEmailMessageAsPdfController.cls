/*
Description  : This Class is designed to parse subject of email message and keep it as file name of pdf.

* version       Date                Owner                                       Description
*******************************************************************************************************************
* V1.0           13/3/2022         sandeep.sankhla@maersk.com                    This class will parse subject of email message by removing thread id and then it will pass it to file name of pdf.     
*-------------------------------------------------------------------------------------------------------------------
*/

public class DownloadEmailMessageAsPdfController {
    
    public string strFileName {get;set;}// File Name of pdf which wll be downloaded.
    public EmailMessage objEmailMessage {get;set;}
    public String emCreatedDate {get;set;}
    
    public DownloadEmailMessageAsPdfController(ApexPages.StandardController controller){
        objEmailMessage = (EmailMessage)controller.getRecord();
        strFileName = 'Your Case Number Is:';
        EmailMessage em = [Select Id, CreatedDate From EmailMessage Where Id =: objEmailMessage.Id];
        emCreatedDate = em.CreatedDate.format();
        try{
            strFileName=objEmailMessage.Subject;
            strFileName = strFileName.split(',')[0];
        }
        catch(Exception ex){
        }
    }
    
}