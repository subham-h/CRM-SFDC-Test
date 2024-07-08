/**
 * This extension Class is for 'AFLSQuote' VF page is used to open AFLS app in a new tab, for creating and editing AFLS Quote.
 * This class is also used to open QOG app in a IFRAME for generation AFLS Quote Output.
 * 
 * Revision    Ref Number   Date          Owner                              Description
 * --------    ----------   -----------   -------------------                -----------
 * 1.0                      06-03-2014    Shiva.Nampally@ust-global.com      code created as part of #Upstream.
 * 2.0         PR-00031_2   29-12-2014    Madhava.kotte@ust-global.com       For checking the Secondary email of primary contact
 * 3.0         RQ-001503    03-06-2015    revathy.sudhindran@ust-global.com  Allow people to use Quote Builder, AFLS or both tools to quote
 * 4.0         RQ-001889    01-09-2015    Madhava.kotte@ust-global.com       Added Carrier codes for Sealand and MCC liner brands
 * 5.0         PR-0055      17-12-2015    Sunu.Paul@ust-global.com           Added Carrier code for Seago liner brand  
 * 6.0         RQ-002950    27-02-2016    meghana.gupta@ust-global.com       Quote Builder decommisioning
 * 7.0         RQ-004136    15-07-2016    deepak.r.mahapatra@in.ibm.com      Added the Else part @line# 175 to 177 for if ( String.isNotEmpty( opportunityOwner.Region__c ) )
 * 8.0         RQ-004643    03-03-2017    deepak.r.mahapatra@in.ibm.com      Delete Quoting Tool Field in the User object
 * 9.0         RQ-012362    12-11-2019    manjunath@maersk                   Removed reference of Account.Primary_Contact__c
 * 10.0        RQ-012758    29-01-2020    Amritesh@UST                       Included code to assign MLL carrier code if loggedIn user is MLL User
 * 11.0        SPI-100      07-06-2022	  Ronnie@SF                          Removed brand hardcoding
 */

public class AFLSQuoteExtController {
    
    
    
    /**
    * Variables used in the class.
    */
    public Opportunity opportunityObj { get; set; }
    public Qt_Quote__c aflsQuoteObj {get; set; }
    public User opportunityOwner { get; set; }  
    public String strOpportunityID { get; set; }  
    public String strQuoteID { get; set; }
    public String iFrameSrc { get; set; }   
    public Boolean showIframe{ get; set; }   
    public Boolean isGenerateOutput{ get; set; } // Flag used to identify Generate Ouput.   
    public Boolean showError; // Flag set to true when validation  error occurs
   
   
   
