/*
Class Name : OpportunityAttachmentController
Description  : 1. opportunity attachment creation ,on click of 'Attach File' button on Opportunity Attachemnts Related list on Quote Detail Page
Created By    : Cognizant Technology Solutions
Created On   : 28/03/2012
Change Log
--------------------------------------------------------------------------
Sr# Description                                Updated By       Updated On
--------------------------------------------------------------------------  
*/ 

public class OpportunityAttachmentController{
    //variable declaration
    public string strOppId{get;set;}//Opportunity ID string
    public Opportunity_Attachment__c  objOppAttachment;//Opportunity Attachment Object
    public Opportunity objOpp{get;set;}//Opportunity Object
    public Attachment  objAttachment{get;set;}
    public Opportunity_Attachment__c objOppAttachmentShow{get;set;}
    public Boolean bUploadMsg{get;set;}//used For rerendered if true show the attachment details :name,size,type  on UI.
    public String strFileSize{get;set;}//used to store file size

    /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
    public String fileSize(integer value){
     if (Value < 1024)
       return string.valueof(Value) + ' Bytes';
     else
     if (Value >= 1024 && Value < (1024*1024)){
       //KB
       Decimal kb = Decimal.valueOf(Value);
       kb = kb.divide(1024,2);
       return string.valueof(kb) + ' KB';
     }
     else
     if (Value >= (1024*1024) && Value < (1024*1024*1024)){
       //MB
       Decimal mb = Decimal.valueOf(Value);
       mb = mb.divide((1024*1024),2);
       return string.valueof(mb) + ' MB';
     }
     else 
         return null;
    }
    
    // Opportunity Attachment getter
     public Opportunity_Attachment__c getobjOppAttachment(){
        return objOppAttachment;
     }
    
    //Opportunity Attachment Setter
   public void setobjOppAttachment(Opportunity_Attachment__c objOppAttachment){
        this.objOppAttachment= objOppAttachment;
    }
    
    //Constructor
    public OpportunityAttachmentController(ApexPages.StandardController stdcontroller){
       bUploadMsg=FALSE;
       if(ApexPages.currentPage().getParameters().get('qid')!=null)
       strOppId=ApexPages.currentPage().getParameters().get('qid');
        //used this variable to show Opportunity name in VF page
       objOpp=[select name from Opportunity where id=:strOppId];
       //creating Opportunity attachment object
       objOppAttachment= new Opportunity_Attachment__c();
    }

    //Create attachemnet object
    public Attachment attachment{
        get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
        }
        set;
    }
 
    //Call when click Attach File Button from VF Page ,used to save the attachment in attachment object and Type(custom field) into Opportunity Attcahment Object.
    public PageReference upload(){
            //assign quote ID to Opportunity attachment object
            objOppAttachment.Opportunity__c=strOppId;

                //insert Opportunity attachment object
            insert objOppAttachment;
 
                attachment.OwnerId = UserInfo.getUserId();
                attachment.ParentId = objOppAttachment.id; // the record the file is attached to
                attachment.IsPrivate = false;
 
                try 
                {
                    //insert attachment object
                  insert attachment;
                  //Fetch the attachment object fields
                  objAttachment=[SELECT BodyLength,Name FROM Attachment where id=:attachment.id];
                  //Call filesize method so that able to find size in Bytes ,KB and MB and then used this strFileSize variable to show in UI after attachment uploaded successfully.
                   strFileSize=fileSize(objAttachment.BodyLength);
                   //used this objOppAttachmentShow variable to show Type of attachment in UI after attachment uploaded successfully.
                  objOppAttachmentShow=[select Type__c FROM Opportunity_Attachment__c where id=:objOppAttachment.id];
                  bUploadMsg=TRUE;
                }
                catch (DMLException e){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
                  //Don't show attachment details if this variable is  false or error has occured so attachment is not uploaded
                  bUploadMsg=FALSE;
                  return null;
                } 
                finally{
                    //create new attachment object
                  attachment = new Attachment();
                    //create new Opportunity attachment object                  
                  objOppAttachment= new Opportunity_Attachment__c();
                }        
    return null;
    }
  
  //Call when click "Done" button on VF Page and go to the quote page
  public pageReference backToQuotePage(){
  PageReference OppPage;
  OppPage= new PageReference('/'+strOppId); 
  OppPage.setRedirect(true);
  return OppPage;
  } 
}