/**
* This is  AFLS Quote Attachments Related list on AFLS Quote Detail Page with view and Del functionality.
* Also , Attach File button is there on related list.
* 
* 13/06/2014    anusha.ravipati@ust-global.com, code created as part of #Upstream
*/

public class AFLSQuoteAttachRelatedListExtController {

    /**
    * Variables used in the class.
    */  
    public List<quoteAttachWrapper> pagelist = new List<quoteAttachWrapper>();  //list which will show at VF page
    public List<Attachment>  attList = new List<Attachment>();  //attachment list
    public List<quoteAttachWrapper> quoteAttachWrapperList = new List<quoteAttachWrapper>();    //wrapper class list
    
    public string strGetVal{ get; set; }    //used in window.open() javascript method
    public string strQuoteId { get; set; }  //used to store the quote id
    public string strQuotAttachId{ get; set; }  //quote attachment id 
    public string alertMessage { get; set; }    //js alert message
    public string errorMessage { get; set; }    
    
    public boolean getblShowNext(){ return blShowNext; }    //show or disable next link in pagination
    public boolean getblShowPrev(){ return blShowPrev; }    //show or disable prev link in pagination
    public boolean blRelatedListShow{ get; set; }   //if no records are present the show "No records to display"
    
    List<AFLS_Quote_Attachment__c>  quoattList = new List<AFLS_Quote_Attachment__c>();  //quote attachment list
    Set<ID> quoattIdSet = new Set<ID>();    //quote attachment id set        
    integer iPagesize = 5; //used in pagination . Minimum size is 5 rows for pagination to work
    integer iCount; //used in pagination
    Boolean blShowNext; //used for pagination when need to show next button
    Boolean blShowPrev; //used for pagination when need to show previous button
    
    
    /**
    * Constructor.
    */
    public AFLSQuoteAttachRelatedListExtController( ApexPages.StandardController controller ) {
    
        //store the quote id
        strQuoteId=ApexPages.currentPage().getParameters().get('id');
        errorMessage=Label.AddErrorOppAttachDelete;
        
        //query on quote for quote id        
        for(Qt_Quote__c quo : [ SELECT (SELECT Id FROM QuoteAttachments__r ORDER BY CreatedDate desc) 
                                FROM Qt_Quote__c WHERE Id = :strQuoteId ]) {
                                
            //fetch out all quote attachment related to quote id
            for(AFLS_Quote_Attachment__c qua:quo.QuoteAttachments__r) {
                       
                //set of quote attachment
                quoattList.add(qua);
                
                //set of quote attachment id
                quoattIdSet.add(qua.id);
            }
        } 
        
        //find out all attachment details for qute attch id which is mentioned above in descending order
        attList = [ SELECT Id, Name, ParentId, CreatedDate, CreatedById FROM Attachment 
                    WHERE parentId IN : quoattIdSet 
                    ORDER BY CreatedDate DESC ]; 
        
        //iterate through all quote attachment list:  quoattList
        for( AFLS_Quote_Attachment__c quaFinal:quoattList ) {
        
            //iterate through all attachment list: attList
            for(Attachment attFinal:attList) {

                //doing mapping whcich attachment is related to quote attachment
                if(quaFinal.id == attFinal.parentId) {
                
                    //passing attachment and quote attachment object to wrapper class
                    quoteAttachWrapperList.add(new quoteAttachWrapper(quaFinal,attFinal));
                    
                }
            }
        }
        
        if( quoteAttachWrapperList.size() > 0) {
        
            blRelatedListShow=TRUE;
        }
            
        //for pagination
        if( quoteAttachWrapperList.size() > iPagesize ) { 
    
           for(Integer i=0; i<iPagesize; i++)
           pagelist.add(quoteAttachWrapperList[i]);       
           blShowNext = true; 
           
        } else{ 
                pagelist= quoteAttachWrapperList;  
        }  
    }
    
    
    
    //To call attach file button on the VF page
     public void attachFile() {
     
     //set value to empty string 
     strGetVal='';
     
        if( ApexPages.currentPage().getParameters().get('id') !=null)
        //passing quote id page link to URL parameter of window.open('{!strGetVal}',-----) so that it will open in same window.
        strGetVal='/apex/AFLSQuoteAttachment?qid='+strQuoteId;
    }
    
    
    
    //call when "Del" link is called from VF page
    public void delAttachement() {
    
        try {
            strGetVal='';
            //initialize to null
            AFLS_Quote_Attachment__c tobeDeleted = null;      
            //use quote attachment list related to quote and finding out which quote attachment need to be deleted
            
            for( AFLS_Quote_Attachment__c q:quoattList ) {
                if(q.id ==strQuotAttachId) {
                    tobeDeleted = q;
                    break;
                }
            }
            
            //delete the quote attachment which is select
            delete tobeDeleted; 
            
            if( ApexPages.currentPage().getParameters().get('id') !=null) {    

                //if successfully deleted then show this alert message on VF page
                alertMessage='Successfully deleted';
                //used in windoe.open() method in VF
                strGetVal ='/'+strQuoteId;     
            }
             
        }
        
        catch(Exception e) {
        
            system.debug('##### Exception :'+e);
            //if deletion fail then show this alert message on VF page
            alertMessage = 'An error occurred -- ' + e.getMessage() + 'Please contact administrator';
        }
    }
  
    // return null; 
    //call "View" link is click on VF page
    public PageReference viewAttachement() {
    
        strGetVal='';        
        //fetch the attachment id which need to view
        ID attId=System.currentPageReference().getParameters().get('attachid');
        //Url to redirect to file
        strGetVal = '/servlet/servlet.FileDownload?file='+attId;
        PageReference page = new PageReference(strGetVal); 
            page.setRedirect(true);
            return page; 
    }
    
    //Wrraper class contain attachment and quote attachment object
    public class quoteAttachWrapper {
    
        public AFLS_Quote_Attachment__c quaAttObj{ get; set; }
        public Attachment attObj{ get; set; }        
        
        //constructor of wrapper class
        public quoteAttachWrapper(AFLS_Quote_Attachment__c quoa,Attachment attach) {
            quaAttObj = quoa;
            attObj = attach;
        }
    }
        
    //wrapper list which is used in VF page
    public List<quoteAttachWrapper> getQuoteAttachmentWrapper() {
   
        return pagelist;
    }
    
    
    
    // calling previous button functionality in pagination
    public void previous()
    {
    try
        {
            blShowNext = true;
            pagelist.clear();
            Integer limit1 = 0; 
            iCount=5;      
            if(iPagesize-(iCount+iCount) > 0)
                limit1 = iPagesize-iCount;
            else
            {
                limit1 = iPagesize-iCount; 
                blShowPrev = false;
            }            
            for(Integer i=iPagesize-(iCount+iCount); i<limit1; i++)    
            pagelist.add(quoteAttachWrapperList[i]);
            iPagesize-=iCount; 
         }catch(Exception e)
            {
                system.debug('##### Exception :'+e);
            }               
     }
      
    //calling next button functionality in pagination
    public void next() {
    try {
            blShowPrev = true;
            pagelist.clear();
            Integer limit1 = 0;
            iCount=5;
            if(iPagesize+iCount < quoteAttachWrapperList.size())
                limit1 = iPagesize+iCount;
            else {
                limit1 = quoteAttachWrapperList.size();
                blShowNext = false;
            }
                
            for(Integer i=iPagesize; i<limit1; i++)
            pagelist.add(quoteAttachWrapperList[i]);
            iPagesize += iCount;
         }catch(Exception e) {
            system.debug('##### Exception :'+e);
        }
    }   
}