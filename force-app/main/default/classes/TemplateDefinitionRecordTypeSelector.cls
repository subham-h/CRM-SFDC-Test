public class TemplateDefinitionRecordTypeSelector {

    public Quote_Template__c TD = New Quote_Template__c();
    
    public TemplateDefinitionRecordTypeSelector(ApexPages.StandardController controller) {

        TD = (Quote_Template__c)controller.getRecord();

    }

    public Pagereference redirectToPage()
    {
        Schema.DescribeSObjectResult TDSObjectResult = Schema.SObjectType.Quote_Template__c; 
        Map<ID,Schema.RecordTypeInfo> rtMapByID = TDSObjectResult.getRecordTypeInfosByID();
        String prefix = TDSObjectResult.getKeyPrefix();
        String recordtypename;
                
        if( ApexPages.currentPage().getParameters().get('Id') == null )
        {
            String selectedRecordType = ApexPages.currentPage().getParameters().get('RecordType');
            recordtypename = rtMapByID.get(selectedRecordType).Name;
                  
            if (recordtypename == 'Planning Data Template')
            {
                PageReference pgref =  new PageReference('/'+prefix+'/e?nooverride=1&retURL=/'+prefix+'/o&RecordType='+selectedRecordType);
                pgref.setredirect(true);
                return pgref;
            }  
            
            /***
            *
            * #Upstream - Made change in the code below for differentiating AFLS Quote email templates and Quote Email Templates
            *             while creating Template definition record
            *
            ***/
            else if( recordtypename == 'Quote Email Template' )            
            {
                PageReference pgref =  new PageReference('/apex/QuoteEmailTemplateEdit?retURL=/'+prefix+'/o&RecordType='+selectedRecordType+'&isAFLSQt=False');
                pgref.setredirect(true);
                return pgref;
            }          
            else
            {
                PageReference pgref =  new PageReference('/apex/QuoteEmailTemplateEdit?retURL=/'+prefix+'/o&RecordType='+selectedRecordType+'&isAFLSQt=True');
                pgref.setredirect(true);
                return pgref;
            }                
        }
        else if( ApexPages.currentPage().getParameters().get('Id') != null )
        {
            ID RecordId = ApexPages.currentPage().getParameters().get('Id');          
    
            if( TD.RecordTypeId != null )
                recordtypename = rtMapByID.get(TD.RecordTypeId).Name;
    
            if(recordtypename == 'Planning Data Template')
            {
                PageReference pgref =  new PageReference('/'+RecordId+'/e?retURL=/'+RecordId+'&nooverride=1');
                pgref.setredirect(true);
                return pgref;
            }
            
            /***
            *
            * #Upstream - Made change in the code below for differentiating AFLS Quote email templates and Quote Email Templates
            *             while creating Template definition record
            *
            ***/
            
            else if( recordtypename == 'Quote Email Template' )            
            {
                PageReference pgref =  new PageReference('/apex/QuoteEmailTemplateEdit?id='+RecordId+'&isAFLSQt=False&retURL=%2F'+RecordId);
                pgref.setredirect(true);
                return pgref;
            } else
            {
            
                PageReference pgref =  new PageReference('/apex/QuoteEmailTemplateEdit?id='+RecordId+'&isAFLSQt=True&retURL=%2F'+RecordId);
                pgref.setredirect(true);
                return pgref;
            }
        }                    
        return null;
    }
}