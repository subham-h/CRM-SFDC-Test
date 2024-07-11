/********************************************************
Name : renewalOppReminderNotifyEmail

Author : Arpitha J

Description : Apex class associated with RenewalOppNotifyEmail.

*********************************************************/
public class RenewalOppReminderNotifyEmail{
    public Id accountId{get;set;}
    public Id renewalOppRecId{get;set;}
    public string renewalOppRecUrl{get;set;}
    public String renewalParentOppId{get;set;}
    public string accountName{get;set;}
    public String closedDate{get;set;}
    public string oppName{get;set;}
    public string renewalParentOppName{get;set;}
    public String oppAgreementEndDate{get;set;}
    public String renewalOppOwnerName{get;set;}
    Public String renewalParentOppContractNumber{get;set;}
    public string xDays{get;set;}
    public String serializedProductQuantitiesList;
    public Set<String> productList{get;set;}
    public String maerskLogo{get;set;}
    public String salesforceLogo { get;set;}
    
    public RenewalOppReminderNotifyEmail(){
        productList = new Set<String>();
        renewalOppRecId = ApexPages.currentPage().getParameters().get('renewalOppRecId');
        renewalOppOwnerName = ApexPages.currentPage().getParameters().get('renewalOppOwnerName');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        accountName = [Select id,name from Account where id=:accountId].name;
        closedDate = ApexPages.currentPage().getParameters().get('closeddate');
        oppName = ApexPages.currentPage().getParameters().get('oppName');
        renewalParentOppName = ApexPages.currentPage().getParameters().get('renewalParentOppName');
        renewalParentOppId = ApexPages.currentPage().getParameters().get('renewalParentOppId');
        oppAgreementEndDate = ApexPages.currentPage().getParameters().get('oppAgreementEndDate');
        xDays = ApexPages.currentPage().getParameters().get('xDays');
        renewalParentOppContractNumber = ApexPages.currentPage().getParameters().get('renewalParentOppContractNumber');
        if(renewalParentOppId!=null){
            for(opportunity_product__c opp : [SELECT Product2ID__r.name,OpportunityId__c FROM opportunity_product__c WHERE OpportunityId__c =:renewalParentOppId]){
                productList.add(opp.Product2ID__r.name);
            }
        }
        
        renewalOppRecUrl = URL.getOrgDomainURL().toExternalForm() + '/' + renewalOppRecId;
        Blob imageDataMaerskLogo = [SELECT Body FROM StaticResource WHERE Name = 'MaerskLogo'].Body;
        maerskLogo = EncodingUtil.base64Encode(imageDataMaerskLogo);
        Blob imageDataSalesforceLogo = [SELECT Body FROM StaticResource WHERE Name = 'SalesforceLogo'].Body;
        salesforceLogo = EncodingUtil.base64Encode(imageDataSalesforceLogo);
    }
    
    //Wrapper class to store parent product ans parent quantities
    public class productQuantities{
        public String parentProduct{get;set;}
        public String parentQuantities{get;set;}
        
        public productQuantities(String parentProd,String parentQuantity){
            parentProduct = parentProd;
            parentQuantities = parentQuantity;
        }
    }
    
 }