    /**
    * Constructor.
    */
    public AFLSQuoteExtController(ApexPages.StandardController controller) {
        
        //Setting the flags to false.
        
        showError = false;
        showIframe = false;     
        isGenerateOutput = false; // This flag is used to show QOG in an iFrame.Rest of other button actions skips iFrame ans show in a new tab
        
        // Get everything ready so we have all the correct parameters to build the URLs to access AFLS.     
        
        if ( ApexPages.currentPage().getParameters().get('iframetarget') == 'aflsnewquote'){
                                  
            // Get the Opportunity details so we can work out what parameters to send to AFLS.
            
            strOpportunityID = ApexPages.currentPage().getParameters().get('oppId');
            opportunityObj = [ SELECT Id, Account.SCV_Code__c, Account.Name, Account.SCV_Status__c, Liner_Brand__c, Account.is_Draft_Account__c, 
                                Opportunity_Ref__c, StageName, CloseDate, Primary_Contact__c, Primary_Contact__r.Email, Primary_Contact__r.Duplicate_Email__c                                                    
                                FROM Opportunity 
                                WHERE Id = : strOpportunityID 
                                LIMIT 1 ];  
                                
            User loggedInUser = [SELECT Id, MLL__c FROM User WHERE Id=:UserInfo.getUserId()]; //#RQ-012758
            
            if(!validationCheck(opportunityObj)){   //Check for validations.
                
                showIframe = true;                                     
               
                //#RQ-001889-Start: Added carrier codes based on liner brands
                String carrierCode;
                
                if (loggedInUser.MLL__c == true) { //#RQ-012758
                    carrierCode = BrandUtilities.getBrandOperatorCode(BrandUtilities.MLL);
                } else {
                    carrierCode = BrandUtilities.getBrandOperatorCode(opportunityObj.Liner_Brand__c);
                }
                
                // START OF FORMING THE LINK FOR CREATING A NEW QUOTE...
                                
                iFrameSrc = System.Label.AFLS_Server_Link + '?pageName=NewQuote'; 
                iFrameSrc = iFrameSrc + '&carrierId=' +carrierCode;        //#RQ-001503 Liner brand hardocdeing removed             
    
                
                // Get the values from the Opportunity to pass to AFLS which should be URL encoded...
                
                if ( String.isNotEmpty( opportunityObj.Account.SCV_Code__c ) ){            
                    
                    iFrameSrc = iFrameSrc + '&customerId=' + EncodingUtil.urlEncode( opportunityObj.Account.SCV_Code__c, 'UTF-8'); 
                
                }else{  
                    
                    String twentyCharAcctNameStr;
                    if( opportunityObj.Account.Name.length() > 20 )
                       
                        twentyCharAcctNameStr = opportunityObj.Account.Name.subString(0,20);
                    
                    else
                        
                        twentyCharAcctNameStr = opportunityObj.Account.Name;
                    
                    iFrameSrc = iFrameSrc + '&customerId=' + EncodingUtil.urlEncode( twentyCharAcctNameStr, 'UTF-8'); 
                }
                        
                    iFrameSrc = iFrameSrc + '&opportunityId=' + EncodingUtil.urlEncode(opportunityObj.Opportunity_Ref__c, 'UTF-8');
                    iFrameSrc = iFrameSrc + '&requestedCurrency=' +  EncodingUtil.urlEncode( 'USD', 'UTF-8');     
                    
                // Convert SFDC DRAFT Account to AFLS PROVISIONAL Quote...
                
                if ( String.isNotEmpty( opportunityObj.Account.is_Draft_Account__c ) )  
                       
                        iFrameSrc = iFrameSrc + '&provisionalCustomer=' + opportunityObj.Account.is_Draft_Account__c;                     
                                                                      
           } 
           
        } else if ( ApexPages.currentPage().getParameters().get('iframetarget') == 'qog' ){
                 
                /*
                * START OF FORMING THE LINK FOR PRINTING A QUOTE...
                */                              
                
                strQuoteID = ApexPages.currentPage().getParameters().get('quoteId');
                aflsQuoteObj = getQuoteDetails( strQuoteID ); 
                showIframe = true; 
                isGenerateOutput = true;         
                
                iFrameSrc = System.Label.Doc_Output_Engine_Server_Link;
                
                iFrameSrc = iFrameSrc + '?CallerID=SFDC';
                
                if ( String.isNotEmpty( aflsQuoteObj.Qt_Quote_Id__c ) ) 
                   
                    iFrameSrc = iFrameSrc + '&QuoteID='+ EncodingUtil.urlEncode( aflsQuoteObj.Qt_Quote_Id__c, 'UTF-8');
                
                iFrameSrc = iFrameSrc + '&QuoteKey=' + aflsQuoteObj.Qt_Quote_Key__c;  
                    
                if(aflsQuoteObj.Opportunity__c != null){    //Bypassing the query since Opportunity will be null for Orphan Quotes
                
                    opportunityOwner = [ SELECT Id, FirstName, LastName, Phone, MobilePhone, Fax, Email, Street, City, State, PostalCode, Country, 
                                            Liner_Brand__c,Region__c 
                                            FROM User 
                                            WHERE Id = :aflsQuoteObj.Opportunity__r.OwnerId 
                                            LIMIT 1 ];         
                                              
                                
                        if ( String.isNotEmpty( opportunityOwner.FirstName ) )
                            iFrameSrc = iFrameSrc + '&SalesPFName='+ EncodingUtil.urlEncode( opportunityOwner.Firstname, 'UTF-8');
                       
                        iFrameSrc = iFrameSrc + '&SalesPLName='+ EncodingUtil.urlEncode( opportunityOwner.LastName, 'UTF-8');
                        iFrameSrc = iFrameSrc + '&SalesPEmail='+ EncodingUtil.urlEncode( opportunityOwner.Email, 'UTF-8');
                       
                        if ( String.isNotEmpty( opportunityOwner.Phone ) )
                           
                            iFrameSrc = iFrameSrc + '&SalesPTele='+ EncodingUtil.urlEncode( opportunityOwner.Phone, 'UTF-8');
                    
                        if ( String.isNotEmpty( opportunityOwner.MobilePhone ) )
                        
                            iFrameSrc = iFrameSrc + '&SalesPMob='+ EncodingUtil.urlEncode( opportunityOwner.MobilePhone, 'UTF-8');                
                       
                        if ( String.isNotEmpty( opportunityOwner.Fax ) )
                            
                            iFrameSrc = iFrameSrc + '&SalesPFax=' + EncodingUtil.urlEncode( opportunityOwner.Fax, 'UTF-8');
                        
                        if ( String.isNotEmpty( opportunityOwner.Region__c ) )    {            
                            
                            iFrameSrc = iFrameSrc + '&SalesPOffice='+ EncodingUtil.urlEncode( opportunityOwner.Region__c + ',', 'UTF-8');
                        // Start of RQ-004136
                        }else{
                            iFrameSrc = iFrameSrc + '&SalesPOffice=';
                        }
                        //End of RQ-004136
                        
                        if ( String.isNotEmpty( opportunityOwner.Street ) )
                            
                            iFrameSrc = iFrameSrc + EncodingUtil.urlEncode( opportunityOwner.Street + ',', 'UTF-8');
                       
                        if ( String.isNotEmpty( opportunityOwner.City ) )
                           
                            iFrameSrc = iFrameSrc + EncodingUtil.urlEncode( opportunityOwner.City + ',', 'UTF-8');
                       
                        if ( String.isNotEmpty( opportunityOwner.State ) )
                            
                            iFrameSrc = iFrameSrc + EncodingUtil.urlEncode( opportunityOwner.State + ',', 'UTF-8');
                       
                        if ( String.isNotEmpty( opportunityOwner.PostalCode ) )
                            
                            iFrameSrc = iFrameSrc + EncodingUtil.urlEncode( opportunityOwner.PostalCode + ',', 'UTF-8');
                       
                        if ( String.isNotEmpty( opportunityOwner.Country ) )
                            
                            iFrameSrc = iFrameSrc + EncodingUtil.urlEncode( opportunityOwner.Country, 'UTF-8');
                            
                    }
                    
                }
                
             
                
                
                /*
                * When standard edit button is clicked, no parameters can be passed along with URL.
                * For all other URLs iframetarget parameter is being passed.Therefore iframetarget null is being
                * checked to identify Edit button action. 
                */
                else if ( ApexPages.currentPage().getParameters().get('iframetarget') == 'null' ){ //When Edit button is clicked on AFLS Quote
                    
                    strQuoteID = controller.getId();
                    aflsQuoteObj = getQuoteDetails( strQuoteID );
                    //User userRec = [SELECT Id, Quoting_Tool__c FROM User WHERE Id = : UserInfo.getUserId()];   //Commented as part of RQ-002950                                     
                    
                    //Checking whether the user is AFLS o 'Both' User. If not, show error message.
                    
                  //  if(userRec.Quoting_Tool__c == 'AFLS'  ){//#RQ-001503  Condition modified to != ' Quote builder to accommodate bothe AFLS and Bothe values'
                    //if(userRec.Quoting_Tool__c !=  Label.Quote_Builder_Label ){ // -- Commented as part of RQ-002950
                  
                        
                        /*
                        * START OF FORMING THE LINK FOR EDITING A QUOTE... 
                        */                  
                        showIframe = true;
                    
                        iFrameSrc = System.Label.AFLS_Server_Link + '?pageName=SavedQuote';                               
                        if ( String.isNotEmpty( aflsQuoteObj.Qt_Carrier__c ) )                  
                            iFrameSrc = iFrameSrc  +'&carrierId=' + aflsQuoteObj.Qt_Carrier__c;  
                        if ( String.isNotEmpty( aflsQuoteObj.Qt_Customer_Code__c ) )    
                           iFrameSrc = iFrameSrc + '&customerId=' +  EncodingUtil.urlEncode(aflsQuoteObj.Qt_Customer_Code__c, 'UTF-8');            
                        iFrameSrc = iFrameSrc + '&quoteId='  +  EncodingUtil.urlEncode(aflsQuoteObj.Name, 'UTF-8');
                        
                        // Convert SFDC DRAFT Account to AFLS PROVISIONAL Quote...
                        
                        if ( String.isNotEmpty( aflsQuoteObj.Opportunity__r.Account.is_Draft_Account__c ) ) 
                            iFrameSrc = iFrameSrc + '&provisionalCustomer=' + aflsQuoteObj.Opportunity__r.Account.is_Draft_Account__c;                     
                                              
                   //Commented as part of RQ-002950
                   /* }
                    else{
                    
                        //If not an AFLS User show error message
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.AFLS_Quote_Edit_Error));
                        
                    }*/
              } 
              System.debug('####IframeSRC###'+iFrameSrc );
    }
    
    
    
    
    /**
    * Get the details of a Quote.
    */
    public Qt_Quote__c getQuoteDetails( String quoteId ){
    
        Qt_Quote__c quote = [ SELECT Id, Name, Qt_Quote_Id__c, Qt_Quote_Key__c, Qt_Carrier__c, Qt_Customer_Code__c, Opportunity__r.Account.is_Draft_Account__c, Opportunity__r.OwnerId
                             FROM Qt_Quote__c 
                             WHERE Id = :quoteId 
                             LIMIT 1 ];
                            
        return quote;
    
    }
    
   
   
