/*              
 * Revision Ref Number  Date          Owner                   Description
 * -------- ----------  -----------   -----------------       -----------
 * 1.0 		SFSE-11233	23-June-2023  Vinay					  Controller for OneClickOfferConfirmationEmailTemplate VF page		
 * 2.0 		SFSE-11769	28-June-2023  Seba					  Modified the code to display unique the product names correctly	
*/
public class OneClickOfferConfirmationEmailCtrl {
    public String productNames {get; set;}
    public Opportunity opty{get;set;}
    public String opportunityId;
    public String agreementStartDate {get; set;}
    public String agreementEndDate {get; set;}
    public String contactName{get;set;}
    public String offersentby{get;set;}
    
    // Constructor
    public OneClickOfferConfirmationEmailCtrl(){
     	opportunityId = ApexPages.currentPage().getParameters().get('optyId');
		contactName = ApexPages.currentPage().getParameters().get('name');
        offersentby = ApexPages.currentPage().getParameters().get('offercreatedby');
        productNames = ''; //SFSE-11769
        
        if(opportunityId!=NULL){
        opty =[SELECT Id,First_Shipment_Date__c,Last_Shipment_Date__c, (SELECT Id, Product2ID__r.name from Opportunity_Products__r) FROM Opportunity WHERE Id=:opportunityId];}
        
        if(opty!=NULL && opty.Opportunity_Products__r.size()>0){
            for(Opportunity_Product__c line: opty.Opportunity_Products__r){                
               //SFSE-11769
               if(!productNames.contains(line.Product2ID__r.Name)){
                    if(productNames == '')
                        productNames += line.Product2ID__r.Name;
                    else 
                        productNames += ', '+line.Product2ID__r.Name;
               }   
            }
        } 
       if(opty!=NULL && opty.First_Shipment_Date__c != null){
            Date agreementfirstDt = opty.First_Shipment_Date__c;   
        	DateTime dt = DateTime.newInstance(agreementfirstDt.year(),agreementfirstDt.month(),agreementfirstDt.day()); 
        	agreementStartDate = agreementfirstDt.day() + ' ' + dt.format('MMMM') + ' ' + agreementfirstDt.year();
        }
        
        if(opty!=NULL && opty.Last_Shipment_Date__c != null){
          Date agreementEndDt = opty.Last_Shipment_Date__c;   
          DateTime endDt = DateTime.newInstance(agreementEndDt.year(),agreementEndDt.month(),agreementEndDt.day()); 
          agreementEndDate = agreementEndDt.day() + ' ' + endDt.format('MMMM') + ' ' + agreementEndDt.year();   
        }
        
    }
}