/********************************************************
Name : renewalOppNotifyEmail

Author : Arpitha J

Description : Apex class retrive table data.

*********************************************************/
public class RenewalOppNotifyEmail{
    public Id OpportunityId{get;set;}
    public Id oppId{get;set;}
    public Id renewalParentOppId;
   
    //To retrive the Opportunity Records
    public Opportunity getOpp(){
        Opportunity opp= [Select id,Owner.Name,Account.Name,Name,Parent_Opportunity__c,Parent_Opportunity__r.Name,Parent_Opportunity__r.Current_Contract_Number__c,Parent_Opportunity__r.Last_Shipment_Date__c from Opportunity where id=:OpportunityId];
        renewalParentOppId = opp.Parent_Opportunity__c;
        return opp;
    }
    
    //To retrive the Maersk Logo
    public String getMaerskLogo(){
        String maerskLogo;
        Blob imageDataMaerskLogo = [SELECT Body FROM StaticResource WHERE Name = 'MaerskLogo'].Body;
        maerskLogo = EncodingUtil.base64Encode(imageDataMaerskLogo);
        return  maerskLogo;
    }
    
    //To retrive the Salesforce Logo
    public String getSalesforceLogo(){
        String salesforceLogo;
        Blob imageDataSalesforceLogo = [SELECT Body FROM StaticResource WHERE Name = 'SalesforceLogo'].Body;
        salesforceLogo = EncodingUtil.base64Encode(imageDataSalesforceLogo);
        return  salesforceLogo;
    }
    
    //To Construct the Opp Link
    public string getRenewalOppRecUrl(){
        String renewalOppRecUrl = URL.getOrgDomainURL().toExternalForm() + '/' + OpportunityId;
        return renewalOppRecUrl;
    }
    
    //To Construct the Renewal Parent Opp Link
    public string getRenewalParentOppRecUrl(){
        String renewalParentOppRecUrl = URL.getOrgDomainURL().toExternalForm() + '/' + renewalParentOppId;
        return renewalParentOppRecUrl;
    }
    
    //To retrive the Opportunity Product
    public Set<String> getproductList(){
        Set<String> productList = new Set<String>();
        if(renewalParentOppId!=null){
            for(opportunity_product__c opp : [SELECT Product2ID__r.name,OpportunityId__c FROM opportunity_product__c WHERE OpportunityId__c =:renewalParentOppId]){
                productList.add(opp.Product2ID__r.name);
            }
        }
        return productList;
    }
     
    public RenewalOppNotifyEmail(){ 
    }
    
    
 }