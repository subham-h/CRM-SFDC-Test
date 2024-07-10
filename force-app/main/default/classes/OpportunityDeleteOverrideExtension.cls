/*
Class Name : OpportunityDeleteOverrideExtension
Description  : 1. This Class is used as a Extension to 'OpportunityDeleteOverride' VF page to override the Delete button fuctionality 
                  of Opportunity Object,it is used to check whether Quote is send to mail or not, if it is sent then prevent user
                  to delete record.
Created By   : Cognizant Technology Solutions
Created On   : 26/06/2012
Change Log
--------------------------------------------------------------------------
Sr# Description                                Updated By       Updated On
1.  Added class comments                       CTS              26/06/2012
--------------------------------------------------------------------------  
*/

public with sharing class OpportunityDeleteOverrideExtension {

//Variable declaration
public Opportunity opportunityObj{get;set;}

    //Constructor
    public OpportunityDeleteOverrideExtension(ApexPages.StandardController controller) {
    opportunityObj =[Select Id, (Select Id, Send_To_Mail__c From Quotes) From Opportunity where Id=:ApexPages.currentPage().getParameters().get('Id')];
    }
   //Method for delete Action and to check whether Quote is sent to Mail or not if it is sent then prevent user to delete record. 
    public PageReference  deleteAction(){
    /*  Boolean preventDeleteBoolean = false;
        for(Quote quoteObj: opportunityObj.Quotes){
            if(quoteObj.Send_To_Mail__c){
                preventDeleteBoolean=true;
                break;  
            }
        } */
        if(opportunityObj.Quotes.size()>0){
            return null;
        }else {
            try{
                delete opportunityObj;
                string strOpp =Schema.SObjectType.Opportunity.getKeyPrefix()+'/o';
                PageReference pf = new PageReference('/'+strOpp);
                return pf;
            }catch(DMLException e){
               return null;
            }
        }
    
    }
    //Method to redirect user to Quote Record detail page if it is sent
    public Pagereference redirectUrl(){
        PageReference pf = new PageReference('/'+opportunityObj.Id);
        return pf;
    }
    
}