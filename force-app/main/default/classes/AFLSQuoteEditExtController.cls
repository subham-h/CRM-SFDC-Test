/**
* This extension class is used for editing AFLS Quote by AFLS user and Quote Builder user.
* When Quote Builder user edits AFLS Quote, it will throw error message
*
* 04/08/2014 jagadeesan.sakthivel@ust-global.com, code created as part of #Upstream.
* 03/03/2017 deepak.r.mahapatra@in.ibm.com #RQ-004643: Delete Quoting Tool Field in the User object 
*/

public class AFLSQuoteEditExtController {

 //public User userRec{get;set;}  //#RQ-004643
 public String strQuoteID {get;set;}
 
    public AFLSQuoteEditExtController(ApexPages.StandardController controller){
        strQuoteID = controller.getId();
       // userRec = [SELECT Id, Quoting_Tool__c FROM User WHERE Id = : UserInfo.getUserId()];  #RQ-004643
                
    }
    
    public PageReference redirectPage(){
    
        String url;
        //if( userRec.Quoting_Tool__c == 'Quote Builder')  // #RQ-004643
           // url = '/apex/AFLSQuoteEditErrorMsg?id='+strQuoteID; // #RQ-004643
        //else // #RQ-004643
            url = '/apex/AFLSQuoteEditPage?id='+strQuoteID+'&retUrl='+ApexPages.CurrentPage();
        PageReference pageRef = new PageReference(url); 
        pageRef.setRedirect(true);
        return pageRef; 
        
    }
}