    /**
    * Go back to the Opportunity.
    */
    public pageReference BackToOpportunityClick(){
    
        PageReference oppPage = new PageReference('/'+ strOpportunityID);
        oppPage.setRedirect(true);
        return oppPage;     
    } 
     
     
     
    /**
    * Go back to the Quote.
    */
    public pageReference BackToQuoteClick(){
    
        PageReference oppPage = new PageReference('/'+ strQuoteID);
        oppPage.setRedirect(true);
        return oppPage;
    } 
    
    
    
    /**
    * Check for validations.
    * If any error, show error message. Else go to AFLS page
    */
    public Boolean validationCheck(Opportunity opportunityObj){
        Boolean showError = true;
        if(opportunityObj.CloseDate< Date.Today()) //If Opportunity closed date is passed, show error message.
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.QuoteClosedOpportunityValidation));
            
        }
         else if(opportunityObj.StageName == Label.close_won || opportunityObj.StageName == Label.Closed_lost) //If stagename is closed won/closed lost, show error message.
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.QuoteClosedOpportunityErr));
        
        }
        else  if(opportunityObj.Account.SCV_Status__c == 'Inactive') // If Account SC status is 'Inactive' show error message.
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.QuoteInActiveAccountErr));
        
        }
        
        // #PR-00031_2: Added check for duplicate email of primary contact
        else if(opportunityObj.Primary_Contact__c == null )
        {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.QuoteOpportunityPrimaryContactErr));
        
        }
        else{
            showError = false;
        }
        return showError;
    }
    
    
    
    
    /**
    * Redirect to new URL
    */
     public PageReference redirectToNewURL(){
     
        System.debug('##### iFrameSrc'+iFrameSrc);
        
        if(showiFrame && !(showError) && !(isGenerateOutput)){
            
            PageReference pageRef = new PageReference(iFrameSrc);
            pageRef.setRedirect(true);
            return pageRef ;
        }
        else{
            return null;
        }

     }  
    
}