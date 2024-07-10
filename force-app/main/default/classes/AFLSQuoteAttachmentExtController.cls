/**
* AFLS Quote Attachment creation, on click of 'Attach File' button on QuoteAttachemnts Related list on AFLS Quote Detail Page.
* 
* 13/06/2014 anusha.ravipati@ust-global.com, code created as part of #Upstream.
*/

public class AFLSQuoteAttachmentExtController {



    /**
    * Variables used in the class.
    */                
    public Qt_Quote__c  objQuote{ get; set; }   //Quote Object
    public Attachment  objAttachment{ get; set; }
    public AFLS_Quote_Attachment__c objQuoteAttachmentShow{ get; set; }
    public AFLS_Quote_Attachment__c  objQuoteAttachment;    //Quite Attachment Object
    public boolean bUploadMsg{get;set;}     //used For rerendered if true show the attachment details :name,size,type  on UI.
    public String strFileSize{get;set;}     //used to store file size
    public string strQuoteId{ get; set; }   //Quote ID string
      
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
    
    
    // Quote Attachment getter
    public AFLS_Quote_Attachment__c getObjQuoteAttachment(){
        return objQuoteAttachment;
    }
    
    //Quote Attachment Setter
    public void setObjQuoteAttachment(AFLS_Quote_Attachment__c objQuoteAttachment) {
        this.objQuoteAttachment= objQuoteAttachment;
    }
    
    
    
    /**
    * Constructor.
    */
    public AFLSQuoteAttachmentExtController(ApexPages.StandardController stdcontroller){
    
       bUploadMsg=FALSE;
       if(ApexPages.currentPage().getParameters().get('qid')!=null)
       strQuoteId=ApexPages.currentPage().getParameters().get('qid');
       
       //used this variable to show quote name in VF page
       objQuote=[SELECT Id, Name FROM Qt_Quote__c WHERE Id=:strQuoteId];
       
       //creating quote attachment object
       objQuoteAttachment= new AFLS_Quote_Attachment__c();
    }

    //Create attachemnet object
    public Attachment attachment {
    
        get {
            if (attachment == null)
            attachment = new Attachment();
            return attachment;
        }
        set;
    }

    //Call when click Attach File Button from VF Page ,used to save the attachment in attachment object and Type(custom field) into Quote Attcahment Object.
    public PageReference upload(){
    
        System.SavePoint lOrignalState =  database.setSavepoint();
        
        //assign quote ID to quote attachment object
        objQuoteAttachment.Quote__c = strQuoteId;
        
        //insert quote attachment object
        insert objQuoteAttachment;

        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = objQuoteAttachment.id; // the record the file is attached to
        attachment.IsPrivate = false;

        try 
        {
           //insert attachment object
          insert attachment;
          
          //Fetch the attachment object fields
          objAttachment=[SELECT BodyLength,Name FROM Attachment WHERE Id=:attachment.Id];
          
          //Call filesize method so that able to find size in Bytes ,KB and MB and then used this strFileSize variable to show in UI after attachment uploaded successfully.
           strFileSize=fileSize(objAttachment.BodyLength);           
           bUploadMsg = true;
        }
        
        catch (DMLException e){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
          //Don't show attachment details if this variable is  false or error has occured so attachment is not uploaded
          bUploadMsg = false;
          database.rollback(lOrignalState);
          return null;
        } 
        finally{
            
            //create new attachment object
            attachment = new Attachment();
            //create new quote attachment object                  
            objQuoteAttachment= new AFLS_Quote_Attachment__c();
        }        
        return null;
    }
  
    //Call when click "Done" button on VF Page and go to the quote page
    public pageReference backToQuotePage(){
          PageReference quotePage;
          quotePage = new PageReference('/'+strQuoteId); 
          quotePage.setRedirect(true);
          return quotePage;
    } 
}