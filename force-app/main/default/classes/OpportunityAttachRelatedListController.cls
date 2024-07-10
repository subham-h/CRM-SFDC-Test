/*
Class Name : OpportunityAttachRelatedListController
Description  : 1. Opportunity Attachments Related list on Quote Detail Page with view and Del functionality .Also , Attach File button is there on related list.
Created By    : Cognizant Technology Solutions
Created On   : 28/03/2012
Change Log
--------------------------------------------------------------------------
Sr# Description                                Updated By       Updated On
--------------------------------------------------------------------------  
*/ 

public class OpportunityAttachRelatedListController
{
        
    Public boolean getblShowNext(){return blShowNext;}//show or disable next link in pagination
    Public boolean getblShowPrev(){return blShowPrev;}//show or disable prev link in pagination  
    public List<Attachment>  attList=new List<Attachment>();//attachment list
    public List<oppAttachWrapper> oppAttachWrapperList = new List<oppAttachWrapper>();//wrapper class list
    List<Opportunity_Attachment__c>  oppattList=new List<Opportunity_Attachment__c>();//Opportunity attachment list
    Set<ID> oppattIdSet= new Set<ID>();//Opportunity attachment id set
    public String strGetVal{get;set;}//used in window.open() javascript method
    public string strOpportId {get;set;}//used to store the quote id
    public boolean blRelatedListShow{get;set;}//if no records are present the show "No records to display"
    public String errorMessage {get;set;}
    public List<oppAttachWrapper> pagelist = new List<oppAttachWrapper>();//list which will show at VF page
    integer iPagesize = 5;//used in pagination . Minimum size is 5 rows for pagination to work
    integer iCount;//used in pagination
    Boolean blShowNext;//used for pagination when need to show next button
    Boolean blShowPrev;//used for pagination when need to show previous button
    public String strOppAttachId{get;set;}//Opportunity attachment id 
    public String alertMessage {get;set;}//js alert message
    
    //constructor
    public OpportunityAttachRelatedListController(ApexPages.StandardController controller) 
    {
            //store the Opportunity id
        strOpportId =ApexPages.currentPage().getParameters().get('id');
        errorMessage=Label.AddErrorOppAttachDelete;
        //query on quote for Opportunity id
        for(Opportunity quo : [Select (Select Id, Type__c,Opportunity__c From Opportunity_Attachments__r order by CreatedDate desc) From Opportunity where id = :strOpportId ])
        {
                //fetch out all Opportunity attachment related to Opportunity id
             for(Opportunity_Attachment__c qua:quo.Opportunity_Attachments__r)
             {
                //set of Opportunity attachment
                oppattList.add(qua);
                //set of Opportunity attachment id
                oppattIdSet.add(qua.id);
             }
        }
            //find out all attachment details for Opportunity attch id which is mentioned above in descending order
        attList=[Select Id, ParentId, Name, CreatedDate, CreatedById From Attachment where parentId IN : oppattIdSet order by CreatedDate desc]; 
        
        //iterate through all Opportunity attachment list:  oppattList
        for(Opportunity_Attachment__c quaFinal:oppattList)
        {
        //iterate through all attachment list: attList
            for(Attachment attFinal:attList)
                {
                //doing mapping whcich attachment is related to Opportunity attachment
                    if(quaFinal.id==attFinal.parentId)
                    {
                    //passing attachment and Opportunity attachment object to wrapper class
                    oppAttachWrapperList .add(new oppAttachWrapper(quaFinal,attFinal));
                    }
                }
        }
        
        if(oppAttachWrapperList .size()>0)
            {
                blRelatedListShow=TRUE;
            }
            
             //for pagination
        if(oppAttachWrapperList .size()>iPagesize)  
             {     
               for(Integer i=0; i<iPagesize; i++)
               pagelist.add(oppAttachWrapperList [i]);       
               blShowNext = true;   
             }
          else
             { 
                pagelist= oppAttachWrapperList ;  
             }  
    }
    
    //To call attach file button on the VF page
     public void attachFile()
     {
     //set value to empty string 
        strGetVal='';
         
        if( ApexPages.currentPage().getParameters().get('id') !=null)
        //passing quote id page link to URL parameter of window.open('{!strGetVal}',-----) so that it will open in same window.
            strGetVal='/apex/OpportunityAttachment?qid='+strOpportId ;
     }
    
    //call when "Del" link is called from VF page
    public void delAttachement()
    { 
        try
        {
            strGetVal='';
            //initialize to null
            Opportunity_Attachment__c tobeDeleted = null;      
            //use Opportunity attachment list related to quote and finding out which Opportunity attachment need to be deleted
            for(Opportunity_Attachment__c q:oppattList)
            {
                if(q.id ==strOppAttachId)
                {
                    tobeDeleted = q;
                    break;
                }
            }
            
            //delete the Opportunity attachment which is select
            delete tobeDeleted;       
            
            if( ApexPages.currentPage().getParameters().get('id') !=null)    
            {
                //if successfully deleted then show this alert message on VF page
                alertMessage='Successfully deleted';
                //used in windoe.open() method in VF
                strGetVal ='/'+strOpportId ;     
            }
        } catch(Exception e)
          {
             system.debug('Exception :'+e);
             //if deletion fail then show this alert message on VF page
             alertMessage = 'An error occurred -- ' + e.getMessage() + 'Please contact administrator';
         }
  }
  
 // return null; 
  //call "View" link is click on VF page
     public PageReference viewAttachement()
    {
        strGetVal='';        
        //fetch the attachment id which need to view
        ID attId=System.currentPageReference().getParameters().get('attachid');
        //Url to redirect to file 
        strGetVal = '/servlet/servlet.FileDownload?file='+attId;
        PageReference page = new PageReference(strGetVal); 
        page.setRedirect(true);
        return page;  
    }
    
    //Wrraper class contain attachment and Opportunity attachment object
    public class oppAttachWrapper
    {
        public Opportunity_Attachment__c quaAttObj{get; set;}
        public Attachment attObj{get; set;}        
        //constructor of wrapper class
        public oppAttachWrapper(Opportunity_Attachment__c quoa,Attachment attach)
        {
        quaAttObj=quoa;
        attObj=attach;
        }
    }
        
        //wrapper list which is used in VF page
     public List<oppAttachWrapper> getQuoteAttachmentWrapper()
        {   
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
                    pagelist.add(oppAttachWrapperList [i]);
                    iPagesize-=iCount; 
                 }catch(Exception e)
                    {
                        system.debug('Exception :'+e);
                    }               
     }
      
      //calling next button functionality in pagination
     public void next() {
        try {
            blShowPrev = true;
            pagelist.clear();
            Integer limit1 = 0;
            iCount=5;
            if(iPagesize+iCount < oppAttachWrapperList .size())
                limit1 = iPagesize+iCount;
            else {
                limit1 = oppAttachWrapperList .size();
                blShowNext = false;
            }
                
            for(Integer i=iPagesize; i<limit1; i++)
            pagelist.add(oppAttachWrapperList [i]);
            iPagesize += iCount;
         }catch(Exception e) {
            system.debug('Exception :'+e);
         }
     }
      
    }